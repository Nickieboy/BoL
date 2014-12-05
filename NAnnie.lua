--[[

	Changelog
			1.0: Released Script


			1.1
			​	Added Farm
				Added DFG and Zhyonas
				Added auto downloading script (Not Libs)
				Added another option in Combo to use R if the R stuns

			1.2
				​Added Auto Kill when Killable (Toggle)
				Added Auto Q when Q will Stun (Inside Harass menu, but will still Cast even when Harass is Off)
				Added Ignite
				Added E cast until Stun is UP
				Added Packet Casting 
				Fixed a bug with AutoDownloading 

			1.3
				Added auto-downloading libraries
				Rewrote combo (Combo where you use R only if it stuns)
				Added auto E if being attacked
				Added Harass option to Q > W if W will stun (so @ 3 stacks)

			1.4
				Fixed bol.boost link

			1.5
				Disabled usage of E when hero is recalling
				Disabled BoL tracker for faster runtime

			1.6
				Fixed ManaManger
				Added not to ult on certain targets
				Fixed Ignite
					Added "Use Ignite On"
				Added barrier and heal
				Added Auto Ult (if ult will hit x targets)
				Better AutoKill (AutoKill and KillSteal are basically the same, so they are now the same menu)
				Added DFG support
				Now Draws Killable (with which spells) on ALL enemies


		Script Coded by Nickieboy.
	]]


if myHero.charName ~= "Annie" then return end


--- BoL Script Status Connector --- 
local ScriptKey = "XKNKQKPMJPN" -- NAnnie auth key
local ScriptVersion = "1.6" -- Your .version file content

-- Thanks to Bilbao for his socket help & encryption
assert(load(Base64Decode("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"), nil, "bt", _ENV))() BolBoost( ScriptKey, ScriptVersion )
-----------------------------------


--[[		Auto Update		]]
local version = "1.6"
local author = "Nickieboy"
local SCRIPT_NAME = "NAnnie"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/NAnnie.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>NAnnie:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/NAnnie.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

-- Lib Updater
local REQUIRED_LIBS = {
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["Spell Damage Library"] = "https://raw.githubusercontent.com/Nickieboy/BoL/master/lib/Spell_Damage_Library.lua",
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#6699FF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

-- Declaring variables
local lastLevel = myHero.level - 1
local Qdmg, Wdmg, Rdmg, DFGdmg, igniteDmg, totalDamage, health, mana, maxHealth, maxMana = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
local canStun = false
local EnemyMinions = minionManager(MINION_ENEMY, 625, myHero, MINION_SORT_HEALTH_ASC)
local ignite, heal, barrier = nil, nil, nil
local passiveStacks = 0
local hasTibbers = false
local isRecalling = false
local Rtargets = {}
local Rtarget = nil
local Qready, Wready, Eready, Rready = false, false, false, false
local Hready, Bready, Iready = false, false, false


--Perform on load
function OnLoad()

 	-- OrbWalker
	OrbWalk = SxOrbWalk()

	FindSummoners() 

	levelSequences = {
			[1] = { _Q, _W, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E },
			[2] = { _W, _Q, _W, _E, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E },
	}

 	-- TargetSelector
 	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 625)

 	DrawMenu()

 	FillResetEnemyTable()

end 

-- Perform every time
function OnTick()
	ts:update()

	SpellChecks()

	Harass()

	Combo()

	AutoUlt()

	--KillSteal()
	KillStealPrecise() 

	--KillIfKillable()
	AutoLevel()
	DrinkPotions()
	Farm()
	Zhonyas()

	if Menu.misc.procE and canStun ~= true and isRecalling ~= true then
		CastSpell(_E)
	end 

	if heal ~= nil then
		if Menu.misc.autoheal.useHeal then
			UseHeal()
		end 
	end 
	if ignite ~= nil then
		if Menu.misc.autoignite.useIgnite then
			UseIgnite()
		end 
	end 
	if barrier ~= nil then
		if Menu.misc.autobarrier.useBarrier then
			UseBarrier()
		end 
	end 

	MenuCheck()
 

end

function OnDraw()
 -- Draw Skill range
	if Menu.drawings.draw then
	 	if Menu.drawings.drawQ then
			DrawQ()
	 	end
	 	if Menu.drawings.drawW then
	 		DrawW()
	 	end
	 	if Menu.drawings.drawR then
	 		DrawR()
	 	end 

	 	if Menu.drawings.drawKillable then
	 		DrawKillable()
	 	end 

 	end

