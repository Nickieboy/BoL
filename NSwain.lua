--[[
				Author: Nickieboy
				Changelog:
						 > 1.0
						 		Release

				Donate: Look link in thread
				Bugs: Post in thread
				Appreciation: Post comment on bol.b00st and in thread
				Need more features: Post in thread. Everything is considered
--]]

-- Download script
local version = 1.0
local author = "Nickieboy"
local SCRIPT_NAME = "NSwain"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/NSwain.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>NSwain:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/NSwain.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version (v"..ServerVersion..") of NVarus by " .. author)
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end


-- Download Libraries
local REQUIRED_LIBS = {
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
	["SourceLib"] = "https://raw.githubusercontent.com/Dienofail/BoL/master/common/SourceLib.lua",
	["SOW"] = "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua",
	["Spell Damage Library"] = "https://raw.githubusercontent.com/Nickieboy/BoL/master/lib/Spell_Damage_Library.lua"
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


if myHero.charName ~= "Swain" then return end

local Qspell = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0}
local Wspell = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge}
local Espell = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400}
local Rspell = {name = "Ravenous Flock", range = 700, delay = 0, speed = 0}
local AA = 500
local rangeAVG = 625 * 625
local Qready, Wready, Eready, Rready = false, false, false, false
local Hready, Iready, Bready = false, false, false
local Qtarget, Wtarget, Etarget = nil, nil, nil
local ultActive = false
local heal, ignite, barrier = nil
local SOWloaded = false
local SxOrbloaded = false
local MMAloaded = false
local SACloaded = false
local SOWOrb, SxOrb = nil, nil
local EnemyMinions = minionManager(MINION_ENEMY, Rspell.range, myHero, MINION_SORT_HEALTH_ASC)
local ts = TargetSelector(TARGET_LOW_HP, 625)


function GetOrbTarget()
	ts:update()

	if SACloaded then
    	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then 
    		return _G.AutoCarry.Attack_Crosshair.target end
  	end

	if MMAloaded then
		return _G.MMA_Target
	end 

	if SxOrbloaded then
		return SxOrb:GetTarget()
		
	end

	if SOWloaded then
		return SOWOrb:GetTarget()
		
	end 

	if ValidTarget(ts.target) then
		return ts.target
	end 


end 

function OnLoad()

	FindSummoners() 

	DelayAction(CheckSACMMA, 1)

	VP = VPrediction()

	Q = Spell(_Q, Qspell.range, false)
	
	W = Spell(_W, Wspell.range, false)
	W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Wspell.width, Wspell.delay, Wspell.speed, false)
	W:SetAOE(true, Wspell.radius, 1)
	
	E = Spell(_E, Espell.range, false)
	
	R = Spell(_R, Rspell.range, false)


	Menu()

end



function OnTick()
	if not loaded then
		CheckSxOrbOrSOW()
	end 

	ts:update()

	SpellChecks()

	if Menu.combo.combo then
		Combo()
	end 

	if Menu.harass.harass then
		Harass()
	end 

	if Menu.farm.farm then
		Farm() 
	end

	if VIP_USER then
		if Menu.misc.skinChanger.skinChanger and skinChanged()  then
			GenModelPacket("Swain", Menu.misc.skinChanger.skinChangerSlice)
	        lastSkin = Menu.misc.skinChanger.skinChangerSlice
		end 
 	end 

 	if not Menu.combo.combo and not Menu.farm.farm and ultActive and CountEnemyHeroInRange(Rspell.range) < 3 then
 		CastSpell(_R)
 	end

 	if CountEnemyHeroInRange(Rspell.range) >= 3 and Rready and not ultActive then
 		CastSpell(_R)
 	end 

 	Zhonyas()
 	DrinkPotions()

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
end


function OnDraw()
	if Menu.drawings.draw then

		if Menu.drawings.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, Qspell.range, 0x111111)
		end

		if Menu.drawings.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, Espell.range, 0x111111)
		end

		if Menu.drawings.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, Rspell.range, 0x111111)
		end
	end 

	if not loaded then
		DrawText3D("Choose an orbwalker", myHero.x, myHero.y + 50, myHero.z, 50, 4294967295, true)
	end

