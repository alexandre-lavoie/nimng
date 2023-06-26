# Package
version       = "0.1.0"
author        = "Alexandre Lavoie"
description   = "Nim on Consoles"
license       = "MIT"
srcDir        = "nimng"
bin           = @["nimng"]

# Dependencies
requires "nim >= 1.6.10"

# Consts
const llvm_mos_toolchain = "toolchains/mos/bin/"

# Tasks
task nes, "Build nes":
    exec "nimble -d:nes --nimcache:cache --define:toolchain:" & llvm_mos_toolchain & " build"

# Hooks
after build:
    rmFile("nimng.out.elf")
