function voronoi_init(seeds_per_chunk)
    return { seeds = {}, seeds_per_chunk = seeds_per_chunk}
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
        table.insert(seeds, {pos={seedx, seedy},active=storage["voronoi_rng"]() > 0.5})
    end
    state.seeds[x][y] = seeds
end
local function distance_squared(p1, p2)
    local dx = p1[1] - p2[1]
    local dy = p1[2] - p2[2]
    return dx * dx + dy * dy
end
function voronoi_closest_seed(state, x, y)
    local chunk_x = math.floor(x / 32)
    local chunk_y = math.floor(y / 32)
    local pos = {x, y}

    voronoi_mk_seeds(state, chunk_x, chunk_y)
    local best_seed = state.seeds[chunk_x][chunk_y][1]
    local best_dist = distance_squared(pos, best_seed.pos)

    for dx=-1,1 do
        for dy=-1,1 do
            voronoi_mk_seeds(state, chunk_x + dx, chunk_y + dy)
            for i,seed in ipairs(state.seeds[chunk_x + dx][chunk_y + dy]) do
                local distance = distance_squared(pos, seed.pos)
                if distance < best_dist then
                    best_seed = seed
                    best_dist = distance
                end
            end
        end
    end
    return best_seed
end