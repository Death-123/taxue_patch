GLOBAL.setmetatable(env, { __index = function (t, k) return GLOBAL.rawget(GLOBAL, k) end })
local ModConfigurationScreen = require("screens/modconfigurationscreen")
local Text = require "widgets/text"

GLOBAL.TaxuePatch = {
    id = "TaxuePatch",
    name = "踏雪补丁",
    cfg = {},
}

require("patchUtil")
TaxuePatch.dataSaver = require("dataSave")(modname)
local config = require("SomniumConfig")(modname)
TaxuePatch.config = config
TaxuePatch.cfg = function (key)
    return TaxuePatch.config:GetValue(key)
end
local cfg = TaxuePatch.cfg
function mprint(...)
    local msg, argnum = "", select("#", ...)
    for i = 1, argnum do
        local v = select(i, ...)
        msg = msg .. tostring(v) .. ((i < argnum) and "\t" or "")
    end

    local prefix = ""

    if false then
        local d = debug.getinfo(2, "Sl")
        prefix = string.format("%s:%s:", d.source or "?", d.currentline or 0)
    end

    local prettyname = KnownModIndex:GetModFancyName(TaxuePatch.name)
    return print(prefix .. "[" .. TaxuePatch.name .. " (" .. prettyname:trim() .. ")" .. "]:", msg)
end

TaxuePatch.mprint = mprint
local print = mprint

TaxuePatch.reload = function ()
    package.loaded["patchlib"] = nil
    package.loaded["command"] = nil
    collectgarbage()

    require("patchlib")
    local command = require "command"
    for name, value in pairs(command) do
        GLOBAL[name] = value
    end
end

local command = require "command"
for name, value in pairs(command) do
    GLOBAL[name] = value
end

TheInput:AddKeyDownHandler(TaxuePatch.cfg("configKeybind"), function ()
    if not (GetPlayer() and GetPlayer().prefab == "taxue") or IsPaused() then return end

    KnownModIndex:LoadModConfigurationOptions(modname)
    TheFrontEnd:PushScreen(ModConfigurationScreen(modname))
end)

-- for _, option in ipairs(KnownModIndex:GetModConfigurationOptions(modname)) do
--     TaxuePatch.cfg[option.name] = GetModConfigData(option.name)
-- end

local fileCheck = cfg("fileCheck")
if cfg("fileCheck.md5Bytes") == "C" and PLATFORM:startWith("WIN32") then
    local oldCpath = package.cpath
    package.cpath = package.cpath .. ";" .. MODROOT .. "scripts/clib/?.dll"
    TaxuePatch.md5lib = require("md5lib")
    package.cpath = oldCpath
elseif fileCheck then
    TaxuePatch.md5lib = require("md5")
end

-- local json = require "json"
require "publicList"
TaxuePatch.patchlib = require "patchlib"
TaxuePatch.superPackageLib = require "superPackageLib"
TaxuePatch.SomniumUtil = require "widgets/SomniumUtil"
TaxuePatch.RGBAColor = TaxuePatch.SomniumUtil.RGBAColor
TaxuePatch.SomniumButton = require "widgets/SomniumButton"
TaxuePatch.ControlPanel = require "screens/controlPanel"

local patchVersionStr = modinfo.version
local patchMasterVersion = patchVersionStr:gsub("%.[^.]*$", "")
local modRoot = "../mods/" .. modname .. "/"
local taxueName = "Taxue1.00"
TaxuePatch.patchVersionStr = patchVersionStr
TaxuePatch.patchMasterVersion = patchMasterVersion
TaxuePatch.name = KnownModIndex:GetModFancyName(modname):trim()
local taxueLoaded = false
local taxueEnabled = false
for _, name in pairs(KnownModIndex:GetModNames()) do
    if string.gsub(KnownModIndex:GetModFancyName(name), "%s+", "") == "踏雪" then
        local taxueInfo = KnownModIndex.savedata.known_mods[name]
        taxueLoaded = true
        taxueEnabled = taxueInfo.enabled
        taxueName = name
        break
    end
end
local taxuePath = "../mods/" .. taxueName .. "/"
TaxuePatch.modRoot = modRoot
PrefabFiles = {}

local PATCHS = {
    --库
    -- ["scripts/patchlib.lua"] = { mode = "override" },
    --面板兼容
    ["scripts/prefab_dsc_taxue.lua"] = { mode = "override" },
    --踏雪优化
    --空格收菜
    ["scripts/game_changed_taxue.lua"] = { md5 = "28860b63d48d067568767c986ac91b3e", lines = {} },
    --修复难度未初始化的崩溃
    ["scripts/widgets/taxue_level.lua"] = { md5 = "2a17053442c7efb4cdb90b5a26505f02", lines = {} },
    -- ["scripts/prefabs/taxue_treasure.lua"] = { md5 = "91b746a2f2a561202eb33f876bbad500", lines = {} },
    --按键排序
    ["scripts/press_key_taxue.lua"] = { md5 = "8e64ea9c309141fbdc1efd4e9013df7b", lines = {} },
    ["scripts/public_method_taxue.lua"] = { md5 = "8737317196a94d704ad8351dcaf697bd", lines = {} },
    --提高石板路优先级
    ["modworldgenmain.lua"] = { md5 = nil, lines = {} },
    --种子机修复
    ["scripts/prefabs/taxue_seeds_machine.lua"] = { md5 = "140bd4cce65d676b54a726827c8f17d3", lines = {} },
    --鱼缸卡顿优化
    ["scripts/prefabs/taxue_fish_tank.lua"] = { md5 = "4512a2847f757c7a2355f3f620a286a8", lines = {} },
    --定位猫猫
    ["scripts/prefabs/taxue_cat_floorlamp.lua"] = { md5 = "6e4ed7b4a09add4bf24d85eda97a3c14", lines = {} },
    -- ["scripts/prefabs/taxue_super_package_machine.lua"] = { md5 = "db41fa7eba267504ec68e578a3c31bb1", lines = {} },
    -- ["scripts/prefabs/taxue_bundle.lua"] = { md5 = "4e3155d658d26dc07183d50b0f0a1ce8", lines = {} },
    --优化收获书
    ["scripts/prefabs/taxue_book.lua"] = { md5 = "0d351683a9ebe047a86f9e7f07d995f8", lines = {} },
    --箱子可以被锤
    -- ["scripts/prefabs/taxue_locked_chest.lua"] = { md5 = "55fd6082fe93360355e9face67115bec", lines = {} },
    --宝石保存,夜明珠地上发光
    ["scripts/prefabs/taxue_equipment.lua"] = { md5 = "7b79cc50b65ad54ade29d4879b83a129", lines = {} },
    --打包机防破坏,法杖增强
    ["scripts/prefabs/taxue_staff.lua"] = { md5 = "ce04691460a4f4899f38696f68964454", lines = {} },
    --花盆碰撞
    ["scripts/prefabs/taxue_flowerpot.lua"] = { md5 = "744ce77c03038276f59a48add2d5f9db", lines = {} },
    --梅运券显示
    ["scripts/prefabs/taxue_other_items.lua"] = { md5 = "fdd70694087974bc9f1fe07ca3255cb9", lines = {} },
    --金钱就是力量
    ["scripts/prefabs/taxue.lua"] = { md5 = "865c2aea6628e0839b1dcbf835d8f6c5", lines = {} },
    --售货亭修改
    ["scripts/prefabs/taxue_sell_pavilion.lua"] = { md5 = "8de4fd20897b6c739e50abf4bb2a661d", lines = {} },
    ["scripts/prefabs/taxue_portable_sell_pavilion.lua"] = { md5 = "f3a02e1649d487cc15f4bfb26eeefdf5", lines = {} },
    --超级建造护符
    ["scripts/prefabs/taxue_greenamulet.lua"] = { md5 = "9cd5d16770da66120739a4b260f23b4d", lines = {} },
    -- ["scripts/prefabs/taxue_agentia_compressor.lua"] = { md5 = "a4d92b944eb75c53a8280966ee18ef79", lines = {} },
}

