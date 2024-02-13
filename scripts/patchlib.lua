local Image = require "widgets/image"

ItemTypeMap = {
    book1 = {
        "book_rocky",     --石虾
        "book_pigman",    --猪人
        "book_bunnyman",  --兔人
        "book_krampus",   --坎普斯
        "book_tentacles", --触手
        "book_birds",
        "book_meteor",
        "book_sleep",
        "book_brimstone"
    },
    book2 = {
        "book_minotaur",          --犀牛
        "book_deerclops",         --巨鹿
        "book_moose",             --鸭子
        "book_dragonfly",         --龙蝇
        "book_bearger",           --熊大
        "book_spiderqueen",       --蜘蛛女王
        "book_leif",              --树精
        "book_touch_leif",        --点树成精
        "book_touch_spiderqueen", --点蛛成精
        "book_animal_breed",      --生物繁殖书
        "book_grow_spiderden",    --蜘蛛生长
    },
    book3 = {
        "book_clear",           --清理书
        "book_harvest",         --收获书
        "book_pickup",          --拾取书
        "book_seeder",          --播种书
        "book_hatch",           --孵化书
        "book_gardening",       --应用园艺学
        "book_incubate",        --应用孵化学
        "book_pisciculture",    --应用渔业学
        "book_pigman_golden",   --猪人点金
        "book_bunnyman_golden", --兔人点金
        "book_golden_rocky",    --黄金石虾
        "book_touch_golden",    --点怪成金书
        "book_seeder_golden",   --黄金播种书
    },
    golden_food = TaxueList.golden_food,
    gem = {
        "redgem",        --红
        "bluegem",       --蓝
        "purplegem",     --紫
        "greengem",      --绿
        "orangegem",     --橙
        "yellowgem",     --黄
        "pink_gem",      --粉宝石
        "cyan_gem",      --青宝石
        "white_gem",     --白宝石
        "black_gem",     --黑宝石
        "taxue_diamond", --钻石

        "random_gem",    --随机宝石
        "promote_gem",   --提升宝石
        "reset_gem",     --重置宝石
        "colorful_gem",  --五彩宝石
        "copy_gem",      --复制宝石
    },
    equipment = TaxueList.equipment,
    my_ticket = TaxueList.my_ticket,
    egg_all = {
        "taxue_egg_nomal",
        "taxue_egg_moose",
        "taxue_egg_doydoy",
        "taxue_egg_tallbird",
        "taxue_egg_colourful",
        "taxue_egg_golden",
        "taxue_egg_sakura",
        "taxue_egg_lacy",
        "taxue_egg_taxue",
        "taxue_egg_totoro",
        "taxue_egg_spotty",
        "taxue_egg_wave",
        "taxue_egg_star",
        "taxue_egg_grassland",
        "taxue_egg_lightning",
        "taxue_egg_whiteblue",
        "taxue_egg_strawberry",
        "taxue_egg_pineapple",
        "taxue_egg_lollipop",
        "taxue_egg_starrysky",
        "taxue_egg_tigershark",
        "taxue_egg_charm",
        "taxue_egg_eddy",
        "taxue_egg_txxm",
        "taxue_egg_hatch",
        "taxue_egg_delicious",
        "taxue_egg_porcelain",
        "taxue_egg_rainbow",
        "taxue_egg_lava",
        "taxue_egg_decorate",
        "taxue_egg_harvest",
        "taxue_egg_lollipop_rare",
        "taxue_egg_ancient",
        "taxue_egg_skin",
        "taxue_egg_melon",
        "taxue_egg_rock",
        "taxue_egg_meteor",
        "taxue_egg_millionclub",
        "taxue_egg_rose",
        "taxue_egg_ampullaria_gigas",
        "taxue_egg_free",
    },
    treasure_map = TaxueList.treasure_map,
    weapon1 = TaxueList.weapon,
    weapon2 = TaxueList.weapon2,
    armor1 = TaxueList.armor,
    armor2 = TaxueList.armor_2,
    key = {

        "corkchest_key",     --软木桶钥匙
        "treasurechest_key", --木箱钥匙
        "skullchest_key",    --骨钥匙
        "pandoraschest_key", --精致钥匙
        "minotaurchest_key", --豪华钥匙
        "terrarium_key",     --恐怖钥匙
        "poison_key",        --剧毒钥匙
    },
    agentia_all = {
        "exp_agentia",             --经验药剂-蓝
        "health_agentia",          --血量药剂-红
        "sanity_agentia",          --san值药剂-绿
        "ice_agentia",             --寒冰药剂
        "hot_agentia",             --炎热药剂
        "map_agentia",             --开心
        "treasure_agentia",        --寻宝
        "totoro_agentia",          --龙猫
        "transfer_agentia",        --随机传送
        "light_agentia",           --发光药剂

        "antivenom_agentia",       --解毒药剂
        "sleep_agentia",           --催眠药水
        "invisible_agentia",       --隐形药水
        "taxue_milk",              --牛奶

        "golden_agentia_pigman",   --点金猪人
        "golden_agentia_bunnyman", --点金兔人
        "scared_agentia",          --恐惧药剂
        "mocking_agentia",         --嘲讽药剂
        "awake_agentia",           --唤醒药剂
        "lessen_agentia",          --缩小药剂
        "paralytic_agentia",       --麻痹药剂
        "bleed_agentia",           --流血药剂
        "weak_agentia",            --虚弱药剂
        "rage_agentia",            --狂暴药剂
        "illegal_cooking_oil",     --地沟油
        "bramble_agentia",         --荆棘药剂
        "bloodsucking_agentia",    --嗜血药剂
    },
    essence = {
        "plant_essence",         --植物精华
        "sea_essence",           --海洋精华
        "volcano_essence",       --火山精华
        "threecolor_essence",    --三色精华
        "delicious_essence",     --美味精华
        "roe_essence",           --鱼籽精华
        "pearl_essence",         --珍珠精华
        "spiderhat_essence",     --蜘蛛帽精华
        "mineral_essence",       --矿石精华
        "mushroom_essence",      --蘑菇精华
        "ice_essence",           --寒冰精华
        "return_fresh_essence",  --反鲜精华
        "free_essence",          --白嫖精华
        "free_essence_advanced", --高级白嫖精华
        "chest_essence",         --宝箱精华
        "chest_essence_nomal"    --稀有宝箱精华
    },
    special = {
        "perpetual_core",     --永动机核心
        "crystal_ball_taxue", --水晶煤球
        "random_agentia",     --随机药剂
        "chest_agentia",      --宝箱药剂
    },
}

