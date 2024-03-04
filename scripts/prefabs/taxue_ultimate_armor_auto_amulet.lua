-- 说明
STRINGS.NAMES.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理护符"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "告别终极装备手动给予修理材料烦恼！"
STRINGS.RECIPE_DESC.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理你值得拥有！"

local function findItem(slots, test)
    if not slots then return nil end
    local found1
    local found2
    for slot, item in pairs(slots) do
        if item then
            if not found2 and item.components and item.components.container then
                found2 = findItem(item.components.container.slots, test)
            else
                if not found1 and TaxuePatch.TestItem(item, test) then
                    found1 = item
                    break
                end
            end
        end
    end
    return found1 and found1 or found2
end

-- 查找修复材料
local function FindAllInventory(owner, test)
    if owner and owner.components and owner.components.inventory then
        local inventory = owner.components.inventory
        -- 物品栏
        if inventory.itemslots then
            local found = findItem(inventory.itemslots, test)
            if found then return found, inventory end
        end
        -- 背包栏
        if inventory.equipslots then
            local back = inventory.equipslots[EQUIPSLOTS.BACK]
            if back and back.components and back.components.container then
                local found = findItem(back.components.container.slots, test)
                if found then return found, back.components.container end
            end
        end
    end
end

local function GetOne(owner, test)
    local item, container = FindAllInventory(owner, test)
    if item and item.components.stackable then
        local stackable = item.components.stackable
        if stackable.stacksize > 1 then
            local instance = SpawnPrefab(item.prefab)

            stackable:SetStackSize(stackable.stacksize - 1)
            instance.components.stackable:SetStackSize(1)

            if stackable.ondestack then
                stackable.ondestack(instance)
            end

            if instance.components.perishable then
                instance.components.perishable.perishremainingtime = item.components.perishable.perishremainingtime
            end

            if instance.components.inventoryitem ~= nil and item.components.inventoryitem ~= nil then
                if item.components.inventoryitem.owner then
                    instance.components.inventoryitem:OnPutInInventory(item.components.inventoryitem.owner)
                end

                item:ApplyInheritedMoisture(instance)
            end

            return instance
        end
    end
    if item then
        container:RemoveItem(item)
    end
    return item
end

local function GetAutoAmulet(owner)
    if owner and owner.components and owner.components.inventory then
        local equipslots = owner.components.inventory.equipslots
        for _, item in pairs(equipslots) do
            if item.prefab == "taxue_ultimate_armor_auto_amulet" then return item end
        end
    end
end

-- 监听耐久消耗
local function ListenDurableConsume(inst, ...)
    local owner = inst.components.inventoryitem.owner
    if owner and owner:HasTag("auto_amulet") then
        if TaxuePatch.cfg.AUTO_AMULET_ARMOR and inst.components.armor:GetPercent() < TaxuePatch.cfg.AUTO_AMULET_ARMOR then
            local repairMaterial = GetOne(owner, "core_gem")
            if repairMaterial then
                inst.components.trader:AcceptGift(owner, repairMaterial)
            end
        end
    else
        inst:RemoveTag("auto_amulet")
        inst:RemoveEventCallback("armorhit", ListenDurableConsume)
    end
end

-- 监听燃料变化
local function ListenFueledChange(inst, data)
    local owner = inst.components.inventoryitem.owner
    if owner:HasTag("auto_amulet") then
        if TaxuePatch.cfg.AUTO_AMULET_WEAPON and data.percent < TaxuePatch.cfg.AUTO_AMULET_WEAPON then
            if inst.components.fueled then
                local fueled = inst.components.fueled
                local repairMaterial = GetOne(owner, function(item) return fueled:CanAcceptFuelItem(item) end)
                if repairMaterial then
                    fueled:TakeFuelItem(repairMaterial)
                    data.percent = fueled:GetPercent()
                    data.fuel = fueled.currentfuel
                end
            elseif inst.components.finiteuses then
                local repairMaterial = inst.prefab == "pink_crescent_sword" and "pink_core_gem" or "core_gem"
                repairMaterial = GetOne(owner, repairMaterial)
                if repairMaterial then
                    inst.components.trader:AcceptGift(owner, repairMaterial)
                    data.percent = inst.components.finiteuses:GetPercent()
                end
            end
        end
    else
        inst:RemoveTag("auto_amulet")
        inst:RemoveEventCallback("percentusedchange", ListenFueledChange)
    end
end

