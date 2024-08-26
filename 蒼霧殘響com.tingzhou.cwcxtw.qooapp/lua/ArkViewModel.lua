---家园VM
ArkViewModel = {}
require("LocalData/HomecharacterLocalData")
require("LocalData/RoleattriskillupLocalData")
require("LocalData/SteamLocalData")---系统杂项表
---远征任务组
ArkViewModel.ExpeditionData = {}
---@type ArkBuildData[] 家园信息缓存
ArkViewModel.HomeData = {}
---@type ArkExpeditionData[] 家园远征任务缓存
ArkViewModel.TaskData = {}
---当前远征任务
ArkViewModel.CurTaskID = nil
---当前远征唯一id
ArkViewModel.CurExpeditionId = nil
---玩家英雄信息
ArkViewModel.CacheRoleData = {}
---家园看板娘
ArkViewModel.ArkItemDataList = {}
ArkViewModel.WeightHashTab = {}
ArkViewModel.TotalWeight = 0
ArkViewModel.TextObj = nil
ArkViewModel.ObjRoot = nil
---跳转标签
ArkViewModel.JumpToYzts = false
---是否已初始化建筑
ArkViewModel.isInited = true
--当前选的看板娘
ArkViewModel.CurArkItemIndex = 0
---搓澡信息
ArkViewModel.BackRubInfo = nil
---当前搓澡次数
ArkViewModel.CurBackRubCount = nil

---初始化
function ArkViewModel.Init()

end
---获取缓存
function ArkViewModel.ReloadCacheData()
    ArkViewModel.HomeData = ArkControl.GetPlayerBuildData()
end

function ArkViewModel.SetArkRoleChoose()
    for key, value in pairs(ArkViewModel.ArkItemDataList) do
        if value.id == ArkViewModel.CurRole then
            value.choose=true
        else
            value.choose=false
        end
    end
end

function ArkViewModel.GetCurChooseArkRole()
    for key, value in pairs(ArkViewModel.ArkItemDataList) do
        if value.id == ArkViewModel.CurRole then
            return value
        end
    end
    return ArkViewModel.ArkItemDataList[1]
end

function ArkViewModel.OpenUI()
    ArkViewModel.ReloadCacheData()

    ArkViewModel.ArkItemDataList=ArkControl.GetArkItemData()
    ---如果没有初始化完毕
    if ArkViewModel.isInited == false then
        ---发送建造基础建筑请求
        ArkViewModel.HomeBaseBuildREQ(function()
            MgrUI.GoHide(UID.Ark_UI)
        end)
    else
        ArkViewModel.GetGameInfoREQ(function()
            MgrUI.GoHide(UID.Ark_UI)
        end)
    end

end

---获得所有角色信息
function ArkViewModel.GetRoleData()
    ArkViewModel.CacheRoleData = HeroControl.GetHaveHero()
    return ArkViewModel.CacheRoleData
end
function ArkViewModel.ClearRoleData()
    for k,v in pairs(ArkViewModel.CacheRoleData) do
        if v.isSelect then
            v.isSelect = false
            v.isSelect = nil
        end
        if v.isRemove then
            v.isRemove = false
            v.isRemove = nil
        end
    end
end

function ArkViewModel.GetCoreDecomposeCount(coreDataArr)
    local count = 0
    ---@type goods[]
    local goodsList = {}
    if next(coreDataArr) == nil then
        return 0
    end
    for i, v in pairs(coreDataArr) do
        ---只添加未装备的核心
        count = count + v.decompose.goods.goodsNum
        table.insert(goodsList,v.goods)
    end
    return count
end

function ArkViewModel.GetSynthesisData(list,sortIdx, isRise)
     local roleList = {}
    for index, value in ipairs(HeroControl.GetHaveHero()) do--123
        roleList[value.id] = value
    end
    local tab = {}
    local untab = {}
    for key, value in pairs(list) do
        if roleList[value.roleid] ~= nil  then
            table.insert(tab,value)
        end
    end
    for key, value in pairs(list) do
        if roleList[value.roleid] == nil  then
            table.insert(untab,value)
        end
    end

    --local array = tab
    local sortGroup = {
        [1] = {"id"},
        [2] = {"quality"},
    }
    local rise = isRise == nil and true or isRise
    Global.Sort(tab,sortGroup[sortIdx or 1],rise)
    Global.Sort(untab,sortGroup[sortIdx or 1],rise)

    for index, value in ipairs(untab) do
        table.insert(tab,value)
    end
    return tab