end

function Combo()
	local target = GetOrbTarget()


	if Menu.combo.comboE then
		if target ~= nil and Eready then
			if VIP_USER and Menu.misc.pc.usePackets then
				Packet("S_CAST", {spellId = _E, fromX = target.x, fromY = target.z, toX = target.x, toY = target.z}):send()
			else 
				E:Cast(target)
			end 
		end
	end 

	if Menu.combo.comboQ then
		if target ~= nil and Qready then
			if VIP_USER and Menu.misc.pc.usePackets then
				Packet("S_CAST", {spellId = _Q, fromX = target.x, fromY = target.z, toX = target.x, toY = target.z}):send()
			else 
				Q:Cast(target)
			end 
		end 
	end 

	if Menu.combo.comboW then
		if target ~= nil and Wready then
			local castPosition, hitChance, nTargets = W:GetPrediction(target)
			if castPosition and hitChance >= 2 then
				W:Cast(castPosition.x, castPosition.z)
			end
		end  
	end 


	if Menu.combo.comboR then
		if Rready and not ultActive and CountEnemyHeroInRange(Rspell.range) > Menu.combo.comboRx then
			CastSpell(_R) 
		end 
		if Rready and ultActive and CountEnemyHeroInRange(Rspell.range) < Menu.combo.comboRx then
			CastSpell(_R)
		end 
	end 

end


function Harass()
	local target = GetOrbTarget()

	if Menu.harass.harassE then
		if target ~= nil and Eready then
			E:Cast(target)
		end 
	end 

	if Menu.harass.harassQ then
		if target ~= nil and Qready then
			Q:Cast(target)
		end 
	end 

	if Menu.harass.harassW then
		if target ~= nil and Wready then
			W:Cast(target.x, target.z)
		end 
	end 


end 

function Farm() 
	EnemyMinions:update()
	if #EnemyMinions.objects >= 2 then

		if Menu.farm.farmW and Wready then
			farmMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) end)
			local castPosition, bestHit = GetBestCircularFarmPosition(Wspell.range, Wspell.radius, farmMinions)

			if castPosition then
				W:Cast(castPosition.x, castPosition.z)
			end 
		end 

		if Menu.farm.farmR then
			if GetEnemyMinions() >= 3 then
				if Rready and not ultActive then
					CastSpell(_R)
				end 
			end 
		end 


	end 
end

function GetEnemyMinions()
	local range = myHero.range * myHero.range
    local minionsInRange = 0
    for i, minion in ipairs(EnemyMinions.objects) do
        if ValidTarget(minion) and GetDistanceSqr(myHero, minion) <= range then
            minionsInRange = minionsInRange + 1
        end
    end
    return minionsInRange
end  

--[[
function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 625) then
			local Qdmg, Wdmg, Edmg = CalculateDamageWithBuff(enemy)
		end 
	end 
end 
--]]

function CalculateDamageWithoutBuff(t)
	local Qdmg = 0
	local Wdmg = 0
	local Edmg = 0
	Qdmg = getDmg("Q", t, myHero)

	Wdmg = getDmg("W", t, myHero) 

	Edmg = getDmg("E", t, myHero)

	return Qdmg, Wdmg, Edmg
end 

function CalculateDamageWithBuff(t)
	local Qdmg, Wdmg, Edmg = CalculateDamageWithoutBuff(t)

	if GetSpellData(_Q).level == 1 then
		Qdmg = ((Qdmg / 100) * 8) + Qdmg
	elseif  GetSpellData(_Q).level == 2 then
		Qdmg = ((Qdmg / 100) * 11) + Qdmg
	elseif GetSpellData(_Q).level == 3 then
		Qdmg = ((Qdmg / 100) * 14) + Qdmg
	elseif GetSpellData(_Q).level == 4 then
		Qdmg = ((Qdmg / 100) * 17) + Qdmg
	elseif GetSpellData(_Q).level == 5 then
		Qdmg = ((Qdmg / 100) * 20) + Qdmg
	end 

	if GetSpellData(_W).level == 1 then
		Wdmg = ((Wdmg / 100) * 8) + Wdmg
	elseif  GetSpellData(_Q).level == 2 then
		Wdmg = ((Qdmg / 100) * 11) + Wdmg
	elseif GetSpellData(_Q).level == 3 then
		Wdmg = ((Qdmg / 100) * 14) + Wdmg
	elseif GetSpellData(_Q).level == 4 then
		Wdmg = ((Qdmg / 100) * 17) + Wdmg
	elseif GetSpellData(_Q).level == 5 then
		Wdmg = ((Qdmg / 100) * 20) + Wdmg
	end 
