"C:\Program Files\nasm\nasm" -f bin boot.asm -o boot.bin
"C:\Program Files\qemu\qemu-system-i386" -fda boot.bin