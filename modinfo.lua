name = "踏雪补丁"
description = "踏雪mod补丁"
author = "Death"
version = "3.76.1"
forumthread = ""
api_version = 6
priority = -3125

dst_compatible = false
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options = {
    {
        name = "HIGH_EQUIPMENT_PERCENT",
        label = "高属性五彩比值",
        hover = "打包时判断高属性五彩装备的(属性/能掉落的最大属性)比值",
        options = {
            { description = "25%", data = 0.25 },
            { description = "50%", data = 0.50 },
            { description = "75%", data = 0.75 },
            { description = "85%", data = 0.85 },
            { description = "90%", data = 0.90 },
            { description = "95%", data = 0.95 },
        },
        default = 0.75,
    },
    {
        name = "SHOW_SHOP",
        label = "显示商店",
        hover = "显示商店售卖物品",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "PACKAGE_PATCH",
        label = "修改打包系统",
        hover = "你值得拥有",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "PACKAGE_MAX_AMOUNT",
        label = "每包最大数量",
        hover = "拆包时,重新打包不可堆叠物品的每包最大数量",
        options = {
            { description = "16",  data = 16 },
            { description = "32",  data = 32 },
            { description = "48",  data = 48 },
            { description = "64",  data = 64 },
            { description = "80",  data = 80 },
            { description = "100", data = 100 },
        },
        default = 16,
    },
    {
        name = "PACKAGE_DES_MAX_LINES",
        label = "包裹最大行数",
        hover = "超级包裹显示最大行数",
        options = {
            { description = "0",  data = 0 },
            { description = "1",  data = 1 },
            { description = "3",  data = 3 },
            { description = "5",  data = 5 },
            { description = "10", data = 10 },
            { description = "15", data = 15 },
        },
        default = 5,
    },
}
