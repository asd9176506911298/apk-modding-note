require("LocalData/RoleattriskillupLocalData")
require("Model/Skill/Data/SkillUpData")
---加锁管理器
SkillUpControl = {}
local mSkillUpData = {}

function SkillUpControl.InitSkillUpData()
    mSkillUpData = {}
    for i, v in pairs(RoleattriskillupLocalData.tab) do
        if mSkillUpData[v[2]] == nil then
            mSkillUpData[v[2]] = {}
            mSkillUpData[v[2]][v[3]] = SkillUpData.New()
        else
            if mSkillUpData[v[2]][v[3]] == nil then
                mSkillUpData[v[2]][v[3]] = SkillUpData.New()
            end
        end
        mSkillUpData[v[2]][v[3]]:PushData(v)
    end
end
---获取技能升级材料
function SkillUpControl.GetSkillUpData(_rank, _skillLv)
    local tData = mSkillUpData[_rank][_skillLv]
    
    return tData
end

function SkillUpControl.Clear()
    mSkillUpData = {}
end

return SkillUpControl
