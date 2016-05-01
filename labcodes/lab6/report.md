### 练习1

- 请理解并分析sched_calss中各个函数指针的用法，并接合Round Robin 调度算法描ucore的调度执行过程


sched_class如下：

	struct sched_class {
    // the name of sched_class
    const char *name;
    // Init the run queue
    void (*init)(struct run_queue *rq);
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
	};
    
其中 name 表示sched_class的名字
init 表示初始化run队列
enqueue表示让一个proc进入run队列
dequeue表示让一个proc退出run队列
pick_next表示选择下一个可运行的任务
proc_tick表示处理time-tick时间的函数

ucore在调度时，会进入sched.c中定义的若干static函数，通过这些函数进入具体的sched_class，然后调用sched_class中的enqueue,dequeue和pick_next等函数。这里默认的是RR_scheduler，所以都通过这种接口的方式调用到了RR的调度方案。

- 请在实验报告中简要说明如何设计实现”多级反馈队列调度算法“，给出概要设计，鼓励给出详细设计

这里主要的麻烦在于如何使用多个队列，注意到sched.c中的rq的传入sched_class->proc_tick(rq, proc);，其中rq是一个静态变量run_queue。

为了实现多级反馈队列，我们需要对run_queue做调整，使得其中包括多个队列，新建一个struct

    struct multi_run_queue {
        run_queue *run_lists;
    };
    
实现时，应该要在init中选择初始化多少个run_queue，也就是有多少级，以及每一个run_queue的max_time_slice如何设置(2^h*t0)

在enqueue时插入到高优先级中，dequeue删除对应run_queue中的proc。
以及当一个线程没有执行完时，例如调用wakeup_proc时，将其放入到低优先级中，为了接口化，我们应该在sched_class中提供一个借口，表示更改某个proc的优先级，例如void (*change_priority)(struct multi_run_queue, struct proc_struct *proc, int priority);
当然，proc中也不应该只有rq，还应该有multi_run_queue mrq。

### 练习2

在sched.h中需要添加void sched_class_proc_tick(struct proc_struct *proc);以及在sched.c中对于对应函数删除static，否则无法在trap.c中调用该函数。

BIG_STRIDE 不应该超过int范围的一半，也就是0x7FFFFFFF，否则无法判断lab6_priority的大小关系。

使用skew_heap中的函数来完成相应的选最小和插入操作。
当插入一个新的proc时，插入倒对应的堆中，然后判断是否有合法的时间片否则赋值位最大的时间片，改变run_pool来记录最小的proc。
删除一个proc时，在堆中删除这个proc，改变run_pool来记录最小的proc。
当需要选择下一个RUNNABLE的proc时，使用run_pool来选择要返回的proc，同时把他的步长加上。

而proc_tick则和RR是一样的，如果有时间片那么-1，否则进行把need_schedule改成1表示进行调度。
