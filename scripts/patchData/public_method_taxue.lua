local str452 = [[
function TaxueOnKilled(player, target)
    local showBanner = TaxuePatch.cfg.EXP_BANNER and TaxuePatch.dyc
    local BANNER_COLOR = TaxuePatch.cfg.BANNER_COLOR
    local bannerColor = showBanner and TaxuePatch.dyc.RGBAColor(BANNER_COLOR[1] / 255, BANNER_COLOR[2] / 255, BANNER_COLOR[3] / 255)
    --#region 是boss
    local IsBoss = false
    local bossTags = {
        minotaur = true,
        moose = true,
        dragonfly = true,
        bearger = true,
        deerclops = true,
        twister = true,
        tigershark = true,
        pugalisk = true,
        antqueen = true,
        ancient = true,
    }
    IsBoss = bossTags[target.prefab] or target.prefab == "kraken"
    --#endregion

    --#region 不是小生物
    local NotSmall = not (target:HasTag("wall") or target:HasTag("bird")) --墙, 鸟
    local smallList = {
        "lureplant",                                                      --食人花
        "eyeplant",                                                       --食人花眼球
        "chester",                                                        --小切
        "bee",                                                            --蜜蜂
        "killerbee",                                                      --杀人蜂
        "tentacle_pillar_arm",                                            --小触手
        "jellyfish_planted",                                              --水母
        "rainbowjellyfish_planted",                                       --彩虹水母
        "butterfly",                                                      --蝴蝶
        "bramblespike",                                                   --荆棘
        "mosquito",                                                       --蚊子
        "mosquito_poison",                                                --毒蚊子
        "glowfly",                                                        --格罗姆
        "pig_ruins_spear_trap",                                           --遗迹尖刺陷阱
    }
    NotSmall = NotSmall and not table.contains(smallList, target.prefab)
    --#endregion

    --不允许多倍掉落
    local IsSpecial = target.prefab == "spiderden" or target.prefab == "lureplant"

    --#region 处理经验值,战斗力,魅力值
    local exp
    local combat
    local charm
    --击杀boss
    if IsBoss then
        exp = math.random() * 5 + 10 + player.exp_extra            --经验值10~15
        combat = math.random() * 5 + 5                             --战斗力5~10
        charm = math.random() * 10 + 10 + player.charm_value_extra --魅力值10~20
        --击杀非小生物
    elseif NotSmall then
        exp = math.random() * 0.5 + 0.5 + player.exp_extra       --经验值0.5~1
        combat = math.random() * 0.5 + 1                         --战斗力1~1.5
        charm = math.random() * 1 + 1 + player.charm_value_extra --魅力值1~2
    end
    if IsBoss or NotSmall then
        player.exp = player.exp and player.exp + exp                                --经验值
        player.combat_capacity = player.combat_capacity and player.combat_capacity + combat     --战斗力
        player.charm_value = player.charm_value and player.charm_value + charm              --魅力值
        if showBanner then
            local bannerExp
            local dyc = TaxuePatch.dyc
            for index, banner in pairs(dyc.bannerSystem.banners) do
                if banner:HasTag("taxueGetExpBanner") then
                    bannerExp = banner
                    break
                end
            end
            if not bannerExp then
                local str = ("*经验+%.2f* *战斗力+%.2f* *魅力值+%.2f*"):format(exp, combat, charm)
                bannerExp = dyc.bannerSystem:ShowMessage(str, 5, bannerColor)
                bannerExp:AddTag("taxueGetExpBanner")
            end
            bannerExp.exp = bannerExp.exp and bannerExp.exp + exp or exp
            bannerExp.combat = bannerExp.combat and bannerExp.combat + combat or combat
            bannerExp.charm = bannerExp.charm and bannerExp.charm + charm or charm
            bannerExp:SetText(("*经验+%.2f* *战斗力+%.2f* *魅力值+%.2f*"):format(bannerExp.exp, bannerExp.combat, bannerExp.charm))
            bannerExp.bannerTimer = 5
            bannerExp:OnUpdate(0)
        else
            local str = ("*经验+%.2f*\n*战斗力+%.2f*\n魅力值+%.2f*"):format(exp, combat, charm)
            TaXueSay(str)
        end
    end
    --#endregion

    --变异撬锁蜘蛛
    if target:HasTag("spider") then
        if math.random() <= 0.01 then
            SpawnPrefab("collapse_small").Transform:SetPosition(player.Transform:GetWorldPosition())  --生成摧毁动画
            SpawnPrefab("taxue_spider_dropper_key").Transform:SetPosition(target.Transform:GetWorldPosition())  --生成钥匙蜘蛛
        end
    end

    --处理多倍战利品和装备掉落	
    if target.components.lootdropper and not IsSpecial then
        local has_save = false  --是否保存
        local dorpList = {}
        local lootdropper = target.components.lootdropper
        local package
        if TaxuePatch.cfg.BETTER_DORP then
            package = TaxuePatch.GetNearestPackageMachine(target)
        end
        --处理赌狗
        if player.gamble_multiple > 0 then
            has_save = true
            if math.random() < 0.1 then
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("赌狗成功! 额外" .. player.gamble_multiple .. "倍掉落", 5, bannerColor)
                else
                    player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
                end
                TaxuePatch.AddLootsToList(lootdropper, dorpList, player.gamble_multiple)
            else
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("赌狗失败!", 5, bannerColor)
                end
                lootdropper:SetChanceLootTable()
                lootdropper:SetLoot({"poop","poop","poop","poop","poop","poop","poop","poop","poop","poop"})
            end
            player.gamble_multiple = 0
            player.has_ticket = false
        end
        --处理战利品券
        if player.loot_multiple > 0 then	--触发战利品券
            has_save = true
            if showBanner then
                TaxuePatch.dyc.bannerSystem:ShowMessage("触发战利品券! 额外" .. player.loot_multiple .. "倍掉落", 5, bannerColor)
            else
                player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
            end
            TaxuePatch.AddLootsToList(lootdropper, dorpList, player.loot_multiple)
            player.loot_multiple = 0
            player.has_ticket = false
        end
        --处理掉包券
        if player.substitute_item ~= "" then
            has_save = true
            if showBanner then
                TaxuePatch.dyc.bannerSystem:ShowMessage("触发掉包券! 掉包物品: " .. TaxueToChs(player.substitute_item), 5, bannerColor)
            else
                player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
            end
            local item_list = lootdropper:GenerateLoot()   --战利品表
            local loot_list = {}
            for _ = 1, #item_list do
                table.insert(loot_list,player.substitute_item)
            end
            lootdropper:SetChanceLootTable()
            lootdropper:SetLoot(loot_list)
            player.substitute_item = ""
            player.has_ticket = false
        end
        --处理脸黑值,概率为0~0.2
        if player.faceblack > 0 and math.random() <= player.faceblack then
            TaxuePatch.AddLootsToList(lootdropper, dorpList)
            if showBanner then
                local bannerFaceBlack
                local dyc = TaxuePatch.dyc
                for index, banner in pairs(dyc.bannerSystem.banners) do
                    if banner:HasTag("taxueFaceBlackDropBanner") then
                        bannerFaceBlack = banner
                        break
                    end
                end
                if not bannerFaceBlack then
                    bannerFaceBlack = dyc.bannerSystem:ShowMessage("脸黑奖触发双爆!", 5, bannerColor)
                    bannerFaceBlack:AddTag("taxueFaceBlackDropBanner")
                    bannerFaceBlack.times = 1
                else
                    bannerFaceBlack.times = bannerFaceBlack.times + 1
                    bannerFaceBlack:SetText(("脸黑奖触发双爆 X%d !"):format(bannerFaceBlack.times))
                    bannerFaceBlack.bannerTimer = 5
                    bannerFaceBlack:OnUpdate(0)
                end
            end
            player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
            -- print("触发脸黑奖掉落")
            --超级掉落
            if math.random() <= 0.005 then	--拥有奖杯则0.5%触发总概率1/3(向下取整)的数量掉落			
                TaxuePatch.AddLootsToList(lootdropper, dorpList, math.floor((player.faceblack * 100 )/3))
                player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
                if showBanner then
                    TaxuePatch.dyc.bannerSystem:ShowMessage("哇！欧气爆炸！！！" .. math.floor((player.faceblack * 100 )/3) .. " 倍多爆！", 5, bannerColor)
                else
                    TaXueSay("哇！欧气爆炸！！！")
                end
                TaxueFx(player,"metal_hulk_ring_fx")
                -- print("触发超级掉落")
            end
        end
        -------------------------------------------------
        if math.random() <= 0.01 then	--默认1%概率双倍战利品
            player.SoundEmitter:PlaySound("drop/sfx/drop")	--播放掉落音效
            TaxuePatch.AddLootsToList(lootdropper, dorpList)
            -- print("双倍掉落")
        end	
        ----------------------------------------------------
        if NotSmall then
            --#region 处理黄金戒指
            if player.golden > 0 and math.random() <= player.golden then
                dorpList["golden_poop"] = dorpList["golden_poop"] and dorpList["golden_poop"] + 1 or 1
            end
            --#endregion

            --#region 处理撬锁器
            local key_1 = {
                "corkchest_key", --软木桶钥匙
                "treasurechest_key", --木箱钥匙
                "skullchest_key", --骨钥匙
            }
            local key_2 = {
                "pandoraschest_key", --精致钥匙
                "minotaurchest_key", --豪华钥匙
            }
            if player.lockpick_chance > 0 and math.random() <= player.lockpick_chance then
                local key = key_1[math.random(#key_1)]
                dorpList[key] = dorpList[key] and dorpList[key] + 1 or 1
            end
            if player.lockpick_chance > 0 and math.random() <= player.lockpick_chance / 10 then
                local key = key_2[math.random(#key_2)]
                dorpList[key] = dorpList[key] and dorpList[key] + 1 or 1
            end
            --#endregion

            --#region 处理魔法海螺
            if player.variation_chance > 0 and math.random() <= player.variation_chance and target.prefab ~= "taxue_spider_dropper_red" then
                SpawnPrefab("collapse_small").Transform:SetPosition(player.Transform:GetWorldPosition()) --生成摧毁动画
                SpawnPrefab("taxue_spider_dropper_red").Transform:SetPosition(target.Transform:GetWorldPosition()) --生成吸血蜘蛛
            end
            --#endregion

            --#region 处理窃贼手套
            if player.thieves_chance > 0 then
                local num = math.floor(player.thieves_chance) --大于1的数量
                if math.random() < (player.thieves_chance - num) then
                    num = num + 1
                end
                dorpList["taxue_coin_silver"] = dorpList["taxue_coin_silver"] and dorpList["taxue_coin_silver"] + num or num
            end
            --#endregion

            --#region 处理波板糖
            local egg_1 = {
                "taxue_egg_nomal", --普通蛋
            }
            local egg_2 = {
                "taxue_egg_doydoy",                                               --嘟嘟鸟蛋
                "taxue_egg_tallbird",                                             --高鸟蛋
                "taxue_egg_taxue",                                                --煤炭蛋
                "taxue_egg_wave",                                                 --波浪蛋
                "taxue_egg_star",                                                 --星斑蛋
                "taxue_egg_grassland",                                            --绿茵蛋
                "taxue_egg_whiteblue",                                            --白蓝蛋
                "taxue_egg_eddy",                                                 --漩涡蛋
                "taxue_egg_tigershark",                                           --虎纹蛋
                "taxue_egg_hatch",                                                --哈奇蛋
                "taxue_egg_rainbow",                                              --彩虹蛋
                "taxue_egg_lava",                                                 --熔岩蛋
                "taxue_egg_decorate",                                             --装饰蛋
                "taxue_egg_ancient",                                              --远古蛋
                "taxue_egg_skin",                                                 --装饰皮肤蛋
                "taxue_egg_ampullaria_gigas",                                     --福寿蛋
            }
            if player.lollipop_chance > 0 and math.random() < player.lollipop_chance then --掉落蛋
                local num = math.random()
                local egg = "taxue_egg_nomal"
                if num < 0.005 then
                    egg = "taxue_egg_lollipop_rare"
                elseif num < 0.06 then
                    egg = "taxue_egg_lollipop"
                elseif num < 0.16 then
                    egg = egg_2[math.random(#egg_2)]
                end
                dorpList[egg] = dorpList[egg] and dorpList[egg] + 1 or 1
            end
            --#endregion

            --#region 处理精致风车
            if player.colourful_windmill_chance > 0 and math.random() < player.colourful_windmill_chance then
                local list1 = {
                    "taxue_coin",           --梅币
                    "taxue_coin",           --梅币
                    "taxue_coin",           --梅币
                    "gray_windmill",        --灰色风车
                    "treasure_map_nomal",   --藏宝图
                    "treasure_map_monster", --怪物藏宝图
                    "raffle_ticket",        --普通抽奖券
                }
                local list2 = {
                    "taxue_diamond",          --钻石
                    "gray_windmill",          --灰色风车
                    "treasure_map_advanced",  --高级藏宝图
                    "raffle_ticket_advanced", --高级抽奖券
                }
                local list3 = {
                    "random_gem",                   --随机宝石
                    "reset_gem",                    --重置宝石
                    "interest_ticket",              --利息券
                    "loot_ticket",                  --战利品券
                    "gamble_ticket",                --赌狗券
                    "substitute_ticket_random",     --随机掉包券
                    "shop_refresh_ticket_directed", --商店定向刷新券
                    "shop_refresh_ticket_rare",     --商店稀有物品刷新券
                }
                local num = math.random()
                local item
                if num < 0.005 then
                    item = list3[math.random(#list3)]
                elseif num < 0.16 then
                    item = list2[math.random(#list2)]
                else
                    item = list1[math.random(#list1)]
                end
                dorpList[item] = dorpList[item] and dorpList[item] + 1 or 1
            end
            --#endregion
        end
        --#region  处理灌铅骰子
        --print("处理灌铅骰子",inst.loaded_dice_chance)
        if player.loaded_dice_chance > 0 and math.random() < player.loaded_dice_chance then     --触发包裹掉落
            local monster_item_list = {}
            if lootdropper then
                monster_item_list = lootdropper:GenerateLoot()     --战利品表
                for i = #monster_item_list, 1, -1 do                                 --这里把非物品栏物品剔除（注：用table库这种方式剔除一定要倒着干，不然无法全部删除）
                    local item = SpawnPrefab(monster_item_list[i])
                    if item then
                        if not item.components.inventoryitem then
                            table.remove(monster_item_list, i)    --用nil置空元素不前移，影响我判断数组长度，还是用库方法
                        end
                        item:Remove()
                    end
                end
                -- for __, v in ipairs(monster_item_list) do
                --     print("表物品：",STRINGS.NAMES[string.upper(v)])
                -- end
            end
            local packageName, min, max
            if math.random() < 0.8 then
                packageName = "loaded_package"
                min, max = 2, 8
            else
                packageName = "loaded_package_luxury"
                min, max = 8, 20
            end
            local loadedPackage = SpawnPrefab(packageName)
            for _ = 1, math.random(min, max) do
                if #monster_item_list > 0 then
                    table.insert(loadedPackage.loaded_item_list, monster_item_list[math.random(#monster_item_list)])
                else
                    table.insert(loadedPackage.loaded_item_list, "taxue_coin_silver")    --防空表
                end
            end
            if package then
                TaxuePatch.AddItemToSuperPackage(package, loadedPackage)
            else
                TaxuePrefabDrop(target, loadedPackage, 1)
            end
        end
        --#endregion

        TaxuePatch.StackDrops(target, dorpList)

        if has_save then
            GetPlayer().components.autosaver:DoSave() 
        end
    end
end
]]

local lines = {
    [452] = { index = 452, endIndex = 742, content = str452 }
}

return lines

