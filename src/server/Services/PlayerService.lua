--[[
    Player Service
    lpz
    idk
]]

--// Services & Modules
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local knit = require(replicated_storage.Packages.Knit)

--// Service
local PlayerService = knit.CreateService({
    Name = "PlayerService",
    Client = {}
})

function PlayerService:KnitInit()
    self.units_service = knit.GetService("UnitsService")
    self.data_service = knit.GetService("DataService")
end

function PlayerService:KnitStart()
    players.PlayerAdded:Connect(function(player: Player)
        self.data_service:WaitForData(player)

        local dynamic_profile = self.data_service:GetDataProfile(player, "Dynamic")
        local dynamic_data = dynamic_profile.Data

        self.units_service:LoadInventory(player, dynamic_data.UnitsInventory)
    end)
end

return PlayerService