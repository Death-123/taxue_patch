GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local Md5 = require "md5"
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

PrefabFiles = {}

local patchComment = "--patch " .. modinfo.version
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

local function patchFile(filePath, data)
    local originPath = taxuePath .. filePath
    local file, error = io.open(originPath, "r")
    if not file then return error end
    local line = file:read("*l")
    local contents = {}
    if not line:startWith(patchComment) then
        file:close()
        file, error = io.open(originPath, "r")
        if not file then return error end
        local fileMd5 = data.md5 and Md5.tohex(file:read("*a"))
        if not data.md5 or fileMd5 == data.md5 then
            local lineNum = 1
            table.insert(contents, patchComment)
            if data.isOverride then
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
                local lines = data.lines
                local i = 1
                local index, mode, endIndex, content
                local inPatch = false
                file, error = io.open(originPath, "r")
                if not file then return error end
                line = file:read("*l")
                while line do
                    if lines[i] then
                        index, mode, endIndex, content = lines[i].index, lines[i].mode, lines[i].endIndex, lines[i].content
                    end
                    if lineNum == index then
                        table.insert(contents, "--patch " .. mode)
                        if mode == "override" then
                            print("patching " .. filePath .. " line " .. index .. " mode override")
                            inPatch = true
                            table.insert(contents, content)
                        elseif mode == "add" then
                            print("patching " .. filePath .. " line " .. index .. " mode add")
                            table.insert(contents, content)
                            table.insert(contents, line)
                        end
                        table.insert(contents, "--endPatch")
                        i = i + 1
                    elseif lineNum == endIndex then
                        inPatch = false
                    elseif not inPatch then
                        table.insert(contents, line)
                    end
                    line = file:read("*l")
                    lineNum = lineNum + 1
                end
            end
        end
    end
    file:close()
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

local PATCHS = {
    ["scripts/prefab_dsc_taxue.lua"] = { isOverride = true },
    ["scripts/game_changed_taxue.lua"] = {
        md5 = "2d2de58581e8aeb8e8a792e889b2e4bd",
        lines = {
            { index = 3070, mode = "add", content = "		bact.invobject = bact.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)" },
        }
    }
}

if taxueLoaded then
    for path, data in pairs(PATCHS) do
        patchFile(path, data)
    end
end
