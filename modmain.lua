GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
package.cpath = package.cpath .. ";" .. MODROOT .. "/scripts/?.dll"
local md5lib = require("md5lib")

GLOBAL.TaxuePatch = { cfg = {} }
local TaxuePatch = GLOBAL.TaxuePatch
for _, option in ipairs(KnownModIndex:GetModConfigurationOptions(modname)) do
    TaxuePatch.cfg[option.name] = GetModConfigData(option.name)
end
local cfg = TaxuePatch.cfg

--#region tool functions
local function mprint(...)
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

    return print(prefix .. "[" .. ModInfoname(modname) .. "]:", msg)
end
local print = mprint
TaxuePatch.print = print

function string.startWith(str, strStart)
    return str:sub(1, #strStart) == strStart
end

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

function string.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function string.compare(s1, s2)
    if type(s1) == "string" and type(s2) == "string" then
        for i = 1, #s1 do
            local n1 = s1:byte(i)
            local n2 = s2:byte(i)
            if n1 ~= n2 then
                return n2 == nil or n1 > n2
            end
        end
        return false
    end
end

local function getFileMd5(path)
    if not cfg.MD5_BYTES then return nil end
    local file, err = io.open(path, "rb")
    if file then
        md5lib.init()
        local bytes = 1024 * cfg.MD5_BYTES
        local line = file:read(bytes)
        while line do
            collectgarbage("collect")
            print("calculating md5, chunk size: " .. cfg.MD5_BYTES .. ", memory usage: " .. collectgarbage("count"))
            md5lib.update(line)
            line = file:read(bytes)
        end
        collectgarbage("collect")
        return md5lib.toHex()
    else
        return nil, err
    end
end

--#endregion

local patchStr = "--patch "
local patchVersionStr = modinfo.version
local patchVersion = patchVersionStr:split(".")[3]
local patchComment = patchStr .. patchVersionStr
local modPath = "../mods/" .. modname .. "/"
local taxueName = "Taxue1.00"
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
local prefabs = {}
PrefabFiles = {}


if taxueEnabled and cfg.AUTO_AMULET then
    Assets = {
        Asset("IMAGE", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.tex"),
        Asset("ATLAS", "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"),
    }
    table.insert(PrefabFiles, "taxue_ultimate_armor_auto_amulet")
    AddPlayerPostInit(function()
        if GetPlayer().prefab == "taxue" then
            Recipe("taxue_ultimate_armor_auto_amulet",
                {
                    Ingredient("chest_essence", 10, "images/inventoryimages/chest_essence.xml"),
                    Ingredient("thulecite", 20),
                    Ingredient("greengem", 10)
                },
                RECIPETABS.TAXUE_TAB, TECH.SCIENCE_TWO).atlas = "images/inventoryimages/taxue_ultimate_armor_auto_amulet.xml"
        end
    end)
end

local PATCHS = {
    --库
    ["scripts/patchlib.lua"] = { mode = "override" },
    --面板兼容
    ["scripts/prefab_dsc_taxue.lua"] = { mode = "override" },
    --踏雪优化
    --空格收菜,打包机防破坏
    ["scripts/game_changed_taxue.lua"] = { md5 = "80802bfa924ce00c3d2110e9f0b7a0bb", lines = {} },
    --修复难度未初始化的崩溃
    ["scripts/widgets/taxue_level.lua"] = { md5 = "6194bdd97527df825238da2ba3d27ec8", lines = {} },
    --修复宝藏不出普通蛋
    ["scripts/prefabs/taxue_treasure.lua"] = { md5 = "aaa243d80a6aeb6125febef8bf6953a1", lines = {} },
    --按键排序
    ["scripts/press_key_taxue.lua"] = { md5 = "86a1c8cb703fe4d310f289c059c5bfef", lines = {} },
    --入箱丢包修复
    ["scripts/public_method_taxue.lua"] = { md5 = "0ac6775af4ac0ceff981a8286954274e", lines = {} },
    --种子机修复
    ["scripts/prefabs/taxue_seeds_machine.lua"] = { md5 = "140bd4cce65d676b54a726827c8f17d3", lines = {} },
    --鱼缸卡顿优化
    ["scripts/prefabs/taxue_fish_tank.lua"] = { md5 = "4512a2847f757c7a2355f3f620a286a8", lines = {} },

    --打包系统
    ["scripts/prefabs/taxue_super_package_machine.lua"] = { md5 = "db41fa7eba267504ec68e578a3c31bb1", lines = {} },
    ["scripts/prefabs/taxue_bundle.lua"] = { md5 = "4e3155d658d26dc07183d50b0f0a1ce8", lines = {} },
    ["scripts/prefabs/taxue_book.lua"] = { md5 = "c0012c48eb693c79576bcc90a45d198e", lines = {} },
    --箱子可以被锤
    ["scripts/prefabs/taxue_locked_chest.lua"] = { md5 = "d1fad116213baf97c67bab84a557662e", lines = {} },
    --宝石保存,夜明珠地上发光
    ["scripts/prefabs/taxue_equipment.lua"] = { md5 = "59ee9457c09e523d48bdfc87d5be9fa0", lines = {} },
    --打包机防破坏,法杖增强
    ["scripts/prefabs/taxue_staff.lua"] = { md5 = "36cd0c32a1ed98671601cb15c18e58de", lines = {} },
    --花盆碰撞
    ["scripts/prefabs/taxue_flowerpot.lua"] = { md5 = "744ce77c03038276f59a48add2d5f9db", lines = {} },
    --梅运券显示
    ["scripts/prefabs/taxue_other_items.lua"] = { md5 = "c7a2da0d655d6de503212fea3e0c3f83", lines = {} },
    --梅运券修改,利息券连地上一起读
    ["scripts/prefabs/taxue.lua"] = { md5 = "ffaca9b7cb0d6fa623266d2f96e744dd", lines = {} },
    --售货亭修改
    ["scripts/prefabs/taxue_sell_pavilion.lua"] = { md5 = "8de4fd20897b6c739e50abf4bb2a661d", lines = {} },
    ["scripts/prefabs/taxue_portable_sell_pavilion.lua"] = { md5 = "f3a02e1649d487cc15f4bfb26eeefdf5", lines = {} },
    --超级建造护符
    ["scripts/prefabs/taxue_greenamulet.lua"] = { md5 = "9cd5d16770da66120739a4b260f23b4d", lines = {} },
}

--#region
local function patchFile(filePath, data)
    local fileVersionStr
    local oringinContents = {}
    local contents = {}
    local isPatched = false
    local sameVersion = false
    local originPath = taxuePath .. filePath
    local lineHex
    if data.lines then
        md5lib.init()
        for _, line in ipairs(data.lines) do
            md5lib.update(tostring(line.index))
        end
        lineHex = md5lib.toHex()
    end
    local versionStr = patchVersionStr .. (lineHex and ("." .. lineHex) or "")
    local file, error = io.open(originPath, "r")
    if file then
        local line = file:read("*l")
        --根据是否已经被patch,读取文件内容
        if line:startWith(patchStr) then
            isPatched = true
            --判断patch版本是否一致
            fileVersionStr = line:sub(#patchStr + 1):trim()
            sameVersion = fileVersionStr == versionStr
            if not sameVersion or data.mode == "unpatch" then
                --如果不一致,读取去除patch的内容
                line = file:read("*l")
                local inPatch = false
                local type = ""
                while line do
                    if not inPatch and line:startWith(patchStr) then
                        inPatch = true
                        type = line:sub(#patchStr + 1):trim()
                    elseif inPatch and line:startWith("--endPatch") then
                        line = file:read("*l")
                        inPatch = false
                    end
                    if not inPatch then
                        table.insert(oringinContents, line)
                    else
                        if type == "override" and line:startWith("--oringin ") then
                            table.insert(oringinContents, line:sub(#"--oringin " + 1))
                        end
                    end
                    line = file:read("*l")
                end
            end
        else
            if data.mode == "unpatch" then
                return
            end
            --如果未被patch,直接读取文件内容
            while line do
                table.insert(oringinContents, line)
                line = file:read("*l")
            end
        end
        file:close()
    end
    print("------------------------")
    print(filePath)
    --如果补丁版本一致,直接返回
    if isPatched and sameVersion and data.mode ~= "unpatch" then
        print("patch version is same, pass")
        return
    end
    --判断md5是否一致
    local md5Same = true
    local md5
    if not isPatched and data.md5 and cfg.MD5_BYTES then
        md5 = getFileMd5(originPath)
        md5Same = data.md5 == md5
    end
    if data.mode == "unpatch" then
        print("unpatched")
        contents = oringinContents
        --如果md5相同
    elseif md5Same then
        --插入patch版本
        table.insert(contents, patchStr .. versionStr)
        --如果是文件覆写模式,直接覆盖原文件
        if data.mode == "override" then
            print("patch mode override")
            local targetPath = modPath .. (data.file or filePath)
            local patchFile, error = io.open(targetPath, "r")
            if not patchFile then return error end
            local patchLine = patchFile:read("*l")
            while patchLine do
                table.insert(contents, patchLine)
                patchLine = patchFile:read("*l")
            end
            patchFile:close()
        else
            local patchLines = data.lines
            table.sort(patchLines, function(a, b) return a.index < b.index end)
            local i = 1
            local index, type, endIndex, content
            local inPatch = false
            --遍历原文件每一行
            for lineNum, line in ipairs(oringinContents) do
                if patchLines[i] then
                    local linedata = patchLines[i]
                    index, type, endIndex, content = linedata.index, linedata.type or "override", linedata.endIndex or linedata.index, linedata.content
                    --是目标行
                    if lineNum == index then
                        table.insert(contents, "--patch " .. type)
                        if type == "override" then
                            print("patching line " .. (linedata.endIndex and index .. " to " .. endIndex or index) .. " type override")
                            inPatch = true
                            if content then table.insert(contents, content) end
                        elseif type == "add" then
                            print("patching line " .. index .. " type add")
                            table.insert(contents, content)
                            table.insert(contents, "--endPatch")
                            i = i + 1
                        end
                        --是目标结束行
                    elseif inPatch and lineNum == endIndex + 1 then
                        inPatch = false
                        table.insert(contents, "--endPatch")
                        i = i + 1
                    end
                end
                --如果patch目标行内,在源代码前插入"--origin "注释
                if inPatch then
                    table.insert(contents, "--oringin " .. line)
                else
                    table.insert(contents, line)
                end
            end
            if inPatch then
                inPatch = false
                table.insert(contents, "--endPatch")
            end
        end
    else
        print((md5 and md5 .. " " or "") .. "md5 not same, skip")
    end
    --写入原文件
    if #contents > 0 then
        local originFile, error = io.open(originPath, "w")
        if not originFile then
            print(error)
            return
        end
        originFile:write(table.concat(contents, "\n"))
        originFile:close()
    end
end

local function testAllMd5()
    if taxueLoaded then
        for path, data in pairs(PATCHS) do
            local originPath = taxuePath .. path
            local isPatched = false
            local file, error = io.open(originPath, "r")
            if file then
                local line = file:read("*l")
                if line:startWith(patchStr) then
                    isPatched = true
                end
            end
            if not isPatched then
                local md5, err = getFileMd5(originPath)
                print("-----------------------------")
                print(path)
                if md5 then
                    print(md5, data.md5 or "", (md5 == data.md5) and "same" or "")
                else
                    print(err)
                end
            end
        end
    end
end

local function test()
    for key, value in pairs(md5lib) do
        print(key, value)
    end
    md5lib.init()
    md5lib.update("a")
    md5lib.update("b")
    md5lib.update("c")
    print(md5lib.toHex())
end

local function patchAll(unpatch)
    if taxueLoaded then
        for path, data in pairs(PATCHS) do
            if not cfg.PATCH_ENABLE or unpatch or (data.lines and #data.lines == 0) then
                data.mode = "unpatch"
            end
            if data.mode == "file" then
                local target, err = io.open(taxuePath .. path, "wb")
                if target then target:write(io.open(modPath .. data.path, "rb"):read("*a")) end
            else
                patchFile(path, data)
            end
        end
    end
end

local function disablePatch(key)
    PATCHS[key].mode = "unpatch"
end

local function addPatch(key, line)
    table.insert(PATCHS[key].lines, line)
end

local function addPatchs(key, lines)
    for _, line in ipairs(lines) do
        table.insert(PATCHS[key].lines, line)
    end
end
--#endregion

--踏雪优化
if cfg.TAXUE_FIX then
    --空格收菜
    addPatchs("scripts/game_changed_taxue.lua", {
        { index = 3085, type = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
    })
    --夜明珠扔地上发光
    addPatchs("scripts/prefabs/taxue_equipment.lua", {
        { index = 492, type = "add", content = "            inst.components.inventoryitem:SetOnDroppedFn(function(self, dropper) if self.Light then self.Light:SetRadius(inst.equip_value) end end) --发光函数" },
    })
    --修复难度未初始化的崩溃
    addPatch("scripts/widgets/taxue_level.lua", { index = 33, type = "add", content = "    if not (GetPlayer().difficulty and GetPlayer().difficulty_low) then return end" })
    --修复宝藏普通蛋不生成
    addPatchs("scripts/prefabs/taxue_treasure.lua", {
        { index = 24, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
        { index = 59, content = [[    {"taxue_egg_nomal",0.05},   --普通蛋]] },
        { index = 82, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
    })
    --按键排序
    addPatchs("scripts/press_key_taxue.lua", {
        {
            index = 297,
            endIndex = 299,
            content = [[
            if item1.prefab == name and item2.prefab == name then
                if type(value1) == "number" then
                    return value1 < value2
                else
                    return value2:compare(value1)
                end
            end
        ]]
        },
        {
            index = 312,
            content = [[
            or CanSort(item1,item2,"substitute_ticket",item1.substitute_item,item2.substitute_item)   --掉包券
            or CanSort(item1,item2,"shop_refresh_ticket_directed",item1.refresh_item,item2.refresh_item)   --定向商店刷新
            or CanSort(item1,item2,"book_touch_leif",item1.leif_num,item2.leif_num)) then   --点树成精
        ]]
        }
    })
    --入箱丢包修复
    addPatchs("scripts/public_method_taxue.lua", {
        { index = 147, content = [[                    if not inst.components.container:IsFull() and inst.components.container:CanTakeItemInSlot(v) then]] },
        { index = 205, content = [[                    if not inst.components.container:IsFull() and inst.components.container:CanTakeItemInSlot(v) then]] },
    })
    --种子机修复
    addPatchs("scripts/prefabs/taxue_seeds_machine.lua", require "patchData/taxue_seeds_machine")
    --利息券连地上一起读
    addPatch("scripts/prefabs/taxue_other_items.lua", {
        index = 62,
        type = "add",
        content = [[
        for _, entity in ipairs(GetNearByEntities(reader, 15, function(entity) return entity.prefab == "interest_ticket" end)) do
			num = num + entity.interest
            entity:Remove()
		end
    ]]
    })
    --鱼缸卡顿优化
    addPatchs("scripts/prefabs/taxue_fish_tank.lua", {
        {index = 46, content = [[
            if not inst.components.workable then
                inst:AddComponent("workable")
            elseif inst.components.workable.action == ACTIONS.DIG then
                return
            end
        ]]},
        {index = 55, content = [[
            if not inst.components.workable then
                inst:AddComponent("workable")
            elseif inst.components.workable.action == ACTIONS.HAMMER then
                return
            end
        ]]},
    })
end

--售货亭修改
if cfg.SELL_PAVILION then
    addPatch("scripts/prefabs/taxue_sell_pavilion.lua", { index = 45, endIndex = 112, content = [[   SellPavilionSellItems(inst)]] })
    addPatch("scripts/prefabs/taxue_portable_sell_pavilion.lua", { index = 33, endIndex = 99, content = [[   SellPavilionSellItems(inst)]] })
end

--打包系统
if cfg.PACKAGE_PATCH then
    PATCHS["scripts/prefabs/taxue_super_package_machine.lua"].lines = require "patchData/taxue_super_package_machine"
    PATCHS["scripts/prefabs/taxue_bundle.lua"].lines = require "patchData/taxue_bundle"
    PATCHS["scripts/prefabs/taxue_book.lua"].lines = require "patchData/taxue_book"
end

--箱子可以被锤
if cfg.CHEST_CAN_HAMMER then
    addPatch("scripts/prefabs/taxue_locked_chest.lua", {
        index = 641,
        type = "override",
        content = [[
        local function onhammered(inst) inst.components.container:DropEverything() inst.components.container.onclosefn(inst) end
        inst.components.workable:SetOnFinishCallback(onhammered)
        ]]
    })
end

--宝石保存
if cfg.DISABLE_GEM_SAVE then
    addPatchs("scripts/prefabs/taxue_equipment.lua", {
        { index = 294, type = "override" },
        { index = 306, type = "override" },
        { index = 332, type = "override" },
        { index = 350, type = "override" },
        { index = 428, type = "override" },
    })
end

--打包机防破坏
if cfg.PACKAGE_STAFF then
    addPatch("scripts/prefabs/taxue_staff.lua",
        {
            index = 288,
            type = "override",
            content =
            [[        if target.prefab == "taxue_treasuretrans_monster_machine" or target.prefab == "thumper" or target.prefab == "taxue_slotmachine" or target.prefab == "super_package_machine" then  --怪物宝藏转移机,地震仪]]
        })
    addPatch("scripts/prefabs/taxue_staff.lua",
        {
            index = 437,
            type = "override",
            content =
            [[            if target.prefab == "taxue_treasuretrans_monster_machine" or target.prefab == "thumper" or target.prefab == "taxue_slotmachine" or target.prefab == "super_package_machine" then]]
        })
    addPatch("scripts/game_changed_taxue.lua", { index = 3315, type = "add", content = [[AddPrefabPostInit("super_package_machine",function (inst) inst:RemoveComponent("workable") end)]] })
end

--法杖增强
if cfg.BUFF_STAFF then
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 491, content = [[    inst.components.tool:SetAction(ACTIONS.DIG,inst.work_efficiency)]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 507, content = [[    inst.components.tool:SetAction(ACTIONS.HAMMER,inst.work_efficiency)      --敲]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 544, content = [[            inst.components.tool:SetAction(ACTIONS.DIG,inst.work_efficiency)]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 552, content = [[            inst.components.tool:SetAction(ACTIONS.HAMMER,inst.work_efficiency)      --敲]] })
    addPatch("scripts/prefabs/taxue_staff.lua", {
        index = 611,
        content = [[
            local list1 = {1.33, 2, 3, 4, 5, 6}
            local list2 = {2, 4, 6, 8, 10, 12}
            local mult1 = list1[TaxuePatch.cfg.BUFF_STAFF_MULT]
            local mult2 = list2[TaxuePatch.cfg.BUFF_STAFF_MULT]
            inst.work_efficiency = name == "blue_staff" and mult1 or mult2
            ]]
    })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 614, content = [[            inst.components.tool:SetAction(ACTIONS.HAMMER, inst.work_efficiency)      --敲]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 651, content = ([[return MakeStaff("colourful_staff", TaxuePatch.cfg.BUFF_STAFF_SPEED / 5 * 7, nil),     --彩虹法杖-冰箱背包升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 653, content = ([[       MakeStaff("blue_staff", TaxuePatch.cfg.BUFF_STAFF_SPEED, nil),            --湛青法杖-武器升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 656, content = ([[       MakeStaff("forge_staff", TaxuePatch.cfg.BUFF_STAFF_SPEED, nil),     --锻造法杖]]) })
end

--超级建造护符耐久
if cfg.GREEN_AMULET then
    addPatch("scripts/prefabs/taxue_greenamulet.lua", {
        index = 59,
        endIndex = 60,
        content = [[
            self.inst.time = self.inst.time + TaxuePatch.cfg.GREEN_AMULET * stacksize
            GetPlayer().components.talker:Say("耐久+"..(TaxuePatch.cfg.GREEN_AMULET * stacksize).."次")
    ]]
    })
end

--花盆碰撞
if cfg.FLOWERPOT_PHYSICS then
    addPatch("scripts/prefabs/taxue_flowerpot.lua", { index = 246 })
end

--梅运券修改
if cfg.FORTUNE_PATCH then
    addPatchs("scripts/prefabs/taxue.lua", {
        { index = 167, type = "add", content = [[    data.fortune_day = inst.fortune_day]] },
        { index = 216, type = "add", content = [[    if data.fortune_day then inst.fortune_day = data.fortune_day end]] },
        { index = 244, type = "add", content = [[        if inst.fortune_day and inst.fortune_day > 0 then inst.fortune_day = inst.fortune_day - 1 end]] },
    })
    addPatch("scripts/prefabs/taxue_other_items.lua", {
        index = 204,
        endIndex = 227,
        content = [[
        local amount = inst.components.stackable.stacksize
        GetPlayer().fortune_day = GetPlayer().fortune_day and GetPlayer().fortune_day + amount or amount
        TaXueSay("已装载梅运券: " .. amount)
        inst:Remove()
    ]]
    })
    --梅运券显示
elseif cfg.FORTUNE_NUM then
    addPatch("scripts/prefabs/taxue_other_items.lua", { index = 226, content = [[		TaXueSay("今天真是"..str..("\n梅运值: %.2f"):format(reader.badluck_num))]] })
    addPatch("scripts/prefabs/taxue_other_items.lua", { index = 239, content = [[		TaXueSay(str..("\n梅运值: %.2f"):format(reader.badluck_num))]] })
end

--灰烬掉落
if cfg.DORP_ASH then
    local special_cooked_prefabs = {
        ["trunk_summer"] = "trunk_cooked",
        ["trunk_winter"] = "trunk_cooked",
    }
    local function AddSpecialCookedPrefab(prefab, cooked_prefab)
        special_cooked_prefabs[prefab] = cooked_prefab
    end
    local function DropLoot(self, pt)
        local prefabs = self:GenerateLoot()
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
        for _, v in pairs(prefabs) do
            self:SpawnLootPrefab(v, pt)
        end
    end
    AddComponentPostInit("lootdropper", function(inst)
        inst.AddSpecialCookedPrefab = AddSpecialCookedPrefab
        inst.DropLoot = DropLoot
    end)
end

-- test()
-- testAllMd5()
patchAll()
