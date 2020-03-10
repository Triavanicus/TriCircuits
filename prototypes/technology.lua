require "prototypes.constants"

local function add_recipe(tech_name, recipe)
    table.insert(data.raw.technology[tech_name].effects, { type = "unlock-recipe", recipe = recipe })
end

add_recipe("circuit-network", "tri-channel-selector")
add_recipe("circuit-network", "tri-mux")
add_recipe("circuit-network", "tri-demux")
