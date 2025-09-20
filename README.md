# OS

A project describing my process of making (or failing to make) my own OS

I'll be adding/changing/removing text in each of these documents as I go to keep the most relevant and useful information. I'd like this to at least support me being able to reproduce the steps involved in this process, but I would also like it to be kind enough that anyone could follow along for the same outcome.

Everything in [the old README](old/old-read.md) was before I made the realization I will describe in the next section:

## Making my OS Using Only x86 Assembly

The main idea of this process was to make an OS from scratch, with no prebuilt classes or objects or anything like that, simply creating the binary files that would run on a new empty machine. Of course, I'm not quite insane enough to work in plain binary (at least, not yet as of writing this), but I don't want to use any tools beyond x86 assembly to create this OS.

In [the old files](old/old-read.md), as mentioned earlier, I started my process by using a tutorial on the [OSDev](https://wiki.osdev.org/) website. That tutorial, however, assumed the reader wanted to create an OS using C/C++ as their primary programming language, and included many steps specific to that.

I, on the other hand, only want to use assembly, which (surprisingly) makes the early steps of OS development easier.

## Where I Started

After learning OSDev wasn't the tool for me, I began researching what I needed to do to get an assembly bootloader working (since by [the end of that tutorial](https://wiki.osdev.org/Bare_Bones#Building_a_Cross-Compiler:~:text=the%20above%20files-,Booting%20the%20Operating%20System,-To%20start%20the) I had learned I would need one). The first useful page I came across was the [wikibooks for x86 Assembly chapter on bootloaders](https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders), which contains a [sample bootloader](references/wikibook-bootloader-sample.md) for an x86 OS.
