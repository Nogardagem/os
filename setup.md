# Setup

[Home](README.md) [Previous - Start](start.md)

[OSDev Bare Bones Tutorial](https://wiki.osdev.org/Bare_Bones#Booting_the_Operating_System:~:text=External%20Links-,Building%20a%20Cross%2DCompiler,-Main%20article%3A)

## GCC Cross Compiler

The GCC Cross Compiler is what's required to compile any code being written into its eventual final form as machine code.

To set up the cross compiler for Windows, you need to have [Cygwin](https://wiki.osdev.org/Cygwin), which is essentially an emulation of a UNIX environment to build code in

### Cygwin

[Cygwin.com](https://www.cygwin.com/) is the website to download

For the sake of this "attempt" (if I need to do this again), I downloaded Cygwin directly in my `C:` drive.

For windows, [this](https://wiki.osdev.org/GCC_Cross-Compiler#Preparing_for_the_build:~:text=build%20from%20there-,Windows%20Users,-Windows%20users%20need) is where the required Cygwin packages are. Add these in from the setup/installer program downloaded from [the Cygwin install page](http://cygwin.com/install.html).

The package selector thing is weird, but to select a package for download you just search in the search bar, then double-click on "skip" and it'll switch to the latest release version to be downloaded.

### Back to GCC Cross Compiler Stuff

I somehow skipped over this, but **it is important**. You need to [download the source code](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=directory%20such%20as-,%24HOME/src,-%3A) into the `$HOME/src` directory (`C:\cygwin64\home\[username]\src` in Cygwin).

The GNU main mirror version of each is best, sorting the lists by last modified to get the most recent versions, and then downloading those as `.tar.gz`. To transfer the files to the appropriate directory, I simply selected the main folder in the `.tar.gz` and dragged it over to a window with the directory open, which extracted those contents into the right folders. Note that one of them is *very large*, and so the extraction/copy will take a while.

The next step is [the build](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=%2D%2Ddisable%2Dlto-,The%20Build,-We%20build%20a) of the GCC Cross Compiler. As given at the start of this section, the recommended install location for the compiler is in `$Home/opt/cross`, which in Cygwin translates to `C:\cygwin64\home\[username]\opt\cross`.

Below the section shows commands for running in the console, in my case the Cygwin terminal. I recommend reading the rest of my process before attempting to run the commands.

> **NOTE**: When the commands say `binutils-x.y.z` and `gcc-x.y.z`, they mean to replace `x.y.z` with the version you installed (or rather, the name of the install directory). In my case, this was `binutils-2.45` and `gcc-15.2.0`.

Some of the steps will take a decent amount of time. In the [Binutils section](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=make%0Amake%20install-,This,-compiles%20the%20binutils), the most notable was `make`, which took about 15 minutes.

For the sake of what I'm doing, I *believe* I can skip the [GDB section](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=useful%20later%20on.-,GDB,-It%20may%20be), as it seems to be optional.

> **NOTE for the [GCC section](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=have%20any%20effect.-,GCC,-See%20also%20the)**: It might make sense to take note of which of the `make` commands you're on, since there are 6 of them in a row and it *may* cause problems if you attempt to re-run one.

- [ ] all-gcc
- [ ] all-target-libgcc
- [ ] all-target-libstdc++-v3
- [ ] install-gcc
- [ ] install-target-libgcc
- [ ] install-target-libstdc++-v3

Of course, if the commands have changed as of the latest version of the OSDev docs, then you should use the new ones instead.

After reaching the line starting with `which`, I go the error echoed, so I needed to go back and restart from [preparation](https://wiki.osdev.org/GCC_Cross-Compiler#:~:text=for%20older%20versions.-,Preparation,-export%20PREFIX%3D), after deleting everything from the `$HOME/scr/build-binutils` directory. This appears to have fixed it.


