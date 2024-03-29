local SomniumWidget = require "widgets/SomniumWidget"
local SomniumUtil = require "widgets/SomniumUtil"
local RGBAColor = SomniumUtil.RGBAColor

---@class SomniumText:SomniumWidget
---@overload fun(font?:string, size?:number, color?:RGBAColor, text?:string):SomniumText
---@field _ctor fun(self,font:string,size:number,color:RGBAColor,text?:string):SomniumText
---@field _base SomniumWidget
---@field TextWidget TextWidget
---@field font string
---@field fontSize number
---@field color RGBAColor
---@field text string
local SomniumText = Class(SomniumWidget,
    function(self, font, size, color, text)
        ---@cast self SomniumText
        SomniumWidget._ctor(self, "Text")

        self.inst.entity:AddTextWidget()
        self.TextWidget = self.inst.TextWidget

        self:SetFont(font or DEFAULTFONT)
        self:SetFontSize(size or 30)
        self:SetColour(color)

        self.VAlign = 0
        self.HAlign = 0

        if text then
            self:SetText(text)
        end
    end)

function SomniumText:__tostring()
    return string.format("%s - %s", self.name, self.text or "")
end

---设置颜色
---@param color? RGBAColor|number
---@param g? number
---@param b? number
---@param a? number
function SomniumText:SetColour(color, g, b, a)
    if type(color) == "number" then
        self.color = RGBAColor(color, g, b, a, true)
        self.TextWidget:SetColour(color, g, b, a)
    else
        if not color then
            color = self.color or RGBAColor()
        end
        self.color = RGBAColor(color[1], color[2], color[3], color[4], true)
        self.TextWidget:SetColour(color[1], color[2], color[3], color[4])
    end
end

function SomniumText:SetHorizontalSqueeze(squeeze)
    self.TextWidget:SetHorizontalSqueeze(squeeze)
end

function SomniumText:SetAlpha(a)
    self.TextWidget:SetColour(1, 1, 1, a)
end

function SomniumText:SetFont(font)
    if not font then return end
    self.font = font
    self.TextWidget:SetFont(font)
end

function SomniumText:SetFontSize(fontSize)
    if not fontSize then return end
    if LOC then
        fontSize = fontSize * LOC.GetTextScale()
    end
    self.fontSize = fontSize
    self.TextWidget:SetSize(fontSize)
end

function SomniumText:GetFontSize()
    return self.fontSize
end

---@param w? number
---@param h? number
function SomniumText:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    SomniumText._base.SetSize(self, w, h)
    self.TextWidget:SetRegionSize(w, h)
end

---@return number w, number h
function SomniumText:GetSize()
    return self.TextWidget:GetRegionSize()
end

function SomniumText:SetString(str)
    local text = tostring(str)
    self.text = text
    self.TextWidget:SetString(text)
end

function SomniumText:SetText(text)
    self:SetString(text)
    self:UpdatePosition()
end

function SomniumText:GetString()
    --print("Text:GetString()", self.TextWidget:GetString())
    return self.TextWidget:GetString() or ""
end

function SomniumText:SetVAnchor(anchor)
    self.TextWidget:SetVAnchor(anchor)
end

function SomniumText:SetHAnchor(anchor)
    self.TextWidget:SetHAnchor(anchor)
end

function SomniumText:EnableWordWrap(enable)
    self.TextWidget:EnableWordWrap(enable)
end

function SomniumText:AnimateIn(speed)
    self.textString = self.text
    self.animSpeed = speed or 60
    self.animIndex = 0
    self.animTimer = 0
    self:SetText("")
    self:StartUpdating()
end

function SomniumText:OnUpdate(dt)
    dt = dt or 0
    SomniumText._base.OnUpdate(self, dt)
    if dt > 0 and self.animIndex and self.textString and #self.textString > 0 then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 1 / self.animSpeed then
            self.animTimer = 0
            self.animIndex = self.animIndex + 1
            if self.animIndex > #self.textString then
                self.animIndex = nil
                self:SetText(self.textString)
            else
                local char = string.byte(string.sub(self.textString, self.animIndex, self.animIndex))
                if char and char > 127 then self.animIndex = self.animIndex + 2 end
                self:SetText(string.sub(self.textString, 1, self.animIndex))
            end
        end
    end
end

return SomniumText