ItemTypeNameMap = {
    book1 = "低级书",
    book2 = "高级书",
    book3 = "功能书",
    golden_food = "黄金食物",
    gem = "宝石",
    equipmentHigh = "高属性五彩装备",
    equipmentLow = "低属性五彩装备",
    my_ticket = "劵类",
    egg_all = "孵化蛋",
    treasure_map = "藏宝图",
    weapon1 = "低级武器",
    weapon2 = "高级武器",
    armor1 = "低级装备",
    armor2 = "高级装备",
    key = "钥匙",
    agentia_all = "药水",
    essence = "精华",
    special = "特殊",
    others = "其他"
}

ItemDataMap = {
    refreshticket_ticket = "refresh_num",          --刷券券
    loot_ticket = "loot_multiple",                 --战利品券
    book_touch_leif = "leif_num",                  --点树成精
    book_touch_spiderqueen = "spiderqueen_num",    --点蛛成精
    book_touch_golden = "golden_num",              --点怪成金
    gamble_ticket = "gamble_multiple",             --赌狗劵
    substitute_ticket = "substitute_item",         --掉包券
    shop_refresh_ticket_directed = "refresh_item", --定向商店刷新券
    interest_ticket = "interest"                   --利息券
}

DataStrMap = {
    refreshticket_ticket = "可刷新数量：%s个", --刷券券
    loot_ticket = "额外掉落：%s倍", --战利品券
    book_touch_leif = "树精数量: %s只", --点树成精
    book_touch_spiderqueen = "蜘蛛女王数量: %s只", --点蛛成精
    book_touch_golden = "点金数量: %s只", --点怪成金
    gamble_ticket = "额外掉落: %s倍", --赌狗劵
    substitute_ticket = "掉包物品: %s", --掉包券
    shop_refresh_ticket_directed = "刷新物品: %s", --定向商店刷新券
    interest_ticket = "利息上限: %s梅币" --利息券
}

local cfg = TaxuePatch.cfg

---count table
---@param table table
---@return integer
TableCount = function(table)
    local count = 0
    for _, _ in pairs(table) do count = count + 1 end
    return count
end
table.TableCount = TableCount

---给列表key对应的值加value
---@param List table
---@param key any
---@param value any
ListAdd = function(List, key, value)
    value = value or 1
    List[key] = List[key] and List[key] + value or value
