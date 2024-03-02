--[[
    Inventory Controller
    lpz
    idk
]]

--// Services & Modules
local replicated_storage = game:GetService("ReplicatedStorage")
local ctx_action_service = game:GetService("ContextActionService")
local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

local globals = require(replicated_storage.Shared.Global)
local global_types = require(replicated_storage.Shared.GlobalTypes)
local knit = require(replicated_storage.Packages.Knit)
local rarities = require(replicated_storage.Shared.Rarities)
local signal = require(replicated_storage.Packages._Index["sleitnick_signal@2.0.1"].signal)

--// Consts
local EQUIPPED_SLOTS_AMOUNT = 5

--// Controller
local InventoryController = knit.CreateController({
    Name = "InventoryController"
})

function InventoryController:KnitInit()
    self.GuiController = knit.GetController("GuiController")
    self.InputController = knit.GetController("InputController")
    
    self.UnitsService = knit.GetService("UnitsService")


    -- local events
    self.IndvSelectionChanged = signal.new()

    -- local vars
    self.inventories = {
        Units = {}
    }
end

function InventoryController:KnitStart()
    self.player = players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")

    self.inventory_canvas = self.GuiController:GetWait("HUD/Inventory")
    self.inventory_main_display = self.GuiController:GetWait("HUD/Inventory/InventoryDisplay")

    self.display_unit_preview = self.GuiController:GetWait("HUD/Inventory/DisplayUnitPreview")
    self.display_unit_buttons = self.GuiController:GetWait("HUD/Inventory/DisplayUnitPreview/Buttons")
    self.display_unit_slots = self.GuiController:GetWait("HUD/Inventory/DisplayUnitPreview/Slots")

    self.bottom_bar = self.GuiController:GetWait("HUD/BottomBar")
    self.slots_frame = self.GuiController:GetWait("HUD/BottomBar/Slots")
    self.slots_display_frame = self.GuiController:GetWait("HUD/BottomBar/Slots/Display")
    
    -- loads the local inventories
    self:SetSectionButtonSelection("Units")

    self.slots_data = {}
    self:LoadSlots()

    --[[
        units related inventory loaders
    ]]
    self.UnitsService.UnitAdded:Connect(function(unit_data: global_types.UnitData)
        self:LoadUnitInSection(unit_data)
    end)

    self.UnitsService.UnitRemoved:Connect(function(item_data: global_types.UnitData)
        
    end)

    self.UnitsService.UnitEquipped:Connect(function(item_data: global_types.UnitData)
        
    end)

    self.UnitsService.UnitUnequipped:Connect(function(item_data: global_types.UnitData)
        
    end)

    self.IndvSelectionChanged:Connect(function(old_idv, new_idv)
        self:SetIndvDisplay(new_idv)
    end)

    --[[
        Open and close menu, animations are WIP
    ]]

    self.InputController:BindKeyboard("M", "InputBegan", function()
        local menu_data = self.GuiController:GetMenuData("Inventory")

        if menu_data.open then
            self.GuiController:CloseMenu("Inventory")
        else
            self.GuiController:OpenMenu("Inventory")
        end
    end, true)

    --[[
        Handles equip n stuff
    ]]
    self:SetSlotsSelectState(true)
    self.equipping = false

    local slot_template = self.display_unit_slots.Display.Display.Configuration.Template

    for i = 1, EQUIPPED_SLOTS_AMOUNT do
        local cloned_template = slot_template:Clone()

        cloned_template.SlotNumber.Text = i .. "."
        cloned_template.TextLabel.Text = "N/A"

        cloned_template.Parent = self.display_unit_slots.Display.Display

        cloned_template.TextButton.Activated:Connect(function()
            print("trying to request a equip from the client... slot: ", i)
            self:SetEquipButtonState(false)
            self:SetSlotsSelectState(true)
            self.UnitsService:RequestEquip(self.current_selected_indv, i)
        end)
    end

    self.display_unit_buttons.Equip.TextButton.Activated:Connect(function()
        self:SetSlotsSelectState(self.equipping)
        self.equipping = not self.equipping
    end)
end

function InventoryController:SetEquipButtonState(state: boolean)
    if not state then
        tween_service:Create(self.display_unit_buttons.Equip.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Scale = 0.8
        }):Play()
        tween_service:Create(self.display_unit_buttons.Equip.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.35
        }):Play()
    else
        tween_service:Create(self.display_unit_buttons.Equip.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Scale = 1
        }):Play()
        tween_service:Create(self.display_unit_buttons.Equip.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        }):Play()
    end
