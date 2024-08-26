---@class ArkItemData:ItemDataBase 物品数据
ArkItemData = Class("ArkItemData")
require("LocalData/HomecharactertxtLocalData")
-------------构造方法-------------
function ArkItemData:ctor(id)
    local config = HomecharacterLocalData.tab[id]
    local itemConfig = HideLocalData.tab[id]
    self.id = id         ---物品配置ID
    self.icon = string.format("Item/%s",itemConfig.icon)      ---物品图标
    self.name = itemConfig.name      ---物品名称
    self.iconFrame= "Quality/RoleRankN_"..itemConfig.quality
    self.coordinate= config[4]  ---立绘坐标
    self.proportion= config[5]  ---点击区域坐标
    self.contentone= config[6]  ---待机点击内容
    self.contenttwo= config[7]  ---点头点击内容
    self.contentthree= config[8]---点胸点击内容
    self.contentfour= config[9] ---点腿点击内容
    self.entervoice=config[10]  ---进入家园内容
    self.setvoice=config[11]    ---设为看板内容
    self.unlockvoice=config[12] ---解锁时语音内容
    self.audition=config[13]    ---语音试听
    self.charplot=config[14]    ---个人剧情
    self.profiles=HomecharactertxtLocalData.tab[tonumber(config[15])][2]    ---个人档案
    self.unlocktxt=HomecharactertxtLocalData.tab[tonumber(config[16])][2]   ---解锁途径
    self.unlock=false   ---是否解锁
    self.choose=false   ---是否为当前选择
    self.like=false     ---是否为喜欢
    self.Plot = UnityEngine.PlayerPrefs.HasKey(tostring(self.id)..PlayerControl.GetPlayerData().UID.."Plot")  ---是否观看过剧情
    self.appear = config[17]   ---是否显示 为0始终显示 为1如果未获得就不显示
end

function ArkItemData:IsUnlock(data)
    self.unlock=data
end

function ArkItemData:SetLike()
    if self.like then
        UnityEngine.PlayerPrefs.DeleteKey(tostring(self.id)..PlayerControl.GetPlayerData().UID)
    else
        UnityEngine.PlayerPrefs.SetInt(tostring(self.id)..PlayerControl.GetPlayerData().UID,self.id)
    end
    self.like = not self.like
end

function ArkItemData:SetPlot()
    if not self.Plot then
        UnityEngine.PlayerPrefs.SetInt(tostring(self.id)..PlayerControl.GetPlayerData().UID.."Plot",self.id)
        self.Plot = UnityEngine.PlayerPrefs.HasKey(tostring(self.id)..PlayerControl.GetPlayerData().UID.."Plot")
    end
end

return ArkItemData