local Widget = require "widgets/widget"
local SomniumUtil = require "widgets/SomniumUtil"

---@class SomniumWidget:Widget
---@overload fun(name:string):SomniumWidget
---@field _ctor fun(self,name:string):SomniumWidget
---@field _base Widget
---@field ImageWidget ImageWidget
---@field UITransform UITransform
---@field draggable boolean|nil
---@field dragging boolean|nil
---@field draggingPos Vector3
---@field keepTop boolean
---@field moveLayerTimer number
---@field basePos Vector3
---@field offset Vector3
---@field position Vector3
---@field width number
---@field height number
---@field VAlign Aligns
---@field HAlign Aligns
local SomniumWidget = Class(Widget,
    function(self, name)
        ---@cast self SomniumWidget
        Widget._ctor(self, name)
        self.UITransform = self.inst.UITransform
        self.moveLayerTimer = 0
        self.basePos = Vector3()
        self.offset = Vector3()
        self.position = Vector3()
        self.width, self.height = 100, 100
    end)

---设置位置
---@param pos? Vector3|number
---@param y? number
---@param z? number
function SomniumWidget:SetPosition(pos, y, z)
    if type(pos) == "table" then
        local x = pos.x or pos[1] or 0
        y = pos.y or pos[2] or 0
        z = pos.z or pos[3] or 0
        self.position.x, self.position.y, self.position.z = x, y, z
        self.UITransform:SetPosition(x, y, z)
    else
        pos = pos or 0; y = y or 0; z = z or 0
        self.position.x, self.position.y, self.position.z = pos, y, z
        self.UITransform:SetPosition(pos, y, z)
    end
end

---设置偏移
---@param offset? Vector3|number
---@param y? number
---@param z? number
function SomniumWidget:SetOffset(offset, y, z)
    if type(offset) == "table" then
        local x = offset.x or offset[1] or self.offset.x
        y = offset.y or offset[2] or self.offset.y
        z = offset.z or offset[3] or self.offset.z
        self.offset.x, self.offset.y, self.offset.z = x, y, z
        self:SetPosition(x + self.basePos.x, y + self.basePos.y, z + self.basePos.z)
    else
        offset = offset or self.offset.x; y = y or self.offset.y; z = z or self.position.z
        self.offset.x, self.offset.y, self.offset.z = offset, y, z
        self.UITransform:SetPosition(offset + self.basePos.x, y + self.basePos.y, z + self.basePos.z)
    end
end

function SomniumWidget:GetOffset()
    return self.offset
end

---@param w? number
---@param h? number
function SomniumWidget:SetSize(w, h)
    self.width = w or self.width
    self.height = h or self.height
end

---@return number w, number h
function SomniumWidget:GetSize()
    return self.width, self.height
end

---设置缩放
---@param scale? Vector3|number
---@param y? number
---@param z? number
function SomniumWidget:SetScale(scale, y, z)
    if type(scale) == "table" then
        self.inst.UITransform:SetScale(scale.x, scale.y, scale.z)
    else
        scale = scale or 1
        self.inst.UITransform:SetScale(scale, y or scale, z or scale)
    end
end

---设置对齐
---@param VAlign? Aligns
---@param HAlign? Aligns
---@return SomniumWidget
function SomniumWidget:SetAligns(VAlign, HAlign)
    self.VAlign = VAlign or self.VAlign
    self.HAlign = HAlign or self.HAlign
    return self
end

function SomniumWidget:UpdateAligns()
    local w, h = self:GetSize()
    if self.VAlign and self.VAlign ~= 0 then
        self.basePos.x = w / 2 * self.VAlign
    else
        self.basePos.x = 0
    end
    if self.HAlign and self.HAlign ~= 0 then
        self.basePos.y = h / 2 * self.HAlign
    else
        self.basePos.y = 0
    end
end

function SomniumWidget:UpdatePosition()
    self:UpdateAligns()
    self:SetOffset()
end

function SomniumWidget:SetDraggable(enable)
    if enable then
        self.draggable = true
        self.draggingPos = Vector3()
        self:SetUpdating("draggable")
    else
        self.draggable = nil
        self.draggingPos = nil
        self:RemoveUpdating("draggable")
    end
