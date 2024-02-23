local SomniumWidget = require "widgets/SomniumWidget"

---@class SomniumImage:SomniumWidget
---@overload fun(atlas:string, tex:string):SomniumImage
---@field _ctor fun(self, atlas:string, tex:string):SomniumImage
---@field _base SomniumWidget
---@field atlas string
---@field tex string
---@field originWidth integer
---@field originHeight integer
local SomniumImage = Class(SomniumWidget,
    function(self, atlas, tex)
        ---@cast self SomniumImage
        SomniumWidget._ctor(self, "SomniumImage")

        self.inst.entity:AddImageWidget()
        self.ImageWidget = self.inst.ImageWidget

        assert(atlas and tex)

        self:SetTexture(atlas, tex)
    end)

---@return string
function SomniumImage:__tostring()
    return string.format("%s - %s:%s", self.name, self.atlas, self.texture)
end

function SomniumImage:SetAlphaRange(min, max)
    self.ImageWidget:SetAlphaRange(min, max)
end

---设置材质
---@param atlas string
---@param tex string
function SomniumImage:SetTexture(atlas, tex)
    assert(atlas and tex)

    self.atlas = resolvefilepath(atlas)
    self.texture = tex
    --print(atlas, tex)
    self.ImageWidget:SetTexture(self.atlas, self.texture)

    -- changing the texture may have changed our metrics
    self.UITransform:UpdateTransform()

    self.originWidth, self.originHeight = self.ImageWidget:GetSize()
end

function SomniumImage:SetMouseOverTexture(atlas, tex)
    self.atlas = resolvefilepath(atlas)
    self.mouseovertex = tex
end

function SomniumImage:SetDisabledTexture(atlas, tex)
    self.atlas = resolvefilepath(atlas)
    self.disabledtex = tex
end

function SomniumImage:SetSize(w, h)
    if type(w) == "number" then
        self.ImageWidget:SetSize(w, h)
    else
        self.ImageWidget:SetSize(w[1], w[2])
    end
end

function SomniumImage:GetOriginSize()
    return self.originWidth, self.originHeight
end

function SomniumImage:GetSize()
    return self.ImageWidget:GetSize()
end

function SomniumImage:ScaleToSize(w, h)
    local w0, h0 = self.ImageWidget:GetSize()
    local scalex = w / w0
    local scaley = h / h0
    self:SetScale(scalex, scaley, 1)
end

---设置颜色
---@param ColorOrR number|RGBAColor
---@param g? number
---@param b? number
---@param a? number
function SomniumImage:SetTint(ColorOrR, g, b, a)
    if type(ColorOrR) == "table" then
        self.ImageWidget:SetTint(ColorOrR.r, ColorOrR.g, ColorOrR.b, ColorOrR.a)
    else
        self.ImageWidget:SetTint(ColorOrR, g, b, a)
    end
end

function SomniumImage:SetVRegPoint(anchor)
    self.ImageWidget:SetVAnchor(anchor)
end

function SomniumImage:SetHRegPoint(anchor)
    self.ImageWidget:SetHAnchor(anchor)
end

function SomniumImage:OnGainFocus()
    if self.enabled and self.mouseovertex then
        self.ImageWidget:SetTexture(self.atlas, self.mouseovertex)
    end
    SomniumImage._base.OnGainFocus(self)
end

function SomniumImage:OnLoseFocus()
    if self.enabled and self.mouseovertex then
        self.ImageWidget:SetTexture(self.atlas, self.texture)
    end
    SomniumImage._base.OnLoseFocus(self)
end

function SomniumImage:OnEnable()
    self.ImageWidget:SetTexture(self.atlas, self.texture)
end

function SomniumImage:OnDisable()
    self.ImageWidget:SetTexture(self.atlas, self.disabledtex)
end

function SomniumImage:SetEffect(filename)
    self.ImageWidget:SetEffect(filename)
    if filename == "shaders/ui_cc.ksh" then
        --hack for faked ambient lighting influence (common_postinit, quagmire.lua)
        --might need to get the colour from the gamemode???
        --If we're going to use the ui_cc shader again, we'll have to have a more sane implementation for setting the ambient lighting influence
        self.ImageWidget:SetEffectParams(0.784, 0.784, 0.784, 1)
    end
end

function SomniumImage:SetEffectParams(param1, param2, param3, param4)
    self.ImageWidget:SetEffectParams(param1, param2, param3, param4)
end

function SomniumImage:EnableEffectParams(enabled)
    self.ImageWidget:EnableEffectParams(enabled)
end

function SomniumImage:SetUVScale(xScale, yScale)
    self.ImageWidget:SetUVScale(xScale, yScale)
end

function SomniumImage:SetBlendMode(mode)
    self.ImageWidget:SetBlendMode(mode)
end

return SomniumImage
