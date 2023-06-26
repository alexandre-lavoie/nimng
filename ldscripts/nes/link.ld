INCLUDE nes-cfg.ld

__rc0 = 0x00;
__rc1 = __rc0 + 1;
PROVIDE(__rc2 = __rc1 + 1);
__rc3 = __rc2 + 1;
PROVIDE(__rc4 = __rc3 + 1);
__rc5 = __rc4 + 1;
PROVIDE(__rc6 = __rc5 + 1);
__rc7 = __rc6 + 1;
PROVIDE(__rc8 = __rc7 + 1);
__rc9 = __rc8 + 1;
PROVIDE(__rc10 = __rc9 + 1);
__rc11 = __rc10 + 1;
PROVIDE(__rc12 = __rc11 + 1);
__rc13 = __rc12 + 1;
PROVIDE(__rc14 = __rc13 + 1);
__rc15 = __rc14 + 1;
PROVIDE(__rc16 = __rc15 + 1);
__rc17 = __rc16 + 1;
PROVIDE(__rc18 = __rc17 + 1);
__rc19 = __rc18 + 1;
PROVIDE(__rc20 = __rc19 + 1);
__rc21 = __rc20 + 1;
PROVIDE(__rc22 = __rc21 + 1);
__rc23 = __rc22 + 1;
PROVIDE(__rc24 = __rc23 + 1);
__rc25 = __rc24 + 1;
PROVIDE(__rc26 = __rc25 + 1);
__rc27 = __rc26 + 1;
PROVIDE(__rc28 = __rc27 + 1);
__rc29 = __rc28 + 1;
PROVIDE(__rc30 = __rc29 + 1);
__rc31 = __rc30 + 1;

ASSERT(__rc31 == 0x1f, "Inconsistent zero page map.")

ASSERT(__prg_rom_size == 1 << LOG2CEIL(__prg_rom_size),
       "PRG-ROM size must be a power of 2.")
ASSERT(__chr_rom_size == 0 || __chr_rom_size == 1 << LOG2CEIL(__chr_rom_size),
       "CHR-ROM size must be a power of 2.")
ASSERT(__prg_ram_size == 0 ||
       __prg_ram_size == 1 << LOG2CEIL(__prg_ram_size),
       "Nonempty PRG-RAM must be a power of 2.")
ASSERT(__prg_nvram_size == 0 ||
       __prg_nvram_size == 1 << LOG2CEIL(__prg_nvram_size),
       "Nonempty PRG-NVRAM must be a power of 2.")
ASSERT(__chr_ram_size == 0 ||
       __chr_ram_size == 1 << LOG2CEIL(__chr_ram_size),
       "Nonempty CHR-RAM must be a power of 2.")
ASSERT(__chr_nvram_size == 0 ||
       __chr_nvram_size == 1 << LOG2CEIL(__chr_nvram_size),
       "Nonempty CHR-NVRAM must be a power of 2.")

__prg_rom_lma = __prg_rom_size == 32 ? 0x8000 : 0xC000;

MEMORY {
    ram : ORIGIN = __rc31 + 1, LENGTH = 0x0800 - (__rc31 + 1)

    prg_rom (rx) : ORIGIN = __prg_rom_lma, LENGTH = __prg_rom_size * 1024
    chr_rom : ORIGIN = 0x01000000, LENGTH = __chr_rom_size * 1024
}

REGION_ALIAS("c_rom", prg_rom)
REGION_ALIAS("c_ram", ram)

SECTIONS {
    .text : {
        _start = .;

        *(.text .text.*)
    } >c_rom

    .rodata : { 
        *(.rodata .rodata.*) 
    } >c_rom

    .data : { 
        __data_start = .;
        *(.data .data.*)
        __data_end = .;
    } >c_ram
    __data_load_start = LOADADDR(.data);
    __data_size = SIZEOF(.data);

    .bss : { 
        __bss_start = .;
        *(.bss .bss.* COMMON)
        __bss_end = .;
    } >c_ram
    __bss_size = SIZEOF(.bss);

    .noinit (NOLOAD) : { 
        *(.noinit .noinit.*)
        __heap_start = .;
    } >c_ram

    .vector 0xfffa : { SHORT(_interrupt) SHORT(_start) SHORT(0) } >prg_rom

    .chr_rom : { 
        KEEP(*(.chr_rom .chr_rom.*)) 
    } >chr_rom
}

OUTPUT_FORMAT {
    INCLUDE ines-header.ld

    FULL(prg_rom)
    FULL(chr_rom)
}
