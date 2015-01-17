--[[
				Author: Nickieboy
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

				Donate: Look link in thread
				Bugs: Post in thread
				Appreciation: Post comment on bol.b00st and in thread
				Need more features: Post in thread. Everything is considered
--]]

if myHero.charName ~= "Swain" then return end

-- Download script
local version = 1.40
local author = "Nickieboy"
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

-- Download Libraries
local REQUIRED_LIBS = {
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
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

if VIP_USER and FileExist(LIB_PATH.."Prodiction.lua") then
	require "Prodiction"
end

if not FileExist(LIB_PATH .. "SxOrbWalk.lua") then return Say("You need SxOrbWalk for this script. Please download this library.") end
if not FileExist(LIB_PATH .. "TotallyLib.lua") then return Say("You need TotallyLib for this script. Please download this library.") end

function InitializeVariables()
	serverMessage = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/announcements/totallyseries.txt")
	print("<font color=\"#000000\"><b>Totally Series (Latest News):</b></font> <font color=\"#ffaa00\">" .. tostring(serverMessage) .. "</font>")

	Spells = {
		["Q"] = {name = "Decrepify", range = 625, radius = 0, delay = 0, speed = 0},
		["W"] = {name = "Nevermore", range = 900, radius = 125, delay = 0.85, speed = math.huge},
		["E"] = {name = "Torment", range = 625, radius = 0, delay = 0, speed = 1400},
		["R"] = {name = "Ravenous Flock", range = 800, delay = 0, speed = 0}

	}

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
end

function GetOrbTarget()
	if SxOrbloaded then return SxOrb:GetTarget() end
	return ts.target
end 


assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQINAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBBkBAAB2AgAAIAACCHwCAAAUAAAAEBgAAAGNsYXNzAAQIAAAAVHJhY2tlcgAEBwAAAF9faW5pdAAECgAAAFVwZGF0ZVdlYgAEGgAAAGNvdW50aW5nSG93TXVjaFVzZXJzSWhhdmUAAgAAAAEAAAADAAAAAQAFCAAAAEwAQADDAIAAAUEAAF1AAAJGgEAApQAAAF1AAAEfAIAAAwAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAAAQQAQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAAAgAAAAMAAAAAAAQGAAAABQAAAAwAQACDAAAAwUAAAB1AAAIfAIAAAgAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAAAQQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAYAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAAAAAAAAQAAAAUAAABzZWxmAAEAAAAAABAAAABAb2JmdXNjYXRlZC5sdWEACAAAAAEAAAABAAAAAQAAAAEAAAACAAAAAwAAAAIAAAADAAAAAQAAAAUAAABzZWxmAAAAAAAIAAAAAQAAAAUAAABfRU5WAAQAAAALAAAAAwAKIwAAAMYAQAABQQAA3YAAAQaBQABHwcABXQGAAB2BAABMAUECwUEBAAGCAQBdQQACWwAAABeAAYBMwUECwQECAAACAAFBQgIA1kGCA11BgAEXQAGATMFBAsGBAgAAAgABQUICANZBggNdQYABTIFDAsHBAwBdAYEBCMCBhgiAAYYIQIGFTAFEAl1BAAEfAIAAEQAAAAQIAAAAcmVxdWlyZQAEBwAAAHNvY2tldAAEBwAAAGFzc2VydAAEBAAAAHRjcAAECAAAAGNvbm5lY3QABBQAAABtYWlraWU2MS5zaW5uZXJzLmJlAAMAAAAAAABUQAQFAAAAc2VuZAAEKwAAAEdFVCAvdHJhY2tlci9pbmRleC5waHAvdXBkYXRlL2luY3JlYXNlP2lkPQAEKQAAACBIVFRQLzEuMA0KSG9zdDogbWFpa2llNjEuc2lubmVycy5iZQ0KDQoABCsAAABHRVQgL3RyYWNrZXIvaW5kZXgucGhwL3VwZGF0ZS9kZWNyZWFzZT9pZD0ABAIAAABzAAQHAAAAc3RhdHVzAAQIAAAAcGFydGlhbAAECAAAAHJlY2VpdmUABAMAAAAqYQAEBgAAAGNsb3NlAAAAAAABAAAAAAAQAAAAQG9iZnVzY2F0ZWQubHVhACMAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAcAAAAHAAAACAAAAAgAAAAJAAAACQAAAAkAAAAIAAAACQAAAAoAAAAKAAAACwAAAAsAAAALAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAUAAAAFAAAAc2VsZgAAAAAAIwAAAAIAAABhAAAAAAAjAAAAAgAAAGIAAAAAACMAAAACAAAAYwADAAAAIwAAAAIAAABkAAcAAAAjAAAAAQAAAAUAAABfRU5WAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEADQAAAAEAAAABAAAAAQAAAAEAAAADAAAAAQAAAAQAAAALAAAABAAAAAsAAAALAAAACwAAAAsAAAAAAAAAAQAAAAUAAABfRU5WAA=="), nil, "bt", _ENV))()


function OnLoad()

	InitializeVariables()
	CheckOrbWalker()

	-- Basic libraries
	VP = VPrediction()
	SxOrb = SxOrbWalk()

	-- Drawing Menu
	Menu()

	-- TotallyLib Spell initializing
	Abilities = SpellHelper(VP, Menu)
	Abilities:AddSpell(_Q, Spells.Q.range)
	Abilities:AddSpell(_E, Spells.E.range)
	Abilities:AddSkillShot(_W, Spells.W.range, Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "circaoe")


	Say("Succesfully loaded. Enjoy the script. Please give feedback on the thread.")

end

function OnTick()

	EnemyMinions:update()
	target = GetOrbTarget()

	if Menu.keys.combo then Combo() end 

	if Menu.keys.harass then Harass() end 

	if Menu.keys.laneclear then LaneClear() end

 	if RcastedThroughBot and not Menu.keys.combo and not Menu.keys.laneclear and ultActive() and CountEnemyHeroInRange(Spells.R.range) < 1 then
 		CastSpell(_R)
 		RcastedThroughBot = false
 	end

 	if myHero.dead and RcastedThroughBot then 
 		RcastedThroughBot = false
 	end 

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
			if IsSpellReady(_R) and not ultActive() and CountEnemyHeroInRange(Spells.R.range) >= Menu.combo.comboRx then
				RcastedThroughBot = true
				CastSpell(_R) 
			elseif IsSpellReady(_R) and ultActive() and CountEnemyHeroInRange(Spells.R.range) < Menu.combo.comboRx then
				CastSpell(_R)
				RcastedThroughBot = false
			end 
			if ultActive() and not RcastedThroughBot then
				RcastedThroughBot = true
			end
		end 

		if Menu.combo.comboItems then
			UseItems(target)
		end 

		if Menu.combo.comboE then
			Abilities:Cast(_E, target)
		end 

		if Menu.combo.comboQ then
			Abilities:Cast(_Q, target) 
		end  

		if Menu.combo.comboW then
			Abilities:Cast(_W, target)
		end
	else
		if ultActive() and RcastedThroughBot and not (CountEnemyHeroInRange(Spells.R.range) >= Menu.combo.comboRx) then
 			CastSpell(_R) 
 		end
 	end
end


function Harass()
	if myHero.dead then return end
	if target ~= nil then
		if Menu.harass.harassE then
			Abilities:Cast(_E, target)
		end 

		if Menu.harass.harassQ then
			Abilities:Cast(_Q, target) 
		end 

		if Menu.harass.harassW then
			Abilities:Cast(_W, target)
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

	if Menu.laneclear.laneclearR and IsSpellReady(_R) and not ultActive() and CountMinions(EnemyMinions.objects, Spells.R.range) >= 1 then
		CastSpell(_R)
		RcastedThroughBot = true
	elseif Menu.laneclear.laneclearR and IsSpellReady(_R) and ultActive() and CountMinions(EnemyMinions.objects, Spells.R.range) < 1 then
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



function ultActive()
	return (myHero:GetSpellData(_Q).range + GetDistance(myHero.minBBox)/2) > 60
end

function Menu()

	Menu = scriptConfig("Totally Swain by Nickieboy", "TotallySwain.cfg")

	Menu:addSubMenu("Key Settings", "keys")
	Menu.keys:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.keys:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu.keys:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	Menu.keys:addParam("lasthit", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	SxOrb:RegisterHotKey("fight", Menu.keys, "combo") 
	SxOrb:RegisterHotKey("harass", Menu.keys, "harass") 
	SxOrb:RegisterHotKey("laneclear", Menu.keys, "laneclear") 
	SxOrb:RegisterHotKey("lasthit", Menu.keys, "lasthit") 

	-- Combo
	Menu:addSubMenu("Combo", "combo")

	Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboRx", "Min amount of people nearby", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
	Menu.combo:addParam("info", "Info:", SCRIPT_PARAM_INFO, "Above option is to only R if x people in range in combo")

	 -- Harass
	Menu:addSubMenu("Harass", "harass")
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)

	-- Farming
	Menu:addSubMenu("Laneclear", "laneclear")
	Menu.laneclear:addParam("laneclearW", "LaneClear using W", SCRIPT_PARAM_ONOFF, false)
	Menu.laneclear:addParam("laneclearR", "Laneclear using R", SCRIPT_PARAM_ONOFF, false)

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
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawR", "Draw " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	--Misc
 	Menu:addSubMenu("Misc", "misc")
	MenuMisc(Menu.misc, true)
 	

	--Orbwalker
	Menu:addSubMenu("OrbWalker", "orbwalker")
	SxOrb:LoadToMenu(Menu.orbwalker, true)

	 -- Always show
	 Menu.keys:permaShow("combo")
	 Menu.keys:permaShow("harass")
	 --Menu.killsteal:permaShow("killsteal")
	 Menu.keys:permaShow("laneclear")
	 Menu.drawings:permaShow("draw")

end 


function CheckOrbWalker()
	if FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		SxOrbloaded = true
	end 
end 
