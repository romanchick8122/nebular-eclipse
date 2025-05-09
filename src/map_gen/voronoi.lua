require("noise_source")
local nop = {}

function voronoi_init(seeds_per_chunk)
    return { seeds = {}, seeds_per_chunk = seeds_per_chunk, try_continue_seeds = {}}
end
local function voronoi_mk_seeds(state, x, y)
    if state.seeds[x] and state.seeds[x][y] then
        return
    end
    if not (state.seeds[x]) then
        state.seeds[x] = {}
    end
    local seeds = {}
    for i=1,state.seeds_per_chunk do
        local seedx = storage["voronoi_rng"](x * 32, (x + 1) * 32 - 1)
        local seedy = storage["voronoi_rng"](y * 32, (y + 1) * 32 - 1)
        table.insert(seeds, {pos={seedx, seedy},disabled=false,assigned=false})
    end
    state.seeds[x][y] = seeds
end
local function touch_chunk(state, x, y)
    for dx=-1,1 do for dy=-1,1 do
        voronoi_mk_seeds(state, x + dx, y + dy)
    end end
end
local function distance_squared(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]
    return dx * dx + dy * dy
end
function voronoi_closest_seed(state, x, y, includeAssigned)
    local chunk_x = math.floor(x / 32)
    local chunk_y = math.floor(y / 32)
    local pos = {x, y}
    touch_chunk(state, chunk_x, chunk_y)
    local best_seed = nil
    local best_dist = math.huge

    for dx=-1,1 do for dy=-1,1 do
        for i,seed in ipairs(state.seeds[chunk_x + dx][chunk_y + dy]) do if (not seed.disabled) and ((not seed.assigned) or includeAssigned) then
            local distance = distance_squared(pos, seed.pos)
            if distance < best_dist then
                best_seed = seed
                best_dist = distance
            end
        end end
    end end
    return best_seed
end
function voronoi_get_tileset(state, seeds)
    local seed_x = storage["noise_seeds_x"]
    local seed_y = storage["noise_seeds_y"]
    local offset_scale = settings.global["nebular-eclipse-voronoi-distortion-impact"].value
    local tiles = {}
    local seed_lut = {}
    local bbminx = math.huge
    local bbminy = math.huge
    local bbmaxx = -math.huge
    local bbmaxy = -math.huge
    for i,seed in ipairs(seeds) do
        seed_lut[seed] = nop
        bbminx = math.min(bbminx, seed.pos[1])
        bbmaxx = math.max(bbmaxx, seed.pos[1])
        bbminy = math.min(bbminy, seed.pos[2])
        bbmaxy = math.max(bbmaxy, seed.pos[2])
    end
    bbminx = bbminx - 32
    bbminy = bbminy - 32
    bbmaxx = bbmaxx + 32
    bbmaxy = bbmaxy + 32
    for x=bbminx,bbmaxx do for y=bbminy,bbmaxy do
        local offset_x = octave_noise(x, y, seed_x) * offset_scale
        local offset_y = octave_noise(x, y, seed_y) * offset_scale
        if seed_lut[voronoi_closest_seed(state, x + offset_x, y + offset_y, true)] then
            table.insert(tiles, {x, y})
        end
    end end
    return tiles
end
function voronoi_expand_seed(state,seed,count)
    local result = {}
    local curr = seed
    while curr and #result < count do
        table.insert(result, curr)
        curr.disabled = true
        curr = voronoi_closest_seed(state,curr.pos[1],curr.pos[2], false)
    end
    for i,sd in ipairs(result) do
        sd.disabled = false
    end
    return result
end
function voronoi_get_map_expansion_tiles(state)

    local continue_seed_index = nil
    local expansion_seed = nil
    while not expansion_seed do
        if continue_seed_index then
            local ln = #state.try_continue_seeds
            state.try_continue_seeds[continue_seed_index] = state.try_continue_seeds[ln]
            state.try_continue_seeds[ln] = nil
        end
        if #(state.try_continue_seeds) == 0 then
            table.insert(state.try_continue_seeds, voronoi_closest_seed(state, 0, 0))
        end
        continue_seed_index = storage["voronoi_rng"](#(state.try_continue_seeds))
        local pos = state.try_continue_seeds[continue_seed_index].pos
        expansion_seed = voronoi_closest_seed(state, pos[1], pos[2], false)
    end
    local seeds = voronoi_expand_seed(state,expansion_seed,settings.global["nebular-eclipse-voronoi-cells-per-expansion"].value)
    local result = voronoi_get_tileset(state, seeds)
    for i,seed in ipairs(seeds) do
        seed.assigned=true
        table.insert(state.try_continue_seeds, seed)
    end
    return result
end