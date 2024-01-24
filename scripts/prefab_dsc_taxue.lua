local Inv = require "widgets/inventorybar"
local OldUpdCT = Inv.UpdateCursorText
local ItemTile = require "widgets/itemtile"
local OldGDS = ItemTile.GetDescriptionString --原版显示物品描述
local Text = require "widgets/text"

local textColor = { 255, 108, 180 }

--获取装备颜色
local function GetEquipmentName(position)
    local slots = { "equipment_purple", "equipment_red", "equipment_yellow", "equipment_blue", "equipment_green" }
    local color = { "粉色", "红色", "黄色", "蓝色", "绿色" }
    for k, v in ipairs(slots) do
        if position == v then
            return color[k]
        end
    end
end

function string.startWith(str, strStart)
    return str:sub(1, #strStart) == strStart
end

--buff名表
local buffNameMap = {
    taxue_tep_cold = "寒冷药剂",
    taxue_tep_hot = "炎热药剂",
    taxue_invisible = "隐形药水",
    taxue_bramble = "荆棘药水",
    taxue_bloodsucking = "嗜血药水",
    taxue_bramble_eggroll = "荆刺蛋卷",
}

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then return false end
    local pos, arr = 0, {}
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

local function formatNumber(number, formatStr)
    local number = tonumber(number)
    local a = math.floor(number)
    local b = number - a
    local numberStr = string.reverse(tostring(a))
    local str = {}
    local length = string.len(a)
    for i = 1, length do
        table.insert(str, string.sub(numberStr, i, i))
        if i % 3 == 0 and i < length then
            table.insert(str, ",")
        end
    end
    local formatStr = "%.f"
    if b >= 0.01 then
        local c = math.floor(b * 10) / 10
        if b - c < 0.01 then
            formatStr = "%.1f"
        else
            formatStr = "%.2f"
        end
    end
    return string.reverse(table.concat(str)) .. string.sub(string.format(formatStr, b), 2)
end

--#region Info
---@class Info
---@field data table|string
---@field index integer
---@field target table
---@field indexs table
local Info = {}
function Info:init(type)
    self.type = type
    if type == "text" then
        self.data = ""
    elseif type == "table" then
        self.index = 1
        self.data = {}
        self.indexs = {}
    end
end

function Info:setTarget(target)
    self.target = target
end

function Info:Add(str, id)
    if self.type == "text" then
        self.data = self.data .. "\n" .. str
    elseif self.type == "table" then
        local strs = str:split("\n")
        for i, str in ipairs(strs) do
            self:addTableText(str, id and id .. i or nil)
        end
    end
end

function Info:addTableText(str, id)
    if self.type == "text" then return end
    local index = id or ("taxue" .. self.index)
    self.index = self.index + (id and 0 or 1)
    if self.target then
        self.target:SetPanelDescription(index, str)
    end
    self.data[index] = str
    if not table.contains(self.indexs, index) then
        table.insert(self.indexs, index)
    end
end

function Info:clear()
    if self.type == "text" then
        self.data = ""
    elseif self.type == "table" then
        self.index = 1
        table.clear(self.data)
    end
end

--#endregion

local function getItemInfo(target)
    if not target then return Info.data end
    Info:clear()
    local player = GetPlayer()

    --人物Buff
    if target.components.taxuebuff then
        local taxuebuff = target.components.taxuebuff
        for name, timer in pairs(taxuebuff.buff_timer) do
            if timer > 0 then
                if name == "taxue_tep" then
                    name = name .. "_" .. taxuebuff.tep_state
                end
                Info:Add(buffNameMap[name] .. ": " .. timer .. "秒")
            end
        end
    end
    --孵蛋器
    if target.prefab == "hatch_machine" then
        local timetonextspawn = target.components.childspawner.timetonextspawn
        local dayLeft = timetonextspawn == 0 and 0 or string.format("%0.1f", timetonextspawn / 480)
        if timetonextspawn ~= 0 then
            Info:Add("剩余时间:" .. math.floor(timetonextspawn) .. "(" .. dayLeft .. "天)")
        end
    end
    --银行
    if target.prefab == "taxue_bank" or target.prefab == "taxue_bank_card" then
        local taxue_coin_silver = player.bank_value * player.bank_interest                                           --每日收入银梅币
        local max = player.initial_interest + (player.level > player.MAX_LEVEL and player.MAX_LEVEL or player.level) --最大利息
        taxue_coin_silver = taxue_coin_silver > max and max or taxue_coin_silver
        local interest = player.bank_interest * 100                                                                  --今日利率百分比
        if player.bank_value > 0 then                                                                                --有钱
            Info:Add("银行存款: " .. formatNumber(player.bank_value, "%.2f") .. "梅币")
            Info:Add("最大利息: " .. formatNumber(max * 100) .. "银梅币")
            Info:Add("明日预计收入: " .. formatNumber(taxue_coin_silver * 100, "%.2f") .. "银梅币")
        end
        Info:Add("今日利率: " .. string.format("%6.2f", interest) .. "%")
    end
    --食物
    if target.components.perishable then
        local time = target.components.perishable.perishremainingtime                           --剩余时间（喵）
        local owner = target.components.inventoryitem and target.components.inventoryitem.owner --容器
        if owner then
            --冰箱
            if owner:HasTag("fridge") then
                if target:HasTag("frozen") and not owner:HasTag("nocool") then
                    time = "∞"
                else
                    time = time * 2
                end
            end
            --腐烂箱
            if owner:HasTag("taxue_fridge_500") then
                time = time / 500
            end
            --4倍
            if owner:HasTag("taxue_fridge_4x") then
                if target:HasTag("frozen") and not owner:HasTag("nocool") then
                    time = "∞"
                else
                    time = time * 4
                end
            end
            --6倍
            if owner:HasTag("taxue_fridge_6x") then
                if target:HasTag("frozen") and not owner:HasTag("nocool") then
                    time = "∞"
                else
                    time = time * 6
                end
            end
            --永久
            if owner:HasTag("taxue_fridge_always") then
                time = "∞"
            end
        end
        if time ~= "∞" then
            time = string.format("%6.1f", time / 480)
        end
        Info:Add("腐烂时间：" .. time .. "天")
    end
    --冰箱
    if target:HasTag("fridge") then
        Info:Add("保鲜时间 * 2")
    end
    --腐烂箱
    if target:HasTag("taxue_fridge_500") then
        Info:Add("保鲜时间 * 1/500")
    end
    --4倍保鲜
    if target:HasTag("taxue_fridge_4x") then
        Info:Add("保鲜时间 * 4")
    end
    --6倍保鲜
    if target:HasTag("taxue_fridge_6x") then
        Info:Add("保鲜时间 * 6")
    end
    --永久保鲜
    if target:HasTag("taxue_fridge_always") then
        Info:Add("永久保鲜")
    end
    --生物
    if target.components.health and target.components.health.absorb then
        Info:Add("伤害减免:" .. math.floor(target.components.health.absorb * 100) .. "%")
    end
    --武器
    if target.damage then
        Info:Add("伤害:" .. string.format("%6.2f", target.damage))
    end
    if target.components.weapon and target.armor_penetration then
        Info:Add("护甲穿透:" .. math.floor(target.armor_penetration * 100) .. "%")
    end
    if target.components.weapon and target.level then
        Info:Add("等级：" .. target.level)
    end
    if target.components.weapon and target.forge_level then
        Info:Add("锻造等级：" .. target.forge_level)
    end
    --法杖
    if target.prefab == "armor_penetration_staff" then
        Info:Add("护甲削减:" .. math.floor(target.armor_penetration * 100) .. "%")
    end
    --护甲
    if target.components.armor then
        Info:Add("护甲吸收:" .. (target.components.armor.absorb_percent * 100) .. "%")
        Info:Add("耐久:" .. string.format("%6.0f", target.components.armor.condition) .. "/" .. target.components.armor.maxcondition)
        if target.level then
            Info:Add("等级:" .. target.level)
        end
    end
    --黄金猫
    if target.prefab == "golden_statue" then
        Info:Add("已收获金肉: " .. GetPlayer().golden_statue_lv .. " 枚")
    end
    --黄金boss雕像
    if target.prefab == "taxue_golden_boss_altar" then
        Info:Add("变异概率: " .. string.format("%6.1f", (GetPlayer().boss_altar_value * 100)) .. " %")
    end
    --利息券
    if target.prefab == "interest_ticket" then
        Info:Add("利息上限:" .. (target.interest * 100) .. "银梅币")
    end
    --刷券券
    if target.prefab == "refreshticket_ticket" then
        Info:Add("可刷新数量：" .. target.refresh_num .. " 个")
    end
    --粉红月牙矿
    if target.prefab == "taxue_crescent_rock" then
        Info:Add("已收获粉宝石: " .. target.level .. " 枚")
    end
    --永动机
    if target.prefab == "taxue_perpetual_machine" then
        if target.lv == 0 then
            Info:Add("正在休眠")
        else
            Info:Add("当前等级: " .. target.lv .. " / 7 级")
        end
        if target.day then
            Info:Add("当前天数: " .. target.day % 3 + 1 .. " / 3")
        end
        if player.perpetual_machine_num then
            Info:Add("已建造数量: " .. player.perpetual_machine_num .. " / " .. target.MAX_NUM)
        end
    end
    --七彩永动机
    if target.prefab == "taxue_perpetual_machine_colorful" then
        if target.day then
            Info:Add("当前天数: " .. target.day % 3 + 1 .. " / 3")
        end
        if player.perpetual_machine_num then
            Info:Add("已建造数量: " .. player.perpetual_machine_num .. " / " .. target.MAX_NUM)
        end
    end
    --踏雪商店
    if target.prefab:startWith("taxue_shop") then
        local id = target.interiorID
        local interior = GetWorld().components.interiorspawner.interiors[id]
        if interior then
            for _, obj in pairs(interior.object_list) do
                if obj.prefab == "shop_buyer" then
                    local item = obj.components.shopdispenser:GetItem()
                    local cost = formatNumber(obj.cost)
                    Info:Add(STRINGS.NAMES[string.upper(item)] .. ": " .. cost .. STRINGS.NAMES[string.upper(obj.costprefab)])
                end
            end
        end
        if target.prefab == "taxue_shop" then
            Info:Add("已建造数量: " .. player.taxue_shop_num .. " / " .. TUNING.TAXUE_SHOP_MAX_NUM)
        end
    end
    --开锁书
    if target.prefab == "book_unlocking" then
        Info:Add("(软木钥匙,木箱钥匙,骨箱钥匙)：" .. (target.corkchest_key) .. " 枚," .. (target.treasurechest_key) .. " 枚," .. (target.skullchest_key) .. " 枚")
        Info:Add("(精致钥匙,豪华钥匙,恐怖钥匙)：" .. (target.pandoraschest_key) .. " 枚," .. (target.minotaurchest_key) .. " 枚," .. (target.terrarium_key) .. " 枚")
        Info:Add("(剧毒钥匙)：" .. (target.poison_key) .. " 枚")
    end
    --批量召唤书
    if target.prefab == "book_batch_summon" then
        Info:Add("召唤物：" .. (#target.monster_list) .. " 只")
    end
    --超级书time类
    if target.time then
        Info:Add("耐久：" .. target.time .. " 次")
    end
    --战利品券
    if target.prefab == "loot_ticket" then
        Info:Add("额外掉落：" .. target.loot_multiple .. " 倍")
    end
    --填充式战利品券
    if target.prefab == "loot_ticket_fill" then
        Info:Add("额外掉落：" .. target.loot_multiple .. " /" .. target.MAX_MULTIPLE .. "倍")
    end
    --鱼缸
    if target.prefab == "taxue_fish_tank" then
        Info:Add("鱼容量：" .. target.components.breeder.volume .. "/" .. target.components.breeder.max_volume .. " 条")
    end
    --超级包裹
    if target.prefab == "super_package" then
        local num = 0
        for __, v in pairs(target.item_list) do
            num = num + v
        end
        local k2, v2
        local num2 = 0
        while true do
            k2, v2 = next(target.item_list, k2)
            if not v2 then
                break
            else
                num2 = num2 + 1
            end
        end
        local num3 = target.components.container:NumItems()
        Info:Add("可堆叠物品种类:" .. num2 .. "/∞，物品数量：" .. formatNumber(num) .. "/∞个")
        Info:Add("其他物品数量:" .. formatNumber(num3) .. "/∞个")
    end
    --点树成精
    if target.prefab == "book_touch_leif" then
        Info:Add("树精数量:" .. target.leif_num .. "只")
    end
    --点蛛成精
    if target.prefab == "book_touch_spiderqueen" then
        Info:Add("蜘蛛女王数量:" .. target.spiderqueen_num .. "只")
    end
    --点怪成金
    if target.prefab == "book_touch_golden" then
        Info:Add("点金数量:" .. target.golden_num .. "只")
    end
    --灌铅包裹
    if target.loaded_item_list then
        Info:Add("物品数量:" .. #target.loaded_item_list .. "个")
    end
    --赌狗劵
    if target.prefab == "gamble_ticket" then
        Info:Add("可能额外掉落:" .. target.gamble_multiple .. "倍")
    end
    --掉包券
    if target.prefab == "substitute_ticket" then
        Info:Add("掉包物品:" .. TaxueToChs(target.substitute_item))
    end
    --定向商店刷新券
    if target.prefab == "shop_refresh_ticket_directed" then
        Info:Add("刷新物品:" .. TaxueToChs(target.refresh_item))
    end
    --重铸器
    if target.prefab == "taxue_recasting_machine" then
        Info:Add("重铸成功率:" .. string.format("%6.2f", GetPlayer().recasting_num * 100) .. "%")
    end
    --超级打包机
    if target.prefab == "super_package_machine" and target.switch == "on" then
        local kind = 0
        local num = 0
        local container_num = 0
        for k, v in pairs(target.item_list) do
            kind = kind + 1
            num = num + v
        end
        local slots = target.components.container.slots
        for __, v in pairs(slots) do
            if v.prefab == "super_package" then
                container_num = v.components.container:NumItems()
            end
        end
        Info:Add("可堆叠物品种类:" .. kind .. "/∞，物品数量：" .. formatNumber(num) .. "/∞个")
        Info:Add("其他物品数量:" .. formatNumber(container_num) .. "/∞个")
    end
    --炼药台
    if target.prefab == "taxue_agentia_station" and target.components.melter.cooking == true then
        Info:Add("正在炼制:" .. TaxueToChs(target.components.melter.product))
    end
    --特殊装备
    --显示信息（参数：1字符串，2物品特有属性-用于判断,3需要乘的系数-方便显示百分比，4保留小数点,5前显示字符，6后显示字符）
    local function ShowStr(name, num1, num2, str_first, str_last)
        if target.equip_sign == name then
            local value = string.format("%." .. num2 .. "f", target.equip_value * num1) --保留小数点后两位
            Info:Add(str_first .. value .. str_last)
        end
    end

    if target.components.equippable then
        ShowStr("equipment_unforgettable", 1, 2, "血量上限:", "") --刻骨铭心
        ShowStr("equipment_baby_dragon", 60, 2, "精神回复:", "/分钟") --幼龙
        ShowStr("equipment_light_pearl", 1, 2, "发光范围:", "") --夜明珠
        ShowStr("equipment_nobel_faceblack", 100, 2, "欧气值:", "%") --诺贝尔脸黑奖
        ShowStr("equipment_fast_sandclock", 100, 2, "移速:", "%") --迅捷沙漏
        ShowStr("equipment_fire_scale", 1, 2, "伤害:", "") --熔岩火鳞
        ShowStr("equipment_golden_ring", 100, 2, "金肉掉落率:", "%") --黄金戒指
        ShowStr("equipment_fire_horn", 100, 2, "暴击率:", "%") --熔岩火角
        ShowStr("equipment_fire_claw", 1, 2, "暴击伤害加成:", "倍") --熔岩火爪
        ShowStr("equipment_magic_conch", 100, 2, "变异率:", "%") --魔法海螺
        ShowStr("equipment_crown", 100, 2, "攻速:", "%") --皇冠
        ShowStr("equipment_lockpick", 100, 2, "钥匙掉率:", "%") --撬锁器
        ShowStr("equipment_clover", 100, 2, "植物精华掉率:", "%") --四叶草
        ShowStr("equipment_sweetheart_hairpin", 1, 2, "魅力值:", "") --甜心发卡
        ShowStr("equipment_crystal_hat", 100, 0, "防水:", "%") --黯晶礼帽
        ShowStr("equipment_exp_book", 1, 2, "额外经验值:", "") --经验秘籍
        ShowStr("equipment_fire_tooth", 1, 2, "真实伤害:", "") --熔岩火牙
        ShowStr("equipment_sea_clover", 100, 2, "海洋精华掉率:", "%") --海洋四叶草
        ShowStr("equipment_thieves_gloves", 100, 2, "银梅币爆率:", "%") --窃贼手套
        ShowStr("equipment_snowflake", 1, 2, "冰冻层数:", "层") --雪花
        ShowStr("equipment_volcano_clover", 100, 2, "火山精华掉率:", "%") --火山四叶草
        ShowStr("equipment_threecolour_clover", 100, 2, "精华掉率:", "%") --三色四叶草
        ShowStr("equipment_lollipop", 100, 2, "孵化蛋掉率:", "%") --波板糖
        ShowStr("equipment_pearl_mussel", 100, 2, "珍珠精华掉率:", "%") --珍珠蚌
        ShowStr("equipment_loaded_dice", 100, 2, "灌铅包裹掉率:", "%") --灌铅骰子
        ShowStr("equipment_colourful_windmill", 100, 2, "特殊奖励掉率:", "%") --炫彩风车

        if target.prefab == "equipment_crystal_hat" or target.prefab == "equipment_crystal_hat_re" then
            Info:Add("防雷:100%")
        end

        if target.equip_position then
            Info:Add("穿戴位置:" .. GetEquipmentName(target.equip_position))
        end
    end
    --货币价值物品
    if target.taxue_coin_value then
        local stacksize = target.components.stackable and target.components.stackable.stacksize or 1
        local stackValueStr = ""
        if stacksize > 1 then
            local stackValue = stacksize * target.taxue_coin_value
            stackValueStr = "/总价值:" .. formatNumber(stackValue) .. "银梅币"
        end
        Info:Add("单个价值:" .. formatNumber(target.taxue_coin_value) .. "银梅币" .. stackValueStr)
    end
    --boss献祭价值
    if target.boss_altar then
        Info:Add("献祭价值:" .. string.format("%6.1f", target.boss_altar * 100) .. "%")
    end
    return Info.data
end

local function NewUpdateCursorText(self) --更新光标的描述文件？
    if self.actionstringbody.GetStringAdd and self.actionstringbody.SetStringAdd then
        local str = getItemInfo(self:GetCursorItem())
        self.actionstringbody:SetStringAdd(str)
    end
    OldUpdCT(self)
end

local function NewGetDescriptionString(self) --获取物品描述字符串
    local oldstr = OldGDS(self)
    local str = ""
    if self.item and self.item.components and self.item.components.inventoryitem then
        str = getItemInfo(self.item)
    end
    if string.len(str) > 3 then
        str = oldstr .. str
    else
        str = oldstr
    end
    return str
end

function Text:SetStringAdd(str) --设置物品描述
    self.stringadd = str
end

function Text:SetString(str) --设置字符串？
    if not str then str = "" else str = tostring(str) end
    self.string = str
    if self.stringadd and (type(self.stringadd) == "string") then str = str .. self.stringadd end
    self.inst.TextWidget:SetString(str or "")
end

function Text:GetStringAdd()
    if self.stringadd and (type(self.stringadd) == "string") then
        return self.stringadd
    else
        return ""
    end
end

--修改鼠标覆盖显示内容
AddClassPostConstruct("widgets/hoverer", function(self)
    local old_SetString = self.text.SetString
    self.text:SetColour(textColor[1] / 255, textColor[2] / 255, textColor[3] / 255, 1)
    self.text.SetString = function(text, str)
        if Info.type == "text" then
            local target = TheInput:GetWorldEntityUnderMouse() --获取鼠标所指的实体
            return old_SetString(text, str .. getItemInfo(target))
        end
        return old_SetString(text, str)
    end
end)

AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0.1, function()
        if DYCInfoPanel and DYCInfoPanel.objectDetailWindow then
            local oldSetObjectDetail = DYCInfoPanel.objectDetailWindow.SetObjectDetail
            DYCInfoPanel.objectDetailWindow.SetObjectDetail = function(self, page)
                for _, item in ipairs(page.lines) do
                    if item.component == 'custom' then
                        item.color = DYCInfoPanel.RGBAColor(textColor[1] / 255, textColor[2] / 255, textColor[3] / 255)
                    end
                end
                oldSetObjectDetail(self, page)
            end
            Info:init("table")
            local oldGetPanelDescriptions = EntityScript.GetPanelDescriptions
            EntityScript.GetPanelDescriptions = function(self)
                Info:setTarget(self)
                for _, index in ipairs(Info.indexs) do
                    self:SetPanelDescription(index, nil)
                end
                getItemInfo(self)
                return oldGetPanelDescriptions(self)
            end
        else
            Info:init("text")
            Inv.UpdateCursorText = NewUpdateCursorText
            ItemTile.GetDescriptionString = NewGetDescriptionString
        end
    end)
end)
