org 7C00h ;offset jump addresses by this, because this is where the bootloader goes in memory

jmp Start

vmem equ 1000h ;makes a constant variable, only for assembler to use

diskNumber: db 0
SECTORS_TO_LOAD equ 5

ERROR: ;prints line of error when called, with ORG subtracted
    call printnl
    mov dx,0x1800
    pop bx
    sub bx,7c00h ; <---- ORG GOES HERE

    push 0
    push ' '
    push 'R'
    push 'R'
    push 'E'
    call printstack

    mov al,bh
    call printbyte
    mov al,bl
    call printbyte
jmp $

LoadSegment:;dl is sector al is how many to load si is position
	pushad

	mov ah, 0x2

    mov dh, 0 ;simplified from below, clears ch and dh, sets cl to dl
    mov cx, dx
	
	;mov ch, 0
	;mov cl, dl
	;mov dh, 0

	mov dl, byte[diskNumber]
	mov bx, si
	int 0x13
	jnc .suc
		call ERROR
	.suc:
	popad
ret

printstack:
    pop si ;remove function return address from stack
    jmp .endps
    .startps:
        call printal
    .endps:
        pop ax
        cmp ax,0
        jne .startps
    push si ;put function return address back
ret

printal:
    pushad
    mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
    mov cx, 1

    mov ah,2 ;cursor pos
    int 10h
    
    mov ah, 9 ;print
    int 10h

    add dx,vmem ;load letter memory pos
    push 0 ;ensure es is 0
    pop es
    mov di,dx
    mov [es:di],al ;fill letter memory for letter
    
    poPaD ;ensures dx doesn't keep the memory pos we added
    inc dl
ret

printbyte: ;prints the byte stored in al as two hex chars
    pushad
    mov ah,0 ;ensure nothing in ah
    mov bl,10h
    div bl

    mov bl,al
    cmp bl, 9
    jbe AfterLetterOffset ;jump below or equal
        add bl, 0007h
    AfterLetterOffset:
    add bl, 0030h ;add offset for chars
    mov al,bl
    call printal ;print the char

    mov bl,ah
    cmp bl, 9
    jbe AfterLetterOffset2 ;jump below or equal
        add bl, 0007h
    AfterLetterOffset2:
    add bl, 0030h ;add offset for chars
    mov al,bl
    call printal

    popad
    add dl,2
ret

printbytedec:
    pushad
    mov di,dx
    mov cx,0

    push 0
    printbytedecstart: ;dividing dx:ax by bx
        mov dx,0
        mov bx,10
        div bx

        mov bx,ax ;move result into bx
        mov ax,dx ;move remainder into ax, which should always be below 10
        add al,0030h
        inc cl
        push ax
        mov ax,bx
        cmp ax,0
    jne printbytedecstart

    mov dx,di
    call printstack

    pop di ;di is last pushed in pushad
    push cx
    popad
    mov cx,di
    add dl,cl
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
	mov byte[diskNumber], dl ;Save device booted from

    ;set all segment registers to 0
	xor ax,ax
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

    mov dl,0

    jmp Main

times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
dw 0AA55h       ;Boot Sector signature

struc VesaInfoBlock				;	VesaInfoBlock_size = 512 bytes
	.Signature		resb 4		;	must be 'VESA'
	.Version		resw 1
	.OEMNamePtr		resd 1
	.Capabilities		resd 1

	.VideoModesOffset	resw 1
	.VideoModesSegment	resw 1

	.CountOf64KBlocks	resw 1
	.OEMSoftwareRevision	resw 1
	.OEMVendorNamePtr	resd 1
	.OEMProductNamePtr	resd 1
	.OEMProductRevisionPtr	resd 1
	.Reserved		resb 222
	.OEMData		resb 256
endstruc

ALIGN(4)

	VesaInfoBlockBuffer: istruc VesaInfoBlock
		at VesaInfoBlock.Signature,				db "VESA"
		times 508 db 0
	iend

struc VesaModeInfoBlock				;	VesaModeInfoBlock_size = 256 bytes
	.attributes		resw 1 ;deprecated
	.window_a	resb 1 ;deprecated
	.window_b	resb 1 ;deprecated
	.granularity	resw 1		;deprecated	in KB
	.window_size		resw 1		;	in KB
	.segment_a	resw 1		;	0 if not supported
	.segment_b	resw 1		;	0 if not supported
	.win_func_ptr	resd 1 ;deprecated
	.pitch	resw 1 ; bytes per scanline

	;	Added in Revision 1.2
	.width			resw 1		;	in pixels(graphics)/columns(text)
	.height			resw 1		;	in pixels(graphics)/columns(text)
	.w_char		resb 1		;	in pixels
	.y_char		resb 1		;	in pixels
	.planes		resb 1
	.bpp		resb 1
	.banks		resb 1 ;deprecated
	.memory_model		resb 1		;	http://www.ctyme.com/intr/rb-0274.htm#Table82
	.bank_size		resb 1		;	deprecated  in KB
	.image_pages	resb 1		;	count - 1
	.reserved0		resb 1		;	equals 0 in Revision 1.0-2.0, 1 in 3.0

	.red_mask		resb 1
	.red_position	resb 1
	.green_mask		resb 1
	.green_position	resb 1
	.blue_mask		resb 1
	.blue_position	resb 1
	.reserved_mask	resb 1
	.reserved_position	resb 1
	.direct_color_attributes	resb 1

	;	Added in Revision 2.0
	.framebuffer		resd 1 ;location of linear frame buffer in memory
	.off_screen_mem_off	resd 1
	.off_screen_mem_size	resw 1		;memory in fb not in screen 	in KB
	.reserved1		resb 206	;	available in Revision 3.0, but useless for now
endstruc


