# NimNG

![Banner](./.github/images/banner.png)

## Overview

Nim game engine for retro consoles.

## NES

### Linux

Install `llvm-mos` toolchain:

```
https://github.com/llvm-mos/llvm-mos/releases/download/llvm-mos-linux-main/llvm-mos-linux-main.tar.xz
```

Copy contents to `toolchains/mos` so that `toolchains/mos/bin` exists.

Build package:

```
nimble nes
```

File will output as `nimng.out`.

## References

- [llvm-mos](https://github.com/llvm-mos/llvm-mos)
- [llvm-mos-sdk](https://github.com/llvm-mos/llvm-mos-sdk)
- [nesdev](https://www.nesdev.org/)
