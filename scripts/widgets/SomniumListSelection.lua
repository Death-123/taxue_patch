local SomniumWindow = require "widgets/SomniumWindow"
local SomniumButton = require "widgets/SomniumButton"
local SomniumImage = require "widgets/SomniumImage"
local SomniumUtil = require "widgets/SomniumUtil"
local RGBAColor = SomniumUtil.RGBAColor

---@class SomniumListSelection:SomniumWindow
---@field displayButton SomniumButton
---@field defaultAtlas string
---@field defaultTex string
---@field open boolean
local SomniumListSelection = Class(SomniumWindow,
    function(self, data)
        ---@cast self SomniumListSelection
        SomniumWindow._ctor(self, { width = data.width, height = data.height, paddingX = 1, paddingY = 1, lineSpacing = 0 })
        self:SetBackground(SomniumImage("images/global.xml", "square.tex"))
        self.background:SetColor(RGBAColor("grey"))
        self.defaultAtlas = "images/global.xml"
        self.defaultTex = "square.tex"
        self.displayButton = self:AddContent(SomniumButton())
        self.displayButton:SetImage(self.defaultAtlas, self.defaultTex)
        self.open = false
        self.list = {}
    end)

function SomniumListSelection:Toggle(enable)
    if self.open then
        self:AnimateSize(self.displayButton:GetSize())
    else
        self:AnimateSize()
    end
    self.open = not self.open
end