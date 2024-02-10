-- 说明
STRINGS.NAMES.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理护符"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "告别终极装备手动给予修理材料烦恼！"
STRINGS.RECIPE_DESC.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理你值得拥有！"

local bagList = { "gorgeous_bag", "agentia_bag" }

local function findItem(slots, test)
    if not slots then return nil end
    local found1
    local found2
    for slot, item in pairs(slots) do
        if item then
            if table.contains(bagList, item.prefab) and item.components and item.components.container then
                found2 = findItem(item.components.container.slots, test)
            else
                if not found1 and TestItem(item, test) then found1 = item end
            end
        end
    end
    return found1 and found1 or found2
end

-- 查找修复材料
local function FindAllInventory(owner, test)
    local found
    if owner and owner.components and owner.components.inventory then
        -- 物品栏
        if owner.components.inventory.itemslots then
            found = findItem(owner.components.inventory.itemslots, test)
        end
        if found then return found end
        -- 背包栏
        if owner.components.inventory.equipslots then
            local back = owner.components.inventory.equipslots[EQUIPSLOTS.BACK]
            if back and back.components and back.components.container then
                found = findItem(back.components.container.slots, test)
            end
        end
    end
    return found
end

local function GetOne(owner, test)
    local repairMaterial = FindAllInventory(owner, test)
    if repairMaterial and repairMaterial.components.stackable then
        repairMaterial = repairMaterial.components.stackable:Get()
    end
    return repairMaterial
end

-- 监听耐久消耗
local function ListenDurableConsume(inst, ...)
    local owner = inst.components.inventoryitem.owner
    if owner and owner:HasTag("auto_amulet") then
        if inst.components.armor:GetPercent() < 0.7 then
            local repairMaterial = GetOne(owner, "core_gem")
            if repairMaterial then
                inst.components.trader:AcceptGift(owner, repairMaterial)
            end
        end
    else
        inst:RemoveTag("ListenDurableConsume")
        inst:RemoveEventCallback("armorhit", ListenDurableConsume)
    end
end

-- 监听燃料变化
local function ListenFueledChange(inst, data)
    local owner = inst.components.inventoryitem.owner
    if owner:HasTag("auto_amulet") then
        if data.percent < 0.5 then
            if inst.components.fueled then
                local inst_fueled = inst.components.fueled
                local repairMaterial = GetOne(owner, function(item) return inst_fueled:CanAcceptFuelItem(item) end)
                if repairMaterial then
                    inst_fueled:TakeFuelItem(repairMaterial)
                end
            elseif inst.components.finiteuses then
                local repairMaterial = inst.prefab == "pink_crescent_sword" and "pink_core_gem" or "core_gem"
                repairMaterial = GetOne(owner, repairMaterial)
                if repairMaterial then
                    inst.components.trader:AcceptGift(owner, repairMaterial)
                end
            end
        end
    else
        inst:RemoveTag("ListenDurableConsume")
        inst:RemoveEventCallback("percentusedchange", ListenFueledChange)
    end
end

-- 护符主人穿戴装备
local function OwnerOnEquip(_, data)
    local equip = data.item
    local eslot = data.eslot
    -- 盔甲
    if eslot == EQUIPSLOTS.BODY and equip and equip.prefab == "blooming_armor" then
        if not equip:HasTag("ListenDurableConsume") then
            equip:AddTag("ListenDurableConsume")
            equip:ListenForEvent("armorhit", ListenDurableConsume)
        end
    end

    -- 头盔
    if eslot == EQUIPSLOTS.HEAD and equip and equip.prefab == "blooming_headwear" then
        if not equip:HasTag("ListenDurableConsume") then
            equip:AddTag("ListenDurableConsume")
            equip:ListenForEvent("armorhit", ListenDurableConsume)
        end
    end

    -- 武器
    if eslot == EQUIPSLOTS.HANDS and equip and equip:HasTag("taxue_ultimate_weapon") then
        if not equip:HasTag("ListenDurableConsume") then
            equip:AddTag("ListenDurableConsume")
            equip:ListenForEvent("percentusedchange", ListenFueledChange)
        end
    end
