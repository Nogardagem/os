        org 7C00h
 
        jmp short Start ;Jump over the data (the 'short' keyword makes the jmp instruction smaller)
 
 Msg:   db "Hello World! "
 EndMsg:
 
 Start: mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
        mov cx, 1       ;We will want to write 1 character
        xor dx, dx      ;Start at top left corner
        mov ds, dx      ;Ensure ds = 0 (to let us load the message)
        cld             ;Ensure direction flag is cleared (for LODSB)
 
 Print: mov al, 0040h     ;Loads the address of the first byte of the message, 7C02h in this case
 
                         ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                         ;AH = 2
 Char:  mov ah, 2       ;BH = page, DH = row, DL = column
        int 10h
        ;mov al, 0041h
        ;inc al
        
        
        
        ;dl / 2
        mov al, dl
        mov ah, 0 ; clean up ah, also you can do it before, like move ax, 9
        mov bl, 2 ; prepare divisor
        div bl
        mov ah, 0
        ;result % 2
        mov bl, 2
        div bl
        mov bl, ah ;ah is mod out
        mov bh, 0
        add bx, 000eh
        mov di, 1000h
        mov [di], bx
        

        mov dx, ax
        mov ah, 0 ; clean up ah, also you can do it before, like move ax, 9
        mov bl, 2 ; prepare divisor
        div bl ; al = ax / bl, ah = ax % bl
        mov ah, 0

        mov di, ax ;these two lines load memory at [dx] into al for determining char
        mov al, [di]
        ;mov al, dl
        ;mov ah, 0 ; clean up ah, also you can do it before, like move ax, 9
        ;mov bl, 2 ; prepare divisor
        ;div bl ; al = ax / bl, ah = ax % bl

        ;mov al, al ;for clarity
        mov di, 1000h
        mov bx, [di]

        ;lodsb           ;Load a byte of the message into AL.
                         ;Remember that DS is 0 and SI holds the
                         ;offset of one of the bytes of the message.
 
                         ;PC BIOS Interrupt 10 Subfunction 9 - Write character and colour
                         ;AH = 9
        mov ah, 9       ;BH = page, AL = character, BL = attribute, CX = character count
        int 10h
 
        inc dl          ;Advance cursor
 
        cmp dl, 80      ;Wrap around edge of screen if necessary
        jne Skip
        xor dl, dl
        inc dh
        mov al, 0040h
 
        cmp dh, 25      ;Wrap around bottom of screen if necessary
        jne Skip
        xor dh, dh
 
 Skip:  jmp Char
 
 
 times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
 
        dw 0AA55h       ;Boot Sector signature
 
 ;OPTIONAL:
 ;To zerofill up to the size of a standard 1.44MB, 3.5" floppy disk
 ;times 1474560 - ($ - $$) db 0