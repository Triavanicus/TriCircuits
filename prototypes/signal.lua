local signals = "__TriCircuits__/graphics/signal/"
local default_signal = {
    type = "virtual-signal",
    icon = "__TriCircuits__/graphics/hidden.png",
    icon_size = 1,
    subgroup = "virtual-signal",
    order = "f[signal]-[]"
}

local channel_signal = table.deepcopy(default_signal)
channel_signal.icon = signals .. "channel.png"
channel_signal.icon_size = 32
channel_signal.name = "tri-signal-channel"
channel_signal.order = "f[signal]-[1channel]"

local channel_count_signal = table.deepcopy(default_signal)
channel_count_signal.icon = signals .. "channels.png"
channel_count_signal.icon_size = 32
channel_count_signal.name = "tri-signal-channel-count"
channel_count_signal.order = "f[signal]-[2channel-count]"

local sink_signal = table.deepcopy(default_signal)
sink_signal.name = "tri-signal-sink"
sink_signal.order = "f[signal]-[3sink]"

data:extend{
    channel_signal,
    channel_count_signal,
    sink_signal
}
