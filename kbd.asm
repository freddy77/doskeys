; compile with NASM: nasm.exe -f bin kbd.asm -o kbd.com

bits 16
org 0x100

    xor     ax, ax

	; clear bss segment
	cld
	lea	di, [bss_start]
	mov	cx, (bss_end-bss_start)/2
	rep	stosw

    mov     es, ax

    cli                         ; update ISR address w/ ints disabled
    push    word [es:9*4+2]     ; preserve ISR address
    push    word [es:9*4]
    mov     word [es:9*4], irq1isr
    mov     [es:9*4+2],cs
    sti

    call    test

    cli                         ; update ISR address w/ ints disabled
    pop     word [es:9*4]       ; restore ISR address
    pop     word [es:9*4+2]
    sti

    ret

; print al in hexadecimal
write_hex:
	push	cx
	push	ax
	mov	cx, 2
write_hex_loop:
	rol	al, 4
	push	ax
	and	al, 0xf
	add	al, '0'
	cmp	al, '9'
	jbe	no_add
	add	al, 'A' - '0' - 10
no_add:
	call	write_char
	pop	ax
	loop	write_hex_loop
	mov	al, ' '
	call	write_char
	pop	ax
	pop	cx
	ret

; write al to output
write_char:
	pusha
	mov		ah, 2
	mov		dl, al
	int		0x21
	popa
	ret

test:
	mov     ah, 9
	mov     dx, msg1
	int     0x21                ; print "Press ESC to exit"

	; print and clear input buffer
	mov	si, 0
get_key:
	mov	al, [si+kbdcodes]
	or	al, al
	jnz	handle_key
	hlt
	jmp	get_key
handle_key:
	; if ESC exit
	cmp	al, 0x1
	jne	no_esc_key

	mov     ah, 9
	mov     dx, msg2
	int     0x21
	ret
no_esc_key:
	; print scancode and remove from buffer
	mov	byte [si+kbdcodes], 0
	call	write_hex
	inc	si
	and	si, 0x7f
	jmp	get_key

irq1isr:
	push	ds
	push	es
	push	cs
	pop	ds
	push	cs
	pop	es
	pusha

	; read keyboard scan code
	in      al, 0x60

	mov	bx, [kbdindex]
	cmp	byte [bx+kbdcodes], 0
	jne	skip_code
	mov	[bx+kbdcodes], al
	inc	bx
	and	bx, 0x7f
	mov	[kbdindex], bx
skip_code:

    ; send EOI to XT keyboard
    in      al, 0x61
    mov     ah, al
    or      al, 0x80
    out     0x61, al
    mov     al, ah
    out     0x61, al

    ; send EOI to master PIC
    mov     al, 0x20
    out     0x20, al

	popa
	pop	es
	pop	ds
	iret

msg1 db "Press ESC to exit", 13, 10, "$"
msg2 db 13, 10, "Goodbye", 13, 10, "$"

align 2

section .bss

bss_start:
kbdindex: resw 1
kbdcodes: resb 128
bss_end:
