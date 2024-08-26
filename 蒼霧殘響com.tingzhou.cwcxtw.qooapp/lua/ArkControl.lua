require("Model/Ark/Data/ArkBuildData")
require("Model/Ark/Data/ArkExpeditionData")
require("Model/Ark/Data/SynthesisData")
require("LocalData/InfrastructurebuildLocalData")
require("LocalData/ExpeditiontaskLocalData")
require("LocalData/EnergysynthesisLocalData")
require("LocalData/SkillitemsynthesisLocalData")
require("UI/ViewModel/ArkViewModel")
require("Model/Ark/Data/ArkItemData")

ArkControl = {}
---@type ArkBuildData[] 所有建筑缓存
local CacheArkBuildList = {}
---@type ArkBuildData[] 玩家建筑缓存
local CachePlayerBuildList = {}
---@type ArkExpeditionData[] 所有远征任务缓存
local CacheExpeditionList = {}
---@type ArkItemData 看板娘
local CacheAkrItemList = {}
---待确认的远征角色缓存
local CacheExpeditionRoleList = {}
---玩家的远征任务信息
local CachePlayerExpeditionList = {}
---合成信息
---@type SynthesisData[]
local SynthesisList = {} --能源工厂
local skillitemSynthesisList = {} --专属技能材料合成列表
local roleeqSynthesisList = {} --限定共鸣装备合成列表
local SkillItemChange = {}  ---专属技能材料兑换列表

---初始化数据
function ArkControl.Init(data,expeditionInfos)
    for k,v in pairs(InfrastructurebuildLocalData.tab) do
        CacheArkBuildList[v[1]] = ArkBuildData.New(k)
    end
    for k,v in pairs(CacheArkBuildList) do
        if v.frontID == 0 then
            CachePlayerBuildList[v.buildType] = v
        end
    end

    for k,v in pairs(ExpeditiontaskLocalData.tab) do
        CacheExpeditionList[v[1]] = ArkExpeditionData.New(k)
    end
    --专属技能材料合成列表
    local roleList = {}
    for index, value in ipairs(HeroControl.GetHaveHero()) do
        roleList[value.id] = value
    end
    --local data = {}
    for k,v in pairs(SkillitemsynthesisLocalData.tab) do
        skillitemSynthesisList[v[1]] = SynthesisData.New(k,2)
        skillitemSynthesisList[v[1]].quality = ItemControl.GetItemByID(k).quality

        if v[6] == 3 then
            SkillItemChange[v[2]] = SynthesisData.New(k,2)
        end
    end
    -- for key, value in pairs(skillitemSynthesisList) do
    --     if roleList[value.roleid] ~= nil  then
    --         table.insert(data,value)
    --     end
    -- end
    -- for key, value in pairs(skillitemSynthesisList) do
    --     if roleList[value.roleid] == nil  then
    --         table.insert(data,value)
    --     end
    -- end
    --skillitemSynthesisList = data
    --限定共鸣装备合成列表
    for k,v in pairs(EnergysynthesisLocalData.tab) do
        if v[5] == 1 and v[4] == 2 then
            roleeqSynthesisList[v[1]] = SynthesisData.New(k,3)
            roleeqSynthesisList[v[1]].quality = ItemControl.GetItemByID(k).quality
        end
    end
    --能源工程
    for k,v in pairs(EnergysynthesisLocalData.tab) do
        if v[5] == 1 and v[4] == 0 then
            SynthesisList[v[1]] = SynthesisData.New(k,1)
            SynthesisList[v[1]].quality = ItemControl.GetItemByID(k).quality
        end
    end

    for k, v in pairs(HomecharacterLocalData.tab) do
        CacheAkrItemList[v[1]]=ArkItemData.New(k)
    end
    ArkControl.GetHomeData()
    ---初始化家园数据
    ArkControl.InitArkData(data,expeditionInfos)
end

---初始化玩家建筑信息
function ArkControl.InitBuildData(id,cTime,uTime)
    for k,v in pairs(CachePlayerBuildList) do
        if CacheArkBuildList[id].buildType == v.buildType then
            CachePlayerBuildList[k] = CacheArkBuildList[id]
            CachePlayerBuildList[k].cTime = cTime
            CachePlayerBuildList[k].uTime = uTime
        end
    end
