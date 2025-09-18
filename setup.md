# Setup
[Home](README.md) [Previous - Start](start.md)

[OSDev Bare Bones Tutorial](https://wiki.osdev.org/Bare_Bones#Booting_the_Operating_System:~:text=External%20Links-,Building%20a%20Cross%2DCompiler,-Main%20article%3A)
## GCC Cross Compiler
The GCC Cross Compiler is what's required to compile any code being written into its eventual final form as machine code.

To set up the cross compiler for Windows, you need to have [Cygwin](https://wiki.osdev.org/Cygwin), which is essentially an emulation of a UNIX environment to build code in
### Cygwin
[Cygwin.com](https://www.cygwin.com/) is the website to download

For windows, [this](https://wiki.osdev.org/GCC_Cross-Compiler#Preparing_for_the_build:~:text=build%20from%20there-,Windows%20Users,-Windows%20users%20need) is where the required Cygwin packages are. Add these in from the setup/installer program downloaded from [the Cygwin install page](http://cygwin.com/install.html).

The package selector thing is weird, but to select a package for download you just search in the search bar, then double-click on "skip" and it'll switch to the latest release version to be downloaded.

### Back to GCC Cross Compiler Stuff
