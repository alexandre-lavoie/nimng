when defined(nes):
    func NimMainModule() {.importc.}
    func `"_start"`() {.exportc, no_return.} =
        NimMainModule()

        while true:
            discard

    from hal/nes import ppu_nmi_enable
    func NimInterrupt() {.importc.}
    func `"_interrupt"`() {.exportc, no_return.} =
        ppu_nmi_enable(false)
        NimInterrupt()
        ppu_nmi_enable(true)

        asm "rti"

    func memset(dest: pointer, b: uint8, size: csize_t): pointer {.exportc.} =
        var d = cast[csize_t](dest)
        var i = size

        while i > 0:
            cast[ptr uint8](d)[] = b

            d.inc
            i.dec

        return dest

    func memcpy(dest: pointer, src: pointer, size: csize_t): pointer {.exportc.} =
        var d = cast[csize_t](dest)
        var s = cast[csize_t](src)
        var i = size

        while i > 0:
            cast[ptr uint8](d)[] = cast[ptr uint8](s)[]

            d.inc
            s.inc
            i.dec

    {.push stackTrace:off.}
    proc `"__call_indir"`() {.exportc, no_return.} =
        asm """
        jmp (__rc18)
        """

    func `"__memset"`(dest: pointer, b: uint8, size: csize_t): void {.exportc.} =
        var d = cast[csize_t](dest)
        var i = size

        while i > 0:
            cast[ptr uint8](d)[] = b

            d.inc
            i.dec
    {.pop.}
