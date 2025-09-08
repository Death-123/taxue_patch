local superPackageLib = {}

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
function superPackageLib.SpawnPackage(name, type)
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

function superPackageLib.addToList(list, entity, number, data)
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

function superPackageLib.processPackageData(package, itemType, itemName, amount, value, data)
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

---检查包裹类型
---@param package package
function superPackageLib.CheckPackageType(package)
    if TaxuePatch.TableCount(package.item_list) == 1 then
        local type, _ = next(package.item_list)
        package.name = TaxuePatch.ItemTypeNameMap[type] or type
        package.type = type
    else
        package.type = nil
        package.name = TaxueToChs(package.prefab)
    end
end

---transform package to patched package
---@param package package
---@return package newPackage
function superPackageLib.TransformPackage(package)
    local slots = package.components.container.slots
    local newPackage = superPackageLib.SpawnPackage()
    for _, v in pairs(slots) do
        superPackageLib.AddItemToSuperPackage(newPackage, v)
    end
    for k, v in pairs(package.item_list) do
        if type(v) == "table" then
            for name, items in pairs(v) do
                if type(items) == "number" then
                    local item = SpawnPrefab(name)
                    item.components.stackable.stacksize = items
                    superPackageLib.AddItemToSuperPackage(newPackage, item)
                else
                    for _, itemData in pairs(items) do
                        if itemData.prefab then
                            local item = SpawnSaveRecord(itemData)
                            superPackageLib.AddItemToSuperPackage(newPackage, item)
                        else
                            for _, itemData in pairs(itemData) do
                                local item = SpawnSaveRecord(itemData)
                                superPackageLib.AddItemToSuperPackage(newPackage, item)
                            end
                        end
                    end
                end
            end
        else
            local newItem = SpawnPrefab(k)
            newItem.components.stackable.stacksize = v
            superPackageLib.AddItemToSuperPackage(newPackage, newItem)
        end
    end
    if TaxuePatch.TableCount(newPackage.item_list) == 1 then
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
function superPackageLib.MergePackage(package, packageM)
    if not package.isPatched then package = superPackageLib.TransformPackage(package) end
    if not packageM.isPatched then packageM = superPackageLib.TransformPackage(packageM) end
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
                        superPackageLib.processPackageData(package, itemType, itemName, 1, value)
                    else
                        for _, item in pairs(list3) do
                            item_list[itemType][itemName][data] = item_list[itemType][itemName][data] or {}
                            table.insert(item_list[itemType][itemName][data], item)
                            local value = packageM.valueMap[itemType].sub[itemName].hasValue and packageM.valueMap[itemType].sub[itemName].sub[data].value / #list3 or nil
                            superPackageLib.processPackageData(package, itemType, itemName, 1, value, data)
                        end
                    end
                end
            else
                item_list[itemType][itemName] = item_list[itemType][itemName] and item_list[itemType][itemName] + list2 or list2
                local value = packageM.valueMap[itemType].sub[itemName].hasValue and packageM.valueMap[itemType].sub[itemName].value or nil
                superPackageLib.processPackageData(package, itemType, itemName, list2, value)
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
function superPackageLib.AddItemToSuperPackage(package, entity, showFx, testFn)
    if not entity or testFn and not testFn(entity) then return false end
    --特效
    if showFx then SpawnPrefab("small_puff").Transform:SetPosition(entity.Transform:GetWorldPosition()) end
    --fx.Transform:SetScale(0.5,0.5,0.5)
    if not package.isPatched then
        package = superPackageLib.TransformPackage(package)
        if not package then return false end
    end

    local item_list = package.item_list
    if entity.prefab == "super_package" then
        superPackageLib.MergePackage(package, entity)
        return true
    end
    if entity:HasTag("loaded_package") and entity.loaded_item_list then
        local loaded_item_list = {}
        for _, name in pairs(entity.loaded_item_list) do
            loaded_item_list[name] = loaded_item_list[name] and loaded_item_list[name] + 1 or 1
        end
        superPackageLib.AddItemsToSuperPackage(package, loaded_item_list)
        entity:Remove()
        return true
    end
    local itemType
    for type, list in pairs(TaxuePatch.ItemTypeMap) do
        if table.contains(list, entity.prefab) then
            if type == "equipment" then
                local isHigh = entity.equip_value >= TaxuePatch.cfg("package.highEquipmentPercent") * entity.MAX_EQUIP_VALUE
                type = isHigh and "equipmentHigh" or "equipmentLow"
            end
            itemType = type
            break
        end
    end
    itemType = itemType or "others"
    local data
    if table.containskey(TaxuePatch.ItemDataMap, entity.prefab) then
        data = entity[TaxuePatch.ItemDataMap[entity.prefab]]
    end
    item_list[itemType] = item_list[itemType] or {}
    superPackageLib.addToList(item_list[itemType], entity, nil, data)

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

    superPackageLib.processPackageData(package, itemType, entity.prefab, amount, coinValue, data)

    entity:Remove()
    return true
