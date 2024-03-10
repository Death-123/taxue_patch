local SomniumWidget = require "widgets/SomniumWidget"
local SomniumImage = require "widgets/SomniumImage"
local SomniumWindow = require "widgets/SomniumWindow"

---@class ControlPanelMainPage:SomniumWindow
local ControlPanelMainPage = Class(SomniumWindow,
    function(self)
        ---@cast self ControlPanelMainPage
        local data = {
            width = 400,
            height = 800,
            paddingX = 40,
            paddingY = 40,
        }
        SomniumWindow._ctor(self, data)
        self.displayRoot = self:AddChild(SomniumWidget("mainPageDisplayRoot"))
        self.displayContents = {}

    end)

function ControlPanelMainPage:InitDisplayContent()
    
end