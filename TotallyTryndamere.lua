--[[
		Script: Totally Tryndamere
		Author: Totally Legit


		Changelog:
					1.0: Release
					1.01: Fixes
					1.04: Had a typo in TotallyLib. This was the reason the E did not cast whiel
						  using VPrediction
					1.05: ScriptStatus integration

--]]


if myHero.charName ~= "Tryndamere" then return end


-- ScriptStatus
assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("XKNLMJPROPM") 


-- Download script
local version = 1.05
local author = "Totally Legit"
local SCRIPT_NAME = "Totally Tryndamere"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/TotallyTryndamere.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function Say(text)
	print("<font color=\"#FF0000\"><b>Totally Tryndamere:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/TotallyTryndamere.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				Say("New version available (v"..ServerVersion .. ")")
				Say("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () Say("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				Say("You have got the latest version (v"..ServerVersion..")")
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


function InitializeVariables()
	serverMessage = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/announcements/totallyseries.txt")
	print("<font color=\"#000000\"><b>Totally Series (Latest News):</b></font> <font color=\"#ffaa00\">" .. tostring(serverMessage) .. "</font>")

	Spells = {
		["AA"] = {range = 125},
		["Q"] = {name = "Bloodlust", range = 0, ready = false},
		["W"] = {name = "Mocking Shout", range = 400, ready = false},
		["E"] = {name = "Spinning Slash", range = 660, radius = 225, speed = math.huge, delay = 0, ready = false},
		["R"] = {name = "Undying Rage", range = 0, delay = 0, speed = 0, ready = false},

	}
	ts = TargetSelector(TARGET_LOW_HP, Spells.E.range)
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
	return SxOrb:GetTarget(Spells.E.range) 
end 



function OnLoad()
	VP = VPrediction()
	SxOrb = SxOrbWalk()

	InitializeVariables()

	DrawMenu()

	Spells.E.Cast = SpellHelper(VP, Menu)
	Spells.E.Cast:AddSkillShot(_E, Spells.E.range, Spells.E.delay, Spells.E.radius, Spells.E.speed, false, "line")

	Say("Loaded Script")
end

function OnTick()
	target = GetOrbTarget()
	Spells.Q.ready = myHero:CanUseSpell(_Q) == READY
	Spells.W.ready = myHero:CanUseSpell(_W) == READY
	Spells.E.ready = myHero:CanUseSpell(_E) == READY
	Spells.R.ready = myHero:CanUseSpell(_R) == READY
	RHelper()
	KillSteal()
	if Menu.keys.combo then Combo() end 
end


function OnDraw()
	if myHero.dead then return end
	if Menu.drawings.draw then
		if Menu.drawings.drawW then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, 0x111111)
		end
		if Menu.drawings.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, 0x111111)
		end
	end 
end

function Combo()
	if myHero.dead then return end
	if target ~= nil then

		if Menu.combo.comboItems then
			UseItems(target)
		end 

		if Menu.combo.comboE then
			Spells.E.Cast:Cast(_E, target)
		end

		if Menu.combo.comboW and Spells.W.ready then
			CastW(target)
		end
	end
end

function CastW(target)
	if target ~= nil then
		if isBothFacing(myHero, target) and GetDistance(target) < Spells.AA.range then
			CastSpell(_W)
		elseif not isFacing(myHero, target) and not isFacing(target, myHero) and GetDistance(target) < Spells.W.range and GetDistance(target) > Spells.AA.range then
			CastSpell(_W)
		end
	end 
end

function RHelper()
	if Menu.rhelper.rhelper and Spells.R.ready and myHero.health / myHero.maxHealth <= Menu.rhelper.useR then
		CastSpell(_R)
	end
end
function KillSteal()
	if Menu.killsteal.killsteal and Menu.killsteal.killstealE then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, Spells.E.range) and Spells.E.ready then
				if getDmg("E", enemy, myHero) > enemy.health then
					Spells.E.Cast:Cast(_E, enemy)
				end
			end
		end
	end
end

function DrawMenu()

	Menu = scriptConfig("Totally Tryndamere", "TotallyTryndamere.cfg")

	Menu:addSubMenu(SCRIPT_NAME .. " - Key Settings", "keys")
	Menu.keys:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.keys:addParam("laneclear", "LaneClear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("K"))
	Menu.keys:addParam("lasthit", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	SxOrb:RegisterHotKey("fight", Menu.keys, "combo") 
	SxOrb:RegisterHotKey("laneclear", Menu.keys, "laneclear") 
	SxOrb:RegisterHotKey("lasthit", Menu.keys, "lasthit") 

	-- Combo
	Menu:addSubMenu(SCRIPT_NAME .. " - Combo", "combo")
	Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)

 	 -- Killsteal
	Menu:addSubMenu(SCRIPT_NAME .. " - KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)

 	Menu:addSubMenu(SCRIPT_NAME .. " - R Helper", "rhelper")
 	Menu.rhelper:addParam("rhelper", "Use R Helper", SCRIPT_PARAM_ONOFF, true)
 	Menu.rhelper:addParam("useR", "Use R if health less %", SCRIPT_PARAM_SLICE, 0.1, 0, 1, 2)

 	--Drawings
 	Menu:addSubMenu(SCRIPT_NAME .. " - Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	--Misc
 	Menu:addSubMenu(SCRIPT_NAME .. " - Misc", "misc")
 	MenuMisc(Menu.misc, true)
 	
	--Orbwalker
	Menu:addSubMenu(SCRIPT_NAME .. " - OrbWalker", "orbwalker")
	SxOrb:LoadToMenu(Menu.orbwalker, true)

	 -- Always show
	 Menu.keys:permaShow("combo")
	 Menu.killsteal:permaShow("killsteal")
	 Menu.drawings:permaShow("draw")
	 
end 

function isFacing(source, target, lineLength)
	local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
	return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

function isBothFacing(source, target, lineLength)
return isFacing(source, target, lineLength) and isFacing(target, source, lineLength)
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
