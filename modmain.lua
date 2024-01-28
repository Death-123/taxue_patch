GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local Md5 = require "md5"

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

--#endregion

PrefabFiles = {}
GLOBAL.TaxuePatch = { cfg = {} }
local TaxuePatch = GLOBAL.TaxuePatch
for _, option in ipairs(KnownModIndex:GetModConfigurationOptions(modname)) do
    TaxuePatch.cfg[option.name] = GetModConfigData(option.name)
end
local cfg = TaxuePatch.cfg


local patchStr = "--patch "
local patchVersionStr = modinfo.version
local patchVersion = patchVersionStr:split(".")[3]
local patchComment = patchStr .. patchVersionStr
local modPath = "../mods/" .. modname .. "/"
local taxueName = "Taxue1.00"
local taxueLoaded = false
for _, name in pairs(KnownModIndex:GetModNames()) do
    if string.gsub(KnownModIndex:GetModFancyName(name), "%s+", "") == "踏雪" then
        taxueLoaded = true
        taxueName = name
        break
    end
end
local taxuePath = "../mods/" .. taxueName .. "/"

local PATCHS = {
    ["scripts/patchlib.lua"] = { mode = "override" },
    ["scripts/prefab_dsc_taxue.lua"] = { mode = "override" },
    ["scripts/game_changed_taxue.lua"] = {
        mode = "patch",
        md5 = "2d2de58581e8aeb8e8a792e889b2e4bd",
        lines = {
            { index = 3070, type = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
        }
    },
    --#region 打包系统
    ["scripts/prefabs/taxue_super_package_machine.lua"] = require "patchData/taxue_super_package_machine",
    ["scripts/prefabs/taxue_bundle.lua"] = {
        mode = "patch",
        md5 = "0d0a2d2de789a9e59381e68e89e890bd",
        lines = {
            { index = 92, endIndex = 176, type = "override", content = "        UnpackSuperPackage(inst)" }
        }
    },
    ["scripts/prefabs/taxue_book.lua"] = require "patchData/taxue_book",
    --#endregion
    --箱子可以被锤
    ["scripts/prefabs/taxue_locked_chest.lua"] = {
        mode = "patch",
        md5 = "6c6f63616c20617373657473203d7b0d",
        lines = {
            { index = 671, type = "override" }
        }
    },
    --移除使用宝石时的保存
    ["scripts/prefabs/taxue_equipment.lua"] = {
        mode = "patch",
        md5 = "2d2de5a484e79086e8a385e5a487e58f",
        lines = {
            { index = 292, type = "override" },
            { index = 304, type = "override" },
            { index = 330, type = "override" },
            { index = 348, type = "override" },
            { index = 426, type = "override" },
        }
    },
    --打包机只能黄金法杖摧毁
    ["scripts/prefabs/taxue_staff.lua"] = {
        md5 = "0d0a6c6f63616c2066756e6374696f6e",
        lines = {}
    }
}

local function patchFile(filePath, data)
    local fileVersionStr
    local oringinContents = {}
    local contents = {}
    local isPatched = false
    local sameVersion = false
    local originPath = taxuePath .. filePath
    local file, error = io.open(originPath, "r")
    if file then
        local line = file:read("*l")
        --根据是否已经被patch,读取文件内容
        if line:startWith(patchStr) then
            isPatched = true
            --判断patch版本是否一致
            fileVersionStr = line:sub(#patchStr + 1):trim()
            sameVersion = fileVersionStr == patchVersionStr
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
            --如果未被patch,直接读取文件内容
            while line do
                table.insert(oringinContents, line)
                line = file:read("*l")
            end
        end
        file:close()
    end
    --如果补丁版本一致,直接返回
    if isPatched and sameVersion and data.mode ~= "unpatch" then
        print(filePath .. " patch version is same, pass")
        return
    end
    --判断md5是否一致
    local fileMd5 = data.md5 and Md5.tohex(table.concat(oringinContents, "\n"))
    local md5Same = fileMd5 == data.md5
    if data.mode == "unpatch" then
        print(filePath .. " unpatched")
        contents = oringinContents
        --如果md5相同
    elseif md5Same then
        --插入patch版本
        table.insert(contents, patchComment)
        --如果是文件覆写模式,直接覆盖原文件
        if data.mode == "override" then
            print("patching " .. filePath .. " mode override")
            local patchFile, error = io.open(modPath .. filePath, "r")
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
                            print("patching " .. filePath .. " line " .. index .. " to " .. endIndex .. " type override")
                            inPatch = true
                            if content then table.insert(contents, content) end
                        elseif type == "add" then
                            print("patching " .. filePath .. " line " .. index .. " type add")
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

local function getMd5()
    if taxueLoaded then
        for path, data in pairs(PATCHS) do
            local originPath = taxuePath .. path
            local file, err = io.open(originPath, "r")
            if file then
                print(path, "\n", Md5.tohex(file:read("*a")))
                file:close()
            else
                print(path, "\n", err)
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

local function patchAll()
    if taxueLoaded then
        for path, data in pairs(PATCHS) do
            if data.lines and #data.lines == 0 then
                data.mode = "unpatch"
            end
            patchFile(path, data)
        end
    end
end

local function disablePatch(key)
    PATCHS[key].mode = "unpatch"
end

local function addPatch(key, line)
    table.insert(PATCHS[key].lines, line)
end

if not cfg.PACKAGE_PATCH then
    disablePatch("scripts/prefabs/taxue_super_package_machine.lua")
    disablePatch("scripts/prefabs/taxue_bundle.lua")
    disablePatch("scripts/prefabs/taxue_book.lua")
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
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 611, content = [[
            local mult1 = ({1.33, 2, 3, 4, 5, 6})[cfg.BUFF_STAFF_MULT]
            local mult2 = ({2, 4, 6, 8, 10, 12})[cfg.BUFF_STAFF_MULT]
            inst.work_efficiency = name == "blue_staff" and mult1 or mult2
            ]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 614, content = [[            inst.components.tool:SetAction(ACTIONS.HAMMER,inst.work_efficiency)      --敲]] })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 651, content = ([[return MakeStaff("colourful_staff",cfg.BUFF_STAFF_SPEED,nil),     --彩虹法杖-冰箱背包升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 653, content = ([[       MakeStaff("blue_staff",cfg.BUFF_STAFF_SPEED,nil),            --湛青法杖-武器升级]]) })
    addPatch("scripts/prefabs/taxue_staff.lua", { index = 656, content = ([[       MakeStaff("forge_staff",cfg.BUFF_STAFF_SPEED,nil),     --锻造法杖]]) })
end

-- getMd5()
patchAll()
