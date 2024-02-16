local Widget = require "widgets/SomniumWidget"
local SlicedImage = require "widgets/SomniumSlicedImage"
local SomniumText = require "widgets/SomniumText"
local WidgetUtil = require "widgets/widgetUtil"
local RGBAColor = WidgetUtil.RGBAColor

---@class SomniumWindow:SomniumWidget
---@overload fun(data:table):SomniumWindow
---@field _base SomniumWidget
---@field background SomniumSlicedImage
---@field paddingX integer
---@field paddingY integer
---@field currentLineY integer
---@field lineSpacing integer
---@field contents SomniumWidget[]
local Window = Class(Widget,
    function(self, data)
        ---@cast self SomniumWindow
        Widget._ctor(self, "SomniumWindow")
        self.width = data.width or 400
        self.height = data.height or 300
        self.paddingX = data.paddingX or 40
        self.paddingY = data.paddingY or 42
        self.screenScale = 1
        self.currentLineY = 0
        self.lineSpacing = data.lineSpacing or 10
        self.contents = {}
        if data.background then
            self:SetBackground(data.background)
        end
        -- self:SetCenterAlignment()
        self:SetSize()
        -- self:SetPosition(0, 0, 0)
        self:StartUpdating()
    end)

function Window:SetBackground(bg)
    if self.background then self.background:Kill() end
    self.background = self:AddChild(SlicedImage(bg))
    self.background:SetSize(self.width, self.height)
end

function Window:SetAnchors(anchorX, anchorY)
    self:SetVAnchor(anchorX)
    self:SetHAnchor(anchorY)
end

function Window:SetAnchor(XY, anchor)
    if XY then
        self:SetVAnchor(anchor)
    else
        self:SetHAnchor(anchor)
    end
end

function Window:SetPosition(...)
    -- self.bg:SetPosition(...)
    self._base.SetPosition(self, ...)
end

function Window:GetPosition()
    return self._base.GetPosition(self)
end

function Window:SetSize(width, height)
    width = width or self.width
    height = height or self.height
    self.width = width; self.height = height
    if self.background then self.background:SetSize(width, height) end
end

function Window:GetSize() return self.width, self.height end

function Window:SetTitle(title, font, size, color)
    if not self.title then
        self.title = self:AddChild(SomniumText(font, size, color, title))
        self.title:SetAligns(nil, WidgetUtil.Aligns.TOP)
        local _, offsetY = self.title:GetSize()
        offsetY = offsetY + self.lineSpacing * 1.5
        if next(self.contents) then
            for _, content in pairs(self.contents) do
                content:SetOffset(nil, offsetY)
            end
        end
        self.currentLineX = self.currentLineY + offsetY
    end
    self.title:SetOffset(0, -self.paddingY, 0)
end

---添加内容
---@param content SomniumWidget
---@param key? string
---@param contentHeight? number
---@return SomniumWidget
function Window:AddContent(content, key, contentHeight)
    local newContent = self:AddChild(content)
    if not contentHeight and newContent.GetSize then
        _, contentHeight = newContent:GetSize()
    end
    contentHeight = contentHeight or 100
    newContent:SetOffset(nil, -self.paddingY - self.currentLineY - contentHeight / 2)
    self.currentLineY = self.currentLineY + contentHeight + self.lineSpacing
    if key then
        self.contents[key] = newContent
    else
        table.insert(self.contents, newContent)
    end
    return newContent
end

function Window:ClearContents()
    for _, content in pairs(self.contents) do content:Kill() end
    table.clear(self.contents)
    self.currentLineY = 0
end

function Window:NewLine(height)
    self.currentLineY = self.currentLineY + height
end

function Window:OnRawKey(key, down)
    local flag = self._base.OnRawKey(self, key, down)
    if not self.focus then return false end
    return flag
end

function Window:OnControl(control, down)
    local flag = self._base.OnControl(self, control, down)
    if not self.focus then return false end
    return flag
end

function Window:AnimateSize(w, h, speed)
    if w and h then
        self.animTargetSize = { w = w, h = h }
        self.animSpeed = speed or 5
    end
end

function Window:OnUpdate(dt)
    dt = dt or 0
    if self.animTargetSize and dt > 0 then
        local w, h = self:GetSize()
        if math.abs(w - self.animTargetSize.w) < 1 then
            self:SetSize(self.animTargetSize.w, self.animTargetSize.h)
            self.animTargetSize = nil
        else
            self:SetSize(WidgetUtil.Lerp(w, self.animTargetSize.w, self.animSpeed * dt), WidgetUtil.Lerp(h, self.animTargetSize.h, self.animSpeed * dt))
        end
    end
    local widthScale = WidgetUtil.getWidthScal()
    if widthScale ~= self.screenScale then
        self.background:SetScale(widthScale)
        local offset = self:GetOffset()
        offset.x = offset.x * widthScale / self.screenScale
        offset.y = offset.y * widthScale / self.screenScale
        self:SetOffset(offset)
        self.screenScale = widthScale
    end
end

return Window
