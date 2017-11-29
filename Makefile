MTOOLSRC:=$(CURDIR)/mtools.conf
export MTOOLSRC

kbd.com: kbd.asm
	nasm -f bin $< -o $@

clean::
	rm -f kbd.com cd.iso fdboot.img

fdboot.img: kbd.com
	cp -f freedos.img fdboot.img
	mdel a:kbd.com > /dev/null 2>&1 || true
	mcopy kbd.com a:KBD.COM

cd.iso: fdboot.img
	mkisofs -pad -b fdboot.img -R -o cd.iso fdboot.img

images:: cd.iso

qemu:: cd.iso
	qemu-system-$$(which qemu-system-i386 > /dev/null 2>&1 && echo i386 || echo x86_64) -cdrom cd.iso
