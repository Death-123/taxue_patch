local str79 = [[
    if not inst.isPatched and inst.item_list and next(inst.item_list) then
        local tempPackage = SpawnPrefab("super_package")
        tempPackage.item_list = inst.item_list
        if package then
            package = MergePackage(package, tempPackage)
        else
            package = TransformPackage(tempPackage)
        end
    end
    if package and not package.isPatched then
        package = TransformPackage(package)
    end
    inst.isPatched = true
]]

local str93 = [[
        local blackList = {"chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone", "blooming_armor", "blooming_headwear"}
        local pos = Vector3(inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, { "INLIMBO", "NOCLICK", "catchable", "fire" })
        local function testFn(ent)
            local item = ent.components.inventoryitem
            return item and item.canbepickedup and item.cangoincontainer and not ent:HasTag("doydoy") and not ent:HasTag("taxue_ultimate_weapon") and not table.contains(blackList, ent.prefab)
        end
        PackAllEntities(package, ents, testFn)
        --判断字典型数组是否空
        if TableCount(package.item_list) == 0 and package.components.container:IsEmpty() then
            package:Remove()
            package = nil
        end
    end)
end
]]

local lines = {
    { index = 79,  endIndex = 82,  type = "override", content = str79 },
    { index = 93,  endIndex = 134, type = "override", content = str93 },
    { index = 88, type = "override", content = "            package = SpawnPackage()" },
    { index = 148, endIndex = 151, type = "override" },
    { index = 166, type = "add", content = "    data.isPatched = inst.isPatched" },
    { index = 172, type = "add", content = "    inst.isPatched = data.isPatched" },
}

return lines
