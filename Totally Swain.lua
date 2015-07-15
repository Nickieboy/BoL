--[[
				Author: Totally Legit
				Changelog:
						 > 1.0
						 		Release
						 > 1.1
						 		Few tweaks
						 		Fixed R
						 > 1.2
						 		R is smoother
						 		Code is smoother
						 		Added library
						 > 1.3
						 		Forgot to actually add item support
						 > 1.35
						 		Fixed laneclear (Mistyped)
						 		You can normally now do manual R
						 			Haven't test it
						> 1.36
								Dead Check
						> 1.37
								Temp fixes
						> 1.42
								Fixed few stuff
						> 1.43
								Ult really works now

						> 1.50
								No longer requires SxOrb
								Supports all predictions now

--]]

-- Download script
local version = 1.50
local author = "Totally Legit"
local SCRIPT_NAME = "Totally Swain"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/Totally Swain.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function Say(text)
	print("<font color=\"#FF0000\"><b>Totally Swain:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/TotallySwain.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				Say("New version available "..ServerVersion)
				Say("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () Say("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				Say("You have got the latest version (v"..ServerVersion..") of Totally Swain by " .. author)
			end
		end
	else
		Say("Error downloading version info")
	end
end

if not FileExist(LIB_PATH.."TotallyLib.lua") then return Say("Please download TotallyLib before running this script, thank you. Make sure it is in your common folder.") end
if not FileExist(LIB_PATH.."VPrediction.lua") then return Say("Please download VPrediction before running this script, thank you. Make sure it is in your common folder.") end

-- Download Libraries
local REQUIRED_LIBS = {
	["VPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
	["TotallyLib"] = "https://raw.githubusercontent.com/Nickieboy/BoL/master/lib/TotallyLib.lua"
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


local divinePredLoaded, hPredLoaded, sPredLoaded = false, false, false

if VIP_USER and FileExist(LIB_PATH.."DivinePred.lua") and FileExist(LIB_PATH.."DivinePred.luac") then
	divinePredLoaded = true
	require "DivinePred"
end 

if FileExist(LIB_PATH.."HPrediction.lua") then
	hPredLoaded = true
	require "HPrediction"
end

if FileExist(LIB_PATH.."SPrediction.lua") then
	sPredLoaded = true
	require "SPrediction"
end


function InitializeVariables()
	serverMessage = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/announcements/totallyseries.txt")
	print("<font color=\"#000000\"><b>Totally Series (Latest News):</b></font> <font color=\"#ffaa00\">" .. tostring(serverMessage) .. "</font>")

	Spells = {
		["Q"] = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0},
		["W"] = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge},
		["E"] = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400},
		["R"] = {name = "Ravenous Flock", range = 800, delay = 0, speed = 0}

	}

	Qready, Wready, Eready, Rready = false

	target = nil
	RcastedThroughBot = false

	SxOrbloaded = false
	SxOrb = nil
	EnemyMinions = minionManager(MINION_ENEMY, Spells.R.range, myHero, MINION_SORT_HEALTH_ASC)

	ts = TargetSelector(TARGET_LOW_HP, 625)
	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}

	-- DivinePrediction
 	if divinePredLoaded then
		DP = assert(DivinePred())
		if not DP then
			divinePredLoaded = false 
		end	
	end

	if hPredLoaded then
		HPred = assert(HPrediction())
		if not HPred then
			hPredLoaded = false 
		end
	end

	if sPredLoaded then
		SPred = assert(SPrediction())
		if not SPred then
			sPredLoaded = false 
		else
			SPred.SpellData[myHero.charName][_W] = { speed = Spells.W.speed, delay = Spells.W.delay, range = Spells.W.range, width = Spells.W.radius, collision = false, aoe = true, type = "circular"}
		end
	end

	-- Checking whether ult is active or not
	ultActive = TargetHaveParticle("swain_demonForm_idle.troy", myHero, 50)
end

function OnCreateObj(obj) 
	if obj and obj.name and obj.name:lower():find("swain_demonform_idle.troy") and GetDistance(obj) <= 50 then
		ultActive = true
	end
end

