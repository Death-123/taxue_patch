local exampleStr = [[
    example
]]

local example = {
    --示例
    --格式如下
    --["文件路径"] = {index = 开始行号, endIndex = 结束行号, type = 修改类型, content = 修改内容},
    --修改类型可以是"add"或"override"
    --add类型会将修改内容插入到开始行号上方
    --add类型结束行号不需要写
    --override类型会将开始行号到结束行号之间的内容全部注释, 然后插入修改内容
    --override类型结束行号默认与开始行号相同, override类型可以不需要写type

    ["scripts/widgets/taxue_level.lua"] = {
        { index = 33, type = "add", content = "    if not (GetPlayer().difficulty and GetPlayer().difficulty_low) then return end" },
    },

    ["scripts/prefabs/taxue_treasure.lua"] = {
        { index = 24, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
        { index = 59, content = [[    {"taxue_egg_nomal",0.05},   --普通蛋]] },
        { index = 82, content = [[    {"taxue_egg_nomal",0.03},   --普通蛋]] },
        { index = 90, content = exampleStr },
    },

    ["scripts/prefabs/taxue_locked_chest.lua"] = {
        {
            index = 641,
            type = "override",
            content = [[
            local function onhammered(inst) inst.components.container:DropEverything() inst.components.container.onclosefn(inst) end
            inst.components.workable:SetOnFinishCallback(onhammered)
            ]]
        }
    },

    ["scripts/prefabs/taxue_sell_pavilion.lua"] = {
         { index = 45, endIndex = 112, content = [[   SellPavilionSellItems(inst)]] }
    },
}

--自定义修改请写在下面
local customPatch = {



}

return customPatch
