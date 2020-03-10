require "prototypes.constants"

local channel_selector = table.deepcopy(data.raw.item["constant-combinator"])
channel_selector.name = "tri-channel-selector"
channel_selector.icon = ICONS .. "channel-selector.png"
channel_selector.icon_size = 32
channel_selector.place_result = "tri-channel-selector"

local mux = table.deepcopy(data.raw.item["decider-combinator"])
mux.name = "tri-mux"
mux.icon = ICONS .. "mux.png"
mux.icon_size = 32
mux.place_result = "tri-mux"

local demux = table.deepcopy(data.raw.item["decider-combinator"])
demux.name = "tri-demux"
demux.icon = ICONS .. "demux.png"
demux.icon_size = 32
demux.place_result = "tri-demux"

data:extend{
    channel_selector,
    mux,
    demux
}
