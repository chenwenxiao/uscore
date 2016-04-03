#Lab3

##练习1
page directory是所有page相关内容的入口，无论要访问哪一个page，都需要从pgdir开始访问
而页表则有多个用处
- 如果页目录中该页表的索引为NULL，那么说明不允许访问这一页表，或者这一页表不存在
- 如果页表为0，那么说明该页表未被分配空间，需要分配页表空间

页目录和页表可以在ucore的页替换算法中起到基本的索引作用，而且在发现页缺失时起到调用页替换函数的作用

如果在缺页服务在执行过程中又出现了页访问异常，硬件应该立即停止当前的操作，并保留现场，然后转入异常处理，设置缺页终端和对应的标志位。操作系统调用异常处理时需要通过硬件来换入换出外存中的页。

##练习2
不支持，由于缺少对应的借口，在extend clock算法中，需要知道一次访问是修改还是只读的，需要拓展函数swap_in参数
而记录标志位的位置应该是在Page中，需要扩展Page出两个bit来记录修改位和访问位
在vmm.c的do_pgfault中，如果对应的page存在或者被分配了（即不直接goto failed），那么需要跳动update函数，用于 维护Page的标记位，每次的update，会将Page对应的标志位修改，这个接口应该存在在swap_manager中

- 换出的页的访问位和修改位均为0
- 需要在swap_out_victim中进行环状的循环，直至找到访问位和修改位均为0的页，否则按照extend clock算法对于访问位和修改位进行置0
- 需要换入时，是产生了缺页并且该页在外存中；需要换出时，是已有的页超出了系统规定页大小

接口如下：

  struct swap_manager
  {
       const char *name;
       /* Global initialization for the swap manager */
       int (*init)            (void);
       /* Initialize the priv data inside mm_struct */
       int (*init_mm)         (struct mm_struct *mm);
       /* Called when tick interrupt occured */
       int (*tick_event)      (struct mm_struct *mm);
       /* Called when map a swappable page into the mm_struct*/
       int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
       /* Called when need update page, update_kind is read or write*/
       int (*map_update)      (struct mm_struct *mm, struct Page *ptr_page, int update_kind);
       /* When a page is marked as shared, this routine is called to
        * delete the addr entry from the swap manager*/
       int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);
       /* Try to swap out a page, return then victim */
       int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);
       /* check the page relpacement algorithm */
       int (*check_swap)(void);     
  };
