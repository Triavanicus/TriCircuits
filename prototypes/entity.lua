require "prototypes.constants"
--[[
If the entity needs only to output a signal, or only read a signal, then it can use a constant combinator
Otherwise if it needs both an input, and output, and they have to be sepparate then
it will need to be either an arithmatic combinator, or a decider combinator, with a hidden output constant
combinator. The hidden output combinator will not draw any activity LED's, make sounds, must not have a collision
box or selection box. The output combinator must be connected to the output of the parent combinator in code, and
deleted when the parent combinator gets deleted. It will be used only as an interface.
--]]

local channel_selector = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
channel_selector.name = "tri-channel-selector"
channel_selector.icon = ICONS .. "channel-selector.png"
channel_selector.icon_size = 32
channel_selector.item_slot_count = 2
channel_selector.minable.result = "tri-channel-selector"
channel_selector.sprites = make_4way_animation_from_spritesheet{
    layers = {
        {
            filename = ENTITIES .. "channel-selector.png",
            width = 58,
            height = 52,
            frame_count = 1,
            shift = util.by_pixel(0, 5),
            hr_version = {
                scale = 0.5,
                filename = ENTITIES .. "hr-channel-selector.png",
                width = 114,
                height = 102,
                frame_count = 1,
                shift = util.by_pixel(0, 5)
            }
        },
        {
            filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
            width = 50,
            height = 34,
            frame_count = 1,
            shift = util.by_pixel(9, 6),
            draw_as_shadow = true,
            hr_version = {
                scale = 0.5,
                filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
                width = 98,
                height = 66,
                frame_count = 1,
                shift = util.by_pixel(8.5, 5.5),
                draw_as_shadow = true
            }
        }
    }
}

local hidden_output_combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
hidden_output_combinator.name = "tri-hidden-output-combinator"
hidden_output_combinator.placeable_by = nil
table.insert(hidden_output_combinator.flags, "hidden")
hidden_output_combinator.item_slot_count = 0
hidden_output_combinator.sprites = EMPTY_SPRITE
hidden_output_combinator.activity_led_sprites = EMPTY_SPRITE
hidden_output_combinator.minable = nil
hidden_output_combinator.order = "zzzzzzzzzzzz"
hidden_output_combinator.collision_mask = {}
hidden_output_combinator.collision_box = nil
hidden_output_combinator.selection_box = nil
hidden_output_combinator.draw_circuit_wires = false
hidden_output_combinator.draw_copper_wires = false
hidden_output_combinator.activity_led_light.intensity = 0

local default_input_combinator = table.deepcopy(data.raw["arithmetic-combinator"]["arithmetic-combinator"])
default_input_combinator.name = nil
default_input_combinator.placeable_by = nil
default_input_combinator.and_symbol_sprites = EMPTY_SPRITE
default_input_combinator.divide_symbol_sprites = EMPTY_SPRITE
default_input_combinator.left_shift_symbol_sprites = EMPTY_SPRITE
default_input_combinator.minus_symbol_sprites = EMPTY_SPRITE
default_input_combinator.modulo_symbol_sprites = EMPTY_SPRITE
default_input_combinator.multiply_symbol_sprites = EMPTY_SPRITE
default_input_combinator.or_symbol_sprites = EMPTY_SPRITE
default_input_combinator.plus_symbol_sprites = EMPTY_SPRITE
default_input_combinator.power_symbol_sprites = EMPTY_SPRITE
default_input_combinator.right_shift_symbol_sprites = EMPTY_SPRITE
default_input_combinator.xor_symbol_sprites = EMPTY_SPRITE
default_input_combinator.sprites = EMPTY_SPRITE
default_input_combinator.screen_light.intensity = 0
default_input_combinator.corpse = nil
default_input_combinator.minable.result = nil
default_input_combinator.activity_led_sprites = data.raw["decider-combinator"]["decider-combinator"].activity_led_sprites
default_input_combinator.input_connection_points = data.raw["decider-combinator"]["decider-combinator"].input_connection_points
default_input_combinator.output_connection_points = data.raw["decider-combinator"]["decider-combinator"].output_connection_points

local mux = table.deepcopy(default_input_combinator)
mux.name = "tri-mux"
mux.icon = ICONS .. "mux.png"
mux.icon_size = 32
mux.minable.result = "tri-mux"
mux.sprites = make_4way_animation_from_spritesheet{
    layers = {
        {
            filename = ENTITIES .. "mux.png",
            width = 78,
            height = 66,
            frame_count = 1,
            shift = util.by_pixel(0, 7),
            hr_version = {
                scale = 0.5,
                filename = ENTITIES .. "hr-mux.png",
                width = 156,
                height = 132,
                frame_count = 1,
                shift = util.by_pixel(0.5, 7.5)
            }
        },
        {
            filename = "__base__/graphics/entity/combinator/decider-combinator-shadow.png",
            width = 78,
            height = 80,
            frame_count = 1,
            shift = util.by_pixel(12, 24),
            draw_as_shadow = true,
            hr_version = {
                scale = 0.5,
                filename = "__base__/graphics/entity/combinator/hr-decider-combinator-shadow.png",
                width = 156,
                height = 158,
                frame_count = 1,
                shift = util.by_pixel(12, 24),
                draw_as_shadow = true
            }
        }
    }
}

local demux = table.deepcopy(default_input_combinator)
demux.name = "tri-demux"
demux.icon = ICONS .. "demux.png"
demux.icon_size = 32
demux.minable.result = "tri-demux"
demux.sprites = make_4way_animation_from_spritesheet{
    layers = {
        {
            filename = ENTITIES .. "demux.png",
            width = 78,
            height = 66,
            frame_count = 1,
            shift = util.by_pixel(0, 7),
            hr_version = {
                scale = 0.5,
                filename = ENTITIES .. "hr-demux.png",
                width = 156,
                height = 132,
                frame_count = 1,
                shift = util.by_pixel(0.5, 7.5)
            }
        },
        {
            filename = "__base__/graphics/entity/combinator/decider-combinator-shadow.png",
            width = 78,
            height = 80,
            frame_count = 1,
            shift = util.by_pixel(12, 24),
            draw_as_shadow = true,
            hr_version = {
                scale = 0.5,
                filename = "__base__/graphics/entity/combinator/hr-decider-combinator-shadow.png",
                width = 156,
                height = 158,
                frame_count = 1,
                shift = util.by_pixel(12, 24),
                draw_as_shadow = true
            }
        }
    }
}

data:extend{
    channel_selector,
    hidden_output_combinator,
    mux,
    demux,
}