end

---测试物品是否符合条件
---@param item entityPrefab
---@param test string|string[]|fun(item:entityPrefab):boolean
---@return boolean
function TestItem(item, test)
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
function FindItem(slots, itemTest)
    if not slots then return nil, nil end
    for slot, item in pairs(slots) do
        if TestItem(item, itemTest) then
            return item, slot
        end
    end
end

---查找周围实体
---@param inst entityPrefab
---@param radius number
---@param testFn? string|fun(entity: entityPrefab):boolean
---@param tags? string[]
---@param notags? string[]
---@return entityPrefab[]|table[]
function GetNearByEntities(inst, radius, testFn, tags, notags)
    if not inst or not inst:IsValid() then return {} end
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local notags = notags or { "INLIMBO", "NOCLICK", "catchable", "fire", "player" }
    local list = {}
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, radius, tags, notags)
    for _, entity in pairs(ents) do
        if entity ~= inst and entity:IsValid() then
            local testResult = true
            if type(testFn) == "string" then
                testResult = entity.prefab == testFn
            elseif type(testFn) == "function" then
                testResult = testFn(entity)
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
function GetChanceResult(chance, times)
    local result = 0
    for _ = 1, times do
        if math.random() < chance then
            result = result + 1
        end
    end
    return result
end

TaxuePatch.GetChanceResult = GetChanceResult

local function giveItem(inst, item)
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
---@param inst entityPrefab
---@param itemList table<string, integer>
function GiveItems(inst, itemList)
    for name, amount in pairs(itemList) do
        local item = SpawnPrefab(name)
        if item.components and item.components.stackable then
            item.components.stackable.stacksize = amount
            giveItem(inst, item)
        else
            item:Remove()
            for _ = 1, amount do
                giveItem(inst, SpawnPrefab(name))
            end
        end
    end
end

local function getStackedItem(name, amount, maxsize)
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

local function addToList(list, entity, number, data)
    local amount = 1
    local name = entity
    if type(entity) == "string" then
        amount = number or 1
    else
        name = entity.prefab
        amount = entity.components.stackable and entity.components.stackable.stacksize or 1
    end
    if type(entity) == "string" or entity.components.stackable then
        list[name] = list[name] and list[name] + amount or amount
    else
        list[name] = list[name] or {}
        local listItem = list[name]
        if data then
            list[name][data] = list[name][data] or {}
            listItem = list[name][data]
        end
        local saveData = entity:GetSaveRecord()
        table.insert(listItem, saveData)
    end
end

local function processPackageData(package, itemType, itemName, amount, value, data)
    package.amount = package.amount or 0
    package.amount = amount and package.amount + amount or package.amount

    package.amountMap = package.amountMap or {}
    package.amountMap[itemType] = package.amountMap[itemType] or { amount = 0, sub = {} }
    local aIndex = package.amountMap[itemType]
    aIndex.amount = amount and aIndex.amount + amount or aIndex.amount

    if package.hasValue == nil then package.hasValue = true end
    package.hasValue = package.hasValue and (value ~= nil)
    if package.hasValue then
        package.taxue_coin_value = package.taxue_coin_value and package.taxue_coin_value + value or value
    else
        package.taxue_coin_value = nil
    end

    package.valueMap = package.valueMap or {}
    package.valueMap[itemType] = package.valueMap[itemType] or { hasValue = true, value = 0, sub = {} }
    local vIndex = package.valueMap[itemType]
    vIndex.hasValue = vIndex.hasValue and (value ~= nil)
    vIndex.value = value and vIndex.value + value or vIndex.value

    for _, i in pairs({ itemName, data }) do
        if i then
            aIndex.sub = aIndex.sub or {}
            aIndex.sub[i] = aIndex.sub[i] or { amount = 0 }
            aIndex = aIndex.sub[i]

            aIndex.amount = amount and aIndex.amount + amount or aIndex.amount

            vIndex.sub = vIndex.sub or {}
            vIndex.sub[i] = vIndex.sub[i] or { hasValue = true, value = 0 }
            vIndex = vIndex.sub[i]

            vIndex.hasValue = vIndex.hasValue and (value ~= nil)
            vIndex.value = value and vIndex.value + value or vIndex.value
        end
    end
end

---@class package:entityPrefab
---@field isPatched boolean
---@field type string
---@field amount integer
---@field amountMap table
---@field hasValue boolean
---@field valueMap table
---@field item_list table<string, table>