function OnDeleteObj(obj)
	if obj and obj.name and obj.name and obj.name:lower():find("swain_demonform_idle.troy") and GetDistance(obj) <= 50 then
		ultActive = false
	end
end

function CheckOrbWalker() 
	if _G.Reborn_Initialised then
		SACLoaded = true 
		Menu.orbwalker:addParam("info", "Detected SAC", SCRIPT_PARAM_INFO, "")
		Say("SAC found.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require("SxOrbWalk")
		SxOrbLoaded = true 
		_G.SxOrb:LoadToMenu(Menu.orbwalker)
		Say("SxOrbWalk found.")
	end

	if SACLoaded or SxOrbLoaded then
		orbWalkLoaded = true
	end

	if not orbWalkLoaded then 
		Say("You need either SAC or SxOrbWalk for this script. Please download one of them.") 
	else
		Say("Succesfully Loaded. Enjoy the script! Report bugs on the thread.")
	end
end

function GetOrbTarget()
	ts:update()
	return ts.target
end 

function isUltActive()
	return ultActive
end

assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQINAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBBkBAAB2AgAAIAACCHwCAAAUAAAAEBgAAAGNsYXNzAAQIAAAAVHJhY2tlcgAEBwAAAF9faW5pdAAECgAAAFVwZGF0ZVdlYgAEGgAAAGNvdW50aW5nSG93TXVjaFVzZXJzSWhhdmUAAgAAAAEAAAADAAAAAQAFCAAAAEwAQADDAIAAAUEAAF1AAAJGgEAApQAAAF1AAAEfAIAAAwAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAAAQQAQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAAAgAAAAMAAAAAAAQGAAAABQAAAAwAQACDAAAAwUAAAB1AAAIfAIAAAgAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAAAQQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAYAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAAAAAAAAQAAAAUAAABzZWxmAAEAAAAAABAAAABAb2JmdXNjYXRlZC5sdWEACAAAAAEAAAABAAAAAQAAAAEAAAACAAAAAwAAAAIAAAADAAAAAQAAAAUAAABzZWxmAAAAAAAIAAAAAQAAAAUAAABfRU5WAAQAAAALAAAAAwAKIwAAAMYAQAABQQAA3YAAAQaBQABHwcABXQGAAB2BAABMAUECwUEBAAGCAQBdQQACWwAAABeAAYBMwUECwQECAAACAAFBQgIA1kGCA11BgAEXQAGATMFBAsGBAgAAAgABQUICANZBggNdQYABTIFDAsHBAwBdAYEBCMCBhgiAAYYIQIGFTAFEAl1BAAEfAIAAEQAAAAQIAAAAcmVxdWlyZQAEBwAAAHNvY2tldAAEBwAAAGFzc2VydAAEBAAAAHRjcAAECAAAAGNvbm5lY3QABBQAAABtYWlraWU2MS5zaW5uZXJzLmJlAAMAAAAAAABUQAQFAAAAc2VuZAAEKwAAAEdFVCAvdHJhY2tlci9pbmRleC5waHAvdXBkYXRlL2luY3JlYXNlP2lkPQAEKQAAACBIVFRQLzEuMA0KSG9zdDogbWFpa2llNjEuc2lubmVycy5iZQ0KDQoABCsAAABHRVQgL3RyYWNrZXIvaW5kZXgucGhwL3VwZGF0ZS9kZWNyZWFzZT9pZD0ABAIAAABzAAQHAAAAc3RhdHVzAAQIAAAAcGFydGlhbAAECAAAAHJlY2VpdmUABAMAAAAqYQAEBgAAAGNsb3NlAAAAAAABAAAAAAAQAAAAQG9iZnVzY2F0ZWQubHVhACMAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAcAAAAHAAAACAAAAAgAAAAJAAAACQAAAAkAAAAIAAAACQAAAAoAAAAKAAAACwAAAAsAAAALAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAUAAAAFAAAAc2VsZgAAAAAAIwAAAAIAAABhAAAAAAAjAAAAAgAAAGIAAAAAACMAAAACAAAAYwADAAAAIwAAAAIAAABkAAcAAAAjAAAAAQAAAAUAAABfRU5WAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEADQAAAAEAAAABAAAAAQAAAAEAAAADAAAAAQAAAAQAAAALAAAABAAAAAsAAAALAAAACwAAAAsAAAAAAAAAAQAAAAUAAABfRU5WAA=="), nil, "bt", _ENV))()


function OnLoad()

	InitializeVariables()

	-- Basic libraries
	VP = VPrediction()

	-- Orbwalker
	DelayAction(function() CheckOrbWalker() end, 10)

	-- Drawing Menu
	Menu()


	if divinePredLoaded then
    	LoadDivinePrediction()
    end

    if hPredLoaded then
    	LoadHPrediction()
    end

end

function LoadDivinePrediction()
	divinePredictionTargetTable = {}
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and enemy.type and enemy.type == myHero.type then
			divinePredictionTargetTable[enemy.networkID] = DPTarget(enemy)
		end
	end

	CircleW = CircleSS(Spells.W.speed, Spells.W.range, Spells.W.radius, (Spells.W.delay * 1000), 0)
end

function LoadHPrediction()
	HPW = HPSkillshot({type = "PromptCircle", delay = Spells.W.delay, range = Spells.W.range, radius = Spells.W.radius, collisionM = Spells.W.collision, collisionH = Spells.W.collision})
end

function DivinePredictionLoaded()
	return divinePredLoaded and Menu.prediction.predictionType == 2
end

function SPredictionLoaded()
 	return sPredLoaded and ((divinePredLoaded and hPredLoaded and Menu.prediction.predictionType == 4) or (divinePredLoaded and not hPredLoaded and Menu.prediction.predictionType == 3) or (hPredLoaded and not divinePredLoaded and Menu.prediction.predictionType == 3) or (not hPredLoaded and not divinePredLoaded and Menu.prediction.predictionType == 2))
 end

function HPredMenuLoaded()
	return hPredLoaded and ((divinePredLoaded and Menu.prediction.predictionType == 3) or (not divinePredLoaded and Menu.prediction.predictionType == 2))
end


function PredictW(target)
	if not target then return end
	local castPos = nil

	if Menu.prediction.predictionType == 1 then
		local dashing, canHit, position = VP:IsDashing(target, Spells.W.delay, Spells.W.radius, Spells.W.speed, myHero)
		if dashing and canHit and GetDistanceSqr(position) <= Spells.W.range * Spells.W.range then
			castPos = position
		else
			local castPos2, hitchance = VP:GetCircularCastPosition(target, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)	
			if hitchance >= Menu.prediction.usePredictionVPred then	
				castPos = castPos2
			end 	
		end

	elseif DivinePredictionLoaded() then
		local tempDivineTarget = nil
		if divinePredictionTargetTable[target.networkID] ~= nil then
			tempDivineTarget = divinePredictionTargetTable[target.networkID]
		end
		if tempDivineTarget then
			local state, hitPos, perc = DP:predict(tempDivineTarget, CircleW)
			if state and state == SkillShot.STATUS.SUCCESS_HIT and hitPos ~= nil and perc >= Menu.prediction.usePredictionDPred then
				castPos = hitPos
			end
		end

	elseif HPredMenuLoaded() then
		local pos, hitchance = HPred:GetPredict(HPW, target, myHero)
		if hitchance >= Menu.prediction.usePredictionHPred  then
			castPos = pos 
		end
	elseif SPredictionLoaded() then
		local CastPosition, Chance, PredPos = SPred:Predict(_W, myHero, target)
		if CastPosition and Chance >= 1 then
			castPos = CastPosition
		end
	end
	return castPos
end

function CastQ(target)
	if target ~= nil and not target.dead and target.visible and GetDistanceSqr(target) <= Spells.Q.range * Spells.Q.range and target.type and (target.type == myHero.type or target.type == "obj_AI_Minion") then
		if Qready and ValidTarget(target) then
			CastSpell(_Q, target)
			return true
		end  
	end 
	return false
end 

function CastE(target)
	if target ~= nil and not target.dead and target.visible and GetDistanceSqr(target) <= Spells.E.range * Spells.E.range and target.type and (target.type == myHero.type or target.type == "obj_AI_Minion") then
		if Eready and ValidTarget(target) then
			CastSpell(_E, target)
			return true
		end  
	end 
	return false
end 

function CastW(target)
	if not target then return end
	if Wready and GetDistanceSqr(target) <= Spells.W.range * Spells.W.range and target and target.type then
		local castPos = PredictW(target)
		if castPos and GetDistance(castPos) <= Spells.W.radius + Spells.W.range then
			CastSpell(_W, castPos.x, castPos.z)
		end
	end
end


function OnTick()

	EnemyMinions:update()
	target = GetOrbTarget()
	Checks()

	if Menu.keys.combo then Combo() end 

	if Menu.keys.harass then Harass() end 

	if Menu.keys.laneclear then LaneClear() end

 	if RcastedThroughBot and not Menu.keys.combo and not Menu.keys.laneclear and isUltActive() and CountEnemyHeroInRange(Spells.R.range) < 1 and not Menu.combo.comboROff then
 		CastSpell(_R)
 		RcastedThroughBot = false
 	end

 	if RcastedThroughBot and not isUltActive() then
 		RcastedThroughBot = false 
 	end

 	if myHero.dead and RcastedThroughBot then 
 		RcastedThroughBot = false
 	end 
 	print(isUltActive() and "true" or "false")
end

function Checks()
	Qready = (myHero:CanUseSpell(_Q) == READY)
	Wready = (myHero:CanUseSpell(_W) == READY)
	Eready = (myHero:CanUseSpell(_E) == READY)
	Rready = (myHero:CanUseSpell(_R) == READY)
end


function OnDraw()
	if myHero.dead then return end
	if Menu.drawings.draw then
		if Menu.drawings.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, 0x111111)
		end
		if Menu.drawings.drawW then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, 0x111111)
		end
		if Menu.drawings.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, 0x111111)
		end
		if Menu.drawings.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range, 0x111111)
		end
	end 

