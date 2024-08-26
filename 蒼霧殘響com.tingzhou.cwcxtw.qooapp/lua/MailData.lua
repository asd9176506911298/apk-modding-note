---@class MailData 角色数据
MailData = Class("MailData")
-------------构造方法-------------
function MailData:ctor(id)
    self.id = id                   ---邮件id
    self.type = 1                  ---邮件类型
    self.name = 0                  ---发件人名字
    self.headIcon = 0    ---发件人头像
    self.title = 0             ---邮件标题
    self.content = 0      ---邮件内容
---@type goods[]
    self.goods = 0                 ---附件
    self.gTime = 0                 ---收件时间
    self.eTime = 0                 ---过期时间
    self.status = 0                ---状态
    self.emailParam = ""           ---邮件参数
end

---@class EmailInfo 服务器定义的共鸣装备结构
local EmailInfo = {
    emailID = 1,        ---邮件id
    emailType = 2,      ---邮件类型
    emailName = 3,      ---发件人名字
    emailHead = 4,      ---发件人头像
    emailTitle = 5,     ---邮件标题
    emailTxt = 6,       ---邮件内容
    emailGoods = 7,     ---附件
    emailGTime = 8,     ---收件时间
    emailETime = 9,     ---过期时间
    emailStatus = 10,    ---状态
    emailParam = 11           ---邮件参数
}
---@param email EmailInfo 覆盖装备数据并解锁角色
function MailData:PushData(email)
    self.id = email.emailID
    self.type = email.emailType
    self.name = email.emailName
    self.headIcon = email.emailHead
    self.title = email.emailTitle
    self.content = email.emailTxt
    self.goods = email.emailGoods
    self.gTime = email.emailGTime
    self.eTime = email.emailETime
    self.status = email.emailStatus
    self.emailParam = email.emailParam
end


return MailData