end

function ArkControl.PushBuildData(frontID,id,cTime,uTime)
    for k,v in pairs(CachePlayerBuildList) do
        if frontID == nil then
            ---基础建筑推送数据
            if CacheArkBuildList[id].buildType == v.buildType and CacheArkBuildList[id].id == id then
                CachePlayerBuildList[k] = CacheArkBuildList[id]
                CachePlayerBuildList[k].cTime = cTime
                CachePlayerBuildList[k].uTime = uTime
            end
        else
            ---正常升级建筑推送数据
            if CacheArkBuildList[id].buildType == v.buildType and CacheArkBuildList[id].frontID == frontID then
                CachePlayerBuildList[k] = CacheArkBuildList[id]
                --UnityEngine.Debug.LogError("Push cTime" ..CachePlayerBuildList[k].cTime)
                --UnityEngine.Debug.LogError("Pushed cTime" ..cTime)
                CachePlayerBuildList[k].cTime = cTime
                CachePlayerBuildList[k].uTime = uTime
            end
        end
    end
end

---获取基础建筑的数量
function ArkControl.GetTotalBaseBuildCount()
    local count = 0
    for k,v in pairs(CacheArkBuildList) do
        if v.frontID == 0 then
            count = count + 1
        end
    end
    return count
end

---通过收获推送数据
function ArkControl.PushBuildDataByReap(id,uTime)
    --UnityEngine.DebugEx.LogError("服务器返回数据  ID "..id.."  uTime "..uTime)
    for k,v in pairs(CachePlayerBuildList) do
        if v.id == id then
            v.uTime = uTime
            v:PushReapTime()
        end
    end
end

---获取玩家的远征信息
function ArkControl.InitPlayerExpeditionData(tab)
    ---@type ArkExpeditionData[]
    CachePlayerExpeditionList= {}
    local arr = {}
    for i,data in pairs(tab) do
        table.insert(arr,{id = data.id,expeditionId = data.expeditionId,heroIds = data.heroIds,status = data.status,uTime = data.uTime})
    end
    ---灌输数据
    for k,v in pairs(arr) do
        ---防止重复
        if ArkControl.Contains(v.expeditionId,CacheExpeditionList,false,true) then
            CachePlayerExpeditionList[k] = ArkExpeditionData.New(v.expeditionId)
        else
            CachePlayerExpeditionList[k] = CacheExpeditionList[v.expeditionId]
        end
        CachePlayerExpeditionList[k].expeditionId = v.id
        CachePlayerExpeditionList[k].heroIds = v.heroIds
        CachePlayerExpeditionList[k].status = v.status
        CachePlayerExpeditionList[k].uTime = v.uTime
        if CachePlayerExpeditionList[k].status == 1 and CachePlayerExpeditionList[k]:GetExpeditionState() == false then
            CachePlayerExpeditionList[k].status = 2
        end
    end

    for k,v in pairs(CachePlayerExpeditionList) do
        if ArkControl.Contains(v.expeditionId,CacheExpeditionRoleList,true) == false then
            CacheExpeditionRoleList[#CacheExpeditionRoleList + 1] = {
                id = v.id,
                heroIds = {},
                expeditionId = v.expeditionId
            }
        end
    end
    table.sort(CachePlayerExpeditionList, function(a,b)     --按照是否已完成排序
        if a.status > b.status then
            return true
        elseif a.status < b.status then
            return false
        else
            return a.id < b.id
        end
    end)

    return CachePlayerExpeditionList
end

---推送玩家远征任务数据
function ArkControl.PushPlayerExpeditionData(id,heros)
    for k,v in pairs(CachePlayerExpeditionList) do
        if id == v.id then
            v.heroIds = heros
        end
    end
end

---推送服务器远征任务数据
function ArkControl.PushExpeditionData(expeditionInfo)
    for k,v in pairs(ArkViewModel.TaskData) do
        if v.id == expeditionInfo.id then
            v.id = expeditionInfo.expeditionId
            v.expeditionId = expeditionInfo.expeditionId
            v.heroIds = expeditionInfo.heroIds
            v.status = expeditionInfo.status
            v.uTime = expeditionInfo.uTime
        end
    end
