require("util")

local hidden_settings = {
    strings = {
        {"nebular-eclipse-default-tile-name", "lab-white"}
    }
}

data:extend(map(hidden_settings.strings, function(opt)
    return {
        type = "string-setting",
        name = opt[1],
        setting_type = "runtime-global",
        hidden = true,
        allowed_values = { opt[2] },
        default_value = opt[2]
    }
end))


data:extend({
    {
        type = "double-setting",
        name = "nebular-eclipse-noise-scale",
        setting_type = "runtime-global",
        minimum_value = 1,
        default_value = 2
    },{
        type = "int-setting",
        name = "nebular-eclipse-noise-octaves",
        setting_type = "runtime-global",
        minimum_value = 1,
        default_value = 4
    },{
        type = "double-setting",
        name = "nebular-eclipse-noise-lacunarity",
        setting_type = "runtime-global",
        default_value = 2
    },{
        type = "double-setting",
        name = "nebular-eclipse-noise-persistence",
        setting_type = "runtime-global",
        default_value = 0.5
    },{
        type = "int-setting",
        name = "nebular-eclipse-voronoi-cells-per-chunk",
        setting_type = "runtime-global",
        default_value = 7,
        minimum_value = 1,
        maximum_value = 20
    },{
        type = "double-setting",
        name = "nebular-eclipse-voronoi-distortion-impact",
        setting_type = "runtime-global",
        default_value = 5,
        minimum_value = 0
    }
})