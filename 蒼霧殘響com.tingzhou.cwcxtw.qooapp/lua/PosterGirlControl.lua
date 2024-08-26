require("Model/PosterGirl/Data/PosterGirlData")
require("LocalData/Live2dLocalData")
---看板娘管理
PosterGirlControl = {}

---@type PosterGirlData[] 看板娘数据
local PosterGirlDataList = {}

------------接口--------------
---根据ID获得看板娘数据
---@return PosterGirlData
function PosterGirlControl.PosterGirlDataByID(roleId)
    return PosterGirlDataList[roleId]
end

---创建所有看板娘
function PosterGirlControl.CreateAllPosterGirl()
    --for i, v in pairs(Live2dLocalData.tab) do
    --    PosterGirlDataList[i] = PosterGirlData.New(i)
    --end
end

---获取所有看板娘
function PosterGirlControl.GetAllPosterGirl()
    local array = {}
    for i,v in pairs(PosterGirlDataList) do
        table.insert(array,v)
    end
    return array
end

---如果有看板娘需要解锁再加
function PosterGirlControl.GetHavePosterGirl()

end

function PosterGirlControl.Clear()
    PosterGirlDataList = {}
end

return PosterGirlControl