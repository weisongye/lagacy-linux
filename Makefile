#
# if you want the ram-disk device, define this to be the
# size in blocks.
#
AS86	=as86 -0 -a
LD86	=ld86 -0

AS	=as    # gas
LD	=ld    # gld
LDFLAGS	=-m elf_i386 -Ttext 0 -e startup_32 -s -x -M
CC	=gcc -mcpu=i386 $(RAMDISK)
CFLAGS	=-Wall -O -fstrength-reduce -fomit-frame-pointer 
CPP	=cpp -nostdinc -Iinclude

.c.s:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -S -o $*.s $<
.s.o:
	$(AS) -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) \
	-nostdinc -Iinclude -c -o $*.o $<

all:	Image

Image: boot/boot tools/system tools/build
	objcopy -O binary -R .note -R .comment tools/system tools/kernel
	tools/build boot/boot tools/kernel  > Image
	sync

disk: Image
	dd bs=8192 if=Image of=/dev/fd0
	sync;sync;sync

tools/build: tools/build.c
	$(CC) $(CFLAGS) \
	-o tools/build tools/build.c

boot/head.o: boot/head.s

tools/system:	boot/head.o 
	$(LD) $(LDFLAGS) boot/head.o  -o tools/system > System.map 


boot/boot:	boot/boot.s
	$(AS86) -o boot/boot.o boot/boot.s
	$(LD86) -s -o boot/boot boot/boot.o


clean:
	rm -f Image System.map tmp_make core boot/boot 
	rm -f init/*.o tools/system tools/build boot/*.o

