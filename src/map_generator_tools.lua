require("map_gen.noise_source")
require("util")

local default_tile = settings.global["nebular-eclipse-default-tile-name"].value
function map_cleanup()
    local surface = game.surfaces["nauvis"]
    surface.map_gen_settings = {
        autoplace_controls = {},
        default_enable_all_autoplace_controls = false,
        autoplace_settings = {},
        seed = 0,
        width = 1,
        height = 1,
        starting_area = "none",
        starting_points={{x=0,y=0}},
        peaceful_mode = true,
        no_enemies_mode = true
    }
    for chunk in surface.get_chunks() do
        if chunk.x < -1 or chunk.x > 0 or chunk.y < -1 or chunk.y > 0 then
            surface.delete_chunk({chunk.x, chunk.y})
        end
    end
    tiles = {}
    local gettile = function(x, y)
        if x < -1 or x > 0 or y < -1 or y > 0 then
            if octave_noise(x, y, storage["noise_seeds"]) > 0 then
                return "out-of-map"
            else 
                return default_tile
            end
        else
            return default_tile
        end
    end
    for i=-32,31 do
        for j=-32,31 do
            table.insert(tiles, {position={i,j},name=gettile(i,j)})
        end
    end
    game.forces["player"].set_spawn_position({0, 0}, "nauvis")
    surface.set_tiles(tiles)
    surface.destroy_decoratives({{-32, -32},{31, 31}})
end
function remove_spaceship_wreck()
    local surface = game.surfaces["nauvis"]
    for _, e in ipairs(surface.find_entities()) do
        if e.type ~= "character" then
            e.destroy()
        end
    end
end

script.on_event(defines.events.on_cutscene_started, function()
    local int_max = 2^31 - 1 + 2^31
    storage["main_rng"] = game.create_random_generator()
    storage["tile_seed"] = storage["main_rng"](int_max)
    local seeds = {}
    for i=0,settings.global["nebular-eclipse-noise-octaves"].value do
        table.insert(seeds, storage["main_rng"](int_max))
    end
    storage["noise_seeds"] = seeds
    map_cleanup()
end)
script.on_event(defines.events.on_cutscene_finished, remove_spaceship_wreck)
script.on_event(defines.events.on_cutscene_cancelled, remove_spaceship_wreck)