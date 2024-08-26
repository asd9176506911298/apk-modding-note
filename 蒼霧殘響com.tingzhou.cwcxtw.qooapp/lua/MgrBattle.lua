require "Fight/View/FightPlay"

MgrBattle = {}

---战斗类型
MgrBattle.fightType = {
    none = 0,
    normal = 1, ---常规
    novice = 2, ---引导
    boss = 3, ---世界boss
    pvp = 4,          ---玩家对战
}
---战斗对应ui
MgrBattle.fightUI = {
    [MgrBattle.fightType.normal] = UID.Battle02_UI,
    [MgrBattle.fightType.novice] = UID.NoviceBattle_UI,
    --[MgrBattle.fightType.boss] = UID.WorldBossBattle_UI,
    [MgrBattle.fightType.boss] = UID.Battle02_UI,
    [MgrBattle.fightType.pvp] = UID.PVPReady_UI,
}

---当前战斗类型
local curType = 0

local _startBattle = function (curType, callback,mapName)
    if mapName == nil then
        if curType == MgrBattle.fightType.normal or curType == MgrBattle.fightType.novice then
            MgrSce.LoadBattle("haigang_baitian", function()
                MgrBattle.InitFight(callback)
            end)
        elseif curType == MgrBattle.fightType.boss then
            MgrSce.LoadBattle("haigang_boss_huanghun", function()
                MgrBattle.InitFight(callback)
            end)
        elseif curType == MgrBattle.fightType.pvp then
            MgrSce.LoadBattle("jingjichang", function()
                MgrBattle.InitFight(callback)
            end)
        else
            MgrSce.LoadBattle("haigang_baitian", function()
                MgrBattle.InitFight(callback)
            end)
        end
        -- MgrSce.Load("Battle", function()
        -- MgrSce.LoadBattle("Battle1", function()
        --MgrSce.LoadBattle("haigang_baitian", function()
        ---- MgrSce.LoadBattle("haigang_boss", function()
        --    MgrBattle.InitFight(callback)
        --end)
    else
        MgrSce.LoadBattle(mapName, function()
            MgrBattle.InitFight(callback)
        end)
    end
end

function MgrBattle.Init()
    CMgrBattle.Instance:Init()
end

---进入战斗
---@param fightType number 战斗类型fightType
function MgrBattle.GoFight(fightType, callback,mapName)
    curType = fightType
    if curType == MgrBattle.fightType.normal or curType == MgrBattle.fightType.novice then
        ---提前预载指定角色
        local rolePackage = {}
        for _, role in ipairs(StormViewModel.CurPointData.roles) do
            rolePackage[role.id] = 1
        end
        ---提前预载怪物
        for _, role in ipairs(StormViewModel.CurPointData.monsters) do
            rolePackage[role.id] = 1
        end
        ---检查下载
        local packCount = 0
        for i, v in pairs(rolePackage) do
            packCount = packCount + 1
        end
        local overCount = 0

        for id, _ in pairs(rolePackage) do
            MgrHot.RolePackage(id,function()
                overCount = overCount + 1
                if overCount == packCount then
                    _startBattle(curType, callback, mapName)
                end
            end)
        end
    else
        _startBattle(curType, callback, mapName)
    end
end

function MgrBattle.InitFight(callback)
    ---加载战斗
    FightPlay.Install()
    if PVPViewModel.continue and PVPViewModel.continueCount > 0 then
        PVPViewModel.StartContinuousPVP()
    else
        ---加载战斗ui
        MgrUI.GoFirst(MgrBattle.fightUI[curType], callback)
    end
end

---退出战斗
---@param isHome boolean 是否直接返回大厅
function MgrBattle.CloseFight(isHome, cell)
    BattleManager.ClearLuaData()
    MgrSce.Load(MgrSce.Scenes.Home,function()
        MgrBattle.curType = MgrBattle.fightType.none
        if isHome then
            ---直接返回大厅
            MgrUI.GoFirst(UID.Home_UI, cell)
        else
            --MgrUI.Pop(UID.FullLoading_UI,{0.5,nil,nil,true},true)
            ---弹出缓存界面
            MgrUI.ShowCacheUI(cell)
        end
    end)
end

return MgrBattle