end

---将表中物品添加到超级包裹中
---@param package package
---@param items {[string]: integer}
---@param showFx? boolean
---@param testFn? fun(ent:entityPrefab):boolean
---@return {[string]: integer} leftItems
function superPackageLib.AddItemsToSuperPackage(package, items, showFx, testFn)
    local blackList = { "houndfire" }
    for _, name in pairs(blackList) do
        items[name] = nil
    end
    local leftItems = {}
    for name, amount in pairs(items) do
        local prefab = SpawnPrefab(name)
        local added = false
        if prefab and prefab.components.stackable then
            prefab.components.stackable.stacksize = amount
            added = superPackageLib.AddItemToSuperPackage(package, prefab, showFx, testFn)
        elseif prefab and (not testFn or testFn(prefab)) then
            added = true
            for _ = 1, amount do
                superPackageLib.AddItemToSuperPackage(package, SpawnPrefab(name), showFx, testFn)
            end
        end
        prefab:Remove()
        if not added then leftItems[name] = amount end
    end
    superPackageLib.CheckPackageType(package)
    return leftItems
end

---打包所有实体
---@param package package
---@param entities entityPrefab[]
---@param testFn? fun(entity:entityPrefab):boolean
---@param isBook? boolean
function superPackageLib.PackAllEntities(package, entities, testFn, isBook)
    local treasures = {}
    local specialResult = {}
    local specialList = {
        golden_rocky = 0,
        golden_pigman = 0,
        golden_bunnyman = 0,
        taxue_strawberry_big = 0,
        taxue_pineapple_big = 0,
        taxue_melon_big = 0,
    }
    for _, ent in ipairs(entities) do
        if TaxuePatch.cfg("package.openTreasures") and ent:HasTag("taxue_treasure") and (isBook or TaxuePatch.cfg("package.machineTreasures")) then
            table.insert(treasures, ent)
        elseif specialList[ent.prefab] then
            local amount = 1
            if ent.components and ent.components.stackable then amount = ent.components.stackable.stacksize end
            specialList[ent.prefab] = specialList[ent.prefab] + amount
            SpawnPrefab("small_puff").Transform:SetPosition(ent.Transform:GetWorldPosition())
            ent:Remove()
        elseif not testFn or testFn(ent) then
            superPackageLib.AddItemToSuperPackage(package, ent, true)
        end
    end
    if next(treasures) then
        superPackageLib.AddTreasuresToPackage(package, treasures, isBook)
    end
    if next(specialList) then
        for name, num in pairs(specialList) do
            local prefab = SpawnPrefab(name)
            TaxuePatch.AddLootsToList(prefab.components.lootdropper, specialResult, num)
            prefab:Remove()
        end
    end
    if next(specialResult) then superPackageLib.AddItemsToSuperPackage(package, specialResult) end
    superPackageLib.CheckPackageType(package)
end

function superPackageLib.DoPack(inst, isBook)
    local blackList = { "chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone" }
    local notags = { "INLIMBO", "NOCLICK", "catchable", "fire", "doydoy" }
    if not isBook then
        TaxueFx(inst, "clouds_bombsplash", 1, { 148, 0, 211 })
        local blackListMachine = { "blooming_armor", "blooming_headwear" }
        local notagsMachine = { "taxue_ultimate_weapon", "taxue_armor_advanced", "taxue_hats_advanced" }
        for _, name in pairs(blackListMachine) do table.insert(blackList, name) end
        for _, name in pairs(notagsMachine) do table.insert(notags, name) end
    end
    local package = isBook and superPackageLib.SpawnPackage() or inst:getPackage()
    local range = isBook and 30 or 50
    local function testFn(ent)
        local inventoryitem = ent.components.inventoryitem
        return inventoryitem and inventoryitem.canbepickedup and inventoryitem.cangoincontainer and not table.contains(blackList, ent.prefab)
    end
    local ents = TaxuePatch.GetNearByEntities(inst, range, nil, nil, notags)
    superPackageLib.PackAllEntities(package, ents, testFn, isBook)
    if isBook then
        if package.amount ~= 0 then
            GetPlayer().components.inventory:GiveItem(package)
            GetPlayer().components.talker:Say("打包成功！")
        else
            package:Remove()
            GetPlayer().components.talker:Say("你在打包空气吗？")
        end
    else
        if package.amount == 0 then
            package:Remove()
        end
    end
