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

-- reload()
-- local target = SpawnPrefab("taxue_spat")
-- target.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
-- -- GetPlayer().super_fortune_num = 100
-- target.components.health:Kill()
-- TaxuePatch.TaxueOnKilled(GetPlayer(), target)

-- local intmax = 2 ^ 32
-- local function hash(str)
--     local hash = 5381
--     for i = 1, #str do
--         hash = (hash * 33 + str:byte(i)) % intmax
--     end
--     print(#str)
--     return hash
-- end
-- local t = os.time()
-- local file, error = io.open("../mods/Taxue1.00/scripts/game_changed_taxue.lua", "r")
-- if file then
--     local line = file:read("*a")
--     print(hash(line))
--     file:close()
-- end
-- print(os.time() - t)

function d_decodedata(path, skipread, suffix, datacb)
    print("DECODING", path)
    suffix = suffix or "_decoded"
    TheSim:GetPersistentString(path, function (load_success, str)
        if load_success then
            print("LOADED...")
            if not skipread then
                local success, savedata = RunInSandbox(str)
                if datacb ~= nil then
                    datacb(savedata)
                end
                str = DataDumper(savedata, nil, false)
            end
            TheSim:SetPersistentString(path .. suffix, str, false, function ()
                print("SAVED!")
            end)
        else
            print("ERROR LOADING FILE! (wrong path?)")
        end
    end)
end

d_decodedata(KnownModIndex:GetModConfigurationPath() .. "modconfiguration_taxue_patch")
