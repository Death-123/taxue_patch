local DataSave = require "dataSave"

---@class option
---@field des string
---@field value any

---@class ConfigEntry
---@field id string
---@field name string
---@field description? string
---@field type? string
---@field forceDisable? boolean
---@field options? option[]
---@field default? any
---@field value? any
---@field subConfigs? ConfigEntry[]
---@field parent? ConfigEntry
---@field Get fun(self,key:string):ConfigEntry
---@field GetValue fun(self,key?:string):any

---@type option[]
local enableOptions = {
    { des = "启用", value = true },
    { des = "禁用", value = false },
}

---@type option[]
local forceDisableOptions = {
    { des = "强制禁用", value = true }
}

---@type option[]
local colorOptions = {
    { des = "海蓝宝石色", value = "aquamarine" },
    { des = "品红色", value = "magenta" },
    { des = "青色", value = "cyan" },
    { des = "蓝色", value = "blue" },
    { des = "绿色", value = "green" },
    { des = "黄色", value = "yellow" },
    { des = "金色", value = "gold" },
    { des = "橙色", value = "orange" },
    { des = "粉红色", value = "pink" },
    { des = "浅绿色", value = "lime" },
    { des = "灰色", value = "grey" },
}

---@type option[]
local percentOptions = {
    { des = "10%", value = 0.10 },
    { des = "20%", value = 0.20 },
    { des = "30%", value = 0.30 },
    { des = "40%", value = 0.40 },
    { des = "50%", value = 0.50 },
    { des = "60%", value = 0.60 },
    { des = "70%", value = 0.70 },
    { des = "80%", value = 0.80 },
    { des = "90%", value = 0.90 },
    { des = "100%", value = 1.00 },
    { des = "禁用", value = false },
}

---@type option[]
local keybindOptions = {
    { des = "小键盘0", value = 256 },
    { des = "小键盘1", value = 257 },
    { des = "小键盘2", value = 258 },
    { des = "小键盘3", value = 259 },
    { des = "小键盘4", value = 260 },
    { des = "小键盘5", value = 261 },
    { des = "小键盘6", value = 262 },
    { des = "小键盘7", value = 263 },
    { des = "小键盘8", value = 264 },
    { des = "小键盘9", value = 265 },
    { des = "小键盘.", value = KEY_KP_PERIOD },
    { des = "小键盘/", value = KEY_KP_DIVIDE },
    { des = "小键盘*", value = KEY_KP_MULTIPLY },
    { des = "小键盘-", value = KEY_KP_MINUS },
    { des = "小键盘+", value = KEY_KP_PLUS },
    { des = "小键盘Enter", value = KEY_KP_ENTER },
}

