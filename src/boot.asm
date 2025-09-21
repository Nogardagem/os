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
        mov di, 1008h
        mov bx, 00f0fh
        mov [di], bx
        
        
        ;dl / 2   via DIV= ax/bl->al, ax%bl->ah
        mov al, dl
        mov ah, 0 
        mov bl, 2 
        div bl
        mov ah, 0
        ;result % 2
        mov bl, 2
        div bl
        mov bl, ah ;ah is mod out
        mov bh, 0
        add bx, 000eh
        mov di, 1000h
        mov [di], bx ;this whole section moves color selection into [0x1000]
        

        mov al, dl ;divides dl by 2
        mov ah, 0
        mov bl, 2
        div bl

        mov di, 1002h ;move dl%2 into storage at 0x1002
        mov [di], ah

        mov ah, 0
        add ax, 1000h ;adds 1000 for mem offset
        
        mov bx, 0 ;add dh<<2 to address
        mov bl, dh
        sal bx, 4
        add ax, bx
        
        ;mov di, 1100h
        ;mov [di], ax
        mov di, ax ;loads memory at result (dx/2 + 1000) into al for determining char
        mov al, [di]

        
        ;mov di, 1002h
        ;mov al, [di]
        ;mov ah, 4
        ;mul ah
        ;mov cl, al

        ;mov di, 1100h
        ;mov di, [di];loads memory at result (dx/2 + 1000) into al for determining char
        ;mov al, [di]

        ;shr al, cl
        ;mov cl, 1
        
        mov ah, 0 ;divide by 0x10 and get remainder
        mov bl, 10h
        div bl

        mov di, 1002h
        mov si, [di]
        mov cx, ax
        mul si
        mov cl, al

        ;si = 1-si
        mov ax, 1
        sub ax, si
        mov si, ax

        mov al, ch
        mul si
        mov ah, 0
        add al, cl
        mov cx, 1
        mov si, 0

        ;mov al, ah
        add al, 0037h ;add offset for chars
        
        mov di, 1000h
        mov bx, [di] ;gets color back from [0x1000] into bx (lowest hex of bx determines color)

        ;lodsb           ;Load a byte of the message into AL.
                         ;Remember that DS is 0 and SI holds the
                         ;offset of one of the bytes of the message.
 
                         ;PC BIOS Interrupt 10 Subfunction 9 - Write character and colour
                         ;AH = 9
        mov ah, 9       ;BH = page, AL = character, BL = attribute, CX = character count
        int 10h
 
        inc dl          ;Advance cursor
 
        cmp dl, 32   ;80   ;Wrap around edge of screen if necessary
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