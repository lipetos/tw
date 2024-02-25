--[[
    Server application entry point
]]

--// Services & Modules
local replicated_storage = game:GetService("ReplicatedStorage")

local knit = require(replicated_storage.Packages.Knit)
local cmdr = require(replicated_storage.Packages:WaitForChild("Cmdr"))


knit.AddServices(script:WaitForChild("Services"))
-- setups CMDR

knit:Start():andThen(function()
    cmdr:RegisterCommandsIn(script:WaitForChild("Commands"))
end):catch(warn)