--[[
script.on_init(function()
    -- setup default global variable or change game parameters
end)

script.on_configuration_changed(function(data)
    -- used for game or prototype changes.
end)

script.on_load(function()
    -- set local variables from global variable, setup metatables, setup conditional events
end)
--]]

local CHANNEL_COUNT_SIGNAL = { type = "virtual", name = "tri-signal-channel-count" }
local CHANNEL_SIGNAL = { type = "virtual", name = "tri-signal-channel" }
local INPUT_CONNECTOR = defines.circuit_connector_id.combinator_input
local OUTPUT_CONNECTOR = defines.circuit_connector_id.combinator_output
local MAX_CHANNELS = 128
local MAX_CHANNEL = MAX_CHANNELS - 1
local MIN_CHANNELS = 1
local MIN_CHANNEL = 0

local function setup_global()
    global.channel_selectors = global.channel_selectors or {}
    global.muxs = global.muxs or {}
    global.demuxs = global.demuxs or {}
end

script.on_init(function()
    setup_global()
end)

local function on_entity_built(entity, force)
    if entity.name == "tri-channel-selector" then
        global.channel_selectors[entity.unit_number] = entity
        entity.get_or_create_control_behavior().parameters = { parameters = { { index = 1, signal = CHANNEL_COUNT_SIGNAL, count = 1 } } }
    elseif entity.name == "tri-mux" then
        local output = entity.surface.create_entity{ name = "tri-hidden-output-combinator", position = entity.position, force = force }
        entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.red, source_circuit_id = OUTPUT_CONNECTOR }
        entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.green, source_circuit_id = OUTPUT_CONNECTOR }
        global.muxs[entity.unit_number] = { input = entity, output = output, channel = 0 }
    elseif entity.name == "tri-demux" then
        local output = entity.surface.create_entity{ name = "tri-hidden-output-combinator", position = entity.position, force = force }
        entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.red, source_circuit_id = OUTPUT_CONNECTOR }
        entity.connect_neighbour{ target_entity = output, wire = defines.wire_type.green, source_circuit_id = OUTPUT_CONNECTOR }
        global.demuxs[entity.unit_number] = { input = entity, output = output, channel = 0 }
    end
end

script.on_event(defines.events.on_built_entity, function(e)
    on_entity_built(e.created_entity, game.players[e.player_index].force)
end)

script.on_event(defines.events.on_robot_built_entity, function(e)
    on_entity_built(e.created_entity, e.robot.force)
end)

local function on_entity_destroyed(entity)
    if entity.name == "tri-channel-selector" then
        global.channel_selectors[entity.unit_number] = nil
    elseif entity.name == "tri-mux" then
        local output = global.muxs[entity.unit_number].output
        if output.valid then
            output.destroy()
        end
        global.muxs[entity.unit_number] = nil
    elseif entity.name == "tri-demux" then
        local output = global.demuxs[entity.unit_number].output
        if output.valid then
            output.destroy()
        end
        global.demuxs[entity.unit_number] = nil
    end
end

script.on_event(defines.events.on_player_mined_entity, function(e)
    on_entity_destroyed(e.entity)
end)

