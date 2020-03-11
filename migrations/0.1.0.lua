for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes
    if technologies["circuit-network"].researched then
        recipes["tri-channel-selector"].enabled = true
        recipes["tri-mux"].enabled = true
        recipes["tri-demux"].enabled = true
    end
end