---@type ConfigEntry[]
local cfg = {
    {
        id = "patchEnable",
        name = "启用补丁",
        description = "是否启用补丁,关闭补丁前请禁用此选项加载一次"
    },
    {
        id = "fileCheck",
        name = "文件校验",
        description = "是否启用文件校验,用于检测踏雪mod文件是否可以被patch,如果禁用,请确保补丁版本匹配,并且踏雪文件没有被改动",
        subConfigs = {
            {
                id = "md5Bytes",
                name = "md5读取长度",
                description = "md5计算时每次读取的字节长度,如果加载mod时内存溢出,可以尝试将此配置改小",
                type = "number",
                options = {
                    { des = "C语言库", value = "C" },
                    { des = "32", value = 32 },
                    { des = "16", value = 16 },
                    { des = "8", value = 8 },
                    { des = "1", value = 1 },
                    { des = "1/16", value = 1 / 16 },
                },
                default = "C"
            }
        }
    },
    {
        id = "ingameGC",
        name = "内存清理",
        description = "定时清理内存,设置清理检查间隔",
        type = "number",
        options = {
            { des = "1分钟", value = 1 },
            { des = "5分钟", value = 5 },
            { des = "10分钟", value = 10 },
            { des = "30分钟", value = 30 },
            { des = "60分钟", value = 60 },
            { des = "禁用", value = false },
        },
        default = 10,
    },
    {
        id = "taxueFix",
        name = "踏雪优化",
        description = "优化踏雪mod部分功能",
        subConfigs = {
            {
                id = "dropAsh",
                name = "移除掉落物变灰烬",
                description = "让着火的怪物掉落物不会变成灰烬",
            },
            {
                id = "betterDrop",
                name = "物品掉落优化",
                description = "掉落物合并,当附近有开启的打包机时,直接进打包机",
                subConfigs = {
                    {
                        id = "stackDrop",
                        name = "掉落物自动堆叠",
                        description = "掉落物会自动堆叠进附近已存在的物品"
                    }
                }
            }
        }
    },
    {
        id = "teleportCat",
        name = "定位猫猫",
        description = "强制检查猫猫地灯会传送到猫猫地灯位置",
        subConfigs = {

        }
    },
    {
        id = "oneClickUse",
        name = "一键使用",
        description = "利息券,战利品券等一键使用",
        subConfigs = {

        }
    },
    {
        id = "displaySetting",
        name = "显示设置",
        type = "forceEnable",
        subConfigs = {
            {
                id = "desColor",
                name = "描述文字颜色",
                description = "物品上方显示或信息面板的文字颜色",
                type = "color",
                default = "aquamarine"
            },
            {
                id = "showBanner",
                name = "横幅提示",
                description = "使用信息面板横幅显示获得经验,双爆等提示",
                subConfigs = {
                    {
                        id = "bannerColor",
                        name = "横幅颜色",
                        type = "color",
                        default = "gold"
                    }
                }
            },
            {
                id = "showShop",
                name = "商店显示",
                description = "显示商店售卖物品"
            }
        }
    },
    {
        id = "fortunePatch",
        name = "梅运券修改",
        subConfigs = {
            {
                id = "usePatch",
                name = "使用方式修改",
                description = "读劵时会将劵填装到玩家上,当填装的劵大于0,可以将鼠标放在右上角状态栏查看运势",
            },
            {
                id = "showNum",
                name = "显示数值",
                description = "显示具体霉运值数值"
            }
        }
    },
    {
        id = "buffThings",
        name = "物品增强",
        subConfigs = {
            {
                id = "chestCanHammer",
                name = "可以锤迷你箱",
                description = "让迷你箱子可以被锤"
            },
            {
                id = "packageMachineCantHammer",
                name = "打包机防破坏",
                description = "让打包机只能被黄金法杖摧毁"
            },
            {
                id = "disableGemSave",
                name = "禁止宝石自动保存",
                description = "移除使用宝石时的保存"
            },
            {
                id = "sellPavilion",
                name = "售货亭修改",
                description = "金砖模式会在卖出后梅币大于500时,将售货亭内梅币转换为金砖,代替银行模式会同时拥有银行的功能",
                options = {
                    { des = "禁用", value = false },
                    { des = "金砖", value = "goldBrick" },
                    { des = "银行", value = "bank" },
                },
                default = "goldBrick"
            },
            {
                id = "flowerporPhysics",
                name = "移除花盆碰撞",
            },
            {
                id = "buffStaff",
                name = "增强湛青法杖",
                description = "提高湛青,锻造法杖的锤,铲工作效率"
            },
            {
                id = "staffSpeed",
                name = "湛青锻造速度",
                description = "湛青/锻造法杖提高的速度",
                type = "number",
                options = {
                    { des = "20%(默认)", value = 0.2 },
                    { des = "35%", value = 0.35 },
                    { des = "50%", value = 0.5 },
                    { des = "75%", value = 0.75 },
                    { des = "100%", value = 1 },
                    { des = "150%", value = 1.5 },
                    { des = "300%", value = 3 },
                },
                default = 0.2
            },
            {
                id = "colorfulStaffSpeed",
                name = "五彩法杖速度",
                description = "五彩法杖提高的速度",
                type = "number",
                options = {
                    { des = "20%", value = 0.2 },
                    { des = "35%(默认)", value = 0.35 },
                    { des = "50%", value = 0.5 },
                    { des = "75%", value = 0.75 },
                    { des = "100%", value = 1 },
                    { des = "150%", value = 1.5 },
                    { des = "300%", value = 3 },
                },
                default = 0.35
            },
            {
                id = "staffMult",
                name = "增强效率",
                description = "湛青法杖提高的工作效率",
                type = "number",
                options = {
                    { des = "1.33(默认)", value = 1.33 },
                    { des = "2", value = 2 },
                    { des = "3", value = 3 },
                    { des = "4", value = 4 },
                    { des = "5", value = 5 },
                    { des = "6", value = 6 },
                },
                default = 1.33
            },
            {
                id = "forgeStaffMult",
                name = "增强效率",
                description = "锻造法杖提高的工作效率",
                type = "number",
                options = {
                    { des = "2(默认)", value = 2 },
                    { des = "4", value = 4 },
                    { des = "6", value = 6 },
                    { des = "8", value = 8 },
                    { des = "10", value = 10 },
                    { des = "12", value = 12 },
                },
                default = 2
            },
            {
                id = "greenAmulet",
                name = "超级绿护符次数",
                description = "修改超级建造护符添加绿宝石增加的耐久",
                type = "integer",
                options = {
                    { des = "4(默认)", value = 4 },
                    { des = "5", value = 5 },
                    { des = "6", value = 6 },
                    { des = "7", value = 7 },
                    { des = "8", value = 8 },
                    { des = "10", value = 10 },
                },
                default = 4
            }
        }
    },
    {
        id = "package",
        name = "打包系统",
        description = "你值得拥有",
        subConfigs = {
            {
                id = "maxAmount",
                name = "每包最大数量",
                description = "拆包时,重新打包物品的每包最大数量",
                type = "integer",
                options = {
                    { des = "16",  value = 16 },
                    { des = "32",  value = 32 },
                    { des = "48",  value = 48 },
                    { des = "64",  value = 64 },
                    { des = "80",  value = 80 },
                    { des = "100", value = 100 },
                },
                default = 16,
            },
            {
                id = "highEquipmentPercent",
                name = "高属性五彩比值",
                description = "设定打包时判断高属性五彩装备的 (属性/能掉落的最大属性) 比值",
                type = "percent",
                options = {
                    { des = "25%", value = 0.25 },
                    { des = "50%", value = 0.50 },
                    { des = "75%", value = 0.75 },
                    { des = "85%", value = 0.85 },
                    { des = "90%", value = 0.90 },
                    { des = "95%", value = 0.95 },
                },
                default = 0.75,
            },
            {
                id = "desMaxLines",
                name = "最大显示行数",
                description = "超级包裹显示最大行数",
                type = "integer",
                options = {
                    { des = "0",  value = 0 },
                    { des = "1",  value = 1 },
                    { des = "3",  value = 3 },
                    { des = "5",  value = 5 },
                    { des = "10", value = 10 },
                    { des = "15", value = 15 },
                    { des = "20", value = 20 },
                    { des = "30", value = 30 },
                },
                default = 10,
            },
            {
                id = "openTreasures",
                name = "打包开宝藏",
                description = "打包书和打包机打包时会开宝藏,并将物品包进包裹",
            },
            {
                id = "machineTreasures",
                name = "打包机能否开宝藏",
            },
            {
                id = "destoryChest",
                name = "拆除宝藏箱子",
                description = "打包书和打包机开宝藏时,会将箱子一并拆除,并将物品包进包裹",
            },
            {
                id = "destoryStatue",
                name = "拆除宝藏雕像",
                description = "打包书和打包机开宝藏时,会将雕像一并拆除,并将物品包进包裹",
            },
        }
    },
    {
        id = "autoAmulet",
        name = "终极自动护符",
        description = "自动维修,自动吃药,终极自动护符等你体验",
        subConfigs = {
            {
                id = "weaponPercent",
                name = "武器耐久触发值",
                description = "当武器耐久低于此百分比时自动维修",
                type = "percent",
                default = 0.5
            },
            {
                id = "armorPercent",
                name = "护甲触发值",
                description = "当护甲耐久低于此百分比时自动维修",
                type = "percent",
                default = 0.7,
            },
            {
                id = "autoEatTemperature",
                name = "自动吃温度药剂",
            },
            {
                id = "autoHeal",
                name = "自动喝血量药剂",
            },
            {
                id = "autoHealNum",
                name = "自动喝血触发值",
                description = "当血量低于此值时自动使用血量药剂",
                type = "integer",
                options = {
                    { des = "10", value = 10 },
                    { des = "20", value = 20 },
                    { des = "30", value = 30 },
                    { des = "40", value = 40 },
                    { des = "50", value = 50 },
                    { des = "60", value = 60 },
                    { des = "70", value = 70 },
                    { des = "80", value = 80 },
                    { des = "90", value = 90 },
                    { des = "100", value = 100 },
                    { des = "150", value = 150 },
                    { des = "200", value = 200 },
                    { des = "禁用", value = false },
                },
                default = 30,
            },
            {
                id = "autoHealPer",
                name = "自动喝血触发百分比",
                description = "当血量低于此百分比时自动使用血量药剂",
                type = "percent",
                default = 0.5
            },
            {
                id = "autoHealKeybind",
                name = "自动喝血按键",
                description = "终极自动护符开关自动喝血按键",
                type = "keybind",
                default = 256
            }
        }
    }
}

