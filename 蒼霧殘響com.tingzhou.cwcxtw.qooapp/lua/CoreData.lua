---@class CoreData:ItemDataBase 核心数据
---@field attrs CoreAttrData[] 核心属性
---@field decompose CoreDecomposeData 分解奖励
CoreData = Class("CoreData",ItemDataBase)
-------------构造方法-------------
function CoreData:ctor()
    CoreData.super.ctor(self)
    ---@type goods 物品goods
    self.goods = {}
    self.id = 0             ---物品配置ID
    self.count = 0          ---数量
    self.goodsType = 0      ---goods类型
    self.quality = 0        ---物品显示品质
    self.star = 0           ---物品星级
    self.icon = ""          ---物品图标
    self.iconFrame = ""     ---物品边框
    self.iconFrameGear = "" ---机甲核心边框
    self.channel = ""       ---物品获取途径
    self.checkpoint = ""    ---物品掉落关卡
    self.use = 0            ---能否使用
    self.name = ""          ---物品名称
    self.txt = ""           ---物品介绍
    self.uid = 0            ---核心uid
    self.properties = 0     ---属性比例
    self.exp = 0            ---当前经验
    self.skill = 0          ---附加技能id
    self.RoleId = 0         ---适用角色
    self.slot = 0           ---槽位 0 未装备 1 左槽 2 右槽位
    self.upCount = 0        ---核心的改造次数(强化时校验用)
    self.time = 0           ---核心获取时间
    self.level = 0          ---核心强化等级
    self.type = 0           ---核心类型
    self.maxExp = 0
    self.attrs = {}
    self.decompose = nil    ---核心分解奖励
    self.armorCoreConfig = nil          ---核心数值配置表
    self.levelsExpConfig = nil          ---核心强化等级经验表表
    self.levelsConsumesConfig = nil     ---核心强化等级消耗表
    self.isLocked = 0               ---核心是否已上锁