end

---获取玩家的远征任务缓存
function ArkControl.GetPlayerExpeditionData()
    return CachePlayerExpeditionList
end

---获取指定id的远征任务数据
function ArkControl.GetExpeditionDataByID(id)
    return CacheExpeditionList[id]
end

---获取看板娘数据
function ArkControl.GetArkItemData()
    local array={}
    for key, value in pairs(CacheAkrItemList) do
        value.unlock = ItemControl.IsThereAnyAkrItem(key)
        if ArkViewModel.CurRole==key then
            value.choose = true
        end
        value.like=UnityEngine.PlayerPrefs.HasKey(tostring(key)..PlayerControl.GetPlayerData().UID)
        ---判断是否显示
        if value.appear == 0 then
            table.insert(array,value)
        elseif value.appear == 1 then
            ---如果已解锁
            if value.unlock then
                table.insert(array,value)
            end
        end
    end
    return array
end

---添加角色ID到待确认的缓存池
function ArkControl.AddExpeditionRole(id,heroId,ExpeditionId)
    ---先剔除重复角色
    for k,v in pairs(CacheExpeditionRoleList) do
        for i,roleId in pairs(v.heroIds) do
            if heroId == roleId then
                table.remove(v.heroIds,i)
                break
            end
        end
    end

    for k,v in pairs(CacheExpeditionRoleList) do
        if id == v.id and ExpeditionId == v.expeditionId then
            table.insert(v.heroIds,heroId)
        end
    end
end

function ArkControl.ClearSingleExpeditionRole(id,ExpeditionId)
    for k,v in pairs(CacheExpeditionRoleList) do
        if id == v.id and ExpeditionId == v.expeditionId then
            v.heroIds = {}
        end
    end
end

---删除缓存池中的角色
function ArkControl.RemoveExpeditionRole(id,heroId,ExpeditionId)
    for k,v in pairs(CacheExpeditionRoleList) do
        if id == v.id and ExpeditionId == v.expeditionId then
            for i,roleId in pairs(v.heroIds) do
                if heroId == roleId then
                    table.remove(v.heroIds,i)
                    break
                end
            end
        end
    end
end

---通过id获取待确认的角色缓存池
function ArkControl.GetExpeditionRoleByID(id,expeditionId)
    for k,v in pairs(CacheExpeditionRoleList) do
        if id == v.id and expeditionId == v.expeditionId then
            return v.heroIds
        end
    end
    return {}
end
---获取待确认的远征英雄的数据
function ArkControl.GetExpeditionRoleData()
    return CacheExpeditionRoleList
end
---清理远征待确认的英雄数据
function ArkControl.ClearExpeditionRoleData()
    CacheExpeditionRoleList = {}
end

---获取玩家建筑信息
function ArkControl.GetPlayerBuildData()
    return CachePlayerBuildList
end

---获取下一等级的建筑信息
function ArkControl.GetNextLevelBuildData(id)
    local nextID = CacheArkBuildList[id].unlockID
    if nextID == 0 then
        return nil
    end
    return CacheArkBuildList[nextID]
end

---获取上一等级的建筑信息
function ArkControl.GetPrevLevelBuildData(id)
    local prevID =  CacheArkBuildList[id].frontID
    if prevID == 0 then
        return CacheArkBuildList[id]
    end
    return CacheArkBuildList[prevID]
end