end

--技能书排序
function ArkViewModel.GetSynthesisDataTypeTwo(list,sortIdx, isRise)
    local roleList = {}
    for index, value in ipairs(HeroControl.GetHaveHero()) do--123
        roleList[value.id] = value
    end
    local tab = {}
    local untab = {}
    for key, value in pairs(list) do
        if ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).Synthesis then
            value.Synthesis = ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).Synthesis
            value.SynthesisCount1 = ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).SynthesisCount1
            table.insert(tab,value)
        end
    end
    for key, value in pairs(list) do
        if not ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).Synthesis  then
            value.Synthesis = ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).Synthesis
            value.SynthesisCount1 = ArkViewModel.CheckRoleIsSynthesis(value,roleList[value.roleid]).SynthesisCount1
            table.insert(untab,value)
        end
    end

    --local array = tab
    local sortGroup = {
        [1] = {"id"},
        [2] = {"quality"},
    }
    local rise = isRise == nil and true or isRise
    Global.Sort(tab,sortGroup[sortIdx or 1],rise)
    Global.Sort(untab,sortGroup[sortIdx or 1],rise)

    for index, value in ipairs(untab) do
        table.insert(tab,value)
    end
    return tab
end

--检测当前角色是否可以合成
function ArkViewModel.CheckRoleIsSynthesis(role,roleTabDt)
    local tab = {}
    tab.Synthesis = false
    tab.SynthesisCount1 = 0
    local curSpend = 0
    local roleData = HeroControl.GetRoleDataByID(role.roleid)

    local tRoleData = RoleData.New(role.roleid)
    local list = {} --当前角色消耗列表
    for index, value in ipairs(RoleattriskillupLocalData.tab) do
        if roleData.rank == value[2] then
            list[value[3]] = value
        end
    end
    local roleLv = 0
    if roleTabDt ~= nil then
        --if roleTabDt:CheckHeroEquipIsMax() then
        --    roleLv = roleData.skillLevel - 1
        --else
            roleLv = roleData.skillLevel
        --end
    end

    if roleLv == 10 then
        roleLv = 9
    end

    if roleLv <= 0 then
        curSpend = 0
    else
        curSpend = list[roleLv - 1][6]--.skillcost 技能等级是加装备以后的
    end
    local spendMax = tonumber(SteamLocalData.tab[105010][2])
    local canSpend = spendMax - curSpend --可以消耗
    local costList = role:GetSynthesisCost()
    if costList[1].count >= canSpend then
        tab.Synthesis = true
        tab.SynthesisCount1 = costList[1].count - canSpend
    end
    return tab
end


---计算核心自动分解已选奖励总数
function ArkViewModel.ReckonAutoCoreAllCount(...)
    ---@type CoreData[]
    local coreArray = BagViewModel.ExactReckonAutoCore(...)
    ---获取总数量
    local count = 0
    for i, v in pairs(coreArray) do
        count = count + v.decompose.goods.goodsNum
    end
    return count
end

---核心自动分解请求(星表,品质表)
function ArkViewModel.SendAutoCoreDecompose(state,idx,cell)
    local coreArray = BagViewModel.ExactReckonAutoCore(state,idx)
    if #coreArray == 0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("arkviewmodel_tips1"),1},true)
    end
    BagViewModel.SendCoreDecompose(coreArray,cell)
end

---创建家园Spine
function ArkViewModel.GetRoleSpineToBox(_Root,id,r,g,b)
    local _RoleId = id
    local name = HomecharacterLocalData.tab[_RoleId][3]
    local posInfo = HomecharacterLocalData.tab[_RoleId][4]

    local _info1 = string.split(posInfo,";")
    local _info2 = string.split(_info1[1],",")
    local x = tonumber(_info2[1])
    local y = tonumber(_info2[2])
    local scale = tonumber(_info1[2])
    MgrRes.LoadWatchSpine(_Root, _RoleId,x,y,scale,nil,function(_ReturnObj)
        ArkViewModel.CurSpineObj = _ReturnObj
    end,r,g,b,tonumber(_info1[3]))
