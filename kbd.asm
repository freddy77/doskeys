; compile with NASM: nasm.exe -f bin kbd.asm -o kbd.com

bits 16
org 0x100

    xor     ax, ax
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

test:
    mov     ah, 9
    mov     dx, msg1
    int     0x21                ; print "Press and hold ESC"

test1:
    mov     al, [kbdbuf + 1]    ; check Escape key state (Esc scan code = 1)
    or      al, al
    jz      test1               ; wait until it's nonzero (pressed/held)

    mov     dx, msg2
    int     0x21                ; print "ESC pressed, release ESC"

test2:
    mov     al, [kbdbuf + 1]    ; check Escape key state (Esc scan code = 1)
    or      al, al
    jnz     test2               ; wait until it's zero (released/not pressed)

    mov     dx, msg3            ; print "ESC released"
    int     0x21

    ret

irq1isr:
    pusha

    ; read keyboard scan code
    in      al, 0x60

    ; update keyboard state
    xor     bh, bh
    mov     bl, al
    and     bl, 0x7F            ; bx = scan code
    shr     al, 7               ; al = 0 if pressed, 1 if released
    xor     al, 1               ; al = 1 if pressed, 0 if released
    mov     [cs:bx+kbdbuf], al

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
    iret

kbdbuf:
    times   128 db 0

msg1 db "Press and hold ESC", 13, 10, "$"
msg2 db "ESC pressed, release ESC", 13, 10, "$"
msg3 db "ESC released", 13, 10, "$"

