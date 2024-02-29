-- for i,j in pairs(getmetatable(TheInput)) do
--     mprint(i,j,type(j)=="function" and getArgs(j) or "")
-- end

TaxuePatch.ControlPanel1 = TaxuePatch.ControlPanel()
TaxuePatch.button = TaxuePatch.SomniumButton()
TaxuePatch.button:SetImage()
TaxuePatch.ControlPanel1:AddContent(TaxuePatch.button)
Mainscreen:AddChild(TaxuePatch.ControlPanel1)
