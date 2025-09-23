"C:\Program Files\nasm\nasm" -f bin boot.asm -o boot.bin
"C:\Program Files\qemu\qemu-system-i386" -drive file=boot.bin,index=0,format=raw