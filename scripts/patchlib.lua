local Image = require "widgets/image"
local superPackageLib = require "superPackageLib"

local cfg = TaxuePatch.cfg

local patchLib = {}

---count table
---@param table table
---@return integer
function patchLib.TableCount(table)
    local count = 0
    for _, _ in pairs(table) do count = count + 1 end
    return count
end

table.count = patchLib.TableCount

---table add
---@param ... table<any,any>
---@return table<any,any>
function patchLib.TableAdd(...)
    local t = {}
    for _, t_ in pairs({ ... }) do
        for key, value in pairs(t_) do
            t[key] = value
        end
    end
    return t
end

---给列表key对应的值加value
---@param List table
---@param key any
---@param value any
function patchLib.ListAdd(List, key, value)
    if value == 0 then return end
    value = value or 1
    List[key] = List[key] and List[key] + value or value
end

---测试物品是否符合条件
---@param item entityPrefab
---@param test string|string[]|fun(item:entityPrefab):boolean
---@return boolean
function patchLib.TestItem(item, test)
    if not item then return false end
    local testFn
    if type(test) == "table" then
        testFn = function(prefab) return table.contains(test, prefab.prefab) end
    elseif type(test) == "string" then
        testFn = function(prefab) return prefab.prefab == test end
    elseif type(test) == "function" then
        testFn = test
    else
        return false
    end
    return testFn(item)
end

---返回slots中找到的第一个符合的物品
---@param slots entityPrefab[]
---@param itemTest string|string[]|fun(item:entityPrefab):boolean
---@return entityPrefab|nil item
---@return integer|nil slot
function patchLib.FindItem(slots, itemTest)
    if not slots then return nil, nil end
    for slot, item in pairs(slots) do
        if patchLib.TestItem(item, itemTest) then
            return item, slot
        end
    end
end

---遍历物品栏
---@param owner entityPrefab
---@param fn fun(container:table,item:entityPrefab,slot:integer):shouldEnd:boolean
---@param opencontainer? boolean
---@return boolean
function patchLib.TraversalAllInventory(owner, fn, opencontainer)
    if not (owner and owner.components) then return false end
    local allSlots = {}
    if owner.components.container then
        allSlots[owner.components.container.slots] = owner.components.container
    elseif owner.components.inventory then
        local inventory = owner.components.inventory
        allSlots[inventory.itemslots] = inventory
        allSlots[inventory.equipslots] = inventory
        if opencontainer then
            for container, _ in pairs(inventory.opencontainers) do
                allSlots[container.components.container.slots] = container.components.container
            end
        end
    end
    for slots, container in pairs(allSlots) do
        for slot, item in pairs(slots) do
            if fn(container, item, slot) then return true end
            if item.components and item.components.container then patchLib.TraversalAllInventory(item, fn) end
        end
    end
    return false
end

---获取物品栏和背包栏所有物品
---@return Item[] items
function patchLib.GetAllInventoryItems()
    local player = GetPlayer()
    local inventory = player.components.inventory
    local back = inventory.equipslots[EQUIPSLOTS.BACK]
    local items = {}
    for _, item in pairs(inventory.itemslots) do
        table.insert(items, item)
    end
    if back and back.components.container then
        for _, item in pairs(back.components.container.slots) do
            table.insert(items, item)
        end
    end
    return items
end

---查找周围实体
---@param inst entityPrefab
---@param radius number
---@param testFn? string|fun(entity: entityPrefab):boolean
---@param tags? string[]
---@param notags? string[]
---@return entityPrefab[]|table[]
function patchLib.GetNearByEntities(inst, radius, testFn, tags, notags)
    if not inst or not inst:IsValid() then return {} end
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local notags = notags or { "INLIMBO", "NOCLICK", "catchable", "fire", "player" }
    local list = {}
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, radius, tags, notags)
    for _, entity in pairs(ents) do
        if entity ~= inst and entity:IsValid() then
            local testResult = true
            if testFn then
                if type(testFn) == "string" then
                    testResult = entity.prefab == testFn
                elseif type(testFn) == "function" then
                    testResult = testFn(entity)
                end
            end
            if testResult then
                table.insert(list, entity)
            end
        end
    end
    return list
end

---计算概率次数结果
---@param chance number
---@param times integer
---@return integer
function patchLib.GetChanceResult(chance, times)
    local result = 0
    for _ = 1, times do
        if math.random() < chance then
            result = result + 1
        end
    end
    return result
end

---移除物品
---@param item entityPrefab
function patchLib.RemoveItem(item)
    local owner = item.components.inventoryitem.owner
    if owner then
        if owner == GetPlayer() then
            owner.components.inventory:RemoveItem(item, true)
        else
            owner.components.container:RemoveItem(item, true)
        end
    end
    item:Remove()
end

---给予物品
---@param inst entityPrefab 目标容器/玩家
---@param item entityPrefab 物品
function patchLib.GiveItem(inst, item)
    if not item or not item.components or not inst or not inst.components then return end
    local container
    if inst.components.inventoryitem then
        local owner = inst.components.inventoryitem.owner
        if owner then
            container = owner == GetPlayer() and owner.components.inventory or owner.components.container
        end
    elseif inst.components.container or inst.components.inventory then
        container = inst == GetPlayer() and inst.components.inventory or inst.components.container
    end
    if container and container:CanTakeItemInSlot(item) then
        container:GiveItem(item)
    else
        local pos = Vector3(inst.Transform:GetWorldPosition())
        item.Transform:SetPosition(pos:Get())
        if item.components.inventoryitem then
            item.components.inventoryitem:OnDropped(true)
        end
    end
end

---给予物品
---@param inst entityPrefab 目标容器/玩家
---@param itemList table<string, integer> 物品名和数量表
function patchLib.GiveItems(inst, itemList)
    for name, amount in pairs(itemList) do
        if amount > 0 then
            local item = SpawnPrefab(name)
            if item.components and item.components.stackable then
                item.components.stackable.stacksize = amount
                patchLib.GiveItem(inst, item)
            else
                item:Remove()
                for _ = 1, amount do
                    patchLib.GiveItem(inst, SpawnPrefab(name))
                end
            end
        end
    end
end

---获取对应数量的堆叠物品
---@param name string
---@param amount integer
---@param maxsize integer
---@return entityPrefab[]
function patchLib.GetStackedItem(name, amount, maxsize)
    local items = {}
    if not maxsize then
        local tempItem = SpawnPrefab(name)
        maxsize = tempItem.components.stackable.maxsize
        tempItem:Remove()
    end
    local size = amount or 1
    local stack_num = math.floor(size / maxsize)
    local surplus_num = size - maxsize * stack_num
    if stack_num > 0 then
        for i = 1, stack_num do
            local newItem = SpawnPrefab(name)
            newItem.components.stackable.stacksize = maxsize
            table.insert(items, newItem)
        end
    end
    if surplus_num > 0 then
        local newItem = SpawnPrefab(name)
        newItem.components.stackable.stacksize = surplus_num
        table.insert(items, newItem)
    end
    return items
end

---删除容器内物品
---@param container table
---@param itemList entityPrefab[]
function patchLib.RemoveSlotsItems(container, itemList)
    for slot, _ in pairs(itemList) do
        container:RemoveItemBySlot(slot):Remove()
    end
end