end
-------------数据操作方法-------------
---@class armors 服务器定义的核心类型
local armors = {
    ID = 1,                 ---核心id
    armorProperties = 2,    ---装备属性比例(0-10000)
    armorID = 3,            ---模板id
    armorExp = 4,           ---当前经验
    armorSkill = 6,         ---附加技能id
    armorRoleID = 7,        ---装备在哪个角色上
    armorSlot = 8,          ---槽位 0 未装备 1 左槽 2 右槽位
    armorUpCount = 9,       ---这件装备的改造次数(强化时校验用)
    time = 10,              ---这件装备的改造次数(强化时校验用)
}
---@param armors armors 覆盖数据
function CoreData:PushData(armors)
    local goods = {
        goodsID = armors.ID,
        goodsType = 3,
        goodsNum = 1,
    }
    local config = CoreLocalData.tab[armors.armorID]
    self.goods = goods
    self.id = armors.armorID
    self.count = goods.goodsNum
    self.goodsType = goods.goodsType
    self.quality = config.quality
    self.star = config.itemstar
    self.icon = string.format("Item/%s",config.icon)
    self.iconFrame = string.format("Quality/RankKuang_%s",config.quality)
    self.iconFrameGear = config.quality
    self.channel = config.channel
    self.checkpoint = config.checkpoint
    self.use = config.use
    self.name = config.name
    self.txt = config.txt
    self.uid = armors.ID
    self.properties = armors.armorProperties/10000
    self.exp = armors.armorExp
    self.skill = armors.armorSkill
    self.RoleId = armors.armorRoleID
    self.slot = armors.armorSlot
    self.upCount = armors.armorUpCount
    self.time = armors.armorGTime
    ---获取核心配置
    self:GetCoreConfig()
    ---获取核心类型
    self.type = self:GetType(self.armorCoreConfig)
    ---覆盖强化等级
    self.level = self:PushLevel(self.strengthenLevels,self.exp)
    ---获取核心分解奖励
    self.decompose = self:GetDecompose(self.star,self.quality)
    ---覆盖核心属性
    self.attrs = self:LoadAttrs(self.properties)
    self.maxExp = self.strengthenLevels[#self.strengthenLevels]
    self.isLocked = CoreControl.GetCoreLock(self.uid)
    print("强化后最高经验",self.maxExp)
end
---配置数据
function CoreData:PushConfig(id,properties,skill)
    local goods = {
        goodsID = id,
        goodsType = 3,
        goodsNum = 1,
    }
    local config = CoreLocalData.tab[id]
    print("配置的核心id："..id)
    self.goods = goods
    self.id = goods.goodsID
    self.count = goods.goodsNum
    self.goodsType = goods.goodsType
    self.quality = config.quality
    self.star = config.itemstar
    self.icon = "Item/"..config.icon
    self.channel = config.channel
    self.checkpoint = config.checkpoint
    self.use = config.use
    self.name = config.name
    self.txt = config.txt

    self.uid = 0
    self.properties = properties / 100
    self.exp = 0
    self.skill = skill
    self.RoleId = 0
    self.slot = 0
    self.upCount = 0
    self.time = 0
    ---获取核心配置
    self:GetCoreConfig()
    ---获取核心类型
    self.type = self:GetType(self.armorCoreConfig)
    ---获取核心分解奖励
    self.decompose = self:GetDecompose(self.star,self.level)
    ---覆盖核心属性
    self.attrs = self:LoadAttrs(self.properties)
end
---获取核心配置
function CoreData:GetCoreConfig()
    ---获取核心数值配置
    self.armorCoreConfig = ArmoredcoreLocalData.tab[self.id]
    print("强化后id",self.id)
    self.strengthenLevels = {}
    self.strengthenConsumes = {}
    for id, data in pairs(CorestrengthenLocalData.tab) do
        if data[2] == self.armorCoreConfig[5] and data[3] == self.armorCoreConfig[4] then
            self.strengthenLevels[(data[4]+1)] = data[5]
            self.strengthenConsumes[(data[4]+1)] = data[5] * (data[6]/10000)
        end
    end
end
---获取核心类型
function CoreData:GetType(armorCoreConfig)
    return armorCoreConfig[9]
end
---根据经验覆盖强化等级
function CoreData:PushLevel(strengthenLevels,exp)
    for i = 1, #strengthenLevels do
        if strengthenLevels[i] <= exp then
            if i == #strengthenLevels  then
                print("尽头",strengthenLevels[i],i)
                return i
            elseif  strengthenLevels[i+1] > exp  then
                print("不是尽头",strengthenLevels[i+1],i)
                return i
            end
        end
    end
    return 0
end
---@return CoreDecomposeData 获取核心分解奖励
function CoreData:GetDecompose(star,level)
    for i, v in pairs(DecomposeLocalData.tab) do
        if v[2] == star and v[3] == level then
            ---@type CoreDecomposeData
            local decomposeData = CoreDecomposeData.New()
            decomposeData:PushData(v[4])
            return decomposeData
        end
    end
end
---@return CoreAttrData[] 根据服务器给的properties按万分位覆盖核心属性
function CoreData:LoadAttrs(properties)
    ---清空已有数值
    local attrs = {}
    ---重新添加核心数据(配置完善后下面两列还原)
    local attrs_str =string.split(self.armorCoreConfig[11],',')
    local value_str =string.split(self.armorCoreConfig[12],',')
    for i = 1, #attrs_str do
        local attr_str = string.split(attrs_str[i],'_')
        ---@type CoreAttrData
        local attrData = CoreAttrData.New()
        local attrId = tonumber(attr_str[2])    ---属性配置表id
        local attrEnum = tonumber(attr_str[1])  ---属性类型 0值 1百分比
        local attr = tonumber(value_str[i]) * properties ---属性具体数值
        if attrEnum == 1 then
            attr = attr * 0.01
        end
        print(attrId,properties)
        attrData:PushData(i,attrId,attrEnum,attr)
        attrs[attrData.attrUID] = attrData
    end
    return attrs
end

function CoreData:ReLoadCore(type, roleId)
        self.slot = type
        self.RoleId = roleId
end

return CoreData