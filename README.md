# OS

A project describing my process of making (or failing to make) my own OS

> I'll be changing each of these documents as I go to keep the most relevant/useful information. I'd like this to support me (and hopefully others) in being able to reproduce this project.
>
> Everything in [the old README](old/old-read.md) was before I made the realization I will describe in the next section.

## Making My OS Using Only x86 Assembly

The main idea of this project is to make an operating system from scratch, with no prebuilt classes or objects or anything like that, simply creating the binary files that'll run on a new empty machine. Of course, I'm not quite insane enough to work in plain binary (at least, not yet), but I don't want to use any tools beyond x86 assembly to create this OS.

In [the old files](old/old-read.md), I started my process by using a tutorial on the [OSDev](https://wiki.osdev.org/) website. That tutorial, however, assumed the reader wanted to create an OS using C/C++ as their primary programming language, and included many steps specific to that.

Instead, I want to use only assembly ([why?](md/why-only-assembly.md)), which (surprisingly) makes the early steps of OS development a little easier.

## Where I Started

After learning OSDev wasn't the tool for me, I began researching what I needed to do to get an assembly bootloader working (since by [the end of that tutorial](https://wiki.osdev.org/Bare_Bones#Building_a_Cross-Compiler:~:text=the%20above%20files-,Booting%20the%20Operating%20System,-To%20start%20the) I had learned I would need one). The first useful page I came across was the [WikiBook for x86 Assembly chapter on bootloaders](https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders), which contains a [sample bootloader](references/wikibook-bootloader-sample.md) for an x86 OS. As this sample was designed for [NASM](https://www.nasm.us/), and I had already heard good things about it as an assembler, it has been chosen as the assembler for this project. I explain downloading and setting it up in [setup.md](md/setup.md). Similarly, I wanted to use an emulator for the start of this project (so I don't break any hardware), and as mentioned by both OSDev and the WikiBook, [QEMU](https://www.qemu.org/) was one of the best emulators to use. The process for downloading and using that was again described in [setup.md](md/setup.md).
