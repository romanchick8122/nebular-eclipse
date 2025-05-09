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