end 

function SpellChecks()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_Q) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)

	if ignite ~= nil then
		Iready = (myHero:CanUseSpell(ignite) == READY)
	end 

	if heal ~= nil then
		Hready = (myHero:CanUseSpell(heal) == READY)
	end 

	if barrier ~= nil then
		Bready = (myHero:CanUseSpell(barrier) == READY)
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

function skinChanged()
        return Menu.misc.skinChanger.skinChangerSlice ~= lastSkin
end


function GenModelPacket(champ, skinId)
        p = CLoLPacket(0x97)
        p:EncodeF(myHero.networkID)
        p.pos = 1
        t1 = p:Decode1()
        t2 = p:Decode1()
        t3 = p:Decode1()
        t4 = p:Decode1()
        p:Encode1(t1)
        p:Encode1(t2)
        p:Encode1(t3)
        p:Encode1(bit32.band(t4,0xB))
        p:Encode1(1)--hardcode 1 bitfield
        p:Encode4(skinId)
        for i = 1, #champ do
                p:Encode1(string.byte(champ:sub(i,i)))
        end
        for i = #champ + 1, 64 do
                p:Encode1(0)
        end
        p:Hide()
        RecvPacket(p)
end


function OnProcessSpell(unit, spell)
    if unit.isMe then
    	if spell.name == "SwainMetamorphism" and ultActive then
    		 ultActive = false
    		 return
    	end 

    	if spell.name == "SwainMetamorphism" and not ultActive then
    		ultActive = true
    		return
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
		if GetDistance(enemy, myHero) < 600 and ValidTarget(enemy, 600) then
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

