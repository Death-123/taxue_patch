local str257 = [[
local datalist = {
    "isPatched",
    "name",
    "type",
    "amount",
    "amountMap",
    "hasValue",
    "valueMap",
    "taxue_coin_value",
}
]]

local str262 = [[
    for _, key in ipairs(datalist) do
        if inst[key] then data[key] = inst[key] end
    end
]]

local str272 = [[
    for _, key in ipairs(datalist) do
        if data[key] then inst[key] = data[key] end
    end
]]

local lines = {
    { index = 92,  endIndex = 176, type = "override", content = "        UnpackSuperPackage(inst)" },
    { index = 257, type = "add",   content = str257 },
    { index = 262, type = "add",   content = str262 },
    { index = 272, type = "add",   content = str272 },
}

return lines