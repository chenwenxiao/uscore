# LAB7 REPORT

#### Exercise 1

内核级信号量的描述在sem.h中有如下定义：

	typedef struct {
    	int value;
    	wait_queue_t wait_queue;
	} semaphore_t;

其中value表示剩余资源数，wait_queue则是则等待这个信号量的相应的等待序列。

提供如下函数，分别是初始化，V操作，P操作，以及尝试P操作：

    void sem_init(semaphore_t *sem, int value);
    void up(semaphore_t *sem);
    void down(semaphore_t *sem);
    bool try_down(semaphore_t *sem);


执行流程：

1. 调用sem_init进行初始化
2. 调用down进行P操作，请求资源
3. 调用up进行V操作，释放资源

如果需要给用户态提供信号量，比较好的方法是提供一个系统调用的接口，例如sys_init,sys_up,sys_down，这三个函数，所需要的操作便是通过中断转到内核态处理，并且调用内核级信号量函数sem_init,up,down。

异同之处在于，用户态中并不存在直接的信号量，而是通过系统调用转到了内核态处理。而之后的部分和内核态完全相同了。

#### Exercise 2

条件变量和管程的定义如下：


    typedef struct condvar{
        semaphore_t sem;        // the sem semaphore  is used to down the waiting proc, and the signaling proc should up the waiting proc
        int count;              // the number of waiters on condvar
        monitor_t * owner;      // the owner(monitor) of this condvar
    } condvar_t;

    typedef struct monitor{
        semaphore_t mutex;      // the mutex lock for going into the routines in monitor, should be initialized to 1
        semaphore_t next;       // the next semaphore is used to down the signaling proc itself, and the other OR wakeuped waiting proc should wake up the sleeped signaling proc.
        int next_count;         // the number of of sleeped signaling proc
        condvar_t *cv;          // the condvars in monitor
    } monitor_t;

其中sen表示条件变量对应的信号量，因为这里的条件变量是基于信号量实现的。count表示等待条件变量的总数，owner表示所属的管程。

mutex表示进入管程的锁，next则是调用了cond_signal的进程所等待的锁，next_count表示等待next的进程总数，cv则是指向条件变量的指针。

大致的执行流程：
申请mutex锁，进入管程
调用cond_signal，临时将锁转交给正在wait的进程进行操作，直到其释放
调用cond_wait，等待某个条件变量的signal，当被signal时继续执行
释放mutex锁，离开管程

与Exercise 1类似，提供sys_signal和sys_wait两个系统调用，通过中断进入内核态，之后在内核态中调用对应的cond_signal和cond_wait函数即可。

