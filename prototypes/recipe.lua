require "prototypes.constants"

local channel_selector = {
    type = "recipe",
    name = "tri-channel-selector",
    ingredients = {
        { "copper-cable", 7 },
        { "electronic-circuit", 10 },
        { "red-wire", 2 },
        { "green-wire", 2 }
    },
    result = "tri-channel-selector",
    result_count = 1,
    energy_required = 0.5,
    enabled = false
}

local mux = {
    type = "recipe",
    name = "tri-mux",
    ingredients = {
        { "copper-cable", 5 },
        { "electronic-circuit", 5 },
        { "red-wire", 2 },
        { "green-wire", 2 }
    },
    result = "tri-mux",
    result_count = 1,
    energy_required = 0.5,
    enabled = false
}

local demux = {
    type = "recipe",
    name = "tri-demux",
    ingredients = {
        { "copper-cable", 5 },
        { "electronic-circuit", 5 },
        { "red-wire", 2 },
        { "green-wire", 2 }
    },
    result = "tri-demux",
    result_count = 1,
    energy_required = 0.5,
    enabled = false
}

data:extend{
    channel_selector,
    mux,
    demux
}
