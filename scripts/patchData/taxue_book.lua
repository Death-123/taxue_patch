local str551 = [[
            local blackList = { "chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone" }
            local package = SpawnPackage()
            local item_list = package.item_list
            local pos = Vector3(inst.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 30, nil, { "INLIMBO", "NOCLICK", "catchable", "fire" })
            for __, v in pairs(ents) do
                local inventoryitem = v.components.inventoryitem
                local itemName = v.prefab
                if inventoryitem and inventoryitem.canbepickedup and inventoryitem.cangoincontainer and not v:HasTag("doydoy")
                    and not table.contains(blackList, itemName) then
                    if v:HasTag("loaded_package") and v.loaded_item_list then
                        for _, name in pairs(v.loaded_item_list) do
                            AddItemToSuperPackage(package, SpawnPrefab(name), true)
                        end
                        v:Remove()
                    else
                        AddItemToSuperPackage(package, v, true)
                    end
                end
            end
            if TableCount(package.item_list) == 1 then
                for type, _ in pairs(package.item_list) do
                    package.name = ItemTypeNameMap[type]
                    package.type = type
                end
            end
]]

local lines = {
    { index = 551, endIndex = 588, type = "override", content = str551 },
}

return lines