end

function DrawQ()
	DrawCircle(myHero.x, myHero.y, myHero.z, 625, 0x111111)
end

function DrawW()
	DrawCircle(myHero.x, myHero.y, myHero.z, 625, 0x111111)
end

function DrawR()
	DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
end


function Harass()
 	if Menu.harass.harass then
 		if ManaManager() then

 			if ts.target ~= nil and ValidTarget(ts.target) then
	 			if (Menu.harass.harassQ) then
	 				CastQ(ts.target)
	 			end 
	 			if (Menu.harass.harassW) then
	 				CastW(ts.target)
	 			end 
 			end
 		end 
 	end 

	if Menu.harass.autoQ and canStun and not Menu.combo.combo and ManaManager() then 
 		if ts.target ~= nil and ValidTarget(ts.target) then
 			CastQ(ts.target)
 		end 
	end 


	if Menu.harass.autoQW and passiveStacks >= 3 and not Menu.combo.combo and ManaManager()then 
 		if ts.target ~= nil and ValidTarget(ts.target) then
 			CastQ(ts.target)
 			DelayAction(function() if canStun then CastW(ts.target) end end, 0.5)
 		end 
 	end 
end

function Combo()
	if Menu.combo.combo then
		if ts.target ~= nil and ValidTarget(ts.target, 625) then
			if Menu.combo.comboRStun and Rready then
				ComboRStun()
			else	
				Combo1()
			end  
		end 
	end 
end 

function Combo1()
	if Menu.combo.comboDFG then
		if GetInventoryHaveItem(3128) and GetInventoryItemIsCastable(3128) then
			local DFGslot = GetInventoryHaveItem(3128)
			if myHero:CanUseSpell(DFGslot) == READY then
				CastItem(DFGslot, ts.target)
			end 
		end
	end 
	if Menu.combo.comboQ then
		CastQ(ts.target)
	end 
	if Menu.combo.comboW then
		CastW(ts.target)
	end 
	if Menu.combo.comboR and Menu.combo.RUsage[ts.target.charName] then
		if ValidTarget(ts.target, 600) then
			CastR(ts.target)
		end  
	end 

end 

function ComboRStun()
	if canStun and Menu.combo.comboR then
		CastR(ts.target)
	end 

	if Menu.combo.comboDFG then
		if GetInventoryHaveItem(3128) and GetInventoryItemIsCastable(3128) then
			local DFGslot = GetInventoryHaveItem(3128)
			if myHero:CanUseSpell(ZhonyaSlot) == READY then
				CastItem(3128, ts.target)
			end 
		end
	end

	if Menu.combo.comboQ then
		CastQ(ts.target)
	end 	 

	if canStun and Menu.combo.comboR then
		CastR(ts.target)
	end 

	if Menu.combo.comboW then
		CastW(ts.target)
	end 

	if canStun and Menu.combo.comboR then
		CastR(ts.target)
	end 

	CastE()

	if Menu.combo.comboR then
		CastR(ts.target)
	end

end 

function AutoUlt()
	Rtarget = ReturnBestUltTarget(Menu.combo.RUsage.hitX)
	if Rtarget ~= nil and ValidTarget(Rtarget, 600) then
		CastR(Rtarget)
	end 
end

function CastQ(target) 
	if Qready and myHero.canAttack and not myHero.dead then
   	 	CastSpell(_Q, target)
   	end
end


function CastW(target) 
	if Wready and myHero.canAttack and not myHero.dead then
    	CastSpell(_W, target)
  	end
end

function CastE()
	if Eready and myHero.canAttack and not myHero.dead then
		CastSpell(_E)
    end
end

function CastR(target)
	if Rready and myHero.canAttack and not myHero.dead and not hasTibbers then
		CastSpell(_R, target)
    end
end

function Farm()
	EnemyMinions:update()

	if Menu.farm.farm and not Menu.combo.combo then
		if Menu.farm.farmStun then
			if not canStun then
				if Menu.farm.farmQ then
					FarmQ()
				end 
				if Menu.farm.farmW then
					FarmW()
				end 
			end 
		else
			if Menu.farm.farmQ then
				FarmQ()
			end 
			if Menu.farm.farmW then
				FarmW()
			end 
		end
	end 