---售货亭卖东西
---@param inst entityPrefab
function patchLib.SellPavilionSellItems(inst)
    local container = inst.components.container
    local slots = container.slots

    local diamond = nil
    local playSound = false
    local coinList = {}
    local coins = 0
    local itemCount = 0
    local lastItem
    local COINS = {
        taxue_coin = 100,
        taxue_coin_silver = 1,
        taxue_coin_copper = 0.01,
    }
    for slot, item in pairs(slots) do
        if item then
            itemCount = itemCount + 1
            lastItem = item

            local amount = 1
            if item.components.stackable then
                amount = item.components.stackable.stacksize
            end
            if COINS[item.prefab] or item.prefab == "gold_brick" then
                coinList[slot] = item
            elseif item.taxue_coin_value then
                --物品价值
                local taxue_coin_value = item.taxue_coin_value
                --有耐久，根据耐久百分比替换价值
                if item.components.finiteuses then
                    local percent = item.components.finiteuses:GetPercent()
                    taxue_coin_value = taxue_coin_value * percent
                end
                --有护甲值
                if item.components.armor then
                    local percent = item.components.armor:GetPercent()
                    taxue_coin_value = taxue_coin_value * percent
                end

                coins = coins + taxue_coin_value * amount

                --移除物品
                container:RemoveItemBySlot(slot):Remove()
            elseif cfg("buffThings.sellPavilion") == "bank" and item.prefab == "taxue_diamond" then
                diamond = item
            end
        end
    end
    if itemCount == 1 and lastItem.prefab == "gold_brick" then return end
    print("总硬币价值：", coins)
    local tempCoins = 0
    local coinNum = {}
    for slot, coin in pairs(coinList) do
        local amount = coin.components.stackable and coin.components.stackable.stacksize or 1
        if COINS[coin.prefab] then
            patchLib.ListAdd(coinNum, coin.prefab, amount)
            tempCoins = tempCoins + amount * COINS[coin.prefab]
        elseif coin.prefab == "gold_brick" then
            tempCoins = tempCoins + coin.taxue_coin_value
        end
    end

    --如果是银行模式并且有钻石,存银行
    if diamond and coins + tempCoins > 0 then
        container:RemoveItem(diamond):Remove()
        patchLib.RemoveSlotsItems(container, coinList)
        GetPlayer().bank_value = GetPlayer().bank_value + (coins + tempCoins) / 100
        playSound = true
        --如果不是禁用,并且金额大于500梅币
    elseif cfg("buffThings.sellPavilion") and coins + tempCoins >= 50000 then
        patchLib.RemoveSlotsItems(container, coinList)
        local goldBrick = SpawnPrefab("gold_brick")
        goldBrick.taxue_coin_value = coins + tempCoins
        container:GiveItem(goldBrick)
        playSound = true
        --否则,生成梅币
    else
        for _, coin in pairs({ "taxue_coin_silver", "taxue_coin_copper" }) do
            if coinNum[coin] and coinNum[coin] > 100 then
                local amount = math.floor(coinNum[coin] / 100) * 100
                container:ConsumeByName(coin, amount)
                coins = coins + amount * COINS[coin]
            end
        end

        local gold = math.floor(coins / 100)
        coins = coins - gold * 100
        local silver = math.floor(coins)
        local copper = math.floor((coins - silver) * 100 + 0.5)

        TaxueGiveItem(inst, "taxue_coin", gold)          --刷金币
        TaxueGiveItem(inst, "taxue_coin_silver", silver) --刷银币
        TaxueGiveItem(inst, "taxue_coin_copper", copper) --刷铜币

        if gold + silver + copper > 0 then
            playSound = true
        end
    end
    if playSound then inst.SoundEmitter:PlaySound("money/sfx/money") end
end

---黄金宝箱按钮
---@param inst entityPrefab
function patchLib.GoldenChestButton(inst)
    local player = GetPlayer()
    --搜寻金猫以及boss献祭雕像
    local statues = {
        golden_statue = true,
        golden_statue_colorful = true,
        taxue_golden_boss_altar = true,
    }
    local function testFn(ent)
        return statues[ent.prefab]
    end
    local ents = patchLib.GetNearByEntities(inst, 3, testFn)
    if #ents > 1 then
        player.components.talker:Say("附近雕像太多了~我要罢工！")
        return
    elseif #ents == 0 then
        player.components.talker:Say("附近没有发现任何黄金雕像！")
        return
    end
    local statue = ents[1]
    local has = false
    local slots = inst.components.container.slots --获取物品栏
    if statue.prefab == "taxue_golden_boss_altar" then
        local num = 0
        for slot, item in pairs(slots) do
            if item:HasTag("boss_altar") then
                has = true
                local amount = item.components.stackable and item.components.stackable.stacksize or 1
                num = num + amount * item.boss_altar
                inst.components.container:RemoveItemBySlot(slot):Remove()
            end
        end
        if has then
            player.boss_altar_value = player.boss_altar_value + num
            player.components.talker:Say("献祭率+" .. (num * 100) .. "%")
        end
    elseif statue.prefab == "golden_statue" or statue.prefab == "golden_statue_colorful" then
        local datas = {
            golden_statue = {
                goldValueLevel = 500,
                changeLevel = 1000,
                chances = {
                    defalut = {
                        bluegem = 0.04,
                        redgem = 0.04,
                    },
                    less = {
                        pink_gem = 0.007,
                        cyan_gem = 0.004,
                    },
                    greater = {
                        pink_gem = 0.01,
                        cyan_gem = 0.006,
                        black_gem = 0.003,
                    },
                },
                specialLevel = {
                    [3124] = {
                        pink_gem = 10,
                        cyan_gem = 10,
                        black_gem = 10,
                        greengem = 10,
                        orangegem = 10,
                        yellowgem = 10,
                    },
                    [31240] = {
                        golden_statue_colorful_blueprint = 1
                    }
                }
            },
            golden_statue_colorful = {
                goldValueLevel = 5000,
                changeLevel = 10000,
                chances = {
                    defalut = {
                        fortune_ticket = 0.003
                    },
                    less = {
                        white_gem = 0.000001,
                        colorful_gem = 0.00001,
                        reset_gem = 0.0004,
                        random_gem = 0.0001,
                        fortune_change_ticket = 0.0004,
                    },
                    greater = {
                        copy_gem = 0.000002,
                        white_gem = 0.000002,
                        colorful_gem = 0.00002,
                        reset_gem = 0.0006,
                        random_gem = 0.0003,
                        fortune_change_ticket = 0.0006,
                    }
                },
                specialLevel = {
                    [3124] = {
                        white_gem = 10,
                        colorful_gem = 10,
                        reset_gem = 10,
                        random_gem = 10,
                        copy_gem = function(itemList)
                            for _ = 1, 10 do
                                if math.random() < 0.3 then
                                    patchLib.ListAdd(itemList, "copy_gem")
                                end
                            end
                        end
                    }
                }
            }
        }
        local relics = {
            relic_1 = true,
            relic_2 = true,
            relic_3 = true,
        }
        local function getLevel()
            return statue.prefab == "golden_statue" and player.golden_statue_lv or player.golden_statue_colorful_lv
        end
        local function setLevel(level)
            if statue.prefab == "golden_statue" then
                player.golden_statue_lv = level
            else
                player.golden_statue_colorful_lv = level
            end
        end
        local data = datas[statue.prefab]
        local results, gold = {}, 0
        local continue = true
        while continue do
            local oldLevel, newLevel, valueNum, goldNum, relicNum = getLevel(), 0, 0, 0, 0
            local lvGreater = oldLevel > data.changeLevel
            local lvGreaterChange
            for slot, item in pairs(slots) do
                if item then
                    local remove
                    local amount = item.components.stackable and item.components.stackable.stacksize or 1
                    if item:HasTag("golden_food") then
                        for _ = 1, amount do
                            setLevel(getLevel() + 1)
                            valueNum = valueNum + math.floor(item.components.tradable.goldvalue * math.min(2, getLevel() / data.goldValueLevel + 1))
                            if not lvGreater and getLevel() > data.changeLevel then
                                lvGreaterChange = true
                                item.components.stackable:SetStackSize(amount - getLevel() + oldLevel)
                                break
                            end
                        end
                        remove = not lvGreaterChange
                    elseif statue.prefab == "golden_statue" then --如果是金猫雕像,计算原版换黄金和遗物
                        if item.components.tradable and item.components.tradable.goldvalue > 0 then
                            goldNum = goldNum + item.components.tradable.goldvalue * amount
                            remove = true
                        elseif relics[item.prefab] then
                            relicNum = relicNum + amount
                            remove = true
                        end
                    end
                    if remove then
                        inst.components.container:RemoveItemBySlot(slot):Remove()
                    end
                    if lvGreaterChange then
                        break
                    end
                end
            end
            newLevel = getLevel()
            continue = lvGreaterChange
            gold = gold + valueNum + goldNum
            local chanceMap = patchLib.TableAdd(data.chances.defalut, lvGreater and data.chances.greater or data.chances.less)
            if valueNum > 0 then
                for name, chance in pairs(chanceMap) do
                    for _ = 1, valueNum do
                        if math.random() < chance then
                            patchLib.ListAdd(results, name)
                        end
                    end
                end
                local showBanner = TaxuePatch.cfg("displaySetting.showBanner") and TaxuePatch.dyc and TaxuePatch.dyc.bannerSystem
                if showBanner then
                    local BANNER_COLOR = TaxuePatch.RGBAColor(TaxuePatch.cfg("displaySetting.showBanner.bannerColor"))
                    local bannerColor = TaxuePatch.dyc.RGBAColor(BANNER_COLOR:Get())
                    TaxuePatch.dyc.bannerSystem:ShowMessage("本次金肉价值为: " .. patchLib.FormatNumber(valueNum), 10, bannerColor)
                end
            end
            --处理特殊等级彩蛋
            for level, prefabs in pairs(data.specialLevel) do
                if level > oldLevel and level <= newLevel then
                    for name, amount in pairs(prefabs) do
                        if type(amount) == "function" then
                            amount(results)
                        else
                            patchLib.ListAdd(results, name, amount)
                        end
                    end
                end
            end
            --处理遗物
            if relicNum > 0 then
                for _ = 1, relicNum do
                    if math.random() < 0.3 then
                        patchLib.ListAdd(results, "redgem")
                    end
                    if math.random() < 0.3 then
                        patchLib.ListAdd(results, "bluegem")
                    end
                    if math.random() < 0.1 then --出随机一颗稀有
                        local num = math.random()
                        if num < 0.33 then
                            patchLib.ListAdd(results, "greengem")
                        elseif num < 0.66 then
                            patchLib.ListAdd(results, "orangegem")
                        else
                            patchLib.ListAdd(results, "yellowgem")
                        end
                    end
                end
                patchLib.ListAdd(results, "oinc100", math.floor(relicNum / 10))
                patchLib.ListAdd(results, "oinc10", relicNum % 10)
            end
        end
        has = gold > 0 or next(results)
        if has then
            if gold < 500 then
                patchLib.ListAdd(results, "goldnugget", gold)
            else
                local goldBrick = SpawnPrefab("gold_brick")
                goldBrick.taxue_coin_value = gold * 3
                patchLib.GiveItem(inst, goldBrick)
            end
            patchLib.GiveItems(inst, results)
        end
    end
    if has then
        inst.SoundEmitter:PlaySound("money/sfx/money")
    else
        player.components.talker:Say("你在点个寂寞呢？")
    end
