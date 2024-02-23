local str26 = [[
    local resultList = {seeds = 0}
    for slot, v in pairs(slots) do     --遍历一遍物品栏 
        local seed_name = string.lower(v.prefab .. "_seeds")
        local can_accept = v and v.components.edible and Prefabs[seed_name] and (v.components.edible.foodtype == "VEGGIE" or v.components.edible.foodtype == "FRUIT")    --物品列表有改物品的_seeds后缀，那么该物品可分解 
        --处理分解
        if can_accept then
            has = true
            --处理原材料堆叠数量
            local stacksize = v.components.stackable and v.components.stackable.stacksize or 1
            inst.components.container:RemoveItemBySlot(slot):Remove()	--删除材料
            local num_seeds = 0
            local nomal_seeds = 0
            for i = 1, stacksize do
                num_seeds = num_seeds + math.random(2)
                nomal_seeds = nomal_seeds + math.random(0,1)
            end
            resultList[seed_name] = resultList[seed_name] and resultList[seed_name] + num_seeds or num_seeds
            resultList.seeds = resultList.seeds + nomal_seeds
        end
    end
    if has == false then
        GetPlayer().components.talker:Say("你在分解个寂寞呢？")
    else
        for seedName, amount in pairs(resultList) do
            TaxueGiveItem(inst, seedName, amount)
        end
    end
]]

local lines = {
    { index = 26,  endIndex = 50, content = str26 },
}

return lines