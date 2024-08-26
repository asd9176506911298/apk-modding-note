---@class ActiveTutorialData  活动引导数据
ActiveTutorialData = Class('ActiveTutorialData')
---@param id number 构造方法
function ActiveTutorialData:ctor(id)
    local config = ActiveTutorialLocalData.tab[id]
    self.id = id
    self.group = config[2]
    self.title = config[3]
    self.text = config[4]
    self.picture = config[5]
end

---获取本地数据状态 是否已经弹出
function ActiveTutorialData:GetLocalState()
    local player = PlayerControl.GetPlayerData()
    if UnityEngine.PlayerPrefs.HasKey(player.UID.."ActiveTutorialLocalData_"..self.group) then
        if UnityEngine.PlayerPrefs.GetString(player.UID.."ActiveTutorialLocalData_"..self.group) == "true" then
            return true
        else
            return false
        end
    else
        return false
    end
end

function ActiveTutorialData:SetLocalState()
    local player = PlayerControl.GetPlayerData()
    UnityEngine.PlayerPrefs.SetString(player.UID.."ActiveTutorialLocalData_"..self.group,"true")
end

return ActiveTutorialData