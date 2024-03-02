local replicated_storage = game:GetService("ReplicatedStorage")
local knit = require(replicated_storage.Packages.Knit)


local function printout(DataStore, Profile)
    warn("======================================")
    warn(DataStore, " DataStore loaded data: ", Profile.Data)
    warn("======================================")
end
local DataService = knit.GetService("DataService")

return function(ctx, player)

    local dynamic_profile = DataService:GetDataProfile(player, "Dynamic")
    local static_profile = DataService:GetDataProfile(player, "Static")

    printout("Dynamic", dynamic_profile)
    printout("Static", static_profile)
end