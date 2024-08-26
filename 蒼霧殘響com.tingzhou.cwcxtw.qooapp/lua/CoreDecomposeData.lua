---@class CoreDecomposeData 核心属性数据
---@field goods goods
CoreDecomposeData = Class("CoreDecomposeData")
-------------构造方法-------------
function CoreDecomposeData:ctor()
    self.goods = {}         ---物品数据
    self.config = {}       ---物品配置
end
function CoreDecomposeData:PushData(str)
    local s = string.split(str,',')
    for k,v in pairs(s) do
        local str = string.split(v,"_")
        local info = {
            goodsType = tonumber(str[1]),
            goodsID = tonumber(str[2]),
            goodsNum = tonumber(str[3])
        }
        table.insert(self.goods,info)
        self.config[tonumber(str[2])] = Global.GetLocalDataByGoods(v)
    end
end

return CoreDecomposeData