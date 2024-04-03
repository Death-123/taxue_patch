-- for i,j in pairs(getmetatable(TheInput)) do
--     mprint(i,j,type(j)=="function" and getArgs(j) or "")
-- end

-- TaxuePatch.ControlPanel1 = TaxuePatch.ControlPanel()
-- TaxuePatch.button = TaxuePatch.SomniumButton()
-- TaxuePatch.button:SetImage()
-- TaxuePatch.ControlPanel1:AddContent(TaxuePatch.button)
-- Mainscreen:AddChild(TaxuePatch.ControlPanel1)

-- GetPlayer().Physics:SetMotorVel(5, 0, 0)
-- mprint(GetPlayer().Transform:GetWorldPosition())
-- GetPlayer():DoTaskInTime(1, function (inst)
--     mprint(GetPlayer().Transform:GetWorldPosition())
--     local x,y,z = GetPlayer().Transform:GetWorldPosition()
--     GetPlayer().Transform:SetPosition(x + 5, y, z)
-- end)

-- local ent = Sel()
-- for _, chanceloot in pairs(ent.components.lootdropper.chanceloot) do
--     mprint(chanceloot.prefab, chanceloot.chance)
-- end

