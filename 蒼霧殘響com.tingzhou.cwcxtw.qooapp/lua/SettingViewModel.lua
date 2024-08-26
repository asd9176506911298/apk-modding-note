require("LocalData/SamplevoiceLocalData") ---设置声音示例表
require("LocalData/SteamLocalData") ---设置声音示例表
---设置VM
SettingViewModel = {}

---初始设定
function SettingViewModel.Init()
    ---设置画质
    SettingViewModel.SetQuality(SettingViewModel.GetQuality())
    ---设置战斗速度
    SettingViewModel.SetBattleSpeed(SettingViewModel.GetBattleSpeed())
    ---设置Ex动画
    SettingViewModel.SetExAnim(SettingViewModel.GetExAnim())
    ---设置Spine动画
    SettingViewModel.SetSpineAnim(SettingViewModel.GetSpineAnim())
    ---设置所有异形适配
    --SettingViewModel.SetFringe(SettingViewModel.GetFringe())
    ---设置所有音量
    SettingViewModel.SetAllSound(SettingViewModel.GetAllSound())
    ---设置背景音量
    SettingViewModel.SetBGMSound(SettingViewModel.GetBGMSound())
    ---设置音效音量
    SettingViewModel.SetEffectSound(SettingViewModel.GetEffectSound())
    ---设置语音音量
    SettingViewModel.SetRoleSound(SettingViewModel.GetRoleSound())
    ---设置体力提醒
    SettingViewModel.SetPowerRemind(SettingViewModel.GetPowerRemind())
    ---设置世界boss提醒
    SettingViewModel.SetWBRemind(SettingViewModel.GetWBRemind())
    ---设置演习场提醒
    SettingViewModel.SetPVPRemind(SettingViewModel.GetPVPRemind())
    ---设置对话框透明度
    SettingViewModel.SetDramaAlpha(SettingViewModel.GetDramaAlpha())
    ---设置对话框文本速度
    SettingViewModel.SetDramaSpeed(SettingViewModel.GetDramaSpeed())
    ---设置剧情自动播放速度
    SettingViewModel.SetDramaASpeed(SettingViewModel.GetDramaASpeed())
    ---设置语音开关
    SettingViewModel.SetPlotLH(SettingViewModel.GetPlotLH())
    SettingViewModel.SetPlotJY(SettingViewModel.GetPlotJY())
    SettingViewModel.SetPlotSDFN(SettingViewModel.GetPlotSDFN())
    SettingViewModel.SetPlotCLS(SettingViewModel.GetPlotCLS())
    SettingViewModel.SetPlotZLWS(SettingViewModel.GetPlotZLWS())
    SettingViewModel.SetPlotFLK(SettingViewModel.GetPlotFLK())
    SettingViewModel.SetPlotOther(SettingViewModel.GetPlotOther())
