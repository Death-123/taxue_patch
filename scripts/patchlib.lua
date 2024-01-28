--patch 3.76.1
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
    egg_all = TaxueList.egg_all,
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

---count table
---@param table table
---@return integer
TableCount = function(table)
    local count = 0
    for _, _ in pairs(table) do count = count + 1 end
    return count
end

local function giveItem(inst, item)
    local owner = inst.components.inventoryitem.owner
    if owner then
        local container = owner == GetPlayer() and owner.components.inventory or owner.components.container
        if container:CanTakeItemInSlot(item) then
            container:GiveItem(item)
            return
        end
    end
    local pos = Vector3(inst.Transform:GetWorldPosition())
    item.Transform:SetPosition(pos:Get())
    item.components.inventoryitem:OnDropped(true)
end

local function giveStackedItem(inst, item, amount)
    item = (type(item) == "table") and item or SpawnPrefab(item)
    if item.components.stackable then
        local maxsize = item.components.stackable.maxsize
        local size = amount or item.components.stackable.stacksize
        local stack_num = math.floor(size / maxsize)
        local surplus_num = size - maxsize * stack_num
        if stack_num > 0 then
            for i = 1, stack_num do
                local newItem = SpawnPrefab(item.prefab)
                newItem.components.stackable.stacksize = maxsize
                giveItem(inst, newItem)
            end
        end
        if surplus_num > 0 then
            local newItem = SpawnPrefab(item.prefab)
            newItem.components.stackable.stacksize = surplus_num
            giveItem(inst, newItem)
        end
        item:Remove()
    else
        giveItem(inst, item)
    end
end

local function addToList(list, entity)
    local name = entity.prefab
    if entity.components.stackable then
        local amount = entity.components.stackable.stacksize
        if list[name] then
            list[name] = list[name] + amount
        else
            list[name] = amount
        end
    else
        list[name] = list[name] or {}
        local data = entity:GetSaveRecord()
        table.insert(list[name], data)
    end
end

---merge two packages into one
---@param package table
---@param packageM table
function MergePackage(package, packageM)
    if package.hasValue == nil then
        package.hasValue = true
    end
    package.hasValue = package.hasValue and (packageM.hasValue ~= nil)
    package.taxue_coin_value = package.taxue_coin_value and packageM.taxue_coin_value and package.taxue_coin_value + packageM.taxue_coin_value or packageM.taxue_coin_value or 0
    local item_list = package.item_list
    for typeName, list in pairs(packageM.item_list) do
        item_list[typeName] = item_list[typeName] or {}
        package.valueMap = package.valueMap or {}
        package.valueMap[typeName] = package.valueMap[typeName] or { hasValue = true }
        package.valueMap[typeName].hasValue = package.valueMap[typeName].hasValue and (packageM.valueMap[typeName].hasValue ~= nil)
        package.valueMap[typeName].value = package.valueMap[typeName].value and package.valueMap[typeName].value + packageM.valueMap[typeName].value or packageM.valueMap[typeName].value or 0
        for itemName, amount in pairs(list) do
            if type(amount) == "table" then
                item_list[typeName][itemName] = item_list[typeName][itemName] or {}
                local i = 0
                for _, v in ipairs(amount) do
                    table.insert(item_list[typeName][itemName], v)
                    i = i + 1
                end
                amount = i
            else
                item_list[typeName][itemName] = item_list[typeName][itemName] and item_list[typeName][itemName] + amount or amount
            end
            package.amount = package.amount and package.amount + amount or amount
            package.amountIndex = package.amountIndex or {}
            package.amountIndex[typeName] = package.amountIndex[typeName] and package.amountIndex[typeName] + amount or amount
        end
    end
    packageM:Remove()
end