function Menu()

	Menu = scriptConfig("NSwain by Nickieboy", "NSwain")

	-- Combo
	Menu:addSubMenu("Combo", "combo")
	Menu.combo:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.combo:addParam("comboQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboW", "Use " .. Wspell.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboR", "Use " .. Rspell.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboRx", "Use R if x amount of people nearby", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)

	 -- Harass
	Menu:addSubMenu("Harass", "harass")
 	Menu.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("harassQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Wspell.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, false)

	-- Farming
	Menu:addSubMenu("Farming", "farm")
	Menu.farm:addParam("farm", "Farming (K)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	Menu.farm:addParam("farmW", "Farm using W", SCRIPT_PARAM_ONOFF, false)
	Menu.farm:addParam("farmR", "Farm using R", SCRIPT_PARAM_ONOFF, false)

--[[
 	 -- Killsteal
	Menu:addSubMenu("KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealW", "Use " .. Wspell.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
--]]
 	--Drawings
 	Menu:addSubMenu("Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawR", "Draw " .. Rspell.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	--Misc
 	Menu:addSubMenu("Misc", "misc")
 	
 	Menu.misc:addSubMenu("Auto Potions", "autopotions")
 	Menu.misc.autopotions:addParam("usePotion", "Use Potions Automatically", SCRIPT_PARAM_ONOFF, false)
 	Menu.misc.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 	Menu.misc.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 	if heal ~= nil then
	Menu.misc:addSubMenu("Auto Heal", "autoheal")
	Menu.misc.autoheal:addParam("useHeal", "Use Summoner Heal", SCRIPT_PARAM_ONOFF, false)
	Menu.misc.autoheal:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
	Menu.misc.autoheal:addParam("helpHeal", "Use Heal to save teammates", SCRIPT_PARAM_ONOFF, false)
	end 

	if ignite ~= nil then
	Menu.misc:addSubMenu("Auto Ignite", "autoignite")
	Menu.misc.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, false)
	end 

	if barrier ~= nil then
	Menu.misc:addSubMenu("Auto Barrier", "autobarrier")
	Menu.misc.autobarrier:addParam("useBarrier", "Use Summoner Barrier", SCRIPT_PARAM_ONOFF, false)
	Menu.misc.autobarrier:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
	end 

	Menu.misc:addSubMenu("Zhyonas", "zhonyas")
 	Menu.misc.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)

	if VIP_USER then
		Menu.misc:addSubMenu("Skin Changer", "skinChanger")
		Menu.misc.skinChanger:addParam("skinChanger", "Change Skin (VIP)", SCRIPT_PARAM_ONOFF, false)
		Menu.misc.skinChanger:addParam("skinChangerSlice", "Change Skin", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
	end

	Menu.misc:addSubMenu("Gapcloser", "gc")
	AntiGapcloser(Menu.misc.gc, castStunGapClosing)
	Menu.misc:addSubMenu("Interrupter", "ai")
	Interrupter(Menu.misc.ai, castStunInterruptable)

	Menu.misc:addSubMenu("Packet Casting", "pc")
	Menu.misc.pc:addParam("usePackets", "Use Packets", SCRIPT_PARAM_ONOFF, false)

	--Orbwalker
	Menu:addSubMenu("OrbWalker", "orbwalker")
	Menu.orbwalker:addParam("sxorbwalk", "Use SxOrbWalk", SCRIPT_PARAM_ONOFF, false)
	Menu.orbwalker:addParam("sow", "Use SOW", SCRIPT_PARAM_ONOFF, false)

end 

-- Gapcloser (SourceLib TriggerCallbacks)
function castStunGapClosing(unit, spell)
	if Wready and GetDistance(unit) <= Wspell.range then
		W:Cast(unit.x, unit.z)
	end
end 

--Interuptable (SourceLib TriggerCallbacks)
function castStunInterruptable(unit, spell) 
	if Wready and GetDistance(unit) <= Wspell.range then
		W:Cast(unit.x, unit.z)
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
	if not HasBuff(myHero, "RegenerationPotion") then
		if GetInventoryHaveItem(2003) then
			if (h / mH <= Menu.misc.autopotions.health) then
				CastItem(2003)
			end 
		end 
	end
end 

function DrinkMana(m, mM) 
	if not HasBuff(myHero, "FlaskOfCrystalWater") then
		if GetInventoryHaveItem(2004) then
			if (m / mM <= Menu.misc.autopotions.mana) then
				CastItem(2004)
			end 
		end 
	end 
end 

function CheckSACMMA()
	if _G.AutoCarry then
  
	    if _G.AutoCarry.Helper then
	    	SACloaded = true
	    	loaded = true
	     	print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\"> Loaded SAC: Reborn</font>")
	    end
    
  	elseif _G.Reborn_Loaded then
    	DelayAction(CheckSACMMA, 1) 
	elseif _G.MMA_Loaded then
		MMAloaded = true
		loaded = true
		print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\"> Loaded MMA</font>")
	end 
end 


function CheckSxOrbOrSOW()
	if Menu.orbwalker.sxorbwalk then
		SxOrb = SxOrbWalk(VP)
		SxOrb:LoadToMenu(Menu.orbwalker)
		SxOrbloaded = true
		loaded = true
		print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\"> Loaded SxOrbWalk</font>")
		print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\"> Press F9 twice to change Orbwalker</font>")

	end 

	if Menu.orbwalker.sow then
		SOWOrb = SOW(VP)
		SOWOrb:LoadToMenu(Menu.orbwalker)
		SOWloaded = true
		loaded = true
		print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\">  Loaded SOW</font>")
		print("<font color=\"#20b2aa\">NSwain:</font> <font color=\"#FF0000\">  Press F9 twice to change Orbwalker</font>")
	end 
end 