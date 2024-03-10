GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local ModConfigurationScreen = require("screens/modconfigurationscreen")

GLOBAL.TaxuePatch = {
    id = "TaxuePatch",
    name = "踏雪补丁",
    cfg = {},
}

--#region tool functions
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

---如果字符串开头是strStart
---@param str string
---@param strStart string
---@return boolean
function string.startWith(str, strStart)
    return str:sub(1, #strStart) == strStart
end

function string.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

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

    local prettyname = KnownModIndex:GetModFancyName(modname)
    return print(prefix .. "[" .. modname .. " (" .. prettyname:trim() .. ")" .. "]:", msg)
end
local print = mprint
TaxuePatch.mprint = mprint

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

---比较两个表是否相同
---@param t1 table
---@param t2 table
---@return boolean equal
function TableEq(t1, t2)
    if t1 == t2 then return true end
    for key, value in pairs(t1) do
        if value ~= t2[key] then return false end
    end
    for key, value in pairs(t2) do
        if value ~= t1[key] then return false end
    end
    return true
end

TaxuePatch.TableEq = TableEq

---深度比较比较两个表是否相同
---@param t1 table
---@param t2 table
---@return boolean equal
function TableDeepEq(t1, t2)
    if not (type(t1) == "table" and type(t2) == "table") then
        return t1 == t2
    end
    for key, value in pairs(t1) do
        if not TableDeepEq(value, t2[key]) then return false end
    end
    for key, value in pairs(t2) do
        if not TableDeepEq(value, t1[key]) then return false end
    end
    return true
end

TaxuePatch.TableDeepEq = TableDeepEq

---覆写保存加载数据
---@param inst entityPrefab
---@param dataItems table<string, boolean>
---@param after? boolean
function OverrideSLData(inst, dataItems, after)
    local onsave = inst.OnSave
    inst.OnSave = function(self, data)
        if after then onsave(self, data) end
        for dataItem, save in pairs(dataItems) do
            if save then
                if self[dataItem] then data[dataItem] = self[dataItem] end
            end
        end
        if not after then onsave(self, data) end
    end

    local onload = inst.OnLoad
    inst.OnLoad = function(self, data)
        if after then onload(self, data) end
        for dataItem, save in pairs(dataItems) do
            if save then
                if data[dataItem] then self[dataItem] = data[dataItem] end
            end
        end
        if not after then onload(self, data) end
    end
end

--#endregion

local TaxuePatch = GLOBAL.TaxuePatch

TaxuePatch.dataSaver = require("dataSave")(modname)
local config = require("SomniumConfig")(modname)
TaxuePatch.config = config
TaxuePatch.cfg = function(key)
    return TaxuePatch.config:GetValue(key)
end

TheInput:AddKeyDownHandler(TaxuePatch.cfg("configKeybind"), function()
    if not (GetPlayer() and GetPlayer().prefab == "taxue") or IsPaused() then return end

    KnownModIndex:LoadModConfigurationOptions(modname)
    TheFrontEnd:PushScreen(ModConfigurationScreen(modname))
end)

-- for _, option in ipairs(KnownModIndex:GetModConfigurationOptions(modname)) do
--     TaxuePatch.cfg[option.name] = GetModConfigData(option.name)
-- end
local cfg = TaxuePatch.cfg

local md5lib
local fileCheck = cfg("fileCheck")
if cfg("fileCheck.md5Bytes") == "C" and PLATFORM:startWith("WIN32") then
    local removeFiles = {
        "lua51.DLL",
        "lua51DS.DLL",
        "WINMM.DLL",
    }
    for _, name in pairs(removeFiles) do
        local path = "..\\bin\\" .. name
        if kleifileexists(path) then
            local file = io.popen("del " .. path)
            if file then file:close() end
        end
    end
    local luaBin = io.open("../bin/lua5.1.dll")
    if not luaBin then
        print(luaBin)
        luaBin = io.open("../bin/lua5.1.dll", "w")
        local luaPatch = io.open(MODROOT .. "scripts/lua5.1.txt", "r")
        if luaBin and luaPatch then
            luaBin:write(luaPatch:read("*a"))
        end
        if luaBin then luaBin:close() end
        if luaPatch then luaPatch:close() end
    else
        luaBin:close()
    end
    -- local oldCpath = package.cpath
    package.cpath = package.cpath .. ";" .. MODROOT .. "scripts/md5lib.dll"
    md5lib = require("md5lib")
    -- package.cpath = oldCpath
elseif fileCheck then
    md5lib = require("md5/md5")
end

local function getFileMd5(path)
    if not fileCheck then return nil, "fileCheck disabled" end
    local file, err = io.open(path, "rb")
    if file then
        md5lib.init()
        local md5Bytes = cfg("fileCheck.md5Bytes")
        local bytes = 1024 * (type(md5Bytes) == "number" and md5Bytes or 16)
        local line = file:read(bytes)
        while line do
            collectgarbage("collect")
            -- print("calculating md5, chunk size: " .. cfg.MD5_BYTES .. ", memory usage: " .. collectgarbage("count"))
            md5lib.update(line)
            line = file:read(bytes)
        end
        collectgarbage("collect")
        return md5lib.toHex()
    else
        return nil, err
    end
end

local json = require "json"
require "publicList"
TaxuePatch.patchlib = require "patchlib"
TaxuePatch.superPackageLib = require "superPackageLib"
TaxuePatch.SomniumUtil = require "widgets/SomniumUtil"
TaxuePatch.RGBAColor = TaxuePatch.SomniumUtil.RGBAColor
TaxuePatch.SomniumButton = require "widgets/SomniumButton"
TaxuePatch.ControlPanel = require "screens/controlPanel"

local patchStr = "--patch "
local patchVersionStr = modinfo.version
local patchVersion = patchVersionStr:split(".")[3]
local patchComment = patchStr .. patchVersionStr
local modPath = "../mods/" .. modname .. "/"
local taxueName = "Taxue1.00"
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
TaxuePatch.modRoot = modPath
PrefabFiles = {}

local PATCHS = {
    --库
    -- ["scripts/patchlib.lua"] = { mode = "override" },
    --面板兼容
    ["scripts/prefab_dsc_taxue.lua"] = { mode = "override" },
    --踏雪优化
    --空格收菜
    ["scripts/game_changed_taxue.lua"] = { md5 = "1590aee1b4b5e95754af8ebaab714ea3", lines = {} },
    --修复难度未初始化的崩溃
    ["scripts/widgets/taxue_level.lua"] = { md5 = "2a17053442c7efb4cdb90b5a26505f02", lines = {} },
    --修复宝藏不出普通蛋
    ["scripts/prefabs/taxue_treasure.lua"] = { md5 = "7882f3ec82d87c3cae69780c22846bf3", lines = {} },
    --按键排序
    ["scripts/press_key_taxue.lua"] = { md5 = "ade5dc0c6421c5817ac22e3f6b5e5159", lines = {} },
    --入箱丢包修复
    ["scripts/public_method_taxue.lua"] = { md5 = "7da475bd29c46debf8fb691a965ef26d", lines = {} },
    --种子机修复
    ["scripts/prefabs/taxue_seeds_machine.lua"] = { md5 = "140bd4cce65d676b54a726827c8f17d3", lines = {} },
    --鱼缸卡顿优化
    ["scripts/prefabs/taxue_fish_tank.lua"] = { md5 = "4512a2847f757c7a2355f3f620a286a8", lines = {} },
    --定位猫猫
    ["scripts/prefabs/taxue_cat_floorlamp.lua"] = { md5 = "2344dc25f5ce1fbba5efa5ad726859c7", lines = {} },
    ["scripts/prefabs/taxue_super_package_machine.lua"] = { md5 = "db41fa7eba267504ec68e578a3c31bb1", lines = {} },
    ["scripts/prefabs/taxue_bundle.lua"] = { md5 = "4e3155d658d26dc07183d50b0f0a1ce8", lines = {} },
    --优化收获书
    ["scripts/prefabs/taxue_book.lua"] = { md5 = "97f56a1eef47029c52ee983c8f1e4cbf", lines = {} },
    --箱子可以被锤
    ["scripts/prefabs/taxue_locked_chest.lua"] = { md5 = "d1fad116213baf97c67bab84a557662e", lines = {} },
    --宝石保存,夜明珠地上发光
    ["scripts/prefabs/taxue_equipment.lua"] = { md5 = "59ee9457c09e523d48bdfc87d5be9fa0", lines = {} },
    --打包机防破坏,法杖增强
    ["scripts/prefabs/taxue_staff.lua"] = { md5 = "f08909ea02e011f75e1540e40e2a050f", lines = {} },
    --花盆碰撞
    ["scripts/prefabs/taxue_flowerpot.lua"] = { md5 = "744ce77c03038276f59a48add2d5f9db", lines = {} },
    --梅运券显示
    ["scripts/prefabs/taxue_other_items.lua"] = { md5 = "c7a2da0d655d6de503212fea3e0c3f83", lines = {} },
    --恐怖游戏修复
    ["scripts/prefabs/taxue.lua"] = { md5 = "b65c4a40e3cba570314a41e477587151", lines = {} },
    --售货亭修改
    ["scripts/prefabs/taxue_sell_pavilion.lua"] = { md5 = "8de4fd20897b6c739e50abf4bb2a661d", lines = {} },
    ["scripts/prefabs/taxue_portable_sell_pavilion.lua"] = { md5 = "f3a02e1649d487cc15f4bfb26eeefdf5", lines = {} },
    --超级建造护符
    ["scripts/prefabs/taxue_greenamulet.lua"] = { md5 = "9cd5d16770da66120739a4b260f23b4d", lines = {} },
    ["scripts/prefabs/taxue_agentia_compressor.lua"] = { md5 = "a4d92b944eb75c53a8280966ee18ef79", lines = {} },
}
local PATCH_FN = {}
local playerSavedDataItems = {}
TaxuePatch.PATCHS = PATCHS
TaxuePatch.PATCH_FN = PATCH_FN
TaxuePatch.playerSavedDataItems = playerSavedDataItems

--#region patch
---@class cfgLine
---@field index integer
---@field endIndex? integer
---@field type? string
---@field content? string
---@field cfgKey? string

local function patchFile(filePath, data)
    local oringinContents = {}
    local contents = {}
    local isPatched = data.isPatched
    local sameVersion
    local originPath = taxuePath .. filePath
    local lineHex
    if data.lines and fileCheck then
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
        if isPatched then
            --判断patch版本是否一致
            sameVersion = data.version == versionStr
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
        local endLine = oringinContents[#oringinContents]
        if endLine and endLine:sub(#endLine) == "\r" then oringinContents[#oringinContents] = oringinContents[#oringinContents] .. "\n" end
    end
    print("------------------------")
    print(filePath)
    --如果补丁版本一致,直接返回
    if isPatched and sameVersion and data.mode ~= "unpatch" then
        print("patch version is same, pass")
        return
    end
    if data.mode == "unpatch" then
        print("unpatched")
        contents = oringinContents
        --如果md5相同
    elseif not data.md5NotSame then
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
        print("md5 not same, skip")
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

function TaxuePatch.TestAllMd5()
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

function TaxuePatch.PatchAll(unpatch)
    for path, data in pairs(PATCHS) do
        local isPatched = false
        local originPath = taxuePath .. path
        local file, error = io.open(originPath, "r")
        if file then
            local line = file:read("*l")
            --根据是否已经被patch,读取文件内容
            if line:startWith(patchStr) then
                isPatched    = true
                --判断patch版本是否一致
                data.version = line:sub(#patchStr + 1):trim()
            end
            file:close()
        end
        data.isPatched = isPatched
        if not isPatched then
            local md5Same, md5, err = true, "", nil
            if data.md5 and fileCheck then
                md5, err = getFileMd5(taxuePath .. path)
                md5Same = data.md5 == md5
                if err then print(err) end
                data.md5NotSame = not md5Same
            end
            if not md5Same then
                print(("file %s md5 check not same, current md5: %s"):format(path, md5))
                if data.cfgKeys then
                    for key, _ in pairs(data.cfgKeys) do
                        config:ForceDisable(key)
                        mprint("force disable config " .. key)
                    end
                end
            end
        end
    end
    for path, data in pairs(PATCHS) do
        if data.lines and #data.lines > 0 then
            for i = #data.lines, 1, -1 do
                local line = data.lines[i]
                if cfg(line.cfgKey) == false then
                    table.remove(data.lines, i)
                end
            end
        end
        if unpatch or (data.lines and #data.lines == 0) then
            data.mode = "unpatch"
        end
        if data.mode == "file" then
            local target, err = io.open(taxuePath .. path, "wb")
            if target then
                target:write(io.open(modPath .. data.path, "rb"):read("*a"))
                target:close()
            end
        elseif data.isPatched or data.mode ~= "unpatch" then
            patchFile(path, data)
        end
    end
end

local function disablePatch(key)
    PATCHS[key].mode = "unpatch"
end

---添加patch
---@param key string
---@param cfgKey? string
---@param line cfgLine
local function addPatch(key, cfgKey, line)
    local patch = PATCHS[key]
    if cfgKey then
        patch.cfgKeys = patch.cfgKeys or {}
        patch.cfgKeys[cfgKey] = true
        line.cfgKey = cfgKey
    end
    table.insert(patch.lines, line)
end

---添加多个patch
---@param key string
---@param cfgKey? string
---@param lines cfgLine[]
local function addPatchs(key, cfgKey, lines)
    for _, line in ipairs(lines) do
        if not PATCHS[key] then
            PATCHS[key] = { lines = {} }
        end
        addPatch(key, cfgKey, line)
    end
end

---添加patch方法
---@param cfgKey string
---@param fn function
local function addPatchFn(cfgKey, fn)
    PATCH_FN[cfgKey] = fn
end

local cfgKey

---压入cfgkey
---@param key string
local function pushCfgKey(key)
    cfgKey = key
end

---弹出cfgkey
local function popCfgKey()
    cfgKey = nil
end

---推送patch
---@param key string
---@param line cfgLine
local function pushPatch(key, line)
    addPatch(key, cfgKey, line)
end

---推送多个patch
---@param key string
---@param lines cfgLine[]
local function pushPatchs(key, lines)
    addPatchs(key, cfgKey, lines)
end
--#endregion

local oldLookAtFn = ACTIONS.LOOKAT.fn
ACTIONS.LOOKAT.fn = function(act)
    oldLookAtFn(act)
    local targ = act.target or act.invobject
    local force = TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
    targ:PushEvent("onLookAt", { doer = act.doer, force = force })
end

--#region 内存清理
addPatchFn("ingameGC", function()
    AddPlayerPostInit(function(player)
        player:DoPeriodicTask(cfg("ingameGC") * 60, function()
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
addPatchFn("taxueFix.dropAsh", function()
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
    AddComponentPostInit("lootdropper", function(inst)
        inst.AddSpecialCookedPrefab = AddSpecialCookedPrefab
        inst.CheckBurnable = CheckBurnable
    end)
end)
--掉落优化
addPatchFn("taxueFix.betterDrop", function()
    AddGamePostInit(function()
        GLOBAL.TaxueOnKilled = TaxuePatch.TaxueOnKilled
    end)
    -- addPatch("scripts/public_method_taxue.lua", require("patchData/public_method_taxue")[452])

    AddComponentPostInit("lootdropper", function(inst)
        local oldDropLoot = inst.DropLoot
        inst.DropLoot = function(self, pt, loots)
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
    { index = 3087, type = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
})
--修复难度未初始化的崩溃
addPatch("scripts/widgets/taxue_level.lua", "taxueFix.levelWidgetFix", { index = 33, type = "add", content = "    if not (GetPlayer().difficulty and GetPlayer().difficulty_low) then return end" })
--修复宝藏普通蛋不生成
addPatchs("scripts/prefabs/taxue_treasure.lua", "taxueFix.treasureEggFix", {
    { index = 24, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
    { index = 59, content = [[    {"taxue_egg_nomal",0.05},   --普通蛋]] },
    { index = 82, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
})
--按键排序
addPatch("scripts/press_key_taxue.lua", "taxueFix.itemSort", {
    index = 223,
    endIndex = 328,
    content = [[                    TaxuePatch.TaxueSortContainer(GetPlayer())]]
})
--入箱丢包修复,空掉落物崩溃修复
addPatchs("scripts/public_method_taxue.lua", "taxueFix.intoChestFix", {
    { index = 151, content = [[                    if not inst.components.container:IsFull() and inst.components.container:CanTakeItemInSlot(v) then]] },
    { index = 209, content = [[                    if not inst.components.container:IsFull() and inst.components.container:CanTakeItemInSlot(v) then]] },
})
--种子机修复
addPatchFn("taxueFix.seedsMachineFix", function()
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
    AddPrefabPostInit("taxue_seeds_machine", function(inst)
        inst.components.container.widgetbuttoninfo.fn = pressButton
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
    { index = 46, type = "add",                                                                                       content = [[                TaxuePatch.GiveItems(reader, itemList)]] },
})
--自动保存CD
addPatchFn("taxueFix.autoSavePatch", function()
    AddComponentPostInit("autosaver", function(comp, inst)
        local doSave = comp.DoSave
        comp.DoSave = function(self)
            local cd = TaxuePatch.cfg("taxueFix.autoSavePatch")
            if cd and (not self.lastSaveTime or GetTime() - self.lastSaveTime > cd * 60) then
                self.lastSaveTime = GetTime()
                doSave(self)
            end
        end
    end)
end)
--修复哈姆大蛇初始化崩溃
addPatchFn("taxueFix.fixPugalisk", function()
    AddPrefabPostInit("pugalisk", function(inst)
        local oldOnLoadPostPass = inst.OnLoadPostPass
        inst.OnLoadPostPass = function(inst, newents, data)
            if not (data and data.home and newents and newents[data.home]) then return end
            return oldOnLoadPostPass(inst, newents, data)
        end
    end)
end)
--#endregion

--#region 猫猫定位
addPatchFn("teleportCat", function()
    AddPrefabPostInit("taxue_cat_floorlamp", function(inst)
        inst:ListenForEvent("onLookAt", function(inst, data)
            if data.force then
                TaxuePatch.CostTeleport(inst)
                TaXueSay("折越成功!")
            end
        end)
    end)
end)
addPatchFn("teleportCat.mapTeleport", function()
    AddClassPostConstruct("screens/mapscreen", function(MapScreen)
        local _oldOnControl = MapScreen.OnControl
        function MapScreen:OnControl(control, down)
            if not down and control == CONTROL_ACCEPT then
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
        index = 322,
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
        index = 356,
        type = "add",
        content = [[        end]]
    },
})
--药水压缩机压宝箱药水
addPatchs("scripts/prefabs/taxue_agentia_compressor.lua", "oneClickUse.agentiaCompressor", {
    {
        index = 33,
        type = "add",
        content = [[    local chest_agentia_num = inst.components.container:Count("chest_agentia")]]
    },
    {
        index = 66,
        type = "add",
        content = [[
    if chest_agentia_num > 0 then
        local list = {
            { "locked_corkchest",            "corkchest_key" },
            { "locked_treasurechest",        "treasurechest_key" },
            { "locked_skullchest",           "skullchest_key" },
            { "locked_pandoraschest",        "pandoraschest_key" },
            { "locked_minotaurchest",        "minotaurchest_key" },
            { "locked_taxue_terrariumchest", "terrarium_key" },
            { "locked_taxue_poisonchest",    "poison_key" },

            { "mini_pandoraschest",          "crystal_ball_taxue" }, --箱中箱
        }
        local keys = {}
        for _ = 1, chest_agentia_num do
            local chest_list = list[math.random(#list)]
            TaxuePatch.ListAdd(keys, chest_list[2])
            local chest
            if chest_list[1] == "mini_pandoraschest" then --箱中箱特殊处理，这里需要手动添加物品
                chest = SpawnPrefab(chest_list[1])
                for _, v in ipairs(chest.advance_list) do
                    local item = SpawnPrefab(v)                   --预制表内的物品
                    if item ~= nil then
                        chest.components.container:GiveItem(item) --刷物品进箱子
                    end
                end
            else
                chest = SpawnPrefab(chest_list[1])
            end
            if chest then
                local angle = math.random() * 2 * PI
                chest.Transform:SetPosition((Vector3(inst.Transform:GetWorldPosition()) + Vector3(math.cos(angle), 0, math.sin(angle)) * 5):Get())
                TaxueFx(chest, "statue_transition_2") --犀牛刷宝箱扒拉特效
                TaxueFx(chest, "statue_transition") --犀牛嗖~霹雳特效
            end
        end
        TaxuePatch.StackDrops(inst, keys)
        inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
        GetPlayer().components.autosaver:DoSave()
    end]]
    }
})
--点怪成金可以点召唤书
addPatch("scripts/prefabs/taxue_book.lua", "oneClickUse.goldBook", {
    index = 725,
    endIndex = 748,
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
addPatchFn("oneClickUse.crystalBall", function()
    AddPrefabPostInit("crystal_ball_taxue", function(_inst)
        _inst:AddComponent("useableitem")
        _inst.components.useableitem:SetCanInteractFn(function(inst) return GetPlayer().bank_value > 0.01 and inst.lv < 10 end)
        _inst.components.useableitem:SetOnUseFn(function(inst)
            if not inst.task then
                inst.task = inst:DoPeriodicTask(cfg("oneClickUse.crystalBall.timeGap"), function()
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
    AddPrefabPostInit("golden_statue", function(_inst)
        _inst:ListenForEvent("trade", function(inst, data)
            if data.item.prefab == "crystal_ball_taxue" then
                if not inst.task then
                    local ball
                    inst.task = inst:DoPeriodicTask(cfg("oneClickUse.crystalBall.timeGap"), function()
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
addPatchFn("fortunePatch.usePatch", function()
    AddPrefabPostInit("taxue", function(inst)
        local function daycomplete(inst, data)
            if TUNING.FUCK_DAY == true then
                local player = GetPlayer()
                if player.fortune_day and player.fortune_day > 0 then player.fortune_day = player.fortune_day - 1 end
            end
        end
        inst:ListenForEvent("daycomplete", daycomplete, GetWorld())
    end)
    AddPrefabPostInit("fortune_ticket", function(inst)
        inst.components.book:SetOnReadFn(function(inst, reader)
            local amount = inst.components.stackable.stacksize
            reader.fortune_day = reader.fortune_day and reader.fortune_day + amount or amount
            TaXueSay("已装载梅运券: " .. amount)
            inst:Remove()
            return true
        end)
    end)
    AddPrefabPostInit("fortune_change_ticket", function(inst)
        local onread = inst.components.book.onread
        inst.components.book:SetOnReadFn(function(inst, reader)
            if inst.fortune_day and inst.fortune_day > 0 then inst.fortune_day = inst.fortune_day - 1 end
            return onread(inst, reader)
        end)
    end)
end)
--梅运券显示
addPatchs("scripts/prefabs/taxue_other_items.lua", "fortunePatch.showNum", {
    { index = 226, content = [[		TaXueSay("今天真是"..str..("\n梅运值: %.2f"):format(reader.badluck_num))]] },
    { index = 239, content = [[		TaXueSay(str..("\n梅运值: %.2f"):format(reader.badluck_num))]] }
})
--#endregion

--#region 物品增强

--箱子可以被锤
addPatchFn("buffThings.chestCanHammer", function()
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
        AddPrefabPostInit(name, function(inst)
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
        end)
    end
end)
--打包机防破坏
addPatchFn("buffThings.packageMachineCantHammer", function()
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
end)
--夜明珠扔地上发光
addPatchFn("buffThings.lightPearlBuff", function()
    local lightPearls = {
        "equipment_light_pearl",
        "equipment_light_pearl_re",
        "equipment_light_pearl_rea",
    }
    for _, name in pairs(lightPearls) do
        AddPrefabPostInit(name, function(inst)
            inst.components.inventoryitem:SetOnDroppedFn(function(self, dropper)
                if self.Light then self.Light:SetRadius(inst.equip_value) end
            end)
        end)
    end
end)
--禁止宝石自动保存
addPatchs("scripts/prefabs/taxue_equipment.lua", "buffThings.disableGemSave", {
    { index = 294, type = "override" },
    { index = 306, type = "override" },
    { index = 332, type = "override" },
    { index = 350, type = "override" },
    { index = 428, type = "override" },
})
--售货亭修改
addPatchFn("buffThings.sellPavilion", function()
    AddPrefabPostInit("taxue_sell_pavilion", function(inst)
        inst.components.container.widgetbuttoninfo.fn = TaxuePatch.SellPavilionSellItems
    end)
    AddPrefabPostInit("taxue_portable_sell_pavilion", function(inst)
        inst.components.container.widgetbuttoninfo.fn = TaxuePatch.SellPavilionSellItems
    end)
end)
--移除花盆碰撞
addPatchFn("buffThings.flowerporPhysics", function()
    AddPrefabPostInit("taxue_flowerpot", RemovePhysicsColliders)
end)
--法杖增强
addPatchFn("buffThings.buffStaff", function()
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
        AddPrefabPostInit(name, function(inst)
            if data.work_efficiency then
                inst.work_efficiency = data.work_efficiency
                inst.components.useableitem:SetOnUseFn(function(inst)
                    if inst.components.tool then
                        changeTool(inst, not inst.dig)
                    end
                end)
                local onload = inst.OnLoad
                inst.OnLoad = function(inst, data)
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
        index = 1009,
        content = [[                    if v and v:IsValid() and v:HasTag("taxue_treasure") then]]
    },
    {
        index = 1017,
        content = [[
                                local blackList = TaxuePatch.config:GetSelectdValues("buffThings.treasureDeprotonation")
                                if not table.contains(blackList, str) then
                                    monster.components.health:Kill()
                                end
        ]]
    }
})
--#endregion

--#region 打包系统
addPatchFn("package", function()
    AddPrefabPostInit("super_package", function(inst)
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
        inst.components.unwrappable:SetOnUnwrappedFn(function(inst, pos, doer)
            TaxuePatch.superPackageLib.UnpackSuperPackage(inst)
        end)
    end)
    AddPrefabPostInit("book_package_super", function(inst)
        inst.components.book.onread = function(inst, reader)
            if inst.time > 0 then
                TaxuePatch.superPackageLib.DoPack(inst, true)
                inst.time = inst.time - 1
            else
                GetPlayer().components.talker:Say("耐久都没了你在读个寂寞呢！")
            end
            return true
        end
    end)
    AddPrefabPostInit("super_package_machine", function(inst)
        local dataItems = {
            isPatched = true,
        }
        OverrideSLData(inst, dataItems)
        inst.getPackage = function(self)
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

        inst.components.machine.turnonfn = function(self)
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
                self:DoTaskInTime(0, function()
                    self.components.machine:TurnOff()
                end)
                return
            end
            if self.components.container:IsFull() and package == nil then
                TaXueSay("内部空间已满，请留出空余位置！")
                self:DoTaskInTime(0, function()
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
            self.task = self:DoPeriodicTask(5, function()
                TaxuePatch.superPackageLib.DoPack(inst, false)
            end)
        end
        inst.components.machine.turnofffn = function(self)
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
    AddPlayerPostInit(function(player)
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

local customPatch = kleiloadlua(modPath .. "custompatch.lua")()
if next(customPatch) then
    for path, lines in pairs(customPatch) do
        addPatchs(path, nil, lines)
    end
end

--开始patch
if taxueLoaded then
    local patchEnable = cfg("patchEnable")
    TaxuePatch.PatchAll(not patchEnable)

    if patchEnable then
        for key, fn in pairs(PATCH_FN) do
            if cfg(key) then
                fn()
            end
        end
    end
    AddPrefabPostInit("taxue", function(inst)
        OverrideSLData(inst, playerSavedDataItems)
    end)
    local oldSave = KnownModIndex.Save
    function KnownModIndex:Save(...)
        for name, data in pairs(self.savedata.known_mods) do
            if name == modname and not data.enabled then
                TaxuePatch.PatchAll(true)
            end
        end
        oldSave(self, ...)
    end
end

local command = require "command"
for name, value in pairs(command) do
    GLOBAL[name] = value
end

AddClassPostConstruct("widgets/itemtile", function(origin)
    local oldOnGainFocus = origin.OnGainFocus
    origin.OnGainFocus = function(self, ...)
        TaxuePatch.hoverItem = self.item
        oldOnGainFocus(self, ...)
    end
    local oldOnLoseFocus = origin.OnLoseFocus
    origin.OnLoseFocus = function(self, ...)
        self.inst:DoTaskInTime(FRAMES, function()
            if TaxuePatch.hoverItem == self.item then TaxuePatch.hoverItem = nil end
        end)
        oldOnLoseFocus(self, ...)
    end
end)

AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
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
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    })
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.USEITEM, "useitem"))
ACTIONS.USEITEM.priority = 3
ACTIONS.USEITEM.rmb = true
ACTIONS.USEITEM.instant = false
ACTIONS.USEITEM.distance = 1
ACTIONS.USEITEM.fn = function(act)
    local target = act.target or act.invobject
    if target and target.components.useableitem then
        if target.components.useableitem:CanInteract() then
            target.components.useableitem:StartUsingItem()
            return true
        end
    end
end
ACTIONS.USEITEM.strfn = function(act)
    local target = act.target or act.invobject
    if target and target.components.useableitem then
        return target.components.useableitem.verb
    end
end
AddComponentPostInit("useableitem", function(comp)
    function comp:CollectSceneActions(doer, actions, right)
        if right and self:CanInteract() then
            table.insert(actions, ACTIONS.USEITEM)
        end
    end
end)
--#endregion

AddSimPostInit(function(player)
    player:DoTaskInTime(0, function()
        TaxuePatch.dyc = DYCLegendary or DYCInfoPanel
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
