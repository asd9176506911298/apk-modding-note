require("LocalData/MonthpassawardLocalData")
---@class PassportItemData 物品数据
PassportItemData = Class("PassportItemData")
-------------构造方法-------------
function PassportItemData:ctor()
    self.id = 0         ---ID
    self.sort = 0       ---排序
    self.awardId = 0    ---通行证奖励组
    self.num = 0        ---通行证积分
    self.award_0 = {}   ---普通奖励
    self.award_1 = {}   ---高级奖励1
    self.award_2 = {}   ---高级奖励2
end

function PassportItemData:PushData(index)
    local config = MonthpassawardLocalData.tab[index]
    self.id = config[1]
    self.sort = config[2]
    self.awardId = config[3]
    self.num = config[4]
    local str1 = string.split(config[5],"_")
    self.award_0 = {tonumber(str1[1]),tonumber(str1[2]),tonumber(str1[3])}
    str1 = string.split(config[6],",")
    local str2 = string.split(str1[1],"_")
    self.award_1 = {tonumber(str2[1]),tonumber(str2[2]),tonumber(str2[3])}
    if str1[2] ~= nil then
        local str3 = string.split(str1[2],"_")
        self.award_2 = {tonumber(str3[1]),tonumber(str3[2]),tonumber(str3[3])}
    end
end

return PassportItemData