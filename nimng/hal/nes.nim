from std/volatile import volatile_load, volatile_store

type
    NESColor* = uint8
    NESBackgroundPalette* = (NESColor, NESColor, NESColor, NESColor)
    NESSpritePalette* = (NESColor, NESColor, NESColor)

type
    NESController* = object
        # TODO: Check order
        right* {.bitsize:1.}: uint8
        left* {.bitsize:1.}: uint8
        down* {.bitsize:1.}: uint8
        up* {.bitsize:1.}: uint8
        start* {.bitsize:1.}: uint8
        select* {.bitsize:1.}: uint8
        b* {.bitsize:1.}: uint8
        a* {.bitsize:1.}: uint8

const CONTROLLER_1*: ptr NESController = cast[ptr NESController](0x4016)
const CONTROLLER_2*: ptr NESController = cast[ptr NESController](0x4017)

type
    PPUCtrl* = object
        # TODO: Double check order
        nametable_select* {.bitsize:2.}: uint8
        increment_mode* {.bitsize:1.}: uint8
        sprite_select* {.bitsize:1.}: uint8
        background_select* {.bitsize:1.}: uint8
        sprite_height* {.bitsize:1.}: uint8
        master_slave* {.bitsize:1.}: uint8
        nmi_enable* {.bitsize:1.}: uint8

    PPUMask* = object
        # TODO: Double check order
        greyscale* {.bitsize:1.}: uint8
        background_col_enable* {.bitsize:1.}: uint8
        sprite_col_enable* {.bitsize:1.}: uint8
        background_enable* {.bitsize:1.}: uint8
        sprite_enable* {.bitsize:1.}: uint8
        color_emphasis* {.bitsize:3.}: uint8

    PPUStatus* = object
        unused {.bitsize:5}: uint8
        sprite_overflow* {.bitsize:1}: uint8
        sprite_hit* {.bitsize:1}: uint8
        vblank* {.bitsize:1}: uint8

    PPUObject* = object
        ctrl*: PPUCtrl
        mask*: PPUMask
        status*: PPUStatus
        oam_address*: uint8
        oam_data*: uint8
        scroll*: uint8
        ppu_address*: uint8
        ppu_data*: uint8

const PPU_ADDRESS: csize_t = 0x2000
const PPU_BACKGROUND_PALETTE_ADDRESS: uint16 = 0x3f00
const PPU_SPRITE_PALETTE_ADDRESS: uint16 = 0x3f10
const PPU: ptr PPUObject = cast[ptr PPUObject](PPU_ADDRESS)

proc ppu_mask*(mask: PPUMask): void {.inline.} = 
    (addr PPU.mask).volatile_store(mask)

proc ppu_set_ppu_address*(address: uint16): void {.inline.} =
    (addr PPU.ppu_address).volatile_store(cast[uint8](address.shr(8)))
    (addr PPU.ppu_address).volatile_store(cast[uint8](address))

proc ppu_write_vram*(data: uint8): void {.inline.} =
    (addr PPU.ppu_data).volatile_store(cast[uint8](data))

proc ppu_set_inc*(state: bool): void {.inline.} =
    # True: increment by 32
    # False: increment by 1

    PPU.ctrl.increment_mode = cast[uint8](state)

proc ppu_nmi_enable*(state: bool): void {.inline.} =
    PPU.ctrl.nmi_enable = cast[uint8](state)

proc ppu_select_background*(state: bool): void {.inline.} =
    var ctrl = PPU.ctrl
    ctrl.background_select = cast[uint8](state)
    (addr PPU.ctrl).volatile_store(ctrl)

proc ppu_set_background_palette*(index: uint8, palette: NESBackgroundPalette): void {.inline.} =
    ppu_set_inc(false)
    ppu_set_ppu_address(cast[uint16](PPU_BACKGROUND_PALETTE_ADDRESS + index * 4))
    ppu_write_vram(palette[0])
    ppu_write_vram(palette[1])
    ppu_write_vram(palette[2])
    ppu_write_vram(palette[3])

proc ppu_set_sprite_palette*(index: uint8, palette: NESSpritePalette): void {.inline.} =
    ppu_set_inc(false)
    ppu_set_ppu_address(cast[uint16](PPU_SPRITE_PALETTE_ADDRESS + index * 4 + 1))
    ppu_write_vram(palette[0])
    ppu_write_vram(palette[1])
    ppu_write_vram(palette[2])

proc ppu_scroll*(x: uint8, y: uint8): void {.inline.} =
    (addr PPU.scroll).volatile_store(x)
    (addr PPU.scroll).volatile_store(y)

proc ppu_block_vblank*(): void {.inline.} =
    while PPU.volatile_load.status.vblank == 0:
        discard
