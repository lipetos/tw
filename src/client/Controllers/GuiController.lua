--[[
    Gui Controller
    lpz
    idk
]]

--// Services & Modules
local replicated_storage = game:GetService("ReplicatedStorage")
local tween_service = game:GetService("TweenService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local globals = require(replicated_storage.Shared.Global)
local knit = require(replicated_storage.Packages.Knit)


--// Controller
local GuiController = knit.CreateController({
    Name = "GuiController"
})

function GuiController:KnitInit()
    self.LightingController = knit.GetController("LightingController")
end

function GuiController:KnitStart()
    self.player = players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")

    
end

function GuiController:Get(path: string)
    return globals.path(self.playerGui, path)
end

function GuiController:GetWait(path: string)
    return globals.path_wait(self.playerGui, path)
end

function GuiController:OpenMenu()
    self.LightingController:SetBlurState(true)
end

function GuiController:CloseMenu()
    self.LightingController:SetBlurState(false)
end

return GuiController