end

function Combo()
	if myHero.dead then return end

	if target ~= nil then
		if Menu.combo.comboR then
			if IsSpellReady(_R) and not isUltActive() and CountEnemyHeroInRange(Spells.R.range) >= Menu.combo.comboRx then
				RcastedThroughBot = true
				CastSpell(_R) 
			elseif IsSpellReady(_R) and isUltActive() and CountEnemyHeroInRange(Spells.R.range) < Menu.combo.comboRx and not Menu.combo.comboROff then
				CastSpell(_R)
				RcastedThroughBot = false
			end 
			if isUltActive() and not RcastedThroughBot then
				RcastedThroughBot = true
			end
		end 

		if Menu.combo.comboItems then
			UseItems(target)
		end 

		if Menu.combo.comboE then
			CastE(target)
		end 

		if Menu.combo.comboQ then
			CastQ(target)
		end  

		if Menu.combo.comboW then
			CastW(target)
		end
	else
		if isUltActive() and RcastedThroughBot and not (CountEnemyHeroInRange(Spells.R.range) >= Menu.combo.comboRx) and not Menu.combo.comboROff then
 			CastSpell(_R) 
 		end
 	end
end


function Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassE then
			CastE(target)
		end 

		if Menu.harass.harassQ then
			CastQ(target)
		end 

		if Menu.harass.harassW then
			CastW(target)
		end 
	end