---@class Config
---@overload fun(modname:string):Config
---@field modname string
---@field cfg ConfigEntry[]
---@field dataSave DataSave
local Config = Class(
    function(self, modname)
        ---@cast self Config
        self.modname = modname
        self.cfg = cfg
        self.dataSave = DataSave(self.modname, { name = self.modname .. "_config" })
        self:Init()
        self:Load()
    end)

function Config:Init()
    self:TraversalAllConfigEntry(function(ConfigEntry, parent)
        setmetatable(ConfigEntry, Config)
        ConfigEntry.parent = parent
    end)
    local oldInitializeModInfo = KnownModIndex.InitializeModInfo
    function KnownModIndex.InitializeModInfo(_self, name, ...)
        local info = oldInitializeModInfo(_self, name, ...)
        if name == self.modname then
            self:InjectModConfig(info.configuration_options)
        end
        return info
    end

    local function overWriteConfig(configuration_options)
        for _, option in pairs(configuration_options) do
            if option.saved ~= nil then
                local function set(configEntry)
                    if configEntry.id == option.name then
                        if option.saved == option.default then
                            configEntry.value = nil
                        else
                            configEntry.value = option.saved
                        end
                        return true
                    end
                end
                self:TraversalAllConfigEntry(set)
            end
        end
    end

    local oldLoadModConfigurationOptions = KnownModIndex.LoadModConfigurationOptions
    function KnownModIndex.LoadModConfigurationOptions(_self, modname, ...)
        local configuration_options = oldLoadModConfigurationOptions(_self, modname, ...)
        if modname == self.modname and configuration_options then
            overWriteConfig(configuration_options)
        end
        return configuration_options
    end

    local oldSaveConfigurationOptions = KnownModIndex.SaveConfigurationOptions
    function KnownModIndex.SaveConfigurationOptions(_self, callback, modname, configdata, ...)
        if modname == self.modname and configdata then
            overWriteConfig(configdata)
            self:SaveCfg()
        end
        oldSaveConfigurationOptions(_self, callback, modname, configdata, ...)
    end
