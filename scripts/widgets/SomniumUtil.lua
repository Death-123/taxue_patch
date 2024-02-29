local SomniumUtil = {}

---获取屏幕横向缩放倍数
---@return number
function SomniumUtil.getWidthScal()
    local w, h = TheSim:GetScreenSize()
    return w / 1920
end

---@param a number start number
---@param b number end number
---@param t number percent
---@return number number number
function SomniumUtil.Lerp(a, b, t) return (b - a) * t + a end

---@enum Aligns
SomniumUtil.Aligns = {
    MIDDLE = 0,
    TOP = 1,
    BOTTOM = -1,
    LEFT = 1,
    RIGHT = 1,
}

--#region RGBAColor
local Colors = {}

---@class RGBAColor:Class
---@overload fun(r?:integer|integer[]|string, g?:integer, b?:integer, a?:integer, raw?:boolean):RGBAColor
---@field r number
---@field g number
---@field b number
---@field a number
local RGBAColor = Class(
    function(self, r, g, b, a, raw)
        if not r then return self:RawSet(r, g, b, a) end
        if type(r) == "table" then
            return self:Set(r[1], r[2], r[3], r[4], raw)
        elseif type(r) == "string" then
            return Colors[r] or self:RawSet()
        else
            return self:Set(r, g, b, a, raw)
        end
    end)

---设置颜色(0-255整数)
---@param r? integer
---@param g? integer
---@param b? integer
---@param a? number
---@param raw? boolean
---@return RGBAColor
function RGBAColor:Set(r, g, b, a, raw)
    if not raw then
        r = r and r / 255 or 0
        g = g and g / 255 or 0
        b = b and b / 255 or 0
    end
    return self:RawSet(r, g, b, a)
end

---设置颜色(0-1小数)
---@param r? number
---@param g? number
---@param b? number
---@param a? number
---@return RGBAColor
function RGBAColor:RawSet(r, g, b, a)
    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
    self.a = a or 1
    return self
end

---克隆
---@return RGBAColor
function RGBAColor:Clone()
    return RGBAColor(self:Get())
end

---拆包
---@return number
---@return number
---@return number
---@return number
function RGBAColor:Get()
    return self.r, self.g, self.b, self.a
end

---@param value number
---@return RGBAColor
function RGBAColor:R(value)
    self.r = value
    return self
end

---@param value number
---@return RGBAColor
function RGBAColor:G(value)
    self.g = value
    return self
end

---@param value number
---@return RGBAColor
function RGBAColor:B(value)
    self.b = value
    return self
end

---@param value number
---@return RGBAColor
function RGBAColor:A(value)
    self.a = value
    return self
end

function RGBAColor:__index(key)
    if key == 1 then
        return self.r
    elseif key == 2 then
        return self.g
    elseif key == 3 then
        return self.b
    elseif key == 4 then
        return self.a
    else
        return rawget(RGBAColor, key)
    end
end

function RGBAColor:__tostring()
    return string.format("(#%02X%02X%02X%02X)", self.r * 255, self.g * 255, self.b * 255, self.a * 255)
end

function RGBAColor:__eq(o)
    return self.r == o[1] and self.g == o[2] and self.b == o[3] and self.a == o[4]
end

SomniumUtil.RGBAColor = RGBAColor

Colors = {
    aquamarine = RGBAColor(127, 255, 212),
    magenta = RGBAColor(255, 108, 180),
    cyan = RGBAColor(0, 255, 255),
    blue = RGBAColor(0, 0, 255),
    green = RGBAColor(0, 255, 0),
    yellow = RGBAColor(255, 255, 0),
    gold = RGBAColor(255, 215, 0),
    orange = RGBAColor(255, 165, 0),
    pink = RGBAColor(255, 20, 147),
    lime = RGBAColor(144, 238, 144),
    grey = RGBAColor(128, 128, 128),
}
--#endregion

local OnMoveHandlers = {}

function SomniumUtil.AddOnMoveHandler(widget)
    OnMoveHandlers[widget] = true
end

function SomniumUtil.RemoveOnMoveHandler(widget)
    OnMoveHandlers[widget] = nil
end

function SomniumUtil.OnMove(x, y)
    for widget, _ in pairs(OnMoveHandlers) do
        widget:OnMouseMove(x, y)
    end
end

TheInput.position:AddEventHandler("move", SomniumUtil.OnMove)

return SomniumUtil
