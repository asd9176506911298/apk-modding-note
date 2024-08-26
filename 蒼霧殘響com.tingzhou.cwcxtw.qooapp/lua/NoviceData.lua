---@class NoviceData
---@field id number 引导id
---@field EventName string 事件名
---@field isTrigger boolean 是否触发
NoviceData = Class('NoviceData')
---@param id number 构造方法
function NoviceData:ctor(id)
    local config = TutorialLocalData.tab[id]
    self.id = id
    self.isTrigger = false
    self.isDone = false
    self.group = config[2]
    self.condition = {}
    local Str = string.split(config[3],",")
    for i, v in pairs(Str) do
        if config[3] ~= "0" and config[3] ~= "-1"  and config[3] ~= nil then
            self.condition[i] = v
        end
    end
    self.coordinate = config[12]
    self.type = config[14]
    self.endSign = config[16]
    self.EventName = config[19]
    self.nextId = config[20]
    self.plotName = config[26]
    self.EndGroupId = config[27]
end

---@param trigger boolean 是否触发
function NoviceData.Change(trigger)
    self.isTrigger = trigger
end

return NoviceData