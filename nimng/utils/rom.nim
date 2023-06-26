import std/enumerate
import std/md5
import strutils

func to_c[T](data: seq[T]): string =
    for d in data:
        result.add($d)
        result.add(",")

func to_uint8_seq(data: string): seq[uint8] =
    for i, c in enumerate(data):
        result.add(cast[uint8](c))

proc to_pattern*(data: string, alphabet_offset: uint8, number_offset: uint8): string =
    for c in data:
        if c.is_lower_ascii():
            result.add(cast[char]((cast[uint8](c) - cast[uint8]('a')) + alphabet_offset))
        elif c.is_upper_ascii():
            result.add(cast[char]((cast[uint8](c) - cast[uint8]('A')) + alphabet_offset))
        elif c.is_digit():
            result.add(cast[char]((cast[uint8](c) - cast[uint8]('0')) + number_offset))
        else:
            result.add('\x00')

template add_to_section*(section_name: string, data: string): void =
    {.emit: "NIM_CONST NU8 section_" & get_md5(data) & "[] __attribute__((section(\"" & section_name & "\"))) = {".}
    {.emit: to_c(to_uint8_seq(data)).}
    {.emit: "};".}