end

function InventoryController:SetSlotsSelectState(state: boolean)
    if state then
        task.spawn(function()
            for i,v in self.display_unit_slots.Display.Display:GetChildren() do
                if v:IsA("Frame") then
                    tween_service:Create(v.UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                        Scale = 0
                    }):Play()

                    task.wait(0.1)
                end
            end
        end)

        tween_service:Create(self.display_unit_slots.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Scale = 0.9
        }):Play()
        tween_service:Create(self.display_unit_slots.TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 1
        }):Play()
        tween_service:Create(self.display_unit_slots.Display, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            GroupTransparency = 1
        }):Play()
        tween_service:Create(self.display_unit_slots.Display.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Transparency = 1
        }):Play()

        self:SetEquipButtonState(true)

        self.display_unit_buttons.Equip.TextLabel.Text = "Equip"
    else
        tween_service:Create(self.display_unit_slots.UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Scale = 1
        }):Play()
        tween_service:Create(self.display_unit_slots.TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            TextTransparency = 0
        }):Play()
        tween_service:Create(self.display_unit_slots.Display, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            GroupTransparency = 0
        }):Play()
        tween_service:Create(self.display_unit_slots.Display.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Transparency = 0
        }):Play()

        task.spawn(function()
            for i,v in self.display_unit_slots.Display.Display:GetChildren() do
                if v:IsA("Frame") then
                    tween_service:Create(v.UIScale, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
                        Scale = 0.8
                    }):Play()

                    task.wait(0.03)
                end
            end
        end)

        self.display_unit_buttons.Equip.TextLabel.Text = "Choosing slots"
        self:SetEquipButtonState(false)
    end
end

function InventoryController:SetIndvDisplay(idv)
    local data = self:GetFromInventories(idv).data :: global_types.UnitData
    local rarity_data = rarities.Units[data.Rarity]
    local previewFrame = self.display_unit_preview.Preview

    self.display_unit_preview.Frame.UIGradient.Color = rarity_data.Color
    previewFrame.TextLabel.Text = data.Name
    previewFrame.TextLabel.UIGradient.Color = rarity_data.Color

    for i,v in data.Stats do
        local statText = previewFrame:FindFirstChild(i)

        if not statText then continue end

        statText.TextLabel.Text = if i == "Spa" then string.format("%s/s", v) else v
    end

    for i,v in previewFrame.Type:GetChildren() do
        if not v:IsA("UIGradient") then continue end

        v.Enabled = v.Name == data.Type
    end

    previewFrame.Type.Text = data.Type

    -- range, spa, type

    --self:_loadViewport(globals.path_wait(self.playerGui, "HUD/ViewportFrame"), globals.path(replicated_storage, `Assets/Units/{data.Name}/{data.Name}Model`), data)
    -- self:_loadViewport(globals.path(self.playerGui, "HUD/Inventory/Preview"), globals.path(replicated_storage, `Assets/Units/{data.Name}/{data.Name}Model`), data)
    -- self:_loadViewport(globals.path(self.playerGui, "HUD/PP"), globals.path(replicated_storage, `Assets/Units/{data.Name}/{data.Name}Model`), data)
    self:_loadViewport(globals.path(self.playerGui, "HUD/Inventory/DisplayUnitPreview/Preview"), globals.path(replicated_storage, `Assets/Units/{data.Name}/{data.Name}Model`), data)
end

function InventoryController:LoadSlots()
    local slot_template = self.slots_display_frame.Configuration.Template

    for i = 1, EQUIPPED_SLOTS_AMOUNT do
        local cloned_template = slot_template:Clone()

        cloned_template.SlotNumber.Text = i .. "."
        cloned_template.TextLabel.Text = "N/A"

        cloned_template.Parent = self.slots_display_frame
        self.slots_data[i] = {
            frame = cloned_template
        }
    end
end

function InventoryController:SetSlot()

end

