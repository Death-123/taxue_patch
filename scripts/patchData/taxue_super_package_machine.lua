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
        inst.components.container:GiveItem(package)
    end
    inst.isPatched = true
]]

local str93 = [[
        local blackList = {"chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone", "blooming_armor", "blooming_headwear"}
        local pos = Vector3(inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, { "INLIMBO", "NOCLICK", "catchable", "fire" })
        for __, v in pairs(ents) do
            local item = v.components.inventoryitem
            if item and item.canbepickedup and item.cangoincontainer and not v:HasTag("doydoy") and not v:HasTag("taxue_ultimate_weapon") and not table.contains(blackList, v.prefab) then
                if v:HasTag("loaded_package") and v.loaded_item_list then
                    for _, name in pairs(v.loaded_item_list) do
                        AddItemToSuperPackage(package, SpawnPrefab(name), true)
                    end
                else
                    AddItemToSuperPackage(package, v, true)
                end
            end
        end
        if TableCount(package.item_list) == 1 then
            for type, _ in pairs(package.item_list) do
                package.type = type
            end
        else
            package.type = nil
            package.name = TaxueToChs(package.prefab)
        end
        --判断字典型数组是否空
        if TableCount(package.item_list) == 0 and package.components.container:IsEmpty() then
            package:Remove()
        end
    end)
end
]]

local data = {
    mode = "patch",
    md5 = "db41fa7eba267504ec68e578a3c31bb1",
    lines = {
        { index = 79,  endIndex = 82,  type = "override", content = str79 },
        { index = 93,  endIndex = 134, type = "override", content = str93 },
        { index = 148, endIndex = 151, type = "override" }
    }
}

return data
