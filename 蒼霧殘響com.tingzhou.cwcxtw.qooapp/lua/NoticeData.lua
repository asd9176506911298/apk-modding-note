---@class NoticeData 技能描述信息

NoticeData = Class('NoticeData')
---构造方法
function NoticeData:ctor()
    self.id = 0                 ---ID
    self.type = 0               ---公告类型(1.活动公告,2.游戏公告)
    self.sortID = 0             ---公告组()
    self.title = ""             ---公告标题(左侧页签)
    self.notice = {}            ---公告内容
    self.openTime = ""          ---开启时间
    self.closeTime = ""         ---结束时间
end
---配置公告数据
function NoticeData:PushConfig(_config)
    self.id = _config.id
    self.type = _config.type
    local tNoticeID = string.split(_config.groupid, ",")
    self.sortID = tonumber(tNoticeID[2])
    self.title = _config.title
    self.openTime = _config.opentime
    self.closeTime = _config.closetime

    self:PushNoticeCfg(_config)
end

function NoticeData:PushNoticeCfg(_config)
    local tNoticeID = string.split(_config.groupid, ",")
    self.notice[tonumber(tNoticeID[2])] = {
        ---公告图片名称
        ImgName = _config.picture,
        ---文本标题
        name = _config.name,
        ---内容文本
        txt = _config.txt,
        ---图片跳转ID
        imgLinkId = _config.picturegotoid,
    }
end

---服务器公告数据(Tag:公告类型;公告组;公告标题;开启时间 Title:公告图片名称;文本标题 Text:内容文本)
function NoticeData:PushServerData(data)
    local tList = string.split(data.Tag, ";")
    if #tList ~= 4 then
        print("公告数据格式不匹配")
        return
    end
    self.type = tonumber(tList[1])
    self.title = tList[3]
    self.openTime = tList[4]
    
    self:PushNoticeData(data)
end

function NoticeData:PushNoticeData(data)
    local tList = string.split(data.Tag, ";")
    local tNotice = string.split(data.Title, ";")
    if #tList ~= 4 or #tNotice ~= 2 then
        print("公告数据格式不匹配")
        return
    end
    local tGroup = string.split(tList[2], ",")
    self.notice[tonumber(tGroup[2])] = {
        ---公告图片名称
        ImgName = tNotice[1],
        ---文本标题
        name = tNotice[2],
        ---内容文本
        txt = data.Text,
        ---图片跳转ID
        imgLinkId = "0"
    }
end

return NoticeData