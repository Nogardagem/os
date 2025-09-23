       org 7C00h ;this line is necessary for jump offsets that end up being absolute
 
        
 
 Start:mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
       mov cx, 1       ;We will want to write 1 character
       xor dx, dx      ;Start at top left corner


                       ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                       ;AH = 2
 Char: inc dl          ;Advance cursor

       cmp dl, 32   ;80   ;Wrap around edge of screen if necessary
       jne Skip
       xor dl, dl
       inc dh
 
       cmp dh, 25      ;Wrap around bottom of screen if necessary
       jne Skip
       xor dh, dh
 
 Skip: ;test for pixel rendering
       
       mov ax,0A000h ;video memory segment   
       mov es,ax     ;into es register
       
       mov ax,0 ;clear ax
       mov al,dh ;move y pos into al
       mov bl,160;move 160 (half screen width) into bl
       mul bl ;multiply y pos by bl (stored in ax)
       add ax,ax ;double result so it's actually times 320
       mov bx,0 ;clear bx
       mov bl,dl ;move x pos into bl
       add ax,bx ;add bx (x pos) to ax (y pos times width)
       mov di,ax ;set pixel location
       
       mov al,4      ;color 4 (red)
       mov [es:di],al        
       mov ax,13h    ;320x200 screen mode
       int 10h       ;graphics interrupt

       jmp Char
 
times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
 
       dw 0AA55h       ;Boot Sector signature