end 

function LaneClear() 
	if myHero.dead then return end
	if Menu.laneclear.laneclearW and IsSpellReady(_W) then
		local castPosition, hitchance, nTargets = GetBestAOEPosition(EnemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
		if castPosition then
			CastSpell(_W, castPosition.x, castPosition.z)
		end 
	end 

	if Menu.laneclear.laneclearR and IsSpellReady(_R) and not isUltActive() and CountMinions(EnemyMinions.objects, Spells.R.range) >= 1 then
		CastSpell(_R)
		RcastedThroughBot = true
	elseif Menu.laneclear.laneclearR and IsSpellReady(_R) and isUltActive() and CountMinions(EnemyMinions.objects, Spells.R.range) < 1 then
		CastSpell(_R)
		RcastedThroughBot = false
	end
end


function CalculateDamageWithoutBuff(t)
	local Qdmg = 0
	local Wdmg = 0
	local Edmg = 0
	Qdmg = getDmg("Q", t, myHero)

	Wdmg = getDmg("W", t, myHero) 

	Edmg = getDmg("E", t, myHero)

	return Qdmg, Wdmg, Edmg
end 

function CalculateDamageWithBuff(targ)
	local Qdmg, Wdmg, Edmg = CalculateDamageWithoutBuff(targ)

	if GetSpellData(_Q).level == 1 then
		Qdmg = Qdmg * 1.08
	elseif  GetSpellData(_Q).level == 2 then
		Qdmg = Qdmg * 1.11
	elseif GetSpellData(_Q).level == 3 then
		Qdmg = Qdmg * 1.14
	elseif GetSpellData(_Q).level == 4 then
		Qdmg = Qdmg * 1.17
	elseif GetSpellData(_Q).level == 5 then
		Qdmg = Qdmg *  1.20
	end 

	if GetSpellData(_W).level == 1 then
		Wdmg = Wdmg * 1.08
	elseif  GetSpellData(_Q).level == 2 then
		Wdmg = Wdmg * 1.11
	elseif GetSpellData(_Q).level == 3 then
		Wdmg = Wdmg * 1.14
	elseif GetSpellData(_Q).level == 4 then
		Wdmg = Wdmg * 1.17
	elseif GetSpellData(_Q).level == 5 then
		Wdmg = Wdmg * 1.20
	end 

	return Qdmg, Wdmg, Edmg
end

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil and myHero:CanUseSpell(item.slot) == READY then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end 

function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end


function Menu()

	Menu = scriptConfig("Totally Swain by Nickieboy", "TotallySwain")

	Menu:addSubMenu("Key Settings", "keys")
	Menu.keys:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.keys:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu.keys:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))

	-- Combo
	Menu:addSubMenu("Combo", "combo")

	Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboRx", "Min amount of people nearby", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
	Menu.combo:addParam("info", "Info:", SCRIPT_PARAM_INFO, "Above option is to only R if x people in range in combo")
	Menu.combo:addParam("comboROff", "Turn R off yourself", SCRIPT_PARAM_ONOFF, false)
	Menu.combo:addParam("info15", "Info:", SCRIPT_PARAM_INFO, "Script will activate R, but not disable it.")

	 -- Harass
	Menu:addSubMenu("Harass", "harass")
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)

	-- Farming
	Menu:addSubMenu("Laneclear", "laneclear")
	Menu.laneclear:addParam("laneclearW", "LaneClear using W", SCRIPT_PARAM_ONOFF, false)
	Menu.laneclear:addParam("laneclearR", "Laneclear using R", SCRIPT_PARAM_ONOFF, false)


 	--Drawings
 	Menu:addSubMenu("Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawR", "Draw " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	-- Prediction
 	Menu:addSubMenu("Prediction", "prediction")
 	if divinePredLoaded and hPredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "HPrediction", "SPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
		Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
 	elseif divinePredLoaded and hPredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "HPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
		Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
 	elseif divinePredLoaded and not hPredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "SPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
 	elseif divinePredLoaded and not hPredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionDPred", "DivinePred HitChance", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
 	elseif hPredLoaded and not divinePredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
 	elseif hPredLoaded and not divinePredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
		Menu.prediction:addParam("usePredictionHPred", "HPrediction HitChance", SCRIPT_PARAM_SLICE, 1, 1, 3, 2)
 	elseif not hPredLoaded and not divinePredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "SPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
 	elseif not hPredLoaded and not divinePredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction"})
 		Menu.prediction:addParam("usePredictionVPred", "VPrediction HitChance", SCRIPT_PARAM_SLICE, 2, 1, 6, 0)
 	end

 	--Misc
 	Menu:addSubMenu("Misc", "misc")
	MenuMisc(Menu.misc, true)
 	

	-- OrbWalker
	Menu:addSubMenu("OrbWalker", "orbwalker")

	 -- Always show
	 Menu.keys:permaShow("combo")
	 Menu.keys:permaShow("harass")
	 --Menu.killsteal:permaShow("killsteal")
	 Menu.keys:permaShow("laneclear")
	 Menu.drawings:permaShow("draw")

end 


assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("OBECCHCHICA") 
