require("map_gen.noise_source")
require("map_gen.voronoi")
require("map_gen.chunk_presets.base")
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

script.on_event(defines.events.on_chunk_generated, function(e)
    local tiles = {}
    for x = e.area.left_top.x, e.area.right_bottom.x do for y = e.area.left_top.y,e.area.right_bottom.y do
        if (x * x + y * y) > 4 then
            table.insert(tiles, {position={x, y}, name="out-of-map"})
        end
    end end
    game.surfaces["nauvis"].set_tiles(tiles)
end)
script.on_event(defines.events.on_player_created, function()
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
    storage["tree_gen_white_seed"] = storage["main_rng"](int_max)
    storage["tree_gen_perlin_seed"] = storage["main_rng"](int_max)
    map_cleanup()

    storage["surface_data"] = {
        ["nauvis"] = {
            voronoi = voronoi_init(settings.global["nebular-eclipse-voronoi-cells-per-chunk"].value)
        }
    }
    commands.add_command("ne-add-area", nil, function(command)
        create_land_chunk("nauvis", voronoi_get_map_expansion_tiles(storage["surface_data"]["nauvis"].voronoi))
    end)
    commands.add_command("ne-add-tree", nil, function (command)
        create_tree_chunk("nauvis", voronoi_get_map_expansion_tiles(storage["surface_data"]["nauvis"].voronoi))
    end)
end)


local function remove_spaceship_wreck()
    local surface = game.surfaces["nauvis"]
    for _, e in ipairs(surface.find_entities()) do
        if e.type ~= "character" then
            e.destroy()
        end
    end
end
script.on_event(defines.events.on_cutscene_finished, remove_spaceship_wreck)
script.on_event(defines.events.on_cutscene_cancelled, remove_spaceship_wreck)