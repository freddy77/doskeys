kbd.com: kbd.asm
	nasm -f bin $< -o $@

clean::
	rm -f kbd.com
