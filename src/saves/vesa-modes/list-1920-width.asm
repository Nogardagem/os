org 7C00h ;offset jump addresses by this, because this is where the bootloader goes in memory

jmp Start

vmem equ 1000h ;makes a constant variable, only for assembler to use

diskNumber: db 0
SECTORS_TO_LOAD equ 4

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
        mov dx,0x1800
        call printal
		jmp $ ;failed to load
	.suc:
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

    mov bh,0
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

    mov dl,0

    jmp Main
	jmp nextSectorStart

times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes
dw 0AA55h       ;Boot Sector signature

nextSectorStart:
    ;push 0
    ;push 'a'
    ;push 'b'
    ;push 'c'
    
    inc ax
    mov dh,24
    call printbyte
    call printnl
jmp nextSectorStart




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

Main:
	push ds
	pop es
	mov di, VesaInfoBlockBuffer
	call get_vesa_info

    mov al,'v'
    mov dx,0x1800
    call printal

	jmp Main2

;	in:
;		es:di - 512-byte buffer
;	out:
;		cf - set on error
get_vesa_info:
	clc
	mov ax, 0x4f00
	int 0x10
	cmp ax, 0x004f
	jne .failed
	ret
	.failed:
		stc
		ret

ALIGN(4)

	VesaInfoBlockBuffer: istruc VesaInfoBlock
		at VesaInfoBlock.Signature,				db "VESA"
		times 508 db 0
	iend

struc VesaModeInfoBlock				;	VesaModeInfoBlock_size = 256 bytes
	.ModeAttributes		resw 1
	.FirstWindowAttributes	resb 1
	.SecondWindowAttributes	resb 1
	.WindowGranularity	resw 1		;	in KB
	.WindowSize		resw 1		;	in KB
	.FirstWindowSegment	resw 1		;	0 if not supported
	.SecondWindowSegment	resw 1		;	0 if not supported
	.WindowFunctionPtr	resd 1
	.BytesPerScanLine	resw 1

	;	Added in Revision 1.2
	.Width			resw 1		;	in pixels(graphics)/columns(text)
	.Height			resw 1		;	in pixels(graphics)/columns(text)
	.CharWidth		resb 1		;	in pixels
	.CharHeight		resb 1		;	in pixels
	.PlanesCount		resb 1
	.BitsPerPixel		resb 1
	.BanksCount		resb 1
	.MemoryModel		resb 1		;	http://www.ctyme.com/intr/rb-0274.htm#Table82
	.BankSize		resb 1		;	in KB
	.ImagePagesCount	resb 1		;	count - 1
	.Reserved1		resb 1		;	equals 0 in Revision 1.0-2.0, 1 in 3.0

	.RedMaskSize		resb 1
	.RedFieldPosition	resb 1
	.GreenMaskSize		resb 1
	.GreenFieldPosition	resb 1
	.BlueMaskSize		resb 1
	.BlueFieldPosition	resb 1
	.ReservedMaskSize	resb 1
	.ReservedMaskPosition	resb 1
	.DirectColorModeInfo	resb 1

	;	Added in Revision 2.0
	.LFBAddress		resd 1
	.OffscreenMemoryOffset	resd 1
	.OffscreenMemorySize	resw 1		;	in KB
	.Reserved2		resb 206	;	available in Revision 3.0, but useless for now
endstruc

Main2:
	; after getting VesaInfoBlock:
	push word [VesaInfoBlockBuffer + VesaInfoBlock.VideoModesSegment]
	pop es
	mov di, VesaModeInfoBlockBuffer
	mov bx, [VesaInfoBlockBuffer + VesaInfoBlock.VideoModesOffset]	;	get video modes list address
	mov cx, [bx]							;	get first video mode number
	cmp cx, 0xffff							;	vesa modes list empty
	je .NoModes

    call vbe_set_mode

	;call get_vesa_mode_info
.NoModes:
    call printnl
    mov ax,[VesaModeInfoBlock.Width]
    call printbyte
    mov al,ah
    call printbyte
    
    call printnl
    mov ax,[VesaModeInfoBlock.Height]
    ;mov ax,0x1234
    call printbyte
    mov al,ah
    call printbyte



	jmp $