end

function ArkViewModel.SetRoleSpineButton(btn1,btn2,btn3,textObj,objRoot)
    local btnStr = string.split(HomecharacterLocalData.tab[ArkViewModel.CurRole][5],";")
    local btnStr1 = string.split(btnStr[1],",")
    local btnStr2 = string.split(btnStr[2],",")
    local btnStr3 = string.split(btnStr[3],",")
    btn1.gameObject:GetComponent("RectTransform").anchoredPosition = Vector2(tonumber(btnStr1[1]),tonumber(btnStr1[2]))
    btn1.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(tonumber(btnStr1[3]),tonumber(btnStr1[4]))

    btn2.gameObject:GetComponent("RectTransform").anchoredPosition = Vector2(tonumber(btnStr2[1]),tonumber(btnStr2[2]))
    btn2.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(tonumber(btnStr2[3]),tonumber(btnStr2[4]))

    btn3.gameObject:GetComponent("RectTransform").anchoredPosition = Vector2(tonumber(btnStr3[1]),tonumber(btnStr3[2]))
    btn3.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(tonumber(btnStr3[3]),tonumber(btnStr3[4]))
    ArkViewModel.TextObj = textObj
    ArkViewModel.ObjRoot = objRoot
    ---隐藏语音文本框
    ArkViewModel.TextObj.transform.parent.gameObject:SetActive(false)

    ---点击头部
    UIEvent.LuaClick(btn1,function()
        local touchHead = string.split(HomecharacterLocalData.tab[ArkViewModel.CurRole][7],";")
        ArkViewModel.PlayRole(touchHead)
    end)
    ---点击胸部
    UIEvent.LuaClick(btn2,function()
        local touchChest = string.split(HomecharacterLocalData.tab[ArkViewModel.CurRole][8],";")
        ArkViewModel.PlayRole(touchChest)
    end)
    ---点击腿部
    UIEvent.LuaClick(btn3,function()
        local touchLeg = string.split(HomecharacterLocalData.tab[ArkViewModel.CurRole][9],";")
        ArkViewModel.PlayRole(touchLeg)
    end)
end

