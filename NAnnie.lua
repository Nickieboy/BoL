--[[
     Script Coded by Nickieboy.
     
    ]]

if myHero.charName ~= "Annie" then return end

require "Spell Damage Library"
require "SxOrbWalk"


local version = "1.1"
local author = "Nickieboy"
local SCRIPT_NAME = "NAnnie"
local lastLevel = myHero.level - 1
local Qdmg = 0
local Wdmg = 0
local Rdmg = 0
local totalDamage = 0
local health = 0
local mana = 0
local maxHealth = 0
local maxMana = 0
local canStun = false
local EnemyMinions = minionManager(MINION_ENEMY, 625, myHero, MINION_SORT_HEALTH_ASC)


--[[		Auto Update		]]
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/blob/master/Nannie.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("NAnnie by Nickieboy") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/blol/master/version/NAnnie.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
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
--Perform on load
function OnLoad()

 -- OrbWalker
OrbWalk = SxOrbWalk()

levelSequences = {
		[1] = { _Q, _W, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E },
		[2] = { _W, _Q, _W, _E, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E },
	}

 -- TargetSelector
 ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 625)

 DrawMenu()
 
 --Send in beginning
 PrintChat("Annie Script by Nickieboy loaded")
 PrintChat("This script does not automatically update. Visit the thread to stay updated")
end 

-- Perform every time
function OnTick()

 ts:update()
 Harass()
 Combo()
 KillSteal()
 AutoLevel()
 DrinkPotions()
 canStun = HaveBuff(myHero, "pyromania_particle")
 Farm()
 Zhonyas()
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
 	if ManaManager() ~= false then
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
end

function Combo()
	if (Menu.combo.combo) then
		if ts.target ~= nil and ValidTarget(ts.target, 625) then
			if Menu.combo.comboRStun and CanUseSpell(_R) then
				Combo2()
			else	
				Combo1()
			end  
		end 
	end 
end 

function Combo1()
	if Menu.combo.comboDFG then
		CastItem(3128, ts.target)
	end 
	if (Menu.combo.comboQ) then
		CastQ(ts.target)
	end 
	if (Menu.combo.comboW) then
		CastW(ts.target)
	end 
	if (Menu.combo.comboR) then
		if ValidTarget(ts.target, 600) then
			CastR(ts.target)
		end 
	end 
end 

function Combo2()
	if Menu.combo.comboR then
		if canStun then
			if ValidTarget(ts.target, 600) then
				CastR(ts.target)
			end 

			if Menu.combo.comboDFG then
				if GetInventoryHaveItem(3128) and GetInventoryItemIsCastable(3128) then
					CastItem(3128, ts.target)
				end
			end 

			if Menu.combo.comboQ then
				CastQ(ts.target)
			end 

			if Menu.combo.comboW then
					CastW(ts.target)
			end 
		else

			if Menu.combo.comboDFG then
				if GetInventoryHaveItem(3128) and GetInventoryItemIsCastable(3128) then
					CastItem(3128, ts.target)
				end
			end 

			if Menu.combo.comboQ then
				CastQ(ts.target)
			end 

			if canStun then
				if ValidTarget(ts.target, 600) then
					CastR(ts.target)
				end 
			else 
				if Menu.combo.comboW then
					CastW(ts.target)
				end 
			end 

			if not CanUseSpell(_R) then
				CastW(ts.target)
			else 
				if canStun then
					CastR(ts.target)
				else 
					CastE()
					if canStun then
						CastR(ts.target)
					end 
				end 
			end 
		end 
	end  
end 

function CastQ(target) 
	if CanUseSpell(_Q) and myHero.canAttack then
    CastSpell(_Q, target)
   end
end


function CastW(target) 
	if CanUseSpell(_W) and myHero.canAttack then
    CastSpell(_W, target)
   end
end

function CastE()
	if CanUseSpell(_E) and myHero.canAttack then
		CastSpell(_E)
    end
end

function CastR(target)
	if CanUseSpell(_R) and myHero.canAttack then
		CastSpell(_R, target)
    end
end

function Farm()
	EnemyMinions:update()
	if Menu.farm.farm and not Menu.combo.combo then
		if Menu.farm.farmQ then
		FarmQ()
		end 
		if Menu.farm.farmW then
			FarmW()
		end 
	end 
end 

function FarmW()
	for i, minion in pairs(EnemyMinions.objects) do
		if Menu.farm.farmW then
			Qdmg = getDmg("Q", minion, myHero)
			if minion ~= nil and not minion.dead and minion.visible and minion.health < Wdmg and OrbWalk:ValidTarget(minion, 625) then
				CastW(minion)
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
	if Menu.zhonyas.zhonyas then
		if GetInventoryHaveItem(3157) and GetInventoryItemIsCastable(3157) then
			health = myHero.health
			mana = myHero.mana
			maxHealth = myHero.maxHealth
			if (health / maxHealth) <= Menu.zhonyas.zhonyasunder then
				CastItem(3157)
			end 
		end 
	end 