---spawn a super package
---@param name? string package display name
---@param type? string|nil package type
---@return package package
function SpawnPackage(name, type)
    local package = SpawnPrefab("super_package")
    package.isPatched = true
    package.name = name or package.name
    package.type = type
    package.amount = 0
    package.amountMap = {}
    package.hasValue = true
    package.valueMap = {}
    return package
end

---检查包裹类型
---@param package package
function CheckPackageType(package)
    if TableCount(package.item_list) == 1 then
        local type, _ = next(package.item_list)
        package.name = ItemTypeNameMap[type]
        package.type = type
    else
        package.type = nil
        package.name = TaxueToChs(package.prefab)
    end
end

---transform package to patched package
---@param package package
---@return package newPackage
function TransformPackage(package)
    local slots = package.components.container.slots
    local newPackage = SpawnPackage()
    for _, v in pairs(slots) do
        AddItemToSuperPackage(newPackage, v)
    end
    for k, v in pairs(package.item_list) do
        if type(v) == "table" then
            for name, items in pairs(v) do
                if type(items) == "number" then
                    local item = SpawnPrefab(name)
                    item.components.stackable.stacksize = items
                    AddItemToSuperPackage(newPackage, item)
                else
                    for _, itemData in pairs(items) do
                        if itemData.prefab then
                            local item = SpawnSaveRecord(itemData)
                            AddItemToSuperPackage(newPackage, item)
                        else
                            for _, itemData in pairs(itemData) do
                                local item = SpawnSaveRecord(itemData)
                                AddItemToSuperPackage(newPackage, item)
                            end
                        end
                    end
                end
            end
        else
            local newItem = SpawnPrefab(k)
            newItem.components.stackable.stacksize = v
            AddItemToSuperPackage(newPackage, newItem)
        end
    end
    if TableCount(newPackage.item_list) == 1 then
        for type, _ in pairs(newPackage.item_list) do
            newPackage.type = type
        end
    end
    local owner = package.components.inventoryitem.owner
    if owner then
        newPackage.components.inventoryitem.owner = owner
        local container, slots
        if owner == GetPlayer() then
            container = owner.components.inventory
            slots = container.itemslots
        else
            container = owner.components.container
            slots = container.slots
        end
        for i, item in pairs(slots) do
            if item == package then
                container:RemoveItemBySlot(i)
                container:GiveItem(newPackage, i)
                break
            end
        end
    else
        newPackage.Transform:SetPosition(Vector3(package.Transform:GetWorldPosition()):Get())
    end
    package:Remove()
    return newPackage
end

---merge two packages into one
---@param package package
---@param packageM package
---@return package package
function MergePackage(package, packageM)
    if not package.isPatched then package = TransformPackage(package) end
    if not packageM.isPatched then packageM = TransformPackage(packageM) end
    if packageM.amount == 0 then return package end

    local item_list = package.item_list
    for itemType, list1 in pairs(packageM.item_list) do
        item_list[itemType] = item_list[itemType] or {}
        for itemName, list2 in pairs(list1) do
            if type(list2) == "table" then
                item_list[itemType][itemName] = item_list[itemType][itemName] or {}
                for data, list3 in pairs(list2) do
                    if list3.prefab then
                        table.insert(item_list[itemType][itemName], list3)
                        local value = packageM.valueMap[itemType].sub[itemName].hasValue and packageM.valueMap[itemType].sub[itemName].value / #list2 or nil
                        processPackageData(package, itemType, itemName, 1, value)
                    else
                        for _, item in pairs(list3) do
                            item_list[itemType][itemName][data] = item_list[itemType][itemName][data] or {}
                            table.insert(item_list[itemType][itemName][data], item)
                            local value = packageM.valueMap[itemType].sub[itemName].hasValue and packageM.valueMap[itemType].sub[itemName].sub[data].value / #list3 or nil
                            processPackageData(package, itemType, itemName, 1, value, data)
                        end
                    end
                end
            else
                item_list[itemType][itemName] = item_list[itemType][itemName] and item_list[itemType][itemName] + list2 or list2
                local value = packageM.valueMap[itemType].sub[itemName].hasValue and packageM.valueMap[itemType].sub[itemName].value or nil
                processPackageData(package, itemType, itemName, list2, value)
            end
        end
    end
    packageM:Remove()
    return package
end