end

function SomniumWidget:OnGainFocus()
    self:PushEvent("onGainFocus")
end

function SomniumWidget:OnLoseFocus()
    self:PushEvent("onLoseFocus")
end

function SomniumWidget:OnMouseButton(button, down, x, y)
    if SomniumWidget._base.OnMouseButton(self, button, down, x, y) then return true end
    self:PushEvent("onMouseButton", { button = button, down = down, x = x, y = y })
    if self.draggable then
        if not down and button == MOUSEBUTTON_LEFT then self.dragging = false end

        if self.focus and button == MOUSEBUTTON_LEFT and down then
            -- local focus = self:GetDeepestFocus()
            -- if focus and tableContains(self.draggableChildren, focus) then
            self.dragging = true
            self.draggingPos.x = x
            self.draggingPos.y = y
            -- end
        end
    end
    return false
end

function SomniumWidget:OnMouseMove(x, y)
    self:PushEvent("onMouseMove", { x = x, y = y })
end

function SomniumWidget:AddOnMouseMove()
    SomniumUtil.AddOnMoveHandler(self)
end

function SomniumWidget:RemoveOnMouseMove()
    SomniumUtil.RemoveOnMoveHandler(self)
end

function SomniumWidget:OnRawKey(key, down)
    if not self.focus then return false end
    self:PushEvent("onRawKey", { key = key, down = down })
    for k, v in pairs(self.children) do
        if v.focus and v:OnRawKey(key, down) then return true end
    end
    return false
end

function SomniumWidget:OnTextInput(text)
    if not self.focus then return false end
    self:PushEvent("onTextInput", text)
    for k, v in pairs(self.children) do
        if v.focus and v:OnTextInput(text) then return true end
    end
    return false
end

function SomniumWidget:OnControl(control, down)
    if not self.focus then return false end
    self:PushEvent("onControl", { control = control, down = down })
    for k, v in pairs(self.children) do
        if v.focus and v:OnControl(control, down) then return true end
    end
    return false
end

---更新
---@param dt? number
function SomniumWidget:OnUpdate(dt)
    dt = dt or 0
    if self.draggable and self.dragging then
        local x, y = TheSim:GetPosition()
        local dx = x - self.draggingPos.x
        local dy = y - self.draggingPos.y
        self.draggingPos.x = x
        self.draggingPos.y = y
        local offset = self:GetOffset()
        offset.x = offset.x + dx; offset.y = offset.y + dy
        self:SetOffset(offset)
    end
    if self.keepTop then
        self.moveLayerTimer = self.moveLayerTimer + dt
        if self.moveLayerTimer > 0.5 then
            self.moveLayerTimer = 0
            self:MoveToFront()
        end
    end
    self:PushEvent("OnUpdate", dt)
end

function SomniumWidget:SetUpdating(source)
    self.updatingSource = self.updatingSource or {}
    self.updatingSource[source] = true
    self:ShouldUpdating()
end

function SomniumWidget:RemoveUpdating(source)
    if self.updatingSource then
        self.updatingSource[source] = nil
        if not next(self.updatingSource) then self.updatingSource = nil end
    end
    self:ShouldUpdating()
end

function SomniumWidget:ShouldUpdating()
    if self.updatingSource then
        TheFrontEnd:StartUpdatingWidget(self)
    else
        TheFrontEnd:StopUpdatingWidget(self)
    end
end

---推送事件
---@param event string
---@param data? any
function SomniumWidget:PushEvent(event, data)
    self.inst:PushEvent(event, data)
end

---监听事件
---@param event string
---@param fn fun(inst:EntityScript,data?:any)
function SomniumWidget:ListenForEvent(event, fn)
    self.inst:ListenForEvent(event, fn)
end

---移除事件监听
---@param event string
---@param fn fun(inst:EntityScript,data?:any)
function SomniumWidget:RemoveEventCallback(event, fn)
    self.inst:RemoveEventCallback(event, fn)
end

---移除所有事件监听
function SomniumWidget:RemoveAllEventCallbacks()
    self.inst:RemoveAllEventCallbacks()
end

return SomniumWidget
