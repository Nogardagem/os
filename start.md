# Starting
[Home](README.md)
## Where to start?
I found [OSDev](https://wiki.osdev.org/Expanded_Main_Page), which has tons of stuff on how to make your own OS.
Going to read through it and see what I get.

The [Getting Started](https://wiki.osdev.org/Getting_Started) page has been the most significantly used page so far.

## What an OS does
Via the [introduction page](https://wiki.osdev.org/Introduction) on the OSDev Wiki
Major functions of operating systems may include:
- Managing memory and other system resources.
- Imposing security and access policies.
- Scheduling and multiplexing processes and threads.
- Launching and closing user programs dynamically.
- Providing a basic user interface and application programmer interface.
Not all operating systems provide all of these functions. Single-tasking systems like MS-DOS would not schedule processes, while embedded systems like eCOS may not have a user interface, or may work with a static set of user programs.

An operating system is **not**:
- The computer hardware.
- A specific application such as a word processor, web browser or game.
- A suite of utilities (like the GNU tools, which are used in many Unix-derived systems).
- A development environment (though some OSes, such as UCSD Pascal or Smalltalk-80, incorporate an interpreter and IDE).
- A graphical user interface (though many modern operating systems incorporate a GUI as part of the OS).

## Important elements of an OS
The [kernel](https://wiki.osdev.org/Introduction#:~:text=of%20operating%20systems.-,What%20is%20a%20kernel%3F,-The%20kernel%20of), which is what handles execution of programs

The [shell](https://wiki.osdev.org/Introduction#:~:text=operation%20more%20efficiently.-,What%20is%20a%20shell%3F,-A%20shell%20is), which is the "UI" responsible for allowing the user to organize files and run programs

The [GUI](https://wiki.osdev.org/Introduction#:~:text=etc.-,What%20is%20a%20GUI%20about%3F,-The%20graphical%20user), the display that the user sees, that can catch inputs, and that can update required screen areas.

## Required knowledge
https://wiki.osdev.org/Required_Knowledge

This contains a list of required knowledge for OS development. I have about 1/2 of the bullet points already covered nicely, and the rest I will be sure to learn as I work more on this project.

The page recommends [this book](https://github.com/tuhdo/os01/blob/master/Operating_Systems_From_0_to_1.pdf) to read for beginning knowledge


[Next - Setup](setup.md)
