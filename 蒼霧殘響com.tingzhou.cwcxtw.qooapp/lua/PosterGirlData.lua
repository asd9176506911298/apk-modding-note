---@class PosterGirlData 角色数据
PosterGirlData = Class("PosterGirlData")

function PosterGirlData:ctor(id)
    ---获取看板娘信息
    local config = Live2dLocalData.tab[id]

    self.id = config[1]                                                         ---id
    self.name = config[2]                                                       ---名称
    self.Interaction = config[3]                                                ---台词组别
    self.icon = "ABOriginal/Role/" ..config[1].. "/NormalIcon/normal"          ---角色头像
    self.rolepicturespine = "ABOriginal/Role/" ..config[1].. "/WatchSpine"   ---立绘动画
    self.coordinate0 = config[6]        ---主界面坐标
    self.coordinate1 = config[7]        ---养成界面坐标
    self.coordinate2 = config[8]        ---抽卡界面坐标

    self.rank = 4                             ---排序品质
    self.cTime = 9000000000                   ---获取时间，可改成读表

    self.iconFrame = "Quality/RoleRank_"..self.rank   ---角色头像边框
end


return PosterGirlData