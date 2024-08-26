JNGear={}

function JNGear:new(_ID,_Level,_StarRare,_Achieve,_Rank,_InfoTab)
    -- statements
    Gear = {}
    setmetatable(Gear, self)
    self.__index = self
    Gear.ID=_InfoTab[1]
    Gear.UID=_ID
    Gear.Level=tonumber(_Level)
    Gear.Rare=tonumber(_StarRare)
    Gear.Achieve=_Achieve
    Gear.Rank=_Rank
    Gear.GearType=tonumber(_InfoTab[18])
    Gear.InfoTab=_InfoTab
    Gear.IsEquip="0"
    if _InfoTab[11] ~= "-1" then
        -- 当前有装备的机娘
        Gear.IsEquip="1"
    end
    --初始化当前的机甲核心可转化的碎片数量
    local _GearPuzzleInfoTab=GameData.tab.decompose[tonumber(Gear.Rare)][tonumber(Gear.Level)+3]
    local _TempTab=string.split(_GearPuzzleInfoTab,"_")
    Gear.gearPuzzleID=_TempTab[1]
    Gear.gearPuzzleCount=tonumber(_TempTab[2])
    return Gear
end

return JNGear