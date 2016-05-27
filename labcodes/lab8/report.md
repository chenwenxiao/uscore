### LAB REPORT

#### EXERCISE 1

UNIX的PIPE机制的详细设计方案：

首先，我们应当提供一种特殊的文件类型：FIFO，以便建立命名通道。比较简单的方法是在

    /* inode (on disk) */
    struct sfs_disk_inode {
        uint32_t size;                                  /* size of the file (in bytes) */
        uint16_t type;                                  /* one of SYS_TYPE_* above */
        uint16_t nlinks;                                /* # of hard links to this file */
        uint32_t blocks;                                /* # of blocks */
        uint32_t direct[SFS_NDIRECT];                   /* direct blocks */
        uint32_t indirect;                              /* indirect blocks */
    //    uint32_t db_indirect;                           /* double indirect blocks */
    	uint32_t isFIFO;
    //   unused
    };

中增加isFIFO这一个参数，当然这样有些浪费空间，但是如果直接修改type，那么可能会由于FIFO的type不是FILE而带来一系列的问题，这里我们直接新增一个参数isFIFO。当其为1时表示这是一个FIFO文件。在创建或者删除时，FIFO文件和其他文件无异，只是要特别加入参数isFIFO罢了，当真正读写FIFO文件时，我们应该做一些修改。

在sfs_io我们看到，最终的读写都会进入sfs_io_nolock，也就是我们在EXERCISE 1中修改的代码部分：

    static inline int
    sfs_io(struct inode *node, struct iobuf *iob, bool write) 

那么，我们在sfs_io_nolock中，判断din的isFIFO，决定要使用的读写函数：

    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, uint32_t blkno, uint32_t nblks);
    if (din->isFIFO) {
    	if (write) {
            sfs_buf_op = sfs_FIFO_wbuf, sfs_block_op = sfs_FIFO_wblock;
        }
        else {
            sfs_buf_op = sfs_FIFO_rbuf, sfs_block_op = sfs_FIFO_rblock;
        }
    } else{
        if (write) {
            sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
        }
        else {
            sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
        }
    }

这里我们更改了sfs_buf_op和sfs_block_op两个函数指针，使其能够指向我们需要的隧道读写函数，那么在之后的部分就可以直接使用EXERCISE 1的代码了。在sfs_FIFO_wbuf和sfs_FIFO_rbuf等函数中，将对于文件系统的读写，更改为对于内存中某一特定段的读写：

    int
    sfs_FIFO_rbuf(struct sfs_fs *sfs, void *buf, size_t len, uint32_t blkno, off_t offset) {
        assert(offset >= 0 && offset < SFS_BLKSIZE && offset + len <= SFS_BLKSIZE);
        int ret;
        lock_sfs_io(sfs);
        {
            if ((ret = sfs_rwblock_nolock(sfs, sfs->sfs_buffer, blkno, 0, 1)) == 0) {
                memcpy(buf, sfs->sfs_FIFO_buffer + offset, len);
            }
        }
        unlock_sfs_io(sfs);
        return ret;
    }

这里是以读举例的，写也是一样，当然这里还需要给文件系统上锁是有原因的，因为如果这里上了锁其他的线程不能同时从文件系统读写了，但是这样可以保证安全，因为就算是PIPE机制，也有可能两者同时读写同一段，这样就有冲突了，这里通过对于文件系统的锁来解决这种冲突。至于sfs_sfs_FIFO_buffer是一段内存中的给FIFO文件预留的内存段，最后需要在file_pipe中加入创建FIFO文件，这样就实现了PIPE机制了。

#### EXERCISE 2

设计实现基于”UNIX的硬链接和软链接机制“的详细设计方案。

首先我们需要修改inode，使得链接机制可以实现。

	struct inode {
        union {
            struct device __device_info;
            struct sfs_inode __sfs_inode_info;
            struct sfs_inode __target_inode_info;
        } in_info;
        enum {
            inode_type_device_info = 0x1234,
            inode_type_sfs_inode_info,
        } in_type;
        int ref_count;
        int open_count;
        struct fs *in_fs;
        const struct inode_ops *in_ops;
	};

增加了一个\__target_inode_info，表示软连接时指向的sfs_inode，在对软连接操作时，只需要将对于\__sys_inode_info的操作都改为对于\__target_inode_info的操作即可。

当然在sfs_disk_inode中需要对于type == SFS_TYPE_LINK时增加一些操作，如设置软连接等等都需要更改type属性，以及设置inode中的\__target_inode_info属性。

详细的说，在创建时需指定type为SFS_TYPE_LINK而\__target_inode_info指向目标文件；在open，write时将对于\__sfs_inode_info的操作全部改为对\__target_sfs_inode_info的操作即可；最后需要注意的就是ref_count的增减。

实现硬链接则较为简单仿照file.c/file_open一样，新增函数file_link表示硬链接。当发现目标文件存在时，需要再创建一个不同的filename但是指向同一个inode的硬链接。

在vfsfile.c/vfs_open中，使用了vfs_lookup来查找对应文件名的inode，而vfs_lookup又调用了vop_lookup，最后进入sys_lookup->sys_look_up_once->sfs_dirent_search_nolock。
在这里面我们发现对于name的查找就是遍历并且比较name与entry->name。那么我们需要创建一个entry，这个entry的inode和目标文件的inode相同，但是拥有不同的filename。

那么具体的步骤就是通过sfs_dirent_search_nolock可以获取到目标文件的entry，得到它的entry->ino，之后在创建一个entry，其name等于链接文件的name，而ino和目标文件的ino相同。