---传入远征任务data获取符合条件的角色
function ArkControl.Recommended(data)
    local levelNum = data.levelLimit  ---任务等级需求
    local totalCount = data.countLimit    ---总人数需求
    local occr = tonumber(string.split(data.occupationLimit,"_")[1])   ---职业需求
    local occrCount = tonumber(string.split(data.occupationLimit,"_")[2])   ---职业需求人数
    ---远征中角色
    local array = {}
    for i,data in pairs(CachePlayerExpeditionList) do
        if data.heroIds then
            for k,v in pairs(data.heroIds) do
                table.insert(array,v)
            end
        end
    end
    local levelNeed = false
    local countNeed = false
    local occrNeed = false
    local target = {}  ---目标角色
    local occrCountNeed = 0  ---满足职业条件的人数
    for k,v in pairs(ArkViewModel.CacheRoleData) do
        if levelNeed and countNeed and occrNeed and #target >= 9 then
            return target
        end
    end


    ---是否满足职业条件
    for k,v in pairs(ArkViewModel.CacheRoleData) do
        if occrNeed == false then
            ---如果没有职业要求
            if occr == 0 then
                if #target >= occrCount then
                    occrNeed = true
                else
                    if ArkControl.Contains(v.id,array) == false then
                        table.insert(target,v.id)
                        occrNeed = true
                    end
                end
            else
                ---如果人数已经达标
                if occrCountNeed >= occrCount then
                    occrNeed = true
                else
                    ---满足职业条件且不是远征中和已在目标数组中的人物
                    if v.career == occr and ArkControl.Contains(v.id,array) == false and ArkControl.Contains(v.id,target) == false then
                        ---满足职业条件的人数+1
                        occrCountNeed = occrCountNeed + 1
                        table.insert(target,v.id)
                    end
                end
            end
        end
    end
    ---是否满足等级条件
    for k,v in pairs(ArkViewModel.CacheRoleData) do
        if levelNeed == false then
            if v.level >= levelNum and ArkControl.Contains(v.id,array) == false and ArkControl.Contains(v.id,target) == false then
                table.insert(target,v.id)
                levelNeed = true
            end
        end
    end
    ---是否满足总人数条件
    for k,v in pairs(ArkViewModel.CacheRoleData) do
        if countNeed == false then
            ---如果人数已满足
            if #target >= totalCount then
                countNeed = true
            else
                if #target < totalCount and ArkControl.Contains(v.id,array) == false and ArkControl.Contains(v.id,target) == false then
                    table.insert(target,v.id)
                end
            end
        end

        ---填充满队伍如果条件都满足
        if #target < 9 and levelNeed and countNeed and occrNeed then
            if ArkControl.Contains(v.id,array) == false and ArkControl.Contains(v.id,target) == false then
                table.insert(target,v.id)
            end
        end
        ---如果到达上限就返回
        if #target >= 9 then
            return target
        end
    end

    return target
end

function ArkControl.Contains(id,tb,isChildId,isMain)
    if isChildId then
        for k,v in pairs(tb) do
            if v.expeditionId == id then
                return true
            end
        end
        return false
    end
    if isMain then
        for k,v in pairs(tb) do
            if v.id == id then
                return true
            end
        end
        return false
    end

    for k,v in pairs(tb) do
        if v == id then
            return true
        end
    end
    return false
end

---通过类型获取合成数据
function ArkControl.GetSynthesisDataByType(type)
    local arr = {}
    if 0 == type then
        for k,v in pairs(SynthesisList) do
            --if v.type == type then
                table.insert(arr,v)
            --end
        end
    elseif 1 == type then
        for k,v in pairs(skillitemSynthesisList) do
            --if v.type == type then
                table.insert(arr,v)
            --end
        end
    elseif 2 == type then
        for k,v in pairs(roleeqSynthesisList) do
            --if v.type == type then
                table.insert(arr,v)
            --end
        end
    end
    return arr
end

---初始化家园数据
function ArkControl.InitArkData(data,expeditionInfos)
    if(data and #data == ArkControl.GetTotalBaseBuildCount()) then
        for k,v in pairs(data) do
            ArkControl.InitBuildData(v.homeId,v.cTime,v.uTime)
        end
    end
    ---远征信息
    if expeditionInfos then
        ArkViewModel.TaskData = expeditionInfos
    end
end

---获取家园数据请求
function ArkControl.GetHomeData()
    local BaseREQ = {
        rev = "1"
    }
    ---序列化
    local bytes = assert(pb.encode('PBClient.ClientGetHomeDataREQ',BaseREQ))
    ---发送数据
    MgrNet.SendReq(MID.CLIENT_GET_HOME_DATA_REQ,bytes,0,nil, ArkControl.GetHomeDataACK,ArkControl.GetHomeDataNTF)
end
---获取家园数据返回
function ArkControl.GetHomeDataACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetHomeDataACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("arkcontrol_tips1"),2},true)
    end
