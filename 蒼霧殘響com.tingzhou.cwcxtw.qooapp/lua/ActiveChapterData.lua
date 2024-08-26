---@class ActiveChapterData 物品数据
ActiveChapterData = Class("ActiveChapterData")
-------------构造方法-------------
function ActiveChapterData:ctor(id)
    local config = ActivechapterLocalData.tab[id]
    self.chapterid = config.chapterid                   ---章id
    self.chaptertype = config.chaptertype               ---章类型
    self.chapternum = config.chapternum                 ---章节顺序
    self.chaptername = config.chaptername               ---章节名称
    self.chapterdesc = config.chapterdesc               ---章节描述
    self.scrollid = config.scrollid                     ---分卷id
    self.pickicon = config.pickicon                     ---图标图片
    self.chapterpicture = config.chapterpicture         ---章背景图
    self.scrollpicture = config.scrollpicture           ---分卷背景图
    self.unlocklevel = config.unlocklevel               ---解锁门票关卡的id
    self.plot = config.plot                             ---章剧情
    self.chaptermusic = config.chaptermusic             ---章bgm
    self.scrollmusic = config.scrollmusic               ---分卷bgm
    self.chaptertime = config.chaptertime               ---章开关时间
    self.beginTime = "0"                                ---活动开始时间
    self.endTime = "0"                                  ---活动结束时间
    self.dayTime = 0                                    ---活动开启天数(特殊时间类型才会判断天数，一般为0)
    if TimeLocalData.tab[config.chaptertime] then
        if self.timeType ~= 999 then
            self.beginTime = TimeLocalData.tab[config.chaptertime][6]
            self.endTime = TimeLocalData.tab[config.chaptertime][7]
        else
            self.dayTime = tonumber(TimeLocalData.tab[config.chaptertime][8])
        end
    end
    self.levels = {}
    local tList = string.split(config.levels,",")
    for i = 1, #tList do
        table.insert(self.levels, tonumber(tList[i]))
    end
    self.awardview = {}
    tList = string.split(config.awardview,",")
    for i = 1, #tList do
        table.insert(self.awardview, tList[i])
    end
    self.bossbackground = config.bossbackground         ---BOSS背景图
    self.bosspicture = config.bosspicture               ---BOSS形象
    self.bossPos = config.bosspos                       ---BOSS坐标
    self.objectivetips = config.objectivetips           ---章节通关目标描述
    self.mapmode = config.mapmode                       ---地图显示模式
end

return ActiveChapterData