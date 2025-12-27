-- RD Common Database
-- Shared data for RD scripts (mounts, items, etc.)

local DB = {}

-- Mount Database
-- Tier 1 (weakest) to Tier 7 (strongest)
DB.mounts = {
    ["Necromancer's Severed Hand"] = 1,
    ["Jungle Raptor Saddle"] = 2,
    ["Selyrah of Fear Saddle"] = 3,
    ["Radiant Hawk Harness"] = 4,
    ["Scalewrought Striker Saddle"] = 5,
    ["Scalewrought Drone Harness"] = 6,
    ["Armored Bee Harness"] = 7,
}

-- Helper function: Get best available mount from inventory
function DB.getBestMount(mq)
    local bestMount = nil
    local highestTier = 0
    
    for mountName, tier in pairs(DB.mounts) do
        local item = mq.TLO.FindItem("=" .. mountName)
        if item() then
            if tier > highestTier then
                highestTier = tier
                bestMount = mountName
            end
        end
    end
    
    return bestMount, highestTier
end

-- Helper function: Get tier for a specific mount
function DB.getMountTier(mountName)
    return DB.mounts[mountName] or 0
end

-- Add more categories here as needed
-- DB.familiars = { ... }
-- DB.illusions = { ... }
-- etc.

return DB
