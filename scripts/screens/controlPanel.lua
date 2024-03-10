local SomniumWidget = require "widgets/SomniumWidget"
local SomniumImage = require "widgets/SomniumImage"
local SomniumWindow = require "widgets/SomniumWindow"

local Pages = {

}

---@class ControlPanel: SomniumWindow
---@field pages table<string,table>
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
        self:Init()

        self:SetDraggable(true)
    end)

function ControlPanel:Init()
    self:SetTitle("踏雪补丁控制面板")
end

function ControlPanel:AddMainPage()
    self.mainPage = self:AddChild()
end

function ControlPanel:AddPages(pages)
    for id, page in pairs(self.pages) do
        page:Kill()
        self.pages[id] = nil
    end
end

function ControlPanel:AddPage(key)
    local pageEntrance = self:AddContent(SomniumWidget("pageEntrance - " .. key))
    pageEntrance.key = key
end

return ControlPanel