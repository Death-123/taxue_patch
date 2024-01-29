-- 说明
STRINGS.NAMES.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理护符"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "告别终极装备手动给予修理材料烦恼！"
STRINGS.RECIPE_DESC.TAXUE_ULTIMATE_ARMOR_AUTO_AMULET = "自动修理你值得拥有！"

-- 查找修复材料
local function FindRepairMaterial(owner, prefab, fn)
    local prefabs = type(prefab) == "table" and prefab or { prefab }
    -- 不存在的修复物品
    if not type(fn) == "function" then
        local new_prefabs = {}
        for _, v in pairs(prefabs) do
            if prefab and Prefabs[v] then
                table.insert(new_prefabs, v)
            end
        end
        if #new_prefabs == 0 then
            return
        end
        prefabs = new_prefabs
    end

    if owner and owner.components and owner.components.inventory then
        -- 物品栏
        if owner.components.inventory.itemslots then
            for _, slot_inst in pairs(owner.components.inventory.itemslots) do
                -- 华丽便携箱
                if slot_inst and slot_inst.prefab == "gorgeous_bag" then
                    for _, bag_slot_inst in pairs(slot_inst.components.container.slots) do
                        if bag_slot_inst and type(fn) == "function" and fn(bag_slot_inst) then
                            return bag_slot_inst
                        elseif bag_slot_inst and table.contains(prefabs, bag_slot_inst.prefab) then
                            return bag_slot_inst
                        end
                    end
                end

                -- 正常物品
                if slot_inst and type(fn) == "function" and fn(slot_inst) then
                    return slot_inst
                elseif slot_inst and table.contains(prefabs, slot_inst.prefab) then
                    return slot_inst
                end
            end
        end
        -- 背包栏
        if owner.components.inventory.equipslots and owner.components.inventory.equipslots[EQUIPSLOTS.BACK] then
            local back = owner.components.inventory.equipslots[EQUIPSLOTS.BACK]
            if back.components and back.components.container then
                for _, slot_inst in pairs(back.components.container.slots) do
                    if slot_inst and type(fn) == "function" and fn(slot_inst) then
                        return slot_inst
                    elseif slot_inst and table.contains(prefabs, slot_inst.prefab) then
                        return slot_inst
                    end
                end
            end
        end
    end
end

-- 取出一个修复材料
local function GetOneRepairMaterial(owner, prefab, fn)
    local repair_material = FindRepairMaterial(owner, prefab, fn)
    if repair_material and repair_material.components.stackable then
        repair_material = repair_material.components.stackable:Get()
    end
    return repair_material
end

-- 监听耐久消耗
local function ListenDurableConsume(inst, ...)
    local owner = inst.components.inventoryitem.owner
    if owner and owner:HasTag("auto_amulet") then
        if inst.components.armor:GetPercent() < 0.7 then
            local repair_material = GetOneRepairMaterial(owner, "core_gem")
            if repair_material then
                inst.components.trader:AcceptGift(owner, repair_material)
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
                local repair_material = GetOneRepairMaterial(owner, nil, function(item)
                    return inst_fueled:CanAcceptFuelItem(item)
                end)
                if repair_material then
                    inst_fueled:TakeFuelItem(repair_material)
                end
            elseif inst.components.finiteuses then
                local repair_material = inst.prefab == "pink_crescent_sword" and "pink_core_gem" or "core_gem"
                repair_material = GetOneRepairMaterial(owner, repair_material)
                if repair_material then
                    inst.components.trader:AcceptGift(owner, repair_material)
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
        equip:RemoveEventCallback("armorhit", ListenFueledChange)
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

-- 穿戴护符
local function OnEquip(_, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")
    owner:AddTag("auto_amulet")

    Init(owner)

    owner:ListenForEvent("equip", OwnerOnEquip)
    owner:ListenForEvent("unequip", OwnerUnEquip)
end

-- 脱下护符
local function OnUnEquip(_, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner:RemoveTag("auto_amulet")

    owner:RemoveEventCallback("equip", OwnerOnEquip)
    owner:RemoveEventCallback("unequip", OwnerUnEquip)
end

-- 存档加载
local function OnLoad(inst, _)
    if inst.components.inventoryitem.owner then
        Init(inst.components.inventoryitem.owner)
    end
end

-- local assets = {
--     Asset("ANIM", "anim/amulets.zip"),
--     Asset("ANIM", "anim/torso_amulets.zip"),
--     Asset("IMAGE", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.tex"),
--     Asset("ATLAS", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"),
-- }

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

    -- 回散Buff
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

return Prefab("common/inventory/taxue_ultimate_armor_auto_amulet", fn, nil, { "sand_puff" })
