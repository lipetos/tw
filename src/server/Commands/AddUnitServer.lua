local replicated_storage = game:GetService("ReplicatedStorage")
local knit = require(replicated_storage.Packages.Knit)

local units_service = knit.GetService("UnitsService")

return function(ctx, player: Player, unit: string)
    if unit == "All" then
        for i,v in units_service:GetAllUnitsName() do
            units_service:AddUnit(player, v)
        end

        return
    end

    units_service:AddUnit(player, unit)
end