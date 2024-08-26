require("LocalData/ActiveTutorialLocalData")
require("Model/Novice/Data/ActiveTutorialData")

ActiveTutorialControl = {}
---@type ActiveTutorialData[]
local AllTutorialData = {}  ---所有引导
local localState = {}

---初始化
function ActiveTutorialControl.Init()
    for k,v in pairs(ActiveTutorialLocalData.tab) do
        table.insert(AllTutorialData,ActiveTutorialData.New(v[1]))
    end
end

---初始化本地数据
function ActiveTutorialControl.InitLocalState()


end

---传入组ID获得整组引导数据
function ActiveTutorialControl.GetGroupDataByID(groupID)
    local arr = {}
    for k,v in pairs(AllTutorialData) do
        if v.group == tonumber(groupID) then
            table.insert(arr,v)
        end
    end
    Global.Sort(arr,{"id"},false)
    return arr
end

---获取组总页数
function ActiveTutorialControl.GetGroupMaxNum(groupID)
    local num = 0
    for k,v in pairs(AllTutorialData) do
        if v.group == groupID then
            num = num + 1
        end
    end
    return num
end

---获取组里最小的id
function ActiveTutorialControl.GetGroupMinNum(groupID)
    local num = 0
    for k,v in pairs(AllTutorialData) do
        if v.group == groupID then
            if num == 0 then
                num = v.id
            else
                if num < v.id then
                    num = v.id
                end
            end
        end
    end
    return num
end

---开启活动引导界面 传入活动组id
function ActiveTutorialControl.OpenGuide(groupID)
    ---@type ActiveTutorialData[]
    local arr = ActiveTutorialControl.GetGroupDataByID(groupID)
    MgrUI.Pop(UID.EventHelpPop_UI,{arr},true)
end

---进入某界面强制弹出
function ActiveTutorialControl.ForcePopGuide(groupID, callback)
    ---@type ActiveTutorialData[]
    local arr = ActiveTutorialControl.GetGroupDataByID(groupID)
    ---如果本地数据记录没有弹出
    if #arr > 0 and arr[1]:GetLocalState() == false then
        MgrUI.Pop(UID.EventHelpPop_UI,{arr, callback},true)
    end
end

---获取弹窗是否弹出过的状态
function ActiveTutorialControl.GetPopState(groupID)
    local arr = ActiveTutorialControl.GetGroupDataByID(groupID)

    if #arr > 0 then
        return arr[1]:GetLocalState()
    end
    ---如果找不到数据,也视作已弹出
    return true
end

function ActiveTutorialControl.Clear()
    AllTutorialData = {}
end

return ActiveTutorialControl