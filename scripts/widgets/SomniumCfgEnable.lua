local SomniumCfgWidget = require "widgets/SomniumCfgWidget"
local SomniumButton = require "widgets/SomniumButton"

---@class SomniumCfgEnableWidget:SomniumCfgWidget
---@field button SomniumButton
local SomniumCfgEnableWidget = Class(SomniumCfgWidget,
    function(self, data)
        ---@cast self SomniumCfgEnableWidget
        SomniumCfgWidget._ctor(self, "SomniumCfgEnable", data)
        self.button = self:AddChild(SomniumButton())
    end)


return SomniumCfgEnableWidget
