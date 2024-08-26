------------邮件VM------------
---待优化及业务逻辑整合
require("LocalData/MailLocalData")
PostMailViewModel = {}

---@type MailData[]
PostMailViewModel.MailCaCheData = {}
PostMailViewModel.MailBirthdayCaCheData = {}
PostMailViewModel.MailBirthdayRedDotCaChe = {} --生日邮件红点缓存
---------------------初始化-----------------------
function PostMailViewModel.Init()
    PostMailViewModel.OpenPostMailUI()
end

function PostMailViewModel.Close()
    MgrUI.GoBack()
end
---------------------UI跳转------------------------
function PostMailViewModel.OpenPostMailUI()
  --  MailControl.ReLoadMailData()
    --PostMailViewModel.ReLoadMailData()
    MgrUI.GoHide(UID.NewPostMail_UI)
end

function PostMailViewModel.ReLoadMailData()
    PostMailViewModel.MailCaCheData =  MailControl.GetMailData()
    --PostMailViewModel.MailBirthdayCaCheData =  MailControl.GetMailData()
end

--判断此生日邮件是否已读
function PostMailViewModel.GetIsReadMailBirthday(id)
    local isRead = false
    for index, value in ipairs(PostMailViewModel.MailBirthdayRedDotCaChe) do
        if value == id then
            isRead = true
            return isRead
        end
    end
    return isRead
end
--添加生日邮件红点缓存
function PostMailViewModel.SetMailBirthdayRedDotCaChe(id)
    table.insert(PostMailViewModel.MailBirthdayRedDotCaChe,id)
end

--清除生日邮件红点缓存
function PostMailViewModel.ClearMailBirthdayRedDotCaChe()
    PostMailViewModel.MailBirthdayRedDotCaChe = {}
end

---获取已读邮件id
function PostMailViewModel.GetReadedMail()
    local array = {}

    for i, v in pairs(PostMailViewModel.MailCaCheData) do
        if v.type~=1 then
            if v.status == 1  then
                if v.goods == nil then
                    table.insert(array,v.id)
                end
            elseif v.status == 2 then
                table.insert(array,v.id)
            end
        end
    end

    return array
end

---获取未读邮件id
function PostMailViewModel.GetUnReadMail()
    local array = {}
    for i, v in pairs(PostMailViewModel.MailCaCheData) do
        if v.status == 0 and MailLocalData.tab[v.id] == nil then
            table.insert(array,v.id)
        end
    end

    return array
end

---获取可以领取奖励邮件id
function PostMailViewModel.GetRewardMail()
    local array = {}

    for i, v in pairs(PostMailViewModel.MailCaCheData) do
        if v.type == 2 or v.type == 3  or v.type == 4 then
            if v.status ~= 2 and v.goods then
                table.insert(array,v.id)
            end
        end
    end

    return array
end
---------------------业务逻辑------------------------

function PostMailViewModel.GetLastTime(target)
    --获取当前时间戳
    local curTimestamp = Global.GetCurTime()
    return target - curTimestamp;
end

---查看请求
function PostMailViewModel.EmailLookClick(emailID,funcACK,funcNTF)
    local EmailDataREQ  =
    {
        emailID = {
            [1] = emailID
        }
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailLookREQ',EmailDataREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_LOOK_REQ,bytes,0,nil,funcACK,funcNTF)
end

---领取奖励请求
function PostMailViewModel.EmailGoodsClick(emailID,isBirthday,funcACK,funcNTF)
    local EmailDataREQ  =
    {
        emailID = emailID,
        isBirthday = isBirthday
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailGoodsREQ',EmailDataREQ))
    ItemControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_GOODS_REQ,bytes,0,nil,funcACK,funcNTF)
end

---批量领取奖励请求
function PostMailViewModel.EmailALLGoodsClick(funcACK,funcNTF)
    local EmailDataREQ  =
    {
        rev = "1"
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailGoodsAllREQ',EmailDataREQ))
    ItemControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_GOODS_ALL_REQ,bytes,0,nil,funcACK,funcNTF)
end

---删除邮件请求
function PostMailViewModel.EmailDeleteClick(emailID,funcACK,funcNTF)
    local EmailDataREQ  =
    {
        emailID = emailID
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailDeleteREQ',EmailDataREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_DELETE_REQ,bytes,0,nil,funcACK,funcNTF)
end

---批量删除邮件请求
function PostMailViewModel.EmailDeleteALLClick(funcACK,funcNTF)
    local EmailDataREQ  =
    {
        rev = "1"
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailDeleteAllREQ',EmailDataREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_DELETE_ALL_REQ,bytes,0,nil,funcACK,funcNTF)
end

function PostMailViewModel.GetDayKeyByUnixTime(unixTime,hour)
    if hour == nil then hour = 0 end
    local retStr = os.date("%Y-%m-%d %H:%M:%S",unixTime)
    local time = unixTime
    local data = os.date("*t",time)
    --(hour)4点前按前一天算
    if data.hour < hour then
        time = time - 24*60*60
    end
    local data2 = os.date("*t",time)
    --dump(data2)
    data2.hour = 0
    data2.min = 0
    data2.sec = 0
    local time2 = os.time(data2)
    local dayKey = os.date("Key%Y%m%d",time2)
    local timeBase = time2
    --天数key，日期格式字符串，天数key 0点的时间戳
    return dayKey,retStr,timeBase
end

function PostMailViewModel.TimeDiff(unixTime1,unixTime2,dayFlagHour)
    if dayFlagHour == nil then dayFlagHour = 0 end
    local key1,str1,time1 = PostMailViewModel.GetDayKeyByUnixTime(unixTime1,dayFlagHour)
    local key2,str2,time2 = PostMailViewModel.GetDayKeyByUnixTime(unixTime2,dayFlagHour)

    local sub = math.abs(time2 - time1)/(24*60*60)
    print(str1.." 与 "..str2.."相差的天数："..sub)

    return sub
end

function PostMailViewModel.Clear()
    PostMailViewModel.MailCaCheData = {}
    PostMailViewModel.MailBirthdayCaCheData = {}
end

return PostMailViewModel