org 7C00h

jmp short Start ;Jump over the data (the 'short' keyword makes the jmp instruction smaller)

vmem equ 1000h

printal:
    pushad
    mov ah,2 ;cursor pos
    int 10h
    
    mov ah, 9 ;print
    int 10h

    add dx,vmem
    mov bl,0
    push 0
    pop es
    mov di,dx
    mov [es:di],al
    
    popad
    inc dl
ret
printnl:
    pushad

    push 0
    pop es
    mov dx,0
    mov dh,0
reprintloop:
    mov di,vmem
    inc dh
    add di,dx
    mov al,[es:di]
    dec dh
    ;mov si,0
    ;mov [es:di],si
    
    call printal
    
    
    cmp dl,80
    jne skipreprintrow
    inc dh
    mov dl,0
    skipreprintrow:
    cmp dh,25
    jne reprintloop

    popad
    mov dl,0
    ret


Start:  mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
        mov cx, 1       ;We will want to write 1 character
        xor dx, dx      ;Start at top left corner
        mov ds, dx      ;Ensure ds = 0 (to let us load the message)
        cld             ;Ensure direction flag is cleared (for LODSB)
 
                         ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                         ;AH = 2
 Char:  mov ah, 2       ;BH = page, DH = row, DL = column
        int 10h
        
        mov dh,24
        inc al
        call printal
        inc al
        call printal
        inc al
        call printal
        call printnl
        ;lodsb           ;Load a byte of the message into AL.
                        ;Remember that DS is 0 and SI holds the
                        ;offset of one of the bytes of the message.

                        ;PC BIOS Interrupt 10 Subfunction 9 - Write character and colour
                        ;AH = 9
        ;mov ah, 9       ;BH = page, AL = character, BL = attribute, CX = character count
        ;int 10h
 
 Skip:   jmp Char       ;otherwise restart from the beginning of the message
 
 
 times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
 
         dw 0AA55h       ;Boot Sector signature
 
 ;OPTIONAL:
 ;To zerofill up to the size of a standard 1.44MB, 3.5" floppy disk
 ;times 1474560 - ($ - $$) db 0