;	in:
;		cx - VESA mode number
;		es:di - 256-byte buffer
;	out:
;		cf - set on error
get_vesa_mode_info:
	clc
	mov ax, 0x4f01
	int 0x10
	cmp ax, 0x004f
	jne .failed
	ret
	.failed:
        mov al,'f'
        mov dx,0x1800
        call printal
		stc
		ret

ALIGN(4)

VesaModeInfoBlockBuffer:	istruc VesaModeInfoBlock
		times VesaModeInfoBlock_size db 0
	iend


; vbe_set_mode:
; Sets a VESA mode
; In\	AX = Width
; In\	BX = Height
; In\	CL = Bits per pixel
; Out\	FLAGS = Carry clear on success
; Out\	Width, height, bpp, physical buffer, all set in vbe_screen structure

vbe_set_mode:
    call printnl
    push 0
    push 'e'
    push 'b'
    push 'v'
    call printstack
    call printnl

	mov [.width], ax
	mov [.height], bx
	mov [.bpp], cl

	sti

	push es					; some VESA BIOSes destroy ES, or so I read

    mov al,'c'
    call printal
    call printnl

	mov ax, 0x4F00				; get VBE BIOS info
	mov di, VesaInfoBlockBuffer
	int 0x10
	pop es

	cmp ax, 0x4F				; BIOS doesn't support VBE?
    mov al,'b'
    call printal
    call printnl

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
	je .error

	push es
	mov ax, 0x4F01				; get VBE mode info
	mov cx, [.mode]
	mov di, VesaModeInfoBlockBuffer
	int 0x10
	pop es

	cmp ax, 0x4F
	jne .error

    

    mov ax,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.Width]
    cmp ax,1920
    jne .Notrightres
    call printnl
    mov dh,24
    mov al,'*'
    call printal

    mov ax,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.Width]
    mov bx,ax
    mov al,bh
    call printbyte
    mov al,bl
    call printbyte

    mov al, ' '
    call printal
    mov ax,[VesaModeInfoBlockBuffer+VesaModeInfoBlock.Height]
    mov bx,ax
    mov al,bh
    call printbyte
    mov al,bl
    call printbyte

    ;1920x1080 in hex is 0x0780 by 0x0438

    push 0
    push '8'
    push '3'
    push '4'
    push '0'
    push ' '
    push '0'
    push '8'
    push '7'
    push '0'
    push ' '
    push ' '
    push ' '
    call printstack
.Notrightres:
    ;call printnl

    jmp .next_mode
	; mov ax, [.width]
	; cmp ax, [mode_info_block.width]
	; jne .next_mode

	; mov ax, [.height]
	; cmp ax, [mode_info_block.height]
	; jne .next_mode

	; mov al, [.bpp]
	; cmp al, [mode_info_block.bpp]
	; jne .next_mode

	; ; If we make it here, we've found the correct mode!
	; mov ax, [.width]
	; mov word[vbe_screen.width], ax
	; mov ax, [.height]
	; mov word[vbe_screen.height], ax
	; mov eax, [mode_info_block.framebuffer]
	; mov dword[vbe_screen.physical_buffer], eax
	; mov ax, [mode_info_block.pitch]
	; mov word[vbe_screen.bytes_per_line], ax
	; mov eax, 0
	; mov al, [.bpp]
	; mov byte[vbe_screen.bpp], al
	; shr eax, 3
	; mov dword[vbe_screen.bytes_per_pixel], eax

	; mov ax, [.width]
	; shr ax, 3
	; dec ax
	; mov word[vbe_screen.x_cur_max], ax

	; mov ax, [.height]
	; shr ax, 4
	; dec ax
	; mov word[vbe_screen.y_cur_max], ax

	; ; Set the mode
	; push es
	; mov ax, 0x4F02
	; mov bx, [.mode]
	; or bx, 0x4000			; enable LFB
	; mov di, 0			; not sure if some BIOSes need this... anyway it doesn't hurt
	; int 0x10
	; pop es

	; cmp ax, 0x4F
	; jne .error

	clc
	ret

.next_mode:
	mov ax, [.segment]
	mov fs, ax
	mov si, [.offset]
	jmp .find_mode

.error:
	stc
    call printnl
    mov al,'e'
    mov dx,0x1800
    call printal
	ret

.width				dw 0
.height				dw 0
.bpp				db 0
.segment			dw 0
.offset				dw 0
.mode				dw 0





times (512*(SECTORS_TO_LOAD+1))-($-$$) db 0