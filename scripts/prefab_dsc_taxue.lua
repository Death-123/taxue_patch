local Inv = require "widgets/inventorybar"
local OldUpdCT = Inv.UpdateCursorText
local ItemTile = require "widgets/itemtile"
local OldGDS = ItemTile.GetDescriptionString --原版显示物品描述
local Text = require "widgets/text"

local function cfg(key, notUsePatch)
    if not TaxuePatch then
        return notUsePatch == true
    else
        return not key or TaxuePatch.cfg(key)
    end
end

local function getColor(color)
    if cfg() then
        if color then
            local colors = {
                { 127, 255, 212, 1 },
                { 255, 108, 180, 1 },
                { 0,   255, 255, 1 },
                { 0,   0,   255, 1 },
                { 0,   255, 0,   1 },
                { 255, 255, 0,   1 },
                { 255, 215, 0,   1 },
                { 255, 165, 0,   1 },
                { 255, 20,  147, 1 },
                { 144, 238, 144, 1 },
                { 128, 128, 128, 1 },
            }
            if colors[color] then
                return unpack(colors[color])
            end
        end
        return TaxuePatch.RGBAColor(TaxuePatch.cfg("displaySetting.desColor")):Get()
    else
        local textColor = { 127, 255, 212, 1 }
        return textColor[1] / 255, textColor[2] / 255, textColor[3] / 255, textColor[4]
    end
end

--#region tool functions

---获取装备颜色
---@param position string
---@return string name
local function GetEquipmentName(position)
    local slots = { "equipment_purple", "equipment_red", "equipment_yellow", "equipment_blue", "equipment_green" }
    local color = { "粉色", "红色", "黄色", "蓝色", "绿色" }
    for k, v in ipairs(slots) do
        if position == v then
            return color[k]
        end
    end
    return "无效位置"
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