end

---将掉落物添加到列表中
---@param lootDropper table
---@param dorpList table<string, integer>
---@param times? integer
---@return table<string, integer> dorpList
function patchLib.AddLootsToList(lootDropper, dorpList, times)
    times = times or 1
    for _ = 1, times do
        if lootDropper.numrandomloot and math.random() <= (lootDropper.chancerandomloot or 1) then
            for k = 1, lootDropper.numrandomloot do
                local loot = lootDropper:PickRandomLoot()
                if loot then
                    dorpList[loot] = dorpList[loot] and dorpList[loot] + 1 or 1
                end
            end
        end
    end

    if lootDropper.chanceloot then
        for k, v in pairs(lootDropper.chanceloot) do
            for _ = 1, times do
                if math.random() < v.chance then
                    dorpList[v.prefab] = dorpList[v.prefab] and dorpList[v.prefab] + 1 or 1
                    lootDropper.droppingchanceloot = true
                end
            end
        end
    end

    if lootDropper.chanceloottable then
        local loot_table = LootTables[lootDropper.chanceloottable]
        if loot_table then
            for i, entry in ipairs(loot_table) do
                local prefab = entry[1]
                local chance = entry[2]
                for _ = 1, times do
                    if math.random() <= chance then
                        dorpList[prefab] = dorpList[prefab] and dorpList[prefab] + 1 or 1
                        lootDropper.droppingchanceloot = true
                    end
                end
            end
        end
    end

    if not lootDropper.droppingchanceloot and lootDropper.ifnotchanceloot then
        lootDropper.inst:PushEvent("ifnotchanceloot")
        for k, v in pairs(lootDropper.ifnotchanceloot) do
            dorpList[v.prefab] = dorpList[v.prefab] and dorpList[v.prefab] + times or times
        end
    end

    if lootDropper.loot then
        for k, v in ipairs(lootDropper.loot) do
            dorpList[v] = dorpList[v] and dorpList[v] + times or times
        end
    end

    local recipename = lootDropper.inst.prefab
    if lootDropper.inst.recipeproxy then
        recipename = lootDropper.inst.recipeproxy
    end

    local recipe = GetRecipe(recipename)

    if recipe then
        local percent = 1

        if lootDropper.lootpercentoverride then
            percent = lootDropper.lootpercentoverride(lootDropper.inst)
        elseif lootDropper.inst.components.finiteuses then
            percent = lootDropper.inst.components.finiteuses:GetPercent()
        end

        for k, v in ipairs(recipe.ingredients) do
            local amt = math.ceil((v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent * times)
            if lootDropper.inst:HasTag("burnt") then
                amt = math.ceil((v.amount * TUNING.BURNT_HAMMER_LOOT_PERCENT) * percent)
            end

            if v.type == "oinc" then
                local oinc100       = math.floor(amt / 100)
                local oinc10        = math.floor((amt - (oinc100 * 100)) / 10)
                local oinc          = amt - (oinc100 * 100) - (oinc10 * 10)

                dorpList["oinc100"] = dorpList["oinc100"] and dorpList["oinc100"] + oinc100 or oinc100
                dorpList["oinc10"]  = dorpList["oinc10"] and dorpList["oinc10"] + oinc10 or oinc10
                dorpList["oinc"]    = dorpList["oinc"] and dorpList["oinc"] + oinc or oinc
            else
                dorpList[v.type] = dorpList[v.type] and dorpList[v.type] + amt or amt
            end
        end
    end

    if lootDropper.inst:HasTag("burnt") then
        for _ = 1, times do
            if math.random() < 0.4 then
                dorpList["charcoal"] = dorpList["charcoal"] and dorpList["charcoal"] + 1 or 1
            end
        end
    end
    return dorpList
end

---堆叠掉落物
---@param target entityPrefab
---@param dorpList table<string, integer>
---@param package? package
function patchLib.StackDrops(target, dorpList, package)
    local blackList = { "houndfire" }
    for _, name in pairs(blackList) do
        dorpList[name] = nil
    end
    if package then
        local blackList = { "chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone" }
        local function testFn(ent)
            local inventoryitem = ent.components.inventoryitem
            local itemName = ent.prefab
            local flag = inventoryitem and inventoryitem.canbepickedup and inventoryitem.cangoincontainer
            flag = flag and not ent:HasTag("doydoy") and not table.contains(blackList, itemName)
            if not flag then
                target.components.lootdropper:DropLootPrefab(ent)
            end
            return flag
        end
        superPackageLib.AddItemsToSuperPackage(package, dorpList, nil, testFn)
        if next(dorpList) then TaxueFx(target, "small_puff") end
    elseif TaxuePatch.cfg("taxueFix.betterDrop.stackDrop") then
        for name, amount in pairs(dorpList) do
            local item = SpawnPrefab(name)
            if item and item.components and item.components.stackable then
                local o = patchLib.GetNearByEntities(target, 15, name)
                if #o > 0 and o[1].components and o[1].components.stackable then
                    local oitem = o[1]
                    local maxsize = oitem.components.stackable.maxsize
                    if oitem.components.stackable.stacksize + amount <= maxsize then
                        oitem.components.stackable.stacksize = oitem.components.stackable.stacksize + amount
                        amount = 0
                        TaxueFx(oitem, "small_puff")
                    elseif oitem.components.stackable.stacksize < maxsize then
                        amount = amount + oitem.components.stackable.stacksize - maxsize
                        oitem.components.stackable.stacksize = maxsize
                        TaxueFx(oitem, "small_puff")
                    end
                end
                if amount > 0 then
                    item.components.stackable.stacksize = amount
                    target.components.lootdropper:DropLootPrefab(item)
                else
                    item:Remove()
                    TaxueFx(target, "small_puff")
                end
            elseif item then
                item:Remove()
                for _ = 1, amount do
                    target.components.lootdropper:DropLootPrefab(SpawnPrefab(name))
                end
            end
        end
    else
        for name, amount in pairs(dorpList) do
            if Prefabs[name] then
                for _ = 1, amount do
                    target.components.lootdropper:DropLootPrefab(SpawnPrefab(name))
                end
            end
        end
    end
end

---获得距离最近的开启的打包机中的包裹
---@param target entityPrefab
---@return package|nil
function patchLib.GetNearestPackageMachine(target)
    local player = GetPlayer()
    if player.nearestPackageMachine then
        local machie = player.nearestPackageMachine
        if target:IsValid() and machie:IsValid() and machie.switch == "on" and machie:GetDistanceSqToInst(target) <= 2500 then
            return machie.getPackage and machie:getPackage()
        else
            player.nearestPackageMachine = nil
        end
    elseif not player.lastScanPackage or GetTime() - player.lastScanPackage > 1 then
        player.lastScanPackage = GetTime()
        local testFn = function(ent)
            return ent.prefab == "super_package_machine" and ent.switch == "on"
        end
        local packageMachines = patchLib.GetNearByEntities(target, 50, testFn)
        if #packageMachines > 0 then
            player.nearestPackageMachine = packageMachines[1]
            return packageMachines[1].getPackage and packageMachines[1]:getPackage()
        else
            player.nearestPackageMachine = nil
        end
    end
    return nil
end

local itemImageCache = {}

---播放物品移动的动画
---@param item string
---@param src table
---@param target table
---@param time? number
function patchLib.PlayItemMove(item, src, target, time)
    local im
    if not itemImageCache[item] then
        local temp = SpawnPrefab(item)
        if temp.components and temp.components.inventoryitem then
            itemImageCache[item] = { temp.components.inventoryitem:GetAtlas(), temp.components.inventoryitem:GetImage() }
        end
        if temp then temp:Remove() end
    end

    im = Image(itemImageCache[item][1], itemImageCache[item][2])
    im:MoveTo(src, target, time or 0.3, function() im:Kill() end)
end

---批量收获
---@param crop table
---@param itemList table<string, integer>
---@param isBook? boolean
function patchLib.MultHarvest(crop, itemList, isBook)
    if not crop.matured or crop.withered then return end
    local player = GetPlayer()
    local product, amount = nil, 1
    local srcPos = Vector3(TheSim:GetScreenPos(crop.inst.Transform:GetWorldPosition()))
    local targetPos = Vector3(TheSim:GetScreenPos(player.Transform:GetWorldPosition())) + Vector3(0, 50, 0)
    if crop.grower and crop.grower:HasTag("fire") or crop.inst:HasTag("fire") then --着火，产物变为烤的
        local temp = SpawnPrefab(crop.product_prefab)                              --产物
        if temp.components.cookable and temp.components.cookable.product then
            product = temp.components.cookable.product
        else
            product = "seeds_cooked"
        end
        temp:Remove() --移除产物
    else
        product = crop.product_prefab
    end

    -----------------处理特殊种子额外收获-----------------
    --仙人掌额外收获花
    if crop.inst.prefab == "plant_cactus" then
        patchLib.ListAdd(itemList, "cactus_flower")
        patchLib.PlayItemMove("cactus_flower", srcPos, targetPos)

        --蘑菇
    elseif crop.inst.prefab == "plant_mushroom" then
        patchLib.ListAdd(itemList, "green_cap")
        patchLib.ListAdd(itemList, "blue_cap")
        patchLib.PlayItemMove("green_cap", srcPos, targetPos)
        patchLib.PlayItemMove("blue_cap", srcPos, targetPos)

        --蜜花额外收获
    elseif crop.inst.prefab == "plant_nectar" then
        amount = 6

        --处理芦苇,盆栽草,树枝,荧光果收获倍率
    elseif crop.inst.prefab == "plant_reeds" or crop.inst.prefab == "plant_grass" or crop.inst.prefab == "plant_sapling"
        or crop.inst.prefab == "plant_bulb" then
        amount = 3
    end

    if crop.grower then
        local grower = crop.grower
        if grower.prefab == "taxue_flowerpot" then
            local mult = 1
            if grower.level == 1 then
                mult = math.random(1, 3)
            elseif grower.level == 2 then
                mult = math.random(2, 5)
            elseif grower.level == 3 then
                mult = math.random(3, 7)
            end
            amount = amount * mult
        end

        local flowerPot = true
        local cloverChance, cloverEssence
        local threecolourclover_chance = player.threecolourclover_chance
        --黄金花盆或者活木花盆
        if grower.prefab == "taxue_flowerpot" and grower.level and grower.level > 0
            or grower and grower.prefab == "taxue_flowerpot_livinglog" then
            cloverChance = player.clover_chance
            cloverEssence = "plant_essence"

            --重置肥力值-永动机
            grower.components.grower.cycles_left = grower.components.grower.max_cycles_left

            --水盆
        elseif grower.prefab == "taxue_flowerpot_water" then
            cloverChance = player.seaclover_chance
            cloverEssence = "sea_essence"

            --火山盆
        elseif grower.prefab == "taxue_flowerpot_volcano" then
            cloverChance = player.volcanoclover_chance
            cloverEssence = "volcano_essence"
        else
            flowerPot = false
        end
        if flowerPot then
            local shoudSay
            --处理四叶草
            if cloverChance and threecolourclover_chance and math.random() < (cloverChance + threecolourclover_chance) then
                patchLib.ListAdd(itemList, cloverEssence)
                patchLib.PlayItemMove(cloverEssence, srcPos, targetPos)
                shoudSay = true
            end
            --处理三色四叶草
            if threecolourclover_chance and math.random() < (threecolourclover_chance / 3) then
                patchLib.ListAdd(itemList, "threecolor_essence")
                patchLib.PlayItemMove("threecolor_essence", srcPos, targetPos)
            end
            if shoudSay then player.components.talker:Say("我转运啦！") end
            --处理蛋蛋
            if isBook and math.random() < 0.005 then
                patchLib.ListAdd(itemList, "taxue_egg_harvest")
                patchLib.PlayItemMove("taxue_egg_harvest", srcPos, targetPos)
            end
        end
    end

    patchLib.ListAdd(itemList, product, amount)
    patchLib.PlayItemMove(product, srcPos, targetPos)

    ProfileStatsAdd("grown_" .. product)


    if crop.grower and crop.grower.components.grower then
        crop.grower.components.grower:RemoveCrop(crop.inst)
        if crop.inst.prefab == "plant_multiseason_taxue" then
            local seedMap = {
                --苹果
                taxue_apple = "taxue_apple_multiseason_seeds",
                taxue_apple_golden = "taxue_apple_multiseason_seeds",
                taxue_apple_green = "taxue_apple_multiseason_seeds",
                --菠萝
                taxue_pineapple = "taxue_pineapple_multiseason_seeds",
                taxue_pineapple_golden = "taxue_pineapple_multiseason_seeds",
                taxue_pineapple_big = "taxue_pineapple_multiseason_seeds",
                --草莓
                taxue_strawberry = "taxue_strawberry_multiseason_seeds",
                taxue_strawberry_golden = "taxue_strawberry_multiseason_seeds",
                taxue_strawberry_big = "taxue_strawberry_multiseason_seeds",
                --甜瓜
                taxue_melon = "taxue_melon_multiseason_seeds",
                taxue_melon_golden = "taxue_melon_multiseason_seeds",
                taxue_melon_big = "taxue_melon_multiseason_seeds",
            }
            crop.grower.components.grower:PlantItem(SpawnPrefab(seedMap[product]))                               --收获之后重新种植一颗作物
        elseif crop.inst.prefab ~= "plant_taxue" then
            crop.grower.components.grower:PlantItem(SpawnPrefab("taxue" .. crop.inst.prefab:sub(6) .. "_seeds")) --收获之后重新种植一颗作物
        end
    else
        crop.inst:Remove()
    end
end

---有消耗传送
---@param inst entityPrefab|Vector3
---@param must? boolean
function patchLib.CostTeleport(inst, must)
    local costFactor = TaxuePatch.cfg("teleportCat.costFactor")
    local maxCost = TaxuePatch.cfg("teleportCat.maxCost")
    local sanityFactor = TaxuePatch.cfg("teleportCat.sanityFactor")
    local x, y, z
    local player = GetPlayer()
    if inst.prefab then
        if not inst:IsValid() then return end
        x, y, z = inst.Transform:GetWorldPosition()
    else
        x, y, z = inst.x, inst.y, inst.z
    end
    if costFactor and player.components.hunger and player.components.sanity then
        local dist = Vector3(x, y, z):Dist(Vector3(player.Transform:GetWorldPosition()))
        local costHunger = math.floor(math.min(dist / costFactor, maxCost))
        local costSanity = math.floor(costHunger * sanityFactor)
        if must then
            if player.components.hunger.current < costHunger or player.components.sanity.current < costSanity then
                TaXueSay("你无法负担折跃消耗")
                return
            end
        end
        player.components.hunger:DoDelta(-costHunger)
        player.components.sanity:DoDelta(-costSanity)
    end
    if player.Physics then
        player.Physics:Teleport(x, 0, z)
    else
        player.Transform:SetPosition(x, 0, z)
    end

    -- follows
    local followers = {}
    if player.components.leader and player.components.leader.followers then
        for k, v in pairs(player.components.leader.followers) do
            table.insert(followers, k)
        end
    end

    patchLib.TraversalAllInventory(player, function(container, item, slot)
        if item.components.leader and item.components.leader.followers then
            for follower, _ in pairs(item.components.leader.followers) do
                table.insert(followers, follower)
            end
        end
        return false
    end)

    for _, follower in pairs(followers) do
        if follower.Physics then
            follower.Physics:Teleport(x, 0, z + 1)
        else
            follower.Transform:SetPosition(x, 0, z + 1)
        end
    end
    TaXueSay("折越成功！")
end

---击杀结算
---@param player Taxue
---@param target entityPrefab
function patchLib.TaxueOnKilled(player, target)
    local has_save = false --是否保存
    local showBanner = TaxuePatch.cfg("displaySetting.showBanner") and TaxuePatch.dyc and TaxuePatch.dyc.bannerSystem
    local BANNER_COLOR = TaxuePatch.RGBAColor(TaxuePatch.cfg("displaySetting.showBanner.bannerColor"))
    local bannerColor = showBanner and TaxuePatch.dyc.RGBAColor(BANNER_COLOR:Get())
    --#region 是boss
    local IsBoss = false
    local bossTags = {
        minotaur = true,
        moose = true,
        dragonfly = true,
        bearger = true,
        deerclops = true,
        twister = true,
        tigershark = true,
        pugalisk = true,
        antqueen = true,
        ancient = true,
    }
    IsBoss = bossTags[target.prefab] or target.prefab == "kraken"
    --#endregion

    --#region 不是小生物
    local NotSmall = not (target:HasTag("wall") or target:HasTag("bird")) --墙, 鸟
    local smallList = {
        "lureplant",                                                      --食人花
        "eyeplant",                                                       --食人花眼球
        "chester",                                                        --小切
        "bee",                                                            --蜜蜂
        "killerbee",                                                      --杀人蜂
        "tentacle_pillar_arm",                                            --小触手
        "jellyfish_planted",                                              --水母
        "rainbowjellyfish_planted",                                       --彩虹水母
        "butterfly",                                                      --蝴蝶
        "bramblespike",                                                   --荆棘
        "mosquito",                                                       --蚊子
        "mosquito_poison",                                                --毒蚊子
        "glowfly",                                                        --格罗姆
        "pig_ruins_spear_trap",                                           --遗迹尖刺陷阱
    }
    NotSmall = NotSmall and not table.contains(smallList, target.prefab)
    --#endregion

    --不允许多倍掉落
    local IsSpecial = target.prefab == "spiderden" or target.prefab == "lureplant"

    --#region 处理经验值,战斗力,魅力值
    local exp
    local combat
    local charm
    --击杀boss
    if IsBoss then
        exp = math.random() * 5 + 10 + player.exp_extra            --经验值10~15
        combat = math.random() * 5 + 5                             --战斗力5~10
        charm = math.random() * 10 + 10 + player.charm_value_extra --魅力值10~20
        --击杀非小生物
    elseif NotSmall then
        exp = math.random() * 0.5 + 0.5 + player.exp_extra       --经验值0.5~1
        combat = math.random() * 0.5 + 1                         --战斗力1~1.5
        charm = math.random() * 1 + 1 + player.charm_value_extra --魅力值1~2
    end
    if IsBoss or NotSmall then
        player.exp = player.exp and player.exp + exp                                        --经验值
        player.combat_capacity = player.combat_capacity and player.combat_capacity + combat --战斗力
        player.charm_value = player.charm_value and player.charm_value + charm              --魅力值
        if showBanner then
            local bannerExp
            local dyc = TaxuePatch.dyc
            for index, banner in pairs(dyc.bannerSystem.banners) do
                if banner:HasTag("taxueGetExpBanner") then
                    bannerExp = banner
                    break
                end
            end
            if not bannerExp then
                local str = ("*经验+%.2f* *战斗力+%.2f* *魅力值+%.2f*"):format(exp, combat, charm)
                bannerExp = dyc.bannerSystem:ShowMessage(str, 5, bannerColor)
                bannerExp:AddTag("taxueGetExpBanner")
            end
            bannerExp.exp = bannerExp.exp and bannerExp.exp + exp or exp
            bannerExp.combat = bannerExp.combat and bannerExp.combat + combat or combat
            bannerExp.charm = bannerExp.charm and bannerExp.charm + charm or charm
            bannerExp:SetText(("*经验+%.2f* *战斗力+%.2f* *魅力值+%.2f*"):format(bannerExp.exp, bannerExp.combat, bannerExp.charm))
            bannerExp.bannerTimer = 5
            bannerExp:OnUpdate(0)
        else
            local str = ("*经验+%.2f*\n*战斗力+%.2f*\n魅力值+%.2f*"):format(exp, combat, charm)
            TaXueSay(str)
        end
    end
    --#endregion

    --处理惊喜之刃掉落
    if player.has_surprised_sword == false and target:HasTag("candrop_surprised_sword") and math.random() < 0.0005 then --高级惊喜掉落
        if showBanner then
            TaxuePatch.dyc.bannerSystem:ShowMessage("原来这就是惊喜！", 5, bannerColor)
        else
            TaXueSay("原来这就是惊喜！")
        end
        local item = SpawnPrefab("surprised_sword")
        item.damage = item.damage + 20
        item.components.weapon:SetDamage(item.damage)
        TaxuePrefabDrop(target, item)
        player.has_surprised_sword = true
        has_save = true
    end

    --变异撬锁蜘蛛
    if target:HasTag("spider") then
        if math.random() <= 0.01 then
            SpawnPrefab("collapse_small").Transform:SetPosition(player.Transform:GetWorldPosition())           --生成摧毁动画
            SpawnPrefab("taxue_spider_dropper_key").Transform:SetPosition(target.Transform:GetWorldPosition()) --生成钥匙蜘蛛
        end
    end

    --处理多倍战利品和装备掉落	
    if target.components.lootdropper and not IsSpecial then
        local dorpList = {}
        local lootdropper = target.components.lootdropper
        local package
        if TaxuePatch.cfg("taxueFix.betterDrop") then
            package = patchLib.GetNearestPackageMachine(target)
        end
        --处理赌狗
        if player.gamble_multiple > 0 then
            has_save = true
            if math.random() < 0.1 then
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("赌狗成功! 额外" .. player.gamble_multiple .. "倍掉落", 5, bannerColor)
                else
                    player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
                end
                patchLib.AddLootsToList(lootdropper, dorpList, player.gamble_multiple)
            else
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("赌狗失败!", 5, bannerColor)
                end
                lootdropper:SetChanceLootTable()
                lootdropper:SetLoot({ "poop", "poop", "poop", "poop", "poop", "poop", "poop", "poop", "poop", "poop" })
            end
            player.gamble_multiple = 0
            player.has_ticket = false
        end
        --处理战利品券
        if player.loot_multiple > 0 then --触发战利品券
            has_save = true
            if showBanner then
                TaxuePatch.dyc.bannerSystem:ShowMessage("触发战利品券! 额外" .. player.loot_multiple .. "倍掉落", 5, bannerColor)
            else
                player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
            end
            patchLib.AddLootsToList(lootdropper, dorpList, player.loot_multiple)
            player.loot_multiple = 0
            player.has_ticket = false
        end
        --处理掉包券
        if player.substitute_item ~= "" then
            has_save = true
            if showBanner then
                TaxuePatch.dyc.bannerSystem:ShowMessage("触发掉包券! 掉包物品: " .. TaxueToChs(player.substitute_item), 5, bannerColor)
            else
                player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
            end
            local item_list = lootdropper:GenerateLoot()       --战利品表
            local loot_list = {}
            for _ = 1, #item_list do
                table.insert(loot_list, player.substitute_item)
            end
            lootdropper:SetChanceLootTable()
            lootdropper:SetLoot(loot_list)
            player.substitute_item = ""
            player.has_ticket = false
        end
        --处理脸黑值,概率为0~0.2
        if player.faceblack > 0 and math.random() <= player.faceblack then
            patchLib.AddLootsToList(lootdropper, dorpList)
            if showBanner then
                local bannerFaceBlack
                local dyc = TaxuePatch.dyc
                for index, banner in pairs(dyc.bannerSystem.banners) do
                    if banner:HasTag("taxueFaceBlackDropBanner") then
                        bannerFaceBlack = banner
                        break
                    end
                end
                if not bannerFaceBlack then
                    bannerFaceBlack = dyc.bannerSystem:ShowMessage("脸黑奖触发双爆!", 5, bannerColor)
                    bannerFaceBlack:AddTag("taxueFaceBlackDropBanner")
                    bannerFaceBlack.times = 1
                else
                    bannerFaceBlack.times = bannerFaceBlack.times + 1
                    bannerFaceBlack:SetText(("脸黑奖触发双爆 X%d !"):format(bannerFaceBlack.times))
                    bannerFaceBlack.bannerTimer = 5
                    bannerFaceBlack:OnUpdate(0)
                end
            end
            player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
            -- print("触发脸黑奖掉落")
            --超级掉落
            if math.random() <= 0.005 then                     --拥有奖杯则0.5%触发总概率1/3(向下取整)的数量掉落			
                patchLib.AddLootsToList(lootdropper, dorpList, math.floor((player.faceblack * 100) / 3))
                player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("哇！欧气爆炸！！！" .. math.floor((player.faceblack * 100) / 3) .. " 倍多爆！", 5, bannerColor)
                else
                    TaXueSay("哇！欧气爆炸！！！")
                end
                TaxueFx(player, "metal_hulk_ring_fx")
                -- print("触发超级掉落")
            end
        end
        -------------------------------------------------
        if math.random() <= 0.01 then                      --默认1%概率双倍战利品
            player.SoundEmitter:PlaySound("drop/sfx/drop") --播放掉落音效
            patchLib.AddLootsToList(lootdropper, dorpList)
            -- print("双倍掉落")
        end
        ----------------------------------------------------
        if NotSmall then
            --#region 处理黄金戒指
            if player.golden > 0 and math.random() <= player.golden then
                dorpList["golden_poop"] = dorpList["golden_poop"] and dorpList["golden_poop"] + 1 or 1
            end
            --#endregion

            --#region 处理撬锁器
            local key_1 = {
                "corkchest_key",     --软木桶钥匙
                "treasurechest_key", --木箱钥匙
                "skullchest_key",    --骨钥匙
            }
            local key_2 = {
                "pandoraschest_key", --精致钥匙
                "minotaurchest_key", --豪华钥匙
            }
            if player.lockpick_chance > 0 and math.random() <= player.lockpick_chance then
                local key = key_1[math.random(#key_1)]
                dorpList[key] = dorpList[key] and dorpList[key] + 1 or 1
            end
            if player.lockpick_chance > 0 and math.random() <= player.lockpick_chance / 10 then
                local key = key_2[math.random(#key_2)]
                dorpList[key] = dorpList[key] and dorpList[key] + 1 or 1
            end
            --#endregion

            --#region 处理魔法海螺
            if player.variation_chance > 0 and math.random() <= player.variation_chance and target.prefab ~= "taxue_spider_dropper_red" then
                SpawnPrefab("collapse_small").Transform:SetPosition(player.Transform:GetWorldPosition())           --生成摧毁动画
                SpawnPrefab("taxue_spider_dropper_red").Transform:SetPosition(target.Transform:GetWorldPosition()) --生成吸血蜘蛛
            end
            --#endregion

            --#region 处理窃贼手套
            if player.thieves_chance > 0 then
                local num = math.floor(player.thieves_chance) --大于1的数量
                if math.random() < (player.thieves_chance - num) then
                    num = num + 1
                end
                dorpList["taxue_coin_silver"] = dorpList["taxue_coin_silver"] and dorpList["taxue_coin_silver"] + num or num
            end
            --#endregion

            --#region 处理波板糖
            local egg_1 = {
                "taxue_egg_nomal", --普通蛋
            }
            local egg_2 = {
                "taxue_egg_doydoy",                                                       --嘟嘟鸟蛋
                "taxue_egg_tallbird",                                                     --高鸟蛋
                "taxue_egg_taxue",                                                        --煤炭蛋
                "taxue_egg_wave",                                                         --波浪蛋
                "taxue_egg_star",                                                         --星斑蛋
                "taxue_egg_grassland",                                                    --绿茵蛋
                "taxue_egg_whiteblue",                                                    --白蓝蛋
                "taxue_egg_eddy",                                                         --漩涡蛋
                "taxue_egg_tigershark",                                                   --虎纹蛋
                "taxue_egg_hatch",                                                        --哈奇蛋
                "taxue_egg_rainbow",                                                      --彩虹蛋
                "taxue_egg_lava",                                                         --熔岩蛋
                "taxue_egg_decorate",                                                     --装饰蛋
                "taxue_egg_ancient",                                                      --远古蛋
                "taxue_egg_skin",                                                         --装饰皮肤蛋
                "taxue_egg_ampullaria_gigas",                                             --福寿蛋
            }
            if player.lollipop_chance > 0 and math.random() < player.lollipop_chance then --掉落蛋
                local num = math.random()
                local egg = "taxue_egg_nomal"
                if num < 0.005 then
                    egg = "taxue_egg_lollipop_rare"
                elseif num < 0.06 then
                    egg = "taxue_egg_lollipop"
                elseif num < 0.16 then
                    egg = egg_2[math.random(#egg_2)]
                end
                dorpList[egg] = dorpList[egg] and dorpList[egg] + 1 or 1
            end
            --#endregion

            --#region 处理精致风车
            if player.colourful_windmill_chance > 0 and math.random() < player.colourful_windmill_chance then
                local list1 = {
                    "taxue_coin",           --梅币
                    "taxue_coin",           --梅币
                    "taxue_coin",           --梅币
                    "gray_windmill",        --灰色风车
                    "treasure_map_nomal",   --藏宝图
                    "treasure_map_monster", --怪物藏宝图
                    "raffle_ticket",        --普通抽奖券
                }
                local list2 = {
                    "taxue_diamond",          --钻石
                    "gray_windmill",          --灰色风车
                    "treasure_map_advanced",  --高级藏宝图
                    "raffle_ticket_advanced", --高级抽奖券
                }
                local list3 = {
                    "random_gem",                   --随机宝石
                    "reset_gem",                    --重置宝石
                    "interest_ticket",              --利息券
                    "loot_ticket",                  --战利品券
                    "gamble_ticket",                --赌狗券
                    "substitute_ticket_random",     --随机掉包券
                    "shop_refresh_ticket_directed", --商店定向刷新券
                    "shop_refresh_ticket_rare",     --商店稀有物品刷新券
                }
                local num = math.random()
                local item
                if num < 0.005 then
                    item = list3[math.random(#list3)]
                elseif num < 0.16 then
                    item = list2[math.random(#list2)]
                else
                    item = list1[math.random(#list1)]
                end
                dorpList[item] = dorpList[item] and dorpList[item] + 1 or 1
            end
            --#endregion
        end
        --#region  处理灌铅骰子
        --print("处理灌铅骰子",inst.loaded_dice_chance)
        if player.loaded_dice_chance > 0 and math.random() < player.loaded_dice_chance then --触发包裹掉落
            local monster_item_list = {}
            if lootdropper then
                monster_item_list = lootdropper:GenerateLoot() --战利品表
                for i = #monster_item_list, 1, -1 do           --这里把非物品栏物品剔除（注：用table库这种方式剔除一定要倒着干，不然无法全部删除）
                    local item = SpawnPrefab(monster_item_list[i])
                    if item then
                        if not item.components.inventoryitem then
                            table.remove(monster_item_list, i) --用nil置空元素不前移，影响我判断数组长度，还是用库方法
                        end
                        item:Remove()
                    end
                end
                -- for __, v in ipairs(monster_item_list) do
                --     print("表物品：",STRINGS.NAMES[string.upper(v)])
                -- end
            end
            local packageName, min, max
            if math.random() < 0.8 then
                packageName = "loaded_package"
                min, max = 2, 8
            else
                packageName = "loaded_package_luxury"
                min, max = 8, 20
            end
            local loadedPackage = SpawnPrefab(packageName)
            for _ = 1, math.random(min, max) do
                if #monster_item_list > 0 then
                    table.insert(loadedPackage.loaded_item_list, monster_item_list[math.random(#monster_item_list)])
                else
                    table.insert(loadedPackage.loaded_item_list, "taxue_coin_silver") --防空表
                end
            end
            if package then
                superPackageLib.AddItemToSuperPackage(package, loadedPackage)
            else
                TaxuePrefabDrop(target, loadedPackage, 1)
            end
        end
        --#endregion

        patchLib.StackDrops(target, dorpList, package)

        if has_save then
            GetPlayer().components.autosaver:DoSave()
        end
    end
end

---格式化数字
---@param number number
---@param formatStr? string
---@return string
function patchLib.FormatNumber(number, formatStr)
    local number = tonumber(number)
    local a = math.floor(number)
    local b = number - a + 0.00000001
    local numberStr = string.reverse(tostring(a))
    local str = {}
    local length = string.len(tostring(a))
    for i = 1, length do
        table.insert(str, string.sub(numberStr, i, i))
        if i % 3 == 0 and i < length then
            table.insert(str, ",")
        end
    end
    if not formatStr then
        formatStr = "%.f"
        if b >= 0.01 then
            local c = math.floor(b * 10) / 10
            if b - c < 0.01 then
                formatStr = "%.1f"
            else
                formatStr = "%.2f"
            end
        end
    end
    return string.reverse(table.concat(str)) .. string.sub(string.format(formatStr, b), 2)
end

---格式化梅币
---@param amount number
---@param force? boolean
---@return string
function patchLib.FormatCoins(amount, force)
    local amount100 = math.floor(amount / 100)
    if force or amount <= amount100 * 100 or amount100 >= 10 then
        return patchLib.FormatNumber(amount / 100) .. "梅币"
    else
        return patchLib.FormatNumber(amount) .. "银梅币"
    end
end

---计算踏雪等级
---@param player Taxue
---@return integer level
function patchLib.GetTaxueLevel(player)
    local d, one, exp = player.EXP_PER, player.EXP_ONE, player.exp
    local b = 0.5 * d - one
    local level = (math.sqrt(b * b - 2 * d * exp) + b) / d
    return math.floor(level)
end

---计算当前等级经验和当前等级升级经验
---@param player Taxue
---@return number currentLevelExp
---@return number currentNeed
function patchLib.GetTaxueExp(player)
    local d, one, exp, level = player.EXP_PER, player.EXP_ONE, player.exp, player.level
    local currentNeed = one + level * d
    local currentLevelExp = exp - (one + (one + d * (level - 1))) * level / 2
    return currentLevelExp, currentNeed
end

---获取美味称号
---@param player Taxue
---@return string
function patchLib.GetDeliciousStr(player)
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
function patchLib.GetBankStr(player)
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
---@return string
function patchLib.GetFortuneStr(player)
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
    for _, entry in pairs(fortune_list) do
        if player.badluck_num >= entry.value then
            return entry.str
        end
    end
    return "比煤老板还煤"
end

local function compare(a, b, up)
    up = up or true
    if a ~= b then
        if a == nil then return not up end
        if b == nil then return up end
        if up then
            return a > b
        else
            return a < b
        end
    end
    return false
end

---物品排序比较方法
---@param item1 entityPrefab
---@param item2 entityPrefab
---@return boolean
function patchLib.TaxueSortItem(item1, item2)
    assert(item1 and item2 and item1.prefab == item2.prefab)
    local key = TaxuePatch.SortValueMap[item1.prefab]
    if key then
        return item1[key] > item2[key]
    end
    if item1:HasTag("taxue_equipment_all") then
        return item1.equip_value > item2.equip_value
    elseif item1.components.weapon and item1.components.weapon.damage ~= item2.components.weapon.damage then
        return item1.components.weapon.damage > item2.components.weapon.damage
    elseif item1.components.armor then
        if item1.components.armor.absorb_percent ~= item2.components.armor.absorb_percent then
            return compare(item1.components.armor.absorb_percent, item2.components.armor.absorb_percent)
        elseif item1.components.armor.maxcondition ~= item2.components.armor.maxcondition then
            return compare(item1.components.armor.maxcondition, item2.components.armor.maxcondition)
        elseif item1.components.armor.condition ~= item2.components.armor.condition then
            return compare(item1.components.armor.condition, item2.components.armor.condition)
        end
    elseif item1.taxue_coin_value then
        if not item2.taxue_coin_value then return true end
        return item1.taxue_coin_value > item2.taxue_coin_value
    end
    return false
end

---排序格子
---@param slots entityPrefab[]
function patchLib.TaxueSortSlots(slots)
    local itemOders = {}
    local allItems = {}
    for i, item in pairs(slots) do
        if item then
            if not table.contains(itemOders, item.prefab) then
                table.insert(itemOders, item.prefab)
            end
            allItems[item.prefab] = allItems[item.prefab] or {}
            local itemList = allItems[item.prefab]
            if item.components.stackable then
                local preItem = itemList[#itemList]
                if preItem and preItem.components.stackable and not preItem.components.stackable:IsFull() then
                    item = preItem.components.stackable:Put(item)
                end
            end
            if item then table.insert(itemList, item) end
            slots[i] = nil
        end
    end
    for _, key in pairs(itemOders) do
        table.sort(allItems[key], patchLib.TaxueSortItem)
        for name, item in pairs(allItems[key]) do
            table.insert(slots, item)
        end
    end
end

---排序打开的物品栏
---@param inst entityPrefab
---@param backpack? boolean
function patchLib.TaxueSortContainer(inst, backpack)
    local inventory = inst.components.inventory
    local has
    for container, _ in pairs(inventory.opencontainers) do
        local isequipped = container.components.equippable and container.components.equippable.isequipped
        if not isequipped or (backpack and isequipped) then
            has = true
            patchLib.TaxueSortSlots(container.components.container.slots)
            container.components.container:Close(inst)
            container.components.container:Open(inst)
        end
    end
    if has then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/open")
        TaXueSay("整理成功！")
    else
        TaXueSay("你在乱按什么？")
    end
end

---一键入箱方法
---@param inst entityPrefab 箱子
---@param items Item[] 物品
---@return boolean has
function patchLib.IntoChest(inst, items)
    local container = inst.components.container
    if not container then return end
    local itemList = {}
    for index, item in pairs(container.slots) do
        itemList[item.prefab] = item
    end
    if not items then items = patchLib.GetAllInventoryItems() end
    local function get(item)
        local owner = item.components.inventoryitem.owner
        if owner then
            if owner == GetPlayer() then
                return owner.components.inventory:RemoveItem(item, true)
            else
                return owner.components.container:RemoveItem(item, true)
            end
        end
        return item
    end
    local function testFn(item)
        local blackList = {
        }
        local blackTags = {
            taxue_hats_advanced = true,
            taxue_armor_advanced = true,
            taxue_ultimate_weapon = true,
        }
        local result = not blackList[item.prefab]
        for tag, _ in pairs(blackTags) do
            if item:HasTag(tag) then return false end
        end
        return result
    end
    local has
    for i, item in pairs(items) do
        if itemList[item.prefab] and testFn(item) and container:CanTakeItemInSlot(item) then
            local itemPos = Vector3(TheSim:GetScreenPos(item.Transform:GetWorldPosition()))
            if not container:IsFull() then
                container:GiveItem(get(item), nil, itemPos)
                items[i] = nil
                has = true
            elseif container.acceptsstacks and item.components.stackable then
                for slot, itemInChest in pairs(container.slots) do
                    if itemInChest and itemInChest.prefab == item.prefab and not itemInChest.components.stackable:IsFull() then
                        has = true
                        if not itemInChest.components.stackable:Put(get(item), itemPos) then break end
                    end
                end
                if item and item:IsValid() and item.prevcontainer then
                    item.prevcontainer:GiveItem(item, item.prevslot)
                else
                    items[i] = nil
                end
            end
        end
    end
    if has then TaxueFx(inst, "statue_transition_2", nil, { 218, 112, 214 }) end
    return has
end

---一键入箱按键方法
function patchLib.TaxueIntoChestKey()
    local player = GetPlayer()
    local items, chests = {}, {}
    local function testChest(inst)
        if not inst.components.container.canbeopened then return false end
        local blackList = {
            gorgeous_pickup_bag = true,
        }
        local blackTags = {
            taxue_locked_chest = true,
        }
        local whiteList, whiteTags
        local result = true
        for name, _ in pairs(TaxuePatch.IntoChestBlackList) do
            blackList[name] = true
        end
        if TaxuePatch.cfg("taxueFix.intoChest.disableVanillaChest") then blackList["treasurechest"] = true end
        if not TaxuePatch.cfg("taxueFix.intoChest.allowOtherChest") then
            whiteList = {
                taxue_icebox = true,
                taxue_sell_pavilion = true,
                taxue_portable_sell_pavilion = true,
                taxue_seeds_machine = true,
                taxue_batchdismantle_machine = true,
                taxue_panda_food_machine = true,
            }
            whiteTags = {
                taxue_chest = true,
                taxue_bag = true,
            }
            for name, _ in pairs(TaxuePatch.IntoChestWhiteList) do
                whiteList[name] = true
            end
            if TaxuePatch.cfg("taxueFix.intoChest.allowPortablecellar") then whiteList["portablecellar"] = true end
            result = whiteList[inst.prefab]
            for tag, _ in pairs(whiteTags) do
                if inst:HasTag(tag) then result = true end
            end
        end
        result = result and not blackList[inst.prefab]
        for tag, _ in pairs(blackTags) do
            if inst:HasTag(tag) then return false end
        end
        if inst.prefab == "gorgeous_bag" then --处理华丽便携箱含有定位三角就不入箱
            for _, item in pairs(inst.components.container.slots) do
                if item and item.prefab == "location_triangle" then
                    return false
                end
            end
        end
        return result
    end
    for _, item in pairs(patchLib.GetAllInventoryItems()) do
        if item.components.container and testChest(item) then
            table.insert(chests, item)
        else
            table.insert(items, item)
        end
    end
    for _, ent in pairs(patchLib.GetNearByEntities(player, 20)) do
        if ent.components then
            if ent.components.inventoryitem then
                table.insert(items, ent)
            elseif ent.components.container and testChest(ent) then
                table.insert(chests, ent)
            end
        end
    end
    for _, chest in pairs(chests) do
        patchLib.IntoChest(chest, items)
    end
end

for key, value in pairs(patchLib) do
    TaxuePatch[key] = value
end
