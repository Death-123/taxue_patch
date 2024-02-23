local SomniumImage = require "widgets/SomniumImage"
local SomniumWindow = require "widgets/SomniumWindow"

---@class ControlPanel: SomniumWindow
local ControlPanel = Class(SomniumWindow,
    function(self)
        ---@cast self ControlPanel
        local data = {
            width = 400,
            height = 300,
            paddingX = 40,
            paddingY = 40,
            lineSpacing = 10,
            background = SomniumImage("images/globalpanels.xml", "panel_long.tex")
        }
        SomniumWindow._ctor(self, data)

        self:SetDraggable(true)
    end)


return ControlPanel