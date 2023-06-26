import os

const toolchain {.strdefine.} = ""

when defined(nes):
    switch("cpu", "avr")
    switch("os", "standalone")

    switch("cc", "clang")
    switch("clang.exe", toolchain / "mos-clang")
    switch("passC", "-Iinc")
    switch("passC", "-fdeclspec")
    switch("clang.linkerexe", toolchain / "ld.lld")
    switch("passL", "-Tldscripts/nes/link.ld")
    switch("passL", "-Lldscripts/nes/")
    switch("passL", "--oformat binary")
    switch("passL", "#") # Fix: Hack to remove `-ldl`

    switch("noMain", "on")
    switch("gc", "none")
    switch("opt", "size")
    switch("stackTrace", "off")
    switch("lineTrace", "off")
    switch("threads", "off")
    switch("assertions", "off")

    switch("define", "release")
    switch("define", "danger")