local playerSavedDataItems = {}
TaxuePatch.playerSavedDataItems = playerSavedDataItems

local ModPatchLib = require("ModPatchLib")({
    enable = taxueEnabled,
    print = mprint,
    originPath = modRoot,
    targetPath = taxuePath,
    versionStr = patchVersionStr,
    fileCheck = fileCheck,
    md5lib = TaxuePatch.md5lib,
    md5Bytes = cfg("fileCheck.md5Bytes"),
    cfgCheck = cfg,
    cfgDisable = function (key)
        config:ForceDisable(key)
        mprint("force disable config " .. key)
    end,
    PATCHS = PATCHS
})
TaxuePatch.ModPatchLib = ModPatchLib

local function addPatchFn(cfgkey, fn)
    ModPatchLib:addPatchFn(cfgkey, fn)
end

local function addPatch(path, cfgkey, line)
    ModPatchLib:addPatch(path, cfgkey, line)
end

local function addPatchs(path, cfgkey, lines)
    ModPatchLib:addPatchs(path, cfgkey, lines)
end

local oldLookAtFn = ACTIONS.LOOKAT.fn
ACTIONS.LOOKAT.fn = function (act)
    oldLookAtFn(act)
    local targ = act.target or act.invobject
    local force = TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
    targ:PushEvent("onLookAt", { doer = act.doer, force = force })
end

--#region 内存清理
addPatchFn("ingameGC", function ()
    AddPlayerPostInit(function (player)
        player:DoPeriodicTask(cfg("ingameGC") * 60, function ()
            if collectgarbage("count") > 200000 then
                print("memory usage: " .. collectgarbage("count") .. ", starting garbage collect")
                collectgarbage("collect")
            end
        end)
    end)
end)
--#endregion

--#region 踏雪优化

