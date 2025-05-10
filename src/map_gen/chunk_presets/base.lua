function create_land_chunk(surface, tiles) 
    game.surfaces[surface].set_tiles(map(tiles, function(pos) return {position=pos,name="grass-1"} end), true, false)
end