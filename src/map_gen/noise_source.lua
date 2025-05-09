-- Adapatation of second one from https://burtleburtle.net/bob/hash/integer.html
function inthash(x)
    x = (x + 0x7ed55d16) + (bit32.lshift(x, 12))
    x = bit32.bxor((bit32.bxor(x, 0xc761c23c)), bit32.rshift(x, 19))
    x = (x + 0x165667b1) + (bit32.lshift(x, 5))
    x = bit32.bxor((x + 0xd3a2646c), bit32.lshift(x, 9))
    x = (x + 0xfd7046c5) + (bit32.lshift(x, 3))
    x = bit32.bxor(bit32.bxor(x, 0xb55a4f09), bit32.rshift(x, 16))
    return x
end
function white_noise(x, y, seed)
    return inthash(bit32.bxor(inthash(bit32.bxor(inthash(x), y)), seed))
end