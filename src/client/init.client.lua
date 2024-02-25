--[[
    Server application entry point
]]

--// Services & Modules
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local knit = require(replicated_storage.Packages.Knit)
local cmdr = require(replicated_storage:WaitForChild("CmdrClient"))

local local_player = players.LocalPlayer
-- waits for all the UIs to load in the game
local_player:WaitForChild("PlayerGui")

knit.AddControllers(script:WaitForChild("Controllers"))

-- setups CMDR
cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

knit:Start():catch(warn)