end

---打开超级包裹
---@param package package
function superPackageLib.UnpackSuperPackage(package)
    if package.isPatched and package.amountMap then
        if package.amount == 0 then
            TaxuePatch.RemoveItem(package)
            return
        end
        local item_list = package.item_list
        if not package.type then
            for itemType, list in pairs(item_list) do
                local typeName = TaxuePatch.ItemTypeNameMap[itemType] or itemType
                local newPackage = superPackageLib.SpawnPackage()
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
                TaxuePatch.GiveItem(package, newPackage)
            end
        else
            local list = package.item_list[package.type]
            local maxAmount = TaxuePatch.cfg("package.maxAmount")
            local itemMaxStackSize = TaxuePatch.cfg("package.itemMaxStackSize")
            local isSingle = TaxuePatch.TableCount(list) == 1
            for itemName, items in pairs(list) do
                local itemList = {}
                if type(items) == "number" then
                    local maxsize
                    if itemMaxStackSize then
                        maxsize = itemMaxStackSize
                    else
                        local tempItem = SpawnPrefab(itemName)
                        maxsize = tempItem.components.stackable.maxsize
                        tempItem:Remove()
                    end
                    itemList = TaxuePatch.GetStackedItem(itemName, items, maxsize)
                else
                    local isSingleData = TaxuePatch.TableCount(items) == 1
                    local newPackage
                    for value, item in pairs(items) do
                        if item.prefab then
                            table.insert(itemList, SpawnSaveRecord(item))
                        elseif isSingleData or package.amountMap[package.type].amount < maxAmount then
                            for _, item_ in ipairs(item) do
                                table.insert(itemList, SpawnSaveRecord(item_))
                            end
                        elseif isSingle then
                            local packageName = TaxueToChs(itemName) .. "  " .. TaxuePatch.DataStrMap[itemName]:format(type(value) == "number" and value or TaxueToChs(value))
                            local newPackage = superPackageLib.SpawnPackage(packageName, package.type)
                            for _, item_ in ipairs(item) do
                                superPackageLib.AddItemToSuperPackage(newPackage, SpawnSaveRecord(item_))
                            end
                            TaxuePatch.GiveItem(package, newPackage)
                        else
                            newPackage = newPackage or superPackageLib.SpawnPackage(TaxueToChs(itemName), package.type)
                            for _, item_ in ipairs(item) do
                                superPackageLib.AddItemToSuperPackage(newPackage, SpawnSaveRecord(item_))
                            end
                        end
                    end
                    if newPackage then TaxuePatch.GiveItem(package, newPackage) end
                end
                local itemNum = #itemList
                if itemNum > maxAmount * 1.5 then
                    local packageName = TaxueToChs(itemName)
                    local packageType = package.type
                    local newPackage = superPackageLib.SpawnPackage(packageName, packageType)
                    local i = 0
                    for _, item in ipairs(itemList) do
                        if isSingle then
                            if i >= maxAmount and itemNum - i > maxAmount / 2 then
                                TaxuePatch.GiveItem(package, newPackage)
                                newPackage = superPackageLib.SpawnPackage(packageName, packageType)
                                itemNum = itemNum - i
                                i = 0
                            end
                            i = i + 1
                        end
                        superPackageLib.AddItemToSuperPackage(newPackage, item)
                    end
                    TaxuePatch.GiveItem(package, newPackage)
                else
                    for _, item in pairs(itemList) do
                        TaxuePatch.GiveItem(package, item)
                    end
                end
            end
        end
    else
        superPackageLib.TransformPackage(package)
    end
    TaxuePatch.RemoveItem(package)
end

