       org 7C00h ;this line is necessary for jump offsets that end up being absolute
 
        
 
 Start:mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
       mov cx, 1       ;We will want to write 1 character
       xor dx, dx      ;Start at top left corner

                       ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                       ;AH = 2
 Char: ;mov ah, 2       ;BH = page, DH = row, DL = column
       ;int 10h
       
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
       add ax, 7c00h ;adds mem offset of some value, 7c00 is for bootloader start
       
       mov bx, 0 ;add dh<<2 to address
       mov bl, dh
       sal bx, 4
       add ax, bx
       
       ;mov di, 1100h
       ;mov [di], ax
       mov di, ax ;loads memory at result (dx/2 + 1000) into al for determining char
       mov al, [di]
       
       mov ah, 0 ;divide by 0x10 and get remainder
       mov bl, 10h
       div bl

       mov di, 1002h ;get dl%2
       mov cl, [di]
       cmp cl, 0
       mov cx, 1
       jne Later ;if dl%2 == 1:
       mov ah, al; then get div result, not remainder (gets [x ] instead of [ x] from byte hex)
       Later:

       mov al, ah
       cmp al, 9
       jbe AfterLetterOffset ;jump below or equal
       add al, 0007h
       AfterLetterOffset:
       add al, 0030h ;add offset for chars
       
       mov di, 1000h
       mov bx, [di] ;gets color back from [0x1000] into bx (lowest hex of bx determines color)

                        ;PC BIOS Interrupt 10 Subfunction 9 - Write character and colour
                        ;AH = 9
       mov ah, 9       ;BH = page, AL = character, BL = attribute, CX = character count
       ;int 10h
 
       inc dl          ;Advance cursor

       cmp dl, 32   ;80   ;Wrap around edge of screen if necessary
       jne Skip
       xor dl, dl
       inc dh
 
       cmp dh, 25      ;Wrap around bottom of screen if necessary
       jne Skip
       xor dh, dh
 
 Skip: ;test for pixel rendering
       mov ax,13h    ;320x200 screen mode
       int 10h       ;graphics interrupt
       mov ax,0A000h ;video memory segment   
       mov es,ax     ;into es register
       
       mov ax,0 ;clear ax
       mov al,dh ;move y pos into al
       mov bl,160;move 160 (half screen width) into bl
       mul bl ;multiply y pos by bl (stored in ax)
       add ax,ax ;double result so it's actually times 320
       mov bx,0 ;clear bx
       mov bl,dl ;move x pos into bl
       add ax,bx ;add bx (x pos) to ax (y pos times width
       mov di,ax
       ;mov di,320      ;pixel location, 0 is top left
       mov al,4      ;color 4 (red)
       mov [es:di],al        
       int 10h

       jmp Char
 
times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
 
       dw 0AA55h       ;Boot Sector signature