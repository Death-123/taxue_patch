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

-- local player = GetPlayer()
-- local locomotor = player.components.locomotor
-- local bufferedaction = locomotor.bufferedaction
-- mprint(bufferedaction.action, player.sg.sg.actionhandlers[bufferedaction.action])

-- locomotor:GoToEntity(Sel(), nil, true)
-- local arrive_dist = locomotor.arrive_dist
-- local destpos_x, destpos_y, destpos_z = locomotor.dest:GetPoint()
-- local mypos_x, mypos_y, mypos_z = locomotor.inst.Transform:GetWorldPosition()

-- local dsq = distsq(destpos_x, destpos_z, mypos_x, mypos_z)
-- local run_dist = locomotor:GetRunSpeed()*0.016*.5
-- mprint(dsq, run_dist * run_dist, arrive_dist * arrive_dist)
local cpath = package.cpath
-- package.cpath = "c:/Users/Death/.vscode/extensions/tangzx.emmylua-0.9.28-win32-x64/debugger/emmy/windows/x64/?.dll"
package.cpath = "c:/Users/Death/.vscode/extensions/tangzx.emmylua-0.9.28-win32-x64/debugger/emmy/windows/x86/?.dll"
local dbg = require("emmy_core")
dbg.tcpListen("localhost", 9966)
dbg.waitIDE()
dbg.breakHere()
print("EmmyLua debugger listening on localhost:9966")
package.cpath = cpath