---将物品添加到超级包裹
---@param package package
---@param entity entityPrefab|package
---@param showFx? boolean
---@param testFn? fun(ent:entityPrefab):boolean
function AddItemToSuperPackage(package, entity, showFx, testFn)
    if not entity or testFn and not testFn(entity) then return end
    --特效
    if showFx then SpawnPrefab("small_puff").Transform:SetPosition(entity.Transform:GetWorldPosition()) end
    --fx.Transform:SetScale(0.5,0.5,0.5)
    if not package.isPatched then
        package = TransformPackage(package)
        if not package then return end
    end

    local item_list = package.item_list
    if entity.prefab == "super_package" then
        MergePackage(package, entity)
        return
    end
    if entity:HasTag("loaded_package") and entity.loaded_item_list then
        local loaded_item_list = {}
        for _, name in pairs(entity.loaded_item_list) do
            loaded_item_list[name] = loaded_item_list[name] and loaded_item_list[name] + 1 or 1
        end
        AddItemsToSuperPackage(package, loaded_item_list)
        entity:Remove()
        return
    end
    local itemType
    for type, list in pairs(ItemTypeMap) do
        if table.contains(list, entity.prefab) then
            if type == "equipment" then
                local isHigh = entity.equip_value >= cfg.HIGH_EQUIPMENT_PERCENT * entity.MAX_EQUIP_VALUE
                type = isHigh and "equipmentHigh" or "equipmentLow"
            end
            itemType = type
            break
        end
    end
    itemType = itemType or "others"
    local data
    if table.containskey(ItemDataMap, entity.prefab) then
        data = entity[ItemDataMap[entity.prefab]]
    end
    item_list[itemType] = item_list[itemType] or {}
    addToList(item_list[itemType], entity, nil, data)

    local amount = entity.components.stackable and entity.components.stackable.stacksize or 1
    local coinValue = entity.taxue_coin_value and entity.taxue_coin_value * amount

    local specialValueMap = {
        taxue_coin = 100,
        taxue_coin_silver = 1,
        taxue_coin_copper = 0.01
    }

    for name, value in pairs(specialValueMap) do
        if entity.prefab == name then
            coinValue = value * amount
            break
        end
    end

    processPackageData(package, itemType, entity.prefab, amount, coinValue, data)

    entity:Remove()
end

---将表中物品添加到超级包裹中
---@param package package
---@param items table<string, integer>
---@param showFx? boolean
---@param testFn? fun(ent:entityPrefab):boolean
function AddItemsToSuperPackage(package, items, showFx, testFn)
    for name, amount in pairs(items) do
        local prefab = SpawnPrefab(name)
        if prefab and prefab.components.stackable then
            prefab.components.stackable.stacksize = amount
            AddItemToSuperPackage(package, prefab, showFx, testFn)
        elseif prefab then
            prefab:Remove()
            for _ = 1, amount do
                AddItemToSuperPackage(package, SpawnPrefab(name), showFx, testFn)
            end
        end
    end
    CheckPackageType(package)
end

---打包所有实体
---@param package package
---@param entities entityPrefab[]
---@param testFn fun(entity:entityPrefab):boolean
---@param isBook? boolean
function PackAllEntities(package, entities, testFn, isBook)
    local treasures = {}
    for _, ent in ipairs(entities) do
        if cfg.OPEN_TREASURES and ent:HasTag("taxue_treasure") and (isBook or cfg.MACHINE_TREASURES) then
            table.insert(treasures, ent)
        elseif testFn(ent) then
            AddItemToSuperPackage(package, ent, true)
        end
    end
    if next(treasures) then
        AddTreasuresToPackage(package, treasures)
    end
    CheckPackageType(package)
end

