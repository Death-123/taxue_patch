---@class ModPatchLib
---@overload fun(data:table):ModPatchLib
---@field enable boolean
---@field originPath string
---@field targetPath string
---@field versionStr string
---@field patchStr string
---@field fileCheck function
---@field md5Bytes number|string|boolean
---@field cfgCheck function
---@field md5lib table
---@field cfgDisable function
---@field PATCHS {[string]: table}
---@field PATCH_FN {always: function[], [string]: function}
---@field print function
local ModPatchLib = Class(function (self, data)
    self.enable = data.enable
    self.originPath = data.originPath
    self.targetPath = data.targetPath
    self.versionStr = data.versionStr
    self.patchStr = data.patchStr or "--patch "
    self.fileCheck = data.fileCheck
    self.md5lib = data.md5lib
    self.md5Bytes = data.md5Bytes or 16
    self.cfgCheck = data.cfgCheck
    self.cfgDisable = data.cfgDisable
    self.PATCHS = data.PATCHS
    self.PATCH_FN = { always = {} }
    self.print = data.print or print
end)

---@class cfgLine
---@field index integer
---@field endIndex? integer
---@field type? string
---@field content? string
---@field cfgKey? string

function ModPatchLib:patchFile(filePath, data)
    local oringinContents = {}
    local contents = {}
    local isPatched = data.isPatched
    local sameVersion
    local targetPath = self.targetPath .. filePath
    local lineHex
    --计算md5
    if data.lines and self.fileCheck then
        self.md5lib.init()
        for _, line in ipairs(data.lines) do
            self.md5lib.update(tostring(line.index))
        end
        lineHex = self.md5lib.toHex()
    end
    local versionStr = self.versionStr .. (lineHex and ("." .. lineHex) or "")
    local file, error = io.open(targetPath, "r")
    --读取文件
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
                    if not inPatch and line:startWith(self.patchStr) then
                        inPatch = true
                        type = line:sub(#self.patchStr + 1):trim()
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
    self.print("------------------------")
    self.print(filePath)
    --如果补丁版本一致,直接返回
    if isPatched and sameVersion and data.mode ~= "unpatch" then
        self.print("patch version is same, pass")
        return
    end
    if data.mode == "unpatch" then
        self.print("unpatched")
        contents = oringinContents
    elseif not data.md5NotSame then --如果md5相同
        --插入patch版本
        table.insert(contents, self.patchStr .. versionStr)
        --如果是文件覆写模式,直接覆盖原文件
        if data.mode == "override" then
            self.print("patch mode override")
            local sourcePath = self.originPath .. (data.file or filePath)
            local patchFile, error = io.open(sourcePath, "r")
            if not patchFile then return error end
            local patchLine = patchFile:read("*l")
            while patchLine do
                table.insert(contents, patchLine)
                patchLine = patchFile:read("*l")
            end
            patchFile:close()
        else
            local patchLines = data.lines
            table.sort(patchLines, function (a, b) return a.index < b.index end)
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
                            self.print("patching line " .. (linedata.endIndex and index .. " to " .. endIndex or index) .. " type override")
                            inPatch = true
                            if content then table.insert(contents, content) end
                        elseif type == "add" then
                            self.print("patching line " .. index .. " type add")
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
        self.print("md5 not same, skip")
    end
    --写入原文件
    if #contents > 0 then
        local originFile, error = io.open(targetPath, "w")
        if not originFile then
            self.print(error)
            return
        end
        originFile:write(table.concat(contents, "\n"))
        originFile:close()
    end
end

function ModPatchLib:getFileMd5(path)
    if not self.fileCheck then return nil, "fileCheck disabled" end
    local file, err = io.open(path, "rb")
    if file then
        self.md5lib.init()
        local bytes = 1024 * (type(self.md5Bytes) == "number" and self.md5Bytes or 16)
        local line = file:read(bytes)
        while line do
            collectgarbage("collect")
            -- self.print("calculating md5, chunk size: " .. cfg.MD5_BYTES .. ", memory usage: " .. collectgarbage("count"))
            self.md5lib.update(line)
            line = file:read(bytes)
        end
        collectgarbage("collect")
        return self.md5lib.toHex()
    else
        return nil, err
    end
end

function ModPatchLib:TestAllMd5()
    if self.enable then
        for path, data in pairs(self.PATCHS) do
            local targetPath = self.targetPath .. path
            local isPatched = false
            local file, error = io.open(targetPath, "r")
            if file then
                local line = file:read("*l")
                if line:startWith(self.patchStr) then
                    isPatched = true
                end
            end
            if not isPatched then
                local md5, err = self:getFileMd5(targetPath)
                self.print("-----------------------------")
                self.print(path)
                if md5 then
                    self.print(md5, data.md5 or "", (md5 == data.md5) and "same" or "")
                else
                    self.print(err)
                end
            end
        end
    end
end

function ModPatchLib:PatchAll(unpatch)
    for path, data in pairs(self.PATCHS) do
        local isPatched = false
        local targetPath = self.targetPath .. path
        local file, error = io.open(targetPath, "r")
        if file then
            local line = file:read("*l")
            --根据是否已经被patch,读取文件内容
            if line:startWith(self.patchStr) then
                isPatched    = true
                --判断patch版本是否一致
                data.version = line:sub(#self.patchStr + 1):trim()
            end
            file:close()
        end
        data.isPatched = isPatched
        if not isPatched then
            local md5Same, md5, err = true, "", nil
            if data.md5 and self.fileCheck then
                md5, err = self:getFileMd5(self.targetPath .. path)
                md5Same = data.md5 == md5
                if err then self.print(err) end
                data.md5NotSame = not md5Same
            end
            if not md5Same then
                self.print(("file %s md5 check not same, current md5: %s"):format(path, md5))
                if data.cfgKeys then
                    for key, _ in pairs(data.cfgKeys) do
                        self.cfgDisable(key)
                    end
                end
            end
        end
    end
    for path, data in pairs(self.PATCHS) do
        if data.lines and #data.lines > 0 then
            for i = #data.lines, 1, -1 do
                local line = data.lines[i]
                if self.cfgCheck(line.cfgKey) == false then
                    table.remove(data.lines, i)
                end
            end
        end
        if unpatch or (data.lines and #data.lines == 0) then
            data.mode = "unpatch"
        end
        if data.mode == "file" then
            local target, err = io.open(self.originPath .. path, "wb")
            if target then
                target:write(io.open(self.targetPath .. data.path, "rb"):read("*a"))
                target:close()
            end
        elseif data.isPatched or data.mode ~= "unpatch" then
            self:patchFile(path, data)
        end
    end
    if self.enable then
        for key, fns in pairs(self.PATCH_FN) do
            if key == "always" then
                for _, fn in pairs(fns) do
                    fn()
                end
            elseif self.cfgCheck(key) then
                fns()
            end
        end
    end
end

function ModPatchLib:disablePatch(path)
    self.PATCHS[path].mode = "unpatch"
end

---添加patch
---@param path string
---@param cfgKey? string
---@param line cfgLine
function ModPatchLib:addPatch(path, cfgKey, line)
    local patch = self.PATCHS[path]
    if not patch then return end
    if cfgKey then
        patch.cfgKeys = patch.cfgKeys or {}
        patch.cfgKeys[cfgKey] = true
        line.cfgKey = cfgKey
    end
    table.insert(patch.lines, line)
end

---添加多个patch
---@param path string
---@param cfgKey? string
---@param lines cfgLine[]
function ModPatchLib:addPatchs(path, cfgKey, lines)
    for _, line in ipairs(lines) do
        if not self.PATCHS[path] then
            self.PATCHS[path] = { lines = {} }
        end
        self:addPatch(path, cfgKey, line)
    end
end

---添加patch方法
---@param path string|string[]|function?
---@param cfgKey string?
---@param fn? function
function ModPatchLib:addPatchFn(path, cfgKey, fn)
    if type(path) == "function" then
        table.insert(self.PATCH_FN.always, fn)
    else
        self.PATCH_FN[cfgKey] = fn
    end
end

local cfgKey

---压入cfgkey
---@param key string
function ModPatchLib:pushCfgKey(key)
    cfgKey = key
end

---弹出cfgkey
function ModPatchLib:popCfgKey()
    cfgKey = nil
end

---推送patch
---@param key string
---@param line cfgLine
function ModPatchLib:pushPatch(key, line)
    ModPatchLib:addPatch(key, cfgKey, line)
end

---推送多个patch
---@param key string
---@param lines cfgLine[]
function ModPatchLib:pushPatchs(key, lines)
    ModPatchLib:addPatchs(key, cfgKey, lines)
end

return ModPatchLib