---将物品添加到超级包裹
---@param package table
---@param entity table
---@param showFx? boolean
function AddItemToSuperPackage(package, entity, showFx)
    --特效
    if showFx then SpawnPrefab("small_puff").Transform:SetPosition(entity.Transform:GetWorldPosition()) end
    --fx.Transform:SetScale(0.5,0.5,0.5)

    local item_list = package.item_list
    if entity.prefab == "super_package" then
        MergePackage(package, entity)
        return
    end
    local added = false
    local itemType
    for type, list in pairs(ItemTypeMap) do
        if table.contains(list, entity.prefab) then
            if type == "equipment" then
                local isHigh = entity.equip_value >= TaxuePatch.cfg.HIGH_EQUIPMENT_PERCENT * entity.MAX_EQUIP_VALUE
                type = isHigh and "equipmentHigh" or "equipmentLow"
            end
            if not item_list[type] then
                item_list[type] = {}
            end
            addToList(item_list[type], entity)
            itemType = type
            added = true
            break
        end
    end
    if not added then
        if not item_list.others then
            item_list.others = {}
        end
        local list = item_list.others
        addToList(list, entity)
        itemType = "others"
    end

    local amount = entity.components.stackable and entity.components.stackable.stacksize or 1
    local coinValue = entity.taxue_coin_value and entity.taxue_coin_value * amount
    if package.hasValue == nil then
        package.hasValue = true
    end
    package.hasValue = package.hasValue and (coinValue ~= nil)
    package.valueMap = package.valueMap or {}
    package.valueMap[itemType] = package.valueMap[itemType] or { hasValue = true }
    if package.hasValue then
        package.taxue_coin_value = package.taxue_coin_value and package.taxue_coin_value + coinValue or coinValue
    else
        package.taxue_coin_value = nil
    end
    package.valueMap[itemType].hasValue = package.valueMap[itemType].hasValue and (coinValue ~= nil)
    package.valueMap[itemType].value = package.valueMap[itemType].value and package.valueMap[itemType].value + (coinValue or 0) or coinValue or 0

    package.amountIndex = package.amountIndex or {}
    package.amount = package.amount and package.amount + amount or amount
    package.amountIndex[itemType] = package.amountIndex[itemType] and package.amountIndex[itemType] + amount or amount

    entity:Remove()
end

---打开超级包裹
---@param package table
function UnpackSuperPackage(package)
    if package.isPatched then
        local item_list = package.item_list
        if not package.type then
            for itemType, list in pairs(item_list) do
                local typeName = ItemTypeNameMap[itemType]
                local newPackage = SpawnPrefab("super_package")
                newPackage.isPatched = true
                newPackage.name = typeName
                newPackage.type = itemType
                newPackage.amount = package.amountIndex[itemType]
                newPackage.amountIndex = newPackage.amountIndex or {}
                newPackage.amountIndex[itemType] = package.amountIndex[itemType]
                newPackage.hasValue = package.valueMap[itemType].hasValue
                newPackage.valueMap = newPackage.valueMap or {}
                newPackage.valueMap[itemType] = package.valueMap[itemType]
                newPackage.taxue_coin_value = newPackage.hasValue and package.valueMap[itemType].value or nil
                newPackage.item_list[itemType] = list
                giveItem(package, newPackage)
            end
        else
            local list = package.item_list[package.type]
            for name, items in pairs(list) do
                if type(items) == "number" then
                    giveStackedItem(package, name, items)
                else
                    local maxAmount = TaxuePatch.cfg.PACKAGE_MAX_AMOUNT
                    local itemNum = TableCount(items)
                    if itemNum > maxAmount * 1.5 then
                        local newPackage = SpawnPrefab("super_package")
                        newPackage.isPatched = true
                        newPackage.name = package.name
                        newPackage.type = package.type
                        local i = 0
                        for _, item in pairs(items) do
                            local item = SpawnSaveRecord(item)
                            if i >= maxAmount and itemNum - i > maxAmount / 2 then
                                giveItem(package, newPackage)
                                newPackage = SpawnPrefab("super_package")
                                newPackage.isPatched = true
                                newPackage.name = package.name
                                newPackage.type = package.type
                                itemNum = itemNum - i
                                i = 0
                            end
                            i = i + 1
                            AddItemToSuperPackage(newPackage, item)
                        end
                        giveItem(package, newPackage)
                    else
                        for _, data in pairs(items) do
                            local item = SpawnSaveRecord(data)
                            giveItem(package, item)
                        end
                    end
                end
            end
        end
    else
        local slots = package.components.container.slots
        local newPackage = SpawnPrefab("super_package")
        for __, v in pairs(slots) do
            AddItemToSuperPackage(newPackage, v)
        end
        for k, v in pairs(package.item_list) do
            local newItem = SpawnPrefab(k)
            newItem.components.stackable.stacksize = v
            AddItemToSuperPackage(newPackage, newItem)
        end
        if TableCount(newPackage.item_list) == 1 then
            for type, _ in pairs(newPackage.item_list) do
                newPackage.type = type
            end
        end
        newPackage.isPatched = true
        giveItem(package, newPackage)
    end
    package:Remove()
end
