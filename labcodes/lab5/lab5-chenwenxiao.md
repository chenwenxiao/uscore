### 练习0

对于LAB1/2/3/4的内容加入了LAB5，并且有增删改，见具体代码

### 练习1

按照注释中提示的内容对于tf中对应的变量进行赋值

第一个用户进程是由第二个内核线程initproc通过把应用程序执行码覆盖到initproc的用户虚拟内存空间来创建的

中间由于产生了多次bug，我对于KERNEL_EXECVE进行了多次跟踪，在这里会进行输出，然后进入kernel_execve，然后使用SYSCALL的方式进行，中间会经理trap的流程（alltrap，trap，dispatch）之后在syscall中进入sys_exec，到do_execve，在这里会进行对proc的各种信息的处理，例如内存空间的设置等，而load_icode会为用户进程建立一个能够让用户进程正常运行的用户环境。之后一路return。

在trapentry.S中

    # get rid of the trap number and error code
    addl $0x8, %esp
    iret
    
中会返回到应用程序的第一句

### 练习2

在copy_range中实现了page到page的copy，之后插入到了page的list中。

COW机制在这次代码中已经实现了，参考vmm和pmm中对应Challenge部分的注释，解注释后即可实现。

我是这么设计的，在copy_range时仅将page对应的PTE_W设置为不可读，之后如果产生了页错误，那么检查页错误的详细信息，如果该页存在并且不可读，那么就是实现COW机制的时候，也就是将该页复制，并将page的list中对应的页替换为新创建的页，复制页的方式和原先copy_range中是一样的

### 练习3

fork: 复制线程
exec: 执行线程
wait: 等待线程完成
exit: 退出当前线程

在实现中，fork会创建一个以当前线程为蓝本复制而成的线程；exec则会改变线程的状态；wait会将线程挂起，直到等待条件完成时再唤醒线程；exit则会将线程从线程list中移除，并且唤醒其他等待的线程。

周期图：

    process state changing:

      alloc_proc                                 RUNNING
          +                                   +--<----<--+
          +                                   + proc_run +
          V                                   +-->---->--+
    PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                               A      +                                                           +
                                               |      +--- do_exit --> PROC_ZOMBIE                                +
                                               +                                                                  +
                                               -----------------------wakeup_proc----------------------------------

### Challenge

参见练习2，对应的代码可以在注释中查看到，需要按照注释修改成Challenge后的版本。

但是由于不知道怎样才算通过了Challenge（没有对应的grade），我只能自己认为我做对了。