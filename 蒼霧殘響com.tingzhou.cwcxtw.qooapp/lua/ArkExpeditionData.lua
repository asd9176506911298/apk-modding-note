---@class ArkExpeditionData
ArkExpeditionData = Class('ArkData')
---@param id number 构造方法
function ArkExpeditionData:ctor(id)
    local config = ExpeditiontaskLocalData.tab[id]
    self.id = id                               ---ID
    self.name = config[2]                      ---任务名
    self.desc = config[3]                      ---任务描述
    self.levelLimit = config[4]                ---任务等级限制
    self.countLimit = config[5]                ---任务人数限制
    self.occupationLimit = config[6]           ---职业限制
    self.useTime = config[7]                   ---所需时间
    self.fixedReward = config[8]               ---固定掉落
    self.randomReward = config[9]              ---随机掉落
    self.icon = config[10]                     ---图片
    self.heroIds = {}                          ---远征的角色ID
    self.status = nil                          ---远征任务状态 0未开始，1正在远征，2远征结束
    self.uTime = 0                           ---远征任务更新时间
    self.expeditionId = nil                    ---远征任务ID(唯一)
end

---获得远征奖励
function ArkExpeditionData:GetRewards()
    local array = {}
    if self.fixedReward ~= "0" and self.fixedReward ~= nil then
        ---固定奖励
        local t = JNStrTool.strSplit(",",self.fixedReward)
        for i, v in pairs(t) do
            local config = Global.GetLocalDataByGoods(v)
            local vSelf = string.split(v,"_")
            local isGet = false
            if isGet ~= true then
                local data = {}
                data.type = vSelf[1]
                data.config = config
                data.id = config.id
                data.quality = config.quality
                data.isOnceAdopt = false
                data.probability = false
                data.count = tonumber(vSelf[3])
                data.isRec = false
                data.idx = #array + 1
                array[#array + 1] = data
            end
        end
    end
    if self.randomReward ~= "0" and self.randomReward ~= nil then
        ---随机奖励
        local t = string.split(self.randomReward,",")
        for i1, v1 in ipairs(t) do
            if v1 ~= nil and v1 ~= "0" and v1 ~= "" then
                local t1 = string.split(v1,"_")
                if t1[1] ~= nil and t1[1] ~= "0" and t1[1] ~= "" then
                    local rRs = DropLocalData.tab[tonumber(t1[1])][4]
                    if rRs ~= nil and rRs ~= "0" and rRs ~= "" then
                        local t3 = JNStrTool.strSplit(",",rRs)
                        for i2, v2 in pairs(t3) do
                            local config = Global.GetLocalDataByGoods(v2)
                            local v2Self = string.split(v2,"_")
                            local isGet = false
                            if isGet ~= true then
                                local data = {}
                                data.type = v2Self[1]
                                data.config = config
                                data.quality = config.quality
                                data.probability = true
                                data.isOnceAdopt = false
                                data.count = tonumber(v2Self[3])
                                data.isRec = false
                                data.idx = #array + 1
                                array[#array + 1] = data
                            end
                        end
                    end
                end
            end
        end
    end
    Global.Sort(array,{"idx"},{false,false})
    return array
end

---获取远征还有多久结束，返回字符串
function ArkExpeditionData:GetCompletedTime()
    local s = 0  ---时间:秒
    local m = 0  ---时间:分
    local h = 0  ---时间:时
    if self.status == 0 then
        s = math.floor(self.useTime % 60)
        m = math.floor((self.useTime % 3600) / 60)
        h = math.floor(self.useTime / 3600)
    elseif self.status == 1 then
        local time = self.useTime + self.uTime - Global.GetCurTime()
        s = math.floor(time % 60)
        m = math.floor((time % 3600) / 60)
        h = math.floor(time / 3600)
        if time <= 0 then
            return "00:00:00"
        end
    elseif self.status == 2 then
        return "00:00:00"
    end
    if(h < 10) then h = "0"..h end
    if(m < 10) then  m = "0"..m end
    if(s < 10) then s = "0"..s end
    return h..":"..m..":"..s
end
---获取是否远征中
function ArkExpeditionData:GetExpeditionState(uTime)
    ---远征时间+点击远征时间 = 远征完成时时间
    ----远征完成时时间 - 当前时间 = 剩余远征时间
    if uTime then
        self.uTime = uTime
    end
    local time = self.useTime + self.uTime - Global.GetCurTime()
    if time <= 0 then
        return false
    else
        ---剩余时间大于0说明还在远征中
        return true
    end
end

return ArkExpeditionData