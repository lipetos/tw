--[[
    Units Service
    lpz
    idk
]]

--// Services & Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Global = require(ReplicatedStorage.Shared.Global)
local GlobalTypes = require(ReplicatedStorage.Shared.GlobalTypes)

--// Assets
local Assets = ReplicatedStorage:WaitForChild("Assets")

--// Types
type UnitStats = GlobalTypes.UnitStats
type UnitSkills = GlobalTypes.UnitSkills
type UnitData = GlobalTypes.UnitData
type UnitCommonData = GlobalTypes.UnitCommonData
type UnitInventory = GlobalTypes.UnitInventory

--// Service
local UnitsService = Knit.CreateService({
    Name = "UnitsService",
    Client = {
        UnitUnequipped = Knit.CreateSignal(),
        UnitEquipped   = Knit.CreateSignal(),
        UnitRemoved    = Knit.CreateSignal(),
        UnitAdded      = Knit.CreateSignal()
    }
})

--// Methods
function UnitsService:KnitInit()
    self.inventoriesCache = {}
end

function UnitsService:KnitStart()

end

function UnitsService:_validateUnit(unit: string): Instance?
    return Global.path(Assets, `Units/{unit}`)
end


function UnitsService:_addToCache(player: Player, data: UnitData): UnitData
    self.inventoriesCache[player][data.Id] = data
    return self.inventoriesCache[player][data.Id]
end

function UnitsService:_getUnitCommonData(unit: string): UnitCommonData?
    local dataMod: ModuleScript? = Global.path(Assets, `Units/{unit}`) :: ModuleScript

    if not dataMod then return end

    return require(dataMod)
end

function UnitsService:_getInventory(player: Player): UnitInventory?
    local inventory: UnitInventory? = self.inventoriesCache[player]

    if not inventory then
        return error(`Could not find players inventory ( plr: {player} )`)
    end

    return inventory
end

function UnitsService:_getUnitFromInventory(player: Player, id: string): UnitData?
    local inventory: UnitInventory? = self:_getInventory(player)

    if not inventory then return end

    return inventory[id]
end

function UnitsService:_getEquippedUnitsAmount(player: Player): number?
    local unit_inventory: UnitInventory? = self:_getInventory(player)

    if not unit_inventory then return end

    local amount = 0
    for i,v in unit_inventory do
        if v.Equipped then
            amount += 1
        end
    end

    return amount
end

function UnitsService:LoadInventory(player: Player, inventory: {[string]: UnitData})
    self.inventoriesCache[player] = {}

    for i,v in inventory do
        local unit: UnitData? = self:AddUnit(player, v.Name, v)

        if not unit then continue end
        if unit.Equipped then
            self:EquipUnit(player, v.Id)
        end
    end
end

function UnitsService:GetAllUnitsName()
    local units_path = Global.path(Assets, `Units`)
    local units_name = {}

    for i,v in units_path:GetChildren() do
        table.insert(units_name, require(v).Name)
    end

    return units_name
end

function UnitsService:AddUnit(player: Player, unit: string, unit_data: UnitData?)
    if not UnitsService:_validateUnit(unit) then
        return
    end

    local common_unit_data: UnitCommonData? = unit_data or self:_getUnitCommonData(unit)

    if not common_unit_data then
        return error(`Could not find {unit} common data`, 2)
    end

    local data: UnitData = self:_addToCache(player, unit_data or {
        Id     = HttpService:GenerateGUID(),
        Name   = common_unit_data.Name,
        Skills = common_unit_data.Skills,
        Type   = common_unit_data.Type,
        Stats  = common_unit_data.InitialStats,

        ToCloneModel = common_unit_data.ToCloneModel,
        Equipped     = false,
        InitialCost  = common_unit_data.InitialCost,
        UnitStats    = {
            Spa   = common_unit_data.InitialStats.Spa,
            Range = common_unit_data.InitialStats.Range,
        } :: GlobalTypes.UnitStats,
        Rarity       = common_unit_data.Rarity,
        Slot         = -1 -- means the unit is unequipped
    } :: UnitData)

    self.Client.UnitAdded:Fire(player, data)

    return data
end

function UnitsService:_waitForInventory(player: Player)
    while not self.inventoriesCache[player] do
        task.wait()
    end
end

function UnitsService:_getUnitInSlot(player: Player, slot: number)
    local inventory: UnitInventory = self:_getInventory(player)

    if not inventory then return end

    for i,v in inventory do
        if v.Slot == slot then
            return v
        end
    end
end

function UnitsService:EquipUnit(player: Player, id: string, slot: number)
    local unit_data: UnitData? = self:_getUnitFromInventory(player, id)

    if not unit_data then
        return error(`Could not find unit_data ( id: {id}, player: {player} )`)
    end

    -- checks if player can equip the unit
    local equippedAmount: number? = self:_getEquippedUnitsAmount(player) :: number?

    if not equippedAmount then return end

    if equippedAmount >= player:GetAttribute("MaxEquipSlots") then
        return -- already reached the max equip slots
    end

    local unit_slot = self:_getUnitInSlot(player, slot)

    if not unit_slot then
        unit_data.Slot = slot
    else
        self:UnequipUnit(player, unit_slot.Id)
        return self:EquipUnit(player, id, slot)
    end

    unit_data.Equipped = true

    self.Client.UnitEquipped:Fire(player, unit_data)
end

function UnitsService:UnequipUnit(player: Player, id: string)
    local unit_data: UnitData? = self:_getUnitFromInventory(player, id)

    if not unit_data then
        return error(`Could not find unit_data ( id: {id}, player: {player} )`)
    end

    unit_data.Slot = -1
    unit_data.Equipped = false

    self.Client.UnitUnequipped:Fire(player, unit_data)
end

function UnitsService:GetReadyToDSInventory(player: Player)
    local inventory: UnitInventory? = self:_getInventory(player)

    if not inventory then return end

    for i,v in inventory do
        if v.CurrentInstance then
            v.CurrentInstance = nil
        end
    end

    return inventory
end

--[[
    Client Functions
]]

function UnitsService.Client:RequestEquip(player: Player, id: string, slot: number)
    if not id then
        return warn("NO id to request an equip")
    end

    self.Server:_waitForInventory(player)

    self.Server:EquipUnit(player, id, slot)
end

return UnitsService