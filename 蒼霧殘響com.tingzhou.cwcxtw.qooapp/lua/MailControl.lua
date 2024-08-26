require("Model/Mail/Data/MailData")
require("LocalData/MailLocalData")
require("LocalData/BirthdaymaillistLocalData")

---物品管理器
MailControl = {}

---@type MailData[]
local MailDataList = {}

function MailControl.GetMailByID(id)
    return MailDataList[id]
end

function MailControl.DelMailById(id)
    MailDataList[id] = nil
end

function MailControl.ReLoadMailData(num)
    ---如果未读邮件数据大于0
    if num > 0 then
        RedDotControl.GetDotData("Mail"):SetState(true)
    else
        RedDotControl.GetDotData("Mail"):SetState(false)
    end
end

function MailControl.ReLoadMailBirthdayData(list)
    ---如果生日邮件数量大于0
    if list and #list > 0 then
        RedDotControl.GetDotData("Mail"):SetState(true)
    end
end

function MailControl.GetMailData()
    local Birthdaymaillist = {} --生日邮件发放表
    local datas = BirthdaymaillistLocalData.tab--123
for index, value in ipairs(datas) do
    local ids = string.split(value.mailid,',')
    for k, v in ipairs(ids) do
        Birthdaymaillist[tonumber(v)] = value
    end
end

    local birthdayArray = {}
    local array = {}
    for i, v in pairs(MailDataList) do
        if MailControl.GetMailBirthday(v.id) then
            table.insert(birthdayArray,v)
        end
    end
    for i, v in pairs(MailDataList) do
        if not MailControl.GetMailBirthday(v.id) then
            table.insert(array,v)
        end
    end
    table.sort(array, function(a,b)
        if a.status < b.status then
            return true
        elseif a.status > b.status then
            return false
        else
            if a.gTime > b.gTime then
                return true
            elseif a.gTime < b.gTime then
                return false
            else
                return false
            end
        end
    end)

    local playerMailBirthday = {}
    local roleMailBirthday = {}
    local realMialList = {}
    for index, value in ipairs(birthdayArray) do --将拥有的角色生日邮件和玩家生日邮件分别存入列表存入列表
        if Birthdaymaillist[value.id] ~= nil then
              --roleMailBirthday[value.id] = Birthdaymaillist[value.id]
              --Birthdaymaillist[value.id].sortMainID = value.id
              value.sortMainID = Birthdaymaillist[value.id].id
              --table.insert(roleMailBirthday,Birthdaymaillist[value.id])
              table.insert(roleMailBirthday,value)
        else
            --playerMailBirthday[value.id] = value
            table.insert(playerMailBirthday,value)
        end
    end

    --玩家生日排序
    Global.Sort(playerMailBirthday,{"id"},true)
    for index1, value1 in ipairs(playerMailBirthday) do
        for i1, v1 in ipairs(birthdayArray) do
            if v1.id == value1.id then
                table.insert(realMialList,v1)
            end
        end
    end
    --角色生日排序
    Global.Sort(roleMailBirthday,{"sortMainID"},true)
    for index, value in ipairs(roleMailBirthday) do
        for i, v in ipairs(birthdayArray) do
            if v.id == value.id then
                table.insert(realMialList,v)
            end
        end
    end

    ---筛选

    --将生日邮件至于列表最前面
    for i, v in pairs(array) do
        --table.insert(birthdayArray,v) --realMialList
        table.insert(realMialList,v)
    end

    --return birthdayArray
    return realMialList
end

--判断是否为生日邮件
function MailControl.GetMailBirthday(id)
    return MailLocalData.tab[id] ~= nil
end

---获取邮件数据请求返回ACK
function MailControl.ReceiveEmailDataACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientEmailDataACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.UnLock("OpenMail")
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("mailcontrol_tips1"),1},true)
    end
end
---获取邮件数据请求返回NTF
function MailControl.ReceiveEmailDataNTF(buffer, tag,callBack)
    local tab = assert(pb.decode('PBClient.ClientEmailDataNTF',buffer))

    --PushBirthdayEmailInfo
    --生日邮件未领取
    if tab.unGetEmail then
        MailControl.PushBirthdayEmailInfo(tab.unGetEmail)
        --PostMailViewModel.ReLoadMailData()
        PostMailViewModel.MailBirthdayUnCaCheData = tab.unGetEmail
    else
        --PostMailViewModel.ReLoadMailData()
        PostMailViewModel.MailBirthdayUnCaCheData = {}
    end

    if tab.email then
        print("一共有",#tab.email)
        MailControl.PushGroupEmailInfo(tab.email)
        PostMailViewModel.ReLoadMailData()
    else
        PostMailViewModel.MailCaCheData =  {}
        PostMailViewModel.ReLoadMailData()
    end

    --生日邮件已领取
    if tab.getEmail then
        PostMailViewModel.MailBirthdayCaCheData =  tab.getEmail
    else
        PostMailViewModel.MailBirthdayCaCheData = {}
    end

    if callBack then
        callBack()
    end
end

---获取邮件数据请求
function MailControl.EmailDataClick(callBack)
    local EmailDataREQ  =
    {
        rev = "1";
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEmailDataREQ',EmailDataREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_EMAIL_DATA_REQ,bytes,0,nil, MailControl.ReceiveEmailDataACK,function(...)
        MailControl.ReceiveEmailDataNTF(...,nil,callBack)
    end)
end

---@param EmailGroup EmailInfo[]
function MailControl.PushGroupEmailInfo(EmailGroup)
    if not EmailGroup then
        print("邮件数据为空")
        return
    end
    for idx, email in pairs(EmailGroup) do
        MailControl.PushSingleEmailInfo(email)---
    end

end


function MailControl.PushBirthdayEmailInfo(EmailGroup)
    if not EmailGroup then
        print("邮件数据为空")
        return
    end
    for idx, email in pairs(EmailGroup) do
            local t = {}
            t.emailGoods = MailControl.GoodsToTable(email)
            t.emailID = email
            t.emailTitle = ""
            t.emailName = ""
            t.emailETime = 0
            t.emailHead = ""
            t.emailGTime = 0
            t.emailTxt = ""
            t.emailType = 3
            t.emailParam =""
            t.emailStatus = 0
            t.isBirthday = true
            --table.insert(self.CurLoopList,t)
        MailControl.PushSingleEmailInfo(t)---
    end
end


--商品字符串转表结构
function MailControl.GoodsToTable(goodsID)
    local goods = {}
    if MailLocalData.tab[goodsID] == nil then
        return
    end
    local strs = string.split(MailLocalData.tab[goodsID].goods,',')
    for index, value in ipairs(strs) do
        local t = string.split(value,'_')
        local tab = {}
        tab.goodsNum = tonumber(t[3])
        tab.goodsType = tonumber(t[1])
        tab.goodsID = tonumber(t[2])
        table.insert(goods,tab)
    end
    return goods
end

---@param email EmailInfo
function MailControl.PushSingleEmailInfo(email)
    if not MailDataList[email.emailID] then
        MailDataList[email.emailID] = MailData.New(email.emailID)
    end
    ---刷新数据
    MailDataList[email.emailID]:PushData(email)
    --if email.emailStatus == 0 then
    --    RedDotControl.GetDotData("Mail"):SetState(true)
    --end
end

function MailControl.Clear()
    MailDataList = {}
end

return MailControl