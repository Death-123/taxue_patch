local SomniumWidget = require "widgets/SomniumWidget"
local SomniumText = require "widgets/SomniumText"
local SomniumImage = require "widgets/SomniumImage"
local SomniumUtil = require "widgets/SomniumUtil"
local RGBAColor = SomniumUtil.RGBAColor

---@class SomniumButton:SomniumWidget
---@overload fun():SomniumButton
---@field _cotr fun(self):SomniumButton
---@field _base SomniumWidget
---@field scaleAnim number|nil
---@field text SomniumText|nil
---@field image SomniumImage|nil
---@field clickoffset Vector3
local SomniumButton = Class(SomniumWidget,
    function(self)
        ---@cast self SomniumButton
        SomniumWidget._ctor(self, "SomniumButton")
    end)


function SomniumButton:SetText(text)
    if not self.text and text then
        self.text = self:AddChild(SomniumText(BUTTONFONT, 40))
        self.text:SetVAnchor(ANCHOR_MIDDLE)
        self.text:SetColour(0, 0, 0, 1)

        self.textcol = RGBAColor()
        self.textfocuscolour = RGBAColor()
        self.clickoffset = Vector3(0, -3, 0)
    else
        if text then
            self.name = text or "SomniumButton"
            self.text:SetString(text)
            self.text:Show()
        else
            self.text:Hide()
        end
    end

    self:UpdateStatus()
end

function SomniumButton:SetImage(atlas, normal, focus, disabled)
    if not self.image then
        if not atlas then
            atlas = atlas or "images/ui.xml"
            normal = normal or "button.tex"
            focus = focus or "button_over.tex"
            disabled = disabled or "button_disabled.tex"
        end
        self.image = self:AddChild(SomniumImage(atlas, normal))
        self.image:MoveToBack()
    end

    self.atlas = atlas or self.atlas
    self.image_normal = normal or self.image_normal
    self.image_focus = focus or self.image_focus or normal
    self.image_disabled = disabled or self.image_disabled or normal

    self:UpdateStatus()
end

function SomniumButton:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    SomniumButton._base.SetSize(self, w, h)
    if self.image then self.image:SetSize(w, h) end
end

function SomniumButton:UpdateStatus()
    if self:IsEnabled() then
        if self.text then
            if self.focus then
                self.text:SetColour(self.textfocuscolour)
                if self.scaleAnim then self.text:SetScale(self.scaleAnim) end
            else
                self.text:SetColour(self.textcol)
                if self.scaleAnim then self.text:SetScale(1) end
            end
        end
        if self.image then
            if self.focus then
                self.image:SetTexture(self.atlas, self.image_focus)
                self.image:SetSize(self:GetSize())
                if self.scaleAnim then self.image:SetScale(self.scaleAnim) end
            else
                self.image:SetTexture(self.atlas, self.image_normal)
                self.image:SetSize(self:GetSize())
                if self.scaleAnim then self.image:SetScale(1) end
            end
        end
    else
        if self.text then
            self.text:SetColour(self.textcol)
            if self.scaleAnim then self.text:SetScale(1) end
        end
        if self.image then
            self.image:SetTexture(self.atlas, self.image_disabled)
            self.image:SetSize(self:GetSize())
            if self.scaleAnim then self.image:SetScale(1) end
        end
    end
end

function SomniumButton:OnControl(control, down)
    if SomniumButton._base.OnControl(self, control, down) then return true end

    if not (self:IsEnabled() and self.focus) then return false end

    if control == CONTROL_ACCEPT then
        if down then
            if not self.down then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                self.o_pos = self:GetLocalPosition()
                self:SetPosition(self.o_pos + self.clickoffset)
                self.down = true
                if self.whiledown then
                    self:StartUpdating()
                end
                if self.ondown then
                    self.ondown()
                end
            end
        else
            if self.down then
                self.down = false
                self:SetPosition(self.o_pos)
                if self.onclick then
                    self.onclick()
                end
                self:StopUpdating()
            end
        end

        return true
    end
end

function SomniumButton:OnUpdate(dt)
    if self.down then
        if self.whiledown then
            self.whiledown(dt)
        end
    end
end

function SomniumButton:Enable()
    SomniumButton._base.Enable(self)
    self:UpdateStatus()
end

function SomniumButton:Disable()
    SomniumButton._base.Disable(self)
    self:UpdateStatus()
end

function SomniumButton:OnGainFocus()
    SomniumButton._base.OnGainFocus(self)
    if self:IsEnabled() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")

        if self.text then
            self.text:SetColour(self.textfocuscolour)
        end
        if self.image then
            self.image:SetTexture(self.atlas, self.image_focus)
            if self.image_focus == self.image_normal then
                self.image:SetScale(1.2, 1.2, 1.2)
            end
        end
    end
end

function SomniumButton:OnLoseFocus()
    SomniumButton._base.OnLoseFocus(self)
    if self.o_pos then
        self:SetPosition(self.o_pos)
    end
    if self.text then
        self.text:SetColour(self.textcol)
    end
    if self.image then
        self.image:SetTexture(self.atlas, self.image_normal)
        if self.image_focus == self.image_normal then
            self.image:SetScale(1, 1, 1)
        end
    end
    self.down = false
end

function SomniumButton:SetFont(font)
    self.text:SetFont(font)
end

function SomniumButton:SetOnDown(fn)
    self.ondown = fn
end

function SomniumButton:SetWhileDown(fn)
    self.whiledown = fn
end

function SomniumButton:SetOnClick(fn)
    self.onclick = fn
end

function SomniumButton:SetTextColour(r, g, b, a)
    self.textcol = RGBAColor(r, g, b, a)

    if not self.focus then
        self.text:SetColour(self.textcol)
    end
end

function SomniumButton:SetTextFocusColour(r, g, b, a)
    self.textfocuscolour = RGBAColor(r, g, b, a)

    if self.focus then
        self.text:SetColour(self.textfocuscolour)
    end
end

function SomniumButton:SetFontSize(sz)
    self.text:SetFontSize(sz)
end

function SomniumButton:GetText()
    return self.text:GetString()
end

function SomniumButton:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)
    return table.concat(t, "  ")
end

return SomniumButton