---播放角色动画及语音
function ArkViewModel.PlayRole(data)
    for i = 1,#data do
        local headInfo = string.split(data[i],"|")
        local index = headInfo[5]
        ArkViewModel.AddRandomTable(index,headInfo,#data)
    end
    local info = ArkViewModel.GetRandom()
    CMgrSpine.Instance:SetSpineAnimation(ArkViewModel.CurSpineObj,info[2],false,nil,"idle")
    ArkViewModel.TextObj.text = HomecharactertxtLocalData.tab[tonumber(info[4])][2]
    ArkViewModel.TextObj.transform.parent.gameObject:SetActive(true)
    ArkViewModel.TextObj.gameObject:SetActive(true)
    MgrSound.PlayRole(info[3],nil,nil,false,0,0,tostring(ArkViewModel.CurRole))
    ArkViewModel.ListenVoice()
end

---添加到随机权重表
function ArkViewModel.AddRandomTable(index,value,totalCount)
    local pro = index/totalCount
    ArkViewModel.TotalWeight = pro * 1000 + ArkViewModel.TotalWeight
    table.insert(ArkViewModel.WeightHashTab,{value,ArkViewModel.TotalWeight})
end
---获取随机的数据
function ArkViewModel.GetRandom()
    if ArkViewModel.TotalWeight == 0 then
        return
    end
    local _randNum = math.random(ArkViewModel.TotalWeight)
    local _FinalVoiceLineId = "" --最终台词下标
    local _IsFound = false --是否找到比第一个元素权重大的权重下标(没有找到则默认返回第一个元素的下标)
    local _CurMaxWeightInSearch = 0 --当前本次遍历中小于随机数的最大的权重
    for key, value in pairs(ArkViewModel.WeightHashTab) do
        --判断当前随机数是否大于当前阶段上限阈值以及是否小于权重表最大阈值，否则不更新
        if value[2] < _randNum and value[2] <= ArkViewModel.TotalWeight then
            -- 符合条件迭代更新
            if value[2] >= _CurMaxWeightInSearch then
                -- 判断当前比较的权重是否大于已经对比过的权重各种最大权重值，小于则不更新
                _FinalVoiceLineId = ArkViewModel.WeightHashTab[key + 1][1]   --高于当前阶段的最大阈值，返回下一阶段的台词ID
                _IsFound = true
                _CurMaxWeightInSearch = value[2]
            end
        end
    end
    if _IsFound == false then
        -- 设置为默认最低等级权重台词
        _FinalVoiceLineId = ArkViewModel.WeightHashTab[1][1]
    end
    ArkViewModel.TotalWeight = 0
    ArkViewModel.WeightHashTab = {}
    return _FinalVoiceLineId
end

--- 监听语音是否结束
function ArkViewModel.ListenVoice()
    MgrTimer.AddRepeat("ArkRoleVoice",0.2,function()
        if MgrSound.CheckRoleStatus(tostring(ArkViewModel.CurRole)) then
            ArkViewModel.TextObj.gameObject:SetActive(false)
            ArkViewModel.TextObj.transform.parent.gameObject:SetActive(false)
            MgrTimer.Cancel("ArkRoleVoice")
        end
    end,-1,nil)
    ---暂时没有音频 设置为5s后关闭语音文本框
    MgrTimer.Cancel("ArkRoleVoice2")
    MgrTimer.AddDelay("ArkRoleVoice2",5,function()
        MgrTimer.Cancel("ArkRoleVoice2")
        ArkViewModel.TextObj.transform.parent.gameObject:SetActive(false)
    end,ArkViewModel.ObjRoot)
end

---家园建筑基础建筑
function ArkViewModel.HomeBaseBuildREQ(callBack)
    local BaseREQ = {
         rev = "1"
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientHomeBaseBuildREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_HOMEBASE_BUILD_REQ,bytes,0,nil, ArkViewModel.HomeBaseBuildACK,function(...)
        ArkViewModel.HomeBaseBuildNTF(...,nil,callBack)
    end)
end

function ArkViewModel.HomeBaseBuildACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientHomeBaseBuildACK',buffer))
    if tab.errNo ~= 0 then
    end
end

function ArkViewModel.HomeBaseBuildNTF(buffer,tag,callBack)
    local tab = assert(pb.decode('PBClient.ClientHomeBaseBuildNTF',buffer))
    if tab.homeInfo then
        for k,v in pairs(tab.homeInfo) do
            ArkControl.PushBuildData(nil,v.homeId,v.cTime,v.uTime)
        end
        ArkViewModel.isInited = true
    end
    if callBack then
        callBack()
    end
end

---家园建造请求
function ArkViewModel.HomeBuildREQ(Id,callback)
    local BaseREQ = {
        homeId = Id
    }
    if callback then
        ArkViewModel.callback = callback
    end
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientHomeBuildREQ',BaseREQ))
    ItemControl.AckError = true
    TaskControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_BUILD_HOME_REQ,bytes,0,nil, ArkViewModel.HomeBuildACK,ArkViewModel.HomeBuildNTF)
end
function ArkViewModel.HomeBuildACK(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientHomeBuildACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("arkviewmodel_buildfail")..tab.errNo},true)
    end