end
---重置设置
function SettingViewModel.ReSetting()
    ---异形屏初始化
    --SettingViewModel.SetFringe(0)
    ---设置画质
    SettingViewModel.SetQuality(tonumber(SteamLocalData.tab[116000][2]))
    ---设置战斗速度
    SettingViewModel.SetBattleSpeed(tonumber(SteamLocalData.tab[116001][2]))
    ---设置战斗镜头
    SettingViewModel.SetCameraMove(1)
    ---设置Ex动画
    SettingViewModel.SetExAnim(tonumber(SteamLocalData.tab[116002][2]))
    ---设置Spine动画
    SettingViewModel.SetSpineAnim(tonumber(SteamLocalData.tab[116003][2]))
    ---设置所有音量
    SettingViewModel.SetAllSound(tonumber(SteamLocalData.tab[116004][2]))
    ---设置背景音量
    SettingViewModel.SetBGMSound(tonumber(SteamLocalData.tab[116005][2]))
    ---设置音效音量
    SettingViewModel.SetEffectSound(tonumber(SteamLocalData.tab[116006][2]))
    ---设置语音音量
    SettingViewModel.SetRoleSound(tonumber(SteamLocalData.tab[116007][2]))
    ---设置对话框透明度
    SettingViewModel.SetDramaAlpha(tonumber(SteamLocalData.tab[116011][2]))
    ---设置对话框文本速度
    SettingViewModel.SetDramaSpeed(tonumber(SteamLocalData.tab[116012][2]))
    ---设置剧情自动播放速度
    SettingViewModel.SetDramaASpeed(tonumber(SteamLocalData.tab[116013][2]))
    ---设置语音开关
    SettingViewModel.SetPlotLH(tonumber(SteamLocalData.tab[116014][2]))
    SettingViewModel.SetPlotJY(tonumber(SteamLocalData.tab[116015][2]))
    SettingViewModel.SetPlotSDFN(tonumber(SteamLocalData.tab[116016][2]))
    SettingViewModel.SetPlotCLS(tonumber(SteamLocalData.tab[116017][2]))
    SettingViewModel.SetPlotZLWS(tonumber(SteamLocalData.tab[116018][2]))
    SettingViewModel.SetPlotFLK(tonumber(SteamLocalData.tab[116019][2]))
    SettingViewModel.SetPlotOther(tonumber(SteamLocalData.tab[116020][2]))
end

---@return number 获取画质 1普通、2高画质
function SettingViewModel.GetQuality()
    local q = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_Quality")
    if q == nil or q == 0 then
        q = tonumber(SteamLocalData.tab[116000][2])
    end
    return q