if not cfg() then
    function string.startWith(str, strStart)
        return str:sub(1, #strStart) == strStart
    end
end

---将字符串以delimiter分割
---@param input string
---@param delimiter string
---@return string[]
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then return {} end
    local pos, arr = 0, {}
    for st, sp in function () return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

---格式化数字
---@param number number
---@param decimalDigits? integer
---@param short? boolean
---@param SegmentLen? integer
---@return string
local function formatNumber(number, decimalDigits, short, SegmentLen)
    local num = tonumber(number)
    if not num then return "NaN" end
    local SegmentLen = math.clamp(SegmentLen or cfg("displaySetting.showNumberSegmentLen") or 4, 2, 10)

    -- 处理负数
    local sign = ""
    if num < 0 then
        sign = "-"
        num = -num
    end

    -- 分离整数和小数部分
    local integerPart = math.floor(num)
    local decimalPart = num - integerPart
    -- 格式化小数部分

    local decimalDigits = decimalDigits or 2
    local decimalStr = string.format("%." .. decimalDigits .. "f", decimalPart)
    if decimalStr:sub(1, 1) == "1" then
        integerPart = integerPart + 1
    end
    if short ~= false then
        local len = 0
        while (decimalStr:sub(-1) == "0" or decimalStr:sub(-1) == ".") and len < decimalDigits + 1 do
            decimalStr = decimalStr:sub(1, -2)
            len = len + 1
        end
    end

    -- 格式化整数部分（千分位）
    local integerStr = tostring(integerPart)
    local formattedInteger = ""
    local len = #integerStr
    for i = 1, len do
        if i > 1 and (len - i + 1) % SegmentLen == 0 then
            formattedInteger = formattedInteger .. ","
        end
        formattedInteger = formattedInteger .. integerStr:sub(i, i)
    end


    return sign .. formattedInteger .. decimalStr:sub(2)
end

---格式化梅币
---@param amount number
---@param force? boolean
---@return string
local function formatCoins(amount, force)
    local amount100 = math.floor(amount / 100)
    if force or amount <= amount100 * 100 or amount100 >= 10 then
        return formatNumber(amount / 100) .. "梅币"
    else
        return formatNumber(amount) .. "银梅币"
    end
end

---将秒数转换为游戏内天数
---@param sec number
---@return number
local function secToDays(sec)
    return sec / TUNING.TOTAL_DAY_TIME
end

---格式化时间
---@param time number
---@param short? boolean
---@return string
local function formatTime(time, short)
    if type(time) ~= "number" then return "time format error " .. (time or "") end
    short = short == nil or short
    local sec = round(time % 60)
    local min = math.floor(time / 60 % 60)
    local hour = math.floor(time / 3600)
    local days = secToDays(time)
    local days = days > 0 and days or 0
    if short then
        local flag1 = hour > 0
        local flag2 = flag1 or min > 0
        return (flag1 and hour .. ":" or "")
            .. (flag1 and min < 10 and "0" or "") .. (flag2 and min .. ":" or "")
            .. (flag2 and sec < 10 and "0" or "") .. sec .. (flag2 and "" or "秒")
            .. ("(%.1f天)"):format(days)
    else
        return ("%02d:%02d:%02d(%.f天)"):format(hour, min, sec, days)
    end
end

---计算当前等级经验和当前等级升级经验
---@param player Taxue
---@return number currentLevelExp
---@return number currentNeed
local function GetTaxueExp(player)
    local d, one, exp, level = player.EXP_PER, player.EXP_ONE, player.exp, player.level
    local currentNeed = one + level * d
    local currentLevelExp = exp - (one + (one + d * (level - 1))) * level / 2
    return currentLevelExp, currentNeed
end

---获取美味称号
---@param player Taxue
---@return string
local function GetDeliciousStr(player)
    local deliciousStr = "无美味称号"
    if player:HasTag("nausea") then
        deliciousStr = "恶心至极"
    elseif player:HasTag("delicious_small") then
        deliciousStr = "美味初成"
    elseif player:HasTag("delicious_nomal") then
        deliciousStr = "美味专家"
    elseif player:HasTag("delicious_big") then
        deliciousStr = "美味大师"
    elseif player:HasTag("delicious_huge") then
        deliciousStr = "美味巅峰"
    end
    return deliciousStr
end

---获取银行称号
---@param player Taxue
---@return string
local function GetBankStr(player)
    local bankStr = "身无分文"
    local bankStrMap = {
        { str = "顶级富豪", value = 1000000000 },
        { str = "亿万富翁", value = 100000000 },
        { str = "千万富翁", value = 10000000 },
        { str = "百万富翁", value = 1000000 },
        { str = "特富阶级", value = 500000 },
        { str = "富人阶级", value = 100000 },
        { str = "中产阶级", value = 50000 },
        { str = "小产阶级", value = 20000 },
        { str = "万元户", value = 10000 },
        { str = "小康水平", value = 3000 },
        { str = "温饱户", value = 1000 },
        { str = "困难户", value = 500 },
        { str = "贫困户", value = 300 },
        { str = "赤贫户", value = 100 },
        { str = "特困户", value = 0 },
    }
    for _, entry in pairs(bankStrMap) do
        if player.bank_value > entry.value then
            bankStr = entry.str
            break
        end
    end
    return bankStr
end

---获取幸运描述
---@param player Taxue
---@return {[1]:string, [2]:string} str 今日, 明日
function GetFortuneStr(player)
    local str = {}
    local fortune_list = {
        { str = "巅峰运势", value = 1.8 },
        { str = "极品欧皇", value = 1.5 },
        { str = "普通欧皇", value = 1.2 },
        { str = "超级好运", value = 1.1 },
        { str = "运气不错", value = 1.05 },
        { str = "普普通通", value = 0.95 },
        { str = "有点小霉", value = 0.85 },
        { str = "倒了大霉", value = 0.7 },
        { str = "霉上加霉", value = 0.4 },
        { str = "梅老板附体", value = 0.2 },
    }
    for i = 1, 2 do
        for _, entry in pairs(fortune_list) do
            if player.badluck_num[i] >= entry.value then
                str[i] = entry.str
            end
        end
        str[i] = str[i] or "比煤老板还煤"
    end
    str[1] = "今日运势: " .. str[1]
    str[2] = "明日运势: " .. str[2]
    str[1] = str[1] .. ("(%.2f)"):format(player.badluck_num[1])
    if player.super_fortune_num > 0 then
        str[1] = str[1] .. string.format("(%s)", formatNumber(player.super_fortune_num))
    end
    if cfg("fortunePatch.showNum") then
        str[2] = str[2] .. ("(%.2f)"):format(player.badluck_num[2])
    end
    return str
end

--#endregion

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
    Info:clear()
    if not target then return Info.data end
    local player = GetPlayer()

    local hoverOnStatus = player.HUD.controls.status.focus
    if hoverOnStatus then
        local levelExp, needExp = GetTaxueExp(player)
        local difficulty = GetPlayer().difficulty and GetPlayer().difficulty or "人物你都没选"

        local modifier = GetPlayer().components.combat.attack_damage_modifiers["taxue"] --攻击系数

        Info:Add("难度:" .. GetDifficulty(difficulty))
        Info:Add("人物生存天数:" .. player.taxue_day_num)
        Info:Add("人物等级:" .. player.level)
        Info:Add("经验值:" .. formatNumber(levelExp) .. "/" .. formatNumber(needExp))
        Info:Add("魅力值:" .. formatNumber(player.charm_value) .. "-" .. (player.charm_switch and "开启" or "关闭"))
        Info:Add("战斗力:" .. formatNumber(player.combat_capacity) .. ",攻击系数:" .. string.format("%.2f", 1 + modifier))
        Info:Add("美味值:" .. formatNumber(player.delicious_value) .. "," .. GetDeliciousStr(player))
        Info:Add("银行存款:" .. formatCoins(player.bank_value * 100) .. "," .. GetBankStr(player))
        Info:Add("已收获利息:" .. formatCoins(player.interest_num * 100))
        local fortuneStr = GetFortuneStr(player)
        if cfg("fortunePatch.usePatch", true) then
            local str = cfg("fortunePatch.usePatch") and "梅运券已装载: " .. (player.fortune_day or 0) or ""
            Info:Add(str)
            Info:Add(fortuneStr[1])
            if player.fortune_day and player.fortune_day > 0 then
                Info:Add(fortuneStr[2])
            end
        else
            Info:Add(fortuneStr[1])
        end

        return Info.data
    end
    --人物Buff
    if target.components and target.components.taxuebuff then
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
    --食物
    if target.components and target.components.perishable then
        local time = target.components.perishable.perishremainingtime                           --剩余时间（喵）
        local owner = target.components.inventoryitem and target.components.inventoryitem.owner --容器
        if owner then
            --冰箱
            if owner:HasTag("fridge") then
                time = time * 2
                --4倍
            elseif owner:HasTag("taxue_fridge_4x") then
                time = time * 4
                --6倍
            elseif owner:HasTag("taxue_fridge_6x") then
                time = time * 6
                --腐烂箱
            elseif owner:HasTag("taxue_fridge_500") then
                time = time / 500
                --永久
            elseif owner:HasTag("taxue_fridge_always") then
                time = "∞天"
            end
            if target:HasTag("frozen") and not owner:HasTag("nocool") and not owner:HasTag("taxue_fridge_500") then
                time = "∞天"
            end
        end
        if time ~= "∞天" then
            time = formatTime(time)
        end
        Info:Add("腐烂时间：" .. time)
    end
    --冰箱
    if target:HasTag("fridge") then
        Info:Add("保鲜时间 * 2")
        --4倍保鲜
    elseif target:HasTag("taxue_fridge_4x") then
        Info:Add("保鲜时间 * 4")
        --6倍保鲜
    elseif target:HasTag("taxue_fridge_6x") then
        Info:Add("保鲜时间 * 6")
        --腐烂箱
    elseif target:HasTag("taxue_fridge_500") then
        Info:Add("保鲜时间 * 1/500")
        --永久保鲜
    elseif target:HasTag("taxue_fridge_always") then
        Info:Add("永久保鲜")
    end
    --生物
    if target.components and target.components.health and target.components.health.absorb then
        Info:Add("伤害减免:" .. math.floor(target.components.health.absorb * 100) .. "%")
    end
    --武器
    if target.damage then
        local damage = target.damage
        if target.prefab == "blazing_sword" then
            local charge, maxcharge = target.components.obsidiantool:GetCharge()
            damage = target.damage + target.damage * (charge / maxcharge)
        end
        Info:Add("伤害:" .. string.format("%6.2f", damage))
    end
    if target.components and target.components.weapon then
        if target.armor_penetration then
            Info:Add("护甲穿透:" .. math.floor(target.armor_penetration * 100) .. "%")
        end
        if target.level then
            Info:Add("等级：" .. target.level)
        end
        if target.forge_level then
            Info:Add("锻造等级：" .. target.forge_level)
        end
    end
    --护甲
    if target.components.armor then
        Info:Add("护甲吸收:" .. (target.components.armor.absorb_percent * 100) .. "%")
        Info:Add("耐久:" .. string.format("%6.0f", target.components.armor.condition) .. "/" .. target.components.armor.maxcondition)
        if target.level then
            Info:Add("等级:" .. target.level)
        end
    end
    --孵蛋器
    if target.prefab == "hatch_machine" then
        local timetonextspawn = target.components.childspawner.timetonextspawn
        if target.egg_name ~= "empty" and timetonextspawn ~= 0 then
            Info:Add("正在孵化: " .. TaxueToChs(target.egg_name))
            Info:Add("剩余时间: " .. formatTime(timetonextspawn))
        end
        --银行
    elseif target.prefab == "taxue_bank" or target.prefab == "taxue_bank_card" then
        local taxue_coin_silver = player.bank_value * player.bank_interest                                           --每日收入银梅币
        local max = player.initial_interest + (player.level > player.MAX_LEVEL and player.MAX_LEVEL or player.level) --最大利息
        taxue_coin_silver = taxue_coin_silver > max and max or taxue_coin_silver
        local interest = player.bank_interest * 100                                                                  --今日利率百分比
        if player.bank_value > 0 then                                                                                --有钱
            Info:Add("银行存款: " .. formatNumber(player.bank_value, 2, false) .. "梅币")
            Info:Add("最大利息: " .. formatNumber(max * 100) .. "银梅币")
            Info:Add("明日预计收入: " .. formatNumber(taxue_coin_silver * 100, 2, false) .. "银梅币")
        end
        Info:Add("今日利率: " .. string.format("%6.2f", interest) .. "%")
        --破甲法杖
    elseif target.prefab == "armor_penetration_staff" then
        Info:Add("护甲削减:" .. math.floor(target.armor_penetration * 100) .. "%")
        --黄金猫
    elseif target.prefab == "golden_statue" then
        Info:Add("已收获金肉: " .. GetPlayer().golden_statue_lv .. " 枚")
    elseif target.prefab == "golden_statue_colorful" then
        Info:Add("已收获金肉: " .. GetPlayer().golden_statue_colorful_lv .. " 枚")
        --黄金boss雕像
    elseif target.prefab == "taxue_golden_boss_altar" then
        Info:Add("变异概率: " .. string.format("%6.1f", (GetPlayer().boss_altar_value * 100)) .. " %")
        --利息券
    elseif target.prefab == "interest_ticket" then
        Info:Add("利息上限:" .. (target.interest * 100) .. "银梅币")
        --刷券券
    elseif target.prefab == "refreshticket_ticket" then
        Info:Add("可刷新数量：" .. target.refresh_num .. " 个")
        --粉红月牙矿
    elseif target.prefab == "taxue_crescent_rock" then
        Info:Add("已收获粉宝石: " .. target.level .. " 枚")
        --永动机
    elseif target.prefab == "taxue_perpetual_machine" then
        if target.lv then
            Info:Add("当前等级: " .. target.lv .. " / 7 级")
        end
        if target.day then
            Info:Add("当前天数: " .. target.day % 3 + 1 .. " / 3")
        end
        if player.perpetual_machine_num then
            Info:Add("已建造数量: " .. player.perpetual_machine_num .. " / " .. target.MAX_NUM)
        end

        --七彩永动机
    elseif target.prefab == "taxue_perpetual_machine_colorful" then
        if target.day then
            Info:Add("当前天数: " .. target.day % 3 + 1 .. " / 3")
        end
        --踏雪商店
    elseif target.prefab and target.prefab:startWith("taxue_shop") then
        local id = target.interiorID
        local interior = GetWorld().components.interiorspawner.interiors[id]
        if interior and cfg("displaySetting.showShop", true) then
            local shopItemList = {}
            local maxNameLength = 0
            local maxCostLength = 0
            --遍历商店中所有实体
            for _, obj in pairs(interior.object_list) do
                --如果是货架,保存物品名 花费 花费物品
                if obj.prefab == "shop_buyer" then
                    local item = obj.components.shopdispenser:GetItem()
                    if item then
                        local name = TaxueToChs(item) or item
                        local cost = formatNumber(obj.cost)
                        local costName = TaxueToChs(obj.costprefab) or obj.costprefab
                        if #tostring(name) > maxNameLength then maxNameLength = #tostring(name) end
                        if #tostring(cost) > maxCostLength then maxCostLength = #tostring(cost) end
                        table.insert(shopItemList, { id = item, name = name, cost = cost, costName = costName })
                    end
                end
            end
            --遍历保存的物品,排序
            local itemList = {}
            for _, shopItem in ipairs(TaxueList.shop_item_atlas) do
                for _, item in pairs(shopItemList) do
                    if shopItem == item.id then
                        table.insert(itemList, item)
                    end
                end
            end
            if #itemList < #shopItemList then
                for _, item in ipairs(shopItemList) do
                    local flag = true
                    if #itemList > 0 then
                        for i = 1, #itemList do
                            if item == itemList[i] then
                                flag = false
                                break
                            end
                        end
                    end
                    if flag then
                        table.insert(itemList, item)
                    end
                end
            end
            --添加信息
            for _, item in ipairs(itemList) do
                if item.name then
                    local space = ((maxCostLength - #item.cost) * 2 - (math.floor(maxCostLength / 4) - math.floor(#item.cost / 4)))
                    local cost = ("%" .. space .. "s"):format("") .. item.cost
                    Info:Add(("%-" .. maxNameLength .. "s: %s%s"):format(item.name, cost, item.costName))
                end
            end
        end
        if target.prefab == "taxue_shop" then
            Info:Add("已建造数量: " .. player.taxue_shop_num .. " / " .. TUNING.TAXUE_SHOP_MAX_NUM)
        end
        --开锁书
    elseif target.prefab == "book_unlocking" then
        Info:Add("(软木钥匙,木箱钥匙,骨箱钥匙)：" .. (target.corkchest_key) .. " 枚," .. (target.treasurechest_key) .. " 枚," .. (target.skullchest_key) .. " 枚")
        Info:Add("(精致钥匙,豪华钥匙,恐怖钥匙)：" .. (target.pandoraschest_key) .. " 枚," .. (target.minotaurchest_key) .. " 枚," .. (target.terrarium_key) .. " 枚")
        Info:Add("(剧毒钥匙)：" .. (target.poison_key) .. " 枚")
        --批量召唤书
    elseif target.prefab == "book_batch_summon" then
        if #target.monster_list > 0 then
            if not (target.monsterNum and target.monsterNum == #target.monster_list) then
                target.monsterNum = #target.monster_list
                target.monsterNumList = {}
                for _, monster in pairs(target.monster_list) do
                    target.monsterNumList[monster] = target.monsterNumList[monster] and target.monsterNumList[monster] + 1 or 1
                end
            end
            local nameMap = {
                moose = "鹿鸭"
            }
            local lineNum = 1
            for name, num in pairs(target.monsterNumList) do
                -- if lineNum > (TaxuePatch.cfg.PACKAGE_DES_MAX_LINES or 10) then break end
                lineNum = lineNum + 1
                Info:Add(("召唤物-%s: %d只"):format(TaxueToChs(name) or nameMap[name] or name, num))
            end
        end
        Info:Add("召唤物总计：" .. (#target.monster_list) .. " 只")
        --战利品券
    elseif target.prefab == "loot_ticket" then
        Info:Add("额外掉落：" .. target.loot_multiple .. " 倍")
        --填充式战利品券
    elseif target.prefab == "loot_ticket_fill" then
        Info:Add("额外掉落：" .. target.loot_multiple .. " /" .. target.MAX_MULTIPLE .. "倍")
        --鱼缸
    elseif target.prefab == "taxue_fish_tank" and target.components.breeder.seeded then
        local breeder = target.components.breeder
        Info:Add(("%s: %d/%d条"):format(TaxueToChs(breeder.product), breeder.volume, breeder.max_volume))
        if breeder.volume < breeder.max_volume and breeder.breedTask then
            local timeLeft = GetTaskRemaining(breeder.breedTask)
            Info:Add("下次生产时间: " .. formatTime(timeLeft))
        end
        --超级包裹
    elseif target.prefab == "super_package" then
        if target.isPatched then
            local totalAmount = target.amount
            local maxLineNum = cfg("package.desMaxLines")
            local singleType = target.type
            local singleItem
            local singleData
            local list = target.item_list
            local amountMap = target.amountMap
            local valueMap = target.valueMap
            local orders = TaxuePatch.ItemTypeOders
            local getNameStr = function (name) return TaxuePatch.ItemTypeNameMap[name] or name end
            local showLines

            if singleType then
                list = list[singleType]
                amountMap = amountMap[singleType].sub
                valueMap = valueMap[singleType].sub
                orders = TaxuePatch.ItemTypeMap[singleType] or { "noOrder" }
                getNameStr = function (name) return TaxueToChs(name) end

                singleItem = table.count(list) == 1 and next(list)
                if singleItem and type(list[singleItem]) == "table" then
                    amountMap = amountMap[singleItem].sub
                    valueMap = valueMap[singleItem].sub
                    list = list[singleItem]
                    orders = { "noOrder" }
                    getNameStr = function (name) return TaxueToChs(singleItem) .. "(" .. TaxuePatch.DataStrMap[singleItem]:format(type(name) == "string" and TaxueToChs(name) or tostring(name)) .. ")" end
                    showLines = table.containskey(TaxuePatch.ItemDataMap, singleItem) or "nodata"

                    singleData = showLines ~= "nodata" and table.count(list) == 1 and next(list)
                    if singleData then
                        amountMap = amountMap[singleData]
                        valueMap = valueMap[singleData]
                        list = list[singleData]
                        showLines = false
                    end
                end
            end

            if target.name == TaxueToChs(target.prefab) and target.type then
                local packageName
                if singleData or singleItem then
                    packageName = TaxueToChs(singleItem)
                else
                    packageName = TaxuePatch.ItemTypeNameMap[target.type]
                end
                if packageName then Info:Add(("超级包裹: %s"):format(packageName)) end
            end
            local lineNum = 0
            if maxLineNum > 0 then
                local lineNumFlag = false
                for _, order in pairs(orders) do
                    for name, subList in pairs(list) do
                        if (showLines ~= false and showLines ~= "nodata") and (order == "noOrder" or name == order) then
                            if lineNum <= maxLineNum then
                                local nameStr = order == "noOrder" and getNameStr(name) or getNameStr(order)
                                local valueStr = valueMap[name].hasValue and "/总价值:" .. formatCoins(valueMap[name].value) or "/无法售出"
                                local numberStr
                                if type(subList) == "number" then
                                    numberStr = (": 数量%s"):format(formatNumber(subList))
                                elseif showLines ~= nil then
                                    numberStr = (": 数量%s"):format(formatNumber(amountMap[name].amount))
                                else
                                    numberStr = ((": 种类%d/总数%s"):format(table.count(subList), formatNumber(amountMap[name].amount)))
                                end
                                Info:Add(nameStr .. numberStr .. valueStr)
                                lineNum = lineNum + 1
                            else
                                Info:Add("...")
                                lineNumFlag = true
                                break
                            end
                            if order ~= "noOrder" then break end
                        end
                    end
                    if lineNumFlag then break end
                end
            end
            local str
            if showLines ~= false and showLines ~= "nodata" then
                str = ("%d%s物品,物品总数量: %s"):format(table.count(list), singleType and "种" or "类", formatNumber(totalAmount))
            elseif showLines == "nodata" then
                str = ("%s - 数量: %s"):format(TaxueToChs(singleItem), formatNumber(totalAmount))
            else
                if singleData then Info:Add(getNameStr(singleData)) end
                str = ("物品数量: %s"):format(formatNumber(totalAmount))
            end
            Info:Add(str)
        else
            local highPercent = cfg("package.highEquipmentPercent") or 0.75
            local numMap = { stackable = 0, stackableKind = 0 }
            local numStrs = {
                specialBook = "贵重书籍",
                book = "普通书籍",
                weapon = "武器护甲",
                highEquipment = "高属性五彩装备",
                lowEquipment = "低属性五彩装备",
                other = "其他不可堆叠物品",
            }
            local order = { "specialBook", "book", "weapon", "highEquipment", "lowEquipment", "other" }
            local totalNum = 0
            for name, amount in pairs(target.item_list) do
                if type(amount) == "table" then
                    Info:Add("包裹数据异常")
                    return Info.data
                end
                numMap.stackable = numMap.stackable + amount
                numMap.stackableKind = numMap.stackableKind + 1
                totalNum = totalNum + amount
            end
            for _, item in pairs(target.components.container.slots) do
                if item then
                    if item:HasTag("book") or item:HasTag("taxue_book") then
                        if item.taxue_coin_value and item.taxue_coin_value >= 300 then
                            numMap.specialBook = numMap.specialBook and numMap.specialBook + 1 or 1
                        else
                            numMap.book = numMap.book and numMap.book + 1 or 1
                        end
                    elseif item:HasTag("taxue_weapon") or item:HasTag("taxue_armor") then
                        numMap.weapon = numMap.weapon and numMap.weapon + 1 or 1
                    elseif item:HasTag("taxue_equipment") then
                        if item.equip_value < highPercent * item.MAX_EQUIP_VALUE then
                            numMap.highEquipment = numMap.highEquipment and numMap.highEquipment + 1 or 1
                        else
                            numMap.lowEquipment = numMap.lowEquipment and numMap.lowEquipment + 1 or 1
                        end
                    else
                        numMap.other = numMap.other and numMap.other + 1 or 1
                    end
                    totalNum = totalNum + 1
                end
            end
            for _, name in pairs(order) do
                if numMap[name] then
                    Info:Add(("%s数量: %s"):format(numStrs[name], formatNumber(numMap[name])))
                end
            end
            Info:Add("可堆叠物品种类:" .. numMap.stackableKind .. "，物品数量：" .. formatNumber(numMap.stackable))
            Info:Add("物品总数量: " .. formatNumber(totalNum))
        end
    elseif target.prefab == "book_touch_leif" then --点树成精
        Info:Add("树精数量: " .. target.leif_num .. "只")
        --点蛛成精
    elseif target.prefab == "book_touch_spiderqueen" then
        Info:Add("蜘蛛女王数量: " .. target.spiderqueen_num .. "只")
        --点怪成金
    elseif target.prefab == "book_touch_golden" then
        Info:Add("点金数量: " .. target.golden_num .. "只")
        --宝藏去质
    elseif target.prefab == "book_treasure_deprotonation" then
        Info:Add("去质宝藏数量:" .. target.treasure_num .. "个")
        --赌狗劵
    elseif target.prefab == "gamble_ticket" then
        Info:Add("可能额外掉落:" .. target.gamble_multiple .. "倍")
        --掉包券
    elseif target.prefab == "substitute_ticket" then
        Info:Add("掉包物品: " .. TaxueToChs(target.substitute_item))
        --定向商店刷新券
    elseif target.prefab == "shop_refresh_ticket_directed" then
        Info:Add("刷新物品: " .. TaxueToChs(target.refresh_item))
        --重铸器
    elseif target.prefab == "taxue_recasting_machine" then
        Info:Add("重铸成功率: " .. string.format("%6.2f", GetPlayer().recasting_num * 100) .. "%")
        --超级打包机
    elseif target.prefab == "super_package_machine" then
        if target.isPatched then
            local slots = target.components.container.slots
            local package = nil
            for __, v in pairs(slots) do
                if v.prefab == "super_package" then
                    package = v
                end
            end
            getItemInfo(package)
        elseif target.switch == "on" then
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
    end
    --超级书time类
    if target.time then
        Info:Add("耐久：" .. target.time .. " 次")
    end
    --装备重置书
    if target.filter_percent then
        Info:Add("筛选数值百分比：高于" .. (target.filter_percent * 100) .. " %")
    end
    --灌铅包裹
    if target.loaded_item_list then
        Info:Add("物品数量: " .. #target.loaded_item_list .. "个")
    end
    --炼药台/炼煤炉
    if target.components and target.components.melter and target.components.melter.cooking == true then
        local timeleft = GetTaskRemaining(target.components.melter.task)
        Info:Add("正在炼制:" .. TaxueToChs(target.components.melter.product))
        if timeleft > 0 then
            Info:Add("剩余时间: " .. formatTime(timeleft))
        end
    end
    --特殊装备
    if target.components and target.equip_position then
        local value = target.equip_value
        local sign = target.equip_sign
        local formatStrs = {
            equipment_unforgettable      = "血量上限:%s", --刻骨铭心
            equipment_baby_dragon        = "精神回复:%s/分钟", --幼龙
            equipment_light_pearl        = "发光范围:%s", --夜明珠
            equipment_nobel_faceblack    = "欧气值:%s%%", --诺贝尔脸黑奖
            equipment_fast_sandclock     = "移速:%s%%", --迅捷沙漏
            equipment_fire_scale         = "伤害:%s", --熔岩火鳞
            equipment_golden_ring        = "金肉掉落率:%s%%", --黄金戒指
            equipment_fire_horn          = "暴击率:%s%%", --熔岩火角
            equipment_fire_claw          = "暴击伤害加成:%s倍", --熔岩火爪
            equipment_magic_conch        = "变异率:%s%%", --魔法海螺
            equipment_crown              = "攻速:%s%%", --皇冠
            equipment_lockpick           = "钥匙掉率:%s%%", --撬锁器
            equipment_clover             = "植物精华掉率:%s%%", --四叶草
            equipment_sweetheart_hairpin = "魅力值:%s", --甜心发卡
            equipment_crystal_hat        = "防水:%s%%", --黯晶礼帽
            equipment_exp_book           = "额外经验值:%s", --经验秘籍
            equipment_fire_tooth         = "真实伤害:%s", --熔岩火牙
            equipment_sea_clover         = "海洋精华掉率:%s%%", --海洋四叶草
            equipment_thieves_gloves     = "银梅币爆率:%s%%", --窃贼手套
            equipment_snowflake          = "冰冻层数:%s层", --雪花
            equipment_volcano_clover     = "火山精华掉率:%s%%", --火山四叶草
            equipment_threecolour_clover = "精华掉率:%s%%", --三色四叶草
            equipment_lollipop           = "孵化蛋掉率:%s%%", --波板糖
            equipment_pearl_mussel       = "珍珠精华掉率:%s%%", --珍珠蚌
            equipment_loaded_dice        = "灌铅包裹掉率:%s%%", --灌铅骰子
            equipment_colourful_windmill = "特殊奖励掉率:%s%%", --炫彩风车
        }
        local formatStr = formatStrs[sign]
        if formatStr then
            local showValue = value
            if formatStr:endsWith("%%") then
                showValue = value * 100
            elseif formatStr:endsWith("分钟") then
                showValue = value * 60
            end
            if sign == "equipment_crystal_hat" then
                Info:Add("防雷:100%")
            end
            Info:Add(formatStr:format(formatNumber(showValue)))
            Info:Add("穿戴位置:" .. GetEquipmentName(target.equip_position))
        end
        local activeitem = player.components.inventory.activeitem
        if activeitem and activeitem.prefab == "copy_gem" and target.components.trader:CanAccept(activeitem, player) and cfg("displaySetting.showCopyChance", true) then
            Info:Add(("复制成功率:%.2f%%"):format(100 / (math.ceil(value / target.MAX_EQUIP_VALUE))))
        end
    end
    --货币价值物品
    if target.taxue_coin_value then
        local stacksize = target.components.stackable and target.components.stackable.stacksize or 1
        local valueStr = formatCoins(target.taxue_coin_value)
        local realValue
        if target.components.finiteuses then
            local percent = target.components.finiteuses:GetPercent()
            realValue = percent < 1 and target.taxue_coin_value * percent
        elseif target.components.armor then
            local percent = target.components.armor:GetPercent()
            realValue = percent < 1 and target.taxue_coin_value * percent
        end
        if stacksize > 1 then
            local stackValue = stacksize * target.taxue_coin_value
            local force = stackValue > 1000
            local stackValueStr = "/总价值:" .. formatCoins(stackValue, force)
            Info:Add("单价:" .. valueStr .. stackValueStr)
        else
            local realValueStr = realValue and "/实际价值:" .. formatCoins(realValue) or ""
            Info:Add("价值:" .. valueStr .. realValueStr)
        end
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
AddClassPostConstruct("widgets/hoverer", function (self)
    local old_SetString = self.text.SetString
    self.text:SetColour(getColor())
    self.text.SetString = function (text, str)
        if Info.type == "text" then
            local target = TheInput:GetWorldEntityUnderMouse() --获取鼠标所指的实体
            local success, err, result = pcall(getItemInfo, target)
            return old_SetString(text, str .. (success and result or err))
        end
        return old_SetString(text, str)
    end
end)

AddPlayerPostInit(function (inst)
    inst:DoTaskInTime(0.1, function ()
        local dyc = DYCLegendary or DYCInfoPanel
        if dyc and dyc.objectDetailWindow then
            --使用信息面板显示
            --修改颜色
            local oldSetObjectDetail = dyc.objectDetailWindow.SetObjectDetail
            dyc.objectDetailWindow.SetObjectDetail = function (self, page)
                for _, line in ipairs(page.lines) do
                    if line.component == 'custom' then
                        if line.text:startWith("#") then
                            line.color = dyc.RGBAColor(getColor(line.text:sub(2, 2)))
                            line.text = line.text:sub(3)
                        else
                            line.color = line.color or dyc.RGBAColor(getColor())
                        end
                    end
                end
                oldSetObjectDetail(self, page)
            end
            --初始化Info类
            Info:init("table")
            --添加信息显示
            local oldGetPanelDescriptions = EntityScript.GetPanelDescriptions
            EntityScript.GetPanelDescriptions = function (self)
                Info:setTarget(self)
                --清空上次添加的信息
                for _, index in ipairs(Info.indexs) do
                    self:SetPanelDescription(index, nil)
                end
                --防止崩溃
                local success, err = pcall(getItemInfo, self)
                if not success then
                    Info:Add(err)
                end
                return oldGetPanelDescriptions(self)
            end
        else
            --使用原版显示
            Info:init("text")
            Inv.UpdateCursorText = NewUpdateCursorText
            ItemTile.GetDescriptionString = NewGetDescriptionString
        end
    end)
end)
