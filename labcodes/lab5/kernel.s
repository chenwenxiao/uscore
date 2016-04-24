
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 a0 12 00 	lgdtl  0x12a018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 a0 12 c0       	mov    $0xc012a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba b8 f0 19 c0       	mov    $0xc019f0b8,%edx
c0100035:	b8 2a bf 19 c0       	mov    $0xc019bf2a,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100049:	00 
c010004a:	c7 04 24 2a bf 19 c0 	movl   $0xc019bf2a,(%esp)
c0100051:	e8 96 bc 00 00       	call   c010bcec <memset>

    cons_init();                // init the console
c0100056:	e8 c0 16 00 00       	call   c010171b <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c010005b:	c7 45 f4 80 be 10 c0 	movl   $0xc010be80,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100062:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100065:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100069:	c7 04 24 9c be 10 c0 	movl   $0xc010be9c,(%esp)
c0100070:	e8 de 02 00 00       	call   c0100353 <cprintf>

    print_kerninfo();
c0100075:	e8 05 09 00 00       	call   c010097f <print_kerninfo>

    grade_backtrace();
c010007a:	e8 9d 00 00 00       	call   c010011c <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007f:	e8 c5 56 00 00       	call   c0105749 <pmm_init>

    pic_init();                 // init interrupt controller
c0100084:	e8 70 20 00 00       	call   c01020f9 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100089:	e8 c2 21 00 00       	call   c0102250 <idt_init>

    vmm_init();                 // init virtual memory management
c010008e:	e8 5b 86 00 00       	call   c01086ee <vmm_init>
    proc_init();                // init process table
c0100093:	e8 17 ac 00 00       	call   c010acaf <proc_init>
    
    ide_init();                 // init ide devices
c0100098:	e8 af 17 00 00       	call   c010184c <ide_init>
    swap_init();                // init swap
c010009d:	e8 78 6d 00 00       	call   c0106e1a <swap_init>

    clock_init();               // init clock interrupt
c01000a2:	e8 2a 0e 00 00       	call   c0100ed1 <clock_init>
    intr_enable();              // enable irq interrupt
c01000a7:	e8 bb 1f 00 00       	call   c0102067 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000ac:	e8 bd ad 00 00       	call   c010ae6e <cpu_idle>

c01000b1 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b1:	55                   	push   %ebp
c01000b2:	89 e5                	mov    %esp,%ebp
c01000b4:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000be:	00 
c01000bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c6:	00 
c01000c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000ce:	e8 30 0d 00 00       	call   c0100e03 <mon_backtrace>
}
c01000d3:	c9                   	leave  
c01000d4:	c3                   	ret    

c01000d5 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d5:	55                   	push   %ebp
c01000d6:	89 e5                	mov    %esp,%ebp
c01000d8:	53                   	push   %ebx
c01000d9:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000dc:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e2:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000ec:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f4:	89 04 24             	mov    %eax,(%esp)
c01000f7:	e8 b5 ff ff ff       	call   c01000b1 <grade_backtrace2>
}
c01000fc:	83 c4 14             	add    $0x14,%esp
c01000ff:	5b                   	pop    %ebx
c0100100:	5d                   	pop    %ebp
c0100101:	c3                   	ret    

c0100102 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100102:	55                   	push   %ebp
c0100103:	89 e5                	mov    %esp,%ebp
c0100105:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100108:	8b 45 10             	mov    0x10(%ebp),%eax
c010010b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100112:	89 04 24             	mov    %eax,(%esp)
c0100115:	e8 bb ff ff ff       	call   c01000d5 <grade_backtrace1>
}
c010011a:	c9                   	leave  
c010011b:	c3                   	ret    

c010011c <grade_backtrace>:

void
grade_backtrace(void) {
c010011c:	55                   	push   %ebp
c010011d:	89 e5                	mov    %esp,%ebp
c010011f:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100122:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100127:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012e:	ff 
c010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013a:	e8 c3 ff ff ff       	call   c0100102 <grade_backtrace0>
}
c010013f:	c9                   	leave  
c0100140:	c3                   	ret    

c0100141 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100141:	55                   	push   %ebp
c0100142:	89 e5                	mov    %esp,%ebp
c0100144:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100147:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014a:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014d:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100150:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100153:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100157:	0f b7 c0             	movzwl %ax,%eax
c010015a:	83 e0 03             	and    $0x3,%eax
c010015d:	89 c2                	mov    %eax,%edx
c010015f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c0100164:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100168:	89 44 24 04          	mov    %eax,0x4(%esp)
c010016c:	c7 04 24 a1 be 10 c0 	movl   $0xc010bea1,(%esp)
c0100173:	e8 db 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100178:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010017c:	0f b7 d0             	movzwl %ax,%edx
c010017f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c0100184:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100188:	89 44 24 04          	mov    %eax,0x4(%esp)
c010018c:	c7 04 24 af be 10 c0 	movl   $0xc010beaf,(%esp)
c0100193:	e8 bb 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100198:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010019c:	0f b7 d0             	movzwl %ax,%edx
c010019f:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ac:	c7 04 24 bd be 10 c0 	movl   $0xc010bebd,(%esp)
c01001b3:	e8 9b 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bc:	0f b7 d0             	movzwl %ax,%edx
c01001bf:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001c4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001cc:	c7 04 24 cb be 10 c0 	movl   $0xc010becb,(%esp)
c01001d3:	e8 7b 01 00 00       	call   c0100353 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d8:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001dc:	0f b7 d0             	movzwl %ax,%edx
c01001df:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001e4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ec:	c7 04 24 d9 be 10 c0 	movl   $0xc010bed9,(%esp)
c01001f3:	e8 5b 01 00 00       	call   c0100353 <cprintf>
    round ++;
c01001f8:	a1 40 bf 19 c0       	mov    0xc019bf40,%eax
c01001fd:	83 c0 01             	add    $0x1,%eax
c0100200:	a3 40 bf 19 c0       	mov    %eax,0xc019bf40
}
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	5d                   	pop    %ebp
c010020b:	c3                   	ret    

c010020c <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020c:	55                   	push   %ebp
c010020d:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010020f:	5d                   	pop    %ebp
c0100210:	c3                   	ret    

c0100211 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100211:	55                   	push   %ebp
c0100212:	89 e5                	mov    %esp,%ebp
c0100214:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100217:	e8 25 ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021c:	c7 04 24 e8 be 10 c0 	movl   $0xc010bee8,(%esp)
c0100223:	e8 2b 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_user();
c0100228:	e8 da ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022d:	e8 0f ff ff ff       	call   c0100141 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100232:	c7 04 24 08 bf 10 c0 	movl   $0xc010bf08,(%esp)
c0100239:	e8 15 01 00 00       	call   c0100353 <cprintf>
    lab1_switch_to_kernel();
c010023e:	e8 c9 ff ff ff       	call   c010020c <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100243:	e8 f9 fe ff ff       	call   c0100141 <lab1_print_cur_status>
}
c0100248:	c9                   	leave  
c0100249:	c3                   	ret    

c010024a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024a:	55                   	push   %ebp
c010024b:	89 e5                	mov    %esp,%ebp
c010024d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100250:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100254:	74 13                	je     c0100269 <readline+0x1f>
        cprintf("%s", prompt);
c0100256:	8b 45 08             	mov    0x8(%ebp),%eax
c0100259:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025d:	c7 04 24 27 bf 10 c0 	movl   $0xc010bf27,(%esp)
c0100264:	e8 ea 00 00 00       	call   c0100353 <cprintf>
    }
    int i = 0, c;
c0100269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100270:	e8 66 01 00 00       	call   c01003db <getchar>
c0100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100278:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010027c:	79 07                	jns    c0100285 <readline+0x3b>
            return NULL;
c010027e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100283:	eb 79                	jmp    c01002fe <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100285:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100289:	7e 28                	jle    c01002b3 <readline+0x69>
c010028b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100292:	7f 1f                	jg     c01002b3 <readline+0x69>
            cputchar(c);
c0100294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100297:	89 04 24             	mov    %eax,(%esp)
c010029a:	e8 da 00 00 00       	call   c0100379 <cputchar>
            buf[i ++] = c;
c010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a2:	8d 50 01             	lea    0x1(%eax),%edx
c01002a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002ab:	88 90 60 bf 19 c0    	mov    %dl,-0x3fe640a0(%eax)
c01002b1:	eb 46                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b7:	75 17                	jne    c01002d0 <readline+0x86>
c01002b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002bd:	7e 11                	jle    c01002d0 <readline+0x86>
            cputchar(c);
c01002bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c2:	89 04 24             	mov    %eax,(%esp)
c01002c5:	e8 af 00 00 00       	call   c0100379 <cputchar>
            i --;
c01002ca:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002ce:	eb 29                	jmp    c01002f9 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d4:	74 06                	je     c01002dc <readline+0x92>
c01002d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002da:	75 1d                	jne    c01002f9 <readline+0xaf>
            cputchar(c);
c01002dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002df:	89 04 24             	mov    %eax,(%esp)
c01002e2:	e8 92 00 00 00       	call   c0100379 <cputchar>
            buf[i] = '\0';
c01002e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ea:	05 60 bf 19 c0       	add    $0xc019bf60,%eax
c01002ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f2:	b8 60 bf 19 c0       	mov    $0xc019bf60,%eax
c01002f7:	eb 05                	jmp    c01002fe <readline+0xb4>
        }
    }
c01002f9:	e9 72 ff ff ff       	jmp    c0100270 <readline+0x26>
}
c01002fe:	c9                   	leave  
c01002ff:	c3                   	ret    

c0100300 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100300:	55                   	push   %ebp
c0100301:	89 e5                	mov    %esp,%ebp
c0100303:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100306:	8b 45 08             	mov    0x8(%ebp),%eax
c0100309:	89 04 24             	mov    %eax,(%esp)
c010030c:	e8 36 14 00 00       	call   c0101747 <cons_putc>
    (*cnt) ++;
c0100311:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100314:	8b 00                	mov    (%eax),%eax
c0100316:	8d 50 01             	lea    0x1(%eax),%edx
c0100319:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031c:	89 10                	mov    %edx,(%eax)
}
c010031e:	c9                   	leave  
c010031f:	c3                   	ret    

c0100320 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100326:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100330:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100334:	8b 45 08             	mov    0x8(%ebp),%eax
c0100337:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033b:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100342:	c7 04 24 00 03 10 c0 	movl   $0xc0100300,(%esp)
c0100349:	e8 df b0 00 00       	call   c010b42d <vprintfmt>
    return cnt;
c010034e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100351:	c9                   	leave  
c0100352:	c3                   	ret    

c0100353 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100353:	55                   	push   %ebp
c0100354:	89 e5                	mov    %esp,%ebp
c0100356:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100359:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010035f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100362:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100366:	8b 45 08             	mov    0x8(%ebp),%eax
c0100369:	89 04 24             	mov    %eax,(%esp)
c010036c:	e8 af ff ff ff       	call   c0100320 <vcprintf>
c0100371:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100377:	c9                   	leave  
c0100378:	c3                   	ret    

c0100379 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0100379:	55                   	push   %ebp
c010037a:	89 e5                	mov    %esp,%ebp
c010037c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010037f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100382:	89 04 24             	mov    %eax,(%esp)
c0100385:	e8 bd 13 00 00       	call   c0101747 <cons_putc>
}
c010038a:	c9                   	leave  
c010038b:	c3                   	ret    

c010038c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010038c:	55                   	push   %ebp
c010038d:	89 e5                	mov    %esp,%ebp
c010038f:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100392:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0100399:	eb 13                	jmp    c01003ae <cputs+0x22>
        cputch(c, &cnt);
c010039b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010039f:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003a6:	89 04 24             	mov    %eax,(%esp)
c01003a9:	e8 52 ff ff ff       	call   c0100300 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b1:	8d 50 01             	lea    0x1(%eax),%edx
c01003b4:	89 55 08             	mov    %edx,0x8(%ebp)
c01003b7:	0f b6 00             	movzbl (%eax),%eax
c01003ba:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003bd:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c1:	75 d8                	jne    c010039b <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ca:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d1:	e8 2a ff ff ff       	call   c0100300 <cputch>
    return cnt;
c01003d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003d9:	c9                   	leave  
c01003da:	c3                   	ret    

c01003db <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003db:	55                   	push   %ebp
c01003dc:	89 e5                	mov    %esp,%ebp
c01003de:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e1:	e8 9d 13 00 00       	call   c0101783 <cons_getc>
c01003e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ed:	74 f2                	je     c01003e1 <getchar+0x6>
        /* do nothing */;
    return c;
c01003ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f2:	c9                   	leave  
c01003f3:	c3                   	ret    

c01003f4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003fd:	8b 00                	mov    (%eax),%eax
c01003ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100402:	8b 45 10             	mov    0x10(%ebp),%eax
c0100405:	8b 00                	mov    (%eax),%eax
c0100407:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100411:	e9 d2 00 00 00       	jmp    c01004e8 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c0100416:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100419:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010041c:	01 d0                	add    %edx,%eax
c010041e:	89 c2                	mov    %eax,%edx
c0100420:	c1 ea 1f             	shr    $0x1f,%edx
c0100423:	01 d0                	add    %edx,%eax
c0100425:	d1 f8                	sar    %eax
c0100427:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010042d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100430:	eb 04                	jmp    c0100436 <stab_binsearch+0x42>
            m --;
c0100432:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100436:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100439:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010043c:	7c 1f                	jl     c010045d <stab_binsearch+0x69>
c010043e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100441:	89 d0                	mov    %edx,%eax
c0100443:	01 c0                	add    %eax,%eax
c0100445:	01 d0                	add    %edx,%eax
c0100447:	c1 e0 02             	shl    $0x2,%eax
c010044a:	89 c2                	mov    %eax,%edx
c010044c:	8b 45 08             	mov    0x8(%ebp),%eax
c010044f:	01 d0                	add    %edx,%eax
c0100451:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100455:	0f b6 c0             	movzbl %al,%eax
c0100458:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045b:	75 d5                	jne    c0100432 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010045d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100460:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100463:	7d 0b                	jge    c0100470 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100468:	83 c0 01             	add    $0x1,%eax
c010046b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010046e:	eb 78                	jmp    c01004e8 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100470:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100477:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047a:	89 d0                	mov    %edx,%eax
c010047c:	01 c0                	add    %eax,%eax
c010047e:	01 d0                	add    %edx,%eax
c0100480:	c1 e0 02             	shl    $0x2,%eax
c0100483:	89 c2                	mov    %eax,%edx
c0100485:	8b 45 08             	mov    0x8(%ebp),%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	8b 40 08             	mov    0x8(%eax),%eax
c010048d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100490:	73 13                	jae    c01004a5 <stab_binsearch+0xb1>
            *region_left = m;
c0100492:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100495:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100498:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010049d:	83 c0 01             	add    $0x1,%eax
c01004a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a3:	eb 43                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a8:	89 d0                	mov    %edx,%eax
c01004aa:	01 c0                	add    %eax,%eax
c01004ac:	01 d0                	add    %edx,%eax
c01004ae:	c1 e0 02             	shl    $0x2,%eax
c01004b1:	89 c2                	mov    %eax,%edx
c01004b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01004b6:	01 d0                	add    %edx,%eax
c01004b8:	8b 40 08             	mov    0x8(%eax),%eax
c01004bb:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004be:	76 16                	jbe    c01004d6 <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004c6:	8b 45 10             	mov    0x10(%ebp),%eax
c01004c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	83 e8 01             	sub    $0x1,%eax
c01004d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d4:	eb 12                	jmp    c01004e8 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004dc:	89 10                	mov    %edx,(%eax)
            l = m;
c01004de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004ee:	0f 8e 22 ff ff ff    	jle    c0100416 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004f8:	75 0f                	jne    c0100509 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 00                	mov    (%eax),%eax
c01004ff:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100502:	8b 45 10             	mov    0x10(%ebp),%eax
c0100505:	89 10                	mov    %edx,(%eax)
c0100507:	eb 3f                	jmp    c0100548 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100509:	8b 45 10             	mov    0x10(%ebp),%eax
c010050c:	8b 00                	mov    (%eax),%eax
c010050e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100511:	eb 04                	jmp    c0100517 <stab_binsearch+0x123>
c0100513:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c0100517:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051a:	8b 00                	mov    (%eax),%eax
c010051c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051f:	7d 1f                	jge    c0100540 <stab_binsearch+0x14c>
c0100521:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100524:	89 d0                	mov    %edx,%eax
c0100526:	01 c0                	add    %eax,%eax
c0100528:	01 d0                	add    %edx,%eax
c010052a:	c1 e0 02             	shl    $0x2,%eax
c010052d:	89 c2                	mov    %eax,%edx
c010052f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100532:	01 d0                	add    %edx,%eax
c0100534:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100538:	0f b6 c0             	movzbl %al,%eax
c010053b:	3b 45 14             	cmp    0x14(%ebp),%eax
c010053e:	75 d3                	jne    c0100513 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100540:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100543:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100546:	89 10                	mov    %edx,(%eax)
    }
}
c0100548:	c9                   	leave  
c0100549:	c3                   	ret    

c010054a <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054a:	55                   	push   %ebp
c010054b:	89 e5                	mov    %esp,%ebp
c010054d:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100553:	c7 00 2c bf 10 c0    	movl   $0xc010bf2c,(%eax)
    info->eip_line = 0;
c0100559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100566:	c7 40 08 2c bf 10 c0 	movl   $0xc010bf2c,0x8(%eax)
    info->eip_fn_namelen = 9;
c010056d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100570:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100577:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057a:	8b 55 08             	mov    0x8(%ebp),%edx
c010057d:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100583:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c010058a:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c0100591:	76 21                	jbe    c01005b4 <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c0100593:	c7 45 f4 a0 e5 10 c0 	movl   $0xc010e5a0,-0xc(%ebp)
        stab_end = __STAB_END__;
c010059a:	c7 45 f0 40 29 12 c0 	movl   $0xc0122940,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c01005a1:	c7 45 ec 41 29 12 c0 	movl   $0xc0122941,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c01005a8:	c7 45 e8 4b 76 12 c0 	movl   $0xc012764b,-0x18(%ebp)
c01005af:	e9 ea 00 00 00       	jmp    c010069e <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c01005b4:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c01005bb:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01005c0:	85 c0                	test   %eax,%eax
c01005c2:	74 11                	je     c01005d5 <debuginfo_eip+0x8b>
c01005c4:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01005c9:	8b 40 18             	mov    0x18(%eax),%eax
c01005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01005cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01005d3:	75 0a                	jne    c01005df <debuginfo_eip+0x95>
            return -1;
c01005d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005da:	e9 9e 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01005df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01005e9:	00 
c01005ea:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01005f1:	00 
c01005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01005f9:	89 04 24             	mov    %eax,(%esp)
c01005fc:	e8 fd 89 00 00       	call   c0108ffe <user_mem_check>
c0100601:	85 c0                	test   %eax,%eax
c0100603:	75 0a                	jne    c010060f <debuginfo_eip+0xc5>
            return -1;
c0100605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060a:	e9 6e 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }

        stabs = usd->stabs;
c010060f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100612:	8b 00                	mov    (%eax),%eax
c0100614:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c0100617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010061a:	8b 40 04             	mov    0x4(%eax),%eax
c010061d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c0100620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100623:	8b 40 08             	mov    0x8(%eax),%eax
c0100626:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010062c:	8b 40 0c             	mov    0xc(%eax),%eax
c010062f:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c0100632:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100635:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100638:	29 c2                	sub    %eax,%edx
c010063a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100644:	00 
c0100645:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100649:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100650:	89 04 24             	mov    %eax,(%esp)
c0100653:	e8 a6 89 00 00       	call   c0108ffe <user_mem_check>
c0100658:	85 c0                	test   %eax,%eax
c010065a:	75 0a                	jne    c0100666 <debuginfo_eip+0x11c>
            return -1;
c010065c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100661:	e9 17 03 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c0100666:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100669:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066c:	29 c2                	sub    %eax,%edx
c010066e:	89 d0                	mov    %edx,%eax
c0100670:	89 c2                	mov    %eax,%edx
c0100672:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100675:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010067c:	00 
c010067d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100681:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100685:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100688:	89 04 24             	mov    %eax,(%esp)
c010068b:	e8 6e 89 00 00       	call   c0108ffe <user_mem_check>
c0100690:	85 c0                	test   %eax,%eax
c0100692:	75 0a                	jne    c010069e <debuginfo_eip+0x154>
            return -1;
c0100694:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100699:	e9 df 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010069e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006a1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006a4:	76 0d                	jbe    c01006b3 <debuginfo_eip+0x169>
c01006a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006a9:	83 e8 01             	sub    $0x1,%eax
c01006ac:	0f b6 00             	movzbl (%eax),%eax
c01006af:	84 c0                	test   %al,%al
c01006b1:	74 0a                	je     c01006bd <debuginfo_eip+0x173>
        return -1;
c01006b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b8:	e9 c0 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006bd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01006c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ca:	29 c2                	sub    %eax,%edx
c01006cc:	89 d0                	mov    %edx,%eax
c01006ce:	c1 f8 02             	sar    $0x2,%eax
c01006d1:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006d7:	83 e8 01             	sub    $0x1,%eax
c01006da:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01006e0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006e4:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006eb:	00 
c01006ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006ef:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006f3:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01006f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006fd:	89 04 24             	mov    %eax,(%esp)
c0100700:	e8 ef fc ff ff       	call   c01003f4 <stab_binsearch>
    if (lfile == 0)
c0100705:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100708:	85 c0                	test   %eax,%eax
c010070a:	75 0a                	jne    c0100716 <debuginfo_eip+0x1cc>
        return -1;
c010070c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100711:	e9 67 02 00 00       	jmp    c010097d <debuginfo_eip+0x433>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100716:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100719:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100722:	8b 45 08             	mov    0x8(%ebp),%eax
c0100725:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100729:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100730:	00 
c0100731:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100734:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100738:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010073b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100742:	89 04 24             	mov    %eax,(%esp)
c0100745:	e8 aa fc ff ff       	call   c01003f4 <stab_binsearch>

    if (lfun <= rfun) {
c010074a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010074d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100750:	39 c2                	cmp    %eax,%edx
c0100752:	7f 7c                	jg     c01007d0 <debuginfo_eip+0x286>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100754:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	89 d0                	mov    %edx,%eax
c010075b:	01 c0                	add    %eax,%eax
c010075d:	01 d0                	add    %edx,%eax
c010075f:	c1 e0 02             	shl    $0x2,%eax
c0100762:	89 c2                	mov    %eax,%edx
c0100764:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100767:	01 d0                	add    %edx,%eax
c0100769:	8b 10                	mov    (%eax),%edx
c010076b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100771:	29 c1                	sub    %eax,%ecx
c0100773:	89 c8                	mov    %ecx,%eax
c0100775:	39 c2                	cmp    %eax,%edx
c0100777:	73 22                	jae    c010079b <debuginfo_eip+0x251>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100779:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077c:	89 c2                	mov    %eax,%edx
c010077e:	89 d0                	mov    %edx,%eax
c0100780:	01 c0                	add    %eax,%eax
c0100782:	01 d0                	add    %edx,%eax
c0100784:	c1 e0 02             	shl    $0x2,%eax
c0100787:	89 c2                	mov    %eax,%edx
c0100789:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078c:	01 d0                	add    %edx,%eax
c010078e:	8b 10                	mov    (%eax),%edx
c0100790:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100793:	01 c2                	add    %eax,%edx
c0100795:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100798:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	8b 50 08             	mov    0x8(%eax),%edx
c01007b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b6:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bc:	8b 40 10             	mov    0x10(%eax),%eax
c01007bf:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c01007c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01007ce:	eb 15                	jmp    c01007e5 <debuginfo_eip+0x29b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d3:	8b 55 08             	mov    0x8(%ebp),%edx
c01007d6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01007df:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007e8:	8b 40 08             	mov    0x8(%eax),%eax
c01007eb:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007f2:	00 
c01007f3:	89 04 24             	mov    %eax,(%esp)
c01007f6:	e8 65 b3 00 00       	call   c010bb60 <strfind>
c01007fb:	89 c2                	mov    %eax,%edx
c01007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100800:	8b 40 08             	mov    0x8(%eax),%eax
c0100803:	29 c2                	sub    %eax,%edx
c0100805:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100808:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010080b:	8b 45 08             	mov    0x8(%ebp),%eax
c010080e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100812:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100819:	00 
c010081a:	8d 45 c8             	lea    -0x38(%ebp),%eax
c010081d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100821:	8d 45 cc             	lea    -0x34(%ebp),%eax
c0100824:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100828:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082b:	89 04 24             	mov    %eax,(%esp)
c010082e:	e8 c1 fb ff ff       	call   c01003f4 <stab_binsearch>
    if (lline <= rline) {
c0100833:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100836:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100839:	39 c2                	cmp    %eax,%edx
c010083b:	7f 24                	jg     c0100861 <debuginfo_eip+0x317>
        info->eip_line = stabs[rline].n_desc;
c010083d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100840:	89 c2                	mov    %eax,%edx
c0100842:	89 d0                	mov    %edx,%eax
c0100844:	01 c0                	add    %eax,%eax
c0100846:	01 d0                	add    %edx,%eax
c0100848:	c1 e0 02             	shl    $0x2,%eax
c010084b:	89 c2                	mov    %eax,%edx
c010084d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100850:	01 d0                	add    %edx,%eax
c0100852:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100856:	0f b7 d0             	movzwl %ax,%edx
c0100859:	8b 45 0c             	mov    0xc(%ebp),%eax
c010085c:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010085f:	eb 13                	jmp    c0100874 <debuginfo_eip+0x32a>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100861:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100866:	e9 12 01 00 00       	jmp    c010097d <debuginfo_eip+0x433>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010086b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010086e:	83 e8 01             	sub    $0x1,%eax
c0100871:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100874:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100877:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010087a:	39 c2                	cmp    %eax,%edx
c010087c:	7c 56                	jl     c01008d4 <debuginfo_eip+0x38a>
           && stabs[lline].n_type != N_SOL
c010087e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100881:	89 c2                	mov    %eax,%edx
c0100883:	89 d0                	mov    %edx,%eax
c0100885:	01 c0                	add    %eax,%eax
c0100887:	01 d0                	add    %edx,%eax
c0100889:	c1 e0 02             	shl    $0x2,%eax
c010088c:	89 c2                	mov    %eax,%edx
c010088e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100891:	01 d0                	add    %edx,%eax
c0100893:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100897:	3c 84                	cmp    $0x84,%al
c0100899:	74 39                	je     c01008d4 <debuginfo_eip+0x38a>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010089b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010089e:	89 c2                	mov    %eax,%edx
c01008a0:	89 d0                	mov    %edx,%eax
c01008a2:	01 c0                	add    %eax,%eax
c01008a4:	01 d0                	add    %edx,%eax
c01008a6:	c1 e0 02             	shl    $0x2,%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ae:	01 d0                	add    %edx,%eax
c01008b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008b4:	3c 64                	cmp    $0x64,%al
c01008b6:	75 b3                	jne    c010086b <debuginfo_eip+0x321>
c01008b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008bb:	89 c2                	mov    %eax,%edx
c01008bd:	89 d0                	mov    %edx,%eax
c01008bf:	01 c0                	add    %eax,%eax
c01008c1:	01 d0                	add    %edx,%eax
c01008c3:	c1 e0 02             	shl    $0x2,%eax
c01008c6:	89 c2                	mov    %eax,%edx
c01008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008cb:	01 d0                	add    %edx,%eax
c01008cd:	8b 40 08             	mov    0x8(%eax),%eax
c01008d0:	85 c0                	test   %eax,%eax
c01008d2:	74 97                	je     c010086b <debuginfo_eip+0x321>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01008d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008da:	39 c2                	cmp    %eax,%edx
c01008dc:	7c 46                	jl     c0100924 <debuginfo_eip+0x3da>
c01008de:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01008e1:	89 c2                	mov    %eax,%edx
c01008e3:	89 d0                	mov    %edx,%eax
c01008e5:	01 c0                	add    %eax,%eax
c01008e7:	01 d0                	add    %edx,%eax
c01008e9:	c1 e0 02             	shl    $0x2,%eax
c01008ec:	89 c2                	mov    %eax,%edx
c01008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f1:	01 d0                	add    %edx,%eax
c01008f3:	8b 10                	mov    (%eax),%edx
c01008f5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008fb:	29 c1                	sub    %eax,%ecx
c01008fd:	89 c8                	mov    %ecx,%eax
c01008ff:	39 c2                	cmp    %eax,%edx
c0100901:	73 21                	jae    c0100924 <debuginfo_eip+0x3da>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100903:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100906:	89 c2                	mov    %eax,%edx
c0100908:	89 d0                	mov    %edx,%eax
c010090a:	01 c0                	add    %eax,%eax
c010090c:	01 d0                	add    %edx,%eax
c010090e:	c1 e0 02             	shl    $0x2,%eax
c0100911:	89 c2                	mov    %eax,%edx
c0100913:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100916:	01 d0                	add    %edx,%eax
c0100918:	8b 10                	mov    (%eax),%edx
c010091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010091d:	01 c2                	add    %eax,%edx
c010091f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100922:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100924:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100927:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010092a:	39 c2                	cmp    %eax,%edx
c010092c:	7d 4a                	jge    c0100978 <debuginfo_eip+0x42e>
        for (lline = lfun + 1;
c010092e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100931:	83 c0 01             	add    $0x1,%eax
c0100934:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100937:	eb 18                	jmp    c0100951 <debuginfo_eip+0x407>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010093c:	8b 40 14             	mov    0x14(%eax),%eax
c010093f:	8d 50 01             	lea    0x1(%eax),%edx
c0100942:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100945:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100948:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010094b:	83 c0 01             	add    $0x1,%eax
c010094e:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100951:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100954:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100957:	39 c2                	cmp    %eax,%edx
c0100959:	7d 1d                	jge    c0100978 <debuginfo_eip+0x42e>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010095e:	89 c2                	mov    %eax,%edx
c0100960:	89 d0                	mov    %edx,%eax
c0100962:	01 c0                	add    %eax,%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	c1 e0 02             	shl    $0x2,%eax
c0100969:	89 c2                	mov    %eax,%edx
c010096b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096e:	01 d0                	add    %edx,%eax
c0100970:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100974:	3c a0                	cmp    $0xa0,%al
c0100976:	74 c1                	je     c0100939 <debuginfo_eip+0x3ef>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100978:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010097d:	c9                   	leave  
c010097e:	c3                   	ret    

c010097f <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010097f:	55                   	push   %ebp
c0100980:	89 e5                	mov    %esp,%ebp
c0100982:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100985:	c7 04 24 36 bf 10 c0 	movl   $0xc010bf36,(%esp)
c010098c:	e8 c2 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100991:	c7 44 24 04 2a 00 10 	movl   $0xc010002a,0x4(%esp)
c0100998:	c0 
c0100999:	c7 04 24 4f bf 10 c0 	movl   $0xc010bf4f,(%esp)
c01009a0:	e8 ae f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009a5:	c7 44 24 04 75 be 10 	movl   $0xc010be75,0x4(%esp)
c01009ac:	c0 
c01009ad:	c7 04 24 67 bf 10 c0 	movl   $0xc010bf67,(%esp)
c01009b4:	e8 9a f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009b9:	c7 44 24 04 2a bf 19 	movl   $0xc019bf2a,0x4(%esp)
c01009c0:	c0 
c01009c1:	c7 04 24 7f bf 10 c0 	movl   $0xc010bf7f,(%esp)
c01009c8:	e8 86 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009cd:	c7 44 24 04 b8 f0 19 	movl   $0xc019f0b8,0x4(%esp)
c01009d4:	c0 
c01009d5:	c7 04 24 97 bf 10 c0 	movl   $0xc010bf97,(%esp)
c01009dc:	e8 72 f9 ff ff       	call   c0100353 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009e1:	b8 b8 f0 19 c0       	mov    $0xc019f0b8,%eax
c01009e6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009ec:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c01009f1:	29 c2                	sub    %eax,%edx
c01009f3:	89 d0                	mov    %edx,%eax
c01009f5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009fb:	85 c0                	test   %eax,%eax
c01009fd:	0f 48 c2             	cmovs  %edx,%eax
c0100a00:	c1 f8 0a             	sar    $0xa,%eax
c0100a03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a07:	c7 04 24 b0 bf 10 c0 	movl   $0xc010bfb0,(%esp)
c0100a0e:	e8 40 f9 ff ff       	call   c0100353 <cprintf>
}
c0100a13:	c9                   	leave  
c0100a14:	c3                   	ret    

c0100a15 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a15:	55                   	push   %ebp
c0100a16:	89 e5                	mov    %esp,%ebp
c0100a18:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a1e:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a28:	89 04 24             	mov    %eax,(%esp)
c0100a2b:	e8 1a fb ff ff       	call   c010054a <debuginfo_eip>
c0100a30:	85 c0                	test   %eax,%eax
c0100a32:	74 15                	je     c0100a49 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3b:	c7 04 24 da bf 10 c0 	movl   $0xc010bfda,(%esp)
c0100a42:	e8 0c f9 ff ff       	call   c0100353 <cprintf>
c0100a47:	eb 6d                	jmp    c0100ab6 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a50:	eb 1c                	jmp    c0100a6e <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0100a52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a58:	01 d0                	add    %edx,%eax
c0100a5a:	0f b6 00             	movzbl (%eax),%eax
c0100a5d:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a63:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a66:	01 ca                	add    %ecx,%edx
c0100a68:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100a6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a74:	7f dc                	jg     c0100a52 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a76:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a7f:	01 d0                	add    %edx,%eax
c0100a81:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a87:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a8a:	89 d1                	mov    %edx,%ecx
c0100a8c:	29 c1                	sub    %eax,%ecx
c0100a8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a94:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a98:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a9e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100aa2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aaa:	c7 04 24 f6 bf 10 c0 	movl   $0xc010bff6,(%esp)
c0100ab1:	e8 9d f8 ff ff       	call   c0100353 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100ab6:	c9                   	leave  
c0100ab7:	c3                   	ret    

c0100ab8 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ab8:	55                   	push   %ebp
c0100ab9:	89 e5                	mov    %esp,%ebp
c0100abb:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100abe:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ac1:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ac4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100ac7:	c9                   	leave  
c0100ac8:	c3                   	ret    

c0100ac9 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ac9:	55                   	push   %ebp
c0100aca:	89 e5                	mov    %esp,%ebp
c0100acc:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100acf:	89 e8                	mov    %ebp,%eax
c0100ad1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return ebp;
c0100ad4:	8b 45 e8             	mov    -0x18(%ebp),%eax
     *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
     *    (3.5) popup a calling stackframe
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100ad7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ada:	e8 d9 ff ff ff       	call   c0100ab8 <read_eip>
c0100adf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for (i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100ae2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ae9:	e9 ce 00 00 00       	jmp    c0100bbc <print_stackframe+0xf3>
        if (!ebp) break;
c0100aee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100af2:	75 05                	jne    c0100af9 <print_stackframe+0x30>
c0100af4:	e9 cd 00 00 00       	jmp    c0100bc6 <print_stackframe+0xfd>
        cprintf("ebp:0x%08x ", ebp);
c0100af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b00:	c7 04 24 08 c0 10 c0 	movl   $0xc010c008,(%esp)
c0100b07:	e8 47 f8 ff ff       	call   c0100353 <cprintf>
        cprintf("eip:0x%08x ", eip);
c0100b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b13:	c7 04 24 14 c0 10 c0 	movl   $0xc010c014,(%esp)
c0100b1a:	e8 34 f8 ff ff       	call   c0100353 <cprintf>
        cprintf("args:");
c0100b1f:	c7 04 24 20 c0 10 c0 	movl   $0xc010c020,(%esp)
c0100b26:	e8 28 f8 ff ff       	call   c0100353 <cprintf>
        cprintf("0x%08x ", *((uint32_t *)ebp + 2));
c0100b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b2e:	83 c0 08             	add    $0x8,%eax
c0100b31:	8b 00                	mov    (%eax),%eax
c0100b33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b37:	c7 04 24 26 c0 10 c0 	movl   $0xc010c026,(%esp)
c0100b3e:	e8 10 f8 ff ff       	call   c0100353 <cprintf>
        cprintf("0x%08x ", *((uint32_t *)ebp + 3));
c0100b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b46:	83 c0 0c             	add    $0xc,%eax
c0100b49:	8b 00                	mov    (%eax),%eax
c0100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4f:	c7 04 24 26 c0 10 c0 	movl   $0xc010c026,(%esp)
c0100b56:	e8 f8 f7 ff ff       	call   c0100353 <cprintf>
        cprintf("0x%08x ", *((uint32_t *)ebp + 4));
c0100b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5e:	83 c0 10             	add    $0x10,%eax
c0100b61:	8b 00                	mov    (%eax),%eax
c0100b63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b67:	c7 04 24 26 c0 10 c0 	movl   $0xc010c026,(%esp)
c0100b6e:	e8 e0 f7 ff ff       	call   c0100353 <cprintf>
        cprintf("0x%08x ", *((uint32_t *)ebp + 5));
c0100b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b76:	83 c0 14             	add    $0x14,%eax
c0100b79:	8b 00                	mov    (%eax),%eax
c0100b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b7f:	c7 04 24 26 c0 10 c0 	movl   $0xc010c026,(%esp)
c0100b86:	e8 c8 f7 ff ff       	call   c0100353 <cprintf>
        cprintf("\n");
c0100b8b:	c7 04 24 2e c0 10 c0 	movl   $0xc010c02e,(%esp)
c0100b92:	e8 bc f7 ff ff       	call   c0100353 <cprintf>
        print_debuginfo(eip - 1);
c0100b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b9a:	83 e8 01             	sub    $0x1,%eax
c0100b9d:	89 04 24             	mov    %eax,(%esp)
c0100ba0:	e8 70 fe ff ff       	call   c0100a15 <print_debuginfo>
        eip = *((uint32_t *)ebp + 1);
c0100ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba8:	83 c0 04             	add    $0x4,%eax
c0100bab:	8b 00                	mov    (%eax),%eax
c0100bad:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = *((uint32_t *)ebp);
c0100bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb3:	8b 00                	mov    (%eax),%eax
c0100bb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i;
    for (i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100bb8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100bbc:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100bc0:	0f 8e 28 ff ff ff    	jle    c0100aee <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = *((uint32_t *)ebp + 1);
        ebp = *((uint32_t *)ebp);
    }
}
c0100bc6:	c9                   	leave  
c0100bc7:	c3                   	ret    

c0100bc8 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100bc8:	55                   	push   %ebp
c0100bc9:	89 e5                	mov    %esp,%ebp
c0100bcb:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100bce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bd5:	eb 0c                	jmp    c0100be3 <parse+0x1b>
            *buf ++ = '\0';
c0100bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bda:	8d 50 01             	lea    0x1(%eax),%edx
c0100bdd:	89 55 08             	mov    %edx,0x8(%ebp)
c0100be0:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100be3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be6:	0f b6 00             	movzbl (%eax),%eax
c0100be9:	84 c0                	test   %al,%al
c0100beb:	74 1d                	je     c0100c0a <parse+0x42>
c0100bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf0:	0f b6 00             	movzbl (%eax),%eax
c0100bf3:	0f be c0             	movsbl %al,%eax
c0100bf6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bfa:	c7 04 24 b0 c0 10 c0 	movl   $0xc010c0b0,(%esp)
c0100c01:	e8 27 af 00 00       	call   c010bb2d <strchr>
c0100c06:	85 c0                	test   %eax,%eax
c0100c08:	75 cd                	jne    c0100bd7 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c0d:	0f b6 00             	movzbl (%eax),%eax
c0100c10:	84 c0                	test   %al,%al
c0100c12:	75 02                	jne    c0100c16 <parse+0x4e>
            break;
c0100c14:	eb 67                	jmp    c0100c7d <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100c16:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100c1a:	75 14                	jne    c0100c30 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100c1c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100c23:	00 
c0100c24:	c7 04 24 b5 c0 10 c0 	movl   $0xc010c0b5,(%esp)
c0100c2b:	e8 23 f7 ff ff       	call   c0100353 <cprintf>
        }
        argv[argc ++] = buf;
c0100c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c33:	8d 50 01             	lea    0x1(%eax),%edx
c0100c36:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c39:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c43:	01 c2                	add    %eax,%edx
c0100c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c48:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c4a:	eb 04                	jmp    c0100c50 <parse+0x88>
            buf ++;
c0100c4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c50:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c53:	0f b6 00             	movzbl (%eax),%eax
c0100c56:	84 c0                	test   %al,%al
c0100c58:	74 1d                	je     c0100c77 <parse+0xaf>
c0100c5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c5d:	0f b6 00             	movzbl (%eax),%eax
c0100c60:	0f be c0             	movsbl %al,%eax
c0100c63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c67:	c7 04 24 b0 c0 10 c0 	movl   $0xc010c0b0,(%esp)
c0100c6e:	e8 ba ae 00 00       	call   c010bb2d <strchr>
c0100c73:	85 c0                	test   %eax,%eax
c0100c75:	74 d5                	je     c0100c4c <parse+0x84>
            buf ++;
        }
    }
c0100c77:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c78:	e9 66 ff ff ff       	jmp    c0100be3 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c80:	c9                   	leave  
c0100c81:	c3                   	ret    

c0100c82 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c82:	55                   	push   %ebp
c0100c83:	89 e5                	mov    %esp,%ebp
c0100c85:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c88:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c92:	89 04 24             	mov    %eax,(%esp)
c0100c95:	e8 2e ff ff ff       	call   c0100bc8 <parse>
c0100c9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100ca1:	75 0a                	jne    c0100cad <runcmd+0x2b>
        return 0;
c0100ca3:	b8 00 00 00 00       	mov    $0x0,%eax
c0100ca8:	e9 85 00 00 00       	jmp    c0100d32 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100cb4:	eb 5c                	jmp    c0100d12 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100cb6:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cbc:	89 d0                	mov    %edx,%eax
c0100cbe:	01 c0                	add    %eax,%eax
c0100cc0:	01 d0                	add    %edx,%eax
c0100cc2:	c1 e0 02             	shl    $0x2,%eax
c0100cc5:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100cca:	8b 00                	mov    (%eax),%eax
c0100ccc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100cd0:	89 04 24             	mov    %eax,(%esp)
c0100cd3:	e8 b6 ad 00 00       	call   c010ba8e <strcmp>
c0100cd8:	85 c0                	test   %eax,%eax
c0100cda:	75 32                	jne    c0100d0e <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cdf:	89 d0                	mov    %edx,%eax
c0100ce1:	01 c0                	add    %eax,%eax
c0100ce3:	01 d0                	add    %edx,%eax
c0100ce5:	c1 e0 02             	shl    $0x2,%eax
c0100ce8:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100ced:	8b 40 08             	mov    0x8(%eax),%eax
c0100cf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100cf3:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100cf6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100cf9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100cfd:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100d00:	83 c2 04             	add    $0x4,%edx
c0100d03:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100d07:	89 0c 24             	mov    %ecx,(%esp)
c0100d0a:	ff d0                	call   *%eax
c0100d0c:	eb 24                	jmp    c0100d32 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d0e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d15:	83 f8 02             	cmp    $0x2,%eax
c0100d18:	76 9c                	jbe    c0100cb6 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100d1a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d21:	c7 04 24 d3 c0 10 c0 	movl   $0xc010c0d3,(%esp)
c0100d28:	e8 26 f6 ff ff       	call   c0100353 <cprintf>
    return 0;
c0100d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d32:	c9                   	leave  
c0100d33:	c3                   	ret    

c0100d34 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d34:	55                   	push   %ebp
c0100d35:	89 e5                	mov    %esp,%ebp
c0100d37:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d3a:	c7 04 24 ec c0 10 c0 	movl   $0xc010c0ec,(%esp)
c0100d41:	e8 0d f6 ff ff       	call   c0100353 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d46:	c7 04 24 14 c1 10 c0 	movl   $0xc010c114,(%esp)
c0100d4d:	e8 01 f6 ff ff       	call   c0100353 <cprintf>

    if (tf != NULL) {
c0100d52:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d56:	74 0b                	je     c0100d63 <kmonitor+0x2f>
        print_trapframe(tf);
c0100d58:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d5b:	89 04 24             	mov    %eax,(%esp)
c0100d5e:	e8 a1 16 00 00       	call   c0102404 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d63:	c7 04 24 39 c1 10 c0 	movl   $0xc010c139,(%esp)
c0100d6a:	e8 db f4 ff ff       	call   c010024a <readline>
c0100d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d76:	74 18                	je     c0100d90 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100d78:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d82:	89 04 24             	mov    %eax,(%esp)
c0100d85:	e8 f8 fe ff ff       	call   c0100c82 <runcmd>
c0100d8a:	85 c0                	test   %eax,%eax
c0100d8c:	79 02                	jns    c0100d90 <kmonitor+0x5c>
                break;
c0100d8e:	eb 02                	jmp    c0100d92 <kmonitor+0x5e>
            }
        }
    }
c0100d90:	eb d1                	jmp    c0100d63 <kmonitor+0x2f>
}
c0100d92:	c9                   	leave  
c0100d93:	c3                   	ret    

c0100d94 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d94:	55                   	push   %ebp
c0100d95:	89 e5                	mov    %esp,%ebp
c0100d97:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100da1:	eb 3f                	jmp    c0100de2 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100da3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100da6:	89 d0                	mov    %edx,%eax
c0100da8:	01 c0                	add    %eax,%eax
c0100daa:	01 d0                	add    %edx,%eax
c0100dac:	c1 e0 02             	shl    $0x2,%eax
c0100daf:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100db4:	8b 48 04             	mov    0x4(%eax),%ecx
c0100db7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100dba:	89 d0                	mov    %edx,%eax
c0100dbc:	01 c0                	add    %eax,%eax
c0100dbe:	01 d0                	add    %edx,%eax
c0100dc0:	c1 e0 02             	shl    $0x2,%eax
c0100dc3:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0100dc8:	8b 00                	mov    (%eax),%eax
c0100dca:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100dce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dd2:	c7 04 24 3d c1 10 c0 	movl   $0xc010c13d,(%esp)
c0100dd9:	e8 75 f5 ff ff       	call   c0100353 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100dde:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100de5:	83 f8 02             	cmp    $0x2,%eax
c0100de8:	76 b9                	jbe    c0100da3 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100def:	c9                   	leave  
c0100df0:	c3                   	ret    

c0100df1 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100df1:	55                   	push   %ebp
c0100df2:	89 e5                	mov    %esp,%ebp
c0100df4:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100df7:	e8 83 fb ff ff       	call   c010097f <print_kerninfo>
    return 0;
c0100dfc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e01:	c9                   	leave  
c0100e02:	c3                   	ret    

c0100e03 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100e03:	55                   	push   %ebp
c0100e04:	89 e5                	mov    %esp,%ebp
c0100e06:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100e09:	e8 bb fc ff ff       	call   c0100ac9 <print_stackframe>
    return 0;
c0100e0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e13:	c9                   	leave  
c0100e14:	c3                   	ret    

c0100e15 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100e15:	55                   	push   %ebp
c0100e16:	89 e5                	mov    %esp,%ebp
c0100e18:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100e1b:	a1 60 c3 19 c0       	mov    0xc019c360,%eax
c0100e20:	85 c0                	test   %eax,%eax
c0100e22:	74 02                	je     c0100e26 <__panic+0x11>
        goto panic_dead;
c0100e24:	eb 48                	jmp    c0100e6e <__panic+0x59>
    }
    is_panic = 1;
c0100e26:	c7 05 60 c3 19 c0 01 	movl   $0x1,0xc019c360
c0100e2d:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100e30:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100e36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e39:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e40:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e44:	c7 04 24 46 c1 10 c0 	movl   $0xc010c146,(%esp)
c0100e4b:	e8 03 f5 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e57:	8b 45 10             	mov    0x10(%ebp),%eax
c0100e5a:	89 04 24             	mov    %eax,(%esp)
c0100e5d:	e8 be f4 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100e62:	c7 04 24 62 c1 10 c0 	movl   $0xc010c162,(%esp)
c0100e69:	e8 e5 f4 ff ff       	call   c0100353 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
c0100e6e:	e8 fa 11 00 00       	call   c010206d <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100e73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e7a:	e8 b5 fe ff ff       	call   c0100d34 <kmonitor>
    }
c0100e7f:	eb f2                	jmp    c0100e73 <__panic+0x5e>

c0100e81 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100e81:	55                   	push   %ebp
c0100e82:	89 e5                	mov    %esp,%ebp
c0100e84:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100e87:	8d 45 14             	lea    0x14(%ebp),%eax
c0100e8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e90:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100e94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e9b:	c7 04 24 64 c1 10 c0 	movl   $0xc010c164,(%esp)
c0100ea2:	e8 ac f4 ff ff       	call   c0100353 <cprintf>
    vcprintf(fmt, ap);
c0100ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100eae:	8b 45 10             	mov    0x10(%ebp),%eax
c0100eb1:	89 04 24             	mov    %eax,(%esp)
c0100eb4:	e8 67 f4 ff ff       	call   c0100320 <vcprintf>
    cprintf("\n");
c0100eb9:	c7 04 24 62 c1 10 c0 	movl   $0xc010c162,(%esp)
c0100ec0:	e8 8e f4 ff ff       	call   c0100353 <cprintf>
    va_end(ap);
}
c0100ec5:	c9                   	leave  
c0100ec6:	c3                   	ret    

c0100ec7 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100ec7:	55                   	push   %ebp
c0100ec8:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100eca:	a1 60 c3 19 c0       	mov    0xc019c360,%eax
}
c0100ecf:	5d                   	pop    %ebp
c0100ed0:	c3                   	ret    

c0100ed1 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100ed1:	55                   	push   %ebp
c0100ed2:	89 e5                	mov    %esp,%ebp
c0100ed4:	83 ec 28             	sub    $0x28,%esp
c0100ed7:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100edd:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100ee5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100ee9:	ee                   	out    %al,(%dx)
c0100eea:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100ef0:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100ef4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ef8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100efc:	ee                   	out    %al,(%dx)
c0100efd:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100f03:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100f07:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f0b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f0f:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100f10:	c7 05 b4 ef 19 c0 00 	movl   $0x0,0xc019efb4
c0100f17:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100f1a:	c7 04 24 82 c1 10 c0 	movl   $0xc010c182,(%esp)
c0100f21:	e8 2d f4 ff ff       	call   c0100353 <cprintf>
    pic_enable(IRQ_TIMER);
c0100f26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100f2d:	e8 99 11 00 00       	call   c01020cb <pic_enable>
}
c0100f32:	c9                   	leave  
c0100f33:	c3                   	ret    

c0100f34 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0100f34:	55                   	push   %ebp
c0100f35:	89 e5                	mov    %esp,%ebp
c0100f37:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100f3a:	9c                   	pushf  
c0100f3b:	58                   	pop    %eax
c0100f3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100f42:	25 00 02 00 00       	and    $0x200,%eax
c0100f47:	85 c0                	test   %eax,%eax
c0100f49:	74 0c                	je     c0100f57 <__intr_save+0x23>
        intr_disable();
c0100f4b:	e8 1d 11 00 00       	call   c010206d <intr_disable>
        return 1;
c0100f50:	b8 01 00 00 00       	mov    $0x1,%eax
c0100f55:	eb 05                	jmp    c0100f5c <__intr_save+0x28>
    }
    return 0;
c0100f57:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100f5c:	c9                   	leave  
c0100f5d:	c3                   	ret    

c0100f5e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100f5e:	55                   	push   %ebp
c0100f5f:	89 e5                	mov    %esp,%ebp
c0100f61:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100f64:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100f68:	74 05                	je     c0100f6f <__intr_restore+0x11>
        intr_enable();
c0100f6a:	e8 f8 10 00 00       	call   c0102067 <intr_enable>
    }
}
c0100f6f:	c9                   	leave  
c0100f70:	c3                   	ret    

c0100f71 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100f71:	55                   	push   %ebp
c0100f72:	89 e5                	mov    %esp,%ebp
c0100f74:	83 ec 10             	sub    $0x10,%esp
c0100f77:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f7d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100f81:	89 c2                	mov    %eax,%edx
c0100f83:	ec                   	in     (%dx),%al
c0100f84:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100f87:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100f8d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100f91:	89 c2                	mov    %eax,%edx
c0100f93:	ec                   	in     (%dx),%al
c0100f94:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100f97:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100f9d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fa1:	89 c2                	mov    %eax,%edx
c0100fa3:	ec                   	in     (%dx),%al
c0100fa4:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100fa7:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100fad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fb1:	89 c2                	mov    %eax,%edx
c0100fb3:	ec                   	in     (%dx),%al
c0100fb4:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100fb7:	c9                   	leave  
c0100fb8:	c3                   	ret    

c0100fb9 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100fb9:	55                   	push   %ebp
c0100fba:	89 e5                	mov    %esp,%ebp
c0100fbc:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100fbf:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100fc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fc9:	0f b7 00             	movzwl (%eax),%eax
c0100fcc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100fd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fd3:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100fd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fdb:	0f b7 00             	movzwl (%eax),%eax
c0100fde:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100fe2:	74 12                	je     c0100ff6 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100fe4:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100feb:	66 c7 05 86 c3 19 c0 	movw   $0x3b4,0xc019c386
c0100ff2:	b4 03 
c0100ff4:	eb 13                	jmp    c0101009 <cga_init+0x50>
    } else {
        *cp = was;
c0100ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ff9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ffd:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101000:	66 c7 05 86 c3 19 c0 	movw   $0x3d4,0xc019c386
c0101007:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101009:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0101010:	0f b7 c0             	movzwl %ax,%eax
c0101013:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101017:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010101f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101023:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101024:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c010102b:	83 c0 01             	add    $0x1,%eax
c010102e:	0f b7 c0             	movzwl %ax,%eax
c0101031:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101035:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101039:	89 c2                	mov    %eax,%edx
c010103b:	ec                   	in     (%dx),%al
c010103c:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c010103f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101043:	0f b6 c0             	movzbl %al,%eax
c0101046:	c1 e0 08             	shl    $0x8,%eax
c0101049:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010104c:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0101053:	0f b7 c0             	movzwl %ax,%eax
c0101056:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010105a:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010105e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101062:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101066:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101067:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c010106e:	83 c0 01             	add    $0x1,%eax
c0101071:	0f b7 c0             	movzwl %ax,%eax
c0101074:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101078:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010107c:	89 c2                	mov    %eax,%edx
c010107e:	ec                   	in     (%dx),%al
c010107f:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0101082:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101086:	0f b6 c0             	movzbl %al,%eax
c0101089:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c010108c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010108f:	a3 80 c3 19 c0       	mov    %eax,0xc019c380
    crt_pos = pos;
c0101094:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101097:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
}
c010109d:	c9                   	leave  
c010109e:	c3                   	ret    

c010109f <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c010109f:	55                   	push   %ebp
c01010a0:	89 e5                	mov    %esp,%ebp
c01010a2:	83 ec 48             	sub    $0x48,%esp
c01010a5:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01010ab:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010af:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010b3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b7:	ee                   	out    %al,(%dx)
c01010b8:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c01010be:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c01010c2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010c6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010ca:	ee                   	out    %al,(%dx)
c01010cb:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c01010d1:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c01010d5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010d9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010dd:	ee                   	out    %al,(%dx)
c01010de:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c01010e4:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01010e8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010ec:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01010f0:	ee                   	out    %al,(%dx)
c01010f1:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c01010f7:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c01010fb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01010ff:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101103:	ee                   	out    %al,(%dx)
c0101104:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c010110a:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c010110e:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101112:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101116:	ee                   	out    %al,(%dx)
c0101117:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010111d:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0101121:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101125:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101129:	ee                   	out    %al,(%dx)
c010112a:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101130:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101134:	89 c2                	mov    %eax,%edx
c0101136:	ec                   	in     (%dx),%al
c0101137:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c010113a:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010113e:	3c ff                	cmp    $0xff,%al
c0101140:	0f 95 c0             	setne  %al
c0101143:	0f b6 c0             	movzbl %al,%eax
c0101146:	a3 88 c3 19 c0       	mov    %eax,0xc019c388
c010114b:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101151:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101155:	89 c2                	mov    %eax,%edx
c0101157:	ec                   	in     (%dx),%al
c0101158:	88 45 d5             	mov    %al,-0x2b(%ebp)
c010115b:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c0101161:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101165:	89 c2                	mov    %eax,%edx
c0101167:	ec                   	in     (%dx),%al
c0101168:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010116b:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c0101170:	85 c0                	test   %eax,%eax
c0101172:	74 0c                	je     c0101180 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101174:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010117b:	e8 4b 0f 00 00       	call   c01020cb <pic_enable>
    }
}
c0101180:	c9                   	leave  
c0101181:	c3                   	ret    

c0101182 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101182:	55                   	push   %ebp
c0101183:	89 e5                	mov    %esp,%ebp
c0101185:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101188:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010118f:	eb 09                	jmp    c010119a <lpt_putc_sub+0x18>
        delay();
c0101191:	e8 db fd ff ff       	call   c0100f71 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101196:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010119a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01011a0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01011a4:	89 c2                	mov    %eax,%edx
c01011a6:	ec                   	in     (%dx),%al
c01011a7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01011aa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01011ae:	84 c0                	test   %al,%al
c01011b0:	78 09                	js     c01011bb <lpt_putc_sub+0x39>
c01011b2:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01011b9:	7e d6                	jle    c0101191 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01011bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01011be:	0f b6 c0             	movzbl %al,%eax
c01011c1:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01011c7:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01011ca:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01011ce:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01011d2:	ee                   	out    %al,(%dx)
c01011d3:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01011d9:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01011dd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01011e1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01011e5:	ee                   	out    %al,(%dx)
c01011e6:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01011ec:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01011f0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01011f4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01011f8:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01011f9:	c9                   	leave  
c01011fa:	c3                   	ret    

c01011fb <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01011fb:	55                   	push   %ebp
c01011fc:	89 e5                	mov    %esp,%ebp
c01011fe:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101201:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101205:	74 0d                	je     c0101214 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101207:	8b 45 08             	mov    0x8(%ebp),%eax
c010120a:	89 04 24             	mov    %eax,(%esp)
c010120d:	e8 70 ff ff ff       	call   c0101182 <lpt_putc_sub>
c0101212:	eb 24                	jmp    c0101238 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c0101214:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010121b:	e8 62 ff ff ff       	call   c0101182 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101220:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101227:	e8 56 ff ff ff       	call   c0101182 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010122c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101233:	e8 4a ff ff ff       	call   c0101182 <lpt_putc_sub>
    }
}
c0101238:	c9                   	leave  
c0101239:	c3                   	ret    

c010123a <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010123a:	55                   	push   %ebp
c010123b:	89 e5                	mov    %esp,%ebp
c010123d:	53                   	push   %ebx
c010123e:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101241:	8b 45 08             	mov    0x8(%ebp),%eax
c0101244:	b0 00                	mov    $0x0,%al
c0101246:	85 c0                	test   %eax,%eax
c0101248:	75 07                	jne    c0101251 <cga_putc+0x17>
        c |= 0x0700;
c010124a:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101251:	8b 45 08             	mov    0x8(%ebp),%eax
c0101254:	0f b6 c0             	movzbl %al,%eax
c0101257:	83 f8 0a             	cmp    $0xa,%eax
c010125a:	74 4c                	je     c01012a8 <cga_putc+0x6e>
c010125c:	83 f8 0d             	cmp    $0xd,%eax
c010125f:	74 57                	je     c01012b8 <cga_putc+0x7e>
c0101261:	83 f8 08             	cmp    $0x8,%eax
c0101264:	0f 85 88 00 00 00    	jne    c01012f2 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c010126a:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c0101271:	66 85 c0             	test   %ax,%ax
c0101274:	74 30                	je     c01012a6 <cga_putc+0x6c>
            crt_pos --;
c0101276:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c010127d:	83 e8 01             	sub    $0x1,%eax
c0101280:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101286:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c010128b:	0f b7 15 84 c3 19 c0 	movzwl 0xc019c384,%edx
c0101292:	0f b7 d2             	movzwl %dx,%edx
c0101295:	01 d2                	add    %edx,%edx
c0101297:	01 c2                	add    %eax,%edx
c0101299:	8b 45 08             	mov    0x8(%ebp),%eax
c010129c:	b0 00                	mov    $0x0,%al
c010129e:	83 c8 20             	or     $0x20,%eax
c01012a1:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01012a4:	eb 72                	jmp    c0101318 <cga_putc+0xde>
c01012a6:	eb 70                	jmp    c0101318 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c01012a8:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01012af:	83 c0 50             	add    $0x50,%eax
c01012b2:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01012b8:	0f b7 1d 84 c3 19 c0 	movzwl 0xc019c384,%ebx
c01012bf:	0f b7 0d 84 c3 19 c0 	movzwl 0xc019c384,%ecx
c01012c6:	0f b7 c1             	movzwl %cx,%eax
c01012c9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01012cf:	c1 e8 10             	shr    $0x10,%eax
c01012d2:	89 c2                	mov    %eax,%edx
c01012d4:	66 c1 ea 06          	shr    $0x6,%dx
c01012d8:	89 d0                	mov    %edx,%eax
c01012da:	c1 e0 02             	shl    $0x2,%eax
c01012dd:	01 d0                	add    %edx,%eax
c01012df:	c1 e0 04             	shl    $0x4,%eax
c01012e2:	29 c1                	sub    %eax,%ecx
c01012e4:	89 ca                	mov    %ecx,%edx
c01012e6:	89 d8                	mov    %ebx,%eax
c01012e8:	29 d0                	sub    %edx,%eax
c01012ea:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
        break;
c01012f0:	eb 26                	jmp    c0101318 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01012f2:	8b 0d 80 c3 19 c0    	mov    0xc019c380,%ecx
c01012f8:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01012ff:	8d 50 01             	lea    0x1(%eax),%edx
c0101302:	66 89 15 84 c3 19 c0 	mov    %dx,0xc019c384
c0101309:	0f b7 c0             	movzwl %ax,%eax
c010130c:	01 c0                	add    %eax,%eax
c010130e:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101311:	8b 45 08             	mov    0x8(%ebp),%eax
c0101314:	66 89 02             	mov    %ax,(%edx)
        break;
c0101317:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101318:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c010131f:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101323:	76 5b                	jbe    c0101380 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101325:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c010132a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101330:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c0101335:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010133c:	00 
c010133d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101341:	89 04 24             	mov    %eax,(%esp)
c0101344:	e8 e2 a9 00 00       	call   c010bd2b <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101349:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101350:	eb 15                	jmp    c0101367 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101352:	a1 80 c3 19 c0       	mov    0xc019c380,%eax
c0101357:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010135a:	01 d2                	add    %edx,%edx
c010135c:	01 d0                	add    %edx,%eax
c010135e:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101363:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101367:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010136e:	7e e2                	jle    c0101352 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101370:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c0101377:	83 e8 50             	sub    $0x50,%eax
c010137a:	66 a3 84 c3 19 c0    	mov    %ax,0xc019c384
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101380:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c0101387:	0f b7 c0             	movzwl %ax,%eax
c010138a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010138e:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101392:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101396:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010139a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c010139b:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01013a2:	66 c1 e8 08          	shr    $0x8,%ax
c01013a6:	0f b6 c0             	movzbl %al,%eax
c01013a9:	0f b7 15 86 c3 19 c0 	movzwl 0xc019c386,%edx
c01013b0:	83 c2 01             	add    $0x1,%edx
c01013b3:	0f b7 d2             	movzwl %dx,%edx
c01013b6:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c01013ba:	88 45 ed             	mov    %al,-0x13(%ebp)
c01013bd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01013c1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01013c5:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01013c6:	0f b7 05 86 c3 19 c0 	movzwl 0xc019c386,%eax
c01013cd:	0f b7 c0             	movzwl %ax,%eax
c01013d0:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01013d4:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01013d8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01013dc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01013e0:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01013e1:	0f b7 05 84 c3 19 c0 	movzwl 0xc019c384,%eax
c01013e8:	0f b6 c0             	movzbl %al,%eax
c01013eb:	0f b7 15 86 c3 19 c0 	movzwl 0xc019c386,%edx
c01013f2:	83 c2 01             	add    $0x1,%edx
c01013f5:	0f b7 d2             	movzwl %dx,%edx
c01013f8:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013fc:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01013ff:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101403:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101407:	ee                   	out    %al,(%dx)
}
c0101408:	83 c4 34             	add    $0x34,%esp
c010140b:	5b                   	pop    %ebx
c010140c:	5d                   	pop    %ebp
c010140d:	c3                   	ret    

c010140e <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010140e:	55                   	push   %ebp
c010140f:	89 e5                	mov    %esp,%ebp
c0101411:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101414:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010141b:	eb 09                	jmp    c0101426 <serial_putc_sub+0x18>
        delay();
c010141d:	e8 4f fb ff ff       	call   c0100f71 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101422:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101426:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010142c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101430:	89 c2                	mov    %eax,%edx
c0101432:	ec                   	in     (%dx),%al
c0101433:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101436:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010143a:	0f b6 c0             	movzbl %al,%eax
c010143d:	83 e0 20             	and    $0x20,%eax
c0101440:	85 c0                	test   %eax,%eax
c0101442:	75 09                	jne    c010144d <serial_putc_sub+0x3f>
c0101444:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010144b:	7e d0                	jle    c010141d <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010144d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101450:	0f b6 c0             	movzbl %al,%eax
c0101453:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101459:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010145c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101460:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101464:	ee                   	out    %al,(%dx)
}
c0101465:	c9                   	leave  
c0101466:	c3                   	ret    

c0101467 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101467:	55                   	push   %ebp
c0101468:	89 e5                	mov    %esp,%ebp
c010146a:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010146d:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101471:	74 0d                	je     c0101480 <serial_putc+0x19>
        serial_putc_sub(c);
c0101473:	8b 45 08             	mov    0x8(%ebp),%eax
c0101476:	89 04 24             	mov    %eax,(%esp)
c0101479:	e8 90 ff ff ff       	call   c010140e <serial_putc_sub>
c010147e:	eb 24                	jmp    c01014a4 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c0101480:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101487:	e8 82 ff ff ff       	call   c010140e <serial_putc_sub>
        serial_putc_sub(' ');
c010148c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101493:	e8 76 ff ff ff       	call   c010140e <serial_putc_sub>
        serial_putc_sub('\b');
c0101498:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010149f:	e8 6a ff ff ff       	call   c010140e <serial_putc_sub>
    }
}
c01014a4:	c9                   	leave  
c01014a5:	c3                   	ret    

c01014a6 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01014a6:	55                   	push   %ebp
c01014a7:	89 e5                	mov    %esp,%ebp
c01014a9:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01014ac:	eb 33                	jmp    c01014e1 <cons_intr+0x3b>
        if (c != 0) {
c01014ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01014b2:	74 2d                	je     c01014e1 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01014b4:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c01014b9:	8d 50 01             	lea    0x1(%eax),%edx
c01014bc:	89 15 a4 c5 19 c0    	mov    %edx,0xc019c5a4
c01014c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01014c5:	88 90 a0 c3 19 c0    	mov    %dl,-0x3fe63c60(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01014cb:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c01014d0:	3d 00 02 00 00       	cmp    $0x200,%eax
c01014d5:	75 0a                	jne    c01014e1 <cons_intr+0x3b>
                cons.wpos = 0;
c01014d7:	c7 05 a4 c5 19 c0 00 	movl   $0x0,0xc019c5a4
c01014de:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01014e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01014e4:	ff d0                	call   *%eax
c01014e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01014e9:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01014ed:	75 bf                	jne    c01014ae <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01014ef:	c9                   	leave  
c01014f0:	c3                   	ret    

c01014f1 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01014f1:	55                   	push   %ebp
c01014f2:	89 e5                	mov    %esp,%ebp
c01014f4:	83 ec 10             	sub    $0x10,%esp
c01014f7:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014fd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101501:	89 c2                	mov    %eax,%edx
c0101503:	ec                   	in     (%dx),%al
c0101504:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101507:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010150b:	0f b6 c0             	movzbl %al,%eax
c010150e:	83 e0 01             	and    $0x1,%eax
c0101511:	85 c0                	test   %eax,%eax
c0101513:	75 07                	jne    c010151c <serial_proc_data+0x2b>
        return -1;
c0101515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010151a:	eb 2a                	jmp    c0101546 <serial_proc_data+0x55>
c010151c:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101522:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101526:	89 c2                	mov    %eax,%edx
c0101528:	ec                   	in     (%dx),%al
c0101529:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c010152c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101530:	0f b6 c0             	movzbl %al,%eax
c0101533:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101536:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010153a:	75 07                	jne    c0101543 <serial_proc_data+0x52>
        c = '\b';
c010153c:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101543:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101546:	c9                   	leave  
c0101547:	c3                   	ret    

c0101548 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101548:	55                   	push   %ebp
c0101549:	89 e5                	mov    %esp,%ebp
c010154b:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010154e:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c0101553:	85 c0                	test   %eax,%eax
c0101555:	74 0c                	je     c0101563 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101557:	c7 04 24 f1 14 10 c0 	movl   $0xc01014f1,(%esp)
c010155e:	e8 43 ff ff ff       	call   c01014a6 <cons_intr>
    }
}
c0101563:	c9                   	leave  
c0101564:	c3                   	ret    

c0101565 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101565:	55                   	push   %ebp
c0101566:	89 e5                	mov    %esp,%ebp
c0101568:	83 ec 38             	sub    $0x38,%esp
c010156b:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101571:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101575:	89 c2                	mov    %eax,%edx
c0101577:	ec                   	in     (%dx),%al
c0101578:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010157b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010157f:	0f b6 c0             	movzbl %al,%eax
c0101582:	83 e0 01             	and    $0x1,%eax
c0101585:	85 c0                	test   %eax,%eax
c0101587:	75 0a                	jne    c0101593 <kbd_proc_data+0x2e>
        return -1;
c0101589:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010158e:	e9 59 01 00 00       	jmp    c01016ec <kbd_proc_data+0x187>
c0101593:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101599:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010159d:	89 c2                	mov    %eax,%edx
c010159f:	ec                   	in     (%dx),%al
c01015a0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01015a3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01015a7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01015aa:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01015ae:	75 17                	jne    c01015c7 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c01015b0:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01015b5:	83 c8 40             	or     $0x40,%eax
c01015b8:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
        return 0;
c01015bd:	b8 00 00 00 00       	mov    $0x0,%eax
c01015c2:	e9 25 01 00 00       	jmp    c01016ec <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01015c7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015cb:	84 c0                	test   %al,%al
c01015cd:	79 47                	jns    c0101616 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01015cf:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01015d4:	83 e0 40             	and    $0x40,%eax
c01015d7:	85 c0                	test   %eax,%eax
c01015d9:	75 09                	jne    c01015e4 <kbd_proc_data+0x7f>
c01015db:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015df:	83 e0 7f             	and    $0x7f,%eax
c01015e2:	eb 04                	jmp    c01015e8 <kbd_proc_data+0x83>
c01015e4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015e8:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01015eb:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015ef:	0f b6 80 60 a0 12 c0 	movzbl -0x3fed5fa0(%eax),%eax
c01015f6:	83 c8 40             	or     $0x40,%eax
c01015f9:	0f b6 c0             	movzbl %al,%eax
c01015fc:	f7 d0                	not    %eax
c01015fe:	89 c2                	mov    %eax,%edx
c0101600:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101605:	21 d0                	and    %edx,%eax
c0101607:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
        return 0;
c010160c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101611:	e9 d6 00 00 00       	jmp    c01016ec <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c0101616:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010161b:	83 e0 40             	and    $0x40,%eax
c010161e:	85 c0                	test   %eax,%eax
c0101620:	74 11                	je     c0101633 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101622:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101626:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010162b:	83 e0 bf             	and    $0xffffffbf,%eax
c010162e:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
    }

    shift |= shiftcode[data];
c0101633:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101637:	0f b6 80 60 a0 12 c0 	movzbl -0x3fed5fa0(%eax),%eax
c010163e:	0f b6 d0             	movzbl %al,%edx
c0101641:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101646:	09 d0                	or     %edx,%eax
c0101648:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8
    shift ^= togglecode[data];
c010164d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101651:	0f b6 80 60 a1 12 c0 	movzbl -0x3fed5ea0(%eax),%eax
c0101658:	0f b6 d0             	movzbl %al,%edx
c010165b:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c0101660:	31 d0                	xor    %edx,%eax
c0101662:	a3 a8 c5 19 c0       	mov    %eax,0xc019c5a8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101667:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010166c:	83 e0 03             	and    $0x3,%eax
c010166f:	8b 14 85 60 a5 12 c0 	mov    -0x3fed5aa0(,%eax,4),%edx
c0101676:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010167a:	01 d0                	add    %edx,%eax
c010167c:	0f b6 00             	movzbl (%eax),%eax
c010167f:	0f b6 c0             	movzbl %al,%eax
c0101682:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101685:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c010168a:	83 e0 08             	and    $0x8,%eax
c010168d:	85 c0                	test   %eax,%eax
c010168f:	74 22                	je     c01016b3 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101691:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101695:	7e 0c                	jle    c01016a3 <kbd_proc_data+0x13e>
c0101697:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010169b:	7f 06                	jg     c01016a3 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010169d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01016a1:	eb 10                	jmp    c01016b3 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01016a3:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01016a7:	7e 0a                	jle    c01016b3 <kbd_proc_data+0x14e>
c01016a9:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01016ad:	7f 04                	jg     c01016b3 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01016af:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01016b3:	a1 a8 c5 19 c0       	mov    0xc019c5a8,%eax
c01016b8:	f7 d0                	not    %eax
c01016ba:	83 e0 06             	and    $0x6,%eax
c01016bd:	85 c0                	test   %eax,%eax
c01016bf:	75 28                	jne    c01016e9 <kbd_proc_data+0x184>
c01016c1:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01016c8:	75 1f                	jne    c01016e9 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01016ca:	c7 04 24 9d c1 10 c0 	movl   $0xc010c19d,(%esp)
c01016d1:	e8 7d ec ff ff       	call   c0100353 <cprintf>
c01016d6:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01016dc:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016e0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01016e4:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01016e8:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01016e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016ec:	c9                   	leave  
c01016ed:	c3                   	ret    

c01016ee <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01016ee:	55                   	push   %ebp
c01016ef:	89 e5                	mov    %esp,%ebp
c01016f1:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01016f4:	c7 04 24 65 15 10 c0 	movl   $0xc0101565,(%esp)
c01016fb:	e8 a6 fd ff ff       	call   c01014a6 <cons_intr>
}
c0101700:	c9                   	leave  
c0101701:	c3                   	ret    

c0101702 <kbd_init>:

static void
kbd_init(void) {
c0101702:	55                   	push   %ebp
c0101703:	89 e5                	mov    %esp,%ebp
c0101705:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101708:	e8 e1 ff ff ff       	call   c01016ee <kbd_intr>
    pic_enable(IRQ_KBD);
c010170d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101714:	e8 b2 09 00 00       	call   c01020cb <pic_enable>
}
c0101719:	c9                   	leave  
c010171a:	c3                   	ret    

c010171b <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c010171b:	55                   	push   %ebp
c010171c:	89 e5                	mov    %esp,%ebp
c010171e:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101721:	e8 93 f8 ff ff       	call   c0100fb9 <cga_init>
    serial_init();
c0101726:	e8 74 f9 ff ff       	call   c010109f <serial_init>
    kbd_init();
c010172b:	e8 d2 ff ff ff       	call   c0101702 <kbd_init>
    if (!serial_exists) {
c0101730:	a1 88 c3 19 c0       	mov    0xc019c388,%eax
c0101735:	85 c0                	test   %eax,%eax
c0101737:	75 0c                	jne    c0101745 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101739:	c7 04 24 a9 c1 10 c0 	movl   $0xc010c1a9,(%esp)
c0101740:	e8 0e ec ff ff       	call   c0100353 <cprintf>
    }
}
c0101745:	c9                   	leave  
c0101746:	c3                   	ret    

c0101747 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101747:	55                   	push   %ebp
c0101748:	89 e5                	mov    %esp,%ebp
c010174a:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010174d:	e8 e2 f7 ff ff       	call   c0100f34 <__intr_save>
c0101752:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101755:	8b 45 08             	mov    0x8(%ebp),%eax
c0101758:	89 04 24             	mov    %eax,(%esp)
c010175b:	e8 9b fa ff ff       	call   c01011fb <lpt_putc>
        cga_putc(c);
c0101760:	8b 45 08             	mov    0x8(%ebp),%eax
c0101763:	89 04 24             	mov    %eax,(%esp)
c0101766:	e8 cf fa ff ff       	call   c010123a <cga_putc>
        serial_putc(c);
c010176b:	8b 45 08             	mov    0x8(%ebp),%eax
c010176e:	89 04 24             	mov    %eax,(%esp)
c0101771:	e8 f1 fc ff ff       	call   c0101467 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101779:	89 04 24             	mov    %eax,(%esp)
c010177c:	e8 dd f7 ff ff       	call   c0100f5e <__intr_restore>
}
c0101781:	c9                   	leave  
c0101782:	c3                   	ret    

c0101783 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101783:	55                   	push   %ebp
c0101784:	89 e5                	mov    %esp,%ebp
c0101786:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101789:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101790:	e8 9f f7 ff ff       	call   c0100f34 <__intr_save>
c0101795:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101798:	e8 ab fd ff ff       	call   c0101548 <serial_intr>
        kbd_intr();
c010179d:	e8 4c ff ff ff       	call   c01016ee <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01017a2:	8b 15 a0 c5 19 c0    	mov    0xc019c5a0,%edx
c01017a8:	a1 a4 c5 19 c0       	mov    0xc019c5a4,%eax
c01017ad:	39 c2                	cmp    %eax,%edx
c01017af:	74 31                	je     c01017e2 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01017b1:	a1 a0 c5 19 c0       	mov    0xc019c5a0,%eax
c01017b6:	8d 50 01             	lea    0x1(%eax),%edx
c01017b9:	89 15 a0 c5 19 c0    	mov    %edx,0xc019c5a0
c01017bf:	0f b6 80 a0 c3 19 c0 	movzbl -0x3fe63c60(%eax),%eax
c01017c6:	0f b6 c0             	movzbl %al,%eax
c01017c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01017cc:	a1 a0 c5 19 c0       	mov    0xc019c5a0,%eax
c01017d1:	3d 00 02 00 00       	cmp    $0x200,%eax
c01017d6:	75 0a                	jne    c01017e2 <cons_getc+0x5f>
                cons.rpos = 0;
c01017d8:	c7 05 a0 c5 19 c0 00 	movl   $0x0,0xc019c5a0
c01017df:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01017e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017e5:	89 04 24             	mov    %eax,(%esp)
c01017e8:	e8 71 f7 ff ff       	call   c0100f5e <__intr_restore>
    return c;
c01017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017f0:	c9                   	leave  
c01017f1:	c3                   	ret    

c01017f2 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01017f2:	55                   	push   %ebp
c01017f3:	89 e5                	mov    %esp,%ebp
c01017f5:	83 ec 14             	sub    $0x14,%esp
c01017f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01017fb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01017ff:	90                   	nop
c0101800:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101804:	83 c0 07             	add    $0x7,%eax
c0101807:	0f b7 c0             	movzwl %ax,%eax
c010180a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010180e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101812:	89 c2                	mov    %eax,%edx
c0101814:	ec                   	in     (%dx),%al
c0101815:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101818:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010181c:	0f b6 c0             	movzbl %al,%eax
c010181f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101822:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101825:	25 80 00 00 00       	and    $0x80,%eax
c010182a:	85 c0                	test   %eax,%eax
c010182c:	75 d2                	jne    c0101800 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010182e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101832:	74 11                	je     c0101845 <ide_wait_ready+0x53>
c0101834:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101837:	83 e0 21             	and    $0x21,%eax
c010183a:	85 c0                	test   %eax,%eax
c010183c:	74 07                	je     c0101845 <ide_wait_ready+0x53>
        return -1;
c010183e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101843:	eb 05                	jmp    c010184a <ide_wait_ready+0x58>
    }
    return 0;
c0101845:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010184a:	c9                   	leave  
c010184b:	c3                   	ret    

c010184c <ide_init>:

void
ide_init(void) {
c010184c:	55                   	push   %ebp
c010184d:	89 e5                	mov    %esp,%ebp
c010184f:	57                   	push   %edi
c0101850:	53                   	push   %ebx
c0101851:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101857:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010185d:	e9 d6 02 00 00       	jmp    c0101b38 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0101862:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101866:	c1 e0 03             	shl    $0x3,%eax
c0101869:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101870:	29 c2                	sub    %eax,%edx
c0101872:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101878:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c010187b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010187f:	66 d1 e8             	shr    %ax
c0101882:	0f b7 c0             	movzwl %ax,%eax
c0101885:	0f b7 04 85 c8 c1 10 	movzwl -0x3fef3e38(,%eax,4),%eax
c010188c:	c0 
c010188d:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0101891:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101895:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010189c:	00 
c010189d:	89 04 24             	mov    %eax,(%esp)
c01018a0:	e8 4d ff ff ff       	call   c01017f2 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01018a5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018a9:	83 e0 01             	and    $0x1,%eax
c01018ac:	c1 e0 04             	shl    $0x4,%eax
c01018af:	83 c8 e0             	or     $0xffffffe0,%eax
c01018b2:	0f b6 c0             	movzbl %al,%eax
c01018b5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018b9:	83 c2 06             	add    $0x6,%edx
c01018bc:	0f b7 d2             	movzwl %dx,%edx
c01018bf:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01018c3:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01018ca:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01018ce:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018cf:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01018da:	00 
c01018db:	89 04 24             	mov    %eax,(%esp)
c01018de:	e8 0f ff ff ff       	call   c01017f2 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01018e3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01018e7:	83 c0 07             	add    $0x7,%eax
c01018ea:	0f b7 c0             	movzwl %ax,%eax
c01018ed:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01018f1:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01018f5:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01018f9:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01018fd:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01018fe:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101902:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101909:	00 
c010190a:	89 04 24             	mov    %eax,(%esp)
c010190d:	e8 e0 fe ff ff       	call   c01017f2 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0101912:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101916:	83 c0 07             	add    $0x7,%eax
c0101919:	0f b7 c0             	movzwl %ax,%eax
c010191c:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101920:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0101924:	89 c2                	mov    %eax,%edx
c0101926:	ec                   	in     (%dx),%al
c0101927:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c010192a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010192e:	84 c0                	test   %al,%al
c0101930:	0f 84 f7 01 00 00    	je     c0101b2d <ide_init+0x2e1>
c0101936:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010193a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101941:	00 
c0101942:	89 04 24             	mov    %eax,(%esp)
c0101945:	e8 a8 fe ff ff       	call   c01017f2 <ide_wait_ready>
c010194a:	85 c0                	test   %eax,%eax
c010194c:	0f 85 db 01 00 00    	jne    c0101b2d <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0101952:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101956:	c1 e0 03             	shl    $0x3,%eax
c0101959:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101960:	29 c2                	sub    %eax,%edx
c0101962:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101968:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010196b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010196f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0101972:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101978:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010197b:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101982:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101985:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101988:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010198b:	89 cb                	mov    %ecx,%ebx
c010198d:	89 df                	mov    %ebx,%edi
c010198f:	89 c1                	mov    %eax,%ecx
c0101991:	fc                   	cld    
c0101992:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101994:	89 c8                	mov    %ecx,%eax
c0101996:	89 fb                	mov    %edi,%ebx
c0101998:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010199b:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010199e:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01019a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01019a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019aa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01019b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01019b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019b6:	25 00 00 00 04       	and    $0x4000000,%eax
c01019bb:	85 c0                	test   %eax,%eax
c01019bd:	74 0e                	je     c01019cd <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01019bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019c2:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01019c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01019cb:	eb 09                	jmp    c01019d6 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01019cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01019d0:	8b 40 78             	mov    0x78(%eax),%eax
c01019d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01019d6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019da:	c1 e0 03             	shl    $0x3,%eax
c01019dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019e4:	29 c2                	sub    %eax,%edx
c01019e6:	81 c2 c0 c5 19 c0    	add    $0xc019c5c0,%edx
c01019ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01019ef:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01019f2:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019f6:	c1 e0 03             	shl    $0x3,%eax
c01019f9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a00:	29 c2                	sub    %eax,%edx
c0101a02:	81 c2 c0 c5 19 c0    	add    $0xc019c5c0,%edx
c0101a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101a0b:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101a0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a11:	83 c0 62             	add    $0x62,%eax
c0101a14:	0f b7 00             	movzwl (%eax),%eax
c0101a17:	0f b7 c0             	movzwl %ax,%eax
c0101a1a:	25 00 02 00 00       	and    $0x200,%eax
c0101a1f:	85 c0                	test   %eax,%eax
c0101a21:	75 24                	jne    c0101a47 <ide_init+0x1fb>
c0101a23:	c7 44 24 0c d0 c1 10 	movl   $0xc010c1d0,0xc(%esp)
c0101a2a:	c0 
c0101a2b:	c7 44 24 08 13 c2 10 	movl   $0xc010c213,0x8(%esp)
c0101a32:	c0 
c0101a33:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101a3a:	00 
c0101a3b:	c7 04 24 28 c2 10 c0 	movl   $0xc010c228,(%esp)
c0101a42:	e8 ce f3 ff ff       	call   c0100e15 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101a47:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a4b:	c1 e0 03             	shl    $0x3,%eax
c0101a4e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a55:	29 c2                	sub    %eax,%edx
c0101a57:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101a5d:	83 c0 0c             	add    $0xc,%eax
c0101a60:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a66:	83 c0 36             	add    $0x36,%eax
c0101a69:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101a6c:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101a73:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101a7a:	eb 34                	jmp    c0101ab0 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a7f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a82:	01 c2                	add    %eax,%edx
c0101a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a87:	8d 48 01             	lea    0x1(%eax),%ecx
c0101a8a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a8d:	01 c8                	add    %ecx,%eax
c0101a8f:	0f b6 00             	movzbl (%eax),%eax
c0101a92:	88 02                	mov    %al,(%edx)
c0101a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101a97:	8d 50 01             	lea    0x1(%eax),%edx
c0101a9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a9d:	01 c2                	add    %eax,%edx
c0101a9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aa2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101aa5:	01 c8                	add    %ecx,%eax
c0101aa7:	0f b6 00             	movzbl (%eax),%eax
c0101aaa:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101aac:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101ab0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ab3:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101ab6:	72 c4                	jb     c0101a7c <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101ab8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101abb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101abe:	01 d0                	add    %edx,%eax
c0101ac0:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101ac3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ac6:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101ac9:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101acc:	85 c0                	test   %eax,%eax
c0101ace:	74 0f                	je     c0101adf <ide_init+0x293>
c0101ad0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ad3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101ad6:	01 d0                	add    %edx,%eax
c0101ad8:	0f b6 00             	movzbl (%eax),%eax
c0101adb:	3c 20                	cmp    $0x20,%al
c0101add:	74 d9                	je     c0101ab8 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101adf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101ae3:	c1 e0 03             	shl    $0x3,%eax
c0101ae6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aed:	29 c2                	sub    %eax,%edx
c0101aef:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101af5:	8d 48 0c             	lea    0xc(%eax),%ecx
c0101af8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101afc:	c1 e0 03             	shl    $0x3,%eax
c0101aff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b06:	29 c2                	sub    %eax,%edx
c0101b08:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101b0e:	8b 50 08             	mov    0x8(%eax),%edx
c0101b11:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b15:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101b19:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b21:	c7 04 24 3a c2 10 c0 	movl   $0xc010c23a,(%esp)
c0101b28:	e8 26 e8 ff ff       	call   c0100353 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101b2d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101b31:	83 c0 01             	add    $0x1,%eax
c0101b34:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b38:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101b3d:	0f 86 1f fd ff ff    	jbe    c0101862 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101b43:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101b4a:	e8 7c 05 00 00       	call   c01020cb <pic_enable>
    pic_enable(IRQ_IDE2);
c0101b4f:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101b56:	e8 70 05 00 00       	call   c01020cb <pic_enable>
}
c0101b5b:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101b61:	5b                   	pop    %ebx
c0101b62:	5f                   	pop    %edi
c0101b63:	5d                   	pop    %ebp
c0101b64:	c3                   	ret    

c0101b65 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101b65:	55                   	push   %ebp
c0101b66:	89 e5                	mov    %esp,%ebp
c0101b68:	83 ec 04             	sub    $0x4,%esp
c0101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b6e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101b72:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101b77:	77 24                	ja     c0101b9d <ide_device_valid+0x38>
c0101b79:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101b7d:	c1 e0 03             	shl    $0x3,%eax
c0101b80:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101b87:	29 c2                	sub    %eax,%edx
c0101b89:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101b8f:	0f b6 00             	movzbl (%eax),%eax
c0101b92:	84 c0                	test   %al,%al
c0101b94:	74 07                	je     c0101b9d <ide_device_valid+0x38>
c0101b96:	b8 01 00 00 00       	mov    $0x1,%eax
c0101b9b:	eb 05                	jmp    c0101ba2 <ide_device_valid+0x3d>
c0101b9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ba2:	c9                   	leave  
c0101ba3:	c3                   	ret    

c0101ba4 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101ba4:	55                   	push   %ebp
c0101ba5:	89 e5                	mov    %esp,%ebp
c0101ba7:	83 ec 08             	sub    $0x8,%esp
c0101baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bad:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101bb1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bb5:	89 04 24             	mov    %eax,(%esp)
c0101bb8:	e8 a8 ff ff ff       	call   c0101b65 <ide_device_valid>
c0101bbd:	85 c0                	test   %eax,%eax
c0101bbf:	74 1b                	je     c0101bdc <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101bc1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101bc5:	c1 e0 03             	shl    $0x3,%eax
c0101bc8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101bcf:	29 c2                	sub    %eax,%edx
c0101bd1:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101bd7:	8b 40 08             	mov    0x8(%eax),%eax
c0101bda:	eb 05                	jmp    c0101be1 <ide_device_size+0x3d>
    }
    return 0;
c0101bdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101be1:	c9                   	leave  
c0101be2:	c3                   	ret    

c0101be3 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101be3:	55                   	push   %ebp
c0101be4:	89 e5                	mov    %esp,%ebp
c0101be6:	57                   	push   %edi
c0101be7:	53                   	push   %ebx
c0101be8:	83 ec 50             	sub    $0x50,%esp
c0101beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bee:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101bf2:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101bf9:	77 24                	ja     c0101c1f <ide_read_secs+0x3c>
c0101bfb:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101c00:	77 1d                	ja     c0101c1f <ide_read_secs+0x3c>
c0101c02:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c06:	c1 e0 03             	shl    $0x3,%eax
c0101c09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101c10:	29 c2                	sub    %eax,%edx
c0101c12:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101c18:	0f b6 00             	movzbl (%eax),%eax
c0101c1b:	84 c0                	test   %al,%al
c0101c1d:	75 24                	jne    c0101c43 <ide_read_secs+0x60>
c0101c1f:	c7 44 24 0c 58 c2 10 	movl   $0xc010c258,0xc(%esp)
c0101c26:	c0 
c0101c27:	c7 44 24 08 13 c2 10 	movl   $0xc010c213,0x8(%esp)
c0101c2e:	c0 
c0101c2f:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101c36:	00 
c0101c37:	c7 04 24 28 c2 10 c0 	movl   $0xc010c228,(%esp)
c0101c3e:	e8 d2 f1 ff ff       	call   c0100e15 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101c43:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101c4a:	77 0f                	ja     c0101c5b <ide_read_secs+0x78>
c0101c4c:	8b 45 14             	mov    0x14(%ebp),%eax
c0101c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101c52:	01 d0                	add    %edx,%eax
c0101c54:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101c59:	76 24                	jbe    c0101c7f <ide_read_secs+0x9c>
c0101c5b:	c7 44 24 0c 80 c2 10 	movl   $0xc010c280,0xc(%esp)
c0101c62:	c0 
c0101c63:	c7 44 24 08 13 c2 10 	movl   $0xc010c213,0x8(%esp)
c0101c6a:	c0 
c0101c6b:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101c72:	00 
c0101c73:	c7 04 24 28 c2 10 c0 	movl   $0xc010c228,(%esp)
c0101c7a:	e8 96 f1 ff ff       	call   c0100e15 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101c7f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c83:	66 d1 e8             	shr    %ax
c0101c86:	0f b7 c0             	movzwl %ax,%eax
c0101c89:	0f b7 04 85 c8 c1 10 	movzwl -0x3fef3e38(,%eax,4),%eax
c0101c90:	c0 
c0101c91:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101c95:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c99:	66 d1 e8             	shr    %ax
c0101c9c:	0f b7 c0             	movzwl %ax,%eax
c0101c9f:	0f b7 04 85 ca c1 10 	movzwl -0x3fef3e36(,%eax,4),%eax
c0101ca6:	c0 
c0101ca7:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101cab:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101caf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101cb6:	00 
c0101cb7:	89 04 24             	mov    %eax,(%esp)
c0101cba:	e8 33 fb ff ff       	call   c01017f2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101cbf:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101cc3:	83 c0 02             	add    $0x2,%eax
c0101cc6:	0f b7 c0             	movzwl %ax,%eax
c0101cc9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101ccd:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101cd1:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101cd5:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101cd9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101cda:	8b 45 14             	mov    0x14(%ebp),%eax
c0101cdd:	0f b6 c0             	movzbl %al,%eax
c0101ce0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ce4:	83 c2 02             	add    $0x2,%edx
c0101ce7:	0f b7 d2             	movzwl %dx,%edx
c0101cea:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101cee:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101cf1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101cf5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101cf9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cfd:	0f b6 c0             	movzbl %al,%eax
c0101d00:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d04:	83 c2 03             	add    $0x3,%edx
c0101d07:	0f b7 d2             	movzwl %dx,%edx
c0101d0a:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101d0e:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101d11:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101d15:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101d19:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d1d:	c1 e8 08             	shr    $0x8,%eax
c0101d20:	0f b6 c0             	movzbl %al,%eax
c0101d23:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d27:	83 c2 04             	add    $0x4,%edx
c0101d2a:	0f b7 d2             	movzwl %dx,%edx
c0101d2d:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101d31:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101d34:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101d38:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101d3c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d40:	c1 e8 10             	shr    $0x10,%eax
c0101d43:	0f b6 c0             	movzbl %al,%eax
c0101d46:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d4a:	83 c2 05             	add    $0x5,%edx
c0101d4d:	0f b7 d2             	movzwl %dx,%edx
c0101d50:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101d54:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101d57:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101d5b:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101d5f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101d60:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d64:	83 e0 01             	and    $0x1,%eax
c0101d67:	c1 e0 04             	shl    $0x4,%eax
c0101d6a:	89 c2                	mov    %eax,%edx
c0101d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101d6f:	c1 e8 18             	shr    $0x18,%eax
c0101d72:	83 e0 0f             	and    $0xf,%eax
c0101d75:	09 d0                	or     %edx,%eax
c0101d77:	83 c8 e0             	or     $0xffffffe0,%eax
c0101d7a:	0f b6 c0             	movzbl %al,%eax
c0101d7d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101d81:	83 c2 06             	add    $0x6,%edx
c0101d84:	0f b7 d2             	movzwl %dx,%edx
c0101d87:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101d8b:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101d8e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101d92:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101d96:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101d97:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101d9b:	83 c0 07             	add    $0x7,%eax
c0101d9e:	0f b7 c0             	movzwl %ax,%eax
c0101da1:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101da5:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101da9:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101dad:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101db1:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101db2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101db9:	eb 5a                	jmp    c0101e15 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101dbb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dbf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101dc6:	00 
c0101dc7:	89 04 24             	mov    %eax,(%esp)
c0101dca:	e8 23 fa ff ff       	call   c01017f2 <ide_wait_ready>
c0101dcf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101dd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101dd6:	74 02                	je     c0101dda <ide_read_secs+0x1f7>
            goto out;
c0101dd8:	eb 41                	jmp    c0101e1b <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101dda:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dde:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101de1:	8b 45 10             	mov    0x10(%ebp),%eax
c0101de4:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101de7:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101dee:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101df1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101df4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101df7:	89 cb                	mov    %ecx,%ebx
c0101df9:	89 df                	mov    %ebx,%edi
c0101dfb:	89 c1                	mov    %eax,%ecx
c0101dfd:	fc                   	cld    
c0101dfe:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101e00:	89 c8                	mov    %ecx,%eax
c0101e02:	89 fb                	mov    %edi,%ebx
c0101e04:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101e07:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101e0a:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101e0e:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101e15:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101e19:	75 a0                	jne    c0101dbb <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e1e:	83 c4 50             	add    $0x50,%esp
c0101e21:	5b                   	pop    %ebx
c0101e22:	5f                   	pop    %edi
c0101e23:	5d                   	pop    %ebp
c0101e24:	c3                   	ret    

c0101e25 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101e25:	55                   	push   %ebp
c0101e26:	89 e5                	mov    %esp,%ebp
c0101e28:	56                   	push   %esi
c0101e29:	53                   	push   %ebx
c0101e2a:	83 ec 50             	sub    $0x50,%esp
c0101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e30:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101e34:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101e3b:	77 24                	ja     c0101e61 <ide_write_secs+0x3c>
c0101e3d:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101e42:	77 1d                	ja     c0101e61 <ide_write_secs+0x3c>
c0101e44:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e48:	c1 e0 03             	shl    $0x3,%eax
c0101e4b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101e52:	29 c2                	sub    %eax,%edx
c0101e54:	8d 82 c0 c5 19 c0    	lea    -0x3fe63a40(%edx),%eax
c0101e5a:	0f b6 00             	movzbl (%eax),%eax
c0101e5d:	84 c0                	test   %al,%al
c0101e5f:	75 24                	jne    c0101e85 <ide_write_secs+0x60>
c0101e61:	c7 44 24 0c 58 c2 10 	movl   $0xc010c258,0xc(%esp)
c0101e68:	c0 
c0101e69:	c7 44 24 08 13 c2 10 	movl   $0xc010c213,0x8(%esp)
c0101e70:	c0 
c0101e71:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101e78:	00 
c0101e79:	c7 04 24 28 c2 10 c0 	movl   $0xc010c228,(%esp)
c0101e80:	e8 90 ef ff ff       	call   c0100e15 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101e85:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101e8c:	77 0f                	ja     c0101e9d <ide_write_secs+0x78>
c0101e8e:	8b 45 14             	mov    0x14(%ebp),%eax
c0101e91:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101e94:	01 d0                	add    %edx,%eax
c0101e96:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101e9b:	76 24                	jbe    c0101ec1 <ide_write_secs+0x9c>
c0101e9d:	c7 44 24 0c 80 c2 10 	movl   $0xc010c280,0xc(%esp)
c0101ea4:	c0 
c0101ea5:	c7 44 24 08 13 c2 10 	movl   $0xc010c213,0x8(%esp)
c0101eac:	c0 
c0101ead:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101eb4:	00 
c0101eb5:	c7 04 24 28 c2 10 c0 	movl   $0xc010c228,(%esp)
c0101ebc:	e8 54 ef ff ff       	call   c0100e15 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101ec1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ec5:	66 d1 e8             	shr    %ax
c0101ec8:	0f b7 c0             	movzwl %ax,%eax
c0101ecb:	0f b7 04 85 c8 c1 10 	movzwl -0x3fef3e38(,%eax,4),%eax
c0101ed2:	c0 
c0101ed3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ed7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101edb:	66 d1 e8             	shr    %ax
c0101ede:	0f b7 c0             	movzwl %ax,%eax
c0101ee1:	0f b7 04 85 ca c1 10 	movzwl -0x3fef3e36(,%eax,4),%eax
c0101ee8:	c0 
c0101ee9:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101eed:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ef1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101ef8:	00 
c0101ef9:	89 04 24             	mov    %eax,(%esp)
c0101efc:	e8 f1 f8 ff ff       	call   c01017f2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101f01:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101f05:	83 c0 02             	add    $0x2,%eax
c0101f08:	0f b7 c0             	movzwl %ax,%eax
c0101f0b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101f0f:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f13:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101f17:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f1b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101f1c:	8b 45 14             	mov    0x14(%ebp),%eax
c0101f1f:	0f b6 c0             	movzbl %al,%eax
c0101f22:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f26:	83 c2 02             	add    $0x2,%edx
c0101f29:	0f b7 d2             	movzwl %dx,%edx
c0101f2c:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101f30:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101f33:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f37:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101f3b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f3f:	0f b6 c0             	movzbl %al,%eax
c0101f42:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f46:	83 c2 03             	add    $0x3,%edx
c0101f49:	0f b7 d2             	movzwl %dx,%edx
c0101f4c:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101f50:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101f53:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101f57:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101f5b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f5f:	c1 e8 08             	shr    $0x8,%eax
c0101f62:	0f b6 c0             	movzbl %al,%eax
c0101f65:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f69:	83 c2 04             	add    $0x4,%edx
c0101f6c:	0f b7 d2             	movzwl %dx,%edx
c0101f6f:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101f73:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101f76:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101f7a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101f7e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f82:	c1 e8 10             	shr    $0x10,%eax
c0101f85:	0f b6 c0             	movzbl %al,%eax
c0101f88:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101f8c:	83 c2 05             	add    $0x5,%edx
c0101f8f:	0f b7 d2             	movzwl %dx,%edx
c0101f92:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101f96:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101f99:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101f9d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101fa1:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101fa2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101fa6:	83 e0 01             	and    $0x1,%eax
c0101fa9:	c1 e0 04             	shl    $0x4,%eax
c0101fac:	89 c2                	mov    %eax,%edx
c0101fae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101fb1:	c1 e8 18             	shr    $0x18,%eax
c0101fb4:	83 e0 0f             	and    $0xf,%eax
c0101fb7:	09 d0                	or     %edx,%eax
c0101fb9:	83 c8 e0             	or     $0xffffffe0,%eax
c0101fbc:	0f b6 c0             	movzbl %al,%eax
c0101fbf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101fc3:	83 c2 06             	add    $0x6,%edx
c0101fc6:	0f b7 d2             	movzwl %dx,%edx
c0101fc9:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101fcd:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101fd0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101fd4:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101fd8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101fd9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101fdd:	83 c0 07             	add    $0x7,%eax
c0101fe0:	0f b7 c0             	movzwl %ax,%eax
c0101fe3:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101fe7:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101feb:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101fef:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101ff3:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101ff4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101ffb:	eb 5a                	jmp    c0102057 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101ffd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102001:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0102008:	00 
c0102009:	89 04 24             	mov    %eax,(%esp)
c010200c:	e8 e1 f7 ff ff       	call   c01017f2 <ide_wait_ready>
c0102011:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102014:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102018:	74 02                	je     c010201c <ide_write_secs+0x1f7>
            goto out;
c010201a:	eb 41                	jmp    c010205d <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c010201c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102020:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102023:	8b 45 10             	mov    0x10(%ebp),%eax
c0102026:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102029:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0102030:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102033:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0102036:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102039:	89 cb                	mov    %ecx,%ebx
c010203b:	89 de                	mov    %ebx,%esi
c010203d:	89 c1                	mov    %eax,%ecx
c010203f:	fc                   	cld    
c0102040:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102042:	89 c8                	mov    %ecx,%eax
c0102044:	89 f3                	mov    %esi,%ebx
c0102046:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0102049:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010204c:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102050:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102057:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010205b:	75 a0                	jne    c0101ffd <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c010205d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102060:	83 c4 50             	add    $0x50,%esp
c0102063:	5b                   	pop    %ebx
c0102064:	5e                   	pop    %esi
c0102065:	5d                   	pop    %ebp
c0102066:	c3                   	ret    

c0102067 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0102067:	55                   	push   %ebp
c0102068:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010206a:	fb                   	sti    
    sti();
}
c010206b:	5d                   	pop    %ebp
c010206c:	c3                   	ret    

c010206d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010206d:	55                   	push   %ebp
c010206e:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0102070:	fa                   	cli    
    cli();
}
c0102071:	5d                   	pop    %ebp
c0102072:	c3                   	ret    

c0102073 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102073:	55                   	push   %ebp
c0102074:	89 e5                	mov    %esp,%ebp
c0102076:	83 ec 14             	sub    $0x14,%esp
c0102079:	8b 45 08             	mov    0x8(%ebp),%eax
c010207c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0102080:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102084:	66 a3 70 a5 12 c0    	mov    %ax,0xc012a570
    if (did_init) {
c010208a:	a1 a0 c6 19 c0       	mov    0xc019c6a0,%eax
c010208f:	85 c0                	test   %eax,%eax
c0102091:	74 36                	je     c01020c9 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0102093:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102097:	0f b6 c0             	movzbl %al,%eax
c010209a:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020a0:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01020a3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01020a7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020ab:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01020ac:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01020b0:	66 c1 e8 08          	shr    $0x8,%ax
c01020b4:	0f b6 c0             	movzbl %al,%eax
c01020b7:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c01020bd:	88 45 f9             	mov    %al,-0x7(%ebp)
c01020c0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01020c4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01020c8:	ee                   	out    %al,(%dx)
    }
}
c01020c9:	c9                   	leave  
c01020ca:	c3                   	ret    

c01020cb <pic_enable>:

void
pic_enable(unsigned int irq) {
c01020cb:	55                   	push   %ebp
c01020cc:	89 e5                	mov    %esp,%ebp
c01020ce:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01020d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01020d4:	ba 01 00 00 00       	mov    $0x1,%edx
c01020d9:	89 c1                	mov    %eax,%ecx
c01020db:	d3 e2                	shl    %cl,%edx
c01020dd:	89 d0                	mov    %edx,%eax
c01020df:	f7 d0                	not    %eax
c01020e1:	89 c2                	mov    %eax,%edx
c01020e3:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c01020ea:	21 d0                	and    %edx,%eax
c01020ec:	0f b7 c0             	movzwl %ax,%eax
c01020ef:	89 04 24             	mov    %eax,(%esp)
c01020f2:	e8 7c ff ff ff       	call   c0102073 <pic_setmask>
}
c01020f7:	c9                   	leave  
c01020f8:	c3                   	ret    

c01020f9 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020f9:	55                   	push   %ebp
c01020fa:	89 e5                	mov    %esp,%ebp
c01020fc:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01020ff:	c7 05 a0 c6 19 c0 01 	movl   $0x1,0xc019c6a0
c0102106:	00 00 00 
c0102109:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010210f:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0102113:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0102117:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010211b:	ee                   	out    %al,(%dx)
c010211c:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0102122:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102126:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010212a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010212e:	ee                   	out    %al,(%dx)
c010212f:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102135:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102139:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010213d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102141:	ee                   	out    %al,(%dx)
c0102142:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102148:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c010214c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102150:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102154:	ee                   	out    %al,(%dx)
c0102155:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c010215b:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010215f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102163:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102167:	ee                   	out    %al,(%dx)
c0102168:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010216e:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c0102172:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102176:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010217a:	ee                   	out    %al,(%dx)
c010217b:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0102181:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102185:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102189:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010218d:	ee                   	out    %al,(%dx)
c010218e:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102194:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102198:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010219c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01021a0:	ee                   	out    %al,(%dx)
c01021a1:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c01021a7:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c01021ab:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01021af:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01021b3:	ee                   	out    %al,(%dx)
c01021b4:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c01021ba:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c01021be:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01021c2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01021c6:	ee                   	out    %al,(%dx)
c01021c7:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01021cd:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01021d1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01021d5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01021d9:	ee                   	out    %al,(%dx)
c01021da:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01021e0:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01021e4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01021e8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01021ec:	ee                   	out    %al,(%dx)
c01021ed:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01021f3:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01021f7:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01021fb:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01021ff:	ee                   	out    %al,(%dx)
c0102200:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c0102206:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c010220a:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010220e:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0102212:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0102213:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c010221a:	66 83 f8 ff          	cmp    $0xffff,%ax
c010221e:	74 12                	je     c0102232 <pic_init+0x139>
        pic_setmask(irq_mask);
c0102220:	0f b7 05 70 a5 12 c0 	movzwl 0xc012a570,%eax
c0102227:	0f b7 c0             	movzwl %ax,%eax
c010222a:	89 04 24             	mov    %eax,(%esp)
c010222d:	e8 41 fe ff ff       	call   c0102073 <pic_setmask>
    }
}
c0102232:	c9                   	leave  
c0102233:	c3                   	ret    

c0102234 <print_ticks>:
#include <sched.h>
#include <sync.h>

#define TICK_NUM 100

static void print_ticks() {
c0102234:	55                   	push   %ebp
c0102235:	89 e5                	mov    %esp,%ebp
c0102237:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010223a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102241:	00 
c0102242:	c7 04 24 c0 c2 10 c0 	movl   $0xc010c2c0,(%esp)
c0102249:	e8 05 e1 ff ff       	call   c0100353 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010224e:	c9                   	leave  
c010224f:	c3                   	ret    

c0102250 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102250:	55                   	push   %ebp
c0102251:	89 e5                	mov    %esp,%ebp
c0102253:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 2013011317 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; ++i) //The size of idt is 256
c0102256:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010225d:	e9 c3 00 00 00       	jmp    c0102325 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);// Use SETGATE macro to setup
c0102262:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102265:	8b 04 85 00 a6 12 c0 	mov    -0x3fed5a00(,%eax,4),%eax
c010226c:	89 c2                	mov    %eax,%edx
c010226e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102271:	66 89 14 c5 c0 c6 19 	mov    %dx,-0x3fe63940(,%eax,8)
c0102278:	c0 
c0102279:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227c:	66 c7 04 c5 c2 c6 19 	movw   $0x8,-0x3fe6393e(,%eax,8)
c0102283:	c0 08 00 
c0102286:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102289:	0f b6 14 c5 c4 c6 19 	movzbl -0x3fe6393c(,%eax,8),%edx
c0102290:	c0 
c0102291:	83 e2 e0             	and    $0xffffffe0,%edx
c0102294:	88 14 c5 c4 c6 19 c0 	mov    %dl,-0x3fe6393c(,%eax,8)
c010229b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010229e:	0f b6 14 c5 c4 c6 19 	movzbl -0x3fe6393c(,%eax,8),%edx
c01022a5:	c0 
c01022a6:	83 e2 1f             	and    $0x1f,%edx
c01022a9:	88 14 c5 c4 c6 19 c0 	mov    %dl,-0x3fe6393c(,%eax,8)
c01022b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022b3:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022ba:	c0 
c01022bb:	83 e2 f0             	and    $0xfffffff0,%edx
c01022be:	83 ca 0e             	or     $0xe,%edx
c01022c1:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022cb:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022d2:	c0 
c01022d3:	83 e2 ef             	and    $0xffffffef,%edx
c01022d6:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022e0:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022e7:	c0 
c01022e8:	83 e2 9f             	and    $0xffffff9f,%edx
c01022eb:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c01022f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f5:	0f b6 14 c5 c5 c6 19 	movzbl -0x3fe6393b(,%eax,8),%edx
c01022fc:	c0 
c01022fd:	83 ca 80             	or     $0xffffff80,%edx
c0102300:	88 14 c5 c5 c6 19 c0 	mov    %dl,-0x3fe6393b(,%eax,8)
c0102307:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010230a:	8b 04 85 00 a6 12 c0 	mov    -0x3fed5a00(,%eax,4),%eax
c0102311:	c1 e8 10             	shr    $0x10,%eax
c0102314:	89 c2                	mov    %eax,%edx
c0102316:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102319:	66 89 14 c5 c6 c6 19 	mov    %dx,-0x3fe6393a(,%eax,8)
c0102320:	c0 
     /* LAB5 2013011317 */
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; ++i) //The size of idt is 256
c0102321:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102325:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c010232c:	0f 8e 30 ff ff ff    	jle    c0102262 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);// Use SETGATE macro to setup
    SETGATE(idt[T_SWITCH_TOK], 1, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER); // switch
c0102332:	a1 e4 a7 12 c0       	mov    0xc012a7e4,%eax
c0102337:	66 a3 88 ca 19 c0    	mov    %ax,0xc019ca88
c010233d:	66 c7 05 8a ca 19 c0 	movw   $0x8,0xc019ca8a
c0102344:	08 00 
c0102346:	0f b6 05 8c ca 19 c0 	movzbl 0xc019ca8c,%eax
c010234d:	83 e0 e0             	and    $0xffffffe0,%eax
c0102350:	a2 8c ca 19 c0       	mov    %al,0xc019ca8c
c0102355:	0f b6 05 8c ca 19 c0 	movzbl 0xc019ca8c,%eax
c010235c:	83 e0 1f             	and    $0x1f,%eax
c010235f:	a2 8c ca 19 c0       	mov    %al,0xc019ca8c
c0102364:	0f b6 05 8d ca 19 c0 	movzbl 0xc019ca8d,%eax
c010236b:	83 c8 0f             	or     $0xf,%eax
c010236e:	a2 8d ca 19 c0       	mov    %al,0xc019ca8d
c0102373:	0f b6 05 8d ca 19 c0 	movzbl 0xc019ca8d,%eax
c010237a:	83 e0 ef             	and    $0xffffffef,%eax
c010237d:	a2 8d ca 19 c0       	mov    %al,0xc019ca8d
c0102382:	0f b6 05 8d ca 19 c0 	movzbl 0xc019ca8d,%eax
c0102389:	83 c8 60             	or     $0x60,%eax
c010238c:	a2 8d ca 19 c0       	mov    %al,0xc019ca8d
c0102391:	0f b6 05 8d ca 19 c0 	movzbl 0xc019ca8d,%eax
c0102398:	83 c8 80             	or     $0xffffff80,%eax
c010239b:	a2 8d ca 19 c0       	mov    %al,0xc019ca8d
c01023a0:	a1 e4 a7 12 c0       	mov    0xc012a7e4,%eax
c01023a5:	c1 e8 10             	shr    $0x10,%eax
c01023a8:	66 a3 8e ca 19 c0    	mov    %ax,0xc019ca8e
c01023ae:	c7 45 f8 80 a5 12 c0 	movl   $0xc012a580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01023b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01023b8:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c01023bb:	c9                   	leave  
c01023bc:	c3                   	ret    

c01023bd <trapname>:

static const char *
trapname(int trapno) {
c01023bd:	55                   	push   %ebp
c01023be:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01023c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c3:	83 f8 13             	cmp    $0x13,%eax
c01023c6:	77 0c                	ja     c01023d4 <trapname+0x17>
        return excnames[trapno];
c01023c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023cb:	8b 04 85 40 c7 10 c0 	mov    -0x3fef38c0(,%eax,4),%eax
c01023d2:	eb 18                	jmp    c01023ec <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023d4:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023d8:	7e 0d                	jle    c01023e7 <trapname+0x2a>
c01023da:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023de:	7f 07                	jg     c01023e7 <trapname+0x2a>
        return "Hardware Interrupt";
c01023e0:	b8 ca c2 10 c0       	mov    $0xc010c2ca,%eax
c01023e5:	eb 05                	jmp    c01023ec <trapname+0x2f>
    }
    return "(unknown trap)";
c01023e7:	b8 dd c2 10 c0       	mov    $0xc010c2dd,%eax
}
c01023ec:	5d                   	pop    %ebp
c01023ed:	c3                   	ret    

c01023ee <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023ee:	55                   	push   %ebp
c01023ef:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023f8:	66 83 f8 08          	cmp    $0x8,%ax
c01023fc:	0f 94 c0             	sete   %al
c01023ff:	0f b6 c0             	movzbl %al,%eax
}
c0102402:	5d                   	pop    %ebp
c0102403:	c3                   	ret    

c0102404 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0102404:	55                   	push   %ebp
c0102405:	89 e5                	mov    %esp,%ebp
c0102407:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010240a:	8b 45 08             	mov    0x8(%ebp),%eax
c010240d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102411:	c7 04 24 1e c3 10 c0 	movl   $0xc010c31e,(%esp)
c0102418:	e8 36 df ff ff       	call   c0100353 <cprintf>
    print_regs(&tf->tf_regs);
c010241d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102420:	89 04 24             	mov    %eax,(%esp)
c0102423:	e8 a1 01 00 00       	call   c01025c9 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102428:	8b 45 08             	mov    0x8(%ebp),%eax
c010242b:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010242f:	0f b7 c0             	movzwl %ax,%eax
c0102432:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102436:	c7 04 24 2f c3 10 c0 	movl   $0xc010c32f,(%esp)
c010243d:	e8 11 df ff ff       	call   c0100353 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102442:	8b 45 08             	mov    0x8(%ebp),%eax
c0102445:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102449:	0f b7 c0             	movzwl %ax,%eax
c010244c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102450:	c7 04 24 42 c3 10 c0 	movl   $0xc010c342,(%esp)
c0102457:	e8 f7 de ff ff       	call   c0100353 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010245c:	8b 45 08             	mov    0x8(%ebp),%eax
c010245f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102463:	0f b7 c0             	movzwl %ax,%eax
c0102466:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246a:	c7 04 24 55 c3 10 c0 	movl   $0xc010c355,(%esp)
c0102471:	e8 dd de ff ff       	call   c0100353 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102476:	8b 45 08             	mov    0x8(%ebp),%eax
c0102479:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010247d:	0f b7 c0             	movzwl %ax,%eax
c0102480:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102484:	c7 04 24 68 c3 10 c0 	movl   $0xc010c368,(%esp)
c010248b:	e8 c3 de ff ff       	call   c0100353 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102490:	8b 45 08             	mov    0x8(%ebp),%eax
c0102493:	8b 40 30             	mov    0x30(%eax),%eax
c0102496:	89 04 24             	mov    %eax,(%esp)
c0102499:	e8 1f ff ff ff       	call   c01023bd <trapname>
c010249e:	8b 55 08             	mov    0x8(%ebp),%edx
c01024a1:	8b 52 30             	mov    0x30(%edx),%edx
c01024a4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01024a8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01024ac:	c7 04 24 7b c3 10 c0 	movl   $0xc010c37b,(%esp)
c01024b3:	e8 9b de ff ff       	call   c0100353 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01024b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01024bb:	8b 40 34             	mov    0x34(%eax),%eax
c01024be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c2:	c7 04 24 8d c3 10 c0 	movl   $0xc010c38d,(%esp)
c01024c9:	e8 85 de ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01024ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d1:	8b 40 38             	mov    0x38(%eax),%eax
c01024d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024d8:	c7 04 24 9c c3 10 c0 	movl   $0xc010c39c,(%esp)
c01024df:	e8 6f de ff ff       	call   c0100353 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024eb:	0f b7 c0             	movzwl %ax,%eax
c01024ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f2:	c7 04 24 ab c3 10 c0 	movl   $0xc010c3ab,(%esp)
c01024f9:	e8 55 de ff ff       	call   c0100353 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102501:	8b 40 40             	mov    0x40(%eax),%eax
c0102504:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102508:	c7 04 24 be c3 10 c0 	movl   $0xc010c3be,(%esp)
c010250f:	e8 3f de ff ff       	call   c0100353 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102514:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010251b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0102522:	eb 3e                	jmp    c0102562 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102524:	8b 45 08             	mov    0x8(%ebp),%eax
c0102527:	8b 50 40             	mov    0x40(%eax),%edx
c010252a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010252d:	21 d0                	and    %edx,%eax
c010252f:	85 c0                	test   %eax,%eax
c0102531:	74 28                	je     c010255b <print_trapframe+0x157>
c0102533:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102536:	8b 04 85 a0 a5 12 c0 	mov    -0x3fed5a60(,%eax,4),%eax
c010253d:	85 c0                	test   %eax,%eax
c010253f:	74 1a                	je     c010255b <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0102541:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102544:	8b 04 85 a0 a5 12 c0 	mov    -0x3fed5a60(,%eax,4),%eax
c010254b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010254f:	c7 04 24 cd c3 10 c0 	movl   $0xc010c3cd,(%esp)
c0102556:	e8 f8 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010255b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010255f:	d1 65 f0             	shll   -0x10(%ebp)
c0102562:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102565:	83 f8 17             	cmp    $0x17,%eax
c0102568:	76 ba                	jbe    c0102524 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010256a:	8b 45 08             	mov    0x8(%ebp),%eax
c010256d:	8b 40 40             	mov    0x40(%eax),%eax
c0102570:	25 00 30 00 00       	and    $0x3000,%eax
c0102575:	c1 e8 0c             	shr    $0xc,%eax
c0102578:	89 44 24 04          	mov    %eax,0x4(%esp)
c010257c:	c7 04 24 d1 c3 10 c0 	movl   $0xc010c3d1,(%esp)
c0102583:	e8 cb dd ff ff       	call   c0100353 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102588:	8b 45 08             	mov    0x8(%ebp),%eax
c010258b:	89 04 24             	mov    %eax,(%esp)
c010258e:	e8 5b fe ff ff       	call   c01023ee <trap_in_kernel>
c0102593:	85 c0                	test   %eax,%eax
c0102595:	75 30                	jne    c01025c7 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102597:	8b 45 08             	mov    0x8(%ebp),%eax
c010259a:	8b 40 44             	mov    0x44(%eax),%eax
c010259d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a1:	c7 04 24 da c3 10 c0 	movl   $0xc010c3da,(%esp)
c01025a8:	e8 a6 dd ff ff       	call   c0100353 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01025ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b0:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01025b4:	0f b7 c0             	movzwl %ax,%eax
c01025b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025bb:	c7 04 24 e9 c3 10 c0 	movl   $0xc010c3e9,(%esp)
c01025c2:	e8 8c dd ff ff       	call   c0100353 <cprintf>
    }
}
c01025c7:	c9                   	leave  
c01025c8:	c3                   	ret    

c01025c9 <print_regs>:

void
print_regs(struct pushregs *regs) {
c01025c9:	55                   	push   %ebp
c01025ca:	89 e5                	mov    %esp,%ebp
c01025cc:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01025cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01025d2:	8b 00                	mov    (%eax),%eax
c01025d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d8:	c7 04 24 fc c3 10 c0 	movl   $0xc010c3fc,(%esp)
c01025df:	e8 6f dd ff ff       	call   c0100353 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01025e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e7:	8b 40 04             	mov    0x4(%eax),%eax
c01025ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025ee:	c7 04 24 0b c4 10 c0 	movl   $0xc010c40b,(%esp)
c01025f5:	e8 59 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fd:	8b 40 08             	mov    0x8(%eax),%eax
c0102600:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102604:	c7 04 24 1a c4 10 c0 	movl   $0xc010c41a,(%esp)
c010260b:	e8 43 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102610:	8b 45 08             	mov    0x8(%ebp),%eax
c0102613:	8b 40 0c             	mov    0xc(%eax),%eax
c0102616:	89 44 24 04          	mov    %eax,0x4(%esp)
c010261a:	c7 04 24 29 c4 10 c0 	movl   $0xc010c429,(%esp)
c0102621:	e8 2d dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102626:	8b 45 08             	mov    0x8(%ebp),%eax
c0102629:	8b 40 10             	mov    0x10(%eax),%eax
c010262c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102630:	c7 04 24 38 c4 10 c0 	movl   $0xc010c438,(%esp)
c0102637:	e8 17 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010263c:	8b 45 08             	mov    0x8(%ebp),%eax
c010263f:	8b 40 14             	mov    0x14(%eax),%eax
c0102642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102646:	c7 04 24 47 c4 10 c0 	movl   $0xc010c447,(%esp)
c010264d:	e8 01 dd ff ff       	call   c0100353 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102652:	8b 45 08             	mov    0x8(%ebp),%eax
c0102655:	8b 40 18             	mov    0x18(%eax),%eax
c0102658:	89 44 24 04          	mov    %eax,0x4(%esp)
c010265c:	c7 04 24 56 c4 10 c0 	movl   $0xc010c456,(%esp)
c0102663:	e8 eb dc ff ff       	call   c0100353 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102668:	8b 45 08             	mov    0x8(%ebp),%eax
c010266b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010266e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102672:	c7 04 24 65 c4 10 c0 	movl   $0xc010c465,(%esp)
c0102679:	e8 d5 dc ff ff       	call   c0100353 <cprintf>
}
c010267e:	c9                   	leave  
c010267f:	c3                   	ret    

c0102680 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102680:	55                   	push   %ebp
c0102681:	89 e5                	mov    %esp,%ebp
c0102683:	53                   	push   %ebx
c0102684:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102687:	8b 45 08             	mov    0x8(%ebp),%eax
c010268a:	8b 40 34             	mov    0x34(%eax),%eax
c010268d:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102690:	85 c0                	test   %eax,%eax
c0102692:	74 07                	je     c010269b <print_pgfault+0x1b>
c0102694:	b9 74 c4 10 c0       	mov    $0xc010c474,%ecx
c0102699:	eb 05                	jmp    c01026a0 <print_pgfault+0x20>
c010269b:	b9 85 c4 10 c0       	mov    $0xc010c485,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c01026a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01026a3:	8b 40 34             	mov    0x34(%eax),%eax
c01026a6:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026a9:	85 c0                	test   %eax,%eax
c01026ab:	74 07                	je     c01026b4 <print_pgfault+0x34>
c01026ad:	ba 57 00 00 00       	mov    $0x57,%edx
c01026b2:	eb 05                	jmp    c01026b9 <print_pgfault+0x39>
c01026b4:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01026b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01026bc:	8b 40 34             	mov    0x34(%eax),%eax
c01026bf:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01026c2:	85 c0                	test   %eax,%eax
c01026c4:	74 07                	je     c01026cd <print_pgfault+0x4d>
c01026c6:	b8 55 00 00 00       	mov    $0x55,%eax
c01026cb:	eb 05                	jmp    c01026d2 <print_pgfault+0x52>
c01026cd:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01026d2:	0f 20 d3             	mov    %cr2,%ebx
c01026d5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01026d8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01026db:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01026df:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01026e3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01026e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01026eb:	c7 04 24 94 c4 10 c0 	movl   $0xc010c494,(%esp)
c01026f2:	e8 5c dc ff ff       	call   c0100353 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01026f7:	83 c4 34             	add    $0x34,%esp
c01026fa:	5b                   	pop    %ebx
c01026fb:	5d                   	pop    %ebp
c01026fc:	c3                   	ret    

c01026fd <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026fd:	55                   	push   %ebp
c01026fe:	89 e5                	mov    %esp,%ebp
c0102700:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c0102703:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0102708:	85 c0                	test   %eax,%eax
c010270a:	74 0b                	je     c0102717 <pgfault_handler+0x1a>
            print_pgfault(tf);
c010270c:	8b 45 08             	mov    0x8(%ebp),%eax
c010270f:	89 04 24             	mov    %eax,(%esp)
c0102712:	e8 69 ff ff ff       	call   c0102680 <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c0102717:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c010271c:	85 c0                	test   %eax,%eax
c010271e:	74 3d                	je     c010275d <pgfault_handler+0x60>
        assert(current == idleproc);
c0102720:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0102726:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010272b:	39 c2                	cmp    %eax,%edx
c010272d:	74 24                	je     c0102753 <pgfault_handler+0x56>
c010272f:	c7 44 24 0c b7 c4 10 	movl   $0xc010c4b7,0xc(%esp)
c0102736:	c0 
c0102737:	c7 44 24 08 cb c4 10 	movl   $0xc010c4cb,0x8(%esp)
c010273e:	c0 
c010273f:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0102746:	00 
c0102747:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c010274e:	e8 c2 e6 ff ff       	call   c0100e15 <__panic>
        mm = check_mm_struct;
c0102753:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0102758:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010275b:	eb 46                	jmp    c01027a3 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010275d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102762:	85 c0                	test   %eax,%eax
c0102764:	75 32                	jne    c0102798 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102766:	8b 45 08             	mov    0x8(%ebp),%eax
c0102769:	89 04 24             	mov    %eax,(%esp)
c010276c:	e8 93 fc ff ff       	call   c0102404 <print_trapframe>
            print_pgfault(tf);
c0102771:	8b 45 08             	mov    0x8(%ebp),%eax
c0102774:	89 04 24             	mov    %eax,(%esp)
c0102777:	e8 04 ff ff ff       	call   c0102680 <print_pgfault>
            panic("unhandled page fault.\n");
c010277c:	c7 44 24 08 f1 c4 10 	movl   $0xc010c4f1,0x8(%esp)
c0102783:	c0 
c0102784:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c010278b:	00 
c010278c:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c0102793:	e8 7d e6 ff ff       	call   c0100e15 <__panic>
        }
        mm = current->mm;
c0102798:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010279d:	8b 40 18             	mov    0x18(%eax),%eax
c01027a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01027a3:	0f 20 d0             	mov    %cr2,%eax
c01027a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c01027a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c01027ac:	89 c2                	mov    %eax,%edx
c01027ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01027b1:	8b 40 34             	mov    0x34(%eax),%eax
c01027b4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01027b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01027bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027bf:	89 04 24             	mov    %eax,(%esp)
c01027c2:	e8 38 66 00 00       	call   c0108dff <do_pgfault>
}
c01027c7:	c9                   	leave  
c01027c8:	c3                   	ret    

c01027c9 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01027c9:	55                   	push   %ebp
c01027ca:	89 e5                	mov    %esp,%ebp
c01027cc:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c01027cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c01027d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01027d9:	8b 40 30             	mov    0x30(%eax),%eax
c01027dc:	83 f8 2f             	cmp    $0x2f,%eax
c01027df:	77 38                	ja     c0102819 <trap_dispatch+0x50>
c01027e1:	83 f8 2e             	cmp    $0x2e,%eax
c01027e4:	0f 83 05 02 00 00    	jae    c01029ef <trap_dispatch+0x226>
c01027ea:	83 f8 20             	cmp    $0x20,%eax
c01027ed:	0f 84 07 01 00 00    	je     c01028fa <trap_dispatch+0x131>
c01027f3:	83 f8 20             	cmp    $0x20,%eax
c01027f6:	77 0a                	ja     c0102802 <trap_dispatch+0x39>
c01027f8:	83 f8 0e             	cmp    $0xe,%eax
c01027fb:	74 3e                	je     c010283b <trap_dispatch+0x72>
c01027fd:	e9 a5 01 00 00       	jmp    c01029a7 <trap_dispatch+0x1de>
c0102802:	83 f8 21             	cmp    $0x21,%eax
c0102805:	0f 84 5a 01 00 00    	je     c0102965 <trap_dispatch+0x19c>
c010280b:	83 f8 24             	cmp    $0x24,%eax
c010280e:	0f 84 28 01 00 00    	je     c010293c <trap_dispatch+0x173>
c0102814:	e9 8e 01 00 00       	jmp    c01029a7 <trap_dispatch+0x1de>
c0102819:	83 f8 78             	cmp    $0x78,%eax
c010281c:	0f 82 85 01 00 00    	jb     c01029a7 <trap_dispatch+0x1de>
c0102822:	83 f8 79             	cmp    $0x79,%eax
c0102825:	0f 86 60 01 00 00    	jbe    c010298b <trap_dispatch+0x1c2>
c010282b:	3d 80 00 00 00       	cmp    $0x80,%eax
c0102830:	0f 84 ba 00 00 00    	je     c01028f0 <trap_dispatch+0x127>
c0102836:	e9 6c 01 00 00       	jmp    c01029a7 <trap_dispatch+0x1de>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010283b:	8b 45 08             	mov    0x8(%ebp),%eax
c010283e:	89 04 24             	mov    %eax,(%esp)
c0102841:	e8 b7 fe ff ff       	call   c01026fd <pgfault_handler>
c0102846:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102849:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010284d:	0f 84 98 00 00 00    	je     c01028eb <trap_dispatch+0x122>
            print_trapframe(tf);
c0102853:	8b 45 08             	mov    0x8(%ebp),%eax
c0102856:	89 04 24             	mov    %eax,(%esp)
c0102859:	e8 a6 fb ff ff       	call   c0102404 <print_trapframe>
            if (current == NULL) {
c010285e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102863:	85 c0                	test   %eax,%eax
c0102865:	75 23                	jne    c010288a <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010286a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010286e:	c7 44 24 08 08 c5 10 	movl   $0xc010c508,0x8(%esp)
c0102875:	c0 
c0102876:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c010287d:	00 
c010287e:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c0102885:	e8 8b e5 ff ff       	call   c0100e15 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c010288a:	8b 45 08             	mov    0x8(%ebp),%eax
c010288d:	89 04 24             	mov    %eax,(%esp)
c0102890:	e8 59 fb ff ff       	call   c01023ee <trap_in_kernel>
c0102895:	85 c0                	test   %eax,%eax
c0102897:	74 23                	je     c01028bc <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102899:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010289c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028a0:	c7 44 24 08 28 c5 10 	movl   $0xc010c528,0x8(%esp)
c01028a7:	c0 
c01028a8:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01028af:	00 
c01028b0:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c01028b7:	e8 59 e5 ff ff       	call   c0100e15 <__panic>
                }
                cprintf("killed by kernel.\n");
c01028bc:	c7 04 24 56 c5 10 c0 	movl   $0xc010c556,(%esp)
c01028c3:	e8 8b da ff ff       	call   c0100353 <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret);
c01028c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028cf:	c7 44 24 08 6c c5 10 	movl   $0xc010c56c,0x8(%esp)
c01028d6:	c0 
c01028d7:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01028de:	00 
c01028df:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c01028e6:	e8 2a e5 ff ff       	call   c0100e15 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
c01028eb:	e9 00 01 00 00       	jmp    c01029f0 <trap_dispatch+0x227>
    case T_SYSCALL:
        syscall();
c01028f0:	e8 84 88 00 00       	call   c010b179 <syscall>
        break;
c01028f5:	e9 f6 00 00 00       	jmp    c01029f0 <trap_dispatch+0x227>
        */
        /* LAB5 2013011317 */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ++ticks;
c01028fa:	a1 b4 ef 19 c0       	mov    0xc019efb4,%eax
c01028ff:	83 c0 01             	add    $0x1,%eax
c0102902:	a3 b4 ef 19 c0       	mov    %eax,0xc019efb4
        if (ticks % TICK_NUM == 0) {
c0102907:	8b 0d b4 ef 19 c0    	mov    0xc019efb4,%ecx
c010290d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102912:	89 c8                	mov    %ecx,%eax
c0102914:	f7 e2                	mul    %edx
c0102916:	89 d0                	mov    %edx,%eax
c0102918:	c1 e8 05             	shr    $0x5,%eax
c010291b:	6b c0 64             	imul   $0x64,%eax,%eax
c010291e:	29 c1                	sub    %eax,%ecx
c0102920:	89 c8                	mov    %ecx,%eax
c0102922:	85 c0                	test   %eax,%eax
c0102924:	75 11                	jne    c0102937 <trap_dispatch+0x16e>
            current->need_resched = 1;
c0102926:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010292b:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
        }
        break;
c0102932:	e9 b9 00 00 00       	jmp    c01029f0 <trap_dispatch+0x227>
c0102937:	e9 b4 00 00 00       	jmp    c01029f0 <trap_dispatch+0x227>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c010293c:	e8 42 ee ff ff       	call   c0101783 <cons_getc>
c0102941:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102944:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102948:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010294c:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102950:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102954:	c7 04 24 95 c5 10 c0 	movl   $0xc010c595,(%esp)
c010295b:	e8 f3 d9 ff ff       	call   c0100353 <cprintf>
        break;
c0102960:	e9 8b 00 00 00       	jmp    c01029f0 <trap_dispatch+0x227>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102965:	e8 19 ee ff ff       	call   c0101783 <cons_getc>
c010296a:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010296d:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102971:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102975:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102979:	89 44 24 04          	mov    %eax,0x4(%esp)
c010297d:	c7 04 24 a7 c5 10 c0 	movl   $0xc010c5a7,(%esp)
c0102984:	e8 ca d9 ff ff       	call   c0100353 <cprintf>
        break;
c0102989:	eb 65                	jmp    c01029f0 <trap_dispatch+0x227>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c010298b:	c7 44 24 08 b6 c5 10 	movl   $0xc010c5b6,0x8(%esp)
c0102992:	c0 
c0102993:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010299a:	00 
c010299b:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c01029a2:	e8 6e e4 ff ff       	call   c0100e15 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c01029a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01029aa:	89 04 24             	mov    %eax,(%esp)
c01029ad:	e8 52 fa ff ff       	call   c0102404 <print_trapframe>
        if (current != NULL) {
c01029b2:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01029b7:	85 c0                	test   %eax,%eax
c01029b9:	74 18                	je     c01029d3 <trap_dispatch+0x20a>
            cprintf("unhandled trap.\n");
c01029bb:	c7 04 24 c6 c5 10 c0 	movl   $0xc010c5c6,(%esp)
c01029c2:	e8 8c d9 ff ff       	call   c0100353 <cprintf>
            do_exit(-E_KILLED);
c01029c7:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c01029ce:	e8 3d 75 00 00       	call   c0109f10 <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c01029d3:	c7 44 24 08 d7 c5 10 	movl   $0xc010c5d7,0x8(%esp)
c01029da:	c0 
c01029db:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c01029e2:	00 
c01029e3:	c7 04 24 e0 c4 10 c0 	movl   $0xc010c4e0,(%esp)
c01029ea:	e8 26 e4 ff ff       	call   c0100e15 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01029ef:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c01029f0:	c9                   	leave  
c01029f1:	c3                   	ret    

c01029f2 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029f2:	55                   	push   %ebp
c01029f3:	89 e5                	mov    %esp,%ebp
c01029f5:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c01029f8:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01029fd:	85 c0                	test   %eax,%eax
c01029ff:	75 0d                	jne    c0102a0e <trap+0x1c>
        trap_dispatch(tf);
c0102a01:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a04:	89 04 24             	mov    %eax,(%esp)
c0102a07:	e8 bd fd ff ff       	call   c01027c9 <trap_dispatch>
c0102a0c:	eb 6c                	jmp    c0102a7a <trap+0x88>
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c0102a0e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a13:	8b 40 3c             	mov    0x3c(%eax),%eax
c0102a16:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c0102a19:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a1e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a21:	89 50 3c             	mov    %edx,0x3c(%eax)

        bool in_kernel = trap_in_kernel(tf);
c0102a24:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a27:	89 04 24             	mov    %eax,(%esp)
c0102a2a:	e8 bf f9 ff ff       	call   c01023ee <trap_in_kernel>
c0102a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)

        trap_dispatch(tf);
c0102a32:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a35:	89 04 24             	mov    %eax,(%esp)
c0102a38:	e8 8c fd ff ff       	call   c01027c9 <trap_dispatch>

        current->tf = otf;
c0102a3d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a45:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a4c:	75 2c                	jne    c0102a7a <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a4e:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a53:	8b 40 44             	mov    0x44(%eax),%eax
c0102a56:	83 e0 01             	and    $0x1,%eax
c0102a59:	85 c0                	test   %eax,%eax
c0102a5b:	74 0c                	je     c0102a69 <trap+0x77>
                do_exit(-E_KILLED);
c0102a5d:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a64:	e8 a7 74 00 00       	call   c0109f10 <do_exit>
            }
            if (current->need_resched) {
c0102a69:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0102a6e:	8b 40 10             	mov    0x10(%eax),%eax
c0102a71:	85 c0                	test   %eax,%eax
c0102a73:	74 05                	je     c0102a7a <trap+0x88>
                schedule();
c0102a75:	e8 07 85 00 00       	call   c010af81 <schedule>
            }
        }
    }
}
c0102a7a:	c9                   	leave  
c0102a7b:	c3                   	ret    

c0102a7c <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a7c:	1e                   	push   %ds
    pushl %es
c0102a7d:	06                   	push   %es
    pushl %fs
c0102a7e:	0f a0                	push   %fs
    pushl %gs
c0102a80:	0f a8                	push   %gs
    pushal
c0102a82:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a83:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a88:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a8a:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a8c:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a8d:	e8 60 ff ff ff       	call   c01029f2 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a92:	5c                   	pop    %esp

c0102a93 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a93:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a94:	0f a9                	pop    %gs
    popl %fs
c0102a96:	0f a1                	pop    %fs
    popl %es
c0102a98:	07                   	pop    %es
    popl %ds
c0102a99:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a9a:	83 c4 08             	add    $0x8,%esp
    iret
c0102a9d:	cf                   	iret   

c0102a9e <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0102a9e:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0102aa2:	e9 ec ff ff ff       	jmp    c0102a93 <__trapret>

c0102aa7 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102aa7:	6a 00                	push   $0x0
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  jmp __alltraps
c0102aab:	e9 cc ff ff ff       	jmp    c0102a7c <__alltraps>

c0102ab0 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102ab0:	6a 00                	push   $0x0
  pushl $1
c0102ab2:	6a 01                	push   $0x1
  jmp __alltraps
c0102ab4:	e9 c3 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102ab9 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102ab9:	6a 00                	push   $0x0
  pushl $2
c0102abb:	6a 02                	push   $0x2
  jmp __alltraps
c0102abd:	e9 ba ff ff ff       	jmp    c0102a7c <__alltraps>

c0102ac2 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102ac2:	6a 00                	push   $0x0
  pushl $3
c0102ac4:	6a 03                	push   $0x3
  jmp __alltraps
c0102ac6:	e9 b1 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102acb <vector4>:
.globl vector4
vector4:
  pushl $0
c0102acb:	6a 00                	push   $0x0
  pushl $4
c0102acd:	6a 04                	push   $0x4
  jmp __alltraps
c0102acf:	e9 a8 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102ad4 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102ad4:	6a 00                	push   $0x0
  pushl $5
c0102ad6:	6a 05                	push   $0x5
  jmp __alltraps
c0102ad8:	e9 9f ff ff ff       	jmp    c0102a7c <__alltraps>

c0102add <vector6>:
.globl vector6
vector6:
  pushl $0
c0102add:	6a 00                	push   $0x0
  pushl $6
c0102adf:	6a 06                	push   $0x6
  jmp __alltraps
c0102ae1:	e9 96 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102ae6 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102ae6:	6a 00                	push   $0x0
  pushl $7
c0102ae8:	6a 07                	push   $0x7
  jmp __alltraps
c0102aea:	e9 8d ff ff ff       	jmp    c0102a7c <__alltraps>

c0102aef <vector8>:
.globl vector8
vector8:
  pushl $8
c0102aef:	6a 08                	push   $0x8
  jmp __alltraps
c0102af1:	e9 86 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102af6 <vector9>:
.globl vector9
vector9:
  pushl $9
c0102af6:	6a 09                	push   $0x9
  jmp __alltraps
c0102af8:	e9 7f ff ff ff       	jmp    c0102a7c <__alltraps>

c0102afd <vector10>:
.globl vector10
vector10:
  pushl $10
c0102afd:	6a 0a                	push   $0xa
  jmp __alltraps
c0102aff:	e9 78 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b04 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102b04:	6a 0b                	push   $0xb
  jmp __alltraps
c0102b06:	e9 71 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b0b <vector12>:
.globl vector12
vector12:
  pushl $12
c0102b0b:	6a 0c                	push   $0xc
  jmp __alltraps
c0102b0d:	e9 6a ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b12 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102b12:	6a 0d                	push   $0xd
  jmp __alltraps
c0102b14:	e9 63 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b19 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102b19:	6a 0e                	push   $0xe
  jmp __alltraps
c0102b1b:	e9 5c ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b20 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102b20:	6a 00                	push   $0x0
  pushl $15
c0102b22:	6a 0f                	push   $0xf
  jmp __alltraps
c0102b24:	e9 53 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b29 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102b29:	6a 00                	push   $0x0
  pushl $16
c0102b2b:	6a 10                	push   $0x10
  jmp __alltraps
c0102b2d:	e9 4a ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b32 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102b32:	6a 11                	push   $0x11
  jmp __alltraps
c0102b34:	e9 43 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b39 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $18
c0102b3b:	6a 12                	push   $0x12
  jmp __alltraps
c0102b3d:	e9 3a ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b42 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $19
c0102b44:	6a 13                	push   $0x13
  jmp __alltraps
c0102b46:	e9 31 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b4b <vector20>:
.globl vector20
vector20:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $20
c0102b4d:	6a 14                	push   $0x14
  jmp __alltraps
c0102b4f:	e9 28 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b54 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $21
c0102b56:	6a 15                	push   $0x15
  jmp __alltraps
c0102b58:	e9 1f ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b5d <vector22>:
.globl vector22
vector22:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $22
c0102b5f:	6a 16                	push   $0x16
  jmp __alltraps
c0102b61:	e9 16 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b66 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $23
c0102b68:	6a 17                	push   $0x17
  jmp __alltraps
c0102b6a:	e9 0d ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b6f <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $24
c0102b71:	6a 18                	push   $0x18
  jmp __alltraps
c0102b73:	e9 04 ff ff ff       	jmp    c0102a7c <__alltraps>

c0102b78 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $25
c0102b7a:	6a 19                	push   $0x19
  jmp __alltraps
c0102b7c:	e9 fb fe ff ff       	jmp    c0102a7c <__alltraps>

c0102b81 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $26
c0102b83:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b85:	e9 f2 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102b8a <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $27
c0102b8c:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b8e:	e9 e9 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102b93 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $28
c0102b95:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b97:	e9 e0 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102b9c <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $29
c0102b9e:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102ba0:	e9 d7 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102ba5 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $30
c0102ba7:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102ba9:	e9 ce fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bae <vector31>:
.globl vector31
vector31:
  pushl $0
c0102bae:	6a 00                	push   $0x0
  pushl $31
c0102bb0:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102bb2:	e9 c5 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bb7 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102bb7:	6a 00                	push   $0x0
  pushl $32
c0102bb9:	6a 20                	push   $0x20
  jmp __alltraps
c0102bbb:	e9 bc fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bc0 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102bc0:	6a 00                	push   $0x0
  pushl $33
c0102bc2:	6a 21                	push   $0x21
  jmp __alltraps
c0102bc4:	e9 b3 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bc9 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $34
c0102bcb:	6a 22                	push   $0x22
  jmp __alltraps
c0102bcd:	e9 aa fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bd2 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102bd2:	6a 00                	push   $0x0
  pushl $35
c0102bd4:	6a 23                	push   $0x23
  jmp __alltraps
c0102bd6:	e9 a1 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bdb <vector36>:
.globl vector36
vector36:
  pushl $0
c0102bdb:	6a 00                	push   $0x0
  pushl $36
c0102bdd:	6a 24                	push   $0x24
  jmp __alltraps
c0102bdf:	e9 98 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102be4 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102be4:	6a 00                	push   $0x0
  pushl $37
c0102be6:	6a 25                	push   $0x25
  jmp __alltraps
c0102be8:	e9 8f fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bed <vector38>:
.globl vector38
vector38:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $38
c0102bef:	6a 26                	push   $0x26
  jmp __alltraps
c0102bf1:	e9 86 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bf6 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102bf6:	6a 00                	push   $0x0
  pushl $39
c0102bf8:	6a 27                	push   $0x27
  jmp __alltraps
c0102bfa:	e9 7d fe ff ff       	jmp    c0102a7c <__alltraps>

c0102bff <vector40>:
.globl vector40
vector40:
  pushl $0
c0102bff:	6a 00                	push   $0x0
  pushl $40
c0102c01:	6a 28                	push   $0x28
  jmp __alltraps
c0102c03:	e9 74 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c08 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102c08:	6a 00                	push   $0x0
  pushl $41
c0102c0a:	6a 29                	push   $0x29
  jmp __alltraps
c0102c0c:	e9 6b fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c11 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $42
c0102c13:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102c15:	e9 62 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c1a <vector43>:
.globl vector43
vector43:
  pushl $0
c0102c1a:	6a 00                	push   $0x0
  pushl $43
c0102c1c:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102c1e:	e9 59 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c23 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102c23:	6a 00                	push   $0x0
  pushl $44
c0102c25:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102c27:	e9 50 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c2c <vector45>:
.globl vector45
vector45:
  pushl $0
c0102c2c:	6a 00                	push   $0x0
  pushl $45
c0102c2e:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102c30:	e9 47 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c35 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $46
c0102c37:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102c39:	e9 3e fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c3e <vector47>:
.globl vector47
vector47:
  pushl $0
c0102c3e:	6a 00                	push   $0x0
  pushl $47
c0102c40:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102c42:	e9 35 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c47 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102c47:	6a 00                	push   $0x0
  pushl $48
c0102c49:	6a 30                	push   $0x30
  jmp __alltraps
c0102c4b:	e9 2c fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c50 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102c50:	6a 00                	push   $0x0
  pushl $49
c0102c52:	6a 31                	push   $0x31
  jmp __alltraps
c0102c54:	e9 23 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c59 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $50
c0102c5b:	6a 32                	push   $0x32
  jmp __alltraps
c0102c5d:	e9 1a fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c62 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102c62:	6a 00                	push   $0x0
  pushl $51
c0102c64:	6a 33                	push   $0x33
  jmp __alltraps
c0102c66:	e9 11 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c6b <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c6b:	6a 00                	push   $0x0
  pushl $52
c0102c6d:	6a 34                	push   $0x34
  jmp __alltraps
c0102c6f:	e9 08 fe ff ff       	jmp    c0102a7c <__alltraps>

c0102c74 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c74:	6a 00                	push   $0x0
  pushl $53
c0102c76:	6a 35                	push   $0x35
  jmp __alltraps
c0102c78:	e9 ff fd ff ff       	jmp    c0102a7c <__alltraps>

c0102c7d <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $54
c0102c7f:	6a 36                	push   $0x36
  jmp __alltraps
c0102c81:	e9 f6 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102c86 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c86:	6a 00                	push   $0x0
  pushl $55
c0102c88:	6a 37                	push   $0x37
  jmp __alltraps
c0102c8a:	e9 ed fd ff ff       	jmp    c0102a7c <__alltraps>

c0102c8f <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c8f:	6a 00                	push   $0x0
  pushl $56
c0102c91:	6a 38                	push   $0x38
  jmp __alltraps
c0102c93:	e9 e4 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102c98 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c98:	6a 00                	push   $0x0
  pushl $57
c0102c9a:	6a 39                	push   $0x39
  jmp __alltraps
c0102c9c:	e9 db fd ff ff       	jmp    c0102a7c <__alltraps>

c0102ca1 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $58
c0102ca3:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102ca5:	e9 d2 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102caa <vector59>:
.globl vector59
vector59:
  pushl $0
c0102caa:	6a 00                	push   $0x0
  pushl $59
c0102cac:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102cae:	e9 c9 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cb3 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102cb3:	6a 00                	push   $0x0
  pushl $60
c0102cb5:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102cb7:	e9 c0 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cbc <vector61>:
.globl vector61
vector61:
  pushl $0
c0102cbc:	6a 00                	push   $0x0
  pushl $61
c0102cbe:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102cc0:	e9 b7 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cc5 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $62
c0102cc7:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102cc9:	e9 ae fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cce <vector63>:
.globl vector63
vector63:
  pushl $0
c0102cce:	6a 00                	push   $0x0
  pushl $63
c0102cd0:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102cd2:	e9 a5 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cd7 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102cd7:	6a 00                	push   $0x0
  pushl $64
c0102cd9:	6a 40                	push   $0x40
  jmp __alltraps
c0102cdb:	e9 9c fd ff ff       	jmp    c0102a7c <__alltraps>

c0102ce0 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102ce0:	6a 00                	push   $0x0
  pushl $65
c0102ce2:	6a 41                	push   $0x41
  jmp __alltraps
c0102ce4:	e9 93 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102ce9 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $66
c0102ceb:	6a 42                	push   $0x42
  jmp __alltraps
c0102ced:	e9 8a fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cf2 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102cf2:	6a 00                	push   $0x0
  pushl $67
c0102cf4:	6a 43                	push   $0x43
  jmp __alltraps
c0102cf6:	e9 81 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102cfb <vector68>:
.globl vector68
vector68:
  pushl $0
c0102cfb:	6a 00                	push   $0x0
  pushl $68
c0102cfd:	6a 44                	push   $0x44
  jmp __alltraps
c0102cff:	e9 78 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d04 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102d04:	6a 00                	push   $0x0
  pushl $69
c0102d06:	6a 45                	push   $0x45
  jmp __alltraps
c0102d08:	e9 6f fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d0d <vector70>:
.globl vector70
vector70:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $70
c0102d0f:	6a 46                	push   $0x46
  jmp __alltraps
c0102d11:	e9 66 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d16 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102d16:	6a 00                	push   $0x0
  pushl $71
c0102d18:	6a 47                	push   $0x47
  jmp __alltraps
c0102d1a:	e9 5d fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d1f <vector72>:
.globl vector72
vector72:
  pushl $0
c0102d1f:	6a 00                	push   $0x0
  pushl $72
c0102d21:	6a 48                	push   $0x48
  jmp __alltraps
c0102d23:	e9 54 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d28 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102d28:	6a 00                	push   $0x0
  pushl $73
c0102d2a:	6a 49                	push   $0x49
  jmp __alltraps
c0102d2c:	e9 4b fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d31 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $74
c0102d33:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102d35:	e9 42 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d3a <vector75>:
.globl vector75
vector75:
  pushl $0
c0102d3a:	6a 00                	push   $0x0
  pushl $75
c0102d3c:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102d3e:	e9 39 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d43 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102d43:	6a 00                	push   $0x0
  pushl $76
c0102d45:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102d47:	e9 30 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d4c <vector77>:
.globl vector77
vector77:
  pushl $0
c0102d4c:	6a 00                	push   $0x0
  pushl $77
c0102d4e:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102d50:	e9 27 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d55 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $78
c0102d57:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102d59:	e9 1e fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d5e <vector79>:
.globl vector79
vector79:
  pushl $0
c0102d5e:	6a 00                	push   $0x0
  pushl $79
c0102d60:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102d62:	e9 15 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d67 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d67:	6a 00                	push   $0x0
  pushl $80
c0102d69:	6a 50                	push   $0x50
  jmp __alltraps
c0102d6b:	e9 0c fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d70 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d70:	6a 00                	push   $0x0
  pushl $81
c0102d72:	6a 51                	push   $0x51
  jmp __alltraps
c0102d74:	e9 03 fd ff ff       	jmp    c0102a7c <__alltraps>

c0102d79 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $82
c0102d7b:	6a 52                	push   $0x52
  jmp __alltraps
c0102d7d:	e9 fa fc ff ff       	jmp    c0102a7c <__alltraps>

c0102d82 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d82:	6a 00                	push   $0x0
  pushl $83
c0102d84:	6a 53                	push   $0x53
  jmp __alltraps
c0102d86:	e9 f1 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102d8b <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d8b:	6a 00                	push   $0x0
  pushl $84
c0102d8d:	6a 54                	push   $0x54
  jmp __alltraps
c0102d8f:	e9 e8 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102d94 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d94:	6a 00                	push   $0x0
  pushl $85
c0102d96:	6a 55                	push   $0x55
  jmp __alltraps
c0102d98:	e9 df fc ff ff       	jmp    c0102a7c <__alltraps>

c0102d9d <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $86
c0102d9f:	6a 56                	push   $0x56
  jmp __alltraps
c0102da1:	e9 d6 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102da6 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102da6:	6a 00                	push   $0x0
  pushl $87
c0102da8:	6a 57                	push   $0x57
  jmp __alltraps
c0102daa:	e9 cd fc ff ff       	jmp    c0102a7c <__alltraps>

c0102daf <vector88>:
.globl vector88
vector88:
  pushl $0
c0102daf:	6a 00                	push   $0x0
  pushl $88
c0102db1:	6a 58                	push   $0x58
  jmp __alltraps
c0102db3:	e9 c4 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102db8 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102db8:	6a 00                	push   $0x0
  pushl $89
c0102dba:	6a 59                	push   $0x59
  jmp __alltraps
c0102dbc:	e9 bb fc ff ff       	jmp    c0102a7c <__alltraps>

c0102dc1 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $90
c0102dc3:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102dc5:	e9 b2 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102dca <vector91>:
.globl vector91
vector91:
  pushl $0
c0102dca:	6a 00                	push   $0x0
  pushl $91
c0102dcc:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102dce:	e9 a9 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102dd3 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102dd3:	6a 00                	push   $0x0
  pushl $92
c0102dd5:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102dd7:	e9 a0 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102ddc <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ddc:	6a 00                	push   $0x0
  pushl $93
c0102dde:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102de0:	e9 97 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102de5 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $94
c0102de7:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102de9:	e9 8e fc ff ff       	jmp    c0102a7c <__alltraps>

c0102dee <vector95>:
.globl vector95
vector95:
  pushl $0
c0102dee:	6a 00                	push   $0x0
  pushl $95
c0102df0:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102df2:	e9 85 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102df7 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102df7:	6a 00                	push   $0x0
  pushl $96
c0102df9:	6a 60                	push   $0x60
  jmp __alltraps
c0102dfb:	e9 7c fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e00 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102e00:	6a 00                	push   $0x0
  pushl $97
c0102e02:	6a 61                	push   $0x61
  jmp __alltraps
c0102e04:	e9 73 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e09 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $98
c0102e0b:	6a 62                	push   $0x62
  jmp __alltraps
c0102e0d:	e9 6a fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e12 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102e12:	6a 00                	push   $0x0
  pushl $99
c0102e14:	6a 63                	push   $0x63
  jmp __alltraps
c0102e16:	e9 61 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e1b <vector100>:
.globl vector100
vector100:
  pushl $0
c0102e1b:	6a 00                	push   $0x0
  pushl $100
c0102e1d:	6a 64                	push   $0x64
  jmp __alltraps
c0102e1f:	e9 58 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e24 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102e24:	6a 00                	push   $0x0
  pushl $101
c0102e26:	6a 65                	push   $0x65
  jmp __alltraps
c0102e28:	e9 4f fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e2d <vector102>:
.globl vector102
vector102:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $102
c0102e2f:	6a 66                	push   $0x66
  jmp __alltraps
c0102e31:	e9 46 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e36 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102e36:	6a 00                	push   $0x0
  pushl $103
c0102e38:	6a 67                	push   $0x67
  jmp __alltraps
c0102e3a:	e9 3d fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e3f <vector104>:
.globl vector104
vector104:
  pushl $0
c0102e3f:	6a 00                	push   $0x0
  pushl $104
c0102e41:	6a 68                	push   $0x68
  jmp __alltraps
c0102e43:	e9 34 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e48 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102e48:	6a 00                	push   $0x0
  pushl $105
c0102e4a:	6a 69                	push   $0x69
  jmp __alltraps
c0102e4c:	e9 2b fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e51 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $106
c0102e53:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102e55:	e9 22 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e5a <vector107>:
.globl vector107
vector107:
  pushl $0
c0102e5a:	6a 00                	push   $0x0
  pushl $107
c0102e5c:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102e5e:	e9 19 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e63 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102e63:	6a 00                	push   $0x0
  pushl $108
c0102e65:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e67:	e9 10 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e6c <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e6c:	6a 00                	push   $0x0
  pushl $109
c0102e6e:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e70:	e9 07 fc ff ff       	jmp    c0102a7c <__alltraps>

c0102e75 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $110
c0102e77:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e79:	e9 fe fb ff ff       	jmp    c0102a7c <__alltraps>

c0102e7e <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e7e:	6a 00                	push   $0x0
  pushl $111
c0102e80:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e82:	e9 f5 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102e87 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e87:	6a 00                	push   $0x0
  pushl $112
c0102e89:	6a 70                	push   $0x70
  jmp __alltraps
c0102e8b:	e9 ec fb ff ff       	jmp    c0102a7c <__alltraps>

c0102e90 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e90:	6a 00                	push   $0x0
  pushl $113
c0102e92:	6a 71                	push   $0x71
  jmp __alltraps
c0102e94:	e9 e3 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102e99 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $114
c0102e9b:	6a 72                	push   $0x72
  jmp __alltraps
c0102e9d:	e9 da fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ea2 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102ea2:	6a 00                	push   $0x0
  pushl $115
c0102ea4:	6a 73                	push   $0x73
  jmp __alltraps
c0102ea6:	e9 d1 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102eab <vector116>:
.globl vector116
vector116:
  pushl $0
c0102eab:	6a 00                	push   $0x0
  pushl $116
c0102ead:	6a 74                	push   $0x74
  jmp __alltraps
c0102eaf:	e9 c8 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102eb4 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102eb4:	6a 00                	push   $0x0
  pushl $117
c0102eb6:	6a 75                	push   $0x75
  jmp __alltraps
c0102eb8:	e9 bf fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ebd <vector118>:
.globl vector118
vector118:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $118
c0102ebf:	6a 76                	push   $0x76
  jmp __alltraps
c0102ec1:	e9 b6 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ec6 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102ec6:	6a 00                	push   $0x0
  pushl $119
c0102ec8:	6a 77                	push   $0x77
  jmp __alltraps
c0102eca:	e9 ad fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ecf <vector120>:
.globl vector120
vector120:
  pushl $0
c0102ecf:	6a 00                	push   $0x0
  pushl $120
c0102ed1:	6a 78                	push   $0x78
  jmp __alltraps
c0102ed3:	e9 a4 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ed8 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102ed8:	6a 00                	push   $0x0
  pushl $121
c0102eda:	6a 79                	push   $0x79
  jmp __alltraps
c0102edc:	e9 9b fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ee1 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $122
c0102ee3:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102ee5:	e9 92 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102eea <vector123>:
.globl vector123
vector123:
  pushl $0
c0102eea:	6a 00                	push   $0x0
  pushl $123
c0102eec:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102eee:	e9 89 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102ef3 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102ef3:	6a 00                	push   $0x0
  pushl $124
c0102ef5:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102ef7:	e9 80 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102efc <vector125>:
.globl vector125
vector125:
  pushl $0
c0102efc:	6a 00                	push   $0x0
  pushl $125
c0102efe:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102f00:	e9 77 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f05 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $126
c0102f07:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102f09:	e9 6e fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f0e <vector127>:
.globl vector127
vector127:
  pushl $0
c0102f0e:	6a 00                	push   $0x0
  pushl $127
c0102f10:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102f12:	e9 65 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f17 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102f17:	6a 00                	push   $0x0
  pushl $128
c0102f19:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102f1e:	e9 59 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f23 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102f23:	6a 00                	push   $0x0
  pushl $129
c0102f25:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102f2a:	e9 4d fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f2f <vector130>:
.globl vector130
vector130:
  pushl $0
c0102f2f:	6a 00                	push   $0x0
  pushl $130
c0102f31:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102f36:	e9 41 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f3b <vector131>:
.globl vector131
vector131:
  pushl $0
c0102f3b:	6a 00                	push   $0x0
  pushl $131
c0102f3d:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102f42:	e9 35 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f47 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102f47:	6a 00                	push   $0x0
  pushl $132
c0102f49:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102f4e:	e9 29 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f53 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102f53:	6a 00                	push   $0x0
  pushl $133
c0102f55:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102f5a:	e9 1d fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f5f <vector134>:
.globl vector134
vector134:
  pushl $0
c0102f5f:	6a 00                	push   $0x0
  pushl $134
c0102f61:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f66:	e9 11 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f6b <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f6b:	6a 00                	push   $0x0
  pushl $135
c0102f6d:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f72:	e9 05 fb ff ff       	jmp    c0102a7c <__alltraps>

c0102f77 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f77:	6a 00                	push   $0x0
  pushl $136
c0102f79:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f7e:	e9 f9 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102f83 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f83:	6a 00                	push   $0x0
  pushl $137
c0102f85:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f8a:	e9 ed fa ff ff       	jmp    c0102a7c <__alltraps>

c0102f8f <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f8f:	6a 00                	push   $0x0
  pushl $138
c0102f91:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f96:	e9 e1 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102f9b <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f9b:	6a 00                	push   $0x0
  pushl $139
c0102f9d:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102fa2:	e9 d5 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fa7 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102fa7:	6a 00                	push   $0x0
  pushl $140
c0102fa9:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102fae:	e9 c9 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fb3 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102fb3:	6a 00                	push   $0x0
  pushl $141
c0102fb5:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102fba:	e9 bd fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fbf <vector142>:
.globl vector142
vector142:
  pushl $0
c0102fbf:	6a 00                	push   $0x0
  pushl $142
c0102fc1:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102fc6:	e9 b1 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fcb <vector143>:
.globl vector143
vector143:
  pushl $0
c0102fcb:	6a 00                	push   $0x0
  pushl $143
c0102fcd:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102fd2:	e9 a5 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fd7 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102fd7:	6a 00                	push   $0x0
  pushl $144
c0102fd9:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102fde:	e9 99 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fe3 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102fe3:	6a 00                	push   $0x0
  pushl $145
c0102fe5:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102fea:	e9 8d fa ff ff       	jmp    c0102a7c <__alltraps>

c0102fef <vector146>:
.globl vector146
vector146:
  pushl $0
c0102fef:	6a 00                	push   $0x0
  pushl $146
c0102ff1:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102ff6:	e9 81 fa ff ff       	jmp    c0102a7c <__alltraps>

c0102ffb <vector147>:
.globl vector147
vector147:
  pushl $0
c0102ffb:	6a 00                	push   $0x0
  pushl $147
c0102ffd:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103002:	e9 75 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103007 <vector148>:
.globl vector148
vector148:
  pushl $0
c0103007:	6a 00                	push   $0x0
  pushl $148
c0103009:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010300e:	e9 69 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103013 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103013:	6a 00                	push   $0x0
  pushl $149
c0103015:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010301a:	e9 5d fa ff ff       	jmp    c0102a7c <__alltraps>

c010301f <vector150>:
.globl vector150
vector150:
  pushl $0
c010301f:	6a 00                	push   $0x0
  pushl $150
c0103021:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103026:	e9 51 fa ff ff       	jmp    c0102a7c <__alltraps>

c010302b <vector151>:
.globl vector151
vector151:
  pushl $0
c010302b:	6a 00                	push   $0x0
  pushl $151
c010302d:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0103032:	e9 45 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103037 <vector152>:
.globl vector152
vector152:
  pushl $0
c0103037:	6a 00                	push   $0x0
  pushl $152
c0103039:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010303e:	e9 39 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103043 <vector153>:
.globl vector153
vector153:
  pushl $0
c0103043:	6a 00                	push   $0x0
  pushl $153
c0103045:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010304a:	e9 2d fa ff ff       	jmp    c0102a7c <__alltraps>

c010304f <vector154>:
.globl vector154
vector154:
  pushl $0
c010304f:	6a 00                	push   $0x0
  pushl $154
c0103051:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0103056:	e9 21 fa ff ff       	jmp    c0102a7c <__alltraps>

c010305b <vector155>:
.globl vector155
vector155:
  pushl $0
c010305b:	6a 00                	push   $0x0
  pushl $155
c010305d:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0103062:	e9 15 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103067 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103067:	6a 00                	push   $0x0
  pushl $156
c0103069:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010306e:	e9 09 fa ff ff       	jmp    c0102a7c <__alltraps>

c0103073 <vector157>:
.globl vector157
vector157:
  pushl $0
c0103073:	6a 00                	push   $0x0
  pushl $157
c0103075:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010307a:	e9 fd f9 ff ff       	jmp    c0102a7c <__alltraps>

c010307f <vector158>:
.globl vector158
vector158:
  pushl $0
c010307f:	6a 00                	push   $0x0
  pushl $158
c0103081:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103086:	e9 f1 f9 ff ff       	jmp    c0102a7c <__alltraps>

c010308b <vector159>:
.globl vector159
vector159:
  pushl $0
c010308b:	6a 00                	push   $0x0
  pushl $159
c010308d:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0103092:	e9 e5 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103097 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103097:	6a 00                	push   $0x0
  pushl $160
c0103099:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010309e:	e9 d9 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030a3 <vector161>:
.globl vector161
vector161:
  pushl $0
c01030a3:	6a 00                	push   $0x0
  pushl $161
c01030a5:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01030aa:	e9 cd f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030af <vector162>:
.globl vector162
vector162:
  pushl $0
c01030af:	6a 00                	push   $0x0
  pushl $162
c01030b1:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01030b6:	e9 c1 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030bb <vector163>:
.globl vector163
vector163:
  pushl $0
c01030bb:	6a 00                	push   $0x0
  pushl $163
c01030bd:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01030c2:	e9 b5 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030c7 <vector164>:
.globl vector164
vector164:
  pushl $0
c01030c7:	6a 00                	push   $0x0
  pushl $164
c01030c9:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01030ce:	e9 a9 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030d3 <vector165>:
.globl vector165
vector165:
  pushl $0
c01030d3:	6a 00                	push   $0x0
  pushl $165
c01030d5:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01030da:	e9 9d f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030df <vector166>:
.globl vector166
vector166:
  pushl $0
c01030df:	6a 00                	push   $0x0
  pushl $166
c01030e1:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01030e6:	e9 91 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030eb <vector167>:
.globl vector167
vector167:
  pushl $0
c01030eb:	6a 00                	push   $0x0
  pushl $167
c01030ed:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01030f2:	e9 85 f9 ff ff       	jmp    c0102a7c <__alltraps>

c01030f7 <vector168>:
.globl vector168
vector168:
  pushl $0
c01030f7:	6a 00                	push   $0x0
  pushl $168
c01030f9:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01030fe:	e9 79 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103103 <vector169>:
.globl vector169
vector169:
  pushl $0
c0103103:	6a 00                	push   $0x0
  pushl $169
c0103105:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010310a:	e9 6d f9 ff ff       	jmp    c0102a7c <__alltraps>

c010310f <vector170>:
.globl vector170
vector170:
  pushl $0
c010310f:	6a 00                	push   $0x0
  pushl $170
c0103111:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0103116:	e9 61 f9 ff ff       	jmp    c0102a7c <__alltraps>

c010311b <vector171>:
.globl vector171
vector171:
  pushl $0
c010311b:	6a 00                	push   $0x0
  pushl $171
c010311d:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0103122:	e9 55 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103127 <vector172>:
.globl vector172
vector172:
  pushl $0
c0103127:	6a 00                	push   $0x0
  pushl $172
c0103129:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010312e:	e9 49 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103133 <vector173>:
.globl vector173
vector173:
  pushl $0
c0103133:	6a 00                	push   $0x0
  pushl $173
c0103135:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010313a:	e9 3d f9 ff ff       	jmp    c0102a7c <__alltraps>

c010313f <vector174>:
.globl vector174
vector174:
  pushl $0
c010313f:	6a 00                	push   $0x0
  pushl $174
c0103141:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0103146:	e9 31 f9 ff ff       	jmp    c0102a7c <__alltraps>

c010314b <vector175>:
.globl vector175
vector175:
  pushl $0
c010314b:	6a 00                	push   $0x0
  pushl $175
c010314d:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0103152:	e9 25 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103157 <vector176>:
.globl vector176
vector176:
  pushl $0
c0103157:	6a 00                	push   $0x0
  pushl $176
c0103159:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010315e:	e9 19 f9 ff ff       	jmp    c0102a7c <__alltraps>

c0103163 <vector177>:
.globl vector177
vector177:
  pushl $0
c0103163:	6a 00                	push   $0x0
  pushl $177
c0103165:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010316a:	e9 0d f9 ff ff       	jmp    c0102a7c <__alltraps>

c010316f <vector178>:
.globl vector178
vector178:
  pushl $0
c010316f:	6a 00                	push   $0x0
  pushl $178
c0103171:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103176:	e9 01 f9 ff ff       	jmp    c0102a7c <__alltraps>

c010317b <vector179>:
.globl vector179
vector179:
  pushl $0
c010317b:	6a 00                	push   $0x0
  pushl $179
c010317d:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0103182:	e9 f5 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103187 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103187:	6a 00                	push   $0x0
  pushl $180
c0103189:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010318e:	e9 e9 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103193 <vector181>:
.globl vector181
vector181:
  pushl $0
c0103193:	6a 00                	push   $0x0
  pushl $181
c0103195:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010319a:	e9 dd f8 ff ff       	jmp    c0102a7c <__alltraps>

c010319f <vector182>:
.globl vector182
vector182:
  pushl $0
c010319f:	6a 00                	push   $0x0
  pushl $182
c01031a1:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01031a6:	e9 d1 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031ab <vector183>:
.globl vector183
vector183:
  pushl $0
c01031ab:	6a 00                	push   $0x0
  pushl $183
c01031ad:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01031b2:	e9 c5 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031b7 <vector184>:
.globl vector184
vector184:
  pushl $0
c01031b7:	6a 00                	push   $0x0
  pushl $184
c01031b9:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01031be:	e9 b9 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031c3 <vector185>:
.globl vector185
vector185:
  pushl $0
c01031c3:	6a 00                	push   $0x0
  pushl $185
c01031c5:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01031ca:	e9 ad f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031cf <vector186>:
.globl vector186
vector186:
  pushl $0
c01031cf:	6a 00                	push   $0x0
  pushl $186
c01031d1:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01031d6:	e9 a1 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031db <vector187>:
.globl vector187
vector187:
  pushl $0
c01031db:	6a 00                	push   $0x0
  pushl $187
c01031dd:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01031e2:	e9 95 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031e7 <vector188>:
.globl vector188
vector188:
  pushl $0
c01031e7:	6a 00                	push   $0x0
  pushl $188
c01031e9:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01031ee:	e9 89 f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031f3 <vector189>:
.globl vector189
vector189:
  pushl $0
c01031f3:	6a 00                	push   $0x0
  pushl $189
c01031f5:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01031fa:	e9 7d f8 ff ff       	jmp    c0102a7c <__alltraps>

c01031ff <vector190>:
.globl vector190
vector190:
  pushl $0
c01031ff:	6a 00                	push   $0x0
  pushl $190
c0103201:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0103206:	e9 71 f8 ff ff       	jmp    c0102a7c <__alltraps>

c010320b <vector191>:
.globl vector191
vector191:
  pushl $0
c010320b:	6a 00                	push   $0x0
  pushl $191
c010320d:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0103212:	e9 65 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103217 <vector192>:
.globl vector192
vector192:
  pushl $0
c0103217:	6a 00                	push   $0x0
  pushl $192
c0103219:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010321e:	e9 59 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103223 <vector193>:
.globl vector193
vector193:
  pushl $0
c0103223:	6a 00                	push   $0x0
  pushl $193
c0103225:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010322a:	e9 4d f8 ff ff       	jmp    c0102a7c <__alltraps>

c010322f <vector194>:
.globl vector194
vector194:
  pushl $0
c010322f:	6a 00                	push   $0x0
  pushl $194
c0103231:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0103236:	e9 41 f8 ff ff       	jmp    c0102a7c <__alltraps>

c010323b <vector195>:
.globl vector195
vector195:
  pushl $0
c010323b:	6a 00                	push   $0x0
  pushl $195
c010323d:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0103242:	e9 35 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103247 <vector196>:
.globl vector196
vector196:
  pushl $0
c0103247:	6a 00                	push   $0x0
  pushl $196
c0103249:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010324e:	e9 29 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103253 <vector197>:
.globl vector197
vector197:
  pushl $0
c0103253:	6a 00                	push   $0x0
  pushl $197
c0103255:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010325a:	e9 1d f8 ff ff       	jmp    c0102a7c <__alltraps>

c010325f <vector198>:
.globl vector198
vector198:
  pushl $0
c010325f:	6a 00                	push   $0x0
  pushl $198
c0103261:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103266:	e9 11 f8 ff ff       	jmp    c0102a7c <__alltraps>

c010326b <vector199>:
.globl vector199
vector199:
  pushl $0
c010326b:	6a 00                	push   $0x0
  pushl $199
c010326d:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0103272:	e9 05 f8 ff ff       	jmp    c0102a7c <__alltraps>

c0103277 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103277:	6a 00                	push   $0x0
  pushl $200
c0103279:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010327e:	e9 f9 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103283 <vector201>:
.globl vector201
vector201:
  pushl $0
c0103283:	6a 00                	push   $0x0
  pushl $201
c0103285:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010328a:	e9 ed f7 ff ff       	jmp    c0102a7c <__alltraps>

c010328f <vector202>:
.globl vector202
vector202:
  pushl $0
c010328f:	6a 00                	push   $0x0
  pushl $202
c0103291:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103296:	e9 e1 f7 ff ff       	jmp    c0102a7c <__alltraps>

c010329b <vector203>:
.globl vector203
vector203:
  pushl $0
c010329b:	6a 00                	push   $0x0
  pushl $203
c010329d:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01032a2:	e9 d5 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032a7 <vector204>:
.globl vector204
vector204:
  pushl $0
c01032a7:	6a 00                	push   $0x0
  pushl $204
c01032a9:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01032ae:	e9 c9 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032b3 <vector205>:
.globl vector205
vector205:
  pushl $0
c01032b3:	6a 00                	push   $0x0
  pushl $205
c01032b5:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01032ba:	e9 bd f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032bf <vector206>:
.globl vector206
vector206:
  pushl $0
c01032bf:	6a 00                	push   $0x0
  pushl $206
c01032c1:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01032c6:	e9 b1 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032cb <vector207>:
.globl vector207
vector207:
  pushl $0
c01032cb:	6a 00                	push   $0x0
  pushl $207
c01032cd:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01032d2:	e9 a5 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032d7 <vector208>:
.globl vector208
vector208:
  pushl $0
c01032d7:	6a 00                	push   $0x0
  pushl $208
c01032d9:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01032de:	e9 99 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032e3 <vector209>:
.globl vector209
vector209:
  pushl $0
c01032e3:	6a 00                	push   $0x0
  pushl $209
c01032e5:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01032ea:	e9 8d f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032ef <vector210>:
.globl vector210
vector210:
  pushl $0
c01032ef:	6a 00                	push   $0x0
  pushl $210
c01032f1:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01032f6:	e9 81 f7 ff ff       	jmp    c0102a7c <__alltraps>

c01032fb <vector211>:
.globl vector211
vector211:
  pushl $0
c01032fb:	6a 00                	push   $0x0
  pushl $211
c01032fd:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0103302:	e9 75 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103307 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103307:	6a 00                	push   $0x0
  pushl $212
c0103309:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010330e:	e9 69 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103313 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103313:	6a 00                	push   $0x0
  pushl $213
c0103315:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010331a:	e9 5d f7 ff ff       	jmp    c0102a7c <__alltraps>

c010331f <vector214>:
.globl vector214
vector214:
  pushl $0
c010331f:	6a 00                	push   $0x0
  pushl $214
c0103321:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103326:	e9 51 f7 ff ff       	jmp    c0102a7c <__alltraps>

c010332b <vector215>:
.globl vector215
vector215:
  pushl $0
c010332b:	6a 00                	push   $0x0
  pushl $215
c010332d:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0103332:	e9 45 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103337 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103337:	6a 00                	push   $0x0
  pushl $216
c0103339:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010333e:	e9 39 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103343 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103343:	6a 00                	push   $0x0
  pushl $217
c0103345:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010334a:	e9 2d f7 ff ff       	jmp    c0102a7c <__alltraps>

c010334f <vector218>:
.globl vector218
vector218:
  pushl $0
c010334f:	6a 00                	push   $0x0
  pushl $218
c0103351:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103356:	e9 21 f7 ff ff       	jmp    c0102a7c <__alltraps>

c010335b <vector219>:
.globl vector219
vector219:
  pushl $0
c010335b:	6a 00                	push   $0x0
  pushl $219
c010335d:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0103362:	e9 15 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103367 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103367:	6a 00                	push   $0x0
  pushl $220
c0103369:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010336e:	e9 09 f7 ff ff       	jmp    c0102a7c <__alltraps>

c0103373 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103373:	6a 00                	push   $0x0
  pushl $221
c0103375:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010337a:	e9 fd f6 ff ff       	jmp    c0102a7c <__alltraps>

c010337f <vector222>:
.globl vector222
vector222:
  pushl $0
c010337f:	6a 00                	push   $0x0
  pushl $222
c0103381:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103386:	e9 f1 f6 ff ff       	jmp    c0102a7c <__alltraps>

c010338b <vector223>:
.globl vector223
vector223:
  pushl $0
c010338b:	6a 00                	push   $0x0
  pushl $223
c010338d:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103392:	e9 e5 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103397 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103397:	6a 00                	push   $0x0
  pushl $224
c0103399:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010339e:	e9 d9 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033a3 <vector225>:
.globl vector225
vector225:
  pushl $0
c01033a3:	6a 00                	push   $0x0
  pushl $225
c01033a5:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01033aa:	e9 cd f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033af <vector226>:
.globl vector226
vector226:
  pushl $0
c01033af:	6a 00                	push   $0x0
  pushl $226
c01033b1:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01033b6:	e9 c1 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033bb <vector227>:
.globl vector227
vector227:
  pushl $0
c01033bb:	6a 00                	push   $0x0
  pushl $227
c01033bd:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01033c2:	e9 b5 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033c7 <vector228>:
.globl vector228
vector228:
  pushl $0
c01033c7:	6a 00                	push   $0x0
  pushl $228
c01033c9:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01033ce:	e9 a9 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033d3 <vector229>:
.globl vector229
vector229:
  pushl $0
c01033d3:	6a 00                	push   $0x0
  pushl $229
c01033d5:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01033da:	e9 9d f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033df <vector230>:
.globl vector230
vector230:
  pushl $0
c01033df:	6a 00                	push   $0x0
  pushl $230
c01033e1:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01033e6:	e9 91 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033eb <vector231>:
.globl vector231
vector231:
  pushl $0
c01033eb:	6a 00                	push   $0x0
  pushl $231
c01033ed:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01033f2:	e9 85 f6 ff ff       	jmp    c0102a7c <__alltraps>

c01033f7 <vector232>:
.globl vector232
vector232:
  pushl $0
c01033f7:	6a 00                	push   $0x0
  pushl $232
c01033f9:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01033fe:	e9 79 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103403 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103403:	6a 00                	push   $0x0
  pushl $233
c0103405:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010340a:	e9 6d f6 ff ff       	jmp    c0102a7c <__alltraps>

c010340f <vector234>:
.globl vector234
vector234:
  pushl $0
c010340f:	6a 00                	push   $0x0
  pushl $234
c0103411:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103416:	e9 61 f6 ff ff       	jmp    c0102a7c <__alltraps>

c010341b <vector235>:
.globl vector235
vector235:
  pushl $0
c010341b:	6a 00                	push   $0x0
  pushl $235
c010341d:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0103422:	e9 55 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103427 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103427:	6a 00                	push   $0x0
  pushl $236
c0103429:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010342e:	e9 49 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103433 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103433:	6a 00                	push   $0x0
  pushl $237
c0103435:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010343a:	e9 3d f6 ff ff       	jmp    c0102a7c <__alltraps>

c010343f <vector238>:
.globl vector238
vector238:
  pushl $0
c010343f:	6a 00                	push   $0x0
  pushl $238
c0103441:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103446:	e9 31 f6 ff ff       	jmp    c0102a7c <__alltraps>

c010344b <vector239>:
.globl vector239
vector239:
  pushl $0
c010344b:	6a 00                	push   $0x0
  pushl $239
c010344d:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0103452:	e9 25 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103457 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103457:	6a 00                	push   $0x0
  pushl $240
c0103459:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010345e:	e9 19 f6 ff ff       	jmp    c0102a7c <__alltraps>

c0103463 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103463:	6a 00                	push   $0x0
  pushl $241
c0103465:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010346a:	e9 0d f6 ff ff       	jmp    c0102a7c <__alltraps>

c010346f <vector242>:
.globl vector242
vector242:
  pushl $0
c010346f:	6a 00                	push   $0x0
  pushl $242
c0103471:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103476:	e9 01 f6 ff ff       	jmp    c0102a7c <__alltraps>

c010347b <vector243>:
.globl vector243
vector243:
  pushl $0
c010347b:	6a 00                	push   $0x0
  pushl $243
c010347d:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103482:	e9 f5 f5 ff ff       	jmp    c0102a7c <__alltraps>

c0103487 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103487:	6a 00                	push   $0x0
  pushl $244
c0103489:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010348e:	e9 e9 f5 ff ff       	jmp    c0102a7c <__alltraps>

c0103493 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103493:	6a 00                	push   $0x0
  pushl $245
c0103495:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010349a:	e9 dd f5 ff ff       	jmp    c0102a7c <__alltraps>

c010349f <vector246>:
.globl vector246
vector246:
  pushl $0
c010349f:	6a 00                	push   $0x0
  pushl $246
c01034a1:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01034a6:	e9 d1 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034ab <vector247>:
.globl vector247
vector247:
  pushl $0
c01034ab:	6a 00                	push   $0x0
  pushl $247
c01034ad:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01034b2:	e9 c5 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034b7 <vector248>:
.globl vector248
vector248:
  pushl $0
c01034b7:	6a 00                	push   $0x0
  pushl $248
c01034b9:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01034be:	e9 b9 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034c3 <vector249>:
.globl vector249
vector249:
  pushl $0
c01034c3:	6a 00                	push   $0x0
  pushl $249
c01034c5:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01034ca:	e9 ad f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034cf <vector250>:
.globl vector250
vector250:
  pushl $0
c01034cf:	6a 00                	push   $0x0
  pushl $250
c01034d1:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01034d6:	e9 a1 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034db <vector251>:
.globl vector251
vector251:
  pushl $0
c01034db:	6a 00                	push   $0x0
  pushl $251
c01034dd:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01034e2:	e9 95 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034e7 <vector252>:
.globl vector252
vector252:
  pushl $0
c01034e7:	6a 00                	push   $0x0
  pushl $252
c01034e9:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01034ee:	e9 89 f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034f3 <vector253>:
.globl vector253
vector253:
  pushl $0
c01034f3:	6a 00                	push   $0x0
  pushl $253
c01034f5:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01034fa:	e9 7d f5 ff ff       	jmp    c0102a7c <__alltraps>

c01034ff <vector254>:
.globl vector254
vector254:
  pushl $0
c01034ff:	6a 00                	push   $0x0
  pushl $254
c0103501:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103506:	e9 71 f5 ff ff       	jmp    c0102a7c <__alltraps>

c010350b <vector255>:
.globl vector255
vector255:
  pushl $0
c010350b:	6a 00                	push   $0x0
  pushl $255
c010350d:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0103512:	e9 65 f5 ff ff       	jmp    c0102a7c <__alltraps>

c0103517 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103517:	55                   	push   %ebp
c0103518:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010351a:	8b 55 08             	mov    0x8(%ebp),%edx
c010351d:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0103522:	29 c2                	sub    %eax,%edx
c0103524:	89 d0                	mov    %edx,%eax
c0103526:	c1 f8 05             	sar    $0x5,%eax
}
c0103529:	5d                   	pop    %ebp
c010352a:	c3                   	ret    

c010352b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010352b:	55                   	push   %ebp
c010352c:	89 e5                	mov    %esp,%ebp
c010352e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103531:	8b 45 08             	mov    0x8(%ebp),%eax
c0103534:	89 04 24             	mov    %eax,(%esp)
c0103537:	e8 db ff ff ff       	call   c0103517 <page2ppn>
c010353c:	c1 e0 0c             	shl    $0xc,%eax
}
c010353f:	c9                   	leave  
c0103540:	c3                   	ret    

c0103541 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0103541:	55                   	push   %ebp
c0103542:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103544:	8b 45 08             	mov    0x8(%ebp),%eax
c0103547:	8b 00                	mov    (%eax),%eax
}
c0103549:	5d                   	pop    %ebp
c010354a:	c3                   	ret    

c010354b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010354b:	55                   	push   %ebp
c010354c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010354e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103551:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103554:	89 10                	mov    %edx,(%eax)
}
c0103556:	5d                   	pop    %ebp
c0103557:	c3                   	ret    

c0103558 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103558:	55                   	push   %ebp
c0103559:	89 e5                	mov    %esp,%ebp
c010355b:	83 ec 10             	sub    $0x10,%esp
c010355e:	c7 45 fc b8 ef 19 c0 	movl   $0xc019efb8,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103565:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103568:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010356b:	89 50 04             	mov    %edx,0x4(%eax)
c010356e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103571:	8b 50 04             	mov    0x4(%eax),%edx
c0103574:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103577:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0103579:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c0103580:	00 00 00 
}
c0103583:	c9                   	leave  
c0103584:	c3                   	ret    

c0103585 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103585:	55                   	push   %ebp
c0103586:	89 e5                	mov    %esp,%ebp
c0103588:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c010358b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010358f:	75 24                	jne    c01035b5 <default_init_memmap+0x30>
c0103591:	c7 44 24 0c 90 c7 10 	movl   $0xc010c790,0xc(%esp)
c0103598:	c0 
c0103599:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01035a0:	c0 
c01035a1:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c01035a8:	00 
c01035a9:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01035b0:	e8 60 d8 ff ff       	call   c0100e15 <__panic>
    struct Page *p = base;
c01035b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01035b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01035bb:	eb 7d                	jmp    c010363a <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01035bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035c0:	83 c0 04             	add    $0x4,%eax
c01035c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01035ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01035d3:	0f a3 10             	bt     %edx,(%eax)
c01035d6:	19 c0                	sbb    %eax,%eax
c01035d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01035db:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01035df:	0f 95 c0             	setne  %al
c01035e2:	0f b6 c0             	movzbl %al,%eax
c01035e5:	85 c0                	test   %eax,%eax
c01035e7:	75 24                	jne    c010360d <default_init_memmap+0x88>
c01035e9:	c7 44 24 0c c1 c7 10 	movl   $0xc010c7c1,0xc(%esp)
c01035f0:	c0 
c01035f1:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01035f8:	c0 
c01035f9:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0103600:	00 
c0103601:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103608:	e8 08 d8 ff ff       	call   c0100e15 <__panic>
        p->flags = p->property = 0;
c010360d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103610:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103617:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010361a:	8b 50 08             	mov    0x8(%eax),%edx
c010361d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103620:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103623:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010362a:	00 
c010362b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010362e:	89 04 24             	mov    %eax,(%esp)
c0103631:	e8 15 ff ff ff       	call   c010354b <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103636:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010363a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010363d:	c1 e0 05             	shl    $0x5,%eax
c0103640:	89 c2                	mov    %eax,%edx
c0103642:	8b 45 08             	mov    0x8(%ebp),%eax
c0103645:	01 d0                	add    %edx,%eax
c0103647:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010364a:	0f 85 6d ff ff ff    	jne    c01035bd <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103650:	8b 45 08             	mov    0x8(%ebp),%eax
c0103653:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103656:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103659:	8b 45 08             	mov    0x8(%ebp),%eax
c010365c:	83 c0 04             	add    $0x4,%eax
c010365f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103666:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103669:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010366c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010366f:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0103672:	8b 15 c0 ef 19 c0    	mov    0xc019efc0,%edx
c0103678:	8b 45 0c             	mov    0xc(%ebp),%eax
c010367b:	01 d0                	add    %edx,%eax
c010367d:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
    list_add(&free_list, &(base->page_link));
c0103682:	8b 45 08             	mov    0x8(%ebp),%eax
c0103685:	83 c0 0c             	add    $0xc,%eax
c0103688:	c7 45 dc b8 ef 19 c0 	movl   $0xc019efb8,-0x24(%ebp)
c010368f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103692:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103695:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103698:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010369b:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010369e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01036a1:	8b 40 04             	mov    0x4(%eax),%eax
c01036a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01036a7:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01036aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01036ad:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01036b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01036b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036b6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01036b9:	89 10                	mov    %edx,(%eax)
c01036bb:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036be:	8b 10                	mov    (%eax),%edx
c01036c0:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01036c3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01036c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01036c9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01036cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01036cf:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01036d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01036d5:	89 10                	mov    %edx,(%eax)
}
c01036d7:	c9                   	leave  
c01036d8:	c3                   	ret    

c01036d9 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01036d9:	55                   	push   %ebp
c01036da:	89 e5                	mov    %esp,%ebp
c01036dc:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01036df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01036e3:	75 24                	jne    c0103709 <default_alloc_pages+0x30>
c01036e5:	c7 44 24 0c 90 c7 10 	movl   $0xc010c790,0xc(%esp)
c01036ec:	c0 
c01036ed:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01036f4:	c0 
c01036f5:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c01036fc:	00 
c01036fd:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103704:	e8 0c d7 ff ff       	call   c0100e15 <__panic>
    if (n > nr_free) {
c0103709:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c010370e:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103711:	73 0a                	jae    c010371d <default_alloc_pages+0x44>
        return NULL;
c0103713:	b8 00 00 00 00       	mov    $0x0,%eax
c0103718:	e9 3f 01 00 00       	jmp    c010385c <default_alloc_pages+0x183>
    }
    struct Page *page = NULL;
c010371d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0103724:	c7 45 f0 b8 ef 19 c0 	movl   $0xc019efb8,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010372b:	eb 1c                	jmp    c0103749 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c010372d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103730:	83 e8 0c             	sub    $0xc,%eax
c0103733:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103736:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103739:	8b 40 08             	mov    0x8(%eax),%eax
c010373c:	3b 45 08             	cmp    0x8(%ebp),%eax
c010373f:	72 08                	jb     c0103749 <default_alloc_pages+0x70>
            page = p;
c0103741:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103744:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103747:	eb 18                	jmp    c0103761 <default_alloc_pages+0x88>
c0103749:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010374c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010374f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103752:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103755:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103758:	81 7d f0 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x10(%ebp)
c010375f:	75 cc                	jne    c010372d <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0103761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103765:	0f 84 ee 00 00 00    	je     c0103859 <default_alloc_pages+0x180>
        if (page->property > n) {
c010376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010376e:	8b 40 08             	mov    0x8(%eax),%eax
c0103771:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103774:	0f 86 85 00 00 00    	jbe    c01037ff <default_alloc_pages+0x126>
            struct Page *p = page + n;
c010377a:	8b 45 08             	mov    0x8(%ebp),%eax
c010377d:	c1 e0 05             	shl    $0x5,%eax
c0103780:	89 c2                	mov    %eax,%edx
c0103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103785:	01 d0                	add    %edx,%eax
c0103787:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010378a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010378d:	8b 40 08             	mov    0x8(%eax),%eax
c0103790:	2b 45 08             	sub    0x8(%ebp),%eax
c0103793:	89 c2                	mov    %eax,%edx
c0103795:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103798:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c010379b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010379e:	83 c0 04             	add    $0x4,%eax
c01037a1:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01037a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01037ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01037ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01037b1:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c01037b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037b7:	83 c0 0c             	add    $0xc,%eax
c01037ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01037bd:	83 c2 0c             	add    $0xc,%edx
c01037c0:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01037c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01037c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037c9:	8b 40 04             	mov    0x4(%eax),%eax
c01037cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01037cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01037d2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01037d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01037d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01037db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01037de:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01037e1:	89 10                	mov    %edx,(%eax)
c01037e3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01037e6:	8b 10                	mov    (%eax),%edx
c01037e8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01037eb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01037ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037f1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01037f4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01037f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01037fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01037fd:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01037ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103802:	83 c0 0c             	add    $0xc,%eax
c0103805:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103808:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010380b:	8b 40 04             	mov    0x4(%eax),%eax
c010380e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103811:	8b 12                	mov    (%edx),%edx
c0103813:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0103816:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103819:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010381c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010381f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103822:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103825:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103828:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c010382a:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c010382f:	2b 45 08             	sub    0x8(%ebp),%eax
c0103832:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
        page->property = n;
c0103837:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010383a:	8b 55 08             	mov    0x8(%ebp),%edx
c010383d:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(page);
c0103840:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103843:	83 c0 04             	add    $0x4,%eax
c0103846:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010384d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103850:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103853:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0103856:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0103859:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010385c:	c9                   	leave  
c010385d:	c3                   	ret    

c010385e <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010385e:	55                   	push   %ebp
c010385f:	89 e5                	mov    %esp,%ebp
c0103861:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0103867:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010386b:	75 24                	jne    c0103891 <default_free_pages+0x33>
c010386d:	c7 44 24 0c 90 c7 10 	movl   $0xc010c790,0xc(%esp)
c0103874:	c0 
c0103875:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010387c:	c0 
c010387d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0103884:	00 
c0103885:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010388c:	e8 84 d5 ff ff       	call   c0100e15 <__panic>
    struct Page *p = base;
c0103891:	8b 45 08             	mov    0x8(%ebp),%eax
c0103894:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0103897:	e9 9d 00 00 00       	jmp    c0103939 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c010389c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389f:	83 c0 04             	add    $0x4,%eax
c01038a2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01038a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038af:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01038b2:	0f a3 10             	bt     %edx,(%eax)
c01038b5:	19 c0                	sbb    %eax,%eax
c01038b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01038ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01038be:	0f 95 c0             	setne  %al
c01038c1:	0f b6 c0             	movzbl %al,%eax
c01038c4:	85 c0                	test   %eax,%eax
c01038c6:	75 2c                	jne    c01038f4 <default_free_pages+0x96>
c01038c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038cb:	83 c0 04             	add    $0x4,%eax
c01038ce:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c01038d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01038db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01038de:	0f a3 10             	bt     %edx,(%eax)
c01038e1:	19 c0                	sbb    %eax,%eax
c01038e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c01038e6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01038ea:	0f 95 c0             	setne  %al
c01038ed:	0f b6 c0             	movzbl %al,%eax
c01038f0:	85 c0                	test   %eax,%eax
c01038f2:	74 24                	je     c0103918 <default_free_pages+0xba>
c01038f4:	c7 44 24 0c d4 c7 10 	movl   $0xc010c7d4,0xc(%esp)
c01038fb:	c0 
c01038fc:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103903:	c0 
c0103904:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c010390b:	00 
c010390c:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103913:	e8 fd d4 ff ff       	call   c0100e15 <__panic>
        p->flags = 0;
c0103918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010391b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0103922:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103929:	00 
c010392a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392d:	89 04 24             	mov    %eax,(%esp)
c0103930:	e8 16 fc ff ff       	call   c010354b <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103935:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103939:	8b 45 0c             	mov    0xc(%ebp),%eax
c010393c:	c1 e0 05             	shl    $0x5,%eax
c010393f:	89 c2                	mov    %eax,%edx
c0103941:	8b 45 08             	mov    0x8(%ebp),%eax
c0103944:	01 d0                	add    %edx,%eax
c0103946:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103949:	0f 85 4d ff ff ff    	jne    c010389c <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010394f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103952:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103955:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103958:	8b 45 08             	mov    0x8(%ebp),%eax
c010395b:	83 c0 04             	add    $0x4,%eax
c010395e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103965:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103968:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010396b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010396e:	0f ab 10             	bts    %edx,(%eax)
c0103971:	c7 45 c8 b8 ef 19 c0 	movl   $0xc019efb8,-0x38(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103978:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010397b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010397e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *insert_list = &free_list;
c0103981:	c7 45 ec b8 ef 19 c0 	movl   $0xc019efb8,-0x14(%ebp)
    while (le != &free_list) {
c0103988:	e9 0b 01 00 00       	jmp    c0103a98 <default_free_pages+0x23a>
        p = le2page(le, page_link);
c010398d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103990:	83 e8 0c             	sub    $0xc,%eax
c0103993:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103996:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103999:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010399c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010399f:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01039a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c01039a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a8:	8b 40 08             	mov    0x8(%eax),%eax
c01039ab:	c1 e0 05             	shl    $0x5,%eax
c01039ae:	89 c2                	mov    %eax,%edx
c01039b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01039b3:	01 d0                	add    %edx,%eax
c01039b5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01039b8:	75 5a                	jne    c0103a14 <default_free_pages+0x1b6>
            base->property += p->property;
c01039ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01039bd:	8b 50 08             	mov    0x8(%eax),%edx
c01039c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039c3:	8b 40 08             	mov    0x8(%eax),%eax
c01039c6:	01 c2                	add    %eax,%edx
c01039c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01039cb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c01039ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039d1:	83 c0 04             	add    $0x4,%eax
c01039d4:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01039db:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01039de:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01039e1:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01039e4:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01039e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039ea:	83 c0 0c             	add    $0xc,%eax
c01039ed:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01039f0:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01039f3:	8b 40 04             	mov    0x4(%eax),%eax
c01039f6:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01039f9:	8b 12                	mov    (%edx),%edx
c01039fb:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01039fe:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103a01:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103a04:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103a07:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103a0a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103a0d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103a10:	89 10                	mov    %edx,(%eax)
c0103a12:	eb 73                	jmp    c0103a87 <default_free_pages+0x229>
        }
        else if (p + p->property == base) {
c0103a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a17:	8b 40 08             	mov    0x8(%eax),%eax
c0103a1a:	c1 e0 05             	shl    $0x5,%eax
c0103a1d:	89 c2                	mov    %eax,%edx
c0103a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a22:	01 d0                	add    %edx,%eax
c0103a24:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103a27:	75 5e                	jne    c0103a87 <default_free_pages+0x229>
            p->property += base->property;
c0103a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a2c:	8b 50 08             	mov    0x8(%eax),%edx
c0103a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a32:	8b 40 08             	mov    0x8(%eax),%eax
c0103a35:	01 c2                	add    %eax,%edx
c0103a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a3a:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0103a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a40:	83 c0 04             	add    $0x4,%eax
c0103a43:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103a4a:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103a4d:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103a50:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103a53:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a59:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0103a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a5f:	83 c0 0c             	add    $0xc,%eax
c0103a62:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103a65:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103a68:	8b 40 04             	mov    0x4(%eax),%eax
c0103a6b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103a6e:	8b 12                	mov    (%edx),%edx
c0103a70:	89 55 a0             	mov    %edx,-0x60(%ebp)
c0103a73:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103a76:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103a79:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103a7c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103a7f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103a82:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103a85:	89 10                	mov    %edx,(%eax)
        }
        if (p < base)
c0103a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a8a:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103a8d:	73 09                	jae    c0103a98 <default_free_pages+0x23a>
            insert_list = &p->page_link;
c0103a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a92:	83 c0 0c             	add    $0xc,%eax
c0103a95:	89 45 ec             	mov    %eax,-0x14(%ebp)
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    list_entry_t *insert_list = &free_list;
    while (le != &free_list) {
c0103a98:	81 7d f0 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x10(%ebp)
c0103a9f:	0f 85 e8 fe ff ff    	jne    c010398d <default_free_pages+0x12f>
            list_del(&(p->page_link));
        }
        if (p < base)
            insert_list = &p->page_link;
    }
    nr_free += n;
c0103aa5:	8b 15 c0 ef 19 c0    	mov    0xc019efc0,%edx
c0103aab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103aae:	01 d0                	add    %edx,%eax
c0103ab0:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
    list_add(insert_list, &(base->page_link));
c0103ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab8:	8d 50 0c             	lea    0xc(%eax),%edx
c0103abb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103abe:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103ac1:	89 55 94             	mov    %edx,-0x6c(%ebp)
c0103ac4:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103ac7:	89 45 90             	mov    %eax,-0x70(%ebp)
c0103aca:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103acd:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103ad0:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103ad3:	8b 40 04             	mov    0x4(%eax),%eax
c0103ad6:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103ad9:	89 55 88             	mov    %edx,-0x78(%ebp)
c0103adc:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103adf:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103ae2:	89 45 80             	mov    %eax,-0x80(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103ae5:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103ae8:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103aeb:	89 10                	mov    %edx,(%eax)
c0103aed:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103af0:	8b 10                	mov    (%eax),%edx
c0103af2:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103af5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103af8:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103afb:	8b 55 80             	mov    -0x80(%ebp),%edx
c0103afe:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103b01:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103b04:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103b07:	89 10                	mov    %edx,(%eax)
}
c0103b09:	c9                   	leave  
c0103b0a:	c3                   	ret    

c0103b0b <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103b0b:	55                   	push   %ebp
c0103b0c:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103b0e:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
}
c0103b13:	5d                   	pop    %ebp
c0103b14:	c3                   	ret    

c0103b15 <basic_check>:

static void
basic_check(void) {
c0103b15:	55                   	push   %ebp
c0103b16:	89 e5                	mov    %esp,%ebp
c0103b18:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103b1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103b2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b35:	e8 dc 15 00 00       	call   c0105116 <alloc_pages>
c0103b3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b3d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103b41:	75 24                	jne    c0103b67 <basic_check+0x52>
c0103b43:	c7 44 24 0c f9 c7 10 	movl   $0xc010c7f9,0xc(%esp)
c0103b4a:	c0 
c0103b4b:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103b52:	c0 
c0103b53:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0103b5a:	00 
c0103b5b:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103b62:	e8 ae d2 ff ff       	call   c0100e15 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103b67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b6e:	e8 a3 15 00 00       	call   c0105116 <alloc_pages>
c0103b73:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b7a:	75 24                	jne    c0103ba0 <basic_check+0x8b>
c0103b7c:	c7 44 24 0c 15 c8 10 	movl   $0xc010c815,0xc(%esp)
c0103b83:	c0 
c0103b84:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103b8b:	c0 
c0103b8c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c0103b93:	00 
c0103b94:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103b9b:	e8 75 d2 ff ff       	call   c0100e15 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103ba0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ba7:	e8 6a 15 00 00       	call   c0105116 <alloc_pages>
c0103bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103baf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103bb3:	75 24                	jne    c0103bd9 <basic_check+0xc4>
c0103bb5:	c7 44 24 0c 31 c8 10 	movl   $0xc010c831,0xc(%esp)
c0103bbc:	c0 
c0103bbd:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103bc4:	c0 
c0103bc5:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0103bcc:	00 
c0103bcd:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103bd4:	e8 3c d2 ff ff       	call   c0100e15 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0103bd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bdc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103bdf:	74 10                	je     c0103bf1 <basic_check+0xdc>
c0103be1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103be4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103be7:	74 08                	je     c0103bf1 <basic_check+0xdc>
c0103be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103bef:	75 24                	jne    c0103c15 <basic_check+0x100>
c0103bf1:	c7 44 24 0c 50 c8 10 	movl   $0xc010c850,0xc(%esp)
c0103bf8:	c0 
c0103bf9:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103c00:	c0 
c0103c01:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0103c08:	00 
c0103c09:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103c10:	e8 00 d2 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0103c15:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c18:	89 04 24             	mov    %eax,(%esp)
c0103c1b:	e8 21 f9 ff ff       	call   c0103541 <page_ref>
c0103c20:	85 c0                	test   %eax,%eax
c0103c22:	75 1e                	jne    c0103c42 <basic_check+0x12d>
c0103c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c27:	89 04 24             	mov    %eax,(%esp)
c0103c2a:	e8 12 f9 ff ff       	call   c0103541 <page_ref>
c0103c2f:	85 c0                	test   %eax,%eax
c0103c31:	75 0f                	jne    c0103c42 <basic_check+0x12d>
c0103c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c36:	89 04 24             	mov    %eax,(%esp)
c0103c39:	e8 03 f9 ff ff       	call   c0103541 <page_ref>
c0103c3e:	85 c0                	test   %eax,%eax
c0103c40:	74 24                	je     c0103c66 <basic_check+0x151>
c0103c42:	c7 44 24 0c 74 c8 10 	movl   $0xc010c874,0xc(%esp)
c0103c49:	c0 
c0103c4a:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103c51:	c0 
c0103c52:	c7 44 24 04 a1 00 00 	movl   $0xa1,0x4(%esp)
c0103c59:	00 
c0103c5a:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103c61:	e8 af d1 ff ff       	call   c0100e15 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0103c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c69:	89 04 24             	mov    %eax,(%esp)
c0103c6c:	e8 ba f8 ff ff       	call   c010352b <page2pa>
c0103c71:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103c77:	c1 e2 0c             	shl    $0xc,%edx
c0103c7a:	39 d0                	cmp    %edx,%eax
c0103c7c:	72 24                	jb     c0103ca2 <basic_check+0x18d>
c0103c7e:	c7 44 24 0c b0 c8 10 	movl   $0xc010c8b0,0xc(%esp)
c0103c85:	c0 
c0103c86:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103c8d:	c0 
c0103c8e:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
c0103c95:	00 
c0103c96:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103c9d:	e8 73 d1 ff ff       	call   c0100e15 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ca5:	89 04 24             	mov    %eax,(%esp)
c0103ca8:	e8 7e f8 ff ff       	call   c010352b <page2pa>
c0103cad:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103cb3:	c1 e2 0c             	shl    $0xc,%edx
c0103cb6:	39 d0                	cmp    %edx,%eax
c0103cb8:	72 24                	jb     c0103cde <basic_check+0x1c9>
c0103cba:	c7 44 24 0c cd c8 10 	movl   $0xc010c8cd,0xc(%esp)
c0103cc1:	c0 
c0103cc2:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103cc9:	c0 
c0103cca:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c0103cd1:	00 
c0103cd2:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103cd9:	e8 37 d1 ff ff       	call   c0100e15 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ce1:	89 04 24             	mov    %eax,(%esp)
c0103ce4:	e8 42 f8 ff ff       	call   c010352b <page2pa>
c0103ce9:	8b 15 e0 ce 19 c0    	mov    0xc019cee0,%edx
c0103cef:	c1 e2 0c             	shl    $0xc,%edx
c0103cf2:	39 d0                	cmp    %edx,%eax
c0103cf4:	72 24                	jb     c0103d1a <basic_check+0x205>
c0103cf6:	c7 44 24 0c ea c8 10 	movl   $0xc010c8ea,0xc(%esp)
c0103cfd:	c0 
c0103cfe:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103d05:	c0 
c0103d06:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0103d0d:	00 
c0103d0e:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103d15:	e8 fb d0 ff ff       	call   c0100e15 <__panic>

    list_entry_t free_list_store = free_list;
c0103d1a:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c0103d1f:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c0103d25:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103d28:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103d2b:	c7 45 e0 b8 ef 19 c0 	movl   $0xc019efb8,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103d32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d35:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103d38:	89 50 04             	mov    %edx,0x4(%eax)
c0103d3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d3e:	8b 50 04             	mov    0x4(%eax),%edx
c0103d41:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d44:	89 10                	mov    %edx,(%eax)
c0103d46:	c7 45 dc b8 ef 19 c0 	movl   $0xc019efb8,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103d4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103d50:	8b 40 04             	mov    0x4(%eax),%eax
c0103d53:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103d56:	0f 94 c0             	sete   %al
c0103d59:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103d5c:	85 c0                	test   %eax,%eax
c0103d5e:	75 24                	jne    c0103d84 <basic_check+0x26f>
c0103d60:	c7 44 24 0c 07 c9 10 	movl   $0xc010c907,0xc(%esp)
c0103d67:	c0 
c0103d68:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103d6f:	c0 
c0103d70:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0103d77:	00 
c0103d78:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103d7f:	e8 91 d0 ff ff       	call   c0100e15 <__panic>

    unsigned int nr_free_store = nr_free;
c0103d84:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103d89:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103d8c:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c0103d93:	00 00 00 

    assert(alloc_page() == NULL);
c0103d96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103d9d:	e8 74 13 00 00       	call   c0105116 <alloc_pages>
c0103da2:	85 c0                	test   %eax,%eax
c0103da4:	74 24                	je     c0103dca <basic_check+0x2b5>
c0103da6:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0103dad:	c0 
c0103dae:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103db5:	c0 
c0103db6:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
c0103dbd:	00 
c0103dbe:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103dc5:	e8 4b d0 ff ff       	call   c0100e15 <__panic>

    free_page(p0);
c0103dca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103dd1:	00 
c0103dd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dd5:	89 04 24             	mov    %eax,(%esp)
c0103dd8:	e8 a4 13 00 00       	call   c0105181 <free_pages>
    free_page(p1);
c0103ddd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103de4:	00 
c0103de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103de8:	89 04 24             	mov    %eax,(%esp)
c0103deb:	e8 91 13 00 00       	call   c0105181 <free_pages>
    free_page(p2);
c0103df0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103df7:	00 
c0103df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dfb:	89 04 24             	mov    %eax,(%esp)
c0103dfe:	e8 7e 13 00 00       	call   c0105181 <free_pages>
    assert(nr_free == 3);
c0103e03:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103e08:	83 f8 03             	cmp    $0x3,%eax
c0103e0b:	74 24                	je     c0103e31 <basic_check+0x31c>
c0103e0d:	c7 44 24 0c 33 c9 10 	movl   $0xc010c933,0xc(%esp)
c0103e14:	c0 
c0103e15:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103e1c:	c0 
c0103e1d:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c0103e24:	00 
c0103e25:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103e2c:	e8 e4 cf ff ff       	call   c0100e15 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103e31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e38:	e8 d9 12 00 00       	call   c0105116 <alloc_pages>
c0103e3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e40:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103e44:	75 24                	jne    c0103e6a <basic_check+0x355>
c0103e46:	c7 44 24 0c f9 c7 10 	movl   $0xc010c7f9,0xc(%esp)
c0103e4d:	c0 
c0103e4e:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103e55:	c0 
c0103e56:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0103e5d:	00 
c0103e5e:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103e65:	e8 ab cf ff ff       	call   c0100e15 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103e6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103e71:	e8 a0 12 00 00       	call   c0105116 <alloc_pages>
c0103e76:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103e7d:	75 24                	jne    c0103ea3 <basic_check+0x38e>
c0103e7f:	c7 44 24 0c 15 c8 10 	movl   $0xc010c815,0xc(%esp)
c0103e86:	c0 
c0103e87:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103e8e:	c0 
c0103e8f:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0103e96:	00 
c0103e97:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103e9e:	e8 72 cf ff ff       	call   c0100e15 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103ea3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103eaa:	e8 67 12 00 00       	call   c0105116 <alloc_pages>
c0103eaf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103eb2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103eb6:	75 24                	jne    c0103edc <basic_check+0x3c7>
c0103eb8:	c7 44 24 0c 31 c8 10 	movl   $0xc010c831,0xc(%esp)
c0103ebf:	c0 
c0103ec0:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103ec7:	c0 
c0103ec8:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0103ecf:	00 
c0103ed0:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103ed7:	e8 39 cf ff ff       	call   c0100e15 <__panic>

    assert(alloc_page() == NULL);
c0103edc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ee3:	e8 2e 12 00 00       	call   c0105116 <alloc_pages>
c0103ee8:	85 c0                	test   %eax,%eax
c0103eea:	74 24                	je     c0103f10 <basic_check+0x3fb>
c0103eec:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0103ef3:	c0 
c0103ef4:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103efb:	c0 
c0103efc:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0103f03:	00 
c0103f04:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103f0b:	e8 05 cf ff ff       	call   c0100e15 <__panic>

    free_page(p0);
c0103f10:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f17:	00 
c0103f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103f1b:	89 04 24             	mov    %eax,(%esp)
c0103f1e:	e8 5e 12 00 00       	call   c0105181 <free_pages>
c0103f23:	c7 45 d8 b8 ef 19 c0 	movl   $0xc019efb8,-0x28(%ebp)
c0103f2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103f2d:	8b 40 04             	mov    0x4(%eax),%eax
c0103f30:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103f33:	0f 94 c0             	sete   %al
c0103f36:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103f39:	85 c0                	test   %eax,%eax
c0103f3b:	74 24                	je     c0103f61 <basic_check+0x44c>
c0103f3d:	c7 44 24 0c 40 c9 10 	movl   $0xc010c940,0xc(%esp)
c0103f44:	c0 
c0103f45:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103f4c:	c0 
c0103f4d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0103f54:	00 
c0103f55:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103f5c:	e8 b4 ce ff ff       	call   c0100e15 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103f61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f68:	e8 a9 11 00 00       	call   c0105116 <alloc_pages>
c0103f6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f73:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103f76:	74 24                	je     c0103f9c <basic_check+0x487>
c0103f78:	c7 44 24 0c 58 c9 10 	movl   $0xc010c958,0xc(%esp)
c0103f7f:	c0 
c0103f80:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103f87:	c0 
c0103f88:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c0103f8f:	00 
c0103f90:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103f97:	e8 79 ce ff ff       	call   c0100e15 <__panic>
    assert(alloc_page() == NULL);
c0103f9c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103fa3:	e8 6e 11 00 00       	call   c0105116 <alloc_pages>
c0103fa8:	85 c0                	test   %eax,%eax
c0103faa:	74 24                	je     c0103fd0 <basic_check+0x4bb>
c0103fac:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0103fb3:	c0 
c0103fb4:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103fbb:	c0 
c0103fbc:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103fc3:	00 
c0103fc4:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103fcb:	e8 45 ce ff ff       	call   c0100e15 <__panic>

    assert(nr_free == 0);
c0103fd0:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0103fd5:	85 c0                	test   %eax,%eax
c0103fd7:	74 24                	je     c0103ffd <basic_check+0x4e8>
c0103fd9:	c7 44 24 0c 71 c9 10 	movl   $0xc010c971,0xc(%esp)
c0103fe0:	c0 
c0103fe1:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0103fe8:	c0 
c0103fe9:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c0103ff0:	00 
c0103ff1:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0103ff8:	e8 18 ce ff ff       	call   c0100e15 <__panic>
    free_list = free_list_store;
c0103ffd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104000:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104003:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c0104008:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc
    nr_free = nr_free_store;
c010400e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104011:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0

    free_page(p);
c0104016:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010401d:	00 
c010401e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104021:	89 04 24             	mov    %eax,(%esp)
c0104024:	e8 58 11 00 00       	call   c0105181 <free_pages>
    free_page(p1);
c0104029:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104030:	00 
c0104031:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104034:	89 04 24             	mov    %eax,(%esp)
c0104037:	e8 45 11 00 00       	call   c0105181 <free_pages>
    free_page(p2);
c010403c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104043:	00 
c0104044:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104047:	89 04 24             	mov    %eax,(%esp)
c010404a:	e8 32 11 00 00       	call   c0105181 <free_pages>
}
c010404f:	c9                   	leave  
c0104050:	c3                   	ret    

c0104051 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0104051:	55                   	push   %ebp
c0104052:	89 e5                	mov    %esp,%ebp
c0104054:	53                   	push   %ebx
c0104055:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010405b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104062:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0104069:	c7 45 ec b8 ef 19 c0 	movl   $0xc019efb8,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104070:	eb 6b                	jmp    c01040dd <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0104072:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104075:	83 e8 0c             	sub    $0xc,%eax
c0104078:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010407b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010407e:	83 c0 04             	add    $0x4,%eax
c0104081:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0104088:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010408b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010408e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104091:	0f a3 10             	bt     %edx,(%eax)
c0104094:	19 c0                	sbb    %eax,%eax
c0104096:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0104099:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010409d:	0f 95 c0             	setne  %al
c01040a0:	0f b6 c0             	movzbl %al,%eax
c01040a3:	85 c0                	test   %eax,%eax
c01040a5:	75 24                	jne    c01040cb <default_check+0x7a>
c01040a7:	c7 44 24 0c 7e c9 10 	movl   $0xc010c97e,0xc(%esp)
c01040ae:	c0 
c01040af:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01040b6:	c0 
c01040b7:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01040be:	00 
c01040bf:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01040c6:	e8 4a cd ff ff       	call   c0100e15 <__panic>
        count ++, total += p->property;
c01040cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01040cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01040d2:	8b 50 08             	mov    0x8(%eax),%edx
c01040d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040d8:	01 d0                	add    %edx,%eax
c01040da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01040dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040e0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01040e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01040e6:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01040e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01040ec:	81 7d ec b8 ef 19 c0 	cmpl   $0xc019efb8,-0x14(%ebp)
c01040f3:	0f 85 79 ff ff ff    	jne    c0104072 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01040f9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01040fc:	e8 b2 10 00 00       	call   c01051b3 <nr_free_pages>
c0104101:	39 c3                	cmp    %eax,%ebx
c0104103:	74 24                	je     c0104129 <default_check+0xd8>
c0104105:	c7 44 24 0c 8e c9 10 	movl   $0xc010c98e,0xc(%esp)
c010410c:	c0 
c010410d:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104114:	c0 
c0104115:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010411c:	00 
c010411d:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104124:	e8 ec cc ff ff       	call   c0100e15 <__panic>

    basic_check();
c0104129:	e8 e7 f9 ff ff       	call   c0103b15 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010412e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104135:	e8 dc 0f 00 00       	call   c0105116 <alloc_pages>
c010413a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010413d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104141:	75 24                	jne    c0104167 <default_check+0x116>
c0104143:	c7 44 24 0c a7 c9 10 	movl   $0xc010c9a7,0xc(%esp)
c010414a:	c0 
c010414b:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104152:	c0 
c0104153:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c010415a:	00 
c010415b:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104162:	e8 ae cc ff ff       	call   c0100e15 <__panic>
    assert(!PageProperty(p0));
c0104167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010416a:	83 c0 04             	add    $0x4,%eax
c010416d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104174:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104177:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010417a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010417d:	0f a3 10             	bt     %edx,(%eax)
c0104180:	19 c0                	sbb    %eax,%eax
c0104182:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104185:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104189:	0f 95 c0             	setne  %al
c010418c:	0f b6 c0             	movzbl %al,%eax
c010418f:	85 c0                	test   %eax,%eax
c0104191:	74 24                	je     c01041b7 <default_check+0x166>
c0104193:	c7 44 24 0c b2 c9 10 	movl   $0xc010c9b2,0xc(%esp)
c010419a:	c0 
c010419b:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01041a2:	c0 
c01041a3:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01041aa:	00 
c01041ab:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01041b2:	e8 5e cc ff ff       	call   c0100e15 <__panic>

    list_entry_t free_list_store = free_list;
c01041b7:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c01041bc:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c01041c2:	89 45 80             	mov    %eax,-0x80(%ebp)
c01041c5:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01041c8:	c7 45 b4 b8 ef 19 c0 	movl   $0xc019efb8,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01041cf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041d2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01041d5:	89 50 04             	mov    %edx,0x4(%eax)
c01041d8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041db:	8b 50 04             	mov    0x4(%eax),%edx
c01041de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01041e1:	89 10                	mov    %edx,(%eax)
c01041e3:	c7 45 b0 b8 ef 19 c0 	movl   $0xc019efb8,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01041ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01041ed:	8b 40 04             	mov    0x4(%eax),%eax
c01041f0:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01041f3:	0f 94 c0             	sete   %al
c01041f6:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01041f9:	85 c0                	test   %eax,%eax
c01041fb:	75 24                	jne    c0104221 <default_check+0x1d0>
c01041fd:	c7 44 24 0c 07 c9 10 	movl   $0xc010c907,0xc(%esp)
c0104204:	c0 
c0104205:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010420c:	c0 
c010420d:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0104214:	00 
c0104215:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010421c:	e8 f4 cb ff ff       	call   c0100e15 <__panic>
    assert(alloc_page() == NULL);
c0104221:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104228:	e8 e9 0e 00 00       	call   c0105116 <alloc_pages>
c010422d:	85 c0                	test   %eax,%eax
c010422f:	74 24                	je     c0104255 <default_check+0x204>
c0104231:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0104238:	c0 
c0104239:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104240:	c0 
c0104241:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0104248:	00 
c0104249:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104250:	e8 c0 cb ff ff       	call   c0100e15 <__panic>

    unsigned int nr_free_store = nr_free;
c0104255:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c010425a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010425d:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c0104264:	00 00 00 

    free_pages(p0 + 2, 3);
c0104267:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010426a:	83 c0 40             	add    $0x40,%eax
c010426d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104274:	00 
c0104275:	89 04 24             	mov    %eax,(%esp)
c0104278:	e8 04 0f 00 00       	call   c0105181 <free_pages>
    assert(alloc_pages(4) == NULL);
c010427d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0104284:	e8 8d 0e 00 00       	call   c0105116 <alloc_pages>
c0104289:	85 c0                	test   %eax,%eax
c010428b:	74 24                	je     c01042b1 <default_check+0x260>
c010428d:	c7 44 24 0c c4 c9 10 	movl   $0xc010c9c4,0xc(%esp)
c0104294:	c0 
c0104295:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010429c:	c0 
c010429d:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01042a4:	00 
c01042a5:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01042ac:	e8 64 cb ff ff       	call   c0100e15 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01042b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042b4:	83 c0 40             	add    $0x40,%eax
c01042b7:	83 c0 04             	add    $0x4,%eax
c01042ba:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01042c1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01042c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01042c7:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01042ca:	0f a3 10             	bt     %edx,(%eax)
c01042cd:	19 c0                	sbb    %eax,%eax
c01042cf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01042d2:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01042d6:	0f 95 c0             	setne  %al
c01042d9:	0f b6 c0             	movzbl %al,%eax
c01042dc:	85 c0                	test   %eax,%eax
c01042de:	74 0e                	je     c01042ee <default_check+0x29d>
c01042e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01042e3:	83 c0 40             	add    $0x40,%eax
c01042e6:	8b 40 08             	mov    0x8(%eax),%eax
c01042e9:	83 f8 03             	cmp    $0x3,%eax
c01042ec:	74 24                	je     c0104312 <default_check+0x2c1>
c01042ee:	c7 44 24 0c dc c9 10 	movl   $0xc010c9dc,0xc(%esp)
c01042f5:	c0 
c01042f6:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01042fd:	c0 
c01042fe:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c0104305:	00 
c0104306:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010430d:	e8 03 cb ff ff       	call   c0100e15 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104312:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0104319:	e8 f8 0d 00 00       	call   c0105116 <alloc_pages>
c010431e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104321:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104325:	75 24                	jne    c010434b <default_check+0x2fa>
c0104327:	c7 44 24 0c 08 ca 10 	movl   $0xc010ca08,0xc(%esp)
c010432e:	c0 
c010432f:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104336:	c0 
c0104337:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010433e:	00 
c010433f:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104346:	e8 ca ca ff ff       	call   c0100e15 <__panic>
    assert(alloc_page() == NULL);
c010434b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104352:	e8 bf 0d 00 00       	call   c0105116 <alloc_pages>
c0104357:	85 c0                	test   %eax,%eax
c0104359:	74 24                	je     c010437f <default_check+0x32e>
c010435b:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0104362:	c0 
c0104363:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010436a:	c0 
c010436b:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0104372:	00 
c0104373:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010437a:	e8 96 ca ff ff       	call   c0100e15 <__panic>
    assert(p0 + 2 == p1);
c010437f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104382:	83 c0 40             	add    $0x40,%eax
c0104385:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104388:	74 24                	je     c01043ae <default_check+0x35d>
c010438a:	c7 44 24 0c 26 ca 10 	movl   $0xc010ca26,0xc(%esp)
c0104391:	c0 
c0104392:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104399:	c0 
c010439a:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01043a1:	00 
c01043a2:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01043a9:	e8 67 ca ff ff       	call   c0100e15 <__panic>

    p2 = p0 + 1;
c01043ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043b1:	83 c0 20             	add    $0x20,%eax
c01043b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01043b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043be:	00 
c01043bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043c2:	89 04 24             	mov    %eax,(%esp)
c01043c5:	e8 b7 0d 00 00       	call   c0105181 <free_pages>
    free_pages(p1, 3);
c01043ca:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01043d1:	00 
c01043d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043d5:	89 04 24             	mov    %eax,(%esp)
c01043d8:	e8 a4 0d 00 00       	call   c0105181 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01043dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043e0:	83 c0 04             	add    $0x4,%eax
c01043e3:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01043ea:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01043ed:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01043f0:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01043f3:	0f a3 10             	bt     %edx,(%eax)
c01043f6:	19 c0                	sbb    %eax,%eax
c01043f8:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01043fb:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01043ff:	0f 95 c0             	setne  %al
c0104402:	0f b6 c0             	movzbl %al,%eax
c0104405:	85 c0                	test   %eax,%eax
c0104407:	74 0b                	je     c0104414 <default_check+0x3c3>
c0104409:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010440c:	8b 40 08             	mov    0x8(%eax),%eax
c010440f:	83 f8 01             	cmp    $0x1,%eax
c0104412:	74 24                	je     c0104438 <default_check+0x3e7>
c0104414:	c7 44 24 0c 34 ca 10 	movl   $0xc010ca34,0xc(%esp)
c010441b:	c0 
c010441c:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104423:	c0 
c0104424:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c010442b:	00 
c010442c:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104433:	e8 dd c9 ff ff       	call   c0100e15 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0104438:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010443b:	83 c0 04             	add    $0x4,%eax
c010443e:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0104445:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104448:	8b 45 90             	mov    -0x70(%ebp),%eax
c010444b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010444e:	0f a3 10             	bt     %edx,(%eax)
c0104451:	19 c0                	sbb    %eax,%eax
c0104453:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0104456:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010445a:	0f 95 c0             	setne  %al
c010445d:	0f b6 c0             	movzbl %al,%eax
c0104460:	85 c0                	test   %eax,%eax
c0104462:	74 0b                	je     c010446f <default_check+0x41e>
c0104464:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104467:	8b 40 08             	mov    0x8(%eax),%eax
c010446a:	83 f8 03             	cmp    $0x3,%eax
c010446d:	74 24                	je     c0104493 <default_check+0x442>
c010446f:	c7 44 24 0c 5c ca 10 	movl   $0xc010ca5c,0xc(%esp)
c0104476:	c0 
c0104477:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010447e:	c0 
c010447f:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0104486:	00 
c0104487:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010448e:	e8 82 c9 ff ff       	call   c0100e15 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0104493:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010449a:	e8 77 0c 00 00       	call   c0105116 <alloc_pages>
c010449f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044a5:	83 e8 20             	sub    $0x20,%eax
c01044a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044ab:	74 24                	je     c01044d1 <default_check+0x480>
c01044ad:	c7 44 24 0c 82 ca 10 	movl   $0xc010ca82,0xc(%esp)
c01044b4:	c0 
c01044b5:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01044bc:	c0 
c01044bd:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c01044c4:	00 
c01044c5:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01044cc:	e8 44 c9 ff ff       	call   c0100e15 <__panic>
    free_page(p0);
c01044d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01044d8:	00 
c01044d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044dc:	89 04 24             	mov    %eax,(%esp)
c01044df:	e8 9d 0c 00 00       	call   c0105181 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01044e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01044eb:	e8 26 0c 00 00       	call   c0105116 <alloc_pages>
c01044f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01044f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01044f6:	83 c0 20             	add    $0x20,%eax
c01044f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01044fc:	74 24                	je     c0104522 <default_check+0x4d1>
c01044fe:	c7 44 24 0c a0 ca 10 	movl   $0xc010caa0,0xc(%esp)
c0104505:	c0 
c0104506:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010450d:	c0 
c010450e:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0104515:	00 
c0104516:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010451d:	e8 f3 c8 ff ff       	call   c0100e15 <__panic>

    free_pages(p0, 2);
c0104522:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0104529:	00 
c010452a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010452d:	89 04 24             	mov    %eax,(%esp)
c0104530:	e8 4c 0c 00 00       	call   c0105181 <free_pages>
    free_page(p2);
c0104535:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010453c:	00 
c010453d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104540:	89 04 24             	mov    %eax,(%esp)
c0104543:	e8 39 0c 00 00       	call   c0105181 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0104548:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010454f:	e8 c2 0b 00 00       	call   c0105116 <alloc_pages>
c0104554:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010455b:	75 24                	jne    c0104581 <default_check+0x530>
c010455d:	c7 44 24 0c c0 ca 10 	movl   $0xc010cac0,0xc(%esp)
c0104564:	c0 
c0104565:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010456c:	c0 
c010456d:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104574:	00 
c0104575:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010457c:	e8 94 c8 ff ff       	call   c0100e15 <__panic>
    assert(alloc_page() == NULL);
c0104581:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104588:	e8 89 0b 00 00       	call   c0105116 <alloc_pages>
c010458d:	85 c0                	test   %eax,%eax
c010458f:	74 24                	je     c01045b5 <default_check+0x564>
c0104591:	c7 44 24 0c 1e c9 10 	movl   $0xc010c91e,0xc(%esp)
c0104598:	c0 
c0104599:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01045a0:	c0 
c01045a1:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01045a8:	00 
c01045a9:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01045b0:	e8 60 c8 ff ff       	call   c0100e15 <__panic>

    assert(nr_free == 0);
c01045b5:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01045ba:	85 c0                	test   %eax,%eax
c01045bc:	74 24                	je     c01045e2 <default_check+0x591>
c01045be:	c7 44 24 0c 71 c9 10 	movl   $0xc010c971,0xc(%esp)
c01045c5:	c0 
c01045c6:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c01045cd:	c0 
c01045ce:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c01045d5:	00 
c01045d6:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c01045dd:	e8 33 c8 ff ff       	call   c0100e15 <__panic>
    nr_free = nr_free_store;
c01045e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045e5:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0

    free_list = free_list_store;
c01045ea:	8b 45 80             	mov    -0x80(%ebp),%eax
c01045ed:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01045f0:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c01045f5:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc
    free_pages(p0, 5);
c01045fb:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104602:	00 
c0104603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104606:	89 04 24             	mov    %eax,(%esp)
c0104609:	e8 73 0b 00 00       	call   c0105181 <free_pages>

    le = &free_list;
c010460e:	c7 45 ec b8 ef 19 c0 	movl   $0xc019efb8,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0104615:	eb 1d                	jmp    c0104634 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0104617:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010461a:	83 e8 0c             	sub    $0xc,%eax
c010461d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0104620:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104624:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104627:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010462a:	8b 40 08             	mov    0x8(%eax),%eax
c010462d:	29 c2                	sub    %eax,%edx
c010462f:	89 d0                	mov    %edx,%eax
c0104631:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104634:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104637:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010463a:	8b 45 88             	mov    -0x78(%ebp),%eax
c010463d:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104640:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104643:	81 7d ec b8 ef 19 c0 	cmpl   $0xc019efb8,-0x14(%ebp)
c010464a:	75 cb                	jne    c0104617 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010464c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104650:	74 24                	je     c0104676 <default_check+0x625>
c0104652:	c7 44 24 0c de ca 10 	movl   $0xc010cade,0xc(%esp)
c0104659:	c0 
c010465a:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c0104661:	c0 
c0104662:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104669:	00 
c010466a:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c0104671:	e8 9f c7 ff ff       	call   c0100e15 <__panic>
    assert(total == 0);
c0104676:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010467a:	74 24                	je     c01046a0 <default_check+0x64f>
c010467c:	c7 44 24 0c e9 ca 10 	movl   $0xc010cae9,0xc(%esp)
c0104683:	c0 
c0104684:	c7 44 24 08 96 c7 10 	movl   $0xc010c796,0x8(%esp)
c010468b:	c0 
c010468c:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0104693:	00 
c0104694:	c7 04 24 ab c7 10 c0 	movl   $0xc010c7ab,(%esp)
c010469b:	e8 75 c7 ff ff       	call   c0100e15 <__panic>
}
c01046a0:	81 c4 94 00 00 00    	add    $0x94,%esp
c01046a6:	5b                   	pop    %ebx
c01046a7:	5d                   	pop    %ebp
c01046a8:	c3                   	ret    

c01046a9 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01046a9:	55                   	push   %ebp
c01046aa:	89 e5                	mov    %esp,%ebp
c01046ac:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01046af:	9c                   	pushf  
c01046b0:	58                   	pop    %eax
c01046b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01046b7:	25 00 02 00 00       	and    $0x200,%eax
c01046bc:	85 c0                	test   %eax,%eax
c01046be:	74 0c                	je     c01046cc <__intr_save+0x23>
        intr_disable();
c01046c0:	e8 a8 d9 ff ff       	call   c010206d <intr_disable>
        return 1;
c01046c5:	b8 01 00 00 00       	mov    $0x1,%eax
c01046ca:	eb 05                	jmp    c01046d1 <__intr_save+0x28>
    }
    return 0;
c01046cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01046d1:	c9                   	leave  
c01046d2:	c3                   	ret    

c01046d3 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01046d3:	55                   	push   %ebp
c01046d4:	89 e5                	mov    %esp,%ebp
c01046d6:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01046d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01046dd:	74 05                	je     c01046e4 <__intr_restore+0x11>
        intr_enable();
c01046df:	e8 83 d9 ff ff       	call   c0102067 <intr_enable>
    }
}
c01046e4:	c9                   	leave  
c01046e5:	c3                   	ret    

c01046e6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01046e6:	55                   	push   %ebp
c01046e7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01046e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01046ec:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01046f1:	29 c2                	sub    %eax,%edx
c01046f3:	89 d0                	mov    %edx,%eax
c01046f5:	c1 f8 05             	sar    $0x5,%eax
}
c01046f8:	5d                   	pop    %ebp
c01046f9:	c3                   	ret    

c01046fa <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01046fa:	55                   	push   %ebp
c01046fb:	89 e5                	mov    %esp,%ebp
c01046fd:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104700:	8b 45 08             	mov    0x8(%ebp),%eax
c0104703:	89 04 24             	mov    %eax,(%esp)
c0104706:	e8 db ff ff ff       	call   c01046e6 <page2ppn>
c010470b:	c1 e0 0c             	shl    $0xc,%eax
}
c010470e:	c9                   	leave  
c010470f:	c3                   	ret    

c0104710 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104710:	55                   	push   %ebp
c0104711:	89 e5                	mov    %esp,%ebp
c0104713:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104716:	8b 45 08             	mov    0x8(%ebp),%eax
c0104719:	c1 e8 0c             	shr    $0xc,%eax
c010471c:	89 c2                	mov    %eax,%edx
c010471e:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104723:	39 c2                	cmp    %eax,%edx
c0104725:	72 1c                	jb     c0104743 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104727:	c7 44 24 08 24 cb 10 	movl   $0xc010cb24,0x8(%esp)
c010472e:	c0 
c010472f:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104736:	00 
c0104737:	c7 04 24 43 cb 10 c0 	movl   $0xc010cb43,(%esp)
c010473e:	e8 d2 c6 ff ff       	call   c0100e15 <__panic>
    }
    return &pages[PPN(pa)];
c0104743:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104748:	8b 55 08             	mov    0x8(%ebp),%edx
c010474b:	c1 ea 0c             	shr    $0xc,%edx
c010474e:	c1 e2 05             	shl    $0x5,%edx
c0104751:	01 d0                	add    %edx,%eax
}
c0104753:	c9                   	leave  
c0104754:	c3                   	ret    

c0104755 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104755:	55                   	push   %ebp
c0104756:	89 e5                	mov    %esp,%ebp
c0104758:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010475b:	8b 45 08             	mov    0x8(%ebp),%eax
c010475e:	89 04 24             	mov    %eax,(%esp)
c0104761:	e8 94 ff ff ff       	call   c01046fa <page2pa>
c0104766:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010476c:	c1 e8 0c             	shr    $0xc,%eax
c010476f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104772:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104777:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010477a:	72 23                	jb     c010479f <page2kva+0x4a>
c010477c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010477f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104783:	c7 44 24 08 54 cb 10 	movl   $0xc010cb54,0x8(%esp)
c010478a:	c0 
c010478b:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104792:	00 
c0104793:	c7 04 24 43 cb 10 c0 	movl   $0xc010cb43,(%esp)
c010479a:	e8 76 c6 ff ff       	call   c0100e15 <__panic>
c010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01047a7:	c9                   	leave  
c01047a8:	c3                   	ret    

c01047a9 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01047a9:	55                   	push   %ebp
c01047aa:	89 e5                	mov    %esp,%ebp
c01047ac:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01047af:	8b 45 08             	mov    0x8(%ebp),%eax
c01047b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047b5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01047bc:	77 23                	ja     c01047e1 <kva2page+0x38>
c01047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047c5:	c7 44 24 08 78 cb 10 	movl   $0xc010cb78,0x8(%esp)
c01047cc:	c0 
c01047cd:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01047d4:	00 
c01047d5:	c7 04 24 43 cb 10 c0 	movl   $0xc010cb43,(%esp)
c01047dc:	e8 34 c6 ff ff       	call   c0100e15 <__panic>
c01047e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e4:	05 00 00 00 40       	add    $0x40000000,%eax
c01047e9:	89 04 24             	mov    %eax,(%esp)
c01047ec:	e8 1f ff ff ff       	call   c0104710 <pa2page>
}
c01047f1:	c9                   	leave  
c01047f2:	c3                   	ret    

c01047f3 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01047f3:	55                   	push   %ebp
c01047f4:	89 e5                	mov    %esp,%ebp
c01047f6:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c01047f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047fc:	ba 01 00 00 00       	mov    $0x1,%edx
c0104801:	89 c1                	mov    %eax,%ecx
c0104803:	d3 e2                	shl    %cl,%edx
c0104805:	89 d0                	mov    %edx,%eax
c0104807:	89 04 24             	mov    %eax,(%esp)
c010480a:	e8 07 09 00 00       	call   c0105116 <alloc_pages>
c010480f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104812:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104816:	75 07                	jne    c010481f <__slob_get_free_pages+0x2c>
    return NULL;
c0104818:	b8 00 00 00 00       	mov    $0x0,%eax
c010481d:	eb 0b                	jmp    c010482a <__slob_get_free_pages+0x37>
  return page2kva(page);
c010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104822:	89 04 24             	mov    %eax,(%esp)
c0104825:	e8 2b ff ff ff       	call   c0104755 <page2kva>
}
c010482a:	c9                   	leave  
c010482b:	c3                   	ret    

c010482c <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c010482c:	55                   	push   %ebp
c010482d:	89 e5                	mov    %esp,%ebp
c010482f:	53                   	push   %ebx
c0104830:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104836:	ba 01 00 00 00       	mov    $0x1,%edx
c010483b:	89 c1                	mov    %eax,%ecx
c010483d:	d3 e2                	shl    %cl,%edx
c010483f:	89 d0                	mov    %edx,%eax
c0104841:	89 c3                	mov    %eax,%ebx
c0104843:	8b 45 08             	mov    0x8(%ebp),%eax
c0104846:	89 04 24             	mov    %eax,(%esp)
c0104849:	e8 5b ff ff ff       	call   c01047a9 <kva2page>
c010484e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104852:	89 04 24             	mov    %eax,(%esp)
c0104855:	e8 27 09 00 00       	call   c0105181 <free_pages>
}
c010485a:	83 c4 14             	add    $0x14,%esp
c010485d:	5b                   	pop    %ebx
c010485e:	5d                   	pop    %ebp
c010485f:	c3                   	ret    

c0104860 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104860:	55                   	push   %ebp
c0104861:	89 e5                	mov    %esp,%ebp
c0104863:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104866:	8b 45 08             	mov    0x8(%ebp),%eax
c0104869:	83 c0 08             	add    $0x8,%eax
c010486c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104871:	76 24                	jbe    c0104897 <slob_alloc+0x37>
c0104873:	c7 44 24 0c 9c cb 10 	movl   $0xc010cb9c,0xc(%esp)
c010487a:	c0 
c010487b:	c7 44 24 08 bb cb 10 	movl   $0xc010cbbb,0x8(%esp)
c0104882:	c0 
c0104883:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010488a:	00 
c010488b:	c7 04 24 d0 cb 10 c0 	movl   $0xc010cbd0,(%esp)
c0104892:	e8 7e c5 ff ff       	call   c0100e15 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104897:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010489e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01048a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a8:	83 c0 07             	add    $0x7,%eax
c01048ab:	c1 e8 03             	shr    $0x3,%eax
c01048ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c01048b1:	e8 f3 fd ff ff       	call   c01046a9 <__intr_save>
c01048b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01048b9:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c01048be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c4:	8b 40 04             	mov    0x4(%eax),%eax
c01048c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01048ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01048ce:	74 25                	je     c01048f5 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01048d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01048d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01048d6:	01 d0                	add    %edx,%eax
c01048d8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01048db:	8b 45 10             	mov    0x10(%ebp),%eax
c01048de:	f7 d8                	neg    %eax
c01048e0:	21 d0                	and    %edx,%eax
c01048e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01048e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01048e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048eb:	29 c2                	sub    %eax,%edx
c01048ed:	89 d0                	mov    %edx,%eax
c01048ef:	c1 f8 03             	sar    $0x3,%eax
c01048f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01048f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f8:	8b 00                	mov    (%eax),%eax
c01048fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01048fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104900:	01 ca                	add    %ecx,%edx
c0104902:	39 d0                	cmp    %edx,%eax
c0104904:	0f 8c aa 00 00 00    	jl     c01049b4 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c010490a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010490e:	74 38                	je     c0104948 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104910:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104913:	8b 00                	mov    (%eax),%eax
c0104915:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104918:	89 c2                	mov    %eax,%edx
c010491a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010491d:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010491f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104922:	8b 50 04             	mov    0x4(%eax),%edx
c0104925:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104928:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c010492b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010492e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104931:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104934:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104937:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010493a:	89 10                	mov    %edx,(%eax)
				prev = cur;
c010493c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010493f:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104942:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104945:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104948:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010494b:	8b 00                	mov    (%eax),%eax
c010494d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104950:	75 0e                	jne    c0104960 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104952:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104955:	8b 50 04             	mov    0x4(%eax),%edx
c0104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495b:	89 50 04             	mov    %edx,0x4(%eax)
c010495e:	eb 3c                	jmp    c010499c <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104960:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104963:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010496a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496d:	01 c2                	add    %eax,%edx
c010496f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104972:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104975:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104978:	8b 40 04             	mov    0x4(%eax),%eax
c010497b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010497e:	8b 12                	mov    (%edx),%edx
c0104980:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104983:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104985:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104988:	8b 40 04             	mov    0x4(%eax),%eax
c010498b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010498e:	8b 52 04             	mov    0x4(%edx),%edx
c0104991:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104994:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104997:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010499a:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c010499c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010499f:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08
			spin_unlock_irqrestore(&slob_lock, flags);
c01049a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049a7:	89 04 24             	mov    %eax,(%esp)
c01049aa:	e8 24 fd ff ff       	call   c01046d3 <__intr_restore>
			return cur;
c01049af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049b2:	eb 7f                	jmp    c0104a33 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c01049b4:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c01049b9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01049bc:	75 61                	jne    c0104a1f <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c01049be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049c1:	89 04 24             	mov    %eax,(%esp)
c01049c4:	e8 0a fd ff ff       	call   c01046d3 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c01049c9:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01049d0:	75 07                	jne    c01049d9 <slob_alloc+0x179>
				return 0;
c01049d2:	b8 00 00 00 00       	mov    $0x0,%eax
c01049d7:	eb 5a                	jmp    c0104a33 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01049d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01049e0:	00 
c01049e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049e4:	89 04 24             	mov    %eax,(%esp)
c01049e7:	e8 07 fe ff ff       	call   c01047f3 <__slob_get_free_pages>
c01049ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01049ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01049f3:	75 07                	jne    c01049fc <slob_alloc+0x19c>
				return 0;
c01049f5:	b8 00 00 00 00       	mov    $0x0,%eax
c01049fa:	eb 37                	jmp    c0104a33 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01049fc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104a03:	00 
c0104a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a07:	89 04 24             	mov    %eax,(%esp)
c0104a0a:	e8 26 00 00 00       	call   c0104a35 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104a0f:	e8 95 fc ff ff       	call   c01046a9 <__intr_save>
c0104a14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104a17:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c0104a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a22:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a28:	8b 40 04             	mov    0x4(%eax),%eax
c0104a2b:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0104a2e:	e9 97 fe ff ff       	jmp    c01048ca <slob_alloc+0x6a>
}
c0104a33:	c9                   	leave  
c0104a34:	c3                   	ret    

c0104a35 <slob_free>:

static void slob_free(void *block, int size)
{
c0104a35:	55                   	push   %ebp
c0104a36:	89 e5                	mov    %esp,%ebp
c0104a38:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104a3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104a41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104a45:	75 05                	jne    c0104a4c <slob_free+0x17>
		return;
c0104a47:	e9 ff 00 00 00       	jmp    c0104b4b <slob_free+0x116>

	if (size)
c0104a4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104a50:	74 10                	je     c0104a62 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0104a52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a55:	83 c0 07             	add    $0x7,%eax
c0104a58:	c1 e8 03             	shr    $0x3,%eax
c0104a5b:	89 c2                	mov    %eax,%edx
c0104a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a60:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104a62:	e8 42 fc ff ff       	call   c01046a9 <__intr_save>
c0104a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104a6a:	a1 08 aa 12 c0       	mov    0xc012aa08,%eax
c0104a6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a72:	eb 27                	jmp    c0104a9b <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a77:	8b 40 04             	mov    0x4(%eax),%eax
c0104a7a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104a7d:	77 13                	ja     c0104a92 <slob_free+0x5d>
c0104a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a82:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104a85:	77 27                	ja     c0104aae <slob_free+0x79>
c0104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a8a:	8b 40 04             	mov    0x4(%eax),%eax
c0104a8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a90:	77 1c                	ja     c0104aae <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a95:	8b 40 04             	mov    0x4(%eax),%eax
c0104a98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a9e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104aa1:	76 d1                	jbe    c0104a74 <slob_free+0x3f>
c0104aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aa6:	8b 40 04             	mov    0x4(%eax),%eax
c0104aa9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104aac:	76 c6                	jbe    c0104a74 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0104aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab1:	8b 00                	mov    (%eax),%eax
c0104ab3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abd:	01 c2                	add    %eax,%edx
c0104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac2:	8b 40 04             	mov    0x4(%eax),%eax
c0104ac5:	39 c2                	cmp    %eax,%edx
c0104ac7:	75 25                	jne    c0104aee <slob_free+0xb9>
		b->units += cur->next->units;
c0104ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104acc:	8b 10                	mov    (%eax),%edx
c0104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ad1:	8b 40 04             	mov    0x4(%eax),%eax
c0104ad4:	8b 00                	mov    (%eax),%eax
c0104ad6:	01 c2                	add    %eax,%edx
c0104ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104adb:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104add:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ae0:	8b 40 04             	mov    0x4(%eax),%eax
c0104ae3:	8b 50 04             	mov    0x4(%eax),%edx
c0104ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ae9:	89 50 04             	mov    %edx,0x4(%eax)
c0104aec:	eb 0c                	jmp    c0104afa <slob_free+0xc5>
	} else
		b->next = cur->next;
c0104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104af1:	8b 50 04             	mov    0x4(%eax),%edx
c0104af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104af7:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104afd:	8b 00                	mov    (%eax),%eax
c0104aff:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b09:	01 d0                	add    %edx,%eax
c0104b0b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104b0e:	75 1f                	jne    c0104b2f <slob_free+0xfa>
		cur->units += b->units;
c0104b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b13:	8b 10                	mov    (%eax),%edx
c0104b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b18:	8b 00                	mov    (%eax),%eax
c0104b1a:	01 c2                	add    %eax,%edx
c0104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b1f:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0104b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b24:	8b 50 04             	mov    0x4(%eax),%edx
c0104b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b2a:	89 50 04             	mov    %edx,0x4(%eax)
c0104b2d:	eb 09                	jmp    c0104b38 <slob_free+0x103>
	} else
		cur->next = b;
c0104b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b32:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b35:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0104b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b3b:	a3 08 aa 12 c0       	mov    %eax,0xc012aa08

	spin_unlock_irqrestore(&slob_lock, flags);
c0104b40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104b43:	89 04 24             	mov    %eax,(%esp)
c0104b46:	e8 88 fb ff ff       	call   c01046d3 <__intr_restore>
}
c0104b4b:	c9                   	leave  
c0104b4c:	c3                   	ret    

c0104b4d <slob_init>:



void
slob_init(void) {
c0104b4d:	55                   	push   %ebp
c0104b4e:	89 e5                	mov    %esp,%ebp
c0104b50:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0104b53:	c7 04 24 e2 cb 10 c0 	movl   $0xc010cbe2,(%esp)
c0104b5a:	e8 f4 b7 ff ff       	call   c0100353 <cprintf>
}
c0104b5f:	c9                   	leave  
c0104b60:	c3                   	ret    

c0104b61 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0104b61:	55                   	push   %ebp
c0104b62:	89 e5                	mov    %esp,%ebp
c0104b64:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0104b67:	e8 e1 ff ff ff       	call   c0104b4d <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0104b6c:	c7 04 24 f6 cb 10 c0 	movl   $0xc010cbf6,(%esp)
c0104b73:	e8 db b7 ff ff       	call   c0100353 <cprintf>
}
c0104b78:	c9                   	leave  
c0104b79:	c3                   	ret    

c0104b7a <slob_allocated>:

size_t
slob_allocated(void) {
c0104b7a:	55                   	push   %ebp
c0104b7b:	89 e5                	mov    %esp,%ebp
  return 0;
c0104b7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b82:	5d                   	pop    %ebp
c0104b83:	c3                   	ret    

c0104b84 <kallocated>:

size_t
kallocated(void) {
c0104b84:	55                   	push   %ebp
c0104b85:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0104b87:	e8 ee ff ff ff       	call   c0104b7a <slob_allocated>
}
c0104b8c:	5d                   	pop    %ebp
c0104b8d:	c3                   	ret    

c0104b8e <find_order>:

static int find_order(int size)
{
c0104b8e:	55                   	push   %ebp
c0104b8f:	89 e5                	mov    %esp,%ebp
c0104b91:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0104b94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0104b9b:	eb 07                	jmp    c0104ba4 <find_order+0x16>
		order++;
c0104b9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0104ba1:	d1 7d 08             	sarl   0x8(%ebp)
c0104ba4:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104bab:	7f f0                	jg     c0104b9d <find_order+0xf>
		order++;
	return order;
c0104bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104bb0:	c9                   	leave  
c0104bb1:	c3                   	ret    

c0104bb2 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0104bb2:	55                   	push   %ebp
c0104bb3:	89 e5                	mov    %esp,%ebp
c0104bb5:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0104bb8:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0104bbf:	77 38                	ja     c0104bf9 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0104bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bc4:	8d 50 08             	lea    0x8(%eax),%edx
c0104bc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104bce:	00 
c0104bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104bd6:	89 14 24             	mov    %edx,(%esp)
c0104bd9:	e8 82 fc ff ff       	call   c0104860 <slob_alloc>
c0104bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0104be1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104be5:	74 08                	je     c0104bef <__kmalloc+0x3d>
c0104be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bea:	83 c0 08             	add    $0x8,%eax
c0104bed:	eb 05                	jmp    c0104bf4 <__kmalloc+0x42>
c0104bef:	b8 00 00 00 00       	mov    $0x0,%eax
c0104bf4:	e9 a6 00 00 00       	jmp    c0104c9f <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0104bf9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c00:	00 
c0104c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104c08:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0104c0f:	e8 4c fc ff ff       	call   c0104860 <slob_alloc>
c0104c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0104c17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104c1b:	75 07                	jne    c0104c24 <__kmalloc+0x72>
		return 0;
c0104c1d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104c22:	eb 7b                	jmp    c0104c9f <__kmalloc+0xed>

	bb->order = find_order(size);
c0104c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c27:	89 04 24             	mov    %eax,(%esp)
c0104c2a:	e8 5f ff ff ff       	call   c0104b8e <find_order>
c0104c2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104c32:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0104c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c37:	8b 00                	mov    (%eax),%eax
c0104c39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c40:	89 04 24             	mov    %eax,(%esp)
c0104c43:	e8 ab fb ff ff       	call   c01047f3 <__slob_get_free_pages>
c0104c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104c4b:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0104c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c51:	8b 40 04             	mov    0x4(%eax),%eax
c0104c54:	85 c0                	test   %eax,%eax
c0104c56:	74 2f                	je     c0104c87 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0104c58:	e8 4c fa ff ff       	call   c01046a9 <__intr_save>
c0104c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0104c60:	8b 15 c4 ce 19 c0    	mov    0xc019cec4,%edx
c0104c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c69:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0104c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c6f:	a3 c4 ce 19 c0       	mov    %eax,0xc019cec4
		spin_unlock_irqrestore(&block_lock, flags);
c0104c74:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c77:	89 04 24             	mov    %eax,(%esp)
c0104c7a:	e8 54 fa ff ff       	call   c01046d3 <__intr_restore>
		return bb->pages;
c0104c7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c82:	8b 40 04             	mov    0x4(%eax),%eax
c0104c85:	eb 18                	jmp    c0104c9f <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0104c87:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104c8e:	00 
c0104c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c92:	89 04 24             	mov    %eax,(%esp)
c0104c95:	e8 9b fd ff ff       	call   c0104a35 <slob_free>
	return 0;
c0104c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104c9f:	c9                   	leave  
c0104ca0:	c3                   	ret    

c0104ca1 <kmalloc>:

void *
kmalloc(size_t size)
{
c0104ca1:	55                   	push   %ebp
c0104ca2:	89 e5                	mov    %esp,%ebp
c0104ca4:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0104ca7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104cae:	00 
c0104caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cb2:	89 04 24             	mov    %eax,(%esp)
c0104cb5:	e8 f8 fe ff ff       	call   c0104bb2 <__kmalloc>
}
c0104cba:	c9                   	leave  
c0104cbb:	c3                   	ret    

c0104cbc <kfree>:


void kfree(void *block)
{
c0104cbc:	55                   	push   %ebp
c0104cbd:	89 e5                	mov    %esp,%ebp
c0104cbf:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0104cc2:	c7 45 f0 c4 ce 19 c0 	movl   $0xc019cec4,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104cc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104ccd:	75 05                	jne    c0104cd4 <kfree+0x18>
		return;
c0104ccf:	e9 a2 00 00 00       	jmp    c0104d76 <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104cdc:	85 c0                	test   %eax,%eax
c0104cde:	75 7f                	jne    c0104d5f <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0104ce0:	e8 c4 f9 ff ff       	call   c01046a9 <__intr_save>
c0104ce5:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104ce8:	a1 c4 ce 19 c0       	mov    0xc019cec4,%eax
c0104ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104cf0:	eb 5c                	jmp    c0104d4e <kfree+0x92>
			if (bb->pages == block) {
c0104cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cf5:	8b 40 04             	mov    0x4(%eax),%eax
c0104cf8:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104cfb:	75 3f                	jne    c0104d3c <kfree+0x80>
				*last = bb->next;
c0104cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d00:	8b 50 08             	mov    0x8(%eax),%edx
c0104d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d06:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0104d08:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d0b:	89 04 24             	mov    %eax,(%esp)
c0104d0e:	e8 c0 f9 ff ff       	call   c01046d3 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0104d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d16:	8b 10                	mov    (%eax),%edx
c0104d18:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d1b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104d1f:	89 04 24             	mov    %eax,(%esp)
c0104d22:	e8 05 fb ff ff       	call   c010482c <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0104d27:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0104d2e:	00 
c0104d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d32:	89 04 24             	mov    %eax,(%esp)
c0104d35:	e8 fb fc ff ff       	call   c0104a35 <slob_free>
				return;
c0104d3a:	eb 3a                	jmp    c0104d76 <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0104d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d3f:	83 c0 08             	add    $0x8,%eax
c0104d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d48:	8b 40 08             	mov    0x8(%eax),%eax
c0104d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d52:	75 9e                	jne    c0104cf2 <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0104d54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d57:	89 04 24             	mov    %eax,(%esp)
c0104d5a:	e8 74 f9 ff ff       	call   c01046d3 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0104d5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d62:	83 e8 08             	sub    $0x8,%eax
c0104d65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104d6c:	00 
c0104d6d:	89 04 24             	mov    %eax,(%esp)
c0104d70:	e8 c0 fc ff ff       	call   c0104a35 <slob_free>
	return;
c0104d75:	90                   	nop
}
c0104d76:	c9                   	leave  
c0104d77:	c3                   	ret    

c0104d78 <ksize>:


unsigned int ksize(const void *block)
{
c0104d78:	55                   	push   %ebp
c0104d79:	89 e5                	mov    %esp,%ebp
c0104d7b:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0104d7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104d82:	75 07                	jne    c0104d8b <ksize+0x13>
		return 0;
c0104d84:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d89:	eb 6b                	jmp    c0104df6 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0104d8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d8e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104d93:	85 c0                	test   %eax,%eax
c0104d95:	75 54                	jne    c0104deb <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0104d97:	e8 0d f9 ff ff       	call   c01046a9 <__intr_save>
c0104d9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0104d9f:	a1 c4 ce 19 c0       	mov    0xc019cec4,%eax
c0104da4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104da7:	eb 31                	jmp    c0104dda <ksize+0x62>
			if (bb->pages == block) {
c0104da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dac:	8b 40 04             	mov    0x4(%eax),%eax
c0104daf:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104db2:	75 1d                	jne    c0104dd1 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0104db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104db7:	89 04 24             	mov    %eax,(%esp)
c0104dba:	e8 14 f9 ff ff       	call   c01046d3 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0104dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dc2:	8b 00                	mov    (%eax),%eax
c0104dc4:	ba 00 10 00 00       	mov    $0x1000,%edx
c0104dc9:	89 c1                	mov    %eax,%ecx
c0104dcb:	d3 e2                	shl    %cl,%edx
c0104dcd:	89 d0                	mov    %edx,%eax
c0104dcf:	eb 25                	jmp    c0104df6 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0104dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dd4:	8b 40 08             	mov    0x8(%eax),%eax
c0104dd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104dde:	75 c9                	jne    c0104da9 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0104de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104de3:	89 04 24             	mov    %eax,(%esp)
c0104de6:	e8 e8 f8 ff ff       	call   c01046d3 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0104deb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dee:	83 e8 08             	sub    $0x8,%eax
c0104df1:	8b 00                	mov    (%eax),%eax
c0104df3:	c1 e0 03             	shl    $0x3,%eax
}
c0104df6:	c9                   	leave  
c0104df7:	c3                   	ret    

c0104df8 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104df8:	55                   	push   %ebp
c0104df9:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104dfb:	8b 55 08             	mov    0x8(%ebp),%edx
c0104dfe:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104e03:	29 c2                	sub    %eax,%edx
c0104e05:	89 d0                	mov    %edx,%eax
c0104e07:	c1 f8 05             	sar    $0x5,%eax
}
c0104e0a:	5d                   	pop    %ebp
c0104e0b:	c3                   	ret    

c0104e0c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104e0c:	55                   	push   %ebp
c0104e0d:	89 e5                	mov    %esp,%ebp
c0104e0f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104e12:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e15:	89 04 24             	mov    %eax,(%esp)
c0104e18:	e8 db ff ff ff       	call   c0104df8 <page2ppn>
c0104e1d:	c1 e0 0c             	shl    $0xc,%eax
}
c0104e20:	c9                   	leave  
c0104e21:	c3                   	ret    

c0104e22 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104e22:	55                   	push   %ebp
c0104e23:	89 e5                	mov    %esp,%ebp
c0104e25:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104e28:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e2b:	c1 e8 0c             	shr    $0xc,%eax
c0104e2e:	89 c2                	mov    %eax,%edx
c0104e30:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104e35:	39 c2                	cmp    %eax,%edx
c0104e37:	72 1c                	jb     c0104e55 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104e39:	c7 44 24 08 14 cc 10 	movl   $0xc010cc14,0x8(%esp)
c0104e40:	c0 
c0104e41:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0104e48:	00 
c0104e49:	c7 04 24 33 cc 10 c0 	movl   $0xc010cc33,(%esp)
c0104e50:	e8 c0 bf ff ff       	call   c0100e15 <__panic>
    }
    return &pages[PPN(pa)];
c0104e55:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0104e5a:	8b 55 08             	mov    0x8(%ebp),%edx
c0104e5d:	c1 ea 0c             	shr    $0xc,%edx
c0104e60:	c1 e2 05             	shl    $0x5,%edx
c0104e63:	01 d0                	add    %edx,%eax
}
c0104e65:	c9                   	leave  
c0104e66:	c3                   	ret    

c0104e67 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104e67:	55                   	push   %ebp
c0104e68:	89 e5                	mov    %esp,%ebp
c0104e6a:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e70:	89 04 24             	mov    %eax,(%esp)
c0104e73:	e8 94 ff ff ff       	call   c0104e0c <page2pa>
c0104e78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e7e:	c1 e8 0c             	shr    $0xc,%eax
c0104e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e84:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0104e89:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104e8c:	72 23                	jb     c0104eb1 <page2kva+0x4a>
c0104e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e91:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e95:	c7 44 24 08 44 cc 10 	movl   $0xc010cc44,0x8(%esp)
c0104e9c:	c0 
c0104e9d:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0104ea4:	00 
c0104ea5:	c7 04 24 33 cc 10 c0 	movl   $0xc010cc33,(%esp)
c0104eac:	e8 64 bf ff ff       	call   c0100e15 <__panic>
c0104eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104eb9:	c9                   	leave  
c0104eba:	c3                   	ret    

c0104ebb <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0104ebb:	55                   	push   %ebp
c0104ebc:	89 e5                	mov    %esp,%ebp
c0104ebe:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ec4:	83 e0 01             	and    $0x1,%eax
c0104ec7:	85 c0                	test   %eax,%eax
c0104ec9:	75 1c                	jne    c0104ee7 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0104ecb:	c7 44 24 08 68 cc 10 	movl   $0xc010cc68,0x8(%esp)
c0104ed2:	c0 
c0104ed3:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104eda:	00 
c0104edb:	c7 04 24 33 cc 10 c0 	movl   $0xc010cc33,(%esp)
c0104ee2:	e8 2e bf ff ff       	call   c0100e15 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104ee7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104eea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104eef:	89 04 24             	mov    %eax,(%esp)
c0104ef2:	e8 2b ff ff ff       	call   c0104e22 <pa2page>
}
c0104ef7:	c9                   	leave  
c0104ef8:	c3                   	ret    

c0104ef9 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104ef9:	55                   	push   %ebp
c0104efa:	89 e5                	mov    %esp,%ebp
c0104efc:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104eff:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f07:	89 04 24             	mov    %eax,(%esp)
c0104f0a:	e8 13 ff ff ff       	call   c0104e22 <pa2page>
}
c0104f0f:	c9                   	leave  
c0104f10:	c3                   	ret    

c0104f11 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104f11:	55                   	push   %ebp
c0104f12:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f17:	8b 00                	mov    (%eax),%eax
}
c0104f19:	5d                   	pop    %ebp
c0104f1a:	c3                   	ret    

c0104f1b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104f1b:	55                   	push   %ebp
c0104f1c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104f1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f21:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104f24:	89 10                	mov    %edx,(%eax)
}
c0104f26:	5d                   	pop    %ebp
c0104f27:	c3                   	ret    

c0104f28 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104f28:	55                   	push   %ebp
c0104f29:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f2e:	8b 00                	mov    (%eax),%eax
c0104f30:	8d 50 01             	lea    0x1(%eax),%edx
c0104f33:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f36:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104f38:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f3b:	8b 00                	mov    (%eax),%eax
}
c0104f3d:	5d                   	pop    %ebp
c0104f3e:	c3                   	ret    

c0104f3f <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0104f3f:	55                   	push   %ebp
c0104f40:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104f42:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f45:	8b 00                	mov    (%eax),%eax
c0104f47:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f4d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f52:	8b 00                	mov    (%eax),%eax
}
c0104f54:	5d                   	pop    %ebp
c0104f55:	c3                   	ret    

c0104f56 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0104f56:	55                   	push   %ebp
c0104f57:	89 e5                	mov    %esp,%ebp
c0104f59:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104f5c:	9c                   	pushf  
c0104f5d:	58                   	pop    %eax
c0104f5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104f64:	25 00 02 00 00       	and    $0x200,%eax
c0104f69:	85 c0                	test   %eax,%eax
c0104f6b:	74 0c                	je     c0104f79 <__intr_save+0x23>
        intr_disable();
c0104f6d:	e8 fb d0 ff ff       	call   c010206d <intr_disable>
        return 1;
c0104f72:	b8 01 00 00 00       	mov    $0x1,%eax
c0104f77:	eb 05                	jmp    c0104f7e <__intr_save+0x28>
    }
    return 0;
c0104f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104f7e:	c9                   	leave  
c0104f7f:	c3                   	ret    

c0104f80 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104f80:	55                   	push   %ebp
c0104f81:	89 e5                	mov    %esp,%ebp
c0104f83:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104f86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f8a:	74 05                	je     c0104f91 <__intr_restore+0x11>
        intr_enable();
c0104f8c:	e8 d6 d0 ff ff       	call   c0102067 <intr_enable>
    }
}
c0104f91:	c9                   	leave  
c0104f92:	c3                   	ret    

c0104f93 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0104f93:	55                   	push   %ebp
c0104f94:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0104f96:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f99:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0104f9c:	b8 23 00 00 00       	mov    $0x23,%eax
c0104fa1:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0104fa3:	b8 23 00 00 00       	mov    $0x23,%eax
c0104fa8:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0104faa:	b8 10 00 00 00       	mov    $0x10,%eax
c0104faf:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0104fb1:	b8 10 00 00 00       	mov    $0x10,%eax
c0104fb6:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0104fb8:	b8 10 00 00 00       	mov    $0x10,%eax
c0104fbd:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0104fbf:	ea c6 4f 10 c0 08 00 	ljmp   $0x8,$0xc0104fc6
}
c0104fc6:	5d                   	pop    %ebp
c0104fc7:	c3                   	ret    

c0104fc8 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0104fc8:	55                   	push   %ebp
c0104fc9:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0104fcb:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fce:	a3 04 cf 19 c0       	mov    %eax,0xc019cf04
}
c0104fd3:	5d                   	pop    %ebp
c0104fd4:	c3                   	ret    

c0104fd5 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104fd5:	55                   	push   %ebp
c0104fd6:	89 e5                	mov    %esp,%ebp
c0104fd8:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0104fdb:	b8 00 a0 12 c0       	mov    $0xc012a000,%eax
c0104fe0:	89 04 24             	mov    %eax,(%esp)
c0104fe3:	e8 e0 ff ff ff       	call   c0104fc8 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104fe8:	66 c7 05 08 cf 19 c0 	movw   $0x10,0xc019cf08
c0104fef:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104ff1:	66 c7 05 48 aa 12 c0 	movw   $0x68,0xc012aa48
c0104ff8:	68 00 
c0104ffa:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c0104fff:	66 a3 4a aa 12 c0    	mov    %ax,0xc012aa4a
c0105005:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c010500a:	c1 e8 10             	shr    $0x10,%eax
c010500d:	a2 4c aa 12 c0       	mov    %al,0xc012aa4c
c0105012:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0105019:	83 e0 f0             	and    $0xfffffff0,%eax
c010501c:	83 c8 09             	or     $0x9,%eax
c010501f:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0105024:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c010502b:	83 e0 ef             	and    $0xffffffef,%eax
c010502e:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0105033:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c010503a:	83 e0 9f             	and    $0xffffff9f,%eax
c010503d:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0105042:	0f b6 05 4d aa 12 c0 	movzbl 0xc012aa4d,%eax
c0105049:	83 c8 80             	or     $0xffffff80,%eax
c010504c:	a2 4d aa 12 c0       	mov    %al,0xc012aa4d
c0105051:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105058:	83 e0 f0             	and    $0xfffffff0,%eax
c010505b:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c0105060:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105067:	83 e0 ef             	and    $0xffffffef,%eax
c010506a:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c010506f:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105076:	83 e0 df             	and    $0xffffffdf,%eax
c0105079:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c010507e:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105085:	83 c8 40             	or     $0x40,%eax
c0105088:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c010508d:	0f b6 05 4e aa 12 c0 	movzbl 0xc012aa4e,%eax
c0105094:	83 e0 7f             	and    $0x7f,%eax
c0105097:	a2 4e aa 12 c0       	mov    %al,0xc012aa4e
c010509c:	b8 00 cf 19 c0       	mov    $0xc019cf00,%eax
c01050a1:	c1 e8 18             	shr    $0x18,%eax
c01050a4:	a2 4f aa 12 c0       	mov    %al,0xc012aa4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01050a9:	c7 04 24 50 aa 12 c0 	movl   $0xc012aa50,(%esp)
c01050b0:	e8 de fe ff ff       	call   c0104f93 <lgdt>
c01050b5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01050bb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01050bf:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01050c2:	c9                   	leave  
c01050c3:	c3                   	ret    

c01050c4 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01050c4:	55                   	push   %ebp
c01050c5:	89 e5                	mov    %esp,%ebp
c01050c7:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01050ca:	c7 05 c4 ef 19 c0 08 	movl   $0xc010cb08,0xc019efc4
c01050d1:	cb 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01050d4:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c01050d9:	8b 00                	mov    (%eax),%eax
c01050db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050df:	c7 04 24 94 cc 10 c0 	movl   $0xc010cc94,(%esp)
c01050e6:	e8 68 b2 ff ff       	call   c0100353 <cprintf>
    pmm_manager->init();
c01050eb:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c01050f0:	8b 40 04             	mov    0x4(%eax),%eax
c01050f3:	ff d0                	call   *%eax
}
c01050f5:	c9                   	leave  
c01050f6:	c3                   	ret    

c01050f7 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory
static void
init_memmap(struct Page *base, size_t n) {
c01050f7:	55                   	push   %ebp
c01050f8:	89 e5                	mov    %esp,%ebp
c01050fa:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c01050fd:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105102:	8b 40 08             	mov    0x8(%eax),%eax
c0105105:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105108:	89 54 24 04          	mov    %edx,0x4(%esp)
c010510c:	8b 55 08             	mov    0x8(%ebp),%edx
c010510f:	89 14 24             	mov    %edx,(%esp)
c0105112:	ff d0                	call   *%eax
}
c0105114:	c9                   	leave  
c0105115:	c3                   	ret    

c0105116 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory
struct Page *
alloc_pages(size_t n) {
c0105116:	55                   	push   %ebp
c0105117:	89 e5                	mov    %esp,%ebp
c0105119:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c010511c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;

    while (1)
    {
         local_intr_save(intr_flag);
c0105123:	e8 2e fe ff ff       	call   c0104f56 <__intr_save>
c0105128:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010512b:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105130:	8b 40 0c             	mov    0xc(%eax),%eax
c0105133:	8b 55 08             	mov    0x8(%ebp),%edx
c0105136:	89 14 24             	mov    %edx,(%esp)
c0105139:	ff d0                	call   *%eax
c010513b:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010513e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105141:	89 04 24             	mov    %eax,(%esp)
c0105144:	e8 37 fe ff ff       	call   c0104f80 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0105149:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010514d:	75 2d                	jne    c010517c <alloc_pages+0x66>
c010514f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0105153:	77 27                	ja     c010517c <alloc_pages+0x66>
c0105155:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c010515a:	85 c0                	test   %eax,%eax
c010515c:	74 1e                	je     c010517c <alloc_pages+0x66>

         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c010515e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105161:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0105166:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010516d:	00 
c010516e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105172:	89 04 24             	mov    %eax,(%esp)
c0105175:	e8 ac 1d 00 00       	call   c0106f26 <swap_out>
    }
c010517a:	eb a7                	jmp    c0105123 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c010517c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010517f:	c9                   	leave  
c0105180:	c3                   	ret    

c0105181 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void
free_pages(struct Page *base, size_t n) {
c0105181:	55                   	push   %ebp
c0105182:	89 e5                	mov    %esp,%ebp
c0105184:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0105187:	e8 ca fd ff ff       	call   c0104f56 <__intr_save>
c010518c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c010518f:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c0105194:	8b 40 10             	mov    0x10(%eax),%eax
c0105197:	8b 55 0c             	mov    0xc(%ebp),%edx
c010519a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010519e:	8b 55 08             	mov    0x8(%ebp),%edx
c01051a1:	89 14 24             	mov    %edx,(%esp)
c01051a4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01051a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051a9:	89 04 24             	mov    %eax,(%esp)
c01051ac:	e8 cf fd ff ff       	call   c0104f80 <__intr_restore>
}
c01051b1:	c9                   	leave  
c01051b2:	c3                   	ret    

c01051b3 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
//of current free memory
size_t
nr_free_pages(void) {
c01051b3:	55                   	push   %ebp
c01051b4:	89 e5                	mov    %esp,%ebp
c01051b6:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01051b9:	e8 98 fd ff ff       	call   c0104f56 <__intr_save>
c01051be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01051c1:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c01051c6:	8b 40 14             	mov    0x14(%eax),%eax
c01051c9:	ff d0                	call   *%eax
c01051cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01051ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051d1:	89 04 24             	mov    %eax,(%esp)
c01051d4:	e8 a7 fd ff ff       	call   c0104f80 <__intr_restore>
    return ret;
c01051d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01051dc:	c9                   	leave  
c01051dd:	c3                   	ret    

c01051de <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01051de:	55                   	push   %ebp
c01051df:	89 e5                	mov    %esp,%ebp
c01051e1:	57                   	push   %edi
c01051e2:	56                   	push   %esi
c01051e3:	53                   	push   %ebx
c01051e4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01051ea:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01051f1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01051f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01051ff:	c7 04 24 ab cc 10 c0 	movl   $0xc010ccab,(%esp)
c0105206:	e8 48 b1 ff ff       	call   c0100353 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010520b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105212:	e9 15 01 00 00       	jmp    c010532c <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105217:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010521a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010521d:	89 d0                	mov    %edx,%eax
c010521f:	c1 e0 02             	shl    $0x2,%eax
c0105222:	01 d0                	add    %edx,%eax
c0105224:	c1 e0 02             	shl    $0x2,%eax
c0105227:	01 c8                	add    %ecx,%eax
c0105229:	8b 50 08             	mov    0x8(%eax),%edx
c010522c:	8b 40 04             	mov    0x4(%eax),%eax
c010522f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0105232:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0105235:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105238:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010523b:	89 d0                	mov    %edx,%eax
c010523d:	c1 e0 02             	shl    $0x2,%eax
c0105240:	01 d0                	add    %edx,%eax
c0105242:	c1 e0 02             	shl    $0x2,%eax
c0105245:	01 c8                	add    %ecx,%eax
c0105247:	8b 48 0c             	mov    0xc(%eax),%ecx
c010524a:	8b 58 10             	mov    0x10(%eax),%ebx
c010524d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105250:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105253:	01 c8                	add    %ecx,%eax
c0105255:	11 da                	adc    %ebx,%edx
c0105257:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010525a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010525d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105260:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105263:	89 d0                	mov    %edx,%eax
c0105265:	c1 e0 02             	shl    $0x2,%eax
c0105268:	01 d0                	add    %edx,%eax
c010526a:	c1 e0 02             	shl    $0x2,%eax
c010526d:	01 c8                	add    %ecx,%eax
c010526f:	83 c0 14             	add    $0x14,%eax
c0105272:	8b 00                	mov    (%eax),%eax
c0105274:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c010527a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010527d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105280:	83 c0 ff             	add    $0xffffffff,%eax
c0105283:	83 d2 ff             	adc    $0xffffffff,%edx
c0105286:	89 c6                	mov    %eax,%esi
c0105288:	89 d7                	mov    %edx,%edi
c010528a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010528d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105290:	89 d0                	mov    %edx,%eax
c0105292:	c1 e0 02             	shl    $0x2,%eax
c0105295:	01 d0                	add    %edx,%eax
c0105297:	c1 e0 02             	shl    $0x2,%eax
c010529a:	01 c8                	add    %ecx,%eax
c010529c:	8b 48 0c             	mov    0xc(%eax),%ecx
c010529f:	8b 58 10             	mov    0x10(%eax),%ebx
c01052a2:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01052a8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01052ac:	89 74 24 14          	mov    %esi,0x14(%esp)
c01052b0:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01052b4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01052b7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01052ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01052be:	89 54 24 10          	mov    %edx,0x10(%esp)
c01052c2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01052c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01052ca:	c7 04 24 b8 cc 10 c0 	movl   $0xc010ccb8,(%esp)
c01052d1:	e8 7d b0 ff ff       	call   c0100353 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01052d6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01052d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01052dc:	89 d0                	mov    %edx,%eax
c01052de:	c1 e0 02             	shl    $0x2,%eax
c01052e1:	01 d0                	add    %edx,%eax
c01052e3:	c1 e0 02             	shl    $0x2,%eax
c01052e6:	01 c8                	add    %ecx,%eax
c01052e8:	83 c0 14             	add    $0x14,%eax
c01052eb:	8b 00                	mov    (%eax),%eax
c01052ed:	83 f8 01             	cmp    $0x1,%eax
c01052f0:	75 36                	jne    c0105328 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c01052f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01052f5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052f8:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c01052fb:	77 2b                	ja     c0105328 <page_init+0x14a>
c01052fd:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0105300:	72 05                	jb     c0105307 <page_init+0x129>
c0105302:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0105305:	73 21                	jae    c0105328 <page_init+0x14a>
c0105307:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010530b:	77 1b                	ja     c0105328 <page_init+0x14a>
c010530d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105311:	72 09                	jb     c010531c <page_init+0x13e>
c0105313:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c010531a:	77 0c                	ja     c0105328 <page_init+0x14a>
                maxpa = end;
c010531c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010531f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105322:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105325:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0105328:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010532c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010532f:	8b 00                	mov    (%eax),%eax
c0105331:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105334:	0f 8f dd fe ff ff    	jg     c0105217 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010533a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010533e:	72 1d                	jb     c010535d <page_init+0x17f>
c0105340:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105344:	77 09                	ja     c010534f <page_init+0x171>
c0105346:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010534d:	76 0e                	jbe    c010535d <page_init+0x17f>
        maxpa = KMEMSIZE;
c010534f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0105356:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010535d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105360:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105363:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105367:	c1 ea 0c             	shr    $0xc,%edx
c010536a:	a3 e0 ce 19 c0       	mov    %eax,0xc019cee0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010536f:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0105376:	b8 b8 f0 19 c0       	mov    $0xc019f0b8,%eax
c010537b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010537e:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105381:	01 d0                	add    %edx,%eax
c0105383:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0105386:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105389:	ba 00 00 00 00       	mov    $0x0,%edx
c010538e:	f7 75 ac             	divl   -0x54(%ebp)
c0105391:	89 d0                	mov    %edx,%eax
c0105393:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105396:	29 c2                	sub    %eax,%edx
c0105398:	89 d0                	mov    %edx,%eax
c010539a:	a3 cc ef 19 c0       	mov    %eax,0xc019efcc

    for (i = 0; i < npage; i ++) {
c010539f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01053a6:	eb 27                	jmp    c01053cf <page_init+0x1f1>
        SetPageReserved(pages + i);
c01053a8:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01053ad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053b0:	c1 e2 05             	shl    $0x5,%edx
c01053b3:	01 d0                	add    %edx,%eax
c01053b5:	83 c0 04             	add    $0x4,%eax
c01053b8:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01053bf:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01053c2:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01053c5:	8b 55 90             	mov    -0x70(%ebp),%edx
c01053c8:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01053cb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01053cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01053d2:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01053d7:	39 c2                	cmp    %eax,%edx
c01053d9:	72 cd                	jb     c01053a8 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01053db:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01053e0:	c1 e0 05             	shl    $0x5,%eax
c01053e3:	89 c2                	mov    %eax,%edx
c01053e5:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01053ea:	01 d0                	add    %edx,%eax
c01053ec:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01053ef:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c01053f6:	77 23                	ja     c010541b <page_init+0x23d>
c01053f8:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01053fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01053ff:	c7 44 24 08 e8 cc 10 	movl   $0xc010cce8,0x8(%esp)
c0105406:	c0 
c0105407:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010540e:	00 
c010540f:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105416:	e8 fa b9 ff ff       	call   c0100e15 <__panic>
c010541b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010541e:	05 00 00 00 40       	add    $0x40000000,%eax
c0105423:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0105426:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010542d:	e9 74 01 00 00       	jmp    c01055a6 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0105432:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105435:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105438:	89 d0                	mov    %edx,%eax
c010543a:	c1 e0 02             	shl    $0x2,%eax
c010543d:	01 d0                	add    %edx,%eax
c010543f:	c1 e0 02             	shl    $0x2,%eax
c0105442:	01 c8                	add    %ecx,%eax
c0105444:	8b 50 08             	mov    0x8(%eax),%edx
c0105447:	8b 40 04             	mov    0x4(%eax),%eax
c010544a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010544d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105450:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0105453:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105456:	89 d0                	mov    %edx,%eax
c0105458:	c1 e0 02             	shl    $0x2,%eax
c010545b:	01 d0                	add    %edx,%eax
c010545d:	c1 e0 02             	shl    $0x2,%eax
c0105460:	01 c8                	add    %ecx,%eax
c0105462:	8b 48 0c             	mov    0xc(%eax),%ecx
c0105465:	8b 58 10             	mov    0x10(%eax),%ebx
c0105468:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010546b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010546e:	01 c8                	add    %ecx,%eax
c0105470:	11 da                	adc    %ebx,%edx
c0105472:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105475:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0105478:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010547b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010547e:	89 d0                	mov    %edx,%eax
c0105480:	c1 e0 02             	shl    $0x2,%eax
c0105483:	01 d0                	add    %edx,%eax
c0105485:	c1 e0 02             	shl    $0x2,%eax
c0105488:	01 c8                	add    %ecx,%eax
c010548a:	83 c0 14             	add    $0x14,%eax
c010548d:	8b 00                	mov    (%eax),%eax
c010548f:	83 f8 01             	cmp    $0x1,%eax
c0105492:	0f 85 0a 01 00 00    	jne    c01055a2 <page_init+0x3c4>
            if (begin < freemem) {
c0105498:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010549b:	ba 00 00 00 00       	mov    $0x0,%edx
c01054a0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054a3:	72 17                	jb     c01054bc <page_init+0x2de>
c01054a5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01054a8:	77 05                	ja     c01054af <page_init+0x2d1>
c01054aa:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01054ad:	76 0d                	jbe    c01054bc <page_init+0x2de>
                begin = freemem;
c01054af:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01054b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01054b5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01054bc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01054c0:	72 1d                	jb     c01054df <page_init+0x301>
c01054c2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01054c6:	77 09                	ja     c01054d1 <page_init+0x2f3>
c01054c8:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01054cf:	76 0e                	jbe    c01054df <page_init+0x301>
                end = KMEMSIZE;
c01054d1:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01054d8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01054df:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01054e2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054e5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054e8:	0f 87 b4 00 00 00    	ja     c01055a2 <page_init+0x3c4>
c01054ee:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01054f1:	72 09                	jb     c01054fc <page_init+0x31e>
c01054f3:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01054f6:	0f 83 a6 00 00 00    	jae    c01055a2 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c01054fc:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0105503:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105506:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105509:	01 d0                	add    %edx,%eax
c010550b:	83 e8 01             	sub    $0x1,%eax
c010550e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105511:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105514:	ba 00 00 00 00       	mov    $0x0,%edx
c0105519:	f7 75 9c             	divl   -0x64(%ebp)
c010551c:	89 d0                	mov    %edx,%eax
c010551e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0105521:	29 c2                	sub    %eax,%edx
c0105523:	89 d0                	mov    %edx,%eax
c0105525:	ba 00 00 00 00       	mov    $0x0,%edx
c010552a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010552d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0105530:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105533:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0105536:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105539:	ba 00 00 00 00       	mov    $0x0,%edx
c010553e:	89 c7                	mov    %eax,%edi
c0105540:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0105546:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0105549:	89 d0                	mov    %edx,%eax
c010554b:	83 e0 00             	and    $0x0,%eax
c010554e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0105551:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105554:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105557:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010555a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c010555d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105560:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105563:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0105566:	77 3a                	ja     c01055a2 <page_init+0x3c4>
c0105568:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010556b:	72 05                	jb     c0105572 <page_init+0x394>
c010556d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105570:	73 30                	jae    c01055a2 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0105572:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0105575:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0105578:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010557b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010557e:	29 c8                	sub    %ecx,%eax
c0105580:	19 da                	sbb    %ebx,%edx
c0105582:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0105586:	c1 ea 0c             	shr    $0xc,%edx
c0105589:	89 c3                	mov    %eax,%ebx
c010558b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010558e:	89 04 24             	mov    %eax,(%esp)
c0105591:	e8 8c f8 ff ff       	call   c0104e22 <pa2page>
c0105596:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010559a:	89 04 24             	mov    %eax,(%esp)
c010559d:	e8 55 fb ff ff       	call   c01050f7 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01055a2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01055a6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01055a9:	8b 00                	mov    (%eax),%eax
c01055ab:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01055ae:	0f 8f 7e fe ff ff    	jg     c0105432 <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01055b4:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01055ba:	5b                   	pop    %ebx
c01055bb:	5e                   	pop    %esi
c01055bc:	5f                   	pop    %edi
c01055bd:	5d                   	pop    %ebp
c01055be:	c3                   	ret    

c01055bf <enable_paging>:

static void
enable_paging(void) {
c01055bf:	55                   	push   %ebp
c01055c0:	89 e5                	mov    %esp,%ebp
c01055c2:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c01055c5:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c01055ca:	89 45 f8             	mov    %eax,-0x8(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01055cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01055d0:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c01055d3:	0f 20 c0             	mov    %cr0,%eax
c01055d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c01055d9:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c01055dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c01055df:	81 4d fc 2f 00 05 80 	orl    $0x8005002f,-0x4(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c01055e6:	83 65 fc f3          	andl   $0xfffffff3,-0x4(%ebp)
c01055ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01055ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c01055f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055f3:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c01055f6:	c9                   	leave  
c01055f7:	c3                   	ret    

c01055f8 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01055f8:	55                   	push   %ebp
c01055f9:	89 e5                	mov    %esp,%ebp
c01055fb:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01055fe:	8b 45 14             	mov    0x14(%ebp),%eax
c0105601:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105604:	31 d0                	xor    %edx,%eax
c0105606:	25 ff 0f 00 00       	and    $0xfff,%eax
c010560b:	85 c0                	test   %eax,%eax
c010560d:	74 24                	je     c0105633 <boot_map_segment+0x3b>
c010560f:	c7 44 24 0c 1a cd 10 	movl   $0xc010cd1a,0xc(%esp)
c0105616:	c0 
c0105617:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010561e:	c0 
c010561f:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0105626:	00 
c0105627:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010562e:	e8 e2 b7 ff ff       	call   c0100e15 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0105633:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010563a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010563d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105642:	89 c2                	mov    %eax,%edx
c0105644:	8b 45 10             	mov    0x10(%ebp),%eax
c0105647:	01 c2                	add    %eax,%edx
c0105649:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010564c:	01 d0                	add    %edx,%eax
c010564e:	83 e8 01             	sub    $0x1,%eax
c0105651:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105654:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105657:	ba 00 00 00 00       	mov    $0x0,%edx
c010565c:	f7 75 f0             	divl   -0x10(%ebp)
c010565f:	89 d0                	mov    %edx,%eax
c0105661:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105664:	29 c2                	sub    %eax,%edx
c0105666:	89 d0                	mov    %edx,%eax
c0105668:	c1 e8 0c             	shr    $0xc,%eax
c010566b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010566e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105671:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105674:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105677:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010567c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010567f:	8b 45 14             	mov    0x14(%ebp),%eax
c0105682:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105688:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010568d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0105690:	eb 6b                	jmp    c01056fd <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0105692:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105699:	00 
c010569a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010569d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01056a4:	89 04 24             	mov    %eax,(%esp)
c01056a7:	e8 d1 01 00 00       	call   c010587d <get_pte>
c01056ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01056af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01056b3:	75 24                	jne    c01056d9 <boot_map_segment+0xe1>
c01056b5:	c7 44 24 0c 46 cd 10 	movl   $0xc010cd46,0xc(%esp)
c01056bc:	c0 
c01056bd:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01056c4:	c0 
c01056c5:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01056cc:	00 
c01056cd:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01056d4:	e8 3c b7 ff ff       	call   c0100e15 <__panic>
        *ptep = pa | PTE_P | perm;
c01056d9:	8b 45 18             	mov    0x18(%ebp),%eax
c01056dc:	8b 55 14             	mov    0x14(%ebp),%edx
c01056df:	09 d0                	or     %edx,%eax
c01056e1:	83 c8 01             	or     $0x1,%eax
c01056e4:	89 c2                	mov    %eax,%edx
c01056e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056e9:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01056eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01056ef:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01056f6:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01056fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105701:	75 8f                	jne    c0105692 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0105703:	c9                   	leave  
c0105704:	c3                   	ret    

c0105705 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1)
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0105705:	55                   	push   %ebp
c0105706:	89 e5                	mov    %esp,%ebp
c0105708:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010570b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105712:	e8 ff f9 ff ff       	call   c0105116 <alloc_pages>
c0105717:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010571a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010571e:	75 1c                	jne    c010573c <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0105720:	c7 44 24 08 53 cd 10 	movl   $0xc010cd53,0x8(%esp)
c0105727:	c0 
c0105728:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010572f:	00 
c0105730:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105737:	e8 d9 b6 ff ff       	call   c0100e15 <__panic>
    }
    return page2kva(p);
c010573c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010573f:	89 04 24             	mov    %eax,(%esp)
c0105742:	e8 20 f7 ff ff       	call   c0104e67 <page2kva>
}
c0105747:	c9                   	leave  
c0105748:	c3                   	ret    

c0105749 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0105749:	55                   	push   %ebp
c010574a:	89 e5                	mov    %esp,%ebp
c010574c:	83 ec 38             	sub    $0x38,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size).
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory.
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010574f:	e8 70 f9 ff ff       	call   c01050c4 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0105754:	e8 85 fa ff ff       	call   c01051de <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0105759:	e8 6d 09 00 00       	call   c01060cb <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c010575e:	e8 a2 ff ff ff       	call   c0105705 <boot_alloc_page>
c0105763:	a3 e4 ce 19 c0       	mov    %eax,0xc019cee4
    memset(boot_pgdir, 0, PGSIZE);
c0105768:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010576d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105774:	00 
c0105775:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010577c:	00 
c010577d:	89 04 24             	mov    %eax,(%esp)
c0105780:	e8 67 65 00 00       	call   c010bcec <memset>
    boot_cr3 = PADDR(boot_pgdir);
c0105785:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010578a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010578d:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105794:	77 23                	ja     c01057b9 <pmm_init+0x70>
c0105796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105799:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010579d:	c7 44 24 08 e8 cc 10 	movl   $0xc010cce8,0x8(%esp)
c01057a4:	c0 
c01057a5:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c01057ac:	00 
c01057ad:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01057b4:	e8 5c b6 ff ff       	call   c0100e15 <__panic>
c01057b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057bc:	05 00 00 00 40       	add    $0x40000000,%eax
c01057c1:	a3 c8 ef 19 c0       	mov    %eax,0xc019efc8

    check_pgdir();
c01057c6:	e8 1e 09 00 00       	call   c01060e9 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01057cb:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01057d0:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01057d6:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01057db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057de:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01057e5:	77 23                	ja     c010580a <pmm_init+0xc1>
c01057e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01057ee:	c7 44 24 08 e8 cc 10 	movl   $0xc010cce8,0x8(%esp)
c01057f5:	c0 
c01057f6:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c01057fd:	00 
c01057fe:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105805:	e8 0b b6 ff ff       	call   c0100e15 <__panic>
c010580a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010580d:	05 00 00 00 40       	add    $0x40000000,%eax
c0105812:	83 c8 03             	or     $0x3,%eax
c0105815:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0105817:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010581c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0105823:	00 
c0105824:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010582b:	00 
c010582c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0105833:	38 
c0105834:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010583b:	c0 
c010583c:	89 04 24             	mov    %eax,(%esp)
c010583f:	e8 b4 fd ff ff       	call   c01055f8 <boot_map_segment>

    //temporary map:
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c0105844:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0105849:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c010584f:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c0105855:	89 10                	mov    %edx,(%eax)

    enable_paging();
c0105857:	e8 63 fd ff ff       	call   c01055bf <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010585c:	e8 74 f7 ff ff       	call   c0104fd5 <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0105861:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0105866:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010586c:	e8 13 0f 00 00       	call   c0106784 <check_boot_pgdir>

    print_pgdir();
c0105871:	e8 9b 13 00 00       	call   c0106c11 <print_pgdir>

    kmalloc_init();
c0105876:	e8 e6 f2 ff ff       	call   c0104b61 <kmalloc_init>

}
c010587b:	c9                   	leave  
c010587c:	c3                   	ret    

c010587d <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010587d:	55                   	push   %ebp
c010587e:	89 e5                	mov    %esp,%ebp
c0105880:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pde = pgdir + PDX(la); // get the entry
c0105883:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105886:	c1 e8 16             	shr    $0x16,%eax
c0105889:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105890:	8b 45 08             	mov    0x8(%ebp),%eax
c0105893:	01 d0                	add    %edx,%eax
c0105895:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (!(*pde & PTE_P)) {
c0105898:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010589b:	8b 00                	mov    (%eax),%eax
c010589d:	83 e0 01             	and    $0x1,%eax
c01058a0:	85 c0                	test   %eax,%eax
c01058a2:	0f 85 b6 00 00 00    	jne    c010595e <get_pte+0xe1>
        //if not present
        struct Page *p = NULL;
c01058a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        if (create) p = alloc_page();
c01058af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01058b3:	74 0f                	je     c01058c4 <get_pte+0x47>
c01058b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058bc:	e8 55 f8 ff ff       	call   c0105116 <alloc_pages>
c01058c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (!p) return NULL;
c01058c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058c8:	75 0a                	jne    c01058d4 <get_pte+0x57>
c01058ca:	b8 00 00 00 00       	mov    $0x0,%eax
c01058cf:	e9 ef 00 00 00       	jmp    c01059c3 <get_pte+0x146>
        set_page_ref(p, 1);
c01058d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01058db:	00 
c01058dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058df:	89 04 24             	mov    %eax,(%esp)
c01058e2:	e8 34 f6 ff ff       	call   c0104f1b <set_page_ref>
        uintptr_t pa = page2pa(p);
c01058e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058ea:	89 04 24             	mov    %eax,(%esp)
c01058ed:	e8 1a f5 ff ff       	call   c0104e0c <page2pa>
c01058f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01058f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01058fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01058fe:	c1 e8 0c             	shr    $0xc,%eax
c0105901:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105904:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0105909:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010590c:	72 23                	jb     c0105931 <get_pte+0xb4>
c010590e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105911:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105915:	c7 44 24 08 44 cc 10 	movl   $0xc010cc44,0x8(%esp)
c010591c:	c0 
c010591d:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
c0105924:	00 
c0105925:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010592c:	e8 e4 b4 ff ff       	call   c0100e15 <__panic>
c0105931:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105934:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105939:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105940:	00 
c0105941:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105948:	00 
c0105949:	89 04 24             	mov    %eax,(%esp)
c010594c:	e8 9b 63 00 00       	call   c010bcec <memset>
        *pde = pa | PTE_U | PTE_W | PTE_P;
c0105951:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105954:	83 c8 07             	or     $0x7,%eax
c0105957:	89 c2                	mov    %eax,%edx
c0105959:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010595c:	89 10                	mov    %edx,(%eax)
    }
    pte_t *pte = ((pte_t*) KADDR(PDE_ADDR(*pde)));
c010595e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105961:	8b 00                	mov    (%eax),%eax
c0105963:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105968:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010596b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010596e:	c1 e8 0c             	shr    $0xc,%eax
c0105971:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105974:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0105979:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010597c:	72 23                	jb     c01059a1 <get_pte+0x124>
c010597e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105981:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105985:	c7 44 24 08 44 cc 10 	movl   $0xc010cc44,0x8(%esp)
c010598c:	c0 
c010598d:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c0105994:	00 
c0105995:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010599c:	e8 74 b4 ff ff       	call   c0100e15 <__panic>
c01059a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01059a4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01059a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return pte + PTX(la);
c01059ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059af:	c1 e8 0c             	shr    $0xc,%eax
c01059b2:	25 ff 03 00 00       	and    $0x3ff,%eax
c01059b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01059be:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01059c1:	01 d0                	add    %edx,%eax
}
c01059c3:	c9                   	leave  
c01059c4:	c3                   	ret    

c01059c5 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01059c5:	55                   	push   %ebp
c01059c6:	89 e5                	mov    %esp,%ebp
c01059c8:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01059cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01059d2:	00 
c01059d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059da:	8b 45 08             	mov    0x8(%ebp),%eax
c01059dd:	89 04 24             	mov    %eax,(%esp)
c01059e0:	e8 98 fe ff ff       	call   c010587d <get_pte>
c01059e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01059e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01059ec:	74 08                	je     c01059f6 <get_page+0x31>
        *ptep_store = ptep;
c01059ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01059f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059f4:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01059f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01059fa:	74 1b                	je     c0105a17 <get_page+0x52>
c01059fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ff:	8b 00                	mov    (%eax),%eax
c0105a01:	83 e0 01             	and    $0x1,%eax
c0105a04:	85 c0                	test   %eax,%eax
c0105a06:	74 0f                	je     c0105a17 <get_page+0x52>
        return pte2page(*ptep);
c0105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0b:	8b 00                	mov    (%eax),%eax
c0105a0d:	89 04 24             	mov    %eax,(%esp)
c0105a10:	e8 a6 f4 ff ff       	call   c0104ebb <pte2page>
c0105a15:	eb 05                	jmp    c0105a1c <get_page+0x57>
    }
    return NULL;
c0105a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a1c:	c9                   	leave  
c0105a1d:	c3                   	ret    

c0105a1e <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0105a1e:	55                   	push   %ebp
c0105a1f:	89 e5                	mov    %esp,%ebp
c0105a21:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0105a24:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a27:	8b 00                	mov    (%eax),%eax
c0105a29:	83 e0 01             	and    $0x1,%eax
c0105a2c:	85 c0                	test   %eax,%eax
c0105a2e:	74 4d                	je     c0105a7d <page_remove_pte+0x5f>
        struct  Page *page = pte2page(*ptep);
c0105a30:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a33:	8b 00                	mov    (%eax),%eax
c0105a35:	89 04 24             	mov    %eax,(%esp)
c0105a38:	e8 7e f4 ff ff       	call   c0104ebb <pte2page>
c0105a3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) free_page(page);
c0105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a43:	89 04 24             	mov    %eax,(%esp)
c0105a46:	e8 f4 f4 ff ff       	call   c0104f3f <page_ref_dec>
c0105a4b:	85 c0                	test   %eax,%eax
c0105a4d:	75 13                	jne    c0105a62 <page_remove_pte+0x44>
c0105a4f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a56:	00 
c0105a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a5a:	89 04 24             	mov    %eax,(%esp)
c0105a5d:	e8 1f f7 ff ff       	call   c0105181 <free_pages>
        *ptep = 0;
c0105a62:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a72:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a75:	89 04 24             	mov    %eax,(%esp)
c0105a78:	e8 1d 05 00 00       	call   c0105f9a <tlb_invalidate>
    }
}
c0105a7d:	c9                   	leave  
c0105a7e:	c3                   	ret    

c0105a7f <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105a7f:	55                   	push   %ebp
c0105a80:	89 e5                	mov    %esp,%ebp
c0105a82:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105a85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a88:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105a8d:	85 c0                	test   %eax,%eax
c0105a8f:	75 0c                	jne    c0105a9d <unmap_range+0x1e>
c0105a91:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a94:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105a99:	85 c0                	test   %eax,%eax
c0105a9b:	74 24                	je     c0105ac1 <unmap_range+0x42>
c0105a9d:	c7 44 24 0c 6c cd 10 	movl   $0xc010cd6c,0xc(%esp)
c0105aa4:	c0 
c0105aa5:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105aac:	c0 
c0105aad:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
c0105ab4:	00 
c0105ab5:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105abc:	e8 54 b3 ff ff       	call   c0100e15 <__panic>
    assert(USER_ACCESS(start, end));
c0105ac1:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105ac8:	76 11                	jbe    c0105adb <unmap_range+0x5c>
c0105aca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105acd:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105ad0:	73 09                	jae    c0105adb <unmap_range+0x5c>
c0105ad2:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105ad9:	76 24                	jbe    c0105aff <unmap_range+0x80>
c0105adb:	c7 44 24 0c 95 cd 10 	movl   $0xc010cd95,0xc(%esp)
c0105ae2:	c0 
c0105ae3:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105aea:	c0 
c0105aeb:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
c0105af2:	00 
c0105af3:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105afa:	e8 16 b3 ff ff       	call   c0100e15 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0105aff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105b06:	00 
c0105b07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b11:	89 04 24             	mov    %eax,(%esp)
c0105b14:	e8 64 fd ff ff       	call   c010587d <get_pte>
c0105b19:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105b1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b20:	75 18                	jne    c0105b3a <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105b22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b25:	05 00 00 40 00       	add    $0x400000,%eax
c0105b2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b30:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105b35:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0105b38:	eb 29                	jmp    c0105b63 <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0105b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b3d:	8b 00                	mov    (%eax),%eax
c0105b3f:	85 c0                	test   %eax,%eax
c0105b41:	74 19                	je     c0105b5c <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0105b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b46:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b54:	89 04 24             	mov    %eax,(%esp)
c0105b57:	e8 c2 fe ff ff       	call   c0105a1e <page_remove_pte>
        }
        start += PGSIZE;
c0105b5c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105b63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b67:	74 08                	je     c0105b71 <unmap_range+0xf2>
c0105b69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b6c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105b6f:	72 8e                	jb     c0105aff <unmap_range+0x80>
}
c0105b71:	c9                   	leave  
c0105b72:	c3                   	ret    

c0105b73 <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0105b73:	55                   	push   %ebp
c0105b74:	89 e5                	mov    %esp,%ebp
c0105b76:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105b79:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b7c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b81:	85 c0                	test   %eax,%eax
c0105b83:	75 0c                	jne    c0105b91 <exit_range+0x1e>
c0105b85:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b88:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105b8d:	85 c0                	test   %eax,%eax
c0105b8f:	74 24                	je     c0105bb5 <exit_range+0x42>
c0105b91:	c7 44 24 0c 6c cd 10 	movl   $0xc010cd6c,0xc(%esp)
c0105b98:	c0 
c0105b99:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105ba0:	c0 
c0105ba1:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0105ba8:	00 
c0105ba9:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105bb0:	e8 60 b2 ff ff       	call   c0100e15 <__panic>
    assert(USER_ACCESS(start, end));
c0105bb5:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0105bbc:	76 11                	jbe    c0105bcf <exit_range+0x5c>
c0105bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bc1:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105bc4:	73 09                	jae    c0105bcf <exit_range+0x5c>
c0105bc6:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0105bcd:	76 24                	jbe    c0105bf3 <exit_range+0x80>
c0105bcf:	c7 44 24 0c 95 cd 10 	movl   $0xc010cd95,0xc(%esp)
c0105bd6:	c0 
c0105bd7:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105bde:	c0 
c0105bdf:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c0105be6:	00 
c0105be7:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105bee:	e8 22 b2 ff ff       	call   c0100e15 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0105bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bfc:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105c01:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0105c04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c07:	c1 e8 16             	shr    $0x16,%eax
c0105c0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0105c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c1a:	01 d0                	add    %edx,%eax
c0105c1c:	8b 00                	mov    (%eax),%eax
c0105c1e:	83 e0 01             	and    $0x1,%eax
c0105c21:	85 c0                	test   %eax,%eax
c0105c23:	74 3e                	je     c0105c63 <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0105c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c32:	01 d0                	add    %edx,%eax
c0105c34:	8b 00                	mov    (%eax),%eax
c0105c36:	89 04 24             	mov    %eax,(%esp)
c0105c39:	e8 bb f2 ff ff       	call   c0104ef9 <pde2page>
c0105c3e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c45:	00 
c0105c46:	89 04 24             	mov    %eax,(%esp)
c0105c49:	e8 33 f5 ff ff       	call   c0105181 <free_pages>
            pgdir[pde_idx] = 0;
c0105c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c51:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105c58:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5b:	01 d0                	add    %edx,%eax
c0105c5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c0105c63:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0105c6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c6e:	74 08                	je     c0105c78 <exit_range+0x105>
c0105c70:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c73:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c76:	72 8c                	jb     c0105c04 <exit_range+0x91>
}
c0105c78:	c9                   	leave  
c0105c79:	c3                   	ret    

c0105c7a <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0105c7a:	55                   	push   %ebp
c0105c7b:	89 e5                	mov    %esp,%ebp
c0105c7d:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0105c80:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c83:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c88:	85 c0                	test   %eax,%eax
c0105c8a:	75 0c                	jne    c0105c98 <copy_range+0x1e>
c0105c8c:	8b 45 14             	mov    0x14(%ebp),%eax
c0105c8f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105c94:	85 c0                	test   %eax,%eax
c0105c96:	74 24                	je     c0105cbc <copy_range+0x42>
c0105c98:	c7 44 24 0c 6c cd 10 	movl   $0xc010cd6c,0xc(%esp)
c0105c9f:	c0 
c0105ca0:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105ca7:	c0 
c0105ca8:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0105caf:	00 
c0105cb0:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105cb7:	e8 59 b1 ff ff       	call   c0100e15 <__panic>
    assert(USER_ACCESS(start, end));
c0105cbc:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c0105cc3:	76 11                	jbe    c0105cd6 <copy_range+0x5c>
c0105cc5:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cc8:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105ccb:	73 09                	jae    c0105cd6 <copy_range+0x5c>
c0105ccd:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c0105cd4:	76 24                	jbe    c0105cfa <copy_range+0x80>
c0105cd6:	c7 44 24 0c 95 cd 10 	movl   $0xc010cd95,0xc(%esp)
c0105cdd:	c0 
c0105cde:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105ce5:	c0 
c0105ce6:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0105ced:	00 
c0105cee:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105cf5:	e8 1b b1 ff ff       	call   c0100e15 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c0105cfa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d01:	00 
c0105d02:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d0c:	89 04 24             	mov    %eax,(%esp)
c0105d0f:	e8 69 fb ff ff       	call   c010587d <get_pte>
c0105d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0105d17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d1b:	75 1b                	jne    c0105d38 <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0105d1d:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d20:	05 00 00 40 00       	add    $0x400000,%eax
c0105d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d2b:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0105d30:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c0105d33:	e9 4c 01 00 00       	jmp    c0105e84 <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c0105d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d3b:	8b 00                	mov    (%eax),%eax
c0105d3d:	83 e0 01             	and    $0x1,%eax
c0105d40:	85 c0                	test   %eax,%eax
c0105d42:	0f 84 35 01 00 00    	je     c0105e7d <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0105d48:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105d4f:	00 
c0105d50:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d57:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5a:	89 04 24             	mov    %eax,(%esp)
c0105d5d:	e8 1b fb ff ff       	call   c010587d <get_pte>
c0105d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d65:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105d69:	75 0a                	jne    c0105d75 <copy_range+0xfb>
                return -E_NO_MEM;
c0105d6b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105d70:	e9 26 01 00 00       	jmp    c0105e9b <copy_range+0x221>
            }
            uint32_t perm = (*ptep & PTE_USER);
c0105d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d78:	8b 00                	mov    (%eax),%eax
c0105d7a:	83 e0 07             	and    $0x7,%eax
c0105d7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            //get page from ptep
            struct Page *page = pte2page(*ptep);
c0105d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d83:	8b 00                	mov    (%eax),%eax
c0105d85:	89 04 24             	mov    %eax,(%esp)
c0105d88:	e8 2e f1 ff ff       	call   c0104ebb <pte2page>
c0105d8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            // alloc a page for process B
            struct Page *npage=alloc_page();
c0105d90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d97:	e8 7a f3 ff ff       	call   c0105116 <alloc_pages>
c0105d9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
            assert(page!=NULL);
c0105d9f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105da3:	75 24                	jne    c0105dc9 <copy_range+0x14f>
c0105da5:	c7 44 24 0c ad cd 10 	movl   $0xc010cdad,0xc(%esp)
c0105dac:	c0 
c0105dad:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105db4:	c0 
c0105db5:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0105dbc:	00 
c0105dbd:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105dc4:	e8 4c b0 ff ff       	call   c0100e15 <__panic>
            assert(npage!=NULL);
c0105dc9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105dcd:	75 24                	jne    c0105df3 <copy_range+0x179>
c0105dcf:	c7 44 24 0c b8 cd 10 	movl   $0xc010cdb8,0xc(%esp)
c0105dd6:	c0 
c0105dd7:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105dde:	c0 
c0105ddf:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0105de6:	00 
c0105de7:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105dee:	e8 22 b0 ff ff       	call   c0100e15 <__panic>
            int ret=0;
c0105df3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
             * (2) find dst_kvaddr: the kernel virtual address of npage
             * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
             * (4) build the map of phy addr of  nage with the linear addr start
             */

            void *src_kvaddr = page2kva(page);
c0105dfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dfd:	89 04 24             	mov    %eax,(%esp)
c0105e00:	e8 62 f0 ff ff       	call   c0104e67 <page2kva>
c0105e05:	89 45 d8             	mov    %eax,-0x28(%ebp)
            void *dst_kvaddr = page2kva(npage);
c0105e08:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e0b:	89 04 24             	mov    %eax,(%esp)
c0105e0e:	e8 54 f0 ff ff       	call   c0104e67 <page2kva>
c0105e13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
c0105e16:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105e1d:	00 
c0105e1e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105e21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105e28:	89 04 24             	mov    %eax,(%esp)
c0105e2b:	e8 9e 5f 00 00       	call   c010bdce <memcpy>
            ret = page_insert(to, npage, start, perm);
c0105e30:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e33:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e37:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e3a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e45:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e48:	89 04 24             	mov    %eax,(%esp)
c0105e4b:	e8 91 00 00 00       	call   c0105ee1 <page_insert>
c0105e50:	89 45 dc             	mov    %eax,-0x24(%ebp)
            assert(ret == 0);
c0105e53:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105e57:	74 24                	je     c0105e7d <copy_range+0x203>
c0105e59:	c7 44 24 0c c4 cd 10 	movl   $0xc010cdc4,0xc(%esp)
c0105e60:	c0 
c0105e61:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0105e68:	c0 
c0105e69:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105e70:	00 
c0105e71:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105e78:	e8 98 af ff ff       	call   c0100e15 <__panic>

            //LAB5 Challenge 2013011317
            // You need to delete below code and use following code
            // *ptep = *ptep & (~PTE_W);
        }
        start += PGSIZE;
c0105e7d:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c0105e84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e88:	74 0c                	je     c0105e96 <copy_range+0x21c>
c0105e8a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e8d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0105e90:	0f 82 64 fe ff ff    	jb     c0105cfa <copy_range+0x80>
    return 0;
c0105e96:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e9b:	c9                   	leave  
c0105e9c:	c3                   	ret    

c0105e9d <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105e9d:	55                   	push   %ebp
c0105e9e:	89 e5                	mov    %esp,%ebp
c0105ea0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0105ea3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105eaa:	00 
c0105eab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105eae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105eb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105eb5:	89 04 24             	mov    %eax,(%esp)
c0105eb8:	e8 c0 f9 ff ff       	call   c010587d <get_pte>
c0105ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0105ec0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ec4:	74 19                	je     c0105edf <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ec9:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ed4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed7:	89 04 24             	mov    %eax,(%esp)
c0105eda:	e8 3f fb ff ff       	call   c0105a1e <page_remove_pte>
    }
}
c0105edf:	c9                   	leave  
c0105ee0:	c3                   	ret    

c0105ee1 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0105ee1:	55                   	push   %ebp
c0105ee2:	89 e5                	mov    %esp,%ebp
c0105ee4:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105ee7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105eee:	00 
c0105eef:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ef6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ef9:	89 04 24             	mov    %eax,(%esp)
c0105efc:	e8 7c f9 ff ff       	call   c010587d <get_pte>
c0105f01:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0105f04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f08:	75 0a                	jne    c0105f14 <page_insert+0x33>
        return -E_NO_MEM;
c0105f0a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105f0f:	e9 84 00 00 00       	jmp    c0105f98 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0105f14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f17:	89 04 24             	mov    %eax,(%esp)
c0105f1a:	e8 09 f0 ff ff       	call   c0104f28 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f22:	8b 00                	mov    (%eax),%eax
c0105f24:	83 e0 01             	and    $0x1,%eax
c0105f27:	85 c0                	test   %eax,%eax
c0105f29:	74 3e                	je     c0105f69 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0105f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f2e:	8b 00                	mov    (%eax),%eax
c0105f30:	89 04 24             	mov    %eax,(%esp)
c0105f33:	e8 83 ef ff ff       	call   c0104ebb <pte2page>
c0105f38:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0105f3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f3e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105f41:	75 0d                	jne    c0105f50 <page_insert+0x6f>
            page_ref_dec(page);
c0105f43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f46:	89 04 24             	mov    %eax,(%esp)
c0105f49:	e8 f1 ef ff ff       	call   c0104f3f <page_ref_dec>
c0105f4e:	eb 19                	jmp    c0105f69 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0105f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f53:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f57:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f61:	89 04 24             	mov    %eax,(%esp)
c0105f64:	e8 b5 fa ff ff       	call   c0105a1e <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0105f69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f6c:	89 04 24             	mov    %eax,(%esp)
c0105f6f:	e8 98 ee ff ff       	call   c0104e0c <page2pa>
c0105f74:	0b 45 14             	or     0x14(%ebp),%eax
c0105f77:	83 c8 01             	or     $0x1,%eax
c0105f7a:	89 c2                	mov    %eax,%edx
c0105f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f7f:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0105f81:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8b:	89 04 24             	mov    %eax,(%esp)
c0105f8e:	e8 07 00 00 00       	call   c0105f9a <tlb_invalidate>
    return 0;
c0105f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f98:	c9                   	leave  
c0105f99:	c3                   	ret    

c0105f9a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105f9a:	55                   	push   %ebp
c0105f9b:	89 e5                	mov    %esp,%ebp
c0105f9d:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0105fa0:	0f 20 d8             	mov    %cr3,%eax
c0105fa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105fa9:	89 c2                	mov    %eax,%edx
c0105fab:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fb1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105fb8:	77 23                	ja     c0105fdd <tlb_invalidate+0x43>
c0105fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105fc1:	c7 44 24 08 e8 cc 10 	movl   $0xc010cce8,0x8(%esp)
c0105fc8:	c0 
c0105fc9:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
c0105fd0:	00 
c0105fd1:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0105fd8:	e8 38 ae ff ff       	call   c0100e15 <__panic>
c0105fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fe0:	05 00 00 00 40       	add    $0x40000000,%eax
c0105fe5:	39 c2                	cmp    %eax,%edx
c0105fe7:	75 0c                	jne    c0105ff5 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0105fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fec:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105fef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ff2:	0f 01 38             	invlpg (%eax)
    }
}
c0105ff5:	c9                   	leave  
c0105ff6:	c3                   	ret    

c0105ff7 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105ff7:	55                   	push   %ebp
c0105ff8:	89 e5                	mov    %esp,%ebp
c0105ffa:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105ffd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106004:	e8 0d f1 ff ff       	call   c0105116 <alloc_pages>
c0106009:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010600c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106010:	0f 84 b0 00 00 00    	je     c01060c6 <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106016:	8b 45 10             	mov    0x10(%ebp),%eax
c0106019:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010601d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106020:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106024:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106027:	89 44 24 04          	mov    %eax,0x4(%esp)
c010602b:	8b 45 08             	mov    0x8(%ebp),%eax
c010602e:	89 04 24             	mov    %eax,(%esp)
c0106031:	e8 ab fe ff ff       	call   c0105ee1 <page_insert>
c0106036:	85 c0                	test   %eax,%eax
c0106038:	74 1a                	je     c0106054 <pgdir_alloc_page+0x5d>
            free_page(page);
c010603a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106041:	00 
c0106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106045:	89 04 24             	mov    %eax,(%esp)
c0106048:	e8 34 f1 ff ff       	call   c0105181 <free_pages>
            return NULL;
c010604d:	b8 00 00 00 00       	mov    $0x0,%eax
c0106052:	eb 75                	jmp    c01060c9 <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c0106054:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0106059:	85 c0                	test   %eax,%eax
c010605b:	74 69                	je     c01060c6 <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c010605d:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0106062:	85 c0                	test   %eax,%eax
c0106064:	74 60                	je     c01060c6 <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c0106066:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c010606b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106072:	00 
c0106073:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106076:	89 54 24 08          	mov    %edx,0x8(%esp)
c010607a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010607d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106081:	89 04 24             	mov    %eax,(%esp)
c0106084:	e8 51 0e 00 00       	call   c0106eda <swap_map_swappable>
                page->pra_vaddr=la;
c0106089:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010608c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010608f:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c0106092:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106095:	89 04 24             	mov    %eax,(%esp)
c0106098:	e8 74 ee ff ff       	call   c0104f11 <page_ref>
c010609d:	83 f8 01             	cmp    $0x1,%eax
c01060a0:	74 24                	je     c01060c6 <pgdir_alloc_page+0xcf>
c01060a2:	c7 44 24 0c cd cd 10 	movl   $0xc010cdcd,0xc(%esp)
c01060a9:	c0 
c01060aa:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01060b1:	c0 
c01060b2:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c01060b9:	00 
c01060ba:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01060c1:	e8 4f ad ff ff       	call   c0100e15 <__panic>
            }
        }

    }

    return page;
c01060c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01060c9:	c9                   	leave  
c01060ca:	c3                   	ret    

c01060cb <check_alloc_page>:

static void
check_alloc_page(void) {
c01060cb:	55                   	push   %ebp
c01060cc:	89 e5                	mov    %esp,%ebp
c01060ce:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01060d1:	a1 c4 ef 19 c0       	mov    0xc019efc4,%eax
c01060d6:	8b 40 18             	mov    0x18(%eax),%eax
c01060d9:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01060db:	c7 04 24 e4 cd 10 c0 	movl   $0xc010cde4,(%esp)
c01060e2:	e8 6c a2 ff ff       	call   c0100353 <cprintf>
}
c01060e7:	c9                   	leave  
c01060e8:	c3                   	ret    

c01060e9 <check_pgdir>:

static void
check_pgdir(void) {
c01060e9:	55                   	push   %ebp
c01060ea:	89 e5                	mov    %esp,%ebp
c01060ec:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01060ef:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01060f4:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01060f9:	76 24                	jbe    c010611f <check_pgdir+0x36>
c01060fb:	c7 44 24 0c 03 ce 10 	movl   $0xc010ce03,0xc(%esp)
c0106102:	c0 
c0106103:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010610a:	c0 
c010610b:	c7 44 24 04 86 02 00 	movl   $0x286,0x4(%esp)
c0106112:	00 
c0106113:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010611a:	e8 f6 ac ff ff       	call   c0100e15 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010611f:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106124:	85 c0                	test   %eax,%eax
c0106126:	74 0e                	je     c0106136 <check_pgdir+0x4d>
c0106128:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010612d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106132:	85 c0                	test   %eax,%eax
c0106134:	74 24                	je     c010615a <check_pgdir+0x71>
c0106136:	c7 44 24 0c 20 ce 10 	movl   $0xc010ce20,0xc(%esp)
c010613d:	c0 
c010613e:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106145:	c0 
c0106146:	c7 44 24 04 87 02 00 	movl   $0x287,0x4(%esp)
c010614d:	00 
c010614e:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106155:	e8 bb ac ff ff       	call   c0100e15 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c010615a:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010615f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106166:	00 
c0106167:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010616e:	00 
c010616f:	89 04 24             	mov    %eax,(%esp)
c0106172:	e8 4e f8 ff ff       	call   c01059c5 <get_page>
c0106177:	85 c0                	test   %eax,%eax
c0106179:	74 24                	je     c010619f <check_pgdir+0xb6>
c010617b:	c7 44 24 0c 58 ce 10 	movl   $0xc010ce58,0xc(%esp)
c0106182:	c0 
c0106183:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010618a:	c0 
c010618b:	c7 44 24 04 88 02 00 	movl   $0x288,0x4(%esp)
c0106192:	00 
c0106193:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010619a:	e8 76 ac ff ff       	call   c0100e15 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010619f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01061a6:	e8 6b ef ff ff       	call   c0105116 <alloc_pages>
c01061ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01061ae:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01061b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01061ba:	00 
c01061bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01061c2:	00 
c01061c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01061c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061ca:	89 04 24             	mov    %eax,(%esp)
c01061cd:	e8 0f fd ff ff       	call   c0105ee1 <page_insert>
c01061d2:	85 c0                	test   %eax,%eax
c01061d4:	74 24                	je     c01061fa <check_pgdir+0x111>
c01061d6:	c7 44 24 0c 80 ce 10 	movl   $0xc010ce80,0xc(%esp)
c01061dd:	c0 
c01061de:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01061e5:	c0 
c01061e6:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
c01061ed:	00 
c01061ee:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01061f5:	e8 1b ac ff ff       	call   c0100e15 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01061fa:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01061ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106206:	00 
c0106207:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010620e:	00 
c010620f:	89 04 24             	mov    %eax,(%esp)
c0106212:	e8 66 f6 ff ff       	call   c010587d <get_pte>
c0106217:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010621a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010621e:	75 24                	jne    c0106244 <check_pgdir+0x15b>
c0106220:	c7 44 24 0c ac ce 10 	movl   $0xc010ceac,0xc(%esp)
c0106227:	c0 
c0106228:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010622f:	c0 
c0106230:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
c0106237:	00 
c0106238:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010623f:	e8 d1 ab ff ff       	call   c0100e15 <__panic>
    assert(pte2page(*ptep) == p1);
c0106244:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106247:	8b 00                	mov    (%eax),%eax
c0106249:	89 04 24             	mov    %eax,(%esp)
c010624c:	e8 6a ec ff ff       	call   c0104ebb <pte2page>
c0106251:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106254:	74 24                	je     c010627a <check_pgdir+0x191>
c0106256:	c7 44 24 0c d9 ce 10 	movl   $0xc010ced9,0xc(%esp)
c010625d:	c0 
c010625e:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106265:	c0 
c0106266:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
c010626d:	00 
c010626e:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106275:	e8 9b ab ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p1) == 1);
c010627a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010627d:	89 04 24             	mov    %eax,(%esp)
c0106280:	e8 8c ec ff ff       	call   c0104f11 <page_ref>
c0106285:	83 f8 01             	cmp    $0x1,%eax
c0106288:	74 24                	je     c01062ae <check_pgdir+0x1c5>
c010628a:	c7 44 24 0c ef ce 10 	movl   $0xc010ceef,0xc(%esp)
c0106291:	c0 
c0106292:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106299:	c0 
c010629a:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
c01062a1:	00 
c01062a2:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01062a9:	e8 67 ab ff ff       	call   c0100e15 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01062ae:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01062b3:	8b 00                	mov    (%eax),%eax
c01062b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01062ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01062bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062c0:	c1 e8 0c             	shr    $0xc,%eax
c01062c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01062c6:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01062cb:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01062ce:	72 23                	jb     c01062f3 <check_pgdir+0x20a>
c01062d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062d7:	c7 44 24 08 44 cc 10 	movl   $0xc010cc44,0x8(%esp)
c01062de:	c0 
c01062df:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
c01062e6:	00 
c01062e7:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01062ee:	e8 22 ab ff ff       	call   c0100e15 <__panic>
c01062f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062f6:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01062fb:	83 c0 04             	add    $0x4,%eax
c01062fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0106301:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106306:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010630d:	00 
c010630e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106315:	00 
c0106316:	89 04 24             	mov    %eax,(%esp)
c0106319:	e8 5f f5 ff ff       	call   c010587d <get_pte>
c010631e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106321:	74 24                	je     c0106347 <check_pgdir+0x25e>
c0106323:	c7 44 24 0c 04 cf 10 	movl   $0xc010cf04,0xc(%esp)
c010632a:	c0 
c010632b:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106332:	c0 
c0106333:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
c010633a:	00 
c010633b:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106342:	e8 ce aa ff ff       	call   c0100e15 <__panic>

    p2 = alloc_page();
c0106347:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010634e:	e8 c3 ed ff ff       	call   c0105116 <alloc_pages>
c0106353:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0106356:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010635b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0106362:	00 
c0106363:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010636a:	00 
c010636b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010636e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106372:	89 04 24             	mov    %eax,(%esp)
c0106375:	e8 67 fb ff ff       	call   c0105ee1 <page_insert>
c010637a:	85 c0                	test   %eax,%eax
c010637c:	74 24                	je     c01063a2 <check_pgdir+0x2b9>
c010637e:	c7 44 24 0c 2c cf 10 	movl   $0xc010cf2c,0xc(%esp)
c0106385:	c0 
c0106386:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010638d:	c0 
c010638e:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
c0106395:	00 
c0106396:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010639d:	e8 73 aa ff ff       	call   c0100e15 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01063a2:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01063a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01063ae:	00 
c01063af:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01063b6:	00 
c01063b7:	89 04 24             	mov    %eax,(%esp)
c01063ba:	e8 be f4 ff ff       	call   c010587d <get_pte>
c01063bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01063c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063c6:	75 24                	jne    c01063ec <check_pgdir+0x303>
c01063c8:	c7 44 24 0c 64 cf 10 	movl   $0xc010cf64,0xc(%esp)
c01063cf:	c0 
c01063d0:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01063d7:	c0 
c01063d8:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
c01063df:	00 
c01063e0:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01063e7:	e8 29 aa ff ff       	call   c0100e15 <__panic>
    assert(*ptep & PTE_U);
c01063ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063ef:	8b 00                	mov    (%eax),%eax
c01063f1:	83 e0 04             	and    $0x4,%eax
c01063f4:	85 c0                	test   %eax,%eax
c01063f6:	75 24                	jne    c010641c <check_pgdir+0x333>
c01063f8:	c7 44 24 0c 94 cf 10 	movl   $0xc010cf94,0xc(%esp)
c01063ff:	c0 
c0106400:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106407:	c0 
c0106408:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
c010640f:	00 
c0106410:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106417:	e8 f9 a9 ff ff       	call   c0100e15 <__panic>
    assert(*ptep & PTE_W);
c010641c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010641f:	8b 00                	mov    (%eax),%eax
c0106421:	83 e0 02             	and    $0x2,%eax
c0106424:	85 c0                	test   %eax,%eax
c0106426:	75 24                	jne    c010644c <check_pgdir+0x363>
c0106428:	c7 44 24 0c a2 cf 10 	movl   $0xc010cfa2,0xc(%esp)
c010642f:	c0 
c0106430:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106437:	c0 
c0106438:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
c010643f:	00 
c0106440:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106447:	e8 c9 a9 ff ff       	call   c0100e15 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010644c:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106451:	8b 00                	mov    (%eax),%eax
c0106453:	83 e0 04             	and    $0x4,%eax
c0106456:	85 c0                	test   %eax,%eax
c0106458:	75 24                	jne    c010647e <check_pgdir+0x395>
c010645a:	c7 44 24 0c b0 cf 10 	movl   $0xc010cfb0,0xc(%esp)
c0106461:	c0 
c0106462:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106469:	c0 
c010646a:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
c0106471:	00 
c0106472:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106479:	e8 97 a9 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p2) == 1);
c010647e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106481:	89 04 24             	mov    %eax,(%esp)
c0106484:	e8 88 ea ff ff       	call   c0104f11 <page_ref>
c0106489:	83 f8 01             	cmp    $0x1,%eax
c010648c:	74 24                	je     c01064b2 <check_pgdir+0x3c9>
c010648e:	c7 44 24 0c c6 cf 10 	movl   $0xc010cfc6,0xc(%esp)
c0106495:	c0 
c0106496:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010649d:	c0 
c010649e:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
c01064a5:	00 
c01064a6:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01064ad:	e8 63 a9 ff ff       	call   c0100e15 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01064b2:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01064b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01064be:	00 
c01064bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01064c6:	00 
c01064c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01064ca:	89 54 24 04          	mov    %edx,0x4(%esp)
c01064ce:	89 04 24             	mov    %eax,(%esp)
c01064d1:	e8 0b fa ff ff       	call   c0105ee1 <page_insert>
c01064d6:	85 c0                	test   %eax,%eax
c01064d8:	74 24                	je     c01064fe <check_pgdir+0x415>
c01064da:	c7 44 24 0c d8 cf 10 	movl   $0xc010cfd8,0xc(%esp)
c01064e1:	c0 
c01064e2:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01064e9:	c0 
c01064ea:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c01064f1:	00 
c01064f2:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01064f9:	e8 17 a9 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p1) == 2);
c01064fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106501:	89 04 24             	mov    %eax,(%esp)
c0106504:	e8 08 ea ff ff       	call   c0104f11 <page_ref>
c0106509:	83 f8 02             	cmp    $0x2,%eax
c010650c:	74 24                	je     c0106532 <check_pgdir+0x449>
c010650e:	c7 44 24 0c 04 d0 10 	movl   $0xc010d004,0xc(%esp)
c0106515:	c0 
c0106516:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010651d:	c0 
c010651e:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
c0106525:	00 
c0106526:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010652d:	e8 e3 a8 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p2) == 0);
c0106532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106535:	89 04 24             	mov    %eax,(%esp)
c0106538:	e8 d4 e9 ff ff       	call   c0104f11 <page_ref>
c010653d:	85 c0                	test   %eax,%eax
c010653f:	74 24                	je     c0106565 <check_pgdir+0x47c>
c0106541:	c7 44 24 0c 16 d0 10 	movl   $0xc010d016,0xc(%esp)
c0106548:	c0 
c0106549:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106550:	c0 
c0106551:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0106558:	00 
c0106559:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106560:	e8 b0 a8 ff ff       	call   c0100e15 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0106565:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010656a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106571:	00 
c0106572:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106579:	00 
c010657a:	89 04 24             	mov    %eax,(%esp)
c010657d:	e8 fb f2 ff ff       	call   c010587d <get_pte>
c0106582:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106585:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106589:	75 24                	jne    c01065af <check_pgdir+0x4c6>
c010658b:	c7 44 24 0c 64 cf 10 	movl   $0xc010cf64,0xc(%esp)
c0106592:	c0 
c0106593:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010659a:	c0 
c010659b:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
c01065a2:	00 
c01065a3:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01065aa:	e8 66 a8 ff ff       	call   c0100e15 <__panic>
    assert(pte2page(*ptep) == p1);
c01065af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065b2:	8b 00                	mov    (%eax),%eax
c01065b4:	89 04 24             	mov    %eax,(%esp)
c01065b7:	e8 ff e8 ff ff       	call   c0104ebb <pte2page>
c01065bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01065bf:	74 24                	je     c01065e5 <check_pgdir+0x4fc>
c01065c1:	c7 44 24 0c d9 ce 10 	movl   $0xc010ced9,0xc(%esp)
c01065c8:	c0 
c01065c9:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01065d0:	c0 
c01065d1:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
c01065d8:	00 
c01065d9:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01065e0:	e8 30 a8 ff ff       	call   c0100e15 <__panic>
    assert((*ptep & PTE_U) == 0);
c01065e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065e8:	8b 00                	mov    (%eax),%eax
c01065ea:	83 e0 04             	and    $0x4,%eax
c01065ed:	85 c0                	test   %eax,%eax
c01065ef:	74 24                	je     c0106615 <check_pgdir+0x52c>
c01065f1:	c7 44 24 0c 28 d0 10 	movl   $0xc010d028,0xc(%esp)
c01065f8:	c0 
c01065f9:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106600:	c0 
c0106601:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
c0106608:	00 
c0106609:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106610:	e8 00 a8 ff ff       	call   c0100e15 <__panic>

    page_remove(boot_pgdir, 0x0);
c0106615:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010661a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106621:	00 
c0106622:	89 04 24             	mov    %eax,(%esp)
c0106625:	e8 73 f8 ff ff       	call   c0105e9d <page_remove>
    assert(page_ref(p1) == 1);
c010662a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010662d:	89 04 24             	mov    %eax,(%esp)
c0106630:	e8 dc e8 ff ff       	call   c0104f11 <page_ref>
c0106635:	83 f8 01             	cmp    $0x1,%eax
c0106638:	74 24                	je     c010665e <check_pgdir+0x575>
c010663a:	c7 44 24 0c ef ce 10 	movl   $0xc010ceef,0xc(%esp)
c0106641:	c0 
c0106642:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106649:	c0 
c010664a:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0106651:	00 
c0106652:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106659:	e8 b7 a7 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p2) == 0);
c010665e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106661:	89 04 24             	mov    %eax,(%esp)
c0106664:	e8 a8 e8 ff ff       	call   c0104f11 <page_ref>
c0106669:	85 c0                	test   %eax,%eax
c010666b:	74 24                	je     c0106691 <check_pgdir+0x5a8>
c010666d:	c7 44 24 0c 16 d0 10 	movl   $0xc010d016,0xc(%esp)
c0106674:	c0 
c0106675:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010667c:	c0 
c010667d:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
c0106684:	00 
c0106685:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010668c:	e8 84 a7 ff ff       	call   c0100e15 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0106691:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106696:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010669d:	00 
c010669e:	89 04 24             	mov    %eax,(%esp)
c01066a1:	e8 f7 f7 ff ff       	call   c0105e9d <page_remove>
    assert(page_ref(p1) == 0);
c01066a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066a9:	89 04 24             	mov    %eax,(%esp)
c01066ac:	e8 60 e8 ff ff       	call   c0104f11 <page_ref>
c01066b1:	85 c0                	test   %eax,%eax
c01066b3:	74 24                	je     c01066d9 <check_pgdir+0x5f0>
c01066b5:	c7 44 24 0c 3d d0 10 	movl   $0xc010d03d,0xc(%esp)
c01066bc:	c0 
c01066bd:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01066c4:	c0 
c01066c5:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
c01066cc:	00 
c01066cd:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01066d4:	e8 3c a7 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p2) == 0);
c01066d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01066dc:	89 04 24             	mov    %eax,(%esp)
c01066df:	e8 2d e8 ff ff       	call   c0104f11 <page_ref>
c01066e4:	85 c0                	test   %eax,%eax
c01066e6:	74 24                	je     c010670c <check_pgdir+0x623>
c01066e8:	c7 44 24 0c 16 d0 10 	movl   $0xc010d016,0xc(%esp)
c01066ef:	c0 
c01066f0:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01066f7:	c0 
c01066f8:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
c01066ff:	00 
c0106700:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106707:	e8 09 a7 ff ff       	call   c0100e15 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010670c:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106711:	8b 00                	mov    (%eax),%eax
c0106713:	89 04 24             	mov    %eax,(%esp)
c0106716:	e8 de e7 ff ff       	call   c0104ef9 <pde2page>
c010671b:	89 04 24             	mov    %eax,(%esp)
c010671e:	e8 ee e7 ff ff       	call   c0104f11 <page_ref>
c0106723:	83 f8 01             	cmp    $0x1,%eax
c0106726:	74 24                	je     c010674c <check_pgdir+0x663>
c0106728:	c7 44 24 0c 50 d0 10 	movl   $0xc010d050,0xc(%esp)
c010672f:	c0 
c0106730:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106737:	c0 
c0106738:	c7 44 24 04 ad 02 00 	movl   $0x2ad,0x4(%esp)
c010673f:	00 
c0106740:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106747:	e8 c9 a6 ff ff       	call   c0100e15 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c010674c:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106751:	8b 00                	mov    (%eax),%eax
c0106753:	89 04 24             	mov    %eax,(%esp)
c0106756:	e8 9e e7 ff ff       	call   c0104ef9 <pde2page>
c010675b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106762:	00 
c0106763:	89 04 24             	mov    %eax,(%esp)
c0106766:	e8 16 ea ff ff       	call   c0105181 <free_pages>
    boot_pgdir[0] = 0;
c010676b:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106770:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0106776:	c7 04 24 77 d0 10 c0 	movl   $0xc010d077,(%esp)
c010677d:	e8 d1 9b ff ff       	call   c0100353 <cprintf>
}
c0106782:	c9                   	leave  
c0106783:	c3                   	ret    

c0106784 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0106784:	55                   	push   %ebp
c0106785:	89 e5                	mov    %esp,%ebp
c0106787:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010678a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106791:	e9 ca 00 00 00       	jmp    c0106860 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0106796:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106799:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010679c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010679f:	c1 e8 0c             	shr    $0xc,%eax
c01067a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01067a5:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c01067aa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01067ad:	72 23                	jb     c01067d2 <check_boot_pgdir+0x4e>
c01067af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01067b6:	c7 44 24 08 44 cc 10 	movl   $0xc010cc44,0x8(%esp)
c01067bd:	c0 
c01067be:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
c01067c5:	00 
c01067c6:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01067cd:	e8 43 a6 ff ff       	call   c0100e15 <__panic>
c01067d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067d5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01067da:	89 c2                	mov    %eax,%edx
c01067dc:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01067e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01067e8:	00 
c01067e9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01067ed:	89 04 24             	mov    %eax,(%esp)
c01067f0:	e8 88 f0 ff ff       	call   c010587d <get_pte>
c01067f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01067f8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01067fc:	75 24                	jne    c0106822 <check_boot_pgdir+0x9e>
c01067fe:	c7 44 24 0c 94 d0 10 	movl   $0xc010d094,0xc(%esp)
c0106805:	c0 
c0106806:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010680d:	c0 
c010680e:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
c0106815:	00 
c0106816:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010681d:	e8 f3 a5 ff ff       	call   c0100e15 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0106822:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106825:	8b 00                	mov    (%eax),%eax
c0106827:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010682c:	89 c2                	mov    %eax,%edx
c010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106831:	39 c2                	cmp    %eax,%edx
c0106833:	74 24                	je     c0106859 <check_boot_pgdir+0xd5>
c0106835:	c7 44 24 0c d1 d0 10 	movl   $0xc010d0d1,0xc(%esp)
c010683c:	c0 
c010683d:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106844:	c0 
c0106845:	c7 44 24 04 ba 02 00 	movl   $0x2ba,0x4(%esp)
c010684c:	00 
c010684d:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106854:	e8 bc a5 ff ff       	call   c0100e15 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0106859:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0106860:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106863:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0106868:	39 c2                	cmp    %eax,%edx
c010686a:	0f 82 26 ff ff ff    	jb     c0106796 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0106870:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106875:	05 ac 0f 00 00       	add    $0xfac,%eax
c010687a:	8b 00                	mov    (%eax),%eax
c010687c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106881:	89 c2                	mov    %eax,%edx
c0106883:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106888:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010688b:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0106892:	77 23                	ja     c01068b7 <check_boot_pgdir+0x133>
c0106894:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106897:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010689b:	c7 44 24 08 e8 cc 10 	movl   $0xc010cce8,0x8(%esp)
c01068a2:	c0 
c01068a3:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c01068aa:	00 
c01068ab:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01068b2:	e8 5e a5 ff ff       	call   c0100e15 <__panic>
c01068b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068ba:	05 00 00 00 40       	add    $0x40000000,%eax
c01068bf:	39 c2                	cmp    %eax,%edx
c01068c1:	74 24                	je     c01068e7 <check_boot_pgdir+0x163>
c01068c3:	c7 44 24 0c e8 d0 10 	movl   $0xc010d0e8,0xc(%esp)
c01068ca:	c0 
c01068cb:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01068d2:	c0 
c01068d3:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
c01068da:	00 
c01068db:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01068e2:	e8 2e a5 ff ff       	call   c0100e15 <__panic>

    assert(boot_pgdir[0] == 0);
c01068e7:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01068ec:	8b 00                	mov    (%eax),%eax
c01068ee:	85 c0                	test   %eax,%eax
c01068f0:	74 24                	je     c0106916 <check_boot_pgdir+0x192>
c01068f2:	c7 44 24 0c 1c d1 10 	movl   $0xc010d11c,0xc(%esp)
c01068f9:	c0 
c01068fa:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106901:	c0 
c0106902:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
c0106909:	00 
c010690a:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106911:	e8 ff a4 ff ff       	call   c0100e15 <__panic>

    struct Page *p;
    p = alloc_page();
c0106916:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010691d:	e8 f4 e7 ff ff       	call   c0105116 <alloc_pages>
c0106922:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0106925:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c010692a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0106931:	00 
c0106932:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0106939:	00 
c010693a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010693d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106941:	89 04 24             	mov    %eax,(%esp)
c0106944:	e8 98 f5 ff ff       	call   c0105ee1 <page_insert>
c0106949:	85 c0                	test   %eax,%eax
c010694b:	74 24                	je     c0106971 <check_boot_pgdir+0x1ed>
c010694d:	c7 44 24 0c 30 d1 10 	movl   $0xc010d130,0xc(%esp)
c0106954:	c0 
c0106955:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c010695c:	c0 
c010695d:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
c0106964:	00 
c0106965:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c010696c:	e8 a4 a4 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p) == 1);
c0106971:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106974:	89 04 24             	mov    %eax,(%esp)
c0106977:	e8 95 e5 ff ff       	call   c0104f11 <page_ref>
c010697c:	83 f8 01             	cmp    $0x1,%eax
c010697f:	74 24                	je     c01069a5 <check_boot_pgdir+0x221>
c0106981:	c7 44 24 0c 5e d1 10 	movl   $0xc010d15e,0xc(%esp)
c0106988:	c0 
c0106989:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106990:	c0 
c0106991:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
c0106998:	00 
c0106999:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01069a0:	e8 70 a4 ff ff       	call   c0100e15 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01069a5:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c01069aa:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01069b1:	00 
c01069b2:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01069b9:	00 
c01069ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01069bd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069c1:	89 04 24             	mov    %eax,(%esp)
c01069c4:	e8 18 f5 ff ff       	call   c0105ee1 <page_insert>
c01069c9:	85 c0                	test   %eax,%eax
c01069cb:	74 24                	je     c01069f1 <check_boot_pgdir+0x26d>
c01069cd:	c7 44 24 0c 70 d1 10 	movl   $0xc010d170,0xc(%esp)
c01069d4:	c0 
c01069d5:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c01069dc:	c0 
c01069dd:	c7 44 24 04 c5 02 00 	movl   $0x2c5,0x4(%esp)
c01069e4:	00 
c01069e5:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c01069ec:	e8 24 a4 ff ff       	call   c0100e15 <__panic>
    assert(page_ref(p) == 2);
c01069f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01069f4:	89 04 24             	mov    %eax,(%esp)
c01069f7:	e8 15 e5 ff ff       	call   c0104f11 <page_ref>
c01069fc:	83 f8 02             	cmp    $0x2,%eax
c01069ff:	74 24                	je     c0106a25 <check_boot_pgdir+0x2a1>
c0106a01:	c7 44 24 0c a7 d1 10 	movl   $0xc010d1a7,0xc(%esp)
c0106a08:	c0 
c0106a09:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106a10:	c0 
c0106a11:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
c0106a18:	00 
c0106a19:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106a20:	e8 f0 a3 ff ff       	call   c0100e15 <__panic>

    const char *str = "ucore: Hello world!!";
c0106a25:	c7 45 dc b8 d1 10 c0 	movl   $0xc010d1b8,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0106a2c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a33:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106a3a:	e8 d6 4f 00 00       	call   c010ba15 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0106a3f:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0106a46:	00 
c0106a47:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106a4e:	e8 3b 50 00 00       	call   c010ba8e <strcmp>
c0106a53:	85 c0                	test   %eax,%eax
c0106a55:	74 24                	je     c0106a7b <check_boot_pgdir+0x2f7>
c0106a57:	c7 44 24 0c d0 d1 10 	movl   $0xc010d1d0,0xc(%esp)
c0106a5e:	c0 
c0106a5f:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106a66:	c0 
c0106a67:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
c0106a6e:	00 
c0106a6f:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106a76:	e8 9a a3 ff ff       	call   c0100e15 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0106a7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106a7e:	89 04 24             	mov    %eax,(%esp)
c0106a81:	e8 e1 e3 ff ff       	call   c0104e67 <page2kva>
c0106a86:	05 00 01 00 00       	add    $0x100,%eax
c0106a8b:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0106a8e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0106a95:	e8 23 4f 00 00       	call   c010b9bd <strlen>
c0106a9a:	85 c0                	test   %eax,%eax
c0106a9c:	74 24                	je     c0106ac2 <check_boot_pgdir+0x33e>
c0106a9e:	c7 44 24 0c 08 d2 10 	movl   $0xc010d208,0xc(%esp)
c0106aa5:	c0 
c0106aa6:	c7 44 24 08 31 cd 10 	movl   $0xc010cd31,0x8(%esp)
c0106aad:	c0 
c0106aae:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
c0106ab5:	00 
c0106ab6:	c7 04 24 0c cd 10 c0 	movl   $0xc010cd0c,(%esp)
c0106abd:	e8 53 a3 ff ff       	call   c0100e15 <__panic>

    free_page(p);
c0106ac2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ac9:	00 
c0106aca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106acd:	89 04 24             	mov    %eax,(%esp)
c0106ad0:	e8 ac e6 ff ff       	call   c0105181 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0106ad5:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106ada:	8b 00                	mov    (%eax),%eax
c0106adc:	89 04 24             	mov    %eax,(%esp)
c0106adf:	e8 15 e4 ff ff       	call   c0104ef9 <pde2page>
c0106ae4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106aeb:	00 
c0106aec:	89 04 24             	mov    %eax,(%esp)
c0106aef:	e8 8d e6 ff ff       	call   c0105181 <free_pages>
    boot_pgdir[0] = 0;
c0106af4:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0106af9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0106aff:	c7 04 24 2c d2 10 c0 	movl   $0xc010d22c,(%esp)
c0106b06:	e8 48 98 ff ff       	call   c0100353 <cprintf>
}
c0106b0b:	c9                   	leave  
c0106b0c:	c3                   	ret    

c0106b0d <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0106b0d:	55                   	push   %ebp
c0106b0e:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0106b10:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b13:	83 e0 04             	and    $0x4,%eax
c0106b16:	85 c0                	test   %eax,%eax
c0106b18:	74 07                	je     c0106b21 <perm2str+0x14>
c0106b1a:	b8 75 00 00 00       	mov    $0x75,%eax
c0106b1f:	eb 05                	jmp    c0106b26 <perm2str+0x19>
c0106b21:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106b26:	a2 68 cf 19 c0       	mov    %al,0xc019cf68
    str[1] = 'r';
c0106b2b:	c6 05 69 cf 19 c0 72 	movb   $0x72,0xc019cf69
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0106b32:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b35:	83 e0 02             	and    $0x2,%eax
c0106b38:	85 c0                	test   %eax,%eax
c0106b3a:	74 07                	je     c0106b43 <perm2str+0x36>
c0106b3c:	b8 77 00 00 00       	mov    $0x77,%eax
c0106b41:	eb 05                	jmp    c0106b48 <perm2str+0x3b>
c0106b43:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0106b48:	a2 6a cf 19 c0       	mov    %al,0xc019cf6a
    str[3] = '\0';
c0106b4d:	c6 05 6b cf 19 c0 00 	movb   $0x0,0xc019cf6b
    return str;
c0106b54:	b8 68 cf 19 c0       	mov    $0xc019cf68,%eax
}
c0106b59:	5d                   	pop    %ebp
c0106b5a:	c3                   	ret    

c0106b5b <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0106b5b:	55                   	push   %ebp
c0106b5c:	89 e5                	mov    %esp,%ebp
c0106b5e:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0106b61:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b64:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b67:	72 0a                	jb     c0106b73 <get_pgtable_items+0x18>
        return 0;
c0106b69:	b8 00 00 00 00       	mov    $0x0,%eax
c0106b6e:	e9 9c 00 00 00       	jmp    c0106c0f <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106b73:	eb 04                	jmp    c0106b79 <get_pgtable_items+0x1e>
        start ++;
c0106b75:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0106b79:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b7c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b7f:	73 18                	jae    c0106b99 <get_pgtable_items+0x3e>
c0106b81:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106b8b:	8b 45 14             	mov    0x14(%ebp),%eax
c0106b8e:	01 d0                	add    %edx,%eax
c0106b90:	8b 00                	mov    (%eax),%eax
c0106b92:	83 e0 01             	and    $0x1,%eax
c0106b95:	85 c0                	test   %eax,%eax
c0106b97:	74 dc                	je     c0106b75 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0106b99:	8b 45 10             	mov    0x10(%ebp),%eax
c0106b9c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106b9f:	73 69                	jae    c0106c0a <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0106ba1:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0106ba5:	74 08                	je     c0106baf <get_pgtable_items+0x54>
            *left_store = start;
c0106ba7:	8b 45 18             	mov    0x18(%ebp),%eax
c0106baa:	8b 55 10             	mov    0x10(%ebp),%edx
c0106bad:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0106baf:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bb2:	8d 50 01             	lea    0x1(%eax),%edx
c0106bb5:	89 55 10             	mov    %edx,0x10(%ebp)
c0106bb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106bbf:	8b 45 14             	mov    0x14(%ebp),%eax
c0106bc2:	01 d0                	add    %edx,%eax
c0106bc4:	8b 00                	mov    (%eax),%eax
c0106bc6:	83 e0 07             	and    $0x7,%eax
c0106bc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106bcc:	eb 04                	jmp    c0106bd2 <get_pgtable_items+0x77>
            start ++;
c0106bce:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0106bd2:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bd5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106bd8:	73 1d                	jae    c0106bf7 <get_pgtable_items+0x9c>
c0106bda:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bdd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106be4:	8b 45 14             	mov    0x14(%ebp),%eax
c0106be7:	01 d0                	add    %edx,%eax
c0106be9:	8b 00                	mov    (%eax),%eax
c0106beb:	83 e0 07             	and    $0x7,%eax
c0106bee:	89 c2                	mov    %eax,%edx
c0106bf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106bf3:	39 c2                	cmp    %eax,%edx
c0106bf5:	74 d7                	je     c0106bce <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0106bf7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0106bfb:	74 08                	je     c0106c05 <get_pgtable_items+0xaa>
            *right_store = start;
c0106bfd:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106c00:	8b 55 10             	mov    0x10(%ebp),%edx
c0106c03:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0106c05:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c08:	eb 05                	jmp    c0106c0f <get_pgtable_items+0xb4>
    }
    return 0;
c0106c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c0f:	c9                   	leave  
c0106c10:	c3                   	ret    

c0106c11 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0106c11:	55                   	push   %ebp
c0106c12:	89 e5                	mov    %esp,%ebp
c0106c14:	57                   	push   %edi
c0106c15:	56                   	push   %esi
c0106c16:	53                   	push   %ebx
c0106c17:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0106c1a:	c7 04 24 4c d2 10 c0 	movl   $0xc010d24c,(%esp)
c0106c21:	e8 2d 97 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
c0106c26:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106c2d:	e9 fa 00 00 00       	jmp    c0106d2c <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106c32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c35:	89 04 24             	mov    %eax,(%esp)
c0106c38:	e8 d0 fe ff ff       	call   c0106b0d <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0106c3d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106c40:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106c43:	29 d1                	sub    %edx,%ecx
c0106c45:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0106c47:	89 d6                	mov    %edx,%esi
c0106c49:	c1 e6 16             	shl    $0x16,%esi
c0106c4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106c4f:	89 d3                	mov    %edx,%ebx
c0106c51:	c1 e3 16             	shl    $0x16,%ebx
c0106c54:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106c57:	89 d1                	mov    %edx,%ecx
c0106c59:	c1 e1 16             	shl    $0x16,%ecx
c0106c5c:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0106c5f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106c62:	29 d7                	sub    %edx,%edi
c0106c64:	89 fa                	mov    %edi,%edx
c0106c66:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106c6a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106c6e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106c72:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106c76:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c7a:	c7 04 24 7d d2 10 c0 	movl   $0xc010d27d,(%esp)
c0106c81:	e8 cd 96 ff ff       	call   c0100353 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0106c86:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c89:	c1 e0 0a             	shl    $0xa,%eax
c0106c8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106c8f:	eb 54                	jmp    c0106ce5 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106c91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c94:	89 04 24             	mov    %eax,(%esp)
c0106c97:	e8 71 fe ff ff       	call   c0106b0d <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0106c9c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0106c9f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106ca2:	29 d1                	sub    %edx,%ecx
c0106ca4:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0106ca6:	89 d6                	mov    %edx,%esi
c0106ca8:	c1 e6 0c             	shl    $0xc,%esi
c0106cab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106cae:	89 d3                	mov    %edx,%ebx
c0106cb0:	c1 e3 0c             	shl    $0xc,%ebx
c0106cb3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106cb6:	c1 e2 0c             	shl    $0xc,%edx
c0106cb9:	89 d1                	mov    %edx,%ecx
c0106cbb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0106cbe:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106cc1:	29 d7                	sub    %edx,%edi
c0106cc3:	89 fa                	mov    %edi,%edx
c0106cc5:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106cc9:	89 74 24 10          	mov    %esi,0x10(%esp)
c0106ccd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0106cd1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0106cd5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106cd9:	c7 04 24 9c d2 10 c0 	movl   $0xc010d29c,(%esp)
c0106ce0:	e8 6e 96 ff ff       	call   c0100353 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0106ce5:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0106cea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106ced:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0106cf0:	89 ce                	mov    %ecx,%esi
c0106cf2:	c1 e6 0a             	shl    $0xa,%esi
c0106cf5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0106cf8:	89 cb                	mov    %ecx,%ebx
c0106cfa:	c1 e3 0a             	shl    $0xa,%ebx
c0106cfd:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0106d00:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106d04:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0106d07:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106d0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106d0f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d13:	89 74 24 04          	mov    %esi,0x4(%esp)
c0106d17:	89 1c 24             	mov    %ebx,(%esp)
c0106d1a:	e8 3c fe ff ff       	call   c0106b5b <get_pgtable_items>
c0106d1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106d22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106d26:	0f 85 65 ff ff ff    	jne    c0106c91 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0106d2c:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0106d31:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106d34:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0106d37:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0106d3b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0106d3e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0106d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106d46:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d4a:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0106d51:	00 
c0106d52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0106d59:	e8 fd fd ff ff       	call   c0106b5b <get_pgtable_items>
c0106d5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106d61:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106d65:	0f 85 c7 fe ff ff    	jne    c0106c32 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0106d6b:	c7 04 24 c0 d2 10 c0 	movl   $0xc010d2c0,(%esp)
c0106d72:	e8 dc 95 ff ff       	call   c0100353 <cprintf>
}
c0106d77:	83 c4 4c             	add    $0x4c,%esp
c0106d7a:	5b                   	pop    %ebx
c0106d7b:	5e                   	pop    %esi
c0106d7c:	5f                   	pop    %edi
c0106d7d:	5d                   	pop    %ebp
c0106d7e:	c3                   	ret    

c0106d7f <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0106d7f:	55                   	push   %ebp
c0106d80:	89 e5                	mov    %esp,%ebp
c0106d82:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106d85:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d88:	c1 e8 0c             	shr    $0xc,%eax
c0106d8b:	89 c2                	mov    %eax,%edx
c0106d8d:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0106d92:	39 c2                	cmp    %eax,%edx
c0106d94:	72 1c                	jb     c0106db2 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106d96:	c7 44 24 08 f4 d2 10 	movl   $0xc010d2f4,0x8(%esp)
c0106d9d:	c0 
c0106d9e:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106da5:	00 
c0106da6:	c7 04 24 13 d3 10 c0 	movl   $0xc010d313,(%esp)
c0106dad:	e8 63 a0 ff ff       	call   c0100e15 <__panic>
    }
    return &pages[PPN(pa)];
c0106db2:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0106db7:	8b 55 08             	mov    0x8(%ebp),%edx
c0106dba:	c1 ea 0c             	shr    $0xc,%edx
c0106dbd:	c1 e2 05             	shl    $0x5,%edx
c0106dc0:	01 d0                	add    %edx,%eax
}
c0106dc2:	c9                   	leave  
c0106dc3:	c3                   	ret    

c0106dc4 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0106dc4:	55                   	push   %ebp
c0106dc5:	89 e5                	mov    %esp,%ebp
c0106dc7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dcd:	83 e0 01             	and    $0x1,%eax
c0106dd0:	85 c0                	test   %eax,%eax
c0106dd2:	75 1c                	jne    c0106df0 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106dd4:	c7 44 24 08 24 d3 10 	movl   $0xc010d324,0x8(%esp)
c0106ddb:	c0 
c0106ddc:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106de3:	00 
c0106de4:	c7 04 24 13 d3 10 c0 	movl   $0xc010d313,(%esp)
c0106deb:	e8 25 a0 ff ff       	call   c0100e15 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106df0:	8b 45 08             	mov    0x8(%ebp),%eax
c0106df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106df8:	89 04 24             	mov    %eax,(%esp)
c0106dfb:	e8 7f ff ff ff       	call   c0106d7f <pa2page>
}
c0106e00:	c9                   	leave  
c0106e01:	c3                   	ret    

c0106e02 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106e02:	55                   	push   %ebp
c0106e03:	89 e5                	mov    %esp,%ebp
c0106e05:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106e08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106e10:	89 04 24             	mov    %eax,(%esp)
c0106e13:	e8 67 ff ff ff       	call   c0106d7f <pa2page>
}
c0106e18:	c9                   	leave  
c0106e19:	c3                   	ret    

c0106e1a <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0106e1a:	55                   	push   %ebp
c0106e1b:	89 e5                	mov    %esp,%ebp
c0106e1d:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0106e20:	e8 7a 23 00 00       	call   c010919f <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0106e25:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106e2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0106e2f:	76 0c                	jbe    c0106e3d <swap_init+0x23>
c0106e31:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106e36:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0106e3b:	76 25                	jbe    c0106e62 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0106e3d:	a1 7c f0 19 c0       	mov    0xc019f07c,%eax
c0106e42:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106e46:	c7 44 24 08 45 d3 10 	movl   $0xc010d345,0x8(%esp)
c0106e4d:	c0 
c0106e4e:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c0106e55:	00 
c0106e56:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0106e5d:	e8 b3 9f ff ff       	call   c0100e15 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0106e62:	c7 05 74 cf 19 c0 60 	movl   $0xc012aa60,0xc019cf74
c0106e69:	aa 12 c0 
     int r = sm->init();
c0106e6c:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e71:	8b 40 04             	mov    0x4(%eax),%eax
c0106e74:	ff d0                	call   *%eax
c0106e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0106e79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106e7d:	75 26                	jne    c0106ea5 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106e7f:	c7 05 6c cf 19 c0 01 	movl   $0x1,0xc019cf6c
c0106e86:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0106e89:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106e8e:	8b 00                	mov    (%eax),%eax
c0106e90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106e94:	c7 04 24 6f d3 10 c0 	movl   $0xc010d36f,(%esp)
c0106e9b:	e8 b3 94 ff ff       	call   c0100353 <cprintf>
          check_swap();
c0106ea0:	e8 a4 04 00 00       	call   c0107349 <check_swap>
     }

     return r;
c0106ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106ea8:	c9                   	leave  
c0106ea9:	c3                   	ret    

c0106eaa <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0106eaa:	55                   	push   %ebp
c0106eab:	89 e5                	mov    %esp,%ebp
c0106ead:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106eb0:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106eb5:	8b 40 08             	mov    0x8(%eax),%eax
c0106eb8:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ebb:	89 14 24             	mov    %edx,(%esp)
c0106ebe:	ff d0                	call   *%eax
}
c0106ec0:	c9                   	leave  
c0106ec1:	c3                   	ret    

c0106ec2 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106ec2:	55                   	push   %ebp
c0106ec3:	89 e5                	mov    %esp,%ebp
c0106ec5:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0106ec8:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106ecd:	8b 40 0c             	mov    0xc(%eax),%eax
c0106ed0:	8b 55 08             	mov    0x8(%ebp),%edx
c0106ed3:	89 14 24             	mov    %edx,(%esp)
c0106ed6:	ff d0                	call   *%eax
}
c0106ed8:	c9                   	leave  
c0106ed9:	c3                   	ret    

c0106eda <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106eda:	55                   	push   %ebp
c0106edb:	89 e5                	mov    %esp,%ebp
c0106edd:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106ee0:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106ee5:	8b 40 10             	mov    0x10(%eax),%eax
c0106ee8:	8b 55 14             	mov    0x14(%ebp),%edx
c0106eeb:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106eef:	8b 55 10             	mov    0x10(%ebp),%edx
c0106ef2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106ef9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106efd:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f00:	89 14 24             	mov    %edx,(%esp)
c0106f03:	ff d0                	call   *%eax
}
c0106f05:	c9                   	leave  
c0106f06:	c3                   	ret    

c0106f07 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106f07:	55                   	push   %ebp
c0106f08:	89 e5                	mov    %esp,%ebp
c0106f0a:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0106f0d:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106f12:	8b 40 14             	mov    0x14(%eax),%eax
c0106f15:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106f18:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f1c:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f1f:	89 14 24             	mov    %edx,(%esp)
c0106f22:	ff d0                	call   *%eax
}
c0106f24:	c9                   	leave  
c0106f25:	c3                   	ret    

c0106f26 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0106f26:	55                   	push   %ebp
c0106f27:	89 e5                	mov    %esp,%ebp
c0106f29:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0106f2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106f33:	e9 5a 01 00 00       	jmp    c0107092 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0106f38:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0106f3d:	8b 40 18             	mov    0x18(%eax),%eax
c0106f40:	8b 55 10             	mov    0x10(%ebp),%edx
c0106f43:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106f47:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0106f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f4e:	8b 55 08             	mov    0x8(%ebp),%edx
c0106f51:	89 14 24             	mov    %edx,(%esp)
c0106f54:	ff d0                	call   *%eax
c0106f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0106f59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106f5d:	74 18                	je     c0106f77 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0106f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106f66:	c7 04 24 84 d3 10 c0 	movl   $0xc010d384,(%esp)
c0106f6d:	e8 e1 93 ff ff       	call   c0100353 <cprintf>
c0106f72:	e9 27 01 00 00       	jmp    c010709e <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0106f77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f7a:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106f7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106f80:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f83:	8b 40 0c             	mov    0xc(%eax),%eax
c0106f86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106f8d:	00 
c0106f8e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f91:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f95:	89 04 24             	mov    %eax,(%esp)
c0106f98:	e8 e0 e8 ff ff       	call   c010587d <get_pte>
c0106f9d:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106fa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106fa3:	8b 00                	mov    (%eax),%eax
c0106fa5:	83 e0 01             	and    $0x1,%eax
c0106fa8:	85 c0                	test   %eax,%eax
c0106faa:	75 24                	jne    c0106fd0 <swap_out+0xaa>
c0106fac:	c7 44 24 0c b1 d3 10 	movl   $0xc010d3b1,0xc(%esp)
c0106fb3:	c0 
c0106fb4:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0106fbb:	c0 
c0106fbc:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106fc3:	00 
c0106fc4:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0106fcb:	e8 45 9e ff ff       	call   c0100e15 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106fd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106fd3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106fd6:	8b 52 1c             	mov    0x1c(%edx),%edx
c0106fd9:	c1 ea 0c             	shr    $0xc,%edx
c0106fdc:	83 c2 01             	add    $0x1,%edx
c0106fdf:	c1 e2 08             	shl    $0x8,%edx
c0106fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106fe6:	89 14 24             	mov    %edx,(%esp)
c0106fe9:	e8 6b 22 00 00       	call   c0109259 <swapfs_write>
c0106fee:	85 c0                	test   %eax,%eax
c0106ff0:	74 34                	je     c0107026 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0106ff2:	c7 04 24 db d3 10 c0 	movl   $0xc010d3db,(%esp)
c0106ff9:	e8 55 93 ff ff       	call   c0100353 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106ffe:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c0107003:	8b 40 10             	mov    0x10(%eax),%eax
c0107006:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107009:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107010:	00 
c0107011:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107015:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107018:	89 54 24 04          	mov    %edx,0x4(%esp)
c010701c:	8b 55 08             	mov    0x8(%ebp),%edx
c010701f:	89 14 24             	mov    %edx,(%esp)
c0107022:	ff d0                	call   *%eax
c0107024:	eb 68                	jmp    c010708e <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0107026:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107029:	8b 40 1c             	mov    0x1c(%eax),%eax
c010702c:	c1 e8 0c             	shr    $0xc,%eax
c010702f:	83 c0 01             	add    $0x1,%eax
c0107032:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107036:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107039:	89 44 24 08          	mov    %eax,0x8(%esp)
c010703d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107040:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107044:	c7 04 24 f4 d3 10 c0 	movl   $0xc010d3f4,(%esp)
c010704b:	e8 03 93 ff ff       	call   c0100353 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0107050:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107053:	8b 40 1c             	mov    0x1c(%eax),%eax
c0107056:	c1 e8 0c             	shr    $0xc,%eax
c0107059:	83 c0 01             	add    $0x1,%eax
c010705c:	c1 e0 08             	shl    $0x8,%eax
c010705f:	89 c2                	mov    %eax,%edx
c0107061:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107064:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0107066:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107069:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107070:	00 
c0107071:	89 04 24             	mov    %eax,(%esp)
c0107074:	e8 08 e1 ff ff       	call   c0105181 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0107079:	8b 45 08             	mov    0x8(%ebp),%eax
c010707c:	8b 40 0c             	mov    0xc(%eax),%eax
c010707f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107082:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107086:	89 04 24             	mov    %eax,(%esp)
c0107089:	e8 0c ef ff ff       	call   c0105f9a <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c010708e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107092:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107095:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107098:	0f 85 9a fe ff ff    	jne    c0106f38 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c010709e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01070a1:	c9                   	leave  
c01070a2:	c3                   	ret    

c01070a3 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01070a3:	55                   	push   %ebp
c01070a4:	89 e5                	mov    %esp,%ebp
c01070a6:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c01070a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01070b0:	e8 61 e0 ff ff       	call   c0105116 <alloc_pages>
c01070b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c01070b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01070bc:	75 24                	jne    c01070e2 <swap_in+0x3f>
c01070be:	c7 44 24 0c 34 d4 10 	movl   $0xc010d434,0xc(%esp)
c01070c5:	c0 
c01070c6:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01070cd:	c0 
c01070ce:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01070d5:	00 
c01070d6:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01070dd:	e8 33 9d ff ff       	call   c0100e15 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01070e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01070e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01070e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01070ef:	00 
c01070f0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01070f3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01070f7:	89 04 24             	mov    %eax,(%esp)
c01070fa:	e8 7e e7 ff ff       	call   c010587d <get_pte>
c01070ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107102:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107105:	8b 00                	mov    (%eax),%eax
c0107107:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010710a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010710e:	89 04 24             	mov    %eax,(%esp)
c0107111:	e8 d1 20 00 00       	call   c01091e7 <swapfs_read>
c0107116:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107119:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010711d:	74 2a                	je     c0107149 <swap_in+0xa6>
     {
        assert(r!=0);
c010711f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107123:	75 24                	jne    c0107149 <swap_in+0xa6>
c0107125:	c7 44 24 0c 41 d4 10 	movl   $0xc010d441,0xc(%esp)
c010712c:	c0 
c010712d:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107134:	c0 
c0107135:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c010713c:	00 
c010713d:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107144:	e8 cc 9c ff ff       	call   c0100e15 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0107149:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010714c:	8b 00                	mov    (%eax),%eax
c010714e:	c1 e8 08             	shr    $0x8,%eax
c0107151:	89 c2                	mov    %eax,%edx
c0107153:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107156:	89 44 24 08          	mov    %eax,0x8(%esp)
c010715a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010715e:	c7 04 24 48 d4 10 c0 	movl   $0xc010d448,(%esp)
c0107165:	e8 e9 91 ff ff       	call   c0100353 <cprintf>
     *ptr_result=result;
c010716a:	8b 45 10             	mov    0x10(%ebp),%eax
c010716d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107170:	89 10                	mov    %edx,(%eax)
     return 0;
c0107172:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107177:	c9                   	leave  
c0107178:	c3                   	ret    

c0107179 <check_content_set>:



static inline void
check_content_set(void)
{
c0107179:	55                   	push   %ebp
c010717a:	89 e5                	mov    %esp,%ebp
c010717c:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c010717f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107184:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107187:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c010718c:	83 f8 01             	cmp    $0x1,%eax
c010718f:	74 24                	je     c01071b5 <check_content_set+0x3c>
c0107191:	c7 44 24 0c 86 d4 10 	movl   $0xc010d486,0xc(%esp)
c0107198:	c0 
c0107199:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01071a0:	c0 
c01071a1:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01071a8:	00 
c01071a9:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01071b0:	e8 60 9c ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01071b5:	b8 10 10 00 00       	mov    $0x1010,%eax
c01071ba:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01071bd:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01071c2:	83 f8 01             	cmp    $0x1,%eax
c01071c5:	74 24                	je     c01071eb <check_content_set+0x72>
c01071c7:	c7 44 24 0c 86 d4 10 	movl   $0xc010d486,0xc(%esp)
c01071ce:	c0 
c01071cf:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01071d6:	c0 
c01071d7:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01071de:	00 
c01071df:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01071e6:	e8 2a 9c ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01071eb:	b8 00 20 00 00       	mov    $0x2000,%eax
c01071f0:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01071f3:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01071f8:	83 f8 02             	cmp    $0x2,%eax
c01071fb:	74 24                	je     c0107221 <check_content_set+0xa8>
c01071fd:	c7 44 24 0c 95 d4 10 	movl   $0xc010d495,0xc(%esp)
c0107204:	c0 
c0107205:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c010720c:	c0 
c010720d:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0107214:	00 
c0107215:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c010721c:	e8 f4 9b ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0107221:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107226:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107229:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c010722e:	83 f8 02             	cmp    $0x2,%eax
c0107231:	74 24                	je     c0107257 <check_content_set+0xde>
c0107233:	c7 44 24 0c 95 d4 10 	movl   $0xc010d495,0xc(%esp)
c010723a:	c0 
c010723b:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107242:	c0 
c0107243:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c010724a:	00 
c010724b:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107252:	e8 be 9b ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0107257:	b8 00 30 00 00       	mov    $0x3000,%eax
c010725c:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010725f:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107264:	83 f8 03             	cmp    $0x3,%eax
c0107267:	74 24                	je     c010728d <check_content_set+0x114>
c0107269:	c7 44 24 0c a4 d4 10 	movl   $0xc010d4a4,0xc(%esp)
c0107270:	c0 
c0107271:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107278:	c0 
c0107279:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0107280:	00 
c0107281:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107288:	e8 88 9b ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010728d:	b8 10 30 00 00       	mov    $0x3010,%eax
c0107292:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107295:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c010729a:	83 f8 03             	cmp    $0x3,%eax
c010729d:	74 24                	je     c01072c3 <check_content_set+0x14a>
c010729f:	c7 44 24 0c a4 d4 10 	movl   $0xc010d4a4,0xc(%esp)
c01072a6:	c0 
c01072a7:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01072ae:	c0 
c01072af:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01072b6:	00 
c01072b7:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01072be:	e8 52 9b ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01072c3:	b8 00 40 00 00       	mov    $0x4000,%eax
c01072c8:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01072cb:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c01072d0:	83 f8 04             	cmp    $0x4,%eax
c01072d3:	74 24                	je     c01072f9 <check_content_set+0x180>
c01072d5:	c7 44 24 0c b3 d4 10 	movl   $0xc010d4b3,0xc(%esp)
c01072dc:	c0 
c01072dd:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01072e4:	c0 
c01072e5:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01072ec:	00 
c01072ed:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01072f4:	e8 1c 9b ff ff       	call   c0100e15 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01072f9:	b8 10 40 00 00       	mov    $0x4010,%eax
c01072fe:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0107301:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107306:	83 f8 04             	cmp    $0x4,%eax
c0107309:	74 24                	je     c010732f <check_content_set+0x1b6>
c010730b:	c7 44 24 0c b3 d4 10 	movl   $0xc010d4b3,0xc(%esp)
c0107312:	c0 
c0107313:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c010731a:	c0 
c010731b:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0107322:	00 
c0107323:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c010732a:	e8 e6 9a ff ff       	call   c0100e15 <__panic>
}
c010732f:	c9                   	leave  
c0107330:	c3                   	ret    

c0107331 <check_content_access>:

static inline int
check_content_access(void)
{
c0107331:	55                   	push   %ebp
c0107332:	89 e5                	mov    %esp,%ebp
c0107334:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0107337:	a1 74 cf 19 c0       	mov    0xc019cf74,%eax
c010733c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010733f:	ff d0                	call   *%eax
c0107341:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0107344:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107347:	c9                   	leave  
c0107348:	c3                   	ret    

c0107349 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0107349:	55                   	push   %ebp
c010734a:	89 e5                	mov    %esp,%ebp
c010734c:	53                   	push   %ebx
c010734d:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0107350:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107357:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010735e:	c7 45 e8 b8 ef 19 c0 	movl   $0xc019efb8,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107365:	eb 6b                	jmp    c01073d2 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c0107367:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010736a:	83 e8 0c             	sub    $0xc,%eax
c010736d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0107370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107373:	83 c0 04             	add    $0x4,%eax
c0107376:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c010737d:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107380:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107383:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107386:	0f a3 10             	bt     %edx,(%eax)
c0107389:	19 c0                	sbb    %eax,%eax
c010738b:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c010738e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107392:	0f 95 c0             	setne  %al
c0107395:	0f b6 c0             	movzbl %al,%eax
c0107398:	85 c0                	test   %eax,%eax
c010739a:	75 24                	jne    c01073c0 <check_swap+0x77>
c010739c:	c7 44 24 0c c2 d4 10 	movl   $0xc010d4c2,0xc(%esp)
c01073a3:	c0 
c01073a4:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01073ab:	c0 
c01073ac:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01073b3:	00 
c01073b4:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01073bb:	e8 55 9a ff ff       	call   c0100e15 <__panic>
        count ++, total += p->property;
c01073c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01073c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073c7:	8b 50 08             	mov    0x8(%eax),%edx
c01073ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073cd:	01 d0                	add    %edx,%eax
c01073cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01073d5:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01073d8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01073db:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01073de:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01073e1:	81 7d e8 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x18(%ebp)
c01073e8:	0f 85 79 ff ff ff    	jne    c0107367 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01073ee:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01073f1:	e8 bd dd ff ff       	call   c01051b3 <nr_free_pages>
c01073f6:	39 c3                	cmp    %eax,%ebx
c01073f8:	74 24                	je     c010741e <check_swap+0xd5>
c01073fa:	c7 44 24 0c d2 d4 10 	movl   $0xc010d4d2,0xc(%esp)
c0107401:	c0 
c0107402:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107409:	c0 
c010740a:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0107411:	00 
c0107412:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107419:	e8 f7 99 ff ff       	call   c0100e15 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010741e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107421:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107425:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107428:	89 44 24 04          	mov    %eax,0x4(%esp)
c010742c:	c7 04 24 ec d4 10 c0 	movl   $0xc010d4ec,(%esp)
c0107433:	e8 1b 8f ff ff       	call   c0100353 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0107438:	e8 1e 0b 00 00       	call   c0107f5b <mm_create>
c010743d:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c0107440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107444:	75 24                	jne    c010746a <check_swap+0x121>
c0107446:	c7 44 24 0c 12 d5 10 	movl   $0xc010d512,0xc(%esp)
c010744d:	c0 
c010744e:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107455:	c0 
c0107456:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c010745d:	00 
c010745e:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107465:	e8 ab 99 ff ff       	call   c0100e15 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010746a:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c010746f:	85 c0                	test   %eax,%eax
c0107471:	74 24                	je     c0107497 <check_swap+0x14e>
c0107473:	c7 44 24 0c 1d d5 10 	movl   $0xc010d51d,0xc(%esp)
c010747a:	c0 
c010747b:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107482:	c0 
c0107483:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c010748a:	00 
c010748b:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107492:	e8 7e 99 ff ff       	call   c0100e15 <__panic>

     check_mm_struct = mm;
c0107497:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010749a:	a3 ac f0 19 c0       	mov    %eax,0xc019f0ac

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010749f:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c01074a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074a8:	89 50 0c             	mov    %edx,0xc(%eax)
c01074ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01074ae:	8b 40 0c             	mov    0xc(%eax),%eax
c01074b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c01074b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074b7:	8b 00                	mov    (%eax),%eax
c01074b9:	85 c0                	test   %eax,%eax
c01074bb:	74 24                	je     c01074e1 <check_swap+0x198>
c01074bd:	c7 44 24 0c 35 d5 10 	movl   $0xc010d535,0xc(%esp)
c01074c4:	c0 
c01074c5:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01074cc:	c0 
c01074cd:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01074d4:	00 
c01074d5:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01074dc:	e8 34 99 ff ff       	call   c0100e15 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01074e1:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01074e8:	00 
c01074e9:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01074f0:	00 
c01074f1:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01074f8:	e8 f7 0a 00 00       	call   c0107ff4 <vma_create>
c01074fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0107500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0107504:	75 24                	jne    c010752a <check_swap+0x1e1>
c0107506:	c7 44 24 0c 43 d5 10 	movl   $0xc010d543,0xc(%esp)
c010750d:	c0 
c010750e:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107515:	c0 
c0107516:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010751d:	00 
c010751e:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107525:	e8 eb 98 ff ff       	call   c0100e15 <__panic>

     insert_vma_struct(mm, vma);
c010752a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010752d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107531:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107534:	89 04 24             	mov    %eax,(%esp)
c0107537:	e8 48 0c 00 00       	call   c0108184 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010753c:	c7 04 24 50 d5 10 c0 	movl   $0xc010d550,(%esp)
c0107543:	e8 0b 8e ff ff       	call   c0100353 <cprintf>
     pte_t *temp_ptep=NULL;
c0107548:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010754f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107552:	8b 40 0c             	mov    0xc(%eax),%eax
c0107555:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010755c:	00 
c010755d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107564:	00 
c0107565:	89 04 24             	mov    %eax,(%esp)
c0107568:	e8 10 e3 ff ff       	call   c010587d <get_pte>
c010756d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0107570:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0107574:	75 24                	jne    c010759a <check_swap+0x251>
c0107576:	c7 44 24 0c 84 d5 10 	movl   $0xc010d584,0xc(%esp)
c010757d:	c0 
c010757e:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107585:	c0 
c0107586:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010758d:	00 
c010758e:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107595:	e8 7b 98 ff ff       	call   c0100e15 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c010759a:	c7 04 24 98 d5 10 c0 	movl   $0xc010d598,(%esp)
c01075a1:	e8 ad 8d ff ff       	call   c0100353 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01075a6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01075ad:	e9 a3 00 00 00       	jmp    c0107655 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c01075b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01075b9:	e8 58 db ff ff       	call   c0105116 <alloc_pages>
c01075be:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01075c1:	89 04 95 e0 ef 19 c0 	mov    %eax,-0x3fe61020(,%edx,4)
          assert(check_rp[i] != NULL );
c01075c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075cb:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c01075d2:	85 c0                	test   %eax,%eax
c01075d4:	75 24                	jne    c01075fa <check_swap+0x2b1>
c01075d6:	c7 44 24 0c bc d5 10 	movl   $0xc010d5bc,0xc(%esp)
c01075dd:	c0 
c01075de:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01075e5:	c0 
c01075e6:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c01075ed:	00 
c01075ee:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01075f5:	e8 1b 98 ff ff       	call   c0100e15 <__panic>
          assert(!PageProperty(check_rp[i]));
c01075fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075fd:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c0107604:	83 c0 04             	add    $0x4,%eax
c0107607:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c010760e:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107611:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107614:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107617:	0f a3 10             	bt     %edx,(%eax)
c010761a:	19 c0                	sbb    %eax,%eax
c010761c:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c010761f:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c0107623:	0f 95 c0             	setne  %al
c0107626:	0f b6 c0             	movzbl %al,%eax
c0107629:	85 c0                	test   %eax,%eax
c010762b:	74 24                	je     c0107651 <check_swap+0x308>
c010762d:	c7 44 24 0c d0 d5 10 	movl   $0xc010d5d0,0xc(%esp)
c0107634:	c0 
c0107635:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c010763c:	c0 
c010763d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0107644:	00 
c0107645:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c010764c:	e8 c4 97 ff ff       	call   c0100e15 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107651:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107655:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107659:	0f 8e 53 ff ff ff    	jle    c01075b2 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c010765f:	a1 b8 ef 19 c0       	mov    0xc019efb8,%eax
c0107664:	8b 15 bc ef 19 c0    	mov    0xc019efbc,%edx
c010766a:	89 45 98             	mov    %eax,-0x68(%ebp)
c010766d:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0107670:	c7 45 a8 b8 ef 19 c0 	movl   $0xc019efb8,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107677:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010767a:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010767d:	89 50 04             	mov    %edx,0x4(%eax)
c0107680:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107683:	8b 50 04             	mov    0x4(%eax),%edx
c0107686:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107689:	89 10                	mov    %edx,(%eax)
c010768b:	c7 45 a4 b8 ef 19 c0 	movl   $0xc019efb8,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0107692:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107695:	8b 40 04             	mov    0x4(%eax),%eax
c0107698:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c010769b:	0f 94 c0             	sete   %al
c010769e:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c01076a1:	85 c0                	test   %eax,%eax
c01076a3:	75 24                	jne    c01076c9 <check_swap+0x380>
c01076a5:	c7 44 24 0c eb d5 10 	movl   $0xc010d5eb,0xc(%esp)
c01076ac:	c0 
c01076ad:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01076b4:	c0 
c01076b5:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c01076bc:	00 
c01076bd:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01076c4:	e8 4c 97 ff ff       	call   c0100e15 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01076c9:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c01076ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c01076d1:	c7 05 c0 ef 19 c0 00 	movl   $0x0,0xc019efc0
c01076d8:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01076db:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01076e2:	eb 1e                	jmp    c0107702 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01076e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01076e7:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c01076ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01076f5:	00 
c01076f6:	89 04 24             	mov    %eax,(%esp)
c01076f9:	e8 83 da ff ff       	call   c0105181 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01076fe:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107702:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0107706:	7e dc                	jle    c01076e4 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0107708:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c010770d:	83 f8 04             	cmp    $0x4,%eax
c0107710:	74 24                	je     c0107736 <check_swap+0x3ed>
c0107712:	c7 44 24 0c 04 d6 10 	movl   $0xc010d604,0xc(%esp)
c0107719:	c0 
c010771a:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107721:	c0 
c0107722:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0107729:	00 
c010772a:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107731:	e8 df 96 ff ff       	call   c0100e15 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0107736:	c7 04 24 28 d6 10 c0 	movl   $0xc010d628,(%esp)
c010773d:	e8 11 8c ff ff       	call   c0100353 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0107742:	c7 05 78 cf 19 c0 00 	movl   $0x0,0xc019cf78
c0107749:	00 00 00 
     
     check_content_set();
c010774c:	e8 28 fa ff ff       	call   c0107179 <check_content_set>
     assert( nr_free == 0);         
c0107751:	a1 c0 ef 19 c0       	mov    0xc019efc0,%eax
c0107756:	85 c0                	test   %eax,%eax
c0107758:	74 24                	je     c010777e <check_swap+0x435>
c010775a:	c7 44 24 0c 4f d6 10 	movl   $0xc010d64f,0xc(%esp)
c0107761:	c0 
c0107762:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107769:	c0 
c010776a:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0107771:	00 
c0107772:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107779:	e8 97 96 ff ff       	call   c0100e15 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010777e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0107785:	eb 26                	jmp    c01077ad <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0107787:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010778a:	c7 04 85 00 f0 19 c0 	movl   $0xffffffff,-0x3fe61000(,%eax,4)
c0107791:	ff ff ff ff 
c0107795:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107798:	8b 14 85 00 f0 19 c0 	mov    -0x3fe61000(,%eax,4),%edx
c010779f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077a2:	89 14 85 40 f0 19 c0 	mov    %edx,-0x3fe60fc0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01077a9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01077ad:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c01077b1:	7e d4                	jle    c0107787 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01077b3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01077ba:	e9 eb 00 00 00       	jmp    c01078aa <check_swap+0x561>
         check_ptep[i]=0;
c01077bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077c2:	c7 04 85 94 f0 19 c0 	movl   $0x0,-0x3fe60f6c(,%eax,4)
c01077c9:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01077cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077d0:	83 c0 01             	add    $0x1,%eax
c01077d3:	c1 e0 0c             	shl    $0xc,%eax
c01077d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01077dd:	00 
c01077de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01077e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01077e5:	89 04 24             	mov    %eax,(%esp)
c01077e8:	e8 90 e0 ff ff       	call   c010587d <get_pte>
c01077ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01077f0:	89 04 95 94 f0 19 c0 	mov    %eax,-0x3fe60f6c(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01077f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077fa:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c0107801:	85 c0                	test   %eax,%eax
c0107803:	75 24                	jne    c0107829 <check_swap+0x4e0>
c0107805:	c7 44 24 0c 5c d6 10 	movl   $0xc010d65c,0xc(%esp)
c010780c:	c0 
c010780d:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107814:	c0 
c0107815:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010781c:	00 
c010781d:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c0107824:	e8 ec 95 ff ff       	call   c0100e15 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0107829:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010782c:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c0107833:	8b 00                	mov    (%eax),%eax
c0107835:	89 04 24             	mov    %eax,(%esp)
c0107838:	e8 87 f5 ff ff       	call   c0106dc4 <pte2page>
c010783d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107840:	8b 14 95 e0 ef 19 c0 	mov    -0x3fe61020(,%edx,4),%edx
c0107847:	39 d0                	cmp    %edx,%eax
c0107849:	74 24                	je     c010786f <check_swap+0x526>
c010784b:	c7 44 24 0c 74 d6 10 	movl   $0xc010d674,0xc(%esp)
c0107852:	c0 
c0107853:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c010785a:	c0 
c010785b:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0107862:	00 
c0107863:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c010786a:	e8 a6 95 ff ff       	call   c0100e15 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010786f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107872:	8b 04 85 94 f0 19 c0 	mov    -0x3fe60f6c(,%eax,4),%eax
c0107879:	8b 00                	mov    (%eax),%eax
c010787b:	83 e0 01             	and    $0x1,%eax
c010787e:	85 c0                	test   %eax,%eax
c0107880:	75 24                	jne    c01078a6 <check_swap+0x55d>
c0107882:	c7 44 24 0c 9c d6 10 	movl   $0xc010d69c,0xc(%esp)
c0107889:	c0 
c010788a:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c0107891:	c0 
c0107892:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0107899:	00 
c010789a:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01078a1:	e8 6f 95 ff ff       	call   c0100e15 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01078a6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01078aa:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01078ae:	0f 8e 0b ff ff ff    	jle    c01077bf <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c01078b4:	c7 04 24 b8 d6 10 c0 	movl   $0xc010d6b8,(%esp)
c01078bb:	e8 93 8a ff ff       	call   c0100353 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01078c0:	e8 6c fa ff ff       	call   c0107331 <check_content_access>
c01078c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c01078c8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01078cc:	74 24                	je     c01078f2 <check_swap+0x5a9>
c01078ce:	c7 44 24 0c de d6 10 	movl   $0xc010d6de,0xc(%esp)
c01078d5:	c0 
c01078d6:	c7 44 24 08 c6 d3 10 	movl   $0xc010d3c6,0x8(%esp)
c01078dd:	c0 
c01078de:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01078e5:	00 
c01078e6:	c7 04 24 60 d3 10 c0 	movl   $0xc010d360,(%esp)
c01078ed:	e8 23 95 ff ff       	call   c0100e15 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01078f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01078f9:	eb 1e                	jmp    c0107919 <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c01078fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078fe:	8b 04 85 e0 ef 19 c0 	mov    -0x3fe61020(,%eax,4),%eax
c0107905:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010790c:	00 
c010790d:	89 04 24             	mov    %eax,(%esp)
c0107910:	e8 6c d8 ff ff       	call   c0105181 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0107915:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0107919:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010791d:	7e dc                	jle    c01078fb <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c010791f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107922:	8b 00                	mov    (%eax),%eax
c0107924:	89 04 24             	mov    %eax,(%esp)
c0107927:	e8 d6 f4 ff ff       	call   c0106e02 <pde2page>
c010792c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107933:	00 
c0107934:	89 04 24             	mov    %eax,(%esp)
c0107937:	e8 45 d8 ff ff       	call   c0105181 <free_pages>
     pgdir[0] = 0;
c010793c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010793f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c0107945:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107948:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c010794f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107952:	89 04 24             	mov    %eax,(%esp)
c0107955:	e8 5a 09 00 00       	call   c01082b4 <mm_destroy>
     check_mm_struct = NULL;
c010795a:	c7 05 ac f0 19 c0 00 	movl   $0x0,0xc019f0ac
c0107961:	00 00 00 
     
     nr_free = nr_free_store;
c0107964:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107967:	a3 c0 ef 19 c0       	mov    %eax,0xc019efc0
     free_list = free_list_store;
c010796c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010796f:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0107972:	a3 b8 ef 19 c0       	mov    %eax,0xc019efb8
c0107977:	89 15 bc ef 19 c0    	mov    %edx,0xc019efbc

     
     le = &free_list;
c010797d:	c7 45 e8 b8 ef 19 c0 	movl   $0xc019efb8,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0107984:	eb 1d                	jmp    c01079a3 <check_swap+0x65a>
         struct Page *p = le2page(le, page_link);
c0107986:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107989:	83 e8 0c             	sub    $0xc,%eax
c010798c:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c010798f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107993:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107996:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107999:	8b 40 08             	mov    0x8(%eax),%eax
c010799c:	29 c2                	sub    %eax,%edx
c010799e:	89 d0                	mov    %edx,%eax
c01079a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01079a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01079a6:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01079a9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01079ac:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01079af:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01079b2:	81 7d e8 b8 ef 19 c0 	cmpl   $0xc019efb8,-0x18(%ebp)
c01079b9:	75 cb                	jne    c0107986 <check_swap+0x63d>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c01079bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01079be:	89 44 24 08          	mov    %eax,0x8(%esp)
c01079c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01079c9:	c7 04 24 e5 d6 10 c0 	movl   $0xc010d6e5,(%esp)
c01079d0:	e8 7e 89 ff ff       	call   c0100353 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c01079d5:	c7 04 24 ff d6 10 c0 	movl   $0xc010d6ff,(%esp)
c01079dc:	e8 72 89 ff ff       	call   c0100353 <cprintf>
}
c01079e1:	83 c4 74             	add    $0x74,%esp
c01079e4:	5b                   	pop    %ebx
c01079e5:	5d                   	pop    %ebp
c01079e6:	c3                   	ret    

c01079e7 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c01079e7:	55                   	push   %ebp
c01079e8:	89 e5                	mov    %esp,%ebp
c01079ea:	83 ec 10             	sub    $0x10,%esp
c01079ed:	c7 45 fc a4 f0 19 c0 	movl   $0xc019f0a4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01079f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01079f7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01079fa:	89 50 04             	mov    %edx,0x4(%eax)
c01079fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a00:	8b 50 04             	mov    0x4(%eax),%edx
c0107a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107a06:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107a08:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a0b:	c7 40 14 a4 f0 19 c0 	movl   $0xc019f0a4,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0107a12:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a17:	c9                   	leave  
c0107a18:	c3                   	ret    

c0107a19 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107a19:	55                   	push   %ebp
c0107a1a:	89 e5                	mov    %esp,%ebp
c0107a1c:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107a1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a22:	8b 40 14             	mov    0x14(%eax),%eax
c0107a25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107a28:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a2b:	83 c0 14             	add    $0x14,%eax
c0107a2e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    assert(entry != NULL && head != NULL);
c0107a31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107a35:	74 06                	je     c0107a3d <_fifo_map_swappable+0x24>
c0107a37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a3b:	75 24                	jne    c0107a61 <_fifo_map_swappable+0x48>
c0107a3d:	c7 44 24 0c 18 d7 10 	movl   $0xc010d718,0xc(%esp)
c0107a44:	c0 
c0107a45:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107a4c:	c0 
c0107a4d:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0107a54:	00 
c0107a55:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107a5c:	e8 b4 93 ff ff       	call   c0100e15 <__panic>
c0107a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a64:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a76:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107a79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a7c:	8b 40 04             	mov    0x4(%eax),%eax
c0107a7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107a82:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0107a85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107a88:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0107a8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107a8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107a91:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107a94:	89 10                	mov    %edx,(%eax)
c0107a96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107a99:	8b 10                	mov    (%eax),%edx
c0107a9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107a9e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107aa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107aa4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107aa7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107aaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107aad:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107ab0:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: 2013011317*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0107ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ab7:	c9                   	leave  
c0107ab8:	c3                   	ret    

c0107ab9 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107ab9:	55                   	push   %ebp
c0107aba:	89 e5                	mov    %esp,%ebp
c0107abc:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107abf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ac2:	8b 40 14             	mov    0x14(%eax),%eax
c0107ac5:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0107ac8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107acc:	75 24                	jne    c0107af2 <_fifo_swap_out_victim+0x39>
c0107ace:	c7 44 24 0c 5f d7 10 	movl   $0xc010d75f,0xc(%esp)
c0107ad5:	c0 
c0107ad6:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107add:	c0 
c0107ade:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0107ae5:	00 
c0107ae6:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107aed:	e8 23 93 ff ff       	call   c0100e15 <__panic>
     assert(in_tick==0);
c0107af2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107af6:	74 24                	je     c0107b1c <_fifo_swap_out_victim+0x63>
c0107af8:	c7 44 24 0c 6c d7 10 	movl   $0xc010d76c,0xc(%esp)
c0107aff:	c0 
c0107b00:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107b07:	c0 
c0107b08:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0107b0f:	00 
c0107b10:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107b17:	e8 f9 92 ff ff       	call   c0100e15 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: 2013011317*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  set the addr of addr of this page to ptr_page
    list_entry_t *le = head->prev;
c0107b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b1f:	8b 00                	mov    (%eax),%eax
c0107b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct Page *p = le2page(le, pra_page_link);
c0107b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b27:	83 e8 14             	sub    $0x14,%eax
c0107b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107b30:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0107b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b36:	8b 40 04             	mov    0x4(%eax),%eax
c0107b39:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0107b3c:	8b 12                	mov    (%edx),%edx
c0107b3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0107b41:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107b44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b47:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107b4a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107b53:	89 10                	mov    %edx,(%eax)
    list_del(le);
    *ptr_page = p;
c0107b55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107b58:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107b5b:	89 10                	mov    %edx,(%eax)
    return 0;
c0107b5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107b62:	c9                   	leave  
c0107b63:	c3                   	ret    

c0107b64 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0107b64:	55                   	push   %ebp
c0107b65:	89 e5                	mov    %esp,%ebp
c0107b67:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107b6a:	c7 04 24 78 d7 10 c0 	movl   $0xc010d778,(%esp)
c0107b71:	e8 dd 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107b76:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107b7b:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0107b7e:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107b83:	83 f8 04             	cmp    $0x4,%eax
c0107b86:	74 24                	je     c0107bac <_fifo_check_swap+0x48>
c0107b88:	c7 44 24 0c 9e d7 10 	movl   $0xc010d79e,0xc(%esp)
c0107b8f:	c0 
c0107b90:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107b97:	c0 
c0107b98:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
c0107b9f:	00 
c0107ba0:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107ba7:	e8 69 92 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107bac:	c7 04 24 b0 d7 10 c0 	movl   $0xc010d7b0,(%esp)
c0107bb3:	e8 9b 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107bb8:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107bbd:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0107bc0:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107bc5:	83 f8 04             	cmp    $0x4,%eax
c0107bc8:	74 24                	je     c0107bee <_fifo_check_swap+0x8a>
c0107bca:	c7 44 24 0c 9e d7 10 	movl   $0xc010d79e,0xc(%esp)
c0107bd1:	c0 
c0107bd2:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107bd9:	c0 
c0107bda:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c0107be1:	00 
c0107be2:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107be9:	e8 27 92 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107bee:	c7 04 24 d8 d7 10 c0 	movl   $0xc010d7d8,(%esp)
c0107bf5:	e8 59 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107bfa:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107bff:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0107c02:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107c07:	83 f8 04             	cmp    $0x4,%eax
c0107c0a:	74 24                	je     c0107c30 <_fifo_check_swap+0xcc>
c0107c0c:	c7 44 24 0c 9e d7 10 	movl   $0xc010d79e,0xc(%esp)
c0107c13:	c0 
c0107c14:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107c1b:	c0 
c0107c1c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c0107c23:	00 
c0107c24:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107c2b:	e8 e5 91 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107c30:	c7 04 24 00 d8 10 c0 	movl   $0xc010d800,(%esp)
c0107c37:	e8 17 87 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107c3c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107c41:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0107c44:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107c49:	83 f8 04             	cmp    $0x4,%eax
c0107c4c:	74 24                	je     c0107c72 <_fifo_check_swap+0x10e>
c0107c4e:	c7 44 24 0c 9e d7 10 	movl   $0xc010d79e,0xc(%esp)
c0107c55:	c0 
c0107c56:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107c5d:	c0 
c0107c5e:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0107c65:	00 
c0107c66:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107c6d:	e8 a3 91 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107c72:	c7 04 24 28 d8 10 c0 	movl   $0xc010d828,(%esp)
c0107c79:	e8 d5 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107c7e:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107c83:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0107c86:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107c8b:	83 f8 05             	cmp    $0x5,%eax
c0107c8e:	74 24                	je     c0107cb4 <_fifo_check_swap+0x150>
c0107c90:	c7 44 24 0c 4e d8 10 	movl   $0xc010d84e,0xc(%esp)
c0107c97:	c0 
c0107c98:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107c9f:	c0 
c0107ca0:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107ca7:	00 
c0107ca8:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107caf:	e8 61 91 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107cb4:	c7 04 24 00 d8 10 c0 	movl   $0xc010d800,(%esp)
c0107cbb:	e8 93 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107cc0:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107cc5:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0107cc8:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107ccd:	83 f8 05             	cmp    $0x5,%eax
c0107cd0:	74 24                	je     c0107cf6 <_fifo_check_swap+0x192>
c0107cd2:	c7 44 24 0c 4e d8 10 	movl   $0xc010d84e,0xc(%esp)
c0107cd9:	c0 
c0107cda:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107ce1:	c0 
c0107ce2:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0107ce9:	00 
c0107cea:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107cf1:	e8 1f 91 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107cf6:	c7 04 24 b0 d7 10 c0 	movl   $0xc010d7b0,(%esp)
c0107cfd:	e8 51 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0107d02:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107d07:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0107d0a:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107d0f:	83 f8 06             	cmp    $0x6,%eax
c0107d12:	74 24                	je     c0107d38 <_fifo_check_swap+0x1d4>
c0107d14:	c7 44 24 0c 5d d8 10 	movl   $0xc010d85d,0xc(%esp)
c0107d1b:	c0 
c0107d1c:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107d23:	c0 
c0107d24:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0107d2b:	00 
c0107d2c:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107d33:	e8 dd 90 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0107d38:	c7 04 24 00 d8 10 c0 	movl   $0xc010d800,(%esp)
c0107d3f:	e8 0f 86 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0107d44:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107d49:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0107d4c:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107d51:	83 f8 07             	cmp    $0x7,%eax
c0107d54:	74 24                	je     c0107d7a <_fifo_check_swap+0x216>
c0107d56:	c7 44 24 0c 6c d8 10 	movl   $0xc010d86c,0xc(%esp)
c0107d5d:	c0 
c0107d5e:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107d65:	c0 
c0107d66:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0107d6d:	00 
c0107d6e:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107d75:	e8 9b 90 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107d7a:	c7 04 24 78 d7 10 c0 	movl   $0xc010d778,(%esp)
c0107d81:	e8 cd 85 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107d86:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107d8b:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0107d8e:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107d93:	83 f8 08             	cmp    $0x8,%eax
c0107d96:	74 24                	je     c0107dbc <_fifo_check_swap+0x258>
c0107d98:	c7 44 24 0c 7b d8 10 	movl   $0xc010d87b,0xc(%esp)
c0107d9f:	c0 
c0107da0:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107da7:	c0 
c0107da8:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0107daf:	00 
c0107db0:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107db7:	e8 59 90 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0107dbc:	c7 04 24 d8 d7 10 c0 	movl   $0xc010d7d8,(%esp)
c0107dc3:	e8 8b 85 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107dc8:	b8 00 40 00 00       	mov    $0x4000,%eax
c0107dcd:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0107dd0:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107dd5:	83 f8 09             	cmp    $0x9,%eax
c0107dd8:	74 24                	je     c0107dfe <_fifo_check_swap+0x29a>
c0107dda:	c7 44 24 0c 8a d8 10 	movl   $0xc010d88a,0xc(%esp)
c0107de1:	c0 
c0107de2:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107de9:	c0 
c0107dea:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0107df1:	00 
c0107df2:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107df9:	e8 17 90 ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0107dfe:	c7 04 24 28 d8 10 c0 	movl   $0xc010d828,(%esp)
c0107e05:	e8 49 85 ff ff       	call   c0100353 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0107e0a:	b8 00 50 00 00       	mov    $0x5000,%eax
c0107e0f:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0107e12:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107e17:	83 f8 0a             	cmp    $0xa,%eax
c0107e1a:	74 24                	je     c0107e40 <_fifo_check_swap+0x2dc>
c0107e1c:	c7 44 24 0c 99 d8 10 	movl   $0xc010d899,0xc(%esp)
c0107e23:	c0 
c0107e24:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107e2b:	c0 
c0107e2c:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107e33:	00 
c0107e34:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107e3b:	e8 d5 8f ff ff       	call   c0100e15 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0107e40:	c7 04 24 b0 d7 10 c0 	movl   $0xc010d7b0,(%esp)
c0107e47:	e8 07 85 ff ff       	call   c0100353 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0107e4c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e51:	0f b6 00             	movzbl (%eax),%eax
c0107e54:	3c 0a                	cmp    $0xa,%al
c0107e56:	74 24                	je     c0107e7c <_fifo_check_swap+0x318>
c0107e58:	c7 44 24 0c ac d8 10 	movl   $0xc010d8ac,0xc(%esp)
c0107e5f:	c0 
c0107e60:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107e67:	c0 
c0107e68:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0107e6f:	00 
c0107e70:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107e77:	e8 99 8f ff ff       	call   c0100e15 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0107e7c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107e81:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107e84:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0107e89:	83 f8 0b             	cmp    $0xb,%eax
c0107e8c:	74 24                	je     c0107eb2 <_fifo_check_swap+0x34e>
c0107e8e:	c7 44 24 0c cd d8 10 	movl   $0xc010d8cd,0xc(%esp)
c0107e95:	c0 
c0107e96:	c7 44 24 08 36 d7 10 	movl   $0xc010d736,0x8(%esp)
c0107e9d:	c0 
c0107e9e:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c0107ea5:	00 
c0107ea6:	c7 04 24 4b d7 10 c0 	movl   $0xc010d74b,(%esp)
c0107ead:	e8 63 8f ff ff       	call   c0100e15 <__panic>
    return 0;
c0107eb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107eb7:	c9                   	leave  
c0107eb8:	c3                   	ret    

c0107eb9 <_fifo_init>:


static int
_fifo_init(void)
{
c0107eb9:	55                   	push   %ebp
c0107eba:	89 e5                	mov    %esp,%ebp
    return 0;
c0107ebc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ec1:	5d                   	pop    %ebp
c0107ec2:	c3                   	ret    

c0107ec3 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107ec3:	55                   	push   %ebp
c0107ec4:	89 e5                	mov    %esp,%ebp
    return 0;
c0107ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ecb:	5d                   	pop    %ebp
c0107ecc:	c3                   	ret    

c0107ecd <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0107ecd:	55                   	push   %ebp
c0107ece:	89 e5                	mov    %esp,%ebp
c0107ed0:	b8 00 00 00 00       	mov    $0x0,%eax
c0107ed5:	5d                   	pop    %ebp
c0107ed6:	c3                   	ret    

c0107ed7 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c0107ed7:	55                   	push   %ebp
c0107ed8:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c0107eda:	8b 45 08             	mov    0x8(%ebp),%eax
c0107edd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c0107ee3:	5d                   	pop    %ebp
c0107ee4:	c3                   	ret    

c0107ee5 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c0107ee5:	55                   	push   %ebp
c0107ee6:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c0107ee8:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eeb:	8b 40 18             	mov    0x18(%eax),%eax
}
c0107eee:	5d                   	pop    %ebp
c0107eef:	c3                   	ret    

c0107ef0 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c0107ef0:	55                   	push   %ebp
c0107ef1:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c0107ef3:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107ef9:	89 50 18             	mov    %edx,0x18(%eax)
}
c0107efc:	5d                   	pop    %ebp
c0107efd:	c3                   	ret    

c0107efe <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107efe:	55                   	push   %ebp
c0107eff:	89 e5                	mov    %esp,%ebp
c0107f01:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107f04:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f07:	c1 e8 0c             	shr    $0xc,%eax
c0107f0a:	89 c2                	mov    %eax,%edx
c0107f0c:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c0107f11:	39 c2                	cmp    %eax,%edx
c0107f13:	72 1c                	jb     c0107f31 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107f15:	c7 44 24 08 f0 d8 10 	movl   $0xc010d8f0,0x8(%esp)
c0107f1c:	c0 
c0107f1d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0107f24:	00 
c0107f25:	c7 04 24 0f d9 10 c0 	movl   $0xc010d90f,(%esp)
c0107f2c:	e8 e4 8e ff ff       	call   c0100e15 <__panic>
    }
    return &pages[PPN(pa)];
c0107f31:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c0107f36:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f39:	c1 ea 0c             	shr    $0xc,%edx
c0107f3c:	c1 e2 05             	shl    $0x5,%edx
c0107f3f:	01 d0                	add    %edx,%eax
}
c0107f41:	c9                   	leave  
c0107f42:	c3                   	ret    

c0107f43 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0107f43:	55                   	push   %ebp
c0107f44:	89 e5                	mov    %esp,%ebp
c0107f46:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107f49:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107f51:	89 04 24             	mov    %eax,(%esp)
c0107f54:	e8 a5 ff ff ff       	call   c0107efe <pa2page>
}
c0107f59:	c9                   	leave  
c0107f5a:	c3                   	ret    

c0107f5b <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0107f5b:	55                   	push   %ebp
c0107f5c:	89 e5                	mov    %esp,%ebp
c0107f5e:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0107f61:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0107f68:	e8 34 cd ff ff       	call   c0104ca1 <kmalloc>
c0107f6d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0107f70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f74:	74 79                	je     c0107fef <mm_create+0x94>
        list_init(&(mm->mmap_list));
c0107f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f79:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107f7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107f82:	89 50 04             	mov    %edx,0x4(%eax)
c0107f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f88:	8b 50 04             	mov    0x4(%eax),%edx
c0107f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f8e:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f9d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0107fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fa7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107fae:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0107fb3:	85 c0                	test   %eax,%eax
c0107fb5:	74 0d                	je     c0107fc4 <mm_create+0x69>
c0107fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fba:	89 04 24             	mov    %eax,(%esp)
c0107fbd:	e8 e8 ee ff ff       	call   c0106eaa <swap_init_mm>
c0107fc2:	eb 0a                	jmp    c0107fce <mm_create+0x73>
        else mm->sm_priv = NULL;
c0107fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fc7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

        set_mm_count(mm, 0);
c0107fce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107fd5:	00 
c0107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fd9:	89 04 24             	mov    %eax,(%esp)
c0107fdc:	e8 0f ff ff ff       	call   c0107ef0 <set_mm_count>
        lock_init(&(mm->mm_lock));
c0107fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fe4:	83 c0 1c             	add    $0x1c,%eax
c0107fe7:	89 04 24             	mov    %eax,(%esp)
c0107fea:	e8 e8 fe ff ff       	call   c0107ed7 <lock_init>
    }
    return mm;
c0107fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107ff2:	c9                   	leave  
c0107ff3:	c3                   	ret    

c0107ff4 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0107ff4:	55                   	push   %ebp
c0107ff5:	89 e5                	mov    %esp,%ebp
c0107ff7:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107ffa:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108001:	e8 9b cc ff ff       	call   c0104ca1 <kmalloc>
c0108006:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0108009:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010800d:	74 1b                	je     c010802a <vma_create+0x36>
        vma->vm_start = vm_start;
c010800f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108012:	8b 55 08             	mov    0x8(%ebp),%edx
c0108015:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0108018:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010801b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010801e:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0108021:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108024:	8b 55 10             	mov    0x10(%ebp),%edx
c0108027:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010802a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010802d:	c9                   	leave  
c010802e:	c3                   	ret    

c010802f <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c010802f:	55                   	push   %ebp
c0108030:	89 e5                	mov    %esp,%ebp
c0108032:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0108035:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c010803c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108040:	0f 84 95 00 00 00    	je     c01080db <find_vma+0xac>
        vma = mm->mmap_cache;
c0108046:	8b 45 08             	mov    0x8(%ebp),%eax
c0108049:	8b 40 08             	mov    0x8(%eax),%eax
c010804c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c010804f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108053:	74 16                	je     c010806b <find_vma+0x3c>
c0108055:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108058:	8b 40 04             	mov    0x4(%eax),%eax
c010805b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010805e:	77 0b                	ja     c010806b <find_vma+0x3c>
c0108060:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108063:	8b 40 08             	mov    0x8(%eax),%eax
c0108066:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108069:	77 61                	ja     c01080cc <find_vma+0x9d>
                bool found = 0;
c010806b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0108072:	8b 45 08             	mov    0x8(%ebp),%eax
c0108075:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108078:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010807b:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c010807e:	eb 28                	jmp    c01080a8 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108083:	83 e8 10             	sub    $0x10,%eax
c0108086:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0108089:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010808c:	8b 40 04             	mov    0x4(%eax),%eax
c010808f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108092:	77 14                	ja     c01080a8 <find_vma+0x79>
c0108094:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108097:	8b 40 08             	mov    0x8(%eax),%eax
c010809a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010809d:	76 09                	jbe    c01080a8 <find_vma+0x79>
                        found = 1;
c010809f:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01080a6:	eb 17                	jmp    c01080bf <find_vma+0x90>
c01080a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01080ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01080b1:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01080b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080ba:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01080bd:	75 c1                	jne    c0108080 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01080bf:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01080c3:	75 07                	jne    c01080cc <find_vma+0x9d>
                    vma = NULL;
c01080c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01080cc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01080d0:	74 09                	je     c01080db <find_vma+0xac>
            mm->mmap_cache = vma;
c01080d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01080d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01080d8:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01080db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01080de:	c9                   	leave  
c01080df:	c3                   	ret    

c01080e0 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01080e0:	55                   	push   %ebp
c01080e1:	89 e5                	mov    %esp,%ebp
c01080e3:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01080e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01080e9:	8b 50 04             	mov    0x4(%eax),%edx
c01080ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01080ef:	8b 40 08             	mov    0x8(%eax),%eax
c01080f2:	39 c2                	cmp    %eax,%edx
c01080f4:	72 24                	jb     c010811a <check_vma_overlap+0x3a>
c01080f6:	c7 44 24 0c 1d d9 10 	movl   $0xc010d91d,0xc(%esp)
c01080fd:	c0 
c01080fe:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108105:	c0 
c0108106:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c010810d:	00 
c010810e:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108115:	e8 fb 8c ff ff       	call   c0100e15 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010811a:	8b 45 08             	mov    0x8(%ebp),%eax
c010811d:	8b 50 08             	mov    0x8(%eax),%edx
c0108120:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108123:	8b 40 04             	mov    0x4(%eax),%eax
c0108126:	39 c2                	cmp    %eax,%edx
c0108128:	76 24                	jbe    c010814e <check_vma_overlap+0x6e>
c010812a:	c7 44 24 0c 60 d9 10 	movl   $0xc010d960,0xc(%esp)
c0108131:	c0 
c0108132:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108139:	c0 
c010813a:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0108141:	00 
c0108142:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108149:	e8 c7 8c ff ff       	call   c0100e15 <__panic>
    assert(next->vm_start < next->vm_end);
c010814e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108151:	8b 50 04             	mov    0x4(%eax),%edx
c0108154:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108157:	8b 40 08             	mov    0x8(%eax),%eax
c010815a:	39 c2                	cmp    %eax,%edx
c010815c:	72 24                	jb     c0108182 <check_vma_overlap+0xa2>
c010815e:	c7 44 24 0c 7f d9 10 	movl   $0xc010d97f,0xc(%esp)
c0108165:	c0 
c0108166:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c010816d:	c0 
c010816e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108175:	00 
c0108176:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c010817d:	e8 93 8c ff ff       	call   c0100e15 <__panic>
}
c0108182:	c9                   	leave  
c0108183:	c3                   	ret    

c0108184 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0108184:	55                   	push   %ebp
c0108185:	89 e5                	mov    %esp,%ebp
c0108187:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010818a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010818d:	8b 50 04             	mov    0x4(%eax),%edx
c0108190:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108193:	8b 40 08             	mov    0x8(%eax),%eax
c0108196:	39 c2                	cmp    %eax,%edx
c0108198:	72 24                	jb     c01081be <insert_vma_struct+0x3a>
c010819a:	c7 44 24 0c 9d d9 10 	movl   $0xc010d99d,0xc(%esp)
c01081a1:	c0 
c01081a2:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01081a9:	c0 
c01081aa:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01081b1:	00 
c01081b2:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01081b9:	e8 57 8c ff ff       	call   c0100e15 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01081be:	8b 45 08             	mov    0x8(%ebp),%eax
c01081c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01081c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081c7:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01081ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01081cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01081d0:	eb 21                	jmp    c01081f3 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01081d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081d5:	83 e8 10             	sub    $0x10,%eax
c01081d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01081db:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081de:	8b 50 04             	mov    0x4(%eax),%edx
c01081e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01081e4:	8b 40 04             	mov    0x4(%eax),%eax
c01081e7:	39 c2                	cmp    %eax,%edx
c01081e9:	76 02                	jbe    c01081ed <insert_vma_struct+0x69>
                break;
c01081eb:	eb 1d                	jmp    c010820a <insert_vma_struct+0x86>
            }
            le_prev = le;
c01081ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01081f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081fc:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01081ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108202:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108205:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108208:	75 c8                	jne    c01081d2 <insert_vma_struct+0x4e>
c010820a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010820d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108210:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108213:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0108216:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010821c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010821f:	74 15                	je     c0108236 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0108221:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108224:	8d 50 f0             	lea    -0x10(%eax),%edx
c0108227:	8b 45 0c             	mov    0xc(%ebp),%eax
c010822a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010822e:	89 14 24             	mov    %edx,(%esp)
c0108231:	e8 aa fe ff ff       	call   c01080e0 <check_vma_overlap>
    }
    if (le_next != list) {
c0108236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108239:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010823c:	74 15                	je     c0108253 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010823e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108241:	83 e8 10             	sub    $0x10,%eax
c0108244:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108248:	8b 45 0c             	mov    0xc(%ebp),%eax
c010824b:	89 04 24             	mov    %eax,(%esp)
c010824e:	e8 8d fe ff ff       	call   c01080e0 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0108253:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108256:	8b 55 08             	mov    0x8(%ebp),%edx
c0108259:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010825b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010825e:	8d 50 10             	lea    0x10(%eax),%edx
c0108261:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108264:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108267:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010826a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010826d:	8b 40 04             	mov    0x4(%eax),%eax
c0108270:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108273:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108276:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108279:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010827c:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010827f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108282:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108285:	89 10                	mov    %edx,(%eax)
c0108287:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010828a:	8b 10                	mov    (%eax),%edx
c010828c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010828f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108292:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108295:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108298:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010829b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010829e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01082a1:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01082a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01082a6:	8b 40 10             	mov    0x10(%eax),%eax
c01082a9:	8d 50 01             	lea    0x1(%eax),%edx
c01082ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01082af:	89 50 10             	mov    %edx,0x10(%eax)
}
c01082b2:	c9                   	leave  
c01082b3:	c3                   	ret    

c01082b4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01082b4:	55                   	push   %ebp
c01082b5:	89 e5                	mov    %esp,%ebp
c01082b7:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c01082ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01082bd:	89 04 24             	mov    %eax,(%esp)
c01082c0:	e8 20 fc ff ff       	call   c0107ee5 <mm_count>
c01082c5:	85 c0                	test   %eax,%eax
c01082c7:	74 24                	je     c01082ed <mm_destroy+0x39>
c01082c9:	c7 44 24 0c b9 d9 10 	movl   $0xc010d9b9,0xc(%esp)
c01082d0:	c0 
c01082d1:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01082d8:	c0 
c01082d9:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01082e0:	00 
c01082e1:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01082e8:	e8 28 8b ff ff       	call   c0100e15 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c01082ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01082f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01082f3:	eb 36                	jmp    c010832b <mm_destroy+0x77>
c01082f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01082fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01082fe:	8b 40 04             	mov    0x4(%eax),%eax
c0108301:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108304:	8b 12                	mov    (%edx),%edx
c0108306:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010830c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010830f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108312:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0108315:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108318:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010831b:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma
c010831d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108320:	83 e8 10             	sub    $0x10,%eax
c0108323:	89 04 24             	mov    %eax,(%esp)
c0108326:	e8 91 c9 ff ff       	call   c0104cbc <kfree>
c010832b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010832e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108331:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108334:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0108337:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010833a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010833d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108340:	75 b3                	jne    c01082f5 <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma
    }
    kfree(mm); //kfree mm
c0108342:	8b 45 08             	mov    0x8(%ebp),%eax
c0108345:	89 04 24             	mov    %eax,(%esp)
c0108348:	e8 6f c9 ff ff       	call   c0104cbc <kfree>
    mm=NULL;
c010834d:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0108354:	c9                   	leave  
c0108355:	c3                   	ret    

c0108356 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c0108356:	55                   	push   %ebp
c0108357:	89 e5                	mov    %esp,%ebp
c0108359:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c010835c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010835f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108365:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010836a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010836d:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c0108374:	8b 45 10             	mov    0x10(%ebp),%eax
c0108377:	8b 55 0c             	mov    0xc(%ebp),%edx
c010837a:	01 c2                	add    %eax,%edx
c010837c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010837f:	01 d0                	add    %edx,%eax
c0108381:	83 e8 01             	sub    $0x1,%eax
c0108384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010838a:	ba 00 00 00 00       	mov    $0x0,%edx
c010838f:	f7 75 e8             	divl   -0x18(%ebp)
c0108392:	89 d0                	mov    %edx,%eax
c0108394:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108397:	29 c2                	sub    %eax,%edx
c0108399:	89 d0                	mov    %edx,%eax
c010839b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c010839e:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c01083a5:	76 11                	jbe    c01083b8 <mm_map+0x62>
c01083a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083aa:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01083ad:	73 09                	jae    c01083b8 <mm_map+0x62>
c01083af:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c01083b6:	76 0a                	jbe    c01083c2 <mm_map+0x6c>
        return -E_INVAL;
c01083b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01083bd:	e9 ae 00 00 00       	jmp    c0108470 <mm_map+0x11a>
    }

    assert(mm != NULL);
c01083c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01083c6:	75 24                	jne    c01083ec <mm_map+0x96>
c01083c8:	c7 44 24 0c cb d9 10 	movl   $0xc010d9cb,0xc(%esp)
c01083cf:	c0 
c01083d0:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01083d7:	c0 
c01083d8:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c01083df:	00 
c01083e0:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01083e7:	e8 29 8a ff ff       	call   c0100e15 <__panic>

    int ret = -E_INVAL;
c01083ec:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c01083f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01083f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01083fd:	89 04 24             	mov    %eax,(%esp)
c0108400:	e8 2a fc ff ff       	call   c010802f <find_vma>
c0108405:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108408:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010840c:	74 0d                	je     c010841b <mm_map+0xc5>
c010840e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108411:	8b 40 04             	mov    0x4(%eax),%eax
c0108414:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108417:	73 02                	jae    c010841b <mm_map+0xc5>
        goto out;
c0108419:	eb 52                	jmp    c010846d <mm_map+0x117>
    }
    ret = -E_NO_MEM;
c010841b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0108422:	8b 45 14             	mov    0x14(%ebp),%eax
c0108425:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108429:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010842c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108430:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108433:	89 04 24             	mov    %eax,(%esp)
c0108436:	e8 b9 fb ff ff       	call   c0107ff4 <vma_create>
c010843b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010843e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108442:	75 02                	jne    c0108446 <mm_map+0xf0>
        goto out;
c0108444:	eb 27                	jmp    c010846d <mm_map+0x117>
    }
    insert_vma_struct(mm, vma);
c0108446:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108449:	89 44 24 04          	mov    %eax,0x4(%esp)
c010844d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108450:	89 04 24             	mov    %eax,(%esp)
c0108453:	e8 2c fd ff ff       	call   c0108184 <insert_vma_struct>
    if (vma_store != NULL) {
c0108458:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010845c:	74 08                	je     c0108466 <mm_map+0x110>
        *vma_store = vma;
c010845e:	8b 45 18             	mov    0x18(%ebp),%eax
c0108461:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108464:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0108466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

out:
    return ret;
c010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108470:	c9                   	leave  
c0108471:	c3                   	ret    

c0108472 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0108472:	55                   	push   %ebp
c0108473:	89 e5                	mov    %esp,%ebp
c0108475:	56                   	push   %esi
c0108476:	53                   	push   %ebx
c0108477:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c010847a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010847e:	74 06                	je     c0108486 <dup_mmap+0x14>
c0108480:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108484:	75 24                	jne    c01084aa <dup_mmap+0x38>
c0108486:	c7 44 24 0c d6 d9 10 	movl   $0xc010d9d6,0xc(%esp)
c010848d:	c0 
c010848e:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108495:	c0 
c0108496:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010849d:	00 
c010849e:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01084a5:	e8 6b 89 ff ff       	call   c0100e15 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c01084aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01084b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01084b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c01084b6:	e9 92 00 00 00       	jmp    c010854d <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c01084bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084be:	83 e8 10             	sub    $0x10,%eax
c01084c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c01084c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084c7:	8b 48 0c             	mov    0xc(%eax),%ecx
c01084ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084cd:	8b 50 08             	mov    0x8(%eax),%edx
c01084d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01084d3:	8b 40 04             	mov    0x4(%eax),%eax
c01084d6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01084da:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084de:	89 04 24             	mov    %eax,(%esp)
c01084e1:	e8 0e fb ff ff       	call   c0107ff4 <vma_create>
c01084e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c01084e9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01084ed:	75 07                	jne    c01084f6 <dup_mmap+0x84>
            return -E_NO_MEM;
c01084ef:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01084f4:	eb 76                	jmp    c010856c <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c01084f6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01084f9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108500:	89 04 24             	mov    %eax,(%esp)
c0108503:	e8 7c fc ff ff       	call   c0108184 <insert_vma_struct>

        bool share = 0;
c0108508:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c010850f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108512:	8b 58 08             	mov    0x8(%eax),%ebx
c0108515:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108518:	8b 48 04             	mov    0x4(%eax),%ecx
c010851b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010851e:	8b 50 0c             	mov    0xc(%eax),%edx
c0108521:	8b 45 08             	mov    0x8(%ebp),%eax
c0108524:	8b 40 0c             	mov    0xc(%eax),%eax
c0108527:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c010852a:	89 74 24 10          	mov    %esi,0x10(%esp)
c010852e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108532:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108536:	89 54 24 04          	mov    %edx,0x4(%esp)
c010853a:	89 04 24             	mov    %eax,(%esp)
c010853d:	e8 38 d7 ff ff       	call   c0105c7a <copy_range>
c0108542:	85 c0                	test   %eax,%eax
c0108544:	74 07                	je     c010854d <dup_mmap+0xdb>
            return -E_NO_MEM;
c0108546:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010854b:	eb 1f                	jmp    c010856c <dup_mmap+0xfa>
c010854d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108550:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0108553:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108556:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0108558:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010855b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010855e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108561:	0f 85 54 ff ff ff    	jne    c01084bb <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0108567:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010856c:	83 c4 40             	add    $0x40,%esp
c010856f:	5b                   	pop    %ebx
c0108570:	5e                   	pop    %esi
c0108571:	5d                   	pop    %ebp
c0108572:	c3                   	ret    

c0108573 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0108573:	55                   	push   %ebp
c0108574:	89 e5                	mov    %esp,%ebp
c0108576:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0108579:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010857d:	74 0f                	je     c010858e <exit_mmap+0x1b>
c010857f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108582:	89 04 24             	mov    %eax,(%esp)
c0108585:	e8 5b f9 ff ff       	call   c0107ee5 <mm_count>
c010858a:	85 c0                	test   %eax,%eax
c010858c:	74 24                	je     c01085b2 <exit_mmap+0x3f>
c010858e:	c7 44 24 0c f4 d9 10 	movl   $0xc010d9f4,0xc(%esp)
c0108595:	c0 
c0108596:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c010859d:	c0 
c010859e:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01085a5:	00 
c01085a6:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01085ad:	e8 63 88 ff ff       	call   c0100e15 <__panic>
    pde_t *pgdir = mm->pgdir;
c01085b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01085b5:	8b 40 0c             	mov    0xc(%eax),%eax
c01085b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c01085bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01085be:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01085c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c01085c7:	eb 28                	jmp    c01085f1 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c01085c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085cc:	83 e8 10             	sub    $0x10,%eax
c01085cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c01085d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085d5:	8b 50 08             	mov    0x8(%eax),%edx
c01085d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01085db:	8b 40 04             	mov    0x4(%eax),%eax
c01085de:	89 54 24 08          	mov    %edx,0x8(%esp)
c01085e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085e9:	89 04 24             	mov    %eax,(%esp)
c01085ec:	e8 8e d4 ff ff       	call   c0105a7f <unmap_range>
c01085f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01085f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085fa:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c01085fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108603:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108606:	75 c1                	jne    c01085c9 <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c0108608:	eb 28                	jmp    c0108632 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c010860a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010860d:	83 e8 10             	sub    $0x10,%eax
c0108610:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0108613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108616:	8b 50 08             	mov    0x8(%eax),%edx
c0108619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010861c:	8b 40 04             	mov    0x4(%eax),%eax
c010861f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108623:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108627:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010862a:	89 04 24             	mov    %eax,(%esp)
c010862d:	e8 41 d5 ff ff       	call   c0105b73 <exit_range>
c0108632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108635:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108638:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010863b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c010863e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108641:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108644:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108647:	75 c1                	jne    c010860a <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c0108649:	c9                   	leave  
c010864a:	c3                   	ret    

c010864b <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c010864b:	55                   	push   %ebp
c010864c:	89 e5                	mov    %esp,%ebp
c010864e:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0108651:	8b 45 10             	mov    0x10(%ebp),%eax
c0108654:	8b 55 18             	mov    0x18(%ebp),%edx
c0108657:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010865b:	8b 55 14             	mov    0x14(%ebp),%edx
c010865e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108662:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108666:	8b 45 08             	mov    0x8(%ebp),%eax
c0108669:	89 04 24             	mov    %eax,(%esp)
c010866c:	e8 8d 09 00 00       	call   c0108ffe <user_mem_check>
c0108671:	85 c0                	test   %eax,%eax
c0108673:	75 07                	jne    c010867c <copy_from_user+0x31>
        return 0;
c0108675:	b8 00 00 00 00       	mov    $0x0,%eax
c010867a:	eb 1e                	jmp    c010869a <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c010867c:	8b 45 14             	mov    0x14(%ebp),%eax
c010867f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108683:	8b 45 10             	mov    0x10(%ebp),%eax
c0108686:	89 44 24 04          	mov    %eax,0x4(%esp)
c010868a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010868d:	89 04 24             	mov    %eax,(%esp)
c0108690:	e8 39 37 00 00       	call   c010bdce <memcpy>
    return 1;
c0108695:	b8 01 00 00 00       	mov    $0x1,%eax
}
c010869a:	c9                   	leave  
c010869b:	c3                   	ret    

c010869c <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c010869c:	55                   	push   %ebp
c010869d:	89 e5                	mov    %esp,%ebp
c010869f:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c01086a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086a5:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01086ac:	00 
c01086ad:	8b 55 14             	mov    0x14(%ebp),%edx
c01086b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01086b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01086bb:	89 04 24             	mov    %eax,(%esp)
c01086be:	e8 3b 09 00 00       	call   c0108ffe <user_mem_check>
c01086c3:	85 c0                	test   %eax,%eax
c01086c5:	75 07                	jne    c01086ce <copy_to_user+0x32>
        return 0;
c01086c7:	b8 00 00 00 00       	mov    $0x0,%eax
c01086cc:	eb 1e                	jmp    c01086ec <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c01086ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01086d1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01086d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086df:	89 04 24             	mov    %eax,(%esp)
c01086e2:	e8 e7 36 00 00       	call   c010bdce <memcpy>
    return 1;
c01086e7:	b8 01 00 00 00       	mov    $0x1,%eax
}
c01086ec:	c9                   	leave  
c01086ed:	c3                   	ret    

c01086ee <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01086ee:	55                   	push   %ebp
c01086ef:	89 e5                	mov    %esp,%ebp
c01086f1:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01086f4:	e8 02 00 00 00       	call   c01086fb <check_vmm>
}
c01086f9:	c9                   	leave  
c01086fa:	c3                   	ret    

c01086fb <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01086fb:	55                   	push   %ebp
c01086fc:	89 e5                	mov    %esp,%ebp
c01086fe:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108701:	e8 ad ca ff ff       	call   c01051b3 <nr_free_pages>
c0108706:	89 45 f4             	mov    %eax,-0xc(%ebp)

    check_vma_struct();
c0108709:	e8 13 00 00 00       	call   c0108721 <check_vma_struct>
    check_pgfault();
c010870e:	e8 a7 04 00 00       	call   c0108bba <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0108713:	c7 04 24 14 da 10 c0 	movl   $0xc010da14,(%esp)
c010871a:	e8 34 7c ff ff       	call   c0100353 <cprintf>
}
c010871f:	c9                   	leave  
c0108720:	c3                   	ret    

c0108721 <check_vma_struct>:

static void
check_vma_struct(void) {
c0108721:	55                   	push   %ebp
c0108722:	89 e5                	mov    %esp,%ebp
c0108724:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108727:	e8 87 ca ff ff       	call   c01051b3 <nr_free_pages>
c010872c:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c010872f:	e8 27 f8 ff ff       	call   c0107f5b <mm_create>
c0108734:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0108737:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010873b:	75 24                	jne    c0108761 <check_vma_struct+0x40>
c010873d:	c7 44 24 0c cb d9 10 	movl   $0xc010d9cb,0xc(%esp)
c0108744:	c0 
c0108745:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c010874c:	c0 
c010874d:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0108754:	00 
c0108755:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c010875c:	e8 b4 86 ff ff       	call   c0100e15 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0108761:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0108768:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010876b:	89 d0                	mov    %edx,%eax
c010876d:	c1 e0 02             	shl    $0x2,%eax
c0108770:	01 d0                	add    %edx,%eax
c0108772:	01 c0                	add    %eax,%eax
c0108774:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0108777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010877a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010877d:	eb 70                	jmp    c01087ef <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010877f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108782:	89 d0                	mov    %edx,%eax
c0108784:	c1 e0 02             	shl    $0x2,%eax
c0108787:	01 d0                	add    %edx,%eax
c0108789:	83 c0 02             	add    $0x2,%eax
c010878c:	89 c1                	mov    %eax,%ecx
c010878e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108791:	89 d0                	mov    %edx,%eax
c0108793:	c1 e0 02             	shl    $0x2,%eax
c0108796:	01 d0                	add    %edx,%eax
c0108798:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010879f:	00 
c01087a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01087a4:	89 04 24             	mov    %eax,(%esp)
c01087a7:	e8 48 f8 ff ff       	call   c0107ff4 <vma_create>
c01087ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c01087af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01087b3:	75 24                	jne    c01087d9 <check_vma_struct+0xb8>
c01087b5:	c7 44 24 0c 2c da 10 	movl   $0xc010da2c,0xc(%esp)
c01087bc:	c0 
c01087bd:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01087c4:	c0 
c01087c5:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c01087cc:	00 
c01087cd:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01087d4:	e8 3c 86 ff ff       	call   c0100e15 <__panic>
        insert_vma_struct(mm, vma);
c01087d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01087dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087e3:	89 04 24             	mov    %eax,(%esp)
c01087e6:	e8 99 f9 ff ff       	call   c0108184 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01087eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01087ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01087f3:	7f 8a                	jg     c010877f <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01087f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01087f8:	83 c0 01             	add    $0x1,%eax
c01087fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01087fe:	eb 70                	jmp    c0108870 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0108800:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108803:	89 d0                	mov    %edx,%eax
c0108805:	c1 e0 02             	shl    $0x2,%eax
c0108808:	01 d0                	add    %edx,%eax
c010880a:	83 c0 02             	add    $0x2,%eax
c010880d:	89 c1                	mov    %eax,%ecx
c010880f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108812:	89 d0                	mov    %edx,%eax
c0108814:	c1 e0 02             	shl    $0x2,%eax
c0108817:	01 d0                	add    %edx,%eax
c0108819:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108820:	00 
c0108821:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0108825:	89 04 24             	mov    %eax,(%esp)
c0108828:	e8 c7 f7 ff ff       	call   c0107ff4 <vma_create>
c010882d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0108830:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108834:	75 24                	jne    c010885a <check_vma_struct+0x139>
c0108836:	c7 44 24 0c 2c da 10 	movl   $0xc010da2c,0xc(%esp)
c010883d:	c0 
c010883e:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108845:	c0 
c0108846:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c010884d:	00 
c010884e:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108855:	e8 bb 85 ff ff       	call   c0100e15 <__panic>
        insert_vma_struct(mm, vma);
c010885a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010885d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108861:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108864:	89 04 24             	mov    %eax,(%esp)
c0108867:	e8 18 f9 ff ff       	call   c0108184 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c010886c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108870:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108873:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108876:	7e 88                	jle    c0108800 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0108878:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010887b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010887e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0108881:	8b 40 04             	mov    0x4(%eax),%eax
c0108884:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0108887:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c010888e:	e9 97 00 00 00       	jmp    c010892a <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0108893:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108896:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108899:	75 24                	jne    c01088bf <check_vma_struct+0x19e>
c010889b:	c7 44 24 0c 38 da 10 	movl   $0xc010da38,0xc(%esp)
c01088a2:	c0 
c01088a3:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01088aa:	c0 
c01088ab:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c01088b2:	00 
c01088b3:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01088ba:	e8 56 85 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c01088bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088c2:	83 e8 10             	sub    $0x10,%eax
c01088c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01088c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01088cb:	8b 48 04             	mov    0x4(%eax),%ecx
c01088ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088d1:	89 d0                	mov    %edx,%eax
c01088d3:	c1 e0 02             	shl    $0x2,%eax
c01088d6:	01 d0                	add    %edx,%eax
c01088d8:	39 c1                	cmp    %eax,%ecx
c01088da:	75 17                	jne    c01088f3 <check_vma_struct+0x1d2>
c01088dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01088df:	8b 48 08             	mov    0x8(%eax),%ecx
c01088e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01088e5:	89 d0                	mov    %edx,%eax
c01088e7:	c1 e0 02             	shl    $0x2,%eax
c01088ea:	01 d0                	add    %edx,%eax
c01088ec:	83 c0 02             	add    $0x2,%eax
c01088ef:	39 c1                	cmp    %eax,%ecx
c01088f1:	74 24                	je     c0108917 <check_vma_struct+0x1f6>
c01088f3:	c7 44 24 0c 50 da 10 	movl   $0xc010da50,0xc(%esp)
c01088fa:	c0 
c01088fb:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108902:	c0 
c0108903:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c010890a:	00 
c010890b:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108912:	e8 fe 84 ff ff       	call   c0100e15 <__panic>
c0108917:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010891a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010891d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0108920:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0108923:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0108926:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010892a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010892d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108930:	0f 8e 5d ff ff ff    	jle    c0108893 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108936:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c010893d:	e9 cd 01 00 00       	jmp    c0108b0f <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c0108942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108945:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108949:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010894c:	89 04 24             	mov    %eax,(%esp)
c010894f:	e8 db f6 ff ff       	call   c010802f <find_vma>
c0108954:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0108957:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010895b:	75 24                	jne    c0108981 <check_vma_struct+0x260>
c010895d:	c7 44 24 0c 85 da 10 	movl   $0xc010da85,0xc(%esp)
c0108964:	c0 
c0108965:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c010896c:	c0 
c010896d:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0108974:	00 
c0108975:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c010897c:	e8 94 84 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0108981:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108984:	83 c0 01             	add    $0x1,%eax
c0108987:	89 44 24 04          	mov    %eax,0x4(%esp)
c010898b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010898e:	89 04 24             	mov    %eax,(%esp)
c0108991:	e8 99 f6 ff ff       	call   c010802f <find_vma>
c0108996:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0108999:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010899d:	75 24                	jne    c01089c3 <check_vma_struct+0x2a2>
c010899f:	c7 44 24 0c 92 da 10 	movl   $0xc010da92,0xc(%esp)
c01089a6:	c0 
c01089a7:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01089ae:	c0 
c01089af:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c01089b6:	00 
c01089b7:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c01089be:	e8 52 84 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c01089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089c6:	83 c0 02             	add    $0x2,%eax
c01089c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01089cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089d0:	89 04 24             	mov    %eax,(%esp)
c01089d3:	e8 57 f6 ff ff       	call   c010802f <find_vma>
c01089d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c01089db:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01089df:	74 24                	je     c0108a05 <check_vma_struct+0x2e4>
c01089e1:	c7 44 24 0c 9f da 10 	movl   $0xc010da9f,0xc(%esp)
c01089e8:	c0 
c01089e9:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c01089f0:	c0 
c01089f1:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01089f8:	00 
c01089f9:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108a00:	e8 10 84 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0108a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a08:	83 c0 03             	add    $0x3,%eax
c0108a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a12:	89 04 24             	mov    %eax,(%esp)
c0108a15:	e8 15 f6 ff ff       	call   c010802f <find_vma>
c0108a1a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c0108a1d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0108a21:	74 24                	je     c0108a47 <check_vma_struct+0x326>
c0108a23:	c7 44 24 0c ac da 10 	movl   $0xc010daac,0xc(%esp)
c0108a2a:	c0 
c0108a2b:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108a32:	c0 
c0108a33:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0108a3a:	00 
c0108a3b:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108a42:	e8 ce 83 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0108a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a4a:	83 c0 04             	add    $0x4,%eax
c0108a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a54:	89 04 24             	mov    %eax,(%esp)
c0108a57:	e8 d3 f5 ff ff       	call   c010802f <find_vma>
c0108a5c:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0108a5f:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0108a63:	74 24                	je     c0108a89 <check_vma_struct+0x368>
c0108a65:	c7 44 24 0c b9 da 10 	movl   $0xc010dab9,0xc(%esp)
c0108a6c:	c0 
c0108a6d:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108a74:	c0 
c0108a75:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c0108a7c:	00 
c0108a7d:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108a84:	e8 8c 83 ff ff       	call   c0100e15 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0108a89:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a8c:	8b 50 04             	mov    0x4(%eax),%edx
c0108a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a92:	39 c2                	cmp    %eax,%edx
c0108a94:	75 10                	jne    c0108aa6 <check_vma_struct+0x385>
c0108a96:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a99:	8b 50 08             	mov    0x8(%eax),%edx
c0108a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a9f:	83 c0 02             	add    $0x2,%eax
c0108aa2:	39 c2                	cmp    %eax,%edx
c0108aa4:	74 24                	je     c0108aca <check_vma_struct+0x3a9>
c0108aa6:	c7 44 24 0c c8 da 10 	movl   $0xc010dac8,0xc(%esp)
c0108aad:	c0 
c0108aae:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108ab5:	c0 
c0108ab6:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0108abd:	00 
c0108abe:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108ac5:	e8 4b 83 ff ff       	call   c0100e15 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0108aca:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108acd:	8b 50 04             	mov    0x4(%eax),%edx
c0108ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ad3:	39 c2                	cmp    %eax,%edx
c0108ad5:	75 10                	jne    c0108ae7 <check_vma_struct+0x3c6>
c0108ad7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108ada:	8b 50 08             	mov    0x8(%eax),%edx
c0108add:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108ae0:	83 c0 02             	add    $0x2,%eax
c0108ae3:	39 c2                	cmp    %eax,%edx
c0108ae5:	74 24                	je     c0108b0b <check_vma_struct+0x3ea>
c0108ae7:	c7 44 24 0c f8 da 10 	movl   $0xc010daf8,0xc(%esp)
c0108aee:	c0 
c0108aef:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108af6:	c0 
c0108af7:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c0108afe:	00 
c0108aff:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108b06:	e8 0a 83 ff ff       	call   c0100e15 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0108b0b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0108b0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108b12:	89 d0                	mov    %edx,%eax
c0108b14:	c1 e0 02             	shl    $0x2,%eax
c0108b17:	01 d0                	add    %edx,%eax
c0108b19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108b1c:	0f 8d 20 fe ff ff    	jge    c0108942 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108b22:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0108b29:	eb 70                	jmp    c0108b9b <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0108b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b35:	89 04 24             	mov    %eax,(%esp)
c0108b38:	e8 f2 f4 ff ff       	call   c010802f <find_vma>
c0108b3d:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0108b40:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108b44:	74 27                	je     c0108b6d <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end);
c0108b46:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108b49:	8b 50 08             	mov    0x8(%eax),%edx
c0108b4c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0108b4f:	8b 40 04             	mov    0x4(%eax),%eax
c0108b52:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108b56:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b61:	c7 04 24 28 db 10 c0 	movl   $0xc010db28,(%esp)
c0108b68:	e8 e6 77 ff ff       	call   c0100353 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0108b6d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108b71:	74 24                	je     c0108b97 <check_vma_struct+0x476>
c0108b73:	c7 44 24 0c 4d db 10 	movl   $0xc010db4d,0xc(%esp)
c0108b7a:	c0 
c0108b7b:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108b82:	c0 
c0108b83:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0108b8a:	00 
c0108b8b:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108b92:	e8 7e 82 ff ff       	call   c0100e15 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0108b97:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108b9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b9f:	79 8a                	jns    c0108b2b <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0108ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ba4:	89 04 24             	mov    %eax,(%esp)
c0108ba7:	e8 08 f7 ff ff       	call   c01082b4 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0108bac:	c7 04 24 64 db 10 c0 	movl   $0xc010db64,(%esp)
c0108bb3:	e8 9b 77 ff ff       	call   c0100353 <cprintf>
}
c0108bb8:	c9                   	leave  
c0108bb9:	c3                   	ret    

c0108bba <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0108bba:	55                   	push   %ebp
c0108bbb:	89 e5                	mov    %esp,%ebp
c0108bbd:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0108bc0:	e8 ee c5 ff ff       	call   c01051b3 <nr_free_pages>
c0108bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0108bc8:	e8 8e f3 ff ff       	call   c0107f5b <mm_create>
c0108bcd:	a3 ac f0 19 c0       	mov    %eax,0xc019f0ac
    assert(check_mm_struct != NULL);
c0108bd2:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0108bd7:	85 c0                	test   %eax,%eax
c0108bd9:	75 24                	jne    c0108bff <check_pgfault+0x45>
c0108bdb:	c7 44 24 0c 83 db 10 	movl   $0xc010db83,0xc(%esp)
c0108be2:	c0 
c0108be3:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108bea:	c0 
c0108beb:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c0108bf2:	00 
c0108bf3:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108bfa:	e8 16 82 ff ff       	call   c0100e15 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0108bff:	a1 ac f0 19 c0       	mov    0xc019f0ac,%eax
c0108c04:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108c07:	8b 15 e4 ce 19 c0    	mov    0xc019cee4,%edx
c0108c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c10:	89 50 0c             	mov    %edx,0xc(%eax)
c0108c13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c16:	8b 40 0c             	mov    0xc(%eax),%eax
c0108c19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0108c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c1f:	8b 00                	mov    (%eax),%eax
c0108c21:	85 c0                	test   %eax,%eax
c0108c23:	74 24                	je     c0108c49 <check_pgfault+0x8f>
c0108c25:	c7 44 24 0c 9b db 10 	movl   $0xc010db9b,0xc(%esp)
c0108c2c:	c0 
c0108c2d:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108c34:	c0 
c0108c35:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0108c3c:	00 
c0108c3d:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108c44:	e8 cc 81 ff ff       	call   c0100e15 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0108c49:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0108c50:	00 
c0108c51:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0108c58:	00 
c0108c59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108c60:	e8 8f f3 ff ff       	call   c0107ff4 <vma_create>
c0108c65:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0108c68:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108c6c:	75 24                	jne    c0108c92 <check_pgfault+0xd8>
c0108c6e:	c7 44 24 0c 2c da 10 	movl   $0xc010da2c,0xc(%esp)
c0108c75:	c0 
c0108c76:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108c7d:	c0 
c0108c7e:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0108c85:	00 
c0108c86:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108c8d:	e8 83 81 ff ff       	call   c0100e15 <__panic>

    insert_vma_struct(mm, vma);
c0108c92:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108c95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c99:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c9c:	89 04 24             	mov    %eax,(%esp)
c0108c9f:	e8 e0 f4 ff ff       	call   c0108184 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0108ca4:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0108cab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108cb2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108cb5:	89 04 24             	mov    %eax,(%esp)
c0108cb8:	e8 72 f3 ff ff       	call   c010802f <find_vma>
c0108cbd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0108cc0:	74 24                	je     c0108ce6 <check_pgfault+0x12c>
c0108cc2:	c7 44 24 0c a9 db 10 	movl   $0xc010dba9,0xc(%esp)
c0108cc9:	c0 
c0108cca:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108cd1:	c0 
c0108cd2:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0108cd9:	00 
c0108cda:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108ce1:	e8 2f 81 ff ff       	call   c0100e15 <__panic>

    int i, sum = 0;
c0108ce6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0108ced:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108cf4:	eb 17                	jmp    c0108d0d <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0108cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108cf9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108cfc:	01 d0                	add    %edx,%eax
c0108cfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d01:	88 10                	mov    %dl,(%eax)
        sum += i;
c0108d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d06:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0108d09:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108d0d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108d11:	7e e3                	jle    c0108cf6 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108d13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108d1a:	eb 15                	jmp    c0108d31 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0108d1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108d1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d22:	01 d0                	add    %edx,%eax
c0108d24:	0f b6 00             	movzbl (%eax),%eax
c0108d27:	0f be c0             	movsbl %al,%eax
c0108d2a:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0108d2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108d31:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0108d35:	7e e5                	jle    c0108d1c <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0108d37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108d3b:	74 24                	je     c0108d61 <check_pgfault+0x1a7>
c0108d3d:	c7 44 24 0c c3 db 10 	movl   $0xc010dbc3,0xc(%esp)
c0108d44:	c0 
c0108d45:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108d4c:	c0 
c0108d4d:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0108d54:	00 
c0108d55:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108d5c:	e8 b4 80 ff ff       	call   c0100e15 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0108d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108d64:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108d67:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d76:	89 04 24             	mov    %eax,(%esp)
c0108d79:	e8 1f d1 ff ff       	call   c0105e9d <page_remove>
    free_page(pde2page(pgdir[0]));
c0108d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d81:	8b 00                	mov    (%eax),%eax
c0108d83:	89 04 24             	mov    %eax,(%esp)
c0108d86:	e8 b8 f1 ff ff       	call   c0107f43 <pde2page>
c0108d8b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108d92:	00 
c0108d93:	89 04 24             	mov    %eax,(%esp)
c0108d96:	e8 e6 c3 ff ff       	call   c0105181 <free_pages>
    pgdir[0] = 0;
c0108d9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0108da4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108da7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0108dae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108db1:	89 04 24             	mov    %eax,(%esp)
c0108db4:	e8 fb f4 ff ff       	call   c01082b4 <mm_destroy>
    check_mm_struct = NULL;
c0108db9:	c7 05 ac f0 19 c0 00 	movl   $0x0,0xc019f0ac
c0108dc0:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0108dc3:	e8 eb c3 ff ff       	call   c01051b3 <nr_free_pages>
c0108dc8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108dcb:	74 24                	je     c0108df1 <check_pgfault+0x237>
c0108dcd:	c7 44 24 0c cc db 10 	movl   $0xc010dbcc,0xc(%esp)
c0108dd4:	c0 
c0108dd5:	c7 44 24 08 3b d9 10 	movl   $0xc010d93b,0x8(%esp)
c0108ddc:	c0 
c0108ddd:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0108de4:	00 
c0108de5:	c7 04 24 50 d9 10 c0 	movl   $0xc010d950,(%esp)
c0108dec:	e8 24 80 ff ff       	call   c0100e15 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0108df1:	c7 04 24 f3 db 10 c0 	movl   $0xc010dbf3,(%esp)
c0108df8:	e8 56 75 ff ff       	call   c0100353 <cprintf>
}
c0108dfd:	c9                   	leave  
c0108dfe:	c3                   	ret    

c0108dff <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0108dff:	55                   	push   %ebp
c0108e00:	89 e5                	mov    %esp,%ebp
c0108e02:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0108e05:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0108e0c:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e13:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e16:	89 04 24             	mov    %eax,(%esp)
c0108e19:	e8 11 f2 ff ff       	call   c010802f <find_vma>
c0108e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0108e21:	a1 78 cf 19 c0       	mov    0xc019cf78,%eax
c0108e26:	83 c0 01             	add    $0x1,%eax
c0108e29:	a3 78 cf 19 c0       	mov    %eax,0xc019cf78
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0108e2e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108e32:	74 0b                	je     c0108e3f <do_pgfault+0x40>
c0108e34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e37:	8b 40 04             	mov    0x4(%eax),%eax
c0108e3a:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108e3d:	76 18                	jbe    c0108e57 <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0108e3f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e46:	c7 04 24 10 dc 10 c0 	movl   $0xc010dc10,(%esp)
c0108e4d:	e8 01 75 ff ff       	call   c0100353 <cprintf>
        goto failed;
c0108e52:	e9 a2 01 00 00       	jmp    c0108ff9 <do_pgfault+0x1fa>
    }
    //check the error_code
    switch (error_code & 3) {
c0108e57:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e5a:	83 e0 03             	and    $0x3,%eax
c0108e5d:	85 c0                	test   %eax,%eax
c0108e5f:	74 36                	je     c0108e97 <do_pgfault+0x98>
c0108e61:	83 f8 01             	cmp    $0x1,%eax
c0108e64:	74 20                	je     c0108e86 <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0108e66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e69:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e6c:	83 e0 02             	and    $0x2,%eax
c0108e6f:	85 c0                	test   %eax,%eax
c0108e71:	75 11                	jne    c0108e84 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0108e73:	c7 04 24 40 dc 10 c0 	movl   $0xc010dc40,(%esp)
c0108e7a:	e8 d4 74 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108e7f:	e9 75 01 00 00       	jmp    c0108ff9 <do_pgfault+0x1fa>
        }
        break;
c0108e84:	eb 2f                	jmp    c0108eb5 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0108e86:	c7 04 24 a0 dc 10 c0 	movl   $0xc010dca0,(%esp)
c0108e8d:	e8 c1 74 ff ff       	call   c0100353 <cprintf>
        goto failed;
c0108e92:	e9 62 01 00 00       	jmp    c0108ff9 <do_pgfault+0x1fa>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0108e97:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0108e9d:	83 e0 05             	and    $0x5,%eax
c0108ea0:	85 c0                	test   %eax,%eax
c0108ea2:	75 11                	jne    c0108eb5 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0108ea4:	c7 04 24 d8 dc 10 c0 	movl   $0xc010dcd8,(%esp)
c0108eab:	e8 a3 74 ff ff       	call   c0100353 <cprintf>
            goto failed;
c0108eb0:	e9 44 01 00 00       	jmp    c0108ff9 <do_pgfault+0x1fa>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0108eb5:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0108ebc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108ebf:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ec2:	83 e0 02             	and    $0x2,%eax
c0108ec5:	85 c0                	test   %eax,%eax
c0108ec7:	74 04                	je     c0108ecd <do_pgfault+0xce>
        perm |= PTE_W;
c0108ec9:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0108ecd:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ed0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108ed3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108ed6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108edb:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0108ede:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0108ee5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    ptep = get_pte(mm->pgdir, addr, 1);
c0108eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eef:	8b 40 0c             	mov    0xc(%eax),%eax
c0108ef2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108ef9:	00 
c0108efa:	8b 55 10             	mov    0x10(%ebp),%edx
c0108efd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f01:	89 04 24             	mov    %eax,(%esp)
c0108f04:	e8 74 c9 ff ff       	call   c010587d <get_pte>
c0108f09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (ptep) {
c0108f0c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108f10:	0f 84 e3 00 00 00    	je     c0108ff9 <do_pgfault+0x1fa>
        if (*ptep == 0) {
c0108f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f19:	8b 00                	mov    (%eax),%eax
c0108f1b:	85 c0                	test   %eax,%eax
c0108f1d:	75 2e                	jne    c0108f4d <do_pgfault+0x14e>
            ptep = pgdir_alloc_page(mm->pgdir, addr, perm);
c0108f1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f22:	8b 40 0c             	mov    0xc(%eax),%eax
c0108f25:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108f28:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108f2c:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f2f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108f33:	89 04 24             	mov    %eax,(%esp)
c0108f36:	e8 bc d0 ff ff       	call   c0105ff7 <pgdir_alloc_page>
c0108f3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (ptep == NULL)
c0108f3e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108f42:	0f 85 aa 00 00 00    	jne    c0108ff2 <do_pgfault+0x1f3>
                goto failed;
c0108f48:	e9 ac 00 00 00       	jmp    c0108ff9 <do_pgfault+0x1fa>
        } else {
            struct Page *p = NULL;
c0108f4d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if (*ptep & PTE_P) {
c0108f54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f57:	8b 00                	mov    (%eax),%eax
c0108f59:	83 e0 01             	and    $0x1,%eax
c0108f5c:	85 c0                	test   %eax,%eax
c0108f5e:	75 45                	jne    c0108fa5 <do_pgfault+0x1a6>
                void *src_kvaddr = page2kva(np);
                void *dst_kvaddr = page2kva(p);
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                */
            } else {
                if (swap_init_ok) {
c0108f60:	a1 6c cf 19 c0       	mov    0xc019cf6c,%eax
c0108f65:	85 c0                	test   %eax,%eax
c0108f67:	74 24                	je     c0108f8d <do_pgfault+0x18e>
                    ret = swap_in(mm, addr, &p);
c0108f69:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0108f6c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108f70:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f77:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f7a:	89 04 24             	mov    %eax,(%esp)
c0108f7d:	e8 21 e1 ff ff       	call   c01070a3 <swap_in>
c0108f82:	89 45 f4             	mov    %eax,-0xc(%ebp)
                    if (ret)
c0108f85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108f89:	74 1a                	je     c0108fa5 <do_pgfault+0x1a6>
                        goto failed;
c0108f8b:	eb 6c                	jmp    c0108ff9 <do_pgfault+0x1fa>
                } else {
                    cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
c0108f8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f90:	8b 00                	mov    (%eax),%eax
c0108f92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f96:	c7 04 24 3c dd 10 c0 	movl   $0xc010dd3c,(%esp)
c0108f9d:	e8 b1 73 ff ff       	call   c0100353 <cprintf>
                    goto failed;
c0108fa2:	90                   	nop
c0108fa3:	eb 54                	jmp    c0108ff9 <do_pgfault+0x1fa>
                }
            }
            page_insert(mm->pgdir, p, addr, perm);
c0108fa5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108fa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fab:	8b 40 0c             	mov    0xc(%eax),%eax
c0108fae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108fb1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108fb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0108fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0108fbc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108fc0:	89 04 24             	mov    %eax,(%esp)
c0108fc3:	e8 19 cf ff ff       	call   c0105ee1 <page_insert>
            swap_map_swappable(mm, addr, p, 1);
c0108fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108fcb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0108fd2:	00 
c0108fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108fd7:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fde:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fe1:	89 04 24             	mov    %eax,(%esp)
c0108fe4:	e8 f1 de ff ff       	call   c0106eda <swap_map_swappable>
            p->pra_vaddr = addr;
c0108fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108fec:	8b 55 10             	mov    0x10(%ebp),%edx
c0108fef:	89 50 1c             	mov    %edx,0x1c(%eax)
        }
        ret = 0;
c0108ff2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    }
failed:
    return ret;
c0108ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108ffc:	c9                   	leave  
c0108ffd:	c3                   	ret    

c0108ffe <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0108ffe:	55                   	push   %ebp
c0108fff:	89 e5                	mov    %esp,%ebp
c0109001:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109004:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109008:	0f 84 e0 00 00 00    	je     c01090ee <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c010900e:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0109015:	76 1c                	jbe    c0109033 <user_mem_check+0x35>
c0109017:	8b 45 10             	mov    0x10(%ebp),%eax
c010901a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010901d:	01 d0                	add    %edx,%eax
c010901f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109022:	76 0f                	jbe    c0109033 <user_mem_check+0x35>
c0109024:	8b 45 10             	mov    0x10(%ebp),%eax
c0109027:	8b 55 0c             	mov    0xc(%ebp),%edx
c010902a:	01 d0                	add    %edx,%eax
c010902c:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0109031:	76 0a                	jbe    c010903d <user_mem_check+0x3f>
            return 0;
c0109033:	b8 00 00 00 00       	mov    $0x0,%eax
c0109038:	e9 e2 00 00 00       	jmp    c010911f <user_mem_check+0x121>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c010903d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109040:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109043:	8b 45 10             	mov    0x10(%ebp),%eax
c0109046:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109049:	01 d0                	add    %edx,%eax
c010904b:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c010904e:	e9 88 00 00 00       	jmp    c01090db <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c0109053:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109056:	89 44 24 04          	mov    %eax,0x4(%esp)
c010905a:	8b 45 08             	mov    0x8(%ebp),%eax
c010905d:	89 04 24             	mov    %eax,(%esp)
c0109060:	e8 ca ef ff ff       	call   c010802f <find_vma>
c0109065:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109068:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010906c:	74 0b                	je     c0109079 <user_mem_check+0x7b>
c010906e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109071:	8b 40 04             	mov    0x4(%eax),%eax
c0109074:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0109077:	76 0a                	jbe    c0109083 <user_mem_check+0x85>
                return 0;
c0109079:	b8 00 00 00 00       	mov    $0x0,%eax
c010907e:	e9 9c 00 00 00       	jmp    c010911f <user_mem_check+0x121>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c0109083:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109086:	8b 50 0c             	mov    0xc(%eax),%edx
c0109089:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010908d:	74 07                	je     c0109096 <user_mem_check+0x98>
c010908f:	b8 02 00 00 00       	mov    $0x2,%eax
c0109094:	eb 05                	jmp    c010909b <user_mem_check+0x9d>
c0109096:	b8 01 00 00 00       	mov    $0x1,%eax
c010909b:	21 d0                	and    %edx,%eax
c010909d:	85 c0                	test   %eax,%eax
c010909f:	75 07                	jne    c01090a8 <user_mem_check+0xaa>
                return 0;
c01090a1:	b8 00 00 00 00       	mov    $0x0,%eax
c01090a6:	eb 77                	jmp    c010911f <user_mem_check+0x121>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c01090a8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01090ac:	74 24                	je     c01090d2 <user_mem_check+0xd4>
c01090ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090b1:	8b 40 0c             	mov    0xc(%eax),%eax
c01090b4:	83 e0 08             	and    $0x8,%eax
c01090b7:	85 c0                	test   %eax,%eax
c01090b9:	74 17                	je     c01090d2 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01090bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090be:	8b 40 04             	mov    0x4(%eax),%eax
c01090c1:	05 00 10 00 00       	add    $0x1000,%eax
c01090c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01090c9:	76 07                	jbe    c01090d2 <user_mem_check+0xd4>
                    return 0;
c01090cb:	b8 00 00 00 00       	mov    $0x0,%eax
c01090d0:	eb 4d                	jmp    c010911f <user_mem_check+0x121>
                }
            }
            start = vma->vm_end;
c01090d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01090d5:	8b 40 08             	mov    0x8(%eax),%eax
c01090d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c01090db:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01090de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01090e1:	0f 82 6c ff ff ff    	jb     c0109053 <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c01090e7:	b8 01 00 00 00       	mov    $0x1,%eax
c01090ec:	eb 31                	jmp    c010911f <user_mem_check+0x121>
    }
    return KERN_ACCESS(addr, addr + len);
c01090ee:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c01090f5:	76 23                	jbe    c010911a <user_mem_check+0x11c>
c01090f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01090fa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01090fd:	01 d0                	add    %edx,%eax
c01090ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109102:	76 16                	jbe    c010911a <user_mem_check+0x11c>
c0109104:	8b 45 10             	mov    0x10(%ebp),%eax
c0109107:	8b 55 0c             	mov    0xc(%ebp),%edx
c010910a:	01 d0                	add    %edx,%eax
c010910c:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0109111:	77 07                	ja     c010911a <user_mem_check+0x11c>
c0109113:	b8 01 00 00 00       	mov    $0x1,%eax
c0109118:	eb 05                	jmp    c010911f <user_mem_check+0x121>
c010911a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010911f:	c9                   	leave  
c0109120:	c3                   	ret    

c0109121 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109121:	55                   	push   %ebp
c0109122:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109124:	8b 55 08             	mov    0x8(%ebp),%edx
c0109127:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c010912c:	29 c2                	sub    %eax,%edx
c010912e:	89 d0                	mov    %edx,%eax
c0109130:	c1 f8 05             	sar    $0x5,%eax
}
c0109133:	5d                   	pop    %ebp
c0109134:	c3                   	ret    

c0109135 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109135:	55                   	push   %ebp
c0109136:	89 e5                	mov    %esp,%ebp
c0109138:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010913b:	8b 45 08             	mov    0x8(%ebp),%eax
c010913e:	89 04 24             	mov    %eax,(%esp)
c0109141:	e8 db ff ff ff       	call   c0109121 <page2ppn>
c0109146:	c1 e0 0c             	shl    $0xc,%eax
}
c0109149:	c9                   	leave  
c010914a:	c3                   	ret    

c010914b <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c010914b:	55                   	push   %ebp
c010914c:	89 e5                	mov    %esp,%ebp
c010914e:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109151:	8b 45 08             	mov    0x8(%ebp),%eax
c0109154:	89 04 24             	mov    %eax,(%esp)
c0109157:	e8 d9 ff ff ff       	call   c0109135 <page2pa>
c010915c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010915f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109162:	c1 e8 0c             	shr    $0xc,%eax
c0109165:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109168:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c010916d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109170:	72 23                	jb     c0109195 <page2kva+0x4a>
c0109172:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109175:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109179:	c7 44 24 08 64 dd 10 	movl   $0xc010dd64,0x8(%esp)
c0109180:	c0 
c0109181:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109188:	00 
c0109189:	c7 04 24 87 dd 10 c0 	movl   $0xc010dd87,(%esp)
c0109190:	e8 80 7c ff ff       	call   c0100e15 <__panic>
c0109195:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109198:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010919d:	c9                   	leave  
c010919e:	c3                   	ret    

c010919f <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010919f:	55                   	push   %ebp
c01091a0:	89 e5                	mov    %esp,%ebp
c01091a2:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01091a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091ac:	e8 b4 89 ff ff       	call   c0101b65 <ide_device_valid>
c01091b1:	85 c0                	test   %eax,%eax
c01091b3:	75 1c                	jne    c01091d1 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01091b5:	c7 44 24 08 95 dd 10 	movl   $0xc010dd95,0x8(%esp)
c01091bc:	c0 
c01091bd:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01091c4:	00 
c01091c5:	c7 04 24 af dd 10 c0 	movl   $0xc010ddaf,(%esp)
c01091cc:	e8 44 7c ff ff       	call   c0100e15 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01091d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091d8:	e8 c7 89 ff ff       	call   c0101ba4 <ide_device_size>
c01091dd:	c1 e8 03             	shr    $0x3,%eax
c01091e0:	a3 7c f0 19 c0       	mov    %eax,0xc019f07c
}
c01091e5:	c9                   	leave  
c01091e6:	c3                   	ret    

c01091e7 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01091e7:	55                   	push   %ebp
c01091e8:	89 e5                	mov    %esp,%ebp
c01091ea:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091f0:	89 04 24             	mov    %eax,(%esp)
c01091f3:	e8 53 ff ff ff       	call   c010914b <page2kva>
c01091f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01091fb:	c1 ea 08             	shr    $0x8,%edx
c01091fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109201:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109205:	74 0b                	je     c0109212 <swapfs_read+0x2b>
c0109207:	8b 15 7c f0 19 c0    	mov    0xc019f07c,%edx
c010920d:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109210:	72 23                	jb     c0109235 <swapfs_read+0x4e>
c0109212:	8b 45 08             	mov    0x8(%ebp),%eax
c0109215:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109219:	c7 44 24 08 c0 dd 10 	movl   $0xc010ddc0,0x8(%esp)
c0109220:	c0 
c0109221:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109228:	00 
c0109229:	c7 04 24 af dd 10 c0 	movl   $0xc010ddaf,(%esp)
c0109230:	e8 e0 7b ff ff       	call   c0100e15 <__panic>
c0109235:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109238:	c1 e2 03             	shl    $0x3,%edx
c010923b:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109242:	00 
c0109243:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109247:	89 54 24 04          	mov    %edx,0x4(%esp)
c010924b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109252:	e8 8c 89 ff ff       	call   c0101be3 <ide_read_secs>
}
c0109257:	c9                   	leave  
c0109258:	c3                   	ret    

c0109259 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109259:	55                   	push   %ebp
c010925a:	89 e5                	mov    %esp,%ebp
c010925c:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010925f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109262:	89 04 24             	mov    %eax,(%esp)
c0109265:	e8 e1 fe ff ff       	call   c010914b <page2kva>
c010926a:	8b 55 08             	mov    0x8(%ebp),%edx
c010926d:	c1 ea 08             	shr    $0x8,%edx
c0109270:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109273:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109277:	74 0b                	je     c0109284 <swapfs_write+0x2b>
c0109279:	8b 15 7c f0 19 c0    	mov    0xc019f07c,%edx
c010927f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109282:	72 23                	jb     c01092a7 <swapfs_write+0x4e>
c0109284:	8b 45 08             	mov    0x8(%ebp),%eax
c0109287:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010928b:	c7 44 24 08 c0 dd 10 	movl   $0xc010ddc0,0x8(%esp)
c0109292:	c0 
c0109293:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c010929a:	00 
c010929b:	c7 04 24 af dd 10 c0 	movl   $0xc010ddaf,(%esp)
c01092a2:	e8 6e 7b ff ff       	call   c0100e15 <__panic>
c01092a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01092aa:	c1 e2 03             	shl    $0x3,%edx
c01092ad:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01092b4:	00 
c01092b5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01092b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01092bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092c4:	e8 5c 8b ff ff       	call   c0101e25 <ide_write_secs>
}
c01092c9:	c9                   	leave  
c01092ca:	c3                   	ret    

c01092cb <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01092cb:	52                   	push   %edx
    call *%ebx              # call fn
c01092cc:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01092ce:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01092cf:	e8 3c 0c 00 00       	call   c0109f10 <do_exit>

c01092d4 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c01092d4:	55                   	push   %ebp
c01092d5:	89 e5                	mov    %esp,%ebp
c01092d7:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092da:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e0:	0f ab 02             	bts    %eax,(%edx)
c01092e3:	19 c0                	sbb    %eax,%eax
c01092e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c01092e8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01092ec:	0f 95 c0             	setne  %al
c01092ef:	0f b6 c0             	movzbl %al,%eax
}
c01092f2:	c9                   	leave  
c01092f3:	c3                   	ret    

c01092f4 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c01092f4:	55                   	push   %ebp
c01092f5:	89 e5                	mov    %esp,%ebp
c01092f7:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c01092fa:	8b 55 0c             	mov    0xc(%ebp),%edx
c01092fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109300:	0f b3 02             	btr    %eax,(%edx)
c0109303:	19 c0                	sbb    %eax,%eax
c0109305:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c0109308:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010930c:	0f 95 c0             	setne  %al
c010930f:	0f b6 c0             	movzbl %al,%eax
}
c0109312:	c9                   	leave  
c0109313:	c3                   	ret    

c0109314 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0109314:	55                   	push   %ebp
c0109315:	89 e5                	mov    %esp,%ebp
c0109317:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010931a:	9c                   	pushf  
c010931b:	58                   	pop    %eax
c010931c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010931f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109322:	25 00 02 00 00       	and    $0x200,%eax
c0109327:	85 c0                	test   %eax,%eax
c0109329:	74 0c                	je     c0109337 <__intr_save+0x23>
        intr_disable();
c010932b:	e8 3d 8d ff ff       	call   c010206d <intr_disable>
        return 1;
c0109330:	b8 01 00 00 00       	mov    $0x1,%eax
c0109335:	eb 05                	jmp    c010933c <__intr_save+0x28>
    }
    return 0;
c0109337:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010933c:	c9                   	leave  
c010933d:	c3                   	ret    

c010933e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010933e:	55                   	push   %ebp
c010933f:	89 e5                	mov    %esp,%ebp
c0109341:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109344:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109348:	74 05                	je     c010934f <__intr_restore+0x11>
        intr_enable();
c010934a:	e8 18 8d ff ff       	call   c0102067 <intr_enable>
    }
}
c010934f:	c9                   	leave  
c0109350:	c3                   	ret    

c0109351 <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c0109351:	55                   	push   %ebp
c0109352:	89 e5                	mov    %esp,%ebp
c0109354:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c0109357:	8b 45 08             	mov    0x8(%ebp),%eax
c010935a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010935e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109365:	e8 6a ff ff ff       	call   c01092d4 <test_and_set_bit>
c010936a:	85 c0                	test   %eax,%eax
c010936c:	0f 94 c0             	sete   %al
c010936f:	0f b6 c0             	movzbl %al,%eax
}
c0109372:	c9                   	leave  
c0109373:	c3                   	ret    

c0109374 <lock>:

static inline void
lock(lock_t *lock) {
c0109374:	55                   	push   %ebp
c0109375:	89 e5                	mov    %esp,%ebp
c0109377:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c010937a:	eb 05                	jmp    c0109381 <lock+0xd>
        schedule();
c010937c:	e8 00 1c 00 00       	call   c010af81 <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c0109381:	8b 45 08             	mov    0x8(%ebp),%eax
c0109384:	89 04 24             	mov    %eax,(%esp)
c0109387:	e8 c5 ff ff ff       	call   c0109351 <try_lock>
c010938c:	85 c0                	test   %eax,%eax
c010938e:	74 ec                	je     c010937c <lock+0x8>
        schedule();
    }
}
c0109390:	c9                   	leave  
c0109391:	c3                   	ret    

c0109392 <unlock>:

static inline void
unlock(lock_t *lock) {
c0109392:	55                   	push   %ebp
c0109393:	89 e5                	mov    %esp,%ebp
c0109395:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c0109398:	8b 45 08             	mov    0x8(%ebp),%eax
c010939b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010939f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01093a6:	e8 49 ff ff ff       	call   c01092f4 <test_and_clear_bit>
c01093ab:	85 c0                	test   %eax,%eax
c01093ad:	75 1c                	jne    c01093cb <unlock+0x39>
        panic("Unlock failed.\n");
c01093af:	c7 44 24 08 e0 dd 10 	movl   $0xc010dde0,0x8(%esp)
c01093b6:	c0 
c01093b7:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c01093be:	00 
c01093bf:	c7 04 24 f0 dd 10 c0 	movl   $0xc010ddf0,(%esp)
c01093c6:	e8 4a 7a ff ff       	call   c0100e15 <__panic>
    }
}
c01093cb:	c9                   	leave  
c01093cc:	c3                   	ret    

c01093cd <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01093cd:	55                   	push   %ebp
c01093ce:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01093d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01093d3:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c01093d8:	29 c2                	sub    %eax,%edx
c01093da:	89 d0                	mov    %edx,%eax
c01093dc:	c1 f8 05             	sar    $0x5,%eax
}
c01093df:	5d                   	pop    %ebp
c01093e0:	c3                   	ret    

c01093e1 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01093e1:	55                   	push   %ebp
c01093e2:	89 e5                	mov    %esp,%ebp
c01093e4:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01093e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01093ea:	89 04 24             	mov    %eax,(%esp)
c01093ed:	e8 db ff ff ff       	call   c01093cd <page2ppn>
c01093f2:	c1 e0 0c             	shl    $0xc,%eax
}
c01093f5:	c9                   	leave  
c01093f6:	c3                   	ret    

c01093f7 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01093f7:	55                   	push   %ebp
c01093f8:	89 e5                	mov    %esp,%ebp
c01093fa:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01093fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0109400:	c1 e8 0c             	shr    $0xc,%eax
c0109403:	89 c2                	mov    %eax,%edx
c0109405:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c010940a:	39 c2                	cmp    %eax,%edx
c010940c:	72 1c                	jb     c010942a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010940e:	c7 44 24 08 04 de 10 	movl   $0xc010de04,0x8(%esp)
c0109415:	c0 
c0109416:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010941d:	00 
c010941e:	c7 04 24 23 de 10 c0 	movl   $0xc010de23,(%esp)
c0109425:	e8 eb 79 ff ff       	call   c0100e15 <__panic>
    }
    return &pages[PPN(pa)];
c010942a:	a1 cc ef 19 c0       	mov    0xc019efcc,%eax
c010942f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109432:	c1 ea 0c             	shr    $0xc,%edx
c0109435:	c1 e2 05             	shl    $0x5,%edx
c0109438:	01 d0                	add    %edx,%eax
}
c010943a:	c9                   	leave  
c010943b:	c3                   	ret    

c010943c <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010943c:	55                   	push   %ebp
c010943d:	89 e5                	mov    %esp,%ebp
c010943f:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109442:	8b 45 08             	mov    0x8(%ebp),%eax
c0109445:	89 04 24             	mov    %eax,(%esp)
c0109448:	e8 94 ff ff ff       	call   c01093e1 <page2pa>
c010944d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109450:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109453:	c1 e8 0c             	shr    $0xc,%eax
c0109456:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109459:	a1 e0 ce 19 c0       	mov    0xc019cee0,%eax
c010945e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109461:	72 23                	jb     c0109486 <page2kva+0x4a>
c0109463:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109466:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010946a:	c7 44 24 08 34 de 10 	movl   $0xc010de34,0x8(%esp)
c0109471:	c0 
c0109472:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109479:	00 
c010947a:	c7 04 24 23 de 10 c0 	movl   $0xc010de23,(%esp)
c0109481:	e8 8f 79 ff ff       	call   c0100e15 <__panic>
c0109486:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109489:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010948e:	c9                   	leave  
c010948f:	c3                   	ret    

c0109490 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0109490:	55                   	push   %ebp
c0109491:	89 e5                	mov    %esp,%ebp
c0109493:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109496:	8b 45 08             	mov    0x8(%ebp),%eax
c0109499:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010949c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01094a3:	77 23                	ja     c01094c8 <kva2page+0x38>
c01094a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094ac:	c7 44 24 08 58 de 10 	movl   $0xc010de58,0x8(%esp)
c01094b3:	c0 
c01094b4:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01094bb:	00 
c01094bc:	c7 04 24 23 de 10 c0 	movl   $0xc010de23,(%esp)
c01094c3:	e8 4d 79 ff ff       	call   c0100e15 <__panic>
c01094c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094cb:	05 00 00 00 40       	add    $0x40000000,%eax
c01094d0:	89 04 24             	mov    %eax,(%esp)
c01094d3:	e8 1f ff ff ff       	call   c01093f7 <pa2page>
}
c01094d8:	c9                   	leave  
c01094d9:	c3                   	ret    

c01094da <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c01094da:	55                   	push   %ebp
c01094db:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c01094dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e0:	8b 40 18             	mov    0x18(%eax),%eax
c01094e3:	8d 50 01             	lea    0x1(%eax),%edx
c01094e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01094e9:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c01094ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ef:	8b 40 18             	mov    0x18(%eax),%eax
}
c01094f2:	5d                   	pop    %ebp
c01094f3:	c3                   	ret    

c01094f4 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c01094f4:	55                   	push   %ebp
c01094f5:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c01094f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01094fa:	8b 40 18             	mov    0x18(%eax),%eax
c01094fd:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109500:	8b 45 08             	mov    0x8(%ebp),%eax
c0109503:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0109506:	8b 45 08             	mov    0x8(%ebp),%eax
c0109509:	8b 40 18             	mov    0x18(%eax),%eax
}
c010950c:	5d                   	pop    %ebp
c010950d:	c3                   	ret    

c010950e <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c010950e:	55                   	push   %ebp
c010950f:	89 e5                	mov    %esp,%ebp
c0109511:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109518:	74 0e                	je     c0109528 <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c010951a:	8b 45 08             	mov    0x8(%ebp),%eax
c010951d:	83 c0 1c             	add    $0x1c,%eax
c0109520:	89 04 24             	mov    %eax,(%esp)
c0109523:	e8 4c fe ff ff       	call   c0109374 <lock>
    }
}
c0109528:	c9                   	leave  
c0109529:	c3                   	ret    

c010952a <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c010952a:	55                   	push   %ebp
c010952b:	89 e5                	mov    %esp,%ebp
c010952d:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109530:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109534:	74 0e                	je     c0109544 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c0109536:	8b 45 08             	mov    0x8(%ebp),%eax
c0109539:	83 c0 1c             	add    $0x1c,%eax
c010953c:	89 04 24             	mov    %eax,(%esp)
c010953f:	e8 4e fe ff ff       	call   c0109392 <unlock>
    }
}
c0109544:	c9                   	leave  
c0109545:	c3                   	ret    

c0109546 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109546:	55                   	push   %ebp
c0109547:	89 e5                	mov    %esp,%ebp
c0109549:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010954c:	c7 04 24 7c 00 00 00 	movl   $0x7c,(%esp)
c0109553:	e8 49 b7 ff ff       	call   c0104ca1 <kmalloc>
c0109558:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010955b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010955f:	0f 84 cd 00 00 00    	je     c0109632 <alloc_proc+0xec>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */

        proc->state = PROC_UNINIT;
c0109565:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109568:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c010956e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109571:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109578:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010957b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109582:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109585:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c010958c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010958f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109596:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109599:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c01095a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095a3:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c01095aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ad:	83 c0 1c             	add    $0x1c,%eax
c01095b0:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01095b7:	00 
c01095b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095bf:	00 
c01095c0:	89 04 24             	mov    %eax,(%esp)
c01095c3:	e8 24 27 00 00       	call   c010bcec <memset>
        proc->tf = NULL;
c01095c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095cb:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c01095d2:	8b 15 c8 ef 19 c0    	mov    0xc019efc8,%edx
c01095d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095db:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c01095de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095e1:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01095e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095eb:	83 c0 48             	add    $0x48,%eax
c01095ee:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01095f5:	00 
c01095f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01095fd:	00 
c01095fe:	89 04 24             	mov    %eax,(%esp)
c0109601:	e8 e6 26 00 00       	call   c010bcec <memset>
        proc->wait_state = 0;
c0109606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109609:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL;
c0109610:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109613:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c010961a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010961d:	8b 50 74             	mov    0x74(%eax),%edx
c0109620:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109623:	89 50 78             	mov    %edx,0x78(%eax)
c0109626:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109629:	8b 50 78             	mov    0x78(%eax),%edx
c010962c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010962f:	89 50 70             	mov    %edx,0x70(%eax)
    }
    return proc;
c0109632:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109635:	c9                   	leave  
c0109636:	c3                   	ret    

c0109637 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109637:	55                   	push   %ebp
c0109638:	89 e5                	mov    %esp,%ebp
c010963a:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c010963d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109640:	83 c0 48             	add    $0x48,%eax
c0109643:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010964a:	00 
c010964b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109652:	00 
c0109653:	89 04 24             	mov    %eax,(%esp)
c0109656:	e8 91 26 00 00       	call   c010bcec <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c010965b:	8b 45 08             	mov    0x8(%ebp),%eax
c010965e:	8d 50 48             	lea    0x48(%eax),%edx
c0109661:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109668:	00 
c0109669:	8b 45 0c             	mov    0xc(%ebp),%eax
c010966c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109670:	89 14 24             	mov    %edx,(%esp)
c0109673:	e8 56 27 00 00       	call   c010bdce <memcpy>
}
c0109678:	c9                   	leave  
c0109679:	c3                   	ret    

c010967a <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c010967a:	55                   	push   %ebp
c010967b:	89 e5                	mov    %esp,%ebp
c010967d:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109680:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109687:	00 
c0109688:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010968f:	00 
c0109690:	c7 04 24 a4 ef 19 c0 	movl   $0xc019efa4,(%esp)
c0109697:	e8 50 26 00 00       	call   c010bcec <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c010969c:	8b 45 08             	mov    0x8(%ebp),%eax
c010969f:	83 c0 48             	add    $0x48,%eax
c01096a2:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01096a9:	00 
c01096aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096ae:	c7 04 24 a4 ef 19 c0 	movl   $0xc019efa4,(%esp)
c01096b5:	e8 14 27 00 00       	call   c010bdce <memcpy>
}
c01096ba:	c9                   	leave  
c01096bb:	c3                   	ret    

c01096bc <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c01096bc:	55                   	push   %ebp
c01096bd:	89 e5                	mov    %esp,%ebp
c01096bf:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c01096c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01096c5:	83 c0 58             	add    $0x58,%eax
c01096c8:	c7 45 fc b0 f0 19 c0 	movl   $0xc019f0b0,-0x4(%ebp)
c01096cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01096d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01096d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01096d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01096db:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01096de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e1:	8b 40 04             	mov    0x4(%eax),%eax
c01096e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01096e7:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01096ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01096ed:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01096f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01096f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096f6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01096f9:	89 10                	mov    %edx,(%eax)
c01096fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01096fe:	8b 10                	mov    (%eax),%edx
c0109700:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109703:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109706:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109709:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010970c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010970f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109712:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109715:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c0109717:	8b 45 08             	mov    0x8(%ebp),%eax
c010971a:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c0109721:	8b 45 08             	mov    0x8(%ebp),%eax
c0109724:	8b 40 14             	mov    0x14(%eax),%eax
c0109727:	8b 50 70             	mov    0x70(%eax),%edx
c010972a:	8b 45 08             	mov    0x8(%ebp),%eax
c010972d:	89 50 78             	mov    %edx,0x78(%eax)
c0109730:	8b 45 08             	mov    0x8(%ebp),%eax
c0109733:	8b 40 78             	mov    0x78(%eax),%eax
c0109736:	85 c0                	test   %eax,%eax
c0109738:	74 0c                	je     c0109746 <set_links+0x8a>
        proc->optr->yptr = proc;
c010973a:	8b 45 08             	mov    0x8(%ebp),%eax
c010973d:	8b 40 78             	mov    0x78(%eax),%eax
c0109740:	8b 55 08             	mov    0x8(%ebp),%edx
c0109743:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c0109746:	8b 45 08             	mov    0x8(%ebp),%eax
c0109749:	8b 40 14             	mov    0x14(%eax),%eax
c010974c:	8b 55 08             	mov    0x8(%ebp),%edx
c010974f:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c0109752:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0109757:	83 c0 01             	add    $0x1,%eax
c010975a:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0
}
c010975f:	c9                   	leave  
c0109760:	c3                   	ret    

c0109761 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0109761:	55                   	push   %ebp
c0109762:	89 e5                	mov    %esp,%ebp
c0109764:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c0109767:	8b 45 08             	mov    0x8(%ebp),%eax
c010976a:	83 c0 58             	add    $0x58,%eax
c010976d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109770:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109773:	8b 40 04             	mov    0x4(%eax),%eax
c0109776:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109779:	8b 12                	mov    (%edx),%edx
c010977b:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010977e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109781:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109784:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109787:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010978a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010978d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109790:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c0109792:	8b 45 08             	mov    0x8(%ebp),%eax
c0109795:	8b 40 78             	mov    0x78(%eax),%eax
c0109798:	85 c0                	test   %eax,%eax
c010979a:	74 0f                	je     c01097ab <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c010979c:	8b 45 08             	mov    0x8(%ebp),%eax
c010979f:	8b 40 78             	mov    0x78(%eax),%eax
c01097a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01097a5:	8b 52 74             	mov    0x74(%edx),%edx
c01097a8:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c01097ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ae:	8b 40 74             	mov    0x74(%eax),%eax
c01097b1:	85 c0                	test   %eax,%eax
c01097b3:	74 11                	je     c01097c6 <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c01097b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097b8:	8b 40 74             	mov    0x74(%eax),%eax
c01097bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01097be:	8b 52 78             	mov    0x78(%edx),%edx
c01097c1:	89 50 78             	mov    %edx,0x78(%eax)
c01097c4:	eb 0f                	jmp    c01097d5 <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c01097c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01097c9:	8b 40 14             	mov    0x14(%eax),%eax
c01097cc:	8b 55 08             	mov    0x8(%ebp),%edx
c01097cf:	8b 52 78             	mov    0x78(%edx),%edx
c01097d2:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c01097d5:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c01097da:	83 e8 01             	sub    $0x1,%eax
c01097dd:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0
}
c01097e2:	c9                   	leave  
c01097e3:	c3                   	ret    

c01097e4 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01097e4:	55                   	push   %ebp
c01097e5:	89 e5                	mov    %esp,%ebp
c01097e7:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01097ea:	c7 45 f8 b0 f0 19 c0 	movl   $0xc019f0b0,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01097f1:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c01097f6:	83 c0 01             	add    $0x1,%eax
c01097f9:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c01097fe:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109803:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109808:	7e 0c                	jle    c0109816 <get_pid+0x32>
        last_pid = 1;
c010980a:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c0109811:	00 00 00 
        goto inside;
c0109814:	eb 13                	jmp    c0109829 <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109816:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c010981c:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c0109821:	39 c2                	cmp    %eax,%edx
c0109823:	0f 8c ac 00 00 00    	jl     c01098d5 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109829:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c0109830:	20 00 00 
    repeat:
        le = list;
c0109833:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109836:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109839:	eb 7f                	jmp    c01098ba <get_pid+0xd6>
            proc = le2proc(le, list_link);
c010983b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010983e:	83 e8 58             	sub    $0x58,%eax
c0109841:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109844:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109847:	8b 50 04             	mov    0x4(%eax),%edx
c010984a:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c010984f:	39 c2                	cmp    %eax,%edx
c0109851:	75 3e                	jne    c0109891 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0109853:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109858:	83 c0 01             	add    $0x1,%eax
c010985b:	a3 80 aa 12 c0       	mov    %eax,0xc012aa80
c0109860:	8b 15 80 aa 12 c0    	mov    0xc012aa80,%edx
c0109866:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c010986b:	39 c2                	cmp    %eax,%edx
c010986d:	7c 4b                	jl     c01098ba <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c010986f:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c0109874:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109879:	7e 0a                	jle    c0109885 <get_pid+0xa1>
                        last_pid = 1;
c010987b:	c7 05 80 aa 12 c0 01 	movl   $0x1,0xc012aa80
c0109882:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109885:	c7 05 84 aa 12 c0 00 	movl   $0x2000,0xc012aa84
c010988c:	20 00 00 
                    goto repeat;
c010988f:	eb a2                	jmp    c0109833 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109891:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109894:	8b 50 04             	mov    0x4(%eax),%edx
c0109897:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
c010989c:	39 c2                	cmp    %eax,%edx
c010989e:	7e 1a                	jle    c01098ba <get_pid+0xd6>
c01098a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098a3:	8b 50 04             	mov    0x4(%eax),%edx
c01098a6:	a1 84 aa 12 c0       	mov    0xc012aa84,%eax
c01098ab:	39 c2                	cmp    %eax,%edx
c01098ad:	7d 0b                	jge    c01098ba <get_pid+0xd6>
                next_safe = proc->pid;
c01098af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01098b2:	8b 40 04             	mov    0x4(%eax),%eax
c01098b5:	a3 84 aa 12 c0       	mov    %eax,0xc012aa84
c01098ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01098c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098c3:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c01098c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01098c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098cc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01098cf:	0f 85 66 ff ff ff    	jne    c010983b <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c01098d5:	a1 80 aa 12 c0       	mov    0xc012aa80,%eax
}
c01098da:	c9                   	leave  
c01098db:	c3                   	ret    

c01098dc <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c01098dc:	55                   	push   %ebp
c01098dd:	89 e5                	mov    %esp,%ebp
c01098df:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c01098e2:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01098e7:	39 45 08             	cmp    %eax,0x8(%ebp)
c01098ea:	74 63                	je     c010994f <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01098ec:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c01098f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01098f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01098f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c01098fa:	e8 15 fa ff ff       	call   c0109314 <__intr_save>
c01098ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109902:	8b 45 08             	mov    0x8(%ebp),%eax
c0109905:	a3 88 cf 19 c0       	mov    %eax,0xc019cf88
            load_esp0(next->kstack + KSTACKSIZE);
c010990a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010990d:	8b 40 0c             	mov    0xc(%eax),%eax
c0109910:	05 00 20 00 00       	add    $0x2000,%eax
c0109915:	89 04 24             	mov    %eax,(%esp)
c0109918:	e8 ab b6 ff ff       	call   c0104fc8 <load_esp0>
            lcr3(next->cr3);
c010991d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109920:	8b 40 40             	mov    0x40(%eax),%eax
c0109923:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109926:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109929:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c010992c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010992f:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109935:	83 c0 1c             	add    $0x1c,%eax
c0109938:	89 54 24 04          	mov    %edx,0x4(%esp)
c010993c:	89 04 24             	mov    %eax,(%esp)
c010993f:	e8 45 15 00 00       	call   c010ae89 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109944:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109947:	89 04 24             	mov    %eax,(%esp)
c010994a:	e8 ef f9 ff ff       	call   c010933e <__intr_restore>
    }
}
c010994f:	c9                   	leave  
c0109950:	c3                   	ret    

c0109951 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109951:	55                   	push   %ebp
c0109952:	89 e5                	mov    %esp,%ebp
c0109954:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109957:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010995c:	8b 40 3c             	mov    0x3c(%eax),%eax
c010995f:	89 04 24             	mov    %eax,(%esp)
c0109962:	e8 37 91 ff ff       	call   c0102a9e <forkrets>
}
c0109967:	c9                   	leave  
c0109968:	c3                   	ret    

c0109969 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109969:	55                   	push   %ebp
c010996a:	89 e5                	mov    %esp,%ebp
c010996c:	53                   	push   %ebx
c010996d:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109970:	8b 45 08             	mov    0x8(%ebp),%eax
c0109973:	8d 58 60             	lea    0x60(%eax),%ebx
c0109976:	8b 45 08             	mov    0x8(%ebp),%eax
c0109979:	8b 40 04             	mov    0x4(%eax),%eax
c010997c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109983:	00 
c0109984:	89 04 24             	mov    %eax,(%esp)
c0109987:	e8 b3 18 00 00       	call   c010b23f <hash32>
c010998c:	c1 e0 03             	shl    $0x3,%eax
c010998f:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c0109994:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109997:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c010999a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010999d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01099a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01099a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01099a9:	8b 40 04             	mov    0x4(%eax),%eax
c01099ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01099af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01099b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01099b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
c01099b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01099bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01099c1:	89 10                	mov    %edx,(%eax)
c01099c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01099c6:	8b 10                	mov    (%eax),%edx
c01099c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01099cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01099ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01099d4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01099d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099da:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01099dd:	89 10                	mov    %edx,(%eax)
}
c01099df:	83 c4 34             	add    $0x34,%esp
c01099e2:	5b                   	pop    %ebx
c01099e3:	5d                   	pop    %ebp
c01099e4:	c3                   	ret    

c01099e5 <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c01099e5:	55                   	push   %ebp
c01099e6:	89 e5                	mov    %esp,%ebp
c01099e8:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c01099eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01099ee:	83 c0 60             	add    $0x60,%eax
c01099f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01099f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01099f7:	8b 40 04             	mov    0x4(%eax),%eax
c01099fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01099fd:	8b 12                	mov    (%edx),%edx
c01099ff:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109a05:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a0b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a11:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109a14:	89 10                	mov    %edx,(%eax)
}
c0109a16:	c9                   	leave  
c0109a17:	c3                   	ret    

c0109a18 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109a18:	55                   	push   %ebp
c0109a19:	89 e5                	mov    %esp,%ebp
c0109a1b:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109a1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109a22:	7e 5f                	jle    c0109a83 <find_proc+0x6b>
c0109a24:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109a2b:	7f 56                	jg     c0109a83 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109a2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a30:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109a37:	00 
c0109a38:	89 04 24             	mov    %eax,(%esp)
c0109a3b:	e8 ff 17 00 00       	call   c010b23f <hash32>
c0109a40:	c1 e0 03             	shl    $0x3,%eax
c0109a43:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c0109a48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109a51:	eb 19                	jmp    c0109a6c <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a56:	83 e8 60             	sub    $0x60,%eax
c0109a59:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109a5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a5f:	8b 40 04             	mov    0x4(%eax),%eax
c0109a62:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109a65:	75 05                	jne    c0109a6c <find_proc+0x54>
                return proc;
c0109a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a6a:	eb 1c                	jmp    c0109a88 <find_proc+0x70>
c0109a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a75:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109a78:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a7e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109a81:	75 d0                	jne    c0109a53 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109a88:	c9                   	leave  
c0109a89:	c3                   	ret    

c0109a8a <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109a8a:	55                   	push   %ebp
c0109a8b:	89 e5                	mov    %esp,%ebp
c0109a8d:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109a90:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109a97:	00 
c0109a98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109a9f:	00 
c0109aa0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109aa3:	89 04 24             	mov    %eax,(%esp)
c0109aa6:	e8 41 22 00 00       	call   c010bcec <memset>
    tf.tf_cs = KERNEL_CS;
c0109aab:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109ab1:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109ab7:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109abb:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109abf:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109ac3:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109aca:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109acd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ad0:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109ad3:	b8 cb 92 10 c0       	mov    $0xc01092cb,%eax
c0109ad8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109adb:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ade:	80 cc 01             	or     $0x1,%ah
c0109ae1:	89 c2                	mov    %eax,%edx
c0109ae3:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109ae6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109aea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109af1:	00 
c0109af2:	89 14 24             	mov    %edx,(%esp)
c0109af5:	e8 25 03 00 00       	call   c0109e1f <do_fork>
}
c0109afa:	c9                   	leave  
c0109afb:	c3                   	ret    

c0109afc <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109afc:	55                   	push   %ebp
c0109afd:	89 e5                	mov    %esp,%ebp
c0109aff:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109b02:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109b09:	e8 08 b6 ff ff       	call   c0105116 <alloc_pages>
c0109b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b15:	74 1a                	je     c0109b31 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b1a:	89 04 24             	mov    %eax,(%esp)
c0109b1d:	e8 1a f9 ff ff       	call   c010943c <page2kva>
c0109b22:	89 c2                	mov    %eax,%edx
c0109b24:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b27:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109b2a:	b8 00 00 00 00       	mov    $0x0,%eax
c0109b2f:	eb 05                	jmp    c0109b36 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109b31:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109b36:	c9                   	leave  
c0109b37:	c3                   	ret    

c0109b38 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109b38:	55                   	push   %ebp
c0109b39:	89 e5                	mov    %esp,%ebp
c0109b3b:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109b3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b41:	8b 40 0c             	mov    0xc(%eax),%eax
c0109b44:	89 04 24             	mov    %eax,(%esp)
c0109b47:	e8 44 f9 ff ff       	call   c0109490 <kva2page>
c0109b4c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109b53:	00 
c0109b54:	89 04 24             	mov    %eax,(%esp)
c0109b57:	e8 25 b6 ff ff       	call   c0105181 <free_pages>
}
c0109b5c:	c9                   	leave  
c0109b5d:	c3                   	ret    

c0109b5e <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109b5e:	55                   	push   %ebp
c0109b5f:	89 e5                	mov    %esp,%ebp
c0109b61:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109b64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109b6b:	e8 a6 b5 ff ff       	call   c0105116 <alloc_pages>
c0109b70:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b77:	75 0a                	jne    c0109b83 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109b79:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109b7e:	e9 80 00 00 00       	jmp    c0109c03 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b86:	89 04 24             	mov    %eax,(%esp)
c0109b89:	e8 ae f8 ff ff       	call   c010943c <page2kva>
c0109b8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109b91:	a1 e4 ce 19 c0       	mov    0xc019cee4,%eax
c0109b96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109b9d:	00 
c0109b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ba5:	89 04 24             	mov    %eax,(%esp)
c0109ba8:	e8 21 22 00 00       	call   c010bdce <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bb0:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109bb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109bbc:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109bc3:	77 23                	ja     c0109be8 <setup_pgdir+0x8a>
c0109bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109bc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109bcc:	c7 44 24 08 58 de 10 	movl   $0xc010de58,0x8(%esp)
c0109bd3:	c0 
c0109bd4:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0109bdb:	00 
c0109bdc:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0109be3:	e8 2d 72 ff ff       	call   c0100e15 <__panic>
c0109be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109beb:	05 00 00 00 40       	add    $0x40000000,%eax
c0109bf0:	83 c8 03             	or     $0x3,%eax
c0109bf3:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109bf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109bfb:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109c03:	c9                   	leave  
c0109c04:	c3                   	ret    

c0109c05 <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109c05:	55                   	push   %ebp
c0109c06:	89 e5                	mov    %esp,%ebp
c0109c08:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c0e:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c11:	89 04 24             	mov    %eax,(%esp)
c0109c14:	e8 77 f8 ff ff       	call   c0109490 <kva2page>
c0109c19:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109c20:	00 
c0109c21:	89 04 24             	mov    %eax,(%esp)
c0109c24:	e8 58 b5 ff ff       	call   c0105181 <free_pages>
}
c0109c29:	c9                   	leave  
c0109c2a:	c3                   	ret    

c0109c2b <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109c2b:	55                   	push   %ebp
c0109c2c:	89 e5                	mov    %esp,%ebp
c0109c2e:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109c31:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109c36:	8b 40 18             	mov    0x18(%eax),%eax
c0109c39:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109c3c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109c40:	75 0a                	jne    c0109c4c <copy_mm+0x21>
        return 0;
c0109c42:	b8 00 00 00 00       	mov    $0x0,%eax
c0109c47:	e9 f9 00 00 00       	jmp    c0109d45 <copy_mm+0x11a>
    }
    if (clone_flags & CLONE_VM) {
c0109c4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c4f:	25 00 01 00 00       	and    $0x100,%eax
c0109c54:	85 c0                	test   %eax,%eax
c0109c56:	74 08                	je     c0109c60 <copy_mm+0x35>
        mm = oldmm;
c0109c58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109c5e:	eb 78                	jmp    c0109cd8 <copy_mm+0xad>
    }

    int ret = -E_NO_MEM;
c0109c60:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109c67:	e8 ef e2 ff ff       	call   c0107f5b <mm_create>
c0109c6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c73:	75 05                	jne    c0109c7a <copy_mm+0x4f>
        goto bad_mm;
c0109c75:	e9 c8 00 00 00       	jmp    c0109d42 <copy_mm+0x117>
    }
    if (setup_pgdir(mm) != 0) {
c0109c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c7d:	89 04 24             	mov    %eax,(%esp)
c0109c80:	e8 d9 fe ff ff       	call   c0109b5e <setup_pgdir>
c0109c85:	85 c0                	test   %eax,%eax
c0109c87:	74 05                	je     c0109c8e <copy_mm+0x63>
        goto bad_pgdir_cleanup_mm;
c0109c89:	e9 a9 00 00 00       	jmp    c0109d37 <copy_mm+0x10c>
    }

    lock_mm(oldmm);
c0109c8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c91:	89 04 24             	mov    %eax,(%esp)
c0109c94:	e8 75 f8 ff ff       	call   c010950e <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ca3:	89 04 24             	mov    %eax,(%esp)
c0109ca6:	e8 c7 e7 ff ff       	call   c0108472 <dup_mmap>
c0109cab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cb1:	89 04 24             	mov    %eax,(%esp)
c0109cb4:	e8 71 f8 ff ff       	call   c010952a <unlock_mm>

    if (ret != 0) {
c0109cb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109cbd:	74 19                	je     c0109cd8 <copy_mm+0xad>
        goto bad_dup_cleanup_mmap;
c0109cbf:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cc3:	89 04 24             	mov    %eax,(%esp)
c0109cc6:	e8 a8 e8 ff ff       	call   c0108573 <exit_mmap>
    put_pgdir(mm);
c0109ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cce:	89 04 24             	mov    %eax,(%esp)
c0109cd1:	e8 2f ff ff ff       	call   c0109c05 <put_pgdir>
c0109cd6:	eb 5f                	jmp    c0109d37 <copy_mm+0x10c>
    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cdb:	89 04 24             	mov    %eax,(%esp)
c0109cde:	e8 f7 f7 ff ff       	call   c01094da <mm_count_inc>
    proc->mm = mm;
c0109ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109ce9:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cef:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cf2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109cf5:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109cfc:	77 23                	ja     c0109d21 <copy_mm+0xf6>
c0109cfe:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d01:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109d05:	c7 44 24 08 58 de 10 	movl   $0xc010de58,0x8(%esp)
c0109d0c:	c0 
c0109d0d:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0109d14:	00 
c0109d15:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0109d1c:	e8 f4 70 ff ff       	call   c0100e15 <__panic>
c0109d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d24:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d2d:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109d30:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d35:	eb 0e                	jmp    c0109d45 <copy_mm+0x11a>
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d3a:	89 04 24             	mov    %eax,(%esp)
c0109d3d:	e8 72 e5 ff ff       	call   c01082b4 <mm_destroy>
bad_mm:
    return ret;
c0109d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109d45:	c9                   	leave  
c0109d46:	c3                   	ret    

c0109d47 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109d47:	55                   	push   %ebp
c0109d48:	89 e5                	mov    %esp,%ebp
c0109d4a:	57                   	push   %edi
c0109d4b:	56                   	push   %esi
c0109d4c:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d50:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d53:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109d58:	89 c2                	mov    %eax,%edx
c0109d5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d5d:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d63:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109d66:	8b 55 10             	mov    0x10(%ebp),%edx
c0109d69:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109d6e:	89 c1                	mov    %eax,%ecx
c0109d70:	83 e1 01             	and    $0x1,%ecx
c0109d73:	85 c9                	test   %ecx,%ecx
c0109d75:	74 0e                	je     c0109d85 <copy_thread+0x3e>
c0109d77:	0f b6 0a             	movzbl (%edx),%ecx
c0109d7a:	88 08                	mov    %cl,(%eax)
c0109d7c:	83 c0 01             	add    $0x1,%eax
c0109d7f:	83 c2 01             	add    $0x1,%edx
c0109d82:	83 eb 01             	sub    $0x1,%ebx
c0109d85:	89 c1                	mov    %eax,%ecx
c0109d87:	83 e1 02             	and    $0x2,%ecx
c0109d8a:	85 c9                	test   %ecx,%ecx
c0109d8c:	74 0f                	je     c0109d9d <copy_thread+0x56>
c0109d8e:	0f b7 0a             	movzwl (%edx),%ecx
c0109d91:	66 89 08             	mov    %cx,(%eax)
c0109d94:	83 c0 02             	add    $0x2,%eax
c0109d97:	83 c2 02             	add    $0x2,%edx
c0109d9a:	83 eb 02             	sub    $0x2,%ebx
c0109d9d:	89 d9                	mov    %ebx,%ecx
c0109d9f:	c1 e9 02             	shr    $0x2,%ecx
c0109da2:	89 c7                	mov    %eax,%edi
c0109da4:	89 d6                	mov    %edx,%esi
c0109da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0109da8:	89 f2                	mov    %esi,%edx
c0109daa:	89 f8                	mov    %edi,%eax
c0109dac:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109db1:	89 de                	mov    %ebx,%esi
c0109db3:	83 e6 02             	and    $0x2,%esi
c0109db6:	85 f6                	test   %esi,%esi
c0109db8:	74 0b                	je     c0109dc5 <copy_thread+0x7e>
c0109dba:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109dbe:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109dc2:	83 c1 02             	add    $0x2,%ecx
c0109dc5:	83 e3 01             	and    $0x1,%ebx
c0109dc8:	85 db                	test   %ebx,%ebx
c0109dca:	74 07                	je     c0109dd3 <copy_thread+0x8c>
c0109dcc:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109dd0:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109dd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109dd6:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109dd9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109de0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109de3:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109de6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109de9:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109dec:	8b 45 08             	mov    0x8(%ebp),%eax
c0109def:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109df2:	8b 55 08             	mov    0x8(%ebp),%edx
c0109df5:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109df8:	8b 52 40             	mov    0x40(%edx),%edx
c0109dfb:	80 ce 02             	or     $0x2,%dh
c0109dfe:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109e01:	ba 51 99 10 c0       	mov    $0xc0109951,%edx
c0109e06:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e09:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109e0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e0f:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e12:	89 c2                	mov    %eax,%edx
c0109e14:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e17:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109e1a:	5b                   	pop    %ebx
c0109e1b:	5e                   	pop    %esi
c0109e1c:	5f                   	pop    %edi
c0109e1d:	5d                   	pop    %ebp
c0109e1e:	c3                   	ret    

c0109e1f <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109e1f:	55                   	push   %ebp
c0109e20:	89 e5                	mov    %esp,%ebp
c0109e22:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109e25:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109e2c:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c0109e31:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109e36:	7e 05                	jle    c0109e3d <do_fork+0x1e>
        goto fork_out;
c0109e38:	e9 bf 00 00 00       	jmp    c0109efc <do_fork+0xdd>
    }
    ret = -E_NO_MEM;
c0109e3d:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    proc = alloc_proc();
c0109e44:	e8 fd f6 ff ff       	call   c0109546 <alloc_proc>
c0109e49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (proc == NULL)
c0109e4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109e50:	75 05                	jne    c0109e57 <do_fork+0x38>
        goto fork_out;
c0109e52:	e9 a5 00 00 00       	jmp    c0109efc <do_fork+0xdd>
    proc->parent = current;
c0109e57:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e60:	89 50 14             	mov    %edx,0x14(%eax)
    if (setup_kstack(proc) != 0)
c0109e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e66:	89 04 24             	mov    %eax,(%esp)
c0109e69:	e8 8e fc ff ff       	call   c0109afc <setup_kstack>
c0109e6e:	85 c0                	test   %eax,%eax
c0109e70:	74 05                	je     c0109e77 <do_fork+0x58>
        goto bad_fork_cleanup_proc;
c0109e72:	e9 8a 00 00 00       	jmp    c0109f01 <do_fork+0xe2>
    if (copy_mm(clone_flags, proc) != 0)
c0109e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109e7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e81:	89 04 24             	mov    %eax,(%esp)
c0109e84:	e8 a2 fd ff ff       	call   c0109c2b <copy_mm>
c0109e89:	85 c0                	test   %eax,%eax
c0109e8b:	74 0e                	je     c0109e9b <do_fork+0x7c>
        goto bad_fork_cleanup_kstack;
c0109e8d:	90                   	nop

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e91:	89 04 24             	mov    %eax,(%esp)
c0109e94:	e8 9f fc ff ff       	call   c0109b38 <put_kstack>
c0109e99:	eb 66                	jmp    c0109f01 <do_fork+0xe2>
    proc->parent = current;
    if (setup_kstack(proc) != 0)
        goto bad_fork_cleanup_proc;
    if (copy_mm(clone_flags, proc) != 0)
        goto bad_fork_cleanup_kstack;
    copy_thread(proc, stack, tf);
c0109e9b:	8b 45 10             	mov    0x10(%ebp),%eax
c0109e9e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eac:	89 04 24             	mov    %eax,(%esp)
c0109eaf:	e8 93 fe ff ff       	call   c0109d47 <copy_thread>
    bool intr_flag;
    local_intr_save(intr_flag);
c0109eb4:	e8 5b f4 ff ff       	call   c0109314 <__intr_save>
c0109eb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0109ebc:	e8 23 f9 ff ff       	call   c01097e4 <get_pid>
c0109ec1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109ec4:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c0109ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eca:	89 04 24             	mov    %eax,(%esp)
c0109ecd:	e8 97 fa ff ff       	call   c0109969 <hash_proc>
        set_links(proc);
c0109ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ed5:	89 04 24             	mov    %eax,(%esp)
c0109ed8:	e8 df f7 ff ff       	call   c01096bc <set_links>
        // list_add(&proc_list, &(proc->list_link));
        // nr_process++;
    }
    local_intr_restore(intr_flag);
c0109edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ee0:	89 04 24             	mov    %eax,(%esp)
c0109ee3:	e8 56 f4 ff ff       	call   c010933e <__intr_restore>
    wakeup_proc(proc);
c0109ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109eeb:	89 04 24             	mov    %eax,(%esp)
c0109eee:	e8 0a 10 00 00       	call   c010aefd <wakeup_proc>
    ret = proc->pid;
c0109ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ef6:	8b 40 04             	mov    0x4(%eax),%eax
c0109ef9:	89 45 f4             	mov    %eax,-0xc(%ebp)

fork_out:
    return ret;
c0109efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109eff:	eb 0d                	jmp    c0109f0e <do_fork+0xef>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0109f01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f04:	89 04 24             	mov    %eax,(%esp)
c0109f07:	e8 b0 ad ff ff       	call   c0104cbc <kfree>
    goto fork_out;
c0109f0c:	eb ee                	jmp    c0109efc <do_fork+0xdd>
}
c0109f0e:	c9                   	leave  
c0109f0f:	c3                   	ret    

c0109f10 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109f10:	55                   	push   %ebp
c0109f11:	89 e5                	mov    %esp,%ebp
c0109f13:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c0109f16:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109f1c:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c0109f21:	39 c2                	cmp    %eax,%edx
c0109f23:	75 1c                	jne    c0109f41 <do_exit+0x31>
        panic("idleproc exit.\n");
c0109f25:	c7 44 24 08 90 de 10 	movl   $0xc010de90,0x8(%esp)
c0109f2c:	c0 
c0109f2d:	c7 44 24 04 be 01 00 	movl   $0x1be,0x4(%esp)
c0109f34:	00 
c0109f35:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0109f3c:	e8 d4 6e ff ff       	call   c0100e15 <__panic>
    }
    if (current == initproc) {
c0109f41:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c0109f47:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c0109f4c:	39 c2                	cmp    %eax,%edx
c0109f4e:	75 1c                	jne    c0109f6c <do_exit+0x5c>
        panic("initproc exit.\n");
c0109f50:	c7 44 24 08 a0 de 10 	movl   $0xc010dea0,0x8(%esp)
c0109f57:	c0 
c0109f58:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
c0109f5f:	00 
c0109f60:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c0109f67:	e8 a9 6e ff ff       	call   c0100e15 <__panic>
    }

    struct mm_struct *mm = current->mm;
c0109f6c:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109f71:	8b 40 18             	mov    0x18(%eax),%eax
c0109f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c0109f77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109f7b:	74 4a                	je     c0109fc7 <do_exit+0xb7>
        lcr3(boot_cr3);
c0109f7d:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c0109f82:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109f85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f88:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c0109f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f8e:	89 04 24             	mov    %eax,(%esp)
c0109f91:	e8 5e f5 ff ff       	call   c01094f4 <mm_count_dec>
c0109f96:	85 c0                	test   %eax,%eax
c0109f98:	75 21                	jne    c0109fbb <do_exit+0xab>
            exit_mmap(mm);
c0109f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f9d:	89 04 24             	mov    %eax,(%esp)
c0109fa0:	e8 ce e5 ff ff       	call   c0108573 <exit_mmap>
            put_pgdir(mm);
c0109fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fa8:	89 04 24             	mov    %eax,(%esp)
c0109fab:	e8 55 fc ff ff       	call   c0109c05 <put_pgdir>
            mm_destroy(mm);
c0109fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fb3:	89 04 24             	mov    %eax,(%esp)
c0109fb6:	e8 f9 e2 ff ff       	call   c01082b4 <mm_destroy>
        }
        current->mm = NULL;
c0109fbb:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fc0:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c0109fc7:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fcc:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c0109fd2:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fd7:	8b 55 08             	mov    0x8(%ebp),%edx
c0109fda:	89 50 68             	mov    %edx,0x68(%eax)

    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c0109fdd:	e8 32 f3 ff ff       	call   c0109314 <__intr_save>
c0109fe2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c0109fe5:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c0109fea:	8b 40 14             	mov    0x14(%eax),%eax
c0109fed:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c0109ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ff3:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109ff6:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c0109ffb:	75 10                	jne    c010a00d <do_exit+0xfd>
            wakeup_proc(proc);
c0109ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a000:	89 04 24             	mov    %eax,(%esp)
c010a003:	e8 f5 0e 00 00       	call   c010aefd <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a008:	e9 8b 00 00 00       	jmp    c010a098 <do_exit+0x188>
c010a00d:	e9 86 00 00 00       	jmp    c010a098 <do_exit+0x188>
            proc = current->cptr;
c010a012:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a017:	8b 40 70             	mov    0x70(%eax),%eax
c010a01a:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a01d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a022:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a025:	8b 52 78             	mov    0x78(%edx),%edx
c010a028:	89 50 70             	mov    %edx,0x70(%eax)

            proc->yptr = NULL;
c010a02b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a02e:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a035:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a03a:	8b 50 70             	mov    0x70(%eax),%edx
c010a03d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a040:	89 50 78             	mov    %edx,0x78(%eax)
c010a043:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a046:	8b 40 78             	mov    0x78(%eax),%eax
c010a049:	85 c0                	test   %eax,%eax
c010a04b:	74 0e                	je     c010a05b <do_exit+0x14b>
                initproc->cptr->yptr = proc;
c010a04d:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a052:	8b 40 70             	mov    0x70(%eax),%eax
c010a055:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a058:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a05b:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010a061:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a064:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a067:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a06c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a06f:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a072:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a075:	8b 00                	mov    (%eax),%eax
c010a077:	83 f8 03             	cmp    $0x3,%eax
c010a07a:	75 1c                	jne    c010a098 <do_exit+0x188>
                if (initproc->wait_state == WT_CHILD) {
c010a07c:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a081:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a084:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a089:	75 0d                	jne    c010a098 <do_exit+0x188>
                    wakeup_proc(initproc);
c010a08b:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a090:	89 04 24             	mov    %eax,(%esp)
c010a093:	e8 65 0e 00 00       	call   c010aefd <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a098:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a09d:	8b 40 70             	mov    0x70(%eax),%eax
c010a0a0:	85 c0                	test   %eax,%eax
c010a0a2:	0f 85 6a ff ff ff    	jne    c010a012 <do_exit+0x102>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a0a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0ab:	89 04 24             	mov    %eax,(%esp)
c010a0ae:	e8 8b f2 ff ff       	call   c010933e <__intr_restore>

    schedule();
c010a0b3:	e8 c9 0e 00 00       	call   c010af81 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a0b8:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a0bd:	8b 40 04             	mov    0x4(%eax),%eax
c010a0c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a0c4:	c7 44 24 08 b0 de 10 	movl   $0xc010deb0,0x8(%esp)
c010a0cb:	c0 
c010a0cc:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c010a0d3:	00 
c010a0d4:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a0db:	e8 35 6d ff ff       	call   c0100e15 <__panic>

c010a0e0 <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a0e0:	55                   	push   %ebp
c010a0e1:	89 e5                	mov    %esp,%ebp
c010a0e3:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a0e6:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a0eb:	8b 40 18             	mov    0x18(%eax),%eax
c010a0ee:	85 c0                	test   %eax,%eax
c010a0f0:	74 1c                	je     c010a10e <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a0f2:	c7 44 24 08 d0 de 10 	movl   $0xc010ded0,0x8(%esp)
c010a0f9:	c0 
c010a0fa:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c010a101:	00 
c010a102:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a109:	e8 07 6d ff ff       	call   c0100e15 <__panic>
    }

    int ret = -E_NO_MEM;
c010a10e:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a115:	e8 41 de ff ff       	call   c0107f5b <mm_create>
c010a11a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a11d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a121:	75 06                	jne    c010a129 <load_icode+0x49>
        goto bad_mm;
c010a123:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a124:	e9 ef 05 00 00       	jmp    c010a718 <load_icode+0x638>
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a129:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a12c:	89 04 24             	mov    %eax,(%esp)
c010a12f:	e8 2a fa ff ff       	call   c0109b5e <setup_pgdir>
c010a134:	85 c0                	test   %eax,%eax
c010a136:	74 05                	je     c010a13d <load_icode+0x5d>
        goto bad_pgdir_cleanup_mm;
c010a138:	e9 f6 05 00 00       	jmp    c010a733 <load_icode+0x653>
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a13d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a140:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a143:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a146:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a149:	8b 45 08             	mov    0x8(%ebp),%eax
c010a14c:	01 d0                	add    %edx,%eax
c010a14e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a151:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a154:	8b 00                	mov    (%eax),%eax
c010a156:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a15b:	74 0c                	je     c010a169 <load_icode+0x89>
        ret = -E_INVAL_ELF;
c010a15d:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a164:	e9 bf 05 00 00       	jmp    c010a728 <load_icode+0x648>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a169:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a16c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a170:	0f b7 c0             	movzwl %ax,%eax
c010a173:	c1 e0 05             	shl    $0x5,%eax
c010a176:	89 c2                	mov    %eax,%edx
c010a178:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a17b:	01 d0                	add    %edx,%eax
c010a17d:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a180:	e9 13 03 00 00       	jmp    c010a498 <load_icode+0x3b8>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a185:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a188:	8b 00                	mov    (%eax),%eax
c010a18a:	83 f8 01             	cmp    $0x1,%eax
c010a18d:	74 05                	je     c010a194 <load_icode+0xb4>
            continue ;
c010a18f:	e9 00 03 00 00       	jmp    c010a494 <load_icode+0x3b4>
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a194:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a197:	8b 50 10             	mov    0x10(%eax),%edx
c010a19a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a19d:	8b 40 14             	mov    0x14(%eax),%eax
c010a1a0:	39 c2                	cmp    %eax,%edx
c010a1a2:	76 0c                	jbe    c010a1b0 <load_icode+0xd0>
            ret = -E_INVAL_ELF;
c010a1a4:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a1ab:	e9 6d 05 00 00       	jmp    c010a71d <load_icode+0x63d>
        }
        if (ph->p_filesz == 0) {
c010a1b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1b3:	8b 40 10             	mov    0x10(%eax),%eax
c010a1b6:	85 c0                	test   %eax,%eax
c010a1b8:	75 05                	jne    c010a1bf <load_icode+0xdf>
            continue ;
c010a1ba:	e9 d5 02 00 00       	jmp    c010a494 <load_icode+0x3b4>
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a1bf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a1c6:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a1cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1d0:	8b 40 18             	mov    0x18(%eax),%eax
c010a1d3:	83 e0 01             	and    $0x1,%eax
c010a1d6:	85 c0                	test   %eax,%eax
c010a1d8:	74 04                	je     c010a1de <load_icode+0xfe>
c010a1da:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a1de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1e1:	8b 40 18             	mov    0x18(%eax),%eax
c010a1e4:	83 e0 02             	and    $0x2,%eax
c010a1e7:	85 c0                	test   %eax,%eax
c010a1e9:	74 04                	je     c010a1ef <load_icode+0x10f>
c010a1eb:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a1ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1f2:	8b 40 18             	mov    0x18(%eax),%eax
c010a1f5:	83 e0 04             	and    $0x4,%eax
c010a1f8:	85 c0                	test   %eax,%eax
c010a1fa:	74 04                	je     c010a200 <load_icode+0x120>
c010a1fc:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a200:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a203:	83 e0 02             	and    $0x2,%eax
c010a206:	85 c0                	test   %eax,%eax
c010a208:	74 04                	je     c010a20e <load_icode+0x12e>
c010a20a:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a20e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a211:	8b 50 14             	mov    0x14(%eax),%edx
c010a214:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a217:	8b 40 08             	mov    0x8(%eax),%eax
c010a21a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a221:	00 
c010a222:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a225:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a229:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a22d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a231:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a234:	89 04 24             	mov    %eax,(%esp)
c010a237:	e8 1a e1 ff ff       	call   c0108356 <mm_map>
c010a23c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a23f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a243:	74 05                	je     c010a24a <load_icode+0x16a>
            goto bad_cleanup_mmap;
c010a245:	e9 d3 04 00 00       	jmp    c010a71d <load_icode+0x63d>
        }
        unsigned char *from = binary + ph->p_offset;
c010a24a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a24d:	8b 50 04             	mov    0x4(%eax),%edx
c010a250:	8b 45 08             	mov    0x8(%ebp),%eax
c010a253:	01 d0                	add    %edx,%eax
c010a255:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a258:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a25b:	8b 40 08             	mov    0x8(%eax),%eax
c010a25e:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a261:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a264:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a267:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a26a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a26f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a272:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a279:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a27c:	8b 50 08             	mov    0x8(%eax),%edx
c010a27f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a282:	8b 40 10             	mov    0x10(%eax),%eax
c010a285:	01 d0                	add    %edx,%eax
c010a287:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a28a:	e9 90 00 00 00       	jmp    c010a31f <load_icode+0x23f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a28f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a292:	8b 40 0c             	mov    0xc(%eax),%eax
c010a295:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a298:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a29c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a29f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a2a3:	89 04 24             	mov    %eax,(%esp)
c010a2a6:	e8 4c bd ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a2ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a2ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a2b2:	75 05                	jne    c010a2b9 <load_icode+0x1d9>
                goto bad_cleanup_mmap;
c010a2b4:	e9 64 04 00 00       	jmp    c010a71d <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a2b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a2bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a2bf:	29 c2                	sub    %eax,%edx
c010a2c1:	89 d0                	mov    %edx,%eax
c010a2c3:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a2c6:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a2cb:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a2ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a2d1:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a2d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a2db:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a2de:	73 0d                	jae    c010a2ed <load_icode+0x20d>
                size -= la - end;
c010a2e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a2e3:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a2e6:	29 c2                	sub    %eax,%edx
c010a2e8:	89 d0                	mov    %edx,%eax
c010a2ea:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a2ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2f0:	89 04 24             	mov    %eax,(%esp)
c010a2f3:	e8 44 f1 ff ff       	call   c010943c <page2kva>
c010a2f8:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a2fb:	01 c2                	add    %eax,%edx
c010a2fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a300:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a304:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a307:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a30b:	89 14 24             	mov    %edx,(%esp)
c010a30e:	e8 bb 1a 00 00       	call   c010bdce <memcpy>
            start += size, from += size;
c010a313:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a316:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a319:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a31c:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a31f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a322:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a325:	0f 82 64 ff ff ff    	jb     c010a28f <load_icode+0x1af>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a32b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a32e:	8b 50 08             	mov    0x8(%eax),%edx
c010a331:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a334:	8b 40 14             	mov    0x14(%eax),%eax
c010a337:	01 d0                	add    %edx,%eax
c010a339:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a33c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a33f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a342:	0f 83 b0 00 00 00    	jae    c010a3f8 <load_icode+0x318>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a348:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a34b:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a34e:	75 05                	jne    c010a355 <load_icode+0x275>
                continue ;
c010a350:	e9 3f 01 00 00       	jmp    c010a494 <load_icode+0x3b4>
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a355:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a358:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a35b:	29 c2                	sub    %eax,%edx
c010a35d:	89 d0                	mov    %edx,%eax
c010a35f:	05 00 10 00 00       	add    $0x1000,%eax
c010a364:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a367:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a36c:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a36f:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a372:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a375:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a378:	73 0d                	jae    c010a387 <load_icode+0x2a7>
                size -= la - end;
c010a37a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a37d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a380:	29 c2                	sub    %eax,%edx
c010a382:	89 d0                	mov    %edx,%eax
c010a384:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a387:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a38a:	89 04 24             	mov    %eax,(%esp)
c010a38d:	e8 aa f0 ff ff       	call   c010943c <page2kva>
c010a392:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a395:	01 c2                	add    %eax,%edx
c010a397:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a39a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a39e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a3a5:	00 
c010a3a6:	89 14 24             	mov    %edx,(%esp)
c010a3a9:	e8 3e 19 00 00       	call   c010bcec <memset>
            start += size;
c010a3ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3b1:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a3b4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3b7:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3ba:	73 08                	jae    c010a3c4 <load_icode+0x2e4>
c010a3bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3bf:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a3c2:	74 34                	je     c010a3f8 <load_icode+0x318>
c010a3c4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3c7:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3ca:	72 08                	jb     c010a3d4 <load_icode+0x2f4>
c010a3cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3cf:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3d2:	74 24                	je     c010a3f8 <load_icode+0x318>
c010a3d4:	c7 44 24 0c f8 de 10 	movl   $0xc010def8,0xc(%esp)
c010a3db:	c0 
c010a3dc:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010a3e3:	c0 
c010a3e4:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010a3eb:	00 
c010a3ec:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a3f3:	e8 1d 6a ff ff       	call   c0100e15 <__panic>
        }
        while (start < end) {
c010a3f8:	e9 8b 00 00 00       	jmp    c010a488 <load_icode+0x3a8>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a3fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a400:	8b 40 0c             	mov    0xc(%eax),%eax
c010a403:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a406:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a40a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a40d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a411:	89 04 24             	mov    %eax,(%esp)
c010a414:	e8 de bb ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a419:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a41c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a420:	75 05                	jne    c010a427 <load_icode+0x347>
                goto bad_cleanup_mmap;
c010a422:	e9 f6 02 00 00       	jmp    c010a71d <load_icode+0x63d>
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a427:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a42a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a42d:	29 c2                	sub    %eax,%edx
c010a42f:	89 d0                	mov    %edx,%eax
c010a431:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a434:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a439:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a43c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a43f:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a446:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a449:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a44c:	73 0d                	jae    c010a45b <load_icode+0x37b>
                size -= la - end;
c010a44e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a451:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010a454:	29 c2                	sub    %eax,%edx
c010a456:	89 d0                	mov    %edx,%eax
c010a458:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a45b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a45e:	89 04 24             	mov    %eax,(%esp)
c010a461:	e8 d6 ef ff ff       	call   c010943c <page2kva>
c010a466:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010a469:	01 c2                	add    %eax,%edx
c010a46b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a46e:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a472:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a479:	00 
c010a47a:	89 14 24             	mov    %edx,(%esp)
c010a47d:	e8 6a 18 00 00       	call   c010bcec <memset>
            start += size;
c010a482:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a485:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a488:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a48b:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a48e:	0f 82 69 ff ff ff    	jb     c010a3fd <load_icode+0x31d>
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a494:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a498:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a49b:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a49e:	0f 82 e1 fc ff ff    	jb     c010a185 <load_icode+0xa5>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a4a4:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a4ab:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a4b2:	00 
c010a4b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a4b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a4ba:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a4c1:	00 
c010a4c2:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a4c9:	af 
c010a4ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4cd:	89 04 24             	mov    %eax,(%esp)
c010a4d0:	e8 81 de ff ff       	call   c0108356 <mm_map>
c010a4d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a4d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a4dc:	74 05                	je     c010a4e3 <load_icode+0x403>
        goto bad_cleanup_mmap;
c010a4de:	e9 3a 02 00 00       	jmp    c010a71d <load_icode+0x63d>
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a4e3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4e6:	8b 40 0c             	mov    0xc(%eax),%eax
c010a4e9:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a4f0:	00 
c010a4f1:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a4f8:	af 
c010a4f9:	89 04 24             	mov    %eax,(%esp)
c010a4fc:	e8 f6 ba ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a501:	85 c0                	test   %eax,%eax
c010a503:	75 24                	jne    c010a529 <load_icode+0x449>
c010a505:	c7 44 24 0c 48 df 10 	movl   $0xc010df48,0xc(%esp)
c010a50c:	c0 
c010a50d:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010a514:	c0 
c010a515:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
c010a51c:	00 
c010a51d:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a524:	e8 ec 68 ff ff       	call   c0100e15 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a529:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a52c:	8b 40 0c             	mov    0xc(%eax),%eax
c010a52f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a536:	00 
c010a537:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a53e:	af 
c010a53f:	89 04 24             	mov    %eax,(%esp)
c010a542:	e8 b0 ba ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a547:	85 c0                	test   %eax,%eax
c010a549:	75 24                	jne    c010a56f <load_icode+0x48f>
c010a54b:	c7 44 24 0c 8c df 10 	movl   $0xc010df8c,0xc(%esp)
c010a552:	c0 
c010a553:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010a55a:	c0 
c010a55b:	c7 44 24 04 5d 02 00 	movl   $0x25d,0x4(%esp)
c010a562:	00 
c010a563:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a56a:	e8 a6 68 ff ff       	call   c0100e15 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a56f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a572:	8b 40 0c             	mov    0xc(%eax),%eax
c010a575:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a57c:	00 
c010a57d:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a584:	af 
c010a585:	89 04 24             	mov    %eax,(%esp)
c010a588:	e8 6a ba ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a58d:	85 c0                	test   %eax,%eax
c010a58f:	75 24                	jne    c010a5b5 <load_icode+0x4d5>
c010a591:	c7 44 24 0c d0 df 10 	movl   $0xc010dfd0,0xc(%esp)
c010a598:	c0 
c010a599:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010a5a0:	c0 
c010a5a1:	c7 44 24 04 5e 02 00 	movl   $0x25e,0x4(%esp)
c010a5a8:	00 
c010a5a9:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a5b0:	e8 60 68 ff ff       	call   c0100e15 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a5b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5b8:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5c2:	00 
c010a5c3:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a5ca:	af 
c010a5cb:	89 04 24             	mov    %eax,(%esp)
c010a5ce:	e8 24 ba ff ff       	call   c0105ff7 <pgdir_alloc_page>
c010a5d3:	85 c0                	test   %eax,%eax
c010a5d5:	75 24                	jne    c010a5fb <load_icode+0x51b>
c010a5d7:	c7 44 24 0c 14 e0 10 	movl   $0xc010e014,0xc(%esp)
c010a5de:	c0 
c010a5df:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010a5e6:	c0 
c010a5e7:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
c010a5ee:	00 
c010a5ef:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a5f6:	e8 1a 68 ff ff       	call   c0100e15 <__panic>

    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a5fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5fe:	89 04 24             	mov    %eax,(%esp)
c010a601:	e8 d4 ee ff ff       	call   c01094da <mm_count_inc>
    current->mm = mm;
c010a606:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a60b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a60e:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a611:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a616:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a619:	8b 52 0c             	mov    0xc(%edx),%edx
c010a61c:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a61f:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a626:	77 23                	ja     c010a64b <load_icode+0x56b>
c010a628:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a62b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a62f:	c7 44 24 08 58 de 10 	movl   $0xc010de58,0x8(%esp)
c010a636:	c0 
c010a637:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
c010a63e:	00 
c010a63f:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a646:	e8 ca 67 ff ff       	call   c0100e15 <__panic>
c010a64b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a64e:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a654:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a657:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a65a:	8b 40 0c             	mov    0xc(%eax),%eax
c010a65d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a660:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a667:	77 23                	ja     c010a68c <load_icode+0x5ac>
c010a669:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a66c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a670:	c7 44 24 08 58 de 10 	movl   $0xc010de58,0x8(%esp)
c010a677:	c0 
c010a678:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c010a67f:	00 
c010a680:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a687:	e8 89 67 ff ff       	call   c0100e15 <__panic>
c010a68c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a68f:	05 00 00 00 40       	add    $0x40000000,%eax
c010a694:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a697:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a69a:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a69d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a6a2:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a6a5:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a6a8:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a6af:	00 
c010a6b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a6b7:	00 
c010a6b8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6bb:	89 04 24             	mov    %eax,(%esp)
c010a6be:	e8 29 16 00 00       	call   c010bcec <memset>
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
c010a6c3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6c6:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a6cc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6cf:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a6d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6d8:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a6dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6df:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a6e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6e6:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a6ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6ed:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a6f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a6f4:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a6fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a6fe:	8b 50 18             	mov    0x18(%eax),%edx
c010a701:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a704:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a707:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a70a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a718:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a71b:	eb 23                	jmp    c010a740 <load_icode+0x660>
bad_cleanup_mmap:
    exit_mmap(mm);
c010a71d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a720:	89 04 24             	mov    %eax,(%esp)
c010a723:	e8 4b de ff ff       	call   c0108573 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a728:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a72b:	89 04 24             	mov    %eax,(%esp)
c010a72e:	e8 d2 f4 ff ff       	call   c0109c05 <put_pgdir>
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a736:	89 04 24             	mov    %eax,(%esp)
c010a739:	e8 76 db ff ff       	call   c01082b4 <mm_destroy>
bad_mm:
    goto out;
c010a73e:	eb d8                	jmp    c010a718 <load_icode+0x638>
}
c010a740:	c9                   	leave  
c010a741:	c3                   	ret    

c010a742 <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a742:	55                   	push   %ebp
c010a743:	89 e5                	mov    %esp,%ebp
c010a745:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a748:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a74d:	8b 40 18             	mov    0x18(%eax),%eax
c010a750:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a753:	8b 45 08             	mov    0x8(%ebp),%eax
c010a756:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a75d:	00 
c010a75e:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a761:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a765:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a769:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a76c:	89 04 24             	mov    %eax,(%esp)
c010a76f:	e8 8a e8 ff ff       	call   c0108ffe <user_mem_check>
c010a774:	85 c0                	test   %eax,%eax
c010a776:	75 0a                	jne    c010a782 <do_execve+0x40>
        return -E_INVAL;
c010a778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a77d:	e9 00 01 00 00       	jmp    c010a882 <do_execve+0x140>
    }
    if (len > PROC_NAME_LEN) {
c010a782:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a786:	76 07                	jbe    c010a78f <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a788:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a78f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a796:	00 
c010a797:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a79e:	00 
c010a79f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7a2:	89 04 24             	mov    %eax,(%esp)
c010a7a5:	e8 42 15 00 00       	call   c010bcec <memset>
    memcpy(local_name, name, len);
c010a7aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a7ad:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a7b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a7b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a7bb:	89 04 24             	mov    %eax,(%esp)
c010a7be:	e8 0b 16 00 00       	call   c010bdce <memcpy>

    if (mm != NULL) {
c010a7c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a7c7:	74 4a                	je     c010a813 <do_execve+0xd1>
        lcr3(boot_cr3);
c010a7c9:	a1 c8 ef 19 c0       	mov    0xc019efc8,%eax
c010a7ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a7d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7d4:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7da:	89 04 24             	mov    %eax,(%esp)
c010a7dd:	e8 12 ed ff ff       	call   c01094f4 <mm_count_dec>
c010a7e2:	85 c0                	test   %eax,%eax
c010a7e4:	75 21                	jne    c010a807 <do_execve+0xc5>
            exit_mmap(mm);
c010a7e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7e9:	89 04 24             	mov    %eax,(%esp)
c010a7ec:	e8 82 dd ff ff       	call   c0108573 <exit_mmap>
            put_pgdir(mm);
c010a7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7f4:	89 04 24             	mov    %eax,(%esp)
c010a7f7:	e8 09 f4 ff ff       	call   c0109c05 <put_pgdir>
            mm_destroy(mm);
c010a7fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a7ff:	89 04 24             	mov    %eax,(%esp)
c010a802:	e8 ad da ff ff       	call   c01082b4 <mm_destroy>
        }
        current->mm = NULL;
c010a807:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a80c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    cprintf("load_icode\n");
c010a813:	c7 04 24 57 e0 10 c0 	movl   $0xc010e057,(%esp)
c010a81a:	e8 34 5b ff ff       	call   c0100353 <cprintf>
    if ((ret = load_icode(binary, size)) != 0) {
c010a81f:	8b 45 14             	mov    0x14(%ebp),%eax
c010a822:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a826:	8b 45 10             	mov    0x10(%ebp),%eax
c010a829:	89 04 24             	mov    %eax,(%esp)
c010a82c:	e8 af f8 ff ff       	call   c010a0e0 <load_icode>
c010a831:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a834:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a838:	74 2f                	je     c010a869 <do_execve+0x127>
        goto execve_exit;
c010a83a:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a83b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a83e:	89 04 24             	mov    %eax,(%esp)
c010a841:	e8 ca f6 ff ff       	call   c0109f10 <do_exit>
    panic("already exit: %e.\n", ret);
c010a846:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a849:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a84d:	c7 44 24 08 63 e0 10 	movl   $0xc010e063,0x8(%esp)
c010a854:	c0 
c010a855:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c010a85c:	00 
c010a85d:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a864:	e8 ac 65 ff ff       	call   c0100e15 <__panic>
    int ret;
    cprintf("load_icode\n");
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010a869:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a86e:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a871:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a875:	89 04 24             	mov    %eax,(%esp)
c010a878:	e8 ba ed ff ff       	call   c0109637 <set_proc_name>
    return 0;
c010a87d:	b8 00 00 00 00       	mov    $0x0,%eax

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}
c010a882:	c9                   	leave  
c010a883:	c3                   	ret    

c010a884 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a884:	55                   	push   %ebp
c010a885:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a887:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a88c:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a893:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a898:	5d                   	pop    %ebp
c010a899:	c3                   	ret    

c010a89a <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a89a:	55                   	push   %ebp
c010a89b:	89 e5                	mov    %esp,%ebp
c010a89d:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a8a0:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a8a5:	8b 40 18             	mov    0x18(%eax),%eax
c010a8a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a8ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a8af:	74 30                	je     c010a8e1 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a8b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8b4:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a8bb:	00 
c010a8bc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a8c3:	00 
c010a8c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a8cb:	89 04 24             	mov    %eax,(%esp)
c010a8ce:	e8 2b e7 ff ff       	call   c0108ffe <user_mem_check>
c010a8d3:	85 c0                	test   %eax,%eax
c010a8d5:	75 0a                	jne    c010a8e1 <do_wait+0x47>
            return -E_INVAL;
c010a8d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a8dc:	e9 4b 01 00 00       	jmp    c010aa2c <do_wait+0x192>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a8e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a8e8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a8ec:	74 39                	je     c010a927 <do_wait+0x8d>
        proc = find_proc(pid);
c010a8ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8f1:	89 04 24             	mov    %eax,(%esp)
c010a8f4:	e8 1f f1 ff ff       	call   c0109a18 <find_proc>
c010a8f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a8fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a900:	74 54                	je     c010a956 <do_wait+0xbc>
c010a902:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a905:	8b 50 14             	mov    0x14(%eax),%edx
c010a908:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a90d:	39 c2                	cmp    %eax,%edx
c010a90f:	75 45                	jne    c010a956 <do_wait+0xbc>
            haskid = 1;
c010a911:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a918:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a91b:	8b 00                	mov    (%eax),%eax
c010a91d:	83 f8 03             	cmp    $0x3,%eax
c010a920:	75 34                	jne    c010a956 <do_wait+0xbc>
                goto found;
c010a922:	e9 80 00 00 00       	jmp    c010a9a7 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
c010a927:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a92c:	8b 40 70             	mov    0x70(%eax),%eax
c010a92f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010a932:	eb 1c                	jmp    c010a950 <do_wait+0xb6>
            haskid = 1;
c010a934:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010a93b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a93e:	8b 00                	mov    (%eax),%eax
c010a940:	83 f8 03             	cmp    $0x3,%eax
c010a943:	75 02                	jne    c010a947 <do_wait+0xad>
                goto found;
c010a945:	eb 60                	jmp    c010a9a7 <do_wait+0x10d>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010a947:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a94a:	8b 40 78             	mov    0x78(%eax),%eax
c010a94d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a950:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a954:	75 de                	jne    c010a934 <do_wait+0x9a>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010a956:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a95a:	74 41                	je     c010a99d <do_wait+0x103>
        current->state = PROC_SLEEPING;
c010a95c:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a961:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010a967:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a96c:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010a973:	e8 09 06 00 00       	call   c010af81 <schedule>
        if (current->flags & PF_EXITING) {
c010a978:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010a97d:	8b 40 44             	mov    0x44(%eax),%eax
c010a980:	83 e0 01             	and    $0x1,%eax
c010a983:	85 c0                	test   %eax,%eax
c010a985:	74 11                	je     c010a998 <do_wait+0xfe>
            do_exit(-E_KILLED);
c010a987:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010a98e:	e8 7d f5 ff ff       	call   c0109f10 <do_exit>
        }
        goto repeat;
c010a993:	e9 49 ff ff ff       	jmp    c010a8e1 <do_wait+0x47>
c010a998:	e9 44 ff ff ff       	jmp    c010a8e1 <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010a99d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010a9a2:	e9 85 00 00 00       	jmp    c010aa2c <do_wait+0x192>

found:
    if (proc == idleproc || proc == initproc) {
c010a9a7:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010a9ac:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9af:	74 0a                	je     c010a9bb <do_wait+0x121>
c010a9b1:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010a9b6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010a9b9:	75 1c                	jne    c010a9d7 <do_wait+0x13d>
        panic("wait idleproc or initproc.\n");
c010a9bb:	c7 44 24 08 76 e0 10 	movl   $0xc010e076,0x8(%esp)
c010a9c2:	c0 
c010a9c3:	c7 44 24 04 e1 02 00 	movl   $0x2e1,0x4(%esp)
c010a9ca:	00 
c010a9cb:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010a9d2:	e8 3e 64 ff ff       	call   c0100e15 <__panic>
    }
    if (code_store != NULL) {
c010a9d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a9db:	74 0b                	je     c010a9e8 <do_wait+0x14e>
        *code_store = proc->exit_code;
c010a9dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9e0:	8b 50 68             	mov    0x68(%eax),%edx
c010a9e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9e6:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010a9e8:	e8 27 e9 ff ff       	call   c0109314 <__intr_save>
c010a9ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010a9f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9f3:	89 04 24             	mov    %eax,(%esp)
c010a9f6:	e8 ea ef ff ff       	call   c01099e5 <unhash_proc>
        remove_links(proc);
c010a9fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a9fe:	89 04 24             	mov    %eax,(%esp)
c010aa01:	e8 5b ed ff ff       	call   c0109761 <remove_links>
    }
    local_intr_restore(intr_flag);
c010aa06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aa09:	89 04 24             	mov    %eax,(%esp)
c010aa0c:	e8 2d e9 ff ff       	call   c010933e <__intr_restore>
    put_kstack(proc);
c010aa11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa14:	89 04 24             	mov    %eax,(%esp)
c010aa17:	e8 1c f1 ff ff       	call   c0109b38 <put_kstack>
    kfree(proc);
c010aa1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa1f:	89 04 24             	mov    %eax,(%esp)
c010aa22:	e8 95 a2 ff ff       	call   c0104cbc <kfree>
    return 0;
c010aa27:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aa2c:	c9                   	leave  
c010aa2d:	c3                   	ret    

c010aa2e <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010aa2e:	55                   	push   %ebp
c010aa2f:	89 e5                	mov    %esp,%ebp
c010aa31:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010aa34:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa37:	89 04 24             	mov    %eax,(%esp)
c010aa3a:	e8 d9 ef ff ff       	call   c0109a18 <find_proc>
c010aa3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aa42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa46:	74 41                	je     c010aa89 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010aa48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa4b:	8b 40 44             	mov    0x44(%eax),%eax
c010aa4e:	83 e0 01             	and    $0x1,%eax
c010aa51:	85 c0                	test   %eax,%eax
c010aa53:	75 2d                	jne    c010aa82 <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010aa55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa58:	8b 40 44             	mov    0x44(%eax),%eax
c010aa5b:	83 c8 01             	or     $0x1,%eax
c010aa5e:	89 c2                	mov    %eax,%edx
c010aa60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa63:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010aa66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa69:	8b 40 6c             	mov    0x6c(%eax),%eax
c010aa6c:	85 c0                	test   %eax,%eax
c010aa6e:	79 0b                	jns    c010aa7b <do_kill+0x4d>
                wakeup_proc(proc);
c010aa70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa73:	89 04 24             	mov    %eax,(%esp)
c010aa76:	e8 82 04 00 00       	call   c010aefd <wakeup_proc>
            }
            return 0;
c010aa7b:	b8 00 00 00 00       	mov    $0x0,%eax
c010aa80:	eb 0c                	jmp    c010aa8e <do_kill+0x60>
        }
        return -E_KILLED;
c010aa82:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010aa87:	eb 05                	jmp    c010aa8e <do_kill+0x60>
    }
    return -E_INVAL;
c010aa89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010aa8e:	c9                   	leave  
c010aa8f:	c3                   	ret    

c010aa90 <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010aa90:	55                   	push   %ebp
c010aa91:	89 e5                	mov    %esp,%ebp
c010aa93:	57                   	push   %edi
c010aa94:	56                   	push   %esi
c010aa95:	53                   	push   %ebx
c010aa96:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010aa99:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa9c:	89 04 24             	mov    %eax,(%esp)
c010aa9f:	e8 19 0f 00 00       	call   c010b9bd <strlen>
c010aaa4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aaa7:	b8 04 00 00 00       	mov    $0x4,%eax
c010aaac:	8b 55 08             	mov    0x8(%ebp),%edx
c010aaaf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010aab2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010aab5:	8b 75 10             	mov    0x10(%ebp),%esi
c010aab8:	89 f7                	mov    %esi,%edi
c010aaba:	cd 80                	int    $0x80
c010aabc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010aabf:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010aac2:	83 c4 2c             	add    $0x2c,%esp
c010aac5:	5b                   	pop    %ebx
c010aac6:	5e                   	pop    %esi
c010aac7:	5f                   	pop    %edi
c010aac8:	5d                   	pop    %ebp
c010aac9:	c3                   	ret    

c010aaca <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010aaca:	55                   	push   %ebp
c010aacb:	89 e5                	mov    %esp,%ebp
c010aacd:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    // KERNEL_EXECVE(exit);
    KERNEL_EXECVE(hello);
c010aad0:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010aad5:	8b 40 04             	mov    0x4(%eax),%eax
c010aad8:	c7 44 24 08 92 e0 10 	movl   $0xc010e092,0x8(%esp)
c010aadf:	c0 
c010aae0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aae4:	c7 04 24 98 e0 10 c0 	movl   $0xc010e098,(%esp)
c010aaeb:	e8 63 58 ff ff       	call   c0100353 <cprintf>
c010aaf0:	b8 ac 78 00 00       	mov    $0x78ac,%eax
c010aaf5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010aaf9:	c7 44 24 04 5b 71 16 	movl   $0xc016715b,0x4(%esp)
c010ab00:	c0 
c010ab01:	c7 04 24 92 e0 10 c0 	movl   $0xc010e092,(%esp)
c010ab08:	e8 83 ff ff ff       	call   c010aa90 <kernel_execve>
#endif
    panic("user_main execve failed.\n");
c010ab0d:	c7 44 24 08 bf e0 10 	movl   $0xc010e0bf,0x8(%esp)
c010ab14:	c0 
c010ab15:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
c010ab1c:	00 
c010ab1d:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ab24:	e8 ec 62 ff ff       	call   c0100e15 <__panic>

c010ab29 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ab29:	55                   	push   %ebp
c010ab2a:	89 e5                	mov    %esp,%ebp
c010ab2c:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ab2f:	e8 7f a6 ff ff       	call   c01051b3 <nr_free_pages>
c010ab34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ab37:	e8 48 a0 ff ff       	call   c0104b84 <kallocated>
c010ab3c:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ab3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ab46:	00 
c010ab47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab4e:	00 
c010ab4f:	c7 04 24 ca aa 10 c0 	movl   $0xc010aaca,(%esp)
c010ab56:	e8 2f ef ff ff       	call   c0109a8a <kernel_thread>
c010ab5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ab5e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ab62:	7f 1c                	jg     c010ab80 <init_main+0x57>
        panic("create user_main failed.\n");
c010ab64:	c7 44 24 08 d9 e0 10 	movl   $0xc010e0d9,0x8(%esp)
c010ab6b:	c0 
c010ab6c:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
c010ab73:	00 
c010ab74:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ab7b:	e8 95 62 ff ff       	call   c0100e15 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
c010ab80:	eb 05                	jmp    c010ab87 <init_main+0x5e>
        schedule();
c010ab82:	e8 fa 03 00 00       	call   c010af81 <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010ab87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ab8e:	00 
c010ab8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ab96:	e8 ff fc ff ff       	call   c010a89a <do_wait>
c010ab9b:	85 c0                	test   %eax,%eax
c010ab9d:	74 e3                	je     c010ab82 <init_main+0x59>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010ab9f:	c7 04 24 f4 e0 10 c0 	movl   $0xc010e0f4,(%esp)
c010aba6:	e8 a8 57 ff ff       	call   c0100353 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010abab:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abb0:	8b 40 70             	mov    0x70(%eax),%eax
c010abb3:	85 c0                	test   %eax,%eax
c010abb5:	75 18                	jne    c010abcf <init_main+0xa6>
c010abb7:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abbc:	8b 40 74             	mov    0x74(%eax),%eax
c010abbf:	85 c0                	test   %eax,%eax
c010abc1:	75 0c                	jne    c010abcf <init_main+0xa6>
c010abc3:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010abc8:	8b 40 78             	mov    0x78(%eax),%eax
c010abcb:	85 c0                	test   %eax,%eax
c010abcd:	74 24                	je     c010abf3 <init_main+0xca>
c010abcf:	c7 44 24 0c 18 e1 10 	movl   $0xc010e118,0xc(%esp)
c010abd6:	c0 
c010abd7:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010abde:	c0 
c010abdf:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
c010abe6:	00 
c010abe7:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010abee:	e8 22 62 ff ff       	call   c0100e15 <__panic>
    assert(nr_process == 2);
c010abf3:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010abf8:	83 f8 02             	cmp    $0x2,%eax
c010abfb:	74 24                	je     c010ac21 <init_main+0xf8>
c010abfd:	c7 44 24 0c 63 e1 10 	movl   $0xc010e163,0xc(%esp)
c010ac04:	c0 
c010ac05:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010ac0c:	c0 
c010ac0d:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
c010ac14:	00 
c010ac15:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ac1c:	e8 f4 61 ff ff       	call   c0100e15 <__panic>
c010ac21:	c7 45 e8 b0 f0 19 c0 	movl   $0xc019f0b0,-0x18(%ebp)
c010ac28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ac2b:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ac2e:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010ac34:	83 c2 58             	add    $0x58,%edx
c010ac37:	39 d0                	cmp    %edx,%eax
c010ac39:	74 24                	je     c010ac5f <init_main+0x136>
c010ac3b:	c7 44 24 0c 74 e1 10 	movl   $0xc010e174,0xc(%esp)
c010ac42:	c0 
c010ac43:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010ac4a:	c0 
c010ac4b:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
c010ac52:	00 
c010ac53:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ac5a:	e8 b6 61 ff ff       	call   c0100e15 <__panic>
c010ac5f:	c7 45 e4 b0 f0 19 c0 	movl   $0xc019f0b0,-0x1c(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010ac66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ac69:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ac6b:	8b 15 84 cf 19 c0    	mov    0xc019cf84,%edx
c010ac71:	83 c2 58             	add    $0x58,%edx
c010ac74:	39 d0                	cmp    %edx,%eax
c010ac76:	74 24                	je     c010ac9c <init_main+0x173>
c010ac78:	c7 44 24 0c a4 e1 10 	movl   $0xc010e1a4,0xc(%esp)
c010ac7f:	c0 
c010ac80:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010ac87:	c0 
c010ac88:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
c010ac8f:	00 
c010ac90:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ac97:	e8 79 61 ff ff       	call   c0100e15 <__panic>

    cprintf("init check memory pass.\n");
c010ac9c:	c7 04 24 d4 e1 10 c0 	movl   $0xc010e1d4,(%esp)
c010aca3:	e8 ab 56 ff ff       	call   c0100353 <cprintf>
    return 0;
c010aca8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010acad:	c9                   	leave  
c010acae:	c3                   	ret    

c010acaf <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void
proc_init(void) {
c010acaf:	55                   	push   %ebp
c010acb0:	89 e5                	mov    %esp,%ebp
c010acb2:	83 ec 28             	sub    $0x28,%esp
c010acb5:	c7 45 ec b0 f0 19 c0 	movl   $0xc019f0b0,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010acbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acbf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010acc2:	89 50 04             	mov    %edx,0x4(%eax)
c010acc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acc8:	8b 50 04             	mov    0x4(%eax),%edx
c010accb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010acce:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010acd0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010acd7:	eb 26                	jmp    c010acff <proc_init+0x50>
        list_init(hash_list + i);
c010acd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010acdc:	c1 e0 03             	shl    $0x3,%eax
c010acdf:	05 a0 cf 19 c0       	add    $0xc019cfa0,%eax
c010ace4:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ace7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acea:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010aced:	89 50 04             	mov    %edx,0x4(%eax)
c010acf0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acf3:	8b 50 04             	mov    0x4(%eax),%edx
c010acf6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010acf9:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010acfb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010acff:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010ad06:	7e d1                	jle    c010acd9 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010ad08:	e8 39 e8 ff ff       	call   c0109546 <alloc_proc>
c010ad0d:	a3 80 cf 19 c0       	mov    %eax,0xc019cf80
c010ad12:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad17:	85 c0                	test   %eax,%eax
c010ad19:	75 1c                	jne    c010ad37 <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010ad1b:	c7 44 24 08 ed e1 10 	movl   $0xc010e1ed,0x8(%esp)
c010ad22:	c0 
c010ad23:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
c010ad2a:	00 
c010ad2b:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ad32:	e8 de 60 ff ff       	call   c0100e15 <__panic>
    }

    idleproc->pid = 0;
c010ad37:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad3c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ad43:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad48:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ad4e:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad53:	ba 00 80 12 c0       	mov    $0xc0128000,%edx
c010ad58:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ad5b:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad60:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ad67:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad6c:	c7 44 24 04 05 e2 10 	movl   $0xc010e205,0x4(%esp)
c010ad73:	c0 
c010ad74:	89 04 24             	mov    %eax,(%esp)
c010ad77:	e8 bb e8 ff ff       	call   c0109637 <set_proc_name>
    nr_process ++;
c010ad7c:	a1 a0 ef 19 c0       	mov    0xc019efa0,%eax
c010ad81:	83 c0 01             	add    $0x1,%eax
c010ad84:	a3 a0 ef 19 c0       	mov    %eax,0xc019efa0

    current = idleproc;
c010ad89:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ad8e:	a3 88 cf 19 c0       	mov    %eax,0xc019cf88

    int pid = kernel_thread(init_main, NULL, 0);
c010ad93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ad9a:	00 
c010ad9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ada2:	00 
c010ada3:	c7 04 24 29 ab 10 c0 	movl   $0xc010ab29,(%esp)
c010adaa:	e8 db ec ff ff       	call   c0109a8a <kernel_thread>
c010adaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010adb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010adb6:	7f 1c                	jg     c010add4 <proc_init+0x125>
        panic("create init_main failed.\n");
c010adb8:	c7 44 24 08 0a e2 10 	movl   $0xc010e20a,0x8(%esp)
c010adbf:	c0 
c010adc0:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
c010adc7:	00 
c010adc8:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010adcf:	e8 41 60 ff ff       	call   c0100e15 <__panic>
    }

    initproc = find_proc(pid);
c010add4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010add7:	89 04 24             	mov    %eax,(%esp)
c010adda:	e8 39 ec ff ff       	call   c0109a18 <find_proc>
c010addf:	a3 84 cf 19 c0       	mov    %eax,0xc019cf84
    set_proc_name(initproc, "init");
c010ade4:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010ade9:	c7 44 24 04 24 e2 10 	movl   $0xc010e224,0x4(%esp)
c010adf0:	c0 
c010adf1:	89 04 24             	mov    %eax,(%esp)
c010adf4:	e8 3e e8 ff ff       	call   c0109637 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010adf9:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010adfe:	85 c0                	test   %eax,%eax
c010ae00:	74 0c                	je     c010ae0e <proc_init+0x15f>
c010ae02:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010ae07:	8b 40 04             	mov    0x4(%eax),%eax
c010ae0a:	85 c0                	test   %eax,%eax
c010ae0c:	74 24                	je     c010ae32 <proc_init+0x183>
c010ae0e:	c7 44 24 0c 2c e2 10 	movl   $0xc010e22c,0xc(%esp)
c010ae15:	c0 
c010ae16:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010ae1d:	c0 
c010ae1e:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
c010ae25:	00 
c010ae26:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ae2d:	e8 e3 5f ff ff       	call   c0100e15 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010ae32:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010ae37:	85 c0                	test   %eax,%eax
c010ae39:	74 0d                	je     c010ae48 <proc_init+0x199>
c010ae3b:	a1 84 cf 19 c0       	mov    0xc019cf84,%eax
c010ae40:	8b 40 04             	mov    0x4(%eax),%eax
c010ae43:	83 f8 01             	cmp    $0x1,%eax
c010ae46:	74 24                	je     c010ae6c <proc_init+0x1bd>
c010ae48:	c7 44 24 0c 54 e2 10 	movl   $0xc010e254,0xc(%esp)
c010ae4f:	c0 
c010ae50:	c7 44 24 08 31 df 10 	movl   $0xc010df31,0x8(%esp)
c010ae57:	c0 
c010ae58:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
c010ae5f:	00 
c010ae60:	c7 04 24 7c de 10 c0 	movl   $0xc010de7c,(%esp)
c010ae67:	e8 a9 5f ff ff       	call   c0100e15 <__panic>
}
c010ae6c:	c9                   	leave  
c010ae6d:	c3                   	ret    

c010ae6e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010ae6e:	55                   	push   %ebp
c010ae6f:	89 e5                	mov    %esp,%ebp
c010ae71:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010ae74:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010ae79:	8b 40 10             	mov    0x10(%eax),%eax
c010ae7c:	85 c0                	test   %eax,%eax
c010ae7e:	74 07                	je     c010ae87 <cpu_idle+0x19>
            schedule();
c010ae80:	e8 fc 00 00 00       	call   c010af81 <schedule>
        }
    }
c010ae85:	eb ed                	jmp    c010ae74 <cpu_idle+0x6>
c010ae87:	eb eb                	jmp    c010ae74 <cpu_idle+0x6>

c010ae89 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010ae89:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010ae8d:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010ae8f:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010ae92:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010ae95:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010ae98:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010ae9b:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010ae9e:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010aea1:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010aea4:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010aea8:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010aeab:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010aeae:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010aeb1:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010aeb4:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010aeb7:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010aeba:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010aebd:	ff 30                	pushl  (%eax)

    ret
c010aebf:	c3                   	ret    

c010aec0 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010aec0:	55                   	push   %ebp
c010aec1:	89 e5                	mov    %esp,%ebp
c010aec3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010aec6:	9c                   	pushf  
c010aec7:	58                   	pop    %eax
c010aec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010aecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010aece:	25 00 02 00 00       	and    $0x200,%eax
c010aed3:	85 c0                	test   %eax,%eax
c010aed5:	74 0c                	je     c010aee3 <__intr_save+0x23>
        intr_disable();
c010aed7:	e8 91 71 ff ff       	call   c010206d <intr_disable>
        return 1;
c010aedc:	b8 01 00 00 00       	mov    $0x1,%eax
c010aee1:	eb 05                	jmp    c010aee8 <__intr_save+0x28>
    }
    return 0;
c010aee3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010aee8:	c9                   	leave  
c010aee9:	c3                   	ret    

c010aeea <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010aeea:	55                   	push   %ebp
c010aeeb:	89 e5                	mov    %esp,%ebp
c010aeed:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010aef0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010aef4:	74 05                	je     c010aefb <__intr_restore+0x11>
        intr_enable();
c010aef6:	e8 6c 71 ff ff       	call   c0102067 <intr_enable>
    }
}
c010aefb:	c9                   	leave  
c010aefc:	c3                   	ret    

c010aefd <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010aefd:	55                   	push   %ebp
c010aefe:	89 e5                	mov    %esp,%ebp
c010af00:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010af03:	8b 45 08             	mov    0x8(%ebp),%eax
c010af06:	8b 00                	mov    (%eax),%eax
c010af08:	83 f8 03             	cmp    $0x3,%eax
c010af0b:	75 24                	jne    c010af31 <wakeup_proc+0x34>
c010af0d:	c7 44 24 0c 7b e2 10 	movl   $0xc010e27b,0xc(%esp)
c010af14:	c0 
c010af15:	c7 44 24 08 96 e2 10 	movl   $0xc010e296,0x8(%esp)
c010af1c:	c0 
c010af1d:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010af24:	00 
c010af25:	c7 04 24 ab e2 10 c0 	movl   $0xc010e2ab,(%esp)
c010af2c:	e8 e4 5e ff ff       	call   c0100e15 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010af31:	e8 8a ff ff ff       	call   c010aec0 <__intr_save>
c010af36:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010af39:	8b 45 08             	mov    0x8(%ebp),%eax
c010af3c:	8b 00                	mov    (%eax),%eax
c010af3e:	83 f8 02             	cmp    $0x2,%eax
c010af41:	74 15                	je     c010af58 <wakeup_proc+0x5b>
            proc->state = PROC_RUNNABLE;
c010af43:	8b 45 08             	mov    0x8(%ebp),%eax
c010af46:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010af4c:	8b 45 08             	mov    0x8(%ebp),%eax
c010af4f:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
c010af56:	eb 1c                	jmp    c010af74 <wakeup_proc+0x77>
        }
        else {
            warn("wakeup runnable process.\n");
c010af58:	c7 44 24 08 c1 e2 10 	movl   $0xc010e2c1,0x8(%esp)
c010af5f:	c0 
c010af60:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c010af67:	00 
c010af68:	c7 04 24 ab e2 10 c0 	movl   $0xc010e2ab,(%esp)
c010af6f:	e8 0d 5f ff ff       	call   c0100e81 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010af74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010af77:	89 04 24             	mov    %eax,(%esp)
c010af7a:	e8 6b ff ff ff       	call   c010aeea <__intr_restore>
}
c010af7f:	c9                   	leave  
c010af80:	c3                   	ret    

c010af81 <schedule>:

void
schedule(void) {
c010af81:	55                   	push   %ebp
c010af82:	89 e5                	mov    %esp,%ebp
c010af84:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010af87:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010af8e:	e8 2d ff ff ff       	call   c010aec0 <__intr_save>
c010af93:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010af96:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010af9b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010afa2:	8b 15 88 cf 19 c0    	mov    0xc019cf88,%edx
c010afa8:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010afad:	39 c2                	cmp    %eax,%edx
c010afaf:	74 0a                	je     c010afbb <schedule+0x3a>
c010afb1:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010afb6:	83 c0 58             	add    $0x58,%eax
c010afb9:	eb 05                	jmp    c010afc0 <schedule+0x3f>
c010afbb:	b8 b0 f0 19 c0       	mov    $0xc019f0b0,%eax
c010afc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010afc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010afc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010afcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010afd2:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010afd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afd8:	81 7d f4 b0 f0 19 c0 	cmpl   $0xc019f0b0,-0xc(%ebp)
c010afdf:	74 15                	je     c010aff6 <schedule+0x75>
                next = le2proc(le, list_link);
c010afe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010afe4:	83 e8 58             	sub    $0x58,%eax
c010afe7:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010afea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afed:	8b 00                	mov    (%eax),%eax
c010afef:	83 f8 02             	cmp    $0x2,%eax
c010aff2:	75 02                	jne    c010aff6 <schedule+0x75>
                    break;
c010aff4:	eb 08                	jmp    c010affe <schedule+0x7d>
                }
            }
        } while (le != last);
c010aff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aff9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010affc:	75 cb                	jne    c010afc9 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010affe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b002:	74 0a                	je     c010b00e <schedule+0x8d>
c010b004:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b007:	8b 00                	mov    (%eax),%eax
c010b009:	83 f8 02             	cmp    $0x2,%eax
c010b00c:	74 08                	je     c010b016 <schedule+0x95>
            next = idleproc;
c010b00e:	a1 80 cf 19 c0       	mov    0xc019cf80,%eax
c010b013:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010b016:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b019:	8b 40 08             	mov    0x8(%eax),%eax
c010b01c:	8d 50 01             	lea    0x1(%eax),%edx
c010b01f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b022:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b025:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b02a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b02d:	74 0b                	je     c010b03a <schedule+0xb9>
            proc_run(next);
c010b02f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b032:	89 04 24             	mov    %eax,(%esp)
c010b035:	e8 a2 e8 ff ff       	call   c01098dc <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b03a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b03d:	89 04 24             	mov    %eax,(%esp)
c010b040:	e8 a5 fe ff ff       	call   c010aeea <__intr_restore>
}
c010b045:	c9                   	leave  
c010b046:	c3                   	ret    

c010b047 <sys_exit>:
#include <stdio.h>
#include <pmm.h>
#include <assert.h>

static int
sys_exit(uint32_t arg[]) {
c010b047:	55                   	push   %ebp
c010b048:	89 e5                	mov    %esp,%ebp
c010b04a:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b04d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b050:	8b 00                	mov    (%eax),%eax
c010b052:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b055:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b058:	89 04 24             	mov    %eax,(%esp)
c010b05b:	e8 b0 ee ff ff       	call   c0109f10 <do_exit>
}
c010b060:	c9                   	leave  
c010b061:	c3                   	ret    

c010b062 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b062:	55                   	push   %ebp
c010b063:	89 e5                	mov    %esp,%ebp
c010b065:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b068:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b06d:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b070:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b073:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b076:	8b 40 44             	mov    0x44(%eax),%eax
c010b079:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b07c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b07f:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b083:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b086:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b08a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b091:	e8 89 ed ff ff       	call   c0109e1f <do_fork>
}
c010b096:	c9                   	leave  
c010b097:	c3                   	ret    

c010b098 <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b098:	55                   	push   %ebp
c010b099:	89 e5                	mov    %esp,%ebp
c010b09b:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b09e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0a1:	8b 00                	mov    (%eax),%eax
c010b0a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b0a6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0a9:	83 c0 04             	add    $0x4,%eax
c010b0ac:	8b 00                	mov    (%eax),%eax
c010b0ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b0b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b0b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0bb:	89 04 24             	mov    %eax,(%esp)
c010b0be:	e8 d7 f7 ff ff       	call   c010a89a <do_wait>
}
c010b0c3:	c9                   	leave  
c010b0c4:	c3                   	ret    

c010b0c5 <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b0c5:	55                   	push   %ebp
c010b0c6:	89 e5                	mov    %esp,%ebp
c010b0c8:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b0cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ce:	8b 00                	mov    (%eax),%eax
c010b0d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b0d3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0d6:	8b 40 04             	mov    0x4(%eax),%eax
c010b0d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b0dc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0df:	83 c0 08             	add    $0x8,%eax
c010b0e2:	8b 00                	mov    (%eax),%eax
c010b0e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b0e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0ea:	8b 40 0c             	mov    0xc(%eax),%eax
c010b0ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b0f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b0f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b0f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b0fa:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b0fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b101:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b105:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b108:	89 04 24             	mov    %eax,(%esp)
c010b10b:	e8 32 f6 ff ff       	call   c010a742 <do_execve>
}
c010b110:	c9                   	leave  
c010b111:	c3                   	ret    

c010b112 <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b112:	55                   	push   %ebp
c010b113:	89 e5                	mov    %esp,%ebp
c010b115:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b118:	e8 67 f7 ff ff       	call   c010a884 <do_yield>
}
c010b11d:	c9                   	leave  
c010b11e:	c3                   	ret    

c010b11f <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b11f:	55                   	push   %ebp
c010b120:	89 e5                	mov    %esp,%ebp
c010b122:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b125:	8b 45 08             	mov    0x8(%ebp),%eax
c010b128:	8b 00                	mov    (%eax),%eax
c010b12a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b12d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b130:	89 04 24             	mov    %eax,(%esp)
c010b133:	e8 f6 f8 ff ff       	call   c010aa2e <do_kill>
}
c010b138:	c9                   	leave  
c010b139:	c3                   	ret    

c010b13a <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b13a:	55                   	push   %ebp
c010b13b:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b13d:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b142:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b145:	5d                   	pop    %ebp
c010b146:	c3                   	ret    

c010b147 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b147:	55                   	push   %ebp
c010b148:	89 e5                	mov    %esp,%ebp
c010b14a:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b14d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b150:	8b 00                	mov    (%eax),%eax
c010b152:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b155:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b158:	89 04 24             	mov    %eax,(%esp)
c010b15b:	e8 19 52 ff ff       	call   c0100379 <cputchar>
    return 0;
c010b160:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b165:	c9                   	leave  
c010b166:	c3                   	ret    

c010b167 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b167:	55                   	push   %ebp
c010b168:	89 e5                	mov    %esp,%ebp
c010b16a:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b16d:	e8 9f ba ff ff       	call   c0106c11 <print_pgdir>
    return 0;
c010b172:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b177:	c9                   	leave  
c010b178:	c3                   	ret    

c010b179 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b179:	55                   	push   %ebp
c010b17a:	89 e5                	mov    %esp,%ebp
c010b17c:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b17f:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b184:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b187:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b18d:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b190:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b193:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b197:	78 5e                	js     c010b1f7 <syscall+0x7e>
c010b199:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b19c:	83 f8 1f             	cmp    $0x1f,%eax
c010b19f:	77 56                	ja     c010b1f7 <syscall+0x7e>
        if (syscalls[num] != NULL) {
c010b1a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1a4:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b1ab:	85 c0                	test   %eax,%eax
c010b1ad:	74 48                	je     c010b1f7 <syscall+0x7e>
            arg[0] = tf->tf_regs.reg_edx;
c010b1af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1b2:	8b 40 14             	mov    0x14(%eax),%eax
c010b1b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b1b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1bb:	8b 40 18             	mov    0x18(%eax),%eax
c010b1be:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b1c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1c4:	8b 40 10             	mov    0x10(%eax),%eax
c010b1c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b1ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1cd:	8b 00                	mov    (%eax),%eax
c010b1cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b1d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1d5:	8b 40 04             	mov    0x4(%eax),%eax
c010b1d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b1db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b1de:	8b 04 85 a0 aa 12 c0 	mov    -0x3fed5560(,%eax,4),%eax
c010b1e5:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b1e8:	89 14 24             	mov    %edx,(%esp)
c010b1eb:	ff d0                	call   *%eax
c010b1ed:	89 c2                	mov    %eax,%edx
c010b1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1f2:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b1f5:	eb 46                	jmp    c010b23d <syscall+0xc4>
        }
    }
    print_trapframe(tf);
c010b1f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1fa:	89 04 24             	mov    %eax,(%esp)
c010b1fd:	e8 02 72 ff ff       	call   c0102404 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b202:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b207:	8d 50 48             	lea    0x48(%eax),%edx
c010b20a:	a1 88 cf 19 c0       	mov    0xc019cf88,%eax
c010b20f:	8b 40 04             	mov    0x4(%eax),%eax
c010b212:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b216:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b21a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b21d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b221:	c7 44 24 08 dc e2 10 	movl   $0xc010e2dc,0x8(%esp)
c010b228:	c0 
c010b229:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010b230:	00 
c010b231:	c7 04 24 08 e3 10 c0 	movl   $0xc010e308,(%esp)
c010b238:	e8 d8 5b ff ff       	call   c0100e15 <__panic>
            num, current->pid, current->name);
}
c010b23d:	c9                   	leave  
c010b23e:	c3                   	ret    

c010b23f <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010b23f:	55                   	push   %ebp
c010b240:	89 e5                	mov    %esp,%ebp
c010b242:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010b245:	8b 45 08             	mov    0x8(%ebp),%eax
c010b248:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010b24e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010b251:	b8 20 00 00 00       	mov    $0x20,%eax
c010b256:	2b 45 0c             	sub    0xc(%ebp),%eax
c010b259:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b25c:	89 c1                	mov    %eax,%ecx
c010b25e:	d3 ea                	shr    %cl,%edx
c010b260:	89 d0                	mov    %edx,%eax
}
c010b262:	c9                   	leave  
c010b263:	c3                   	ret    

c010b264 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010b264:	55                   	push   %ebp
c010b265:	89 e5                	mov    %esp,%ebp
c010b267:	83 ec 58             	sub    $0x58,%esp
c010b26a:	8b 45 10             	mov    0x10(%ebp),%eax
c010b26d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010b270:	8b 45 14             	mov    0x14(%ebp),%eax
c010b273:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010b276:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010b279:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010b27c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b27f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010b282:	8b 45 18             	mov    0x18(%ebp),%eax
c010b285:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b288:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b28b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b28e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b291:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010b294:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b297:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b29a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b29e:	74 1c                	je     c010b2bc <printnum+0x58>
c010b2a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2a3:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2a8:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010b2ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2b1:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2b6:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b2bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b2c2:	f7 75 e4             	divl   -0x1c(%ebp)
c010b2c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b2c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010b2cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b2d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b2d4:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b2d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b2da:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010b2dd:	8b 45 18             	mov    0x18(%ebp),%eax
c010b2e0:	ba 00 00 00 00       	mov    $0x0,%edx
c010b2e5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b2e8:	77 56                	ja     c010b340 <printnum+0xdc>
c010b2ea:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010b2ed:	72 05                	jb     c010b2f4 <printnum+0x90>
c010b2ef:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010b2f2:	77 4c                	ja     c010b340 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010b2f4:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010b2f7:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b2fa:	8b 45 20             	mov    0x20(%ebp),%eax
c010b2fd:	89 44 24 18          	mov    %eax,0x18(%esp)
c010b301:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b305:	8b 45 18             	mov    0x18(%ebp),%eax
c010b308:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b30c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b30f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b312:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b316:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b31a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b31d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b321:	8b 45 08             	mov    0x8(%ebp),%eax
c010b324:	89 04 24             	mov    %eax,(%esp)
c010b327:	e8 38 ff ff ff       	call   c010b264 <printnum>
c010b32c:	eb 1c                	jmp    c010b34a <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010b32e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b331:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b335:	8b 45 20             	mov    0x20(%ebp),%eax
c010b338:	89 04 24             	mov    %eax,(%esp)
c010b33b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b33e:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010b340:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010b344:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010b348:	7f e4                	jg     c010b32e <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010b34a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b34d:	05 24 e4 10 c0       	add    $0xc010e424,%eax
c010b352:	0f b6 00             	movzbl (%eax),%eax
c010b355:	0f be c0             	movsbl %al,%eax
c010b358:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b35b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b35f:	89 04 24             	mov    %eax,(%esp)
c010b362:	8b 45 08             	mov    0x8(%ebp),%eax
c010b365:	ff d0                	call   *%eax
}
c010b367:	c9                   	leave  
c010b368:	c3                   	ret    

c010b369 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010b369:	55                   	push   %ebp
c010b36a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b36c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b370:	7e 14                	jle    c010b386 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010b372:	8b 45 08             	mov    0x8(%ebp),%eax
c010b375:	8b 00                	mov    (%eax),%eax
c010b377:	8d 48 08             	lea    0x8(%eax),%ecx
c010b37a:	8b 55 08             	mov    0x8(%ebp),%edx
c010b37d:	89 0a                	mov    %ecx,(%edx)
c010b37f:	8b 50 04             	mov    0x4(%eax),%edx
c010b382:	8b 00                	mov    (%eax),%eax
c010b384:	eb 30                	jmp    c010b3b6 <getuint+0x4d>
    }
    else if (lflag) {
c010b386:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b38a:	74 16                	je     c010b3a2 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010b38c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b38f:	8b 00                	mov    (%eax),%eax
c010b391:	8d 48 04             	lea    0x4(%eax),%ecx
c010b394:	8b 55 08             	mov    0x8(%ebp),%edx
c010b397:	89 0a                	mov    %ecx,(%edx)
c010b399:	8b 00                	mov    (%eax),%eax
c010b39b:	ba 00 00 00 00       	mov    $0x0,%edx
c010b3a0:	eb 14                	jmp    c010b3b6 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010b3a2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3a5:	8b 00                	mov    (%eax),%eax
c010b3a7:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3aa:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3ad:	89 0a                	mov    %ecx,(%edx)
c010b3af:	8b 00                	mov    (%eax),%eax
c010b3b1:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010b3b6:	5d                   	pop    %ebp
c010b3b7:	c3                   	ret    

c010b3b8 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010b3b8:	55                   	push   %ebp
c010b3b9:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010b3bb:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010b3bf:	7e 14                	jle    c010b3d5 <getint+0x1d>
        return va_arg(*ap, long long);
c010b3c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3c4:	8b 00                	mov    (%eax),%eax
c010b3c6:	8d 48 08             	lea    0x8(%eax),%ecx
c010b3c9:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3cc:	89 0a                	mov    %ecx,(%edx)
c010b3ce:	8b 50 04             	mov    0x4(%eax),%edx
c010b3d1:	8b 00                	mov    (%eax),%eax
c010b3d3:	eb 28                	jmp    c010b3fd <getint+0x45>
    }
    else if (lflag) {
c010b3d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b3d9:	74 12                	je     c010b3ed <getint+0x35>
        return va_arg(*ap, long);
c010b3db:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3de:	8b 00                	mov    (%eax),%eax
c010b3e0:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3e3:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3e6:	89 0a                	mov    %ecx,(%edx)
c010b3e8:	8b 00                	mov    (%eax),%eax
c010b3ea:	99                   	cltd   
c010b3eb:	eb 10                	jmp    c010b3fd <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010b3ed:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3f0:	8b 00                	mov    (%eax),%eax
c010b3f2:	8d 48 04             	lea    0x4(%eax),%ecx
c010b3f5:	8b 55 08             	mov    0x8(%ebp),%edx
c010b3f8:	89 0a                	mov    %ecx,(%edx)
c010b3fa:	8b 00                	mov    (%eax),%eax
c010b3fc:	99                   	cltd   
    }
}
c010b3fd:	5d                   	pop    %ebp
c010b3fe:	c3                   	ret    

c010b3ff <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010b3ff:	55                   	push   %ebp
c010b400:	89 e5                	mov    %esp,%ebp
c010b402:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010b405:	8d 45 14             	lea    0x14(%ebp),%eax
c010b408:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010b40b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b40e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b412:	8b 45 10             	mov    0x10(%ebp),%eax
c010b415:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b419:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b41c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b420:	8b 45 08             	mov    0x8(%ebp),%eax
c010b423:	89 04 24             	mov    %eax,(%esp)
c010b426:	e8 02 00 00 00       	call   c010b42d <vprintfmt>
    va_end(ap);
}
c010b42b:	c9                   	leave  
c010b42c:	c3                   	ret    

c010b42d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010b42d:	55                   	push   %ebp
c010b42e:	89 e5                	mov    %esp,%ebp
c010b430:	56                   	push   %esi
c010b431:	53                   	push   %ebx
c010b432:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b435:	eb 18                	jmp    c010b44f <vprintfmt+0x22>
            if (ch == '\0') {
c010b437:	85 db                	test   %ebx,%ebx
c010b439:	75 05                	jne    c010b440 <vprintfmt+0x13>
                return;
c010b43b:	e9 d1 03 00 00       	jmp    c010b811 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010b440:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b443:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b447:	89 1c 24             	mov    %ebx,(%esp)
c010b44a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b44d:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b44f:	8b 45 10             	mov    0x10(%ebp),%eax
c010b452:	8d 50 01             	lea    0x1(%eax),%edx
c010b455:	89 55 10             	mov    %edx,0x10(%ebp)
c010b458:	0f b6 00             	movzbl (%eax),%eax
c010b45b:	0f b6 d8             	movzbl %al,%ebx
c010b45e:	83 fb 25             	cmp    $0x25,%ebx
c010b461:	75 d4                	jne    c010b437 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010b463:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010b467:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010b46e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b471:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010b474:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010b47b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b47e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010b481:	8b 45 10             	mov    0x10(%ebp),%eax
c010b484:	8d 50 01             	lea    0x1(%eax),%edx
c010b487:	89 55 10             	mov    %edx,0x10(%ebp)
c010b48a:	0f b6 00             	movzbl (%eax),%eax
c010b48d:	0f b6 d8             	movzbl %al,%ebx
c010b490:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010b493:	83 f8 55             	cmp    $0x55,%eax
c010b496:	0f 87 44 03 00 00    	ja     c010b7e0 <vprintfmt+0x3b3>
c010b49c:	8b 04 85 48 e4 10 c0 	mov    -0x3fef1bb8(,%eax,4),%eax
c010b4a3:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010b4a5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010b4a9:	eb d6                	jmp    c010b481 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010b4ab:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010b4af:	eb d0                	jmp    c010b481 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b4b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010b4b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b4bb:	89 d0                	mov    %edx,%eax
c010b4bd:	c1 e0 02             	shl    $0x2,%eax
c010b4c0:	01 d0                	add    %edx,%eax
c010b4c2:	01 c0                	add    %eax,%eax
c010b4c4:	01 d8                	add    %ebx,%eax
c010b4c6:	83 e8 30             	sub    $0x30,%eax
c010b4c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010b4cc:	8b 45 10             	mov    0x10(%ebp),%eax
c010b4cf:	0f b6 00             	movzbl (%eax),%eax
c010b4d2:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010b4d5:	83 fb 2f             	cmp    $0x2f,%ebx
c010b4d8:	7e 0b                	jle    c010b4e5 <vprintfmt+0xb8>
c010b4da:	83 fb 39             	cmp    $0x39,%ebx
c010b4dd:	7f 06                	jg     c010b4e5 <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010b4df:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010b4e3:	eb d3                	jmp    c010b4b8 <vprintfmt+0x8b>
            goto process_precision;
c010b4e5:	eb 33                	jmp    c010b51a <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010b4e7:	8b 45 14             	mov    0x14(%ebp),%eax
c010b4ea:	8d 50 04             	lea    0x4(%eax),%edx
c010b4ed:	89 55 14             	mov    %edx,0x14(%ebp)
c010b4f0:	8b 00                	mov    (%eax),%eax
c010b4f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010b4f5:	eb 23                	jmp    c010b51a <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010b4f7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b4fb:	79 0c                	jns    c010b509 <vprintfmt+0xdc>
                width = 0;
c010b4fd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010b504:	e9 78 ff ff ff       	jmp    c010b481 <vprintfmt+0x54>
c010b509:	e9 73 ff ff ff       	jmp    c010b481 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010b50e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010b515:	e9 67 ff ff ff       	jmp    c010b481 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010b51a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b51e:	79 12                	jns    c010b532 <vprintfmt+0x105>
                width = precision, precision = -1;
c010b520:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b523:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b526:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010b52d:	e9 4f ff ff ff       	jmp    c010b481 <vprintfmt+0x54>
c010b532:	e9 4a ff ff ff       	jmp    c010b481 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010b537:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010b53b:	e9 41 ff ff ff       	jmp    c010b481 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010b540:	8b 45 14             	mov    0x14(%ebp),%eax
c010b543:	8d 50 04             	lea    0x4(%eax),%edx
c010b546:	89 55 14             	mov    %edx,0x14(%ebp)
c010b549:	8b 00                	mov    (%eax),%eax
c010b54b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b54e:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b552:	89 04 24             	mov    %eax,(%esp)
c010b555:	8b 45 08             	mov    0x8(%ebp),%eax
c010b558:	ff d0                	call   *%eax
            break;
c010b55a:	e9 ac 02 00 00       	jmp    c010b80b <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010b55f:	8b 45 14             	mov    0x14(%ebp),%eax
c010b562:	8d 50 04             	lea    0x4(%eax),%edx
c010b565:	89 55 14             	mov    %edx,0x14(%ebp)
c010b568:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010b56a:	85 db                	test   %ebx,%ebx
c010b56c:	79 02                	jns    c010b570 <vprintfmt+0x143>
                err = -err;
c010b56e:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010b570:	83 fb 18             	cmp    $0x18,%ebx
c010b573:	7f 0b                	jg     c010b580 <vprintfmt+0x153>
c010b575:	8b 34 9d c0 e3 10 c0 	mov    -0x3fef1c40(,%ebx,4),%esi
c010b57c:	85 f6                	test   %esi,%esi
c010b57e:	75 23                	jne    c010b5a3 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010b580:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010b584:	c7 44 24 08 35 e4 10 	movl   $0xc010e435,0x8(%esp)
c010b58b:	c0 
c010b58c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b58f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b593:	8b 45 08             	mov    0x8(%ebp),%eax
c010b596:	89 04 24             	mov    %eax,(%esp)
c010b599:	e8 61 fe ff ff       	call   c010b3ff <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010b59e:	e9 68 02 00 00       	jmp    c010b80b <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010b5a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010b5a7:	c7 44 24 08 3e e4 10 	movl   $0xc010e43e,0x8(%esp)
c010b5ae:	c0 
c010b5af:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b5b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5b6:	8b 45 08             	mov    0x8(%ebp),%eax
c010b5b9:	89 04 24             	mov    %eax,(%esp)
c010b5bc:	e8 3e fe ff ff       	call   c010b3ff <printfmt>
            }
            break;
c010b5c1:	e9 45 02 00 00       	jmp    c010b80b <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010b5c6:	8b 45 14             	mov    0x14(%ebp),%eax
c010b5c9:	8d 50 04             	lea    0x4(%eax),%edx
c010b5cc:	89 55 14             	mov    %edx,0x14(%ebp)
c010b5cf:	8b 30                	mov    (%eax),%esi
c010b5d1:	85 f6                	test   %esi,%esi
c010b5d3:	75 05                	jne    c010b5da <vprintfmt+0x1ad>
                p = "(null)";
c010b5d5:	be 41 e4 10 c0       	mov    $0xc010e441,%esi
            }
            if (width > 0 && padc != '-') {
c010b5da:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b5de:	7e 3e                	jle    c010b61e <vprintfmt+0x1f1>
c010b5e0:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010b5e4:	74 38                	je     c010b61e <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b5e6:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010b5e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b5ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b5f0:	89 34 24             	mov    %esi,(%esp)
c010b5f3:	e8 ed 03 00 00       	call   c010b9e5 <strnlen>
c010b5f8:	29 c3                	sub    %eax,%ebx
c010b5fa:	89 d8                	mov    %ebx,%eax
c010b5fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b5ff:	eb 17                	jmp    c010b618 <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010b601:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010b605:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b608:	89 54 24 04          	mov    %edx,0x4(%esp)
c010b60c:	89 04 24             	mov    %eax,(%esp)
c010b60f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b612:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010b614:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b618:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b61c:	7f e3                	jg     c010b601 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b61e:	eb 38                	jmp    c010b658 <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010b620:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010b624:	74 1f                	je     c010b645 <vprintfmt+0x218>
c010b626:	83 fb 1f             	cmp    $0x1f,%ebx
c010b629:	7e 05                	jle    c010b630 <vprintfmt+0x203>
c010b62b:	83 fb 7e             	cmp    $0x7e,%ebx
c010b62e:	7e 15                	jle    c010b645 <vprintfmt+0x218>
                    putch('?', putdat);
c010b630:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b633:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b637:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010b63e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b641:	ff d0                	call   *%eax
c010b643:	eb 0f                	jmp    c010b654 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010b645:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b648:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b64c:	89 1c 24             	mov    %ebx,(%esp)
c010b64f:	8b 45 08             	mov    0x8(%ebp),%eax
c010b652:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010b654:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b658:	89 f0                	mov    %esi,%eax
c010b65a:	8d 70 01             	lea    0x1(%eax),%esi
c010b65d:	0f b6 00             	movzbl (%eax),%eax
c010b660:	0f be d8             	movsbl %al,%ebx
c010b663:	85 db                	test   %ebx,%ebx
c010b665:	74 10                	je     c010b677 <vprintfmt+0x24a>
c010b667:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b66b:	78 b3                	js     c010b620 <vprintfmt+0x1f3>
c010b66d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010b671:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010b675:	79 a9                	jns    c010b620 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b677:	eb 17                	jmp    c010b690 <vprintfmt+0x263>
                putch(' ', putdat);
c010b679:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b67c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b680:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010b687:	8b 45 08             	mov    0x8(%ebp),%eax
c010b68a:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010b68c:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010b690:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b694:	7f e3                	jg     c010b679 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010b696:	e9 70 01 00 00       	jmp    c010b80b <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010b69b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b69e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6a2:	8d 45 14             	lea    0x14(%ebp),%eax
c010b6a5:	89 04 24             	mov    %eax,(%esp)
c010b6a8:	e8 0b fd ff ff       	call   c010b3b8 <getint>
c010b6ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b6b0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010b6b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b6b9:	85 d2                	test   %edx,%edx
c010b6bb:	79 26                	jns    c010b6e3 <vprintfmt+0x2b6>
                putch('-', putdat);
c010b6bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010b6cb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6ce:	ff d0                	call   *%eax
                num = -(long long)num;
c010b6d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b6d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b6d6:	f7 d8                	neg    %eax
c010b6d8:	83 d2 00             	adc    $0x0,%edx
c010b6db:	f7 da                	neg    %edx
c010b6dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b6e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010b6e3:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b6ea:	e9 a8 00 00 00       	jmp    c010b797 <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010b6ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b6f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b6f6:	8d 45 14             	lea    0x14(%ebp),%eax
c010b6f9:	89 04 24             	mov    %eax,(%esp)
c010b6fc:	e8 68 fc ff ff       	call   c010b369 <getuint>
c010b701:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b704:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010b707:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010b70e:	e9 84 00 00 00       	jmp    c010b797 <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010b713:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b716:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b71a:	8d 45 14             	lea    0x14(%ebp),%eax
c010b71d:	89 04 24             	mov    %eax,(%esp)
c010b720:	e8 44 fc ff ff       	call   c010b369 <getuint>
c010b725:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b728:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010b72b:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010b732:	eb 63                	jmp    c010b797 <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010b734:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b737:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b73b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010b742:	8b 45 08             	mov    0x8(%ebp),%eax
c010b745:	ff d0                	call   *%eax
            putch('x', putdat);
c010b747:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b74a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b74e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010b755:	8b 45 08             	mov    0x8(%ebp),%eax
c010b758:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010b75a:	8b 45 14             	mov    0x14(%ebp),%eax
c010b75d:	8d 50 04             	lea    0x4(%eax),%edx
c010b760:	89 55 14             	mov    %edx,0x14(%ebp)
c010b763:	8b 00                	mov    (%eax),%eax
c010b765:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010b76f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010b776:	eb 1f                	jmp    c010b797 <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010b778:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b77b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b77f:	8d 45 14             	lea    0x14(%ebp),%eax
c010b782:	89 04 24             	mov    %eax,(%esp)
c010b785:	e8 df fb ff ff       	call   c010b369 <getuint>
c010b78a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b78d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010b790:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010b797:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010b79b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b79e:	89 54 24 18          	mov    %edx,0x18(%esp)
c010b7a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b7a5:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b7a9:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b7ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b7b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b7b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b7b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010b7bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7be:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7c5:	89 04 24             	mov    %eax,(%esp)
c010b7c8:	e8 97 fa ff ff       	call   c010b264 <printnum>
            break;
c010b7cd:	eb 3c                	jmp    c010b80b <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010b7cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7d6:	89 1c 24             	mov    %ebx,(%esp)
c010b7d9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7dc:	ff d0                	call   *%eax
            break;
c010b7de:	eb 2b                	jmp    c010b80b <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010b7e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b7e7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010b7ee:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7f1:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010b7f3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b7f7:	eb 04                	jmp    c010b7fd <vprintfmt+0x3d0>
c010b7f9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b7fd:	8b 45 10             	mov    0x10(%ebp),%eax
c010b800:	83 e8 01             	sub    $0x1,%eax
c010b803:	0f b6 00             	movzbl (%eax),%eax
c010b806:	3c 25                	cmp    $0x25,%al
c010b808:	75 ef                	jne    c010b7f9 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010b80a:	90                   	nop
        }
    }
c010b80b:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010b80c:	e9 3e fc ff ff       	jmp    c010b44f <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010b811:	83 c4 40             	add    $0x40,%esp
c010b814:	5b                   	pop    %ebx
c010b815:	5e                   	pop    %esi
c010b816:	5d                   	pop    %ebp
c010b817:	c3                   	ret    

c010b818 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010b818:	55                   	push   %ebp
c010b819:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010b81b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b81e:	8b 40 08             	mov    0x8(%eax),%eax
c010b821:	8d 50 01             	lea    0x1(%eax),%edx
c010b824:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b827:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010b82a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b82d:	8b 10                	mov    (%eax),%edx
c010b82f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b832:	8b 40 04             	mov    0x4(%eax),%eax
c010b835:	39 c2                	cmp    %eax,%edx
c010b837:	73 12                	jae    c010b84b <sprintputch+0x33>
        *b->buf ++ = ch;
c010b839:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b83c:	8b 00                	mov    (%eax),%eax
c010b83e:	8d 48 01             	lea    0x1(%eax),%ecx
c010b841:	8b 55 0c             	mov    0xc(%ebp),%edx
c010b844:	89 0a                	mov    %ecx,(%edx)
c010b846:	8b 55 08             	mov    0x8(%ebp),%edx
c010b849:	88 10                	mov    %dl,(%eax)
    }
}
c010b84b:	5d                   	pop    %ebp
c010b84c:	c3                   	ret    

c010b84d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010b84d:	55                   	push   %ebp
c010b84e:	89 e5                	mov    %esp,%ebp
c010b850:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010b853:	8d 45 14             	lea    0x14(%ebp),%eax
c010b856:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010b859:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b85c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b860:	8b 45 10             	mov    0x10(%ebp),%eax
c010b863:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b867:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b86a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b86e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b871:	89 04 24             	mov    %eax,(%esp)
c010b874:	e8 08 00 00 00       	call   c010b881 <vsnprintf>
c010b879:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010b87c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010b87f:	c9                   	leave  
c010b880:	c3                   	ret    

c010b881 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010b881:	55                   	push   %ebp
c010b882:	89 e5                	mov    %esp,%ebp
c010b884:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010b887:	8b 45 08             	mov    0x8(%ebp),%eax
c010b88a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b88d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b890:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b893:	8b 45 08             	mov    0x8(%ebp),%eax
c010b896:	01 d0                	add    %edx,%eax
c010b898:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b89b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010b8a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010b8a6:	74 0a                	je     c010b8b2 <vsnprintf+0x31>
c010b8a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b8ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b8ae:	39 c2                	cmp    %eax,%edx
c010b8b0:	76 07                	jbe    c010b8b9 <vsnprintf+0x38>
        return -E_INVAL;
c010b8b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010b8b7:	eb 2a                	jmp    c010b8e3 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010b8b9:	8b 45 14             	mov    0x14(%ebp),%eax
c010b8bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b8c0:	8b 45 10             	mov    0x10(%ebp),%eax
c010b8c3:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b8c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010b8ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b8ce:	c7 04 24 18 b8 10 c0 	movl   $0xc010b818,(%esp)
c010b8d5:	e8 53 fb ff ff       	call   c010b42d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010b8da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b8dd:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010b8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010b8e3:	c9                   	leave  
c010b8e4:	c3                   	ret    

c010b8e5 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010b8e5:	55                   	push   %ebp
c010b8e6:	89 e5                	mov    %esp,%ebp
c010b8e8:	57                   	push   %edi
c010b8e9:	56                   	push   %esi
c010b8ea:	53                   	push   %ebx
c010b8eb:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010b8ee:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010b8f3:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010b8f9:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010b8ff:	6b f0 05             	imul   $0x5,%eax,%esi
c010b902:	01 f7                	add    %esi,%edi
c010b904:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010b909:	f7 e6                	mul    %esi
c010b90b:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010b90e:	89 f2                	mov    %esi,%edx
c010b910:	83 c0 0b             	add    $0xb,%eax
c010b913:	83 d2 00             	adc    $0x0,%edx
c010b916:	89 c7                	mov    %eax,%edi
c010b918:	83 e7 ff             	and    $0xffffffff,%edi
c010b91b:	89 f9                	mov    %edi,%ecx
c010b91d:	0f b7 da             	movzwl %dx,%ebx
c010b920:	89 0d 20 ab 12 c0    	mov    %ecx,0xc012ab20
c010b926:	89 1d 24 ab 12 c0    	mov    %ebx,0xc012ab24
    unsigned long long result = (next >> 12);
c010b92c:	a1 20 ab 12 c0       	mov    0xc012ab20,%eax
c010b931:	8b 15 24 ab 12 c0    	mov    0xc012ab24,%edx
c010b937:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010b93b:	c1 ea 0c             	shr    $0xc,%edx
c010b93e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b941:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010b944:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010b94b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b94e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b951:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b954:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b957:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b95a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b95d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010b961:	74 1c                	je     c010b97f <rand+0x9a>
c010b963:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b966:	ba 00 00 00 00       	mov    $0x0,%edx
c010b96b:	f7 75 dc             	divl   -0x24(%ebp)
c010b96e:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010b971:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b974:	ba 00 00 00 00       	mov    $0x0,%edx
c010b979:	f7 75 dc             	divl   -0x24(%ebp)
c010b97c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010b97f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b982:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b985:	f7 75 dc             	divl   -0x24(%ebp)
c010b988:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010b98b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b98e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010b991:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b994:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b997:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b99a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010b99d:	83 c4 24             	add    $0x24,%esp
c010b9a0:	5b                   	pop    %ebx
c010b9a1:	5e                   	pop    %esi
c010b9a2:	5f                   	pop    %edi
c010b9a3:	5d                   	pop    %ebp
c010b9a4:	c3                   	ret    

c010b9a5 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010b9a5:	55                   	push   %ebp
c010b9a6:	89 e5                	mov    %esp,%ebp
    next = seed;
c010b9a8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9ab:	ba 00 00 00 00       	mov    $0x0,%edx
c010b9b0:	a3 20 ab 12 c0       	mov    %eax,0xc012ab20
c010b9b5:	89 15 24 ab 12 c0    	mov    %edx,0xc012ab24
}
c010b9bb:	5d                   	pop    %ebp
c010b9bc:	c3                   	ret    

c010b9bd <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b9bd:	55                   	push   %ebp
c010b9be:	89 e5                	mov    %esp,%ebp
c010b9c0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b9c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b9ca:	eb 04                	jmp    c010b9d0 <strlen+0x13>
        cnt ++;
c010b9cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010b9d0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9d3:	8d 50 01             	lea    0x1(%eax),%edx
c010b9d6:	89 55 08             	mov    %edx,0x8(%ebp)
c010b9d9:	0f b6 00             	movzbl (%eax),%eax
c010b9dc:	84 c0                	test   %al,%al
c010b9de:	75 ec                	jne    c010b9cc <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010b9e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b9e3:	c9                   	leave  
c010b9e4:	c3                   	ret    

c010b9e5 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b9e5:	55                   	push   %ebp
c010b9e6:	89 e5                	mov    %esp,%ebp
c010b9e8:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b9eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b9f2:	eb 04                	jmp    c010b9f8 <strnlen+0x13>
        cnt ++;
c010b9f4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010b9f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b9fb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b9fe:	73 10                	jae    c010ba10 <strnlen+0x2b>
c010ba00:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba03:	8d 50 01             	lea    0x1(%eax),%edx
c010ba06:	89 55 08             	mov    %edx,0x8(%ebp)
c010ba09:	0f b6 00             	movzbl (%eax),%eax
c010ba0c:	84 c0                	test   %al,%al
c010ba0e:	75 e4                	jne    c010b9f4 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010ba10:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010ba13:	c9                   	leave  
c010ba14:	c3                   	ret    

c010ba15 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010ba15:	55                   	push   %ebp
c010ba16:	89 e5                	mov    %esp,%ebp
c010ba18:	57                   	push   %edi
c010ba19:	56                   	push   %esi
c010ba1a:	83 ec 20             	sub    $0x20,%esp
c010ba1d:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ba23:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba26:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010ba29:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010ba2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ba2f:	89 d1                	mov    %edx,%ecx
c010ba31:	89 c2                	mov    %eax,%edx
c010ba33:	89 ce                	mov    %ecx,%esi
c010ba35:	89 d7                	mov    %edx,%edi
c010ba37:	ac                   	lods   %ds:(%esi),%al
c010ba38:	aa                   	stos   %al,%es:(%edi)
c010ba39:	84 c0                	test   %al,%al
c010ba3b:	75 fa                	jne    c010ba37 <strcpy+0x22>
c010ba3d:	89 fa                	mov    %edi,%edx
c010ba3f:	89 f1                	mov    %esi,%ecx
c010ba41:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010ba44:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ba47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010ba4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010ba4d:	83 c4 20             	add    $0x20,%esp
c010ba50:	5e                   	pop    %esi
c010ba51:	5f                   	pop    %edi
c010ba52:	5d                   	pop    %ebp
c010ba53:	c3                   	ret    

c010ba54 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010ba54:	55                   	push   %ebp
c010ba55:	89 e5                	mov    %esp,%ebp
c010ba57:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010ba5a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010ba60:	eb 21                	jmp    c010ba83 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010ba62:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba65:	0f b6 10             	movzbl (%eax),%edx
c010ba68:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ba6b:	88 10                	mov    %dl,(%eax)
c010ba6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010ba70:	0f b6 00             	movzbl (%eax),%eax
c010ba73:	84 c0                	test   %al,%al
c010ba75:	74 04                	je     c010ba7b <strncpy+0x27>
            src ++;
c010ba77:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010ba7b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010ba7f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010ba83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010ba87:	75 d9                	jne    c010ba62 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010ba89:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010ba8c:	c9                   	leave  
c010ba8d:	c3                   	ret    

c010ba8e <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010ba8e:	55                   	push   %ebp
c010ba8f:	89 e5                	mov    %esp,%ebp
c010ba91:	57                   	push   %edi
c010ba92:	56                   	push   %esi
c010ba93:	83 ec 20             	sub    $0x20,%esp
c010ba96:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba99:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ba9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010baa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010baa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010baa8:	89 d1                	mov    %edx,%ecx
c010baaa:	89 c2                	mov    %eax,%edx
c010baac:	89 ce                	mov    %ecx,%esi
c010baae:	89 d7                	mov    %edx,%edi
c010bab0:	ac                   	lods   %ds:(%esi),%al
c010bab1:	ae                   	scas   %es:(%edi),%al
c010bab2:	75 08                	jne    c010babc <strcmp+0x2e>
c010bab4:	84 c0                	test   %al,%al
c010bab6:	75 f8                	jne    c010bab0 <strcmp+0x22>
c010bab8:	31 c0                	xor    %eax,%eax
c010baba:	eb 04                	jmp    c010bac0 <strcmp+0x32>
c010babc:	19 c0                	sbb    %eax,%eax
c010babe:	0c 01                	or     $0x1,%al
c010bac0:	89 fa                	mov    %edi,%edx
c010bac2:	89 f1                	mov    %esi,%ecx
c010bac4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bac7:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010baca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010bacd:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010bad0:	83 c4 20             	add    $0x20,%esp
c010bad3:	5e                   	pop    %esi
c010bad4:	5f                   	pop    %edi
c010bad5:	5d                   	pop    %ebp
c010bad6:	c3                   	ret    

c010bad7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010bad7:	55                   	push   %ebp
c010bad8:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bada:	eb 0c                	jmp    c010bae8 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010badc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010bae0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bae4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010bae8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010baec:	74 1a                	je     c010bb08 <strncmp+0x31>
c010baee:	8b 45 08             	mov    0x8(%ebp),%eax
c010baf1:	0f b6 00             	movzbl (%eax),%eax
c010baf4:	84 c0                	test   %al,%al
c010baf6:	74 10                	je     c010bb08 <strncmp+0x31>
c010baf8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bafb:	0f b6 10             	movzbl (%eax),%edx
c010bafe:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb01:	0f b6 00             	movzbl (%eax),%eax
c010bb04:	38 c2                	cmp    %al,%dl
c010bb06:	74 d4                	je     c010badc <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010bb08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bb0c:	74 18                	je     c010bb26 <strncmp+0x4f>
c010bb0e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb11:	0f b6 00             	movzbl (%eax),%eax
c010bb14:	0f b6 d0             	movzbl %al,%edx
c010bb17:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb1a:	0f b6 00             	movzbl (%eax),%eax
c010bb1d:	0f b6 c0             	movzbl %al,%eax
c010bb20:	29 c2                	sub    %eax,%edx
c010bb22:	89 d0                	mov    %edx,%eax
c010bb24:	eb 05                	jmp    c010bb2b <strncmp+0x54>
c010bb26:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb2b:	5d                   	pop    %ebp
c010bb2c:	c3                   	ret    

c010bb2d <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010bb2d:	55                   	push   %ebp
c010bb2e:	89 e5                	mov    %esp,%ebp
c010bb30:	83 ec 04             	sub    $0x4,%esp
c010bb33:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb36:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bb39:	eb 14                	jmp    c010bb4f <strchr+0x22>
        if (*s == c) {
c010bb3b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb3e:	0f b6 00             	movzbl (%eax),%eax
c010bb41:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bb44:	75 05                	jne    c010bb4b <strchr+0x1e>
            return (char *)s;
c010bb46:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb49:	eb 13                	jmp    c010bb5e <strchr+0x31>
        }
        s ++;
c010bb4b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010bb4f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb52:	0f b6 00             	movzbl (%eax),%eax
c010bb55:	84 c0                	test   %al,%al
c010bb57:	75 e2                	jne    c010bb3b <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010bb59:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb5e:	c9                   	leave  
c010bb5f:	c3                   	ret    

c010bb60 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010bb60:	55                   	push   %ebp
c010bb61:	89 e5                	mov    %esp,%ebp
c010bb63:	83 ec 04             	sub    $0x4,%esp
c010bb66:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bb69:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010bb6c:	eb 11                	jmp    c010bb7f <strfind+0x1f>
        if (*s == c) {
c010bb6e:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb71:	0f b6 00             	movzbl (%eax),%eax
c010bb74:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010bb77:	75 02                	jne    c010bb7b <strfind+0x1b>
            break;
c010bb79:	eb 0e                	jmp    c010bb89 <strfind+0x29>
        }
        s ++;
c010bb7b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010bb7f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bb82:	0f b6 00             	movzbl (%eax),%eax
c010bb85:	84 c0                	test   %al,%al
c010bb87:	75 e5                	jne    c010bb6e <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010bb89:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010bb8c:	c9                   	leave  
c010bb8d:	c3                   	ret    

c010bb8e <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010bb8e:	55                   	push   %ebp
c010bb8f:	89 e5                	mov    %esp,%ebp
c010bb91:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010bb94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010bb9b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bba2:	eb 04                	jmp    c010bba8 <strtol+0x1a>
        s ++;
c010bba4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010bba8:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbab:	0f b6 00             	movzbl (%eax),%eax
c010bbae:	3c 20                	cmp    $0x20,%al
c010bbb0:	74 f2                	je     c010bba4 <strtol+0x16>
c010bbb2:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbb5:	0f b6 00             	movzbl (%eax),%eax
c010bbb8:	3c 09                	cmp    $0x9,%al
c010bbba:	74 e8                	je     c010bba4 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010bbbc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbbf:	0f b6 00             	movzbl (%eax),%eax
c010bbc2:	3c 2b                	cmp    $0x2b,%al
c010bbc4:	75 06                	jne    c010bbcc <strtol+0x3e>
        s ++;
c010bbc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bbca:	eb 15                	jmp    c010bbe1 <strtol+0x53>
    }
    else if (*s == '-') {
c010bbcc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbcf:	0f b6 00             	movzbl (%eax),%eax
c010bbd2:	3c 2d                	cmp    $0x2d,%al
c010bbd4:	75 0b                	jne    c010bbe1 <strtol+0x53>
        s ++, neg = 1;
c010bbd6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bbda:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010bbe1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bbe5:	74 06                	je     c010bbed <strtol+0x5f>
c010bbe7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010bbeb:	75 24                	jne    c010bc11 <strtol+0x83>
c010bbed:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbf0:	0f b6 00             	movzbl (%eax),%eax
c010bbf3:	3c 30                	cmp    $0x30,%al
c010bbf5:	75 1a                	jne    c010bc11 <strtol+0x83>
c010bbf7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbfa:	83 c0 01             	add    $0x1,%eax
c010bbfd:	0f b6 00             	movzbl (%eax),%eax
c010bc00:	3c 78                	cmp    $0x78,%al
c010bc02:	75 0d                	jne    c010bc11 <strtol+0x83>
        s += 2, base = 16;
c010bc04:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010bc08:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010bc0f:	eb 2a                	jmp    c010bc3b <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010bc11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc15:	75 17                	jne    c010bc2e <strtol+0xa0>
c010bc17:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc1a:	0f b6 00             	movzbl (%eax),%eax
c010bc1d:	3c 30                	cmp    $0x30,%al
c010bc1f:	75 0d                	jne    c010bc2e <strtol+0xa0>
        s ++, base = 8;
c010bc21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bc25:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010bc2c:	eb 0d                	jmp    c010bc3b <strtol+0xad>
    }
    else if (base == 0) {
c010bc2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010bc32:	75 07                	jne    c010bc3b <strtol+0xad>
        base = 10;
c010bc34:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010bc3b:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc3e:	0f b6 00             	movzbl (%eax),%eax
c010bc41:	3c 2f                	cmp    $0x2f,%al
c010bc43:	7e 1b                	jle    c010bc60 <strtol+0xd2>
c010bc45:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc48:	0f b6 00             	movzbl (%eax),%eax
c010bc4b:	3c 39                	cmp    $0x39,%al
c010bc4d:	7f 11                	jg     c010bc60 <strtol+0xd2>
            dig = *s - '0';
c010bc4f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc52:	0f b6 00             	movzbl (%eax),%eax
c010bc55:	0f be c0             	movsbl %al,%eax
c010bc58:	83 e8 30             	sub    $0x30,%eax
c010bc5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bc5e:	eb 48                	jmp    c010bca8 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010bc60:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc63:	0f b6 00             	movzbl (%eax),%eax
c010bc66:	3c 60                	cmp    $0x60,%al
c010bc68:	7e 1b                	jle    c010bc85 <strtol+0xf7>
c010bc6a:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc6d:	0f b6 00             	movzbl (%eax),%eax
c010bc70:	3c 7a                	cmp    $0x7a,%al
c010bc72:	7f 11                	jg     c010bc85 <strtol+0xf7>
            dig = *s - 'a' + 10;
c010bc74:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc77:	0f b6 00             	movzbl (%eax),%eax
c010bc7a:	0f be c0             	movsbl %al,%eax
c010bc7d:	83 e8 57             	sub    $0x57,%eax
c010bc80:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bc83:	eb 23                	jmp    c010bca8 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010bc85:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc88:	0f b6 00             	movzbl (%eax),%eax
c010bc8b:	3c 40                	cmp    $0x40,%al
c010bc8d:	7e 3d                	jle    c010bccc <strtol+0x13e>
c010bc8f:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc92:	0f b6 00             	movzbl (%eax),%eax
c010bc95:	3c 5a                	cmp    $0x5a,%al
c010bc97:	7f 33                	jg     c010bccc <strtol+0x13e>
            dig = *s - 'A' + 10;
c010bc99:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc9c:	0f b6 00             	movzbl (%eax),%eax
c010bc9f:	0f be c0             	movsbl %al,%eax
c010bca2:	83 e8 37             	sub    $0x37,%eax
c010bca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010bca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcab:	3b 45 10             	cmp    0x10(%ebp),%eax
c010bcae:	7c 02                	jl     c010bcb2 <strtol+0x124>
            break;
c010bcb0:	eb 1a                	jmp    c010bccc <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010bcb2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010bcb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bcb9:	0f af 45 10          	imul   0x10(%ebp),%eax
c010bcbd:	89 c2                	mov    %eax,%edx
c010bcbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcc2:	01 d0                	add    %edx,%eax
c010bcc4:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010bcc7:	e9 6f ff ff ff       	jmp    c010bc3b <strtol+0xad>

    if (endptr) {
c010bccc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bcd0:	74 08                	je     c010bcda <strtol+0x14c>
        *endptr = (char *) s;
c010bcd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcd5:	8b 55 08             	mov    0x8(%ebp),%edx
c010bcd8:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010bcda:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010bcde:	74 07                	je     c010bce7 <strtol+0x159>
c010bce0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bce3:	f7 d8                	neg    %eax
c010bce5:	eb 03                	jmp    c010bcea <strtol+0x15c>
c010bce7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010bcea:	c9                   	leave  
c010bceb:	c3                   	ret    

c010bcec <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010bcec:	55                   	push   %ebp
c010bced:	89 e5                	mov    %esp,%ebp
c010bcef:	57                   	push   %edi
c010bcf0:	83 ec 24             	sub    $0x24,%esp
c010bcf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcf6:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010bcf9:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010bcfd:	8b 55 08             	mov    0x8(%ebp),%edx
c010bd00:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010bd03:	88 45 f7             	mov    %al,-0x9(%ebp)
c010bd06:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd09:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010bd0c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010bd0f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010bd13:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010bd16:	89 d7                	mov    %edx,%edi
c010bd18:	f3 aa                	rep stos %al,%es:(%edi)
c010bd1a:	89 fa                	mov    %edi,%edx
c010bd1c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010bd1f:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010bd22:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010bd25:	83 c4 24             	add    $0x24,%esp
c010bd28:	5f                   	pop    %edi
c010bd29:	5d                   	pop    %ebp
c010bd2a:	c3                   	ret    

c010bd2b <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010bd2b:	55                   	push   %ebp
c010bd2c:	89 e5                	mov    %esp,%ebp
c010bd2e:	57                   	push   %edi
c010bd2f:	56                   	push   %esi
c010bd30:	53                   	push   %ebx
c010bd31:	83 ec 30             	sub    $0x30,%esp
c010bd34:	8b 45 08             	mov    0x8(%ebp),%eax
c010bd37:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bd3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bd3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010bd40:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd43:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010bd46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd49:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010bd4c:	73 42                	jae    c010bd90 <memmove+0x65>
c010bd4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bd51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bd54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bd57:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bd5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bd5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bd60:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bd63:	c1 e8 02             	shr    $0x2,%eax
c010bd66:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010bd68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bd6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bd6e:	89 d7                	mov    %edx,%edi
c010bd70:	89 c6                	mov    %eax,%esi
c010bd72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bd74:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010bd77:	83 e1 03             	and    $0x3,%ecx
c010bd7a:	74 02                	je     c010bd7e <memmove+0x53>
c010bd7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bd7e:	89 f0                	mov    %esi,%eax
c010bd80:	89 fa                	mov    %edi,%edx
c010bd82:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010bd85:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010bd88:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010bd8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bd8e:	eb 36                	jmp    c010bdc6 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010bd90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bd93:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bd96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bd99:	01 c2                	add    %eax,%edx
c010bd9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bd9e:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010bda1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bda4:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010bda7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bdaa:	89 c1                	mov    %eax,%ecx
c010bdac:	89 d8                	mov    %ebx,%eax
c010bdae:	89 d6                	mov    %edx,%esi
c010bdb0:	89 c7                	mov    %eax,%edi
c010bdb2:	fd                   	std    
c010bdb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010bdb5:	fc                   	cld    
c010bdb6:	89 f8                	mov    %edi,%eax
c010bdb8:	89 f2                	mov    %esi,%edx
c010bdba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010bdbd:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010bdc0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010bdc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010bdc6:	83 c4 30             	add    $0x30,%esp
c010bdc9:	5b                   	pop    %ebx
c010bdca:	5e                   	pop    %esi
c010bdcb:	5f                   	pop    %edi
c010bdcc:	5d                   	pop    %ebp
c010bdcd:	c3                   	ret    

c010bdce <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010bdce:	55                   	push   %ebp
c010bdcf:	89 e5                	mov    %esp,%ebp
c010bdd1:	57                   	push   %edi
c010bdd2:	56                   	push   %esi
c010bdd3:	83 ec 20             	sub    $0x20,%esp
c010bdd6:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bddc:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bde2:	8b 45 10             	mov    0x10(%ebp),%eax
c010bde5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010bde8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010bdeb:	c1 e8 02             	shr    $0x2,%eax
c010bdee:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010bdf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bdf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bdf6:	89 d7                	mov    %edx,%edi
c010bdf8:	89 c6                	mov    %eax,%esi
c010bdfa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010bdfc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010bdff:	83 e1 03             	and    $0x3,%ecx
c010be02:	74 02                	je     c010be06 <memcpy+0x38>
c010be04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010be06:	89 f0                	mov    %esi,%eax
c010be08:	89 fa                	mov    %edi,%edx
c010be0a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010be0d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010be10:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010be13:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010be16:	83 c4 20             	add    $0x20,%esp
c010be19:	5e                   	pop    %esi
c010be1a:	5f                   	pop    %edi
c010be1b:	5d                   	pop    %ebp
c010be1c:	c3                   	ret    

c010be1d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010be1d:	55                   	push   %ebp
c010be1e:	89 e5                	mov    %esp,%ebp
c010be20:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010be23:	8b 45 08             	mov    0x8(%ebp),%eax
c010be26:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010be29:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be2c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010be2f:	eb 30                	jmp    c010be61 <memcmp+0x44>
        if (*s1 != *s2) {
c010be31:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010be34:	0f b6 10             	movzbl (%eax),%edx
c010be37:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be3a:	0f b6 00             	movzbl (%eax),%eax
c010be3d:	38 c2                	cmp    %al,%dl
c010be3f:	74 18                	je     c010be59 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010be41:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010be44:	0f b6 00             	movzbl (%eax),%eax
c010be47:	0f b6 d0             	movzbl %al,%edx
c010be4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010be4d:	0f b6 00             	movzbl (%eax),%eax
c010be50:	0f b6 c0             	movzbl %al,%eax
c010be53:	29 c2                	sub    %eax,%edx
c010be55:	89 d0                	mov    %edx,%eax
c010be57:	eb 1a                	jmp    c010be73 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010be59:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010be5d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010be61:	8b 45 10             	mov    0x10(%ebp),%eax
c010be64:	8d 50 ff             	lea    -0x1(%eax),%edx
c010be67:	89 55 10             	mov    %edx,0x10(%ebp)
c010be6a:	85 c0                	test   %eax,%eax
c010be6c:	75 c3                	jne    c010be31 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010be6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010be73:	c9                   	leave  
c010be74:	c3                   	ret    
