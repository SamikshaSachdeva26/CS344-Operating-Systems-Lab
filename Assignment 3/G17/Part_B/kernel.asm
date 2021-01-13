
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 c5 10 80       	mov    $0x8010c5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 80 33 10 80       	mov    $0x80103380,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
80100044:	56                   	push   %esi
80100045:	53                   	push   %ebx
80100046:	89 c6                	mov    %eax,%esi
80100048:	89 d7                	mov    %edx,%edi
8010004a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
8010004d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100052:	e8 19 49 00 00       	call   80104970 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100057:	8b 1d 10 0d 11 80    	mov    0x80110d10,%ebx
8010005d:	83 c4 10             	add    $0x10,%esp
80100060:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100066:	75 13                	jne    8010007b <bget+0x3b>
80100068:	eb 26                	jmp    80100090 <bget+0x50>
8010006a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100070:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100073:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100079:	74 15                	je     80100090 <bget+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010007b:	39 73 04             	cmp    %esi,0x4(%ebx)
8010007e:	75 f0                	jne    80100070 <bget+0x30>
80100080:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100083:	75 eb                	jne    80100070 <bget+0x30>
      b->refcnt++;
80100085:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
80100089:	eb 3f                	jmp    801000ca <bget+0x8a>
8010008b:	90                   	nop
8010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100090:	8b 1d 0c 0d 11 80    	mov    0x80110d0c,%ebx
80100096:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
8010009c:	75 0d                	jne    801000ab <bget+0x6b>
8010009e:	eb 4f                	jmp    801000ef <bget+0xaf>
801000a0:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000a3:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
801000a9:	74 44                	je     801000ef <bget+0xaf>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
801000ae:	85 c0                	test   %eax,%eax
801000b0:	75 ee                	jne    801000a0 <bget+0x60>
801000b2:	f6 03 04             	testb  $0x4,(%ebx)
801000b5:	75 e9                	jne    801000a0 <bget+0x60>
      b->dev = dev;
801000b7:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000ba:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000c3:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000ca:	83 ec 0c             	sub    $0xc,%esp
801000cd:	68 c0 c5 10 80       	push   $0x8010c5c0
801000d2:	e8 b9 49 00 00       	call   80104a90 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 ce 46 00 00       	call   801047b0 <acquiresleep>
      return b;
801000e2:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e8:	89 d8                	mov    %ebx,%eax
801000ea:	5b                   	pop    %ebx
801000eb:	5e                   	pop    %esi
801000ec:	5f                   	pop    %edi
801000ed:	5d                   	pop    %ebp
801000ee:	c3                   	ret    
  panic("bget: no buffers");
801000ef:	83 ec 0c             	sub    $0xc,%esp
801000f2:	68 a0 7b 10 80       	push   $0x80107ba0
801000f7:	e8 04 06 00 00       	call   80100700 <panic>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100100 <binit>:
{
80100100:	55                   	push   %ebp
80100101:	89 e5                	mov    %esp,%ebp
80100103:	53                   	push   %ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100104:	bb f4 c5 10 80       	mov    $0x8010c5f4,%ebx
{
80100109:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010010c:	68 b1 7b 10 80       	push   $0x80107bb1
80100111:	68 c0 c5 10 80       	push   $0x8010c5c0
80100116:	e8 65 47 00 00       	call   80104880 <initlock>
  bcache.head.prev = &bcache.head;
8010011b:	c7 05 0c 0d 11 80 bc 	movl   $0x80110cbc,0x80110d0c
80100122:	0c 11 80 
  bcache.head.next = &bcache.head;
80100125:	c7 05 10 0d 11 80 bc 	movl   $0x80110cbc,0x80110d10
8010012c:	0c 11 80 
8010012f:	83 c4 10             	add    $0x10,%esp
80100132:	ba bc 0c 11 80       	mov    $0x80110cbc,%edx
80100137:	eb 09                	jmp    80100142 <binit+0x42>
80100139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100140:	89 c3                	mov    %eax,%ebx
    initsleeplock(&b->lock, "buffer");
80100142:	8d 43 0c             	lea    0xc(%ebx),%eax
80100145:	83 ec 08             	sub    $0x8,%esp
    b->next = bcache.head.next;
80100148:	89 53 54             	mov    %edx,0x54(%ebx)
    b->prev = &bcache.head;
8010014b:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100152:	68 b8 7b 10 80       	push   $0x80107bb8
80100157:	50                   	push   %eax
80100158:	e8 13 46 00 00       	call   80104770 <initsleeplock>
    bcache.head.next->prev = b;
8010015d:	a1 10 0d 11 80       	mov    0x80110d10,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100162:	83 c4 10             	add    $0x10,%esp
80100165:	89 da                	mov    %ebx,%edx
    bcache.head.next->prev = b;
80100167:	89 58 50             	mov    %ebx,0x50(%eax)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010016a:	8d 83 5c 02 00 00    	lea    0x25c(%ebx),%eax
    bcache.head.next = b;
80100170:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100176:	3d bc 0c 11 80       	cmp    $0x80110cbc,%eax
8010017b:	72 c3                	jb     80100140 <binit+0x40>
}
8010017d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100180:	c9                   	leave  
80100181:	c3                   	ret    
80100182:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100189:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100190 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80100190:	55                   	push   %ebp
80100191:	89 e5                	mov    %esp,%ebp
80100193:	57                   	push   %edi
80100194:	56                   	push   %esi
80100195:	53                   	push   %ebx
  
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if(!(dp = nameiparent(path, name)))
80100196:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80100199:	83 ec 44             	sub    $0x44,%esp
8010019c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010019f:	8b 55 10             	mov    0x10(%ebp),%edx
801001a2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  if(!(dp = nameiparent(path, name)))
801001a5:	56                   	push   %esi
801001a6:	ff 75 08             	pushl  0x8(%ebp)
{
801001a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
801001ac:	89 55 c0             	mov    %edx,-0x40(%ebp)
801001af:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if(!(dp = nameiparent(path, name)))
801001b2:	e8 a9 21 00 00       	call   80102360 <nameiparent>
801001b7:	83 c4 10             	add    $0x10,%esp
801001ba:	85 c0                	test   %eax,%eax
801001bc:	0f 84 4e 01 00 00    	je     80100310 <create+0x180>
  {
    return 0;
  }
  ilock(dp);
801001c2:	83 ec 0c             	sub    $0xc,%esp
801001c5:	89 c3                	mov    %eax,%ebx
801001c7:	50                   	push   %eax
801001c8:	e8 13 19 00 00       	call   80101ae0 <ilock>

  uint off;
  if((ip = dirlookup(dp, name, &off)))
801001cd:	8d 45 d4             	lea    -0x2c(%ebp),%eax
801001d0:	83 c4 0c             	add    $0xc,%esp
801001d3:	50                   	push   %eax
801001d4:	56                   	push   %esi
801001d5:	53                   	push   %ebx
801001d6:	e8 35 1e 00 00       	call   80102010 <dirlookup>
801001db:	83 c4 10             	add    $0x10,%esp
801001de:	85 c0                	test   %eax,%eax
801001e0:	89 c7                	mov    %eax,%edi
801001e2:	74 3c                	je     80100220 <create+0x90>
  {
    iunlockput(dp);
801001e4:	83 ec 0c             	sub    $0xc,%esp
801001e7:	53                   	push   %ebx
801001e8:	e8 83 1b 00 00       	call   80101d70 <iunlockput>
    ilock(ip);
801001ed:	89 3c 24             	mov    %edi,(%esp)
801001f0:	e8 eb 18 00 00       	call   80101ae0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801001f5:	83 c4 10             	add    $0x10,%esp
801001f8:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801001fd:	0f 85 9d 00 00 00    	jne    801002a0 <create+0x110>
80100203:	66 83 7f 50 02       	cmpw   $0x2,0x50(%edi)
80100208:	0f 85 92 00 00 00    	jne    801002a0 <create+0x110>
    panic("create: dirlink");
  }

  iunlockput(dp);
  return ip;
}
8010020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100211:	89 f8                	mov    %edi,%eax
80100213:	5b                   	pop    %ebx
80100214:	5e                   	pop    %esi
80100215:	5f                   	pop    %edi
80100216:	5d                   	pop    %ebp
80100217:	c3                   	ret    
80100218:	90                   	nop
80100219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!(ip = ialloc(dp->dev, type)))
80100220:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80100224:	83 ec 08             	sub    $0x8,%esp
80100227:	50                   	push   %eax
80100228:	ff 33                	pushl  (%ebx)
8010022a:	e8 41 17 00 00       	call   80101970 <ialloc>
8010022f:	83 c4 10             	add    $0x10,%esp
80100232:	85 c0                	test   %eax,%eax
80100234:	89 c7                	mov    %eax,%edi
80100236:	0f 84 e8 00 00 00    	je     80100324 <create+0x194>
  ilock(ip);
8010023c:	83 ec 0c             	sub    $0xc,%esp
8010023f:	50                   	push   %eax
80100240:	e8 9b 18 00 00       	call   80101ae0 <ilock>
  ip->nlink = 1;
80100245:	b8 01 00 00 00       	mov    $0x1,%eax
8010024a:	66 89 47 56          	mov    %ax,0x56(%edi)
  ip->major = major;
8010024e:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80100252:	66 89 47 52          	mov    %ax,0x52(%edi)
  ip->minor = minor;
80100256:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
8010025a:	66 89 47 54          	mov    %ax,0x54(%edi)
  iupdate(ip);
8010025e:	89 3c 24             	mov    %edi,(%esp)
80100261:	e8 ca 17 00 00       	call   80101a30 <iupdate>
  if(type == T_DIR)
80100266:	83 c4 10             	add    $0x10,%esp
80100269:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010026e:	74 50                	je     801002c0 <create+0x130>
  if(dirlink(dp, name, ip->inum) < 0)
80100270:	83 ec 04             	sub    $0x4,%esp
80100273:	ff 77 04             	pushl  0x4(%edi)
80100276:	56                   	push   %esi
80100277:	53                   	push   %ebx
80100278:	e8 03 20 00 00       	call   80102280 <dirlink>
8010027d:	83 c4 10             	add    $0x10,%esp
80100280:	85 c0                	test   %eax,%eax
80100282:	0f 88 8f 00 00 00    	js     80100317 <create+0x187>
  iunlockput(dp);
80100288:	83 ec 0c             	sub    $0xc,%esp
8010028b:	53                   	push   %ebx
8010028c:	e8 df 1a 00 00       	call   80101d70 <iunlockput>
  return ip;
80100291:	83 c4 10             	add    $0x10,%esp
}
80100294:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100297:	89 f8                	mov    %edi,%eax
80100299:	5b                   	pop    %ebx
8010029a:	5e                   	pop    %esi
8010029b:	5f                   	pop    %edi
8010029c:	5d                   	pop    %ebp
8010029d:	c3                   	ret    
8010029e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	57                   	push   %edi
    return 0;
801002a4:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
801002a6:	e8 c5 1a 00 00       	call   80101d70 <iunlockput>
    return 0;
801002ab:	83 c4 10             	add    $0x10,%esp
}
801002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002b1:	89 f8                	mov    %edi,%eax
801002b3:	5b                   	pop    %ebx
801002b4:	5e                   	pop    %esi
801002b5:	5f                   	pop    %edi
801002b6:	5d                   	pop    %ebp
801002b7:	c3                   	ret    
801002b8:	90                   	nop
801002b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  
801002c0:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
801002c5:	83 ec 0c             	sub    $0xc,%esp
801002c8:	53                   	push   %ebx
801002c9:	e8 62 17 00 00       	call   80101a30 <iupdate>
    if(dirlink(ip, "..", dp->inum) < 0 || dirlink(ip, ".", ip->inum) < 0)
801002ce:	83 c4 0c             	add    $0xc,%esp
801002d1:	ff 73 04             	pushl  0x4(%ebx)
801002d4:	68 ce 7b 10 80       	push   $0x80107bce
801002d9:	57                   	push   %edi
801002da:	e8 a1 1f 00 00       	call   80102280 <dirlink>
801002df:	83 c4 10             	add    $0x10,%esp
801002e2:	85 c0                	test   %eax,%eax
801002e4:	78 1c                	js     80100302 <create+0x172>
801002e6:	83 ec 04             	sub    $0x4,%esp
801002e9:	ff 77 04             	pushl  0x4(%edi)
801002ec:	68 cf 7b 10 80       	push   $0x80107bcf
801002f1:	57                   	push   %edi
801002f2:	e8 89 1f 00 00       	call   80102280 <dirlink>
801002f7:	83 c4 10             	add    $0x10,%esp
801002fa:	85 c0                	test   %eax,%eax
801002fc:	0f 89 6e ff ff ff    	jns    80100270 <create+0xe0>
      panic("create: dots");
80100302:	83 ec 0c             	sub    $0xc,%esp
80100305:	68 d1 7b 10 80       	push   $0x80107bd1
8010030a:	e8 f1 03 00 00       	call   80100700 <panic>
8010030f:	90                   	nop
    return 0;
80100310:	31 ff                	xor    %edi,%edi
80100312:	e9 f7 fe ff ff       	jmp    8010020e <create+0x7e>
    panic("create: dirlink");
80100317:	83 ec 0c             	sub    $0xc,%esp
8010031a:	68 de 7b 10 80       	push   $0x80107bde
8010031f:	e8 dc 03 00 00       	call   80100700 <panic>
    panic("create: ialloc");
80100324:	83 ec 0c             	sub    $0xc,%esp
80100327:	68 bf 7b 10 80       	push   $0x80107bbf
8010032c:	e8 cf 03 00 00       	call   80100700 <panic>
80100331:	eb 0d                	jmp    80100340 <createSwapFile>
80100333:	90                   	nop
80100334:	90                   	nop
80100335:	90                   	nop
80100336:	90                   	nop
80100337:	90                   	nop
80100338:	90                   	nop
80100339:	90                   	nop
8010033a:	90                   	nop
8010033b:	90                   	nop
8010033c:	90                   	nop
8010033d:	90                   	nop
8010033e:	90                   	nop
8010033f:	90                   	nop

80100340 <createSwapFile>:

struct file*
createSwapFile(char*pg, int pid, pte_t *pte)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	56                   	push   %esi
80100344:	53                   	push   %ebx
	char path[100];

  uint x=((*pte)&(0xfffff000));

  x=(x>>12);
  itoa(pid,path);
80100345:	8d 5d 94             	lea    -0x6c(%ebp),%ebx
{
80100348:	83 ec 78             	sub    $0x78,%esp
8010034b:	8b 45 10             	mov    0x10(%ebp),%eax
8010034e:	8b 30                	mov    (%eax),%esi
  itoa(pid,path);
80100350:	53                   	push   %ebx
80100351:	ff 75 0c             	pushl  0xc(%ebp)
80100354:	e8 27 20 00 00       	call   80102380 <itoa>
  int len = strlen(path);
80100359:	89 1c 24             	mov    %ebx,(%esp)
8010035c:	c1 ee 0c             	shr    $0xc,%esi
8010035f:	e8 ac 49 00 00       	call   80104d10 <strlen>

  path[len]='_';
  path[len+1]='\0';

  len=strlen(path);
80100364:	89 1c 24             	mov    %ebx,(%esp)
  path[len]='_';
80100367:	c6 44 05 94 5f       	movb   $0x5f,-0x6c(%ebp,%eax,1)
  path[len+1]='\0';
8010036c:	c6 44 05 95 00       	movb   $0x0,-0x6b(%ebp,%eax,1)
  len=strlen(path);
80100371:	e8 9a 49 00 00       	call   80104d10 <strlen>
	itoa(x, path+ len);
80100376:	5a                   	pop    %edx
80100377:	59                   	pop    %ecx
80100378:	01 d8                	add    %ebx,%eax
8010037a:	50                   	push   %eax
8010037b:	56                   	push   %esi
8010037c:	e8 ff 1f 00 00       	call   80102380 <itoa>
  begin_op();
80100381:	e8 fa 2c 00 00       	call   80103080 <begin_op>
  struct inode * in = create(path, 2, 0, 0);
80100386:	6a 00                	push   $0x0
80100388:	6a 00                	push   $0x0
8010038a:	6a 02                	push   $0x2
8010038c:	53                   	push   %ebx
8010038d:	e8 fe fd ff ff       	call   80100190 <create>
	iunlock(in);
80100392:	83 c4 14             	add    $0x14,%esp
  struct inode * in = create(path, 2, 0, 0);
80100395:	89 c6                	mov    %eax,%esi
	iunlock(in);
80100397:	50                   	push   %eax
80100398:	e8 23 18 00 00       	call   80101bc0 <iunlock>
  ret=filealloc();
8010039d:	e8 4e 0d 00 00       	call   801010f0 <filealloc>

	if(ret == 0)
801003a2:	83 c4 10             	add    $0x10,%esp
801003a5:	85 c0                	test   %eax,%eax
801003a7:	74 29                	je     801003d2 <createSwapFile+0x92>
801003a9:	89 c3                	mov    %eax,%ebx
  {
		panic("no slot for files on store");
  }
  
	ret->ip = in;
801003ab:	89 70 10             	mov    %esi,0x10(%eax)
	ret->type = FD_INODE;
801003ae:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	ret->off = 0;
801003b4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  ret->writable = O_RDWR;
	ret->readable = O_WRONLY;
801003bb:	b8 01 02 00 00       	mov    $0x201,%eax
801003c0:	66 89 43 08          	mov    %ax,0x8(%ebx)
  end_op();
801003c4:	e8 27 2d 00 00       	call   801030f0 <end_op>
  return ret;
}
801003c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801003cc:	89 d8                	mov    %ebx,%eax
801003ce:	5b                   	pop    %ebx
801003cf:	5e                   	pop    %esi
801003d0:	5d                   	pop    %ebp
801003d1:	c3                   	ret    
		panic("no slot for files on store");
801003d2:	83 ec 0c             	sub    $0xc,%esp
801003d5:	68 ee 7b 10 80       	push   $0x80107bee
801003da:	e8 21 03 00 00       	call   80100700 <panic>
801003df:	90                   	nop

801003e0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801003e0:	55                   	push   %ebp
801003e1:	89 e5                	mov    %esp,%ebp
801003e3:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801003e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801003e9:	8b 45 08             	mov    0x8(%ebp),%eax
801003ec:	e8 4f fc ff ff       	call   80100040 <bget>
  if((b->flags & B_VALID) == 0) {
801003f1:	f6 00 02             	testb  $0x2,(%eax)
801003f4:	74 0a                	je     80100400 <bread+0x20>
    iderw(b);
  }
  return b;
}
801003f6:	c9                   	leave  
801003f7:	c3                   	ret    
801003f8:	90                   	nop
801003f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100400:	83 ec 0c             	sub    $0xc,%esp
80100403:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100406:	50                   	push   %eax
80100407:	e8 f4 21 00 00       	call   80102600 <iderw>
8010040c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010040f:	83 c4 10             	add    $0x10,%esp
}
80100412:	c9                   	leave  
80100413:	c3                   	ret    
80100414:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010041a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80100420 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100420:	55                   	push   %ebp
80100421:	89 e5                	mov    %esp,%ebp
80100423:	53                   	push   %ebx
80100424:	83 ec 10             	sub    $0x10,%esp
80100427:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010042a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010042d:	50                   	push   %eax
8010042e:	e8 1d 44 00 00       	call   80104850 <holdingsleep>
80100433:	83 c4 10             	add    $0x10,%esp
80100436:	85 c0                	test   %eax,%eax
80100438:	74 0f                	je     80100449 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
8010043a:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
8010043d:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80100440:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100443:	c9                   	leave  
  iderw(b);
80100444:	e9 b7 21 00 00       	jmp    80102600 <iderw>
    panic("bwrite");
80100449:	83 ec 0c             	sub    $0xc,%esp
8010044c:	68 09 7c 10 80       	push   $0x80107c09
80100451:	e8 aa 02 00 00       	call   80100700 <panic>
80100456:	8d 76 00             	lea    0x0(%esi),%esi
80100459:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100460 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100460:	55                   	push   %ebp
80100461:	89 e5                	mov    %esp,%ebp
80100463:	56                   	push   %esi
80100464:	53                   	push   %ebx
80100465:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
80100468:	83 ec 0c             	sub    $0xc,%esp
8010046b:	8d 73 0c             	lea    0xc(%ebx),%esi
8010046e:	56                   	push   %esi
8010046f:	e8 dc 43 00 00       	call   80104850 <holdingsleep>
80100474:	83 c4 10             	add    $0x10,%esp
80100477:	85 c0                	test   %eax,%eax
80100479:	74 66                	je     801004e1 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010047b:	83 ec 0c             	sub    $0xc,%esp
8010047e:	56                   	push   %esi
8010047f:	e8 8c 43 00 00       	call   80104810 <releasesleep>

  acquire(&bcache.lock);
80100484:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010048b:	e8 e0 44 00 00       	call   80104970 <acquire>
  b->refcnt--;
80100490:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100493:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100496:	83 e8 01             	sub    $0x1,%eax
  if (b->refcnt == 0) {
80100499:	85 c0                	test   %eax,%eax
  b->refcnt--;
8010049b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010049e:	75 2f                	jne    801004cf <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
801004a0:	8b 43 54             	mov    0x54(%ebx),%eax
801004a3:	8b 53 50             	mov    0x50(%ebx),%edx
801004a6:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801004a9:	8b 43 50             	mov    0x50(%ebx),%eax
801004ac:	8b 53 54             	mov    0x54(%ebx),%edx
801004af:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801004b2:	a1 10 0d 11 80       	mov    0x80110d10,%eax
    b->prev = &bcache.head;
801004b7:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    b->next = bcache.head.next;
801004be:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
801004c1:	a1 10 0d 11 80       	mov    0x80110d10,%eax
801004c6:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801004c9:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  }

  release(&bcache.lock);
801004cf:	c7 45 08 c0 c5 10 80 	movl   $0x8010c5c0,0x8(%ebp)
}
801004d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801004d9:	5b                   	pop    %ebx
801004da:	5e                   	pop    %esi
801004db:	5d                   	pop    %ebp
  release(&bcache.lock);
801004dc:	e9 af 45 00 00       	jmp    80104a90 <release>
    panic("brelse");
801004e1:	83 ec 0c             	sub    $0xc,%esp
801004e4:	68 10 7c 10 80       	push   $0x80107c10
801004e9:	e8 12 02 00 00       	call   80100700 <panic>
801004ee:	66 90                	xchg   %ax,%ax

801004f0 <read_page_from_disk>:
{
801004f0:	55                   	push   %ebp
801004f1:	89 e5                	mov    %esp,%ebp
801004f3:	57                   	push   %edi
801004f4:	56                   	push   %esi
801004f5:	53                   	push   %ebx
801004f6:	83 ec 1c             	sub    $0x1c,%esp
801004f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801004fc:	8b 75 10             	mov    0x10(%ebp),%esi
801004ff:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
80100505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100508:	90                   	nop
80100509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    buffer=bread(ROOTDEV,blockno);    //if present in buffer, returns from buffer else from disk
80100510:	83 ec 08             	sub    $0x8,%esp
80100513:	56                   	push   %esi
80100514:	6a 01                	push   $0x1
80100516:	83 c6 01             	add    $0x1,%esi
80100519:	e8 c2 fe ff ff       	call   801003e0 <bread>
8010051e:	89 c7                	mov    %eax,%edi
    memmove(pg+ithpart, buffer->data,512);  //write to pg from buffer
80100520:	8d 40 5c             	lea    0x5c(%eax),%eax
80100523:	83 c4 0c             	add    $0xc,%esp
80100526:	68 00 02 00 00       	push   $0x200
8010052b:	50                   	push   %eax
8010052c:	53                   	push   %ebx
8010052d:	81 c3 00 02 00 00    	add    $0x200,%ebx
80100533:	e8 68 46 00 00       	call   80104ba0 <memmove>
    brelse(buffer);                   //release lock
80100538:	89 3c 24             	mov    %edi,(%esp)
8010053b:	e8 20 ff ff ff       	call   80100460 <brelse>
  for(int i=0;i<8;i++)
80100540:	83 c4 10             	add    $0x10,%esp
80100543:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
80100546:	75 c8                	jne    80100510 <read_page_from_disk+0x20>
}
80100548:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010054b:	5b                   	pop    %ebx
8010054c:	5e                   	pop    %esi
8010054d:	5f                   	pop    %edi
8010054e:	5d                   	pop    %ebp
8010054f:	c3                   	ret    

80100550 <write_page_to_disk>:
{
80100550:	55                   	push   %ebp
80100551:	89 e5                	mov    %esp,%ebp
80100553:	57                   	push   %edi
80100554:	56                   	push   %esi
80100555:	53                   	push   %ebx
  struct file* towrite=createSwapFile(pg,pid,pte);
80100556:	31 f6                	xor    %esi,%esi
{
80100558:	83 ec 10             	sub    $0x10,%esp
  struct file* towrite=createSwapFile(pg,pid,pte);
8010055b:	ff 75 18             	pushl  0x18(%ebp)
8010055e:	ff 75 14             	pushl  0x14(%ebp)
80100561:	ff 75 0c             	pushl  0xc(%ebp)
80100564:	e8 d7 fd ff ff       	call   80100340 <createSwapFile>
80100569:	83 c4 10             	add    $0x10,%esp
8010056c:	89 c7                	mov    %eax,%edi
8010056e:	66 90                	xchg   %ax,%ax
    buffer=bget(ROOTDEV,blockno);
80100570:	8b 55 10             	mov    0x10(%ebp),%edx
80100573:	b8 01 00 00 00       	mov    $0x1,%eax
80100578:	e8 c3 fa ff ff       	call   80100040 <bget>
8010057d:	89 c3                	mov    %eax,%ebx
    memmove(buffer->data,pg+ithPart,512);   // Writing 512 bytes to the block
8010057f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100582:	83 ec 04             	sub    $0x4,%esp
    towrite->off=i*512;
80100585:	89 77 14             	mov    %esi,0x14(%edi)
    memmove(buffer->data,pg+ithPart,512);   // Writing 512 bytes to the block
80100588:	68 00 02 00 00       	push   $0x200
8010058d:	01 f0                	add    %esi,%eax
8010058f:	81 c6 00 02 00 00    	add    $0x200,%esi
80100595:	50                   	push   %eax
80100596:	8d 43 5c             	lea    0x5c(%ebx),%eax
80100599:	50                   	push   %eax
8010059a:	e8 01 46 00 00       	call   80104ba0 <memmove>
    filewrite(towrite,(char *)buffer,512);
8010059f:	83 c4 0c             	add    $0xc,%esp
801005a2:	68 00 02 00 00       	push   $0x200
801005a7:	53                   	push   %ebx
801005a8:	57                   	push   %edi
801005a9:	e8 b2 0d 00 00       	call   80101360 <filewrite>
    bwrite(buffer);
801005ae:	89 1c 24             	mov    %ebx,(%esp)
801005b1:	e8 6a fe ff ff       	call   80100420 <bwrite>
    brelse(buffer);                         //releasing the lock
801005b6:	89 1c 24             	mov    %ebx,(%esp)
801005b9:	e8 a2 fe ff ff       	call   80100460 <brelse>
801005be:	83 45 10 01          	addl   $0x1,0x10(%ebp)
  for(int i=0;i<8;i++)
801005c2:	83 c4 10             	add    $0x10,%esp
801005c5:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
801005cb:	75 a3                	jne    80100570 <write_page_to_disk+0x20>
}
801005cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005d0:	5b                   	pop    %ebx
801005d1:	5e                   	pop    %esi
801005d2:	5f                   	pop    %edi
801005d3:	5d                   	pop    %ebp
801005d4:	c3                   	ret    
801005d5:	66 90                	xchg   %ax,%ax
801005d7:	66 90                	xchg   %ax,%ax
801005d9:	66 90                	xchg   %ax,%ax
801005db:	66 90                	xchg   %ax,%ax
801005dd:	66 90                	xchg   %ax,%ax
801005df:	90                   	nop

801005e0 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
801005e0:	55                   	push   %ebp
801005e1:	89 e5                	mov    %esp,%ebp
801005e3:	57                   	push   %edi
801005e4:	56                   	push   %esi
801005e5:	53                   	push   %ebx
801005e6:	83 ec 28             	sub    $0x28,%esp
801005e9:	8b 7d 08             	mov    0x8(%ebp),%edi
801005ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
801005ef:	57                   	push   %edi
801005f0:	e8 cb 15 00 00       	call   80101bc0 <iunlock>
  target = n;
  acquire(&cons.lock);
801005f5:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
801005fc:	e8 6f 43 00 00       	call   80104970 <acquire>
  while(n > 0){
80100601:	8b 5d 10             	mov    0x10(%ebp),%ebx
80100604:	83 c4 10             	add    $0x10,%esp
80100607:	31 c0                	xor    %eax,%eax
80100609:	85 db                	test   %ebx,%ebx
8010060b:	0f 8e a1 00 00 00    	jle    801006b2 <consoleread+0xd2>
    while(input.r == input.w){
80100611:	8b 15 a0 0f 11 80    	mov    0x80110fa0,%edx
80100617:	39 15 a4 0f 11 80    	cmp    %edx,0x80110fa4
8010061d:	74 2c                	je     8010064b <consoleread+0x6b>
8010061f:	eb 5f                	jmp    80100680 <consoleread+0xa0>
80100621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
80100628:	83 ec 08             	sub    $0x8,%esp
8010062b:	68 20 b5 10 80       	push   $0x8010b520
80100630:	68 a0 0f 11 80       	push   $0x80110fa0
80100635:	e8 f6 3b 00 00       	call   80104230 <sleep>
    while(input.r == input.w){
8010063a:	8b 15 a0 0f 11 80    	mov    0x80110fa0,%edx
80100640:	83 c4 10             	add    $0x10,%esp
80100643:	3b 15 a4 0f 11 80    	cmp    0x80110fa4,%edx
80100649:	75 35                	jne    80100680 <consoleread+0xa0>
      if(myproc()->killed){
8010064b:	e8 70 36 00 00       	call   80103cc0 <myproc>
80100650:	8b 40 24             	mov    0x24(%eax),%eax
80100653:	85 c0                	test   %eax,%eax
80100655:	74 d1                	je     80100628 <consoleread+0x48>
        release(&cons.lock);
80100657:	83 ec 0c             	sub    $0xc,%esp
8010065a:	68 20 b5 10 80       	push   $0x8010b520
8010065f:	e8 2c 44 00 00       	call   80104a90 <release>
        ilock(ip);
80100664:	89 3c 24             	mov    %edi,(%esp)
80100667:	e8 74 14 00 00       	call   80101ae0 <ilock>
        return -1;
8010066c:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
8010066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
80100672:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100677:	5b                   	pop    %ebx
80100678:	5e                   	pop    %esi
80100679:	5f                   	pop    %edi
8010067a:	5d                   	pop    %ebp
8010067b:	c3                   	ret    
8010067c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100680:	8d 42 01             	lea    0x1(%edx),%eax
80100683:	a3 a0 0f 11 80       	mov    %eax,0x80110fa0
80100688:	89 d0                	mov    %edx,%eax
8010068a:	83 e0 7f             	and    $0x7f,%eax
8010068d:	0f be 80 20 0f 11 80 	movsbl -0x7feef0e0(%eax),%eax
    if(c == C('D')){  // EOF
80100694:	83 f8 04             	cmp    $0x4,%eax
80100697:	74 3f                	je     801006d8 <consoleread+0xf8>
    *dst++ = c;
80100699:	83 c6 01             	add    $0x1,%esi
    --n;
8010069c:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
8010069f:	83 f8 0a             	cmp    $0xa,%eax
    *dst++ = c;
801006a2:	88 46 ff             	mov    %al,-0x1(%esi)
    if(c == '\n')
801006a5:	74 43                	je     801006ea <consoleread+0x10a>
  while(n > 0){
801006a7:	85 db                	test   %ebx,%ebx
801006a9:	0f 85 62 ff ff ff    	jne    80100611 <consoleread+0x31>
801006af:	8b 45 10             	mov    0x10(%ebp),%eax
  release(&cons.lock);
801006b2:	83 ec 0c             	sub    $0xc,%esp
801006b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801006b8:	68 20 b5 10 80       	push   $0x8010b520
801006bd:	e8 ce 43 00 00       	call   80104a90 <release>
  ilock(ip);
801006c2:	89 3c 24             	mov    %edi,(%esp)
801006c5:	e8 16 14 00 00       	call   80101ae0 <ilock>
  return target - n;
801006ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801006cd:	83 c4 10             	add    $0x10,%esp
}
801006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801006d3:	5b                   	pop    %ebx
801006d4:	5e                   	pop    %esi
801006d5:	5f                   	pop    %edi
801006d6:	5d                   	pop    %ebp
801006d7:	c3                   	ret    
801006d8:	8b 45 10             	mov    0x10(%ebp),%eax
801006db:	29 d8                	sub    %ebx,%eax
      if(n < target){
801006dd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
801006e0:	73 d0                	jae    801006b2 <consoleread+0xd2>
        input.r--;
801006e2:	89 15 a0 0f 11 80    	mov    %edx,0x80110fa0
801006e8:	eb c8                	jmp    801006b2 <consoleread+0xd2>
801006ea:	8b 45 10             	mov    0x10(%ebp),%eax
801006ed:	29 d8                	sub    %ebx,%eax
801006ef:	eb c1                	jmp    801006b2 <consoleread+0xd2>
801006f1:	eb 0d                	jmp    80100700 <panic>
801006f3:	90                   	nop
801006f4:	90                   	nop
801006f5:	90                   	nop
801006f6:	90                   	nop
801006f7:	90                   	nop
801006f8:	90                   	nop
801006f9:	90                   	nop
801006fa:	90                   	nop
801006fb:	90                   	nop
801006fc:	90                   	nop
801006fd:	90                   	nop
801006fe:	90                   	nop
801006ff:	90                   	nop

80100700 <panic>:
{
80100700:	55                   	push   %ebp
80100701:	89 e5                	mov    %esp,%ebp
80100703:	56                   	push   %esi
80100704:	53                   	push   %ebx
80100705:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100708:	fa                   	cli    
  cons.locking = 0;
80100709:	c7 05 54 b5 10 80 00 	movl   $0x0,0x8010b554
80100710:	00 00 00 
  getcallerpcs(&s, pcs);
80100713:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100716:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100719:	e8 f2 24 00 00       	call   80102c10 <lapicid>
8010071e:	83 ec 08             	sub    $0x8,%esp
80100721:	50                   	push   %eax
80100722:	68 17 7c 10 80       	push   $0x80107c17
80100727:	e8 a4 02 00 00       	call   801009d0 <cprintf>
  cprintf(s);
8010072c:	58                   	pop    %eax
8010072d:	ff 75 08             	pushl  0x8(%ebp)
80100730:	e8 9b 02 00 00       	call   801009d0 <cprintf>
  cprintf("\n");
80100735:	c7 04 24 e3 86 10 80 	movl   $0x801086e3,(%esp)
8010073c:	e8 8f 02 00 00       	call   801009d0 <cprintf>
  getcallerpcs(&s, pcs);
80100741:	5a                   	pop    %edx
80100742:	8d 45 08             	lea    0x8(%ebp),%eax
80100745:	59                   	pop    %ecx
80100746:	53                   	push   %ebx
80100747:	50                   	push   %eax
80100748:	e8 53 41 00 00       	call   801048a0 <getcallerpcs>
8010074d:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
80100750:	83 ec 08             	sub    $0x8,%esp
80100753:	ff 33                	pushl  (%ebx)
80100755:	83 c3 04             	add    $0x4,%ebx
80100758:	68 2b 7c 10 80       	push   $0x80107c2b
8010075d:	e8 6e 02 00 00       	call   801009d0 <cprintf>
  for(i=0; i<10; i++)
80100762:	83 c4 10             	add    $0x10,%esp
80100765:	39 f3                	cmp    %esi,%ebx
80100767:	75 e7                	jne    80100750 <panic+0x50>
  panicked = 1; // freeze other CPU
80100769:	c7 05 58 b5 10 80 01 	movl   $0x1,0x8010b558
80100770:	00 00 00 
80100773:	eb fe                	jmp    80100773 <panic+0x73>
80100775:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80100780 <consputc>:
  if(panicked){
80100780:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
80100786:	85 c9                	test   %ecx,%ecx
80100788:	74 06                	je     80100790 <consputc+0x10>
8010078a:	fa                   	cli    
8010078b:	eb fe                	jmp    8010078b <consputc+0xb>
8010078d:	8d 76 00             	lea    0x0(%esi),%esi
{
80100790:	55                   	push   %ebp
80100791:	89 e5                	mov    %esp,%ebp
80100793:	57                   	push   %edi
80100794:	56                   	push   %esi
80100795:	53                   	push   %ebx
80100796:	89 c6                	mov    %eax,%esi
80100798:	83 ec 0c             	sub    $0xc,%esp
  if(c == BACKSPACE){
8010079b:	3d 00 01 00 00       	cmp    $0x100,%eax
801007a0:	0f 84 b1 00 00 00    	je     80100857 <consputc+0xd7>
    uartputc(c);
801007a6:	83 ec 0c             	sub    $0xc,%esp
801007a9:	50                   	push   %eax
801007aa:	e8 91 5e 00 00       	call   80106640 <uartputc>
801007af:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801007b2:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801007b7:	b8 0e 00 00 00       	mov    $0xe,%eax
801007bc:	89 da                	mov    %ebx,%edx
801007be:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801007bf:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801007c4:	89 ca                	mov    %ecx,%edx
801007c6:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801007c7:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801007ca:	89 da                	mov    %ebx,%edx
801007cc:	c1 e0 08             	shl    $0x8,%eax
801007cf:	89 c7                	mov    %eax,%edi
801007d1:	b8 0f 00 00 00       	mov    $0xf,%eax
801007d6:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801007d7:	89 ca                	mov    %ecx,%edx
801007d9:	ec                   	in     (%dx),%al
801007da:	0f b6 d8             	movzbl %al,%ebx
  pos |= inb(CRTPORT+1);
801007dd:	09 fb                	or     %edi,%ebx
  if(c == '\n')
801007df:	83 fe 0a             	cmp    $0xa,%esi
801007e2:	0f 84 f3 00 00 00    	je     801008db <consputc+0x15b>
  else if(c == BACKSPACE){
801007e8:	81 fe 00 01 00 00    	cmp    $0x100,%esi
801007ee:	0f 84 d7 00 00 00    	je     801008cb <consputc+0x14b>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801007f4:	89 f0                	mov    %esi,%eax
801007f6:	0f b6 c0             	movzbl %al,%eax
801007f9:	80 cc 07             	or     $0x7,%ah
801007fc:	66 89 84 1b 00 80 0b 	mov    %ax,-0x7ff48000(%ebx,%ebx,1)
80100803:	80 
80100804:	83 c3 01             	add    $0x1,%ebx
  if(pos < 0 || pos > 25*80)
80100807:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
8010080d:	0f 8f ab 00 00 00    	jg     801008be <consputc+0x13e>
  if((pos/80) >= 24){  // Scroll up.
80100813:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100819:	7f 66                	jg     80100881 <consputc+0x101>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010081b:	be d4 03 00 00       	mov    $0x3d4,%esi
80100820:	b8 0e 00 00 00       	mov    $0xe,%eax
80100825:	89 f2                	mov    %esi,%edx
80100827:	ee                   	out    %al,(%dx)
80100828:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
  outb(CRTPORT+1, pos>>8);
8010082d:	89 d8                	mov    %ebx,%eax
8010082f:	c1 f8 08             	sar    $0x8,%eax
80100832:	89 ca                	mov    %ecx,%edx
80100834:	ee                   	out    %al,(%dx)
80100835:	b8 0f 00 00 00       	mov    $0xf,%eax
8010083a:	89 f2                	mov    %esi,%edx
8010083c:	ee                   	out    %al,(%dx)
8010083d:	89 d8                	mov    %ebx,%eax
8010083f:	89 ca                	mov    %ecx,%edx
80100841:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100842:	b8 20 07 00 00       	mov    $0x720,%eax
80100847:	66 89 84 1b 00 80 0b 	mov    %ax,-0x7ff48000(%ebx,%ebx,1)
8010084e:	80 
}
8010084f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100852:	5b                   	pop    %ebx
80100853:	5e                   	pop    %esi
80100854:	5f                   	pop    %edi
80100855:	5d                   	pop    %ebp
80100856:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100857:	83 ec 0c             	sub    $0xc,%esp
8010085a:	6a 08                	push   $0x8
8010085c:	e8 df 5d 00 00       	call   80106640 <uartputc>
80100861:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100868:	e8 d3 5d 00 00       	call   80106640 <uartputc>
8010086d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100874:	e8 c7 5d 00 00       	call   80106640 <uartputc>
80100879:	83 c4 10             	add    $0x10,%esp
8010087c:	e9 31 ff ff ff       	jmp    801007b2 <consputc+0x32>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100881:	52                   	push   %edx
80100882:	68 60 0e 00 00       	push   $0xe60
    pos -= 80;
80100887:	83 eb 50             	sub    $0x50,%ebx
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010088a:	68 a0 80 0b 80       	push   $0x800b80a0
8010088f:	68 00 80 0b 80       	push   $0x800b8000
80100894:	e8 07 43 00 00       	call   80104ba0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100899:	b8 80 07 00 00       	mov    $0x780,%eax
8010089e:	83 c4 0c             	add    $0xc,%esp
801008a1:	29 d8                	sub    %ebx,%eax
801008a3:	01 c0                	add    %eax,%eax
801008a5:	50                   	push   %eax
801008a6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
801008a9:	6a 00                	push   $0x0
801008ab:	2d 00 80 f4 7f       	sub    $0x7ff48000,%eax
801008b0:	50                   	push   %eax
801008b1:	e8 3a 42 00 00       	call   80104af0 <memset>
801008b6:	83 c4 10             	add    $0x10,%esp
801008b9:	e9 5d ff ff ff       	jmp    8010081b <consputc+0x9b>
    panic("pos under/overflow");
801008be:	83 ec 0c             	sub    $0xc,%esp
801008c1:	68 2f 7c 10 80       	push   $0x80107c2f
801008c6:	e8 35 fe ff ff       	call   80100700 <panic>
    if(pos > 0) --pos;
801008cb:	85 db                	test   %ebx,%ebx
801008cd:	0f 84 48 ff ff ff    	je     8010081b <consputc+0x9b>
801008d3:	83 eb 01             	sub    $0x1,%ebx
801008d6:	e9 2c ff ff ff       	jmp    80100807 <consputc+0x87>
    pos += 80 - pos%80;
801008db:	89 d8                	mov    %ebx,%eax
801008dd:	b9 50 00 00 00       	mov    $0x50,%ecx
801008e2:	99                   	cltd   
801008e3:	f7 f9                	idiv   %ecx
801008e5:	29 d1                	sub    %edx,%ecx
801008e7:	01 cb                	add    %ecx,%ebx
801008e9:	e9 19 ff ff ff       	jmp    80100807 <consputc+0x87>
801008ee:	66 90                	xchg   %ax,%ax

801008f0 <printint>:
{
801008f0:	55                   	push   %ebp
801008f1:	89 e5                	mov    %esp,%ebp
801008f3:	57                   	push   %edi
801008f4:	56                   	push   %esi
801008f5:	53                   	push   %ebx
801008f6:	89 d3                	mov    %edx,%ebx
801008f8:	83 ec 2c             	sub    $0x2c,%esp
  if(sign && (sign = xx < 0))
801008fb:	85 c9                	test   %ecx,%ecx
{
801008fd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
80100900:	74 04                	je     80100906 <printint+0x16>
80100902:	85 c0                	test   %eax,%eax
80100904:	78 5a                	js     80100960 <printint+0x70>
    x = xx;
80100906:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  i = 0;
8010090d:	31 c9                	xor    %ecx,%ecx
8010090f:	8d 75 d7             	lea    -0x29(%ebp),%esi
80100912:	eb 06                	jmp    8010091a <printint+0x2a>
80100914:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    buf[i++] = digits[x % base];
80100918:	89 f9                	mov    %edi,%ecx
8010091a:	31 d2                	xor    %edx,%edx
8010091c:	8d 79 01             	lea    0x1(%ecx),%edi
8010091f:	f7 f3                	div    %ebx
80100921:	0f b6 92 5c 7c 10 80 	movzbl -0x7fef83a4(%edx),%edx
  }while((x /= base) != 0);
80100928:	85 c0                	test   %eax,%eax
    buf[i++] = digits[x % base];
8010092a:	88 14 3e             	mov    %dl,(%esi,%edi,1)
  }while((x /= base) != 0);
8010092d:	75 e9                	jne    80100918 <printint+0x28>
  if(sign)
8010092f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100932:	85 c0                	test   %eax,%eax
80100934:	74 08                	je     8010093e <printint+0x4e>
    buf[i++] = '-';
80100936:	c6 44 3d d8 2d       	movb   $0x2d,-0x28(%ebp,%edi,1)
8010093b:	8d 79 02             	lea    0x2(%ecx),%edi
8010093e:	8d 5c 3d d7          	lea    -0x29(%ebp,%edi,1),%ebx
80100942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    consputc(buf[i]);
80100948:	0f be 03             	movsbl (%ebx),%eax
8010094b:	83 eb 01             	sub    $0x1,%ebx
8010094e:	e8 2d fe ff ff       	call   80100780 <consputc>
  while(--i >= 0)
80100953:	39 f3                	cmp    %esi,%ebx
80100955:	75 f1                	jne    80100948 <printint+0x58>
}
80100957:	83 c4 2c             	add    $0x2c,%esp
8010095a:	5b                   	pop    %ebx
8010095b:	5e                   	pop    %esi
8010095c:	5f                   	pop    %edi
8010095d:	5d                   	pop    %ebp
8010095e:	c3                   	ret    
8010095f:	90                   	nop
    x = -xx;
80100960:	f7 d8                	neg    %eax
80100962:	eb a9                	jmp    8010090d <printint+0x1d>
80100964:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010096a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80100970 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100970:	55                   	push   %ebp
80100971:	89 e5                	mov    %esp,%ebp
80100973:	57                   	push   %edi
80100974:	56                   	push   %esi
80100975:	53                   	push   %ebx
80100976:	83 ec 18             	sub    $0x18,%esp
80100979:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
8010097c:	ff 75 08             	pushl  0x8(%ebp)
8010097f:	e8 3c 12 00 00       	call   80101bc0 <iunlock>
  acquire(&cons.lock);
80100984:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010098b:	e8 e0 3f 00 00       	call   80104970 <acquire>
  for(i = 0; i < n; i++)
80100990:	83 c4 10             	add    $0x10,%esp
80100993:	85 f6                	test   %esi,%esi
80100995:	7e 18                	jle    801009af <consolewrite+0x3f>
80100997:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010099a:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
8010099d:	8d 76 00             	lea    0x0(%esi),%esi
    consputc(buf[i] & 0xff);
801009a0:	0f b6 07             	movzbl (%edi),%eax
801009a3:	83 c7 01             	add    $0x1,%edi
801009a6:	e8 d5 fd ff ff       	call   80100780 <consputc>
  for(i = 0; i < n; i++)
801009ab:	39 fb                	cmp    %edi,%ebx
801009ad:	75 f1                	jne    801009a0 <consolewrite+0x30>
  release(&cons.lock);
801009af:	83 ec 0c             	sub    $0xc,%esp
801009b2:	68 20 b5 10 80       	push   $0x8010b520
801009b7:	e8 d4 40 00 00       	call   80104a90 <release>
  ilock(ip);
801009bc:	58                   	pop    %eax
801009bd:	ff 75 08             	pushl  0x8(%ebp)
801009c0:	e8 1b 11 00 00       	call   80101ae0 <ilock>

  return n;
}
801009c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801009c8:	89 f0                	mov    %esi,%eax
801009ca:	5b                   	pop    %ebx
801009cb:	5e                   	pop    %esi
801009cc:	5f                   	pop    %edi
801009cd:	5d                   	pop    %ebp
801009ce:	c3                   	ret    
801009cf:	90                   	nop

801009d0 <cprintf>:
{
801009d0:	55                   	push   %ebp
801009d1:	89 e5                	mov    %esp,%ebp
801009d3:	57                   	push   %edi
801009d4:	56                   	push   %esi
801009d5:	53                   	push   %ebx
801009d6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801009d9:	a1 54 b5 10 80       	mov    0x8010b554,%eax
  if(locking)
801009de:	85 c0                	test   %eax,%eax
  locking = cons.locking;
801009e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(locking)
801009e3:	0f 85 6f 01 00 00    	jne    80100b58 <cprintf+0x188>
  if (fmt == 0)
801009e9:	8b 45 08             	mov    0x8(%ebp),%eax
801009ec:	85 c0                	test   %eax,%eax
801009ee:	89 c7                	mov    %eax,%edi
801009f0:	0f 84 77 01 00 00    	je     80100b6d <cprintf+0x19d>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801009f6:	0f b6 00             	movzbl (%eax),%eax
  argp = (uint*)(void*)(&fmt + 1);
801009f9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801009fc:	31 db                	xor    %ebx,%ebx
  argp = (uint*)(void*)(&fmt + 1);
801009fe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100a01:	85 c0                	test   %eax,%eax
80100a03:	75 56                	jne    80100a5b <cprintf+0x8b>
80100a05:	eb 79                	jmp    80100a80 <cprintf+0xb0>
80100a07:	89 f6                	mov    %esi,%esi
80100a09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    c = fmt[++i] & 0xff;
80100a10:	0f b6 16             	movzbl (%esi),%edx
    if(c == 0)
80100a13:	85 d2                	test   %edx,%edx
80100a15:	74 69                	je     80100a80 <cprintf+0xb0>
80100a17:	83 c3 02             	add    $0x2,%ebx
    switch(c){
80100a1a:	83 fa 70             	cmp    $0x70,%edx
80100a1d:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
80100a20:	0f 84 84 00 00 00    	je     80100aaa <cprintf+0xda>
80100a26:	7f 78                	jg     80100aa0 <cprintf+0xd0>
80100a28:	83 fa 25             	cmp    $0x25,%edx
80100a2b:	0f 84 ff 00 00 00    	je     80100b30 <cprintf+0x160>
80100a31:	83 fa 64             	cmp    $0x64,%edx
80100a34:	0f 85 8e 00 00 00    	jne    80100ac8 <cprintf+0xf8>
      printint(*argp++, 10, 1);
80100a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100a3d:	ba 0a 00 00 00       	mov    $0xa,%edx
80100a42:	8d 48 04             	lea    0x4(%eax),%ecx
80100a45:	8b 00                	mov    (%eax),%eax
80100a47:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80100a4a:	b9 01 00 00 00       	mov    $0x1,%ecx
80100a4f:	e8 9c fe ff ff       	call   801008f0 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100a54:	0f b6 06             	movzbl (%esi),%eax
80100a57:	85 c0                	test   %eax,%eax
80100a59:	74 25                	je     80100a80 <cprintf+0xb0>
80100a5b:	8d 53 01             	lea    0x1(%ebx),%edx
    if(c != '%'){
80100a5e:	83 f8 25             	cmp    $0x25,%eax
80100a61:	8d 34 17             	lea    (%edi,%edx,1),%esi
80100a64:	74 aa                	je     80100a10 <cprintf+0x40>
80100a66:	89 55 e0             	mov    %edx,-0x20(%ebp)
      consputc(c);
80100a69:	e8 12 fd ff ff       	call   80100780 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100a6e:	0f b6 06             	movzbl (%esi),%eax
      continue;
80100a71:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100a74:	89 d3                	mov    %edx,%ebx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100a76:	85 c0                	test   %eax,%eax
80100a78:	75 e1                	jne    80100a5b <cprintf+0x8b>
80100a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(locking)
80100a80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100a83:	85 c0                	test   %eax,%eax
80100a85:	74 10                	je     80100a97 <cprintf+0xc7>
    release(&cons.lock);
80100a87:	83 ec 0c             	sub    $0xc,%esp
80100a8a:	68 20 b5 10 80       	push   $0x8010b520
80100a8f:	e8 fc 3f 00 00       	call   80104a90 <release>
80100a94:	83 c4 10             	add    $0x10,%esp
}
80100a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a9a:	5b                   	pop    %ebx
80100a9b:	5e                   	pop    %esi
80100a9c:	5f                   	pop    %edi
80100a9d:	5d                   	pop    %ebp
80100a9e:	c3                   	ret    
80100a9f:	90                   	nop
    switch(c){
80100aa0:	83 fa 73             	cmp    $0x73,%edx
80100aa3:	74 43                	je     80100ae8 <cprintf+0x118>
80100aa5:	83 fa 78             	cmp    $0x78,%edx
80100aa8:	75 1e                	jne    80100ac8 <cprintf+0xf8>
      printint(*argp++, 16, 0);
80100aaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100aad:	ba 10 00 00 00       	mov    $0x10,%edx
80100ab2:	8d 48 04             	lea    0x4(%eax),%ecx
80100ab5:	8b 00                	mov    (%eax),%eax
80100ab7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80100aba:	31 c9                	xor    %ecx,%ecx
80100abc:	e8 2f fe ff ff       	call   801008f0 <printint>
      break;
80100ac1:	eb 91                	jmp    80100a54 <cprintf+0x84>
80100ac3:	90                   	nop
80100ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      consputc('%');
80100ac8:	b8 25 00 00 00       	mov    $0x25,%eax
80100acd:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100ad0:	e8 ab fc ff ff       	call   80100780 <consputc>
      consputc(c);
80100ad5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ad8:	89 d0                	mov    %edx,%eax
80100ada:	e8 a1 fc ff ff       	call   80100780 <consputc>
      break;
80100adf:	e9 70 ff ff ff       	jmp    80100a54 <cprintf+0x84>
80100ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if((s = (char*)*argp++) == 0)
80100ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100aeb:	8b 10                	mov    (%eax),%edx
80100aed:	8d 48 04             	lea    0x4(%eax),%ecx
80100af0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80100af3:	85 d2                	test   %edx,%edx
80100af5:	74 49                	je     80100b40 <cprintf+0x170>
      for(; *s; s++)
80100af7:	0f be 02             	movsbl (%edx),%eax
      if((s = (char*)*argp++) == 0)
80100afa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
      for(; *s; s++)
80100afd:	84 c0                	test   %al,%al
80100aff:	0f 84 4f ff ff ff    	je     80100a54 <cprintf+0x84>
80100b05:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80100b08:	89 d3                	mov    %edx,%ebx
80100b0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100b10:	83 c3 01             	add    $0x1,%ebx
        consputc(*s);
80100b13:	e8 68 fc ff ff       	call   80100780 <consputc>
      for(; *s; s++)
80100b18:	0f be 03             	movsbl (%ebx),%eax
80100b1b:	84 c0                	test   %al,%al
80100b1d:	75 f1                	jne    80100b10 <cprintf+0x140>
      if((s = (char*)*argp++) == 0)
80100b1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100b22:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80100b25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100b28:	e9 27 ff ff ff       	jmp    80100a54 <cprintf+0x84>
80100b2d:	8d 76 00             	lea    0x0(%esi),%esi
      consputc('%');
80100b30:	b8 25 00 00 00       	mov    $0x25,%eax
80100b35:	e8 46 fc ff ff       	call   80100780 <consputc>
      break;
80100b3a:	e9 15 ff ff ff       	jmp    80100a54 <cprintf+0x84>
80100b3f:	90                   	nop
        s = "(null)";
80100b40:	ba 42 7c 10 80       	mov    $0x80107c42,%edx
      for(; *s; s++)
80100b45:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80100b48:	b8 28 00 00 00       	mov    $0x28,%eax
80100b4d:	89 d3                	mov    %edx,%ebx
80100b4f:	eb bf                	jmp    80100b10 <cprintf+0x140>
80100b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
80100b58:	83 ec 0c             	sub    $0xc,%esp
80100b5b:	68 20 b5 10 80       	push   $0x8010b520
80100b60:	e8 0b 3e 00 00       	call   80104970 <acquire>
80100b65:	83 c4 10             	add    $0x10,%esp
80100b68:	e9 7c fe ff ff       	jmp    801009e9 <cprintf+0x19>
    panic("null fmt");
80100b6d:	83 ec 0c             	sub    $0xc,%esp
80100b70:	68 49 7c 10 80       	push   $0x80107c49
80100b75:	e8 86 fb ff ff       	call   80100700 <panic>
80100b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100b80 <consoleintr>:
{
80100b80:	55                   	push   %ebp
80100b81:	89 e5                	mov    %esp,%ebp
80100b83:	57                   	push   %edi
80100b84:	56                   	push   %esi
80100b85:	53                   	push   %ebx
  int c, doprocdump = 0;
80100b86:	31 f6                	xor    %esi,%esi
{
80100b88:	83 ec 18             	sub    $0x18,%esp
80100b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
80100b8e:	68 20 b5 10 80       	push   $0x8010b520
80100b93:	e8 d8 3d 00 00       	call   80104970 <acquire>
  while((c = getc()) >= 0){
80100b98:	83 c4 10             	add    $0x10,%esp
80100b9b:	90                   	nop
80100b9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100ba0:	ff d3                	call   *%ebx
80100ba2:	85 c0                	test   %eax,%eax
80100ba4:	89 c7                	mov    %eax,%edi
80100ba6:	78 48                	js     80100bf0 <consoleintr+0x70>
    switch(c){
80100ba8:	83 ff 10             	cmp    $0x10,%edi
80100bab:	0f 84 e7 00 00 00    	je     80100c98 <consoleintr+0x118>
80100bb1:	7e 5d                	jle    80100c10 <consoleintr+0x90>
80100bb3:	83 ff 15             	cmp    $0x15,%edi
80100bb6:	0f 84 ec 00 00 00    	je     80100ca8 <consoleintr+0x128>
80100bbc:	83 ff 7f             	cmp    $0x7f,%edi
80100bbf:	75 54                	jne    80100c15 <consoleintr+0x95>
      if(input.e != input.w){
80100bc1:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100bc6:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100bcc:	74 d2                	je     80100ba0 <consoleintr+0x20>
        input.e--;
80100bce:	83 e8 01             	sub    $0x1,%eax
80100bd1:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
        consputc(BACKSPACE);
80100bd6:	b8 00 01 00 00       	mov    $0x100,%eax
80100bdb:	e8 a0 fb ff ff       	call   80100780 <consputc>
  while((c = getc()) >= 0){
80100be0:	ff d3                	call   *%ebx
80100be2:	85 c0                	test   %eax,%eax
80100be4:	89 c7                	mov    %eax,%edi
80100be6:	79 c0                	jns    80100ba8 <consoleintr+0x28>
80100be8:	90                   	nop
80100be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
80100bf0:	83 ec 0c             	sub    $0xc,%esp
80100bf3:	68 20 b5 10 80       	push   $0x8010b520
80100bf8:	e8 93 3e 00 00       	call   80104a90 <release>
  if(doprocdump) {
80100bfd:	83 c4 10             	add    $0x10,%esp
80100c00:	85 f6                	test   %esi,%esi
80100c02:	0f 85 f8 00 00 00    	jne    80100d00 <consoleintr+0x180>
}
80100c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100c0b:	5b                   	pop    %ebx
80100c0c:	5e                   	pop    %esi
80100c0d:	5f                   	pop    %edi
80100c0e:	5d                   	pop    %ebp
80100c0f:	c3                   	ret    
    switch(c){
80100c10:	83 ff 08             	cmp    $0x8,%edi
80100c13:	74 ac                	je     80100bc1 <consoleintr+0x41>
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100c15:	85 ff                	test   %edi,%edi
80100c17:	74 87                	je     80100ba0 <consoleintr+0x20>
80100c19:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100c1e:	89 c2                	mov    %eax,%edx
80100c20:	2b 15 a0 0f 11 80    	sub    0x80110fa0,%edx
80100c26:	83 fa 7f             	cmp    $0x7f,%edx
80100c29:	0f 87 71 ff ff ff    	ja     80100ba0 <consoleintr+0x20>
80100c2f:	8d 50 01             	lea    0x1(%eax),%edx
80100c32:	83 e0 7f             	and    $0x7f,%eax
        c = (c == '\r') ? '\n' : c;
80100c35:	83 ff 0d             	cmp    $0xd,%edi
        input.buf[input.e++ % INPUT_BUF] = c;
80100c38:	89 15 a8 0f 11 80    	mov    %edx,0x80110fa8
        c = (c == '\r') ? '\n' : c;
80100c3e:	0f 84 cc 00 00 00    	je     80100d10 <consoleintr+0x190>
        input.buf[input.e++ % INPUT_BUF] = c;
80100c44:	89 f9                	mov    %edi,%ecx
80100c46:	88 88 20 0f 11 80    	mov    %cl,-0x7feef0e0(%eax)
        consputc(c);
80100c4c:	89 f8                	mov    %edi,%eax
80100c4e:	e8 2d fb ff ff       	call   80100780 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100c53:	83 ff 0a             	cmp    $0xa,%edi
80100c56:	0f 84 c5 00 00 00    	je     80100d21 <consoleintr+0x1a1>
80100c5c:	83 ff 04             	cmp    $0x4,%edi
80100c5f:	0f 84 bc 00 00 00    	je     80100d21 <consoleintr+0x1a1>
80100c65:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
80100c6a:	83 e8 80             	sub    $0xffffff80,%eax
80100c6d:	39 05 a8 0f 11 80    	cmp    %eax,0x80110fa8
80100c73:	0f 85 27 ff ff ff    	jne    80100ba0 <consoleintr+0x20>
          wakeup(&input.r);
80100c79:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100c7c:	a3 a4 0f 11 80       	mov    %eax,0x80110fa4
          wakeup(&input.r);
80100c81:	68 a0 0f 11 80       	push   $0x80110fa0
80100c86:	e8 65 37 00 00       	call   801043f0 <wakeup>
80100c8b:	83 c4 10             	add    $0x10,%esp
80100c8e:	e9 0d ff ff ff       	jmp    80100ba0 <consoleintr+0x20>
80100c93:	90                   	nop
80100c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      doprocdump = 1;
80100c98:	be 01 00 00 00       	mov    $0x1,%esi
80100c9d:	e9 fe fe ff ff       	jmp    80100ba0 <consoleintr+0x20>
80100ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      while(input.e != input.w &&
80100ca8:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100cad:	39 05 a4 0f 11 80    	cmp    %eax,0x80110fa4
80100cb3:	75 2b                	jne    80100ce0 <consoleintr+0x160>
80100cb5:	e9 e6 fe ff ff       	jmp    80100ba0 <consoleintr+0x20>
80100cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        input.e--;
80100cc0:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
        consputc(BACKSPACE);
80100cc5:	b8 00 01 00 00       	mov    $0x100,%eax
80100cca:	e8 b1 fa ff ff       	call   80100780 <consputc>
      while(input.e != input.w &&
80100ccf:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100cd4:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100cda:	0f 84 c0 fe ff ff    	je     80100ba0 <consoleintr+0x20>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100ce0:	83 e8 01             	sub    $0x1,%eax
80100ce3:	89 c2                	mov    %eax,%edx
80100ce5:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100ce8:	80 ba 20 0f 11 80 0a 	cmpb   $0xa,-0x7feef0e0(%edx)
80100cef:	75 cf                	jne    80100cc0 <consoleintr+0x140>
80100cf1:	e9 aa fe ff ff       	jmp    80100ba0 <consoleintr+0x20>
80100cf6:	8d 76 00             	lea    0x0(%esi),%esi
80100cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
}
80100d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d03:	5b                   	pop    %ebx
80100d04:	5e                   	pop    %esi
80100d05:	5f                   	pop    %edi
80100d06:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100d07:	e9 c4 37 00 00       	jmp    801044d0 <procdump>
80100d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        input.buf[input.e++ % INPUT_BUF] = c;
80100d10:	c6 80 20 0f 11 80 0a 	movb   $0xa,-0x7feef0e0(%eax)
        consputc(c);
80100d17:	b8 0a 00 00 00       	mov    $0xa,%eax
80100d1c:	e8 5f fa ff ff       	call   80100780 <consputc>
80100d21:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100d26:	e9 4e ff ff ff       	jmp    80100c79 <consoleintr+0xf9>
80100d2b:	90                   	nop
80100d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100d30 <consoleinit>:

void
consoleinit(void)
{
80100d30:	55                   	push   %ebp
80100d31:	89 e5                	mov    %esp,%ebp
80100d33:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100d36:	68 52 7c 10 80       	push   $0x80107c52
80100d3b:	68 20 b5 10 80       	push   $0x8010b520
80100d40:	e8 3b 3b 00 00       	call   80104880 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100d45:	58                   	pop    %eax
80100d46:	5a                   	pop    %edx
80100d47:	6a 00                	push   $0x0
80100d49:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100d4b:	c7 05 6c 19 11 80 70 	movl   $0x80100970,0x8011196c
80100d52:	09 10 80 
  devsw[CONSOLE].read = consoleread;
80100d55:	c7 05 68 19 11 80 e0 	movl   $0x801005e0,0x80111968
80100d5c:	05 10 80 
  cons.locking = 1;
80100d5f:	c7 05 54 b5 10 80 01 	movl   $0x1,0x8010b554
80100d66:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100d69:	e8 42 1a 00 00       	call   801027b0 <ioapicenable>
}
80100d6e:	83 c4 10             	add    $0x10,%esp
80100d71:	c9                   	leave  
80100d72:	c3                   	ret    
80100d73:	66 90                	xchg   %ax,%ax
80100d75:	66 90                	xchg   %ax,%ax
80100d77:	66 90                	xchg   %ax,%ax
80100d79:	66 90                	xchg   %ax,%ax
80100d7b:	66 90                	xchg   %ax,%ax
80100d7d:	66 90                	xchg   %ax,%ax
80100d7f:	90                   	nop

80100d80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100d80:	55                   	push   %ebp
80100d81:	89 e5                	mov    %esp,%ebp
80100d83:	57                   	push   %edi
80100d84:	56                   	push   %esi
80100d85:	53                   	push   %ebx
80100d86:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100d8c:	e8 2f 2f 00 00       	call   80103cc0 <myproc>
80100d91:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
80100d97:	e8 e4 22 00 00       	call   80103080 <begin_op>

  if((ip = namei(path)) == 0){
80100d9c:	83 ec 0c             	sub    $0xc,%esp
80100d9f:	ff 75 08             	pushl  0x8(%ebp)
80100da2:	e8 99 15 00 00       	call   80102340 <namei>
80100da7:	83 c4 10             	add    $0x10,%esp
80100daa:	85 c0                	test   %eax,%eax
80100dac:	0f 84 91 01 00 00    	je     80100f43 <exec+0x1c3>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100db2:	83 ec 0c             	sub    $0xc,%esp
80100db5:	89 c3                	mov    %eax,%ebx
80100db7:	50                   	push   %eax
80100db8:	e8 23 0d 00 00       	call   80101ae0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100dbd:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100dc3:	6a 34                	push   $0x34
80100dc5:	6a 00                	push   $0x0
80100dc7:	50                   	push   %eax
80100dc8:	53                   	push   %ebx
80100dc9:	e8 f2 0f 00 00       	call   80101dc0 <readi>
80100dce:	83 c4 20             	add    $0x20,%esp
80100dd1:	83 f8 34             	cmp    $0x34,%eax
80100dd4:	74 22                	je     80100df8 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100dd6:	83 ec 0c             	sub    $0xc,%esp
80100dd9:	53                   	push   %ebx
80100dda:	e8 91 0f 00 00       	call   80101d70 <iunlockput>
    end_op();
80100ddf:	e8 0c 23 00 00       	call   801030f0 <end_op>
80100de4:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100dec:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100def:	5b                   	pop    %ebx
80100df0:	5e                   	pop    %esi
80100df1:	5f                   	pop    %edi
80100df2:	5d                   	pop    %ebp
80100df3:	c3                   	ret    
80100df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100df8:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100dff:	45 4c 46 
80100e02:	75 d2                	jne    80100dd6 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100e04:	e8 77 69 00 00       	call   80107780 <setupkvm>
80100e09:	85 c0                	test   %eax,%eax
80100e0b:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100e11:	74 c3                	je     80100dd6 <exec+0x56>
  sz = 0;
80100e13:	31 ff                	xor    %edi,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e15:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100e1c:	00 
80100e1d:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
80100e23:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100e29:	0f 84 8c 02 00 00    	je     801010bb <exec+0x33b>
80100e2f:	31 f6                	xor    %esi,%esi
80100e31:	eb 7f                	jmp    80100eb2 <exec+0x132>
80100e33:	90                   	nop
80100e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ph.type != ELF_PROG_LOAD)
80100e38:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100e3f:	75 63                	jne    80100ea4 <exec+0x124>
    if(ph.memsz < ph.filesz)
80100e41:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100e47:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100e4d:	0f 82 86 00 00 00    	jb     80100ed9 <exec+0x159>
80100e53:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100e59:	72 7e                	jb     80100ed9 <exec+0x159>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100e5b:	83 ec 04             	sub    $0x4,%esp
80100e5e:	50                   	push   %eax
80100e5f:	57                   	push   %edi
80100e60:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100e66:	e8 65 67 00 00       	call   801075d0 <allocuvm>
80100e6b:	83 c4 10             	add    $0x10,%esp
80100e6e:	85 c0                	test   %eax,%eax
80100e70:	89 c7                	mov    %eax,%edi
80100e72:	74 65                	je     80100ed9 <exec+0x159>
    if(ph.vaddr % PGSIZE != 0)
80100e74:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100e7a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100e7f:	75 58                	jne    80100ed9 <exec+0x159>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100e81:	83 ec 0c             	sub    $0xc,%esp
80100e84:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100e8a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100e90:	53                   	push   %ebx
80100e91:	50                   	push   %eax
80100e92:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100e98:	e8 73 66 00 00       	call   80107510 <loaduvm>
80100e9d:	83 c4 20             	add    $0x20,%esp
80100ea0:	85 c0                	test   %eax,%eax
80100ea2:	78 35                	js     80100ed9 <exec+0x159>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ea4:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100eab:	83 c6 01             	add    $0x1,%esi
80100eae:	39 f0                	cmp    %esi,%eax
80100eb0:	7e 3d                	jle    80100eef <exec+0x16f>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100eb2:	89 f0                	mov    %esi,%eax
80100eb4:	6a 20                	push   $0x20
80100eb6:	c1 e0 05             	shl    $0x5,%eax
80100eb9:	03 85 ec fe ff ff    	add    -0x114(%ebp),%eax
80100ebf:	50                   	push   %eax
80100ec0:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100ec6:	50                   	push   %eax
80100ec7:	53                   	push   %ebx
80100ec8:	e8 f3 0e 00 00       	call   80101dc0 <readi>
80100ecd:	83 c4 10             	add    $0x10,%esp
80100ed0:	83 f8 20             	cmp    $0x20,%eax
80100ed3:	0f 84 5f ff ff ff    	je     80100e38 <exec+0xb8>
    freevm(pgdir);
80100ed9:	83 ec 0c             	sub    $0xc,%esp
80100edc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100ee2:	e8 19 68 00 00       	call   80107700 <freevm>
80100ee7:	83 c4 10             	add    $0x10,%esp
80100eea:	e9 e7 fe ff ff       	jmp    80100dd6 <exec+0x56>
80100eef:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100ef5:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80100efb:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	53                   	push   %ebx
80100f05:	e8 66 0e 00 00       	call   80101d70 <iunlockput>
  end_op();
80100f0a:	e8 e1 21 00 00       	call   801030f0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100f0f:	83 c4 0c             	add    $0xc,%esp
80100f12:	56                   	push   %esi
80100f13:	57                   	push   %edi
80100f14:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100f1a:	e8 b1 66 00 00       	call   801075d0 <allocuvm>
80100f1f:	83 c4 10             	add    $0x10,%esp
80100f22:	85 c0                	test   %eax,%eax
80100f24:	89 c6                	mov    %eax,%esi
80100f26:	75 3a                	jne    80100f62 <exec+0x1e2>
    freevm(pgdir);
80100f28:	83 ec 0c             	sub    $0xc,%esp
80100f2b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100f31:	e8 ca 67 00 00       	call   80107700 <freevm>
80100f36:	83 c4 10             	add    $0x10,%esp
  return -1;
80100f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3e:	e9 a9 fe ff ff       	jmp    80100dec <exec+0x6c>
    end_op();
80100f43:	e8 a8 21 00 00       	call   801030f0 <end_op>
    cprintf("exec: fail\n");
80100f48:	83 ec 0c             	sub    $0xc,%esp
80100f4b:	68 6d 7c 10 80       	push   $0x80107c6d
80100f50:	e8 7b fa ff ff       	call   801009d0 <cprintf>
    return -1;
80100f55:	83 c4 10             	add    $0x10,%esp
80100f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f5d:	e9 8a fe ff ff       	jmp    80100dec <exec+0x6c>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100f62:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100f68:	83 ec 08             	sub    $0x8,%esp
  for(argc = 0; argv[argc]; argc++) {
80100f6b:	31 ff                	xor    %edi,%edi
80100f6d:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100f6f:	50                   	push   %eax
80100f70:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100f76:	e8 45 69 00 00       	call   801078c0 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f7e:	83 c4 10             	add    $0x10,%esp
80100f81:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100f87:	8b 00                	mov    (%eax),%eax
80100f89:	85 c0                	test   %eax,%eax
80100f8b:	74 70                	je     80100ffd <exec+0x27d>
80100f8d:	89 b5 ec fe ff ff    	mov    %esi,-0x114(%ebp)
80100f93:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100f99:	eb 0a                	jmp    80100fa5 <exec+0x225>
80100f9b:	90                   	nop
80100f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(argc >= MAXARG)
80100fa0:	83 ff 20             	cmp    $0x20,%edi
80100fa3:	74 83                	je     80100f28 <exec+0x1a8>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100fa5:	83 ec 0c             	sub    $0xc,%esp
80100fa8:	50                   	push   %eax
80100fa9:	e8 62 3d 00 00       	call   80104d10 <strlen>
80100fae:	f7 d0                	not    %eax
80100fb0:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fb5:	5a                   	pop    %edx
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100fb6:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100fb9:	ff 34 b8             	pushl  (%eax,%edi,4)
80100fbc:	e8 4f 3d 00 00       	call   80104d10 <strlen>
80100fc1:	83 c0 01             	add    $0x1,%eax
80100fc4:	50                   	push   %eax
80100fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100fc8:	ff 34 b8             	pushl  (%eax,%edi,4)
80100fcb:	53                   	push   %ebx
80100fcc:	56                   	push   %esi
80100fcd:	e8 2e 6b 00 00       	call   80107b00 <copyout>
80100fd2:	83 c4 20             	add    $0x20,%esp
80100fd5:	85 c0                	test   %eax,%eax
80100fd7:	0f 88 4b ff ff ff    	js     80100f28 <exec+0x1a8>
  for(argc = 0; argv[argc]; argc++) {
80100fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100fe0:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100fe7:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100fea:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100ff0:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100ff3:	85 c0                	test   %eax,%eax
80100ff5:	75 a9                	jne    80100fa0 <exec+0x220>
80100ff7:	8b b5 ec fe ff ff    	mov    -0x114(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ffd:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80101004:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80101006:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
8010100d:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80101011:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80101018:	ff ff ff 
  ustack[1] = argc;
8010101b:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101021:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80101023:	83 c0 0c             	add    $0xc,%eax
80101026:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101028:	50                   	push   %eax
80101029:	52                   	push   %edx
8010102a:	53                   	push   %ebx
8010102b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80101031:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80101037:	e8 c4 6a 00 00       	call   80107b00 <copyout>
8010103c:	83 c4 10             	add    $0x10,%esp
8010103f:	85 c0                	test   %eax,%eax
80101041:	0f 88 e1 fe ff ff    	js     80100f28 <exec+0x1a8>
  for(last=s=path; *s; s++)
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
8010104a:	0f b6 00             	movzbl (%eax),%eax
8010104d:	84 c0                	test   %al,%al
8010104f:	74 17                	je     80101068 <exec+0x2e8>
80101051:	8b 55 08             	mov    0x8(%ebp),%edx
80101054:	89 d1                	mov    %edx,%ecx
80101056:	83 c1 01             	add    $0x1,%ecx
80101059:	3c 2f                	cmp    $0x2f,%al
8010105b:	0f b6 01             	movzbl (%ecx),%eax
8010105e:	0f 44 d1             	cmove  %ecx,%edx
80101061:	84 c0                	test   %al,%al
80101063:	75 f1                	jne    80101056 <exec+0x2d6>
80101065:	89 55 08             	mov    %edx,0x8(%ebp)
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80101068:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
8010106e:	50                   	push   %eax
8010106f:	6a 10                	push   $0x10
80101071:	ff 75 08             	pushl  0x8(%ebp)
80101074:	89 f8                	mov    %edi,%eax
80101076:	83 c0 6c             	add    $0x6c,%eax
80101079:	50                   	push   %eax
8010107a:	e8 51 3c 00 00       	call   80104cd0 <safestrcpy>
  curproc->pgdir = pgdir;
8010107f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  oldpgdir = curproc->pgdir;
80101085:	89 f9                	mov    %edi,%ecx
80101087:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->tf->eip = elf.entry;  // main
8010108a:	8b 41 18             	mov    0x18(%ecx),%eax
  curproc->sz = sz;
8010108d:	89 31                	mov    %esi,(%ecx)
  curproc->pgdir = pgdir;
8010108f:	89 51 04             	mov    %edx,0x4(%ecx)
  curproc->tf->eip = elf.entry;  // main
80101092:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80101098:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
8010109b:	8b 41 18             	mov    0x18(%ecx),%eax
8010109e:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
801010a1:	89 0c 24             	mov    %ecx,(%esp)
801010a4:	e8 d7 62 00 00       	call   80107380 <switchuvm>
  freevm(oldpgdir);
801010a9:	89 3c 24             	mov    %edi,(%esp)
801010ac:	e8 4f 66 00 00       	call   80107700 <freevm>
  return 0;
801010b1:	83 c4 10             	add    $0x10,%esp
801010b4:	31 c0                	xor    %eax,%eax
801010b6:	e9 31 fd ff ff       	jmp    80100dec <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
801010bb:	be 00 20 00 00       	mov    $0x2000,%esi
801010c0:	e9 3c fe ff ff       	jmp    80100f01 <exec+0x181>
801010c5:	66 90                	xchg   %ax,%ax
801010c7:	66 90                	xchg   %ax,%ax
801010c9:	66 90                	xchg   %ax,%ax
801010cb:	66 90                	xchg   %ax,%ax
801010cd:	66 90                	xchg   %ax,%ax
801010cf:	90                   	nop

801010d0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010d0:	55                   	push   %ebp
801010d1:	89 e5                	mov    %esp,%ebp
801010d3:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
801010d6:	68 79 7c 10 80       	push   $0x80107c79
801010db:	68 c0 0f 11 80       	push   $0x80110fc0
801010e0:	e8 9b 37 00 00       	call   80104880 <initlock>
}
801010e5:	83 c4 10             	add    $0x10,%esp
801010e8:	c9                   	leave  
801010e9:	c3                   	ret    
801010ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801010f0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010f0:	55                   	push   %ebp
801010f1:	89 e5                	mov    %esp,%ebp
801010f3:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010f4:	bb f4 0f 11 80       	mov    $0x80110ff4,%ebx
{
801010f9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
801010fc:	68 c0 0f 11 80       	push   $0x80110fc0
80101101:	e8 6a 38 00 00       	call   80104970 <acquire>
80101106:	83 c4 10             	add    $0x10,%esp
80101109:	eb 10                	jmp    8010111b <filealloc+0x2b>
8010110b:	90                   	nop
8010110c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101110:	83 c3 18             	add    $0x18,%ebx
80101113:	81 fb 54 19 11 80    	cmp    $0x80111954,%ebx
80101119:	73 25                	jae    80101140 <filealloc+0x50>
    if(f->ref == 0){
8010111b:	8b 43 04             	mov    0x4(%ebx),%eax
8010111e:	85 c0                	test   %eax,%eax
80101120:	75 ee                	jne    80101110 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80101122:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80101125:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
8010112c:	68 c0 0f 11 80       	push   $0x80110fc0
80101131:	e8 5a 39 00 00       	call   80104a90 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80101136:	89 d8                	mov    %ebx,%eax
      return f;
80101138:	83 c4 10             	add    $0x10,%esp
}
8010113b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010113e:	c9                   	leave  
8010113f:	c3                   	ret    
  release(&ftable.lock);
80101140:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80101143:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80101145:	68 c0 0f 11 80       	push   $0x80110fc0
8010114a:	e8 41 39 00 00       	call   80104a90 <release>
}
8010114f:	89 d8                	mov    %ebx,%eax
  return 0;
80101151:	83 c4 10             	add    $0x10,%esp
}
80101154:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101157:	c9                   	leave  
80101158:	c3                   	ret    
80101159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101160 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101160:	55                   	push   %ebp
80101161:	89 e5                	mov    %esp,%ebp
80101163:	53                   	push   %ebx
80101164:	83 ec 10             	sub    $0x10,%esp
80101167:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
8010116a:	68 c0 0f 11 80       	push   $0x80110fc0
8010116f:	e8 fc 37 00 00       	call   80104970 <acquire>
  if(f->ref < 1)
80101174:	8b 43 04             	mov    0x4(%ebx),%eax
80101177:	83 c4 10             	add    $0x10,%esp
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7e 1a                	jle    80101198 <filedup+0x38>
    panic("filedup");
  f->ref++;
8010117e:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80101181:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80101184:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80101187:	68 c0 0f 11 80       	push   $0x80110fc0
8010118c:	e8 ff 38 00 00       	call   80104a90 <release>
  return f;
}
80101191:	89 d8                	mov    %ebx,%eax
80101193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101196:	c9                   	leave  
80101197:	c3                   	ret    
    panic("filedup");
80101198:	83 ec 0c             	sub    $0xc,%esp
8010119b:	68 80 7c 10 80       	push   $0x80107c80
801011a0:	e8 5b f5 ff ff       	call   80100700 <panic>
801011a5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801011a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801011b0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011b0:	55                   	push   %ebp
801011b1:	89 e5                	mov    %esp,%ebp
801011b3:	57                   	push   %edi
801011b4:	56                   	push   %esi
801011b5:	53                   	push   %ebx
801011b6:	83 ec 28             	sub    $0x28,%esp
801011b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
801011bc:	68 c0 0f 11 80       	push   $0x80110fc0
801011c1:	e8 aa 37 00 00       	call   80104970 <acquire>
  if(f->ref < 1)
801011c6:	8b 43 04             	mov    0x4(%ebx),%eax
801011c9:	83 c4 10             	add    $0x10,%esp
801011cc:	85 c0                	test   %eax,%eax
801011ce:	0f 8e 9b 00 00 00    	jle    8010126f <fileclose+0xbf>
    panic("fileclose");
  if(--f->ref > 0){
801011d4:	83 e8 01             	sub    $0x1,%eax
801011d7:	85 c0                	test   %eax,%eax
801011d9:	89 43 04             	mov    %eax,0x4(%ebx)
801011dc:	74 1a                	je     801011f8 <fileclose+0x48>
    release(&ftable.lock);
801011de:	c7 45 08 c0 0f 11 80 	movl   $0x80110fc0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
801011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011e8:	5b                   	pop    %ebx
801011e9:	5e                   	pop    %esi
801011ea:	5f                   	pop    %edi
801011eb:	5d                   	pop    %ebp
    release(&ftable.lock);
801011ec:	e9 9f 38 00 00       	jmp    80104a90 <release>
801011f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  ff = *f;
801011f8:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
801011fc:	8b 3b                	mov    (%ebx),%edi
  release(&ftable.lock);
801011fe:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80101201:	8b 73 0c             	mov    0xc(%ebx),%esi
  f->type = FD_NONE;
80101204:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
8010120a:	88 45 e7             	mov    %al,-0x19(%ebp)
8010120d:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80101210:	68 c0 0f 11 80       	push   $0x80110fc0
  ff = *f;
80101215:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80101218:	e8 73 38 00 00       	call   80104a90 <release>
  if(ff.type == FD_PIPE)
8010121d:	83 c4 10             	add    $0x10,%esp
80101220:	83 ff 01             	cmp    $0x1,%edi
80101223:	74 13                	je     80101238 <fileclose+0x88>
  else if(ff.type == FD_INODE){
80101225:	83 ff 02             	cmp    $0x2,%edi
80101228:	74 26                	je     80101250 <fileclose+0xa0>
}
8010122a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010122d:	5b                   	pop    %ebx
8010122e:	5e                   	pop    %esi
8010122f:	5f                   	pop    %edi
80101230:	5d                   	pop    %ebp
80101231:	c3                   	ret    
80101232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pipeclose(ff.pipe, ff.writable);
80101238:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
8010123c:	83 ec 08             	sub    $0x8,%esp
8010123f:	53                   	push   %ebx
80101240:	56                   	push   %esi
80101241:	e8 ea 25 00 00       	call   80103830 <pipeclose>
80101246:	83 c4 10             	add    $0x10,%esp
80101249:	eb df                	jmp    8010122a <fileclose+0x7a>
8010124b:	90                   	nop
8010124c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    begin_op();
80101250:	e8 2b 1e 00 00       	call   80103080 <begin_op>
    iput(ff.ip);
80101255:	83 ec 0c             	sub    $0xc,%esp
80101258:	ff 75 e0             	pushl  -0x20(%ebp)
8010125b:	e8 b0 09 00 00       	call   80101c10 <iput>
    end_op();
80101260:	83 c4 10             	add    $0x10,%esp
}
80101263:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101266:	5b                   	pop    %ebx
80101267:	5e                   	pop    %esi
80101268:	5f                   	pop    %edi
80101269:	5d                   	pop    %ebp
    end_op();
8010126a:	e9 81 1e 00 00       	jmp    801030f0 <end_op>
    panic("fileclose");
8010126f:	83 ec 0c             	sub    $0xc,%esp
80101272:	68 88 7c 10 80       	push   $0x80107c88
80101277:	e8 84 f4 ff ff       	call   80100700 <panic>
8010127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101280 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101280:	55                   	push   %ebp
80101281:	89 e5                	mov    %esp,%ebp
80101283:	53                   	push   %ebx
80101284:	83 ec 04             	sub    $0x4,%esp
80101287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
8010128a:	83 3b 02             	cmpl   $0x2,(%ebx)
8010128d:	75 31                	jne    801012c0 <filestat+0x40>
    ilock(f->ip);
8010128f:	83 ec 0c             	sub    $0xc,%esp
80101292:	ff 73 10             	pushl  0x10(%ebx)
80101295:	e8 46 08 00 00       	call   80101ae0 <ilock>
    stati(f->ip, st);
8010129a:	58                   	pop    %eax
8010129b:	5a                   	pop    %edx
8010129c:	ff 75 0c             	pushl  0xc(%ebp)
8010129f:	ff 73 10             	pushl  0x10(%ebx)
801012a2:	e8 e9 0a 00 00       	call   80101d90 <stati>
    iunlock(f->ip);
801012a7:	59                   	pop    %ecx
801012a8:	ff 73 10             	pushl  0x10(%ebx)
801012ab:	e8 10 09 00 00       	call   80101bc0 <iunlock>
    return 0;
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
801012b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801012b8:	c9                   	leave  
801012b9:	c3                   	ret    
801012ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return -1;
801012c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012c5:	eb ee                	jmp    801012b5 <filestat+0x35>
801012c7:	89 f6                	mov    %esi,%esi
801012c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801012d0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012d0:	55                   	push   %ebp
801012d1:	89 e5                	mov    %esp,%ebp
801012d3:	57                   	push   %edi
801012d4:	56                   	push   %esi
801012d5:	53                   	push   %ebx
801012d6:	83 ec 0c             	sub    $0xc,%esp
801012d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801012dc:	8b 75 0c             	mov    0xc(%ebp),%esi
801012df:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
801012e2:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
801012e6:	74 60                	je     80101348 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
801012e8:	8b 03                	mov    (%ebx),%eax
801012ea:	83 f8 01             	cmp    $0x1,%eax
801012ed:	74 41                	je     80101330 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
801012ef:	83 f8 02             	cmp    $0x2,%eax
801012f2:	75 5b                	jne    8010134f <fileread+0x7f>
    ilock(f->ip);
801012f4:	83 ec 0c             	sub    $0xc,%esp
801012f7:	ff 73 10             	pushl  0x10(%ebx)
801012fa:	e8 e1 07 00 00       	call   80101ae0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012ff:	57                   	push   %edi
80101300:	ff 73 14             	pushl  0x14(%ebx)
80101303:	56                   	push   %esi
80101304:	ff 73 10             	pushl  0x10(%ebx)
80101307:	e8 b4 0a 00 00       	call   80101dc0 <readi>
8010130c:	83 c4 20             	add    $0x20,%esp
8010130f:	85 c0                	test   %eax,%eax
80101311:	89 c6                	mov    %eax,%esi
80101313:	7e 03                	jle    80101318 <fileread+0x48>
      f->off += r;
80101315:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	ff 73 10             	pushl  0x10(%ebx)
8010131e:	e8 9d 08 00 00       	call   80101bc0 <iunlock>
    return r;
80101323:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101326:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101329:	89 f0                	mov    %esi,%eax
8010132b:	5b                   	pop    %ebx
8010132c:	5e                   	pop    %esi
8010132d:	5f                   	pop    %edi
8010132e:	5d                   	pop    %ebp
8010132f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80101330:	8b 43 0c             	mov    0xc(%ebx),%eax
80101333:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101336:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101339:	5b                   	pop    %ebx
8010133a:	5e                   	pop    %esi
8010133b:	5f                   	pop    %edi
8010133c:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
8010133d:	e9 9e 26 00 00       	jmp    801039e0 <piperead>
80101342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80101348:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010134d:	eb d7                	jmp    80101326 <fileread+0x56>
  panic("fileread");
8010134f:	83 ec 0c             	sub    $0xc,%esp
80101352:	68 92 7c 10 80       	push   $0x80107c92
80101357:	e8 a4 f3 ff ff       	call   80100700 <panic>
8010135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101360 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101360:	55                   	push   %ebp
80101361:	89 e5                	mov    %esp,%ebp
80101363:	57                   	push   %edi
80101364:	56                   	push   %esi
80101365:	53                   	push   %ebx
80101366:	83 ec 1c             	sub    $0x1c,%esp
80101369:	8b 75 08             	mov    0x8(%ebp),%esi
8010136c:	8b 45 0c             	mov    0xc(%ebp),%eax
  int r;

  if(f->writable == 0)
8010136f:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
{
80101373:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101376:	8b 45 10             	mov    0x10(%ebp),%eax
80101379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
8010137c:	0f 84 aa 00 00 00    	je     8010142c <filewrite+0xcc>
    return -1;
  if(f->type == FD_PIPE)
80101382:	8b 06                	mov    (%esi),%eax
80101384:	83 f8 01             	cmp    $0x1,%eax
80101387:	0f 84 c3 00 00 00    	je     80101450 <filewrite+0xf0>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010138d:	83 f8 02             	cmp    $0x2,%eax
80101390:	0f 85 d9 00 00 00    	jne    8010146f <filewrite+0x10f>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101399:	31 ff                	xor    %edi,%edi
    while(i < n){
8010139b:	85 c0                	test   %eax,%eax
8010139d:	7f 34                	jg     801013d3 <filewrite+0x73>
8010139f:	e9 9c 00 00 00       	jmp    80101440 <filewrite+0xe0>
801013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
801013a8:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
801013ab:	83 ec 0c             	sub    $0xc,%esp
801013ae:	ff 76 10             	pushl  0x10(%esi)
        f->off += r;
801013b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
801013b4:	e8 07 08 00 00       	call   80101bc0 <iunlock>
      end_op();
801013b9:	e8 32 1d 00 00       	call   801030f0 <end_op>
801013be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801013c1:	83 c4 10             	add    $0x10,%esp

      if(r < 0)
        break;
      if(r != n1)
801013c4:	39 c3                	cmp    %eax,%ebx
801013c6:	0f 85 96 00 00 00    	jne    80101462 <filewrite+0x102>
        panic("short filewrite");
      i += r;
801013cc:	01 df                	add    %ebx,%edi
    while(i < n){
801013ce:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801013d1:	7e 6d                	jle    80101440 <filewrite+0xe0>
      int n1 = n - i;
801013d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801013d6:	b8 00 06 00 00       	mov    $0x600,%eax
801013db:	29 fb                	sub    %edi,%ebx
801013dd:	81 fb 00 06 00 00    	cmp    $0x600,%ebx
801013e3:	0f 4f d8             	cmovg  %eax,%ebx
      begin_op();
801013e6:	e8 95 1c 00 00       	call   80103080 <begin_op>
      ilock(f->ip);
801013eb:	83 ec 0c             	sub    $0xc,%esp
801013ee:	ff 76 10             	pushl  0x10(%esi)
801013f1:	e8 ea 06 00 00       	call   80101ae0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801013f9:	53                   	push   %ebx
801013fa:	ff 76 14             	pushl  0x14(%esi)
801013fd:	01 f8                	add    %edi,%eax
801013ff:	50                   	push   %eax
80101400:	ff 76 10             	pushl  0x10(%esi)
80101403:	e8 b8 0a 00 00       	call   80101ec0 <writei>
80101408:	83 c4 20             	add    $0x20,%esp
8010140b:	85 c0                	test   %eax,%eax
8010140d:	7f 99                	jg     801013a8 <filewrite+0x48>
      iunlock(f->ip);
8010140f:	83 ec 0c             	sub    $0xc,%esp
80101412:	ff 76 10             	pushl  0x10(%esi)
80101415:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101418:	e8 a3 07 00 00       	call   80101bc0 <iunlock>
      end_op();
8010141d:	e8 ce 1c 00 00       	call   801030f0 <end_op>
      if(r < 0)
80101422:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101425:	83 c4 10             	add    $0x10,%esp
80101428:	85 c0                	test   %eax,%eax
8010142a:	74 98                	je     801013c4 <filewrite+0x64>
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
8010142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010142f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
}
80101434:	89 f8                	mov    %edi,%eax
80101436:	5b                   	pop    %ebx
80101437:	5e                   	pop    %esi
80101438:	5f                   	pop    %edi
80101439:	5d                   	pop    %ebp
8010143a:	c3                   	ret    
8010143b:	90                   	nop
8010143c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return i == n ? n : -1;
80101440:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101443:	75 e7                	jne    8010142c <filewrite+0xcc>
}
80101445:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101448:	89 f8                	mov    %edi,%eax
8010144a:	5b                   	pop    %ebx
8010144b:	5e                   	pop    %esi
8010144c:	5f                   	pop    %edi
8010144d:	5d                   	pop    %ebp
8010144e:	c3                   	ret    
8010144f:	90                   	nop
    return pipewrite(f->pipe, addr, n);
80101450:	8b 46 0c             	mov    0xc(%esi),%eax
80101453:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101456:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101459:	5b                   	pop    %ebx
8010145a:	5e                   	pop    %esi
8010145b:	5f                   	pop    %edi
8010145c:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
8010145d:	e9 6e 24 00 00       	jmp    801038d0 <pipewrite>
        panic("short filewrite");
80101462:	83 ec 0c             	sub    $0xc,%esp
80101465:	68 9b 7c 10 80       	push   $0x80107c9b
8010146a:	e8 91 f2 ff ff       	call   80100700 <panic>
  panic("filewrite");
8010146f:	83 ec 0c             	sub    $0xc,%esp
80101472:	68 a1 7c 10 80       	push   $0x80107ca1
80101477:	e8 84 f2 ff ff       	call   80100700 <panic>
8010147c:	66 90                	xchg   %ax,%ax
8010147e:	66 90                	xchg   %ax,%ax

80101480 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101480:	55                   	push   %ebp
80101481:	89 e5                	mov    %esp,%ebp
80101483:	57                   	push   %edi
80101484:	56                   	push   %esi
80101485:	53                   	push   %ebx
80101486:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;
  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101489:	8b 0d c0 19 11 80    	mov    0x801119c0,%ecx
{
8010148f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101492:	85 c9                	test   %ecx,%ecx
80101494:	0f 84 81 00 00 00    	je     8010151b <balloc+0x9b>
8010149a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
801014a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
801014a4:	83 ec 08             	sub    $0x8,%esp
801014a7:	89 d8                	mov    %ebx,%eax
801014a9:	c1 f8 0c             	sar    $0xc,%eax
801014ac:	03 05 d8 19 11 80    	add    0x801119d8,%eax
801014b2:	50                   	push   %eax
801014b3:	ff 75 dc             	pushl  -0x24(%ebp)
801014b6:	e8 25 ef ff ff       	call   801003e0 <bread>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014bb:	8b 15 c0 19 11 80    	mov    0x801119c0,%edx
801014c1:	83 c4 10             	add    $0x10,%esp
801014c4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801014c7:	31 d2                	xor    %edx,%edx
801014c9:	eb 2d                	jmp    801014f8 <balloc+0x78>
801014cb:	90                   	nop
801014cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      m = 1 << (bi % 8);
801014d0:	89 d1                	mov    %edx,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d2:	89 d6                	mov    %edx,%esi
      m = 1 << (bi % 8);
801014d4:	bf 01 00 00 00       	mov    $0x1,%edi
801014d9:	83 e1 07             	and    $0x7,%ecx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014dc:	c1 fe 03             	sar    $0x3,%esi
      m = 1 << (bi % 8);
801014df:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014e1:	0f b6 4c 30 5c       	movzbl 0x5c(%eax,%esi,1),%ecx
801014e6:	85 f9                	test   %edi,%ecx
801014e8:	74 46                	je     80101530 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014ea:	83 c2 01             	add    $0x1,%edx
801014ed:	83 c3 01             	add    $0x1,%ebx
801014f0:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
801014f6:	74 05                	je     801014fd <balloc+0x7d>
801014f8:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
801014fb:	77 d3                	ja     801014d0 <balloc+0x50>
        bzero(dev, b + bi);
        end_op();
        return b + bi;
      }
    }
    brelse(bp);
801014fd:	83 ec 0c             	sub    $0xc,%esp
80101500:	50                   	push   %eax
80101501:	e8 5a ef ff ff       	call   80100460 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101506:	81 45 e0 00 10 00 00 	addl   $0x1000,-0x20(%ebp)
8010150d:	83 c4 10             	add    $0x10,%esp
80101510:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101513:	39 05 c0 19 11 80    	cmp    %eax,0x801119c0
80101519:	77 86                	ja     801014a1 <balloc+0x21>
  }
  panic("balloc: out of blocks");
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	68 ab 7c 10 80       	push   $0x80107cab
80101523:	e8 d8 f1 ff ff       	call   80100700 <panic>
80101528:	90                   	nop
80101529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101530:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        begin_op();
80101533:	e8 48 1b 00 00       	call   80103080 <begin_op>
        bp->data[bi/8] |= m;  // Mark block in use.
80101538:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010153b:	89 f8                	mov    %edi,%eax
        log_write(bp);
8010153d:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101540:	08 44 32 5c          	or     %al,0x5c(%edx,%esi,1)
        log_write(bp);
80101544:	52                   	push   %edx
80101545:	e8 06 1d 00 00       	call   80103250 <log_write>
        brelse(bp);
8010154a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010154d:	89 14 24             	mov    %edx,(%esp)
80101550:	e8 0b ef ff ff       	call   80100460 <brelse>
  bp = bread(dev, bno);
80101555:	58                   	pop    %eax
80101556:	5a                   	pop    %edx
80101557:	53                   	push   %ebx
80101558:	ff 75 dc             	pushl  -0x24(%ebp)
8010155b:	e8 80 ee ff ff       	call   801003e0 <bread>
80101560:	89 c6                	mov    %eax,%esi
  memset(bp->data, 0, BSIZE);
80101562:	8d 40 5c             	lea    0x5c(%eax),%eax
80101565:	83 c4 0c             	add    $0xc,%esp
80101568:	68 00 02 00 00       	push   $0x200
8010156d:	6a 00                	push   $0x0
8010156f:	50                   	push   %eax
80101570:	e8 7b 35 00 00       	call   80104af0 <memset>
  log_write(bp);
80101575:	89 34 24             	mov    %esi,(%esp)
80101578:	e8 d3 1c 00 00       	call   80103250 <log_write>
  brelse(bp);
8010157d:	89 34 24             	mov    %esi,(%esp)
80101580:	e8 db ee ff ff       	call   80100460 <brelse>
        end_op();
80101585:	e8 66 1b 00 00       	call   801030f0 <end_op>
}
8010158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010158d:	89 d8                	mov    %ebx,%eax
8010158f:	5b                   	pop    %ebx
80101590:	5e                   	pop    %esi
80101591:	5f                   	pop    %edi
80101592:	5d                   	pop    %ebp
80101593:	c3                   	ret    
80101594:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010159a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801015a0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801015a0:	55                   	push   %ebp
801015a1:	89 e5                	mov    %esp,%ebp
801015a3:	57                   	push   %edi
801015a4:	56                   	push   %esi
801015a5:	53                   	push   %ebx
801015a6:	89 c7                	mov    %eax,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
801015a8:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801015aa:	bb 14 1a 11 80       	mov    $0x80111a14,%ebx
{
801015af:	83 ec 28             	sub    $0x28,%esp
801015b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
801015b5:	68 e0 19 11 80       	push   $0x801119e0
801015ba:	e8 b1 33 00 00       	call   80104970 <acquire>
801015bf:	83 c4 10             	add    $0x10,%esp
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801015c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801015c5:	eb 17                	jmp    801015de <iget+0x3e>
801015c7:	89 f6                	mov    %esi,%esi
801015c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801015d0:	81 c3 90 00 00 00    	add    $0x90,%ebx
801015d6:	81 fb 34 36 11 80    	cmp    $0x80113634,%ebx
801015dc:	73 22                	jae    80101600 <iget+0x60>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801015de:	8b 4b 08             	mov    0x8(%ebx),%ecx
801015e1:	85 c9                	test   %ecx,%ecx
801015e3:	7e 04                	jle    801015e9 <iget+0x49>
801015e5:	39 3b                	cmp    %edi,(%ebx)
801015e7:	74 4f                	je     80101638 <iget+0x98>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801015e9:	85 f6                	test   %esi,%esi
801015eb:	75 e3                	jne    801015d0 <iget+0x30>
801015ed:	85 c9                	test   %ecx,%ecx
801015ef:	0f 44 f3             	cmove  %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801015f2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801015f8:	81 fb 34 36 11 80    	cmp    $0x80113634,%ebx
801015fe:	72 de                	jb     801015de <iget+0x3e>
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101600:	85 f6                	test   %esi,%esi
80101602:	74 5b                	je     8010165f <iget+0xbf>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
80101604:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
80101607:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
80101609:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
8010160c:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101613:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010161a:	68 e0 19 11 80       	push   $0x801119e0
8010161f:	e8 6c 34 00 00       	call   80104a90 <release>

  return ip;
80101624:	83 c4 10             	add    $0x10,%esp
}
80101627:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010162a:	89 f0                	mov    %esi,%eax
8010162c:	5b                   	pop    %ebx
8010162d:	5e                   	pop    %esi
8010162e:	5f                   	pop    %edi
8010162f:	5d                   	pop    %ebp
80101630:	c3                   	ret    
80101631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101638:	39 53 04             	cmp    %edx,0x4(%ebx)
8010163b:	75 ac                	jne    801015e9 <iget+0x49>
      release(&icache.lock);
8010163d:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101640:	83 c1 01             	add    $0x1,%ecx
      return ip;
80101643:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
80101645:	68 e0 19 11 80       	push   $0x801119e0
      ip->ref++;
8010164a:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
8010164d:	e8 3e 34 00 00       	call   80104a90 <release>
      return ip;
80101652:	83 c4 10             	add    $0x10,%esp
}
80101655:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101658:	89 f0                	mov    %esi,%eax
8010165a:	5b                   	pop    %ebx
8010165b:	5e                   	pop    %esi
8010165c:	5f                   	pop    %edi
8010165d:	5d                   	pop    %ebp
8010165e:	c3                   	ret    
    panic("iget: no inodes");
8010165f:	83 ec 0c             	sub    $0xc,%esp
80101662:	68 c1 7c 10 80       	push   $0x80107cc1
80101667:	e8 94 f0 ff ff       	call   80100700 <panic>
8010166c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101670 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101670:	55                   	push   %ebp
80101671:	89 e5                	mov    %esp,%ebp
80101673:	57                   	push   %edi
80101674:	56                   	push   %esi
80101675:	53                   	push   %ebx
80101676:	89 c6                	mov    %eax,%esi
80101678:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010167b:	83 fa 0b             	cmp    $0xb,%edx
8010167e:	77 18                	ja     80101698 <bmap+0x28>
80101680:	8d 3c 90             	lea    (%eax,%edx,4),%edi
    if((addr = ip->addrs[bn]) == 0)
80101683:	8b 5f 5c             	mov    0x5c(%edi),%ebx
80101686:	85 db                	test   %ebx,%ebx
80101688:	74 76                	je     80101700 <bmap+0x90>
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
}
8010168a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010168d:	89 d8                	mov    %ebx,%eax
8010168f:	5b                   	pop    %ebx
80101690:	5e                   	pop    %esi
80101691:	5f                   	pop    %edi
80101692:	5d                   	pop    %ebp
80101693:	c3                   	ret    
80101694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bn -= NDIRECT;
80101698:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010169b:	83 fb 7f             	cmp    $0x7f,%ebx
8010169e:	0f 87 90 00 00 00    	ja     80101734 <bmap+0xc4>
    if((addr = ip->addrs[NDIRECT]) == 0)
801016a4:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
801016aa:	8b 00                	mov    (%eax),%eax
801016ac:	85 d2                	test   %edx,%edx
801016ae:	74 70                	je     80101720 <bmap+0xb0>
    bp = bread(ip->dev, addr);
801016b0:	83 ec 08             	sub    $0x8,%esp
801016b3:	52                   	push   %edx
801016b4:	50                   	push   %eax
801016b5:	e8 26 ed ff ff       	call   801003e0 <bread>
    if((addr = a[bn]) == 0){
801016ba:	8d 54 98 5c          	lea    0x5c(%eax,%ebx,4),%edx
801016be:	83 c4 10             	add    $0x10,%esp
    bp = bread(ip->dev, addr);
801016c1:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
801016c3:	8b 1a                	mov    (%edx),%ebx
801016c5:	85 db                	test   %ebx,%ebx
801016c7:	75 1d                	jne    801016e6 <bmap+0x76>
      a[bn] = addr = balloc(ip->dev);
801016c9:	8b 06                	mov    (%esi),%eax
801016cb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801016ce:	e8 ad fd ff ff       	call   80101480 <balloc>
801016d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
801016d6:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801016d9:	89 c3                	mov    %eax,%ebx
801016db:	89 02                	mov    %eax,(%edx)
      log_write(bp);
801016dd:	57                   	push   %edi
801016de:	e8 6d 1b 00 00       	call   80103250 <log_write>
801016e3:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801016e6:	83 ec 0c             	sub    $0xc,%esp
801016e9:	57                   	push   %edi
801016ea:	e8 71 ed ff ff       	call   80100460 <brelse>
801016ef:	83 c4 10             	add    $0x10,%esp
}
801016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016f5:	89 d8                	mov    %ebx,%eax
801016f7:	5b                   	pop    %ebx
801016f8:	5e                   	pop    %esi
801016f9:	5f                   	pop    %edi
801016fa:	5d                   	pop    %ebp
801016fb:	c3                   	ret    
801016fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ip->addrs[bn] = addr = balloc(ip->dev);
80101700:	8b 00                	mov    (%eax),%eax
80101702:	e8 79 fd ff ff       	call   80101480 <balloc>
80101707:	89 47 5c             	mov    %eax,0x5c(%edi)
}
8010170a:	8d 65 f4             	lea    -0xc(%ebp),%esp
      ip->addrs[bn] = addr = balloc(ip->dev);
8010170d:	89 c3                	mov    %eax,%ebx
}
8010170f:	89 d8                	mov    %ebx,%eax
80101711:	5b                   	pop    %ebx
80101712:	5e                   	pop    %esi
80101713:	5f                   	pop    %edi
80101714:	5d                   	pop    %ebp
80101715:	c3                   	ret    
80101716:	8d 76 00             	lea    0x0(%esi),%esi
80101719:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101720:	e8 5b fd ff ff       	call   80101480 <balloc>
80101725:	89 c2                	mov    %eax,%edx
80101727:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010172d:	8b 06                	mov    (%esi),%eax
8010172f:	e9 7c ff ff ff       	jmp    801016b0 <bmap+0x40>
  panic("bmap: out of range");
80101734:	83 ec 0c             	sub    $0xc,%esp
80101737:	68 d1 7c 10 80       	push   $0x80107cd1
8010173c:	e8 bf ef ff ff       	call   80100700 <panic>
80101741:	eb 0d                	jmp    80101750 <readsb>
80101743:	90                   	nop
80101744:	90                   	nop
80101745:	90                   	nop
80101746:	90                   	nop
80101747:	90                   	nop
80101748:	90                   	nop
80101749:	90                   	nop
8010174a:	90                   	nop
8010174b:	90                   	nop
8010174c:	90                   	nop
8010174d:	90                   	nop
8010174e:	90                   	nop
8010174f:	90                   	nop

80101750 <readsb>:
{
80101750:	55                   	push   %ebp
80101751:	89 e5                	mov    %esp,%ebp
80101753:	56                   	push   %esi
80101754:	53                   	push   %ebx
80101755:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101758:	83 ec 08             	sub    $0x8,%esp
8010175b:	6a 01                	push   $0x1
8010175d:	ff 75 08             	pushl  0x8(%ebp)
80101760:	e8 7b ec ff ff       	call   801003e0 <bread>
80101765:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101767:	8d 40 5c             	lea    0x5c(%eax),%eax
8010176a:	83 c4 0c             	add    $0xc,%esp
8010176d:	6a 1c                	push   $0x1c
8010176f:	50                   	push   %eax
80101770:	56                   	push   %esi
80101771:	e8 2a 34 00 00       	call   80104ba0 <memmove>
  brelse(bp);
80101776:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101779:	83 c4 10             	add    $0x10,%esp
}
8010177c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010177f:	5b                   	pop    %ebx
80101780:	5e                   	pop    %esi
80101781:	5d                   	pop    %ebp
  brelse(bp);
80101782:	e9 d9 ec ff ff       	jmp    80100460 <brelse>
80101787:	89 f6                	mov    %esi,%esi
80101789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101790 <bfree>:
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	56                   	push   %esi
80101794:	53                   	push   %ebx
80101795:	89 d3                	mov    %edx,%ebx
80101797:	89 c6                	mov    %eax,%esi
  readsb(dev, &sb);
80101799:	83 ec 08             	sub    $0x8,%esp
8010179c:	68 c0 19 11 80       	push   $0x801119c0
801017a1:	50                   	push   %eax
801017a2:	e8 a9 ff ff ff       	call   80101750 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801017a7:	58                   	pop    %eax
801017a8:	5a                   	pop    %edx
801017a9:	89 da                	mov    %ebx,%edx
801017ab:	c1 ea 0c             	shr    $0xc,%edx
801017ae:	03 15 d8 19 11 80    	add    0x801119d8,%edx
801017b4:	52                   	push   %edx
801017b5:	56                   	push   %esi
801017b6:	e8 25 ec ff ff       	call   801003e0 <bread>
  m = 1 << (bi % 8);
801017bb:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801017bd:	c1 fb 03             	sar    $0x3,%ebx
  m = 1 << (bi % 8);
801017c0:	ba 01 00 00 00       	mov    $0x1,%edx
801017c5:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
801017c8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801017ce:	83 c4 10             	add    $0x10,%esp
  m = 1 << (bi % 8);
801017d1:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
801017d3:	0f b6 4c 18 5c       	movzbl 0x5c(%eax,%ebx,1),%ecx
801017d8:	85 d1                	test   %edx,%ecx
801017da:	74 25                	je     80101801 <bfree+0x71>
  bp->data[bi/8] &= ~m;
801017dc:	f7 d2                	not    %edx
801017de:	89 c6                	mov    %eax,%esi
  bwrite(bp);
801017e0:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
801017e3:	21 ca                	and    %ecx,%edx
801017e5:	88 54 1e 5c          	mov    %dl,0x5c(%esi,%ebx,1)
  bwrite(bp);
801017e9:	56                   	push   %esi
801017ea:	e8 31 ec ff ff       	call   80100420 <bwrite>
  brelse(bp);
801017ef:	89 34 24             	mov    %esi,(%esp)
801017f2:	e8 69 ec ff ff       	call   80100460 <brelse>
}
801017f7:	83 c4 10             	add    $0x10,%esp
801017fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801017fd:	5b                   	pop    %ebx
801017fe:	5e                   	pop    %esi
801017ff:	5d                   	pop    %ebp
80101800:	c3                   	ret    
    panic("freeing free block");
80101801:	83 ec 0c             	sub    $0xc,%esp
80101804:	68 e4 7c 10 80       	push   $0x80107ce4
80101809:	e8 f2 ee ff ff       	call   80100700 <panic>
8010180e:	66 90                	xchg   %ax,%ax

80101810 <balloc_page>:
{
80101810:	55                   	push   %ebp
80101811:	89 e5                	mov    %esp,%ebp
80101813:	57                   	push   %edi
80101814:	56                   	push   %esi
80101815:	53                   	push   %ebx
  for(int i=0;i<8;i++)
80101816:	31 f6                	xor    %esi,%esi
  int indexNCB=-1;     //pointer for above array, keeps track till where it is filled
80101818:	bf ff ff ff ff       	mov    $0xffffffff,%edi
{
8010181d:	81 ec 8c 1a 06 00    	sub    $0x61a8c,%esp
80101823:	90                   	nop
80101824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      alloc_b[indexNCB] = balloc(dev);
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
      indexNCB++;
8010182b:	8d 5f 01             	lea    0x1(%edi),%ebx
      alloc_b[indexNCB] = balloc(dev);
8010182e:	e8 4d fc ff ff       	call   80101480 <balloc>
      if(i>0)
80101833:	85 f6                	test   %esi,%esi
      alloc_b[indexNCB] = balloc(dev);
80101835:	89 84 9d 68 e5 f9 ff 	mov    %eax,-0x61a98(%ebp,%ebx,4)
      if(i>0)
8010183c:	74 0c                	je     8010184a <balloc_page+0x3a>
          if((alloc_b[indexNCB]-alloc_b[indexNCB-1])!=1)  //this allocated block in non consecutive
8010183e:	2b 84 9d 64 e5 f9 ff 	sub    -0x61a9c(%ebp,%ebx,4),%eax
80101845:	83 f8 01             	cmp    $0x1,%eax
80101848:	74 0e                	je     80101858 <balloc_page+0x48>
  for(int i=0;i<8;i++)
8010184a:	be 01 00 00 00       	mov    $0x1,%esi
8010184f:	89 df                	mov    %ebx,%edi
80101851:	eb d5                	jmp    80101828 <balloc_page+0x18>
80101853:	90                   	nop
80101854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101858:	83 c6 01             	add    $0x1,%esi
8010185b:	83 fe 08             	cmp    $0x8,%esi
8010185e:	75 ef                	jne    8010184f <balloc_page+0x3f>
    for(int i=0;i<=indexNCB-8;i++)
80101860:	8d 77 fa             	lea    -0x6(%edi),%esi
80101863:	85 f6                	test   %esi,%esi
80101865:	7e 24                	jle    8010188b <balloc_page+0x7b>
80101867:	8d 9d 68 e5 f9 ff    	lea    -0x61a98(%ebp),%ebx
8010186d:	8d bc bd 50 e5 f9 ff 	lea    -0x61ab0(%ebp,%edi,4),%edi
80101874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      bfree(ROOTDEV,alloc_b[i]);    //free unnecesarily allocated blocks
80101878:	8b 13                	mov    (%ebx),%edx
8010187a:	b8 01 00 00 00       	mov    $0x1,%eax
8010187f:	83 c3 04             	add    $0x4,%ebx
80101882:	e8 09 ff ff ff       	call   80101790 <bfree>
    for(int i=0;i<=indexNCB-8;i++)
80101887:	39 fb                	cmp    %edi,%ebx
80101889:	75 ed                	jne    80101878 <balloc_page+0x68>
	  return alloc_b[indexNCB-7];  //return last 8 blocks (address of 1st block among them)
8010188b:	8b 84 b5 68 e5 f9 ff 	mov    -0x61a98(%ebp,%esi,4),%eax
    numallocblocks++;
80101892:	83 05 5c b5 10 80 01 	addl   $0x1,0x8010b55c
}
80101899:	81 c4 8c 1a 06 00    	add    $0x61a8c,%esp
8010189f:	5b                   	pop    %ebx
801018a0:	5e                   	pop    %esi
801018a1:	5f                   	pop    %edi
801018a2:	5d                   	pop    %ebp
801018a3:	c3                   	ret    
801018a4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801018aa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801018b0 <bfree_page>:
{ 
801018b0:	55                   	push   %ebp
801018b1:	89 e5                	mov    %esp,%ebp
801018b3:	56                   	push   %esi
801018b4:	53                   	push   %ebx
801018b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801018b8:	8d 73 08             	lea    0x8(%ebx),%esi
801018bb:	90                   	nop
801018bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bfree(ROOTDEV,b+i);
801018c0:	89 da                	mov    %ebx,%edx
801018c2:	b8 01 00 00 00       	mov    $0x1,%eax
801018c7:	83 c3 01             	add    $0x1,%ebx
801018ca:	e8 c1 fe ff ff       	call   80101790 <bfree>
  for(uint i=0;i<8;i++){
801018cf:	39 f3                	cmp    %esi,%ebx
801018d1:	75 ed                	jne    801018c0 <bfree_page+0x10>
}
801018d3:	5b                   	pop    %ebx
  numallocblocks-=1;
801018d4:	83 2d 5c b5 10 80 01 	subl   $0x1,0x8010b55c
}
801018db:	5e                   	pop    %esi
801018dc:	5d                   	pop    %ebp
801018dd:	c3                   	ret    
801018de:	66 90                	xchg   %ax,%ax

801018e0 <iinit>:
{
801018e0:	55                   	push   %ebp
801018e1:	89 e5                	mov    %esp,%ebp
801018e3:	53                   	push   %ebx
801018e4:	bb 20 1a 11 80       	mov    $0x80111a20,%ebx
801018e9:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801018ec:	68 f7 7c 10 80       	push   $0x80107cf7
801018f1:	68 e0 19 11 80       	push   $0x801119e0
801018f6:	e8 85 2f 00 00       	call   80104880 <initlock>
801018fb:	83 c4 10             	add    $0x10,%esp
801018fe:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
80101900:	83 ec 08             	sub    $0x8,%esp
80101903:	68 fe 7c 10 80       	push   $0x80107cfe
80101908:	53                   	push   %ebx
80101909:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010190f:	e8 5c 2e 00 00       	call   80104770 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101914:	83 c4 10             	add    $0x10,%esp
80101917:	81 fb 40 36 11 80    	cmp    $0x80113640,%ebx
8010191d:	75 e1                	jne    80101900 <iinit+0x20>
  readsb(dev, &sb);
8010191f:	83 ec 08             	sub    $0x8,%esp
80101922:	68 c0 19 11 80       	push   $0x801119c0
80101927:	ff 75 08             	pushl  0x8(%ebp)
8010192a:	e8 21 fe ff ff       	call   80101750 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
8010192f:	ff 35 d8 19 11 80    	pushl  0x801119d8
80101935:	ff 35 d4 19 11 80    	pushl  0x801119d4
8010193b:	ff 35 d0 19 11 80    	pushl  0x801119d0
80101941:	ff 35 cc 19 11 80    	pushl  0x801119cc
80101947:	ff 35 c8 19 11 80    	pushl  0x801119c8
8010194d:	ff 35 c4 19 11 80    	pushl  0x801119c4
80101953:	ff 35 c0 19 11 80    	pushl  0x801119c0
80101959:	68 64 7d 10 80       	push   $0x80107d64
8010195e:	e8 6d f0 ff ff       	call   801009d0 <cprintf>
}
80101963:	83 c4 30             	add    $0x30,%esp
80101966:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101969:	c9                   	leave  
8010196a:	c3                   	ret    
8010196b:	90                   	nop
8010196c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101970 <ialloc>:
{
80101970:	55                   	push   %ebp
80101971:	89 e5                	mov    %esp,%ebp
80101973:	57                   	push   %edi
80101974:	56                   	push   %esi
80101975:	53                   	push   %ebx
80101976:	83 ec 1c             	sub    $0x1c,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101979:	83 3d c8 19 11 80 01 	cmpl   $0x1,0x801119c8
{
80101980:	8b 45 0c             	mov    0xc(%ebp),%eax
80101983:	8b 75 08             	mov    0x8(%ebp),%esi
80101986:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101989:	0f 86 91 00 00 00    	jbe    80101a20 <ialloc+0xb0>
8010198f:	bb 01 00 00 00       	mov    $0x1,%ebx
80101994:	eb 21                	jmp    801019b7 <ialloc+0x47>
80101996:	8d 76 00             	lea    0x0(%esi),%esi
80101999:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    brelse(bp);
801019a0:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801019a3:	83 c3 01             	add    $0x1,%ebx
    brelse(bp);
801019a6:	57                   	push   %edi
801019a7:	e8 b4 ea ff ff       	call   80100460 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801019ac:	83 c4 10             	add    $0x10,%esp
801019af:	39 1d c8 19 11 80    	cmp    %ebx,0x801119c8
801019b5:	76 69                	jbe    80101a20 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
801019b7:	89 d8                	mov    %ebx,%eax
801019b9:	83 ec 08             	sub    $0x8,%esp
801019bc:	c1 e8 03             	shr    $0x3,%eax
801019bf:	03 05 d4 19 11 80    	add    0x801119d4,%eax
801019c5:	50                   	push   %eax
801019c6:	56                   	push   %esi
801019c7:	e8 14 ea ff ff       	call   801003e0 <bread>
801019cc:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
801019ce:	89 d8                	mov    %ebx,%eax
    if(dip->type == 0){  // a free inode
801019d0:	83 c4 10             	add    $0x10,%esp
    dip = (struct dinode*)bp->data + inum%IPB;
801019d3:	83 e0 07             	and    $0x7,%eax
801019d6:	c1 e0 06             	shl    $0x6,%eax
801019d9:	8d 4c 07 5c          	lea    0x5c(%edi,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
801019dd:	66 83 39 00          	cmpw   $0x0,(%ecx)
801019e1:	75 bd                	jne    801019a0 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801019e3:	83 ec 04             	sub    $0x4,%esp
801019e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801019e9:	6a 40                	push   $0x40
801019eb:	6a 00                	push   $0x0
801019ed:	51                   	push   %ecx
801019ee:	e8 fd 30 00 00       	call   80104af0 <memset>
      dip->type = type;
801019f3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801019f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801019fa:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801019fd:	89 3c 24             	mov    %edi,(%esp)
80101a00:	e8 4b 18 00 00       	call   80103250 <log_write>
      brelse(bp);
80101a05:	89 3c 24             	mov    %edi,(%esp)
80101a08:	e8 53 ea ff ff       	call   80100460 <brelse>
      return iget(dev, inum);
80101a0d:	83 c4 10             	add    $0x10,%esp
}
80101a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101a13:	89 da                	mov    %ebx,%edx
80101a15:	89 f0                	mov    %esi,%eax
}
80101a17:	5b                   	pop    %ebx
80101a18:	5e                   	pop    %esi
80101a19:	5f                   	pop    %edi
80101a1a:	5d                   	pop    %ebp
      return iget(dev, inum);
80101a1b:	e9 80 fb ff ff       	jmp    801015a0 <iget>
  panic("ialloc: no inodes");
80101a20:	83 ec 0c             	sub    $0xc,%esp
80101a23:	68 04 7d 10 80       	push   $0x80107d04
80101a28:	e8 d3 ec ff ff       	call   80100700 <panic>
80101a2d:	8d 76 00             	lea    0x0(%esi),%esi

80101a30 <iupdate>:
{
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	56                   	push   %esi
80101a34:	53                   	push   %ebx
80101a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a38:	83 ec 08             	sub    $0x8,%esp
80101a3b:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a3e:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a41:	c1 e8 03             	shr    $0x3,%eax
80101a44:	03 05 d4 19 11 80    	add    0x801119d4,%eax
80101a4a:	50                   	push   %eax
80101a4b:	ff 73 a4             	pushl  -0x5c(%ebx)
80101a4e:	e8 8d e9 ff ff       	call   801003e0 <bread>
80101a53:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a55:	8b 43 a8             	mov    -0x58(%ebx),%eax
  dip->type = ip->type;
80101a58:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a5c:	83 c4 0c             	add    $0xc,%esp
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5f:	83 e0 07             	and    $0x7,%eax
80101a62:	c1 e0 06             	shl    $0x6,%eax
80101a65:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101a69:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101a6c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a70:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101a73:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101a77:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
80101a7b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
80101a7f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101a83:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101a87:	8b 53 fc             	mov    -0x4(%ebx),%edx
80101a8a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101a8d:	6a 34                	push   $0x34
80101a8f:	53                   	push   %ebx
80101a90:	50                   	push   %eax
80101a91:	e8 0a 31 00 00       	call   80104ba0 <memmove>
  log_write(bp);
80101a96:	89 34 24             	mov    %esi,(%esp)
80101a99:	e8 b2 17 00 00       	call   80103250 <log_write>
  brelse(bp);
80101a9e:	89 75 08             	mov    %esi,0x8(%ebp)
80101aa1:	83 c4 10             	add    $0x10,%esp
}
80101aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101aa7:	5b                   	pop    %ebx
80101aa8:	5e                   	pop    %esi
80101aa9:	5d                   	pop    %ebp
  brelse(bp);
80101aaa:	e9 b1 e9 ff ff       	jmp    80100460 <brelse>
80101aaf:	90                   	nop

80101ab0 <idup>:
{
80101ab0:	55                   	push   %ebp
80101ab1:	89 e5                	mov    %esp,%ebp
80101ab3:	53                   	push   %ebx
80101ab4:	83 ec 10             	sub    $0x10,%esp
80101ab7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101aba:	68 e0 19 11 80       	push   $0x801119e0
80101abf:	e8 ac 2e 00 00       	call   80104970 <acquire>
  ip->ref++;
80101ac4:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101ac8:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101acf:	e8 bc 2f 00 00       	call   80104a90 <release>
}
80101ad4:	89 d8                	mov    %ebx,%eax
80101ad6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ad9:	c9                   	leave  
80101ada:	c3                   	ret    
80101adb:	90                   	nop
80101adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101ae0 <ilock>:
{
80101ae0:	55                   	push   %ebp
80101ae1:	89 e5                	mov    %esp,%ebp
80101ae3:	56                   	push   %esi
80101ae4:	53                   	push   %ebx
80101ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101ae8:	85 db                	test   %ebx,%ebx
80101aea:	0f 84 b7 00 00 00    	je     80101ba7 <ilock+0xc7>
80101af0:	8b 53 08             	mov    0x8(%ebx),%edx
80101af3:	85 d2                	test   %edx,%edx
80101af5:	0f 8e ac 00 00 00    	jle    80101ba7 <ilock+0xc7>
  acquiresleep(&ip->lock);
80101afb:	8d 43 0c             	lea    0xc(%ebx),%eax
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	50                   	push   %eax
80101b02:	e8 a9 2c 00 00       	call   801047b0 <acquiresleep>
  if(ip->valid == 0){
80101b07:	8b 43 4c             	mov    0x4c(%ebx),%eax
80101b0a:	83 c4 10             	add    $0x10,%esp
80101b0d:	85 c0                	test   %eax,%eax
80101b0f:	74 0f                	je     80101b20 <ilock+0x40>
}
80101b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101b14:	5b                   	pop    %ebx
80101b15:	5e                   	pop    %esi
80101b16:	5d                   	pop    %ebp
80101b17:	c3                   	ret    
80101b18:	90                   	nop
80101b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b20:	8b 43 04             	mov    0x4(%ebx),%eax
80101b23:	83 ec 08             	sub    $0x8,%esp
80101b26:	c1 e8 03             	shr    $0x3,%eax
80101b29:	03 05 d4 19 11 80    	add    0x801119d4,%eax
80101b2f:	50                   	push   %eax
80101b30:	ff 33                	pushl  (%ebx)
80101b32:	e8 a9 e8 ff ff       	call   801003e0 <bread>
80101b37:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b39:	8b 43 04             	mov    0x4(%ebx),%eax
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b3c:	83 c4 0c             	add    $0xc,%esp
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b3f:	83 e0 07             	and    $0x7,%eax
80101b42:	c1 e0 06             	shl    $0x6,%eax
80101b45:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101b49:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b4c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
80101b4f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101b53:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101b57:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101b5b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
80101b5f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101b63:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101b67:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101b6b:	8b 50 fc             	mov    -0x4(%eax),%edx
80101b6e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b71:	6a 34                	push   $0x34
80101b73:	50                   	push   %eax
80101b74:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101b77:	50                   	push   %eax
80101b78:	e8 23 30 00 00       	call   80104ba0 <memmove>
    brelse(bp);
80101b7d:	89 34 24             	mov    %esi,(%esp)
80101b80:	e8 db e8 ff ff       	call   80100460 <brelse>
    if(ip->type == 0)
80101b85:	83 c4 10             	add    $0x10,%esp
80101b88:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
80101b8d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101b94:	0f 85 77 ff ff ff    	jne    80101b11 <ilock+0x31>
      panic("ilock: no type");
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 1c 7d 10 80       	push   $0x80107d1c
80101ba2:	e8 59 eb ff ff       	call   80100700 <panic>
    panic("ilock");
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	68 16 7d 10 80       	push   $0x80107d16
80101baf:	e8 4c eb ff ff       	call   80100700 <panic>
80101bb4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101bba:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80101bc0 <iunlock>:
{
80101bc0:	55                   	push   %ebp
80101bc1:	89 e5                	mov    %esp,%ebp
80101bc3:	56                   	push   %esi
80101bc4:	53                   	push   %ebx
80101bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bc8:	85 db                	test   %ebx,%ebx
80101bca:	74 28                	je     80101bf4 <iunlock+0x34>
80101bcc:	8d 73 0c             	lea    0xc(%ebx),%esi
80101bcf:	83 ec 0c             	sub    $0xc,%esp
80101bd2:	56                   	push   %esi
80101bd3:	e8 78 2c 00 00       	call   80104850 <holdingsleep>
80101bd8:	83 c4 10             	add    $0x10,%esp
80101bdb:	85 c0                	test   %eax,%eax
80101bdd:	74 15                	je     80101bf4 <iunlock+0x34>
80101bdf:	8b 43 08             	mov    0x8(%ebx),%eax
80101be2:	85 c0                	test   %eax,%eax
80101be4:	7e 0e                	jle    80101bf4 <iunlock+0x34>
  releasesleep(&ip->lock);
80101be6:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101be9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101bec:	5b                   	pop    %ebx
80101bed:	5e                   	pop    %esi
80101bee:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101bef:	e9 1c 2c 00 00       	jmp    80104810 <releasesleep>
    panic("iunlock");
80101bf4:	83 ec 0c             	sub    $0xc,%esp
80101bf7:	68 2b 7d 10 80       	push   $0x80107d2b
80101bfc:	e8 ff ea ff ff       	call   80100700 <panic>
80101c01:	eb 0d                	jmp    80101c10 <iput>
80101c03:	90                   	nop
80101c04:	90                   	nop
80101c05:	90                   	nop
80101c06:	90                   	nop
80101c07:	90                   	nop
80101c08:	90                   	nop
80101c09:	90                   	nop
80101c0a:	90                   	nop
80101c0b:	90                   	nop
80101c0c:	90                   	nop
80101c0d:	90                   	nop
80101c0e:	90                   	nop
80101c0f:	90                   	nop

80101c10 <iput>:
{
80101c10:	55                   	push   %ebp
80101c11:	89 e5                	mov    %esp,%ebp
80101c13:	57                   	push   %edi
80101c14:	56                   	push   %esi
80101c15:	53                   	push   %ebx
80101c16:	83 ec 28             	sub    $0x28,%esp
80101c19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101c1c:	8d 7b 0c             	lea    0xc(%ebx),%edi
80101c1f:	57                   	push   %edi
80101c20:	e8 8b 2b 00 00       	call   801047b0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c25:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101c28:	83 c4 10             	add    $0x10,%esp
80101c2b:	85 d2                	test   %edx,%edx
80101c2d:	74 07                	je     80101c36 <iput+0x26>
80101c2f:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101c34:	74 32                	je     80101c68 <iput+0x58>
  releasesleep(&ip->lock);
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	57                   	push   %edi
80101c3a:	e8 d1 2b 00 00       	call   80104810 <releasesleep>
  acquire(&icache.lock);
80101c3f:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101c46:	e8 25 2d 00 00       	call   80104970 <acquire>
  ip->ref--;
80101c4b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101c4f:	83 c4 10             	add    $0x10,%esp
80101c52:	c7 45 08 e0 19 11 80 	movl   $0x801119e0,0x8(%ebp)
}
80101c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c5c:	5b                   	pop    %ebx
80101c5d:	5e                   	pop    %esi
80101c5e:	5f                   	pop    %edi
80101c5f:	5d                   	pop    %ebp
  release(&icache.lock);
80101c60:	e9 2b 2e 00 00       	jmp    80104a90 <release>
80101c65:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101c68:	83 ec 0c             	sub    $0xc,%esp
80101c6b:	68 e0 19 11 80       	push   $0x801119e0
80101c70:	e8 fb 2c 00 00       	call   80104970 <acquire>
    int r = ip->ref;
80101c75:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101c78:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
80101c7f:	e8 0c 2e 00 00       	call   80104a90 <release>
    if(r == 1){
80101c84:	83 c4 10             	add    $0x10,%esp
80101c87:	83 fe 01             	cmp    $0x1,%esi
80101c8a:	75 aa                	jne    80101c36 <iput+0x26>
80101c8c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101c92:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101c95:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101c98:	89 cf                	mov    %ecx,%edi
80101c9a:	eb 0b                	jmp    80101ca7 <iput+0x97>
80101c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101ca0:	83 c6 04             	add    $0x4,%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ca3:	39 fe                	cmp    %edi,%esi
80101ca5:	74 19                	je     80101cc0 <iput+0xb0>
    if(ip->addrs[i]){
80101ca7:	8b 16                	mov    (%esi),%edx
80101ca9:	85 d2                	test   %edx,%edx
80101cab:	74 f3                	je     80101ca0 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
80101cad:	8b 03                	mov    (%ebx),%eax
80101caf:	e8 dc fa ff ff       	call   80101790 <bfree>
      ip->addrs[i] = 0;
80101cb4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101cba:	eb e4                	jmp    80101ca0 <iput+0x90>
80101cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101cc0:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101cc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101cc9:	85 c0                	test   %eax,%eax
80101ccb:	75 33                	jne    80101d00 <iput+0xf0>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101ccd:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101cd0:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101cd7:	53                   	push   %ebx
80101cd8:	e8 53 fd ff ff       	call   80101a30 <iupdate>
      ip->type = 0;
80101cdd:	31 c0                	xor    %eax,%eax
80101cdf:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101ce3:	89 1c 24             	mov    %ebx,(%esp)
80101ce6:	e8 45 fd ff ff       	call   80101a30 <iupdate>
      ip->valid = 0;
80101ceb:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101cf2:	83 c4 10             	add    $0x10,%esp
80101cf5:	e9 3c ff ff ff       	jmp    80101c36 <iput+0x26>
80101cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d00:	83 ec 08             	sub    $0x8,%esp
80101d03:	50                   	push   %eax
80101d04:	ff 33                	pushl  (%ebx)
80101d06:	e8 d5 e6 ff ff       	call   801003e0 <bread>
80101d0b:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101d11:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101d14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101d17:	8d 70 5c             	lea    0x5c(%eax),%esi
80101d1a:	83 c4 10             	add    $0x10,%esp
80101d1d:	89 cf                	mov    %ecx,%edi
80101d1f:	eb 0e                	jmp    80101d2f <iput+0x11f>
80101d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101d28:	83 c6 04             	add    $0x4,%esi
    for(j = 0; j < NINDIRECT; j++){
80101d2b:	39 fe                	cmp    %edi,%esi
80101d2d:	74 0f                	je     80101d3e <iput+0x12e>
      if(a[j])
80101d2f:	8b 16                	mov    (%esi),%edx
80101d31:	85 d2                	test   %edx,%edx
80101d33:	74 f3                	je     80101d28 <iput+0x118>
        bfree(ip->dev, a[j]);
80101d35:	8b 03                	mov    (%ebx),%eax
80101d37:	e8 54 fa ff ff       	call   80101790 <bfree>
80101d3c:	eb ea                	jmp    80101d28 <iput+0x118>
    brelse(bp);
80101d3e:	83 ec 0c             	sub    $0xc,%esp
80101d41:	ff 75 e4             	pushl  -0x1c(%ebp)
80101d44:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101d47:	e8 14 e7 ff ff       	call   80100460 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d4c:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101d52:	8b 03                	mov    (%ebx),%eax
80101d54:	e8 37 fa ff ff       	call   80101790 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d59:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101d60:	00 00 00 
80101d63:	83 c4 10             	add    $0x10,%esp
80101d66:	e9 62 ff ff ff       	jmp    80101ccd <iput+0xbd>
80101d6b:	90                   	nop
80101d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101d70 <iunlockput>:
{
80101d70:	55                   	push   %ebp
80101d71:	89 e5                	mov    %esp,%ebp
80101d73:	53                   	push   %ebx
80101d74:	83 ec 10             	sub    $0x10,%esp
80101d77:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101d7a:	53                   	push   %ebx
80101d7b:	e8 40 fe ff ff       	call   80101bc0 <iunlock>
  iput(ip);
80101d80:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101d83:	83 c4 10             	add    $0x10,%esp
}
80101d86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d89:	c9                   	leave  
  iput(ip);
80101d8a:	e9 81 fe ff ff       	jmp    80101c10 <iput>
80101d8f:	90                   	nop

80101d90 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101d90:	55                   	push   %ebp
80101d91:	89 e5                	mov    %esp,%ebp
80101d93:	8b 55 08             	mov    0x8(%ebp),%edx
80101d96:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101d99:	8b 0a                	mov    (%edx),%ecx
80101d9b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101d9e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101da1:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101da4:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101da8:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101dab:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101daf:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101db3:	8b 52 58             	mov    0x58(%edx),%edx
80101db6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101db9:	5d                   	pop    %ebp
80101dba:	c3                   	ret    
80101dbb:	90                   	nop
80101dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101dc0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101dc0:	55                   	push   %ebp
80101dc1:	89 e5                	mov    %esp,%ebp
80101dc3:	57                   	push   %edi
80101dc4:	56                   	push   %esi
80101dc5:	53                   	push   %ebx
80101dc6:	83 ec 1c             	sub    $0x1c,%esp
80101dc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101dcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101dd2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101dd7:	89 75 e0             	mov    %esi,-0x20(%ebp)
80101dda:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ddd:	8b 75 10             	mov    0x10(%ebp),%esi
80101de0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101de3:	0f 84 a7 00 00 00    	je     80101e90 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101de9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101dec:	8b 40 58             	mov    0x58(%eax),%eax
80101def:	39 c6                	cmp    %eax,%esi
80101df1:	0f 87 ba 00 00 00    	ja     80101eb1 <readi+0xf1>
80101df7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101dfa:	89 f9                	mov    %edi,%ecx
80101dfc:	01 f1                	add    %esi,%ecx
80101dfe:	0f 82 ad 00 00 00    	jb     80101eb1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101e04:	89 c2                	mov    %eax,%edx
80101e06:	29 f2                	sub    %esi,%edx
80101e08:	39 c8                	cmp    %ecx,%eax
80101e0a:	0f 43 d7             	cmovae %edi,%edx

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e0d:	31 ff                	xor    %edi,%edi
80101e0f:	85 d2                	test   %edx,%edx
    n = ip->size - off;
80101e11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e14:	74 6c                	je     80101e82 <readi+0xc2>
80101e16:	8d 76 00             	lea    0x0(%esi),%esi
80101e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e20:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101e23:	89 f2                	mov    %esi,%edx
80101e25:	c1 ea 09             	shr    $0x9,%edx
80101e28:	89 d8                	mov    %ebx,%eax
80101e2a:	e8 41 f8 ff ff       	call   80101670 <bmap>
80101e2f:	83 ec 08             	sub    $0x8,%esp
80101e32:	50                   	push   %eax
80101e33:	ff 33                	pushl  (%ebx)
80101e35:	e8 a6 e5 ff ff       	call   801003e0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101e3a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e3d:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101e3f:	89 f0                	mov    %esi,%eax
80101e41:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e46:	b9 00 02 00 00       	mov    $0x200,%ecx
80101e4b:	83 c4 0c             	add    $0xc,%esp
80101e4e:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101e50:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101e54:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e57:	29 fb                	sub    %edi,%ebx
80101e59:	39 d9                	cmp    %ebx,%ecx
80101e5b:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101e5e:	53                   	push   %ebx
80101e5f:	50                   	push   %eax
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e60:	01 df                	add    %ebx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101e62:	ff 75 e0             	pushl  -0x20(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e65:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101e67:	e8 34 2d 00 00       	call   80104ba0 <memmove>
    brelse(bp);
80101e6c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101e6f:	89 14 24             	mov    %edx,(%esp)
80101e72:	e8 e9 e5 ff ff       	call   80100460 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e77:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101e7a:	83 c4 10             	add    $0x10,%esp
80101e7d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101e80:	77 9e                	ja     80101e20 <readi+0x60>
  }
  return n;
80101e82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e88:	5b                   	pop    %ebx
80101e89:	5e                   	pop    %esi
80101e8a:	5f                   	pop    %edi
80101e8b:	5d                   	pop    %ebp
80101e8c:	c3                   	ret    
80101e8d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e90:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101e94:	66 83 f8 09          	cmp    $0x9,%ax
80101e98:	77 17                	ja     80101eb1 <readi+0xf1>
80101e9a:	8b 04 c5 60 19 11 80 	mov    -0x7feee6a0(,%eax,8),%eax
80101ea1:	85 c0                	test   %eax,%eax
80101ea3:	74 0c                	je     80101eb1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101ea5:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101ea8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101eab:	5b                   	pop    %ebx
80101eac:	5e                   	pop    %esi
80101ead:	5f                   	pop    %edi
80101eae:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101eaf:	ff e0                	jmp    *%eax
      return -1;
80101eb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eb6:	eb cd                	jmp    80101e85 <readi+0xc5>
80101eb8:	90                   	nop
80101eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ec0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ec0:	55                   	push   %ebp
80101ec1:	89 e5                	mov    %esp,%ebp
80101ec3:	57                   	push   %edi
80101ec4:	56                   	push   %esi
80101ec5:	53                   	push   %ebx
80101ec6:	83 ec 1c             	sub    $0x1c,%esp
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
80101ecf:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101ed7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101eda:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101edd:	8b 75 10             	mov    0x10(%ebp),%esi
80101ee0:	89 7d e0             	mov    %edi,-0x20(%ebp)
  if(ip->type == T_DEV){
80101ee3:	0f 84 b7 00 00 00    	je     80101fa0 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101eec:	39 70 58             	cmp    %esi,0x58(%eax)
80101eef:	0f 82 eb 00 00 00    	jb     80101fe0 <writei+0x120>
80101ef5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101ef8:	31 d2                	xor    %edx,%edx
80101efa:	89 f8                	mov    %edi,%eax
80101efc:	01 f0                	add    %esi,%eax
80101efe:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101f01:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f06:	0f 87 d4 00 00 00    	ja     80101fe0 <writei+0x120>
80101f0c:	85 d2                	test   %edx,%edx
80101f0e:	0f 85 cc 00 00 00    	jne    80101fe0 <writei+0x120>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f14:	85 ff                	test   %edi,%edi
80101f16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101f1d:	74 72                	je     80101f91 <writei+0xd1>
80101f1f:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f20:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101f23:	89 f2                	mov    %esi,%edx
80101f25:	c1 ea 09             	shr    $0x9,%edx
80101f28:	89 f8                	mov    %edi,%eax
80101f2a:	e8 41 f7 ff ff       	call   80101670 <bmap>
80101f2f:	83 ec 08             	sub    $0x8,%esp
80101f32:	50                   	push   %eax
80101f33:	ff 37                	pushl  (%edi)
80101f35:	e8 a6 e4 ff ff       	call   801003e0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101f3a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101f3d:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f40:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101f42:	89 f0                	mov    %esi,%eax
80101f44:	b9 00 02 00 00       	mov    $0x200,%ecx
80101f49:	83 c4 0c             	add    $0xc,%esp
80101f4c:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f51:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101f53:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101f57:	39 d9                	cmp    %ebx,%ecx
80101f59:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101f5c:	53                   	push   %ebx
80101f5d:	ff 75 dc             	pushl  -0x24(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f60:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101f62:	50                   	push   %eax
80101f63:	e8 38 2c 00 00       	call   80104ba0 <memmove>
    log_write(bp);
80101f68:	89 3c 24             	mov    %edi,(%esp)
80101f6b:	e8 e0 12 00 00       	call   80103250 <log_write>
    brelse(bp);
80101f70:	89 3c 24             	mov    %edi,(%esp)
80101f73:	e8 e8 e4 ff ff       	call   80100460 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f78:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101f7b:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101f7e:	83 c4 10             	add    $0x10,%esp
80101f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101f84:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101f87:	77 97                	ja     80101f20 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101f89:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101f8c:	3b 70 58             	cmp    0x58(%eax),%esi
80101f8f:	77 37                	ja     80101fc8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101f91:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f97:	5b                   	pop    %ebx
80101f98:	5e                   	pop    %esi
80101f99:	5f                   	pop    %edi
80101f9a:	5d                   	pop    %ebp
80101f9b:	c3                   	ret    
80101f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fa0:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101fa4:	66 83 f8 09          	cmp    $0x9,%ax
80101fa8:	77 36                	ja     80101fe0 <writei+0x120>
80101faa:	8b 04 c5 64 19 11 80 	mov    -0x7feee69c(,%eax,8),%eax
80101fb1:	85 c0                	test   %eax,%eax
80101fb3:	74 2b                	je     80101fe0 <writei+0x120>
    return devsw[ip->major].write(ip, src, n);
80101fb5:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fbb:	5b                   	pop    %ebx
80101fbc:	5e                   	pop    %esi
80101fbd:	5f                   	pop    %edi
80101fbe:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101fbf:	ff e0                	jmp    *%eax
80101fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101fc8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101fcb:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101fce:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101fd1:	50                   	push   %eax
80101fd2:	e8 59 fa ff ff       	call   80101a30 <iupdate>
80101fd7:	83 c4 10             	add    $0x10,%esp
80101fda:	eb b5                	jmp    80101f91 <writei+0xd1>
80101fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return -1;
80101fe0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fe5:	eb ad                	jmp    80101f94 <writei+0xd4>
80101fe7:	89 f6                	mov    %esi,%esi
80101fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80101ff0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101ff6:	6a 0e                	push   $0xe
80101ff8:	ff 75 0c             	pushl  0xc(%ebp)
80101ffb:	ff 75 08             	pushl  0x8(%ebp)
80101ffe:	e8 0d 2c 00 00       	call   80104c10 <strncmp>
}
80102003:	c9                   	leave  
80102004:	c3                   	ret    
80102005:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102010 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102010:	55                   	push   %ebp
80102011:	89 e5                	mov    %esp,%ebp
80102013:	57                   	push   %edi
80102014:	56                   	push   %esi
80102015:	53                   	push   %ebx
80102016:	83 ec 1c             	sub    $0x1c,%esp
80102019:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010201c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80102021:	0f 85 85 00 00 00    	jne    801020ac <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102027:	8b 53 58             	mov    0x58(%ebx),%edx
8010202a:	31 ff                	xor    %edi,%edi
8010202c:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010202f:	85 d2                	test   %edx,%edx
80102031:	74 3e                	je     80102071 <dirlookup+0x61>
80102033:	90                   	nop
80102034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102038:	6a 10                	push   $0x10
8010203a:	57                   	push   %edi
8010203b:	56                   	push   %esi
8010203c:	53                   	push   %ebx
8010203d:	e8 7e fd ff ff       	call   80101dc0 <readi>
80102042:	83 c4 10             	add    $0x10,%esp
80102045:	83 f8 10             	cmp    $0x10,%eax
80102048:	75 55                	jne    8010209f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
8010204a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010204f:	74 18                	je     80102069 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80102051:	8d 45 da             	lea    -0x26(%ebp),%eax
80102054:	83 ec 04             	sub    $0x4,%esp
80102057:	6a 0e                	push   $0xe
80102059:	50                   	push   %eax
8010205a:	ff 75 0c             	pushl  0xc(%ebp)
8010205d:	e8 ae 2b 00 00       	call   80104c10 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80102062:	83 c4 10             	add    $0x10,%esp
80102065:	85 c0                	test   %eax,%eax
80102067:	74 17                	je     80102080 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102069:	83 c7 10             	add    $0x10,%edi
8010206c:	3b 7b 58             	cmp    0x58(%ebx),%edi
8010206f:	72 c7                	jb     80102038 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80102071:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80102074:	31 c0                	xor    %eax,%eax
}
80102076:	5b                   	pop    %ebx
80102077:	5e                   	pop    %esi
80102078:	5f                   	pop    %edi
80102079:	5d                   	pop    %ebp
8010207a:	c3                   	ret    
8010207b:	90                   	nop
8010207c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(poff)
80102080:	8b 45 10             	mov    0x10(%ebp),%eax
80102083:	85 c0                	test   %eax,%eax
80102085:	74 05                	je     8010208c <dirlookup+0x7c>
        *poff = off;
80102087:	8b 45 10             	mov    0x10(%ebp),%eax
8010208a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
8010208c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80102090:	8b 03                	mov    (%ebx),%eax
80102092:	e8 09 f5 ff ff       	call   801015a0 <iget>
}
80102097:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010209a:	5b                   	pop    %ebx
8010209b:	5e                   	pop    %esi
8010209c:	5f                   	pop    %edi
8010209d:	5d                   	pop    %ebp
8010209e:	c3                   	ret    
      panic("dirlookup read");
8010209f:	83 ec 0c             	sub    $0xc,%esp
801020a2:	68 45 7d 10 80       	push   $0x80107d45
801020a7:	e8 54 e6 ff ff       	call   80100700 <panic>
    panic("dirlookup not DIR");
801020ac:	83 ec 0c             	sub    $0xc,%esp
801020af:	68 33 7d 10 80       	push   $0x80107d33
801020b4:	e8 47 e6 ff ff       	call   80100700 <panic>
801020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801020c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801020c0:	55                   	push   %ebp
801020c1:	89 e5                	mov    %esp,%ebp
801020c3:	57                   	push   %edi
801020c4:	56                   	push   %esi
801020c5:	53                   	push   %ebx
801020c6:	89 cf                	mov    %ecx,%edi
801020c8:	89 c3                	mov    %eax,%ebx
801020ca:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
801020cd:	80 38 2f             	cmpb   $0x2f,(%eax)
{
801020d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(*path == '/')
801020d3:	0f 84 67 01 00 00    	je     80102240 <namex+0x180>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
801020d9:	e8 e2 1b 00 00       	call   80103cc0 <myproc>
  acquire(&icache.lock);
801020de:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
801020e1:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
801020e4:	68 e0 19 11 80       	push   $0x801119e0
801020e9:	e8 82 28 00 00       	call   80104970 <acquire>
  ip->ref++;
801020ee:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
801020f2:	c7 04 24 e0 19 11 80 	movl   $0x801119e0,(%esp)
801020f9:	e8 92 29 00 00       	call   80104a90 <release>
801020fe:	83 c4 10             	add    $0x10,%esp
80102101:	eb 08                	jmp    8010210b <namex+0x4b>
80102103:	90                   	nop
80102104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80102108:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
8010210b:	0f b6 03             	movzbl (%ebx),%eax
8010210e:	3c 2f                	cmp    $0x2f,%al
80102110:	74 f6                	je     80102108 <namex+0x48>
  if(*path == 0)
80102112:	84 c0                	test   %al,%al
80102114:	0f 84 ee 00 00 00    	je     80102208 <namex+0x148>
  while(*path != '/' && *path != 0)
8010211a:	0f b6 03             	movzbl (%ebx),%eax
8010211d:	3c 2f                	cmp    $0x2f,%al
8010211f:	0f 84 b3 00 00 00    	je     801021d8 <namex+0x118>
80102125:	84 c0                	test   %al,%al
80102127:	89 da                	mov    %ebx,%edx
80102129:	75 09                	jne    80102134 <namex+0x74>
8010212b:	e9 a8 00 00 00       	jmp    801021d8 <namex+0x118>
80102130:	84 c0                	test   %al,%al
80102132:	74 0a                	je     8010213e <namex+0x7e>
    path++;
80102134:	83 c2 01             	add    $0x1,%edx
  while(*path != '/' && *path != 0)
80102137:	0f b6 02             	movzbl (%edx),%eax
8010213a:	3c 2f                	cmp    $0x2f,%al
8010213c:	75 f2                	jne    80102130 <namex+0x70>
8010213e:	89 d1                	mov    %edx,%ecx
80102140:	29 d9                	sub    %ebx,%ecx
  if(len >= DIRSIZ)
80102142:	83 f9 0d             	cmp    $0xd,%ecx
80102145:	0f 8e 91 00 00 00    	jle    801021dc <namex+0x11c>
    memmove(name, s, DIRSIZ);
8010214b:	83 ec 04             	sub    $0x4,%esp
8010214e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80102151:	6a 0e                	push   $0xe
80102153:	53                   	push   %ebx
80102154:	57                   	push   %edi
80102155:	e8 46 2a 00 00       	call   80104ba0 <memmove>
    path++;
8010215a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    memmove(name, s, DIRSIZ);
8010215d:	83 c4 10             	add    $0x10,%esp
    path++;
80102160:	89 d3                	mov    %edx,%ebx
  while(*path == '/')
80102162:	80 3a 2f             	cmpb   $0x2f,(%edx)
80102165:	75 11                	jne    80102178 <namex+0xb8>
80102167:	89 f6                	mov    %esi,%esi
80102169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    path++;
80102170:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80102173:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80102176:	74 f8                	je     80102170 <namex+0xb0>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80102178:	83 ec 0c             	sub    $0xc,%esp
8010217b:	56                   	push   %esi
8010217c:	e8 5f f9 ff ff       	call   80101ae0 <ilock>
    if(ip->type != T_DIR){
80102181:	83 c4 10             	add    $0x10,%esp
80102184:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80102189:	0f 85 91 00 00 00    	jne    80102220 <namex+0x160>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
8010218f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102192:	85 d2                	test   %edx,%edx
80102194:	74 09                	je     8010219f <namex+0xdf>
80102196:	80 3b 00             	cmpb   $0x0,(%ebx)
80102199:	0f 84 b7 00 00 00    	je     80102256 <namex+0x196>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010219f:	83 ec 04             	sub    $0x4,%esp
801021a2:	6a 00                	push   $0x0
801021a4:	57                   	push   %edi
801021a5:	56                   	push   %esi
801021a6:	e8 65 fe ff ff       	call   80102010 <dirlookup>
801021ab:	83 c4 10             	add    $0x10,%esp
801021ae:	85 c0                	test   %eax,%eax
801021b0:	74 6e                	je     80102220 <namex+0x160>
  iunlock(ip);
801021b2:	83 ec 0c             	sub    $0xc,%esp
801021b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801021b8:	56                   	push   %esi
801021b9:	e8 02 fa ff ff       	call   80101bc0 <iunlock>
  iput(ip);
801021be:	89 34 24             	mov    %esi,(%esp)
801021c1:	e8 4a fa ff ff       	call   80101c10 <iput>
801021c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801021c9:	83 c4 10             	add    $0x10,%esp
801021cc:	89 c6                	mov    %eax,%esi
801021ce:	e9 38 ff ff ff       	jmp    8010210b <namex+0x4b>
801021d3:	90                   	nop
801021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(*path != '/' && *path != 0)
801021d8:	89 da                	mov    %ebx,%edx
801021da:	31 c9                	xor    %ecx,%ecx
    memmove(name, s, len);
801021dc:	83 ec 04             	sub    $0x4,%esp
801021df:	89 55 dc             	mov    %edx,-0x24(%ebp)
801021e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801021e5:	51                   	push   %ecx
801021e6:	53                   	push   %ebx
801021e7:	57                   	push   %edi
801021e8:	e8 b3 29 00 00       	call   80104ba0 <memmove>
    name[len] = 0;
801021ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801021f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801021f3:	83 c4 10             	add    $0x10,%esp
801021f6:	c6 04 0f 00          	movb   $0x0,(%edi,%ecx,1)
801021fa:	89 d3                	mov    %edx,%ebx
801021fc:	e9 61 ff ff ff       	jmp    80102162 <namex+0xa2>
80102201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102208:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010220b:	85 c0                	test   %eax,%eax
8010220d:	75 5d                	jne    8010226c <namex+0x1ac>
    iput(ip);
    return 0;
  }
  return ip;
}
8010220f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102212:	89 f0                	mov    %esi,%eax
80102214:	5b                   	pop    %ebx
80102215:	5e                   	pop    %esi
80102216:	5f                   	pop    %edi
80102217:	5d                   	pop    %ebp
80102218:	c3                   	ret    
80102219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
80102220:	83 ec 0c             	sub    $0xc,%esp
80102223:	56                   	push   %esi
80102224:	e8 97 f9 ff ff       	call   80101bc0 <iunlock>
  iput(ip);
80102229:	89 34 24             	mov    %esi,(%esp)
      return 0;
8010222c:	31 f6                	xor    %esi,%esi
  iput(ip);
8010222e:	e8 dd f9 ff ff       	call   80101c10 <iput>
      return 0;
80102233:	83 c4 10             	add    $0x10,%esp
}
80102236:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102239:	89 f0                	mov    %esi,%eax
8010223b:	5b                   	pop    %ebx
8010223c:	5e                   	pop    %esi
8010223d:	5f                   	pop    %edi
8010223e:	5d                   	pop    %ebp
8010223f:	c3                   	ret    
    ip = iget(ROOTDEV, ROOTINO);
80102240:	ba 01 00 00 00       	mov    $0x1,%edx
80102245:	b8 01 00 00 00       	mov    $0x1,%eax
8010224a:	e8 51 f3 ff ff       	call   801015a0 <iget>
8010224f:	89 c6                	mov    %eax,%esi
80102251:	e9 b5 fe ff ff       	jmp    8010210b <namex+0x4b>
      iunlock(ip);
80102256:	83 ec 0c             	sub    $0xc,%esp
80102259:	56                   	push   %esi
8010225a:	e8 61 f9 ff ff       	call   80101bc0 <iunlock>
      return ip;
8010225f:	83 c4 10             	add    $0x10,%esp
}
80102262:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102265:	89 f0                	mov    %esi,%eax
80102267:	5b                   	pop    %ebx
80102268:	5e                   	pop    %esi
80102269:	5f                   	pop    %edi
8010226a:	5d                   	pop    %ebp
8010226b:	c3                   	ret    
    iput(ip);
8010226c:	83 ec 0c             	sub    $0xc,%esp
8010226f:	56                   	push   %esi
    return 0;
80102270:	31 f6                	xor    %esi,%esi
    iput(ip);
80102272:	e8 99 f9 ff ff       	call   80101c10 <iput>
    return 0;
80102277:	83 c4 10             	add    $0x10,%esp
8010227a:	eb 93                	jmp    8010220f <namex+0x14f>
8010227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102280 <dirlink>:
{
80102280:	55                   	push   %ebp
80102281:	89 e5                	mov    %esp,%ebp
80102283:	57                   	push   %edi
80102284:	56                   	push   %esi
80102285:	53                   	push   %ebx
80102286:	83 ec 20             	sub    $0x20,%esp
80102289:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
8010228c:	6a 00                	push   $0x0
8010228e:	ff 75 0c             	pushl  0xc(%ebp)
80102291:	53                   	push   %ebx
80102292:	e8 79 fd ff ff       	call   80102010 <dirlookup>
80102297:	83 c4 10             	add    $0x10,%esp
8010229a:	85 c0                	test   %eax,%eax
8010229c:	75 67                	jne    80102305 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010229e:	8b 7b 58             	mov    0x58(%ebx),%edi
801022a1:	8d 75 d8             	lea    -0x28(%ebp),%esi
801022a4:	85 ff                	test   %edi,%edi
801022a6:	74 29                	je     801022d1 <dirlink+0x51>
801022a8:	31 ff                	xor    %edi,%edi
801022aa:	8d 75 d8             	lea    -0x28(%ebp),%esi
801022ad:	eb 09                	jmp    801022b8 <dirlink+0x38>
801022af:	90                   	nop
801022b0:	83 c7 10             	add    $0x10,%edi
801022b3:	3b 7b 58             	cmp    0x58(%ebx),%edi
801022b6:	73 19                	jae    801022d1 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b8:	6a 10                	push   $0x10
801022ba:	57                   	push   %edi
801022bb:	56                   	push   %esi
801022bc:	53                   	push   %ebx
801022bd:	e8 fe fa ff ff       	call   80101dc0 <readi>
801022c2:	83 c4 10             	add    $0x10,%esp
801022c5:	83 f8 10             	cmp    $0x10,%eax
801022c8:	75 4e                	jne    80102318 <dirlink+0x98>
    if(de.inum == 0)
801022ca:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801022cf:	75 df                	jne    801022b0 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
801022d1:	8d 45 da             	lea    -0x26(%ebp),%eax
801022d4:	83 ec 04             	sub    $0x4,%esp
801022d7:	6a 0e                	push   $0xe
801022d9:	ff 75 0c             	pushl  0xc(%ebp)
801022dc:	50                   	push   %eax
801022dd:	e8 8e 29 00 00       	call   80104c70 <strncpy>
  de.inum = inum;
801022e2:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e5:	6a 10                	push   $0x10
801022e7:	57                   	push   %edi
801022e8:	56                   	push   %esi
801022e9:	53                   	push   %ebx
  de.inum = inum;
801022ea:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ee:	e8 cd fb ff ff       	call   80101ec0 <writei>
801022f3:	83 c4 20             	add    $0x20,%esp
801022f6:	83 f8 10             	cmp    $0x10,%eax
801022f9:	75 2a                	jne    80102325 <dirlink+0xa5>
  return 0;
801022fb:	31 c0                	xor    %eax,%eax
}
801022fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102300:	5b                   	pop    %ebx
80102301:	5e                   	pop    %esi
80102302:	5f                   	pop    %edi
80102303:	5d                   	pop    %ebp
80102304:	c3                   	ret    
    iput(ip);
80102305:	83 ec 0c             	sub    $0xc,%esp
80102308:	50                   	push   %eax
80102309:	e8 02 f9 ff ff       	call   80101c10 <iput>
    return -1;
8010230e:	83 c4 10             	add    $0x10,%esp
80102311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102316:	eb e5                	jmp    801022fd <dirlink+0x7d>
      panic("dirlink read");
80102318:	83 ec 0c             	sub    $0xc,%esp
8010231b:	68 54 7d 10 80       	push   $0x80107d54
80102320:	e8 db e3 ff ff       	call   80100700 <panic>
    panic("dirlink");
80102325:	83 ec 0c             	sub    $0xc,%esp
80102328:	68 e6 7b 10 80       	push   $0x80107be6
8010232d:	e8 ce e3 ff ff       	call   80100700 <panic>
80102332:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102339:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102340 <namei>:

struct inode*
namei(char *path)
{
80102340:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102341:	31 d2                	xor    %edx,%edx
{
80102343:	89 e5                	mov    %esp,%ebp
80102345:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80102348:	8b 45 08             	mov    0x8(%ebp),%eax
8010234b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
8010234e:	e8 6d fd ff ff       	call   801020c0 <namex>
}
80102353:	c9                   	leave  
80102354:	c3                   	ret    
80102355:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102360 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102360:	55                   	push   %ebp
  return namex(path, 1, name);
80102361:	ba 01 00 00 00       	mov    $0x1,%edx
{
80102366:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80102368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010236e:	5d                   	pop    %ebp
  return namex(path, 1, name);
8010236f:	e9 4c fd ff ff       	jmp    801020c0 <namex>
80102374:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010237a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80102380 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102380:	55                   	push   %ebp
    char const digit[] = "0123456789";
80102381:	b8 38 39 00 00       	mov    $0x3938,%eax
char* itoa(int i, char b[]){
80102386:	89 e5                	mov    %esp,%ebp
80102388:	57                   	push   %edi
80102389:	56                   	push   %esi
8010238a:	53                   	push   %ebx
8010238b:	83 ec 10             	sub    $0x10,%esp
8010238e:	8b 4d 08             	mov    0x8(%ebp),%ecx
    char const digit[] = "0123456789";
80102391:	c7 45 e9 30 31 32 33 	movl   $0x33323130,-0x17(%ebp)
80102398:	c7 45 ed 34 35 36 37 	movl   $0x37363534,-0x13(%ebp)
8010239f:	66 89 45 f1          	mov    %ax,-0xf(%ebp)
801023a3:	c6 45 f3 00          	movb   $0x0,-0xd(%ebp)
801023a7:	8b 75 0c             	mov    0xc(%ebp),%esi
    char* p = b;
    if(i<0){
801023aa:	85 c9                	test   %ecx,%ecx
801023ac:	79 0a                	jns    801023b8 <itoa+0x38>
801023ae:	89 f0                	mov    %esi,%eax
801023b0:	8d 76 01             	lea    0x1(%esi),%esi
        *p++ = '-';
        i *= -1;
801023b3:	f7 d9                	neg    %ecx
        *p++ = '-';
801023b5:	c6 00 2d             	movb   $0x2d,(%eax)
    }
    int shifter = i;
801023b8:	89 cb                	mov    %ecx,%ebx
    do{ //Move to where representation ends
        ++p;
        shifter = shifter/10;
801023ba:	bf 67 66 66 66       	mov    $0x66666667,%edi
801023bf:	90                   	nop
801023c0:	89 d8                	mov    %ebx,%eax
801023c2:	c1 fb 1f             	sar    $0x1f,%ebx
        ++p;
801023c5:	83 c6 01             	add    $0x1,%esi
        shifter = shifter/10;
801023c8:	f7 ef                	imul   %edi
801023ca:	c1 fa 02             	sar    $0x2,%edx
    }while(shifter);
801023cd:	29 da                	sub    %ebx,%edx
801023cf:	89 d3                	mov    %edx,%ebx
801023d1:	75 ed                	jne    801023c0 <itoa+0x40>
    *p = '\0';
801023d3:	c6 06 00             	movb   $0x0,(%esi)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801023d6:	bb 67 66 66 66       	mov    $0x66666667,%ebx
801023db:	90                   	nop
801023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801023e0:	89 c8                	mov    %ecx,%eax
801023e2:	83 ee 01             	sub    $0x1,%esi
801023e5:	f7 eb                	imul   %ebx
801023e7:	89 c8                	mov    %ecx,%eax
801023e9:	c1 f8 1f             	sar    $0x1f,%eax
801023ec:	c1 fa 02             	sar    $0x2,%edx
801023ef:	29 c2                	sub    %eax,%edx
801023f1:	8d 04 92             	lea    (%edx,%edx,4),%eax
801023f4:	01 c0                	add    %eax,%eax
801023f6:	29 c1                	sub    %eax,%ecx
        i = i/10;
    }while(i);
801023f8:	85 d2                	test   %edx,%edx
        *--p = digit[i%10];
801023fa:	0f b6 44 0d e9       	movzbl -0x17(%ebp,%ecx,1),%eax
        i = i/10;
801023ff:	89 d1                	mov    %edx,%ecx
        *--p = digit[i%10];
80102401:	88 06                	mov    %al,(%esi)
    }while(i);
80102403:	75 db                	jne    801023e0 <itoa+0x60>
    return b;
80102405:	8b 45 0c             	mov    0xc(%ebp),%eax
80102408:	83 c4 10             	add    $0x10,%esp
8010240b:	5b                   	pop    %ebx
8010240c:	5e                   	pop    %esi
8010240d:	5f                   	pop    %edi
8010240e:	5d                   	pop    %ebp
8010240f:	c3                   	ret    

80102410 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102410:	55                   	push   %ebp
  if(b == 0)
80102411:	85 c0                	test   %eax,%eax
{
80102413:	89 e5                	mov    %esp,%ebp
80102415:	56                   	push   %esi
80102416:	53                   	push   %ebx
  if(b == 0)
80102417:	0f 84 af 00 00 00    	je     801024cc <idestart+0xbc>
    panic("idestart");
  if(b->blockno >= FSSIZE)
8010241d:	8b 58 08             	mov    0x8(%eax),%ebx
80102420:	89 c6                	mov    %eax,%esi
80102422:	81 fb ff f3 01 00    	cmp    $0x1f3ff,%ebx
80102428:	0f 87 91 00 00 00    	ja     801024bf <idestart+0xaf>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010242e:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102433:	90                   	nop
80102434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102438:	89 ca                	mov    %ecx,%edx
8010243a:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010243b:	83 e0 c0             	and    $0xffffffc0,%eax
8010243e:	3c 40                	cmp    $0x40,%al
80102440:	75 f6                	jne    80102438 <idestart+0x28>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102442:	31 c0                	xor    %eax,%eax
80102444:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102449:	ee                   	out    %al,(%dx)
8010244a:	b8 01 00 00 00       	mov    $0x1,%eax
8010244f:	ba f2 01 00 00       	mov    $0x1f2,%edx
80102454:	ee                   	out    %al,(%dx)
80102455:	ba f3 01 00 00       	mov    $0x1f3,%edx
8010245a:	89 d8                	mov    %ebx,%eax
8010245c:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
8010245d:	89 d8                	mov    %ebx,%eax
8010245f:	ba f4 01 00 00       	mov    $0x1f4,%edx
80102464:	c1 f8 08             	sar    $0x8,%eax
80102467:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80102468:	89 d8                	mov    %ebx,%eax
8010246a:	ba f5 01 00 00       	mov    $0x1f5,%edx
8010246f:	c1 f8 10             	sar    $0x10,%eax
80102472:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102473:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80102477:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010247c:	c1 e0 04             	shl    $0x4,%eax
8010247f:	83 e0 10             	and    $0x10,%eax
80102482:	83 c8 e0             	or     $0xffffffe0,%eax
80102485:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80102486:	f6 06 04             	testb  $0x4,(%esi)
80102489:	75 15                	jne    801024a0 <idestart+0x90>
8010248b:	b8 20 00 00 00       	mov    $0x20,%eax
80102490:	89 ca                	mov    %ecx,%edx
80102492:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102493:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102496:	5b                   	pop    %ebx
80102497:	5e                   	pop    %esi
80102498:	5d                   	pop    %ebp
80102499:	c3                   	ret    
8010249a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801024a0:	b8 30 00 00 00       	mov    $0x30,%eax
801024a5:	89 ca                	mov    %ecx,%edx
801024a7:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
801024a8:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
801024ad:	83 c6 5c             	add    $0x5c,%esi
801024b0:	ba f0 01 00 00       	mov    $0x1f0,%edx
801024b5:	fc                   	cld    
801024b6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801024b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801024bb:	5b                   	pop    %ebx
801024bc:	5e                   	pop    %esi
801024bd:	5d                   	pop    %ebp
801024be:	c3                   	ret    
    panic("incorrect blockno");
801024bf:	83 ec 0c             	sub    $0xc,%esp
801024c2:	68 c0 7d 10 80       	push   $0x80107dc0
801024c7:	e8 34 e2 ff ff       	call   80100700 <panic>
    panic("idestart");
801024cc:	83 ec 0c             	sub    $0xc,%esp
801024cf:	68 b7 7d 10 80       	push   $0x80107db7
801024d4:	e8 27 e2 ff ff       	call   80100700 <panic>
801024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801024e0 <ideinit>:
{
801024e0:	55                   	push   %ebp
801024e1:	89 e5                	mov    %esp,%ebp
801024e3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801024e6:	68 d2 7d 10 80       	push   $0x80107dd2
801024eb:	68 80 b5 10 80       	push   $0x8010b580
801024f0:	e8 8b 23 00 00       	call   80104880 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801024f5:	58                   	pop    %eax
801024f6:	a1 00 3d 11 80       	mov    0x80113d00,%eax
801024fb:	5a                   	pop    %edx
801024fc:	83 e8 01             	sub    $0x1,%eax
801024ff:	50                   	push   %eax
80102500:	6a 0e                	push   $0xe
80102502:	e8 a9 02 00 00       	call   801027b0 <ioapicenable>
80102507:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010250a:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010250f:	90                   	nop
80102510:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102511:	83 e0 c0             	and    $0xffffffc0,%eax
80102514:	3c 40                	cmp    $0x40,%al
80102516:	75 f8                	jne    80102510 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102518:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010251d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102522:	ee                   	out    %al,(%dx)
80102523:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102528:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010252d:	eb 06                	jmp    80102535 <ideinit+0x55>
8010252f:	90                   	nop
  for(i=0; i<1000; i++){
80102530:	83 e9 01             	sub    $0x1,%ecx
80102533:	74 0f                	je     80102544 <ideinit+0x64>
80102535:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102536:	84 c0                	test   %al,%al
80102538:	74 f6                	je     80102530 <ideinit+0x50>
      havedisk1 = 1;
8010253a:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
80102541:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102544:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102549:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010254e:	ee                   	out    %al,(%dx)
}
8010254f:	c9                   	leave  
80102550:	c3                   	ret    
80102551:	eb 0d                	jmp    80102560 <ideintr>
80102553:	90                   	nop
80102554:	90                   	nop
80102555:	90                   	nop
80102556:	90                   	nop
80102557:	90                   	nop
80102558:	90                   	nop
80102559:	90                   	nop
8010255a:	90                   	nop
8010255b:	90                   	nop
8010255c:	90                   	nop
8010255d:	90                   	nop
8010255e:	90                   	nop
8010255f:	90                   	nop

80102560 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102560:	55                   	push   %ebp
80102561:	89 e5                	mov    %esp,%ebp
80102563:	57                   	push   %edi
80102564:	56                   	push   %esi
80102565:	53                   	push   %ebx
80102566:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102569:	68 80 b5 10 80       	push   $0x8010b580
8010256e:	e8 fd 23 00 00       	call   80104970 <acquire>

  if((b = idequeue) == 0){
80102573:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
80102579:	83 c4 10             	add    $0x10,%esp
8010257c:	85 db                	test   %ebx,%ebx
8010257e:	74 67                	je     801025e7 <ideintr+0x87>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102580:	8b 43 58             	mov    0x58(%ebx),%eax
80102583:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102588:	8b 3b                	mov    (%ebx),%edi
8010258a:	f7 c7 04 00 00 00    	test   $0x4,%edi
80102590:	75 31                	jne    801025c3 <ideintr+0x63>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102592:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102597:	89 f6                	mov    %esi,%esi
80102599:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801025a0:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801025a1:	89 c6                	mov    %eax,%esi
801025a3:	83 e6 c0             	and    $0xffffffc0,%esi
801025a6:	89 f1                	mov    %esi,%ecx
801025a8:	80 f9 40             	cmp    $0x40,%cl
801025ab:	75 f3                	jne    801025a0 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025ad:	a8 21                	test   $0x21,%al
801025af:	75 12                	jne    801025c3 <ideintr+0x63>
    insl(0x1f0, b->data, BSIZE/4);
801025b1:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801025b4:	b9 80 00 00 00       	mov    $0x80,%ecx
801025b9:	ba f0 01 00 00       	mov    $0x1f0,%edx
801025be:	fc                   	cld    
801025bf:	f3 6d                	rep insl (%dx),%es:(%edi)
801025c1:	8b 3b                	mov    (%ebx),%edi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
801025c3:	83 e7 fb             	and    $0xfffffffb,%edi
  wakeup(b);
801025c6:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801025c9:	89 f9                	mov    %edi,%ecx
801025cb:	83 c9 02             	or     $0x2,%ecx
801025ce:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
801025d0:	53                   	push   %ebx
801025d1:	e8 1a 1e 00 00       	call   801043f0 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801025d6:	a1 64 b5 10 80       	mov    0x8010b564,%eax
801025db:	83 c4 10             	add    $0x10,%esp
801025de:	85 c0                	test   %eax,%eax
801025e0:	74 05                	je     801025e7 <ideintr+0x87>
    idestart(idequeue);
801025e2:	e8 29 fe ff ff       	call   80102410 <idestart>
    release(&idelock);
801025e7:	83 ec 0c             	sub    $0xc,%esp
801025ea:	68 80 b5 10 80       	push   $0x8010b580
801025ef:	e8 9c 24 00 00       	call   80104a90 <release>

  release(&idelock);
}
801025f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801025f7:	5b                   	pop    %ebx
801025f8:	5e                   	pop    %esi
801025f9:	5f                   	pop    %edi
801025fa:	5d                   	pop    %ebp
801025fb:	c3                   	ret    
801025fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102600 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102600:	55                   	push   %ebp
80102601:	89 e5                	mov    %esp,%ebp
80102603:	53                   	push   %ebx
80102604:	83 ec 10             	sub    $0x10,%esp
80102607:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010260a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010260d:	50                   	push   %eax
8010260e:	e8 3d 22 00 00       	call   80104850 <holdingsleep>
80102613:	83 c4 10             	add    $0x10,%esp
80102616:	85 c0                	test   %eax,%eax
80102618:	0f 84 c6 00 00 00    	je     801026e4 <iderw+0xe4>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010261e:	8b 03                	mov    (%ebx),%eax
80102620:	83 e0 06             	and    $0x6,%eax
80102623:	83 f8 02             	cmp    $0x2,%eax
80102626:	0f 84 ab 00 00 00    	je     801026d7 <iderw+0xd7>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010262c:	8b 53 04             	mov    0x4(%ebx),%edx
8010262f:	85 d2                	test   %edx,%edx
80102631:	74 0d                	je     80102640 <iderw+0x40>
80102633:	a1 60 b5 10 80       	mov    0x8010b560,%eax
80102638:	85 c0                	test   %eax,%eax
8010263a:	0f 84 b1 00 00 00    	je     801026f1 <iderw+0xf1>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102640:	83 ec 0c             	sub    $0xc,%esp
80102643:	68 80 b5 10 80       	push   $0x8010b580
80102648:	e8 23 23 00 00       	call   80104970 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010264d:	8b 15 64 b5 10 80    	mov    0x8010b564,%edx
80102653:	83 c4 10             	add    $0x10,%esp
  b->qnext = 0;
80102656:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010265d:	85 d2                	test   %edx,%edx
8010265f:	75 09                	jne    8010266a <iderw+0x6a>
80102661:	eb 6d                	jmp    801026d0 <iderw+0xd0>
80102663:	90                   	nop
80102664:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102668:	89 c2                	mov    %eax,%edx
8010266a:	8b 42 58             	mov    0x58(%edx),%eax
8010266d:	85 c0                	test   %eax,%eax
8010266f:	75 f7                	jne    80102668 <iderw+0x68>
80102671:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
80102674:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80102676:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
8010267c:	74 42                	je     801026c0 <iderw+0xc0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010267e:	8b 03                	mov    (%ebx),%eax
80102680:	83 e0 06             	and    $0x6,%eax
80102683:	83 f8 02             	cmp    $0x2,%eax
80102686:	74 23                	je     801026ab <iderw+0xab>
80102688:	90                   	nop
80102689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(b, &idelock);
80102690:	83 ec 08             	sub    $0x8,%esp
80102693:	68 80 b5 10 80       	push   $0x8010b580
80102698:	53                   	push   %ebx
80102699:	e8 92 1b 00 00       	call   80104230 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010269e:	8b 03                	mov    (%ebx),%eax
801026a0:	83 c4 10             	add    $0x10,%esp
801026a3:	83 e0 06             	and    $0x6,%eax
801026a6:	83 f8 02             	cmp    $0x2,%eax
801026a9:	75 e5                	jne    80102690 <iderw+0x90>
  }


  release(&idelock);
801026ab:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
801026b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026b5:	c9                   	leave  
  release(&idelock);
801026b6:	e9 d5 23 00 00       	jmp    80104a90 <release>
801026bb:	90                   	nop
801026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    idestart(b);
801026c0:	89 d8                	mov    %ebx,%eax
801026c2:	e8 49 fd ff ff       	call   80102410 <idestart>
801026c7:	eb b5                	jmp    8010267e <iderw+0x7e>
801026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801026d0:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
801026d5:	eb 9d                	jmp    80102674 <iderw+0x74>
    panic("iderw: nothing to do");
801026d7:	83 ec 0c             	sub    $0xc,%esp
801026da:	68 ec 7d 10 80       	push   $0x80107dec
801026df:	e8 1c e0 ff ff       	call   80100700 <panic>
    panic("iderw: buf not locked");
801026e4:	83 ec 0c             	sub    $0xc,%esp
801026e7:	68 d6 7d 10 80       	push   $0x80107dd6
801026ec:	e8 0f e0 ff ff       	call   80100700 <panic>
    panic("iderw: ide disk 1 not present");
801026f1:	83 ec 0c             	sub    $0xc,%esp
801026f4:	68 01 7e 10 80       	push   $0x80107e01
801026f9:	e8 02 e0 ff ff       	call   80100700 <panic>
801026fe:	66 90                	xchg   %ax,%ax

80102700 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102700:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102701:	c7 05 34 36 11 80 00 	movl   $0xfec00000,0x80113634
80102708:	00 c0 fe 
{
8010270b:	89 e5                	mov    %esp,%ebp
8010270d:	56                   	push   %esi
8010270e:	53                   	push   %ebx
  ioapic->reg = reg;
8010270f:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80102716:	00 00 00 
  return ioapic->data;
80102719:	a1 34 36 11 80       	mov    0x80113634,%eax
8010271e:	8b 58 10             	mov    0x10(%eax),%ebx
  ioapic->reg = reg;
80102721:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return ioapic->data;
80102727:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010272d:	0f b6 15 60 37 11 80 	movzbl 0x80113760,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102734:	c1 eb 10             	shr    $0x10,%ebx
  return ioapic->data;
80102737:	8b 41 10             	mov    0x10(%ecx),%eax
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010273a:	0f b6 db             	movzbl %bl,%ebx
  id = ioapicread(REG_ID) >> 24;
8010273d:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102740:	39 c2                	cmp    %eax,%edx
80102742:	74 16                	je     8010275a <ioapicinit+0x5a>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102744:	83 ec 0c             	sub    $0xc,%esp
80102747:	68 20 7e 10 80       	push   $0x80107e20
8010274c:	e8 7f e2 ff ff       	call   801009d0 <cprintf>
80102751:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
80102757:	83 c4 10             	add    $0x10,%esp
8010275a:	83 c3 21             	add    $0x21,%ebx
{
8010275d:	ba 10 00 00 00       	mov    $0x10,%edx
80102762:	b8 20 00 00 00       	mov    $0x20,%eax
80102767:	89 f6                	mov    %esi,%esi
80102769:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  ioapic->reg = reg;
80102770:	89 11                	mov    %edx,(%ecx)
  ioapic->data = data;
80102772:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102778:	89 c6                	mov    %eax,%esi
8010277a:	81 ce 00 00 01 00    	or     $0x10000,%esi
80102780:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102783:	89 71 10             	mov    %esi,0x10(%ecx)
80102786:	8d 72 01             	lea    0x1(%edx),%esi
80102789:	83 c2 02             	add    $0x2,%edx
  for(i = 0; i <= maxintr; i++){
8010278c:	39 d8                	cmp    %ebx,%eax
  ioapic->reg = reg;
8010278e:	89 31                	mov    %esi,(%ecx)
  ioapic->data = data;
80102790:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
80102796:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010279d:	75 d1                	jne    80102770 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010279f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801027a2:	5b                   	pop    %ebx
801027a3:	5e                   	pop    %esi
801027a4:	5d                   	pop    %ebp
801027a5:	c3                   	ret    
801027a6:	8d 76 00             	lea    0x0(%esi),%esi
801027a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801027b0 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801027b0:	55                   	push   %ebp
  ioapic->reg = reg;
801027b1:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
{
801027b7:	89 e5                	mov    %esp,%ebp
801027b9:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801027bc:	8d 50 20             	lea    0x20(%eax),%edx
801027bf:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801027c3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801027c5:	8b 0d 34 36 11 80    	mov    0x80113634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801027cb:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801027ce:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801027d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801027d4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801027d6:	a1 34 36 11 80       	mov    0x80113634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801027db:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801027de:	89 50 10             	mov    %edx,0x10(%eax)
}
801027e1:	5d                   	pop    %ebp
801027e2:	c3                   	ret    
801027e3:	66 90                	xchg   %ax,%ax
801027e5:	66 90                	xchg   %ax,%ax
801027e7:	66 90                	xchg   %ax,%ax
801027e9:	66 90                	xchg   %ax,%ax
801027eb:	66 90                	xchg   %ax,%ax
801027ed:	66 90                	xchg   %ax,%ax
801027ef:	90                   	nop

801027f0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801027f0:	55                   	push   %ebp
801027f1:	89 e5                	mov    %esp,%ebp
801027f3:	53                   	push   %ebx
801027f4:	83 ec 04             	sub    $0x4,%esp
801027f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  
  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801027fa:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102800:	75 70                	jne    80102872 <kfree+0x82>
80102802:	81 fb e8 67 11 80    	cmp    $0x801167e8,%ebx
80102808:	72 68                	jb     80102872 <kfree+0x82>
8010280a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102810:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
80102815:	77 5b                	ja     80102872 <kfree+0x82>
    panic("kfree in kalloc.c");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102817:	83 ec 04             	sub    $0x4,%esp
8010281a:	68 00 10 00 00       	push   $0x1000
8010281f:	6a 01                	push   $0x1
80102821:	53                   	push   %ebx
80102822:	e8 c9 22 00 00       	call   80104af0 <memset>

  if(kmem.use_lock)
80102827:	8b 15 74 36 11 80    	mov    0x80113674,%edx
8010282d:	83 c4 10             	add    $0x10,%esp
80102830:	85 d2                	test   %edx,%edx
80102832:	75 2c                	jne    80102860 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102834:	a1 78 36 11 80       	mov    0x80113678,%eax
80102839:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010283b:	a1 74 36 11 80       	mov    0x80113674,%eax
  kmem.freelist = r;
80102840:	89 1d 78 36 11 80    	mov    %ebx,0x80113678
  if(kmem.use_lock)
80102846:	85 c0                	test   %eax,%eax
80102848:	75 06                	jne    80102850 <kfree+0x60>
    release(&kmem.lock);
}
8010284a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010284d:	c9                   	leave  
8010284e:	c3                   	ret    
8010284f:	90                   	nop
    release(&kmem.lock);
80102850:	c7 45 08 40 36 11 80 	movl   $0x80113640,0x8(%ebp)
}
80102857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010285a:	c9                   	leave  
    release(&kmem.lock);
8010285b:	e9 30 22 00 00       	jmp    80104a90 <release>
    acquire(&kmem.lock);
80102860:	83 ec 0c             	sub    $0xc,%esp
80102863:	68 40 36 11 80       	push   $0x80113640
80102868:	e8 03 21 00 00       	call   80104970 <acquire>
8010286d:	83 c4 10             	add    $0x10,%esp
80102870:	eb c2                	jmp    80102834 <kfree+0x44>
    panic("kfree in kalloc.c");
80102872:	83 ec 0c             	sub    $0xc,%esp
80102875:	68 52 7e 10 80       	push   $0x80107e52
8010287a:	e8 81 de ff ff       	call   80100700 <panic>
8010287f:	90                   	nop

80102880 <freerange>:
{
80102880:	55                   	push   %ebp
80102881:	89 e5                	mov    %esp,%ebp
80102883:	56                   	push   %esi
80102884:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102885:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102888:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010288b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102891:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102897:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010289d:	39 de                	cmp    %ebx,%esi
8010289f:	72 23                	jb     801028c4 <freerange+0x44>
801028a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801028a8:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801028ae:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801028b7:	50                   	push   %eax
801028b8:	e8 33 ff ff ff       	call   801027f0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028bd:	83 c4 10             	add    $0x10,%esp
801028c0:	39 f3                	cmp    %esi,%ebx
801028c2:	76 e4                	jbe    801028a8 <freerange+0x28>
}
801028c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801028c7:	5b                   	pop    %ebx
801028c8:	5e                   	pop    %esi
801028c9:	5d                   	pop    %ebp
801028ca:	c3                   	ret    
801028cb:	90                   	nop
801028cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801028d0 <kinit1>:
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	56                   	push   %esi
801028d4:	53                   	push   %ebx
801028d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
801028d8:	83 ec 08             	sub    $0x8,%esp
801028db:	68 64 7e 10 80       	push   $0x80107e64
801028e0:	68 40 36 11 80       	push   $0x80113640
801028e5:	e8 96 1f 00 00       	call   80104880 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
801028ea:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801028ed:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801028f0:	c7 05 74 36 11 80 00 	movl   $0x0,0x80113674
801028f7:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
801028fa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102900:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102906:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010290c:	39 de                	cmp    %ebx,%esi
8010290e:	72 1c                	jb     8010292c <kinit1+0x5c>
    kfree(p);
80102910:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
80102916:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102919:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010291f:	50                   	push   %eax
80102920:	e8 cb fe ff ff       	call   801027f0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102925:	83 c4 10             	add    $0x10,%esp
80102928:	39 de                	cmp    %ebx,%esi
8010292a:	73 e4                	jae    80102910 <kinit1+0x40>
}
8010292c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010292f:	5b                   	pop    %ebx
80102930:	5e                   	pop    %esi
80102931:	5d                   	pop    %ebp
80102932:	c3                   	ret    
80102933:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102939:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102940 <kinit2>:
{
80102940:	55                   	push   %ebp
80102941:	89 e5                	mov    %esp,%ebp
80102943:	56                   	push   %esi
80102944:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102945:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102948:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010294b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102951:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102957:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010295d:	39 de                	cmp    %ebx,%esi
8010295f:	72 23                	jb     80102984 <kinit2+0x44>
80102961:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102968:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
8010296e:	83 ec 0c             	sub    $0xc,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102971:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102977:	50                   	push   %eax
80102978:	e8 73 fe ff ff       	call   801027f0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010297d:	83 c4 10             	add    $0x10,%esp
80102980:	39 de                	cmp    %ebx,%esi
80102982:	73 e4                	jae    80102968 <kinit2+0x28>
  kmem.use_lock = 1;
80102984:	c7 05 74 36 11 80 01 	movl   $0x1,0x80113674
8010298b:	00 00 00 
}
8010298e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102991:	5b                   	pop    %ebx
80102992:	5e                   	pop    %esi
80102993:	5d                   	pop    %ebp
80102994:	c3                   	ret    
80102995:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102999:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801029a0 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
801029a0:	a1 74 36 11 80       	mov    0x80113674,%eax
801029a5:	85 c0                	test   %eax,%eax
801029a7:	75 1f                	jne    801029c8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
801029a9:	a1 78 36 11 80       	mov    0x80113678,%eax
  if(r)
801029ae:	85 c0                	test   %eax,%eax
801029b0:	74 0e                	je     801029c0 <kalloc+0x20>
    kmem.freelist = r->next;
801029b2:	8b 10                	mov    (%eax),%edx
801029b4:	89 15 78 36 11 80    	mov    %edx,0x80113678
801029ba:	c3                   	ret    
801029bb:	90                   	nop
801029bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}
801029c0:	f3 c3                	repz ret 
801029c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
{
801029c8:	55                   	push   %ebp
801029c9:	89 e5                	mov    %esp,%ebp
801029cb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801029ce:	68 40 36 11 80       	push   $0x80113640
801029d3:	e8 98 1f 00 00       	call   80104970 <acquire>
  r = kmem.freelist;
801029d8:	a1 78 36 11 80       	mov    0x80113678,%eax
  if(r)
801029dd:	83 c4 10             	add    $0x10,%esp
801029e0:	8b 15 74 36 11 80    	mov    0x80113674,%edx
801029e6:	85 c0                	test   %eax,%eax
801029e8:	74 08                	je     801029f2 <kalloc+0x52>
    kmem.freelist = r->next;
801029ea:	8b 08                	mov    (%eax),%ecx
801029ec:	89 0d 78 36 11 80    	mov    %ecx,0x80113678
  if(kmem.use_lock)
801029f2:	85 d2                	test   %edx,%edx
801029f4:	74 16                	je     80102a0c <kalloc+0x6c>
    release(&kmem.lock);
801029f6:	83 ec 0c             	sub    $0xc,%esp
801029f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029fc:	68 40 36 11 80       	push   $0x80113640
80102a01:	e8 8a 20 00 00       	call   80104a90 <release>
  return (char*)r;
80102a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
80102a09:	83 c4 10             	add    $0x10,%esp
}
80102a0c:	c9                   	leave  
80102a0d:	c3                   	ret    
80102a0e:	66 90                	xchg   %ax,%ax

80102a10 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a10:	ba 64 00 00 00       	mov    $0x64,%edx
80102a15:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102a16:	a8 01                	test   $0x1,%al
80102a18:	0f 84 c2 00 00 00    	je     80102ae0 <kbdgetc+0xd0>
80102a1e:	ba 60 00 00 00       	mov    $0x60,%edx
80102a23:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102a24:	0f b6 d0             	movzbl %al,%edx
80102a27:	8b 0d b4 b5 10 80    	mov    0x8010b5b4,%ecx

  if(data == 0xE0){
80102a2d:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102a33:	0f 84 7f 00 00 00    	je     80102ab8 <kbdgetc+0xa8>
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
80102a3c:	53                   	push   %ebx
80102a3d:	89 cb                	mov    %ecx,%ebx
80102a3f:	83 e3 40             	and    $0x40,%ebx
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102a42:	84 c0                	test   %al,%al
80102a44:	78 4a                	js     80102a90 <kbdgetc+0x80>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102a46:	85 db                	test   %ebx,%ebx
80102a48:	74 09                	je     80102a53 <kbdgetc+0x43>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102a4a:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102a4d:	83 e1 bf             	and    $0xffffffbf,%ecx
    data |= 0x80;
80102a50:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
80102a53:	0f b6 82 a0 7f 10 80 	movzbl -0x7fef8060(%edx),%eax
80102a5a:	09 c1                	or     %eax,%ecx
  shift ^= togglecode[data];
80102a5c:	0f b6 82 a0 7e 10 80 	movzbl -0x7fef8160(%edx),%eax
80102a63:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102a65:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
80102a67:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102a6d:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102a70:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102a73:	8b 04 85 80 7e 10 80 	mov    -0x7fef8180(,%eax,4),%eax
80102a7a:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102a7e:	74 31                	je     80102ab1 <kbdgetc+0xa1>
    if('a' <= c && c <= 'z')
80102a80:	8d 50 9f             	lea    -0x61(%eax),%edx
80102a83:	83 fa 19             	cmp    $0x19,%edx
80102a86:	77 40                	ja     80102ac8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102a88:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102a8b:	5b                   	pop    %ebx
80102a8c:	5d                   	pop    %ebp
80102a8d:	c3                   	ret    
80102a8e:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
80102a90:	83 e0 7f             	and    $0x7f,%eax
80102a93:	85 db                	test   %ebx,%ebx
80102a95:	0f 44 d0             	cmove  %eax,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102a98:	0f b6 82 a0 7f 10 80 	movzbl -0x7fef8060(%edx),%eax
80102a9f:	83 c8 40             	or     $0x40,%eax
80102aa2:	0f b6 c0             	movzbl %al,%eax
80102aa5:	f7 d0                	not    %eax
80102aa7:	21 c1                	and    %eax,%ecx
    return 0;
80102aa9:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
80102aab:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
80102ab1:	5b                   	pop    %ebx
80102ab2:	5d                   	pop    %ebp
80102ab3:	c3                   	ret    
80102ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    shift |= E0ESC;
80102ab8:	83 c9 40             	or     $0x40,%ecx
    return 0;
80102abb:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102abd:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
    return 0;
80102ac3:	c3                   	ret    
80102ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
80102ac8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
80102acb:	8d 50 20             	lea    0x20(%eax),%edx
}
80102ace:	5b                   	pop    %ebx
      c += 'a' - 'A';
80102acf:	83 f9 1a             	cmp    $0x1a,%ecx
80102ad2:	0f 42 c2             	cmovb  %edx,%eax
}
80102ad5:	5d                   	pop    %ebp
80102ad6:	c3                   	ret    
80102ad7:	89 f6                	mov    %esi,%esi
80102ad9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80102ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102ae5:	c3                   	ret    
80102ae6:	8d 76 00             	lea    0x0(%esi),%esi
80102ae9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102af0 <kbdintr>:

void
kbdintr(void)
{
80102af0:	55                   	push   %ebp
80102af1:	89 e5                	mov    %esp,%ebp
80102af3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102af6:	68 10 2a 10 80       	push   $0x80102a10
80102afb:	e8 80 e0 ff ff       	call   80100b80 <consoleintr>
}
80102b00:	83 c4 10             	add    $0x10,%esp
80102b03:	c9                   	leave  
80102b04:	c3                   	ret    
80102b05:	66 90                	xchg   %ax,%ax
80102b07:	66 90                	xchg   %ax,%ax
80102b09:	66 90                	xchg   %ax,%ax
80102b0b:	66 90                	xchg   %ax,%ax
80102b0d:	66 90                	xchg   %ax,%ax
80102b0f:	90                   	nop

80102b10 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102b10:	a1 7c 36 11 80       	mov    0x8011367c,%eax
{
80102b15:	55                   	push   %ebp
80102b16:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102b18:	85 c0                	test   %eax,%eax
80102b1a:	0f 84 c8 00 00 00    	je     80102be8 <lapicinit+0xd8>
  lapic[index] = value;
80102b20:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102b27:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b2a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b2d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102b34:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b37:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b3a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102b41:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102b44:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b47:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
80102b4e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102b51:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b54:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102b5b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102b5e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b61:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102b68:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102b6b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102b6e:	8b 50 30             	mov    0x30(%eax),%edx
80102b71:	c1 ea 10             	shr    $0x10,%edx
80102b74:	80 fa 03             	cmp    $0x3,%dl
80102b77:	77 77                	ja     80102bf0 <lapicinit+0xe0>
  lapic[index] = value;
80102b79:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102b80:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b83:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b86:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b8d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b90:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b93:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102b9a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b9d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ba0:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102ba7:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102baa:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102bad:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102bb4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102bb7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102bba:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102bc1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102bc4:	8b 50 20             	mov    0x20(%eax),%edx
80102bc7:	89 f6                	mov    %esi,%esi
80102bc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102bd0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102bd6:	80 e6 10             	and    $0x10,%dh
80102bd9:	75 f5                	jne    80102bd0 <lapicinit+0xc0>
  lapic[index] = value;
80102bdb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102be2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102be5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102be8:	5d                   	pop    %ebp
80102be9:	c3                   	ret    
80102bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  lapic[index] = value;
80102bf0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102bf7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102bfa:	8b 50 20             	mov    0x20(%eax),%edx
80102bfd:	e9 77 ff ff ff       	jmp    80102b79 <lapicinit+0x69>
80102c02:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102c09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c10 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102c10:	8b 15 7c 36 11 80    	mov    0x8011367c,%edx
{
80102c16:	55                   	push   %ebp
80102c17:	31 c0                	xor    %eax,%eax
80102c19:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102c1b:	85 d2                	test   %edx,%edx
80102c1d:	74 06                	je     80102c25 <lapicid+0x15>
    return 0;
  return lapic[ID] >> 24;
80102c1f:	8b 42 20             	mov    0x20(%edx),%eax
80102c22:	c1 e8 18             	shr    $0x18,%eax
}
80102c25:	5d                   	pop    %ebp
80102c26:	c3                   	ret    
80102c27:	89 f6                	mov    %esi,%esi
80102c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c30 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102c30:	a1 7c 36 11 80       	mov    0x8011367c,%eax
{
80102c35:	55                   	push   %ebp
80102c36:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102c38:	85 c0                	test   %eax,%eax
80102c3a:	74 0d                	je     80102c49 <lapiceoi+0x19>
  lapic[index] = value;
80102c3c:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102c43:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102c46:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102c49:	5d                   	pop    %ebp
80102c4a:	c3                   	ret    
80102c4b:	90                   	nop
80102c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102c50 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102c50:	55                   	push   %ebp
80102c51:	89 e5                	mov    %esp,%ebp
}
80102c53:	5d                   	pop    %ebp
80102c54:	c3                   	ret    
80102c55:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80102c60 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102c60:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c61:	b8 0f 00 00 00       	mov    $0xf,%eax
80102c66:	ba 70 00 00 00       	mov    $0x70,%edx
80102c6b:	89 e5                	mov    %esp,%ebp
80102c6d:	53                   	push   %ebx
80102c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102c71:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102c74:	ee                   	out    %al,(%dx)
80102c75:	b8 0a 00 00 00       	mov    $0xa,%eax
80102c7a:	ba 71 00 00 00       	mov    $0x71,%edx
80102c7f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102c80:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102c82:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102c85:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102c8b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c8d:	c1 e9 0c             	shr    $0xc,%ecx
  wrv[1] = addr >> 4;
80102c90:	c1 e8 04             	shr    $0x4,%eax
  lapicw(ICRHI, apicid<<24);
80102c93:	89 da                	mov    %ebx,%edx
    lapicw(ICRLO, STARTUP | (addr>>12));
80102c95:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102c98:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102c9e:	a1 7c 36 11 80       	mov    0x8011367c,%eax
80102ca3:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ca9:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102cac:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102cb3:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102cb6:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102cb9:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102cc0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102cc3:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102cc6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ccc:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102ccf:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102cd5:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102cd8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102cde:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102ce1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102ce7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
80102cea:	5b                   	pop    %ebx
80102ceb:	5d                   	pop    %ebp
80102cec:	c3                   	ret    
80102ced:	8d 76 00             	lea    0x0(%esi),%esi

80102cf0 <cmostime>:
  r->year   = cmos_read(YEAR);
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cf0:	55                   	push   %ebp
80102cf1:	b8 0b 00 00 00       	mov    $0xb,%eax
80102cf6:	ba 70 00 00 00       	mov    $0x70,%edx
80102cfb:	89 e5                	mov    %esp,%ebp
80102cfd:	57                   	push   %edi
80102cfe:	56                   	push   %esi
80102cff:	53                   	push   %ebx
80102d00:	83 ec 4c             	sub    $0x4c,%esp
80102d03:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d04:	ba 71 00 00 00       	mov    $0x71,%edx
80102d09:	ec                   	in     (%dx),%al
80102d0a:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d0d:	bb 70 00 00 00       	mov    $0x70,%ebx
80102d12:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102d15:	8d 76 00             	lea    0x0(%esi),%esi
80102d18:	31 c0                	xor    %eax,%eax
80102d1a:	89 da                	mov    %ebx,%edx
80102d1c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d1d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102d22:	89 ca                	mov    %ecx,%edx
80102d24:	ec                   	in     (%dx),%al
80102d25:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d28:	89 da                	mov    %ebx,%edx
80102d2a:	b8 02 00 00 00       	mov    $0x2,%eax
80102d2f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d30:	89 ca                	mov    %ecx,%edx
80102d32:	ec                   	in     (%dx),%al
80102d33:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d36:	89 da                	mov    %ebx,%edx
80102d38:	b8 04 00 00 00       	mov    $0x4,%eax
80102d3d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d3e:	89 ca                	mov    %ecx,%edx
80102d40:	ec                   	in     (%dx),%al
80102d41:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d44:	89 da                	mov    %ebx,%edx
80102d46:	b8 07 00 00 00       	mov    $0x7,%eax
80102d4b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d4c:	89 ca                	mov    %ecx,%edx
80102d4e:	ec                   	in     (%dx),%al
80102d4f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d52:	89 da                	mov    %ebx,%edx
80102d54:	b8 08 00 00 00       	mov    $0x8,%eax
80102d59:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d5a:	89 ca                	mov    %ecx,%edx
80102d5c:	ec                   	in     (%dx),%al
80102d5d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d5f:	89 da                	mov    %ebx,%edx
80102d61:	b8 09 00 00 00       	mov    $0x9,%eax
80102d66:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d67:	89 ca                	mov    %ecx,%edx
80102d69:	ec                   	in     (%dx),%al
80102d6a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d6c:	89 da                	mov    %ebx,%edx
80102d6e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102d73:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d74:	89 ca                	mov    %ecx,%edx
80102d76:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102d77:	84 c0                	test   %al,%al
80102d79:	78 9d                	js     80102d18 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102d7b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102d7f:	89 fa                	mov    %edi,%edx
80102d81:	0f b6 fa             	movzbl %dl,%edi
80102d84:	89 f2                	mov    %esi,%edx
80102d86:	0f b6 f2             	movzbl %dl,%esi
80102d89:	89 7d c8             	mov    %edi,-0x38(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d8c:	89 da                	mov    %ebx,%edx
80102d8e:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102d91:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102d94:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102d98:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102d9b:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102d9f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102da2:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102da6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102da9:	31 c0                	xor    %eax,%eax
80102dab:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dac:	89 ca                	mov    %ecx,%edx
80102dae:	ec                   	in     (%dx),%al
80102daf:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102db2:	89 da                	mov    %ebx,%edx
80102db4:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102db7:	b8 02 00 00 00       	mov    $0x2,%eax
80102dbc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dbd:	89 ca                	mov    %ecx,%edx
80102dbf:	ec                   	in     (%dx),%al
80102dc0:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dc3:	89 da                	mov    %ebx,%edx
80102dc5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102dc8:	b8 04 00 00 00       	mov    $0x4,%eax
80102dcd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dce:	89 ca                	mov    %ecx,%edx
80102dd0:	ec                   	in     (%dx),%al
80102dd1:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dd4:	89 da                	mov    %ebx,%edx
80102dd6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102dd9:	b8 07 00 00 00       	mov    $0x7,%eax
80102dde:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ddf:	89 ca                	mov    %ecx,%edx
80102de1:	ec                   	in     (%dx),%al
80102de2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102de5:	89 da                	mov    %ebx,%edx
80102de7:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102dea:	b8 08 00 00 00       	mov    $0x8,%eax
80102def:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102df0:	89 ca                	mov    %ecx,%edx
80102df2:	ec                   	in     (%dx),%al
80102df3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102df6:	89 da                	mov    %ebx,%edx
80102df8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102dfb:	b8 09 00 00 00       	mov    $0x9,%eax
80102e00:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e01:	89 ca                	mov    %ecx,%edx
80102e03:	ec                   	in     (%dx),%al
80102e04:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e07:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102e0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102e0d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102e10:	6a 18                	push   $0x18
80102e12:	50                   	push   %eax
80102e13:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102e16:	50                   	push   %eax
80102e17:	e8 24 1d 00 00       	call   80104b40 <memcmp>
80102e1c:	83 c4 10             	add    $0x10,%esp
80102e1f:	85 c0                	test   %eax,%eax
80102e21:	0f 85 f1 fe ff ff    	jne    80102d18 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102e27:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102e2b:	75 78                	jne    80102ea5 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102e2d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102e30:	89 c2                	mov    %eax,%edx
80102e32:	83 e0 0f             	and    $0xf,%eax
80102e35:	c1 ea 04             	shr    $0x4,%edx
80102e38:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e3b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102e41:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102e44:	89 c2                	mov    %eax,%edx
80102e46:	83 e0 0f             	and    $0xf,%eax
80102e49:	c1 ea 04             	shr    $0x4,%edx
80102e4c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e4f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e52:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102e55:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102e58:	89 c2                	mov    %eax,%edx
80102e5a:	83 e0 0f             	and    $0xf,%eax
80102e5d:	c1 ea 04             	shr    $0x4,%edx
80102e60:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e63:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e66:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102e69:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102e6c:	89 c2                	mov    %eax,%edx
80102e6e:	83 e0 0f             	and    $0xf,%eax
80102e71:	c1 ea 04             	shr    $0x4,%edx
80102e74:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e77:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102e7d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102e80:	89 c2                	mov    %eax,%edx
80102e82:	83 e0 0f             	and    $0xf,%eax
80102e85:	c1 ea 04             	shr    $0x4,%edx
80102e88:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e8b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102e8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102e91:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102e94:	89 c2                	mov    %eax,%edx
80102e96:	83 e0 0f             	and    $0xf,%eax
80102e99:	c1 ea 04             	shr    $0x4,%edx
80102e9c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102e9f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102ea2:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102ea5:	8b 75 08             	mov    0x8(%ebp),%esi
80102ea8:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102eab:	89 06                	mov    %eax,(%esi)
80102ead:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102eb0:	89 46 04             	mov    %eax,0x4(%esi)
80102eb3:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102eb6:	89 46 08             	mov    %eax,0x8(%esi)
80102eb9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102ebc:	89 46 0c             	mov    %eax,0xc(%esi)
80102ebf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102ec2:	89 46 10             	mov    %eax,0x10(%esi)
80102ec5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102ec8:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102ecb:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ed5:	5b                   	pop    %ebx
80102ed6:	5e                   	pop    %esi
80102ed7:	5f                   	pop    %edi
80102ed8:	5d                   	pop    %ebp
80102ed9:	c3                   	ret    
80102eda:	66 90                	xchg   %ax,%ax
80102edc:	66 90                	xchg   %ax,%ax
80102ede:	66 90                	xchg   %ax,%ax

80102ee0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ee0:	8b 0d c8 36 11 80    	mov    0x801136c8,%ecx
80102ee6:	85 c9                	test   %ecx,%ecx
80102ee8:	0f 8e 8a 00 00 00    	jle    80102f78 <install_trans+0x98>
{
80102eee:	55                   	push   %ebp
80102eef:	89 e5                	mov    %esp,%ebp
80102ef1:	57                   	push   %edi
80102ef2:	56                   	push   %esi
80102ef3:	53                   	push   %ebx
  for (tail = 0; tail < log.lh.n; tail++) {
80102ef4:	31 db                	xor    %ebx,%ebx
{
80102ef6:	83 ec 0c             	sub    $0xc,%esp
80102ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102f00:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80102f05:	83 ec 08             	sub    $0x8,%esp
80102f08:	01 d8                	add    %ebx,%eax
80102f0a:	83 c0 01             	add    $0x1,%eax
80102f0d:	50                   	push   %eax
80102f0e:	ff 35 c4 36 11 80    	pushl  0x801136c4
80102f14:	e8 c7 d4 ff ff       	call   801003e0 <bread>
80102f19:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102f1b:	58                   	pop    %eax
80102f1c:	5a                   	pop    %edx
80102f1d:	ff 34 9d cc 36 11 80 	pushl  -0x7feec934(,%ebx,4)
80102f24:	ff 35 c4 36 11 80    	pushl  0x801136c4
  for (tail = 0; tail < log.lh.n; tail++) {
80102f2a:	83 c3 01             	add    $0x1,%ebx
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102f2d:	e8 ae d4 ff ff       	call   801003e0 <bread>
80102f32:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102f34:	8d 47 5c             	lea    0x5c(%edi),%eax
80102f37:	83 c4 0c             	add    $0xc,%esp
80102f3a:	68 00 02 00 00       	push   $0x200
80102f3f:	50                   	push   %eax
80102f40:	8d 46 5c             	lea    0x5c(%esi),%eax
80102f43:	50                   	push   %eax
80102f44:	e8 57 1c 00 00       	call   80104ba0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102f49:	89 34 24             	mov    %esi,(%esp)
80102f4c:	e8 cf d4 ff ff       	call   80100420 <bwrite>
    brelse(lbuf);
80102f51:	89 3c 24             	mov    %edi,(%esp)
80102f54:	e8 07 d5 ff ff       	call   80100460 <brelse>
    brelse(dbuf);
80102f59:	89 34 24             	mov    %esi,(%esp)
80102f5c:	e8 ff d4 ff ff       	call   80100460 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102f61:	83 c4 10             	add    $0x10,%esp
80102f64:	39 1d c8 36 11 80    	cmp    %ebx,0x801136c8
80102f6a:	7f 94                	jg     80102f00 <install_trans+0x20>
  }
}
80102f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f6f:	5b                   	pop    %ebx
80102f70:	5e                   	pop    %esi
80102f71:	5f                   	pop    %edi
80102f72:	5d                   	pop    %ebp
80102f73:	c3                   	ret    
80102f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102f78:	f3 c3                	repz ret 
80102f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102f80 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f80:	55                   	push   %ebp
80102f81:	89 e5                	mov    %esp,%ebp
80102f83:	56                   	push   %esi
80102f84:	53                   	push   %ebx
  struct buf *buf = bread(log.dev, log.start);
80102f85:	83 ec 08             	sub    $0x8,%esp
80102f88:	ff 35 b4 36 11 80    	pushl  0x801136b4
80102f8e:	ff 35 c4 36 11 80    	pushl  0x801136c4
80102f94:	e8 47 d4 ff ff       	call   801003e0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102f99:	8b 1d c8 36 11 80    	mov    0x801136c8,%ebx
  for (i = 0; i < log.lh.n; i++) {
80102f9f:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102fa2:	89 c6                	mov    %eax,%esi
  for (i = 0; i < log.lh.n; i++) {
80102fa4:	85 db                	test   %ebx,%ebx
  hb->n = log.lh.n;
80102fa6:	89 58 5c             	mov    %ebx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fa9:	7e 16                	jle    80102fc1 <write_head+0x41>
80102fab:	c1 e3 02             	shl    $0x2,%ebx
80102fae:	31 d2                	xor    %edx,%edx
    hb->block[i] = log.lh.block[i];
80102fb0:	8b 8a cc 36 11 80    	mov    -0x7feec934(%edx),%ecx
80102fb6:	89 4c 16 60          	mov    %ecx,0x60(%esi,%edx,1)
80102fba:	83 c2 04             	add    $0x4,%edx
  for (i = 0; i < log.lh.n; i++) {
80102fbd:	39 da                	cmp    %ebx,%edx
80102fbf:	75 ef                	jne    80102fb0 <write_head+0x30>
  }
  bwrite(buf);
80102fc1:	83 ec 0c             	sub    $0xc,%esp
80102fc4:	56                   	push   %esi
80102fc5:	e8 56 d4 ff ff       	call   80100420 <bwrite>
  brelse(buf);
80102fca:	89 34 24             	mov    %esi,(%esp)
80102fcd:	e8 8e d4 ff ff       	call   80100460 <brelse>
}
80102fd2:	83 c4 10             	add    $0x10,%esp
80102fd5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102fd8:	5b                   	pop    %ebx
80102fd9:	5e                   	pop    %esi
80102fda:	5d                   	pop    %ebp
80102fdb:	c3                   	ret    
80102fdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102fe0 <initlog>:
{
80102fe0:	55                   	push   %ebp
80102fe1:	89 e5                	mov    %esp,%ebp
80102fe3:	53                   	push   %ebx
80102fe4:	83 ec 2c             	sub    $0x2c,%esp
80102fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102fea:	68 a0 80 10 80       	push   $0x801080a0
80102fef:	68 80 36 11 80       	push   $0x80113680
80102ff4:	e8 87 18 00 00       	call   80104880 <initlock>
  readsb(dev, &sb);
80102ff9:	58                   	pop    %eax
80102ffa:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102ffd:	5a                   	pop    %edx
80102ffe:	50                   	push   %eax
80102fff:	53                   	push   %ebx
80103000:	e8 4b e7 ff ff       	call   80101750 <readsb>
  log.size = sb.nlog;
80103005:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80103008:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
8010300b:	59                   	pop    %ecx
  log.dev = dev;
8010300c:	89 1d c4 36 11 80    	mov    %ebx,0x801136c4
  log.size = sb.nlog;
80103012:	89 15 b8 36 11 80    	mov    %edx,0x801136b8
  log.start = sb.logstart;
80103018:	a3 b4 36 11 80       	mov    %eax,0x801136b4
  struct buf *buf = bread(log.dev, log.start);
8010301d:	5a                   	pop    %edx
8010301e:	50                   	push   %eax
8010301f:	53                   	push   %ebx
80103020:	e8 bb d3 ff ff       	call   801003e0 <bread>
  log.lh.n = lh->n;
80103025:	8b 58 5c             	mov    0x5c(%eax),%ebx
  for (i = 0; i < log.lh.n; i++) {
80103028:	83 c4 10             	add    $0x10,%esp
8010302b:	85 db                	test   %ebx,%ebx
  log.lh.n = lh->n;
8010302d:	89 1d c8 36 11 80    	mov    %ebx,0x801136c8
  for (i = 0; i < log.lh.n; i++) {
80103033:	7e 1c                	jle    80103051 <initlog+0x71>
80103035:	c1 e3 02             	shl    $0x2,%ebx
80103038:	31 d2                	xor    %edx,%edx
8010303a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    log.lh.block[i] = lh->block[i];
80103040:	8b 4c 10 60          	mov    0x60(%eax,%edx,1),%ecx
80103044:	83 c2 04             	add    $0x4,%edx
80103047:	89 8a c8 36 11 80    	mov    %ecx,-0x7feec938(%edx)
  for (i = 0; i < log.lh.n; i++) {
8010304d:	39 d3                	cmp    %edx,%ebx
8010304f:	75 ef                	jne    80103040 <initlog+0x60>
  brelse(buf);
80103051:	83 ec 0c             	sub    $0xc,%esp
80103054:	50                   	push   %eax
80103055:	e8 06 d4 ff ff       	call   80100460 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
8010305a:	e8 81 fe ff ff       	call   80102ee0 <install_trans>
  log.lh.n = 0;
8010305f:	c7 05 c8 36 11 80 00 	movl   $0x0,0x801136c8
80103066:	00 00 00 
  write_head(); // clear the log
80103069:	e8 12 ff ff ff       	call   80102f80 <write_head>
}
8010306e:	83 c4 10             	add    $0x10,%esp
80103071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103074:	c9                   	leave  
80103075:	c3                   	ret    
80103076:	8d 76 00             	lea    0x0(%esi),%esi
80103079:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103080 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80103080:	55                   	push   %ebp
80103081:	89 e5                	mov    %esp,%ebp
80103083:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80103086:	68 80 36 11 80       	push   $0x80113680
8010308b:	e8 e0 18 00 00       	call   80104970 <acquire>
80103090:	83 c4 10             	add    $0x10,%esp
80103093:	eb 18                	jmp    801030ad <begin_op+0x2d>
80103095:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80103098:	83 ec 08             	sub    $0x8,%esp
8010309b:	68 80 36 11 80       	push   $0x80113680
801030a0:	68 80 36 11 80       	push   $0x80113680
801030a5:	e8 86 11 00 00       	call   80104230 <sleep>
801030aa:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801030ad:	a1 c0 36 11 80       	mov    0x801136c0,%eax
801030b2:	85 c0                	test   %eax,%eax
801030b4:	75 e2                	jne    80103098 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801030b6:	a1 bc 36 11 80       	mov    0x801136bc,%eax
801030bb:	8b 15 c8 36 11 80    	mov    0x801136c8,%edx
801030c1:	83 c0 01             	add    $0x1,%eax
801030c4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801030c7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
801030ca:	83 fa 1e             	cmp    $0x1e,%edx
801030cd:	7f c9                	jg     80103098 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
801030cf:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
801030d2:	a3 bc 36 11 80       	mov    %eax,0x801136bc
      release(&log.lock);
801030d7:	68 80 36 11 80       	push   $0x80113680
801030dc:	e8 af 19 00 00       	call   80104a90 <release>
      break;
    }
  }
}
801030e1:	83 c4 10             	add    $0x10,%esp
801030e4:	c9                   	leave  
801030e5:	c3                   	ret    
801030e6:	8d 76 00             	lea    0x0(%esi),%esi
801030e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801030f0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030f0:	55                   	push   %ebp
801030f1:	89 e5                	mov    %esp,%ebp
801030f3:	57                   	push   %edi
801030f4:	56                   	push   %esi
801030f5:	53                   	push   %ebx
801030f6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
801030f9:	68 80 36 11 80       	push   $0x80113680
801030fe:	e8 6d 18 00 00       	call   80104970 <acquire>
  log.outstanding -= 1;
80103103:	a1 bc 36 11 80       	mov    0x801136bc,%eax
  if(log.committing)
80103108:	8b 35 c0 36 11 80    	mov    0x801136c0,%esi
8010310e:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103111:	8d 58 ff             	lea    -0x1(%eax),%ebx
  if(log.committing)
80103114:	85 f6                	test   %esi,%esi
  log.outstanding -= 1;
80103116:	89 1d bc 36 11 80    	mov    %ebx,0x801136bc
  if(log.committing)
8010311c:	0f 85 1a 01 00 00    	jne    8010323c <end_op+0x14c>
    panic("log.committing");
  if(log.outstanding == 0){
80103122:	85 db                	test   %ebx,%ebx
80103124:	0f 85 ee 00 00 00    	jne    80103218 <end_op+0x128>
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
8010312a:	83 ec 0c             	sub    $0xc,%esp
    log.committing = 1;
8010312d:	c7 05 c0 36 11 80 01 	movl   $0x1,0x801136c0
80103134:	00 00 00 
  release(&log.lock);
80103137:	68 80 36 11 80       	push   $0x80113680
8010313c:	e8 4f 19 00 00       	call   80104a90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80103141:	8b 0d c8 36 11 80    	mov    0x801136c8,%ecx
80103147:	83 c4 10             	add    $0x10,%esp
8010314a:	85 c9                	test   %ecx,%ecx
8010314c:	0f 8e 85 00 00 00    	jle    801031d7 <end_op+0xe7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103152:	a1 b4 36 11 80       	mov    0x801136b4,%eax
80103157:	83 ec 08             	sub    $0x8,%esp
8010315a:	01 d8                	add    %ebx,%eax
8010315c:	83 c0 01             	add    $0x1,%eax
8010315f:	50                   	push   %eax
80103160:	ff 35 c4 36 11 80    	pushl  0x801136c4
80103166:	e8 75 d2 ff ff       	call   801003e0 <bread>
8010316b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010316d:	58                   	pop    %eax
8010316e:	5a                   	pop    %edx
8010316f:	ff 34 9d cc 36 11 80 	pushl  -0x7feec934(,%ebx,4)
80103176:	ff 35 c4 36 11 80    	pushl  0x801136c4
  for (tail = 0; tail < log.lh.n; tail++) {
8010317c:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010317f:	e8 5c d2 ff ff       	call   801003e0 <bread>
80103184:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103186:	8d 40 5c             	lea    0x5c(%eax),%eax
80103189:	83 c4 0c             	add    $0xc,%esp
8010318c:	68 00 02 00 00       	push   $0x200
80103191:	50                   	push   %eax
80103192:	8d 46 5c             	lea    0x5c(%esi),%eax
80103195:	50                   	push   %eax
80103196:	e8 05 1a 00 00       	call   80104ba0 <memmove>
    bwrite(to);  // write the log
8010319b:	89 34 24             	mov    %esi,(%esp)
8010319e:	e8 7d d2 ff ff       	call   80100420 <bwrite>
    brelse(from);
801031a3:	89 3c 24             	mov    %edi,(%esp)
801031a6:	e8 b5 d2 ff ff       	call   80100460 <brelse>
    brelse(to);
801031ab:	89 34 24             	mov    %esi,(%esp)
801031ae:	e8 ad d2 ff ff       	call   80100460 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801031b3:	83 c4 10             	add    $0x10,%esp
801031b6:	3b 1d c8 36 11 80    	cmp    0x801136c8,%ebx
801031bc:	7c 94                	jl     80103152 <end_op+0x62>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
801031be:	e8 bd fd ff ff       	call   80102f80 <write_head>
    install_trans(); // Now install writes to home locations
801031c3:	e8 18 fd ff ff       	call   80102ee0 <install_trans>
    log.lh.n = 0;
801031c8:	c7 05 c8 36 11 80 00 	movl   $0x0,0x801136c8
801031cf:	00 00 00 
    write_head();    // Erase the transaction from the log
801031d2:	e8 a9 fd ff ff       	call   80102f80 <write_head>
    acquire(&log.lock);
801031d7:	83 ec 0c             	sub    $0xc,%esp
801031da:	68 80 36 11 80       	push   $0x80113680
801031df:	e8 8c 17 00 00       	call   80104970 <acquire>
    wakeup(&log);
801031e4:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
    log.committing = 0;
801031eb:	c7 05 c0 36 11 80 00 	movl   $0x0,0x801136c0
801031f2:	00 00 00 
    wakeup(&log);
801031f5:	e8 f6 11 00 00       	call   801043f0 <wakeup>
    release(&log.lock);
801031fa:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
80103201:	e8 8a 18 00 00       	call   80104a90 <release>
80103206:	83 c4 10             	add    $0x10,%esp
}
80103209:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010320c:	5b                   	pop    %ebx
8010320d:	5e                   	pop    %esi
8010320e:	5f                   	pop    %edi
8010320f:	5d                   	pop    %ebp
80103210:	c3                   	ret    
80103211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&log);
80103218:	83 ec 0c             	sub    $0xc,%esp
8010321b:	68 80 36 11 80       	push   $0x80113680
80103220:	e8 cb 11 00 00       	call   801043f0 <wakeup>
  release(&log.lock);
80103225:	c7 04 24 80 36 11 80 	movl   $0x80113680,(%esp)
8010322c:	e8 5f 18 00 00       	call   80104a90 <release>
80103231:	83 c4 10             	add    $0x10,%esp
}
80103234:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103237:	5b                   	pop    %ebx
80103238:	5e                   	pop    %esi
80103239:	5f                   	pop    %edi
8010323a:	5d                   	pop    %ebp
8010323b:	c3                   	ret    
    panic("log.committing");
8010323c:	83 ec 0c             	sub    $0xc,%esp
8010323f:	68 a4 80 10 80       	push   $0x801080a4
80103244:	e8 b7 d4 ff ff       	call   80100700 <panic>
80103249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103250 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103250:	55                   	push   %ebp
80103251:	89 e5                	mov    %esp,%ebp
80103253:	53                   	push   %ebx
80103254:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103257:	8b 15 c8 36 11 80    	mov    0x801136c8,%edx
{
8010325d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103260:	83 fa 1d             	cmp    $0x1d,%edx
80103263:	0f 8f 9d 00 00 00    	jg     80103306 <log_write+0xb6>
80103269:	a1 b8 36 11 80       	mov    0x801136b8,%eax
8010326e:	83 e8 01             	sub    $0x1,%eax
80103271:	39 c2                	cmp    %eax,%edx
80103273:	0f 8d 8d 00 00 00    	jge    80103306 <log_write+0xb6>
    panic("too big a transaction");
  if (log.outstanding < 1)
80103279:	a1 bc 36 11 80       	mov    0x801136bc,%eax
8010327e:	85 c0                	test   %eax,%eax
80103280:	0f 8e 8d 00 00 00    	jle    80103313 <log_write+0xc3>
    panic("log_write outside of trans");

  acquire(&log.lock);
80103286:	83 ec 0c             	sub    $0xc,%esp
80103289:	68 80 36 11 80       	push   $0x80113680
8010328e:	e8 dd 16 00 00       	call   80104970 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103293:	8b 0d c8 36 11 80    	mov    0x801136c8,%ecx
80103299:	83 c4 10             	add    $0x10,%esp
8010329c:	83 f9 00             	cmp    $0x0,%ecx
8010329f:	7e 57                	jle    801032f8 <log_write+0xa8>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032a1:	8b 53 08             	mov    0x8(%ebx),%edx
  for (i = 0; i < log.lh.n; i++) {
801032a4:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032a6:	3b 15 cc 36 11 80    	cmp    0x801136cc,%edx
801032ac:	75 0b                	jne    801032b9 <log_write+0x69>
801032ae:	eb 38                	jmp    801032e8 <log_write+0x98>
801032b0:	39 14 85 cc 36 11 80 	cmp    %edx,-0x7feec934(,%eax,4)
801032b7:	74 2f                	je     801032e8 <log_write+0x98>
  for (i = 0; i < log.lh.n; i++) {
801032b9:	83 c0 01             	add    $0x1,%eax
801032bc:	39 c1                	cmp    %eax,%ecx
801032be:	75 f0                	jne    801032b0 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
801032c0:	89 14 85 cc 36 11 80 	mov    %edx,-0x7feec934(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
801032c7:	83 c0 01             	add    $0x1,%eax
801032ca:	a3 c8 36 11 80       	mov    %eax,0x801136c8
  b->flags |= B_DIRTY; // prevent eviction
801032cf:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801032d2:	c7 45 08 80 36 11 80 	movl   $0x80113680,0x8(%ebp)
}
801032d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032dc:	c9                   	leave  
  release(&log.lock);
801032dd:	e9 ae 17 00 00       	jmp    80104a90 <release>
801032e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
801032e8:	89 14 85 cc 36 11 80 	mov    %edx,-0x7feec934(,%eax,4)
801032ef:	eb de                	jmp    801032cf <log_write+0x7f>
801032f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801032f8:	8b 43 08             	mov    0x8(%ebx),%eax
801032fb:	a3 cc 36 11 80       	mov    %eax,0x801136cc
  if (i == log.lh.n)
80103300:	75 cd                	jne    801032cf <log_write+0x7f>
80103302:	31 c0                	xor    %eax,%eax
80103304:	eb c1                	jmp    801032c7 <log_write+0x77>
    panic("too big a transaction");
80103306:	83 ec 0c             	sub    $0xc,%esp
80103309:	68 b3 80 10 80       	push   $0x801080b3
8010330e:	e8 ed d3 ff ff       	call   80100700 <panic>
    panic("log_write outside of trans");
80103313:	83 ec 0c             	sub    $0xc,%esp
80103316:	68 c9 80 10 80       	push   $0x801080c9
8010331b:	e8 e0 d3 ff ff       	call   80100700 <panic>

80103320 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103320:	55                   	push   %ebp
80103321:	89 e5                	mov    %esp,%ebp
80103323:	53                   	push   %ebx
80103324:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103327:	e8 74 09 00 00       	call   80103ca0 <cpuid>
8010332c:	89 c3                	mov    %eax,%ebx
8010332e:	e8 6d 09 00 00       	call   80103ca0 <cpuid>
80103333:	83 ec 04             	sub    $0x4,%esp
80103336:	53                   	push   %ebx
80103337:	50                   	push   %eax
80103338:	68 e4 80 10 80       	push   $0x801080e4
8010333d:	e8 8e d6 ff ff       	call   801009d0 <cprintf>
  idtinit();       // load idt register
80103342:	e8 f9 2a 00 00       	call   80105e40 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103347:	e8 d4 08 00 00       	call   80103c20 <mycpu>
8010334c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010334e:	b8 01 00 00 00       	mov    $0x1,%eax
80103353:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010335a:	e8 f1 0b 00 00       	call   80103f50 <scheduler>
8010335f:	90                   	nop

80103360 <mpenter>:
{
80103360:	55                   	push   %ebp
80103361:	89 e5                	mov    %esp,%ebp
80103363:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103366:	e8 f5 3f 00 00       	call   80107360 <switchkvm>
  seginit();
8010336b:	e8 60 3f 00 00       	call   801072d0 <seginit>
  lapicinit();
80103370:	e8 9b f7 ff ff       	call   80102b10 <lapicinit>
  mpmain();
80103375:	e8 a6 ff ff ff       	call   80103320 <mpmain>
8010337a:	66 90                	xchg   %ax,%ax
8010337c:	66 90                	xchg   %ax,%ax
8010337e:	66 90                	xchg   %ax,%ax

80103380 <main>:
{
80103380:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103384:	83 e4 f0             	and    $0xfffffff0,%esp
80103387:	ff 71 fc             	pushl  -0x4(%ecx)
8010338a:	55                   	push   %ebp
8010338b:	89 e5                	mov    %esp,%ebp
8010338d:	53                   	push   %ebx
8010338e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010338f:	83 ec 08             	sub    $0x8,%esp
80103392:	68 00 00 40 80       	push   $0x80400000
80103397:	68 e8 67 11 80       	push   $0x801167e8
8010339c:	e8 2f f5 ff ff       	call   801028d0 <kinit1>
  kvmalloc();      // kernel page table
801033a1:	e8 5a 44 00 00       	call   80107800 <kvmalloc>
  mpinit();        // detect other processors
801033a6:	e8 75 01 00 00       	call   80103520 <mpinit>
  lapicinit();     // interrupt controller
801033ab:	e8 60 f7 ff ff       	call   80102b10 <lapicinit>
  seginit();       // segment descriptors
801033b0:	e8 1b 3f 00 00       	call   801072d0 <seginit>
  picinit();       // disable pic
801033b5:	e8 46 03 00 00       	call   80103700 <picinit>
  ioapicinit();    // another interrupt controller
801033ba:	e8 41 f3 ff ff       	call   80102700 <ioapicinit>
  consoleinit();   // console hardware
801033bf:	e8 6c d9 ff ff       	call   80100d30 <consoleinit>
  uartinit();      // serial port
801033c4:	e8 b7 31 00 00       	call   80106580 <uartinit>
  pinit();         // process table
801033c9:	e8 32 08 00 00       	call   80103c00 <pinit>
  tvinit();        // trap vectors
801033ce:	e8 ed 29 00 00       	call   80105dc0 <tvinit>
  binit();         // buffer cache
801033d3:	e8 28 cd ff ff       	call   80100100 <binit>
  fileinit();      // file table
801033d8:	e8 f3 dc ff ff       	call   801010d0 <fileinit>
  ideinit();       // disk 
801033dd:	e8 fe f0 ff ff       	call   801024e0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801033e2:	83 c4 0c             	add    $0xc,%esp
801033e5:	68 8a 00 00 00       	push   $0x8a
801033ea:	68 8c b4 10 80       	push   $0x8010b48c
801033ef:	68 00 70 00 80       	push   $0x80007000
801033f4:	e8 a7 17 00 00       	call   80104ba0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801033f9:	69 05 00 3d 11 80 b0 	imul   $0xb0,0x80113d00,%eax
80103400:	00 00 00 
80103403:	83 c4 10             	add    $0x10,%esp
80103406:	05 80 37 11 80       	add    $0x80113780,%eax
8010340b:	3d 80 37 11 80       	cmp    $0x80113780,%eax
80103410:	76 71                	jbe    80103483 <main+0x103>
80103412:	bb 80 37 11 80       	mov    $0x80113780,%ebx
80103417:	89 f6                	mov    %esi,%esi
80103419:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    if(c == mycpu())  // We've started already.
80103420:	e8 fb 07 00 00       	call   80103c20 <mycpu>
80103425:	39 d8                	cmp    %ebx,%eax
80103427:	74 41                	je     8010346a <main+0xea>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103429:	e8 72 f5 ff ff       	call   801029a0 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
8010342e:	05 00 10 00 00       	add    $0x1000,%eax
    *(void**)(code-8) = mpenter;
80103433:	c7 05 f8 6f 00 80 60 	movl   $0x80103360,0x80006ff8
8010343a:	33 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010343d:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
80103444:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
80103447:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc

    lapicstartap(c->apicid, V2P(code));
8010344c:	0f b6 03             	movzbl (%ebx),%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	68 00 70 00 00       	push   $0x7000
80103457:	50                   	push   %eax
80103458:	e8 03 f8 ff ff       	call   80102c60 <lapicstartap>
8010345d:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103460:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103466:	85 c0                	test   %eax,%eax
80103468:	74 f6                	je     80103460 <main+0xe0>
  for(c = cpus; c < cpus+ncpu; c++){
8010346a:	69 05 00 3d 11 80 b0 	imul   $0xb0,0x80113d00,%eax
80103471:	00 00 00 
80103474:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
8010347a:	05 80 37 11 80       	add    $0x80113780,%eax
8010347f:	39 c3                	cmp    %eax,%ebx
80103481:	72 9d                	jb     80103420 <main+0xa0>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103483:	83 ec 08             	sub    $0x8,%esp
80103486:	68 00 00 40 80       	push   $0x80400000
8010348b:	68 00 00 40 80       	push   $0x80400000
80103490:	e8 ab f4 ff ff       	call   80102940 <kinit2>
  userinit();      // first user process
80103495:	e8 56 08 00 00       	call   80103cf0 <userinit>
  mpmain();        // finish this processor's setup
8010349a:	e8 81 fe ff ff       	call   80103320 <mpmain>
8010349f:	90                   	nop

801034a0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801034a0:	55                   	push   %ebp
801034a1:	89 e5                	mov    %esp,%ebp
801034a3:	57                   	push   %edi
801034a4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
801034a5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
801034ab:	53                   	push   %ebx
  e = addr+len;
801034ac:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
801034af:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801034b2:	39 de                	cmp    %ebx,%esi
801034b4:	72 10                	jb     801034c6 <mpsearch1+0x26>
801034b6:	eb 50                	jmp    80103508 <mpsearch1+0x68>
801034b8:	90                   	nop
801034b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801034c0:	39 fb                	cmp    %edi,%ebx
801034c2:	89 fe                	mov    %edi,%esi
801034c4:	76 42                	jbe    80103508 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034c6:	83 ec 04             	sub    $0x4,%esp
801034c9:	8d 7e 10             	lea    0x10(%esi),%edi
801034cc:	6a 04                	push   $0x4
801034ce:	68 f8 80 10 80       	push   $0x801080f8
801034d3:	56                   	push   %esi
801034d4:	e8 67 16 00 00       	call   80104b40 <memcmp>
801034d9:	83 c4 10             	add    $0x10,%esp
801034dc:	85 c0                	test   %eax,%eax
801034de:	75 e0                	jne    801034c0 <mpsearch1+0x20>
801034e0:	89 f1                	mov    %esi,%ecx
801034e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801034e8:	0f b6 11             	movzbl (%ecx),%edx
801034eb:	83 c1 01             	add    $0x1,%ecx
801034ee:	01 d0                	add    %edx,%eax
  for(i=0; i<len; i++)
801034f0:	39 f9                	cmp    %edi,%ecx
801034f2:	75 f4                	jne    801034e8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801034f4:	84 c0                	test   %al,%al
801034f6:	75 c8                	jne    801034c0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801034f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034fb:	89 f0                	mov    %esi,%eax
801034fd:	5b                   	pop    %ebx
801034fe:	5e                   	pop    %esi
801034ff:	5f                   	pop    %edi
80103500:	5d                   	pop    %ebp
80103501:	c3                   	ret    
80103502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103508:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010350b:	31 f6                	xor    %esi,%esi
}
8010350d:	89 f0                	mov    %esi,%eax
8010350f:	5b                   	pop    %ebx
80103510:	5e                   	pop    %esi
80103511:	5f                   	pop    %edi
80103512:	5d                   	pop    %ebp
80103513:	c3                   	ret    
80103514:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010351a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103520 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103520:	55                   	push   %ebp
80103521:	89 e5                	mov    %esp,%ebp
80103523:	57                   	push   %edi
80103524:	56                   	push   %esi
80103525:	53                   	push   %ebx
80103526:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103529:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103530:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103537:	c1 e0 08             	shl    $0x8,%eax
8010353a:	09 d0                	or     %edx,%eax
8010353c:	c1 e0 04             	shl    $0x4,%eax
8010353f:	85 c0                	test   %eax,%eax
80103541:	75 1b                	jne    8010355e <mpinit+0x3e>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103543:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010354a:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103551:	c1 e0 08             	shl    $0x8,%eax
80103554:	09 d0                	or     %edx,%eax
80103556:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103559:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010355e:	ba 00 04 00 00       	mov    $0x400,%edx
80103563:	e8 38 ff ff ff       	call   801034a0 <mpsearch1>
80103568:	85 c0                	test   %eax,%eax
8010356a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010356d:	0f 84 3d 01 00 00    	je     801036b0 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103576:	8b 58 04             	mov    0x4(%eax),%ebx
80103579:	85 db                	test   %ebx,%ebx
8010357b:	0f 84 4f 01 00 00    	je     801036d0 <mpinit+0x1b0>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103581:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80103587:	83 ec 04             	sub    $0x4,%esp
8010358a:	6a 04                	push   $0x4
8010358c:	68 15 81 10 80       	push   $0x80108115
80103591:	56                   	push   %esi
80103592:	e8 a9 15 00 00       	call   80104b40 <memcmp>
80103597:	83 c4 10             	add    $0x10,%esp
8010359a:	85 c0                	test   %eax,%eax
8010359c:	0f 85 2e 01 00 00    	jne    801036d0 <mpinit+0x1b0>
  if(conf->version != 1 && conf->version != 4)
801035a2:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
801035a9:	3c 01                	cmp    $0x1,%al
801035ab:	0f 95 c2             	setne  %dl
801035ae:	3c 04                	cmp    $0x4,%al
801035b0:	0f 95 c0             	setne  %al
801035b3:	20 c2                	and    %al,%dl
801035b5:	0f 85 15 01 00 00    	jne    801036d0 <mpinit+0x1b0>
  if(sum((uchar*)conf, conf->length) != 0)
801035bb:	0f b7 bb 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edi
  for(i=0; i<len; i++)
801035c2:	66 85 ff             	test   %di,%di
801035c5:	74 1a                	je     801035e1 <mpinit+0xc1>
801035c7:	89 f0                	mov    %esi,%eax
801035c9:	01 f7                	add    %esi,%edi
  sum = 0;
801035cb:	31 d2                	xor    %edx,%edx
801035cd:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801035d0:	0f b6 08             	movzbl (%eax),%ecx
801035d3:	83 c0 01             	add    $0x1,%eax
801035d6:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801035d8:	39 c7                	cmp    %eax,%edi
801035da:	75 f4                	jne    801035d0 <mpinit+0xb0>
801035dc:	84 d2                	test   %dl,%dl
801035de:	0f 95 c2             	setne  %dl
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
801035e1:	85 f6                	test   %esi,%esi
801035e3:	0f 84 e7 00 00 00    	je     801036d0 <mpinit+0x1b0>
801035e9:	84 d2                	test   %dl,%dl
801035eb:	0f 85 df 00 00 00    	jne    801036d0 <mpinit+0x1b0>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801035f1:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801035f7:	a3 7c 36 11 80       	mov    %eax,0x8011367c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801035fc:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80103603:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
  ismp = 1;
80103609:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010360e:	01 d6                	add    %edx,%esi
80103610:	39 c6                	cmp    %eax,%esi
80103612:	76 23                	jbe    80103637 <mpinit+0x117>
    switch(*p){
80103614:	0f b6 10             	movzbl (%eax),%edx
80103617:	80 fa 04             	cmp    $0x4,%dl
8010361a:	0f 87 ca 00 00 00    	ja     801036ea <mpinit+0x1ca>
80103620:	ff 24 95 3c 81 10 80 	jmp    *-0x7fef7ec4(,%edx,4)
80103627:	89 f6                	mov    %esi,%esi
80103629:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103630:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103633:	39 c6                	cmp    %eax,%esi
80103635:	77 dd                	ja     80103614 <mpinit+0xf4>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103637:	85 db                	test   %ebx,%ebx
80103639:	0f 84 9e 00 00 00    	je     801036dd <mpinit+0x1bd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010363f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103642:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80103646:	74 15                	je     8010365d <mpinit+0x13d>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103648:	b8 70 00 00 00       	mov    $0x70,%eax
8010364d:	ba 22 00 00 00       	mov    $0x22,%edx
80103652:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103653:	ba 23 00 00 00       	mov    $0x23,%edx
80103658:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103659:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010365c:	ee                   	out    %al,(%dx)
  }
}
8010365d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103660:	5b                   	pop    %ebx
80103661:	5e                   	pop    %esi
80103662:	5f                   	pop    %edi
80103663:	5d                   	pop    %ebp
80103664:	c3                   	ret    
80103665:	8d 76 00             	lea    0x0(%esi),%esi
      if(ncpu < NCPU) {
80103668:	8b 0d 00 3d 11 80    	mov    0x80113d00,%ecx
8010366e:	83 f9 07             	cmp    $0x7,%ecx
80103671:	7f 19                	jg     8010368c <mpinit+0x16c>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103673:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80103677:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
        ncpu++;
8010367d:	83 c1 01             	add    $0x1,%ecx
80103680:	89 0d 00 3d 11 80    	mov    %ecx,0x80113d00
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103686:	88 97 80 37 11 80    	mov    %dl,-0x7feec880(%edi)
      p += sizeof(struct mpproc);
8010368c:	83 c0 14             	add    $0x14,%eax
      continue;
8010368f:	e9 7c ff ff ff       	jmp    80103610 <mpinit+0xf0>
80103694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103698:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      p += sizeof(struct mpioapic);
8010369c:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
8010369f:	88 15 60 37 11 80    	mov    %dl,0x80113760
      continue;
801036a5:	e9 66 ff ff ff       	jmp    80103610 <mpinit+0xf0>
801036aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return mpsearch1(0xF0000, 0x10000);
801036b0:	ba 00 00 01 00       	mov    $0x10000,%edx
801036b5:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801036ba:	e8 e1 fd ff ff       	call   801034a0 <mpsearch1>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801036bf:	85 c0                	test   %eax,%eax
  return mpsearch1(0xF0000, 0x10000);
801036c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801036c4:	0f 85 a9 fe ff ff    	jne    80103573 <mpinit+0x53>
801036ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    panic("Expect to run on an SMP");
801036d0:	83 ec 0c             	sub    $0xc,%esp
801036d3:	68 fd 80 10 80       	push   $0x801080fd
801036d8:	e8 23 d0 ff ff       	call   80100700 <panic>
    panic("Didn't find a suitable machine");
801036dd:	83 ec 0c             	sub    $0xc,%esp
801036e0:	68 1c 81 10 80       	push   $0x8010811c
801036e5:	e8 16 d0 ff ff       	call   80100700 <panic>
      ismp = 0;
801036ea:	31 db                	xor    %ebx,%ebx
801036ec:	e9 26 ff ff ff       	jmp    80103617 <mpinit+0xf7>
801036f1:	66 90                	xchg   %ax,%ax
801036f3:	66 90                	xchg   %ax,%ax
801036f5:	66 90                	xchg   %ax,%ax
801036f7:	66 90                	xchg   %ax,%ax
801036f9:	66 90                	xchg   %ax,%ax
801036fb:	66 90                	xchg   %ax,%ax
801036fd:	66 90                	xchg   %ax,%ax
801036ff:	90                   	nop

80103700 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103700:	55                   	push   %ebp
80103701:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103706:	ba 21 00 00 00       	mov    $0x21,%edx
8010370b:	89 e5                	mov    %esp,%ebp
8010370d:	ee                   	out    %al,(%dx)
8010370e:	ba a1 00 00 00       	mov    $0xa1,%edx
80103713:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103714:	5d                   	pop    %ebp
80103715:	c3                   	ret    
80103716:	66 90                	xchg   %ax,%ax
80103718:	66 90                	xchg   %ax,%ax
8010371a:	66 90                	xchg   %ax,%ax
8010371c:	66 90                	xchg   %ax,%ax
8010371e:	66 90                	xchg   %ax,%ax

80103720 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103720:	55                   	push   %ebp
80103721:	89 e5                	mov    %esp,%ebp
80103723:	57                   	push   %edi
80103724:	56                   	push   %esi
80103725:	53                   	push   %ebx
80103726:	83 ec 0c             	sub    $0xc,%esp
80103729:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010372c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010372f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103735:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010373b:	e8 b0 d9 ff ff       	call   801010f0 <filealloc>
80103740:	85 c0                	test   %eax,%eax
80103742:	89 03                	mov    %eax,(%ebx)
80103744:	74 22                	je     80103768 <pipealloc+0x48>
80103746:	e8 a5 d9 ff ff       	call   801010f0 <filealloc>
8010374b:	85 c0                	test   %eax,%eax
8010374d:	89 06                	mov    %eax,(%esi)
8010374f:	74 3f                	je     80103790 <pipealloc+0x70>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103751:	e8 4a f2 ff ff       	call   801029a0 <kalloc>
80103756:	85 c0                	test   %eax,%eax
80103758:	89 c7                	mov    %eax,%edi
8010375a:	75 54                	jne    801037b0 <pipealloc+0x90>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
8010375c:	8b 03                	mov    (%ebx),%eax
8010375e:	85 c0                	test   %eax,%eax
80103760:	75 34                	jne    80103796 <pipealloc+0x76>
80103762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    fileclose(*f0);
  if(*f1)
80103768:	8b 06                	mov    (%esi),%eax
8010376a:	85 c0                	test   %eax,%eax
8010376c:	74 0c                	je     8010377a <pipealloc+0x5a>
    fileclose(*f1);
8010376e:	83 ec 0c             	sub    $0xc,%esp
80103771:	50                   	push   %eax
80103772:	e8 39 da ff ff       	call   801011b0 <fileclose>
80103777:	83 c4 10             	add    $0x10,%esp
  return -1;
}
8010377a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010377d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103782:	5b                   	pop    %ebx
80103783:	5e                   	pop    %esi
80103784:	5f                   	pop    %edi
80103785:	5d                   	pop    %ebp
80103786:	c3                   	ret    
80103787:	89 f6                	mov    %esi,%esi
80103789:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  if(*f0)
80103790:	8b 03                	mov    (%ebx),%eax
80103792:	85 c0                	test   %eax,%eax
80103794:	74 e4                	je     8010377a <pipealloc+0x5a>
    fileclose(*f0);
80103796:	83 ec 0c             	sub    $0xc,%esp
80103799:	50                   	push   %eax
8010379a:	e8 11 da ff ff       	call   801011b0 <fileclose>
  if(*f1)
8010379f:	8b 06                	mov    (%esi),%eax
    fileclose(*f0);
801037a1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801037a4:	85 c0                	test   %eax,%eax
801037a6:	75 c6                	jne    8010376e <pipealloc+0x4e>
801037a8:	eb d0                	jmp    8010377a <pipealloc+0x5a>
801037aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  initlock(&p->lock, "pipe");
801037b0:	83 ec 08             	sub    $0x8,%esp
  p->readopen = 1;
801037b3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801037ba:	00 00 00 
  p->writeopen = 1;
801037bd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801037c4:	00 00 00 
  p->nwrite = 0;
801037c7:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801037ce:	00 00 00 
  p->nread = 0;
801037d1:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801037d8:	00 00 00 
  initlock(&p->lock, "pipe");
801037db:	68 50 81 10 80       	push   $0x80108150
801037e0:	50                   	push   %eax
801037e1:	e8 9a 10 00 00       	call   80104880 <initlock>
  (*f0)->type = FD_PIPE;
801037e6:	8b 03                	mov    (%ebx),%eax
  return 0;
801037e8:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801037eb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801037f1:	8b 03                	mov    (%ebx),%eax
801037f3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801037f7:	8b 03                	mov    (%ebx),%eax
801037f9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801037fd:	8b 03                	mov    (%ebx),%eax
801037ff:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103802:	8b 06                	mov    (%esi),%eax
80103804:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010380a:	8b 06                	mov    (%esi),%eax
8010380c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103810:	8b 06                	mov    (%esi),%eax
80103812:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103816:	8b 06                	mov    (%esi),%eax
80103818:	89 78 0c             	mov    %edi,0xc(%eax)
}
8010381b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010381e:	31 c0                	xor    %eax,%eax
}
80103820:	5b                   	pop    %ebx
80103821:	5e                   	pop    %esi
80103822:	5f                   	pop    %edi
80103823:	5d                   	pop    %ebp
80103824:	c3                   	ret    
80103825:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103830 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103830:	55                   	push   %ebp
80103831:	89 e5                	mov    %esp,%ebp
80103833:	56                   	push   %esi
80103834:	53                   	push   %ebx
80103835:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103838:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010383b:	83 ec 0c             	sub    $0xc,%esp
8010383e:	53                   	push   %ebx
8010383f:	e8 2c 11 00 00       	call   80104970 <acquire>
  if(writable){
80103844:	83 c4 10             	add    $0x10,%esp
80103847:	85 f6                	test   %esi,%esi
80103849:	74 45                	je     80103890 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
8010384b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103851:	83 ec 0c             	sub    $0xc,%esp
    p->writeopen = 0;
80103854:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010385b:	00 00 00 
    wakeup(&p->nread);
8010385e:	50                   	push   %eax
8010385f:	e8 8c 0b 00 00       	call   801043f0 <wakeup>
80103864:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103867:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010386d:	85 d2                	test   %edx,%edx
8010386f:	75 0a                	jne    8010387b <pipeclose+0x4b>
80103871:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103877:	85 c0                	test   %eax,%eax
80103879:	74 35                	je     801038b0 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010387b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010387e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103881:	5b                   	pop    %ebx
80103882:	5e                   	pop    %esi
80103883:	5d                   	pop    %ebp
    release(&p->lock);
80103884:	e9 07 12 00 00       	jmp    80104a90 <release>
80103889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103890:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103896:	83 ec 0c             	sub    $0xc,%esp
    p->readopen = 0;
80103899:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801038a0:	00 00 00 
    wakeup(&p->nwrite);
801038a3:	50                   	push   %eax
801038a4:	e8 47 0b 00 00       	call   801043f0 <wakeup>
801038a9:	83 c4 10             	add    $0x10,%esp
801038ac:	eb b9                	jmp    80103867 <pipeclose+0x37>
801038ae:	66 90                	xchg   %ax,%ax
    release(&p->lock);
801038b0:	83 ec 0c             	sub    $0xc,%esp
801038b3:	53                   	push   %ebx
801038b4:	e8 d7 11 00 00       	call   80104a90 <release>
    kfree((char*)p);
801038b9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801038bc:	83 c4 10             	add    $0x10,%esp
}
801038bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038c2:	5b                   	pop    %ebx
801038c3:	5e                   	pop    %esi
801038c4:	5d                   	pop    %ebp
    kfree((char*)p);
801038c5:	e9 26 ef ff ff       	jmp    801027f0 <kfree>
801038ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801038d0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801038d0:	55                   	push   %ebp
801038d1:	89 e5                	mov    %esp,%ebp
801038d3:	57                   	push   %edi
801038d4:	56                   	push   %esi
801038d5:	53                   	push   %ebx
801038d6:	83 ec 28             	sub    $0x28,%esp
801038d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801038dc:	53                   	push   %ebx
801038dd:	e8 8e 10 00 00       	call   80104970 <acquire>
  for(i = 0; i < n; i++){
801038e2:	8b 45 10             	mov    0x10(%ebp),%eax
801038e5:	83 c4 10             	add    $0x10,%esp
801038e8:	85 c0                	test   %eax,%eax
801038ea:	0f 8e c9 00 00 00    	jle    801039b9 <pipewrite+0xe9>
801038f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801038f3:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801038f9:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
801038ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80103902:	03 4d 10             	add    0x10(%ebp),%ecx
80103905:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103908:	8b 8b 34 02 00 00    	mov    0x234(%ebx),%ecx
8010390e:	8d 91 00 02 00 00    	lea    0x200(%ecx),%edx
80103914:	39 d0                	cmp    %edx,%eax
80103916:	75 71                	jne    80103989 <pipewrite+0xb9>
      if(p->readopen == 0 || myproc()->killed){
80103918:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
8010391e:	85 c0                	test   %eax,%eax
80103920:	74 4e                	je     80103970 <pipewrite+0xa0>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103922:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
80103928:	eb 3a                	jmp    80103964 <pipewrite+0x94>
8010392a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      wakeup(&p->nread);
80103930:	83 ec 0c             	sub    $0xc,%esp
80103933:	57                   	push   %edi
80103934:	e8 b7 0a 00 00       	call   801043f0 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103939:	5a                   	pop    %edx
8010393a:	59                   	pop    %ecx
8010393b:	53                   	push   %ebx
8010393c:	56                   	push   %esi
8010393d:	e8 ee 08 00 00       	call   80104230 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103942:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103948:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010394e:	83 c4 10             	add    $0x10,%esp
80103951:	05 00 02 00 00       	add    $0x200,%eax
80103956:	39 c2                	cmp    %eax,%edx
80103958:	75 36                	jne    80103990 <pipewrite+0xc0>
      if(p->readopen == 0 || myproc()->killed){
8010395a:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103960:	85 c0                	test   %eax,%eax
80103962:	74 0c                	je     80103970 <pipewrite+0xa0>
80103964:	e8 57 03 00 00       	call   80103cc0 <myproc>
80103969:	8b 40 24             	mov    0x24(%eax),%eax
8010396c:	85 c0                	test   %eax,%eax
8010396e:	74 c0                	je     80103930 <pipewrite+0x60>
        release(&p->lock);
80103970:	83 ec 0c             	sub    $0xc,%esp
80103973:	53                   	push   %ebx
80103974:	e8 17 11 00 00       	call   80104a90 <release>
        return -1;
80103979:	83 c4 10             	add    $0x10,%esp
8010397c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103981:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103984:	5b                   	pop    %ebx
80103985:	5e                   	pop    %esi
80103986:	5f                   	pop    %edi
80103987:	5d                   	pop    %ebp
80103988:	c3                   	ret    
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103989:	89 c2                	mov    %eax,%edx
8010398b:	90                   	nop
8010398c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103990:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103993:	8d 42 01             	lea    0x1(%edx),%eax
80103996:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010399c:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801039a2:	83 c6 01             	add    $0x1,%esi
801039a5:	0f b6 4e ff          	movzbl -0x1(%esi),%ecx
  for(i = 0; i < n; i++){
801039a9:	3b 75 e0             	cmp    -0x20(%ebp),%esi
801039ac:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801039af:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801039b3:	0f 85 4f ff ff ff    	jne    80103908 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801039b9:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801039bf:	83 ec 0c             	sub    $0xc,%esp
801039c2:	50                   	push   %eax
801039c3:	e8 28 0a 00 00       	call   801043f0 <wakeup>
  release(&p->lock);
801039c8:	89 1c 24             	mov    %ebx,(%esp)
801039cb:	e8 c0 10 00 00       	call   80104a90 <release>
  return n;
801039d0:	83 c4 10             	add    $0x10,%esp
801039d3:	8b 45 10             	mov    0x10(%ebp),%eax
801039d6:	eb a9                	jmp    80103981 <pipewrite+0xb1>
801039d8:	90                   	nop
801039d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801039e0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801039e0:	55                   	push   %ebp
801039e1:	89 e5                	mov    %esp,%ebp
801039e3:	57                   	push   %edi
801039e4:	56                   	push   %esi
801039e5:	53                   	push   %ebx
801039e6:	83 ec 18             	sub    $0x18,%esp
801039e9:	8b 75 08             	mov    0x8(%ebp),%esi
801039ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801039ef:	56                   	push   %esi
801039f0:	e8 7b 0f 00 00       	call   80104970 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801039f5:	83 c4 10             	add    $0x10,%esp
801039f8:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
801039fe:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103a04:	75 6a                	jne    80103a70 <piperead+0x90>
80103a06:	8b 9e 40 02 00 00    	mov    0x240(%esi),%ebx
80103a0c:	85 db                	test   %ebx,%ebx
80103a0e:	0f 84 c4 00 00 00    	je     80103ad8 <piperead+0xf8>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103a14:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103a1a:	eb 2d                	jmp    80103a49 <piperead+0x69>
80103a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103a20:	83 ec 08             	sub    $0x8,%esp
80103a23:	56                   	push   %esi
80103a24:	53                   	push   %ebx
80103a25:	e8 06 08 00 00       	call   80104230 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103a2a:	83 c4 10             	add    $0x10,%esp
80103a2d:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103a33:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103a39:	75 35                	jne    80103a70 <piperead+0x90>
80103a3b:	8b 96 40 02 00 00    	mov    0x240(%esi),%edx
80103a41:	85 d2                	test   %edx,%edx
80103a43:	0f 84 8f 00 00 00    	je     80103ad8 <piperead+0xf8>
    if(myproc()->killed){
80103a49:	e8 72 02 00 00       	call   80103cc0 <myproc>
80103a4e:	8b 48 24             	mov    0x24(%eax),%ecx
80103a51:	85 c9                	test   %ecx,%ecx
80103a53:	74 cb                	je     80103a20 <piperead+0x40>
      release(&p->lock);
80103a55:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103a58:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103a5d:	56                   	push   %esi
80103a5e:	e8 2d 10 00 00       	call   80104a90 <release>
      return -1;
80103a63:	83 c4 10             	add    $0x10,%esp
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103a69:	89 d8                	mov    %ebx,%eax
80103a6b:	5b                   	pop    %ebx
80103a6c:	5e                   	pop    %esi
80103a6d:	5f                   	pop    %edi
80103a6e:	5d                   	pop    %ebp
80103a6f:	c3                   	ret    
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103a70:	8b 45 10             	mov    0x10(%ebp),%eax
80103a73:	85 c0                	test   %eax,%eax
80103a75:	7e 61                	jle    80103ad8 <piperead+0xf8>
    if(p->nread == p->nwrite)
80103a77:	31 db                	xor    %ebx,%ebx
80103a79:	eb 13                	jmp    80103a8e <piperead+0xae>
80103a7b:	90                   	nop
80103a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103a80:	8b 8e 34 02 00 00    	mov    0x234(%esi),%ecx
80103a86:	3b 8e 38 02 00 00    	cmp    0x238(%esi),%ecx
80103a8c:	74 1f                	je     80103aad <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103a8e:	8d 41 01             	lea    0x1(%ecx),%eax
80103a91:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
80103a97:	89 86 34 02 00 00    	mov    %eax,0x234(%esi)
80103a9d:	0f b6 44 0e 34       	movzbl 0x34(%esi,%ecx,1),%eax
80103aa2:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103aa5:	83 c3 01             	add    $0x1,%ebx
80103aa8:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103aab:	75 d3                	jne    80103a80 <piperead+0xa0>
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103aad:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103ab3:	83 ec 0c             	sub    $0xc,%esp
80103ab6:	50                   	push   %eax
80103ab7:	e8 34 09 00 00       	call   801043f0 <wakeup>
  release(&p->lock);
80103abc:	89 34 24             	mov    %esi,(%esp)
80103abf:	e8 cc 0f 00 00       	call   80104a90 <release>
  return i;
80103ac4:	83 c4 10             	add    $0x10,%esp
}
80103ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103aca:	89 d8                	mov    %ebx,%eax
80103acc:	5b                   	pop    %ebx
80103acd:	5e                   	pop    %esi
80103ace:	5f                   	pop    %edi
80103acf:	5d                   	pop    %ebp
80103ad0:	c3                   	ret    
80103ad1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ad8:	31 db                	xor    %ebx,%ebx
80103ada:	eb d1                	jmp    80103aad <piperead+0xcd>
80103adc:	66 90                	xchg   %ax,%ax
80103ade:	66 90                	xchg   %ax,%ax

80103ae0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103ae0:	55                   	push   %ebp
80103ae1:	89 e5                	mov    %esp,%ebp
80103ae3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ae4:	bb 94 40 11 80       	mov    $0x80114094,%ebx
{
80103ae9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103aec:	68 60 40 11 80       	push   $0x80114060
80103af1:	e8 7a 0e 00 00       	call   80104970 <acquire>
80103af6:	83 c4 10             	add    $0x10,%esp
80103af9:	eb 10                	jmp    80103b0b <allocproc+0x2b>
80103afb:	90                   	nop
80103afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103b00:	83 c3 7c             	add    $0x7c,%ebx
80103b03:	81 fb 94 5f 11 80    	cmp    $0x80115f94,%ebx
80103b09:	73 75                	jae    80103b80 <allocproc+0xa0>
    if(p->state == UNUSED)
80103b0b:	8b 43 0c             	mov    0xc(%ebx),%eax
80103b0e:	85 c0                	test   %eax,%eax
80103b10:	75 ee                	jne    80103b00 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103b12:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  release(&ptable.lock);
80103b17:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
80103b1a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103b21:	8d 50 01             	lea    0x1(%eax),%edx
80103b24:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103b27:	68 60 40 11 80       	push   $0x80114060
  p->pid = nextpid++;
80103b2c:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
80103b32:	e8 59 0f 00 00       	call   80104a90 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103b37:	e8 64 ee ff ff       	call   801029a0 <kalloc>
80103b3c:	83 c4 10             	add    $0x10,%esp
80103b3f:	85 c0                	test   %eax,%eax
80103b41:	89 43 08             	mov    %eax,0x8(%ebx)
80103b44:	74 53                	je     80103b99 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b46:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103b4c:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103b4f:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103b54:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103b57:	c7 40 14 b2 5d 10 80 	movl   $0x80105db2,0x14(%eax)
  p->context = (struct context*)sp;
80103b5e:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103b61:	6a 14                	push   $0x14
80103b63:	6a 00                	push   $0x0
80103b65:	50                   	push   %eax
80103b66:	e8 85 0f 00 00       	call   80104af0 <memset>
  p->context->eip = (uint)forkret;
80103b6b:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
80103b6e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b71:	c7 40 10 b0 3b 10 80 	movl   $0x80103bb0,0x10(%eax)
}
80103b78:	89 d8                	mov    %ebx,%eax
80103b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b7d:	c9                   	leave  
80103b7e:	c3                   	ret    
80103b7f:	90                   	nop
  release(&ptable.lock);
80103b80:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103b83:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103b85:	68 60 40 11 80       	push   $0x80114060
80103b8a:	e8 01 0f 00 00       	call   80104a90 <release>
}
80103b8f:	89 d8                	mov    %ebx,%eax
  return 0;
80103b91:	83 c4 10             	add    $0x10,%esp
}
80103b94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b97:	c9                   	leave  
80103b98:	c3                   	ret    
    p->state = UNUSED;
80103b99:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103ba0:	31 db                	xor    %ebx,%ebx
80103ba2:	eb d4                	jmp    80103b78 <allocproc+0x98>
80103ba4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103baa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103bb0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103bb0:	55                   	push   %ebp
80103bb1:	89 e5                	mov    %esp,%ebp
80103bb3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103bb6:	68 60 40 11 80       	push   $0x80114060
80103bbb:	e8 d0 0e 00 00       	call   80104a90 <release>

  if (first) {
80103bc0:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103bc5:	83 c4 10             	add    $0x10,%esp
80103bc8:	85 c0                	test   %eax,%eax
80103bca:	75 04                	jne    80103bd0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103bcc:	c9                   	leave  
80103bcd:	c3                   	ret    
80103bce:	66 90                	xchg   %ax,%ax
    iinit(ROOTDEV);
80103bd0:	83 ec 0c             	sub    $0xc,%esp
    first = 0;
80103bd3:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103bda:	00 00 00 
    iinit(ROOTDEV);
80103bdd:	6a 01                	push   $0x1
80103bdf:	e8 fc dc ff ff       	call   801018e0 <iinit>
    initlog(ROOTDEV);
80103be4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103beb:	e8 f0 f3 ff ff       	call   80102fe0 <initlog>
80103bf0:	83 c4 10             	add    $0x10,%esp
}
80103bf3:	c9                   	leave  
80103bf4:	c3                   	ret    
80103bf5:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103c00 <pinit>:
{
80103c00:	55                   	push   %ebp
80103c01:	89 e5                	mov    %esp,%ebp
80103c03:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103c06:	68 55 81 10 80       	push   $0x80108155
80103c0b:	68 60 40 11 80       	push   $0x80114060
80103c10:	e8 6b 0c 00 00       	call   80104880 <initlock>
}
80103c15:	83 c4 10             	add    $0x10,%esp
80103c18:	c9                   	leave  
80103c19:	c3                   	ret    
80103c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103c20 <mycpu>:
{
80103c20:	55                   	push   %ebp
80103c21:	89 e5                	mov    %esp,%ebp
80103c23:	56                   	push   %esi
80103c24:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c25:	9c                   	pushf  
80103c26:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c27:	f6 c4 02             	test   $0x2,%ah
80103c2a:	75 5e                	jne    80103c8a <mycpu+0x6a>
  apicid = lapicid();
80103c2c:	e8 df ef ff ff       	call   80102c10 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103c31:	8b 35 00 3d 11 80    	mov    0x80113d00,%esi
80103c37:	85 f6                	test   %esi,%esi
80103c39:	7e 42                	jle    80103c7d <mycpu+0x5d>
    if (cpus[i].apicid == apicid)
80103c3b:	0f b6 15 80 37 11 80 	movzbl 0x80113780,%edx
80103c42:	39 d0                	cmp    %edx,%eax
80103c44:	74 30                	je     80103c76 <mycpu+0x56>
80103c46:	b9 30 38 11 80       	mov    $0x80113830,%ecx
  for (i = 0; i < ncpu; ++i) {
80103c4b:	31 d2                	xor    %edx,%edx
80103c4d:	8d 76 00             	lea    0x0(%esi),%esi
80103c50:	83 c2 01             	add    $0x1,%edx
80103c53:	39 f2                	cmp    %esi,%edx
80103c55:	74 26                	je     80103c7d <mycpu+0x5d>
    if (cpus[i].apicid == apicid)
80103c57:	0f b6 19             	movzbl (%ecx),%ebx
80103c5a:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
80103c60:	39 c3                	cmp    %eax,%ebx
80103c62:	75 ec                	jne    80103c50 <mycpu+0x30>
80103c64:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103c6a:	05 80 37 11 80       	add    $0x80113780,%eax
}
80103c6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c72:	5b                   	pop    %ebx
80103c73:	5e                   	pop    %esi
80103c74:	5d                   	pop    %ebp
80103c75:	c3                   	ret    
    if (cpus[i].apicid == apicid)
80103c76:	b8 80 37 11 80       	mov    $0x80113780,%eax
      return &cpus[i];
80103c7b:	eb f2                	jmp    80103c6f <mycpu+0x4f>
  panic("unknown apicid\n");
80103c7d:	83 ec 0c             	sub    $0xc,%esp
80103c80:	68 5c 81 10 80       	push   $0x8010815c
80103c85:	e8 76 ca ff ff       	call   80100700 <panic>
    panic("mycpu called with interrupts enabled\n");
80103c8a:	83 ec 0c             	sub    $0xc,%esp
80103c8d:	68 38 82 10 80       	push   $0x80108238
80103c92:	e8 69 ca ff ff       	call   80100700 <panic>
80103c97:	89 f6                	mov    %esi,%esi
80103c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ca0 <cpuid>:
cpuid() {
80103ca0:	55                   	push   %ebp
80103ca1:	89 e5                	mov    %esp,%ebp
80103ca3:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103ca6:	e8 75 ff ff ff       	call   80103c20 <mycpu>
80103cab:	2d 80 37 11 80       	sub    $0x80113780,%eax
}
80103cb0:	c9                   	leave  
  return mycpu()-cpus;
80103cb1:	c1 f8 04             	sar    $0x4,%eax
80103cb4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103cba:	c3                   	ret    
80103cbb:	90                   	nop
80103cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103cc0 <myproc>:
myproc(void) {
80103cc0:	55                   	push   %ebp
80103cc1:	89 e5                	mov    %esp,%ebp
80103cc3:	53                   	push   %ebx
80103cc4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103cc7:	e8 64 0c 00 00       	call   80104930 <pushcli>
  c = mycpu();
80103ccc:	e8 4f ff ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80103cd1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103cd7:	e8 54 0d 00 00       	call   80104a30 <popcli>
}
80103cdc:	83 c4 04             	add    $0x4,%esp
80103cdf:	89 d8                	mov    %ebx,%eax
80103ce1:	5b                   	pop    %ebx
80103ce2:	5d                   	pop    %ebp
80103ce3:	c3                   	ret    
80103ce4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103cea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80103cf0 <userinit>:
{
80103cf0:	55                   	push   %ebp
80103cf1:	89 e5                	mov    %esp,%ebp
80103cf3:	53                   	push   %ebx
80103cf4:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103cf7:	e8 e4 fd ff ff       	call   80103ae0 <allocproc>
80103cfc:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103cfe:	a3 b8 b5 10 80       	mov    %eax,0x8010b5b8
  if((p->pgdir = setupkvm()) == 0)
80103d03:	e8 78 3a 00 00       	call   80107780 <setupkvm>
80103d08:	85 c0                	test   %eax,%eax
80103d0a:	89 43 04             	mov    %eax,0x4(%ebx)
80103d0d:	0f 84 bd 00 00 00    	je     80103dd0 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103d13:	83 ec 04             	sub    $0x4,%esp
80103d16:	68 2c 00 00 00       	push   $0x2c
80103d1b:	68 60 b4 10 80       	push   $0x8010b460
80103d20:	50                   	push   %eax
80103d21:	e8 6a 37 00 00       	call   80107490 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103d26:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103d29:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103d2f:	6a 4c                	push   $0x4c
80103d31:	6a 00                	push   $0x0
80103d33:	ff 73 18             	pushl  0x18(%ebx)
80103d36:	e8 b5 0d 00 00       	call   80104af0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d3b:	8b 43 18             	mov    0x18(%ebx),%eax
80103d3e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d43:	b9 23 00 00 00       	mov    $0x23,%ecx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103d48:	83 c4 0c             	add    $0xc,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103d4b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103d4f:	8b 43 18             	mov    0x18(%ebx),%eax
80103d52:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103d56:	8b 43 18             	mov    0x18(%ebx),%eax
80103d59:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103d5d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103d61:	8b 43 18             	mov    0x18(%ebx),%eax
80103d64:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103d68:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103d6c:	8b 43 18             	mov    0x18(%ebx),%eax
80103d6f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103d76:	8b 43 18             	mov    0x18(%ebx),%eax
80103d79:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103d80:	8b 43 18             	mov    0x18(%ebx),%eax
80103d83:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103d8a:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103d8d:	6a 10                	push   $0x10
80103d8f:	68 85 81 10 80       	push   $0x80108185
80103d94:	50                   	push   %eax
80103d95:	e8 36 0f 00 00       	call   80104cd0 <safestrcpy>
  p->cwd = namei("/");
80103d9a:	c7 04 24 8e 81 10 80 	movl   $0x8010818e,(%esp)
80103da1:	e8 9a e5 ff ff       	call   80102340 <namei>
80103da6:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103da9:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80103db0:	e8 bb 0b 00 00       	call   80104970 <acquire>
  p->state = RUNNABLE;
80103db5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103dbc:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80103dc3:	e8 c8 0c 00 00       	call   80104a90 <release>
}
80103dc8:	83 c4 10             	add    $0x10,%esp
80103dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    
    panic("userinit: out of memory?");
80103dd0:	83 ec 0c             	sub    $0xc,%esp
80103dd3:	68 6c 81 10 80       	push   $0x8010816c
80103dd8:	e8 23 c9 ff ff       	call   80100700 <panic>
80103ddd:	8d 76 00             	lea    0x0(%esi),%esi

80103de0 <growproc>:
{
80103de0:	55                   	push   %ebp
80103de1:	89 e5                	mov    %esp,%ebp
80103de3:	56                   	push   %esi
80103de4:	53                   	push   %ebx
80103de5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103de8:	e8 43 0b 00 00       	call   80104930 <pushcli>
  c = mycpu();
80103ded:	e8 2e fe ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80103df2:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103df8:	e8 33 0c 00 00       	call   80104a30 <popcli>
  if (n < 0 || n > KERNBASE || curproc->sz + n > KERNBASE)
80103dfd:	85 db                	test   %ebx,%ebx
80103dff:	78 1f                	js     80103e20 <growproc+0x40>
80103e01:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80103e07:	77 17                	ja     80103e20 <growproc+0x40>
80103e09:	03 1e                	add    (%esi),%ebx
80103e0b:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80103e11:	77 0d                	ja     80103e20 <growproc+0x40>
  curproc->sz += n;
80103e13:	89 1e                	mov    %ebx,(%esi)
  return 0;
80103e15:	31 c0                	xor    %eax,%eax
}
80103e17:	5b                   	pop    %ebx
80103e18:	5e                   	pop    %esi
80103e19:	5d                   	pop    %ebp
80103e1a:	c3                   	ret    
80103e1b:	90                   	nop
80103e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
	  return -1;
80103e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e25:	eb f0                	jmp    80103e17 <growproc+0x37>
80103e27:	89 f6                	mov    %esi,%esi
80103e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103e30 <fork>:
{
80103e30:	55                   	push   %ebp
80103e31:	89 e5                	mov    %esp,%ebp
80103e33:	57                   	push   %edi
80103e34:	56                   	push   %esi
80103e35:	53                   	push   %ebx
80103e36:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103e39:	e8 f2 0a 00 00       	call   80104930 <pushcli>
  c = mycpu();
80103e3e:	e8 dd fd ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80103e43:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e49:	e8 e2 0b 00 00       	call   80104a30 <popcli>
  if((np = allocproc()) == 0){
80103e4e:	e8 8d fc ff ff       	call   80103ae0 <allocproc>
80103e53:	85 c0                	test   %eax,%eax
80103e55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103e58:	0f 84 bf 00 00 00    	je     80103f1d <fork+0xed>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz,curproc->pid)) == 0){
80103e5e:	83 ec 04             	sub    $0x4,%esp
80103e61:	ff 73 10             	pushl  0x10(%ebx)
80103e64:	ff 33                	pushl  (%ebx)
80103e66:	ff 73 04             	pushl  0x4(%ebx)
80103e69:	89 c7                	mov    %eax,%edi
80103e6b:	e8 80 3a 00 00       	call   801078f0 <copyuvm>
80103e70:	83 c4 10             	add    $0x10,%esp
80103e73:	85 c0                	test   %eax,%eax
80103e75:	89 47 04             	mov    %eax,0x4(%edi)
80103e78:	0f 84 a6 00 00 00    	je     80103f24 <fork+0xf4>
  np->sz = curproc->sz;
80103e7e:	8b 03                	mov    (%ebx),%eax
80103e80:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e83:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103e85:	89 59 14             	mov    %ebx,0x14(%ecx)
80103e88:	89 c8                	mov    %ecx,%eax
  *np->tf = *curproc->tf;
80103e8a:	8b 79 18             	mov    0x18(%ecx),%edi
80103e8d:	8b 73 18             	mov    0x18(%ebx),%esi
80103e90:	b9 13 00 00 00       	mov    $0x13,%ecx
80103e95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103e97:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103e99:	8b 40 18             	mov    0x18(%eax),%eax
80103e9c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
80103ea3:	90                   	nop
80103ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[i])
80103ea8:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103eac:	85 c0                	test   %eax,%eax
80103eae:	74 13                	je     80103ec3 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103eb0:	83 ec 0c             	sub    $0xc,%esp
80103eb3:	50                   	push   %eax
80103eb4:	e8 a7 d2 ff ff       	call   80101160 <filedup>
80103eb9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103ebc:	83 c4 10             	add    $0x10,%esp
80103ebf:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103ec3:	83 c6 01             	add    $0x1,%esi
80103ec6:	83 fe 10             	cmp    $0x10,%esi
80103ec9:	75 dd                	jne    80103ea8 <fork+0x78>
  np->cwd = idup(curproc->cwd);
80103ecb:	83 ec 0c             	sub    $0xc,%esp
80103ece:	ff 73 68             	pushl  0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ed1:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103ed4:	e8 d7 db ff ff       	call   80101ab0 <idup>
80103ed9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103edc:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103edf:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ee2:	8d 47 6c             	lea    0x6c(%edi),%eax
80103ee5:	6a 10                	push   $0x10
80103ee7:	53                   	push   %ebx
80103ee8:	50                   	push   %eax
80103ee9:	e8 e2 0d 00 00       	call   80104cd0 <safestrcpy>
  pid = np->pid;
80103eee:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103ef1:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80103ef8:	e8 73 0a 00 00       	call   80104970 <acquire>
  np->state = RUNNABLE;
80103efd:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103f04:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80103f0b:	e8 80 0b 00 00       	call   80104a90 <release>
  return pid;
80103f10:	83 c4 10             	add    $0x10,%esp
}
80103f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f16:	89 d8                	mov    %ebx,%eax
80103f18:	5b                   	pop    %ebx
80103f19:	5e                   	pop    %esi
80103f1a:	5f                   	pop    %edi
80103f1b:	5d                   	pop    %ebp
80103f1c:	c3                   	ret    
    return -1;
80103f1d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103f22:	eb ef                	jmp    80103f13 <fork+0xe3>
    kfree(np->kstack);
80103f24:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103f27:	83 ec 0c             	sub    $0xc,%esp
80103f2a:	ff 73 08             	pushl  0x8(%ebx)
80103f2d:	e8 be e8 ff ff       	call   801027f0 <kfree>
    np->kstack = 0;
80103f32:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103f39:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103f40:	83 c4 10             	add    $0x10,%esp
80103f43:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103f48:	eb c9                	jmp    80103f13 <fork+0xe3>
80103f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103f50 <scheduler>:
{
80103f50:	55                   	push   %ebp
80103f51:	89 e5                	mov    %esp,%ebp
80103f53:	57                   	push   %edi
80103f54:	56                   	push   %esi
80103f55:	53                   	push   %ebx
80103f56:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103f59:	e8 c2 fc ff ff       	call   80103c20 <mycpu>
80103f5e:	8d 78 04             	lea    0x4(%eax),%edi
80103f61:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103f63:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103f6a:	00 00 00 
80103f6d:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103f70:	fb                   	sti    
    acquire(&ptable.lock);
80103f71:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f74:	bb 94 40 11 80       	mov    $0x80114094,%ebx
    acquire(&ptable.lock);
80103f79:	68 60 40 11 80       	push   $0x80114060
80103f7e:	e8 ed 09 00 00       	call   80104970 <acquire>
80103f83:	83 c4 10             	add    $0x10,%esp
80103f86:	8d 76 00             	lea    0x0(%esi),%esi
80103f89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      if(p->state != RUNNABLE)
80103f90:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103f94:	75 33                	jne    80103fc9 <scheduler+0x79>
      switchuvm(p);
80103f96:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103f99:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103f9f:	53                   	push   %ebx
80103fa0:	e8 db 33 00 00       	call   80107380 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103fa5:	58                   	pop    %eax
80103fa6:	5a                   	pop    %edx
80103fa7:	ff 73 1c             	pushl  0x1c(%ebx)
80103faa:	57                   	push   %edi
      p->state = RUNNING;
80103fab:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103fb2:	e8 74 0d 00 00       	call   80104d2b <swtch>
      switchkvm();
80103fb7:	e8 a4 33 00 00       	call   80107360 <switchkvm>
      c->proc = 0;
80103fbc:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103fc3:	00 00 00 
80103fc6:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fc9:	83 c3 7c             	add    $0x7c,%ebx
80103fcc:	81 fb 94 5f 11 80    	cmp    $0x80115f94,%ebx
80103fd2:	72 bc                	jb     80103f90 <scheduler+0x40>
    release(&ptable.lock);
80103fd4:	83 ec 0c             	sub    $0xc,%esp
80103fd7:	68 60 40 11 80       	push   $0x80114060
80103fdc:	e8 af 0a 00 00       	call   80104a90 <release>
    sti();
80103fe1:	83 c4 10             	add    $0x10,%esp
80103fe4:	eb 8a                	jmp    80103f70 <scheduler+0x20>
80103fe6:	8d 76 00             	lea    0x0(%esi),%esi
80103fe9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80103ff0 <sched>:
{
80103ff0:	55                   	push   %ebp
80103ff1:	89 e5                	mov    %esp,%ebp
80103ff3:	56                   	push   %esi
80103ff4:	53                   	push   %ebx
  pushcli();
80103ff5:	e8 36 09 00 00       	call   80104930 <pushcli>
  c = mycpu();
80103ffa:	e8 21 fc ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80103fff:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104005:	e8 26 0a 00 00       	call   80104a30 <popcli>
  if(!holding(&ptable.lock))
8010400a:	83 ec 0c             	sub    $0xc,%esp
8010400d:	68 60 40 11 80       	push   $0x80114060
80104012:	e8 d9 08 00 00       	call   801048f0 <holding>
80104017:	83 c4 10             	add    $0x10,%esp
8010401a:	85 c0                	test   %eax,%eax
8010401c:	74 4f                	je     8010406d <sched+0x7d>
  if(mycpu()->ncli != 1)
8010401e:	e8 fd fb ff ff       	call   80103c20 <mycpu>
80104023:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010402a:	75 68                	jne    80104094 <sched+0xa4>
  if(p->state == RUNNING)
8010402c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80104030:	74 55                	je     80104087 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104032:	9c                   	pushf  
80104033:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104034:	f6 c4 02             	test   $0x2,%ah
80104037:	75 41                	jne    8010407a <sched+0x8a>
  intena = mycpu()->intena;
80104039:	e8 e2 fb ff ff       	call   80103c20 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
8010403e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80104041:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80104047:	e8 d4 fb ff ff       	call   80103c20 <mycpu>
8010404c:	83 ec 08             	sub    $0x8,%esp
8010404f:	ff 70 04             	pushl  0x4(%eax)
80104052:	53                   	push   %ebx
80104053:	e8 d3 0c 00 00       	call   80104d2b <swtch>
  mycpu()->intena = intena;
80104058:	e8 c3 fb ff ff       	call   80103c20 <mycpu>
}
8010405d:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104060:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80104066:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104069:	5b                   	pop    %ebx
8010406a:	5e                   	pop    %esi
8010406b:	5d                   	pop    %ebp
8010406c:	c3                   	ret    
    panic("sched ptable.lock");
8010406d:	83 ec 0c             	sub    $0xc,%esp
80104070:	68 90 81 10 80       	push   $0x80108190
80104075:	e8 86 c6 ff ff       	call   80100700 <panic>
    panic("sched interruptible");
8010407a:	83 ec 0c             	sub    $0xc,%esp
8010407d:	68 bc 81 10 80       	push   $0x801081bc
80104082:	e8 79 c6 ff ff       	call   80100700 <panic>
    panic("sched running");
80104087:	83 ec 0c             	sub    $0xc,%esp
8010408a:	68 ae 81 10 80       	push   $0x801081ae
8010408f:	e8 6c c6 ff ff       	call   80100700 <panic>
    panic("sched locks");
80104094:	83 ec 0c             	sub    $0xc,%esp
80104097:	68 a2 81 10 80       	push   $0x801081a2
8010409c:	e8 5f c6 ff ff       	call   80100700 <panic>
801040a1:	eb 0d                	jmp    801040b0 <exit>
801040a3:	90                   	nop
801040a4:	90                   	nop
801040a5:	90                   	nop
801040a6:	90                   	nop
801040a7:	90                   	nop
801040a8:	90                   	nop
801040a9:	90                   	nop
801040aa:	90                   	nop
801040ab:	90                   	nop
801040ac:	90                   	nop
801040ad:	90                   	nop
801040ae:	90                   	nop
801040af:	90                   	nop

801040b0 <exit>:
{
801040b0:	55                   	push   %ebp
801040b1:	89 e5                	mov    %esp,%ebp
801040b3:	57                   	push   %edi
801040b4:	56                   	push   %esi
801040b5:	53                   	push   %ebx
801040b6:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
801040b9:	e8 72 08 00 00       	call   80104930 <pushcli>
  c = mycpu();
801040be:	e8 5d fb ff ff       	call   80103c20 <mycpu>
  p = c->proc;
801040c3:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
801040c9:	e8 62 09 00 00       	call   80104a30 <popcli>
  if(curproc == initproc)
801040ce:	39 35 b8 b5 10 80    	cmp    %esi,0x8010b5b8
801040d4:	8d 5e 28             	lea    0x28(%esi),%ebx
801040d7:	8d 7e 68             	lea    0x68(%esi),%edi
801040da:	0f 84 e7 00 00 00    	je     801041c7 <exit+0x117>
    if(curproc->ofile[fd]){
801040e0:	8b 03                	mov    (%ebx),%eax
801040e2:	85 c0                	test   %eax,%eax
801040e4:	74 12                	je     801040f8 <exit+0x48>
      fileclose(curproc->ofile[fd]);
801040e6:	83 ec 0c             	sub    $0xc,%esp
801040e9:	50                   	push   %eax
801040ea:	e8 c1 d0 ff ff       	call   801011b0 <fileclose>
      curproc->ofile[fd] = 0;
801040ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
801040f5:	83 c4 10             	add    $0x10,%esp
801040f8:	83 c3 04             	add    $0x4,%ebx
  for(fd = 0; fd < NOFILE; fd++){
801040fb:	39 fb                	cmp    %edi,%ebx
801040fd:	75 e1                	jne    801040e0 <exit+0x30>
  begin_op();
801040ff:	e8 7c ef ff ff       	call   80103080 <begin_op>
  iput(curproc->cwd);
80104104:	83 ec 0c             	sub    $0xc,%esp
80104107:	ff 76 68             	pushl  0x68(%esi)
8010410a:	e8 01 db ff ff       	call   80101c10 <iput>
  end_op();
8010410f:	e8 dc ef ff ff       	call   801030f0 <end_op>
  curproc->cwd = 0;
80104114:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010411b:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80104122:	e8 49 08 00 00       	call   80104970 <acquire>
  wakeup1(curproc->parent);
80104127:	8b 56 14             	mov    0x14(%esi),%edx
8010412a:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010412d:	b8 94 40 11 80       	mov    $0x80114094,%eax
80104132:	eb 0e                	jmp    80104142 <exit+0x92>
80104134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104138:	83 c0 7c             	add    $0x7c,%eax
8010413b:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
80104140:	73 1c                	jae    8010415e <exit+0xae>
    if(p->state == SLEEPING && p->chan == chan)
80104142:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80104146:	75 f0                	jne    80104138 <exit+0x88>
80104148:	3b 50 20             	cmp    0x20(%eax),%edx
8010414b:	75 eb                	jne    80104138 <exit+0x88>
      p->state = RUNNABLE;
8010414d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104154:	83 c0 7c             	add    $0x7c,%eax
80104157:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
8010415c:	72 e4                	jb     80104142 <exit+0x92>
      p->parent = initproc;
8010415e:	8b 0d b8 b5 10 80    	mov    0x8010b5b8,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104164:	ba 94 40 11 80       	mov    $0x80114094,%edx
80104169:	eb 10                	jmp    8010417b <exit+0xcb>
8010416b:	90                   	nop
8010416c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104170:	83 c2 7c             	add    $0x7c,%edx
80104173:	81 fa 94 5f 11 80    	cmp    $0x80115f94,%edx
80104179:	73 33                	jae    801041ae <exit+0xfe>
    if(p->parent == curproc){
8010417b:	39 72 14             	cmp    %esi,0x14(%edx)
8010417e:	75 f0                	jne    80104170 <exit+0xc0>
      if(p->state == ZOMBIE)
80104180:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80104184:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80104187:	75 e7                	jne    80104170 <exit+0xc0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104189:	b8 94 40 11 80       	mov    $0x80114094,%eax
8010418e:	eb 0a                	jmp    8010419a <exit+0xea>
80104190:	83 c0 7c             	add    $0x7c,%eax
80104193:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
80104198:	73 d6                	jae    80104170 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
8010419a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010419e:	75 f0                	jne    80104190 <exit+0xe0>
801041a0:	3b 48 20             	cmp    0x20(%eax),%ecx
801041a3:	75 eb                	jne    80104190 <exit+0xe0>
      p->state = RUNNABLE;
801041a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801041ac:	eb e2                	jmp    80104190 <exit+0xe0>
  curproc->state = ZOMBIE;
801041ae:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801041b5:	e8 36 fe ff ff       	call   80103ff0 <sched>
  panic("zombie exit");
801041ba:	83 ec 0c             	sub    $0xc,%esp
801041bd:	68 dd 81 10 80       	push   $0x801081dd
801041c2:	e8 39 c5 ff ff       	call   80100700 <panic>
    panic("init exiting");
801041c7:	83 ec 0c             	sub    $0xc,%esp
801041ca:	68 d0 81 10 80       	push   $0x801081d0
801041cf:	e8 2c c5 ff ff       	call   80100700 <panic>
801041d4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801041da:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801041e0 <yield>:
{
801041e0:	55                   	push   %ebp
801041e1:	89 e5                	mov    %esp,%ebp
801041e3:	53                   	push   %ebx
801041e4:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801041e7:	68 60 40 11 80       	push   $0x80114060
801041ec:	e8 7f 07 00 00       	call   80104970 <acquire>
  pushcli();
801041f1:	e8 3a 07 00 00       	call   80104930 <pushcli>
  c = mycpu();
801041f6:	e8 25 fa ff ff       	call   80103c20 <mycpu>
  p = c->proc;
801041fb:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104201:	e8 2a 08 00 00       	call   80104a30 <popcli>
  myproc()->state = RUNNABLE;
80104206:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
8010420d:	e8 de fd ff ff       	call   80103ff0 <sched>
  release(&ptable.lock);
80104212:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
80104219:	e8 72 08 00 00       	call   80104a90 <release>
}
8010421e:	83 c4 10             	add    $0x10,%esp
80104221:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104224:	c9                   	leave  
80104225:	c3                   	ret    
80104226:	8d 76 00             	lea    0x0(%esi),%esi
80104229:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104230 <sleep>:
{
80104230:	55                   	push   %ebp
80104231:	89 e5                	mov    %esp,%ebp
80104233:	57                   	push   %edi
80104234:	56                   	push   %esi
80104235:	53                   	push   %ebx
80104236:	83 ec 0c             	sub    $0xc,%esp
80104239:	8b 7d 08             	mov    0x8(%ebp),%edi
8010423c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
8010423f:	e8 ec 06 00 00       	call   80104930 <pushcli>
  c = mycpu();
80104244:	e8 d7 f9 ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80104249:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010424f:	e8 dc 07 00 00       	call   80104a30 <popcli>
  if(p == 0)
80104254:	85 db                	test   %ebx,%ebx
80104256:	0f 84 87 00 00 00    	je     801042e3 <sleep+0xb3>
  if(lk == 0)
8010425c:	85 f6                	test   %esi,%esi
8010425e:	74 76                	je     801042d6 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104260:	81 fe 60 40 11 80    	cmp    $0x80114060,%esi
80104266:	74 50                	je     801042b8 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104268:	83 ec 0c             	sub    $0xc,%esp
8010426b:	68 60 40 11 80       	push   $0x80114060
80104270:	e8 fb 06 00 00       	call   80104970 <acquire>
    release(lk);
80104275:	89 34 24             	mov    %esi,(%esp)
80104278:	e8 13 08 00 00       	call   80104a90 <release>
  p->chan = chan;
8010427d:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80104280:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104287:	e8 64 fd ff ff       	call   80103ff0 <sched>
  p->chan = 0;
8010428c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104293:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
8010429a:	e8 f1 07 00 00       	call   80104a90 <release>
    acquire(lk);
8010429f:	89 75 08             	mov    %esi,0x8(%ebp)
801042a2:	83 c4 10             	add    $0x10,%esp
}
801042a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042a8:	5b                   	pop    %ebx
801042a9:	5e                   	pop    %esi
801042aa:	5f                   	pop    %edi
801042ab:	5d                   	pop    %ebp
    acquire(lk);
801042ac:	e9 bf 06 00 00       	jmp    80104970 <acquire>
801042b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
801042b8:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
801042bb:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
801042c2:	e8 29 fd ff ff       	call   80103ff0 <sched>
  p->chan = 0;
801042c7:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
801042ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042d1:	5b                   	pop    %ebx
801042d2:	5e                   	pop    %esi
801042d3:	5f                   	pop    %edi
801042d4:	5d                   	pop    %ebp
801042d5:	c3                   	ret    
    panic("sleep without lk");
801042d6:	83 ec 0c             	sub    $0xc,%esp
801042d9:	68 ef 81 10 80       	push   $0x801081ef
801042de:	e8 1d c4 ff ff       	call   80100700 <panic>
    panic("sleep");
801042e3:	83 ec 0c             	sub    $0xc,%esp
801042e6:	68 e9 81 10 80       	push   $0x801081e9
801042eb:	e8 10 c4 ff ff       	call   80100700 <panic>

801042f0 <wait>:
{
801042f0:	55                   	push   %ebp
801042f1:	89 e5                	mov    %esp,%ebp
801042f3:	57                   	push   %edi
801042f4:	56                   	push   %esi
801042f5:	53                   	push   %ebx
801042f6:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
801042f9:	e8 32 06 00 00       	call   80104930 <pushcli>
  c = mycpu();
801042fe:	e8 1d f9 ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80104303:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80104309:	e8 22 07 00 00       	call   80104a30 <popcli>
  acquire(&ptable.lock);
8010430e:	83 ec 0c             	sub    $0xc,%esp
80104311:	68 60 40 11 80       	push   $0x80114060
80104316:	e8 55 06 00 00       	call   80104970 <acquire>
8010431b:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
8010431e:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104320:	bb 94 40 11 80       	mov    $0x80114094,%ebx
80104325:	eb 14                	jmp    8010433b <wait+0x4b>
80104327:	89 f6                	mov    %esi,%esi
80104329:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104330:	83 c3 7c             	add    $0x7c,%ebx
80104333:	81 fb 94 5f 11 80    	cmp    $0x80115f94,%ebx
80104339:	73 1b                	jae    80104356 <wait+0x66>
      if(p->parent != curproc)
8010433b:	39 73 14             	cmp    %esi,0x14(%ebx)
8010433e:	75 f0                	jne    80104330 <wait+0x40>
      if(p->state == ZOMBIE){
80104340:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80104344:	74 32                	je     80104378 <wait+0x88>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104346:	83 c3 7c             	add    $0x7c,%ebx
      havekids = 1;
80104349:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010434e:	81 fb 94 5f 11 80    	cmp    $0x80115f94,%ebx
80104354:	72 e5                	jb     8010433b <wait+0x4b>
    if(!havekids || curproc->killed){
80104356:	85 c0                	test   %eax,%eax
80104358:	74 7e                	je     801043d8 <wait+0xe8>
8010435a:	8b 46 24             	mov    0x24(%esi),%eax
8010435d:	85 c0                	test   %eax,%eax
8010435f:	75 77                	jne    801043d8 <wait+0xe8>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104361:	83 ec 08             	sub    $0x8,%esp
80104364:	68 60 40 11 80       	push   $0x80114060
80104369:	56                   	push   %esi
8010436a:	e8 c1 fe ff ff       	call   80104230 <sleep>
    havekids = 0;
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	eb aa                	jmp    8010431e <wait+0x2e>
80104374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        kfree(p->kstack);
80104378:	83 ec 0c             	sub    $0xc,%esp
8010437b:	ff 73 08             	pushl  0x8(%ebx)
        pid = p->pid;
8010437e:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104381:	e8 6a e4 ff ff       	call   801027f0 <kfree>
        pgdir = p->pgdir;
80104386:	8b 7b 04             	mov    0x4(%ebx),%edi
        release(&ptable.lock);
80104389:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
        p->kstack = 0;
80104390:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        p->pgdir = 0;
80104397:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
        p->pid = 0;
8010439e:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801043a5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801043ac:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801043b0:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801043b7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801043be:	e8 cd 06 00 00       	call   80104a90 <release>
        freevm(pgdir);
801043c3:	89 3c 24             	mov    %edi,(%esp)
801043c6:	e8 35 33 00 00       	call   80107700 <freevm>
        return pid;
801043cb:	83 c4 10             	add    $0x10,%esp
}
801043ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801043d1:	89 f0                	mov    %esi,%eax
801043d3:	5b                   	pop    %ebx
801043d4:	5e                   	pop    %esi
801043d5:	5f                   	pop    %edi
801043d6:	5d                   	pop    %ebp
801043d7:	c3                   	ret    
      release(&ptable.lock);
801043d8:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801043db:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
801043e0:	68 60 40 11 80       	push   $0x80114060
801043e5:	e8 a6 06 00 00       	call   80104a90 <release>
      return -1;
801043ea:	83 c4 10             	add    $0x10,%esp
801043ed:	eb df                	jmp    801043ce <wait+0xde>
801043ef:	90                   	nop

801043f0 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	53                   	push   %ebx
801043f4:	83 ec 10             	sub    $0x10,%esp
801043f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
801043fa:	68 60 40 11 80       	push   $0x80114060
801043ff:	e8 6c 05 00 00       	call   80104970 <acquire>
80104404:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104407:	b8 94 40 11 80       	mov    $0x80114094,%eax
8010440c:	eb 0c                	jmp    8010441a <wakeup+0x2a>
8010440e:	66 90                	xchg   %ax,%ax
80104410:	83 c0 7c             	add    $0x7c,%eax
80104413:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
80104418:	73 1c                	jae    80104436 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010441a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010441e:	75 f0                	jne    80104410 <wakeup+0x20>
80104420:	3b 58 20             	cmp    0x20(%eax),%ebx
80104423:	75 eb                	jne    80104410 <wakeup+0x20>
      p->state = RUNNABLE;
80104425:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010442c:	83 c0 7c             	add    $0x7c,%eax
8010442f:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
80104434:	72 e4                	jb     8010441a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
80104436:	c7 45 08 60 40 11 80 	movl   $0x80114060,0x8(%ebp)
}
8010443d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104440:	c9                   	leave  
  release(&ptable.lock);
80104441:	e9 4a 06 00 00       	jmp    80104a90 <release>
80104446:	8d 76 00             	lea    0x0(%esi),%esi
80104449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104450 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104450:	55                   	push   %ebp
80104451:	89 e5                	mov    %esp,%ebp
80104453:	53                   	push   %ebx
80104454:	83 ec 10             	sub    $0x10,%esp
80104457:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010445a:	68 60 40 11 80       	push   $0x80114060
8010445f:	e8 0c 05 00 00       	call   80104970 <acquire>
80104464:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104467:	b8 94 40 11 80       	mov    $0x80114094,%eax
8010446c:	eb 0c                	jmp    8010447a <kill+0x2a>
8010446e:	66 90                	xchg   %ax,%ax
80104470:	83 c0 7c             	add    $0x7c,%eax
80104473:	3d 94 5f 11 80       	cmp    $0x80115f94,%eax
80104478:	73 36                	jae    801044b0 <kill+0x60>
    if(p->pid == pid){
8010447a:	39 58 10             	cmp    %ebx,0x10(%eax)
8010447d:	75 f1                	jne    80104470 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010447f:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104483:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010448a:	75 07                	jne    80104493 <kill+0x43>
        p->state = RUNNABLE;
8010448c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104493:	83 ec 0c             	sub    $0xc,%esp
80104496:	68 60 40 11 80       	push   $0x80114060
8010449b:	e8 f0 05 00 00       	call   80104a90 <release>
      return 0;
801044a0:	83 c4 10             	add    $0x10,%esp
801044a3:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801044a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044a8:	c9                   	leave  
801044a9:	c3                   	ret    
801044aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
801044b0:	83 ec 0c             	sub    $0xc,%esp
801044b3:	68 60 40 11 80       	push   $0x80114060
801044b8:	e8 d3 05 00 00       	call   80104a90 <release>
  return -1;
801044bd:	83 c4 10             	add    $0x10,%esp
801044c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c8:	c9                   	leave  
801044c9:	c3                   	ret    
801044ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044d0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801044d0:	55                   	push   %ebp
801044d1:	89 e5                	mov    %esp,%ebp
801044d3:	57                   	push   %edi
801044d4:	56                   	push   %esi
801044d5:	53                   	push   %ebx
801044d6:	8d 75 e8             	lea    -0x18(%ebp),%esi
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044d9:	bb 94 40 11 80       	mov    $0x80114094,%ebx
{
801044de:	83 ec 3c             	sub    $0x3c,%esp
801044e1:	eb 24                	jmp    80104507 <procdump+0x37>
801044e3:	90                   	nop
801044e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801044e8:	83 ec 0c             	sub    $0xc,%esp
801044eb:	68 e3 86 10 80       	push   $0x801086e3
801044f0:	e8 db c4 ff ff       	call   801009d0 <cprintf>
801044f5:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044f8:	83 c3 7c             	add    $0x7c,%ebx
801044fb:	81 fb 94 5f 11 80    	cmp    $0x80115f94,%ebx
80104501:	0f 83 81 00 00 00    	jae    80104588 <procdump+0xb8>
    if(p->state == UNUSED)
80104507:	8b 43 0c             	mov    0xc(%ebx),%eax
8010450a:	85 c0                	test   %eax,%eax
8010450c:	74 ea                	je     801044f8 <procdump+0x28>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010450e:	83 f8 05             	cmp    $0x5,%eax
      state = "???";
80104511:	ba 00 82 10 80       	mov    $0x80108200,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104516:	77 11                	ja     80104529 <procdump+0x59>
80104518:	8b 14 85 00 83 10 80 	mov    -0x7fef7d00(,%eax,4),%edx
      state = "???";
8010451f:	b8 00 82 10 80       	mov    $0x80108200,%eax
80104524:	85 d2                	test   %edx,%edx
80104526:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
80104529:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010452c:	50                   	push   %eax
8010452d:	52                   	push   %edx
8010452e:	ff 73 10             	pushl  0x10(%ebx)
80104531:	68 04 82 10 80       	push   $0x80108204
80104536:	e8 95 c4 ff ff       	call   801009d0 <cprintf>
    if(p->state == SLEEPING){
8010453b:	83 c4 10             	add    $0x10,%esp
8010453e:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80104542:	75 a4                	jne    801044e8 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104544:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104547:	83 ec 08             	sub    $0x8,%esp
8010454a:	8d 7d c0             	lea    -0x40(%ebp),%edi
8010454d:	50                   	push   %eax
8010454e:	8b 43 1c             	mov    0x1c(%ebx),%eax
80104551:	8b 40 0c             	mov    0xc(%eax),%eax
80104554:	83 c0 08             	add    $0x8,%eax
80104557:	50                   	push   %eax
80104558:	e8 43 03 00 00       	call   801048a0 <getcallerpcs>
8010455d:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104560:	8b 17                	mov    (%edi),%edx
80104562:	85 d2                	test   %edx,%edx
80104564:	74 82                	je     801044e8 <procdump+0x18>
        cprintf(" %p", pc[i]);
80104566:	83 ec 08             	sub    $0x8,%esp
80104569:	83 c7 04             	add    $0x4,%edi
8010456c:	52                   	push   %edx
8010456d:	68 2b 7c 10 80       	push   $0x80107c2b
80104572:	e8 59 c4 ff ff       	call   801009d0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80104577:	83 c4 10             	add    $0x10,%esp
8010457a:	39 fe                	cmp    %edi,%esi
8010457c:	75 e2                	jne    80104560 <procdump+0x90>
8010457e:	e9 65 ff ff ff       	jmp    801044e8 <procdump+0x18>
80104583:	90                   	nop
80104584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  }
}
80104588:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010458b:	5b                   	pop    %ebx
8010458c:	5e                   	pop    %esi
8010458d:	5f                   	pop    %edi
8010458e:	5d                   	pop    %ebp
8010458f:	c3                   	ret    

80104590 <swapout>:

void
swapout(void){
80104590:	55                   	push   %ebp
80104591:	89 e5                	mov    %esp,%ebp
80104593:	83 ec 14             	sub    $0x14,%esp
  // this function is currently a test.
  // should be running in kernel mode... right????
  // make this function an infinite loop so it never returns.
  // int i;
  release(&ptable.lock);
80104596:	68 60 40 11 80       	push   $0x80114060
8010459b:	e8 f0 04 00 00       	call   80104a90 <release>
  
  cprintf("The swapout swapper has been loaded.\n");
801045a0:	c7 04 24 60 82 10 80 	movl   $0x80108260,(%esp)
801045a7:	e8 24 c4 ff ff       	call   801009d0 <cprintf>
801045ac:	83 c4 10             	add    $0x10,%esp
801045af:	90                   	nop
  
  for(;;){
    acquire(&swap.lock);
801045b0:	83 ec 0c             	sub    $0xc,%esp
801045b3:	68 20 40 11 80       	push   $0x80114020
801045b8:	e8 b3 03 00 00       	call   80104970 <acquire>
    sleep(&swap.chanswapout, &swap.lock);
801045bd:	58                   	pop    %eax
801045be:	5a                   	pop    %edx
801045bf:	68 20 40 11 80       	push   $0x80114020
801045c4:	68 58 40 11 80       	push   $0x80114058
801045c9:	e8 62 fc ff ff       	call   80104230 <sleep>
    // Save contents of that page to a file.
    // Take the memory and put it on kmem.freelist ??? (in kalloc.c)
    // Get the process to run kalloc again???? (by moving program counter back 
    // so that it executes kalloc).
    
    release(&swap.lock);
801045ce:	c7 04 24 20 40 11 80 	movl   $0x80114020,(%esp)
801045d5:	e8 b6 04 00 00       	call   80104a90 <release>
801045da:	83 c4 10             	add    $0x10,%esp
801045dd:	eb d1                	jmp    801045b0 <swapout+0x20>
801045df:	90                   	nop

801045e0 <swapin>:
}



void
swapin(void){
801045e0:	55                   	push   %ebp
801045e1:	89 e5                	mov    %esp,%ebp
801045e3:	83 ec 14             	sub    $0x14,%esp
  // this function is currently a test.
  // should be running in kernel mode... right????
  // make this function an infinite loop so it never returns.
  // int i;
  release(&ptable.lock);
801045e6:	68 60 40 11 80       	push   $0x80114060
801045eb:	e8 a0 04 00 00       	call   80104a90 <release>
  
  cprintf("The swapin swapper has been loaded.\n");
801045f0:	c7 04 24 88 82 10 80 	movl   $0x80108288,(%esp)
801045f7:	e8 d4 c3 ff ff       	call   801009d0 <cprintf>
801045fc:	83 c4 10             	add    $0x10,%esp
801045ff:	90                   	nop
  
  for(;;){
    acquire(&swap.lock);
80104600:	83 ec 0c             	sub    $0xc,%esp
80104603:	68 20 40 11 80       	push   $0x80114020
80104608:	e8 63 03 00 00       	call   80104970 <acquire>
    sleep(&swap.chanswapin, &swap.lock);
8010460d:	58                   	pop    %eax
8010460e:	5a                   	pop    %edx
8010460f:	68 20 40 11 80       	push   $0x80114020
80104614:	68 54 40 11 80       	push   $0x80114054
80104619:	e8 12 fc ff ff       	call   80104230 <sleep>
    // Find the place to put the page in the page table.
    // Load contents of page from file into page table.
    // release page table lock.
    // delete the file from disk.
    
    release(&swap.lock);
8010461e:	c7 04 24 20 40 11 80 	movl   $0x80114020,(%esp)
80104625:	e8 66 04 00 00       	call   80104a90 <release>
8010462a:	83 c4 10             	add    $0x10,%esp
8010462d:	eb d1                	jmp    80104600 <swapin+0x20>
8010462f:	90                   	nop

80104630 <create_kernel_process>:
}


void
create_kernel_process(const char *name, void (*entrypoint) ())
{
80104630:	55                   	push   %ebp
80104631:	89 e5                	mov    %esp,%ebp
80104633:	57                   	push   %edi
80104634:	56                   	push   %esi
80104635:	53                   	push   %ebx
80104636:	83 ec 0c             	sub    $0xc,%esp
80104639:	8b 7d 08             	mov    0x8(%ebp),%edi
8010463c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct proc *p;
  struct qnode *qn;
  
  // Allocate process
  if ((p = allocproc()) == 0)
8010463f:	e8 9c f4 ff ff       	call   80103ae0 <allocproc>
80104644:	85 c0                	test   %eax,%eax
80104646:	0f 84 ea 00 00 00    	je     80104736 <create_kernel_process+0x106>
8010464c:	89 c3                	mov    %eax,%ebx
    panic("Failed to allocate kernel process.");
  
  // qn = freenode;
  freenode = freenode->next;
8010464e:	a1 5c 40 11 80       	mov    0x8011405c,%eax
80104653:	8b 40 04             	mov    0x4(%eax),%eax
  if(freenode != 0)
80104656:	85 c0                	test   %eax,%eax
  freenode = freenode->next;
80104658:	a3 5c 40 11 80       	mov    %eax,0x8011405c
  if(freenode != 0)
8010465d:	74 07                	je     80104666 <create_kernel_process+0x36>
    freenode->prev = 0;
8010465f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  
  //setup page table
  if((p->pgdir = setupkvm()) == 0){
80104666:	e8 15 31 00 00       	call   80107780 <setupkvm>
8010466b:	85 c0                	test   %eax,%eax
8010466d:	89 43 04             	mov    %eax,0x4(%ebx)
80104670:	0f 84 cd 00 00 00    	je     80104743 <create_kernel_process+0x113>
    p->state = UNUSED;
    panic("Failed to setup pgdir for kernel process.");
  }
  //other parameters
  p->sz = PGSIZE;
  p->parent = initproc; // parent is the first process.
80104676:	a1 b8 b5 10 80       	mov    0x8010b5b8,%eax
  memset(p->tf, 0, sizeof(*p->tf));
8010467b:	83 ec 04             	sub    $0x4,%esp
  p->sz = PGSIZE;
8010467e:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  p->parent = initproc; // parent is the first process.
80104684:	89 43 14             	mov    %eax,0x14(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80104687:	6a 4c                	push   $0x4c
80104689:	6a 00                	push   $0x0
8010468b:	ff 73 18             	pushl  0x18(%ebx)
8010468e:	e8 5d 04 00 00       	call   80104af0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104693:	8b 43 18             	mov    0x18(%ebx),%eax
80104696:	ba 1b 00 00 00       	mov    $0x1b,%edx
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010469b:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046a0:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801046a4:	8b 43 18             	mov    0x18(%ebx),%eax
801046a7:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
801046ab:	8b 43 18             	mov    0x18(%ebx),%eax
801046ae:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801046b2:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801046b6:	8b 43 18             	mov    0x18(%ebx),%eax
801046b9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801046bd:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046c1:	8b 43 18             	mov    0x18(%ebx),%eax
801046c4:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046cb:	8b 43 18             	mov    0x18(%ebx),%eax
801046ce:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  
801046d5:	8b 43 18             	mov    0x18(%ebx),%eax
801046d8:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  p->tf->eax = 0;
801046df:	8b 43 18             	mov    0x18(%ebx),%eax
801046e2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  p->cwd = namei("/");
801046e9:	c7 04 24 8e 81 10 80 	movl   $0x8010818e,(%esp)
801046f0:	e8 4b dc ff ff       	call   80102340 <namei>
801046f5:	89 43 68             	mov    %eax,0x68(%ebx)
  safestrcpy(p->name, name, sizeof(name));
801046f8:	8d 43 6c             	lea    0x6c(%ebx),%eax
801046fb:	83 c4 0c             	add    $0xc,%esp
801046fe:	6a 04                	push   $0x4
80104700:	57                   	push   %edi
80104701:	50                   	push   %eax
80104702:	e8 c9 05 00 00       	call   80104cd0 <safestrcpy>
  qn->p = p;
  acquire(&ptable.lock);
80104707:	c7 04 24 60 40 11 80 	movl   $0x80114060,(%esp)
8010470e:	e8 5d 02 00 00       	call   80104970 <acquire>
  p->context->eip = (uint)entrypoint;
80104713:	8b 43 1c             	mov    0x1c(%ebx),%eax
  p->state = RUNNABLE;
  release(&ptable.lock);
80104716:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)entrypoint;
80104719:	89 70 10             	mov    %esi,0x10(%eax)
  p->state = RUNNABLE;
8010471c:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80104723:	c7 45 08 60 40 11 80 	movl   $0x80114060,0x8(%ebp)
}
8010472a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010472d:	5b                   	pop    %ebx
8010472e:	5e                   	pop    %esi
8010472f:	5f                   	pop    %edi
80104730:	5d                   	pop    %ebp
  release(&ptable.lock);
80104731:	e9 5a 03 00 00       	jmp    80104a90 <release>
    panic("Failed to allocate kernel process.");
80104736:	83 ec 0c             	sub    $0xc,%esp
80104739:	68 b0 82 10 80       	push   $0x801082b0
8010473e:	e8 bd bf ff ff       	call   80100700 <panic>
    kfree(p->kstack);
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	ff 73 08             	pushl  0x8(%ebx)
80104749:	e8 a2 e0 ff ff       	call   801027f0 <kfree>
    p->kstack = 0;
8010474e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    p->state = UNUSED;
80104755:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    panic("Failed to setup pgdir for kernel process.");
8010475c:	c7 04 24 d4 82 10 80 	movl   $0x801082d4,(%esp)
80104763:	e8 98 bf ff ff       	call   80100700 <panic>
80104768:	66 90                	xchg   %ax,%ax
8010476a:	66 90                	xchg   %ax,%ax
8010476c:	66 90                	xchg   %ax,%ax
8010476e:	66 90                	xchg   %ax,%ax

80104770 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104770:	55                   	push   %ebp
80104771:	89 e5                	mov    %esp,%ebp
80104773:	53                   	push   %ebx
80104774:	83 ec 0c             	sub    $0xc,%esp
80104777:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010477a:	68 18 83 10 80       	push   $0x80108318
8010477f:	8d 43 04             	lea    0x4(%ebx),%eax
80104782:	50                   	push   %eax
80104783:	e8 f8 00 00 00       	call   80104880 <initlock>
  lk->name = name;
80104788:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010478b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104791:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104794:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010479b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010479e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801047a1:	c9                   	leave  
801047a2:	c3                   	ret    
801047a3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801047a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801047b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801047b0:	55                   	push   %ebp
801047b1:	89 e5                	mov    %esp,%ebp
801047b3:	56                   	push   %esi
801047b4:	53                   	push   %ebx
801047b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801047b8:	83 ec 0c             	sub    $0xc,%esp
801047bb:	8d 73 04             	lea    0x4(%ebx),%esi
801047be:	56                   	push   %esi
801047bf:	e8 ac 01 00 00       	call   80104970 <acquire>
  while (lk->locked) {
801047c4:	8b 13                	mov    (%ebx),%edx
801047c6:	83 c4 10             	add    $0x10,%esp
801047c9:	85 d2                	test   %edx,%edx
801047cb:	74 16                	je     801047e3 <acquiresleep+0x33>
801047cd:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
801047d0:	83 ec 08             	sub    $0x8,%esp
801047d3:	56                   	push   %esi
801047d4:	53                   	push   %ebx
801047d5:	e8 56 fa ff ff       	call   80104230 <sleep>
  while (lk->locked) {
801047da:	8b 03                	mov    (%ebx),%eax
801047dc:	83 c4 10             	add    $0x10,%esp
801047df:	85 c0                	test   %eax,%eax
801047e1:	75 ed                	jne    801047d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
801047e3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801047e9:	e8 d2 f4 ff ff       	call   80103cc0 <myproc>
801047ee:	8b 40 10             	mov    0x10(%eax),%eax
801047f1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801047f4:	89 75 08             	mov    %esi,0x8(%ebp)
}
801047f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801047fa:	5b                   	pop    %ebx
801047fb:	5e                   	pop    %esi
801047fc:	5d                   	pop    %ebp
  release(&lk->lk);
801047fd:	e9 8e 02 00 00       	jmp    80104a90 <release>
80104802:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104809:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104810 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	56                   	push   %esi
80104814:	53                   	push   %ebx
80104815:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104818:	83 ec 0c             	sub    $0xc,%esp
8010481b:	8d 73 04             	lea    0x4(%ebx),%esi
8010481e:	56                   	push   %esi
8010481f:	e8 4c 01 00 00       	call   80104970 <acquire>
  lk->locked = 0;
80104824:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010482a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104831:	89 1c 24             	mov    %ebx,(%esp)
80104834:	e8 b7 fb ff ff       	call   801043f0 <wakeup>
  release(&lk->lk);
80104839:	89 75 08             	mov    %esi,0x8(%ebp)
8010483c:	83 c4 10             	add    $0x10,%esp
}
8010483f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104842:	5b                   	pop    %ebx
80104843:	5e                   	pop    %esi
80104844:	5d                   	pop    %ebp
  release(&lk->lk);
80104845:	e9 46 02 00 00       	jmp    80104a90 <release>
8010484a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104850 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104850:	55                   	push   %ebp
80104851:	89 e5                	mov    %esp,%ebp
80104853:	56                   	push   %esi
80104854:	53                   	push   %ebx
80104855:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
80104858:	83 ec 0c             	sub    $0xc,%esp
8010485b:	8d 5e 04             	lea    0x4(%esi),%ebx
8010485e:	53                   	push   %ebx
8010485f:	e8 0c 01 00 00       	call   80104970 <acquire>
  r = lk->locked;
80104864:	8b 36                	mov    (%esi),%esi
  release(&lk->lk);
80104866:	89 1c 24             	mov    %ebx,(%esp)
80104869:	e8 22 02 00 00       	call   80104a90 <release>
  return r;
}
8010486e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104871:	89 f0                	mov    %esi,%eax
80104873:	5b                   	pop    %ebx
80104874:	5e                   	pop    %esi
80104875:	5d                   	pop    %ebp
80104876:	c3                   	ret    
80104877:	66 90                	xchg   %ax,%ax
80104879:	66 90                	xchg   %ax,%ax
8010487b:	66 90                	xchg   %ax,%ax
8010487d:	66 90                	xchg   %ax,%ax
8010487f:	90                   	nop

80104880 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104880:	55                   	push   %ebp
80104881:	89 e5                	mov    %esp,%ebp
80104883:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104886:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104889:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010488f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104892:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104899:	5d                   	pop    %ebp
8010489a:	c3                   	ret    
8010489b:	90                   	nop
8010489c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801048a0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801048a0:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801048a1:	31 d2                	xor    %edx,%edx
{
801048a3:	89 e5                	mov    %esp,%ebp
801048a5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801048a6:	8b 45 08             	mov    0x8(%ebp),%eax
{
801048a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801048ac:	83 e8 08             	sub    $0x8,%eax
801048af:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801048b0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801048b6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801048bc:	77 1a                	ja     801048d8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801048be:	8b 58 04             	mov    0x4(%eax),%ebx
801048c1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801048c4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801048c7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801048c9:	83 fa 0a             	cmp    $0xa,%edx
801048cc:	75 e2                	jne    801048b0 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801048ce:	5b                   	pop    %ebx
801048cf:	5d                   	pop    %ebp
801048d0:	c3                   	ret    
801048d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048d8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801048db:	83 c1 28             	add    $0x28,%ecx
801048de:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801048e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801048e6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
801048e9:	39 c1                	cmp    %eax,%ecx
801048eb:	75 f3                	jne    801048e0 <getcallerpcs+0x40>
}
801048ed:	5b                   	pop    %ebx
801048ee:	5d                   	pop    %ebp
801048ef:	c3                   	ret    

801048f0 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801048f0:	55                   	push   %ebp
801048f1:	89 e5                	mov    %esp,%ebp
801048f3:	53                   	push   %ebx
801048f4:	83 ec 04             	sub    $0x4,%esp
801048f7:	8b 55 08             	mov    0x8(%ebp),%edx
  return lock->locked && lock->cpu == mycpu();
801048fa:	8b 02                	mov    (%edx),%eax
801048fc:	85 c0                	test   %eax,%eax
801048fe:	75 10                	jne    80104910 <holding+0x20>
}
80104900:	83 c4 04             	add    $0x4,%esp
80104903:	31 c0                	xor    %eax,%eax
80104905:	5b                   	pop    %ebx
80104906:	5d                   	pop    %ebp
80104907:	c3                   	ret    
80104908:	90                   	nop
80104909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return lock->locked && lock->cpu == mycpu();
80104910:	8b 5a 08             	mov    0x8(%edx),%ebx
80104913:	e8 08 f3 ff ff       	call   80103c20 <mycpu>
80104918:	39 c3                	cmp    %eax,%ebx
8010491a:	0f 94 c0             	sete   %al
}
8010491d:	83 c4 04             	add    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104920:	0f b6 c0             	movzbl %al,%eax
}
80104923:	5b                   	pop    %ebx
80104924:	5d                   	pop    %ebp
80104925:	c3                   	ret    
80104926:	8d 76 00             	lea    0x0(%esi),%esi
80104929:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104930 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104930:	55                   	push   %ebp
80104931:	89 e5                	mov    %esp,%ebp
80104933:	53                   	push   %ebx
80104934:	83 ec 04             	sub    $0x4,%esp
80104937:	9c                   	pushf  
80104938:	5b                   	pop    %ebx
  asm volatile("cli");
80104939:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
8010493a:	e8 e1 f2 ff ff       	call   80103c20 <mycpu>
8010493f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104945:	85 c0                	test   %eax,%eax
80104947:	75 11                	jne    8010495a <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
80104949:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010494f:	e8 cc f2 ff ff       	call   80103c20 <mycpu>
80104954:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
8010495a:	e8 c1 f2 ff ff       	call   80103c20 <mycpu>
8010495f:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104966:	83 c4 04             	add    $0x4,%esp
80104969:	5b                   	pop    %ebx
8010496a:	5d                   	pop    %ebp
8010496b:	c3                   	ret    
8010496c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104970 <acquire>:
{
80104970:	55                   	push   %ebp
80104971:	89 e5                	mov    %esp,%ebp
80104973:	56                   	push   %esi
80104974:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
80104975:	e8 b6 ff ff ff       	call   80104930 <pushcli>
  if(holding(lk))
8010497a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  return lock->locked && lock->cpu == mycpu();
8010497d:	8b 03                	mov    (%ebx),%eax
8010497f:	85 c0                	test   %eax,%eax
80104981:	0f 85 81 00 00 00    	jne    80104a08 <acquire+0x98>
  asm volatile("lock; xchgl %0, %1" :
80104987:	ba 01 00 00 00       	mov    $0x1,%edx
8010498c:	eb 05                	jmp    80104993 <acquire+0x23>
8010498e:	66 90                	xchg   %ax,%ax
80104990:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104993:	89 d0                	mov    %edx,%eax
80104995:	f0 87 03             	lock xchg %eax,(%ebx)
  while(xchg(&lk->locked, 1) != 0)
80104998:	85 c0                	test   %eax,%eax
8010499a:	75 f4                	jne    80104990 <acquire+0x20>
  __sync_synchronize();
8010499c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
801049a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801049a4:	e8 77 f2 ff ff       	call   80103c20 <mycpu>
  for(i = 0; i < 10; i++){
801049a9:	31 d2                	xor    %edx,%edx
  getcallerpcs(&lk, lk->pcs);
801049ab:	8d 4b 0c             	lea    0xc(%ebx),%ecx
  lk->cpu = mycpu();
801049ae:	89 43 08             	mov    %eax,0x8(%ebx)
  ebp = (uint*)v - 2;
801049b1:	89 e8                	mov    %ebp,%eax
801049b3:	90                   	nop
801049b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049b8:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801049be:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801049c4:	77 1a                	ja     801049e0 <acquire+0x70>
    pcs[i] = ebp[1];     // saved %eip
801049c6:	8b 58 04             	mov    0x4(%eax),%ebx
801049c9:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801049cc:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801049cf:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801049d1:	83 fa 0a             	cmp    $0xa,%edx
801049d4:	75 e2                	jne    801049b8 <acquire+0x48>
}
801049d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801049d9:	5b                   	pop    %ebx
801049da:	5e                   	pop    %esi
801049db:	5d                   	pop    %ebp
801049dc:	c3                   	ret    
801049dd:	8d 76 00             	lea    0x0(%esi),%esi
801049e0:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801049e3:	83 c1 28             	add    $0x28,%ecx
801049e6:	8d 76 00             	lea    0x0(%esi),%esi
801049e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    pcs[i] = 0;
801049f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801049f6:	83 c0 04             	add    $0x4,%eax
  for(; i < 10; i++)
801049f9:	39 c8                	cmp    %ecx,%eax
801049fb:	75 f3                	jne    801049f0 <acquire+0x80>
}
801049fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a00:	5b                   	pop    %ebx
80104a01:	5e                   	pop    %esi
80104a02:	5d                   	pop    %ebp
80104a03:	c3                   	ret    
80104a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return lock->locked && lock->cpu == mycpu();
80104a08:	8b 73 08             	mov    0x8(%ebx),%esi
80104a0b:	e8 10 f2 ff ff       	call   80103c20 <mycpu>
80104a10:	39 c6                	cmp    %eax,%esi
80104a12:	0f 85 6f ff ff ff    	jne    80104987 <acquire+0x17>
    panic("acquire");
80104a18:	83 ec 0c             	sub    $0xc,%esp
80104a1b:	68 23 83 10 80       	push   $0x80108323
80104a20:	e8 db bc ff ff       	call   80100700 <panic>
80104a25:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104a30 <popcli>:

void
popcli(void)
{
80104a30:	55                   	push   %ebp
80104a31:	89 e5                	mov    %esp,%ebp
80104a33:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a36:	9c                   	pushf  
80104a37:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104a38:	f6 c4 02             	test   $0x2,%ah
80104a3b:	75 35                	jne    80104a72 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104a3d:	e8 de f1 ff ff       	call   80103c20 <mycpu>
80104a42:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104a49:	78 34                	js     80104a7f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a4b:	e8 d0 f1 ff ff       	call   80103c20 <mycpu>
80104a50:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a56:	85 d2                	test   %edx,%edx
80104a58:	74 06                	je     80104a60 <popcli+0x30>
    sti();
}
80104a5a:	c9                   	leave  
80104a5b:	c3                   	ret    
80104a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a60:	e8 bb f1 ff ff       	call   80103c20 <mycpu>
80104a65:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a6b:	85 c0                	test   %eax,%eax
80104a6d:	74 eb                	je     80104a5a <popcli+0x2a>
  asm volatile("sti");
80104a6f:	fb                   	sti    
}
80104a70:	c9                   	leave  
80104a71:	c3                   	ret    
    panic("popcli - interruptible");
80104a72:	83 ec 0c             	sub    $0xc,%esp
80104a75:	68 2b 83 10 80       	push   $0x8010832b
80104a7a:	e8 81 bc ff ff       	call   80100700 <panic>
    panic("popcli");
80104a7f:	83 ec 0c             	sub    $0xc,%esp
80104a82:	68 42 83 10 80       	push   $0x80108342
80104a87:	e8 74 bc ff ff       	call   80100700 <panic>
80104a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104a90 <release>:
{
80104a90:	55                   	push   %ebp
80104a91:	89 e5                	mov    %esp,%ebp
80104a93:	56                   	push   %esi
80104a94:	53                   	push   %ebx
80104a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  return lock->locked && lock->cpu == mycpu();
80104a98:	8b 03                	mov    (%ebx),%eax
80104a9a:	85 c0                	test   %eax,%eax
80104a9c:	74 0c                	je     80104aaa <release+0x1a>
80104a9e:	8b 73 08             	mov    0x8(%ebx),%esi
80104aa1:	e8 7a f1 ff ff       	call   80103c20 <mycpu>
80104aa6:	39 c6                	cmp    %eax,%esi
80104aa8:	74 16                	je     80104ac0 <release+0x30>
    panic("release");
80104aaa:	83 ec 0c             	sub    $0xc,%esp
80104aad:	68 49 83 10 80       	push   $0x80108349
80104ab2:	e8 49 bc ff ff       	call   80100700 <panic>
80104ab7:	89 f6                	mov    %esi,%esi
80104ab9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  lk->pcs[0] = 0;
80104ac0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104ac7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104ace:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104ad3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104adc:	5b                   	pop    %ebx
80104add:	5e                   	pop    %esi
80104ade:	5d                   	pop    %ebp
  popcli();
80104adf:	e9 4c ff ff ff       	jmp    80104a30 <popcli>
80104ae4:	66 90                	xchg   %ax,%ax
80104ae6:	66 90                	xchg   %ax,%ax
80104ae8:	66 90                	xchg   %ax,%ax
80104aea:	66 90                	xchg   %ax,%ax
80104aec:	66 90                	xchg   %ax,%ax
80104aee:	66 90                	xchg   %ax,%ax

80104af0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104af0:	55                   	push   %ebp
80104af1:	89 e5                	mov    %esp,%ebp
80104af3:	57                   	push   %edi
80104af4:	53                   	push   %ebx
80104af5:	8b 55 08             	mov    0x8(%ebp),%edx
80104af8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80104afb:	f6 c2 03             	test   $0x3,%dl
80104afe:	75 05                	jne    80104b05 <memset+0x15>
80104b00:	f6 c1 03             	test   $0x3,%cl
80104b03:	74 13                	je     80104b18 <memset+0x28>
  asm volatile("cld; rep stosb" :
80104b05:	89 d7                	mov    %edx,%edi
80104b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b0a:	fc                   	cld    
80104b0b:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104b0d:	5b                   	pop    %ebx
80104b0e:	89 d0                	mov    %edx,%eax
80104b10:	5f                   	pop    %edi
80104b11:	5d                   	pop    %ebp
80104b12:	c3                   	ret    
80104b13:	90                   	nop
80104b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c &= 0xFF;
80104b18:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104b1c:	c1 e9 02             	shr    $0x2,%ecx
80104b1f:	89 f8                	mov    %edi,%eax
80104b21:	89 fb                	mov    %edi,%ebx
80104b23:	c1 e0 18             	shl    $0x18,%eax
80104b26:	c1 e3 10             	shl    $0x10,%ebx
80104b29:	09 d8                	or     %ebx,%eax
80104b2b:	09 f8                	or     %edi,%eax
80104b2d:	c1 e7 08             	shl    $0x8,%edi
80104b30:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104b32:	89 d7                	mov    %edx,%edi
80104b34:	fc                   	cld    
80104b35:	f3 ab                	rep stos %eax,%es:(%edi)
}
80104b37:	5b                   	pop    %ebx
80104b38:	89 d0                	mov    %edx,%eax
80104b3a:	5f                   	pop    %edi
80104b3b:	5d                   	pop    %ebp
80104b3c:	c3                   	ret    
80104b3d:	8d 76 00             	lea    0x0(%esi),%esi

80104b40 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	57                   	push   %edi
80104b44:	56                   	push   %esi
80104b45:	53                   	push   %ebx
80104b46:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104b49:	8b 75 08             	mov    0x8(%ebp),%esi
80104b4c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104b4f:	85 db                	test   %ebx,%ebx
80104b51:	74 29                	je     80104b7c <memcmp+0x3c>
    if(*s1 != *s2)
80104b53:	0f b6 16             	movzbl (%esi),%edx
80104b56:	0f b6 0f             	movzbl (%edi),%ecx
80104b59:	38 d1                	cmp    %dl,%cl
80104b5b:	75 2b                	jne    80104b88 <memcmp+0x48>
80104b5d:	b8 01 00 00 00       	mov    $0x1,%eax
80104b62:	eb 14                	jmp    80104b78 <memcmp+0x38>
80104b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b68:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104b6c:	83 c0 01             	add    $0x1,%eax
80104b6f:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104b74:	38 ca                	cmp    %cl,%dl
80104b76:	75 10                	jne    80104b88 <memcmp+0x48>
  while(n-- > 0){
80104b78:	39 d8                	cmp    %ebx,%eax
80104b7a:	75 ec                	jne    80104b68 <memcmp+0x28>
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
}
80104b7c:	5b                   	pop    %ebx
  return 0;
80104b7d:	31 c0                	xor    %eax,%eax
}
80104b7f:	5e                   	pop    %esi
80104b80:	5f                   	pop    %edi
80104b81:	5d                   	pop    %ebp
80104b82:	c3                   	ret    
80104b83:	90                   	nop
80104b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      return *s1 - *s2;
80104b88:	0f b6 c2             	movzbl %dl,%eax
}
80104b8b:	5b                   	pop    %ebx
      return *s1 - *s2;
80104b8c:	29 c8                	sub    %ecx,%eax
}
80104b8e:	5e                   	pop    %esi
80104b8f:	5f                   	pop    %edi
80104b90:	5d                   	pop    %ebp
80104b91:	c3                   	ret    
80104b92:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ba0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	56                   	push   %esi
80104ba4:	53                   	push   %ebx
80104ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104bab:	8b 75 10             	mov    0x10(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104bae:	39 c3                	cmp    %eax,%ebx
80104bb0:	73 26                	jae    80104bd8 <memmove+0x38>
80104bb2:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
80104bb5:	39 c8                	cmp    %ecx,%eax
80104bb7:	73 1f                	jae    80104bd8 <memmove+0x38>
    s += n;
    d += n;
    while(n-- > 0)
80104bb9:	85 f6                	test   %esi,%esi
80104bbb:	8d 56 ff             	lea    -0x1(%esi),%edx
80104bbe:	74 0f                	je     80104bcf <memmove+0x2f>
      *--d = *--s;
80104bc0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104bc4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    while(n-- > 0)
80104bc7:	83 ea 01             	sub    $0x1,%edx
80104bca:	83 fa ff             	cmp    $0xffffffff,%edx
80104bcd:	75 f1                	jne    80104bc0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104bcf:	5b                   	pop    %ebx
80104bd0:	5e                   	pop    %esi
80104bd1:	5d                   	pop    %ebp
80104bd2:	c3                   	ret    
80104bd3:	90                   	nop
80104bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    while(n-- > 0)
80104bd8:	31 d2                	xor    %edx,%edx
80104bda:	85 f6                	test   %esi,%esi
80104bdc:	74 f1                	je     80104bcf <memmove+0x2f>
80104bde:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80104be0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
80104be4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80104be7:	83 c2 01             	add    $0x1,%edx
    while(n-- > 0)
80104bea:	39 d6                	cmp    %edx,%esi
80104bec:	75 f2                	jne    80104be0 <memmove+0x40>
}
80104bee:	5b                   	pop    %ebx
80104bef:	5e                   	pop    %esi
80104bf0:	5d                   	pop    %ebp
80104bf1:	c3                   	ret    
80104bf2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c00 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104c00:	55                   	push   %ebp
80104c01:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80104c03:	5d                   	pop    %ebp
  return memmove(dst, src, n);
80104c04:	eb 9a                	jmp    80104ba0 <memmove>
80104c06:	8d 76 00             	lea    0x0(%esi),%esi
80104c09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104c10 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104c10:	55                   	push   %ebp
80104c11:	89 e5                	mov    %esp,%ebp
80104c13:	57                   	push   %edi
80104c14:	56                   	push   %esi
80104c15:	8b 7d 10             	mov    0x10(%ebp),%edi
80104c18:	53                   	push   %ebx
80104c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104c1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  while(n > 0 && *p && *p == *q)
80104c1f:	85 ff                	test   %edi,%edi
80104c21:	74 2f                	je     80104c52 <strncmp+0x42>
80104c23:	0f b6 01             	movzbl (%ecx),%eax
80104c26:	0f b6 1e             	movzbl (%esi),%ebx
80104c29:	84 c0                	test   %al,%al
80104c2b:	74 37                	je     80104c64 <strncmp+0x54>
80104c2d:	38 c3                	cmp    %al,%bl
80104c2f:	75 33                	jne    80104c64 <strncmp+0x54>
80104c31:	01 f7                	add    %esi,%edi
80104c33:	eb 13                	jmp    80104c48 <strncmp+0x38>
80104c35:	8d 76 00             	lea    0x0(%esi),%esi
80104c38:	0f b6 01             	movzbl (%ecx),%eax
80104c3b:	84 c0                	test   %al,%al
80104c3d:	74 21                	je     80104c60 <strncmp+0x50>
80104c3f:	0f b6 1a             	movzbl (%edx),%ebx
80104c42:	89 d6                	mov    %edx,%esi
80104c44:	38 d8                	cmp    %bl,%al
80104c46:	75 1c                	jne    80104c64 <strncmp+0x54>
    n--, p++, q++;
80104c48:	8d 56 01             	lea    0x1(%esi),%edx
80104c4b:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104c4e:	39 fa                	cmp    %edi,%edx
80104c50:	75 e6                	jne    80104c38 <strncmp+0x28>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
}
80104c52:	5b                   	pop    %ebx
    return 0;
80104c53:	31 c0                	xor    %eax,%eax
}
80104c55:	5e                   	pop    %esi
80104c56:	5f                   	pop    %edi
80104c57:	5d                   	pop    %ebp
80104c58:	c3                   	ret    
80104c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c60:	0f b6 5e 01          	movzbl 0x1(%esi),%ebx
  return (uchar)*p - (uchar)*q;
80104c64:	29 d8                	sub    %ebx,%eax
}
80104c66:	5b                   	pop    %ebx
80104c67:	5e                   	pop    %esi
80104c68:	5f                   	pop    %edi
80104c69:	5d                   	pop    %ebp
80104c6a:	c3                   	ret    
80104c6b:	90                   	nop
80104c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104c70 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c70:	55                   	push   %ebp
80104c71:	89 e5                	mov    %esp,%ebp
80104c73:	56                   	push   %esi
80104c74:	53                   	push   %ebx
80104c75:	8b 45 08             	mov    0x8(%ebp),%eax
80104c78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c7e:	89 c2                	mov    %eax,%edx
80104c80:	eb 19                	jmp    80104c9b <strncpy+0x2b>
80104c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104c88:	83 c3 01             	add    $0x1,%ebx
80104c8b:	0f b6 4b ff          	movzbl -0x1(%ebx),%ecx
80104c8f:	83 c2 01             	add    $0x1,%edx
80104c92:	84 c9                	test   %cl,%cl
80104c94:	88 4a ff             	mov    %cl,-0x1(%edx)
80104c97:	74 09                	je     80104ca2 <strncpy+0x32>
80104c99:	89 f1                	mov    %esi,%ecx
80104c9b:	85 c9                	test   %ecx,%ecx
80104c9d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80104ca0:	7f e6                	jg     80104c88 <strncpy+0x18>
    ;
  while(n-- > 0)
80104ca2:	31 c9                	xor    %ecx,%ecx
80104ca4:	85 f6                	test   %esi,%esi
80104ca6:	7e 17                	jle    80104cbf <strncpy+0x4f>
80104ca8:	90                   	nop
80104ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104cb0:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
80104cb4:	89 f3                	mov    %esi,%ebx
80104cb6:	83 c1 01             	add    $0x1,%ecx
80104cb9:	29 cb                	sub    %ecx,%ebx
  while(n-- > 0)
80104cbb:	85 db                	test   %ebx,%ebx
80104cbd:	7f f1                	jg     80104cb0 <strncpy+0x40>
  return os;
}
80104cbf:	5b                   	pop    %ebx
80104cc0:	5e                   	pop    %esi
80104cc1:	5d                   	pop    %ebp
80104cc2:	c3                   	ret    
80104cc3:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104cd0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
80104cd3:	56                   	push   %esi
80104cd4:	53                   	push   %ebx
80104cd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80104cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104cde:	85 c9                	test   %ecx,%ecx
80104ce0:	7e 26                	jle    80104d08 <safestrcpy+0x38>
80104ce2:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
80104ce6:	89 c1                	mov    %eax,%ecx
80104ce8:	eb 17                	jmp    80104d01 <safestrcpy+0x31>
80104cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104cf0:	83 c2 01             	add    $0x1,%edx
80104cf3:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
80104cf7:	83 c1 01             	add    $0x1,%ecx
80104cfa:	84 db                	test   %bl,%bl
80104cfc:	88 59 ff             	mov    %bl,-0x1(%ecx)
80104cff:	74 04                	je     80104d05 <safestrcpy+0x35>
80104d01:	39 f2                	cmp    %esi,%edx
80104d03:	75 eb                	jne    80104cf0 <safestrcpy+0x20>
    ;
  *s = 0;
80104d05:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104d08:	5b                   	pop    %ebx
80104d09:	5e                   	pop    %esi
80104d0a:	5d                   	pop    %ebp
80104d0b:	c3                   	ret    
80104d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104d10 <strlen>:

int
strlen(const char *s)
{
80104d10:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104d11:	31 c0                	xor    %eax,%eax
{
80104d13:	89 e5                	mov    %esp,%ebp
80104d15:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104d18:	80 3a 00             	cmpb   $0x0,(%edx)
80104d1b:	74 0c                	je     80104d29 <strlen+0x19>
80104d1d:	8d 76 00             	lea    0x0(%esi),%esi
80104d20:	83 c0 01             	add    $0x1,%eax
80104d23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104d27:	75 f7                	jne    80104d20 <strlen+0x10>
    ;
  return n;
}
80104d29:	5d                   	pop    %ebp
80104d2a:	c3                   	ret    

80104d2b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104d2b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104d2f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104d33:	55                   	push   %ebp
  pushl %ebx
80104d34:	53                   	push   %ebx
  pushl %esi
80104d35:	56                   	push   %esi
  pushl %edi
80104d36:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d37:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d39:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d3b:	5f                   	pop    %edi
  popl %esi
80104d3c:	5e                   	pop    %esi
  popl %ebx
80104d3d:	5b                   	pop    %ebx
  popl %ebp
80104d3e:	5d                   	pop    %ebp
  ret
80104d3f:	c3                   	ret    

80104d40 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
80104d43:	53                   	push   %ebx
80104d44:	83 ec 04             	sub    $0x4,%esp
80104d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104d4a:	e8 71 ef ff ff       	call   80103cc0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104d4f:	8b 00                	mov    (%eax),%eax
80104d51:	39 d8                	cmp    %ebx,%eax
80104d53:	76 1b                	jbe    80104d70 <fetchint+0x30>
80104d55:	8d 53 04             	lea    0x4(%ebx),%edx
80104d58:	39 d0                	cmp    %edx,%eax
80104d5a:	72 14                	jb     80104d70 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5f:	8b 13                	mov    (%ebx),%edx
80104d61:	89 10                	mov    %edx,(%eax)
  return 0;
80104d63:	31 c0                	xor    %eax,%eax
}
80104d65:	83 c4 04             	add    $0x4,%esp
80104d68:	5b                   	pop    %ebx
80104d69:	5d                   	pop    %ebp
80104d6a:	c3                   	ret    
80104d6b:	90                   	nop
80104d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d75:	eb ee                	jmp    80104d65 <fetchint+0x25>
80104d77:	89 f6                	mov    %esi,%esi
80104d79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104d80 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104d80:	55                   	push   %ebp
80104d81:	89 e5                	mov    %esp,%ebp
80104d83:	53                   	push   %ebx
80104d84:	83 ec 04             	sub    $0x4,%esp
80104d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104d8a:	e8 31 ef ff ff       	call   80103cc0 <myproc>

  if(addr >= curproc->sz)
80104d8f:	39 18                	cmp    %ebx,(%eax)
80104d91:	76 29                	jbe    80104dbc <fetchstr+0x3c>
    return -1;
  *pp = (char*)addr;
80104d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104d96:	89 da                	mov    %ebx,%edx
80104d98:	89 19                	mov    %ebx,(%ecx)
  ep = (char*)curproc->sz;
80104d9a:	8b 00                	mov    (%eax),%eax
  for(s = *pp; s < ep; s++){
80104d9c:	39 c3                	cmp    %eax,%ebx
80104d9e:	73 1c                	jae    80104dbc <fetchstr+0x3c>
    if(*s == 0)
80104da0:	80 3b 00             	cmpb   $0x0,(%ebx)
80104da3:	75 10                	jne    80104db5 <fetchstr+0x35>
80104da5:	eb 39                	jmp    80104de0 <fetchstr+0x60>
80104da7:	89 f6                	mov    %esi,%esi
80104da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104db0:	80 3a 00             	cmpb   $0x0,(%edx)
80104db3:	74 1b                	je     80104dd0 <fetchstr+0x50>
  for(s = *pp; s < ep; s++){
80104db5:	83 c2 01             	add    $0x1,%edx
80104db8:	39 d0                	cmp    %edx,%eax
80104dba:	77 f4                	ja     80104db0 <fetchstr+0x30>
    return -1;
80104dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      return s - *pp;
  }
  return -1;
}
80104dc1:	83 c4 04             	add    $0x4,%esp
80104dc4:	5b                   	pop    %ebx
80104dc5:	5d                   	pop    %ebp
80104dc6:	c3                   	ret    
80104dc7:	89 f6                	mov    %esi,%esi
80104dc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80104dd0:	83 c4 04             	add    $0x4,%esp
80104dd3:	89 d0                	mov    %edx,%eax
80104dd5:	29 d8                	sub    %ebx,%eax
80104dd7:	5b                   	pop    %ebx
80104dd8:	5d                   	pop    %ebp
80104dd9:	c3                   	ret    
80104dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(*s == 0)
80104de0:	31 c0                	xor    %eax,%eax
      return s - *pp;
80104de2:	eb dd                	jmp    80104dc1 <fetchstr+0x41>
80104de4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104dea:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80104df0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
80104df3:	56                   	push   %esi
80104df4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104df5:	e8 c6 ee ff ff       	call   80103cc0 <myproc>
80104dfa:	8b 40 18             	mov    0x18(%eax),%eax
80104dfd:	8b 55 08             	mov    0x8(%ebp),%edx
80104e00:	8b 40 44             	mov    0x44(%eax),%eax
80104e03:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104e06:	e8 b5 ee ff ff       	call   80103cc0 <myproc>
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e0b:	8b 00                	mov    (%eax),%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e0d:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e10:	39 c6                	cmp    %eax,%esi
80104e12:	73 1c                	jae    80104e30 <argint+0x40>
80104e14:	8d 53 08             	lea    0x8(%ebx),%edx
80104e17:	39 d0                	cmp    %edx,%eax
80104e19:	72 15                	jb     80104e30 <argint+0x40>
  *ip = *(int*)(addr);
80104e1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e1e:	8b 53 04             	mov    0x4(%ebx),%edx
80104e21:	89 10                	mov    %edx,(%eax)
  return 0;
80104e23:	31 c0                	xor    %eax,%eax
}
80104e25:	5b                   	pop    %ebx
80104e26:	5e                   	pop    %esi
80104e27:	5d                   	pop    %ebp
80104e28:	c3                   	ret    
80104e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104e30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104e35:	eb ee                	jmp    80104e25 <argint+0x35>
80104e37:	89 f6                	mov    %esi,%esi
80104e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104e40 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	56                   	push   %esi
80104e44:	53                   	push   %ebx
80104e45:	83 ec 10             	sub    $0x10,%esp
80104e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104e4b:	e8 70 ee ff ff       	call   80103cc0 <myproc>
80104e50:	89 c6                	mov    %eax,%esi

  if(argint(n, &i) < 0)
80104e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e55:	83 ec 08             	sub    $0x8,%esp
80104e58:	50                   	push   %eax
80104e59:	ff 75 08             	pushl  0x8(%ebp)
80104e5c:	e8 8f ff ff ff       	call   80104df0 <argint>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104e61:	83 c4 10             	add    $0x10,%esp
80104e64:	85 c0                	test   %eax,%eax
80104e66:	78 28                	js     80104e90 <argptr+0x50>
80104e68:	85 db                	test   %ebx,%ebx
80104e6a:	78 24                	js     80104e90 <argptr+0x50>
80104e6c:	8b 16                	mov    (%esi),%edx
80104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e71:	39 c2                	cmp    %eax,%edx
80104e73:	76 1b                	jbe    80104e90 <argptr+0x50>
80104e75:	01 c3                	add    %eax,%ebx
80104e77:	39 da                	cmp    %ebx,%edx
80104e79:	72 15                	jb     80104e90 <argptr+0x50>
    return -1;
  *pp = (char*)i;
80104e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e7e:	89 02                	mov    %eax,(%edx)
  return 0;
80104e80:	31 c0                	xor    %eax,%eax
}
80104e82:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e85:	5b                   	pop    %ebx
80104e86:	5e                   	pop    %esi
80104e87:	5d                   	pop    %ebp
80104e88:	c3                   	ret    
80104e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e95:	eb eb                	jmp    80104e82 <argptr+0x42>
80104e97:	89 f6                	mov    %esi,%esi
80104e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ea0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104ea6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ea9:	50                   	push   %eax
80104eaa:	ff 75 08             	pushl  0x8(%ebp)
80104ead:	e8 3e ff ff ff       	call   80104df0 <argint>
80104eb2:	83 c4 10             	add    $0x10,%esp
80104eb5:	85 c0                	test   %eax,%eax
80104eb7:	78 17                	js     80104ed0 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
80104eb9:	83 ec 08             	sub    $0x8,%esp
80104ebc:	ff 75 0c             	pushl  0xc(%ebp)
80104ebf:	ff 75 f4             	pushl  -0xc(%ebp)
80104ec2:	e8 b9 fe ff ff       	call   80104d80 <fetchstr>
80104ec7:	83 c4 10             	add    $0x10,%esp
}
80104eca:	c9                   	leave  
80104ecb:	c3                   	ret    
80104ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104ed0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ed5:	c9                   	leave  
80104ed6:	c3                   	ret    
80104ed7:	89 f6                	mov    %esi,%esi
80104ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80104ee0 <syscall>:
[SYS_swap]    sys_swap,
};

void
syscall(void)
{
80104ee0:	55                   	push   %ebp
80104ee1:	89 e5                	mov    %esp,%ebp
80104ee3:	53                   	push   %ebx
80104ee4:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104ee7:	e8 d4 ed ff ff       	call   80103cc0 <myproc>
80104eec:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104eee:	8b 40 18             	mov    0x18(%eax),%eax
80104ef1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104ef4:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ef7:	83 fa 16             	cmp    $0x16,%edx
80104efa:	77 1c                	ja     80104f18 <syscall+0x38>
80104efc:	8b 14 85 80 83 10 80 	mov    -0x7fef7c80(,%eax,4),%edx
80104f03:	85 d2                	test   %edx,%edx
80104f05:	74 11                	je     80104f18 <syscall+0x38>
    curproc->tf->eax = syscalls[num]();
80104f07:	ff d2                	call   *%edx
80104f09:	8b 53 18             	mov    0x18(%ebx),%edx
80104f0c:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104f0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f12:	c9                   	leave  
80104f13:	c3                   	ret    
80104f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cprintf("%d %s: unknown sys call %d\n",
80104f18:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80104f19:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80104f1c:	50                   	push   %eax
80104f1d:	ff 73 10             	pushl  0x10(%ebx)
80104f20:	68 51 83 10 80       	push   $0x80108351
80104f25:	e8 a6 ba ff ff       	call   801009d0 <cprintf>
    curproc->tf->eax = -1;
80104f2a:	8b 43 18             	mov    0x18(%ebx),%eax
80104f2d:	83 c4 10             	add    $0x10,%esp
80104f30:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
80104f37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f3a:	c9                   	leave  
80104f3b:	c3                   	ret    
80104f3c:	66 90                	xchg   %ax,%ax
80104f3e:	66 90                	xchg   %ax,%ax

80104f40 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104f40:	55                   	push   %ebp
80104f41:	89 e5                	mov    %esp,%ebp
80104f43:	57                   	push   %edi
80104f44:	56                   	push   %esi
80104f45:	53                   	push   %ebx
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104f46:	8d 75 da             	lea    -0x26(%ebp),%esi
{
80104f49:	83 ec 44             	sub    $0x44,%esp
80104f4c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104f4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
80104f52:	56                   	push   %esi
80104f53:	50                   	push   %eax
{
80104f54:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104f57:	89 4d bc             	mov    %ecx,-0x44(%ebp)
  if((dp = nameiparent(path, name)) == 0)
80104f5a:	e8 01 d4 ff ff       	call   80102360 <nameiparent>
80104f5f:	83 c4 10             	add    $0x10,%esp
80104f62:	85 c0                	test   %eax,%eax
80104f64:	0f 84 46 01 00 00    	je     801050b0 <create+0x170>
    return 0;
  ilock(dp);
80104f6a:	83 ec 0c             	sub    $0xc,%esp
80104f6d:	89 c3                	mov    %eax,%ebx
80104f6f:	50                   	push   %eax
80104f70:	e8 6b cb ff ff       	call   80101ae0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104f75:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80104f78:	83 c4 0c             	add    $0xc,%esp
80104f7b:	50                   	push   %eax
80104f7c:	56                   	push   %esi
80104f7d:	53                   	push   %ebx
80104f7e:	e8 8d d0 ff ff       	call   80102010 <dirlookup>
80104f83:	83 c4 10             	add    $0x10,%esp
80104f86:	85 c0                	test   %eax,%eax
80104f88:	89 c7                	mov    %eax,%edi
80104f8a:	74 34                	je     80104fc0 <create+0x80>
    iunlockput(dp);
80104f8c:	83 ec 0c             	sub    $0xc,%esp
80104f8f:	53                   	push   %ebx
80104f90:	e8 db cd ff ff       	call   80101d70 <iunlockput>
    ilock(ip);
80104f95:	89 3c 24             	mov    %edi,(%esp)
80104f98:	e8 43 cb ff ff       	call   80101ae0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104f9d:	83 c4 10             	add    $0x10,%esp
80104fa0:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104fa5:	0f 85 95 00 00 00    	jne    80105040 <create+0x100>
80104fab:	66 83 7f 50 02       	cmpw   $0x2,0x50(%edi)
80104fb0:	0f 85 8a 00 00 00    	jne    80105040 <create+0x100>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104fb9:	89 f8                	mov    %edi,%eax
80104fbb:	5b                   	pop    %ebx
80104fbc:	5e                   	pop    %esi
80104fbd:	5f                   	pop    %edi
80104fbe:	5d                   	pop    %ebp
80104fbf:	c3                   	ret    
  if((ip = ialloc(dp->dev, type)) == 0)
80104fc0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104fc4:	83 ec 08             	sub    $0x8,%esp
80104fc7:	50                   	push   %eax
80104fc8:	ff 33                	pushl  (%ebx)
80104fca:	e8 a1 c9 ff ff       	call   80101970 <ialloc>
80104fcf:	83 c4 10             	add    $0x10,%esp
80104fd2:	85 c0                	test   %eax,%eax
80104fd4:	89 c7                	mov    %eax,%edi
80104fd6:	0f 84 e8 00 00 00    	je     801050c4 <create+0x184>
  ilock(ip);
80104fdc:	83 ec 0c             	sub    $0xc,%esp
80104fdf:	50                   	push   %eax
80104fe0:	e8 fb ca ff ff       	call   80101ae0 <ilock>
  ip->major = major;
80104fe5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104fe9:	66 89 47 52          	mov    %ax,0x52(%edi)
  ip->minor = minor;
80104fed:	0f b7 45 bc          	movzwl -0x44(%ebp),%eax
80104ff1:	66 89 47 54          	mov    %ax,0x54(%edi)
  ip->nlink = 1;
80104ff5:	b8 01 00 00 00       	mov    $0x1,%eax
80104ffa:	66 89 47 56          	mov    %ax,0x56(%edi)
  iupdate(ip);
80104ffe:	89 3c 24             	mov    %edi,(%esp)
80105001:	e8 2a ca ff ff       	call   80101a30 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105006:	83 c4 10             	add    $0x10,%esp
80105009:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
8010500e:	74 50                	je     80105060 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105010:	83 ec 04             	sub    $0x4,%esp
80105013:	ff 77 04             	pushl  0x4(%edi)
80105016:	56                   	push   %esi
80105017:	53                   	push   %ebx
80105018:	e8 63 d2 ff ff       	call   80102280 <dirlink>
8010501d:	83 c4 10             	add    $0x10,%esp
80105020:	85 c0                	test   %eax,%eax
80105022:	0f 88 8f 00 00 00    	js     801050b7 <create+0x177>
  iunlockput(dp);
80105028:	83 ec 0c             	sub    $0xc,%esp
8010502b:	53                   	push   %ebx
8010502c:	e8 3f cd ff ff       	call   80101d70 <iunlockput>
  return ip;
80105031:	83 c4 10             	add    $0x10,%esp
}
80105034:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105037:	89 f8                	mov    %edi,%eax
80105039:	5b                   	pop    %ebx
8010503a:	5e                   	pop    %esi
8010503b:	5f                   	pop    %edi
8010503c:	5d                   	pop    %ebp
8010503d:	c3                   	ret    
8010503e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105040:	83 ec 0c             	sub    $0xc,%esp
80105043:	57                   	push   %edi
    return 0;
80105044:	31 ff                	xor    %edi,%edi
    iunlockput(ip);
80105046:	e8 25 cd ff ff       	call   80101d70 <iunlockput>
    return 0;
8010504b:	83 c4 10             	add    $0x10,%esp
}
8010504e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105051:	89 f8                	mov    %edi,%eax
80105053:	5b                   	pop    %ebx
80105054:	5e                   	pop    %esi
80105055:	5f                   	pop    %edi
80105056:	5d                   	pop    %ebp
80105057:	c3                   	ret    
80105058:	90                   	nop
80105059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink++;  // for ".."
80105060:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80105065:	83 ec 0c             	sub    $0xc,%esp
80105068:	53                   	push   %ebx
80105069:	e8 c2 c9 ff ff       	call   80101a30 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010506e:	83 c4 0c             	add    $0xc,%esp
80105071:	ff 77 04             	pushl  0x4(%edi)
80105074:	68 cf 7b 10 80       	push   $0x80107bcf
80105079:	57                   	push   %edi
8010507a:	e8 01 d2 ff ff       	call   80102280 <dirlink>
8010507f:	83 c4 10             	add    $0x10,%esp
80105082:	85 c0                	test   %eax,%eax
80105084:	78 1c                	js     801050a2 <create+0x162>
80105086:	83 ec 04             	sub    $0x4,%esp
80105089:	ff 73 04             	pushl  0x4(%ebx)
8010508c:	68 ce 7b 10 80       	push   $0x80107bce
80105091:	57                   	push   %edi
80105092:	e8 e9 d1 ff ff       	call   80102280 <dirlink>
80105097:	83 c4 10             	add    $0x10,%esp
8010509a:	85 c0                	test   %eax,%eax
8010509c:	0f 89 6e ff ff ff    	jns    80105010 <create+0xd0>
      panic("create dots");
801050a2:	83 ec 0c             	sub    $0xc,%esp
801050a5:	68 e0 83 10 80       	push   $0x801083e0
801050aa:	e8 51 b6 ff ff       	call   80100700 <panic>
801050af:	90                   	nop
    return 0;
801050b0:	31 ff                	xor    %edi,%edi
801050b2:	e9 ff fe ff ff       	jmp    80104fb6 <create+0x76>
    panic("create: dirlink");
801050b7:	83 ec 0c             	sub    $0xc,%esp
801050ba:	68 de 7b 10 80       	push   $0x80107bde
801050bf:	e8 3c b6 ff ff       	call   80100700 <panic>
    panic("create: ialloc");
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	68 bf 7b 10 80       	push   $0x80107bbf
801050cc:	e8 2f b6 ff ff       	call   80100700 <panic>
801050d1:	eb 0d                	jmp    801050e0 <argfd.constprop.0>
801050d3:	90                   	nop
801050d4:	90                   	nop
801050d5:	90                   	nop
801050d6:	90                   	nop
801050d7:	90                   	nop
801050d8:	90                   	nop
801050d9:	90                   	nop
801050da:	90                   	nop
801050db:	90                   	nop
801050dc:	90                   	nop
801050dd:	90                   	nop
801050de:	90                   	nop
801050df:	90                   	nop

801050e0 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
801050e0:	55                   	push   %ebp
801050e1:	89 e5                	mov    %esp,%ebp
801050e3:	56                   	push   %esi
801050e4:	53                   	push   %ebx
801050e5:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
801050e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
801050ea:	89 d6                	mov    %edx,%esi
801050ec:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801050ef:	50                   	push   %eax
801050f0:	6a 00                	push   $0x0
801050f2:	e8 f9 fc ff ff       	call   80104df0 <argint>
801050f7:	83 c4 10             	add    $0x10,%esp
801050fa:	85 c0                	test   %eax,%eax
801050fc:	78 2a                	js     80105128 <argfd.constprop.0+0x48>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801050fe:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105102:	77 24                	ja     80105128 <argfd.constprop.0+0x48>
80105104:	e8 b7 eb ff ff       	call   80103cc0 <myproc>
80105109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010510c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80105110:	85 c0                	test   %eax,%eax
80105112:	74 14                	je     80105128 <argfd.constprop.0+0x48>
  if(pfd)
80105114:	85 db                	test   %ebx,%ebx
80105116:	74 02                	je     8010511a <argfd.constprop.0+0x3a>
    *pfd = fd;
80105118:	89 13                	mov    %edx,(%ebx)
    *pf = f;
8010511a:	89 06                	mov    %eax,(%esi)
  return 0;
8010511c:	31 c0                	xor    %eax,%eax
}
8010511e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105121:	5b                   	pop    %ebx
80105122:	5e                   	pop    %esi
80105123:	5d                   	pop    %ebp
80105124:	c3                   	ret    
80105125:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512d:	eb ef                	jmp    8010511e <argfd.constprop.0+0x3e>
8010512f:	90                   	nop

80105130 <sys_dup>:
{
80105130:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80105131:	31 c0                	xor    %eax,%eax
{
80105133:	89 e5                	mov    %esp,%ebp
80105135:	56                   	push   %esi
80105136:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80105137:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
8010513a:	83 ec 10             	sub    $0x10,%esp
  if(argfd(0, 0, &f) < 0)
8010513d:	e8 9e ff ff ff       	call   801050e0 <argfd.constprop.0>
80105142:	85 c0                	test   %eax,%eax
80105144:	78 42                	js     80105188 <sys_dup+0x58>
  if((fd=fdalloc(f)) < 0)
80105146:	8b 75 f4             	mov    -0xc(%ebp),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105149:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
8010514b:	e8 70 eb ff ff       	call   80103cc0 <myproc>
80105150:	eb 0e                	jmp    80105160 <sys_dup+0x30>
80105152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105158:	83 c3 01             	add    $0x1,%ebx
8010515b:	83 fb 10             	cmp    $0x10,%ebx
8010515e:	74 28                	je     80105188 <sys_dup+0x58>
    if(curproc->ofile[fd] == 0){
80105160:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105164:	85 d2                	test   %edx,%edx
80105166:	75 f0                	jne    80105158 <sys_dup+0x28>
      curproc->ofile[fd] = f;
80105168:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
8010516c:	83 ec 0c             	sub    $0xc,%esp
8010516f:	ff 75 f4             	pushl  -0xc(%ebp)
80105172:	e8 e9 bf ff ff       	call   80101160 <filedup>
  return fd;
80105177:	83 c4 10             	add    $0x10,%esp
}
8010517a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010517d:	89 d8                	mov    %ebx,%eax
8010517f:	5b                   	pop    %ebx
80105180:	5e                   	pop    %esi
80105181:	5d                   	pop    %ebp
80105182:	c3                   	ret    
80105183:	90                   	nop
80105184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105188:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
8010518b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105190:	89 d8                	mov    %ebx,%eax
80105192:	5b                   	pop    %ebx
80105193:	5e                   	pop    %esi
80105194:	5d                   	pop    %ebp
80105195:	c3                   	ret    
80105196:	8d 76 00             	lea    0x0(%esi),%esi
80105199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801051a0 <sys_read>:
{
801051a0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051a1:	31 c0                	xor    %eax,%eax
{
801051a3:	89 e5                	mov    %esp,%ebp
801051a5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801051a8:	8d 55 ec             	lea    -0x14(%ebp),%edx
801051ab:	e8 30 ff ff ff       	call   801050e0 <argfd.constprop.0>
801051b0:	85 c0                	test   %eax,%eax
801051b2:	78 4c                	js     80105200 <sys_read+0x60>
801051b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801051b7:	83 ec 08             	sub    $0x8,%esp
801051ba:	50                   	push   %eax
801051bb:	6a 02                	push   $0x2
801051bd:	e8 2e fc ff ff       	call   80104df0 <argint>
801051c2:	83 c4 10             	add    $0x10,%esp
801051c5:	85 c0                	test   %eax,%eax
801051c7:	78 37                	js     80105200 <sys_read+0x60>
801051c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801051cc:	83 ec 04             	sub    $0x4,%esp
801051cf:	ff 75 f0             	pushl  -0x10(%ebp)
801051d2:	50                   	push   %eax
801051d3:	6a 01                	push   $0x1
801051d5:	e8 66 fc ff ff       	call   80104e40 <argptr>
801051da:	83 c4 10             	add    $0x10,%esp
801051dd:	85 c0                	test   %eax,%eax
801051df:	78 1f                	js     80105200 <sys_read+0x60>
  return fileread(f, p, n);
801051e1:	83 ec 04             	sub    $0x4,%esp
801051e4:	ff 75 f0             	pushl  -0x10(%ebp)
801051e7:	ff 75 f4             	pushl  -0xc(%ebp)
801051ea:	ff 75 ec             	pushl  -0x14(%ebp)
801051ed:	e8 de c0 ff ff       	call   801012d0 <fileread>
801051f2:	83 c4 10             	add    $0x10,%esp
}
801051f5:	c9                   	leave  
801051f6:	c3                   	ret    
801051f7:	89 f6                	mov    %esi,%esi
801051f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105200:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105205:	c9                   	leave  
80105206:	c3                   	ret    
80105207:	89 f6                	mov    %esi,%esi
80105209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105210 <sys_write>:
{
80105210:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105211:	31 c0                	xor    %eax,%eax
{
80105213:	89 e5                	mov    %esp,%ebp
80105215:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105218:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010521b:	e8 c0 fe ff ff       	call   801050e0 <argfd.constprop.0>
80105220:	85 c0                	test   %eax,%eax
80105222:	78 4c                	js     80105270 <sys_write+0x60>
80105224:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105227:	83 ec 08             	sub    $0x8,%esp
8010522a:	50                   	push   %eax
8010522b:	6a 02                	push   $0x2
8010522d:	e8 be fb ff ff       	call   80104df0 <argint>
80105232:	83 c4 10             	add    $0x10,%esp
80105235:	85 c0                	test   %eax,%eax
80105237:	78 37                	js     80105270 <sys_write+0x60>
80105239:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010523c:	83 ec 04             	sub    $0x4,%esp
8010523f:	ff 75 f0             	pushl  -0x10(%ebp)
80105242:	50                   	push   %eax
80105243:	6a 01                	push   $0x1
80105245:	e8 f6 fb ff ff       	call   80104e40 <argptr>
8010524a:	83 c4 10             	add    $0x10,%esp
8010524d:	85 c0                	test   %eax,%eax
8010524f:	78 1f                	js     80105270 <sys_write+0x60>
  return filewrite(f, p, n);
80105251:	83 ec 04             	sub    $0x4,%esp
80105254:	ff 75 f0             	pushl  -0x10(%ebp)
80105257:	ff 75 f4             	pushl  -0xc(%ebp)
8010525a:	ff 75 ec             	pushl  -0x14(%ebp)
8010525d:	e8 fe c0 ff ff       	call   80101360 <filewrite>
80105262:	83 c4 10             	add    $0x10,%esp
}
80105265:	c9                   	leave  
80105266:	c3                   	ret    
80105267:	89 f6                	mov    %esi,%esi
80105269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
80105270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105275:	c9                   	leave  
80105276:	c3                   	ret    
80105277:	89 f6                	mov    %esi,%esi
80105279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105280 <sys_close>:
{
80105280:	55                   	push   %ebp
80105281:	89 e5                	mov    %esp,%ebp
80105283:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80105286:	8d 55 f4             	lea    -0xc(%ebp),%edx
80105289:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010528c:	e8 4f fe ff ff       	call   801050e0 <argfd.constprop.0>
80105291:	85 c0                	test   %eax,%eax
80105293:	78 2b                	js     801052c0 <sys_close+0x40>
  myproc()->ofile[fd] = 0;
80105295:	e8 26 ea ff ff       	call   80103cc0 <myproc>
8010529a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
8010529d:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801052a0:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801052a7:	00 
  fileclose(f);
801052a8:	ff 75 f4             	pushl  -0xc(%ebp)
801052ab:	e8 00 bf ff ff       	call   801011b0 <fileclose>
  return 0;
801052b0:	83 c4 10             	add    $0x10,%esp
801052b3:	31 c0                	xor    %eax,%eax
}
801052b5:	c9                   	leave  
801052b6:	c3                   	ret    
801052b7:	89 f6                	mov    %esi,%esi
801052b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    return -1;
801052c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052c5:	c9                   	leave  
801052c6:	c3                   	ret    
801052c7:	89 f6                	mov    %esi,%esi
801052c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801052d0 <sys_fstat>:
{
801052d0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801052d1:	31 c0                	xor    %eax,%eax
{
801052d3:	89 e5                	mov    %esp,%ebp
801052d5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801052d8:	8d 55 f0             	lea    -0x10(%ebp),%edx
801052db:	e8 00 fe ff ff       	call   801050e0 <argfd.constprop.0>
801052e0:	85 c0                	test   %eax,%eax
801052e2:	78 2c                	js     80105310 <sys_fstat+0x40>
801052e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052e7:	83 ec 04             	sub    $0x4,%esp
801052ea:	6a 14                	push   $0x14
801052ec:	50                   	push   %eax
801052ed:	6a 01                	push   $0x1
801052ef:	e8 4c fb ff ff       	call   80104e40 <argptr>
801052f4:	83 c4 10             	add    $0x10,%esp
801052f7:	85 c0                	test   %eax,%eax
801052f9:	78 15                	js     80105310 <sys_fstat+0x40>
  return filestat(f, st);
801052fb:	83 ec 08             	sub    $0x8,%esp
801052fe:	ff 75 f4             	pushl  -0xc(%ebp)
80105301:	ff 75 f0             	pushl  -0x10(%ebp)
80105304:	e8 77 bf ff ff       	call   80101280 <filestat>
80105309:	83 c4 10             	add    $0x10,%esp
}
8010530c:	c9                   	leave  
8010530d:	c3                   	ret    
8010530e:	66 90                	xchg   %ax,%ax
    return -1;
80105310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105315:	c9                   	leave  
80105316:	c3                   	ret    
80105317:	89 f6                	mov    %esi,%esi
80105319:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105320 <sys_link>:
{
80105320:	55                   	push   %ebp
80105321:	89 e5                	mov    %esp,%ebp
80105323:	57                   	push   %edi
80105324:	56                   	push   %esi
80105325:	53                   	push   %ebx
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105326:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105329:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010532c:	50                   	push   %eax
8010532d:	6a 00                	push   $0x0
8010532f:	e8 6c fb ff ff       	call   80104ea0 <argstr>
80105334:	83 c4 10             	add    $0x10,%esp
80105337:	85 c0                	test   %eax,%eax
80105339:	0f 88 fb 00 00 00    	js     8010543a <sys_link+0x11a>
8010533f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80105342:	83 ec 08             	sub    $0x8,%esp
80105345:	50                   	push   %eax
80105346:	6a 01                	push   $0x1
80105348:	e8 53 fb ff ff       	call   80104ea0 <argstr>
8010534d:	83 c4 10             	add    $0x10,%esp
80105350:	85 c0                	test   %eax,%eax
80105352:	0f 88 e2 00 00 00    	js     8010543a <sys_link+0x11a>
  begin_op();
80105358:	e8 23 dd ff ff       	call   80103080 <begin_op>
  if((ip = namei(old)) == 0){
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	ff 75 d4             	pushl  -0x2c(%ebp)
80105363:	e8 d8 cf ff ff       	call   80102340 <namei>
80105368:	83 c4 10             	add    $0x10,%esp
8010536b:	85 c0                	test   %eax,%eax
8010536d:	89 c3                	mov    %eax,%ebx
8010536f:	0f 84 ea 00 00 00    	je     8010545f <sys_link+0x13f>
  ilock(ip);
80105375:	83 ec 0c             	sub    $0xc,%esp
80105378:	50                   	push   %eax
80105379:	e8 62 c7 ff ff       	call   80101ae0 <ilock>
  if(ip->type == T_DIR){
8010537e:	83 c4 10             	add    $0x10,%esp
80105381:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105386:	0f 84 bb 00 00 00    	je     80105447 <sys_link+0x127>
  ip->nlink++;
8010538c:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  iupdate(ip);
80105391:	83 ec 0c             	sub    $0xc,%esp
  if((dp = nameiparent(new, name)) == 0)
80105394:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105397:	53                   	push   %ebx
80105398:	e8 93 c6 ff ff       	call   80101a30 <iupdate>
  iunlock(ip);
8010539d:	89 1c 24             	mov    %ebx,(%esp)
801053a0:	e8 1b c8 ff ff       	call   80101bc0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801053a5:	58                   	pop    %eax
801053a6:	5a                   	pop    %edx
801053a7:	57                   	push   %edi
801053a8:	ff 75 d0             	pushl  -0x30(%ebp)
801053ab:	e8 b0 cf ff ff       	call   80102360 <nameiparent>
801053b0:	83 c4 10             	add    $0x10,%esp
801053b3:	85 c0                	test   %eax,%eax
801053b5:	89 c6                	mov    %eax,%esi
801053b7:	74 5b                	je     80105414 <sys_link+0xf4>
  ilock(dp);
801053b9:	83 ec 0c             	sub    $0xc,%esp
801053bc:	50                   	push   %eax
801053bd:	e8 1e c7 ff ff       	call   80101ae0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801053c2:	83 c4 10             	add    $0x10,%esp
801053c5:	8b 03                	mov    (%ebx),%eax
801053c7:	39 06                	cmp    %eax,(%esi)
801053c9:	75 3d                	jne    80105408 <sys_link+0xe8>
801053cb:	83 ec 04             	sub    $0x4,%esp
801053ce:	ff 73 04             	pushl  0x4(%ebx)
801053d1:	57                   	push   %edi
801053d2:	56                   	push   %esi
801053d3:	e8 a8 ce ff ff       	call   80102280 <dirlink>
801053d8:	83 c4 10             	add    $0x10,%esp
801053db:	85 c0                	test   %eax,%eax
801053dd:	78 29                	js     80105408 <sys_link+0xe8>
  iunlockput(dp);
801053df:	83 ec 0c             	sub    $0xc,%esp
801053e2:	56                   	push   %esi
801053e3:	e8 88 c9 ff ff       	call   80101d70 <iunlockput>
  iput(ip);
801053e8:	89 1c 24             	mov    %ebx,(%esp)
801053eb:	e8 20 c8 ff ff       	call   80101c10 <iput>
  end_op();
801053f0:	e8 fb dc ff ff       	call   801030f0 <end_op>
  return 0;
801053f5:	83 c4 10             	add    $0x10,%esp
801053f8:	31 c0                	xor    %eax,%eax
}
801053fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801053fd:	5b                   	pop    %ebx
801053fe:	5e                   	pop    %esi
801053ff:	5f                   	pop    %edi
80105400:	5d                   	pop    %ebp
80105401:	c3                   	ret    
80105402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105408:	83 ec 0c             	sub    $0xc,%esp
8010540b:	56                   	push   %esi
8010540c:	e8 5f c9 ff ff       	call   80101d70 <iunlockput>
    goto bad;
80105411:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105414:	83 ec 0c             	sub    $0xc,%esp
80105417:	53                   	push   %ebx
80105418:	e8 c3 c6 ff ff       	call   80101ae0 <ilock>
  ip->nlink--;
8010541d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105422:	89 1c 24             	mov    %ebx,(%esp)
80105425:	e8 06 c6 ff ff       	call   80101a30 <iupdate>
  iunlockput(ip);
8010542a:	89 1c 24             	mov    %ebx,(%esp)
8010542d:	e8 3e c9 ff ff       	call   80101d70 <iunlockput>
  end_op();
80105432:	e8 b9 dc ff ff       	call   801030f0 <end_op>
  return -1;
80105437:	83 c4 10             	add    $0x10,%esp
}
8010543a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
8010543d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105442:	5b                   	pop    %ebx
80105443:	5e                   	pop    %esi
80105444:	5f                   	pop    %edi
80105445:	5d                   	pop    %ebp
80105446:	c3                   	ret    
    iunlockput(ip);
80105447:	83 ec 0c             	sub    $0xc,%esp
8010544a:	53                   	push   %ebx
8010544b:	e8 20 c9 ff ff       	call   80101d70 <iunlockput>
    end_op();
80105450:	e8 9b dc ff ff       	call   801030f0 <end_op>
    return -1;
80105455:	83 c4 10             	add    $0x10,%esp
80105458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545d:	eb 9b                	jmp    801053fa <sys_link+0xda>
    end_op();
8010545f:	e8 8c dc ff ff       	call   801030f0 <end_op>
    return -1;
80105464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105469:	eb 8f                	jmp    801053fa <sys_link+0xda>
8010546b:	90                   	nop
8010546c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105470 <sys_unlink>:
{
80105470:	55                   	push   %ebp
80105471:	89 e5                	mov    %esp,%ebp
80105473:	57                   	push   %edi
80105474:	56                   	push   %esi
80105475:	53                   	push   %ebx
  if(argstr(0, &path) < 0)
80105476:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80105479:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010547c:	50                   	push   %eax
8010547d:	6a 00                	push   $0x0
8010547f:	e8 1c fa ff ff       	call   80104ea0 <argstr>
80105484:	83 c4 10             	add    $0x10,%esp
80105487:	85 c0                	test   %eax,%eax
80105489:	0f 88 77 01 00 00    	js     80105606 <sys_unlink+0x196>
  if((dp = nameiparent(path, name)) == 0){
8010548f:	8d 5d ca             	lea    -0x36(%ebp),%ebx
  begin_op();
80105492:	e8 e9 db ff ff       	call   80103080 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105497:	83 ec 08             	sub    $0x8,%esp
8010549a:	53                   	push   %ebx
8010549b:	ff 75 c0             	pushl  -0x40(%ebp)
8010549e:	e8 bd ce ff ff       	call   80102360 <nameiparent>
801054a3:	83 c4 10             	add    $0x10,%esp
801054a6:	85 c0                	test   %eax,%eax
801054a8:	89 c6                	mov    %eax,%esi
801054aa:	0f 84 60 01 00 00    	je     80105610 <sys_unlink+0x1a0>
  ilock(dp);
801054b0:	83 ec 0c             	sub    $0xc,%esp
801054b3:	50                   	push   %eax
801054b4:	e8 27 c6 ff ff       	call   80101ae0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801054b9:	58                   	pop    %eax
801054ba:	5a                   	pop    %edx
801054bb:	68 cf 7b 10 80       	push   $0x80107bcf
801054c0:	53                   	push   %ebx
801054c1:	e8 2a cb ff ff       	call   80101ff0 <namecmp>
801054c6:	83 c4 10             	add    $0x10,%esp
801054c9:	85 c0                	test   %eax,%eax
801054cb:	0f 84 03 01 00 00    	je     801055d4 <sys_unlink+0x164>
801054d1:	83 ec 08             	sub    $0x8,%esp
801054d4:	68 ce 7b 10 80       	push   $0x80107bce
801054d9:	53                   	push   %ebx
801054da:	e8 11 cb ff ff       	call   80101ff0 <namecmp>
801054df:	83 c4 10             	add    $0x10,%esp
801054e2:	85 c0                	test   %eax,%eax
801054e4:	0f 84 ea 00 00 00    	je     801055d4 <sys_unlink+0x164>
  if((ip = dirlookup(dp, name, &off)) == 0)
801054ea:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801054ed:	83 ec 04             	sub    $0x4,%esp
801054f0:	50                   	push   %eax
801054f1:	53                   	push   %ebx
801054f2:	56                   	push   %esi
801054f3:	e8 18 cb ff ff       	call   80102010 <dirlookup>
801054f8:	83 c4 10             	add    $0x10,%esp
801054fb:	85 c0                	test   %eax,%eax
801054fd:	89 c3                	mov    %eax,%ebx
801054ff:	0f 84 cf 00 00 00    	je     801055d4 <sys_unlink+0x164>
  ilock(ip);
80105505:	83 ec 0c             	sub    $0xc,%esp
80105508:	50                   	push   %eax
80105509:	e8 d2 c5 ff ff       	call   80101ae0 <ilock>
  if(ip->nlink < 1)
8010550e:	83 c4 10             	add    $0x10,%esp
80105511:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80105516:	0f 8e 10 01 00 00    	jle    8010562c <sys_unlink+0x1bc>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010551c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105521:	74 6d                	je     80105590 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80105523:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105526:	83 ec 04             	sub    $0x4,%esp
80105529:	6a 10                	push   $0x10
8010552b:	6a 00                	push   $0x0
8010552d:	50                   	push   %eax
8010552e:	e8 bd f5 ff ff       	call   80104af0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105533:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105536:	6a 10                	push   $0x10
80105538:	ff 75 c4             	pushl  -0x3c(%ebp)
8010553b:	50                   	push   %eax
8010553c:	56                   	push   %esi
8010553d:	e8 7e c9 ff ff       	call   80101ec0 <writei>
80105542:	83 c4 20             	add    $0x20,%esp
80105545:	83 f8 10             	cmp    $0x10,%eax
80105548:	0f 85 eb 00 00 00    	jne    80105639 <sys_unlink+0x1c9>
  if(ip->type == T_DIR){
8010554e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105553:	0f 84 97 00 00 00    	je     801055f0 <sys_unlink+0x180>
  iunlockput(dp);
80105559:	83 ec 0c             	sub    $0xc,%esp
8010555c:	56                   	push   %esi
8010555d:	e8 0e c8 ff ff       	call   80101d70 <iunlockput>
  ip->nlink--;
80105562:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105567:	89 1c 24             	mov    %ebx,(%esp)
8010556a:	e8 c1 c4 ff ff       	call   80101a30 <iupdate>
  iunlockput(ip);
8010556f:	89 1c 24             	mov    %ebx,(%esp)
80105572:	e8 f9 c7 ff ff       	call   80101d70 <iunlockput>
  end_op();
80105577:	e8 74 db ff ff       	call   801030f0 <end_op>
  return 0;
8010557c:	83 c4 10             	add    $0x10,%esp
8010557f:	31 c0                	xor    %eax,%eax
}
80105581:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105584:	5b                   	pop    %ebx
80105585:	5e                   	pop    %esi
80105586:	5f                   	pop    %edi
80105587:	5d                   	pop    %ebp
80105588:	c3                   	ret    
80105589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105590:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105594:	76 8d                	jbe    80105523 <sys_unlink+0xb3>
80105596:	bf 20 00 00 00       	mov    $0x20,%edi
8010559b:	eb 0f                	jmp    801055ac <sys_unlink+0x13c>
8010559d:	8d 76 00             	lea    0x0(%esi),%esi
801055a0:	83 c7 10             	add    $0x10,%edi
801055a3:	3b 7b 58             	cmp    0x58(%ebx),%edi
801055a6:	0f 83 77 ff ff ff    	jae    80105523 <sys_unlink+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801055ac:	8d 45 d8             	lea    -0x28(%ebp),%eax
801055af:	6a 10                	push   $0x10
801055b1:	57                   	push   %edi
801055b2:	50                   	push   %eax
801055b3:	53                   	push   %ebx
801055b4:	e8 07 c8 ff ff       	call   80101dc0 <readi>
801055b9:	83 c4 10             	add    $0x10,%esp
801055bc:	83 f8 10             	cmp    $0x10,%eax
801055bf:	75 5e                	jne    8010561f <sys_unlink+0x1af>
    if(de.inum != 0)
801055c1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801055c6:	74 d8                	je     801055a0 <sys_unlink+0x130>
    iunlockput(ip);
801055c8:	83 ec 0c             	sub    $0xc,%esp
801055cb:	53                   	push   %ebx
801055cc:	e8 9f c7 ff ff       	call   80101d70 <iunlockput>
    goto bad;
801055d1:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801055d4:	83 ec 0c             	sub    $0xc,%esp
801055d7:	56                   	push   %esi
801055d8:	e8 93 c7 ff ff       	call   80101d70 <iunlockput>
  end_op();
801055dd:	e8 0e db ff ff       	call   801030f0 <end_op>
  return -1;
801055e2:	83 c4 10             	add    $0x10,%esp
801055e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055ea:	eb 95                	jmp    80105581 <sys_unlink+0x111>
801055ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    dp->nlink--;
801055f0:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
801055f5:	83 ec 0c             	sub    $0xc,%esp
801055f8:	56                   	push   %esi
801055f9:	e8 32 c4 ff ff       	call   80101a30 <iupdate>
801055fe:	83 c4 10             	add    $0x10,%esp
80105601:	e9 53 ff ff ff       	jmp    80105559 <sys_unlink+0xe9>
    return -1;
80105606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010560b:	e9 71 ff ff ff       	jmp    80105581 <sys_unlink+0x111>
    end_op();
80105610:	e8 db da ff ff       	call   801030f0 <end_op>
    return -1;
80105615:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010561a:	e9 62 ff ff ff       	jmp    80105581 <sys_unlink+0x111>
      panic("isdirempty: readi");
8010561f:	83 ec 0c             	sub    $0xc,%esp
80105622:	68 fe 83 10 80       	push   $0x801083fe
80105627:	e8 d4 b0 ff ff       	call   80100700 <panic>
    panic("unlink: nlink < 1");
8010562c:	83 ec 0c             	sub    $0xc,%esp
8010562f:	68 ec 83 10 80       	push   $0x801083ec
80105634:	e8 c7 b0 ff ff       	call   80100700 <panic>
    panic("unlink: writei");
80105639:	83 ec 0c             	sub    $0xc,%esp
8010563c:	68 10 84 10 80       	push   $0x80108410
80105641:	e8 ba b0 ff ff       	call   80100700 <panic>
80105646:	8d 76 00             	lea    0x0(%esi),%esi
80105649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105650 <sys_open>:

int
sys_open(void)
{
80105650:	55                   	push   %ebp
80105651:	89 e5                	mov    %esp,%ebp
80105653:	57                   	push   %edi
80105654:	56                   	push   %esi
80105655:	53                   	push   %ebx
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105656:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
80105659:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010565c:	50                   	push   %eax
8010565d:	6a 00                	push   $0x0
8010565f:	e8 3c f8 ff ff       	call   80104ea0 <argstr>
80105664:	83 c4 10             	add    $0x10,%esp
80105667:	85 c0                	test   %eax,%eax
80105669:	0f 88 1d 01 00 00    	js     8010578c <sys_open+0x13c>
8010566f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105672:	83 ec 08             	sub    $0x8,%esp
80105675:	50                   	push   %eax
80105676:	6a 01                	push   $0x1
80105678:	e8 73 f7 ff ff       	call   80104df0 <argint>
8010567d:	83 c4 10             	add    $0x10,%esp
80105680:	85 c0                	test   %eax,%eax
80105682:	0f 88 04 01 00 00    	js     8010578c <sys_open+0x13c>
    return -1;

  begin_op();
80105688:	e8 f3 d9 ff ff       	call   80103080 <begin_op>

  if(omode & O_CREATE){
8010568d:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
80105691:	0f 85 a9 00 00 00    	jne    80105740 <sys_open+0xf0>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80105697:	83 ec 0c             	sub    $0xc,%esp
8010569a:	ff 75 e0             	pushl  -0x20(%ebp)
8010569d:	e8 9e cc ff ff       	call   80102340 <namei>
801056a2:	83 c4 10             	add    $0x10,%esp
801056a5:	85 c0                	test   %eax,%eax
801056a7:	89 c6                	mov    %eax,%esi
801056a9:	0f 84 b2 00 00 00    	je     80105761 <sys_open+0x111>
      end_op();
      return -1;
    }
    ilock(ip);
801056af:	83 ec 0c             	sub    $0xc,%esp
801056b2:	50                   	push   %eax
801056b3:	e8 28 c4 ff ff       	call   80101ae0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801056b8:	83 c4 10             	add    $0x10,%esp
801056bb:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801056c0:	0f 84 aa 00 00 00    	je     80105770 <sys_open+0x120>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801056c6:	e8 25 ba ff ff       	call   801010f0 <filealloc>
801056cb:	85 c0                	test   %eax,%eax
801056cd:	89 c7                	mov    %eax,%edi
801056cf:	0f 84 a6 00 00 00    	je     8010577b <sys_open+0x12b>
  struct proc *curproc = myproc();
801056d5:	e8 e6 e5 ff ff       	call   80103cc0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801056da:	31 db                	xor    %ebx,%ebx
801056dc:	eb 0e                	jmp    801056ec <sys_open+0x9c>
801056de:	66 90                	xchg   %ax,%ax
801056e0:	83 c3 01             	add    $0x1,%ebx
801056e3:	83 fb 10             	cmp    $0x10,%ebx
801056e6:	0f 84 ac 00 00 00    	je     80105798 <sys_open+0x148>
    if(curproc->ofile[fd] == 0){
801056ec:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
801056f0:	85 d2                	test   %edx,%edx
801056f2:	75 ec                	jne    801056e0 <sys_open+0x90>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801056f4:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801056f7:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
801056fb:	56                   	push   %esi
801056fc:	e8 bf c4 ff ff       	call   80101bc0 <iunlock>
  end_op();
80105701:	e8 ea d9 ff ff       	call   801030f0 <end_op>

  f->type = FD_INODE;
80105706:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
8010570c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010570f:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
80105712:	89 77 10             	mov    %esi,0x10(%edi)
  f->off = 0;
80105715:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
8010571c:	89 d0                	mov    %edx,%eax
8010571e:	f7 d0                	not    %eax
80105720:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105723:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
80105726:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105729:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
8010572d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105730:	89 d8                	mov    %ebx,%eax
80105732:	5b                   	pop    %ebx
80105733:	5e                   	pop    %esi
80105734:	5f                   	pop    %edi
80105735:	5d                   	pop    %ebp
80105736:	c3                   	ret    
80105737:	89 f6                	mov    %esi,%esi
80105739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ip = create(path, T_FILE, 0, 0);
80105740:	83 ec 0c             	sub    $0xc,%esp
80105743:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105746:	31 c9                	xor    %ecx,%ecx
80105748:	6a 00                	push   $0x0
8010574a:	ba 02 00 00 00       	mov    $0x2,%edx
8010574f:	e8 ec f7 ff ff       	call   80104f40 <create>
    if(ip == 0){
80105754:	83 c4 10             	add    $0x10,%esp
80105757:	85 c0                	test   %eax,%eax
    ip = create(path, T_FILE, 0, 0);
80105759:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010575b:	0f 85 65 ff ff ff    	jne    801056c6 <sys_open+0x76>
      end_op();
80105761:	e8 8a d9 ff ff       	call   801030f0 <end_op>
      return -1;
80105766:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010576b:	eb c0                	jmp    8010572d <sys_open+0xdd>
8010576d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
80105770:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105773:	85 c9                	test   %ecx,%ecx
80105775:	0f 84 4b ff ff ff    	je     801056c6 <sys_open+0x76>
    iunlockput(ip);
8010577b:	83 ec 0c             	sub    $0xc,%esp
8010577e:	56                   	push   %esi
8010577f:	e8 ec c5 ff ff       	call   80101d70 <iunlockput>
    end_op();
80105784:	e8 67 d9 ff ff       	call   801030f0 <end_op>
    return -1;
80105789:	83 c4 10             	add    $0x10,%esp
8010578c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105791:	eb 9a                	jmp    8010572d <sys_open+0xdd>
80105793:	90                   	nop
80105794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      fileclose(f);
80105798:	83 ec 0c             	sub    $0xc,%esp
8010579b:	57                   	push   %edi
8010579c:	e8 0f ba ff ff       	call   801011b0 <fileclose>
801057a1:	83 c4 10             	add    $0x10,%esp
801057a4:	eb d5                	jmp    8010577b <sys_open+0x12b>
801057a6:	8d 76 00             	lea    0x0(%esi),%esi
801057a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801057b0 <sys_mkdir>:

int
sys_mkdir(void)
{
801057b0:	55                   	push   %ebp
801057b1:	89 e5                	mov    %esp,%ebp
801057b3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057b6:	e8 c5 d8 ff ff       	call   80103080 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057be:	83 ec 08             	sub    $0x8,%esp
801057c1:	50                   	push   %eax
801057c2:	6a 00                	push   $0x0
801057c4:	e8 d7 f6 ff ff       	call   80104ea0 <argstr>
801057c9:	83 c4 10             	add    $0x10,%esp
801057cc:	85 c0                	test   %eax,%eax
801057ce:	78 30                	js     80105800 <sys_mkdir+0x50>
801057d0:	83 ec 0c             	sub    $0xc,%esp
801057d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057d6:	31 c9                	xor    %ecx,%ecx
801057d8:	6a 00                	push   $0x0
801057da:	ba 01 00 00 00       	mov    $0x1,%edx
801057df:	e8 5c f7 ff ff       	call   80104f40 <create>
801057e4:	83 c4 10             	add    $0x10,%esp
801057e7:	85 c0                	test   %eax,%eax
801057e9:	74 15                	je     80105800 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
801057eb:	83 ec 0c             	sub    $0xc,%esp
801057ee:	50                   	push   %eax
801057ef:	e8 7c c5 ff ff       	call   80101d70 <iunlockput>
  end_op();
801057f4:	e8 f7 d8 ff ff       	call   801030f0 <end_op>
  return 0;
801057f9:	83 c4 10             	add    $0x10,%esp
801057fc:	31 c0                	xor    %eax,%eax
}
801057fe:	c9                   	leave  
801057ff:	c3                   	ret    
    end_op();
80105800:	e8 eb d8 ff ff       	call   801030f0 <end_op>
    return -1;
80105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    
8010580c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105810 <sys_mknod>:

int
sys_mknod(void)
{
80105810:	55                   	push   %ebp
80105811:	89 e5                	mov    %esp,%ebp
80105813:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105816:	e8 65 d8 ff ff       	call   80103080 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010581b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010581e:	83 ec 08             	sub    $0x8,%esp
80105821:	50                   	push   %eax
80105822:	6a 00                	push   $0x0
80105824:	e8 77 f6 ff ff       	call   80104ea0 <argstr>
80105829:	83 c4 10             	add    $0x10,%esp
8010582c:	85 c0                	test   %eax,%eax
8010582e:	78 60                	js     80105890 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105830:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105833:	83 ec 08             	sub    $0x8,%esp
80105836:	50                   	push   %eax
80105837:	6a 01                	push   $0x1
80105839:	e8 b2 f5 ff ff       	call   80104df0 <argint>
  if((argstr(0, &path)) < 0 ||
8010583e:	83 c4 10             	add    $0x10,%esp
80105841:	85 c0                	test   %eax,%eax
80105843:	78 4b                	js     80105890 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105845:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105848:	83 ec 08             	sub    $0x8,%esp
8010584b:	50                   	push   %eax
8010584c:	6a 02                	push   $0x2
8010584e:	e8 9d f5 ff ff       	call   80104df0 <argint>
     argint(1, &major) < 0 ||
80105853:	83 c4 10             	add    $0x10,%esp
80105856:	85 c0                	test   %eax,%eax
80105858:	78 36                	js     80105890 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010585a:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
     argint(2, &minor) < 0 ||
8010585e:	83 ec 0c             	sub    $0xc,%esp
     (ip = create(path, T_DEV, major, minor)) == 0){
80105861:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80105865:	ba 03 00 00 00       	mov    $0x3,%edx
8010586a:	50                   	push   %eax
8010586b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010586e:	e8 cd f6 ff ff       	call   80104f40 <create>
80105873:	83 c4 10             	add    $0x10,%esp
80105876:	85 c0                	test   %eax,%eax
80105878:	74 16                	je     80105890 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010587a:	83 ec 0c             	sub    $0xc,%esp
8010587d:	50                   	push   %eax
8010587e:	e8 ed c4 ff ff       	call   80101d70 <iunlockput>
  end_op();
80105883:	e8 68 d8 ff ff       	call   801030f0 <end_op>
  return 0;
80105888:	83 c4 10             	add    $0x10,%esp
8010588b:	31 c0                	xor    %eax,%eax
}
8010588d:	c9                   	leave  
8010588e:	c3                   	ret    
8010588f:	90                   	nop
    end_op();
80105890:	e8 5b d8 ff ff       	call   801030f0 <end_op>
    return -1;
80105895:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010589a:	c9                   	leave  
8010589b:	c3                   	ret    
8010589c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801058a0 <sys_chdir>:

int
sys_chdir(void)
{
801058a0:	55                   	push   %ebp
801058a1:	89 e5                	mov    %esp,%ebp
801058a3:	56                   	push   %esi
801058a4:	53                   	push   %ebx
801058a5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058a8:	e8 13 e4 ff ff       	call   80103cc0 <myproc>
801058ad:	89 c6                	mov    %eax,%esi

  begin_op();
801058af:	e8 cc d7 ff ff       	call   80103080 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b7:	83 ec 08             	sub    $0x8,%esp
801058ba:	50                   	push   %eax
801058bb:	6a 00                	push   $0x0
801058bd:	e8 de f5 ff ff       	call   80104ea0 <argstr>
801058c2:	83 c4 10             	add    $0x10,%esp
801058c5:	85 c0                	test   %eax,%eax
801058c7:	78 77                	js     80105940 <sys_chdir+0xa0>
801058c9:	83 ec 0c             	sub    $0xc,%esp
801058cc:	ff 75 f4             	pushl  -0xc(%ebp)
801058cf:	e8 6c ca ff ff       	call   80102340 <namei>
801058d4:	83 c4 10             	add    $0x10,%esp
801058d7:	85 c0                	test   %eax,%eax
801058d9:	89 c3                	mov    %eax,%ebx
801058db:	74 63                	je     80105940 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
801058dd:	83 ec 0c             	sub    $0xc,%esp
801058e0:	50                   	push   %eax
801058e1:	e8 fa c1 ff ff       	call   80101ae0 <ilock>
  if(ip->type != T_DIR){
801058e6:	83 c4 10             	add    $0x10,%esp
801058e9:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801058ee:	75 30                	jne    80105920 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801058f0:	83 ec 0c             	sub    $0xc,%esp
801058f3:	53                   	push   %ebx
801058f4:	e8 c7 c2 ff ff       	call   80101bc0 <iunlock>
  iput(curproc->cwd);
801058f9:	58                   	pop    %eax
801058fa:	ff 76 68             	pushl  0x68(%esi)
801058fd:	e8 0e c3 ff ff       	call   80101c10 <iput>
  end_op();
80105902:	e8 e9 d7 ff ff       	call   801030f0 <end_op>
  curproc->cwd = ip;
80105907:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010590a:	83 c4 10             	add    $0x10,%esp
8010590d:	31 c0                	xor    %eax,%eax
}
8010590f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105912:	5b                   	pop    %ebx
80105913:	5e                   	pop    %esi
80105914:	5d                   	pop    %ebp
80105915:	c3                   	ret    
80105916:	8d 76 00             	lea    0x0(%esi),%esi
80105919:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    iunlockput(ip);
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	53                   	push   %ebx
80105924:	e8 47 c4 ff ff       	call   80101d70 <iunlockput>
    end_op();
80105929:	e8 c2 d7 ff ff       	call   801030f0 <end_op>
    return -1;
8010592e:	83 c4 10             	add    $0x10,%esp
80105931:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105936:	eb d7                	jmp    8010590f <sys_chdir+0x6f>
80105938:	90                   	nop
80105939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105940:	e8 ab d7 ff ff       	call   801030f0 <end_op>
    return -1;
80105945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594a:	eb c3                	jmp    8010590f <sys_chdir+0x6f>
8010594c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105950 <sys_exec>:

int
sys_exec(void)
{
80105950:	55                   	push   %ebp
80105951:	89 e5                	mov    %esp,%ebp
80105953:	57                   	push   %edi
80105954:	56                   	push   %esi
80105955:	53                   	push   %ebx
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105956:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
8010595c:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105962:	50                   	push   %eax
80105963:	6a 00                	push   $0x0
80105965:	e8 36 f5 ff ff       	call   80104ea0 <argstr>
8010596a:	83 c4 10             	add    $0x10,%esp
8010596d:	85 c0                	test   %eax,%eax
8010596f:	0f 88 87 00 00 00    	js     801059fc <sys_exec+0xac>
80105975:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010597b:	83 ec 08             	sub    $0x8,%esp
8010597e:	50                   	push   %eax
8010597f:	6a 01                	push   $0x1
80105981:	e8 6a f4 ff ff       	call   80104df0 <argint>
80105986:	83 c4 10             	add    $0x10,%esp
80105989:	85 c0                	test   %eax,%eax
8010598b:	78 6f                	js     801059fc <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010598d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105993:	83 ec 04             	sub    $0x4,%esp
  for(i=0;; i++){
80105996:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105998:	68 80 00 00 00       	push   $0x80
8010599d:	6a 00                	push   $0x0
8010599f:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
801059a5:	50                   	push   %eax
801059a6:	e8 45 f1 ff ff       	call   80104af0 <memset>
801059ab:	83 c4 10             	add    $0x10,%esp
801059ae:	eb 2c                	jmp    801059dc <sys_exec+0x8c>
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
801059b0:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801059b6:	85 c0                	test   %eax,%eax
801059b8:	74 56                	je     80105a10 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801059ba:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
801059c0:	83 ec 08             	sub    $0x8,%esp
801059c3:	8d 14 31             	lea    (%ecx,%esi,1),%edx
801059c6:	52                   	push   %edx
801059c7:	50                   	push   %eax
801059c8:	e8 b3 f3 ff ff       	call   80104d80 <fetchstr>
801059cd:	83 c4 10             	add    $0x10,%esp
801059d0:	85 c0                	test   %eax,%eax
801059d2:	78 28                	js     801059fc <sys_exec+0xac>
  for(i=0;; i++){
801059d4:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
801059d7:	83 fb 20             	cmp    $0x20,%ebx
801059da:	74 20                	je     801059fc <sys_exec+0xac>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801059dc:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801059e2:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
801059e9:	83 ec 08             	sub    $0x8,%esp
801059ec:	57                   	push   %edi
801059ed:	01 f0                	add    %esi,%eax
801059ef:	50                   	push   %eax
801059f0:	e8 4b f3 ff ff       	call   80104d40 <fetchint>
801059f5:	83 c4 10             	add    $0x10,%esp
801059f8:	85 c0                	test   %eax,%eax
801059fa:	79 b4                	jns    801059b0 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
801059fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
801059ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a04:	5b                   	pop    %ebx
80105a05:	5e                   	pop    %esi
80105a06:	5f                   	pop    %edi
80105a07:	5d                   	pop    %ebp
80105a08:	c3                   	ret    
80105a09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105a10:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a16:	83 ec 08             	sub    $0x8,%esp
      argv[i] = 0;
80105a19:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105a20:	00 00 00 00 
  return exec(path, argv);
80105a24:	50                   	push   %eax
80105a25:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105a2b:	e8 50 b3 ff ff       	call   80100d80 <exec>
80105a30:	83 c4 10             	add    $0x10,%esp
}
80105a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a36:	5b                   	pop    %ebx
80105a37:	5e                   	pop    %esi
80105a38:	5f                   	pop    %edi
80105a39:	5d                   	pop    %ebp
80105a3a:	c3                   	ret    
80105a3b:	90                   	nop
80105a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105a40 <sys_pipe>:

int
sys_pipe(void)
{
80105a40:	55                   	push   %ebp
80105a41:	89 e5                	mov    %esp,%ebp
80105a43:	57                   	push   %edi
80105a44:	56                   	push   %esi
80105a45:	53                   	push   %ebx
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105a46:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105a49:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105a4c:	6a 08                	push   $0x8
80105a4e:	50                   	push   %eax
80105a4f:	6a 00                	push   $0x0
80105a51:	e8 ea f3 ff ff       	call   80104e40 <argptr>
80105a56:	83 c4 10             	add    $0x10,%esp
80105a59:	85 c0                	test   %eax,%eax
80105a5b:	0f 88 ae 00 00 00    	js     80105b0f <sys_pipe+0xcf>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105a61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a64:	83 ec 08             	sub    $0x8,%esp
80105a67:	50                   	push   %eax
80105a68:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105a6b:	50                   	push   %eax
80105a6c:	e8 af dc ff ff       	call   80103720 <pipealloc>
80105a71:	83 c4 10             	add    $0x10,%esp
80105a74:	85 c0                	test   %eax,%eax
80105a76:	0f 88 93 00 00 00    	js     80105b0f <sys_pipe+0xcf>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105a7c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105a7f:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105a81:	e8 3a e2 ff ff       	call   80103cc0 <myproc>
80105a86:	eb 10                	jmp    80105a98 <sys_pipe+0x58>
80105a88:	90                   	nop
80105a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(fd = 0; fd < NOFILE; fd++){
80105a90:	83 c3 01             	add    $0x1,%ebx
80105a93:	83 fb 10             	cmp    $0x10,%ebx
80105a96:	74 60                	je     80105af8 <sys_pipe+0xb8>
    if(curproc->ofile[fd] == 0){
80105a98:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105a9c:	85 f6                	test   %esi,%esi
80105a9e:	75 f0                	jne    80105a90 <sys_pipe+0x50>
      curproc->ofile[fd] = f;
80105aa0:	8d 73 08             	lea    0x8(%ebx),%esi
80105aa3:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105aa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80105aaa:	e8 11 e2 ff ff       	call   80103cc0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105aaf:	31 d2                	xor    %edx,%edx
80105ab1:	eb 0d                	jmp    80105ac0 <sys_pipe+0x80>
80105ab3:	90                   	nop
80105ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105ab8:	83 c2 01             	add    $0x1,%edx
80105abb:	83 fa 10             	cmp    $0x10,%edx
80105abe:	74 28                	je     80105ae8 <sys_pipe+0xa8>
    if(curproc->ofile[fd] == 0){
80105ac0:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80105ac4:	85 c9                	test   %ecx,%ecx
80105ac6:	75 f0                	jne    80105ab8 <sys_pipe+0x78>
      curproc->ofile[fd] = f;
80105ac8:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105acc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105acf:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105ad1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ad4:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105ad7:	31 c0                	xor    %eax,%eax
}
80105ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105adc:	5b                   	pop    %ebx
80105add:	5e                   	pop    %esi
80105ade:	5f                   	pop    %edi
80105adf:	5d                   	pop    %ebp
80105ae0:	c3                   	ret    
80105ae1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      myproc()->ofile[fd0] = 0;
80105ae8:	e8 d3 e1 ff ff       	call   80103cc0 <myproc>
80105aed:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105af4:	00 
80105af5:	8d 76 00             	lea    0x0(%esi),%esi
    fileclose(rf);
80105af8:	83 ec 0c             	sub    $0xc,%esp
80105afb:	ff 75 e0             	pushl  -0x20(%ebp)
80105afe:	e8 ad b6 ff ff       	call   801011b0 <fileclose>
    fileclose(wf);
80105b03:	58                   	pop    %eax
80105b04:	ff 75 e4             	pushl  -0x1c(%ebp)
80105b07:	e8 a4 b6 ff ff       	call   801011b0 <fileclose>
    return -1;
80105b0c:	83 c4 10             	add    $0x10,%esp
80105b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b14:	eb c3                	jmp    80105ad9 <sys_pipe+0x99>
80105b16:	8d 76 00             	lea    0x0(%esi),%esi
80105b19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105b20 <sys_bstat>:

// returns the number of swapped pages

int
sys_bstat(void)
{
80105b20:	55                   	push   %ebp
	return numallocblocks;
}
80105b21:	a1 5c b5 10 80       	mov    0x8010b55c,%eax
{
80105b26:	89 e5                	mov    %esp,%ebp
}
80105b28:	5d                   	pop    %ebp
80105b29:	c3                   	ret    
80105b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105b30 <sys_swap>:

int
sys_swap(void)
{
80105b30:	55                   	push   %ebp
80105b31:	89 e5                	mov    %esp,%ebp
80105b33:	57                   	push   %edi
80105b34:	56                   	push   %esi
80105b35:	53                   	push   %ebx
  uint addr;

  if(argint(0, (int*)&addr) < 0)
80105b36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
{
80105b39:	83 ec 24             	sub    $0x24,%esp
  if(argint(0, (int*)&addr) < 0)
80105b3c:	50                   	push   %eax
80105b3d:	6a 00                	push   $0x0
80105b3f:	e8 ac f2 ff ff       	call   80104df0 <argint>
80105b44:	83 c4 10             	add    $0x10,%esp
80105b47:	85 c0                	test   %eax,%eax
80105b49:	0f 88 91 00 00 00    	js     80105be0 <sys_swap+0xb0>
    return -1;
  struct proc *currentProcess=myproc();
80105b4f:	e8 6c e1 ff ff       	call   80103cc0 <myproc>
  pde_t *pgdir=currentProcess->pgdir;
  pte_t *pte=walkpgdir(pgdir,(char*)addr,1);
80105b54:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  pde = &pgdir[PDX(va)];
80105b57:	8b 40 04             	mov    0x4(%eax),%eax
80105b5a:	89 f2                	mov    %esi,%edx
80105b5c:	c1 ea 16             	shr    $0x16,%edx
80105b5f:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105b62:	8b 07                	mov    (%edi),%eax
80105b64:	a8 01                	test   $0x1,%al
80105b66:	75 60                	jne    80105bc8 <sys_swap+0x98>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105b68:	e8 33 ce ff ff       	call   801029a0 <kalloc>
80105b6d:	85 c0                	test   %eax,%eax
80105b6f:	89 c3                	mov    %eax,%ebx
80105b71:	74 65                	je     80105bd8 <sys_swap+0xa8>
    memset(pgtab, 0, PGSIZE);
80105b73:	83 ec 04             	sub    $0x4,%esp
80105b76:	68 00 10 00 00       	push   $0x1000
80105b7b:	6a 00                	push   $0x0
80105b7d:	50                   	push   %eax
80105b7e:	e8 6d ef ff ff       	call   80104af0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105b83:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105b89:	83 c4 10             	add    $0x10,%esp
80105b8c:	83 c8 07             	or     $0x7,%eax
80105b8f:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
80105b91:	89 f0                	mov    %esi,%eax
  if(*pte & PTE_P){
    swap_page_from_pte(pte,myproc()->pid);
  }

  return 0;
80105b93:	31 f6                	xor    %esi,%esi
  return &pgtab[PTX(va)];
80105b95:	c1 e8 0a             	shr    $0xa,%eax
80105b98:	25 fc 0f 00 00       	and    $0xffc,%eax
80105b9d:	01 c3                	add    %eax,%ebx
  if(*pte & PTE_P){
80105b9f:	f6 03 01             	testb  $0x1,(%ebx)
80105ba2:	74 14                	je     80105bb8 <sys_swap+0x88>
    swap_page_from_pte(pte,myproc()->pid);
80105ba4:	e8 17 e1 ff ff       	call   80103cc0 <myproc>
80105ba9:	83 ec 08             	sub    $0x8,%esp
80105bac:	ff 70 10             	pushl  0x10(%eax)
80105baf:	53                   	push   %ebx
80105bb0:	e8 db 05 00 00       	call   80106190 <swap_page_from_pte>
80105bb5:	83 c4 10             	add    $0x10,%esp
}
80105bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bbb:	89 f0                	mov    %esi,%eax
80105bbd:	5b                   	pop    %ebx
80105bbe:	5e                   	pop    %esi
80105bbf:	5f                   	pop    %edi
80105bc0:	5d                   	pop    %ebp
80105bc1:	c3                   	ret    
80105bc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105bc8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105bcd:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80105bd3:	eb bc                	jmp    80105b91 <sys_swap+0x61>
80105bd5:	8d 76 00             	lea    0x0(%esi),%esi
  if(*pte & PTE_P){
80105bd8:	a1 00 00 00 00       	mov    0x0,%eax
80105bdd:	0f 0b                	ud2    
80105bdf:	90                   	nop
    return -1;
80105be0:	be ff ff ff ff       	mov    $0xffffffff,%esi
80105be5:	eb d1                	jmp    80105bb8 <sys_swap+0x88>
80105be7:	66 90                	xchg   %ax,%ax
80105be9:	66 90                	xchg   %ax,%ax
80105beb:	66 90                	xchg   %ax,%ax
80105bed:	66 90                	xchg   %ax,%ax
80105bef:	90                   	nop

80105bf0 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105bf0:	55                   	push   %ebp
80105bf1:	89 e5                	mov    %esp,%ebp
  return fork();
}
80105bf3:	5d                   	pop    %ebp
  return fork();
80105bf4:	e9 37 e2 ff ff       	jmp    80103e30 <fork>
80105bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105c00 <sys_exit>:

int
sys_exit(void)
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c06:	e8 a5 e4 ff ff       	call   801040b0 <exit>
  return 0;  // not reached
}
80105c0b:	31 c0                	xor    %eax,%eax
80105c0d:	c9                   	leave  
80105c0e:	c3                   	ret    
80105c0f:	90                   	nop

80105c10 <sys_wait>:

int
sys_wait(void)
{
80105c10:	55                   	push   %ebp
80105c11:	89 e5                	mov    %esp,%ebp
  return wait();
}
80105c13:	5d                   	pop    %ebp
  return wait();
80105c14:	e9 d7 e6 ff ff       	jmp    801042f0 <wait>
80105c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105c20 <sys_kill>:

int
sys_kill(void)
{
80105c20:	55                   	push   %ebp
80105c21:	89 e5                	mov    %esp,%ebp
80105c23:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c29:	50                   	push   %eax
80105c2a:	6a 00                	push   $0x0
80105c2c:	e8 bf f1 ff ff       	call   80104df0 <argint>
80105c31:	83 c4 10             	add    $0x10,%esp
80105c34:	85 c0                	test   %eax,%eax
80105c36:	78 18                	js     80105c50 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105c38:	83 ec 0c             	sub    $0xc,%esp
80105c3b:	ff 75 f4             	pushl  -0xc(%ebp)
80105c3e:	e8 0d e8 ff ff       	call   80104450 <kill>
80105c43:	83 c4 10             	add    $0x10,%esp
}
80105c46:	c9                   	leave  
80105c47:	c3                   	ret    
80105c48:	90                   	nop
80105c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c55:	c9                   	leave  
80105c56:	c3                   	ret    
80105c57:	89 f6                	mov    %esi,%esi
80105c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105c60 <sys_getpid>:

int
sys_getpid(void)
{
80105c60:	55                   	push   %ebp
80105c61:	89 e5                	mov    %esp,%ebp
80105c63:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105c66:	e8 55 e0 ff ff       	call   80103cc0 <myproc>
80105c6b:	8b 40 10             	mov    0x10(%eax),%eax
}
80105c6e:	c9                   	leave  
80105c6f:	c3                   	ret    

80105c70 <sys_sbrk>:

int
sys_sbrk(void)
{
80105c70:	55                   	push   %ebp
80105c71:	89 e5                	mov    %esp,%ebp
80105c73:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105c74:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105c77:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105c7a:	50                   	push   %eax
80105c7b:	6a 00                	push   $0x0
80105c7d:	e8 6e f1 ff ff       	call   80104df0 <argint>
80105c82:	83 c4 10             	add    $0x10,%esp
80105c85:	85 c0                	test   %eax,%eax
80105c87:	78 27                	js     80105cb0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105c89:	e8 32 e0 ff ff       	call   80103cc0 <myproc>
  if(growproc(n) < 0)
80105c8e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105c91:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105c93:	ff 75 f4             	pushl  -0xc(%ebp)
80105c96:	e8 45 e1 ff ff       	call   80103de0 <growproc>
80105c9b:	83 c4 10             	add    $0x10,%esp
80105c9e:	85 c0                	test   %eax,%eax
80105ca0:	78 0e                	js     80105cb0 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105ca2:	89 d8                	mov    %ebx,%eax
80105ca4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ca7:	c9                   	leave  
80105ca8:	c3                   	ret    
80105ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105cb0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105cb5:	eb eb                	jmp    80105ca2 <sys_sbrk+0x32>
80105cb7:	89 f6                	mov    %esi,%esi
80105cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105cc0 <sys_sleep>:

int
sys_sleep(void)
{
80105cc0:	55                   	push   %ebp
80105cc1:	89 e5                	mov    %esp,%ebp
80105cc3:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105cc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105cc7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105cca:	50                   	push   %eax
80105ccb:	6a 00                	push   $0x0
80105ccd:	e8 1e f1 ff ff       	call   80104df0 <argint>
80105cd2:	83 c4 10             	add    $0x10,%esp
80105cd5:	85 c0                	test   %eax,%eax
80105cd7:	0f 88 8a 00 00 00    	js     80105d67 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105cdd:	83 ec 0c             	sub    $0xc,%esp
80105ce0:	68 a0 5f 11 80       	push   $0x80115fa0
80105ce5:	e8 86 ec ff ff       	call   80104970 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ced:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105cf0:	8b 1d e0 67 11 80    	mov    0x801167e0,%ebx
  while(ticks - ticks0 < n){
80105cf6:	85 d2                	test   %edx,%edx
80105cf8:	75 27                	jne    80105d21 <sys_sleep+0x61>
80105cfa:	eb 54                	jmp    80105d50 <sys_sleep+0x90>
80105cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105d00:	83 ec 08             	sub    $0x8,%esp
80105d03:	68 a0 5f 11 80       	push   $0x80115fa0
80105d08:	68 e0 67 11 80       	push   $0x801167e0
80105d0d:	e8 1e e5 ff ff       	call   80104230 <sleep>
  while(ticks - ticks0 < n){
80105d12:	a1 e0 67 11 80       	mov    0x801167e0,%eax
80105d17:	83 c4 10             	add    $0x10,%esp
80105d1a:	29 d8                	sub    %ebx,%eax
80105d1c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105d1f:	73 2f                	jae    80105d50 <sys_sleep+0x90>
    if(myproc()->killed){
80105d21:	e8 9a df ff ff       	call   80103cc0 <myproc>
80105d26:	8b 40 24             	mov    0x24(%eax),%eax
80105d29:	85 c0                	test   %eax,%eax
80105d2b:	74 d3                	je     80105d00 <sys_sleep+0x40>
      release(&tickslock);
80105d2d:	83 ec 0c             	sub    $0xc,%esp
80105d30:	68 a0 5f 11 80       	push   $0x80115fa0
80105d35:	e8 56 ed ff ff       	call   80104a90 <release>
      return -1;
80105d3a:	83 c4 10             	add    $0x10,%esp
80105d3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&tickslock);
  return 0;
}
80105d42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d45:	c9                   	leave  
80105d46:	c3                   	ret    
80105d47:	89 f6                	mov    %esi,%esi
80105d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  release(&tickslock);
80105d50:	83 ec 0c             	sub    $0xc,%esp
80105d53:	68 a0 5f 11 80       	push   $0x80115fa0
80105d58:	e8 33 ed ff ff       	call   80104a90 <release>
  return 0;
80105d5d:	83 c4 10             	add    $0x10,%esp
80105d60:	31 c0                	xor    %eax,%eax
}
80105d62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d65:	c9                   	leave  
80105d66:	c3                   	ret    
    return -1;
80105d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6c:	eb f4                	jmp    80105d62 <sys_sleep+0xa2>
80105d6e:	66 90                	xchg   %ax,%ax

80105d70 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105d70:	55                   	push   %ebp
80105d71:	89 e5                	mov    %esp,%ebp
80105d73:	53                   	push   %ebx
80105d74:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105d77:	68 a0 5f 11 80       	push   $0x80115fa0
80105d7c:	e8 ef eb ff ff       	call   80104970 <acquire>
  xticks = ticks;
80105d81:	8b 1d e0 67 11 80    	mov    0x801167e0,%ebx
  release(&tickslock);
80105d87:	c7 04 24 a0 5f 11 80 	movl   $0x80115fa0,(%esp)
80105d8e:	e8 fd ec ff ff       	call   80104a90 <release>
  return xticks;
}
80105d93:	89 d8                	mov    %ebx,%eax
80105d95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d98:	c9                   	leave  
80105d99:	c3                   	ret    

80105d9a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d9a:	1e                   	push   %ds
  pushl %es
80105d9b:	06                   	push   %es
  pushl %fs
80105d9c:	0f a0                	push   %fs
  pushl %gs
80105d9e:	0f a8                	push   %gs
  pushal
80105da0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105da1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105da5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105da7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105da9:	54                   	push   %esp
  call trap
80105daa:	e8 c1 00 00 00       	call   80105e70 <trap>
  addl $4, %esp
80105daf:	83 c4 04             	add    $0x4,%esp

80105db2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105db2:	61                   	popa   
  popl %gs
80105db3:	0f a9                	pop    %gs
  popl %fs
80105db5:	0f a1                	pop    %fs
  popl %es
80105db7:	07                   	pop    %es
  popl %ds
80105db8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105db9:	83 c4 08             	add    $0x8,%esp
  iret
80105dbc:	cf                   	iret   
80105dbd:	66 90                	xchg   %ax,%ax
80105dbf:	90                   	nop

80105dc0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105dc0:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105dc1:	31 c0                	xor    %eax,%eax
{
80105dc3:	89 e5                	mov    %esp,%ebp
80105dc5:	83 ec 08             	sub    $0x8,%esp
80105dc8:	90                   	nop
80105dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105dd0:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105dd7:	c7 04 c5 e2 5f 11 80 	movl   $0x8e000008,-0x7feea01e(,%eax,8)
80105dde:	08 00 00 8e 
80105de2:	66 89 14 c5 e0 5f 11 	mov    %dx,-0x7feea020(,%eax,8)
80105de9:	80 
80105dea:	c1 ea 10             	shr    $0x10,%edx
80105ded:	66 89 14 c5 e6 5f 11 	mov    %dx,-0x7feea01a(,%eax,8)
80105df4:	80 
  for(i = 0; i < 256; i++)
80105df5:	83 c0 01             	add    $0x1,%eax
80105df8:	3d 00 01 00 00       	cmp    $0x100,%eax
80105dfd:	75 d1                	jne    80105dd0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105dff:	a1 08 b1 10 80       	mov    0x8010b108,%eax

  initlock(&tickslock, "time");
80105e04:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e07:	c7 05 e2 61 11 80 08 	movl   $0xef000008,0x801161e2
80105e0e:	00 00 ef 
  initlock(&tickslock, "time");
80105e11:	68 1f 84 10 80       	push   $0x8010841f
80105e16:	68 a0 5f 11 80       	push   $0x80115fa0
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e1b:	66 a3 e0 61 11 80    	mov    %ax,0x801161e0
80105e21:	c1 e8 10             	shr    $0x10,%eax
80105e24:	66 a3 e6 61 11 80    	mov    %ax,0x801161e6
  initlock(&tickslock, "time");
80105e2a:	e8 51 ea ff ff       	call   80104880 <initlock>
}
80105e2f:	83 c4 10             	add    $0x10,%esp
80105e32:	c9                   	leave  
80105e33:	c3                   	ret    
80105e34:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105e3a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80105e40 <idtinit>:

void
idtinit(void)
{
80105e40:	55                   	push   %ebp
  pd[0] = size-1;
80105e41:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105e46:	89 e5                	mov    %esp,%ebp
80105e48:	83 ec 10             	sub    $0x10,%esp
80105e4b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e4f:	b8 e0 5f 11 80       	mov    $0x80115fe0,%eax
80105e54:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e58:	c1 e8 10             	shr    $0x10,%eax
80105e5b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e5f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e62:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105e65:	c9                   	leave  
80105e66:	c3                   	ret    
80105e67:	89 f6                	mov    %esi,%esi
80105e69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80105e70 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105e70:	55                   	push   %ebp
80105e71:	89 e5                	mov    %esp,%ebp
80105e73:	57                   	push   %edi
80105e74:	56                   	push   %esi
80105e75:	53                   	push   %ebx
80105e76:	83 ec 1c             	sub    $0x1c,%esp
80105e79:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(tf->trapno == T_SYSCALL){
80105e7c:	8b 47 30             	mov    0x30(%edi),%eax
80105e7f:	83 f8 40             	cmp    $0x40,%eax
80105e82:	0f 84 f0 00 00 00    	je     80105f78 <trap+0x108>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105e88:	83 e8 0e             	sub    $0xe,%eax
80105e8b:	83 f8 31             	cmp    $0x31,%eax
80105e8e:	77 10                	ja     80105ea0 <trap+0x30>
80105e90:	ff 24 85 c8 84 10 80 	jmp    *-0x7fef7b38(,%eax,4)
80105e97:	89 f6                	mov    %esi,%esi
80105e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105ea0:	e8 1b de ff ff       	call   80103cc0 <myproc>
80105ea5:	85 c0                	test   %eax,%eax
80105ea7:	8b 5f 38             	mov    0x38(%edi),%ebx
80105eaa:	0f 84 04 02 00 00    	je     801060b4 <trap+0x244>
80105eb0:	f6 47 3c 03          	testb  $0x3,0x3c(%edi)
80105eb4:	0f 84 fa 01 00 00    	je     801060b4 <trap+0x244>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105eba:	0f 20 d1             	mov    %cr2,%ecx
80105ebd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105ec0:	e8 db dd ff ff       	call   80103ca0 <cpuid>
80105ec5:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105ec8:	8b 47 34             	mov    0x34(%edi),%eax
80105ecb:	8b 77 30             	mov    0x30(%edi),%esi
80105ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105ed1:	e8 ea dd ff ff       	call   80103cc0 <myproc>
80105ed6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105ed9:	e8 e2 dd ff ff       	call   80103cc0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105ede:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105ee1:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105ee4:	51                   	push   %ecx
80105ee5:	53                   	push   %ebx
80105ee6:	52                   	push   %edx
            myproc()->pid, myproc()->name, tf->trapno,
80105ee7:	8b 55 e0             	mov    -0x20(%ebp),%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105eea:	ff 75 e4             	pushl  -0x1c(%ebp)
80105eed:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105eee:	83 c2 6c             	add    $0x6c,%edx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105ef1:	52                   	push   %edx
80105ef2:	ff 70 10             	pushl  0x10(%eax)
80105ef5:	68 84 84 10 80       	push   $0x80108484
80105efa:	e8 d1 aa ff ff       	call   801009d0 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80105eff:	83 c4 20             	add    $0x20,%esp
80105f02:	e8 b9 dd ff ff       	call   80103cc0 <myproc>
80105f07:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105f0e:	66 90                	xchg   %ax,%ax
  }

  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105f10:	e8 ab dd ff ff       	call   80103cc0 <myproc>
80105f15:	85 c0                	test   %eax,%eax
80105f17:	74 1d                	je     80105f36 <trap+0xc6>
80105f19:	e8 a2 dd ff ff       	call   80103cc0 <myproc>
80105f1e:	8b 50 24             	mov    0x24(%eax),%edx
80105f21:	85 d2                	test   %edx,%edx
80105f23:	74 11                	je     80105f36 <trap+0xc6>
80105f25:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
80105f29:	83 e0 03             	and    $0x3,%eax
80105f2c:	66 83 f8 03          	cmp    $0x3,%ax
80105f30:	0f 84 3a 01 00 00    	je     80106070 <trap+0x200>
    exit();

  if(myproc() && myproc()->state == RUNNING &&
80105f36:	e8 85 dd ff ff       	call   80103cc0 <myproc>
80105f3b:	85 c0                	test   %eax,%eax
80105f3d:	74 0b                	je     80105f4a <trap+0xda>
80105f3f:	e8 7c dd ff ff       	call   80103cc0 <myproc>
80105f44:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105f48:	74 66                	je     80105fb0 <trap+0x140>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105f4a:	e8 71 dd ff ff       	call   80103cc0 <myproc>
80105f4f:	85 c0                	test   %eax,%eax
80105f51:	74 19                	je     80105f6c <trap+0xfc>
80105f53:	e8 68 dd ff ff       	call   80103cc0 <myproc>
80105f58:	8b 40 24             	mov    0x24(%eax),%eax
80105f5b:	85 c0                	test   %eax,%eax
80105f5d:	74 0d                	je     80105f6c <trap+0xfc>
80105f5f:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
80105f63:	83 e0 03             	and    $0x3,%eax
80105f66:	66 83 f8 03          	cmp    $0x3,%ax
80105f6a:	74 35                	je     80105fa1 <trap+0x131>
    exit();
}
80105f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f6f:	5b                   	pop    %ebx
80105f70:	5e                   	pop    %esi
80105f71:	5f                   	pop    %edi
80105f72:	5d                   	pop    %ebp
80105f73:	c3                   	ret    
80105f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80105f78:	e8 43 dd ff ff       	call   80103cc0 <myproc>
80105f7d:	8b 58 24             	mov    0x24(%eax),%ebx
80105f80:	85 db                	test   %ebx,%ebx
80105f82:	0f 85 d8 00 00 00    	jne    80106060 <trap+0x1f0>
    myproc()->tf = tf;
80105f88:	e8 33 dd ff ff       	call   80103cc0 <myproc>
80105f8d:	89 78 18             	mov    %edi,0x18(%eax)
    syscall();
80105f90:	e8 4b ef ff ff       	call   80104ee0 <syscall>
    if(myproc()->killed)
80105f95:	e8 26 dd ff ff       	call   80103cc0 <myproc>
80105f9a:	8b 48 24             	mov    0x24(%eax),%ecx
80105f9d:	85 c9                	test   %ecx,%ecx
80105f9f:	74 cb                	je     80105f6c <trap+0xfc>
}
80105fa1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105fa4:	5b                   	pop    %ebx
80105fa5:	5e                   	pop    %esi
80105fa6:	5f                   	pop    %edi
80105fa7:	5d                   	pop    %ebp
      exit();
80105fa8:	e9 03 e1 ff ff       	jmp    801040b0 <exit>
80105fad:	8d 76 00             	lea    0x0(%esi),%esi
  if(myproc() && myproc()->state == RUNNING &&
80105fb0:	83 7f 30 20          	cmpl   $0x20,0x30(%edi)
80105fb4:	75 94                	jne    80105f4a <trap+0xda>
    yield();
80105fb6:	e8 25 e2 ff ff       	call   801041e0 <yield>
80105fbb:	eb 8d                	jmp    80105f4a <trap+0xda>
80105fbd:	8d 76 00             	lea    0x0(%esi),%esi
  	handle_pgfault();
80105fc0:	e8 4b 04 00 00       	call   80106410 <handle_pgfault>
  	break;
80105fc5:	e9 46 ff ff ff       	jmp    80105f10 <trap+0xa0>
80105fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(cpuid() == 0){
80105fd0:	e8 cb dc ff ff       	call   80103ca0 <cpuid>
80105fd5:	85 c0                	test   %eax,%eax
80105fd7:	0f 84 a3 00 00 00    	je     80106080 <trap+0x210>
    lapiceoi();
80105fdd:	e8 4e cc ff ff       	call   80102c30 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105fe2:	e8 d9 dc ff ff       	call   80103cc0 <myproc>
80105fe7:	85 c0                	test   %eax,%eax
80105fe9:	0f 85 2a ff ff ff    	jne    80105f19 <trap+0xa9>
80105fef:	e9 42 ff ff ff       	jmp    80105f36 <trap+0xc6>
80105ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kbdintr();
80105ff8:	e8 f3 ca ff ff       	call   80102af0 <kbdintr>
    lapiceoi();
80105ffd:	e8 2e cc ff ff       	call   80102c30 <lapiceoi>
    break;
80106002:	e9 09 ff ff ff       	jmp    80105f10 <trap+0xa0>
80106007:	89 f6                	mov    %esi,%esi
80106009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    uartintr();
80106010:	e8 5b 06 00 00       	call   80106670 <uartintr>
    lapiceoi();
80106015:	e8 16 cc ff ff       	call   80102c30 <lapiceoi>
    break;
8010601a:	e9 f1 fe ff ff       	jmp    80105f10 <trap+0xa0>
8010601f:	90                   	nop
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106020:	0f b7 5f 3c          	movzwl 0x3c(%edi),%ebx
80106024:	8b 77 38             	mov    0x38(%edi),%esi
80106027:	e8 74 dc ff ff       	call   80103ca0 <cpuid>
8010602c:	56                   	push   %esi
8010602d:	53                   	push   %ebx
8010602e:	50                   	push   %eax
8010602f:	68 2c 84 10 80       	push   $0x8010842c
80106034:	e8 97 a9 ff ff       	call   801009d0 <cprintf>
    lapiceoi();
80106039:	e8 f2 cb ff ff       	call   80102c30 <lapiceoi>
    break;
8010603e:	83 c4 10             	add    $0x10,%esp
80106041:	e9 ca fe ff ff       	jmp    80105f10 <trap+0xa0>
80106046:	8d 76 00             	lea    0x0(%esi),%esi
80106049:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    ideintr();
80106050:	e8 0b c5 ff ff       	call   80102560 <ideintr>
80106055:	eb 86                	jmp    80105fdd <trap+0x16d>
80106057:	89 f6                	mov    %esi,%esi
80106059:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
      exit();
80106060:	e8 4b e0 ff ff       	call   801040b0 <exit>
80106065:	e9 1e ff ff ff       	jmp    80105f88 <trap+0x118>
8010606a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    exit();
80106070:	e8 3b e0 ff ff       	call   801040b0 <exit>
80106075:	e9 bc fe ff ff       	jmp    80105f36 <trap+0xc6>
8010607a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
80106080:	83 ec 0c             	sub    $0xc,%esp
80106083:	68 a0 5f 11 80       	push   $0x80115fa0
80106088:	e8 e3 e8 ff ff       	call   80104970 <acquire>
      wakeup(&ticks);
8010608d:	c7 04 24 e0 67 11 80 	movl   $0x801167e0,(%esp)
      ticks++;
80106094:	83 05 e0 67 11 80 01 	addl   $0x1,0x801167e0
      wakeup(&ticks);
8010609b:	e8 50 e3 ff ff       	call   801043f0 <wakeup>
      release(&tickslock);
801060a0:	c7 04 24 a0 5f 11 80 	movl   $0x80115fa0,(%esp)
801060a7:	e8 e4 e9 ff ff       	call   80104a90 <release>
801060ac:	83 c4 10             	add    $0x10,%esp
801060af:	e9 29 ff ff ff       	jmp    80105fdd <trap+0x16d>
801060b4:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801060b7:	e8 e4 db ff ff       	call   80103ca0 <cpuid>
801060bc:	83 ec 0c             	sub    $0xc,%esp
801060bf:	56                   	push   %esi
801060c0:	53                   	push   %ebx
801060c1:	50                   	push   %eax
801060c2:	ff 77 30             	pushl  0x30(%edi)
801060c5:	68 50 84 10 80       	push   $0x80108450
801060ca:	e8 01 a9 ff ff       	call   801009d0 <cprintf>
      panic("trap");
801060cf:	83 c4 14             	add    $0x14,%esp
801060d2:	68 24 84 10 80       	push   $0x80108424
801060d7:	e8 24 a6 ff ff       	call   80100700 <panic>
801060dc:	66 90                	xchg   %ax,%ax
801060de:	66 90                	xchg   %ax,%ax

801060e0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801060e0:	55                   	push   %ebp
801060e1:	89 e5                	mov    %esp,%ebp
801060e3:	57                   	push   %edi
801060e4:	56                   	push   %esi
801060e5:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801060e6:	89 d3                	mov    %edx,%ebx
{
801060e8:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
801060ea:	c1 eb 16             	shr    $0x16,%ebx
801060ed:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
801060f0:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
801060f3:	8b 06                	mov    (%esi),%eax
801060f5:	a8 01                	test   $0x1,%al
801060f7:	74 27                	je     80106120 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801060f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801060fe:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106104:	c1 ef 0a             	shr    $0xa,%edi
}
80106107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
8010610a:	89 fa                	mov    %edi,%edx
8010610c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80106112:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80106115:	5b                   	pop    %ebx
80106116:	5e                   	pop    %esi
80106117:	5f                   	pop    %edi
80106118:	5d                   	pop    %ebp
80106119:	c3                   	ret    
8010611a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106120:	85 c9                	test   %ecx,%ecx
80106122:	74 2c                	je     80106150 <walkpgdir+0x70>
80106124:	e8 77 c8 ff ff       	call   801029a0 <kalloc>
80106129:	85 c0                	test   %eax,%eax
8010612b:	89 c3                	mov    %eax,%ebx
8010612d:	74 21                	je     80106150 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
8010612f:	83 ec 04             	sub    $0x4,%esp
80106132:	68 00 10 00 00       	push   $0x1000
80106137:	6a 00                	push   $0x0
80106139:	50                   	push   %eax
8010613a:	e8 b1 e9 ff ff       	call   80104af0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010613f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106145:	83 c4 10             	add    $0x10,%esp
80106148:	83 c8 07             	or     $0x7,%eax
8010614b:	89 06                	mov    %eax,(%esi)
8010614d:	eb b5                	jmp    80106104 <walkpgdir+0x24>
8010614f:	90                   	nop
}
80106150:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106153:	31 c0                	xor    %eax,%eax
}
80106155:	5b                   	pop    %ebx
80106156:	5e                   	pop    %esi
80106157:	5f                   	pop    %edi
80106158:	5d                   	pop    %ebp
80106159:	c3                   	ret    
8010615a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106160 <myproc__>:
myproc__(void) {
80106160:	55                   	push   %ebp
80106161:	89 e5                	mov    %esp,%ebp
80106163:	53                   	push   %ebx
80106164:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80106167:	e8 c4 e7 ff ff       	call   80104930 <pushcli>
  c = mycpu();
8010616c:	e8 af da ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80106171:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80106177:	e8 b4 e8 ff ff       	call   80104a30 <popcli>
}
8010617c:	83 c4 04             	add    $0x4,%esp
8010617f:	89 d8                	mov    %ebx,%eax
80106181:	5b                   	pop    %ebx
80106182:	5d                   	pop    %ebp
80106183:	c3                   	ret    
80106184:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
8010618a:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80106190 <swap_page_from_pte>:
{
80106190:	55                   	push   %ebp
80106191:	89 e5                	mov    %esp,%ebp
80106193:	57                   	push   %edi
80106194:	56                   	push   %esi
80106195:	53                   	push   %ebx
80106196:	83 ec 1c             	sub    $0x1c,%esp
80106199:	8b 7d 08             	mov    0x8(%ebp),%edi
8010619c:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(physicalAddress==0)
8010619f:	8b 1f                	mov    (%edi),%ebx
{
801061a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(physicalAddress==0)
801061a4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
801061aa:	75 10                	jne    801061bc <swap_page_from_pte+0x2c>
    cprintf("physicalAddress address is zero\n");
801061ac:	83 ec 0c             	sub    $0xc,%esp
801061af:	68 90 85 10 80       	push   $0x80108590
801061b4:	e8 17 a8 ff ff       	call   801009d0 <cprintf>
801061b9:	83 c4 10             	add    $0x10,%esp
  uint diskPage=balloc_page(ROOTDEV);
801061bc:	83 ec 0c             	sub    $0xc,%esp
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage,pid,pte);    //write this page to disk
801061bf:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
  uint diskPage=balloc_page(ROOTDEV);
801061c5:	6a 01                	push   $0x1
801061c7:	e8 44 b6 ff ff       	call   80101810 <balloc_page>
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage,pid,pte);    //write this page to disk
801061cc:	89 3c 24             	mov    %edi,(%esp)
  uint diskPage=balloc_page(ROOTDEV);
801061cf:	89 c6                	mov    %eax,%esi
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage,pid,pte);    //write this page to disk
801061d1:	ff 75 e4             	pushl  -0x1c(%ebp)
801061d4:	50                   	push   %eax
801061d5:	53                   	push   %ebx
  *pte = (diskPage << 12)| PTE_SWAPPED;
801061d6:	c1 e6 0c             	shl    $0xc,%esi
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage,pid,pte);    //write this page to disk
801061d9:	6a 01                	push   $0x1
  *pte = (diskPage << 12)| PTE_SWAPPED;
801061db:	81 ce 00 02 00 00    	or     $0x200,%esi
  write_page_to_disk(ROOTDEV,(char*)P2V(physicalAddress),diskPage,pid,pte);    //write this page to disk
801061e1:	e8 6a a3 ff ff       	call   80100550 <write_page_to_disk>
  kfree(P2V(physicalAddress));
801061e6:	83 c4 14             	add    $0x14,%esp
  *pte = (diskPage << 12)| PTE_SWAPPED;
801061e9:	89 37                	mov    %esi,(%edi)
  kfree(P2V(physicalAddress));
801061eb:	53                   	push   %ebx
801061ec:	e8 ff c5 ff ff       	call   801027f0 <kfree>
  cprintf("\nReturning from swap page from pte\n");
801061f1:	c7 45 08 b4 85 10 80 	movl   $0x801085b4,0x8(%ebp)
801061f8:	83 c4 10             	add    $0x10,%esp
}
801061fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061fe:	5b                   	pop    %ebx
801061ff:	5e                   	pop    %esi
80106200:	5f                   	pop    %edi
80106201:	5d                   	pop    %ebp
  cprintf("\nReturning from swap page from pte\n");
80106202:	e9 c9 a7 ff ff       	jmp    801009d0 <cprintf>
80106207:	89 f6                	mov    %esi,%esi
80106209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106210 <swap_page>:
{
80106210:	55                   	push   %ebp
80106211:	89 e5                	mov    %esp,%ebp
80106213:	56                   	push   %esi
80106214:	53                   	push   %ebx
80106215:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pte_t* pte=select_a_victim(pgdir);         //returns *pte
80106218:	83 ec 0c             	sub    $0xc,%esp
8010621b:	53                   	push   %ebx
8010621c:	e8 ff 15 00 00       	call   80107820 <select_a_victim>
  if(pte==0){                                     //If this is true, victim is not found in 1st attempt. Inside this function
80106221:	83 c4 10             	add    $0x10,%esp
80106224:	85 c0                	test   %eax,%eax
80106226:	74 38                	je     80106260 <swap_page+0x50>
    cprintf("Victim found in 1st attempt.");
80106228:	83 ec 0c             	sub    $0xc,%esp
8010622b:	89 c6                	mov    %eax,%esi
8010622d:	68 aa 86 10 80       	push   $0x801086aa
80106232:	e8 99 a7 ff ff       	call   801009d0 <cprintf>
80106237:	83 c4 10             	add    $0x10,%esp
  swap_page_from_pte(pte,pid);  //swap victim page to disk
8010623a:	83 ec 08             	sub    $0x8,%esp
8010623d:	ff 75 0c             	pushl  0xc(%ebp)
  lcr3(V2P(pgdir));         //This operation ensures that the older TLB entries are flushed
80106240:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
  swap_page_from_pte(pte,pid);  //swap victim page to disk
80106246:	56                   	push   %esi
80106247:	e8 44 ff ff ff       	call   80106190 <swap_page_from_pte>
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010624c:	0f 22 db             	mov    %ebx,%cr3
}
8010624f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106252:	b8 01 00 00 00       	mov    $0x1,%eax
80106257:	5b                   	pop    %ebx
80106258:	5e                   	pop    %esi
80106259:	5d                   	pop    %ebp
8010625a:	c3                   	ret    
8010625b:	90                   	nop
8010625c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    cprintf("No victim found in 1st attempt. Clearing access bits.");
80106260:	83 ec 0c             	sub    $0xc,%esp
80106263:	68 d8 85 10 80       	push   $0x801085d8
80106268:	e8 63 a7 ff ff       	call   801009d0 <cprintf>
    clearaccessbit(pgdir);                        //Accessbits are cleared,
8010626d:	89 1c 24             	mov    %ebx,(%esp)
80106270:	e8 fb 15 00 00       	call   80107870 <clearaccessbit>
    cprintf("Finding victim again, after clearing access bits of 10%% pages.");
80106275:	c7 04 24 10 86 10 80 	movl   $0x80108610,(%esp)
8010627c:	e8 4f a7 ff ff       	call   801009d0 <cprintf>
    pte=select_a_victim(pgdir);                   //then victim is selected again. Victim is found this time.
80106281:	89 1c 24             	mov    %ebx,(%esp)
80106284:	e8 97 15 00 00       	call   80107820 <select_a_victim>
    if(pte!=0) cprintf("victim found");
80106289:	83 c4 10             	add    $0x10,%esp
8010628c:	85 c0                	test   %eax,%eax
    pte=select_a_victim(pgdir);                   //then victim is selected again. Victim is found this time.
8010628e:	89 c6                	mov    %eax,%esi
    if(pte!=0) cprintf("victim found");
80106290:	74 16                	je     801062a8 <swap_page+0x98>
80106292:	83 ec 0c             	sub    $0xc,%esp
80106295:	68 9d 86 10 80       	push   $0x8010869d
8010629a:	e8 31 a7 ff ff       	call   801009d0 <cprintf>
8010629f:	83 c4 10             	add    $0x10,%esp
801062a2:	eb 96                	jmp    8010623a <swap_page+0x2a>
801062a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else cprintf("Not found even in second attempt." );
801062a8:	83 ec 0c             	sub    $0xc,%esp
801062ab:	68 50 86 10 80       	push   $0x80108650
801062b0:	e8 1b a7 ff ff       	call   801009d0 <cprintf>
801062b5:	83 c4 10             	add    $0x10,%esp
801062b8:	eb 80                	jmp    8010623a <swap_page+0x2a>
801062ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801062c0 <map_address>:
{
801062c0:	55                   	push   %ebp
801062c1:	89 e5                	mov    %esp,%ebp
801062c3:	57                   	push   %edi
801062c4:	56                   	push   %esi
801062c5:	53                   	push   %ebx
801062c6:	83 ec 1c             	sub    $0x1c,%esp
801062c9:	8b 45 10             	mov    0x10(%ebp),%eax
801062cc:	8b 7d 08             	mov    0x8(%ebp),%edi
801062cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
801062d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  pushcli();
801062d5:	e8 56 e6 ff ff       	call   80104930 <pushcli>
  c = mycpu();
801062da:	e8 41 d9 ff ff       	call   80103c20 <mycpu>
  popcli();
801062df:	e8 4c e7 ff ff       	call   80104a30 <popcli>
  asm volatile("movl %%cr2,%0" : "=r" (val));
801062e4:	0f 20 d6             	mov    %cr2,%esi
	uint a= PGROUNDDOWN(rcr2());			//rounds the address to a multiple of page size (PGSIZE)
801062e7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  pte_t *pte=walkpgdir(pgdir, (char*)a, 0);
801062ed:	31 c9                	xor    %ecx,%ecx
801062ef:	89 f8                	mov    %edi,%eax
801062f1:	89 f2                	mov    %esi,%edx
801062f3:	89 f3                	mov    %esi,%ebx
801062f5:	e8 e6 fd ff ff       	call   801060e0 <walkpgdir>
801062fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	char *mem=kalloc();    //allocate a physical page
801062fd:	e8 9e c6 ff ff       	call   801029a0 <kalloc>
  if(mem==0){
80106302:	85 c0                	test   %eax,%eax
80106304:	89 c7                	mov    %eax,%edi
80106306:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106309:	0f 84 d1 00 00 00    	je     801063e0 <map_address+0x120>
  if(pte!=0){
8010630f:	85 d2                	test   %edx,%edx
80106311:	74 75                	je     80106388 <map_address+0xc8>
    if(*pte & PTE_SWAPPED){
80106313:	f7 02 00 02 00 00    	testl  $0x200,(%edx)
80106319:	8d 8f 00 00 00 80    	lea    -0x80000000(%edi),%ecx
8010631f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80106322:	89 4d dc             	mov    %ecx,-0x24(%ebp)
80106325:	75 69                	jne    80106390 <map_address+0xd0>
      memset(mem,0,PGSIZE);
80106327:	83 ec 04             	sub    $0x4,%esp
8010632a:	68 00 10 00 00       	push   $0x1000
8010632f:	6a 00                	push   $0x0
80106331:	57                   	push   %edi
80106332:	29 f7                	sub    %esi,%edi
80106334:	81 c7 00 00 00 80    	add    $0x80000000,%edi
8010633a:	e8 b1 e7 ff ff       	call   80104af0 <memset>
{
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010633f:	89 75 e0             	mov    %esi,-0x20(%ebp)
80106342:	83 c4 10             	add    $0x10,%esp
80106345:	eb 19                	jmp    80106360 <map_address+0xa0>
80106347:	89 f6                	mov    %esi,%esi
80106349:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    *pte = pa | perm | PTE_P;
80106350:	83 ce 07             	or     $0x7,%esi
    if(a == last)
80106353:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
    *pte = pa | perm | PTE_P;
80106356:	89 30                	mov    %esi,(%eax)
    if(a == last)
80106358:	74 2e                	je     80106388 <map_address+0xc8>
      break;
    a += PGSIZE;
8010635a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106360:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106363:	b9 01 00 00 00       	mov    $0x1,%ecx
80106368:	89 da                	mov    %ebx,%edx
8010636a:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
8010636d:	e8 6e fd ff ff       	call   801060e0 <walkpgdir>
80106372:	85 c0                	test   %eax,%eax
80106374:	75 da                	jne    80106350 <map_address+0x90>
    		panic("allocuvm out of memory xv7 in mappages/n");
80106376:	83 ec 0c             	sub    $0xc,%esp
80106379:	68 74 86 10 80       	push   $0x80108674
8010637e:	e8 7d a3 ff ff       	call   80100700 <panic>
80106383:	90                   	nop
80106384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
}
80106388:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010638b:	5b                   	pop    %ebx
8010638c:	5e                   	pop    %esi
8010638d:	5f                   	pop    %edi
8010638e:	5d                   	pop    %ebp
8010638f:	c3                   	ret    
      blockid=getswappedblk(pgdir,a);      //disk id where the page was swapped
80106390:	83 ec 08             	sub    $0x8,%esp
80106393:	56                   	push   %esi
80106394:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106397:	56                   	push   %esi
80106398:	e8 03 15 00 00       	call   801078a0 <getswappedblk>
      read_page_from_disk(ROOTDEV, mem, blockid);
8010639d:	83 c4 0c             	add    $0xc,%esp
      blockid=getswappedblk(pgdir,a);      //disk id where the page was swapped
801063a0:	89 c3                	mov    %eax,%ebx
      read_page_from_disk(ROOTDEV, mem, blockid);
801063a2:	50                   	push   %eax
801063a3:	57                   	push   %edi
801063a4:	6a 01                	push   $0x1
801063a6:	e8 45 a1 ff ff       	call   801004f0 <read_page_from_disk>
      *pte &= ~PTE_SWAPPED;
801063ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
801063ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
      lcr3(V2P(pgdir));
801063b1:	89 f0                	mov    %esi,%eax
801063b3:	05 00 00 00 80       	add    $0x80000000,%eax
      *pte &= ~PTE_SWAPPED;
801063b8:	80 e5 fd             	and    $0xfd,%ch
801063bb:	83 c9 07             	or     $0x7,%ecx
801063be:	89 0a                	mov    %ecx,(%edx)
  asm volatile("movl %0,%%cr3" : : "r" (val));
801063c0:	0f 22 d8             	mov    %eax,%cr3
      bfree_page(ROOTDEV,blockid);
801063c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801063c6:	c7 45 08 01 00 00 00 	movl   $0x1,0x8(%ebp)
801063cd:	83 c4 10             	add    $0x10,%esp
}
801063d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063d3:	5b                   	pop    %ebx
801063d4:	5e                   	pop    %esi
801063d5:	5f                   	pop    %edi
801063d6:	5d                   	pop    %ebp
      bfree_page(ROOTDEV,blockid);
801063d7:	e9 d4 b4 ff ff       	jmp    801018b0 <bfree_page>
801063dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    swap_page(pgdir,pid);
801063e0:	83 ec 08             	sub    $0x8,%esp
801063e3:	ff 75 dc             	pushl  -0x24(%ebp)
801063e6:	ff 75 e4             	pushl  -0x1c(%ebp)
801063e9:	e8 22 fe ff ff       	call   80106210 <swap_page>
    mem=kalloc();             //now a physical page has been swapped to disk and free, so this time we will get physical page for sure.
801063ee:	e8 ad c5 ff ff       	call   801029a0 <kalloc>
    cprintf("kalloc success\n");
801063f3:	c7 04 24 c7 86 10 80 	movl   $0x801086c7,(%esp)
    mem=kalloc();             //now a physical page has been swapped to disk and free, so this time we will get physical page for sure.
801063fa:	89 c7                	mov    %eax,%edi
    cprintf("kalloc success\n");
801063fc:	e8 cf a5 ff ff       	call   801009d0 <cprintf>
80106401:	83 c4 10             	add    $0x10,%esp
80106404:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106407:	e9 03 ff ff ff       	jmp    8010630f <map_address+0x4f>
8010640c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106410 <handle_pgfault>:
{
80106410:	55                   	push   %ebp
80106411:	89 e5                	mov    %esp,%ebp
80106413:	53                   	push   %ebx
80106414:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80106417:	e8 14 e5 ff ff       	call   80104930 <pushcli>
  c = mycpu();
8010641c:	e8 ff d7 ff ff       	call   80103c20 <mycpu>
  p = c->proc;
80106421:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80106427:	e8 04 e6 ff ff       	call   80104a30 <popcli>
	asm volatile ("movl %%cr2, %0 \n\t" : "=r" (addr));
8010642c:	0f 20 d0             	mov    %cr2,%eax
	map_address(curproc->pgdir, addr, curproc->pid);
8010642f:	83 ec 04             	sub    $0x4,%esp
	addr &= ~0xfff;
80106432:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	map_address(curproc->pgdir, addr, curproc->pid);
80106437:	ff 73 10             	pushl  0x10(%ebx)
8010643a:	50                   	push   %eax
8010643b:	ff 73 04             	pushl  0x4(%ebx)
8010643e:	e8 7d fe ff ff       	call   801062c0 <map_address>
}
80106443:	83 c4 10             	add    $0x10,%esp
80106446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106449:	c9                   	leave  
8010644a:	c3                   	ret    
8010644b:	90                   	nop
8010644c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106450 <deallocuvmXV7>:
{
80106450:	55                   	push   %ebp
80106451:	89 e5                	mov    %esp,%ebp
80106453:	57                   	push   %edi
80106454:	56                   	push   %esi
80106455:	53                   	push   %ebx
80106456:	83 ec 1c             	sub    $0x1c,%esp
80106459:	8b 75 0c             	mov    0xc(%ebp),%esi
  if(newsz >= oldsz)
8010645c:	39 75 10             	cmp    %esi,0x10(%ebp)
{
8010645f:	8b 7d 08             	mov    0x8(%ebp),%edi
    return oldsz;
80106462:	89 f0                	mov    %esi,%eax
  if(newsz >= oldsz)
80106464:	73 79                	jae    801064df <deallocuvmXV7+0x8f>
  a = PGROUNDUP(newsz);
80106466:	8b 45 10             	mov    0x10(%ebp),%eax
80106469:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010646f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106475:	39 de                	cmp    %ebx,%esi
80106477:	77 3e                	ja     801064b7 <deallocuvmXV7+0x67>
80106479:	eb 61                	jmp    801064dc <deallocuvmXV7+0x8c>
8010647b:	90                   	nop
8010647c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if((*pte & PTE_P) != 0){
80106480:	8b 10                	mov    (%eax),%edx
80106482:	f6 c2 01             	test   $0x1,%dl
80106485:	74 26                	je     801064ad <deallocuvmXV7+0x5d>
      if(pa == 0)
80106487:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010648d:	74 58                	je     801064e7 <deallocuvmXV7+0x97>
      kfree(v);
8010648f:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106492:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80106498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
8010649b:	52                   	push   %edx
8010649c:	e8 4f c3 ff ff       	call   801027f0 <kfree>
      *pte = 0;
801064a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064a4:	83 c4 10             	add    $0x10,%esp
801064a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801064ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801064b3:	39 de                	cmp    %ebx,%esi
801064b5:	76 25                	jbe    801064dc <deallocuvmXV7+0x8c>
    pte = walkpgdir(pgdir, (char*)a, 0);
801064b7:	31 c9                	xor    %ecx,%ecx
801064b9:	89 da                	mov    %ebx,%edx
801064bb:	89 f8                	mov    %edi,%eax
801064bd:	e8 1e fc ff ff       	call   801060e0 <walkpgdir>
    if(!pte)
801064c2:	85 c0                	test   %eax,%eax
801064c4:	75 ba                	jne    80106480 <deallocuvmXV7+0x30>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801064c6:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
801064cc:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801064d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801064d8:	39 de                	cmp    %ebx,%esi
801064da:	77 db                	ja     801064b7 <deallocuvmXV7+0x67>
  return newsz;
801064dc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801064df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064e2:	5b                   	pop    %ebx
801064e3:	5e                   	pop    %esi
801064e4:	5f                   	pop    %edi
801064e5:	5d                   	pop    %ebp
801064e6:	c3                   	ret    
        panic("kfree");
801064e7:	83 ec 0c             	sub    $0xc,%esp
801064ea:	68 d7 86 10 80       	push   $0x801086d7
801064ef:	e8 0c a2 ff ff       	call   80100700 <panic>
801064f4:	66 90                	xchg   %ax,%ax
801064f6:	66 90                	xchg   %ax,%ax
801064f8:	66 90                	xchg   %ax,%ax
801064fa:	66 90                	xchg   %ax,%ax
801064fc:	66 90                	xchg   %ax,%ax
801064fe:	66 90                	xchg   %ax,%ax

80106500 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106500:	a1 bc b5 10 80       	mov    0x8010b5bc,%eax
{
80106505:	55                   	push   %ebp
80106506:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106508:	85 c0                	test   %eax,%eax
8010650a:	74 1c                	je     80106528 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010650c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106511:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106512:	a8 01                	test   $0x1,%al
80106514:	74 12                	je     80106528 <uartgetc+0x28>
80106516:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010651b:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010651c:	0f b6 c0             	movzbl %al,%eax
}
8010651f:	5d                   	pop    %ebp
80106520:	c3                   	ret    
80106521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010652d:	5d                   	pop    %ebp
8010652e:	c3                   	ret    
8010652f:	90                   	nop

80106530 <uartputc.part.0>:
uartputc(int c)
80106530:	55                   	push   %ebp
80106531:	89 e5                	mov    %esp,%ebp
80106533:	57                   	push   %edi
80106534:	56                   	push   %esi
80106535:	53                   	push   %ebx
80106536:	89 c7                	mov    %eax,%edi
80106538:	bb 80 00 00 00       	mov    $0x80,%ebx
8010653d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106542:	83 ec 0c             	sub    $0xc,%esp
80106545:	eb 1b                	jmp    80106562 <uartputc.part.0+0x32>
80106547:	89 f6                	mov    %esi,%esi
80106549:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
    microdelay(10);
80106550:	83 ec 0c             	sub    $0xc,%esp
80106553:	6a 0a                	push   $0xa
80106555:	e8 f6 c6 ff ff       	call   80102c50 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010655a:	83 c4 10             	add    $0x10,%esp
8010655d:	83 eb 01             	sub    $0x1,%ebx
80106560:	74 07                	je     80106569 <uartputc.part.0+0x39>
80106562:	89 f2                	mov    %esi,%edx
80106564:	ec                   	in     (%dx),%al
80106565:	a8 20                	test   $0x20,%al
80106567:	74 e7                	je     80106550 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106569:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010656e:	89 f8                	mov    %edi,%eax
80106570:	ee                   	out    %al,(%dx)
}
80106571:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106574:	5b                   	pop    %ebx
80106575:	5e                   	pop    %esi
80106576:	5f                   	pop    %edi
80106577:	5d                   	pop    %ebp
80106578:	c3                   	ret    
80106579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106580 <uartinit>:
{
80106580:	55                   	push   %ebp
80106581:	31 c9                	xor    %ecx,%ecx
80106583:	89 c8                	mov    %ecx,%eax
80106585:	89 e5                	mov    %esp,%ebp
80106587:	57                   	push   %edi
80106588:	56                   	push   %esi
80106589:	53                   	push   %ebx
8010658a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
8010658f:	89 da                	mov    %ebx,%edx
80106591:	83 ec 0c             	sub    $0xc,%esp
80106594:	ee                   	out    %al,(%dx)
80106595:	bf fb 03 00 00       	mov    $0x3fb,%edi
8010659a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010659f:	89 fa                	mov    %edi,%edx
801065a1:	ee                   	out    %al,(%dx)
801065a2:	b8 0c 00 00 00       	mov    $0xc,%eax
801065a7:	ba f8 03 00 00       	mov    $0x3f8,%edx
801065ac:	ee                   	out    %al,(%dx)
801065ad:	be f9 03 00 00       	mov    $0x3f9,%esi
801065b2:	89 c8                	mov    %ecx,%eax
801065b4:	89 f2                	mov    %esi,%edx
801065b6:	ee                   	out    %al,(%dx)
801065b7:	b8 03 00 00 00       	mov    $0x3,%eax
801065bc:	89 fa                	mov    %edi,%edx
801065be:	ee                   	out    %al,(%dx)
801065bf:	ba fc 03 00 00       	mov    $0x3fc,%edx
801065c4:	89 c8                	mov    %ecx,%eax
801065c6:	ee                   	out    %al,(%dx)
801065c7:	b8 01 00 00 00       	mov    $0x1,%eax
801065cc:	89 f2                	mov    %esi,%edx
801065ce:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801065cf:	ba fd 03 00 00       	mov    $0x3fd,%edx
801065d4:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801065d5:	3c ff                	cmp    $0xff,%al
801065d7:	74 5a                	je     80106633 <uartinit+0xb3>
  uart = 1;
801065d9:	c7 05 bc b5 10 80 01 	movl   $0x1,0x8010b5bc
801065e0:	00 00 00 
801065e3:	89 da                	mov    %ebx,%edx
801065e5:	ec                   	in     (%dx),%al
801065e6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801065eb:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801065ec:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
801065ef:	bb dd 86 10 80       	mov    $0x801086dd,%ebx
  ioapicenable(IRQ_COM1, 0);
801065f4:	6a 00                	push   $0x0
801065f6:	6a 04                	push   $0x4
801065f8:	e8 b3 c1 ff ff       	call   801027b0 <ioapicenable>
801065fd:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106600:	b8 78 00 00 00       	mov    $0x78,%eax
80106605:	eb 13                	jmp    8010661a <uartinit+0x9a>
80106607:	89 f6                	mov    %esi,%esi
80106609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106610:	83 c3 01             	add    $0x1,%ebx
80106613:	0f be 03             	movsbl (%ebx),%eax
80106616:	84 c0                	test   %al,%al
80106618:	74 19                	je     80106633 <uartinit+0xb3>
  if(!uart)
8010661a:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
80106620:	85 d2                	test   %edx,%edx
80106622:	74 ec                	je     80106610 <uartinit+0x90>
  for(p="xv6...\n"; *p; p++)
80106624:	83 c3 01             	add    $0x1,%ebx
80106627:	e8 04 ff ff ff       	call   80106530 <uartputc.part.0>
8010662c:	0f be 03             	movsbl (%ebx),%eax
8010662f:	84 c0                	test   %al,%al
80106631:	75 e7                	jne    8010661a <uartinit+0x9a>
}
80106633:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106636:	5b                   	pop    %ebx
80106637:	5e                   	pop    %esi
80106638:	5f                   	pop    %edi
80106639:	5d                   	pop    %ebp
8010663a:	c3                   	ret    
8010663b:	90                   	nop
8010663c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106640 <uartputc>:
  if(!uart)
80106640:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
{
80106646:	55                   	push   %ebp
80106647:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106649:	85 d2                	test   %edx,%edx
{
8010664b:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
8010664e:	74 10                	je     80106660 <uartputc+0x20>
}
80106650:	5d                   	pop    %ebp
80106651:	e9 da fe ff ff       	jmp    80106530 <uartputc.part.0>
80106656:	8d 76 00             	lea    0x0(%esi),%esi
80106659:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
80106660:	5d                   	pop    %ebp
80106661:	c3                   	ret    
80106662:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106669:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80106670 <uartintr>:

void
uartintr(void)
{
80106670:	55                   	push   %ebp
80106671:	89 e5                	mov    %esp,%ebp
80106673:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106676:	68 00 65 10 80       	push   $0x80106500
8010667b:	e8 00 a5 ff ff       	call   80100b80 <consoleintr>
}
80106680:	83 c4 10             	add    $0x10,%esp
80106683:	c9                   	leave  
80106684:	c3                   	ret    

80106685 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106685:	6a 00                	push   $0x0
  pushl $0
80106687:	6a 00                	push   $0x0
  jmp alltraps
80106689:	e9 0c f7 ff ff       	jmp    80105d9a <alltraps>

8010668e <vector1>:
.globl vector1
vector1:
  pushl $0
8010668e:	6a 00                	push   $0x0
  pushl $1
80106690:	6a 01                	push   $0x1
  jmp alltraps
80106692:	e9 03 f7 ff ff       	jmp    80105d9a <alltraps>

80106697 <vector2>:
.globl vector2
vector2:
  pushl $0
80106697:	6a 00                	push   $0x0
  pushl $2
80106699:	6a 02                	push   $0x2
  jmp alltraps
8010669b:	e9 fa f6 ff ff       	jmp    80105d9a <alltraps>

801066a0 <vector3>:
.globl vector3
vector3:
  pushl $0
801066a0:	6a 00                	push   $0x0
  pushl $3
801066a2:	6a 03                	push   $0x3
  jmp alltraps
801066a4:	e9 f1 f6 ff ff       	jmp    80105d9a <alltraps>

801066a9 <vector4>:
.globl vector4
vector4:
  pushl $0
801066a9:	6a 00                	push   $0x0
  pushl $4
801066ab:	6a 04                	push   $0x4
  jmp alltraps
801066ad:	e9 e8 f6 ff ff       	jmp    80105d9a <alltraps>

801066b2 <vector5>:
.globl vector5
vector5:
  pushl $0
801066b2:	6a 00                	push   $0x0
  pushl $5
801066b4:	6a 05                	push   $0x5
  jmp alltraps
801066b6:	e9 df f6 ff ff       	jmp    80105d9a <alltraps>

801066bb <vector6>:
.globl vector6
vector6:
  pushl $0
801066bb:	6a 00                	push   $0x0
  pushl $6
801066bd:	6a 06                	push   $0x6
  jmp alltraps
801066bf:	e9 d6 f6 ff ff       	jmp    80105d9a <alltraps>

801066c4 <vector7>:
.globl vector7
vector7:
  pushl $0
801066c4:	6a 00                	push   $0x0
  pushl $7
801066c6:	6a 07                	push   $0x7
  jmp alltraps
801066c8:	e9 cd f6 ff ff       	jmp    80105d9a <alltraps>

801066cd <vector8>:
.globl vector8
vector8:
  pushl $8
801066cd:	6a 08                	push   $0x8
  jmp alltraps
801066cf:	e9 c6 f6 ff ff       	jmp    80105d9a <alltraps>

801066d4 <vector9>:
.globl vector9
vector9:
  pushl $0
801066d4:	6a 00                	push   $0x0
  pushl $9
801066d6:	6a 09                	push   $0x9
  jmp alltraps
801066d8:	e9 bd f6 ff ff       	jmp    80105d9a <alltraps>

801066dd <vector10>:
.globl vector10
vector10:
  pushl $10
801066dd:	6a 0a                	push   $0xa
  jmp alltraps
801066df:	e9 b6 f6 ff ff       	jmp    80105d9a <alltraps>

801066e4 <vector11>:
.globl vector11
vector11:
  pushl $11
801066e4:	6a 0b                	push   $0xb
  jmp alltraps
801066e6:	e9 af f6 ff ff       	jmp    80105d9a <alltraps>

801066eb <vector12>:
.globl vector12
vector12:
  pushl $12
801066eb:	6a 0c                	push   $0xc
  jmp alltraps
801066ed:	e9 a8 f6 ff ff       	jmp    80105d9a <alltraps>

801066f2 <vector13>:
.globl vector13
vector13:
  pushl $13
801066f2:	6a 0d                	push   $0xd
  jmp alltraps
801066f4:	e9 a1 f6 ff ff       	jmp    80105d9a <alltraps>

801066f9 <vector14>:
.globl vector14
vector14:
  pushl $14
801066f9:	6a 0e                	push   $0xe
  jmp alltraps
801066fb:	e9 9a f6 ff ff       	jmp    80105d9a <alltraps>

80106700 <vector15>:
.globl vector15
vector15:
  pushl $0
80106700:	6a 00                	push   $0x0
  pushl $15
80106702:	6a 0f                	push   $0xf
  jmp alltraps
80106704:	e9 91 f6 ff ff       	jmp    80105d9a <alltraps>

80106709 <vector16>:
.globl vector16
vector16:
  pushl $0
80106709:	6a 00                	push   $0x0
  pushl $16
8010670b:	6a 10                	push   $0x10
  jmp alltraps
8010670d:	e9 88 f6 ff ff       	jmp    80105d9a <alltraps>

80106712 <vector17>:
.globl vector17
vector17:
  pushl $17
80106712:	6a 11                	push   $0x11
  jmp alltraps
80106714:	e9 81 f6 ff ff       	jmp    80105d9a <alltraps>

80106719 <vector18>:
.globl vector18
vector18:
  pushl $0
80106719:	6a 00                	push   $0x0
  pushl $18
8010671b:	6a 12                	push   $0x12
  jmp alltraps
8010671d:	e9 78 f6 ff ff       	jmp    80105d9a <alltraps>

80106722 <vector19>:
.globl vector19
vector19:
  pushl $0
80106722:	6a 00                	push   $0x0
  pushl $19
80106724:	6a 13                	push   $0x13
  jmp alltraps
80106726:	e9 6f f6 ff ff       	jmp    80105d9a <alltraps>

8010672b <vector20>:
.globl vector20
vector20:
  pushl $0
8010672b:	6a 00                	push   $0x0
  pushl $20
8010672d:	6a 14                	push   $0x14
  jmp alltraps
8010672f:	e9 66 f6 ff ff       	jmp    80105d9a <alltraps>

80106734 <vector21>:
.globl vector21
vector21:
  pushl $0
80106734:	6a 00                	push   $0x0
  pushl $21
80106736:	6a 15                	push   $0x15
  jmp alltraps
80106738:	e9 5d f6 ff ff       	jmp    80105d9a <alltraps>

8010673d <vector22>:
.globl vector22
vector22:
  pushl $0
8010673d:	6a 00                	push   $0x0
  pushl $22
8010673f:	6a 16                	push   $0x16
  jmp alltraps
80106741:	e9 54 f6 ff ff       	jmp    80105d9a <alltraps>

80106746 <vector23>:
.globl vector23
vector23:
  pushl $0
80106746:	6a 00                	push   $0x0
  pushl $23
80106748:	6a 17                	push   $0x17
  jmp alltraps
8010674a:	e9 4b f6 ff ff       	jmp    80105d9a <alltraps>

8010674f <vector24>:
.globl vector24
vector24:
  pushl $0
8010674f:	6a 00                	push   $0x0
  pushl $24
80106751:	6a 18                	push   $0x18
  jmp alltraps
80106753:	e9 42 f6 ff ff       	jmp    80105d9a <alltraps>

80106758 <vector25>:
.globl vector25
vector25:
  pushl $0
80106758:	6a 00                	push   $0x0
  pushl $25
8010675a:	6a 19                	push   $0x19
  jmp alltraps
8010675c:	e9 39 f6 ff ff       	jmp    80105d9a <alltraps>

80106761 <vector26>:
.globl vector26
vector26:
  pushl $0
80106761:	6a 00                	push   $0x0
  pushl $26
80106763:	6a 1a                	push   $0x1a
  jmp alltraps
80106765:	e9 30 f6 ff ff       	jmp    80105d9a <alltraps>

8010676a <vector27>:
.globl vector27
vector27:
  pushl $0
8010676a:	6a 00                	push   $0x0
  pushl $27
8010676c:	6a 1b                	push   $0x1b
  jmp alltraps
8010676e:	e9 27 f6 ff ff       	jmp    80105d9a <alltraps>

80106773 <vector28>:
.globl vector28
vector28:
  pushl $0
80106773:	6a 00                	push   $0x0
  pushl $28
80106775:	6a 1c                	push   $0x1c
  jmp alltraps
80106777:	e9 1e f6 ff ff       	jmp    80105d9a <alltraps>

8010677c <vector29>:
.globl vector29
vector29:
  pushl $0
8010677c:	6a 00                	push   $0x0
  pushl $29
8010677e:	6a 1d                	push   $0x1d
  jmp alltraps
80106780:	e9 15 f6 ff ff       	jmp    80105d9a <alltraps>

80106785 <vector30>:
.globl vector30
vector30:
  pushl $0
80106785:	6a 00                	push   $0x0
  pushl $30
80106787:	6a 1e                	push   $0x1e
  jmp alltraps
80106789:	e9 0c f6 ff ff       	jmp    80105d9a <alltraps>

8010678e <vector31>:
.globl vector31
vector31:
  pushl $0
8010678e:	6a 00                	push   $0x0
  pushl $31
80106790:	6a 1f                	push   $0x1f
  jmp alltraps
80106792:	e9 03 f6 ff ff       	jmp    80105d9a <alltraps>

80106797 <vector32>:
.globl vector32
vector32:
  pushl $0
80106797:	6a 00                	push   $0x0
  pushl $32
80106799:	6a 20                	push   $0x20
  jmp alltraps
8010679b:	e9 fa f5 ff ff       	jmp    80105d9a <alltraps>

801067a0 <vector33>:
.globl vector33
vector33:
  pushl $0
801067a0:	6a 00                	push   $0x0
  pushl $33
801067a2:	6a 21                	push   $0x21
  jmp alltraps
801067a4:	e9 f1 f5 ff ff       	jmp    80105d9a <alltraps>

801067a9 <vector34>:
.globl vector34
vector34:
  pushl $0
801067a9:	6a 00                	push   $0x0
  pushl $34
801067ab:	6a 22                	push   $0x22
  jmp alltraps
801067ad:	e9 e8 f5 ff ff       	jmp    80105d9a <alltraps>

801067b2 <vector35>:
.globl vector35
vector35:
  pushl $0
801067b2:	6a 00                	push   $0x0
  pushl $35
801067b4:	6a 23                	push   $0x23
  jmp alltraps
801067b6:	e9 df f5 ff ff       	jmp    80105d9a <alltraps>

801067bb <vector36>:
.globl vector36
vector36:
  pushl $0
801067bb:	6a 00                	push   $0x0
  pushl $36
801067bd:	6a 24                	push   $0x24
  jmp alltraps
801067bf:	e9 d6 f5 ff ff       	jmp    80105d9a <alltraps>

801067c4 <vector37>:
.globl vector37
vector37:
  pushl $0
801067c4:	6a 00                	push   $0x0
  pushl $37
801067c6:	6a 25                	push   $0x25
  jmp alltraps
801067c8:	e9 cd f5 ff ff       	jmp    80105d9a <alltraps>

801067cd <vector38>:
.globl vector38
vector38:
  pushl $0
801067cd:	6a 00                	push   $0x0
  pushl $38
801067cf:	6a 26                	push   $0x26
  jmp alltraps
801067d1:	e9 c4 f5 ff ff       	jmp    80105d9a <alltraps>

801067d6 <vector39>:
.globl vector39
vector39:
  pushl $0
801067d6:	6a 00                	push   $0x0
  pushl $39
801067d8:	6a 27                	push   $0x27
  jmp alltraps
801067da:	e9 bb f5 ff ff       	jmp    80105d9a <alltraps>

801067df <vector40>:
.globl vector40
vector40:
  pushl $0
801067df:	6a 00                	push   $0x0
  pushl $40
801067e1:	6a 28                	push   $0x28
  jmp alltraps
801067e3:	e9 b2 f5 ff ff       	jmp    80105d9a <alltraps>

801067e8 <vector41>:
.globl vector41
vector41:
  pushl $0
801067e8:	6a 00                	push   $0x0
  pushl $41
801067ea:	6a 29                	push   $0x29
  jmp alltraps
801067ec:	e9 a9 f5 ff ff       	jmp    80105d9a <alltraps>

801067f1 <vector42>:
.globl vector42
vector42:
  pushl $0
801067f1:	6a 00                	push   $0x0
  pushl $42
801067f3:	6a 2a                	push   $0x2a
  jmp alltraps
801067f5:	e9 a0 f5 ff ff       	jmp    80105d9a <alltraps>

801067fa <vector43>:
.globl vector43
vector43:
  pushl $0
801067fa:	6a 00                	push   $0x0
  pushl $43
801067fc:	6a 2b                	push   $0x2b
  jmp alltraps
801067fe:	e9 97 f5 ff ff       	jmp    80105d9a <alltraps>

80106803 <vector44>:
.globl vector44
vector44:
  pushl $0
80106803:	6a 00                	push   $0x0
  pushl $44
80106805:	6a 2c                	push   $0x2c
  jmp alltraps
80106807:	e9 8e f5 ff ff       	jmp    80105d9a <alltraps>

8010680c <vector45>:
.globl vector45
vector45:
  pushl $0
8010680c:	6a 00                	push   $0x0
  pushl $45
8010680e:	6a 2d                	push   $0x2d
  jmp alltraps
80106810:	e9 85 f5 ff ff       	jmp    80105d9a <alltraps>

80106815 <vector46>:
.globl vector46
vector46:
  pushl $0
80106815:	6a 00                	push   $0x0
  pushl $46
80106817:	6a 2e                	push   $0x2e
  jmp alltraps
80106819:	e9 7c f5 ff ff       	jmp    80105d9a <alltraps>

8010681e <vector47>:
.globl vector47
vector47:
  pushl $0
8010681e:	6a 00                	push   $0x0
  pushl $47
80106820:	6a 2f                	push   $0x2f
  jmp alltraps
80106822:	e9 73 f5 ff ff       	jmp    80105d9a <alltraps>

80106827 <vector48>:
.globl vector48
vector48:
  pushl $0
80106827:	6a 00                	push   $0x0
  pushl $48
80106829:	6a 30                	push   $0x30
  jmp alltraps
8010682b:	e9 6a f5 ff ff       	jmp    80105d9a <alltraps>

80106830 <vector49>:
.globl vector49
vector49:
  pushl $0
80106830:	6a 00                	push   $0x0
  pushl $49
80106832:	6a 31                	push   $0x31
  jmp alltraps
80106834:	e9 61 f5 ff ff       	jmp    80105d9a <alltraps>

80106839 <vector50>:
.globl vector50
vector50:
  pushl $0
80106839:	6a 00                	push   $0x0
  pushl $50
8010683b:	6a 32                	push   $0x32
  jmp alltraps
8010683d:	e9 58 f5 ff ff       	jmp    80105d9a <alltraps>

80106842 <vector51>:
.globl vector51
vector51:
  pushl $0
80106842:	6a 00                	push   $0x0
  pushl $51
80106844:	6a 33                	push   $0x33
  jmp alltraps
80106846:	e9 4f f5 ff ff       	jmp    80105d9a <alltraps>

8010684b <vector52>:
.globl vector52
vector52:
  pushl $0
8010684b:	6a 00                	push   $0x0
  pushl $52
8010684d:	6a 34                	push   $0x34
  jmp alltraps
8010684f:	e9 46 f5 ff ff       	jmp    80105d9a <alltraps>

80106854 <vector53>:
.globl vector53
vector53:
  pushl $0
80106854:	6a 00                	push   $0x0
  pushl $53
80106856:	6a 35                	push   $0x35
  jmp alltraps
80106858:	e9 3d f5 ff ff       	jmp    80105d9a <alltraps>

8010685d <vector54>:
.globl vector54
vector54:
  pushl $0
8010685d:	6a 00                	push   $0x0
  pushl $54
8010685f:	6a 36                	push   $0x36
  jmp alltraps
80106861:	e9 34 f5 ff ff       	jmp    80105d9a <alltraps>

80106866 <vector55>:
.globl vector55
vector55:
  pushl $0
80106866:	6a 00                	push   $0x0
  pushl $55
80106868:	6a 37                	push   $0x37
  jmp alltraps
8010686a:	e9 2b f5 ff ff       	jmp    80105d9a <alltraps>

8010686f <vector56>:
.globl vector56
vector56:
  pushl $0
8010686f:	6a 00                	push   $0x0
  pushl $56
80106871:	6a 38                	push   $0x38
  jmp alltraps
80106873:	e9 22 f5 ff ff       	jmp    80105d9a <alltraps>

80106878 <vector57>:
.globl vector57
vector57:
  pushl $0
80106878:	6a 00                	push   $0x0
  pushl $57
8010687a:	6a 39                	push   $0x39
  jmp alltraps
8010687c:	e9 19 f5 ff ff       	jmp    80105d9a <alltraps>

80106881 <vector58>:
.globl vector58
vector58:
  pushl $0
80106881:	6a 00                	push   $0x0
  pushl $58
80106883:	6a 3a                	push   $0x3a
  jmp alltraps
80106885:	e9 10 f5 ff ff       	jmp    80105d9a <alltraps>

8010688a <vector59>:
.globl vector59
vector59:
  pushl $0
8010688a:	6a 00                	push   $0x0
  pushl $59
8010688c:	6a 3b                	push   $0x3b
  jmp alltraps
8010688e:	e9 07 f5 ff ff       	jmp    80105d9a <alltraps>

80106893 <vector60>:
.globl vector60
vector60:
  pushl $0
80106893:	6a 00                	push   $0x0
  pushl $60
80106895:	6a 3c                	push   $0x3c
  jmp alltraps
80106897:	e9 fe f4 ff ff       	jmp    80105d9a <alltraps>

8010689c <vector61>:
.globl vector61
vector61:
  pushl $0
8010689c:	6a 00                	push   $0x0
  pushl $61
8010689e:	6a 3d                	push   $0x3d
  jmp alltraps
801068a0:	e9 f5 f4 ff ff       	jmp    80105d9a <alltraps>

801068a5 <vector62>:
.globl vector62
vector62:
  pushl $0
801068a5:	6a 00                	push   $0x0
  pushl $62
801068a7:	6a 3e                	push   $0x3e
  jmp alltraps
801068a9:	e9 ec f4 ff ff       	jmp    80105d9a <alltraps>

801068ae <vector63>:
.globl vector63
vector63:
  pushl $0
801068ae:	6a 00                	push   $0x0
  pushl $63
801068b0:	6a 3f                	push   $0x3f
  jmp alltraps
801068b2:	e9 e3 f4 ff ff       	jmp    80105d9a <alltraps>

801068b7 <vector64>:
.globl vector64
vector64:
  pushl $0
801068b7:	6a 00                	push   $0x0
  pushl $64
801068b9:	6a 40                	push   $0x40
  jmp alltraps
801068bb:	e9 da f4 ff ff       	jmp    80105d9a <alltraps>

801068c0 <vector65>:
.globl vector65
vector65:
  pushl $0
801068c0:	6a 00                	push   $0x0
  pushl $65
801068c2:	6a 41                	push   $0x41
  jmp alltraps
801068c4:	e9 d1 f4 ff ff       	jmp    80105d9a <alltraps>

801068c9 <vector66>:
.globl vector66
vector66:
  pushl $0
801068c9:	6a 00                	push   $0x0
  pushl $66
801068cb:	6a 42                	push   $0x42
  jmp alltraps
801068cd:	e9 c8 f4 ff ff       	jmp    80105d9a <alltraps>

801068d2 <vector67>:
.globl vector67
vector67:
  pushl $0
801068d2:	6a 00                	push   $0x0
  pushl $67
801068d4:	6a 43                	push   $0x43
  jmp alltraps
801068d6:	e9 bf f4 ff ff       	jmp    80105d9a <alltraps>

801068db <vector68>:
.globl vector68
vector68:
  pushl $0
801068db:	6a 00                	push   $0x0
  pushl $68
801068dd:	6a 44                	push   $0x44
  jmp alltraps
801068df:	e9 b6 f4 ff ff       	jmp    80105d9a <alltraps>

801068e4 <vector69>:
.globl vector69
vector69:
  pushl $0
801068e4:	6a 00                	push   $0x0
  pushl $69
801068e6:	6a 45                	push   $0x45
  jmp alltraps
801068e8:	e9 ad f4 ff ff       	jmp    80105d9a <alltraps>

801068ed <vector70>:
.globl vector70
vector70:
  pushl $0
801068ed:	6a 00                	push   $0x0
  pushl $70
801068ef:	6a 46                	push   $0x46
  jmp alltraps
801068f1:	e9 a4 f4 ff ff       	jmp    80105d9a <alltraps>

801068f6 <vector71>:
.globl vector71
vector71:
  pushl $0
801068f6:	6a 00                	push   $0x0
  pushl $71
801068f8:	6a 47                	push   $0x47
  jmp alltraps
801068fa:	e9 9b f4 ff ff       	jmp    80105d9a <alltraps>

801068ff <vector72>:
.globl vector72
vector72:
  pushl $0
801068ff:	6a 00                	push   $0x0
  pushl $72
80106901:	6a 48                	push   $0x48
  jmp alltraps
80106903:	e9 92 f4 ff ff       	jmp    80105d9a <alltraps>

80106908 <vector73>:
.globl vector73
vector73:
  pushl $0
80106908:	6a 00                	push   $0x0
  pushl $73
8010690a:	6a 49                	push   $0x49
  jmp alltraps
8010690c:	e9 89 f4 ff ff       	jmp    80105d9a <alltraps>

80106911 <vector74>:
.globl vector74
vector74:
  pushl $0
80106911:	6a 00                	push   $0x0
  pushl $74
80106913:	6a 4a                	push   $0x4a
  jmp alltraps
80106915:	e9 80 f4 ff ff       	jmp    80105d9a <alltraps>

8010691a <vector75>:
.globl vector75
vector75:
  pushl $0
8010691a:	6a 00                	push   $0x0
  pushl $75
8010691c:	6a 4b                	push   $0x4b
  jmp alltraps
8010691e:	e9 77 f4 ff ff       	jmp    80105d9a <alltraps>

80106923 <vector76>:
.globl vector76
vector76:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $76
80106925:	6a 4c                	push   $0x4c
  jmp alltraps
80106927:	e9 6e f4 ff ff       	jmp    80105d9a <alltraps>

8010692c <vector77>:
.globl vector77
vector77:
  pushl $0
8010692c:	6a 00                	push   $0x0
  pushl $77
8010692e:	6a 4d                	push   $0x4d
  jmp alltraps
80106930:	e9 65 f4 ff ff       	jmp    80105d9a <alltraps>

80106935 <vector78>:
.globl vector78
vector78:
  pushl $0
80106935:	6a 00                	push   $0x0
  pushl $78
80106937:	6a 4e                	push   $0x4e
  jmp alltraps
80106939:	e9 5c f4 ff ff       	jmp    80105d9a <alltraps>

8010693e <vector79>:
.globl vector79
vector79:
  pushl $0
8010693e:	6a 00                	push   $0x0
  pushl $79
80106940:	6a 4f                	push   $0x4f
  jmp alltraps
80106942:	e9 53 f4 ff ff       	jmp    80105d9a <alltraps>

80106947 <vector80>:
.globl vector80
vector80:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $80
80106949:	6a 50                	push   $0x50
  jmp alltraps
8010694b:	e9 4a f4 ff ff       	jmp    80105d9a <alltraps>

80106950 <vector81>:
.globl vector81
vector81:
  pushl $0
80106950:	6a 00                	push   $0x0
  pushl $81
80106952:	6a 51                	push   $0x51
  jmp alltraps
80106954:	e9 41 f4 ff ff       	jmp    80105d9a <alltraps>

80106959 <vector82>:
.globl vector82
vector82:
  pushl $0
80106959:	6a 00                	push   $0x0
  pushl $82
8010695b:	6a 52                	push   $0x52
  jmp alltraps
8010695d:	e9 38 f4 ff ff       	jmp    80105d9a <alltraps>

80106962 <vector83>:
.globl vector83
vector83:
  pushl $0
80106962:	6a 00                	push   $0x0
  pushl $83
80106964:	6a 53                	push   $0x53
  jmp alltraps
80106966:	e9 2f f4 ff ff       	jmp    80105d9a <alltraps>

8010696b <vector84>:
.globl vector84
vector84:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $84
8010696d:	6a 54                	push   $0x54
  jmp alltraps
8010696f:	e9 26 f4 ff ff       	jmp    80105d9a <alltraps>

80106974 <vector85>:
.globl vector85
vector85:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $85
80106976:	6a 55                	push   $0x55
  jmp alltraps
80106978:	e9 1d f4 ff ff       	jmp    80105d9a <alltraps>

8010697d <vector86>:
.globl vector86
vector86:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $86
8010697f:	6a 56                	push   $0x56
  jmp alltraps
80106981:	e9 14 f4 ff ff       	jmp    80105d9a <alltraps>

80106986 <vector87>:
.globl vector87
vector87:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $87
80106988:	6a 57                	push   $0x57
  jmp alltraps
8010698a:	e9 0b f4 ff ff       	jmp    80105d9a <alltraps>

8010698f <vector88>:
.globl vector88
vector88:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $88
80106991:	6a 58                	push   $0x58
  jmp alltraps
80106993:	e9 02 f4 ff ff       	jmp    80105d9a <alltraps>

80106998 <vector89>:
.globl vector89
vector89:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $89
8010699a:	6a 59                	push   $0x59
  jmp alltraps
8010699c:	e9 f9 f3 ff ff       	jmp    80105d9a <alltraps>

801069a1 <vector90>:
.globl vector90
vector90:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $90
801069a3:	6a 5a                	push   $0x5a
  jmp alltraps
801069a5:	e9 f0 f3 ff ff       	jmp    80105d9a <alltraps>

801069aa <vector91>:
.globl vector91
vector91:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $91
801069ac:	6a 5b                	push   $0x5b
  jmp alltraps
801069ae:	e9 e7 f3 ff ff       	jmp    80105d9a <alltraps>

801069b3 <vector92>:
.globl vector92
vector92:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $92
801069b5:	6a 5c                	push   $0x5c
  jmp alltraps
801069b7:	e9 de f3 ff ff       	jmp    80105d9a <alltraps>

801069bc <vector93>:
.globl vector93
vector93:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $93
801069be:	6a 5d                	push   $0x5d
  jmp alltraps
801069c0:	e9 d5 f3 ff ff       	jmp    80105d9a <alltraps>

801069c5 <vector94>:
.globl vector94
vector94:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $94
801069c7:	6a 5e                	push   $0x5e
  jmp alltraps
801069c9:	e9 cc f3 ff ff       	jmp    80105d9a <alltraps>

801069ce <vector95>:
.globl vector95
vector95:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $95
801069d0:	6a 5f                	push   $0x5f
  jmp alltraps
801069d2:	e9 c3 f3 ff ff       	jmp    80105d9a <alltraps>

801069d7 <vector96>:
.globl vector96
vector96:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $96
801069d9:	6a 60                	push   $0x60
  jmp alltraps
801069db:	e9 ba f3 ff ff       	jmp    80105d9a <alltraps>

801069e0 <vector97>:
.globl vector97
vector97:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $97
801069e2:	6a 61                	push   $0x61
  jmp alltraps
801069e4:	e9 b1 f3 ff ff       	jmp    80105d9a <alltraps>

801069e9 <vector98>:
.globl vector98
vector98:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $98
801069eb:	6a 62                	push   $0x62
  jmp alltraps
801069ed:	e9 a8 f3 ff ff       	jmp    80105d9a <alltraps>

801069f2 <vector99>:
.globl vector99
vector99:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $99
801069f4:	6a 63                	push   $0x63
  jmp alltraps
801069f6:	e9 9f f3 ff ff       	jmp    80105d9a <alltraps>

801069fb <vector100>:
.globl vector100
vector100:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $100
801069fd:	6a 64                	push   $0x64
  jmp alltraps
801069ff:	e9 96 f3 ff ff       	jmp    80105d9a <alltraps>

80106a04 <vector101>:
.globl vector101
vector101:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $101
80106a06:	6a 65                	push   $0x65
  jmp alltraps
80106a08:	e9 8d f3 ff ff       	jmp    80105d9a <alltraps>

80106a0d <vector102>:
.globl vector102
vector102:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $102
80106a0f:	6a 66                	push   $0x66
  jmp alltraps
80106a11:	e9 84 f3 ff ff       	jmp    80105d9a <alltraps>

80106a16 <vector103>:
.globl vector103
vector103:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $103
80106a18:	6a 67                	push   $0x67
  jmp alltraps
80106a1a:	e9 7b f3 ff ff       	jmp    80105d9a <alltraps>

80106a1f <vector104>:
.globl vector104
vector104:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $104
80106a21:	6a 68                	push   $0x68
  jmp alltraps
80106a23:	e9 72 f3 ff ff       	jmp    80105d9a <alltraps>

80106a28 <vector105>:
.globl vector105
vector105:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $105
80106a2a:	6a 69                	push   $0x69
  jmp alltraps
80106a2c:	e9 69 f3 ff ff       	jmp    80105d9a <alltraps>

80106a31 <vector106>:
.globl vector106
vector106:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $106
80106a33:	6a 6a                	push   $0x6a
  jmp alltraps
80106a35:	e9 60 f3 ff ff       	jmp    80105d9a <alltraps>

80106a3a <vector107>:
.globl vector107
vector107:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $107
80106a3c:	6a 6b                	push   $0x6b
  jmp alltraps
80106a3e:	e9 57 f3 ff ff       	jmp    80105d9a <alltraps>

80106a43 <vector108>:
.globl vector108
vector108:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $108
80106a45:	6a 6c                	push   $0x6c
  jmp alltraps
80106a47:	e9 4e f3 ff ff       	jmp    80105d9a <alltraps>

80106a4c <vector109>:
.globl vector109
vector109:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $109
80106a4e:	6a 6d                	push   $0x6d
  jmp alltraps
80106a50:	e9 45 f3 ff ff       	jmp    80105d9a <alltraps>

80106a55 <vector110>:
.globl vector110
vector110:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $110
80106a57:	6a 6e                	push   $0x6e
  jmp alltraps
80106a59:	e9 3c f3 ff ff       	jmp    80105d9a <alltraps>

80106a5e <vector111>:
.globl vector111
vector111:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $111
80106a60:	6a 6f                	push   $0x6f
  jmp alltraps
80106a62:	e9 33 f3 ff ff       	jmp    80105d9a <alltraps>

80106a67 <vector112>:
.globl vector112
vector112:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $112
80106a69:	6a 70                	push   $0x70
  jmp alltraps
80106a6b:	e9 2a f3 ff ff       	jmp    80105d9a <alltraps>

80106a70 <vector113>:
.globl vector113
vector113:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $113
80106a72:	6a 71                	push   $0x71
  jmp alltraps
80106a74:	e9 21 f3 ff ff       	jmp    80105d9a <alltraps>

80106a79 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $114
80106a7b:	6a 72                	push   $0x72
  jmp alltraps
80106a7d:	e9 18 f3 ff ff       	jmp    80105d9a <alltraps>

80106a82 <vector115>:
.globl vector115
vector115:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $115
80106a84:	6a 73                	push   $0x73
  jmp alltraps
80106a86:	e9 0f f3 ff ff       	jmp    80105d9a <alltraps>

80106a8b <vector116>:
.globl vector116
vector116:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $116
80106a8d:	6a 74                	push   $0x74
  jmp alltraps
80106a8f:	e9 06 f3 ff ff       	jmp    80105d9a <alltraps>

80106a94 <vector117>:
.globl vector117
vector117:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $117
80106a96:	6a 75                	push   $0x75
  jmp alltraps
80106a98:	e9 fd f2 ff ff       	jmp    80105d9a <alltraps>

80106a9d <vector118>:
.globl vector118
vector118:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $118
80106a9f:	6a 76                	push   $0x76
  jmp alltraps
80106aa1:	e9 f4 f2 ff ff       	jmp    80105d9a <alltraps>

80106aa6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $119
80106aa8:	6a 77                	push   $0x77
  jmp alltraps
80106aaa:	e9 eb f2 ff ff       	jmp    80105d9a <alltraps>

80106aaf <vector120>:
.globl vector120
vector120:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $120
80106ab1:	6a 78                	push   $0x78
  jmp alltraps
80106ab3:	e9 e2 f2 ff ff       	jmp    80105d9a <alltraps>

80106ab8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $121
80106aba:	6a 79                	push   $0x79
  jmp alltraps
80106abc:	e9 d9 f2 ff ff       	jmp    80105d9a <alltraps>

80106ac1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $122
80106ac3:	6a 7a                	push   $0x7a
  jmp alltraps
80106ac5:	e9 d0 f2 ff ff       	jmp    80105d9a <alltraps>

80106aca <vector123>:
.globl vector123
vector123:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $123
80106acc:	6a 7b                	push   $0x7b
  jmp alltraps
80106ace:	e9 c7 f2 ff ff       	jmp    80105d9a <alltraps>

80106ad3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $124
80106ad5:	6a 7c                	push   $0x7c
  jmp alltraps
80106ad7:	e9 be f2 ff ff       	jmp    80105d9a <alltraps>

80106adc <vector125>:
.globl vector125
vector125:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $125
80106ade:	6a 7d                	push   $0x7d
  jmp alltraps
80106ae0:	e9 b5 f2 ff ff       	jmp    80105d9a <alltraps>

80106ae5 <vector126>:
.globl vector126
vector126:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $126
80106ae7:	6a 7e                	push   $0x7e
  jmp alltraps
80106ae9:	e9 ac f2 ff ff       	jmp    80105d9a <alltraps>

80106aee <vector127>:
.globl vector127
vector127:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $127
80106af0:	6a 7f                	push   $0x7f
  jmp alltraps
80106af2:	e9 a3 f2 ff ff       	jmp    80105d9a <alltraps>

80106af7 <vector128>:
.globl vector128
vector128:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $128
80106af9:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106afe:	e9 97 f2 ff ff       	jmp    80105d9a <alltraps>

80106b03 <vector129>:
.globl vector129
vector129:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $129
80106b05:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b0a:	e9 8b f2 ff ff       	jmp    80105d9a <alltraps>

80106b0f <vector130>:
.globl vector130
vector130:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $130
80106b11:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b16:	e9 7f f2 ff ff       	jmp    80105d9a <alltraps>

80106b1b <vector131>:
.globl vector131
vector131:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $131
80106b1d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106b22:	e9 73 f2 ff ff       	jmp    80105d9a <alltraps>

80106b27 <vector132>:
.globl vector132
vector132:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $132
80106b29:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106b2e:	e9 67 f2 ff ff       	jmp    80105d9a <alltraps>

80106b33 <vector133>:
.globl vector133
vector133:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $133
80106b35:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106b3a:	e9 5b f2 ff ff       	jmp    80105d9a <alltraps>

80106b3f <vector134>:
.globl vector134
vector134:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $134
80106b41:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106b46:	e9 4f f2 ff ff       	jmp    80105d9a <alltraps>

80106b4b <vector135>:
.globl vector135
vector135:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $135
80106b4d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106b52:	e9 43 f2 ff ff       	jmp    80105d9a <alltraps>

80106b57 <vector136>:
.globl vector136
vector136:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $136
80106b59:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106b5e:	e9 37 f2 ff ff       	jmp    80105d9a <alltraps>

80106b63 <vector137>:
.globl vector137
vector137:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $137
80106b65:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106b6a:	e9 2b f2 ff ff       	jmp    80105d9a <alltraps>

80106b6f <vector138>:
.globl vector138
vector138:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $138
80106b71:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b76:	e9 1f f2 ff ff       	jmp    80105d9a <alltraps>

80106b7b <vector139>:
.globl vector139
vector139:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $139
80106b7d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106b82:	e9 13 f2 ff ff       	jmp    80105d9a <alltraps>

80106b87 <vector140>:
.globl vector140
vector140:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $140
80106b89:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106b8e:	e9 07 f2 ff ff       	jmp    80105d9a <alltraps>

80106b93 <vector141>:
.globl vector141
vector141:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $141
80106b95:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106b9a:	e9 fb f1 ff ff       	jmp    80105d9a <alltraps>

80106b9f <vector142>:
.globl vector142
vector142:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $142
80106ba1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106ba6:	e9 ef f1 ff ff       	jmp    80105d9a <alltraps>

80106bab <vector143>:
.globl vector143
vector143:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $143
80106bad:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106bb2:	e9 e3 f1 ff ff       	jmp    80105d9a <alltraps>

80106bb7 <vector144>:
.globl vector144
vector144:
  pushl $0
80106bb7:	6a 00                	push   $0x0
  pushl $144
80106bb9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106bbe:	e9 d7 f1 ff ff       	jmp    80105d9a <alltraps>

80106bc3 <vector145>:
.globl vector145
vector145:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $145
80106bc5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106bca:	e9 cb f1 ff ff       	jmp    80105d9a <alltraps>

80106bcf <vector146>:
.globl vector146
vector146:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $146
80106bd1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106bd6:	e9 bf f1 ff ff       	jmp    80105d9a <alltraps>

80106bdb <vector147>:
.globl vector147
vector147:
  pushl $0
80106bdb:	6a 00                	push   $0x0
  pushl $147
80106bdd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106be2:	e9 b3 f1 ff ff       	jmp    80105d9a <alltraps>

80106be7 <vector148>:
.globl vector148
vector148:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $148
80106be9:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106bee:	e9 a7 f1 ff ff       	jmp    80105d9a <alltraps>

80106bf3 <vector149>:
.globl vector149
vector149:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $149
80106bf5:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106bfa:	e9 9b f1 ff ff       	jmp    80105d9a <alltraps>

80106bff <vector150>:
.globl vector150
vector150:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $150
80106c01:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c06:	e9 8f f1 ff ff       	jmp    80105d9a <alltraps>

80106c0b <vector151>:
.globl vector151
vector151:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $151
80106c0d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c12:	e9 83 f1 ff ff       	jmp    80105d9a <alltraps>

80106c17 <vector152>:
.globl vector152
vector152:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $152
80106c19:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106c1e:	e9 77 f1 ff ff       	jmp    80105d9a <alltraps>

80106c23 <vector153>:
.globl vector153
vector153:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $153
80106c25:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106c2a:	e9 6b f1 ff ff       	jmp    80105d9a <alltraps>

80106c2f <vector154>:
.globl vector154
vector154:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $154
80106c31:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106c36:	e9 5f f1 ff ff       	jmp    80105d9a <alltraps>

80106c3b <vector155>:
.globl vector155
vector155:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $155
80106c3d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106c42:	e9 53 f1 ff ff       	jmp    80105d9a <alltraps>

80106c47 <vector156>:
.globl vector156
vector156:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $156
80106c49:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106c4e:	e9 47 f1 ff ff       	jmp    80105d9a <alltraps>

80106c53 <vector157>:
.globl vector157
vector157:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $157
80106c55:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106c5a:	e9 3b f1 ff ff       	jmp    80105d9a <alltraps>

80106c5f <vector158>:
.globl vector158
vector158:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $158
80106c61:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106c66:	e9 2f f1 ff ff       	jmp    80105d9a <alltraps>

80106c6b <vector159>:
.globl vector159
vector159:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $159
80106c6d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106c72:	e9 23 f1 ff ff       	jmp    80105d9a <alltraps>

80106c77 <vector160>:
.globl vector160
vector160:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $160
80106c79:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c7e:	e9 17 f1 ff ff       	jmp    80105d9a <alltraps>

80106c83 <vector161>:
.globl vector161
vector161:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $161
80106c85:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106c8a:	e9 0b f1 ff ff       	jmp    80105d9a <alltraps>

80106c8f <vector162>:
.globl vector162
vector162:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $162
80106c91:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106c96:	e9 ff f0 ff ff       	jmp    80105d9a <alltraps>

80106c9b <vector163>:
.globl vector163
vector163:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $163
80106c9d:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ca2:	e9 f3 f0 ff ff       	jmp    80105d9a <alltraps>

80106ca7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $164
80106ca9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106cae:	e9 e7 f0 ff ff       	jmp    80105d9a <alltraps>

80106cb3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $165
80106cb5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106cba:	e9 db f0 ff ff       	jmp    80105d9a <alltraps>

80106cbf <vector166>:
.globl vector166
vector166:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $166
80106cc1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106cc6:	e9 cf f0 ff ff       	jmp    80105d9a <alltraps>

80106ccb <vector167>:
.globl vector167
vector167:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $167
80106ccd:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106cd2:	e9 c3 f0 ff ff       	jmp    80105d9a <alltraps>

80106cd7 <vector168>:
.globl vector168
vector168:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $168
80106cd9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106cde:	e9 b7 f0 ff ff       	jmp    80105d9a <alltraps>

80106ce3 <vector169>:
.globl vector169
vector169:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $169
80106ce5:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106cea:	e9 ab f0 ff ff       	jmp    80105d9a <alltraps>

80106cef <vector170>:
.globl vector170
vector170:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $170
80106cf1:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106cf6:	e9 9f f0 ff ff       	jmp    80105d9a <alltraps>

80106cfb <vector171>:
.globl vector171
vector171:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $171
80106cfd:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d02:	e9 93 f0 ff ff       	jmp    80105d9a <alltraps>

80106d07 <vector172>:
.globl vector172
vector172:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $172
80106d09:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d0e:	e9 87 f0 ff ff       	jmp    80105d9a <alltraps>

80106d13 <vector173>:
.globl vector173
vector173:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $173
80106d15:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106d1a:	e9 7b f0 ff ff       	jmp    80105d9a <alltraps>

80106d1f <vector174>:
.globl vector174
vector174:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $174
80106d21:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106d26:	e9 6f f0 ff ff       	jmp    80105d9a <alltraps>

80106d2b <vector175>:
.globl vector175
vector175:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $175
80106d2d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106d32:	e9 63 f0 ff ff       	jmp    80105d9a <alltraps>

80106d37 <vector176>:
.globl vector176
vector176:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $176
80106d39:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106d3e:	e9 57 f0 ff ff       	jmp    80105d9a <alltraps>

80106d43 <vector177>:
.globl vector177
vector177:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $177
80106d45:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106d4a:	e9 4b f0 ff ff       	jmp    80105d9a <alltraps>

80106d4f <vector178>:
.globl vector178
vector178:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $178
80106d51:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106d56:	e9 3f f0 ff ff       	jmp    80105d9a <alltraps>

80106d5b <vector179>:
.globl vector179
vector179:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $179
80106d5d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106d62:	e9 33 f0 ff ff       	jmp    80105d9a <alltraps>

80106d67 <vector180>:
.globl vector180
vector180:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $180
80106d69:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106d6e:	e9 27 f0 ff ff       	jmp    80105d9a <alltraps>

80106d73 <vector181>:
.globl vector181
vector181:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $181
80106d75:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d7a:	e9 1b f0 ff ff       	jmp    80105d9a <alltraps>

80106d7f <vector182>:
.globl vector182
vector182:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $182
80106d81:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106d86:	e9 0f f0 ff ff       	jmp    80105d9a <alltraps>

80106d8b <vector183>:
.globl vector183
vector183:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $183
80106d8d:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106d92:	e9 03 f0 ff ff       	jmp    80105d9a <alltraps>

80106d97 <vector184>:
.globl vector184
vector184:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $184
80106d99:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106d9e:	e9 f7 ef ff ff       	jmp    80105d9a <alltraps>

80106da3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $185
80106da5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106daa:	e9 eb ef ff ff       	jmp    80105d9a <alltraps>

80106daf <vector186>:
.globl vector186
vector186:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $186
80106db1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106db6:	e9 df ef ff ff       	jmp    80105d9a <alltraps>

80106dbb <vector187>:
.globl vector187
vector187:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $187
80106dbd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106dc2:	e9 d3 ef ff ff       	jmp    80105d9a <alltraps>

80106dc7 <vector188>:
.globl vector188
vector188:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $188
80106dc9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106dce:	e9 c7 ef ff ff       	jmp    80105d9a <alltraps>

80106dd3 <vector189>:
.globl vector189
vector189:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $189
80106dd5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106dda:	e9 bb ef ff ff       	jmp    80105d9a <alltraps>

80106ddf <vector190>:
.globl vector190
vector190:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $190
80106de1:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106de6:	e9 af ef ff ff       	jmp    80105d9a <alltraps>

80106deb <vector191>:
.globl vector191
vector191:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $191
80106ded:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106df2:	e9 a3 ef ff ff       	jmp    80105d9a <alltraps>

80106df7 <vector192>:
.globl vector192
vector192:
  pushl $0
80106df7:	6a 00                	push   $0x0
  pushl $192
80106df9:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106dfe:	e9 97 ef ff ff       	jmp    80105d9a <alltraps>

80106e03 <vector193>:
.globl vector193
vector193:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $193
80106e05:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e0a:	e9 8b ef ff ff       	jmp    80105d9a <alltraps>

80106e0f <vector194>:
.globl vector194
vector194:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $194
80106e11:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e16:	e9 7f ef ff ff       	jmp    80105d9a <alltraps>

80106e1b <vector195>:
.globl vector195
vector195:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $195
80106e1d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106e22:	e9 73 ef ff ff       	jmp    80105d9a <alltraps>

80106e27 <vector196>:
.globl vector196
vector196:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $196
80106e29:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106e2e:	e9 67 ef ff ff       	jmp    80105d9a <alltraps>

80106e33 <vector197>:
.globl vector197
vector197:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $197
80106e35:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106e3a:	e9 5b ef ff ff       	jmp    80105d9a <alltraps>

80106e3f <vector198>:
.globl vector198
vector198:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $198
80106e41:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106e46:	e9 4f ef ff ff       	jmp    80105d9a <alltraps>

80106e4b <vector199>:
.globl vector199
vector199:
  pushl $0
80106e4b:	6a 00                	push   $0x0
  pushl $199
80106e4d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106e52:	e9 43 ef ff ff       	jmp    80105d9a <alltraps>

80106e57 <vector200>:
.globl vector200
vector200:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $200
80106e59:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106e5e:	e9 37 ef ff ff       	jmp    80105d9a <alltraps>

80106e63 <vector201>:
.globl vector201
vector201:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $201
80106e65:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106e6a:	e9 2b ef ff ff       	jmp    80105d9a <alltraps>

80106e6f <vector202>:
.globl vector202
vector202:
  pushl $0
80106e6f:	6a 00                	push   $0x0
  pushl $202
80106e71:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e76:	e9 1f ef ff ff       	jmp    80105d9a <alltraps>

80106e7b <vector203>:
.globl vector203
vector203:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $203
80106e7d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106e82:	e9 13 ef ff ff       	jmp    80105d9a <alltraps>

80106e87 <vector204>:
.globl vector204
vector204:
  pushl $0
80106e87:	6a 00                	push   $0x0
  pushl $204
80106e89:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106e8e:	e9 07 ef ff ff       	jmp    80105d9a <alltraps>

80106e93 <vector205>:
.globl vector205
vector205:
  pushl $0
80106e93:	6a 00                	push   $0x0
  pushl $205
80106e95:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106e9a:	e9 fb ee ff ff       	jmp    80105d9a <alltraps>

80106e9f <vector206>:
.globl vector206
vector206:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $206
80106ea1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106ea6:	e9 ef ee ff ff       	jmp    80105d9a <alltraps>

80106eab <vector207>:
.globl vector207
vector207:
  pushl $0
80106eab:	6a 00                	push   $0x0
  pushl $207
80106ead:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106eb2:	e9 e3 ee ff ff       	jmp    80105d9a <alltraps>

80106eb7 <vector208>:
.globl vector208
vector208:
  pushl $0
80106eb7:	6a 00                	push   $0x0
  pushl $208
80106eb9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ebe:	e9 d7 ee ff ff       	jmp    80105d9a <alltraps>

80106ec3 <vector209>:
.globl vector209
vector209:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $209
80106ec5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106eca:	e9 cb ee ff ff       	jmp    80105d9a <alltraps>

80106ecf <vector210>:
.globl vector210
vector210:
  pushl $0
80106ecf:	6a 00                	push   $0x0
  pushl $210
80106ed1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ed6:	e9 bf ee ff ff       	jmp    80105d9a <alltraps>

80106edb <vector211>:
.globl vector211
vector211:
  pushl $0
80106edb:	6a 00                	push   $0x0
  pushl $211
80106edd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106ee2:	e9 b3 ee ff ff       	jmp    80105d9a <alltraps>

80106ee7 <vector212>:
.globl vector212
vector212:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $212
80106ee9:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106eee:	e9 a7 ee ff ff       	jmp    80105d9a <alltraps>

80106ef3 <vector213>:
.globl vector213
vector213:
  pushl $0
80106ef3:	6a 00                	push   $0x0
  pushl $213
80106ef5:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106efa:	e9 9b ee ff ff       	jmp    80105d9a <alltraps>

80106eff <vector214>:
.globl vector214
vector214:
  pushl $0
80106eff:	6a 00                	push   $0x0
  pushl $214
80106f01:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f06:	e9 8f ee ff ff       	jmp    80105d9a <alltraps>

80106f0b <vector215>:
.globl vector215
vector215:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $215
80106f0d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f12:	e9 83 ee ff ff       	jmp    80105d9a <alltraps>

80106f17 <vector216>:
.globl vector216
vector216:
  pushl $0
80106f17:	6a 00                	push   $0x0
  pushl $216
80106f19:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106f1e:	e9 77 ee ff ff       	jmp    80105d9a <alltraps>

80106f23 <vector217>:
.globl vector217
vector217:
  pushl $0
80106f23:	6a 00                	push   $0x0
  pushl $217
80106f25:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106f2a:	e9 6b ee ff ff       	jmp    80105d9a <alltraps>

80106f2f <vector218>:
.globl vector218
vector218:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $218
80106f31:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106f36:	e9 5f ee ff ff       	jmp    80105d9a <alltraps>

80106f3b <vector219>:
.globl vector219
vector219:
  pushl $0
80106f3b:	6a 00                	push   $0x0
  pushl $219
80106f3d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106f42:	e9 53 ee ff ff       	jmp    80105d9a <alltraps>

80106f47 <vector220>:
.globl vector220
vector220:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $220
80106f49:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106f4e:	e9 47 ee ff ff       	jmp    80105d9a <alltraps>

80106f53 <vector221>:
.globl vector221
vector221:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $221
80106f55:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106f5a:	e9 3b ee ff ff       	jmp    80105d9a <alltraps>

80106f5f <vector222>:
.globl vector222
vector222:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $222
80106f61:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106f66:	e9 2f ee ff ff       	jmp    80105d9a <alltraps>

80106f6b <vector223>:
.globl vector223
vector223:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $223
80106f6d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106f72:	e9 23 ee ff ff       	jmp    80105d9a <alltraps>

80106f77 <vector224>:
.globl vector224
vector224:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $224
80106f79:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f7e:	e9 17 ee ff ff       	jmp    80105d9a <alltraps>

80106f83 <vector225>:
.globl vector225
vector225:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $225
80106f85:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106f8a:	e9 0b ee ff ff       	jmp    80105d9a <alltraps>

80106f8f <vector226>:
.globl vector226
vector226:
  pushl $0
80106f8f:	6a 00                	push   $0x0
  pushl $226
80106f91:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106f96:	e9 ff ed ff ff       	jmp    80105d9a <alltraps>

80106f9b <vector227>:
.globl vector227
vector227:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $227
80106f9d:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106fa2:	e9 f3 ed ff ff       	jmp    80105d9a <alltraps>

80106fa7 <vector228>:
.globl vector228
vector228:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $228
80106fa9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106fae:	e9 e7 ed ff ff       	jmp    80105d9a <alltraps>

80106fb3 <vector229>:
.globl vector229
vector229:
  pushl $0
80106fb3:	6a 00                	push   $0x0
  pushl $229
80106fb5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106fba:	e9 db ed ff ff       	jmp    80105d9a <alltraps>

80106fbf <vector230>:
.globl vector230
vector230:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $230
80106fc1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106fc6:	e9 cf ed ff ff       	jmp    80105d9a <alltraps>

80106fcb <vector231>:
.globl vector231
vector231:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $231
80106fcd:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106fd2:	e9 c3 ed ff ff       	jmp    80105d9a <alltraps>

80106fd7 <vector232>:
.globl vector232
vector232:
  pushl $0
80106fd7:	6a 00                	push   $0x0
  pushl $232
80106fd9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106fde:	e9 b7 ed ff ff       	jmp    80105d9a <alltraps>

80106fe3 <vector233>:
.globl vector233
vector233:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $233
80106fe5:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106fea:	e9 ab ed ff ff       	jmp    80105d9a <alltraps>

80106fef <vector234>:
.globl vector234
vector234:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $234
80106ff1:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106ff6:	e9 9f ed ff ff       	jmp    80105d9a <alltraps>

80106ffb <vector235>:
.globl vector235
vector235:
  pushl $0
80106ffb:	6a 00                	push   $0x0
  pushl $235
80106ffd:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107002:	e9 93 ed ff ff       	jmp    80105d9a <alltraps>

80107007 <vector236>:
.globl vector236
vector236:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $236
80107009:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010700e:	e9 87 ed ff ff       	jmp    80105d9a <alltraps>

80107013 <vector237>:
.globl vector237
vector237:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $237
80107015:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010701a:	e9 7b ed ff ff       	jmp    80105d9a <alltraps>

8010701f <vector238>:
.globl vector238
vector238:
  pushl $0
8010701f:	6a 00                	push   $0x0
  pushl $238
80107021:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107026:	e9 6f ed ff ff       	jmp    80105d9a <alltraps>

8010702b <vector239>:
.globl vector239
vector239:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $239
8010702d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107032:	e9 63 ed ff ff       	jmp    80105d9a <alltraps>

80107037 <vector240>:
.globl vector240
vector240:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $240
80107039:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010703e:	e9 57 ed ff ff       	jmp    80105d9a <alltraps>

80107043 <vector241>:
.globl vector241
vector241:
  pushl $0
80107043:	6a 00                	push   $0x0
  pushl $241
80107045:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010704a:	e9 4b ed ff ff       	jmp    80105d9a <alltraps>

8010704f <vector242>:
.globl vector242
vector242:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $242
80107051:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107056:	e9 3f ed ff ff       	jmp    80105d9a <alltraps>

8010705b <vector243>:
.globl vector243
vector243:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $243
8010705d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107062:	e9 33 ed ff ff       	jmp    80105d9a <alltraps>

80107067 <vector244>:
.globl vector244
vector244:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $244
80107069:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010706e:	e9 27 ed ff ff       	jmp    80105d9a <alltraps>

80107073 <vector245>:
.globl vector245
vector245:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $245
80107075:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010707a:	e9 1b ed ff ff       	jmp    80105d9a <alltraps>

8010707f <vector246>:
.globl vector246
vector246:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $246
80107081:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107086:	e9 0f ed ff ff       	jmp    80105d9a <alltraps>

8010708b <vector247>:
.globl vector247
vector247:
  pushl $0
8010708b:	6a 00                	push   $0x0
  pushl $247
8010708d:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107092:	e9 03 ed ff ff       	jmp    80105d9a <alltraps>

80107097 <vector248>:
.globl vector248
vector248:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $248
80107099:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010709e:	e9 f7 ec ff ff       	jmp    80105d9a <alltraps>

801070a3 <vector249>:
.globl vector249
vector249:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $249
801070a5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801070aa:	e9 eb ec ff ff       	jmp    80105d9a <alltraps>

801070af <vector250>:
.globl vector250
vector250:
  pushl $0
801070af:	6a 00                	push   $0x0
  pushl $250
801070b1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801070b6:	e9 df ec ff ff       	jmp    80105d9a <alltraps>

801070bb <vector251>:
.globl vector251
vector251:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $251
801070bd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801070c2:	e9 d3 ec ff ff       	jmp    80105d9a <alltraps>

801070c7 <vector252>:
.globl vector252
vector252:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $252
801070c9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801070ce:	e9 c7 ec ff ff       	jmp    80105d9a <alltraps>

801070d3 <vector253>:
.globl vector253
vector253:
  pushl $0
801070d3:	6a 00                	push   $0x0
  pushl $253
801070d5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801070da:	e9 bb ec ff ff       	jmp    80105d9a <alltraps>

801070df <vector254>:
.globl vector254
vector254:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $254
801070e1:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801070e6:	e9 af ec ff ff       	jmp    80105d9a <alltraps>

801070eb <vector255>:
.globl vector255
vector255:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $255
801070ed:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801070f2:	e9 a3 ec ff ff       	jmp    80105d9a <alltraps>
801070f7:	66 90                	xchg   %ax,%ax
801070f9:	66 90                	xchg   %ax,%ax
801070fb:	66 90                	xchg   %ax,%ax
801070fd:	66 90                	xchg   %ax,%ax
801070ff:	90                   	nop

80107100 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107100:	55                   	push   %ebp
80107101:	89 e5                	mov    %esp,%ebp
80107103:	57                   	push   %edi
80107104:	56                   	push   %esi
80107105:	53                   	push   %ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107106:	89 d3                	mov    %edx,%ebx
{
80107108:	89 d7                	mov    %edx,%edi
  pde = &pgdir[PDX(va)];
8010710a:	c1 eb 16             	shr    $0x16,%ebx
8010710d:	8d 34 98             	lea    (%eax,%ebx,4),%esi
{
80107110:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80107113:	8b 06                	mov    (%esi),%eax
80107115:	a8 01                	test   $0x1,%al
80107117:	74 27                	je     80107140 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107119:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010711e:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80107124:	c1 ef 0a             	shr    $0xa,%edi
}
80107127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
8010712a:	89 fa                	mov    %edi,%edx
8010712c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107132:	8d 04 13             	lea    (%ebx,%edx,1),%eax
}
80107135:	5b                   	pop    %ebx
80107136:	5e                   	pop    %esi
80107137:	5f                   	pop    %edi
80107138:	5d                   	pop    %ebp
80107139:	c3                   	ret    
8010713a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107140:	85 c9                	test   %ecx,%ecx
80107142:	74 2c                	je     80107170 <walkpgdir+0x70>
80107144:	e8 57 b8 ff ff       	call   801029a0 <kalloc>
80107149:	85 c0                	test   %eax,%eax
8010714b:	89 c3                	mov    %eax,%ebx
8010714d:	74 21                	je     80107170 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
8010714f:	83 ec 04             	sub    $0x4,%esp
80107152:	68 00 10 00 00       	push   $0x1000
80107157:	6a 00                	push   $0x0
80107159:	50                   	push   %eax
8010715a:	e8 91 d9 ff ff       	call   80104af0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010715f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107165:	83 c4 10             	add    $0x10,%esp
80107168:	83 c8 07             	or     $0x7,%eax
8010716b:	89 06                	mov    %eax,(%esi)
8010716d:	eb b5                	jmp    80107124 <walkpgdir+0x24>
8010716f:	90                   	nop
}
80107170:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80107173:	31 c0                	xor    %eax,%eax
}
80107175:	5b                   	pop    %ebx
80107176:	5e                   	pop    %esi
80107177:	5f                   	pop    %edi
80107178:	5d                   	pop    %ebp
80107179:	c3                   	ret    
8010717a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107180 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107180:	55                   	push   %ebp
80107181:	89 e5                	mov    %esp,%ebp
80107183:	57                   	push   %edi
80107184:	56                   	push   %esi
80107185:	53                   	push   %ebx
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107186:	89 d3                	mov    %edx,%ebx
80107188:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
{
8010718e:	83 ec 1c             	sub    $0x1c,%esp
80107191:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107194:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
80107198:	8b 7d 08             	mov    0x8(%ebp),%edi
8010719b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap in mappages in vm.c");
    *pte = pa | perm | PTE_P;
801071a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801071a6:	29 df                	sub    %ebx,%edi
801071a8:	83 c8 01             	or     $0x1,%eax
801071ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
801071ae:	eb 15                	jmp    801071c5 <mappages+0x45>
    if(*pte & PTE_P)
801071b0:	f6 00 01             	testb  $0x1,(%eax)
801071b3:	75 45                	jne    801071fa <mappages+0x7a>
    *pte = pa | perm | PTE_P;
801071b5:	0b 75 dc             	or     -0x24(%ebp),%esi
    if(a == last)
801071b8:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
    *pte = pa | perm | PTE_P;
801071bb:	89 30                	mov    %esi,(%eax)
    if(a == last)
801071bd:	74 31                	je     801071f0 <mappages+0x70>
      break;
    a += PGSIZE;
801071bf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801071c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071c8:	b9 01 00 00 00       	mov    $0x1,%ecx
801071cd:	89 da                	mov    %ebx,%edx
801071cf:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
801071d2:	e8 29 ff ff ff       	call   80107100 <walkpgdir>
801071d7:	85 c0                	test   %eax,%eax
801071d9:	75 d5                	jne    801071b0 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
801071db:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801071de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801071e3:	5b                   	pop    %ebx
801071e4:	5e                   	pop    %esi
801071e5:	5f                   	pop    %edi
801071e6:	5d                   	pop    %ebp
801071e7:	c3                   	ret    
801071e8:	90                   	nop
801071e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801071f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801071f3:	31 c0                	xor    %eax,%eax
}
801071f5:	5b                   	pop    %ebx
801071f6:	5e                   	pop    %esi
801071f7:	5f                   	pop    %edi
801071f8:	5d                   	pop    %ebp
801071f9:	c3                   	ret    
      panic("remap in mappages in vm.c");
801071fa:	83 ec 0c             	sub    $0xc,%esp
801071fd:	68 e5 86 10 80       	push   $0x801086e5
80107202:	e8 f9 94 ff ff       	call   80100700 <panic>
80107207:	89 f6                	mov    %esi,%esi
80107209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107210 <deallocuvm.part.0>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
// If the page was swapped free the corresponding disk block.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107210:	55                   	push   %ebp
80107211:	89 e5                	mov    %esp,%ebp
80107213:	57                   	push   %edi
80107214:	56                   	push   %esi
80107215:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107216:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
8010721c:	89 c7                	mov    %eax,%edi
  a = PGROUNDUP(newsz);
8010721e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107224:	83 ec 1c             	sub    $0x1c,%esp
80107227:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010722a:	39 d3                	cmp    %edx,%ebx
8010722c:	73 6b                	jae    80107299 <deallocuvm.part.0+0x89>
8010722e:	89 d6                	mov    %edx,%esi
80107230:	eb 42                	jmp    80107274 <deallocuvm.part.0+0x64>
80107232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);

    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;

    else if(*pte & PTE_SWAPPED){
80107238:	8b 10                	mov    (%eax),%edx
8010723a:	f6 c6 02             	test   $0x2,%dh
8010723d:	75 69                	jne    801072a8 <deallocuvm.part.0+0x98>
        uint block_id= (*pte)>>12;
        bfree_page(ROOTDEV,block_id);
      }

    else if((*pte & PTE_P) != 0){
8010723f:	f6 c2 01             	test   $0x1,%dl
80107242:	74 26                	je     8010726a <deallocuvm.part.0+0x5a>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80107244:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
8010724a:	74 6f                	je     801072bb <deallocuvm.part.0+0xab>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
8010724c:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010724f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v);
80107258:	52                   	push   %edx
80107259:	e8 92 b5 ff ff       	call   801027f0 <kfree>
      *pte = 0;
8010725e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107261:	83 c4 10             	add    $0x10,%esp
80107264:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010726a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107270:	39 f3                	cmp    %esi,%ebx
80107272:	73 25                	jae    80107299 <deallocuvm.part.0+0x89>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107274:	31 c9                	xor    %ecx,%ecx
80107276:	89 da                	mov    %ebx,%edx
80107278:	89 f8                	mov    %edi,%eax
8010727a:	e8 81 fe ff ff       	call   80107100 <walkpgdir>
    if(!pte)
8010727f:	85 c0                	test   %eax,%eax
80107281:	75 b5                	jne    80107238 <deallocuvm.part.0+0x28>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107283:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
80107289:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010728f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107295:	39 f3                	cmp    %esi,%ebx
80107297:	72 db                	jb     80107274 <deallocuvm.part.0+0x64>
    }

  }
  return newsz;
}
80107299:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010729c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010729f:	5b                   	pop    %ebx
801072a0:	5e                   	pop    %esi
801072a1:	5f                   	pop    %edi
801072a2:	5d                   	pop    %ebp
801072a3:	c3                   	ret    
801072a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        bfree_page(ROOTDEV,block_id);
801072a8:	83 ec 08             	sub    $0x8,%esp
        uint block_id= (*pte)>>12;
801072ab:	c1 ea 0c             	shr    $0xc,%edx
        bfree_page(ROOTDEV,block_id);
801072ae:	52                   	push   %edx
801072af:	6a 01                	push   $0x1
801072b1:	e8 fa a5 ff ff       	call   801018b0 <bfree_page>
801072b6:	83 c4 10             	add    $0x10,%esp
801072b9:	eb af                	jmp    8010726a <deallocuvm.part.0+0x5a>
        panic("kfree");
801072bb:	83 ec 0c             	sub    $0xc,%esp
801072be:	68 d7 86 10 80       	push   $0x801086d7
801072c3:	e8 38 94 ff ff       	call   80100700 <panic>
801072c8:	90                   	nop
801072c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801072d0 <seginit>:
{
801072d0:	55                   	push   %ebp
801072d1:	89 e5                	mov    %esp,%ebp
801072d3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801072d6:	e8 c5 c9 ff ff       	call   80103ca0 <cpuid>
801072db:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  pd[0] = size-1;
801072e1:	ba 2f 00 00 00       	mov    $0x2f,%edx
801072e6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801072ea:	c7 80 f8 37 11 80 ff 	movl   $0xffff,-0x7feec808(%eax)
801072f1:	ff 00 00 
801072f4:	c7 80 fc 37 11 80 00 	movl   $0xcf9a00,-0x7feec804(%eax)
801072fb:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801072fe:	c7 80 00 38 11 80 ff 	movl   $0xffff,-0x7feec800(%eax)
80107305:	ff 00 00 
80107308:	c7 80 04 38 11 80 00 	movl   $0xcf9200,-0x7feec7fc(%eax)
8010730f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107312:	c7 80 08 38 11 80 ff 	movl   $0xffff,-0x7feec7f8(%eax)
80107319:	ff 00 00 
8010731c:	c7 80 0c 38 11 80 00 	movl   $0xcffa00,-0x7feec7f4(%eax)
80107323:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107326:	c7 80 10 38 11 80 ff 	movl   $0xffff,-0x7feec7f0(%eax)
8010732d:	ff 00 00 
80107330:	c7 80 14 38 11 80 00 	movl   $0xcff200,-0x7feec7ec(%eax)
80107337:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010733a:	05 f0 37 11 80       	add    $0x801137f0,%eax
  pd[1] = (uint)p;
8010733f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107343:	c1 e8 10             	shr    $0x10,%eax
80107346:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010734a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010734d:	0f 01 10             	lgdtl  (%eax)
}
80107350:	c9                   	leave  
80107351:	c3                   	ret    
80107352:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107359:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107360 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107360:	a1 e4 67 11 80       	mov    0x801167e4,%eax
{
80107365:	55                   	push   %ebp
80107366:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107368:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010736d:	0f 22 d8             	mov    %eax,%cr3
}
80107370:	5d                   	pop    %ebp
80107371:	c3                   	ret    
80107372:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107379:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107380 <switchuvm>:
{
80107380:	55                   	push   %ebp
80107381:	89 e5                	mov    %esp,%ebp
80107383:	57                   	push   %edi
80107384:	56                   	push   %esi
80107385:	53                   	push   %ebx
80107386:	83 ec 1c             	sub    $0x1c,%esp
80107389:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(p == 0)
8010738c:	85 db                	test   %ebx,%ebx
8010738e:	0f 84 cb 00 00 00    	je     8010745f <switchuvm+0xdf>
  if(p->kstack == 0)
80107394:	8b 43 08             	mov    0x8(%ebx),%eax
80107397:	85 c0                	test   %eax,%eax
80107399:	0f 84 da 00 00 00    	je     80107479 <switchuvm+0xf9>
  if(p->pgdir == 0)
8010739f:	8b 43 04             	mov    0x4(%ebx),%eax
801073a2:	85 c0                	test   %eax,%eax
801073a4:	0f 84 c2 00 00 00    	je     8010746c <switchuvm+0xec>
  pushcli();
801073aa:	e8 81 d5 ff ff       	call   80104930 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801073af:	e8 6c c8 ff ff       	call   80103c20 <mycpu>
801073b4:	89 c6                	mov    %eax,%esi
801073b6:	e8 65 c8 ff ff       	call   80103c20 <mycpu>
801073bb:	89 c7                	mov    %eax,%edi
801073bd:	e8 5e c8 ff ff       	call   80103c20 <mycpu>
801073c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801073c5:	83 c7 08             	add    $0x8,%edi
801073c8:	e8 53 c8 ff ff       	call   80103c20 <mycpu>
801073cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801073d0:	83 c0 08             	add    $0x8,%eax
801073d3:	ba 67 00 00 00       	mov    $0x67,%edx
801073d8:	c1 e8 18             	shr    $0x18,%eax
801073db:	66 89 96 98 00 00 00 	mov    %dx,0x98(%esi)
801073e2:	66 89 be 9a 00 00 00 	mov    %di,0x9a(%esi)
801073e9:	88 86 9f 00 00 00    	mov    %al,0x9f(%esi)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801073ef:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801073f4:	83 c1 08             	add    $0x8,%ecx
801073f7:	c1 e9 10             	shr    $0x10,%ecx
801073fa:	88 8e 9c 00 00 00    	mov    %cl,0x9c(%esi)
80107400:	b9 99 40 00 00       	mov    $0x4099,%ecx
80107405:	66 89 8e 9d 00 00 00 	mov    %cx,0x9d(%esi)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010740c:	be 10 00 00 00       	mov    $0x10,%esi
  mycpu()->gdt[SEG_TSS].s = 0;
80107411:	e8 0a c8 ff ff       	call   80103c20 <mycpu>
80107416:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010741d:	e8 fe c7 ff ff       	call   80103c20 <mycpu>
80107422:	66 89 70 10          	mov    %si,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107426:	8b 73 08             	mov    0x8(%ebx),%esi
80107429:	e8 f2 c7 ff ff       	call   80103c20 <mycpu>
8010742e:	81 c6 00 10 00 00    	add    $0x1000,%esi
80107434:	89 70 0c             	mov    %esi,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107437:	e8 e4 c7 ff ff       	call   80103c20 <mycpu>
8010743c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107440:	b8 28 00 00 00       	mov    $0x28,%eax
80107445:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80107448:	8b 43 04             	mov    0x4(%ebx),%eax
8010744b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107450:	0f 22 d8             	mov    %eax,%cr3
}
80107453:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107456:	5b                   	pop    %ebx
80107457:	5e                   	pop    %esi
80107458:	5f                   	pop    %edi
80107459:	5d                   	pop    %ebp
  popcli();
8010745a:	e9 d1 d5 ff ff       	jmp    80104a30 <popcli>
    panic("switchuvm: no process");
8010745f:	83 ec 0c             	sub    $0xc,%esp
80107462:	68 ff 86 10 80       	push   $0x801086ff
80107467:	e8 94 92 ff ff       	call   80100700 <panic>
    panic("switchuvm: no pgdir");
8010746c:	83 ec 0c             	sub    $0xc,%esp
8010746f:	68 2a 87 10 80       	push   $0x8010872a
80107474:	e8 87 92 ff ff       	call   80100700 <panic>
    panic("switchuvm: no kstack");
80107479:	83 ec 0c             	sub    $0xc,%esp
8010747c:	68 15 87 10 80       	push   $0x80108715
80107481:	e8 7a 92 ff ff       	call   80100700 <panic>
80107486:	8d 76 00             	lea    0x0(%esi),%esi
80107489:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107490 <inituvm>:
{
80107490:	55                   	push   %ebp
80107491:	89 e5                	mov    %esp,%ebp
80107493:	57                   	push   %edi
80107494:	56                   	push   %esi
80107495:	53                   	push   %ebx
80107496:	83 ec 1c             	sub    $0x1c,%esp
80107499:	8b 75 10             	mov    0x10(%ebp),%esi
8010749c:	8b 45 08             	mov    0x8(%ebp),%eax
8010749f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
801074a2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
{
801074a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
801074ab:	77 49                	ja     801074f6 <inituvm+0x66>
  mem = kalloc();
801074ad:	e8 ee b4 ff ff       	call   801029a0 <kalloc>
  memset(mem, 0, PGSIZE);
801074b2:	83 ec 04             	sub    $0x4,%esp
  mem = kalloc();
801074b5:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801074b7:	68 00 10 00 00       	push   $0x1000
801074bc:	6a 00                	push   $0x0
801074be:	50                   	push   %eax
801074bf:	e8 2c d6 ff ff       	call   80104af0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801074c4:	58                   	pop    %eax
801074c5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801074cb:	b9 00 10 00 00       	mov    $0x1000,%ecx
801074d0:	5a                   	pop    %edx
801074d1:	6a 06                	push   $0x6
801074d3:	50                   	push   %eax
801074d4:	31 d2                	xor    %edx,%edx
801074d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801074d9:	e8 a2 fc ff ff       	call   80107180 <mappages>
  memmove(mem, init, sz);
801074de:	89 75 10             	mov    %esi,0x10(%ebp)
801074e1:	89 7d 0c             	mov    %edi,0xc(%ebp)
801074e4:	83 c4 10             	add    $0x10,%esp
801074e7:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801074ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074ed:	5b                   	pop    %ebx
801074ee:	5e                   	pop    %esi
801074ef:	5f                   	pop    %edi
801074f0:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801074f1:	e9 aa d6 ff ff       	jmp    80104ba0 <memmove>
    panic("inituvm: more than a page");
801074f6:	83 ec 0c             	sub    $0xc,%esp
801074f9:	68 3e 87 10 80       	push   $0x8010873e
801074fe:	e8 fd 91 ff ff       	call   80100700 <panic>
80107503:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107509:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107510 <loaduvm>:
{
80107510:	55                   	push   %ebp
80107511:	89 e5                	mov    %esp,%ebp
80107513:	57                   	push   %edi
80107514:	56                   	push   %esi
80107515:	53                   	push   %ebx
80107516:	83 ec 0c             	sub    $0xc,%esp
  if((uint) addr % PGSIZE != 0)
80107519:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80107520:	0f 85 91 00 00 00    	jne    801075b7 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80107526:	8b 75 18             	mov    0x18(%ebp),%esi
80107529:	31 db                	xor    %ebx,%ebx
8010752b:	85 f6                	test   %esi,%esi
8010752d:	75 1a                	jne    80107549 <loaduvm+0x39>
8010752f:	eb 6f                	jmp    801075a0 <loaduvm+0x90>
80107531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107538:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010753e:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80107544:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80107547:	76 57                	jbe    801075a0 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107549:	8b 55 0c             	mov    0xc(%ebp),%edx
8010754c:	8b 45 08             	mov    0x8(%ebp),%eax
8010754f:	31 c9                	xor    %ecx,%ecx
80107551:	01 da                	add    %ebx,%edx
80107553:	e8 a8 fb ff ff       	call   80107100 <walkpgdir>
80107558:	85 c0                	test   %eax,%eax
8010755a:	74 4e                	je     801075aa <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
8010755c:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010755e:	8b 4d 14             	mov    0x14(%ebp),%ecx
    if(sz - i < PGSIZE)
80107561:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107566:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010756b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107571:	0f 46 fe             	cmovbe %esi,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107574:	01 d9                	add    %ebx,%ecx
80107576:	05 00 00 00 80       	add    $0x80000000,%eax
8010757b:	57                   	push   %edi
8010757c:	51                   	push   %ecx
8010757d:	50                   	push   %eax
8010757e:	ff 75 10             	pushl  0x10(%ebp)
80107581:	e8 3a a8 ff ff       	call   80101dc0 <readi>
80107586:	83 c4 10             	add    $0x10,%esp
80107589:	39 f8                	cmp    %edi,%eax
8010758b:	74 ab                	je     80107538 <loaduvm+0x28>
}
8010758d:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107595:	5b                   	pop    %ebx
80107596:	5e                   	pop    %esi
80107597:	5f                   	pop    %edi
80107598:	5d                   	pop    %ebp
80107599:	c3                   	ret    
8010759a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801075a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801075a3:	31 c0                	xor    %eax,%eax
}
801075a5:	5b                   	pop    %ebx
801075a6:	5e                   	pop    %esi
801075a7:	5f                   	pop    %edi
801075a8:	5d                   	pop    %ebp
801075a9:	c3                   	ret    
      panic("loaduvm: address should exist");
801075aa:	83 ec 0c             	sub    $0xc,%esp
801075ad:	68 58 87 10 80       	push   $0x80108758
801075b2:	e8 49 91 ff ff       	call   80100700 <panic>
    panic("loaduvm: addr must be page aligned");
801075b7:	83 ec 0c             	sub    $0xc,%esp
801075ba:	68 c0 87 10 80       	push   $0x801087c0
801075bf:	e8 3c 91 ff ff       	call   80100700 <panic>
801075c4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801075ca:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

801075d0 <allocuvm>:
{
801075d0:	55                   	push   %ebp
801075d1:	89 e5                	mov    %esp,%ebp
801075d3:	57                   	push   %edi
801075d4:	56                   	push   %esi
801075d5:	53                   	push   %ebx
801075d6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
801075d9:	8b 7d 10             	mov    0x10(%ebp),%edi
801075dc:	85 ff                	test   %edi,%edi
801075de:	78 76                	js     80107656 <allocuvm+0x86>
  if(newsz < oldsz)
801075e0:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801075e3:	0f 82 7f 00 00 00    	jb     80107668 <allocuvm+0x98>
  a = PGROUNDUP(oldsz);
801075e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801075ec:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801075f2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801075f8:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801075fb:	76 6e                	jbe    8010766b <allocuvm+0x9b>
801075fd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80107600:	8b 7d 08             	mov    0x8(%ebp),%edi
80107603:	eb 3e                	jmp    80107643 <allocuvm+0x73>
80107605:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
80107608:	83 ec 04             	sub    $0x4,%esp
8010760b:	68 00 10 00 00       	push   $0x1000
80107610:	6a 00                	push   $0x0
80107612:	50                   	push   %eax
80107613:	e8 d8 d4 ff ff       	call   80104af0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107618:	58                   	pop    %eax
80107619:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
8010761f:	b9 00 10 00 00       	mov    $0x1000,%ecx
80107624:	5a                   	pop    %edx
80107625:	6a 06                	push   $0x6
80107627:	50                   	push   %eax
80107628:	89 da                	mov    %ebx,%edx
8010762a:	89 f8                	mov    %edi,%eax
8010762c:	e8 4f fb ff ff       	call   80107180 <mappages>
80107631:	83 c4 10             	add    $0x10,%esp
80107634:	85 c0                	test   %eax,%eax
80107636:	78 40                	js     80107678 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80107638:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010763e:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80107641:	76 65                	jbe    801076a8 <allocuvm+0xd8>
    mem = kalloc();
80107643:	e8 58 b3 ff ff       	call   801029a0 <kalloc>
    if(mem == 0){
80107648:	85 c0                	test   %eax,%eax
    mem = kalloc();
8010764a:	89 c6                	mov    %eax,%esi
    if(mem == 0){
8010764c:	75 ba                	jne    80107608 <allocuvm+0x38>
  if(newsz >= oldsz)
8010764e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107651:	39 45 10             	cmp    %eax,0x10(%ebp)
80107654:	77 62                	ja     801076b8 <allocuvm+0xe8>
}
80107656:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107659:	31 ff                	xor    %edi,%edi
}
8010765b:	89 f8                	mov    %edi,%eax
8010765d:	5b                   	pop    %ebx
8010765e:	5e                   	pop    %esi
8010765f:	5f                   	pop    %edi
80107660:	5d                   	pop    %ebp
80107661:	c3                   	ret    
80107662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return oldsz;
80107668:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
8010766b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010766e:	89 f8                	mov    %edi,%eax
80107670:	5b                   	pop    %ebx
80107671:	5e                   	pop    %esi
80107672:	5f                   	pop    %edi
80107673:	5d                   	pop    %ebp
80107674:	c3                   	ret    
80107675:	8d 76 00             	lea    0x0(%esi),%esi
  if(newsz >= oldsz)
80107678:	8b 45 0c             	mov    0xc(%ebp),%eax
8010767b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010767e:	76 0d                	jbe    8010768d <allocuvm+0xbd>
80107680:	89 c1                	mov    %eax,%ecx
80107682:	8b 55 10             	mov    0x10(%ebp),%edx
80107685:	8b 45 08             	mov    0x8(%ebp),%eax
80107688:	e8 83 fb ff ff       	call   80107210 <deallocuvm.part.0>
      kfree(mem);
8010768d:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107690:	31 ff                	xor    %edi,%edi
      kfree(mem);
80107692:	56                   	push   %esi
80107693:	e8 58 b1 ff ff       	call   801027f0 <kfree>
      return 0;
80107698:	83 c4 10             	add    $0x10,%esp
}
8010769b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010769e:	89 f8                	mov    %edi,%eax
801076a0:	5b                   	pop    %ebx
801076a1:	5e                   	pop    %esi
801076a2:	5f                   	pop    %edi
801076a3:	5d                   	pop    %ebp
801076a4:	c3                   	ret    
801076a5:	8d 76 00             	lea    0x0(%esi),%esi
801076a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801076ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801076ae:	5b                   	pop    %ebx
801076af:	89 f8                	mov    %edi,%eax
801076b1:	5e                   	pop    %esi
801076b2:	5f                   	pop    %edi
801076b3:	5d                   	pop    %ebp
801076b4:	c3                   	ret    
801076b5:	8d 76 00             	lea    0x0(%esi),%esi
801076b8:	89 c1                	mov    %eax,%ecx
801076ba:	8b 55 10             	mov    0x10(%ebp),%edx
801076bd:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
801076c0:	31 ff                	xor    %edi,%edi
801076c2:	e8 49 fb ff ff       	call   80107210 <deallocuvm.part.0>
801076c7:	eb a2                	jmp    8010766b <allocuvm+0x9b>
801076c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801076d0 <deallocuvm>:
{
801076d0:	55                   	push   %ebp
801076d1:	89 e5                	mov    %esp,%ebp
801076d3:	8b 55 0c             	mov    0xc(%ebp),%edx
801076d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801076d9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
801076dc:	39 d1                	cmp    %edx,%ecx
801076de:	73 10                	jae    801076f0 <deallocuvm+0x20>
}
801076e0:	5d                   	pop    %ebp
801076e1:	e9 2a fb ff ff       	jmp    80107210 <deallocuvm.part.0>
801076e6:	8d 76 00             	lea    0x0(%esi),%esi
801076e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
801076f0:	89 d0                	mov    %edx,%eax
801076f2:	5d                   	pop    %ebp
801076f3:	c3                   	ret    
801076f4:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801076fa:	8d bf 00 00 00 00    	lea    0x0(%edi),%edi

80107700 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107700:	55                   	push   %ebp
80107701:	89 e5                	mov    %esp,%ebp
80107703:	57                   	push   %edi
80107704:	56                   	push   %esi
80107705:	53                   	push   %ebx
80107706:	83 ec 0c             	sub    $0xc,%esp
80107709:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010770c:	85 f6                	test   %esi,%esi
8010770e:	74 59                	je     80107769 <freevm+0x69>
80107710:	31 c9                	xor    %ecx,%ecx
80107712:	ba 00 00 00 80       	mov    $0x80000000,%edx
80107717:	89 f0                	mov    %esi,%eax
80107719:	e8 f2 fa ff ff       	call   80107210 <deallocuvm.part.0>
8010771e:	89 f3                	mov    %esi,%ebx
80107720:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107726:	eb 0f                	jmp    80107737 <freevm+0x37>
80107728:	90                   	nop
80107729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107730:	83 c3 04             	add    $0x4,%ebx
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107733:	39 fb                	cmp    %edi,%ebx
80107735:	74 23                	je     8010775a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107737:	8b 03                	mov    (%ebx),%eax
80107739:	a8 01                	test   $0x1,%al
8010773b:	74 f3                	je     80107730 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010773d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107742:	83 ec 0c             	sub    $0xc,%esp
80107745:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107748:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010774d:	50                   	push   %eax
8010774e:	e8 9d b0 ff ff       	call   801027f0 <kfree>
80107753:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107756:	39 fb                	cmp    %edi,%ebx
80107758:	75 dd                	jne    80107737 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010775a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010775d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107760:	5b                   	pop    %ebx
80107761:	5e                   	pop    %esi
80107762:	5f                   	pop    %edi
80107763:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107764:	e9 87 b0 ff ff       	jmp    801027f0 <kfree>
    panic("freevm: no pgdir");
80107769:	83 ec 0c             	sub    $0xc,%esp
8010776c:	68 76 87 10 80       	push   $0x80108776
80107771:	e8 8a 8f ff ff       	call   80100700 <panic>
80107776:	8d 76 00             	lea    0x0(%esi),%esi
80107779:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107780 <setupkvm>:
{
80107780:	55                   	push   %ebp
80107781:	89 e5                	mov    %esp,%ebp
80107783:	56                   	push   %esi
80107784:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107785:	e8 16 b2 ff ff       	call   801029a0 <kalloc>
8010778a:	85 c0                	test   %eax,%eax
8010778c:	89 c6                	mov    %eax,%esi
8010778e:	74 42                	je     801077d2 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80107790:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107793:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107798:	68 00 10 00 00       	push   $0x1000
8010779d:	6a 00                	push   $0x0
8010779f:	50                   	push   %eax
801077a0:	e8 4b d3 ff ff       	call   80104af0 <memset>
801077a5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
801077a8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801077ab:	8b 4b 08             	mov    0x8(%ebx),%ecx
801077ae:	83 ec 08             	sub    $0x8,%esp
801077b1:	8b 13                	mov    (%ebx),%edx
801077b3:	ff 73 0c             	pushl  0xc(%ebx)
801077b6:	50                   	push   %eax
801077b7:	29 c1                	sub    %eax,%ecx
801077b9:	89 f0                	mov    %esi,%eax
801077bb:	e8 c0 f9 ff ff       	call   80107180 <mappages>
801077c0:	83 c4 10             	add    $0x10,%esp
801077c3:	85 c0                	test   %eax,%eax
801077c5:	78 19                	js     801077e0 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801077c7:	83 c3 10             	add    $0x10,%ebx
801077ca:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
801077d0:	75 d6                	jne    801077a8 <setupkvm+0x28>
}
801077d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801077d5:	89 f0                	mov    %esi,%eax
801077d7:	5b                   	pop    %ebx
801077d8:	5e                   	pop    %esi
801077d9:	5d                   	pop    %ebp
801077da:	c3                   	ret    
801077db:	90                   	nop
801077dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      freevm(pgdir);
801077e0:	83 ec 0c             	sub    $0xc,%esp
801077e3:	56                   	push   %esi
      return 0;
801077e4:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
801077e6:	e8 15 ff ff ff       	call   80107700 <freevm>
      return 0;
801077eb:	83 c4 10             	add    $0x10,%esp
}
801077ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
801077f1:	89 f0                	mov    %esi,%eax
801077f3:	5b                   	pop    %ebx
801077f4:	5e                   	pop    %esi
801077f5:	5d                   	pop    %ebp
801077f6:	c3                   	ret    
801077f7:	89 f6                	mov    %esi,%esi
801077f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

80107800 <kvmalloc>:
{
80107800:	55                   	push   %ebp
80107801:	89 e5                	mov    %esp,%ebp
80107803:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107806:	e8 75 ff ff ff       	call   80107780 <setupkvm>
8010780b:	a3 e4 67 11 80       	mov    %eax,0x801167e4
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107810:	05 00 00 00 80       	add    $0x80000000,%eax
80107815:	0f 22 d8             	mov    %eax,%cr3
}
80107818:	c9                   	leave  
80107819:	c3                   	ret    
8010781a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107820 <select_a_victim>:
ii) if (i) is unable to find any such page, randomly reset access bit
    of 10% of the allocated pages and call select_a_victim() again
*/

pte_t* select_a_victim(pde_t *pgdir)
{
80107820:	55                   	push   %ebp
80107821:	89 e5                	mov    %esp,%ebp
80107823:	56                   	push   %esi
80107824:	53                   	push   %ebx
80107825:	8b 75 08             	mov    0x8(%ebp),%esi
  pte_t *pte;
  for(long i=4096; i<KERNBASE;i+=PGSIZE)
80107828:	bb 00 10 00 00       	mov    $0x1000,%ebx
8010782d:	eb 13                	jmp    80107842 <select_a_victim+0x22>
8010782f:	90                   	nop
  {    //for all pages in the user virtual space
    if((pte=walkpgdir(pgdir,(char*)i,0))!= 0) //if mapping exists 
		  {  
           if(*pte & PTE_P)
80107830:	8b 10                	mov    (%eax),%edx
80107832:	f6 c2 01             	test   $0x1,%dl
80107835:	74 05                	je     8010783c <select_a_victim+0x1c>
           {   
                if(*pte & ~PTE_A)      //access bit not set.
80107837:	83 e2 df             	and    $0xffffffdf,%edx
8010783a:	75 2c                	jne    80107868 <select_a_victim+0x48>
  for(long i=4096; i<KERNBASE;i+=PGSIZE)
8010783c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if((pte=walkpgdir(pgdir,(char*)i,0))!= 0) //if mapping exists 
80107842:	31 c9                	xor    %ecx,%ecx
80107844:	89 da                	mov    %ebx,%edx
80107846:	89 f0                	mov    %esi,%eax
80107848:	e8 b3 f8 ff ff       	call   80107100 <walkpgdir>
8010784d:	85 c0                	test   %eax,%eax
8010784f:	75 df                	jne    80107830 <select_a_victim+0x10>
                }
           }
      }
      else
      {
        cprintf("walkpgdir failed \n ");
80107851:	83 ec 0c             	sub    $0xc,%esp
80107854:	68 87 87 10 80       	push   $0x80108787
80107859:	e8 72 91 ff ff       	call   801009d0 <cprintf>
8010785e:	83 c4 10             	add    $0x10,%esp
80107861:	eb d9                	jmp    8010783c <select_a_victim+0x1c>
80107863:	90                   	nop
80107864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      }
	}
  return 0;
}
80107868:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010786b:	5b                   	pop    %ebx
8010786c:	5e                   	pop    %esi
8010786d:	5d                   	pop    %ebp
8010786e:	c3                   	ret    
8010786f:	90                   	nop

80107870 <clearaccessbit>:

// Clear access bit of a random pte.
void clearaccessbit(pde_t *pgdir)
{
80107870:	55                   	push   %ebp
80107871:	89 e5                	mov    %esp,%ebp
80107873:	56                   	push   %esi
80107874:	53                   	push   %ebx
80107875:	8b 75 08             	mov    0x8(%ebp),%esi
  pte_t *pte;
  int cnt=0;
  for(long i=4096;i<KERNBASE;i+=PGSIZE)
80107878:	bb 00 10 00 00       	mov    $0x1000,%ebx
8010787d:	8d 76 00             	lea    0x0(%esi),%esi
  {
      if((pte=walkpgdir(pgdir,(char*)i,0))!= 0)
80107880:	89 da                	mov    %ebx,%edx
80107882:	31 c9                	xor    %ecx,%ecx
80107884:	89 f0                	mov    %esi,%eax
80107886:	e8 75 f8 ff ff       	call   80107100 <walkpgdir>
  for(long i=4096;i<KERNBASE;i+=PGSIZE)
8010788b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107891:	eb ed                	jmp    80107880 <clearaccessbit+0x10>
80107893:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107899:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi

801078a0 <getswappedblk>:

// return the disk block-id, if the virtual address
// was swapped, -1 otherwise.
int
getswappedblk(pde_t *pgdir, uint va)
{
801078a0:	55                   	push   %ebp
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
801078a1:	31 c9                	xor    %ecx,%ecx
{
801078a3:	89 e5                	mov    %esp,%ebp
801078a5:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
801078a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801078ab:	8b 45 08             	mov    0x8(%ebp),%eax
801078ae:	e8 4d f8 ff ff       	call   80107100 <walkpgdir>
  int block_id= (*pte)>>12;
801078b3:	8b 00                	mov    (%eax),%eax
  return block_id;
}
801078b5:	c9                   	leave  
  int block_id= (*pte)>>12;
801078b6:	c1 e8 0c             	shr    $0xc,%eax
}
801078b9:	c3                   	ret    
801078ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801078c0 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801078c0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801078c1:	31 c9                	xor    %ecx,%ecx
{
801078c3:	89 e5                	mov    %esp,%ebp
801078c5:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
801078c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	e8 2d f8 ff ff       	call   80107100 <walkpgdir>
  if(pte == 0)
801078d3:	85 c0                	test   %eax,%eax
801078d5:	74 05                	je     801078dc <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
801078d7:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801078da:	c9                   	leave  
801078db:	c3                   	ret    
    panic("clearpteu");
801078dc:	83 ec 0c             	sub    $0xc,%esp
801078df:	68 9b 87 10 80       	push   $0x8010879b
801078e4:	e8 17 8e ff ff       	call   80100700 <panic>
801078e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801078f0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz,int pid)
{
801078f0:	55                   	push   %ebp
801078f1:	89 e5                	mov    %esp,%ebp
801078f3:	57                   	push   %edi
801078f4:	56                   	push   %esi
801078f5:	53                   	push   %ebx
801078f6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
  if((d = setupkvm()) == 0)
801078f9:	e8 82 fe ff ff       	call   80107780 <setupkvm>
801078fe:	85 c0                	test   %eax,%eax
80107900:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107903:	0f 84 5c 01 00 00    	je     80107a65 <copyuvm+0x175>
    return 0;

  for(i = 0; i < sz; i += PGSIZE){
80107909:	8b 75 0c             	mov    0xc(%ebp),%esi
8010790c:	85 f6                	test   %esi,%esi
8010790e:	0f 84 51 01 00 00    	je     80107a65 <copyuvm+0x175>
      int blockid=getswappedblk(pgdir,i);      //disk id where the page was swapped
      read_page_from_disk(ROOTDEV,mem,blockid);

      *pte=V2P(mem) | PTE_W | PTE_U | PTE_P;
      *pte &= ~PTE_SWAPPED;
      lcr3(V2P(pgdir));
80107914:	8b 45 08             	mov    0x8(%ebp),%eax
  for(i = 0; i < sz; i += PGSIZE){
80107917:	31 f6                	xor    %esi,%esi
      lcr3(V2P(pgdir));
80107919:	05 00 00 00 80       	add    $0x80000000,%eax
8010791e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80107921:	eb 70                	jmp    80107993 <copyuvm+0xa3>
80107923:	90                   	nop
80107924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

      bfree_page(ROOTDEV,blockid);
    }

    pa = PTE_ADDR(*pte);
80107928:	89 df                	mov    %ebx,%edi
    flags = PTE_FLAGS(*pte);
8010792a:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    if((mem = kalloc()) == 0)
80107930:	e8 6b b0 ff ff       	call   801029a0 <kalloc>
    pa = PTE_ADDR(*pte);
80107935:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
8010793b:	85 c0                	test   %eax,%eax
8010793d:	89 c2                	mov    %eax,%edx
8010793f:	0f 84 cb 00 00 00    	je     80107a10 <copyuvm+0x120>
      mem=kalloc();
      if(mem==0)
        cprintf("unable to get memory in copyuvm");
    }

    memmove(mem, (char*)P2V(pa), PGSIZE);
80107945:	83 ec 04             	sub    $0x4,%esp
80107948:	81 c7 00 00 00 80    	add    $0x80000000,%edi
8010794e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80107951:	68 00 10 00 00       	push   $0x1000
80107956:	57                   	push   %edi
80107957:	52                   	push   %edx
80107958:	e8 43 d2 ff ff       	call   80104ba0 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
8010795d:	58                   	pop    %eax
8010795e:	5a                   	pop    %edx
8010795f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107962:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107965:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010796a:	53                   	push   %ebx
8010796b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80107971:	52                   	push   %edx
80107972:	89 f2                	mov    %esi,%edx
80107974:	e8 07 f8 ff ff       	call   80107180 <mappages>
80107979:	83 c4 10             	add    $0x10,%esp
8010797c:	85 c0                	test   %eax,%eax
8010797e:	0f 88 cc 00 00 00    	js     80107a50 <copyuvm+0x160>
  for(i = 0; i < sz; i += PGSIZE){
80107984:	81 c6 00 10 00 00    	add    $0x1000,%esi
8010798a:	39 75 0c             	cmp    %esi,0xc(%ebp)
8010798d:	0f 86 d2 00 00 00    	jbe    80107a65 <copyuvm+0x175>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107993:	8b 45 08             	mov    0x8(%ebp),%eax
80107996:	31 c9                	xor    %ecx,%ecx
80107998:	89 f2                	mov    %esi,%edx
8010799a:	e8 61 f7 ff ff       	call   80107100 <walkpgdir>
8010799f:	85 c0                	test   %eax,%eax
801079a1:	89 c7                	mov    %eax,%edi
801079a3:	0f 84 e4 00 00 00    	je     80107a8d <copyuvm+0x19d>
    if(*pte & PTE_SWAPPED){
801079a9:	8b 18                	mov    (%eax),%ebx
801079ab:	f6 c7 02             	test   $0x2,%bh
801079ae:	0f 84 74 ff ff ff    	je     80107928 <copyuvm+0x38>
      if((mem = kalloc()) == 0)
801079b4:	e8 e7 af ff ff       	call   801029a0 <kalloc>
801079b9:	85 c0                	test   %eax,%eax
801079bb:	89 c3                	mov    %eax,%ebx
801079bd:	0f 84 ad 00 00 00    	je     80107a70 <copyuvm+0x180>
  pte_t *pte= walkpgdir(pgdir,(char*)va,0);
801079c3:	8b 45 08             	mov    0x8(%ebp),%eax
801079c6:	31 c9                	xor    %ecx,%ecx
801079c8:	89 f2                	mov    %esi,%edx
801079ca:	e8 31 f7 ff ff       	call   80107100 <walkpgdir>
  int block_id= (*pte)>>12;
801079cf:	8b 00                	mov    (%eax),%eax
      read_page_from_disk(ROOTDEV,mem,blockid);
801079d1:	83 ec 04             	sub    $0x4,%esp
  int block_id= (*pte)>>12;
801079d4:	c1 e8 0c             	shr    $0xc,%eax
      read_page_from_disk(ROOTDEV,mem,blockid);
801079d7:	50                   	push   %eax
801079d8:	53                   	push   %ebx
      *pte=V2P(mem) | PTE_W | PTE_U | PTE_P;
801079d9:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
      read_page_from_disk(ROOTDEV,mem,blockid);
801079df:	6a 01                	push   $0x1
      *pte &= ~PTE_SWAPPED;
801079e1:	80 e7 fd             	and    $0xfd,%bh
      read_page_from_disk(ROOTDEV,mem,blockid);
801079e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      *pte &= ~PTE_SWAPPED;
801079e7:	83 cb 07             	or     $0x7,%ebx
      read_page_from_disk(ROOTDEV,mem,blockid);
801079ea:	e8 01 8b ff ff       	call   801004f0 <read_page_from_disk>
      *pte &= ~PTE_SWAPPED;
801079ef:	89 1f                	mov    %ebx,(%edi)
801079f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801079f4:	0f 22 d8             	mov    %eax,%cr3
      bfree_page(ROOTDEV,blockid);
801079f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801079fa:	59                   	pop    %ecx
801079fb:	5b                   	pop    %ebx
801079fc:	50                   	push   %eax
801079fd:	6a 01                	push   $0x1
801079ff:	e8 ac 9e ff ff       	call   801018b0 <bfree_page>
80107a04:	8b 1f                	mov    (%edi),%ebx
80107a06:	83 c4 10             	add    $0x10,%esp
80107a09:	e9 1a ff ff ff       	jmp    80107928 <copyuvm+0x38>
80107a0e:	66 90                	xchg   %ax,%ax
      swap_page(pgdir,pid);
80107a10:	83 ec 08             	sub    $0x8,%esp
80107a13:	ff 75 10             	pushl  0x10(%ebp)
80107a16:	ff 75 08             	pushl  0x8(%ebp)
80107a19:	e8 f2 e7 ff ff       	call   80106210 <swap_page>
      mem=kalloc();
80107a1e:	e8 7d af ff ff       	call   801029a0 <kalloc>
      if(mem==0)
80107a23:	83 c4 10             	add    $0x10,%esp
80107a26:	85 c0                	test   %eax,%eax
      mem=kalloc();
80107a28:	89 c2                	mov    %eax,%edx
      if(mem==0)
80107a2a:	0f 85 15 ff ff ff    	jne    80107945 <copyuvm+0x55>
        cprintf("unable to get memory in copyuvm");
80107a30:	83 ec 0c             	sub    $0xc,%esp
80107a33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107a36:	68 e4 87 10 80       	push   $0x801087e4
80107a3b:	e8 90 8f ff ff       	call   801009d0 <cprintf>
80107a40:	83 c4 10             	add    $0x10,%esp
80107a43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a46:	e9 fa fe ff ff       	jmp    80107945 <copyuvm+0x55>
80107a4b:	90                   	nop
80107a4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      goto bad;
}
  return d;

bad:
  freevm(d);
80107a50:	83 ec 0c             	sub    $0xc,%esp
80107a53:	ff 75 e0             	pushl  -0x20(%ebp)
80107a56:	e8 a5 fc ff ff       	call   80107700 <freevm>
  return 0;
80107a5b:	83 c4 10             	add    $0x10,%esp
80107a5e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
}
80107a65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a6b:	5b                   	pop    %ebx
80107a6c:	5e                   	pop    %esi
80107a6d:	5f                   	pop    %edi
80107a6e:	5d                   	pop    %ebp
80107a6f:	c3                   	ret    
        swap_page(pgdir,pid);
80107a70:	83 ec 08             	sub    $0x8,%esp
80107a73:	ff 75 10             	pushl  0x10(%ebp)
80107a76:	ff 75 08             	pushl  0x8(%ebp)
80107a79:	e8 92 e7 ff ff       	call   80106210 <swap_page>
        mem=kalloc();
80107a7e:	e8 1d af ff ff       	call   801029a0 <kalloc>
80107a83:	83 c4 10             	add    $0x10,%esp
80107a86:	89 c3                	mov    %eax,%ebx
80107a88:	e9 36 ff ff ff       	jmp    801079c3 <copyuvm+0xd3>
      panic("copyuvm: pte should exist");
80107a8d:	83 ec 0c             	sub    $0xc,%esp
80107a90:	68 a5 87 10 80       	push   $0x801087a5
80107a95:	e8 66 8c ff ff       	call   80100700 <panic>
80107a9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107aa0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107aa0:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107aa1:	31 c9                	xor    %ecx,%ecx
{
80107aa3:	89 e5                	mov    %esp,%ebp
80107aa5:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80107aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
80107aab:	8b 45 08             	mov    0x8(%ebp),%eax
80107aae:	e8 4d f6 ff ff       	call   80107100 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107ab3:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107ab5:	c9                   	leave  
  if((*pte & PTE_U) == 0)
80107ab6:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107ab8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107abd:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107ac0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ac5:	83 fa 05             	cmp    $0x5,%edx
80107ac8:	ba 00 00 00 00       	mov    $0x0,%edx
80107acd:	0f 45 c2             	cmovne %edx,%eax
}
80107ad0:	c3                   	ret    
80107ad1:	eb 0d                	jmp    80107ae0 <uva2pte>
80107ad3:	90                   	nop
80107ad4:	90                   	nop
80107ad5:	90                   	nop
80107ad6:	90                   	nop
80107ad7:	90                   	nop
80107ad8:	90                   	nop
80107ad9:	90                   	nop
80107ada:	90                   	nop
80107adb:	90                   	nop
80107adc:	90                   	nop
80107add:	90                   	nop
80107ade:	90                   	nop
80107adf:	90                   	nop

80107ae0 <uva2pte>:

// returns the page table entry corresponding
// to a virtual address.
pte_t*
uva2pte(pde_t *pgdir, uint uva)
{
80107ae0:	55                   	push   %ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107ae1:	31 c9                	xor    %ecx,%ecx
{
80107ae3:	89 e5                	mov    %esp,%ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ae8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80107aeb:	5d                   	pop    %ebp
  return walkpgdir(pgdir, (void*)uva, 0);
80107aec:	e9 0f f6 ff ff       	jmp    80107100 <walkpgdir>
80107af1:	eb 0d                	jmp    80107b00 <copyout>
80107af3:	90                   	nop
80107af4:	90                   	nop
80107af5:	90                   	nop
80107af6:	90                   	nop
80107af7:	90                   	nop
80107af8:	90                   	nop
80107af9:	90                   	nop
80107afa:	90                   	nop
80107afb:	90                   	nop
80107afc:	90                   	nop
80107afd:	90                   	nop
80107afe:	90                   	nop
80107aff:	90                   	nop

80107b00 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107b00:	55                   	push   %ebp
80107b01:	89 e5                	mov    %esp,%ebp
80107b03:	57                   	push   %edi
80107b04:	56                   	push   %esi
80107b05:	53                   	push   %ebx
80107b06:	83 ec 1c             	sub    $0x1c,%esp
80107b09:	8b 5d 14             	mov    0x14(%ebp),%ebx
80107b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
80107b0f:	8b 7d 10             	mov    0x10(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107b12:	85 db                	test   %ebx,%ebx
80107b14:	75 40                	jne    80107b56 <copyout+0x56>
80107b16:	eb 70                	jmp    80107b88 <copyout+0x88>
80107b18:	90                   	nop
80107b19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80107b20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b23:	89 f1                	mov    %esi,%ecx
80107b25:	29 d1                	sub    %edx,%ecx
80107b27:	81 c1 00 10 00 00    	add    $0x1000,%ecx
80107b2d:	39 d9                	cmp    %ebx,%ecx
80107b2f:	0f 47 cb             	cmova  %ebx,%ecx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107b32:	29 f2                	sub    %esi,%edx
80107b34:	83 ec 04             	sub    $0x4,%esp
80107b37:	01 d0                	add    %edx,%eax
80107b39:	51                   	push   %ecx
80107b3a:	57                   	push   %edi
80107b3b:	50                   	push   %eax
80107b3c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80107b3f:	e8 5c d0 ff ff       	call   80104ba0 <memmove>
    len -= n;
    buf += n;
80107b44:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  while(len > 0){
80107b47:	83 c4 10             	add    $0x10,%esp
    va = va0 + PGSIZE;
80107b4a:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
    buf += n;
80107b50:	01 cf                	add    %ecx,%edi
  while(len > 0){
80107b52:	29 cb                	sub    %ecx,%ebx
80107b54:	74 32                	je     80107b88 <copyout+0x88>
    va0 = (uint)PGROUNDDOWN(va);
80107b56:	89 d6                	mov    %edx,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107b58:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
80107b5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80107b5e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80107b64:	56                   	push   %esi
80107b65:	ff 75 08             	pushl  0x8(%ebp)
80107b68:	e8 33 ff ff ff       	call   80107aa0 <uva2ka>
    if(pa0 == 0)
80107b6d:	83 c4 10             	add    $0x10,%esp
80107b70:	85 c0                	test   %eax,%eax
80107b72:	75 ac                	jne    80107b20 <copyout+0x20>
  }
  return 0;
}
80107b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107b7c:	5b                   	pop    %ebx
80107b7d:	5e                   	pop    %esi
80107b7e:	5f                   	pop    %edi
80107b7f:	5d                   	pop    %ebp
80107b80:	c3                   	ret    
80107b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107b8b:	31 c0                	xor    %eax,%eax
}
80107b8d:	5b                   	pop    %ebx
80107b8e:	5e                   	pop    %esi
80107b8f:	5f                   	pop    %edi
80107b90:	5d                   	pop    %ebp
80107b91:	c3                   	ret    
