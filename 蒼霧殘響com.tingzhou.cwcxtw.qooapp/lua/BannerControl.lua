require("LocalData/BannerLocalData")
require("Model/Banner/Data/BannerData")
---公告管理器
BannerControl = {}
BannerControl.cBannerData = {}     ---配置活动公告数据

function BannerControl.InitBannerData()
    BannerControl.cBannerData = {}
    for i, v in ipairs(BannerLocalData.tab) do
        if BannerControl.cBannerData[i] == nil then
            BannerControl.cBannerData[i] = BannerData.New()
            BannerControl.cBannerData[i]:PushConfig(v)
        end
    end
end

function BannerControl.GetBannerData()
    local tList = {}
    for i, v in ipairs(BannerControl.cBannerData) do
        if Global.GetTimeByStr(v.openTime) < Global.GetCurTime() and Global.GetTimeByStr(v.closeTime) > Global.GetCurTime() then
            tList[#tList+1] = v
        end
    end
    
    return tList
end

function BannerControl.Clear()
    BannerControl.cBannerData = {}
end

return BannerControl
