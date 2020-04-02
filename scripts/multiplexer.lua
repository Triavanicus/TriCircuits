CHANNEL_COUNT_SIGNAL = { type = "virtual", name = "tri-signal-channel-count" }
CHANNEL_SIGNAL = { type = "virtual", name = "tri-signal-channel" }
INPUT_CONNECTOR = defines.circuit_connector_id.combinator_input
OUTPUT_CONNECTOR = defines.circuit_connector_id.combinator_output
MAX_CHANNELS = 128
MAX_CHANNEL = MAX_CHANNELS - 1
MIN_CHANNELS = 1
MIN_CHANNEL = 0

muxs = {}
Mux = { input = {}, output = {}}
Mux.__index = Mux

function Mux:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Mux:build(entity)
    local output = entity.surface.create_entity{ name = "tri-hidden-output-combinator", position = entity.position, force = force }
    entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.red, source_circuit_id = OUTPUT_CONNECTOR }
    entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.green, source_circuit_id = OUTPUT_CONNECTOR }
    global.muxs[entity.unit_number] = { input = entity, output = output }
    muxs[entity.unit_number] = Mux:new(global.muxs[entity.unit_number])
end

function Mux:get_input_control()
    return self.input.get_or_create_control_behavior()
end

function Mux:get_input_parameters()
    return self:get_input_control().parameters.parameters
end

function Mux:set_input_parameters(parameters)
    self:get_input_control().parameters = { parameters = parameters }
end

function Mux:get_output_control()
    return self.output.get_or_create_control_behavior()
end

function Mux:get_output_paramerters()
    return self:get_output_control().parameters.parameters
end

function Mux:set_output_parameters(parameters)
    self:get_output_control().parameters = { parameters = parameters }
end

function Mux:get_channel()
    return self:get_input_parameters().first_constant or 0
end

function Mux:set_channel(channel)
    self:set_input_parameters{ first_constant = channel }
end

function Mux:tick()
    local control = self:get_output_control()
    if self.output.get_merged_signal(CHANNEL_SIGNAL) == self:get_channel() then
        local signals = self.input.get_merged_signals(INPUT_CONNECTOR)
        if signals then
            for i, signal in pairs(signals) do
                control.set_signal(i, signal)
            end
        end
    else
        self:set_output_parameters{}
    end
end

demuxs = {}
Demux = Mux:new()

function Demux:build(entity)
    local output = entity.surface.create_entity{ name = "tri-hidden-output-combinator", position = entity.position, force = force }
    entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.red, source_circuit_id = OUTPUT_CONNECTOR }
    entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.green, source_circuit_id = OUTPUT_CONNECTOR }
    global.demuxs[entity.unit_number] = { input = entity, output = output }
    demuxs[entity.unit_number] = Demux:new(global.demuxs[entity.unit_number])
end

function Demux:tick()
    if self.input.get_merged_signal(CHANNEL_SIGNAL, INPUT_CONNECTOR) == self:get_channel() + 1 then
        local signals = self.input.get_merged_signals(INPUT_CONNECTOR)
        local control = self:get_output_control()
        if signals then
            self:set_output_parameters{}
            for i, signal in pairs(signals) do
                if signal.signal.name ~= CHANNEL_SIGNAL.name and signal.signal.name ~= CHANNEL_COUNT_SIGNAL.name then
                    control.set_signal(i, signal)
                end
            end
        else
            self:set_output_parameters{}
        end
    end
end

