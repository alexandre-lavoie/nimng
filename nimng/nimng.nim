include core

import hal/nes
from utils/rom import add_to_section, to_pattern
from utils/img import pgm_parse, to_chr_rom

add_to_section ".chr_rom", static_read("../assets/empty.pgm").pgm_parse().to_chr_rom()
add_to_section ".chr_rom", static_read("../assets/font/alphabet.pgm").pgm_parse().to_chr_rom()
add_to_section ".chr_rom", static_read("../assets/font/numbers.pgm").pgm_parse().to_chr_rom()
add_to_section ".chr_rom", static_read("../assets/crown.pgm").pgm_parse().to_chr_rom()

add_to_section ".rodata", static_read("../assets/banner.txt")

const banner = "NIM".to_pattern(1, 27)

const background_palettes = [
    (NESColor(0x0e), NESColor(0x08), NESColor(0x08), NESColor(0x28))
]

const sprite_palettes = [
    (NESColor(0x00), NESColor(0x00), NESColor(0x00))
]

var t = 0'u8

proc tick(): void {.inline.} =
    if t == 32:
        t = 0
    else:
        inc t

var scroll_offset = 64'u8
var scroll_on = 0'u8

proc tick_scroll(): void {.inline.} =
    if t == 0 and scroll_on == 0'u8:
        inc scroll_offset

    if scroll_offset == 0xff:
        scroll_on = 1'u8

    ppu_scroll(scroll_offset, 0)

proc NimInterrupt(): void {.exportc.} =
    if scroll_offset == 64'u8:
        ppu_mask(PPUMask(background_enable: 1))

    tick()
    tick_scroll()

proc main(): void {.inline.} =
    var i = 0'u8
    for p in background_palettes:
        ppu_set_background_palette(i, p)
        inc i

    i = 0
    for p in sprite_palettes:
        ppu_set_sprite_palette(i, p)
        inc i

    ppu_block_vblank()

    ppu_set_ppu_address(0x2400 + 32 * 11 + 14)
    for i in countup(0x25'u8, 0x27'u8):
        ppu_write_vram(i)

    ppu_set_ppu_address(0x2400 + 32 * 12 + 14)
    for i in countup(0x28'u8, 0x2a'u8):
        ppu_write_vram(i)

    ppu_set_ppu_address(0x2400 + 32 * 13 + 14)
    for i in countup(0x2b'u8, 0x2d'u8):
        ppu_write_vram(i)

    ppu_set_ppu_address(0x2400 + 32 * 15 + 16 - banner.len() div 2 - 1)
    for p in banner:
        ppu_write_vram(cast[uint8](p))

    ppu_block_vblank()

    ppu_nmi_enable(true)

    while true:
        discard

when is_main_module:
    main()

