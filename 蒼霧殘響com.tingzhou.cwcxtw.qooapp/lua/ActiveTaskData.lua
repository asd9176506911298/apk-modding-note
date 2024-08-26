---@class ActiveTaskData
ActiveTaskData = Class("ActiveTaskData")
-------------构造方法-------------
function ActiveTaskData:ctor(id)
    local config = ActiveLocalData.tab[id]
end

return ActiveTaskData