end
function ArkViewModel.HomeBuildNTF(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientHomeBuildNTF',buffer))
    if tab then
        ---消耗物品
        ItemControl.PushGroupItemData(tab.cost,ItemControl.PushEnum.consume)
        ---更新数据统计
        TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
        ---推送新建筑数据
        ArkControl.PushBuildData(tab.frontHomeID,tab.homeInfo.homeId,tab.homeInfo.cTime,tab.homeInfo.uTime)
        ---刷新缓存数据
        ArkViewModel.ReloadCacheData()
        if ArkViewModel.callback then
            ArkViewModel.callback()
            ArkViewModel.callback = nil
        end
    end
end

---家园建筑收获
function ArkViewModel.HomeReapREQ(Id,funACK,funNTF)
    local BaseREQ = {
        homeId = Id
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientHomeReapREQ',BaseREQ))
    ItemControl.AckError = true
    TaskControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_HOME_REAP_REQ,bytes,0,nil, funACK,funNTF)
end

---家园远征结算
function ArkViewModel.EndHomeExpeditionREQ(missionIds,hId,funACK,funNTF)
    local BaseREQ = {
        Ids = missionIds,
        homeId = hId,
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientEndHomeExpeditionREQ',BaseREQ))
    ItemControl.AckError = true
    TaskControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_END_HOME_EXPEDITION_REQ,bytes,0,nil, funACK,funNTF)
end
---获取家园远征任务组
function ArkViewModel.GetHomeExpedition(Id,funACK,funNTF)
    local BaseREQ = {
        homeId = Id
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientGetHomeExpeditionREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_GET_HOME_EXPEDITION_REQ ,bytes,0,nil, funACK,funNTF)
end

---发送家园合成请求
function ArkViewModel.SendHomeMake(itemId,MakeCount,callBack)
    local bytes =  assert(pb.encode('PBClient.ClientHomeMakeREQ',{
        id = itemId,
        count = MakeCount,
    }))
    ItemControl.AckError = true
    TaskControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_HOME_MAKE_REQ,bytes,0,nil,function(...)
        ArkViewModel.HomeMakeACK(...)
    end,function(...)
        ArkViewModel.HomeMakeNTF(...)
        if callBack then
            callBack()
        end
    end)
end

function ArkViewModel.HomeMakeACK(buffer, tag ,callback)
    local tab = assert(pb.decode('PBClient.ClientHomeMakeACK',buffer))
    if tab.errNo == 0 then
    else
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("arkviewmodel_composefail"),1},true)
    end
end
function ArkViewModel.HomeMakeNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientHomeMakeNTF',buffer))
    ---更新数据统计
    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
    ---添加到物品
    ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
    ---物品消耗
    ItemControl.PushGroupItemData(tab.cost,ItemControl.PushEnum.consume)
    ---弹出奖励窗口
    local tGoods = {}
    if tab.equip then
        local t = {}
        t[1] = {goodsType = 5, goodsID = tab.equip[1].equipID, goodsNum = 1}
        table.insert(tGoods,t)
        EquipControl.PushSingleEquipData(tab.equip[1])
    end
    if tab.goods then
        if #tGoods > 0 then
            for key, value in pairs(tab.goods) do
                table.insert(tGoods[1],value)
            end
        else
            for key, value in pairs(tab.goods) do
                local a = {}
                local d = {}
                d.goodsID = value.goodsID
                d.goodsType = value.goodsType
                d.goodsNum = value.goodsNum
                table.insert(a,d)
                table.insert(tGoods,a)
            end
        end
    end
    if #tGoods > 0 then
        MgrUI.Pop(UID.ItemAchievePop_UI,tGoods,true)
    else
        print("没有商品...")
    end
end

--技能书合成
function ArkViewModel.SendSkillMaterialsMake(id,count,callBack)
    local bytes =  assert(pb.encode('PBClient.ClientSkillMaterialsMakeREQ',{
        roleID = id,    ---已改成配置的下标，而非角色ID
        count = count,
    }))
    ItemControl.AckError = true
    TaskControl.AckError = true
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_SKILLMATERIALS_MAKE_REQ,bytes,0,nil,function(...)
        ArkViewModel.SkillMaterialsMakeACK(...)
    end,function(...)
        ArkViewModel.SkillMaterialsMakeNTF(...)
        if callBack then
            callBack()
        end
    end)
end


function ArkViewModel.SkillMaterialsMakeACK(buffer, tag ,callback)
    local tab = assert(pb.decode('PBClient.ClientSkillMaterialsMakeACK',buffer))
    if tab.errNo == 0 then
    else
        MgrUI.Pop(UID.PopTip_UI,{"技能书合成失败",1},true)
    end
end

