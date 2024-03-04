local SomniumImage = require "widgets/SomniumImage"
local SomniumWindow = require "widgets/SomniumWindow"

---@class ControlPanel: SomniumWindow
local ControlPanel = Class(SomniumWindow,
    function(self)
        ---@cast self ControlPanel
        local data = {
            width = 400,
            height = 800,
            paddingX = 40,
            paddingY = 40,
            lineSpacing = 10,
            background = SomniumImage("images/dst/scoreboard.xml", "scoreboard_frame.tex")
        }
        SomniumWindow._ctor(self, data)

        self:SetDraggable(true)
    end)


return ControlPanel