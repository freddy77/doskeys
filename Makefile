MTOOLSRC:=$(CURDIR)/mtools.conf
export MTOOLSRC

kbd.com: kbd.asm
	nasm -f bin $< -o $@

clean::
	rm -f kbd.com cd.iso fdboot.img

images:: kbd.com
	cp -f freedos.img fdboot.img
	-mdel a:kbd.com > /dev/null 2>&1
	mcopy kbd.com a:KBD.COM
	mkisofs -pad -b fdboot.img -R -o cd.iso fdboot.img
