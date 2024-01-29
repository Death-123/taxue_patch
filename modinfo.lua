name = "    踏雪补丁"
description = "踏雪mod补丁"
author = "Death"
version = "3.77.4"
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
        hover = "设定打包时判断高属性五彩装备的 (属性/能掉落的最大属性) 比值",
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
        name = "CHEST_CAN_HAMMER",
        label = "可以锤迷你箱",
        hover = "让迷你箱子可以锤",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "PACKAGE_STAFF",
        label = "打包机防破坏",
        hover = "让打包机只能被黄金法杖摧毁",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "DISABLE_GEM_SAVE",
        label = "禁止宝石自动保存",
        hover = "移除使用宝石时的保存",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "BUFF_STAFF",
        label = "增强湛青法杖",
        hover = "提高湛青,锻造法杖的工作效率,并且提高加速数值",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "BUFF_STAFF_SPEED",
        label = "增强速度",
        hover = "湛青/五彩/锻造法杖提高的速度",
        options = {
            { description = "50",  data = 0.5 },
            { description = "75",  data = 0.75 },
            { description = "100", data = 1 },
            { description = "150", data = 1.5 },
            { description = "300", data = 3 },
        },
        default = 0.5,
    },
    {
        name = "BUFF_STAFF_MULT",
        label = "增强效率",
        hover = "湛青/锻造法杖提高的工作效率",
        options = {
            { description = "1.33/2(默认)", data = 1 },
            { description = "2/4", data = 2 },
            { description = "3/6", data = 3 },
            { description = "4/8", data = 4 },
            { description = "5/10", data = 5 },
            { description = "6/12", data = 6 },
        },
        default = 1,
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
    {
        name = "FLOWERPOT_PHYSICS",
        label = "移除花盆碰撞",
        hover = "移除花盆碰撞",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
    {
        name = "AUTO_AMULET",
        label = "终极自动护符",
        hover = "终极自动护符",
        options = {
            { description = "启用", data = true },
            { description = "禁用", data = false },
        },
        default = true,
    },
}
