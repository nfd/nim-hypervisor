Hypervisor.framework demonstration in Nim
===

This is a partial port of [hvdos](https://github.com/mist64/hvdos) to the Nim programming language. HVDos (also see [here](https://www.pagetable.com/?p=764)) demonstrates the use of macOS's [Hypervisor.framework](https://developer.apple.com/documentation/hypervisor) to load 16-bit DOS executables, and includes partial DOS emulation so that it can run some programs written for MS-DOS. This partial port starts a 16-bit hypervisor but doesn't include any DOS emulation.

You will need a Mac capable of using Hypervisor.framework.

To build and run, `nim c --run main.nim <image>` where `image` is a DOS `.COM` file, or indeed any 16-bit program with an entry point of 0x100.