end

-- 护符主人脱下装备
local function OwnerUnEquip(_, data)
    local equip = data.item
    local eslot = data.eslot
    -- 盔甲
    if eslot == EQUIPSLOTS.BODY and equip and equip:HasTag("ListenDurableConsume") then
        equip:RemoveTag("ListenDurableConsume")
        equip:RemoveEventCallback("armorhit", ListenDurableConsume)
    end

    -- 头盔
    if eslot == EQUIPSLOTS.HEAD and equip and equip:HasTag("ListenDurableConsume") then
        equip:RemoveTag("ListenDurableConsume")
        equip:RemoveEventCallback("armorhit", ListenDurableConsume)
    end

    -- 武器
    if eslot == EQUIPSLOTS.HANDS and equip and equip:HasTag("ListenDurableConsume") then
        equip:RemoveTag("ListenDurableConsume")
        equip:RemoveEventCallback("percentusedchange", ListenFueledChange)
    end
end

local function onTemperaturedelta(inst, data)
    local eater
    if inst and inst.components and inst.components.eater then
        eater = inst.components.eater
    else
        return
    end
    local temperature = inst.components.temperature
    if not temperature or not inst.components.health then return end
    if temperature.current <= 0 and temperature.maxtemp > 0 then
        local hot_agentia = GetOne(inst, { "hot_agentia", "hot_agentia_advanced" })
        if hot_agentia then eater:Eat(hot_agentia) end
    elseif temperature.current >= temperature.overheattemp and temperature.mintemp < temperature.overheattemp then
        local ice_agentia = GetOne(inst, { "ice_agentia", "ice_agentia_advanced" })
        if ice_agentia then eater:Eat(ice_agentia) end
    end
end

-- 初始化
local function Init(owner)
    if owner and owner.components and owner.components.inventory then
        -- 盔甲
        local armor_body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        if armor_body and armor_body.prefab == "blooming_armor" then
            if not armor_body:HasTag("ListenDurableConsume") then
                armor_body:AddTag("ListenDurableConsume")
                armor_body:ListenForEvent("armorhit", ListenDurableConsume) -- 监听护甲受损
            end
        end

        -- 头盔
        local armor_head = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if armor_head and armor_head.prefab == "blooming_headwear" then
            if not armor_head:HasTag("ListenDurableConsume") then
                armor_head:AddTag("ListenDurableConsume")
                armor_head:ListenForEvent("armorhit", ListenDurableConsume) -- 监听护甲受损
            end
        end

        -- 武器
        local weapon = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if weapon and (weapon:HasTag("taxue_ultimate_weapon") and weapon.components.fueled) then
            if not weapon:HasTag("ListenDurableConsume") then
                weapon:AddTag("ListenDurableConsume")
                weapon:ListenForEvent("percentusedchange", ListenFueledChange)
            end
        end
    end
end

local function addListeners(owner)
    if not owner:HasTag("auto_amulet") then
        owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")
        owner:AddTag("auto_amulet")

        owner:ListenForEvent("equip", OwnerOnEquip)
        owner:ListenForEvent("unequip", OwnerUnEquip)
        owner:ListenForEvent("temperaturedelta", onTemperaturedelta)
    end
end

-- 穿戴护符
local function OnEquip(_, owner)
    addListeners(owner)
    Init(owner)
end

-- 脱下护符
local function OnUnEquip(_, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner:RemoveTag("auto_amulet")

    owner:RemoveEventCallback("equip", OwnerOnEquip)
    owner:RemoveEventCallback("unequip", OwnerUnEquip)
    owner:RemoveEventCallback("temperaturedelta", onTemperaturedelta)
end

-- 存档加载
local function OnLoad(inst, _)
    if inst.components.inventoryitem.owner then
        addListeners(inst.components.inventoryitem.owner)
        Init(inst.components.inventoryitem.owner)
    end
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

    inst:AddTag("taxue")
    inst:AddTag("taxue_ultimate_armor_auto_amulet")

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/taxue_ultimate_armor_auto_amulet", fn, assets, { "sand_puff" })
