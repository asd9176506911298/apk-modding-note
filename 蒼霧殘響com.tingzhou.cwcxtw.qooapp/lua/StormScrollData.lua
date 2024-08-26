---卷数据
---@class StormScrollData
---@field box ScrollRewardBox[] 章节宝箱
StormScrollData = Class('StormScrollData')
---构造方法
function StormScrollData:ctor(id)
    self.id = id                        ---卷ID
    self.points = {}                    ---卷下的关卡id
    self.type = nil                     ---卷类型
    self.type2 = nil                    ---卷子类型
    self.index = nil                    ---卷序
    self.name = ""                      ---卷名
    self.alias = ""                     ---卷别名
    self.description = ""               ---卷描述
    self.scrollimg = ""                 ---卷图片
    self.scrollbg = ""                  ---卷背景
    self.map = ""                       ---卷地图
    self.bgm = ""                       ---卷背景音乐
    self.box = {}                       ---章节宝箱(id = {图片，星级，奖励})
    self.additionitem = {}              ---加成道具
    self.additionrole = {}              ---加成角色
    self.raidType = nil                 ---副本类型
    self.effect = nil                   ---特效
    self.pickIcon = nil                 ---资源副本图标
end
---@param config ChapterLocalData
function StormScrollData:PushConfig(config)
    self.id = config.id                 ---卷ID
    local pointStr = string.split(config.simple,",")
    for idx, idStr in pairs(pointStr) do
        self.points[#self.points + 1] = tonumber(idStr)
    end
    table.sort(self.points,function(a,b)
        if a < b then
            return true
        end
    end)
    self.type = config.sort             ---卷类型
    self.type2 = config.sortchild       ---卷子类型
    self.index = config.scroll          ---卷序
    self.name = config.scrollname       ---卷名
    self.alias = config.titlename       ---卷别名
    self.description = config.desc      ---卷描述
    self.icon = string.format("Storm/%s",config.scrollimg)   ---卷封面
    self.bg = string.format("Storm/%s",config.scrollbg)    ---卷背景
    self.map = config.background                   ---卷地图
    self.bgm = config.bgm                   ---卷背景音乐
    self.additionitem = string.split(config.additionitem,"_")   ---活动加成道具
    self.additionrole = string.split(config.additionrole,"_")   ---活动加成角色
    self.raidType = config.type
    self.effect = config.bgeffect   ---背景特效
    self.pickIcon = config.pickicon  ---资源本小图标
    ---获取章节宝箱
    for boxId, boxConf in pairs(ChapterboxLocalData.tab) do
        if boxConf[2] == self.id then
            self.box[boxId] = {
                img = boxConf[3],
                star = boxConf[4],
                reward = boxConf[5],
                isGet = false,
            }
        end
    end
end
---添加挑战红巨配置属性
function StormScrollData:PushTower(points)
    self.id = 1
    local pointStr = string.split(points,",")
    for idx, idStr in pairs(pointStr) do
        self.points[#self.points + 1] = tonumber(idStr)
    end
    self.name = MgrLanguageData.GetLanguageByKey("stormscrolldata_redtower")
    self.type2 = 20
    self.bg = "Storm/ScrollBg_20_20"  ---卷背景
end
---添加挑战战术指导配置
function StormScrollData:PushGuide(points)
    self.id = 1
    local pointStr = string.split(points,",")
    for idx, idStr in pairs(pointStr) do
        self.points[#self.points + 1] = tonumber(idStr)
    end
    self.name = MgrLanguageData.GetLanguageByKey("stormscrolldata_tacticguide")
    self.type2 = 21
    self.bg = "Storm/ScrollBg_20_21"  ---卷背景
end
---更新章节宝箱领取状态
function StormScrollData:PushBox(boxId)
    for id, box in pairs(self.box) do
        if id == boxId then
            self.box[id].isGet = true
        end
    end
end
---获取章节完成度
---@return number,number 当前进度，总进度
function StormScrollData:GetCompletion()
    local maxCom = 0
    local curCom = 0
    for i, id in pairs(self.points) do
        maxCom = maxCom + 1
        if StormControl.GetStormPointByID(id).star > 0 then
            curCom = curCom + 1
        end
    end
    return curCom,maxCom
end
---获取挑战章节完成度
---@return number,number 当前进度，总进度
function StormScrollData:GetChaCompletion()
    local maxCom = 0
    local curCom = 0
    if self.type2 == 20 then
        for i, data in pairs(StormControl.GetStormTowerPointData()) do
            maxCom = maxCom + 1
            for i, v in ipairs(data:CheckTowerTask()) do
                if v then
                    curCom = curCom + 1
                    break
                end
            end
        end
    elseif self.type2 == 21 then
        for i, data in pairs(StormControl.GetStormGuidePointData()) do
            maxCom = maxCom + 1
            if data:CheckGuideLock() then
                curCom = curCom + 1
            end
        end
    end
    return curCom,maxCom
end
---获取战术指导完成度
---@return number,number 当前进度，总进度
function StormScrollData:GetGuideCompletion()
    local maxCom = 0
    local curCom = 0
    for i, data in pairs(StormControl.GetStormGuidePointData()) do
        maxCom = maxCom + 1
        for i, v in ipairs(data:CheckGuideLock()) do
            if v then
                curCom = curCom + 1
                break
            end
        end
    end
    return curCom,maxCom
end
---获取章节宝箱星级
---@return number,number 最大星，当前星 最大星为0则无章节宝箱
function StormScrollData:GetMaxBoxStar()
    if self.type ~= 0 then
        return 0,0
    end
    if self.type == 0 and self.raidType == 999 then
        return 1,1
    end
    local maxStar = 0
    local curStar = 0
    ---获取最大星
    for i, v in pairs(self.box) do
        if v.star > maxStar then
            maxStar = v.star
        end
    end
    ---获取当前星
    for i, id in pairs(self.points) do
        local data = StormControl.GetStormPointByID(id)
        if data.battleMap ~= nil and data.battleMap ~= "0" and data.type ~= 999 then
            local s1,s2,s3 = data:CheckStar()
            curStar = s1 and curStar + 1 or curStar
            curStar = s2 and curStar + 1 or curStar
            curStar = s3 and curStar + 1 or curStar
        end
    end
    return maxStar,curStar
end
---@return boolean 是否存在可领取章节宝箱
function StormScrollData:IsGetBoxStar()
    local curStar = 0
    ---获取当前星
    for i, id in pairs(self.points) do
        local data = StormControl.GetStormPointByID(id)
        if data.battleMap ~= nil and data.battleMap ~= "0" and data.type ~= 999 then
            local s1,s2,s3 = data:CheckStar()
            curStar = s1 and curStar + 1 or curStar
            curStar = s2 and curStar + 1 or curStar
            curStar = s3 and curStar + 1 or curStar
        end
    end
    ---获取当前目标最大星
    for i, v in pairs(self.box) do
        if not v.isGet and curStar >= v.star then
            return true
        end
    end
    return false
end

---@class ScrollRewardBox 章节宝箱
local ScrollRewardBox = {
    img = 1,
    star = 2,
    reward = 3,
    isGet = 4,
}

return StormScrollData