end

---获取配置
---@param key string
---@return ConfigEntry|nil configEntry
function Config:Get(key)
    if not key then
        if self --[[@as ConfigEntry]].id then
            ---@type ConfigEntry
            return self
        else
            return nil
        end
    end
    local keys = key:split(".")
    local data = self.cfg or self
    local found
    for _, key in pairs(keys) do
        found = nil
        for _, configEntry in pairs(data) do
            if configEntry.id == key then
                found = configEntry
                data = configEntry.subConfigs
                break
            end
        end
        if not found then return nil end
    end
    return setmetatable(found, Config)
end

---获取配置值
---@param key? string
---@return any value
---@return boolean isDefault
function Config:GetValue(key)
    local configEntry = self:Get(key)
    if not configEntry then return nil, false end
    local value, isDefault = nil, false
    if configEntry.forceDisable then
        return false, false
    elseif configEntry.value ~= nil then
        value = configEntry.value
    elseif configEntry.default then
        value, isDefault = configEntry.default, true
    else
        value, isDefault = true, true
    end
    local parent = configEntry.parent
    if parent then
        value = value and parent:GetValue()
    end
    return value, isDefault
end

---设置配置值
---@param key string|any
---@param value? any
function Config:Set(key, value)
    local configEntry = value and self:Get(key) or self
    configEntry.value = value or key
