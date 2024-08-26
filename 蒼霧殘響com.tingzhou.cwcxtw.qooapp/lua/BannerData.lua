---@class BannerData 技能描述信息

BannerData = Class('BannerData')
---构造方法
function BannerData:ctor()
    self.id = 0                 ---ID
    self.sortID = 0             ---排序
    self.ImgName = ""           ---Banner图片名称
    self.interval = 1           ---轮播间隔时间
    self.imgLinkId = ""         ---图片跳转ID
    self.netLinkId = ""         ---网页跳转
    self.openTime = ""          ---开启时间
    self.closeTime = ""         ---结束时间
end
---配置Banner数据
function BannerData:PushConfig(_config)
    self.id = _config.id
    self.sortID = _config.sort
    self.ImgName = _config.picture
    self.interval = _config.interval
    self.imgLinkId = _config.picturegotoid
    self.netLinkId = _config.webgotoid
    self.openTime = _config.opentime
    self.closeTime = _config.closetime
end

return BannerData