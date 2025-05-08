script.on_init(function()
    local surface = game.surfaces["nauvis"]
    surface.map_gen_settings = {
        autoplace_controls = {},
        default_enable_all_autoplace_controls = false,
        autoplace_settings = {},
        seed = 0,
        width = 1,
        height = 1,
        starting_area = "none",
        peaceful_mode = true,
        no_enemies_mode = true
    }
    for chunk in surface.get_chunks() do
        surface.delete_chunk({chunk.x, chunk.y})
    end
end)