end


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
				 			if CanUseSpell(_Q) then
				 				CastSpell(_Q, champ)
				 		    elseif CanUseSpell(_W) then
				 		    	CastSpell(_W, champ)
				 		    else 
				 		    	CastSpell(_R, champ)
				 			end
				 		end 
				 	end
				end
			end
		end 
   end 
end

--[[
NOT FUNCTIONABLE DUE TO IT NOT DRAWING CORRECTLY
function DrawKillable()
	for i = 1, heroManager.iCount, 1 do
		local champ = heroManager:getHero(i)
		
		if champ.team ~= myHero.team then 
			if CanUseSpell(_Q) then
			Qdmg = getDmg("Q", champ, myHero)
		    else 
		    	Qdmg = 0
		    end 
		    if CanUseSpell(_W) then
			Wdmg = getDmg("W", champ, myHero)
		    else 
		    	wDmg = 0 
		    end 
		    if CanUseSpell(_R) then
			Rdmg = getDmg("R", champ, myHero)
			else 
			Rdmg = 0
			end 

			totalDamage = Qdmg + Wdmg + Rdmg

			if (totalDamage >= champ.health) then
				DrawText("Can be killed", 10, champ.x, champ.y, ARGB(255, 255, 255, 0))
			end 
		end 
	end 
end
]]--

function HaveBuff(unit,buffname)
	local result = false
	for i = 1, 64, 1 do 
		if unit:getBuff(i) ~= nil and unit:getBuff(i).name == buffname then 
			result = true 
			break 
		end 
	end 
	return result
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
			if (h / mH <= Menu.autopotions.health) then
				CastItem(2003)
			end 
		end 
	end
end 

function DrinkMana(m, mM) 
	if not HaveBuff(myHero, "FlaskOfCrystalWater") then
		if GetInventoryHaveItem(2004) then
			if (m / mM <= Menu.autopotions.mana) then
				CastItem(2004)
			end 
		end 
	end 
end 


function ManaManager()
	mana = myHero.mana
	if (mana < Menu.harass.harassMana) then
		return false
	end
	return true 
end 

function AutoLevel()

	if Menu.autolevel.levelAuto == 1 or myHero.level <= lastLevel then return end

	LevelSpell(levelSequences[Menu.autolevel.levelAuto - 1][myHero.level])
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
 Menu.combo:addParam("comboDFG", "Use DFG", SCRIPT_PARAM_ONOFF, true)
 Menu.combo:addParam("comboRStun", "Use R if can stun", SCRIPT_PARAM_ONOFF, true)

 -- Harass
 Menu:addSubMenu("Harass", "harass")
 Menu.harass:addParam("harass", "Harass (T)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 Menu.harass:addParam("harass", "Harass Toggle (Y)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))
 Menu.harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.harass:addParam("harassW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.harass:addParam("harassMana", "Mana Manager %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 -- Farming
 Menu:addSubMenu("Farming", "farm")
 Menu.farm:addParam("farm", "Farming (K)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
 Menu.farm:addParam("farmQ", "Farm using Q", SCRIPT_PARAM_ONOFF, false)
 Menu.farm:addParam("farmW", "Farm using W", SCRIPT_PARAM_ONOFF, false)

 --Drawings
 Menu:addSubMenu("Drawings", "drawings")
 Menu.drawings:addParam("draw", "Drawings", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
 Menu.drawings:addParam("drawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

 -- KillSteal
 Menu:addSubMenu("Killsteal", "killsteal")
 Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 Menu.killsteal:addParam("killstealQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealW", "Use W", SCRIPT_PARAM_ONOFF, true)
 Menu.killsteal:addParam("killstealR", "Use R", SCRIPT_PARAM_ONOFF, true)

 -- Auto Level
 Menu:addSubMenu("Auto Level", "autolevel")
 Menu.autolevel:addParam("levelAuto", "Auto Level Spells", SCRIPT_PARAM_LIST, 1, { "Off", "QWER", "WQER"})

 -- Auto Potions
 Menu:addSubMenu("Auto Potions", "autopotions")
 Menu.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 Menu.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 Menu:addSubMenu("Zhyonas", "zhonyas")
 Menu.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 Menu.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)

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
 Menu.killsteal:permaShow("killsteal")
 Menu.farm:permaShow("farm")
 Menu.zhonyas:permaShow("zhonyas")
 Menu.drawings:permaShow("draw")

end


--- BoL Script Status Connector --- 
local ScriptKey = "WJMJOPOPJNI" -- NAnnie auth key

-- Thanks to Bilbao for his socket help & encryption
assert(load(Base64Decode("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"), nil, "bt", _ENV))() BolBoost( ScriptKey, "" )
-----------------------------------