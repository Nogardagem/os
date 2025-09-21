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
"C:\Program Files\qemu\qemu-system-i386" -fda boot.bin
```

Surprisingly, this was all it took to get a working bootloader. After [executing `os.bat`](references/os-bat-explanation.md#executing-osbat), QEMU opened and displayed my OS, which according to the sample was filling the screen with copies of `Hello, World!` and looping at the screen's edges.