---开宝藏
---@param treasures entityPrefab[]
---@param isBook boolean
---@return table loots
---@return table[] numbers
function superPackageLib.OpenTreasures(treasures, isBook)
    treasures[1].SoundEmitter:PlaySound("dontstarve_DLC002/common/loot_reveal")

    local numbers = { {}, {} }

    local loots = { boneshard = 0, obsidian = 0 }

    local books = { "book_tentacles", "book_birds", "book_meteor", "book_sleep", "book_brimstone", "book_gardening",
        "book_tentacles", "book_birds", "book_meteor", "book_sleep", "book_brimstone" }                                --原版书籍
    local statues = { "ruins_statue_head", "ruins_statue_head_nogem", "ruins_statue_mage", "ruins_statue_mage_nogem" } --远古雕像

    local inventory = GetPlayer().components.inventory
    local function getBook()
        local book
        TaxuePatch.TraversalAllInventory(GetPlayer(), function (container, item, slot)
            if item.prefab == "book_treasure_deprotonation" or
                (item.prefab == "book_treasure_deprotonation_super" and item.time > 0) then
                book = item
                return true
            end
        end)
        return book
    end
    local function getBookNum(book)
        if book.prefab == "book_treasure_deprotonation" then
            return book.treasure_num
        else
            return book.time
        end
    end
    local function bookNumMinus(book)
        if book.prefab == "book_treasure_deprotonation" then
            book.treasure_num = book.treasure_num - 1
        else
            book.time = book.time - 1
        end
    end
    local deprotonationBook = getBook()
    local monstersToKill = {}

    for _, treasure in pairs(treasures) do
        local opened
        if treasure.prefab == "taxue_buriedtreasure_monster" then --怪物宝藏
            local name = treasure.advance_list[1]
            if not Prefabs[name] then name = "spider" end
            local inBlackList = table.contains(TaxuePatch.config:GetSelectdValues("buffThings.treasureDeprotonation"), name)
            if deprotonationBook and not inBlackList then
                opened = true
                bookNumMinus(deprotonationBook)
                if getBookNum(deprotonationBook) <= 0 then
                    if deprotonationBook.prefab ~= "book_treasure_deprotonation_super" then
                        inventory:RemoveItem(deprotonationBook):Remove()
                    end
                    deprotonationBook = getBook()
                end
                TaxuePatch.ListAdd(monstersToKill, name)
            elseif (deprotonationBook and inBlackList) or TaxuePatch.cfg("package.alwaysOpenMonster") or not isBook then
                opened = true
                local monster = SpawnPrefab(name)
                monster.Transform:SetPosition(treasure.Transform:GetWorldPosition())
            end
        else
            opened = true
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
                if TaxuePatch.cfg("package.destoryChest") then
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
                if TaxuePatch.cfg("package.destoryStatue") then
                    local dorps = statue.components.lootdropper:GenerateLoot()
                    for _, prefab in ipairs(dorps) do
                        loots[prefab] = loots[prefab] and loots[prefab] + 1 or 1
                        statue:Remove()
                    end
                else
                    statue.Transform:SetPosition(treasure.Transform:GetWorldPosition()) --生成随机雕像
                end
            end
        end
        if opened then
            loots["boneshard"] = loots["boneshard"] + 2

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

            if math.random() <= 0.1 then
                local book = books[math.random(#books)]
                loots[book] = loots[book] and loots[book] + 1 or 1
            end

            numbers[1][treasure.prefab] = numbers[1][treasure.prefab] and numbers[1][treasure.prefab] + 1 or 1
            treasure:Remove()
        end
    end
    for name, num in pairs(monstersToKill) do
        local monster = SpawnPrefab(name)
        TaxuePatch.AddLootsToList(monster.components.lootdropper, loots, num)
        monster:Remove()
    end
    for _, name in pairs({ "boneshard", "obsidian" }) do
        if loots[name] == 0 then
            loots[name] = nil
        end
    end
    return loots, numbers
end

---开启所有宝藏并将物品添加进包裹
---@param package package
---@param treasures entityPrefab[]
---@param isBook boolean
function superPackageLib.AddTreasuresToPackage(package, treasures, isBook)
    local loots, numbers = superPackageLib.OpenTreasures(treasures, isBook)
    for name, amount in pairs(loots) do
        local prefab = SpawnPrefab(name)
        if prefab and prefab.components.stackable then
            prefab.components.stackable.stacksize = amount
            superPackageLib.AddItemToSuperPackage(package, prefab)
        elseif prefab then
            prefab:Remove()
            for _ = 1, amount do
                superPackageLib.AddItemToSuperPackage(package, SpawnPrefab(name))
            end
        end
    end
    if next(numbers[1]) then
        local str = "这波打包了:\n"
        for _, line in pairs(numbers) do
            for name, number in pairs(line) do
                local name = name == "statue" and "雕像" or TaxueToChs(name)
                str = str .. name .. number .. "个 "
            end
            str = str .. "\n"
        end
        if not package.components.talker then package:AddComponent("talker") end
        package.components.talker.colour = Vector3(255 / 255, 131 / 255, 250 / 255)
        package.components.talker.offset = Vector3(0, 100, 0)
        package.components.talker:Say(str, 10)
        package:ListenForEvent("onremove", function () package.components.talker:ShutUp() end)
    end
end

return superPackageLib
