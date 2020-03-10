local virtual_signal_count = table_size(data.raw["item"])
local fluid_count = table_size(data.raw["fluid"])
local item_count = table_size(data.raw["virtual-signal"])
local all_signals = virtual_signal_count + fluid_count + item_count

local hidden_output_combinator = table.deepcopy(data.raw["constant-combinator"]["tri-hidden-output-combinator"])
hidden_output_combinator.item_slot_count = all_signals

data:extend{
    hidden_output_combinator
}