function InventoryController:_loadViewport(viewport: ViewportFrame, model: Model, unit_data)
    local world_model = viewport:FindFirstChild("WorldModel")
    if not viewport.CurrentCamera then
        -- setups the viewport
        local camera = Instance.new("Camera")
        camera.CameraType = Enum.CameraType.Scriptable
        viewport.CurrentCamera = camera   
        camera.Parent = viewport

        world_model = Instance.new("WorldModel")
        world_model.Parent = viewport
    end

    -- clears the current model in the viewport
    for i,v in world_model:GetChildren() do
        if v:IsA("Model") then
            v:Destroy()
        end
    end

    local cloned_model = model:Clone()
    local primary_part = cloned_model.PrimaryPart
    cloned_model.Parent = world_model

    -- loads idle animation
    local animations_folder = globals.path(replicated_storage, `Assets/Units/{unit_data.Name}/Animations`)

    if animations_folder then
        local loaded_animation = cloned_model.Humanoid:LoadAnimation(animations_folder.Idle)
        loaded_animation.Looped = true
        loaded_animation.Priority = Enum.AnimationPriority.Action4
        loaded_animation:Play()
    end

    local camera = viewport.CurrentCamera
    camera.CFrame = primary_part.CFrame * CFrame.new(0, -0.2, -6.5)
    camera.CFrame = CFrame.new(camera.CFrame.Position, primary_part.Position)
end

function InventoryController:GetFromInventories(id)
    for i,v in self.inventories do
        if v[id] then
            return v[id]
        end
    end
end

function InventoryController:_findAnClearSec(rarity: string)
    local ivs_display = self.inventory_main_display:WaitForChild("Display")

    local sec_instance = ivs_display.ScrollingFrame:FindFirstChild(rarity)

    if sec_instance then
        for i,v in sec_instance.ScrollingFrame:GetChildren() do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
    end

    return sec_instance
end

function InventoryController:SetSectionButtonSelection(button: string)
    self.currentSection = button
    self:LoadInventorySection(button)
end

function InventoryController:_getRaritySection(rarity: string): Frame?
    local ivs_display = self.inventory_main_display:WaitForChild("Display")
    local rarity_data = rarities[rarity]
    local main_scrolling = ivs_display.ScrollingFrame
    local sec = main_scrolling:FindFirstChild(rarity)

    if not sec then
        return warn("Could not find the following rarity_Section:", rarity)
    end

    return sec
end

function InventoryController:_applyRarityColor(rarity: string, frame: Frame)
    local color = rarities.Units[rarity].Color

    frame.UIStroke.UIGradient.Color = color
    frame.Frame.UIStroke.UIGradient.Color = color
end

function InventoryController:_createUnitFrame(unit_data: global_types.UnitData)
    local rarity_section = self:_getRaritySection(unit_data.Rarity)
    local display_units = rarity_section.DisplayUnits
    local cloned_template = display_units.Configuration.Template:Clone()
    local color = rarities.Units[unit_data.Rarity].Color

    cloned_template.TextLabel.Text = unit_data.Name

    self:_applyRarityColor(unit_data.Rarity, cloned_template)

    cloned_template.Name = unit_data.Id
    cloned_template.Parent = rarity_section.DisplayUnits

    cloned_template.TextButton.Activated:Connect(function()
        local old_idv = self.current_selected_indv

        self.current_selected_indv = unit_data.Id
        self.IndvSelectionChanged:Fire(old_idv, unit_data.Id)
    end)
end

function InventoryController:LoadUnitInSection(unit_data: global_types.UnitData)
    local rarity_section = self:_getRaritySection(unit_data.Rarity)

    if not rarity_section then return end

    local cached_data = self.inventories.Units[unit_data.Id]
    if not cached_data then
        self.inventories.Units[unit_data.Id] = {
            data = unit_data,
            frame = self:_createUnitFrame(unit_data)
        }
    end
    cached_data = self.inventories.Units[unit_data.Id]
end

function InventoryController:LoadInventorySection(section: string)
    local ivs_display = self.inventory_main_display:WaitForChild("Display")
    local rarity_data = rarities[section]
    local main_scrolling = ivs_display.ScrollingFrame

    for i,v in ivs_display.ScrollingFrame:GetChildren() do
        if v:IsA("Frame") then
            local r_data = rarity_data[v.Name]
            self:_findAndClearSec(
                if r_data then r_data.id else ""
            )
        end
    end

    for i,v in rarity_data do
        local sec_instance = main_scrolling:FindFirstChild(i)

        if not sec_instance then
            sec_instance = main_scrolling.Configuration.RaritySectionTemplate:Clone()
            sec_instance.Parent = main_scrolling
        end

        if v.id == "Secret" then
            sec_instance.TextLabel.UIStroke.Color = Color3.fromRGB(255, 255, 255)
            sec_instance.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
            sec_instance.TextLabel.UIGradient.Enabled = false
        else
            sec_instance.TextLabel.UIGradient.Rotation = 90
            sec_instance.TextLabel.UIGradient.Color = v.Color
        end

        sec_instance.Name = v.id
        sec_instance.TextLabel.Text = v.id
        sec_instance.LayoutOrder = v.Priority
    end
end

return InventoryController