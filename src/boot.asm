org 7C00h ;offset jump addresses by this, because this is where the bootloader goes in memory

jmp short Start

vmem equ 1000h ;makes a constant variable, only for assembler to use

diskNumber: db 0
SECTORS_TO_LOAD equ 1

LoadSegment:;dl is sector al is how many to load si is position
	pushad

	mov ah, 0x2
	mov ch, 0
	mov cl, dl
	mov dh, 0
	mov dl, byte[diskNumber]
	mov bx, si
	int 0x13
	jnc .suc
		mov al, 'F'
        
		jmp $
	.suc:
	;print . for number of sectors loaded
	mov cl, al
	mov al, '$'
    
	popad
	ret

printstack:
    pop si ;remove function return address from stack
    jmp endps
    startps:
        call printal
    endps:
        pop ax
        cmp ax,0
        jne startps
    push si ;put function return address back
    ret

printal:
    pushad
    mov ah,2 ;cursor pos
    int 10h
    
    mov ah, 9 ;print
    int 10h

    add dx,vmem ;load letter memory pos
    push 0 ;ensure es is 0
    pop es
    mov di,dx
    mov [es:di],al ;fill letter memory for letter
    
    popad ;ensures dx doesn't keep the memory pos we added
    inc dl
ret

printnl:
    pushad

    push 0 ;ensure es is 0
    pop es
    mov dx,0 ;start at top left
    reprintloop:
        mov di,vmem ;get address of letter memory loaded
        
        inc dh ;grab letter in next row
        add di,dx
        mov al,[es:di]
        dec dh
        
        call printal ;print that letter in this row
        ;printal moved to right already
        
        cmp dl,80
        jne skipreprintrow
            inc dh ;if at width, inc row
            mov dl,0
        skipreprintrow:
        cmp dh,25
        jne reprintloop ;if not at height, continue

    popad
    mov dl,0
    ret


Start:
    ;Save device booted from
	mov byte[diskNumber], dl

    mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
    mov cx, 1       ;We will want to write 1 character
    xor dx, dx      ;Start at top left corner

    mov dh,24
    mov al,0x0041
    call printal
    ;call printnl

    ;set all segment registers to 0
	mov ax, 0
	mov es, ax
	mov ss, ax
	mov ds, ax
	;clear direction flag for string operations
	cld
	;Create the stack
	mov esp, 0x7c00
	mov ebp, esp
	
	;Load rest of code into memory
	mov dl, 2 ; sector id (1 indexed i.e 1=bootloader sector)
	mov al, SECTORS_TO_LOAD ; number of sectors to load, must match amount of padding in extend.asm
	mov si, 0x7e00 ; where to place the sectors
	call LoadSegment

	jmp nextSectorStart

times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
dw 0AA55h       ;Boot Sector signature

nextSectorStart:
                ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                ;AH = 2
    mov ah, 2   ;BH = page, DH = row, DL = column
    int 10h
    
    push 0
    push 'a'
    push 'b'
    push 'c'
    
    mov dh,24
    call printstack
    call printnl
 jmp nextSectorStart


times (512*(SECTORS_TO_LOAD+1))-($-$$) db 0