end 

function FarmW()
	for i, minion in pairs(EnemyMinions.objects) do
		if Menu.farm.farmW then
			Wmg = getDmg("W", minion, myHero)
			if minion ~= nil and not minion.dead and minion.visible and minion.health < Wdmg and OrbWalk:ValidTarget(minion, 625) then
				CastW(minion, minion.x, minion.y)
			end 
		end 
	end 
end 

function FarmQ()
	for i, minion in pairs(EnemyMinions.objects) do
		if Menu.farm.farmQ then
			Qdmg = getDmg("Q", minion, myHero)
			if minion ~= nil and not minion.dead and minion.visible and minion.health < Qdmg and OrbWalk:ValidTarget(minion, 625) then
				CastQ(minion)
			end 
		end 
	end 
end 

function Zhonyas()
	if Menu.misc.zhonyas.zhonyas then
		if GetInventoryHaveItem(3157) and GetInventoryItemIsCastable(3157) then
			health = myHero.health
			mana = myHero.mana
			maxHealth = myHero.maxHealth
			if (health / maxHealth) <= Menu.misc.zhonyas.zhonyasunder then
				CastItem(3157)
			end 
		end 
	end 
end

--[[
function KillSteal()
	if Menu.killsteal.killsteal then
	 	for i = 1, heroManager.iCount, 1 do
			local champ = heroManager:getHero(i)
			if champ.team ~= myHero.team then 
			 	if Menu.killsteal.killstealQ then
			 		Qdmg = getDmg("Q", champ, myHero)
			 		if Qdmg >= champ.health then
			 			if ValidTarget(champ, 625) and not champ.dead then
			 				CastQ(champ)
				 		end
			 		end
				end

				if Menu.killsteal.killstealW then
 
				 	Wdmg = getDmg("W", champ, myHero)
					if Wdmg >= champ.health then
						if ValidTarget(champ, 625) and not champ.dead  then
				 			CastW(champ)
				 		end
				 	end
				end 

				if Menu.killsteal.killstealR then
				 	Rdmg = getDmg("R", champ, myHero)
				 	if Rdmg >= champ.health then
				 		if ValidTarget(champ, 600) and not champ.dead then
				 			if  Qready then
				 				CastSpell(_Q, champ)
				 		    elseif  Wready then
				 		    	CastSpell(_W, champ)
				 		    else 
				 		    	CastSpell(_R, champ)
				 			end
				 		end 
				 	end
				end

				if Menu.killsteal.killstealIgnite then
					local igniteDmg = getDmg("IGNITE", champ, myHero)
					if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then 
						ignite = SUMMONER_1
    				elseif 
    					myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then 
    					ignite = SUMMONER_2
    				end 
    				if ValidTarget(champ, 600) then
	    				if igniteDmg >= champ.health then
	    					if ignite ~= nil and  (myHero:CanUseSpell(ignite) == READY) and not champ.dead then
	    						CastSpell(ignite, champ)
	    					end 
	    				end 
	    			end 
				end 
			end
		end 
   end 
end
--]]

function SpellChecks()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
	if heal ~= nil then
		Hready = (myHero:CanUseSpell(heal) == READY)
	end 
	if barrier ~= nil then
		Bready = (myHero:CanUseSpell(barrier) == READY)
	end 
	if ignite ~= nil then
		Iready = (myHero:CanUseSpell(ignite) == READY)
	end 
end 

function FindSummoners() 
	if myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") then 
		heal = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") then 
    	heal = SUMMONER_2
    end 

    if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then 
		ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then 
    	ignite = SUMMONER_2
    end 

    if myHero:GetSpellData(SUMMONER_1).name:find("summonerbarrier") then 
		barrier = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerbarrier") then 
    	barrier = SUMMONER_2
    end
end 

