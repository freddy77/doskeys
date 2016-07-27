kbd
===

Utility to print scancodes from DOS.

The purpose of this utility is getting the hardware scancodes as low
level as possible.

Once launched it prints the scancode you get from the AT keyboard as
long as ESC is not pressed.

Tools needed:

 * *Linux* environment
 * *nasm* to compile
 * *mtools* to build floppy image
 * *mkisofs* to build a bootable cd image

The freedos.img file contains a copy of FreeDOS 1.0 used to get a
floppy disk image.

`make images` command will compile the program and build floppy
and cd image.

How to use the floppy image
---------------------------
 1. write to a physical floppy (quite hard these days)
 2. `dd` the image into an USB stick and boot from the USB stick
    (I used a `dd if=fdboot.img bs=1024 of=/dev/sdb`)
 3. use the image in a virtual environment

How to use the cd image
-----------------------
 1. burn the image on a physical CD and boot from it
 2. use the image in a virtual environment
