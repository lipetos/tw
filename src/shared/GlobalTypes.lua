export type UnitStats = {
    Spa: number,
    Range: number
}
export type UnitSkills = {}
export type UnitData = {
    Name: string,
    Id: string,
    ToCloneModel: string,
    CurrentInstance: Instance?,
    Skills: UnitSkills,
    Stats: UnitStats,
    Type: string,
    Equipped: boolean,
    Slot: number,
    InitialCost: number,
    Rarity: string
}
export type UnitCommonData = {
    Name: string,
    InitialCost: number,
    InitialStats: UnitStats,
    Skills: UnitSkills,
    ToCloneModel: string,
    Type: string,
    Rarity: string
}
export type UnitInventory = {[string]: UnitData}

return {}