local str551 = [[
    local blackList = { "chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone" }
    local package = SpawnPackage()
    local item_list = package.item_list
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30, nil, { "INLIMBO", "NOCLICK", "catchable", "fire" })
    local function testFn(ent)
        local inventoryitem = ent.components.inventoryitem
        local itemName = ent.prefab
        return inventoryitem and inventoryitem.canbepickedup and inventoryitem.cangoincontainer and not ent:HasTag("doydoy")
            and not table.contains(blackList, itemName)
    end
    PackAllEntities(package, ents, testFn, true)
]]

local lines = {
    { index = 551, endIndex = 588, type = "override", content = str551 },
}

return lines
