# os.bat Explanation

## The Batch File [Source](../src/os.bat)

```batch
"C:\Program Files\nasm\nasm" -f bin boot.asm -o boot.bin
"C:\Program Files\qemu\qemu-system-i386" -fda boot.bin
```

## Files

`boot.asm` is my bootloader (just [the sample](wikibook-bootloader-sample.md) as of this stage)

`boot.bin` is the resulting binary file from compilation

## NASM

I haven't yet looked into what the NASM parameters do

My guess would be `-f bin` specifies the output file is in the `.bin` (binary) format, and `-o boot.bin` specifies what the output file is called.

## QEMU

`qemu-system-i386` is the name of the appropriate executable in QEMU for emulating an x86 machine

The `-fda` parameter for QEMU puts `boot.bin` into the `a` drive when booting the emulated machine