---打开超级包裹
---@param package package
function UnpackSuperPackage(package)
    if package.isPatched and package.amountMap then
        if package.amount == 0 then return end
        local item_list = package.item_list
        if not package.type then
            for itemType, list in pairs(item_list) do
                local typeName = ItemTypeNameMap[itemType]
                local newPackage = SpawnPackage()
                newPackage.name = typeName
                newPackage.type = itemType
                newPackage.amount = package.amountMap[itemType].amount
                newPackage.amountMap = newPackage.amountMap or {}
                newPackage.amountMap[itemType] = package.amountMap[itemType]
                newPackage.hasValue = package.valueMap[itemType].hasValue
                newPackage.valueMap = newPackage.valueMap or {}
                newPackage.valueMap[itemType] = package.valueMap[itemType]
                newPackage.taxue_coin_value = newPackage.hasValue and package.valueMap[itemType] and package.valueMap[itemType].value or nil
                newPackage.item_list[itemType] = list
                giveItem(package, newPackage)
            end
        else
            local list = package.item_list[package.type]
            local maxAmount = cfg.PACKAGE_MAX_AMOUNT
            local isSingle = TableCount(list) == 1
            for itemName, items in pairs(list) do
                local itemList = {}
                if type(items) == "number" then
                    local tempItem = SpawnPrefab(itemName)
                    local maxsize = tempItem.components.stackable.maxsize
                    tempItem:Remove()
                    itemList = getStackedItem(itemName, items, maxsize)
                else
                    local isSingleData = TableCount(items) == 1
                    local newPackage
                    for value, item in pairs(items) do
                        if item.prefab then
                            table.insert(itemList, SpawnSaveRecord(item))
                        elseif isSingleData or package.amountMap[package.type].amount < maxAmount then
                            for _, item_ in ipairs(item) do
                                table.insert(itemList, SpawnSaveRecord(item_))
                            end
                        elseif isSingle then
                            local packageName = TaxueToChs(itemName) .. "  " .. DataStrMap[itemName]:format(type(value) == "number" and value or TaxueToChs(value))
                            local newPackage = SpawnPackage(packageName, package.type)
                            for _, item_ in ipairs(item) do
                                AddItemToSuperPackage(newPackage, SpawnSaveRecord(item_))
                            end
                            giveItem(package, newPackage)
                        else
                            newPackage = newPackage or SpawnPackage(TaxueToChs(itemName), package.type)
                            for _, item_ in ipairs(item) do
                                AddItemToSuperPackage(newPackage, SpawnSaveRecord(item_))
                            end
                        end
                    end
                    if newPackage then giveItem(package, newPackage) end
                end
                local itemNum = #itemList
                if itemNum > maxAmount * 1.5 then
                    local packageName = TaxueToChs(itemName)
                    local packageType = package.type
                    local newPackage = SpawnPackage(packageName, packageType)
                    local i = 0
                    for _, item in ipairs(itemList) do
                        if isSingle then
                            if i >= maxAmount and itemNum - i > maxAmount / 2 then
                                giveItem(package, newPackage)
                                newPackage = SpawnPackage(packageName, packageType)
                                itemNum = itemNum - i
                                i = 0
                            end
                            i = i + 1
                        end
                        AddItemToSuperPackage(newPackage, item)
                    end
                    giveItem(package, newPackage)
                else
                    for _, item in pairs(itemList) do
                        giveItem(package, item)
                    end
                end
            end
        end
    else
        TransformPackage(package)
    end
    local owner = package.components.inventoryitem.owner
    if owner then
        if owner == GetPlayer() then
            owner.components.inventory:RemoveItem(package, true)
        else
            owner.components.container:RemoveItem(package, true)
        end
    end
    package:Remove()
end

---删除容器内物品
---@param container table
---@param itemList entityPrefab[]
function RemoveSlotsItems(container, itemList)
    for slot, _ in pairs(itemList) do
        container:RemoveItemBySlot(slot):Remove()
    end
end

---售货亭卖东西
---@param inst entityPrefab
function SellPavilionSellItems(inst)
    local container = inst.components.container
    local slots = container.slots

    local diamond = nil
    local playSound = false
    local coinList = {}
    local coins = 0
    local itemCount = 0
    local lastItem
    for slot, item in pairs(slots) do
        if item then
            itemCount = itemCount + 1
            lastItem = item
        end
        local amount = 1
        if item and item.components.stackable then
            amount = item.components.stackable.stacksize
        end
        if item and item.taxue_coin_value then
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
        elseif item and item.prefab == "taxue_coin" then
            coinList[slot] = item
        elseif item and item.prefab == "taxue_coin_silver" then
            coinList[slot] = item
        elseif item and item.prefab == "taxue_coin_copper" then
            coinList[slot] = item
        elseif item and cfg.SELL_PAVILION == "bank" and item.prefab == "taxue_diamond" then
            diamond = item
        end
    end
    if itemCount == 1 and lastItem.prefab == "gold_brick" then return end
    print("总硬币价值：", coins)
    local tempCoins = 0
    for slot, coin in pairs(coinList) do
        local amount = coin.components.stackable.stacksize
        if coin.prefab == "taxue_coin" then
            tempCoins = tempCoins + amount * 100
        elseif coin.prefab == "taxue_coin_silver" then
            tempCoins = tempCoins + amount
        elseif coin.prefab == "taxue_coin_copper" then
            tempCoins = tempCoins + amount * 0.01
        end
    end

    --如果是银行模式并且有钻石,存银行
    if diamond and coins + tempCoins > 0 then
        container:RemoveItem(diamond):Remove()
        RemoveSlotsItems(container, coinList)
        GetPlayer().bank_value = GetPlayer().bank_value + (coins + tempCoins) / 100
        playSound = true
        --如果不是禁用,并且金额大于500梅币
    elseif cfg.SELL_PAVILION and coins + tempCoins >= 50000 then
        RemoveSlotsItems(container, coinList)
        local goldBrick = SpawnPrefab("gold_brick")
        goldBrick.taxue_coin_value = coins + tempCoins
        container:GiveItem(goldBrick)
        playSound = true
        --否则,生成梅币
    else
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

