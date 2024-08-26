require("LocalData/SkilllistLocalData")
require("Model/Skill/Data/SkillDetailData")
---加锁管理器
SkillDetailControl = {}
---@type SkillDetailData[]
---角色技能说明
SkillDetailControl.SkillDetailList = {}

function SkillDetailControl.InitSkillDetail()
    SkillDetailControl.SkillDetailList = {}
    for i, v in pairs(SkilllistLocalData.tab) do
        if SkillDetailControl.SkillDetailList[v[2]] == nil then
            SkillDetailControl.SkillDetailList[v[2]] = {}
            SkillDetailControl.SkillDetailList[v[2]][v[3]] = SkillDetailData.New()
        else
            if SkillDetailControl.SkillDetailList[v[2]][v[3]] == nil then
                SkillDetailControl.SkillDetailList[v[2]][v[3]] = SkillDetailData.New()
            end
        end
        SkillDetailControl.SkillDetailList[v[2]][v[3]]:PushConfig(v)
    end
end
---获取技能简略列表 _index为heroID
function SkillDetailControl.GetSkillListByID(_index)
    ---如果有EX,将有EX技能前置
    local tList = SkillDetailControl.SkillDetailList[_index]
    local tSkillList = {}
    if #tList == 5 then
        tSkillList[1] = tList[5]
        for i = 1, #tList-1 do
            tSkillList[#tSkillList+1] = tList[i]
        end
    else
        for i, v in pairs(tList) do
            table.insert(tSkillList,v)
        end
    end
    
    return tSkillList
end

function SkillDetailControl.Clear()
    SkillDetailControl.SkillDetailList = {}
end

return SkillDetailControl
