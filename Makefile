MTOOLSRC:=$(CURDIR)/mtools.conf
export MTOOLSRC

kbd.com: kbd.asm
	nasm -f bin $< -o $@

kbd_mbr.dat: kbd.asm
	nasm -f bin $< -o $@ -DMBR

clean::
	rm -f kbd.com cd.iso fdboot.img fdboot_mbr.img cd_mbr.iso kbd_mbr.dat

fdboot.img: kbd.com kbd_mbr.dat
	cp -f freedos.img fdboot.img
	mdel a:kbd.com > /dev/null 2>&1 || true
	mcopy kbd.com a:KBD.COM

cd.iso: fdboot.img
	mkisofs -pad -b fdboot.img -R -o cd.iso fdboot.img

cd_mbr.iso: kbd_mbr.dat
	cp -f freedos.img fdboot_mbr.img
	dd if=kbd_mbr.dat bs=512 count=1 of=fdboot_mbr.img conv=notrunc
	mkisofs -pad -b fdboot_mbr.img -R -o cd_mbr.iso fdboot_mbr.img

images:: cd.iso cd_mbr.iso

qemu:: cd.iso
	qemu-system-$$(which qemu-system-i386 > /dev/null 2>&1 && echo i386 || echo x86_64) -cdrom $<

qemu_mbr:: cd_mbr.iso
	qemu-system-$$(which qemu-system-i386 > /dev/null 2>&1 && echo i386 || echo x86_64) -cdrom $<
