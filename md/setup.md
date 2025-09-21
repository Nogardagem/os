# Setup

[Back to the README](../README.md)
This is an explanation of my process for downloading, installing, and setting up the tools I've used to make my OS. As I am using Windows, all of these explanations will (likely) be Windows-specific.

>**NOTE:** If I was to do this again (or to reset my setup for any reason), I would most likely install the programs directly in `C:/`, rather than in `C:/Program Files/`, primarily for convenience.

## NASM

[NASM](https://www.nasm.us/) is a popular choice of assembler for projects invloving the use of x86 assembly, and was the assembler of choice for me. The process for downloading and installing NASM was relatively simple. I found the [Windows x64 installer](https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/win64/) and ran it, leaving most settings alone, but ensuring it was downloaded to `C:/Program Files/nasm/`.

## QEMU

[QEMU](https://www.qemu.org/) was one of the most popular choices of emulator I could find for x86 machines. I followed a similar process to downloading NASM, finding the latest installer for windows from the [Windows install options](https://qemu.weilnetz.de/w64/) for it. I also ensured when running the installer that QEMU was placed in `C:/Program Files/qemu/`.
