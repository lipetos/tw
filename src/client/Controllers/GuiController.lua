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

--// Types
export type MenuInstance = Frame | CanvasGroup

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

    --[[
        Menu Animations
    ]]
    self.menus_data = {}
    self.menu_animations = {
        Inventory = {
            open = function(menu_instance: MenuInstance)
                menu_instance.Visible = true
            end,
            close = function(menu_instance: MenuInstance)
                menu_instance.Visible = false
            end
        },
        BottomBar = {
            open = function(menu_instance: MenuInstance)
                menu_instance.Visible = true
            end,
            close = function(menu_instance: MenuInstance)
                menu_instance.Visible = false
            end
        }
    }

    local hud = self:GetWait("HUD")
    self.menus_instances = {}

    for i,v in hud:GetChildren() do
        self.menus_instances[v.Name] = v
    end

    for i,v in hud:GetChildren() do
        local closeOnStart = v:GetAttribute("CloseOnStart")
        self.menus_data[v.Name] = {
            open = if closeOnStart then false else v.Visible
        }

        if closeOnStart then
            self:CloseMenu(v.Name)
        end
    end
end

function GuiController:Get(path: string)
    return globals.path(self.playerGui, path)
end

function GuiController:GetWait(path: string)
    return globals.path_wait(self.playerGui, path)
end

function GuiController:GetMenuData(menu: string)
    return self.menus_data[menu]
end

function GuiController:OpenMenu(menu: string)
    self.LightingController:SetBlurState(true)
    local open_animation = self.menu_animations[menu].open

    self:GetMenuData(menu).open = true

    for i,v in self.menus_instances do
        if v:GetAttribute("CloseWhenOtherOpen") then
            self:CloseMenu(v.Name)
        end
    end

    open_animation(self:Get("HUD/" .. menu))
end

function GuiController:CloseMenu(menu: string)
    self.LightingController:SetBlurState(false)
    local close_animation = self.menu_animations[menu].close

    self:GetMenuData(menu).open = false

    close_animation(self:Get("HUD/" .. menu))
end

return GuiController