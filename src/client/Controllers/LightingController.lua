--[[
    Lighting Controller
    lpz
    idk
]]

--// Services & Modules
local lighting = game:GetService("Lighting")
local tween_service = game:GetService("TweenService")
local replicated_storage = game:GetService("ReplicatedStorage")

local knit = require(replicated_storage.Packages.Knit)

--// Controller
local LightingController = knit.CreateController({
    Name = "LightingController"
})

function LightingController:KnitInit()

end

function LightingController:KnitStart()

end

function LightingController:SetBlurState(state: boolean)
    local size = if state then 24 else 0

    tween_service:Create(lighting.Blur, TweenInfo.new(0.8), {
        Size = size
    }):Play()
end

return LightingController