function KillStealPrecise()
	if Menu.autokill.autokill and not Menu.combo.combo then

		SpellChecks()

		local useQ = Menu.autokill.autokillQ
		local useW = Menu.autokill.autokillW
		local useR = Menu.autokill.autokillR
		local useDFG = Menu.autokill.autokillDFG
		local DFGSlot = GetInventorySlotItem(3128)
		local DFGready = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
		

		for i, enemy in ipairs(GetEnemyHeroes()) do
			if Menu.autokill[enemy.charName] then
				if ValidTarget(enemy, 625) then
					if useDFG then
						if GetInventoryItemIsCastable(3128) then
							if DFGready then
								DFGdmg = getDmg("DFG", enemy, myHero)
							end 
						end
					end 
					if useDFG and DFGready then
						if useQ and Qready then
							Qdmg = getDmg("Q", enemy, myHero) + ((getDmg("Q", enemy, myHero) / 100) * 20)
						end 
						if useW and Wready then
							Wdmg = getDmg("W", enemy, myHero) + ((getDmg("W", enemy, myHero) / 100) * 20)
						end 
						if useR and Rready then
							Rdmg = getDmg("R", enemy, myHero) + ((getDmg("R", enemy, myHero) / 100) * 20)
						end 
					else
						if useQ and Qready then
							Qdmg = getDmg("Q", enemy, myHero)
						end 
						if useW and Wready then
							Wdmg = getDmg("W", enemy, myHero)
						end 
						if useR and Rready then
							Rdmg = getDmg("R", enemy, myHero)
						end 
					end 

					if useDFG and DFGready then
						if Qdmg > Wdmg and Wready and useW and Wdmg + DFGdmg > enemy.health then
							CastItem(DFGSlot, enemy)
							CastW(enemy)
						elseif Wdmg > Qdmg and Qready and useQ and Qdmg + DFGdmg > enemy.health then
							CastItem(DFGSlot, enemy)
							CastQ(enemy)
						elseif Qready and Wready and useQ and useW and Qdmg + Wdmg + DFGdmg > enemy.health then
							CastItem(DFGSlot, enemy)
							CastQ(enemy)
							CastW(enemy)
						elseif Qready and Rready and useQ and useR and Qdmg + Rdmg + DFGdmg > enemy.health then
							CastItem(DFGSlot, enemy)
							CastQ(enemy)	
							CastR(enemy)
						elseif Qready and Wready and Rready and useQ and useW and useR and Qdmg + Wdmg + Rdmg + DFGdmg > enemy.health then
							CastItem(DFGSlot, enemy)
							CastQ(enemy)
							CastW(enemy)
							CastR(enemy)
						end 
					else
						if Qdmg > Wdmg and useW and Wready and Wdmg > enemy.health then
							CastW(enemy)
						elseif Wdmg > Qdmg and useQ and Qready and Qdmg > enemy.health then
							CastQ(enemy)
						elseif Qready and Wready and useQ and useW and Qdmg + Wdmg > enemy.health then
							CastQ(enemy)
							CastW(enemy)
						elseif Qready and Rready and useQ and useR and Qdmg + Rdmg > enemy.health then
							CastQ(enemy)
							CastR(enemy)
						elseif Qready and Wready and Rready and useQ and useW and useR and Qdmg + Wdmg + Rdmg > enemy.health then
							CastQ(enemy)
							CastW(enemy)
							CastR(enemy)
						end 
					end  
				end 
			end 		
		end
	end
end 


