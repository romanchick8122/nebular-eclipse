local umberima_empty_expand = {
    type = "technology",
    name = "umberima-empty-expand",
    icon = "__umberima__/graphics/umberima-empty-expand.png",
    icon_size = 256,
    upgrade = true,
    unit = {
        count_formula = "100*1.2^L",
        ingredients = { {"automation-science-pack", 1} },
        time = 60
    },
    max_level = "infinite",
    show_levels_info = true
}
data:extend{umberima_empty_expand}