---开宝藏
---@param treasures entityPrefab[]
---@return table loots
---@return table[] numbers
function OpenTreasures(treasures)
    treasures[1].SoundEmitter:PlaySound("dontstarve_DLC002/common/loot_reveal")

    local numbers = { {}, {} }

    local loots = { boneshard = 2 * #treasures }

    loots["obsidian"] = 0

    for _, treasure in pairs(treasures) do
        for i = 1, treasure.components.workable.workleft do
            if math.random() <= 0.2 then
                loots["obsidian"] = loots["obsidian"] + 1
            end
        end

        for _, entry in ipairs(LootTables[treasure.prefab]) do
            local prefab = entry[1]
            local chance = entry[2]
            if math.random() <= chance then
                loots[prefab] = loots[prefab] and loots[prefab] + 1 or 1
            end
        end

        local books = { "book_tentacles", "book_birds", "book_meteor", "book_sleep", "book_brimstone", "book_gardening",
            "book_tentacles", "book_birds", "book_meteor", "book_sleep", "book_brimstone" }                                --原版书籍
        local statues = { "ruins_statue_head", "ruins_statue_head_nogem", "ruins_statue_mage", "ruins_statue_mage_nogem" } --远古雕像
        if math.random() <= 0.1 then
            local book = books[math.random(#books)]
            loots[book] = loots[book] and loots[book] + 1 or 1
        end

        if treasure.prefab == "taxue_buriedtreasure_monster" then --怪物宝藏
            local str = treasure.advance_list[1] or "spider"
            local monster = SpawnPrefab(str)
            if monster then
                monster.Transform:SetPosition(treasure.Transform:GetWorldPosition())
            end
        else
            local chanceChest = 0
            local chanceStatue = 0
            local chest
            if treasure.prefab == "taxue_buriedtreasure" then
                chanceChest = 0.5
                chanceStatue = 0.2
                chest = "taxue_treasurechest"
            elseif treasure.prefab == "taxue_buriedtreasure_luxury" then
                chanceChest = 0.3
                chanceStatue = 0.3
                chest = "taxue_pandoraschest"
            end

            if math.random() <= chanceChest then
                numbers[2][chest] = numbers[2][chest] and numbers[2][chest] + 1 or 1
                if cfg.DESTORY_CHEST then
                    loots.boards = loots.boards and loots.boards + 1 or 1
                    for __, prefab in ipairs(treasure.advance_list) do
                        loots[prefab] = loots[prefab] and loots[prefab] + 1 or 1
                    end
                else
                    local chest = SpawnPrefab(chest)
                    for __, v in ipairs(treasure.advance_list) do
                        local item = SpawnPrefab(v)
                        if item ~= nil then
                            chest.components.container:GiveItem(item)
                        end
                    end
                    chest.Transform:SetPosition(treasure.Transform:GetWorldPosition())
                end
            elseif math.random() <= chanceStatue then
                numbers[2]["statue"] = numbers[2]["statue"] and numbers[2]["statue"] + 1 or 1
                local statue = SpawnPrefab(statues[math.random(#statues)])
                if cfg.DESTORY_STATUE then
                    local dorps = statue.components.lootdropper:GetAllLoot()
                    for _, prefab in ipairs(dorps) do
                        loots[prefab] = loots[prefab] and loots[prefab] + 1 or 1
                        statue:Remove()
                    end
                else
                    statue.Transform:SetPosition(treasure.Transform:GetWorldPosition()) --生成随机雕像
                end
            end
        end
        numbers[1][treasure.prefab] = numbers[1][treasure.prefab] and numbers[1][treasure.prefab] + 1 or 1
        treasure:Remove()
    end
    return loots, numbers
end

---开启所有宝藏并将物品添加进包裹
---@param package package
---@param treasures entityPrefab[]
function AddTreasuresToPackage(package, treasures)
    local loots, numbers = OpenTreasures(treasures)
    for name, amount in pairs(loots) do
        local prefab = SpawnPrefab(name)
        if prefab and prefab.components.stackable then
            prefab.components.stackable.stacksize = amount
            AddItemToSuperPackage(package, prefab)
        elseif prefab then
            prefab:Remove()
            for _ = 1, amount do
                AddItemToSuperPackage(package, SpawnPrefab(name))
            end
        end
    end
    local str = "这波打包了:\n"
    for _, line in pairs(numbers) do
        for name, number in pairs(line) do
            local name = name == "statue" and "雕像" or TaxueToChs(name)
            str = str .. name .. number .. "个 "
        end
        str = str .. "\n"
    end
    package:AddComponent("talker")
    package.components.talker.colour = Vector3(255 / 255, 131 / 255, 250 / 255, 1)
    package.components.talker.offset = Vector3(0, 100, 0)
    package.components.talker:Say(str, 10)
    package:RemoveComponent("talker")
end

---将掉落物添加到列表中
---@param lootDropper table
---@param dorpList table<string, integer>
---@param times? integer
function AddLootsToList(lootDropper, dorpList, times)
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
                if math.random() <= chance then
                    dorpList[prefab] = dorpList[prefab] and dorpList[prefab] + 1 or 1
                    lootDropper.droppingchanceloot = true
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
end

---堆叠掉落物
---@param target entityPrefab
---@param dorpList table<string, integer>
---@param package? package
function StackDrops(target, dorpList, package)
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
        AddItemsToSuperPackage(package, dorpList, nil, testFn)
        if next(dorpList) then TaxueFx(target, "small_puff") end
    elseif TaxuePatch.cfg.STACK_DROP then
        for name, amount in pairs(dorpList) do
            local item = SpawnPrefab(name)
            if item and item.components and item.components.stackable then
                local o = GetNearByEntities(target, 15, name)
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
            local item = SpawnPrefab(name)
            if item and item.components and item.components.stackable then
                item.components.stackable.stacksize = amount
                target.components.lootdropper:DropLootPrefab(item)
            elseif item then
                item:Remove()
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
function GetNearestPackageMachine(target)
    local player = GetPlayer()
    if player.nearestPackageMachine and player.nearestPackageMachine.switch == "on" and player.nearestPackageMachine:GetDistanceSqToInst(target) <= 2500 then
        return player.nearestPackageMachine.getPackage and player.nearestPackageMachine:getPackage()
    elseif not player.lastScanPackage or GetTime() - player.lastScanPackage > 1 then
        player.lastScanPackage = GetTime()
        local testFn = function(ent)
            return ent.prefab == "super_package_machine" and ent.switch == "on"
        end
        local packageMachines = GetNearByEntities(target, 50, testFn)
        if #packageMachines > 0 then
            player.nearestPackageMachine = packageMachines[1]
            return packageMachines[1]:getPackage()
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
function PlayItemMove(item, src, target, time)
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
function MultHarvest(crop, itemList, isBook)
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
        ListAdd(itemList, "cactus_flower")
        PlayItemMove("cactus_flower", srcPos, targetPos)

        --蘑菇
    elseif crop.inst.prefab == "plant_mushroom" then
        ListAdd(itemList, "green_cap")
        ListAdd(itemList, "blue_cap")
        PlayItemMove("green_cap", srcPos, targetPos)
        PlayItemMove("blue_cap", srcPos, targetPos)

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
                mult = math.random(2, 6)
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
                ListAdd(itemList, cloverEssence)
                PlayItemMove(cloverEssence, srcPos, targetPos)
                shoudSay = true
            end
            --处理三色四叶草
            if threecolourclover_chance and math.random() < (threecolourclover_chance / 3) then
                ListAdd(itemList, "threecolor_essence")
                PlayItemMove("threecolor_essence", srcPos, targetPos)
            end
            if shoudSay then player.components.talker:Say("我转运啦！") end
            --处理蛋蛋
            if isBook and math.random() < 0.005 then
                ListAdd(itemList, "taxue_egg_harvest")
                PlayItemMove("taxue_egg_harvest", srcPos, targetPos)
            end
        end
    end

    ListAdd(itemList, product, amount)
    PlayItemMove(product, srcPos, targetPos)

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
