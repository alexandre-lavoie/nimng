import parseutils

type
    Image* = object
        width*: BiggestUInt
        height*: BiggestUInt
        max_value*: BiggestUInt
        data*: string

proc skip_pgm_comments(s: string, start: int): int =
    var i = start

    while true:
        i.inc(s.skip_whitespace(i))
        if i >= s.len() or s[i] != '#':
            break
        i.inc(1)
        i.inc(s.skipUntil('\n', i))

    result = i - start 

proc pgm_parse*(data: string): Image =
    var i = 2

    if data[0] != 'P' or (data[1] != '2' and data[1] != '5'):
        # raise new_exception(ValueError, "Invalid magic")
        return

    i.inc(data.skip_pgm_comments(i))

    i.inc(data.parse_biggest_uint(result.width, i))

    i.inc(data.skip_pgm_comments(i))

    i.inc(data.parse_biggest_uint(result.height, i))

    i.inc(data.skip_pgm_comments(i))

    i.inc(data.parse_biggest_uint(result.max_value, i))

    var p: BiggestUInt
    for _ in countup(cast[BiggestUInt](0), result.width * result.height):
        i.inc(data.skip_pgm_comments(i))
        var offset = data.parse_biggest_uint(p, i)
        i.inc(offset)

        if offset == 0:
            # raise new_exception(ValueError, "Ran out of data")
            break

        result.data.add(cast[char](p))

proc to_chr_rom*(img: Image): string =
    let quarter = (img.max_value + 1) div 4

    for i in countup(0, img.data.len() - 1, 64):
        var b1s, b2s: seq[uint8]

        for j in countup(0, 7):
            var b1: uint8 = 0
            var b2: uint8 = 0
            for k in countup(0, 7):
                let p = cast[uint8](cast[uint8](img.data[i + j * 8 + k]) div quarter)
                
                b1 = b1 shl 1
                b1 = b1 or (p and 0b1)

                b2 = b2 shl 1
                b2 = b2 or (p.shr(1) and 0b1)
            b1s.add(b1)
            b2s.add(b2)

        for b in b1s:
            result.add(cast[char](b))

        for b in b2s:
            result.add(cast[char](b))