end
---@param value number 画质 1普通、2高画质
function SettingViewModel.SetQuality(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_Quality",value)
    CMgrCamera.Instance:SetFrameRate(value)
end
---@return number 获取战斗速度 1一倍速、2二倍速、3三倍速
function SettingViewModel.GetBattleSpeed()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_Speed")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116001][2])
    end
    return s
end
---@param value number 战斗速度 1一倍速、2二倍速、3三倍速
function SettingViewModel.SetBattleSpeed(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_Speed",value)
    if value == 1 then
        CJNBattleMgr.SetGameSpeed(1)
    elseif value == 2 then
        CJNBattleMgr.SetGameSpeed(2)
    --elseif value == 3 then
        --CJNBattleMgr.SetGameSpeed(2.5)
    end
end
---@return number 获取Ex技能动画 1开启、2关闭
function SettingViewModel.GetExAnim()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_ExAnim")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116002][2])
    end
    return s
end
---@param value number Ex技能动画 1开启、2关闭
function SettingViewModel.SetExAnim(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_ExAnim",value)
    CJNBattleMgr.NoEx = value == 2
end

function SettingViewModel.GetCameraMove()
    local f = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_CameraMove")
    if f == nil or f == 0 then
        --f = tonumber(SteamLocalData.tab[116002][2])
        f = 1   --默认的为移动
    end
    return f
end

function SettingViewModel.SetCameraMove(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_CameraMove",value)
end

---@return number 获取动态立绘显示 1开启、2关闭
function SettingViewModel.GetSpineAnim()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_SpineAnim")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116003][2])
    end
    return s
end
---@param value number 动态立绘显示 1开启、2关闭
function SettingViewModel.SetSpineAnim(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_SpineAnim",value)
    if value == 1 then
    elseif value == 2 then
    end
end
---@return number 获取异形屏适配 0~100
--function SettingViewModel.GetFringe()
--    local s = UnityEngine.PlayerPrefs.GetString(PlayerControl.GetPlayerData().UID.."St_Fringe")
--    if s == "" then
--        -- s = CMgrUI.Instance.AreaX
--        s = math.min(100, CMgrUI.Instance.AreaX)
--    end
--    return s
--end
---@param value number 异形屏适配 0~100
--function SettingViewModel.SetFringe(value)
--    UnityEngine.PlayerPrefs.SetString(PlayerControl.GetPlayerData().UID.."St_Fringe",tostring(value))
--    CMgrUI.Instance.AreaX = tonumber(value)
--end
---@return number 获取整体声音 1开启、2关闭
function SettingViewModel.GetAllSound()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_AllSound")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116004][2])
    end
    return s
end
---@param value number 整体声音 1开启、2关闭
function SettingViewModel.SetAllSound(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_AllSound",value)
    if value == 1 then
        MgrSound.SetAllVol(1)
    elseif value == 2 then
        MgrSound.SetAllVol(0)
    end
end
---@return number 获取背景音乐 0~100
function SettingViewModel.GetBGMSound()
    local s = UnityEngine.PlayerPrefs.GetString(PlayerControl.GetPlayerData().UID.."St_BGMSound")
    if s == "" then
        s = tonumber(SteamLocalData.tab[116005][2])
    end
    return tonumber(s)
end
---@param value number 获取背景音乐 0~100
function SettingViewModel.SetBGMSound(value)
    UnityEngine.PlayerPrefs.SetString(PlayerControl.GetPlayerData().UID.."St_BGMSound",tostring(value))
    MgrSound.SetBGMVol(value/100)
end
---@return number 获取音效音量 0~100
function SettingViewModel.GetEffectSound()
    local s = UnityEngine.PlayerPrefs.GetString(PlayerControl.GetPlayerData().UID.."St_EffectSound")
    if s == "" then
        s = tonumber(SteamLocalData.tab[116006][2])
    end
    return tonumber(s)
end
---@param value number 获取音效音量 0~100
function SettingViewModel.SetEffectSound(value)
    UnityEngine.PlayerPrefs.SetString(PlayerControl.GetPlayerData().UID.."St_EffectSound",tostring(value))
    MgrSound.SetEffectVol(value/100)
    MgrSound.SetFightVol(value/100)
end
---@return number 获取语音音量 0~100
function SettingViewModel.GetRoleSound()
    local s = UnityEngine.PlayerPrefs.GetString(PlayerControl.GetPlayerData().UID.."St_RoleSound")
    if s == "" then
        s = tonumber(SteamLocalData.tab[116007][2])
    end
    return tonumber(s)
end
---@param value number 语音音量 0~100
function SettingViewModel.SetRoleSound(value)
    UnityEngine.PlayerPrefs.SetString(PlayerControl.GetPlayerData().UID.."St_RoleSound",tostring(value))
    MgrSound.SetRoleVol(value/100)
    MgrSound.SetPlotVol(value/100)
end

---@return number 获取体力全满提醒 1开启、2关闭
function SettingViewModel.GetPowerRemind()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PowerRemind")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116008][2])
    end
    return s
end
---@param value number 获取体力全满提醒 1开启、2关闭
function SettingViewModel.SetPowerRemind(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PowerRemind",value)
    if value == 1 then
    elseif value == 2 then
    elseif value == 3 then
    end
end
---@return number 获取世界Boss提醒 1开启、2关闭
function SettingViewModel.GetWBRemind()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_WBRemind")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116009][2])
    end
    return s
end
---@param value number 获取世界Boss提醒 1开启、2关闭
function SettingViewModel.SetWBRemind(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_WBRemind",value)
    if value == 1 then
    elseif value == 2 then
    elseif value == 3 then
    end
end
---@return number 获取演习场提醒 1开启、2关闭
function SettingViewModel.GetPVPRemind()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_WBRemind")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116010][2])
    end
    return s
end
---@param value number 演习场提醒 1开启、2关闭
function SettingViewModel.SetPVPRemind(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_WBRemind",value)
    if value == 1 then
    elseif value == 2 then
    end
end
---@return number 对话框透明度 0~100
function SettingViewModel.GetDramaAlpha()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_DramaA")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116011][2])
        s = s < 1 and 1 or s
        s = s > 100 and 100 or s
    end
    return s
end
---@param value number 对话框透明度 1~100
function SettingViewModel.SetDramaAlpha(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_DramaA",value)
end
---@return number 对话框文本播放速度 1~100
function SettingViewModel.GetDramaSpeed()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_DramaS")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116012][2])
        s = s < 1 and 1 or s
        s = s > 100 and 100 or s
    end
    return s
end
---@param value number 对话框文本播放速度 1~100
function SettingViewModel.SetDramaSpeed(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_DramaS",value)
end
---@return number 剧情跳幕间隔 1~100 （50为1秒）
function SettingViewModel.GetDramaASpeed()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_DramaAS")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116013][2])
        s = s < 1 and 1 or s
        s = s > 100 and 100 or s
    end
    return s
end
---@param value number 剧情跳幕间隔 1~100 （50为1秒）
function SettingViewModel.SetDramaASpeed(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_DramaAS",value)
end
---@return number 剧情领航语音开关 1开启、2关闭
function SettingViewModel.GetPlotLH()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotLH")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116014][2])
    end
    return s
end
---@param value number 剧情领航语音开关 1开启、2关闭
function SettingViewModel.SetPlotLH(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotLH",value)
end
---@return number 剧情吉雅语音开关 1开启、2关闭
function SettingViewModel.GetPlotJY()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotJY")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116015][2])
    end
    return s
end
---@param value number 剧情吉雅语音开关 1开启、2关闭
function SettingViewModel.SetPlotJY(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotJY",value)
end
---@return number 剧情史提芬妮语音开关 1开启、2关闭
function SettingViewModel.GetPlotSDFN()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotSDFN")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116016][2])
    end
    return s
end
---@param value number 剧情史提芬妮语音开关 1开启、2关闭
function SettingViewModel.SetPlotSDFN(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotSDFN",value)
end
---@return number 剧情查丽莎语音开关 1开启、2关闭
function SettingViewModel.GetPlotCLS()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotCLS")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116017][2])
    end
    return s
end
---@param value number 剧情查丽莎语音开关 1开启、2关闭
function SettingViewModel.SetPlotCLS(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotCLS",value)
end
---@return number 剧情朱利乌斯语音开关 1开启、2关闭
function SettingViewModel.GetPlotZLWS()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotZLWS")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116018][2])
    end
    return s
end
---@param value number 剧情朱利乌斯语音开关 1开启、2关闭
function SettingViewModel.SetPlotZLWS(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotZLWS",value)
end
---@return number 剧情弗兰卡语音开关 1开启、2关闭
function SettingViewModel.GetPlotFLK()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotFLK")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116019][2])
    end
    return s
end
---@param value number 剧情弗兰卡语音开关 1开启、2关闭
function SettingViewModel.SetPlotFLK(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotFLK",value)
end
---@return number 剧情其他语音开关 1开启、2关闭
function SettingViewModel.GetPlotOther()
    local s = UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."St_PlotOther")
    if s == nil or s == 0 then
        s = tonumber(SteamLocalData.tab[116020][2])
    end
    return s
end
---@param value number 剧情其他语音开关 1开启、2关闭
function SettingViewModel.SetPlotOther(value)
    UnityEngine.PlayerPrefs.SetInt(PlayerControl.GetPlayerData().UID.."St_PlotOther",value)
end

---修改签名请求
function SettingViewModel.CDKeyREQ(_key,callBack)
    local REQ  =
    {
        key = _key
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientCDKeyREQ',REQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_CDKEY_REQ,bytes,0,nil,SettingViewModel.CDKeyACK,function(...)
        SettingViewModel.CDKeyNTF(...)
        if callBack then
            callBack()
        end
    end)
end

function SettingViewModel.CDKeyACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientCDKeyACK',buffer))
    print(tab.errNo)
    if tab.errNo ~= 0 then
        if tab.errNo == 6 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_cdkey_tips1"),2},true)
        else
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_tongyong_text227"),2},true)
        end
    end
end


function SettingViewModel.CDKeyNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientCDKeyNTF',buffer))
    if tab.email then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("ui_tongyong_text226"),2},true)
    end
end

return SettingViewModel
