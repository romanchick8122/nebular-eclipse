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
    local v = voronoi_init(settings.global["nebular-eclipse-voronoi-cells-per-chunk"].value)
    local noise_offset_scale = settings.global["nebular-eclipse-voronoi-distortion-impact"].value
    local gettile = function(x, y)
        if x < -1 or x > 0 or y < -1 or y > 0 then
            local noise_vx = octave_noise(x, y, storage["noise_seeds_x"])
            local noise_vy = octave_noise(x, y, storage["noise_seeds_y"])
            return voronoi_closest_seed(v, x + noise_vx * noise_offset_scale, y + noise_vy * noise_offset_scale).active and "water" or "grass-1"
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



    
    surface.set_tiles(map(v.seeds[0][0], function(x) return {position=x.pos,name=(x.active and "water" or "grass-1")} end))
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