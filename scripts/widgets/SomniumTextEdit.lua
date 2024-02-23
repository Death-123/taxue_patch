local SomniumWidget = require "widgets/SomniumWidget"
local SomniumText = require "widgets/SomniumText"

---@class SomniumTextEdit:SomniumText
---@field TextEditWidget TextEditWidget
local TextEdit = Class(SomniumText,
	function(self, font, size, text)
		---@cast self SomniumTextEdit
		SomniumText._ctor(self, font, size, text)

		self.inst.entity:AddTextEditWidget()
		self.TextEditWidget = self.inst.TextEditWidget
		self:SetEditString(text)
		self:SetEditing(false)
		self.validrawkeys = {}
	end)

function TextEdit:SetEditString(str)
	self.TextEditWidget:SetString(str or "")
end

function TextEdit:SetEditing(editing)
	if editing then
		self:SetFocus()
	end
	self.editing = editing
	self.inst.TextWidget:ShowEditCursor(self.editing)
	-- TheFrontEnd:LockFocus(self.editing)
end

function TextEdit:OnMouseButton(button, down, x, y)
	self:SetEditing(true)
end

function TextEdit:OnTextInput(text)
	if not self.editing then return end

	if self.limit then
		local str = self:GetString()
		--print("len", string.len(str), "limit", self.limit)
		if string.len(str) >= self.limit then
			return
		end
	end

	if self.validchars then
		if not string.find(self.validchars, text, 1, true) then
			return
		end
	end

	self.TextEditWidget:OnTextInput(text)
end

function TextEdit:OnProcess()
	self:SetEditing(false)
	TheInputProxy:FlushInput()
	if self.OnTextEntered then
		self.OnTextEntered(self:GetString())
	end
end

function TextEdit:OnRawKey(key, down)
	if TextEdit._base.OnRawKey(self, key, down) then return true end

	if self.editing then
		if down then
			if key == KEY_ENTER then
				self:OnProcess()
				return true
			else
				self.TextEditWidget:OnKeyDown(key)
			end
		else
			self.TextEditWidget:OnKeyUp(key)
		end
	end

	if self.validrawkeys[key] then return false end
	return true --gobble this up, or we will engage debug keys!
end

function TextEdit:OnControl(control, down)
	if TextEdit._base.OnControl(self, control, down) then return true end

	--gobble up extra controls
	if self.editing and (control ~= CONTROL_CANCEL and control ~= CONTROL_OPEN_DEBUG_CONSOLE and control ~= CONTROL_ACCEPT) then
		return true
	end

	if self.editing and not down and control == CONTROL_CANCEL then
		self:SetEditing(false)
		return true
	end

	if not down and control == CONTROL_ACCEPT then
		self:SetEditing(true)
		return true
	end
end

function TextEdit:OnFocusMove()
	return true
end

function TextEdit:OnGainFocus()
	SomniumText.OnGainFocus(self)

	if self.focusedtex and self.unfocusedtex then
		self.focusimage:SetTexture(self.atlas, self.focus and self.focusedtex or self.unfocusedtex)
	end
end

function TextEdit:OnLoseFocus()
	SomniumText.OnLoseFocus(self)
	self:SetEditing(false)
	if self.focusedtex and self.unfocusedtex then
		self.focusimage:SetTexture(self.atlas, self.focus and self.focusedtex or self.unfocusedtex)
	end
end

function TextEdit:SetFocusedImage(widget, atlas, focused, unfocused)
	self.focusimage = widget
	self.atlas = atlas
	self.focusedtex = focused
	self.unfocusedtex = unfocused

	if self.focusedtex and self.unfocusedtex then
		self.focusimage:SetTexture(self.atlas, self.focus and self.focusedtex or self.unfocusedtex)
	end
end

function TextEdit:SetTextLengthLimit(limit)
	self.limit = limit
end

function TextEdit:SetCharacterFilter(validchars)
	self.validchars = validchars
end

-- Unlike GetString() which returns the string stored in the displayed text widget
-- GetLineEditString will return the 'intended' string, even if the display is nulled out (for passwords)
function TextEdit:GetLineEditString()
	return self.TextEditWidget:GetString()
end

function TextEdit:SetPassword(to)
	self.TextEditWidget:SetPassword(to)
end

function TextEdit:SetAllowClipboardPaste(to)
	self.TextEditWidget:SetAllowClipboardPaste(to)
end

return TextEdit
