GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local Md5 = require "md5"

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

local function getFileMd5(path)
    local file, err = io.open(path, "rb")
    if file then
        local md5 = Md5.new()
        local bytes = 1024 * cfg.MD5_BYTES
        local line = file:read(bytes)
        while line do
            collectgarbage("collect")
            md5:update(line)
            line = file:read(bytes)
        end
        collectgarbage("collect")
        return Md5.tohex(md5:finish())
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
    print("自动维修护符")
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
    ["scripts/patchlib.lua"] = { mode = "override" },
    ["scripts/prefab_dsc_taxue.lua"] = { mode = "override" },
    ["scripts/game_changed_taxue.lua"] = {
        mode = "patch",
        md5 = "117d742c942fb6b54f8e544958d911ca",
        lines = {
            { index = 3065, type = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
        }
    },
    --打包系统
    ["scripts/prefabs/taxue_super_package_machine.lua"] = { md5 = "db41fa7eba267504ec68e578a3c31bb1", lines = {} },
    ["scripts/prefabs/taxue_bundle.lua"] = { md5 = "4e3155d658d26dc07183d50b0f0a1ce8", lines = {} },
    ["scripts/prefabs/taxue_book.lua"] = { md5 = "c0012c48eb693c79576bcc90a45d198e", lines = {} },
    --箱子可以被锤
    ["scripts/prefabs/taxue_locked_chest.lua"] = {
        mode = "patch",
        md5 = "d1fad116213baf97c67bab84a557662e",
        lines = {
            { index = 641, type = "override" }
        }
    },
    --移除使用宝石时的保存
    ["scripts/prefabs/taxue_equipment.lua"] = {
        mode = "patch",
        md5 = "d56e0e8e57c5835b8a91ac9e3e7bf6bc",
        lines = {
            { index = 292, type = "override" },
            { index = 304, type = "override" },
            { index = 330, type = "override" },
            { index = 348, type = "override" },
            { index = 426, type = "override" },
        }
    },
    --打包机只能黄金法杖摧毁
    ["scripts/prefabs/taxue_staff.lua"] = { md5 = "36cd0c32a1ed98671601cb15c18e58de", lines = {} },
    ["scripts/prefabs/taxue_flowerpot.lua"] = { md5 = "744ce77c03038276f59a48add2d5f9db", lines = {} },
    ["scripts/prefabs/taxue_other_items.lua"] = { md5 = "c7a2da0d655d6de503212fea3e0c3f83", lines = {} },
}

local function patchFile(filePath, data)
    local fileVersionStr
    local oringinContents = {}
    local contents = {}
    local isPatched = false
    local sameVersion = false
    local originPath = taxuePath .. filePath
    local lineHex
    if data.lines then
        local md5 = Md5.new()
        for _, line in ipairs(data.lines) do
            md5:update(tostring(line.index))
        end
        lineHex = Md5.tohex(md5:finish())
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
    --如果补丁版本一致,直接返回
    if isPatched and sameVersion and data.mode ~= "unpatch" then
        print(filePath)
        print("patch version is same, pass")
        return
    end
    --判断md5是否一致
    local md5Same = true
    local md5
    if not isPatched and data.md5 then
        md5 = getFileMd5(originPath)
        md5Same = data.md5 == md5
    end
    if data.mode == "unpatch" then
        print(filePath)
        print("unpatched")
        contents = oringinContents
        --如果md5相同
    elseif md5Same then
        --插入patch版本
        table.insert(contents, patchStr .. versionStr)
        --如果是文件覆写模式,直接覆盖原文件
        if data.mode == "override" then
            print("patching " .. filePath)
            print("mode override")
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
            print("patching " .. filePath)
            local patchLines = data.lines
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
        print(filePath)
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

local function test()
    patchFile("modmain.lua", {
        mode = "unpatch",
        md5 = "474c4f42414c2e7365746d6574617461",
        lines = {
            { index = 2,   type = "add",   content = "--test1" },
            { index = 3,   endIndex = 5,   type = "override",  content = "--test2" },
            { index = 118, endIndex = 128, type = "override" },
        }
    })
    patchFile("scripts/patchlib.lua", { mode = "override" })
end

local function patchAll(unpatch)
    if taxueLoaded then
        for path, data in pairs(PATCHS) do
            if unpatch or (data.lines and #data.lines == 0) then
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

if cfg.PACKAGE_PATCH then
    PATCHS["scripts/prefabs/taxue_super_package_machine.lua"].lines = require "patchData/taxue_super_package_machine"
    PATCHS["scripts/prefabs/taxue_bundle.lua"].lines = require "patchData/taxue_bundle"
    PATCHS["scripts/prefabs/taxue_book.lua"].lines = require "patchData/taxue_book"
end

if not cfg.CHEST_CAN_HAMMER then
    disablePatch("scripts/prefabs/taxue_locked_chest.lua")
end

if not cfg.DISABLE_GEM_SAVE then
    disablePatch("scripts/prefabs/taxue_equipment.lua")
end

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
    addPatch("scripts/game_changed_taxue.lua", { index = 3305, type = "add", content = [[AddPrefabPostInit("super_package_machine",function (inst) inst:RemoveComponent("workable") end)]] })
end

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
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 614, content = [[            inst.components.tool:SetAction(ACTIONS.HAMMER,inst.work_efficiency)      --敲]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 651, content = ([[return MakeStaff("colourful_staff",TaxuePatch.cfg.BUFF_STAFF_SPEED,nil),     --彩虹法杖-冰箱背包升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 653, content = ([[       MakeStaff("blue_staff",TaxuePatch.cfg.BUFF_STAFF_SPEED,nil),            --湛青法杖-武器升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 656, content = ([[       MakeStaff("forge_staff",TaxuePatch.cfg.BUFF_STAFF_SPEED,nil),     --锻造法杖]]) })
end

if cfg.FLOWERPOT_PHYSICS then
    addPatch("scripts/prefabs/taxue_flowerpot.lua", { index = 246 })
end

if cfg.FORTUNE_NUM then
    addPatch("scripts/prefabs/taxue_other_items.lua", { index = 226, content = [[		TaXueSay("今天真是"..str..("\n霉运值: %.2f"):format(reader.badluck_num))]] })
    addPatch("scripts/prefabs/taxue_other_items.lua", { index = 239, content = [[		TaXueSay(str..("\n霉运值: %.2f"):format(reader.badluck_num))]] })
end

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

-- testAllMd5()
patchAll()
