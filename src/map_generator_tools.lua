require("map_gen.noise_source")
require("map_gen.voronoi")
require("util")

local default_tile = settings.global["nebular-eclipse-default-tile-name"].value
function map_cleanup()
    local surface = game.surfaces["nauvis"]
    surface.map_gen_settings = {
        autoplace_controls = {},
        default_enable_all_autoplace_controls = false,
        autoplace_settings = {},
        seed = 0,
        width = 0,
        height = 0,
        starting_area = "none",
        starting_points={{x=0,y=0}},
        peaceful_mode = true,
        no_enemies_mode = true
    }
    game.forces["player"].set_spawn_position({0, 0}, "nauvis")
end
function remove_spaceship_wreck()
    local surface = game.surfaces["nauvis"]
    for _, e in ipairs(surface.find_entities()) do
        if e.type ~= "character" then
            e.destroy()
        end
    end


    

    local v = voronoi_init(settings.global["nebular-eclipse-voronoi-cells-per-chunk"].value)
    local function set_tile_group(tilename)
        local seed_at_0 = voronoi_closest_seed(v, 0, 0, false)
        local seeds = voronoi_expand_seed(v,seed_at_0,10)
        surface.set_tiles(map(voronoi_get_tileset(v, seeds), function(pos) return {position=pos,name=tilename} end), true, false)
        for i,seed in ipairs(seeds) do
            surface.set_tiles({{position=seed.pos,name="lab-white"}}, true, false)
            seed.assigned=true
        end
    end
    commands.add_command("ne-add-area", nil, function(command)
        set_tile_group(command.parameter)
    end)
end
script.on_event(defines.events.on_chunk_generated, function(e)
    local tiles = {}
    for x = e.area.left_top.x, e.area.right_bottom.x do for y = e.area.left_top.y,e.area.right_bottom.y do
        if (x * x + y * y) > 4 then
            table.insert(tiles, {position={x, y}, name="out-of-map"})
        end
    end end
    game.surfaces["nauvis"].set_tiles(tiles)
end)
script.on_event(defines.events.on_cutscene_started, function()
    local int_max = 2^31 - 1 + 2^31
    storage["main_rng"] = game.create_random_generator()
    local function gen_seeds(count)
        local seeds = {}
        for i=1,count do
            table.insert(seeds, storage["main_rng"](int_max))
        end
        return seeds
    end
    storage["noise_seeds_x"] = gen_seeds(settings.global["nebular-eclipse-noise-octaves"].value)
    storage["noise_seeds_y"] = gen_seeds(settings.global["nebular-eclipse-noise-octaves"].value)
    storage["voronoi_rng"] = game.create_random_generator(storage["main_rng"](int_max))
    map_cleanup()
end)
script.on_event(defines.events.on_cutscene_finished, remove_spaceship_wreck)
script.on_event(defines.events.on_cutscene_cancelled, remove_spaceship_wreck)