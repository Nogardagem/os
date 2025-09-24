# OS

A project describing my process of making (or failing to make) my own OS

> I'll be changing each of these documents as I go to keep the most relevant/useful information. I'd like this to support me (and hopefully others) in being able to reproduce this project.

## Making My OS Using Only x86 Assembly

The main idea of this project is to make an operating system from scratch[^1], with no prebuilt classes or objects or anything like that, simply creating the binary files that'll run on a new empty machine. Of course, I'm not quite insane enough to work in plain binary (at least, not yet [[foreshadowing]](md/my-own-assembly-editor.md)), but I don't want to use any tools/languages beyond x86 assembly to create this OS.

[^1]: I guess it's not *entirely* from scratch if I use example code, but I've ended up replacing most of it in my experimentation/updates anyway.

In [the old files](old/old-read.md), I started my process by using a tutorial on the [OSDev](https://wiki.osdev.org/) website. That tutorial, however, assumed the reader wanted to create an OS using C/C++ as their primary programming language, and included many steps specific to that.

Instead, I want to use **only assembly ([why?](md/why-only-assembly.md))**, which *somehow* manages to make the earliest steps of OS development a little easier.

## Where I Started

After learning OSDev didn't have the tutorial I wanted, I began researching what I needed to do to get an assembly bootloader working (since by the end of [that tutorial](https://wiki.osdev.org/Bare_Bones) I learned I would need one). The first useful page I came across was the [WikiBook for x86 Assembly bootloaders](https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders), which contains a [sample bootloader](references/wikibook-bootloader-sample.md) for an x86 OS. As this sample was designed for [NASM](https://www.nasm.us/), and I had already heard good things about it as an assembler, I chose it as the assembler for this project. I explain downloading and setting it up in [setup.md](md/setup.md). Similarly, I wanted to use an emulator for the start of this project (so I don't break any hardware). As mentioned by both OSDev and the WikiBook, [QEMU](https://www.qemu.org/) was one of the best emulators to use (its setup is also described in [setup.md](md/setup.md)).

Along with NASM and QEMU, I need some sort of editor for the code itself. I decided on VS Code, as it's easy to use and comes with tools that make the whole process much easier (most notably including GitHub committing features and different command lines). Another goal I have as part of this project, however, is to make [my own assembly editor](md/my-own-assembly-editor.md).

## The Experimentation Phase

> this may or may not be moved to a separate file later on

After getting my tools ready, I wanted to immediately get into running my own code. To get started, I decided to find out how to get the [sample bootloader](references/wikibook-bootloader-sample.md) working. As the [WikiBook](https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders) stated, I need to first assemble the code into binary using NASM, and then test it using an emulator like QEMU. I found out how to get those running given my setup, which resulted in [`os.bat`](references/os-bat-explanation.md):

```batch
"C:\Program Files\nasm\nasm" -f bin boot.asm -o boot.bin
"C:\Program Files\qemu\qemu-system-i386" -drive file=boot.bin,index=0,format=raw
```

Surprisingly, this was all it took to get a working bootloader. After [executing `os.bat`](references/os-bat-explanation.md#executing-osbat), QEMU opened and displayed my OS, which according to the sample was filling the screen with copies of `Hello, World!` and looping at the screen's edges.

### First Experiments

#### Better "Hello, World!"

The first thing I did to mess with the sample code was make it so `Hello, World!` ended a line, so you could read it consistently. All this took was deleting

```nasm
inc dl          ;Advance cursor

cmp dl, 80      ;Wrap around edge of screen if necessary
jne Skip
xor dl, dl
inc dh
```

from the main loop section, and instead adding `inc dh` to make

```nasm
cmp si, EndMsg  ;If we're not at end of message,
jne Char        ;continue loading characters

inc dh ; <--added, new line after finishing "Hello, World!"

jmp Print       ;otherwise restart from the beginning of the message
```

at the `Skip` label.

This works because the [sample bootloader](references/wikibook-bootloader-sample.md) is using the lower half of the `d` register (`dl`) to store the x position of the cursor, and the upper half (`dh`) to store the y position. Instead of testing for wrapping at screen edges, I had it always wrap at the end of the message.

> If the message was long enough to reach the screen edge on its own, then you'd want to leave in the first section, so the message fills two lines instead of continuing off-screen.

#### Memory Rendering

After getting this text rendering working, I decided to see what else I could do with this limited rendering mode. I honestly don't remember too much of this process, as I was having a lot of fun messing with things.

What I ended up creating, however, was a boot file ([`src/saves/boot-mem.asm`](src/saves/boot-mem.asm)) that renders a certain region of memory as bytes on the screen. I set it to render the memory region containing the running bootloader, and so if you were to run it instead of `boot.asm` in `os.bat`, the memory it displays is the same as the hex values in the generated binary file for the bootloader (`boot.bin`).

If you want to know more about how it works, there are *some* comments in the file which may explain things well enough to be useful.

#### Pixel Rendering

My next goal was to get any rendering system other than text rendering to work. Similarly, I poorly documented my process, but the comments this time are much better.

> I left the structure from the original template in, so label names are a bit odd

The primary code for this version is

```nasm
mov ax,0A000h    ;video memory segment   
mov es,ax        ;into es register

mov ax,0         ;clear ax
mov al,dh        ;move y pos into al
mov bl,160       ;move 160 (half screen width) into bl
mul bl           ;multiply y pos by bl (stored in ax)
add ax,ax        ;double result so it's actually times 320
mov bx,0         ;clear bx
mov bl,dl        ;move x pos into bl
add ax,bx        ;add bx (x pos) to ax (y pos times width)
mov di,ax        ;set pixel location

mov al,4         ;color 4 (red)
mov [es:di],al        
mov ax,13h       ;320x200 screen mode
int 10h          ;graphics interrupt
```

This makes use of the 320x200 pixel rendering mode, with 16 unique colors. I repurposed the main loop of the previous setup to render a pixel at the end of each step, putting the pixel at the x and y position of the former cursor. This makes a single red pixel loop around inside a small box until it reaches the bottom right, where it then goes back to the beginning. A similar version to this can be found [in `src/saves/`](src/saves/boot-rendering-working.asm).

#### "Debugging" For Memory Information

My next major goal *was* to make use of VGE graphics to render, rather than plain VGA. I found [this guide](https://dev.to/willy1948/guide-to-vbe-graphics-in-x86-5g2n) to setting it up, and learned that VGE was still too limiting for me, as I want to eventually have 1920x1080 rendering. I still managed to make use of some of their other code for my next experiment, which was now meant to lead me into better rendering.

When the bootloader is loaded normally, it only brings the 512 bytes around it into memory. Using [the github linked in that article](https://github.com/asdf-a11/VBE_Tutorial/blob/main/bootloader.asm), I was able to use their sector loading get larger programs working.

After getting a larger programming space, I was able to implement a new version of my text renderer which could print as if it's a console, adding text on one line and pushing all the lines up when told to print a newline. The primary code for that is here:

```nasm
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
```

The `printal` function makes use of `al`, `dl`, and `dh` as parameters for its printing. As implied by its name, `al` is the character to be printed. `dl` is responsible for holding the cursor x position, and `dh` is for the y position. `dh` is meant to be set to 24 before the main print function, so that new characters are printed on the bottom line. It doesn't do that itself, however, so that the newline shifting can make use of it. This could likely be optimized to not require that, but I'm too lazy right now.

`printnl` prints a newline, which really means it shifts the entire screen of characters up one line. I opted to make my own copy of the display in memory, rather than finding if it's stored somewhere in memory already, as it could be convenient later.

The main use of these functions will be to render memory and labels for data that I get from running BIOS interrupts for rendering data. From [OSDev's VESA Video Mode page](https://wiki.osdev.org/VESA_Video_Modes), it seems like I'll be able to query the BIOS for supported video modes. I can then hopefully use this information to grab the closest mode to 1080p, and adjust my rendering routines to it.

#### Querying Video Modes

For this section, I've used code and ideas from [OSDev VESA Video Modes](https://wiki.osdev.org/VESA_Video_Modes) and the [OSDev VESA Tutorial](https://wiki.osdev.org/User:Omarrx024/VESA_Tutorial). Initially, I copied and reinterpreted code from *VESA Video Modes* to get the supported video modes from the BIOS using `int 0x10` with `ax = 0x4f01`. After confirming that worked using my `printbyte` function, I got the code from the *VESA Tutorial* that looped through each valid video mode and checked their resolution. I checked the values stored in the `width` variable of the data section, and printed the `width` and `height` of each resolution with a `width` of 1920 (`0x780`), which resulted in `0x780 by 0x438` and `0x780 by 0x4B0`, which are 1920x1080 (16:9) and 1920x1200 (16:10), respectively.