function ReturnBestUltTarget(amountOfTargets)
	local targ = nil
	FillResetEnemyTable()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistance(enemy, myHero) <= 600 then
			for i, Tenemy in ipairs(GetEnemyHeroes()) do
				if enemy ~= Tenemy then
					if GetDistance(Tenemy, enemy) < 150 then
						Rtargets[enemy] = Rtargets[enemy] + 1
					end 
				end 
			end

			if Rtargets[enemy] >= amountOfTargets and Menu.combo.RUsage[enemy.charName] then
				targ = enemy
				break
			end
		end 
	end 
	return targ
	--table.sort(Rtargets[enemy])
	--if Rtargets[#enemy] > amountOfTargets then
	--return Rtargets[#Rtargets]
	--end 
end 

function FillResetEnemyTable()
	for i, enemy in ipairs(GetEnemyHeroes()) do
 		Rtargets[enemy] = 0
 	end 
end 


--[[
function KillIfKillable()
	if Menu.autokill and not Menu.combo.combo then
		for i, enemy in ipairs(GetEnemyHeroes()) do 
			local name = enemy.charName
			if Menu.autokill[name] then
				if (ValidTarget(enemy, 625)) then

					if  Qready then
						Qdmg = getDmg("Q", enemy, myHero)
					else
						Qdmg = 0
					end 

					if  Wready then
						Wdmg = getDmg("W", enemy, myHero)
					else 
						Wdmg = 0
					end

					if  Rready then
						Rdmg = getDmg("R", enemy, myHero)
					else
						Rdmg = 0
					end 

					if (Wdmg > Qdmg and Wdmg >= enemy.health and Qdmg < enemy.health) then
						CastW(enemy)
					end 

					if (Qdmg >= enemy.health) and not enemy.dead and enemy.visible then 
						CastQ(enemy)
					elseif ((Qdmg + Wdmg) >= enemy.health) and not enemy.dead and enemy.visible then
						CastQ(enemy)
						CastW(enemy)
					elseif ((Qdmg + Wdmg + Rdmg) >= enemy.health) and not enemy.dead and enemy.visible then
						CastQ(enemy)
						CastW(enemy)
						CastR(enemy)
					end 

				end 
			end 
		end 
	end 
end 
--]]

function DrawKillable()
	for i = 1, heroManager.iCount, 1 do
		local enemy = heroManager:getHero(i)
		--if ValidTarget(champ, 625) then
			if enemy.team ~= myHero.team then 

				if Qready then
					Qdmg = getDmg("Q", enemy, myHero)
				end
			    if  Wready then
					Wdmg = getDmg("W", enemy, myHero)
			    end 
			    if  Rready then
					Rdmg = getDmg("R", enemy, myHero)
				end 

				if Qready and Qdmg > enemy.health then
					DrawText3D("Q = kill", enemy.x, enemy.y + 25, enemy.z, 0, 4294967295, true)
				elseif Qready and Wready and Qdmg + Wdmg > enemy.health then
					DrawText3D("QW = kill", enemy.x, enemy.y + 25, enemy.z, 0, 4294967295, true)
				elseif Qready and Wready and Rready and Qdmg + Wdmg + Rdmg > enemy.health then
					DrawText3D("QWR = kill", enemy.x, enemy.y + 25, enemy.z, 0, 4294967295, true)
				elseif Qready and Wready and Rready and Qdmg + Wdmg + Rdmg + Qdmg > enemy.health then
					DrawText3D("QQWWR = kill", enemy.x, enemy.y + 25, enemy.z, 0, 4294967295, true)
				elseif Qready and Wready and Rready and Qdmg + Wdmg + Rdmg + Qdmg + Wdmg > enemy.health then
					DrawText3D("QQWWR = kill", enemy.x, enemy.y + 25, enemy.z, 0, 4294967295, true)
				end 
			end 
		--end 
	end 
end

function HaveBuff(unit,buffname)
	local result = false
	for i = 1, unit.buffCount, 1 do 
		if unit:getBuff(i) ~= nil and unit:getBuff(i).name == buffname and unit:getBuff(i).valid and BuffIsValid(unit:getBuff(i)) then 
			result = true 
			break 
		end 
	end 
	return result
end 

function OnCreateObj(object)
    if object.name == "StunReady.troy" and GetDistance(object, myHero) < 50 then
        canStun = true
    end


end 


function OnDeleteObj(object)
    if object.name == "StunReady.troy" and GetDistance(object, myHero) < 50 then
        canStun = false
    end
end
 

function OnGainBuff(unit, buff)
	if unit.isMe and (buff.name == "pyromania") then
		passiveStacks = 1
	end

	if unit.isMe and (buff.name == "infernalguardiantimer") then
		hasTibbers = true
	end 

	if unit.isMe and (buff.name == "recall") then
		isRecalling = true
	end 

end

function OnUpdateBuff(unit, buff)
	if unit.isMe and (buff.name == "pyromania") then
		passiveStacks = passiveStacks + 1
	end 
end

function OnLoseBuff(unit, buff)
	if unit.isMe and (buff.name == "pyromania_particle") then
		passiveStacks = 0
	end 
	if unit.isMe and (buff.name == "infernalguardiantimer") then
		hasTibbers = false
	end 
	if unit.isMe and (buff.name == "recall") then
		isRecalling = false
	end 
end


function OnProcessSpell(object, spell)
  	if (spell.target == myHero and string.find(spell.name, "BasicAttack")) and Menu.misc.useEonAttack then
   	 	CastSpell(_E)
  	end
end


function DrinkPotions()
	health = myHero.health
	mana = myHero.mana
	maxHealth = myHero.maxHealth
	maxMana = myHero.maxMana
	
		DrinkHealth(health, maxHealth)
		DrinkMana(mana, maxMana)
end 

function DrinkHealth(h, mH) 
	if not HaveBuff(myHero, "RegenerationPotion") then
		if GetInventoryHaveItem(2003) then
			if (h / mH <= Menu.misc.autopotions.health) then
				CastItem(2003)
			end 
		end 
	end
end 

function DrinkMana(m, mM) 
	if not HaveBuff(myHero, "FlaskOfCrystalWater") then
		if GetInventoryHaveItem(2004) then
			if (m / mM <= Menu.misc.autopotions.mana) then
				CastItem(2004)
			end 
		end 
	end 
end 

function UseHeal()
	health = myHero.health
	maxHealth = myHero.maxHealth

	if Hready then
		if ((health / maxHealth) <= Menu.misc.autoheal.amountOfHealth) then
			CastSpell(heal)
		end 
	end 

	if Menu.misc.autoheal.amountOfHealth then
		for i, teammate in ipairs(GetAllyHeroes()) do
			if GetDistance(teammate, myHero) <= 700 then
				health = teammate.health
				maxHealth = teammate.maxHealth

				if ((health / maxHealth) <= Menu.misc.autoheal.amountOfHealth) then
					if Hready then
						CastSpell(heal)
					end 
				end 
			end 
		end 
	end 
end 

function UseIgnite()
	local igniteDMG = (50 + (20 * myHero.level))
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistance(enemy, myHero) < 600 and ValidTarget(enemy, 600) and Menu.misc.autoignite[enemy.charName] then
			if Iready then
				if enemy.health < igniteDMG then
					CastSpell(ignite, enemy)
				end 
			end 
		end  
	end 
end 


function UseBarrier()
	health = myHero.health
	maxHealth = myHero.maxHealth

	if Bready then
		if ((health / maxHealth) <= Menu.misc.autobarrier.amountOfHealth) then
			CastSpell(barrier)
		end 
	end 
end 


function ManaManager()
	mana = myHero.mana
	if (mana / myHero.maxMana <= Menu.harass.harassMana) then
		return false
	end
	return true 
end 


function AutoLevel()

	if Menu.misc.autolevel.levelAuto == 1 or myHero.level <= lastLevel then return end

	LevelSpell(levelSequences[Menu.misc.autolevel.levelAuto - 1][myHero.level])
	lastLevel = myHero.level

end


function DrawMenu()
	-- Menu
 Menu = scriptConfig("NAnnie by Nickieboy", "NAnnie")

 -- Combo
 Menu:addSubMenu("Combo", "combo")
 Menu.combo:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 Menu.combo:addParam("comboQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.combo:addParam("comboW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.combo:addParam("comboR", "Use R", SCRIPT_PARAM_ONOFF, true)
  Menu.combo:addSubMenu("R Usage", "RUsage")
 for i, enemy in ipairs(GetEnemyHeroes()) do
	Menu.combo.RUsage:addParam(enemy.charName, "Use R on " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
 end 
 Menu.combo.RUsage:addParam("hitX", "Auto R if hit x enemies", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
 Menu.combo:addParam("comboDFG", "Use DFG", SCRIPT_PARAM_ONOFF, true)
 Menu.combo:addParam("comboRStun", "Only R if R stuns", SCRIPT_PARAM_ONOFF, true)

 -- Harass
 Menu:addSubMenu("Harass", "harass")
 Menu.harass:addParam("harass", "Harass (T)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 Menu.harass:addParam("harass", "Harass Toggle (Y)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))
 Menu.harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.harass:addParam("harassW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.harass:addParam("autoQ", "Auto Q when stuns enemy", SCRIPT_PARAM_ONOFF, false)
 Menu.harass:addParam("autoQW", "Auto Q/W when W will stun enemy", SCRIPT_PARAM_ONOFF, false)
 Menu.harass:addParam("harassMana", "Mana Manager %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 -- Farming
 Menu:addSubMenu("Farming", "farm")
 Menu.farm:addParam("farm", "Farming (K)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
 Menu.farm:addParam("farmQ", "Farm using Q", SCRIPT_PARAM_ONOFF, false)
 Menu.farm:addParam("farmW", "Farm using W", SCRIPT_PARAM_ONOFF, false)
 Menu.farm:addParam("farmStun", "Farm until Stun is up", SCRIPT_PARAM_ONOFF, false)

 --Drawings
 Menu:addSubMenu("Drawings", "drawings")
 Menu.drawings:addParam("draw", "Drawings", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawKillable", "Draw Killable", SCRIPT_PARAM_ONOFF, true)


 -- KillSteal
 --[[
 Menu:addSubMenu("Killsteal", "killsteal")
 Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 Menu.killsteal:addParam("killstealQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealR", "Use R", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealIgnite", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealDFG", "Use DFG", SCRIPT_PARAM_ONOFF, true)
--]]

 Menu:addSubMenu("Auto Kill when killable", "autokill")
 Menu.autokill:addParam("autokill", "Auto Kill - KillSteal", SCRIPT_PARAM_ONOFF, false)
 Menu.autokill:addParam("autokillDFG", "Use DFG", SCRIPT_PARAM_ONOFF, true)
 Menu.autokill:addParam("autokillQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.autokill:addParam("autokillW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.autokill:addParam("autokillR", "Use R", SCRIPT_PARAM_ONOFF, true)
 for i, enemy in ipairs(GetEnemyHeroes()) do
	Menu.autokill:addParam(enemy.charName, "Kill " .. enemy.charName, SCRIPT_PARAM_ONOFF, false)
 end 

 -- Misc
 Menu:addSubMenu("Misc", "misc")
 Menu.misc:addParam("procE", "Use E to get stacks", SCRIPT_PARAM_ONOFF, false)
 Menu.misc:addParam("useEonAttack", "Auto E when attacked", SCRIPT_PARAM_ONOFF, false)
 Menu.misc:addParam("info", "CAN NOT BE BOTH ON", SCRIPT_PARAM_INFO, "CAREFUL")

  -- Auto Level
 Menu.misc:addSubMenu("Auto Level", "autolevel")
 Menu.misc.autolevel:addParam("levelAuto", "Auto Level Spells", SCRIPT_PARAM_LIST, 1, { "Off", "QWER", "WQER"})

 -- Auto Potions
 Menu.misc:addSubMenu("Auto Potions", "autopotions")
 Menu.misc.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 Menu.misc.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 Menu.misc:addSubMenu("Zhyonas", "zhonyas")
 Menu.misc.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 Menu.misc.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)

if heal ~= nil then
	Menu.misc:addSubMenu("Auto Heal", "autoheal")
	Menu.misc.autoheal:addParam("useHeal", "Use Summoner Heal", SCRIPT_PARAM_ONOFF, false)
	Menu.misc.autoheal:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
	Menu.misc.autoheal:addParam("helpHeal", "Use Heal to save teammates", SCRIPT_PARAM_ONOFF, false)
end 
if ignite ~= nil then
	Menu.misc:addSubMenu("Auto Ignite", "autoignite")
	Menu.misc.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, false)
 	for i, enemy in ipairs(GetEnemyHeroes()) do
		Menu.misc.autoignite:addParam(enemy.charName, "Use Ignite On " .. enemy.charName, SCRIPT_PARAM_ONOFF, false)
 	end 
end 

if barrier ~= nil then
	Menu.misc:addSubMenu("Auto Barrier", "autobarrier")
	Menu.misc.autobarrier:addParam("useBarrier", "Use Summoner Barrier", SCRIPT_PARAM_ONOFF, false)
	Menu.misc.autobarrier:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
end 
  -- Default Information
 Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
 Menu:addParam("Author", "Author",  SCRIPT_PARAM_INFO, author)

  -- Target Selector
  Menu:addTS(ts)
  ts.name = "TargetSelector"

 -- Orbwalker to menu
 Menu:addSubMenu("Orbwalker", "Orbwalker")
 OrbWalk:LoadToMenu(Menu.Orbwalker)
 
 -- Always show
 Menu.combo:permaShow("combo")
 Menu.harass:permaShow("harass")
 --Menu.killsteal:permaShow("killsteal")
 Menu.autokill:permaShow("autokill")
 Menu.farm:permaShow("farm")
 Menu.misc.zhonyas:permaShow("zhonyas")
 Menu.drawings:permaShow("draw")

end

function MenuCheck()
	if Menu.misc.procE then
 		Menu.misc.useEonAttack = false
 	end
 	if Menu.misc.useEonAttack then
 		Menu.misc.procE = false
 	end 
end 



