local print = TaxuePatch.mprint

---@param input string
---@param delimiter string
---@return table
function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then return { input } end
    local pos, arr = 0, {}
    for st, sp in function () return string.find(input, delimiter, pos, true) end do
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
    inst.OnSave = function (self, data)
        if after then onsave(self, data) end
        for dataItem, save in pairs(dataItems) do
            if save then
                if self[dataItem] then data[dataItem] = self[dataItem] end
            end
        end
        if not after then onsave(self, data) end
    end

    local onload = inst.OnLoad
    inst.OnLoad = function (self, data)
        if after then onload(self, data) end
        for dataItem, save in pairs(dataItems) do
            if save then
                if data[dataItem] then self[dataItem] = data[dataItem] end
            end
        end
        if not after then onload(self, data) end
    end
end
