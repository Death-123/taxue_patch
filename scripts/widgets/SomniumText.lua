local Widget = require "widgets/SomniumWidget"
local WidgetUtil = require "widgets/widgetUtil"
local RGBAColor = WidgetUtil.RGBAColor

---@class SomniumText:SomniumWidget
---@overload fun(font?:string, size?:number, color?:RGBAColor, text?:string):SomniumText
---@field _ctor fun(self,font:string,size:number,color:RGBAColor,text?:string):SomniumText
---@field _base SomniumWidget
---@field TextWidget TextWidget
---@field font string
---@field fontSize number
---@field color RGBAColor
---@field text string
local Text = Class(Widget,
    function(self, font, size, color, text)
        ---@cast self SomniumText
        Widget._ctor(self, "Text")

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

function Text:__tostring()
    return string.format("%s - %s", self.name, self.text or "")
end

---设置颜色
---@param r? RGBAColor|number
---@param g? number
---@param b? number
---@param a? number
function Text:SetColour(r, g, b, a)
    if type(r) == "number" then
        self.color = RGBAColor(r, g, b, a, true)
        self.TextWidget:SetColour(r, g, b, a)
    else
        if not r then
            r = RGBAColor()
        end
        self.color = RGBAColor(r[1], r[2], r[3], r[4], true)
        self.TextWidget:SetColour(r[1], r[2], r[3], r[4])
    end
end

function Text:SetHorizontalSqueeze(squeeze)
    self.TextWidget:SetHorizontalSqueeze(squeeze)
end

function Text:SetAlpha(a)
    self.TextWidget:SetColour(1, 1, 1, a)
end

function Text:SetFont(font)
    self.font = font
    self.TextWidget:SetFont(font)
end

function Text:SetFontSize(fontSize)
    if LOC then
        fontSize = fontSize * LOC.GetTextScale()
    end
    self.fontSize = fontSize
    self.TextWidget:SetSize(fontSize)
end

function Text:GetFontSize()
    return self.fontSize
end

---@param w? number
---@param h? number
function Text:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    self._base.SetSize(self, w, h)
    self.TextWidget:SetRegionSize(w, h)
end

---@return number w, number h
function Text:GetSize()
    return self.TextWidget:GetRegionSize()
end

function Text:SetString(str)
    local text = tostring(str)
    self.text = text
    self.TextWidget:SetString(text)
end

function Text:SetText(text)
    self:SetString(text)
    self:UpdatePosition()
end

function Text:GetString()
    --print("Text:GetString()", self.TextWidget:GetString())
    return self.TextWidget:GetString() or ""
end

function Text:SetVAnchor(anchor)
    self.TextWidget:SetVAnchor(anchor)
end

function Text:SetHAnchor(anchor)
    self.TextWidget:SetHAnchor(anchor)
end

function Text:EnableWordWrap(enable)
    self.TextWidget:EnableWordWrap(enable)
end

function Text:AnimateIn(speed)
    self.textString = self.text
    self.animSpeed = speed or 60
    self.animIndex = 0
    self.animTimer = 0
    self:SetText("")
    self:StartUpdating()
end

function Text:OnUpdate(dt)
    dt = dt or 0
    self._base.OnUpdate(self, dt)
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

return Text