Main:
    in al, 0x92 ;set a20 line??
    or al, 2
    out 0x92, al

	call vbe_set_mode

    ;mov esi,0
    ;mov si,[vbe_screen.bytes_per_line]
    mov edx,[vbe_screen.physical_buffer]
    mov ebx,0 ;x pos
    mov ecx,0 ;y pos
    .loopy:
        .loopx:
            ;esi = bytes per scan line
            ;edx = physical address of linear framebuffer memory.
            ;ebx = x coord * 3
            ;ecx = y coord
            call DrawPixel
            add ebx,3

        cmp ebx,1920*3
        jle .loopx
    mov ebx,0
    inc ecx
    cmp ecx,1080
    jle .loopy
    mov ecx,0
    jmp .loopy

.NoModes:
    call ERROR

ALIGN(4)

VesaModeInfoBlockBuffer:	istruc VesaModeInfoBlock
		times VesaModeInfoBlock_size db 0
	iend

vbe_screen:
    .width dw 1
    .height dw 1
    .physical_buffer dd 1
    .bytes_per_line dw 1
    .bpp db 1
	.bytes_per_pixel dd 1
    .x_cur_max dw 1
    .y_cur_max dw 1

;esi = bytes per scan line
;edx = physical address of linear framebuffer memory.
;ebx = x coord * 3
;ecx = y coord

; IN (ebx,ecx,edx,esi) OUT () MOD (eax)
DrawPixel:
    mov eax,0
    mov ax,[vbe_screen.bytes_per_line]; BytesPerScanLine
    imul    eax, ecx                ; BytesPerScanLine * Y
    add     eax, ebx                ; BytesPerScanLine * Y + X * 3
    mov     word [eax+edx], 0x3456  ; Low word of RGB triplet
    mov     byte [eax+edx+2], 0x12  ; High byte of RGB triplet
    ret



vbe_set_mode:
    mov ax,1920
    mov [.width], ax
    mov bx,1080
	mov [.height], bx
    mov cl,24 ;32
	mov [.bpp], cl

	sti

	push es					; some VESA BIOSes destroy ES, or so I read
    mov ax, 0x4F00				; get VBE BIOS info
	mov di, VesaInfoBlockBuffer
	int 0x10
	pop es

	cmp ax, 0x4F				; BIOS doesn't support VBE?
    jne .error

	mov ax, word[VesaInfoBlockBuffer+VesaInfoBlock.VideoModesOffset]
	mov [.offset], ax
	mov ax, word[VesaInfoBlockBuffer+VesaInfoBlock.VideoModesOffset+2]
	mov [.segment], ax

	mov ax, [.segment]
	mov fs, ax
	mov si, [.offset]

.find_mode:
	mov dx, [fs:si]
	add si, 2
	mov [.offset], si
	mov [.mode], dx
	mov ax, 0
	mov fs, ax

	cmp word[.mode], 0xFFFF			; end of list?
	je .no_more_modes

	push es
	mov ax, 0x4F01				; get VBE mode info
	mov cx, [.mode]
	mov di, VesaModeInfoBlockBuffer
	int 0x10
	pop es

	cmp ax, 0x4F
    
	jne .error

    ; mov bx,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.width]
    ; cmp bx,1399 ;limit width
    ; jle .Notrightres ;if less than limit amount
    mov al, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.bpp]
    cmp al,24
    jne .Notrightres
    
    call printnl
    mov dh,24

    mov al, [.mode]
    call printbyte
    mov al,' '
    call printal

    mov ax,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.width]
    call printbytedec

    mov al, 'x'
    call printal
    mov ax,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.height]
    call printbytedec
    
    ;print bpp
    mov dl,0xF ;column 15 always
    mov al, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.bpp]
    mov ah,0
    call printbytedec

    .Notrightres:
    ;1920x1080 in hex is 0x0780 by 0x0438

    ;jmp .next_mode
	mov ax, [.width]
	cmp ax, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.width]
	jne .next_mode

	mov ax, [.height]
	cmp ax, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.height]
	jne .next_mode

	mov al, [.bpp]
	cmp al, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.bpp]
	jne .next_mode


    ;call ERROR

	; If we make it here, we've found the correct mode!
	mov ax, [.width]
	mov word[vbe_screen.width], ax
	mov ax, [.height]
	mov word[vbe_screen.height], ax
	mov eax, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.framebuffer]
	mov dword[vbe_screen.physical_buffer], eax
	mov ax, [VesaModeInfoBlockBuffer+VesaModeInfoBlock.pitch]
	mov word[vbe_screen.bytes_per_line], ax
	mov eax, 0
	mov al, [.bpp]
	mov byte[vbe_screen.bpp], al
	shr eax, 3
	mov dword[vbe_screen.bytes_per_pixel], eax

	mov ax, [.width]
	shr ax, 3
	dec ax
	mov word[vbe_screen.x_cur_max], ax

	mov ax, [.height]
	shr ax, 4
	dec ax
	mov word[vbe_screen.y_cur_max], ax

	; Set the mode
	push es
	mov ax, 0x4F02
	mov bx, [.mode]
	or bx, 0x4000			; enable LFB
	mov di, 0			; not sure if some BIOSes need this... anyway it doesn't hurt
	int 0x10
	pop es

	cmp ax, 0x4F
	jne .error

	clc
	ret

.next_mode:
	mov ax, [.segment]
	mov fs, ax
	mov si, [.offset]
	jmp .find_mode

.error:
	call ERROR

.no_more_modes:
    ;pass
ret

.width				dw 0
.height				dw 0
.bpp				db 0
.segment			dw 0
.offset				dw 0
.mode				dw 0





times (512*(SECTORS_TO_LOAD+1))-($-$$) db 0 ;if this errors cuz of negative, need to load more sectors