end
function ArkControl.GetHomeDataNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetHomeDataNTF',buffer))
    if(tab.info and #tab.info == ArkControl.GetTotalBaseBuildCount()) then
        for k,v in pairs(tab.info) do
            ArkControl.InitBuildData(v.homeId,v.cTime,v.uTime)
        end
    else
        ---如果为空说明是第一次进入指挥室
        ArkViewModel.isInited = false
        ---发生建造基础建筑请求
        ArkViewModel.HomeBaseBuildREQ()
    end
    if not tab.role or tab.role==0 then
        ArkViewModel.CurRole = tonumber(SteamLocalData.tab[104020][2]) --当前看板娘ID
    else
        ArkViewModel.CurRole = tab.role --当前看板娘ID
    end
end

---检查红点
function ArkControl.CheckRedPoint()
    RedDotControl.GetDotData("Ark"):SetState(false)
    for k,v in pairs(CachePlayerBuildList) do
        ---如果有产出就显示红点
        if v:GetBuildState() == false  and v:GetYieldCount(Global.GetCurTime(),v.uTime) >= v.capacity and v:GetYieldCount(Global.GetCurTime(),v.uTime) > 0 then
            RedDotControl.GetDotData("Ark"):SetState(true)
            break
        end
        ---如果有下一级建筑且可升级就显示红点
        if v:GetUpgradeState() then
            RedDotControl.GetDotData("Ark"):SetState(true)
            break
        end
    end

    ---如有有远征任务完成
    for k,v in pairs(ArkViewModel.TaskData) do
        if v.status == 1 and ArkControl.GetExpeditionDataByID(v.expeditionId):GetExpeditionState(v.uTime) == false then
            RedDotControl.GetDotData("Ark"):SetState(true)
            break
        end
    end
    
    ---解锁但未观看个人剧情的看板娘
    for k, v in ipairs(ArkViewModel.ArkItemDataList) do
        if not v.Plot and tonumber(v.charplot) ~= 0 and v.unlock == true  then
            RedDotControl.GetDotData("Ark"):SetState(true)
            break
        end
    end
    ---方舟锁
    if not SysLockControl.CheckSysLock(1600) then
        ---未解锁不显示红点
        RedDotControl.GetDotData("Ark"):SetState(false)
    end

    --办公室
    local isShow = false
    local tab= {}
    local player = PlayerControl.GetPlayerData()
    for k,v in pairs(ArkViewModel.HomeData) do
        if v.canUp == 0 then  --如果建筑可升级
            table.insert(tab,v)
            local nextInfo = ArkControl.GetNextLevelBuildData(v.id)
            local info = ArkViewModel.HomeData[v.buildType]
            local coin = ItemControl.GetItemByIdAndType(tonumber(info.cost[2]),tonumber(info.cost[1]))
            if nextInfo and player.level >= nextInfo.playerLevel and coin.count >= tonumber(nextInfo.cost[3]) then
                isShow = true
                break
            end
        end
    end
    if isShow then
        RedDotControl.GetDotData("Ark"):SetState(true)
    end

end

function ArkControl.GetHomeExpeditionACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetHomeExpeditionACK',buffer))
    print(tab.errNo)
end

function ArkControl.GetHomeExpeditionNTF(buffer,tag)
    local tab = assert(pb.decode('PBClient.ClientGetHomeExpeditionNTF',buffer))
    if(tab.expeditionInfos) then
        ArkViewModel.TaskData = tab.expeditionInfos
        for k,v in pairs(tab.expeditionInfos) do
            if v.status == 1 and ArkControl.GetExpeditionDataByID(v.expeditionId).useTime + v.uTime - Global.GetCurTime() <= 0 then
                RedDotControl.GetDotData("Ark"):SetState(true)
                break
            end
        end
    end
end

function ArkControl.GetSkillItemChange(_roleId)
    return SkillItemChange[_roleId]
end

function ArkControl.Clear()
    CacheArkBuildList = {}
    CachePlayerBuildList = {}
    CacheExpeditionList = {}
    CacheAkrItemList = {}
    CacheExpeditionRoleList = {}
    CachePlayerExpeditionList = {}
    SynthesisList = {}
    skillitemSynthesisList = {}
    roleeqSynthesisList = {}
    SkillItemChange = {}
end

return ArkControl