script.on_event(defines.events.on_entity_died, function(e)
    on_entity_destroyed(e.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(e)
    on_entity_destroyed(e.entity)
end)

script.on_event(defines.events.on_tick, function ()
    for _, channel_selector in pairs(global.channel_selectors) do
        local control = channel_selector.get_or_create_control_behavior()
        local num_of_channels = control.get_signal(1).count
        if num_of_channels > 0 then
            control.set_signal(2, { signal = CHANNEL_SIGNAL, count = game.tick % (num_of_channels + 1) })
        else
            control.set_signal(1, { signal = CHANNEL_COUNT_SIGNAL, count = 1 })
            control.set_signal(2, { signal = CHANNEL_SIGNAL, count = 0 })
        end
    end
    for _, mux in pairs(global.muxs) do
        local control = mux.output.get_or_create_control_behavior()
        if mux.output.get_merged_signal(CHANNEL_SIGNAL) == mux.channel then
            local signals = mux.input.get_merged_signals(INPUT_CONNECTOR)
            if signals then
                for i, signal in pairs(signals) do
                    control.set_signal(i, signal)
                end
            end
        else
            control.parameters = { parameters = {} }
        end
    end
    for _, demux in pairs(global.demuxs) do
        if demux.input.get_merged_signal(CHANNEL_SIGNAL, INPUT_CONNECTOR) == demux.channel + 1 then
            local control = demux.output.get_or_create_control_behavior()
            local signals = demux.input.get_merged_signals(INPUT_CONNECTOR)
            if signals then
                demux.output.get_or_create_control_behavior().parameters = { parameters = {} }
                for i, signal in pairs(signals) do
                    if signal.signal.name ~= CHANNEL_SIGNAL.name and signal.signal.name ~= CHANNEL_COUNT_SIGNAL.name then
                        control.set_signal(i, signal)
                    end
                end
            else
                control.parameters = { parameters = {} }
            end
        end
    end
end)

local function create_lone_frame(player, name, title)
    title = title or ""
    local frame = player.gui.screen.add{type="frame", direction = "vertical", caption=title, name=name}
    frame.style.use_header_filler = true
    frame.force_auto_center()
    return frame
end

local function add_entity_preview(parent, entity, name)
    name = name or "entity-preview"
    local entity_preview = parent.add{ type = "entity-preview", name = name }
    entity_preview.entity = entity
    entity_preview.visible = true
    entity_preview.style.width = 100
    entity_preview.style.height = 100
    return entity_preview
end

script.on_event(defines.events.on_gui_opened, function(e)
    local player = game.players[e.player_index]
    if e.gui_type == defines.gui_type.entity then
        local entity = e.entity
        if entity.name == "tri-channel-selector" then
            local channel_selector = global.channel_selectors[entity.unit_number]
            local control = channel_selector.get_or_create_control_behavior()
            local num_of_channels = control.get_signal(1).count
            local root = create_lone_frame(player, "tri-channel-selector-gui", entity.localised_name)
            add_entity_preview(root, entity)
            root.add{ type = "line", direction = "horizontal" }
            root.add{ type = "label", caption = { "gui-text.tri-number-of-channels" } }
            local row = root.add{ type = "flow", name = "channel", direction = "horizontal" }
            row.style.vertical_align = "center"
            local slider = row.add{
                type = "slider",
                name = "tri-channel-selector-gui/channel/slider",
                minimum_value = 1,
                maximum_value = 128,
                value = num_of_channels
            }
            local slider_text = row.add{
                type = "textfield",
                name = "tri-channel-selector-gui/channel/text",
                text = num_of_channels,
                numeric = true,
                allow_negative = false,
                allow_decimal = false,
                lose_focus_on_confirm = true,
                clear_and_focus_on_right_click = true
            }
            slider_text.style.width = 40
            player.opened = root
        elseif entity.name == "tri-mux" then
            local mux = global.muxs[entity.unit_number]
            local root = create_lone_frame(player, "tri-mux-gui", entity.localised_name)
            add_entity_preview(root, entity)
            root.add{type = "line", direction = "horizontal" }
            root.add{ type = "label", caption = { "gui-text.tri-channel" } }
            local row = root.add{ type = "flow", name = "channel", direction = "horizontal" }
            row.style.vertical_align = "center"
            local slider = row.add{
                type = "slider",
                name = "tri-mux-gui/channel/slider",
                minimum_value = 0,
                maximum_value = 127,
                value = mux.channel
            }
            local slider_text = row.add{
                type = "textfield",
                name = "tri-mux-gui/channel/text",
                text = mux.channel,
                numeric = true,
                allow_negative = false,
                allow_decimal = false,
                lose_focus_on_confirm = true,
                clear_and_focus_on_right_click = true
            }
            slider_text.style.width = 50
            player.opened = root
        elseif entity.name == "tri-demux" then
            local demux = global.demuxs[entity.unit_number]
            local root = create_lone_frame(player, "tri-demux-gui", entity.localised_name)
            add_entity_preview(root, entity)
            root.add{type = "line", direction = "horizontal" }
            root.add{ type = "label", caption = { "gui-text.tri-channel" } }
            local row = root.add{ type = "flow", name = "channel", direction = "horizontal" }
            row.style.vertical_align = "center"
            local slider = row.add{
                type = "slider",
                name = "tri-demux-gui/channel/slider",
                minimum_value = 0,
                maximum_value = 127,
                value = demux.channel
            }
            local slider_text = row.add{
                type = "textfield",
                name = "tri-demux-gui/channel/text",
                text = demux.channel,
                numeric = true,
                allow_negative = false,
                allow_decimal = false,
                lose_focus_on_confirm = true,
                clear_and_focus_on_right_click = true
            }
            slider_text.style.width = 50
            player.opened = root
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(e)
    local player = game.players[e.player_index]
    if e.gui_type == defines.gui_type.custom then
        local element = e.element
        if element.name == "tri-channel-selector-gui" then
            element.destroy()
        elseif element.name == "tri-mux-gui" then
            element.destroy()
        elseif element.name == "tri-demux-gui" then
            element.destroy()
        end
    end
end)

script.on_event(defines.events.on_gui_value_changed, function (e)
    local element = e.element
    if element.name == "tri-channel-selector-gui/channel/slider" then
        local gui = element.parent.parent
        gui["channel"]["tri-channel-selector-gui/channel/text"].text = element.slider_value
        local channel_selector = global.channel_selectors[gui["entity-preview"].entity.unit_number]
        local control = channel_selector.get_or_create_control_behavior()
        control.set_signal(1, { signal = CHANNEL_COUNT_SIGNAL, count = element.slider_value })
    elseif element.name == "tri-mux-gui/channel/slider" then
        local gui = element.parent.parent
        gui["channel"]["tri-mux-gui/channel/text"].text = element.slider_value
        global.muxs[gui["entity-preview"].entity.unit_number].channel = element.slider_value
    elseif element.name == "tri-demux-gui/channel/slider" then
        local gui = element.parent.parent
        gui["channel"]["tri-demux-gui/channel/text"].text = element.slider_value
        global.demuxs[gui["entity-preview"].entity.unit_number].channel = element.slider_value
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(e)
    local element = e.element
    if element.name == "tri-channel-selector-gui/channel/text" then
        local value = tonumber(element.text) or MIN_CHANNELS
        if value > MAX_CHANNELS then
            value = MAX_CHANNELS
            element.text = MAX_CHANNELS
        end
        local gui = element.parent.parent
        gui["channel"]["tri-channel-selector-gui/channel/slider"].slider_value = value
        local channel_selector = global.channel_selectors[gui["entity-preview"].entity.unit_number]
        local control = channel_selector.get_or_create_control_behavior()
        control.set_signal(1, { signal = CHANNEL_COUNT_SIGNAL, count = value })
    elseif element.name == "tri-mux-gui/channel/text" then
        local value = tonumber(element.text) or MIN_CHANNEL
        if value > MAX_CHANNEL then
            value = MAX_CHANNEL
            element.text = MAX_CHANNEL
        end
        local gui = element.parent.parent
        gui["channel"]["tri-mux-gui/channel/slider"].slider_value = value
        global.muxs[gui["entity-preview"].entity.unit_number].channel = value
    elseif element.name == "tri-demux-gui/channel/text" then
        local value = tonumber(element.text) or MIN_CHANNEL
        if value > MAX_CHANNEL then
            value = MAX_CHANNEL
            element.text = MAX_CHANNEL
        end
        local gui = element.parent.parent
        gui["channel"]["tri-demux-gui/channel/slider"].slider_value = value
        global.demuxs[gui["entity-preview"].entity.unit_number].channel = value
    end
end)