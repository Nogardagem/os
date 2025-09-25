# os.bat Explanation

## The [os.bat Source](../src/os.bat)

```batch
"C:\Program Files\nasm\nasm" -f bin boot.asm -o boot.bin
"C:\Program Files\qemu\qemu-system-i386" -drive file=boot.bin,index=0,format=raw -display gtk,zoom-to-fit=on
```

## Files

Quotation marks are required around the file locations because `Program Files` contains a space.

`boot.asm` is my bootloader (just [the sample](wikibook-bootloader-sample.md) as of this stage).

`boot.bin` is the resulting binary file from assembling `boot.asm`.

All of these files, as well as `os.bat` itself, are contained in [`os/src/`](/src/).

## Executing os.bat

I executed `os.bat` via `source os.bat` in the bash terminal while in [`os/src/`](/src/)

You need to be in `os/src/` while executing the batch file because it uses relative file locations. If you were to move `os.bat` to `os/` and wanted to execute it from `os/`, then you would need to alter it to use `src/boot.asm` and `src/boot.bin`.

## NASM

I haven't yet looked into what the NASM parameters do.

My guess would be `-f bin` specifies the output file is in the `.bin` (binary) format, and `-o boot.bin` specifies what the output file is called.

## QEMU

`qemu-system-i386` is the name of the appropriate executable in QEMU for emulating an x86 machine.

The `-drive` parameter for QEMU puts a given file (`boot.bin`) into a given drive (`a`, or index 0) when booting the emulated machine. `format=raw` tells QEMU what format the drive is in so that it doesn't complain about being unsure.

More information can be found [here](https://www.qemu.org/docs/master/system/invocation.html#:~:text=add%20QMP%20command.-,%2Ddrive,-option%5B%2Coption%5B%2Coption);

`-display gtk,zoom-to-fit=on` tells qemu to default to zoom to fit the window, so that it doesn't resize it extra large after changing its resolution.