function ArkViewModel.SkillMaterialsMakeNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientSkillMaterialsMakeNTF',buffer))
    ItemControl.PushGroupItemData(tab.cost,ItemControl.PushEnum.consume)
    ItemControl.PushGroupItemData(tab.goods,ItemControl.PushEnum.add)
    TaskControl.ChangeStatistics(tab.day,tab.week,tab.month,tab.glory)
    local t = {}
    table.insert(t,tab.goods)
    MgrUI.Pop(UID.ItemAchievePop_UI,t,true)
    --self:RefreshUI()
end



---检查任务状态
function ArkViewModel.CheckTaskState()
    for k,v in pairs(ArkViewModel.TaskData) do
        if v.status == 1 and ArkControl.GetExpeditionDataByID(v.expeditionId).useTime + v.uTime - Global.GetCurTime() <= 0 then
            return true
        end
    end
    return false
end

---刷新红点
function ArkViewModel.UpdateRedPoint()
    if SysLockControl.CheckSysLock(1600) then
        ArkControl.CheckRedPoint()
        MgrTimer.AddRepeat("UpdateArkRedPoint",60,function()
            ArkControl.CheckRedPoint()
        end,-1,nil)
    end
end

---刷新远征任务状态
function ArkViewModel.RefreshTaskDataStatus()
    if next(ArkViewModel.TaskData) == nil then
        return
    end
    for k,v in pairs(ArkViewModel.TaskData) do
        if v.status == 1 and ArkControl.GetExpeditionDataByID(v.id):GetExpeditionState() == false then
            v.status = 2
            break
        end
    end
end

---搓澡req
function ArkViewModel.GetGameInfoREQ(callBack)
    ---序列化请求
    local bytes = assert(pb.encode('PBClient.ClientGetGameInfoREQ', { rev = "" }))
    MgrNet.SendReq(MID.CLIENT_GET_GAME_INFO_REQ, bytes, 0, nil, ArkViewModel.GameInfoAck,function(...)
        ArkViewModel.GameInfoNTF(...)
        if callBack then
            callBack()
        end
    end)
end

function ArkViewModel.GameInfoAck(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetGameInfoACK', buffer))
    if tab.errNo ~= 0 then
        print(tab)
    end
end

function ArkViewModel.GameInfoNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetGameInfoNTF', buffer))
    ArkViewModel.BackRubInfo = tab
    ArkViewModel.CurBackRubCount = tab.count
end

---获取远征中队伍数量
function ArkViewModel.GetExpeditionNum()
    local num = 0
    if next(ArkViewModel.TaskData) then
        for k,v in pairs(ArkViewModel.TaskData) do
            if v.status == 1 and ArkControl.GetExpeditionDataByID(v.expeditionId).useTime + v.uTime > Global.GetCurTime() then  --如果状态是1且在远征中
                num = num + 1
            end
        end
    end
    return num
end

function ArkViewModel.GetFinishExpeditionNum()
    local num = 0
    if next(ArkViewModel.TaskData) then
        for k,v in pairs(ArkViewModel.TaskData) do
            if v.status == 1 and Global.GetCurTime() > ArkControl.GetExpeditionDataByID(v.expeditionId).useTime + v.uTime then  --如果状态是1且在远征中
                num = num + 1
            end
        end
    end
    return num
end

function ArkViewModel.Clear()
    for i,build in pairs(ArkViewModel.HomeData) do
        MgrTimer.Cancel(ArkViewModel.HomeData[i].TimerName)
    end
    ArkViewModel.ExpeditionData = {}
    ArkViewModel.HomeData = {}
    ArkViewModel.TaskData = {}
    ArkViewModel.CurTaskID = nil
    ArkViewModel.CurExpeditionId = nil
    ArkViewModel.CacheRoleData = {}
    ArkViewModel.ArkItemDataList = {}
    ArkViewModel.WeightHashTab = {}
    ArkViewModel.TotalWeight = 0
    ArkViewModel.TextObj = nil
    ArkViewModel.ObjRoot = nil
    ArkViewModel.JumpToYzts = false
    ArkViewModel.isInited = true
    ArkViewModel.BackRubInfo = nil
    ArkViewModel.CurBackRubCount = nil
end

return ArkViewModel