require("UI/ViewModel/StormViewModel")---战斗相关
---公告管理器
SysNoticeControl = {}

SysNoticeControl.SysNoticeData = {}
SysNoticeControl.SysNoticeObj = nil
---开启跑马灯
function SysNoticeControl.CheckNotice(data)
    if SysNoticeControl.CheckMsg(data) then
        ---剧情模式不给公告
        if StormViewModel == nil or not StormViewModel.IsPlotStarting then
            MgrUI.Pop(UID.SystemNotice_UI,{ data },true)
        end
        SysNoticeControl.SysNoticeData = data
    end
end
---注册跑马灯推送监听
function SysNoticeControl.RegisterMarqueeNtf()
    MgrNet.RegisterNTF(MID.CLIENT_MARQUEE_NTF,function(buffer,tag)
        ---收到商品推送
        local info = assert(pb.decode('PBClient.ClientMarqueeNTF',buffer))
        local tGroupInfo = {}
        tGroupInfo[1] = info.marquee
        SysNoticeControl.CheckNotice(tGroupInfo)
    end)
end

function SysNoticeControl.CheckMsg(_msg)
    ---检查是否存在时间区间内,需要播放的公告
    local a = Global.GetCurTime()
    if _msg ~= nil then
        for i = 1, #_msg do
            if Global.GetCurTime() < _msg[i].stopTime then
                return true
            end
        end
    end
    
    return false
end

function SysNoticeControl.CloseSysNoticeUI()
    MgrUI.ClosePop(UID.SystemNotice_UI)
end

function SysNoticeControl.SetSysNoticeObj(obj)
    SysNoticeControl.SysNoticeObj = obj
end

function SysNoticeControl.SetSysNoticeOffsetY(posY)
    --if SysNoticeControl.SysNoticeObj then
    --    SysNoticeControl.SysNoticeObj:SetOffsetY(posY)
    --end
end

function SysNoticeControl.Clear()
    SysNoticeControl.SysNoticeData = {}
    SysNoticeControl.SysNoticeObj = nil
end

function SysNoticeControl.Hide()
    if SysNoticeControl.SysNoticeObj then
        SysNoticeControl.SysNoticeObj:HideUI()
    end
end
function SysNoticeControl.Show()
    if SysNoticeControl.SysNoticeObj then
        SysNoticeControl.SysNoticeObj:ShowUI()
    end
end

return SysNoticeControl
