local SomniumWidget = require "widgets/SomniumWidget"
local SomniumText = require "widgets/SomniumText"
local SomniumUtil = require "widgets/SomniumUtil"
local RGBAColor = SomniumUtil.RGBAColor

---@alias data {width?:number,height?:number,paddingX?:number,paddingY?:number,lineSpacing?:number,background?:SomniumImage}

---@class SomniumWindow:SomniumWidget
---@overload fun(data?:data):SomniumWindow
---@field _ctor fun(self, data?:data):SomniumWindow
---@field _base SomniumWidget
---@field background SomniumImage
---@field paddingX integer
---@field paddingY integer
---@field currentLineY integer
---@field lineSpacing integer
---@field contents SomniumWidget[]
local SomniumWindow = Class(SomniumWidget,
    function(self, data)
        ---@cast self SomniumWindow
        SomniumWidget._ctor(self, "SomniumWindow")
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
        self:SetAnchors(ANCHOR_MIDDLE, ANCHOR_MIDDLE)
        self:SetSize()
        -- self:SetPosition(0, 0, 0)
        -- self:StartUpdating()
    end)

---设置背景
---@param bg SomniumImage
function SomniumWindow:SetBackground(bg)
    if self.background then self.background:Kill() end
    self.background = self:AddChild(bg)
    self.background:SetSize(self.width, self.height)
end

function SomniumWindow:SetAnchors(anchorX, anchorY)
    self:SetVAnchor(anchorX)
    self:SetHAnchor(anchorY)
end

function SomniumWindow:SetAnchor(XY, anchor)
    if XY then
        self:SetVAnchor(anchor)
    else
        self:SetHAnchor(anchor)
    end
end

function SomniumWindow:SetPosition(...)
    -- self.bg:SetPosition(...)
    SomniumWindow._base.SetPosition(self, ...)
end

function SomniumWindow:GetPosition()
    return SomniumWindow._base.GetPosition(self)
end

function SomniumWindow:SetSize(width, height)
    width = width or self.width
    height = height or self.height
    self.width = width; self.height = height
    if self.background then self.background:SetSize(width, height) end
end

function SomniumWindow:GetSize() return self.width, self.height end

function SomniumWindow:SetTitle(title, font, size, color)
    if not self.title then
        self.title = self:AddChild(SomniumText(font, size, color, title))
        self.title:SetAligns(nil, SomniumUtil.Aligns.TOP)
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
function SomniumWindow:AddContent(content, key, contentHeight)
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

function SomniumWindow:ClearContents()
    for _, content in pairs(self.contents) do content:Kill() end
    table.clear(self.contents)
    self.currentLineY = 0
end

function SomniumWindow:NewLine(height)
    self.currentLineY = self.currentLineY + height
end

function SomniumWindow:OnRawKey(key, down)
    local flag = SomniumWindow._base.OnRawKey(self, key, down)
    if not self.focus then return false end
    return flag
end

function SomniumWindow:OnControl(control, down)
    local flag = SomniumWindow._base.OnControl(self, control, down)
    if not self.focus then return false end
    return flag
end

function SomniumWindow:AnimateSize(w, h, speed)
    w = w or self.width
    h = h or self.height
    self.animTargetSize = { w = w, h = h }
    self.animSpeed = speed or 5
    self:SetUpdating("animateSize")
end

function SomniumWindow:OnUpdate(dt)
    dt = dt or 0
    SomniumWindow._base.OnUpdate(self, dt)
    if self.animTargetSize and dt > 0 then
        local w, h = self:GetSize()
        if math.abs(w - self.animTargetSize.w) < 1 and math.abs(h - self.animTargetSize.h) < 1 then
            self:SetSize(self.animTargetSize.w, self.animTargetSize.h)
            self.animTargetSize = nil
            self:RemoveUpdating("animateSize")
        else
            self:SetSize(SomniumUtil.Lerp(w, self.animTargetSize.w, self.animSpeed * dt), SomniumUtil.Lerp(h, self.animTargetSize.h, self.animSpeed * dt))
        end
    end
    local widthScale = SomniumUtil.getWidthScal()
    if widthScale ~= self.screenScale then
        self.background:SetScale(widthScale)
        local offset = self:GetOffset()
        offset.x = offset.x * widthScale / self.screenScale
        offset.y = offset.y * widthScale / self.screenScale
        self:SetOffset(offset)
        self.screenScale = widthScale
    end
end

return SomniumWindow