end

---获取配置类型
---@param key? string
---@return string?
function Config:GetType(key)
    local configEntry = key and self:Get(key) or self
    return configEntry.type
end

---获取配置选项
---@param configEntry ConfigEntry
---@return option[]?
function Config.getOptions(configEntry)
    if configEntry.forceDisable then
        return 
    elseif configEntry.options then
        return configEntry.options
    elseif configEntry.type then
        if configEntry.type == "color" then
            return colorOptions
        elseif configEntry.type == "percent" then
            return percentOptions
        elseif configEntry.type == "keybind" then
            return keybindOptions
        else
            return { { des = " ", value = true } }
        end
    else
        return enableOptions
    end
end

---获取配置选项
---@param key? string
---@return option[]?
function Config:GetOptions(key)
    local configEntry = key and self:Get(key) or self
    return Config.getOptions(configEntry)
end

---获取默认值
---@param configEntry ConfigEntry
---@return any
function Config.getDefault(configEntry)
    return configEntry.default or true
end

---获取默认值
---@param key? string
---@return any
function Config:GetDefault(key)
    local configEntry = key and self:Get(key) or self
    return Config.getDefault(configEntry)
end

function Config:forceDisable(key)
    local configEntry = self:Get(key)
    if configEntry then
        configEntry.forceDisable = true
    end
end

---遍历所有配置项
---@param fn fun(ConfigEntry:ConfigEntry,parent?:ConfigEntry): stop:boolean?
---@param ConfigEntrys? ConfigEntry[]
---@param parent? ConfigEntry
---@return boolean? stop
function Config:TraversalAllConfigEntry(fn, ConfigEntrys, parent)
    ConfigEntrys = ConfigEntrys or self.cfg
    for _, ConfigEntry in pairs(ConfigEntrys) do
        if fn(ConfigEntry, parent) then return true end
        if ConfigEntry.subConfigs then
            self:TraversalAllConfigEntry(fn, ConfigEntry.subConfigs, ConfigEntry)
        end
    end
end

function Config.GetVanillaEntry(ConfigEntry)
    local entry = {}
    entry.name = ConfigEntry.id
    entry.label = ConfigEntry.name
    entry.hover = ConfigEntry.description
    entry.options = {}
    entry.default = Config.getDefault(ConfigEntry)
    local options = Config.getOptions(ConfigEntry)
    for _, option in pairs(options) do
        table.insert(entry.options, { description = option.des, data = option.value })
    end
    return entry
end

---注入原版配置项
---@param configuration_options? table
---@return table configuration_options
function Config:InjectModConfig(configuration_options)
    local configuration_options = configuration_options or KnownModIndex:GetModInfo(self.modname).configuration_options
    local function InjectModConfigEntry(ConfigEntry)
        table.insert(configuration_options, ConfigEntry:GetVanillaEntry())
    end
    self:TraversalAllConfigEntry(InjectModConfigEntry)
    return configuration_options
end

function Config:SaveCfg()
    local data = {}
    local function save(ConfigEntry)
        if ConfigEntry.value ~= nil then
            table.insert(data, { id = ConfigEntry.id, value = ConfigEntry.value })
        end
    end
    self:TraversalAllConfigEntry(save)
    self.dataSave:Save(data)
end

function Config:LoadCfg()
    local success, data = self.dataSave:Load()
    if data then
        local function load(ConfigEntry)
            for _, entry in pairs(data) do
                if entry.id == ConfigEntry.id then
                    ConfigEntry.value = entry.value
                    break
                end
            end
        end
        self:TraversalAllConfigEntry(load)
    end
end

function Config:Save()
    local configuration_options = KnownModIndex:GetModInfo(self.modname).configuration_options
    local function save(ConfigEntry)
        if ConfigEntry.value ~= nil then
            for _, option in pairs(configuration_options) do
                if option.name == ConfigEntry.id then
                    option.saved = ConfigEntry.value
                    break
                end
            end
        end
    end
    self:TraversalAllConfigEntry(save)
    KnownModIndex:SaveConfigurationOptions(nil, self.modname, configuration_options)
end

function Config:Load()
    self:LoadCfg()
    KnownModIndex:LoadModConfigurationOptions(self.modname)
end

return Config