-- 护符主人穿戴装备
local function OwnerOnEquip(owner, data)
    local item = data.item
    local eslot = data.eslot
    local amulet = data.amulet or GetAutoAmulet(owner)
    if not amulet then return end
    if not (item and eslot) then return end
    if item:HasTag("auto_amulet") then return end
    item:AddTag("auto_amulet")

    -- 武器
    if eslot == EQUIPSLOTS.HANDS then
        if item:HasTag("taxue_ultimate_weapon") then
            item:ListenForEvent("percentusedchange", ListenFueledChange)
        end
        if amulet.level > 0 and not item:HasTag("cantdrop") and not item.components.projectile then
            amulet.cantdrop = true
            item:AddTag("cantdrop")
        end

        -- 盔甲
    elseif eslot == EQUIPSLOTS.BODY and item.prefab == "blooming_armor" then
        item:ListenForEvent("armorhit", ListenDurableConsume)

        -- 头盔
    elseif eslot == EQUIPSLOTS.HEAD and item.prefab == "blooming_headwear" then
        item:ListenForEvent("armorhit", ListenDurableConsume)
    end
end

-- 护符主人脱下装备
local function OwnerUnEquip(owner, data)
    local item = data.item
    local eslot = data.eslot
    local amulet = data.amulet or GetAutoAmulet(owner)
    if not amulet then return end
    if not (item and eslot) then return end
    if not item:HasTag("auto_amulet") then return end
    item:RemoveTag("auto_amulet")
    -- 武器
    if eslot == EQUIPSLOTS.HANDS then
        item:RemoveEventCallback("percentusedchange", ListenFueledChange)
        if amulet.cantdrop then
            amulet.cantdrop = nil
            item:RemoveTag("cantdrop")
        end

        -- 盔甲
    elseif eslot == EQUIPSLOTS.BODY then
        item:RemoveEventCallback("armorhit", ListenDurableConsume)

        -- 头盔
    elseif eslot == EQUIPSLOTS.HEAD then
        item:RemoveEventCallback("armorhit", ListenDurableConsume)
    end
end

local function onTemperaturedelta(owner, data)
    if not (owner and owner.components and owner.components.eater) then return end
    local eater = owner.components.eater
    local temperature = owner.components.temperature
    if not (temperature and owner.components.health) then return end
    if temperature.current <= 0 and temperature.maxtemp > 0 then
        local hot_agentia = GetOne(owner, { "hot_agentia", "hot_agentia_advanced" })
        if hot_agentia then eater:Eat(hot_agentia) end
    elseif temperature.current >= temperature.overheattemp and temperature.mintemp < temperature.overheattemp then
        local ice_agentia = GetOne(owner, { "ice_agentia", "ice_agentia_advanced" })
        if ice_agentia then eater:Eat(ice_agentia) end
    end
end

local enableHeal = TaxuePatch.cfg.AUTO_AMULET_HEAL

local function onHealthdelta(owner, data)
    if enableHeal then
        if not (owner and owner.components and owner.components.health and owner.components.eater) then return end
        local health = owner.components.health
        if health.currenthealth == health.maxhealth or not data.cause then return end
        if (TaxuePatch.cfg.AUTO_AMULET_HEAL_NUM and health.currenthealth < TaxuePatch.cfg.AUTO_AMULET_HEAL_NUM) or
            (TaxuePatch.cfg.AUTO_AMULET_HEAL_PER and data.newpercent < TaxuePatch.cfg.AUTO_AMULET_HEAL_PER) then
            local health_agentia = GetOne(owner, "health_agentia")
            if health_agentia and health_agentia.components.edible then
                health:DoDelta(health_agentia.components.edible.healthvalue, nil, health_agentia.prefab)
                data.newpercent = health:GetPercent()
                health_agentia:Remove()
            end
        end
    end
end

TheInput:AddKeyDownHandler(TaxuePatch.cfg.AUTO_AMULET_HEAL_KEY, function()
    if not (GetPlayer() and GetPlayer().prefab == "taxue") or IsPaused() then return end
    enableHeal = not enableHeal
    TaXueSay(enableHeal and "自动喝血启用" or "自动喝血禁用")
end)

local Listeners = {
    equip = OwnerOnEquip,
    unequip = OwnerUnEquip,
    temperaturedelta = onTemperaturedelta,
    healthdelta = onHealthdelta,
}

