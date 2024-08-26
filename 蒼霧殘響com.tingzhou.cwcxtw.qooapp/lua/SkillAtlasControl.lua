SkillAtlasControl = {}
require("LocalData/SkilldexLocalData")
require("Model/Illustration/Data/SkillAtlasData")

---@type SkillAtlasData[] 所有技能数据缓存
local AllCacheData = {}
---主技能数据
local MainSkillData = {}

---初始化数据
function SkillAtlasControl.InitData()
    ---灌注所有技能数据
    for k,v in pairs(SkilldexLocalData.tab) do
        table.insert(AllCacheData,SkillAtlasData.New(v[1]))
    end
    ---灌注主技能数据
    for k,v in pairs(AllCacheData) do
        if MainSkillData[v.type1] == nil then
            MainSkillData[v.type1] = v.type1Name
        end
    end
end

---获取主数据
function SkillAtlasControl.GetMainData()
    return MainSkillData
end

---@return SkillAtlasData[] 传入主类型获取对应技能子类别数据
function SkillAtlasControl.GetSonData(type)
    local arr = {}
    for k,v in pairs(AllCacheData) do
        if v.type1 == type and arr[v.type2] == nil then
            arr[v.type2] = v
        end
    end
    Global.Sort(arr,{"type2"},false)
    return arr
end

---传入子类型获取所有子类型的技能数据
function SkillAtlasControl.GetItemData(type1,type2)
    local arr = {}
    for k,v in pairs(AllCacheData) do
        if v.type1 == type1 and v.type2 == type2 then
            table.insert(arr,v)
        end
    end
    Global.Sort(arr,{"Sort"},false)
    return arr
end

function SkillAtlasControl.Clear()
    AllCacheData = {}
    MainSkillData = {}
end


return SkillAtlasControl