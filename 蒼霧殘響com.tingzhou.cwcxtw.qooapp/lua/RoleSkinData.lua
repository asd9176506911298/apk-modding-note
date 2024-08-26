---@class RoleSkinData 角色数据
RoleSkinData = Class("RoleSkinData")

function RoleSkinData:ctor(id)
    local config = RoleuiskinLocalData.tab[id]
    local config2 = UiskinlockLocalData.tab[id]
    local backGroundConfig = MainuiskinLocalData.tab[id]
    self.id = config.id                             ---皮肤ID
    self.type = config.type                         ---前景类型
    self.skinName = config.name                     ---皮肤名称
    self.story = config.story                       ---皮肤故事
    self.backgroundpic = config.backgroundpic       ---皮肤背景
    self.foregroundpic = config.foregroundpic       ---皮肤前景
    self.cv = config.voiceexcellence                ---CV
    if backGroundConfig then
        self.morning = backGroundConfig.morning
        self.evening = backGroundConfig.evening
    else
        self.morning = nil
        self.evening = nil
    end
    self.roleId = config2.roleid
    self.unlockState = false
    self.interaction = config.interaction
    self.unlock = self:SplitLadder_One(config2.unlock)
end

function RoleSkinData:SplitLadder_One(str)
    if str == nil or str == "" then
        return {}
    end
    if str == "0" then
        self:SetLockState(true)
        return {}
    end
    local gs = string.split(str, "_")
    ---@type goods
    local goods = {}
    goods.goodsType = tonumber(gs[1])
    goods.goodsID = tonumber(gs[2])
    goods.goodsNum = tonumber(gs[3])
    return goods
end

function RoleSkinData:SetLockState(state)
    self.unlockState = state
end


return RoleSkinData