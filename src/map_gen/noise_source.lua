-- Adapatation of second one from https://burtleburtle.net/bob/hash/integer.html
local function inthash(x)
    x = (x + 0x7ed55d16) + (bit32.lshift(x, 12))
    x = bit32.bxor((bit32.bxor(x, 0xc761c23c)), bit32.rshift(x, 19))
    x = (x + 0x165667b1) + (bit32.lshift(x, 5))
    x = bit32.bxor((x + 0xd3a2646c), bit32.lshift(x, 9))
    x = (x + 0xfd7046c5) + (bit32.lshift(x, 3))
    x = bit32.bxor(bit32.bxor(x, 0xb55a4f09), bit32.rshift(x, 16))
    return x
end
function white_noise(x, y, seed)
    return inthash(bit32.bxor(inthash(bit32.bxor(inthash(x), y)), seed)) / 2^32
end
local function gradient_at(x, y, seed)
    local ang = white_noise(x, y, seed) * math.pi * 2
    return {math.cos(ang), math.sin(ang)}
end
local function dot(a, b)
    return a[1] * b[1] + a[2] * b[2]
end
local function smoothstep(x)
    if x < 0 then
        return 0
    elseif x > 1 then
        return 1
    else
        return x * x * (3 - 2 * x)
    end
end
local function interpolate(v0, v1, x)
    return v0 + smoothstep(x) * (v1 - v0)
end
function perlin_noise(x, y, seed)
    local x_min = math.floor(x)
    local y_min = math.floor(y)
    local x_max = x_min + 1
    local y_max = y_min + 1

    local g1 = dot(gradient_at(x_min, y_min, seed), {x - x_min, y - y_min})
    local g2 = dot(gradient_at(x_min, y_max, seed), {x - x_min, y - y_max})
    local g3 = dot(gradient_at(x_max, y_min, seed), {x - x_max, y - y_min})
    local g4 = dot(gradient_at(x_max, y_max, seed), {x - x_max, y - y_max})

    local v1 = interpolate(g1, g2, y - y_min)
    local v2 = interpolate(g3, g4, y - y_min)

    return interpolate(v1, v2, x - x_min)
end
local scale = settings.global["nebular-eclipse-noise-scale"].value
local octaves = settings.global["nebular-eclipse-noise-octaves"].value
local lacunarity = settings.global["nebular-eclipse-noise-lacunarity"].value
local persistence = settings.global["nebular-eclipse-noise-persistence"].value
function octave_noise(x, y, seeds)
    local cscale = scale
    local camp = 1
    local renorm = 0
    local total = 0
    for _,seed in ipairs(seeds) do
        total = total + perlin_noise(x / cscale, y / cscale, seed) * camp
        renorm = renorm + camp
        cscale = cscale * lacunarity
        camp = camp * persistence
    end
    return total / renorm
end