--移除掉落物变灰烬
addPatchFn("taxueFix.dropAsh", function ()
    local special_cooked_prefabs = {
        ["trunk_summer"] = "trunk_cooked",
        ["trunk_winter"] = "trunk_cooked",
        ["fish_raw"] = "fish_med_cooked",
    }
    local function AddSpecialCookedPrefab(prefab, cooked_prefab)
        special_cooked_prefabs[prefab] = cooked_prefab
    end
    local function CheckBurnable(self, prefabs)
        -- check burnable
        if not self.inst.components.fueled and self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
            for k, v in pairs(prefabs) do
                local cookedAfter = v .. "_cooked"
                local cookedBefore = "cooked" .. v

                if special_cooked_prefabs[v] then
                    prefabs[k] = special_cooked_prefabs[v]
                elseif PrefabExists(cookedAfter) then
                    prefabs[k] = cookedAfter
                elseif PrefabExists(cookedBefore) then
                    prefabs[k] = cookedBefore
                end
            end
        end
    end
    AddComponentPostInit("lootdropper", function (inst)
        inst.AddSpecialCookedPrefab = AddSpecialCookedPrefab
        inst.CheckBurnable = CheckBurnable
    end)
end)
--掉落优化
addPatchFn("taxueFix.betterDrop", function ()
    AddGamePostInit(function ()
        GLOBAL.TaxueOnKilled = TaxuePatch.TaxueOnKilled
    end)

    AddComponentPostInit("lootdropper", function (inst)
        local oldDropLoot = inst.DropLoot
        inst.DropLoot = function (self, pt, loots)
            if loots then
                oldDropLoot(self, pt, loots)
            else
                local prefabs = self:GenerateLoot()
                self:CheckBurnable(prefabs)
                local dorpList = {}
                for _, name in pairs(prefabs) do
                    dorpList[name] = dorpList[name] and dorpList[name] + 1 or 1
                end

                local target = self.inst
                local package = TaxuePatch.GetNearestPackageMachine(target)

                TaxuePatch.StackDrops(target, dorpList, package)
            end
        end
    end)
end)
--空格收菜
addPatchs("scripts/game_changed_taxue.lua", "taxueFix.taxueMoe", {
    { index = 3118, type = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
})
--修复难度未初始化的崩溃
addPatch("scripts/widgets/taxue_level.lua", "taxueFix.levelWidgetFix", { index = 33, type = "add", content = "    if not (GetPlayer().difficulty and GetPlayer().difficulty_low) then return end" })
--按键排序
addPatch("scripts/press_key_taxue.lua", "taxueFix.itemSort", {
    index = 251,
    endIndex = 357,
    content = [[                    TaxuePatch.TaxueSortContainer(GetPlayer())]]
})
--增强一键入箱
addPatchs("scripts/press_key_taxue.lua", "taxueFix.intoChest", {
    { index = 176, endIndex = 198, content = [[TaxuePatch.TaxueIntoChestKey()]] },
})
addPatchFn("taxueFix.intoChest", function ()
    AddGamePostInit(function ()
        GLOBAL.TaxueIntoChest = TaxuePatch.IntoChest
    end)
end)
--种子机修复
addPatchFn("taxueFix.seedsMachineFix", function ()
    local function pressButton(inst)
        local slots = inst.components.container.slots
        local has = false
        local resultList = { seeds = 0 }
        for slot, v in pairs(slots) do
            local seed_name = string.lower(v.prefab .. "_seeds")
            local canAccept = v and v.components.edible and GLOBAL.Prefabs[seed_name] and
                (v.components.edible.foodtype == "VEGGIE" or v.components.edible.foodtype == "FRUIT")
            mprint(seed_name, canAccept)
            mprint(v, v.components.edible, GLOBAL.Prefabs[seed_name], v.components.edible.foodtype == "VEGGIE" or v.components.edible.foodtype == "FRUIT")
            if canAccept then
                has = true
                --处理原材料堆叠数量
                local stacksize = v.components.stackable and v.components.stackable.stacksize or 1
                inst.components.container:RemoveItemBySlot(slot):Remove() --删除材料
                local num_seeds = 0
                local nomal_seeds = 0
                for i = 1, stacksize do
                    num_seeds = num_seeds + math.random(2)
                    nomal_seeds = nomal_seeds + math.random(0, 1)
                end
                resultList[seed_name] = resultList[seed_name] and resultList[seed_name] + num_seeds or num_seeds
                resultList.seeds = resultList.seeds + nomal_seeds
            end
        end
        if not has then
            GetPlayer().components.talker:Say("你在分解个寂寞呢？")
        else
            for seedName, amount in pairs(resultList) do
                TaxueGiveItem(inst, seedName, amount)
            end
        end
    end
    AddPrefabPostInit("taxue_seeds_machine", function (inst)
        inst.components.container.widgetbuttoninfo.fn = pressButton
    end)
end)
--黄金宝箱优化
addPatchFn("taxueFix.goldenChest", function ()
    AddPrefabPostInit("taxue_goldenchest", function (inst)
        inst.components.container.widgetbuttoninfo.fn = TaxuePatch.GoldenChestButton
    end)
end)
--鱼缸卡顿优化
addPatchs("scripts/prefabs/taxue_fish_tank.lua", "taxueFix.fishTankFix", {
    {
        index = 46,
        content = [[
            if not inst.components.workable then
                inst:AddComponent("workable")
            elseif inst.components.workable.action == ACTIONS.DIG then
                return
            end
        ]]
    },
    {
        index = 55,
        content = [[
            if not inst.components.workable then
                inst:AddComponent("workable")
            elseif inst.components.workable.action == ACTIONS.HAMMER then
                return
            end
        ]]
    },
})
--优化收获书
addPatchs("scripts/prefabs/taxue_book.lua", "taxueFix.harvestBookPatch", {
    { index = 21, type = "add",                                                                                       content = [[                local itemList = {}]] },
    { index = 36, content = [[                            TaxuePatch.MultHarvest(v.components.crop, itemList, true)]] },
    { index = 49, type = "add",                                                                                       content = [[                TaxuePatch.GiveItems(reader, itemList)]] },
})
--自动保存CD
addPatchFn("taxueFix.autoSavePatch", function ()
    AddComponentPostInit("autosaver", function (comp, inst)
        local doSave = comp.DoSave
        comp.DoSave = function (self)
            local cd = TaxuePatch.cfg("taxueFix.autoSavePatch")
            if cd and (not self.lastSaveTime or GetTime() - self.lastSaveTime > cd * 60) then
                self.lastSaveTime = GetTime()
                doSave(self)
            end
        end
    end)
end)
--修复哈姆大蛇初始化崩溃
addPatchFn("taxueFix.fixPugalisk", function ()
    AddPrefabPostInit("pugalisk", function (inst)
        local oldOnLoadPostPass = inst.OnLoadPostPass
        inst.OnLoadPostPass = function (inst, newents, data)
            if not (data and data.home and newents and newents[data.home]) then return end
            return oldOnLoadPostPass(inst, newents, data)
        end
    end)
end)
--每天减战斗力可以用钱抵消
addPatch("scripts/prefabs/taxue.lua", "taxueFix.moneyIsPower", {
    index = 232,
    type = "add",
    content = [[
        local min = TaxuePatch.cfg("taxueFix.moneyIsPower.minMoney")
		if min and inst.bank_value > min then
			local factor = TaxuePatch.cfg("taxueFix.moneyIsPower.combatFactor")
			local cost = math.min(inst.bank_value - min, num * factor)
			inst.bank_value = inst.bank_value - cost
			num = num - cost / factor
			local showBanner = TaxuePatch.cfg("displaySetting.showBanner") and TaxuePatch.dyc and TaxuePatch.dyc.bannerSystem
			local BANNER_COLOR = TaxuePatch.RGBAColor(TaxuePatch.cfg("displaySetting.showBanner.bannerColor"))
			local bannerColor = showBanner and TaxuePatch.dyc.RGBAColor(BANNER_COLOR:Get())
			if showBanner then
				TaxuePatch.dyc.bannerSystem:ShowMessage(("有钱能使磨推鬼! 使用%s抵消%s战斗力降低!"):format(TaxuePatch.FormatCoins(cost * 100), TaxuePatch.FormatNumber(cost / factor)), 5, bannerColor)
			end
		end
    ]]
})
--提高石板路的优先级
addPatch("modworldgenmain.lua", "taxueFix.cobbleroad", {
    index = 61,
    type = "add",
    content = [[
        local grounds = require('worldtiledefs').ground
        local cobbleroad
        for i, tile in pairs(grounds) do
            if cobbleroad then
                grounds[i - 1] = grounds[i]
            elseif tile[1] == GROUND.COBBLEROAD then
                cobbleroad = tile
            end
        end
        grounds[#grounds] = cobbleroad
    ]]
})
--修光源阻止放置建筑
addPatchFn(function ()
    AddPrefabPostInit("taxue_light_holder", function (inst)
        inst:AddTag("NOBLOCK")
        inst:AddTag("FX")
    end)
end)
--#endregion

--#region 猫猫定位
addPatchFn("teleportCat", function ()
    AddPrefabPostInit("taxue_cat_floorlamp", function (inst)
        inst:ListenForEvent("onLookAt", function (inst, data)
            if data.force then
                TaxuePatch.CostTeleport(inst)
                TaXueSay("折越成功!")
            end
        end)
    end)
end)
addPatchFn("teleportCat.mapTeleport", function ()
    AddClassPostConstruct("screens/mapscreen", function (MapScreen)
        local _oldOnControl = MapScreen.OnControl
        function MapScreen:OnControl(control, down)
            if control == CONTROL_ACCEPT then
                if down then
                    self.startPos = TheInput:GetScreenPosition()
                else
                    if TheInput:GetScreenPosition():DistSq(self.startPos) < 1 then
                        if not (GetWorld().components.interiorspawner and GetWorld().components.interiorspawner:IsInInterior()) then
                            local x, y, z = self.minimap:GetWorldMousePosition():Get()
                            local notags = { "INLIMBO", "NOCLICK", "catchable", "fire", "player" }
                            local ents = TheSim:FindEntities(x, y, z, 5, nil, notags)
                            for _, entity in pairs(ents) do
                                if entity.prefab == "taxue_cat_floorlamp" then
                                    entity:PushEvent("onLookAt", { doer = GetPlayer(), force = true })
                                    TheFrontEnd:PopScreen()
                                    return true
                                end
                            end
                        end
                    end
                    self.startPos = nil
                end
            end
            return _oldOnControl(self, control, down)
        end
    end)
end)
--#endregion

--#region 一键使用

--券类
addPatchs("scripts/prefabs/taxue_other_items.lua", "oneClickUse.ticket", {
    --利息券连地上一起读
    {
        index = 62,
        type = "add",
        content = [[
            for _, entity in ipairs(TaxuePatch.GetNearByEntities(reader, 15, function(entity) return entity.prefab == "interest_ticket" end)) do
                num = num + entity.interest
                entity:Remove()
            end
        ]]
    },
    --战利品券一键填装
    {
        index = 72,
        type = "add",
        content = [[
        if inst.prefab == "loot_ticket_fill" and inst.loot_multiple and inst.loot_multiple < 20 then
			local hasLootTicket
			local function fill(container, item, slot)
				if item.prefab == "loot_ticket" and item.loot_multiple < 20 then
					hasLootTicket = true
					if inst.loot_multiple + item.loot_multiple <= 20 then
						inst.loot_multiple = inst.loot_multiple + item.loot_multiple
						container:RemoveItemBySlot(slot):Remove()
					else
						item.loot_multiple = inst.loot_multiple + item.loot_multiple - 20
						inst.loot_multiple = 20
						return true
					end
				end
			end
            local oldLoot_multiple = inst.loot_multiple
			TaxuePatch.TraversalAllInventory(reader, fill, true)
			if hasLootTicket then
				TaXueSay(("战利品券已填装！%d -> %d"):format(oldLoot_multiple, inst.loot_multiple))
				return true
			end
		end
        ]]
    }
})
--一键湛青升级
addPatchs("scripts/prefabs/taxue_staff.lua", "oneClickUse.blueStaff", {
    {
        index = 336,
        type = "add",
        content = [[
            local ents = TaxuePatch.GetNearByEntities(inst, 10, "blue_staff")
            local num, numhas = 0, 0
            local prefabLevel = {
                blooming_sword = 100,
                black_falchion_sword = 100,
                lightning_crescent_sword = 100,
                surprised_sword = 100,
                blooming_armor = 10,
                black_blooming_armor = 10,
                blooming_headwear = 10,
                black_blooming_headwear = 10,
            }
            if prefabLevel[target.prefab] then
                num = prefabLevel[target.prefab] - 1 - target.level
            end
            for i = 1, num do
                if ents[i] then
                    ents[i]:Remove()
                    numhas = numhas + 1
                else
                    break
                end
            end
            TaXueSay(("等级提升！%d -> %d"):format(target.level, target.level + numhas + 1))
            for _ = 1, numhas + 1 do
            ]]
    },
    {
        index = 370,
        type = "add",
        content = [[        end]]
    },
})
--药水压缩机压宝箱药水
-- addPatchs("scripts/prefabs/taxue_agentia_compressor.lua", "oneClickUse.agentiaCompressor", {
--     {
--         index = 33,
--         type = "add",
--         content = [[    local chest_agentia_num = inst.components.container:Count("chest_agentia")]]
--     },
--     {
--         index = 66,
--         type = "add",
--         content = [[
--     if chest_agentia_num > 0 then
--         local list = {
--             { "locked_corkchest",            "corkchest_key" },
--             { "locked_treasurechest",        "treasurechest_key" },
--             { "locked_skullchest",           "skullchest_key" },
--             { "locked_pandoraschest",        "pandoraschest_key" },
--             { "locked_minotaurchest",        "minotaurchest_key" },
--             { "locked_taxue_terrariumchest", "terrarium_key" },
--             { "locked_taxue_poisonchest",    "poison_key" },
--             { "mini_pandoraschest",          "crystal_ball_taxue" }, --箱中箱
--         }
--         local keys = {}
--         for _ = 1, chest_agentia_num do
--             local chest_list = list[math.random(#list)]
--             TaxuePatch.ListAdd(keys, chest_list[2])
--             local chest
--             if chest_list[1] == "mini_pandoraschest" then --箱中箱特殊处理，这里需要手动添加物品
--                 chest = SpawnPrefab(chest_list[1])
--                 for _, v in ipairs(chest.advance_list) do
--                     local item = SpawnPrefab(v)                   --预制表内的物品
--                     if item ~= nil then
--                         chest.components.container:GiveItem(item) --刷物品进箱子
--                     end
--                 end
--             else
--                 chest = SpawnPrefab(chest_list[1])
--             end
--             if chest then
--                 local angle = math.random() * 2 * PI
--                 chest.Transform:SetPosition((Vector3(inst.Transform:GetWorldPosition()) + Vector3(math.cos(angle), 0, math.sin(angle)) * 5):Get())
--                 TaxueFx(chest, "statue_transition_2") --犀牛刷宝箱扒拉特效
--                 TaxueFx(chest, "statue_transition") --犀牛嗖~霹雳特效
--             end
--         end
--         TaxuePatch.StackDrops(inst, keys)
--         inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
--         GetPlayer().components.autosaver:DoSave()
--     end]]
--     }
-- })

--点怪成金可以点召唤书
addPatch("scripts/prefabs/taxue_book.lua", "oneClickUse.goldBook", {
    index = 780,
    endIndex = 803,
    content = [[
            local goldenMap = {
                bunnyman = "golden_bunnyman",
                book_bunnyman = "golden_bunnyman",
                pigman = "golden_pigman",
                book_pigman = "golden_pigman",
                pigguard = "golden_pigman",
                wildbore = "golden_pigman",
                book_rocky = "golden_rocky",
                rocky = "golden_rocky",
            }
            for __, v in pairs(ents) do
                if v and goldenMap[v.prefab] then
                    has = true
                    local golden_monster = goldenMap[v.prefab]
                    if v.components.health then
                        v.components.lootdropper:SetLoot()
                        v.components.health:Kill()	--先击杀保证猪人房能再次刷猪
                    end
                    SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())  -- 生成摧毁动画并设坐标
		            SpawnPrefab("lightning").Transform:SetPosition(v.Transform:GetWorldPosition())  -- 生成闪电动画并设坐标
                    local amount = 1
                    if v.components.finiteuses then
                        local uses = v.components.finiteuses.current
                        if uses > num then
                            v.components.finiteuses.current = uses - num
                            amount = num
                        else
                            v:Remove()
                            amount = uses
                        end
                    else
                        v:Remove()
                    end
                    for _ = 1, amount do
                        local newGoldenMonster = SpawnPrefab(golden_monster)
                        newGoldenMonster.Transform:SetPosition(v.Transform:GetWorldPosition())
                    end
                    num = num - amount
                    if num == 0 then break end
            ]]
})
--一键水晶煤球
addPatchFn("oneClickUse.crystalBall", function ()
    AddPrefabPostInit("crystal_ball_taxue", function (_inst)
        _inst:AddComponent("useableitem")
        _inst.components.useableitem:SetCanInteractFn(function (inst) return GetPlayer().bank_value > 0.01 and inst.lv < 10 end)
        _inst.components.useableitem:SetOnUseFn(function (inst)
            if not inst.task then
                inst.task = inst:DoPeriodicTask(cfg("oneClickUse.crystalBall.timeGap"), function ()
                    local player = GetPlayer()
                    if player.bank_value > 0.01 and inst.lv < 10 then
                        player.bank_value = player.bank_value - 0.01
                        inst.components.trader.onaccept(inst)
                        TaXueSay("给梅老板投币喵！")
                        local soundNum = cfg("oneClickUse.crystalBall.soundNum")
                        if soundNum then
                            player.SoundEmitter:PlaySound("drop/sfx/drop", nil, soundNum)
                        end
                    else
                        inst.task:Cancel()
                        inst.task = nil
                    end
                end)
            end
        end)
    end)
    AddPrefabPostInit("golden_statue", function (_inst)
        _inst:ListenForEvent("trade", function (inst, data)
            if data.item.prefab == "crystal_ball_taxue" then
                if not inst.task then
                    local ball
                    inst.task = inst:DoPeriodicTask(cfg("oneClickUse.crystalBall.timeGap"), function ()
                        if ball then
                            if not ball.task then
                                inst.components.trader:AcceptGift(GetPlayer(), ball)
                                TaxueFx(ball, "small_puff")
                                TaXueSay("给梅老板喂球喵！")
                                ball = nil
                            end
                            return
                        end
                        local ents = TaxuePatch.GetNearByEntities(inst, 15, "crystal_ball_taxue")
                        local _, ent = next(ents)
                        if ent then
                            if ent.components.useableitem:CanInteract() then
                                ent.components.useableitem:StartUsingItem()
                            end
                            ball = ent
                        else
                            inst.task:Cancel()
                            inst.task = nil
                        end
                    end)
                end
            end
        end)
    end)
end)
--#endregion

--#region 梅运券修改

playerSavedDataItems.fortune_day = true
addPatchFn("fortunePatch.usePatch", function ()
    AddPrefabPostInit("taxue", function (inst)
        local function daycomplete(inst, data)
            if TUNING.FUCK_DAY == true then
                local player = GetPlayer()
                if player.fortune_day and player.fortune_day > 0 then
                    player.fortune_day = player.fortune_day - 1
                    local str = TaxuePatch.GetFortuneStr(player)
                    TaxuePatch.showBanner(str[1])
                    TaxuePatch.showBanner(str[2])
                end
            end
        end
        inst:ListenForEvent("daycomplete", daycomplete, GetWorld())
    end)
    AddPrefabPostInit("fortune_ticket", function (inst)
        inst.components.book:SetOnReadFn(function (inst, reader)
            local amount = inst.components.stackable.stacksize
            reader.fortune_day = reader.fortune_day and reader.fortune_day + amount or amount
            TaXueSay("已装载梅运券: " .. amount)
            inst:Remove()
            return true
        end)
    end)
    AddPrefabPostInit("fortune_change_ticket", function (inst)
        local onread = inst.components.book.onread
        inst.components.book:SetOnReadFn(function (inst, reader)
            if inst.fortune_day and inst.fortune_day > 0 then inst.fortune_day = inst.fortune_day - 1 end
            return onread(inst, reader)
        end)
    end)
end)
--梅运券显示
addPatchs("scripts/prefabs/taxue_other_items.lua", "fortunePatch.showNum", {
    { index = 226, content = [[		TaXueSay("明天估计是"..str..("\n梅运值: %.2f"):format(reader.badluck_num[2]))]] },
    { index = 239, content = [[		TaXueSay(str..("\n梅运值: %.2f"):format(reader.badluck_num[2]))]] }
})
--#endregion

--#region 物品增强

--箱子可以被锤
addPatchFn("buffThings.chestCanHammer", function ()
    local miniChests = {
        "mini_pandoraschest",
        "mini_pandoraschest_advanced",
        "mini_terrariumchest",
    }
    local function onhammered(inst)
        inst.components.container:DropEverything()
        inst.components.container.onclosefn(inst)
    end
    for _, name in pairs(miniChests) do
        AddPrefabPostInit(name, function (inst)
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
        end)
    end
end)
--打包机防破坏
--[[ addPatchFn("buffThings.packageMachineCantHammer", function()
    local items = {
        super_package_machine = true
    }
    AddPrefabPostInit("golden_staff", function(inst)
        local oldspelltest = inst.components.spellcaster.spelltest
        inst.components.spellcaster.spelltest = function(inst, caster, target)
            if target and items[target.prefab] then
                return true
            else
                return oldspelltest(inst, caster, target)
            end
        end
        local oldsspell = inst.components.spellcaster.spell
        inst.components.spellcaster.spell = function(inst, target)
            if items[target.prefab] then
                if target.components.container then
                    target.components.container:Close()
                    target.components.container:DropEverything()
                end
                target.components.lootdropper:DropLoot()
                SpawnPrefab("collapse_small").Transform:SetPosition(target.Transform:GetWorldPosition())
                target.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
                target:Remove()

                inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
                if inst.components.stackable then
                    inst.components.stackable:Get(1):Remove()
                else
                    inst:Remove()
                end
            else
                oldsspell(inst, target)
            end
        end
    end)
    for name, _ in pairs(items) do
        AddPrefabPostInit(name, function(inst)
            inst:RemoveComponent("workable")
        end)
    end
end) ]]

--夜明珠扔地上发光
addPatchFn("buffThings.lightPearlBuff", function ()
    local lightPearls = {
        "equipment_light_pearl",
        "equipment_light_pearl_re",
        "equipment_light_pearl_rea",
    }
    for _, name in pairs(lightPearls) do
        AddPrefabPostInit(name, function (inst)
            inst.components.inventoryitem:SetOnDroppedFn(function (self, dropper)
                if self.Light then self.Light:SetRadius(inst.equip_value) end
            end)
        end)
    end
end)
--禁止宝石自动保存
addPatchs("scripts/prefabs/taxue_equipment.lua", "buffThings.disableGemSave", {
    { index = 348, type = "override" },
})
--售货亭修改
addPatchFn("buffThings.sellPavilion", function ()
    AddPrefabPostInit("taxue_sell_pavilion", function (inst)
        inst.components.container.widgetbuttoninfo.fn = TaxuePatch.SellPavilionSellItems
    end)
    AddPrefabPostInit("taxue_portable_sell_pavilion", function (inst)
        inst.components.container.widgetbuttoninfo.fn = TaxuePatch.SellPavilionSellItems
    end)
end)
--移除花盆碰撞
addPatchFn("buffThings.flowerporPhysics", function ()
    local pots = {
        "taxue_flowerpot",           --蔬菜花盆
        "taxue_flowerpot_golden",    --黄金蔬菜花盆
        "taxue_flowerpot_water",     --蔬菜水盆
        "taxue_flowerpot_volcano",   --火山花盆
        "taxue_flowerpot_ancient",   --远古花盆
        "taxue_flowerpot_livinglog", --活木盆
        "taxue_flowerpot_colorful",  --五彩花盆
    }
    for _, pot in pairs(pots) do
        AddPrefabPostInit(pot, RemovePhysicsColliders)
    end
end)
--法杖增强
addPatchFn("buffThings.buffStaff", function ()
    local function changeTool(inst, dig)
        if dig ~= nil then inst.dig = dig end
        local symbol = "swap_" .. inst.prefab .. (inst.dig and "_dig" or "")
        if inst.components.useableitem:CanInteract() then
            GetPlayer().AnimState:OverrideSymbol("swap_object", symbol, symbol)
            GetPlayer().AnimState:Show("ARM_carry")
            GetPlayer().AnimState:Hide("ARM_normal")
        end
        if inst.dig then
            inst:RemoveTag("taxue_mow")
            inst:RemoveComponent("tool")
            inst:AddComponent("tool")
            inst.components.tool:SetAction(ACTIONS.DIG, inst.work_efficiency)
        else
            inst:AddTag("taxue_mow")
            inst:RemoveComponent("tool")
            inst:AddComponent("tool")
            inst.components.tool:SetAction(ACTIONS.SHEAR)                        --剪
            inst.components.tool:SetAction(ACTIONS.CHOP, inst.work_efficiency)   --砍
            inst.components.tool:SetAction(ACTIONS.MINE, inst.work_efficiency)   --凿
            inst.components.tool:SetAction(ACTIONS.HAMMER, inst.work_efficiency) --敲
            inst.components.tool:SetAction(ACTIONS.HACK, inst.work_efficiency)   --砍刀
            inst.components.tool:SetAction(ACTIONS.TAXUE_MOW)                    --割
        end
        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    local staffs = {
        blue_staff = { work_efficiency = cfg("buffThings.buffStaff.staffMult"), speed = cfg("buffThings.buffStaff.staffSpeed") },
        forge_staff = { work_efficiency = cfg("buffThings.buffStaff.forgeStaffMult"), speed = cfg("buffThings.buffStaff.staffSpeed") },
        colourful_staff = { speed = cfg("buffThings.buffStaff.colorfulStaffSpeed") },
    }
    for name, data in pairs(staffs) do
        AddPrefabPostInit(name, function (inst)
            if data.work_efficiency then
                inst.work_efficiency = data.work_efficiency
                inst.components.useableitem:SetOnUseFn(function (inst)
                    if inst.components.tool then
                        changeTool(inst, not inst.dig)
                    end
                end)
                local onload = inst.OnLoad
                inst.OnLoad = function (inst, data)
                    onload(inst, data)
                    changeTool(inst)
                end
            end
            if data.speed then
                inst.components.equippable.walkspeedmult = data.speed
            end
        end)
    end
end)
--超级建造护符耐久
addPatch("scripts/prefabs/taxue_greenamulet.lua", "buffThings.greenAmulet", {
    index = 59,
    endIndex = 60,
    content = [[
            local num = TaxuePatch.cfg("buffThings.greenAmulet")
            self.inst.time = self.inst.time + num * stacksize
            GetPlayer().components.talker:Say("耐久+"..(num * stacksize).."次")
    ]]
})
--宝藏去质黑名单
addPatchs("scripts/prefabs/taxue_book.lua", "buffThings.treasureDeprotonation", {
    {
        index = 1152,
        content = [[                    if v and v:IsValid() and v:HasTag("taxue_treasure") then]]
    },
    {
        index = 1160,
        content = [[
                                local blackList = TaxuePatch.config:GetSelectdValues("buffThings.treasureDeprotonation")
                                if not table.contains(blackList, str) then
                                    monster.components.health:Kill()
                                end
        ]]
    },
    {
        index = 1199,
        content = [[                    if v and v:IsValid() and v:HasTag("taxue_treasure") then]]
    },
    {
        index = 1207,
        content = [[
                                local blackList = TaxuePatch.config:GetSelectdValues("buffThings.treasureDeprotonation")
                                if not table.contains(blackList, str) then
                                    monster.components.health:Kill()
                                end
        ]]
    },
})
--五彩宝石加速合成
addPatchFn("buffThings.colorfulGemCraft", function ()
    local function finish(comp)
        return function (self, doer, target)
            local task = target.components[comp].task
            if task then
                self.inst.components.stackable:Get():Remove()
                if task.onfinish then
                    if task.fn then
                        if task.arg then
                            task.fn(unpack(task.arg))
                        else
                            task.fn()
                        end
                    end
                    if task.arg then
                        task.onfinish(task, true, unpack(task.arg))
                    else
                        task.onfinish(task, true)
                    end
                end
                task:Cleanup()
            end
        end
    end
    local entMap = {
        taxue_cookpot_portable = finish("stewer"),
        taxue_cookpot = finish("stewer"),
        taxue_agentia_station = finish("melter"),
        taxue_coal_furnace = finish("melter"),
    }

    AddPrefabPostInit("colorful_gem", function (inst)
        inst:AddComponent("itemGiver")
        inst.components.itemGiver.test = function (self, doer, target)
            return entMap[target.prefab]
        end
        inst.components.itemGiver.fn = function (self, doer, target)
            entMap[target.prefab](self, doer, target)
        end
    end)
end)
--增强青龙aoe
addPatchFn("buffThings.falchionAoe", function ()
    local function getTargets(target, range, attacker)
        local test = function (ent)
            return ent ~= target and attacker.components.combat:CanTarget(ent) and not attacker.components.combat:IsAlly(ent)
        end
        return TaxuePatch.GetNearByEntities(target, range, test, nil, { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR" })
    end
    AddPrefabPostInit("falchion_sword", function (sword)
        sword.components.weapon:SetOnAttack(function (inst, attacker, target)
            for _, ent in pairs(getTargets(target, 3, attacker)) do
                ent.components.combat:GetAttacked(attacker, attacker.components.combat:CalcDamage(ent, inst) * 0.4, inst)
            end
        end)
    end)
    AddPrefabPostInit("black_falchion_sword", function (sword)
        sword.components.weapon:SetOnAttack(function (inst, attacker, target)
            TaxueFx(target, "laser_explosion", 1, { 0, 104, 139 })
            inst.components.fueled:DoDelta(-1)
            if inst.components.fueled:IsEmpty() then
                inst.components.talker:Say("耐久耗尽！")
            end
            local range = inst.forge_level >= 20 and 4 or 3
            local dmg_percent = inst.level * 0.005 + 0.5
            for _, ent in pairs(getTargets(target, range, attacker)) do
                ent.components.combat:GetAttacked(attacker, attacker.components.combat:CalcDamage(ent, inst) * dmg_percent, inst)
            end
        end)
    end)
end)
--金砖取出
addPatchFn("buffThings.goldBrick", function ()
    AddPrefabPostInit("gold_brick", function (_inst)
        _inst:AddComponent("useableitem")
        _inst.components.useableitem:SetCanInteractFn(function (inst) return inst.taxue_coin_value > 3 end)
        _inst.components.useableitem:SetOnUseFn(function (inst)
            local value = inst.taxue_coin_value
            local goldMaxNum = math.floor(value / 3)
            local maxTake = cfg("buffThings.goldBrick.maxGoldNum")
            local goldNum = math.min(goldMaxNum, maxTake)
            if goldNum > 0 then
                inst.taxue_coin_value = value - goldNum * 3
                TaxuePatch.GiveItems(inst, { goldnugget = goldNum })
            end
        end)
    end)
end)
--龙猫荧光果换便便
addPatch("scripts/public_method_taxue.lua", "buffThings.totoroPoop", {
    index = 481,
    type = "add",
    content = [[    Refine("lightbulb","poop",1)]]
})
--#endregion

--#region 打包系统
addPatchFn("package", function ()
    AddPrefabPostInit("super_package", function (inst)
        local dataItems = {
            isPatched = true,
            name = true,
            type = true,
            amount = true,
            amountMap = true,
            hasValue = true,
            valueMap = true,
            taxue_coin_value = true,
        }
        OverrideSLData(inst, dataItems)
        inst.components.unwrappable:SetOnUnwrappedFn(function (inst, pos, doer)
            TaxuePatch.superPackageLib.UnpackSuperPackage(inst)
        end)
    end)
    AddPrefabPostInit("book_package_super", function (inst)
        inst.components.book.onread = function (inst, reader)
            if inst.time > 0 then
                TaxuePatch.superPackageLib.DoPack(inst, true)
                inst.time = inst.time - 1
            else
                GetPlayer().components.talker:Say("耐久都没了你在读个寂寞呢！")
            end
            return true
        end
    end)
    AddPrefabPostInit("super_package_machine", function (inst)
        local dataItems = {
            isPatched = true,
        }
        OverrideSLData(inst, dataItems)
        inst.getPackage = function (self)
            if self.switch == "off" then return nil end
            local slots = self.components.container.slots
            local package = nil
            for _, v in pairs(slots) do
                if v.prefab == "super_package" then
                    package = v
                    break
                end
            end
            if package == nil then
                package = TaxuePatch.superPackageLib.SpawnPackage()
                self.components.container:GiveItem(package)
            end
            return package
        end

        inst.components.machine.turnonfn = function (self)
            self.components.container:Close()
            self.components.container.canbeopened = false

            local diamond_num = self.components.container:Count("taxue_diamond")
            local slots = self.components.container.slots
            local package = nil
            for __, v in pairs(slots) do
                if v.prefab == "super_package" then
                    package = v
                end
            end
            if diamond_num < 1 and self.switch == "off" then
                TaXueSay("请至少放入一颗钻石再启动！")
                self:DoTaskInTime(0, function ()
                    self.components.machine:TurnOff()
                end)
                return
            end
            if self.components.container:IsFull() and package == nil then
                TaXueSay("内部空间已满，请留出空余位置！")
                self:DoTaskInTime(0, function ()
                    self.components.machine:TurnOff()
                end)
                return
            end
            TaXueSay("启动成功！")
            TaxueFx(self, "clouds_bombsplash", 1, { 148, 0, 211 })
            self.Light:Enable(true)
            if self.switch == "off" then
                self.components.container:ConsumeByName("taxue_diamond", 1)
            end
            if not self.isPatched and self.item_list and next(self.item_list) then
                local tempPackage = SpawnPrefab("super_package")
                tempPackage.item_list = self.item_list
                if package then
                    package = TaxuePatch.superPackageLib.MergePackage(package, tempPackage)
                else
                    package = TaxuePatch.superPackageLib.TransformPackage(tempPackage)
                end
            end
            if package and not package.isPatched then
                package = TaxuePatch.superPackageLib.TransformPackage(package)
            end
            self.isPatched = true
            self.switch = "on"
            self.task = self:DoPeriodicTask(5, function ()
                TaxuePatch.superPackageLib.DoPack(inst, false)
            end)
        end
        inst.components.machine.turnofffn = function (self)
            --移除空包裹
            local container = self.components.container
            for slot, v in pairs(container.slots) do
                if v.prefab == "super_package" then
                    if next(v.item_list) == nil and container:IsEmpty() then
                        container:RemoveItemBySlot(slot):Remove()
                        print("包裹已移除")
                    end
                end
            end
            self.Light:Enable(false)
            self.switch = "off"
            self.components.container.canbeopened = true
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
    end)
end)
--#endregion

--#region 自动护符
if taxueEnabled and cfg("autoAmulet") then
    table.insert(PrefabFiles, "taxue_ultimate_armor_auto_amulet")
    AddPlayerPostInit(function (player)
        if player.prefab == "taxue" then
            Recipe("taxue_ultimate_armor_auto_amulet",
                {
                    Ingredient("chest_essence", 5, "images/inventoryimages/chest_essence.xml"),
                    Ingredient("thulecite", 10),
                    Ingredient("greengem", 5)
                },
                RECIPETABS.TAXUE_TAB, TECH.SCIENCE_TWO).atlas = "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"
        end
    end)
    addPatch("scripts/prefabs/taxue_equipment.lua", nil, { index = 115 })
end
--#endregion

local customPatch = kleiloadlua(modRoot .. "custompatch.lua")()
if next(customPatch) then
    for path, lines in pairs(customPatch) do
        addPatchs(path, nil, lines)
    end
end

--开始patch
if taxueLoaded then
    local patchEnable = cfg("patchEnable")
    ModPatchLib:PatchAll(not patchEnable)

    AddPrefabPostInit("taxue", function (inst)
        OverrideSLData(inst, playerSavedDataItems)
    end)
    local oldSave = KnownModIndex.Save
    function KnownModIndex:Save(...)
        for name, data in pairs(self.savedata.known_mods) do
            if name == modname and not data.enabled then
                ModPatchLib:PatchAll(true)
            end
        end
        oldSave(self, ...)
    end
end

AddClassPostConstruct("widgets/itemtile", function (origin)
    local oldOnGainFocus = origin.OnGainFocus
    origin.OnGainFocus = function (self, ...)
        TaxuePatch.hoverItem = self.item
        oldOnGainFocus(self, ...)
    end
    local oldOnLoseFocus = origin.OnLoseFocus
    origin.OnLoseFocus = function (self, ...)
        self.inst:DoTaskInTime(FRAMES, function ()
            if TaxuePatch.hoverItem == self.item then TaxuePatch.hoverItem = nil end
        end)
        oldOnLoseFocus(self, ...)
    end
end)

AddClassPostConstruct("widgets/mapwidget", function (MapWidget)
    MapWidget.mapOffset = Vector3(0, 0, 0)

    MapWidget._oldOnUpdate = MapWidget.OnUpdate
    function MapWidget:OnUpdate(...)
        if not self.shown then return end

        if TheInput:IsControlPressed(CONTROL_PRIMARY) then
            local pos = TheInput:GetScreenPosition()
            if self.lastpos then
                local scale = 0.2
                local dx = scale * (pos.x - self.lastpos.x)
                local dy = scale * (pos.y - self.lastpos.y)
                self:Offset(dx, dy)
            end
            self.lastpos = pos
        else
            self.lastpos = nil
        end
    end

    MapWidget._oldOffset = MapWidget.Offset
    function MapWidget:Offset(dx, dy, ...)
        self.mapOffset.x = self.mapOffset.x + dx
        self.mapOffset.y = self.mapOffset.y + dy
        MapWidget._oldOffset(self, dx, dy, ...)
    end

    MapWidget._oldOnShow = MapWidget.OnShow
    function MapWidget:OnShow(...)
        self.mapOffset.x = 0
        self.mapOffset.y = 0
        MapWidget._oldOnShow(self, ...)
    end

    MapWidget._oldOnZoomIn = MapWidget.OnZoomIn
    function MapWidget:OnZoomIn(...)
        local zoom1 = self.minimap:GetZoom()
        MapWidget._oldOnZoomIn(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown then
            self.mapOffset = self.mapOffset * zoom1 / zoom2
        end
    end

    MapWidget._oldOnZoomOut = MapWidget.OnZoomOut
    function MapWidget:OnZoomOut(...)
        local zoom1 = self.minimap:GetZoom()
        MapWidget._oldOnZoomOut(self, ...)
        local zoom2 = self.minimap:GetZoom()
        if self.shown and zoom1 < 20 then
            self.mapOffset = self.mapOffset * zoom1 / zoom2
        end
    end

    function MapWidget:GetTargetDoor()
        local interiorspawner = GetWorld().components.interiorspawner
        if not interiorspawner or not interiorspawner:IsInInterior() then
            return
        end
        local object_list = interiorspawner:GetCurrentInteriorEntities()
        for _, object in pairs(object_list) do
            local door = object.components.door
            if door and not door.target_interior then
                if interiorspawner.doors[door.target_door_id] then
                    return interiorspawner.doors[door.target_door_id].inst
                end
            end
        end
    end

    function MapWidget:GetRoomMapLayout()
        local room_map_layout = {}
        local pos_map = {}
        local interiorspawner = GetWorld().components.interiorspawner
        local function GetLayout(current_pos)
            local pos_x = pos_map[current_pos][1]
            local pos_y = pos_map[current_pos][2]
            local object_list
            if current_pos == "0_0" then
                object_list = interiorspawner:GetCurrentInteriorEntities()
            else
                object_list = room_map_layout[current_pos].object_list
            end
            for _, object in pairs(object_list) do
                local door = object.components.door
                if door and door.target_interior then
                    local connected_interior = interiorspawner:GetInteriorByName(door.target_interior)
                    local pos_x_new, pos_y_new = pos_x, pos_y
                    local pos_str_new
                    if object:HasTag("door_north") then
                        pos_y_new = pos_y_new + 1
                    elseif object:HasTag("door_south") then
                        pos_y_new = pos_y_new - 1
                    elseif object:HasTag("door_east") then
                        pos_x_new = pos_x_new + 1
                    elseif object:HasTag("door_west") then
                        pos_x_new = pos_x_new - 1
                    end
                    pos_str_new = tostring(pos_x_new) .. "_" .. tostring(pos_y_new)
                    for k, v in pairs(pos_map) do
                        if k == pos_str_new then
                            pos_str_new = nil
                            break
                        end
                    end
                    if pos_str_new then
                        pos_map[pos_str_new] = { pos_x_new, pos_y_new }
                        room_map_layout[pos_str_new] = connected_interior
                        GetLayout(pos_str_new)
                    end
                end
            end

            local prefab_list = room_map_layout[current_pos].prefabs
            prefab_list = prefab_list or {}

            for _, prefab in pairs(prefab_list) do
                if prefab.name == "prop_door" then
                    local connected_interior = interiorspawner:GetInteriorByName(prefab.target_interior)
                    local door_tag = prefab.addtags[2]
                    local pos_x_new, pos_y_new = pos_x, pos_y
                    local pos_str_new
                    if door_tag == "door_north" then
                        pos_y_new = pos_y_new + 1
                    elseif door_tag == "door_south" then
                        pos_y_new = pos_y_new - 1
                    elseif door_tag == "door_east" then
                        pos_x_new = pos_x_new + 1
                    elseif door_tag == "door_west" then
                        pos_x_new = pos_x_new - 1
                    end
                    pos_str_new = tostring(pos_x_new) .. "_" .. tostring(pos_y_new)
                    for k, v in pairs(pos_map) do
                        if k == pos_str_new then
                            pos_str_new = nil
                            break
                        end
                    end
                    if pos_str_new then
                        pos_map[pos_str_new] = { pos_x_new, pos_y_new }
                        room_map_layout[pos_str_new] = connected_interior
                        GetLayout(pos_str_new)
                    end
                end
            end
        end

        if not (interiorspawner and interiorspawner:IsInInterior()) then
            return
        else
            local relatedInteriors = interiorspawner:GetCurrentInteriors()
            room_map_layout["0_0"] = interiorspawner.current_interior
            pos_map["0_0"] = { 0, 0 }
            if (#relatedInteriors) > 1 then
                GetLayout("0_0")
            end
            return room_map_layout
        end
    end

    function MapWidget:GetWorldMousePosition()
        local target_door = self:GetTargetDoor()
        local screenwidth, screenheight = TheSim:GetScreenSize()

        -- 玩家图标在地图界面上的像素位置
        local cx = screenwidth * 0.5 + self.mapOffset.x * 4.5
        local cy = screenheight * 0.5 + self.mapOffset.y * 4.5

        -- 鼠标在地图界面上的像素位置
        local mx, my = TheInput:GetScreenPosition():Get()
        if TheInput:ControllerAttached() then
            mx, my = screenwidth * 0.5, screenheight * 0.5
        end

        -- 两个位置的偏移
        local ox = mx - cx
        local oy = my - cy


        -- 像素位置差转换为在实际地图上的坐标距离
        local angle
        if target_door then
            angle = 0
        else
            angle = TheCamera:GetHeadingTarget() * math.pi / 180
        end

        local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
        local wa = math.atan2(ox, oy) - angle

        -- 鼠标位置对应的地图坐标
        local px, pz
        if target_door then
            px, _, pz = target_door:GetPosition():Get()
        else
            px, _, pz = GetPlayer():GetPosition():Get()
        end
        local wx = px - wd * math.cos(wa)
        local wz = pz + wd * math.sin(wa)
        return Vector3(wx, 0, wz)
    end

    function MapWidget:GetMouseInterior()
        local interiorspawner = GetWorld().components.interiorspawner
        if interiorspawner and not interiorspawner:IsInInterior() then
            return
        end
        local relatedInteriors = interiorspawner:GetCurrentInteriors()
        if (#relatedInteriors) <= 1 then
            return
        end

        local screenwidth, screenheight = TheSim:GetScreenSize()

        -- 玩家所在房间的中心在地图上的像素位置
        local cx = screenwidth * 0.5 + self.mapOffset.x * 4.5
        local cy = screenheight * 0.5 + self.mapOffset.y * 4.5

        -- 鼠标在地图界面上的像素位置
        local mx, my = TheInput:GetScreenPosition():Get()
        if TheInput:ControllerAttached() then
            mx, my = screenwidth * 0.5, screenheight * 0.5
        end

        -- 两个位置的偏移
        local ox = mx - cx
        local oy = my - cy

        -- 实际距离差距
        ox = ox * self.minimap:GetZoom()
        oy = oy * self.minimap:GetZoom()

        -- interior width 和 interior depth
        local iw = interiorspawner.current_interior.width
        local id = interiorspawner.current_interior.depth

        -- 当zoom为1时interior的长和宽的像素数
        local iw_pixel = iw * 2.5 * 4.5
        local id_pixel = id * 2.5 * 4.5

        local i, j
        if math.abs(ox) < iw_pixel / 2 then
            i = 0
        else
            local interior_num = (math.abs(ox) - iw_pixel / 2) / (iw_pixel + 80)
            local interior_num_int = math.ceil(interior_num)
            local interior_num_deci = interior_num - interior_num_int + 1
            if interior_num_deci < 80 / (iw_pixel + 80) then
                return
            end
            i = interior_num_int * ox / math.abs(ox)
        end

        if math.abs(oy) < id_pixel / 2 then
            j = 0
        else
            local interior_num = (math.abs(oy) - id_pixel / 2) / (id_pixel + 80)
            local interior_num_int = math.ceil(interior_num)
            local interior_num_deci = interior_num - interior_num_int + 1
            if interior_num_deci < 80 / (id_pixel + 80) then
                return
            end
            j = interior_num_int * oy / math.abs(oy)
        end
        local room_map_layout = self:GetRoomMapLayout()
        return room_map_layout and room_map_layout[tostring(i) .. "_" .. tostring(j)]
    end
end)

--#region 修改useitem
AddStategraphState("wilson",
    State {
        name = "useitem",
        onenter = function (inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function (inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function (inst) inst.sg:GoToState("idle") end),
        },
    })
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.USEITEM, "useitem"))
ACTIONS.USEITEM.priority = 3
ACTIONS.USEITEM.rmb = true
ACTIONS.USEITEM.instant = false
ACTIONS.USEITEM.distance = 1
ACTIONS.USEITEM.fn = function (act)
    local target = act.target or act.invobject
    if target and target.components.useableitem then
        if target.components.useableitem:CanInteract() then
            target.components.useableitem:StartUsingItem()
            return true
        end
    end
end
ACTIONS.USEITEM.strfn = function (act)
    local target = act.target or act.invobject
    if target and target.components.useableitem then
        return target.components.useableitem.verb
    end
end
AddComponentPostInit("useableitem", function (comp)
    function comp:CollectSceneActions(doer, actions, right)
        if right and self:CanInteract() then
            table.insert(actions, ACTIONS.USEITEM)
        end
    end
end)
--#endregion

STRINGS.ACTIONS.ITEMGIVER = "给予"
ACTIONS.ITEMGIVER = Action({ mount_enabled = true }, 3)
ACTIONS.ITEMGIVER.str = ACTIONS.GIVE.str
ACTIONS.ITEMGIVER.id = "ITEMGIVER"
ACTIONS.ITEMGIVER.fn = function (act)
    act.invobject.components.itemGiver:fn(act.doer, act.target)
    return true
end
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ITEMGIVER, "give"))

--#region 修改lootdropper
AddComponentPostInit("lootdropper", function (comp)
    comp.taxueLoots = {}
    local oldGenerateLoot = comp.GenerateLoot

    ---重写GenerateLoot函数，在原有战利品基础上添加踏雪战利品掉落逻辑
    ---@return table 战利品列表
    comp.GenerateLoot = function (self)
        local loots = oldGenerateLoot(self)
        -- 如果存在踏雪战利品配置，则根据概率和运气值进行额外掉落
        if #self.taxueLoots > 0 then
            local luck = GetPlayer().badluck_num[1]
            for _, loot in ipairs(self.taxueLoots) do
                local chance = loot.chance or 1
                local item = loot.item
                -- 根据概率和运气值判断是否掉落
                if math.random() < chance * luck then
                    -- 处理不同类型的物品配置（单个物品或随机物品列表）
                    if type(item) == "string" then
                        table.insert(loots, item)
                    elseif type(item) == "table" then
                        table.insert(loots, item[math.random(#item)])
                    end
                end
            end
        end
        return loots
    end

    ---设置特殊战利品及其掉落概率
    ---@param loot string|table 战利品配置（可以是字符串或表）
    ---@param chance number? 基础掉落概率
    comp.setTaxueLoots = function (self, loot, chance)
        local num = GetModConfigData("DIFFICULTY") == "retarded" and 100 or 1
        table.insert(self.taxueLoots, { item = loot, chance = (chance or 1) * num })
    end

    local oldSetLoot = comp.SetLoot
    ---重写SetLoot函数，重置特殊战利品列表
    ---@param loot table 原始战利品配置
    comp.SetLoot = function (self, loot)
        self.taxueLoots = {}
        oldSetLoot(self, loot)
    end
end)
--#endregion

AddSimPostInit(function (player)
    player:DoTaskInTime(0, function ()
        --#region 面板
        TaxuePatch.dyc = DYCLegendary or DYCInfoPanel
        if TaxuePatch.dyc then
            local color = TaxuePatch.cfg("displaySetting.showBanner.bannerColor")
            local BANNER_COLOR = TaxuePatch.RGBAColor(color)
            TaxuePatch.bannerColor = TaxuePatch.dyc.RGBAColor(BANNER_COLOR:Get())
            TaxuePatch.showBanner = function (msg, time)
                if TaxuePatch.dyc then
                    TaxuePatch.dyc.bannerSystem:ShowMessage(msg, time or 5, TaxuePatch.bannerColor)
                end
            end
        end
        --#endregion
        local taxueLevelText = player.HUD.controls.taxue_widget.text
        TaxuePatch.taxueLevelText = taxueLevelText
        local oldSetString = taxueLevelText:GetString()
        local taxueVersion = TUNING.TEST_STR:split(":")[2]
        taxueLevelText:SetString(oldSetString .. "  补丁版本:" .. modinfo.version)
        TaxuePatch.patchVersionMatchStr = taxueLevelText:AddChild(Text(BODYTEXTFONT, 60))

        local color = { 1, 0, 0, 1 }
        local str = " 补丁版本不匹配,可能导致bug"
        if patchMasterVersion == taxueVersion then
            color = { 0, 1, 0, 1 }
            str = " 补丁版本匹配"
        end
        TaxuePatch.patchVersionMatchStr:SetPosition(0, -50)
        TaxuePatch.patchVersionMatchStr:SetColour(color)
        TaxuePatch.patchVersionMatchStr:SetString(str)
        player:DoTaskInTime(60, function ()
            TaxuePatch.patchVersionMatchStr:Kill()
        end)

        --兼容4.0.2运势修改
        if type(player.badluck_num) == "number" then
            player.badluck_num = { 1, 1 }
        end
    end)
end)

--修改全部长动作为短动作
-- AddSimPostInit(function(player)
--     local state = player.sg.sg.states.dolongaction
--     if state then
--         state.tags = nil
--         state.onenter = function(inst)
--             inst.sg:GoToState("doshortaction")
--         end
--     end
-- end)

-- local function test()
-- end
-- TaxuePatch.test = test

-- test()
-- TaxuePatch.TestAllMd5()