-- 穿戴护符
local function OnEquip(self, owner)
    owner:AddTag("auto_amulet")
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")

    for event, fn in pairs(Listeners) do
        owner:ListenForEvent(event, fn)
    end

    if owner and owner.components then
        if owner.components.inventory then
            for _, eslot in pairs(EQUIPSLOTS) do
                local item = owner.components.inventory:GetEquippedItem(eslot)
                Listeners.equip(owner, { item = item, eslot = eslot, amulet = self })
            end
        end
        if self.level > 0 then
            if owner.components.health then
                self.fire_damage_scale = owner.components.health.fire_damage_scale
                owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale - self.fire_damage_scale
            end
        end
    end
end

-- 脱下护符
local function OnUnEquip(self, owner)
    owner:RemoveTag("auto_amulet")
    owner.AnimState:ClearOverrideSymbol("swap_body")

    for event, fn in pairs(Listeners) do
        owner:RemoveEventCallback(event, fn)
    end

    if owner and owner.components and owner.components.inventory then
        for _, eslot in pairs(EQUIPSLOTS) do
            local item = owner.components.inventory:GetEquippedItem(eslot)
            Listeners.unequip(owner, { item = item, eslot = eslot, amulet = self })
        end
    end

    if self.fire_damage_scale then
        owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale + self.fire_damage_scale
        self.fire_damage_scale = nil
    end
end

local function ShouldAcceptItem(inst, item)
    if not (inst.components and inst.components.inventoryitem and inst.components.inventoryitem.owner) then return false end
    local owner = inst.components.inventoryitem.owner
    if not (owner.components and owner.components.inventory) then return false end
    local inventory = owner.components.inventory
    if inst.level < 1 and item.prefab == "perpetual_core" then
        local result = true
        for name, amount in pairs(inst.upgradeMaterials) do
            result = result and inventory:Has(name, amount, true)
        end
        return result
    end
    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    local inventory = giver.components and giver.components.inventory
    for name, amount in pairs(inst.upgradeMaterials) do
        inventory:ConsumeByName(name, amount, true)
    end
    inst.level = inst.level + 1
    TaXueSay("护符升级成功")
    inst.SoundEmitter:PlaySound("onupdate/sfx/onupdate")
    inst.components.equippable.walkspeedmult = 0.2
    if inst.components.inventoryitem.owner then
        inst.components.equippable:Unequip(inst.components.inventoryitem.owner)
        inst.components.equippable:Equip(inst.components.inventoryitem.owner)
    end
end

local function OnRefuseItem(inst, giver, item)
    local str
    if inst.level < 1 and item.prefab == "perpetual_core" then
        str = "升级材料缺失:\n"
        local inventory = giver.components and giver.components.inventory
        for name, amount in pairs(inst.upgradeMaterials) do
            if inventory then
                amount = math.max(0, amount - inventory:Count(name, true))
            end
            if amount > 0 then
                str = str .. " " .. TaxueToChs(name) .. "X" .. amount
            end
        end
    else
        str = "使用永动机核心升级"
    end
    TaXueSay(str)
end

local dataItems = { "level", "fire_damage_scale", "cantdrop" }

local function OnSave(self, data)
    for _, dataItem in pairs(dataItems) do
        if self[dataItem] then data[dataItem] = self[dataItem] end
    end
    data.walkspeedmult = self.components.equippable.walkspeedmult
end

local function OnLoad(self, data)
    for _, dataItem in pairs(dataItems) do
        if data[dataItem] then self[dataItem] = data[dataItem] end
    end
    self.components.equippable.walkspeedmult = data.walkspeedmult
end

local assets = {
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
    Asset("IMAGE", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.tex"),
    Asset("ATLAS", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("amulets")
    inst.AnimState:PlayAnimation("orangeamulet") -- 懒人护符动画

    MakeInventoryFloatable(inst, "orangeamulet_water", "orangeamulet")

    inst:AddComponent("inspectable")
    inst.components.inspectable.description = function(inst, viewer)
        local desc = GetDescription(string.upper(viewer.prefab), inst, inst.components.inspectable:GetStatus(viewer))
        if inst.level < 1 then
            desc = desc .. "\t可使用永动机核心升级,当前等级: " .. inst.level
        end
        return desc
    end

    -- 可装备
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnEquip)

    -- 回san Buff
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL

    -- 库存物品
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddTag("taxue")
    inst:AddTag("taxue_ultimate_armor_auto_amulet")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.level = 0
    inst.upgradeMaterials = {
        chest_essence = 10,
        thulecite = 20,
        greengem = 20
    }

    return inst
end

return Prefab("common/inventory/taxue_ultimate_armor_auto_amulet", fn, assets, { "sand_puff" })
