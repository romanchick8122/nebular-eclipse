local function compute_edge_distance(tiles)
    local lut = {}
    for _,tile in ipairs(tiles) do
        if not (lut[tile[1]]) then
            lut[tile[1]] = {}
        end
        lut[tile[1]][tile[2]] = tile
    end
    local function check_tile(tile, dx, dy)
        return lut[tile[1] + dx] and lut[tile[1] + dx][tile[2] + dy]
    end
    local bfsq = {}
    local rptr = 1
    local wptr = 1
    for _,tile in ipairs(tiles) do
        if not (check_tile(tile, -1, 0) and check_tile(tile, 1, 0) and check_tile(tile, 0, -1) and check_tile(tile, 0, 1)) then
            bfsq[wptr] = {tile, 0}
            wptr = wptr + 1
        end
    end
    for i=1,(wptr-1) do
        local x = bfsq[i][1][1]
        local y = bfsq[i][1][2]
        lut[x][y] = nil
    end
    local function queue_tile(tile, dx, dy, dist)
        if not check_tile(tile, dx, dy) then return end
        local tx = tile[1] + dx
        local ty = tile[2] + dy
        bfsq[wptr] = {lut[tx][ty], dist + 1}
        wptr = wptr + 1
        lut[tx][ty] = nil
    end
    while rptr < wptr do
        local curr = bfsq[rptr]
        rptr = rptr + 1
        queue_tile(curr[1], -1, 0, curr[2])
        queue_tile(curr[1], 1, 0, curr[2])
        queue_tile(curr[1], 0, -1, curr[2])
        queue_tile(curr[1], 0, 1, curr[2])
    end
    return bfsq
end
function create_land_chunk(surface, tiles)
    local tiles_upd = map(compute_edge_distance(tiles), function (item)
        local tile_type = nil
        if (item[2] == 0) then tile_type = "sand-1"
        elseif (item[2] == 1) then tile_type = "dirt-1"
        elseif (item[2] == 2) then tile_type = "grass-1"
        else tile_type = "water"
        end
        return {position = item[1], name=tile_type}
    end)
    game.surfaces[surface].set_tiles(tiles_upd, true, false)
end