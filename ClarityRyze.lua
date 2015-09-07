--[[
	Team Clarity:
		Team Clarity is a group of friends that united as quickly as a group of scripters.
		We only recently decided to group up, so we aren't putting our work together yet. We are simply 
		creating new content, so our teammembers can see how we code and what we can.
		Once we know our style of coding, we'll be able to improve each other.
		Our main purpose is to create decent content for the users, both free and paid.
	
	ChangeLog:
			1.0 
				Beta release
			1.05
				Forgot one check with HPediction, sorry.
			1.10
				Anti-GapCloser
				Snare under turret
				Tear Stacker / Passive Stacker
				Combo starts R -> Q -> E -> W
				Fixed Combo
				Fixed Harass
				Added a ton of nil checks
				Fixed bug where 2 predictions were still required
				Added ManaManagers
				
			1.11
				IsSpellReady error fix
			1.12
				Updated for 5.9
				Added Spell loop check on combo R
				Fixed spams
			1.13
				Fix'd crashes
			1.14
				fix'd error spamming
					Make sure your hpred/divinepred and SxOrbwalk are up-to-date
						you only need updated sxorb when you use it ofc ^^
				Added option to ignore minion collision on Q when passive is up

			1.15
				Fix'd a few more stuff
				Added humanizer
				Added SPred

			1.16
				Updated to patch 5.13
				Fix'd some minor stuff

			1.17
				Updated to newest SPred API

			1.18
				Updated for 5.14

			1.19
				Updated DPred API
--]]


if myHero.charName:lower() ~= "ryze" then return end


_G.Ryze_Loaded = true
_G.ScriptVersion = 1.19
_G.PerformAutoUpdate = true




function Say(text)
	print("<font color=\"#FF0000\"><b>Clarity Ryze:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

if not FileExist(LIB_PATH.."VPrediction.lua") then Say("You need at least VPrediction for this script to function.") return end

assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("VILKHQQMNHP") 

function AutoUpdate()
	local ToUpdate = {}
    ToUpdate.Version = _G.ScriptVersion
    ToUpdate.UseHttps = true
    ToUpdate.Host = "raw.githubusercontent.com"
    ToUpdate.VersionPath = "/Nickieboy/BoL/master/version/ClarityRyze.version"
    ToUpdate.ScriptPath =  "/Nickieboy/BoL/master/ClarityRyze.lua"
    ToUpdate.SavePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
    ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) Say("Updated to "..NewVersion..".") end
    ToUpdate.CallbackNoUpdate = function(OldVersion) Say("No Updates Found") end
    ToUpdate.CallbackNewVersion = function(NewVersion) Say("New Version found ("..NewVersion.."). Please wait until its downloaded.") end
    ToUpdate.CallbackError = function(NewVersion) Say("Error while Downloading. Please try again.") end
    SxScriptUpdate(ToUpdate.Version,ToUpdate.UseHttps, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end


-- Prediction
local SxOrbLoaded, divinePredLoaded, hPredLoaded, SACLoaded, sPredLoaded = false
local SxOrb, HPred, DPred, VP, SPred = nil

-- Lib Updater
local REQUIRED_LIBS = {
	["VPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua"
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


function DeclareVariables() 
 	Spells = {
 				["Passive"] = {stacks = 0, charged = false},
				["Q"] = {name = "Overload", spellname = "RyzeQ", spellname2 = "ryzerq", range = 1000, speed = 1400, radius = 55, delay = 0.25, collision = true, ready = false},
				["W"] = {name = "Rune Prison", spellname = "RyzeW", spellname2 = "ryzerw", range = 600, ready = false},
				["E"] = {name = "Spell Flux", spellname = "RyzeE", spellname2 = "ryzere", range = 600, ready = false},
				["R"] = {name = "Desperate Power", spellname = "RyzeR", ready = false, radius = 200, spellnames = {"ryzerq", "ryzerw", "ryzere"} }
	}

	Cast = {
		["Q"] = os.clock(),
		["W"] = os.clock(),
		["E"] = os.clock(),
		["R"] = os.clock(),
		["General"] = os.clock()
	}

	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}

	minionCollision = true

	--Priority
	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
			},
			
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
			},
			
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed", "Kalista"
			},
			
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
	}

	isAGapcloserUnit = {
                                ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
                                ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, },
                                ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, },
                                ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, },
                                ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
                                ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
                                ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, },
                                ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, },
                                ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, },
                                ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
                                ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
                                ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
                                ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
                                ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, },
                                ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, },
                                ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
                                ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, },
                                ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
                                ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
                                ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
                                ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
                                ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
                                ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, },
                        	}
                        	--]]
	--For AA
	AAdisabled = false

	-- Anti Gap closer
	informationTable = {}
	spellExpired = true

	--MinionManager
	enemyMinions = minionManager(MINION_ENEMY, 600, myHero, MINION_SORT_HEALTH_DEC)

	-- Target
	Qts = TargetSelector(TARGET_LOW_HP, 900, DAMAGE_MAGIC, true)
	ts = TargetSelector(TARGET_LOW_HP, 600, DAMAGE_MAGIC, true)
	Qtarget, target = nil

	-- Initialize main variables
	InitializePredictions()

	-- Specific Prediction stuff
	LoadDivineTargets()
	LoadHPrediction()

end

function LoadDivineTargets()
	if divinePredLoaded then
		lineSS = LineSS(Spells.Q.speed, Spells.Q.range, Spells.Q.radius, (Spells.Q.delay * 1000), 0)
		DPred:bindSS("skillShotQ", lineSS, 1)
	end
end

function LoadHPrediction()
	if hPredLoaded then
		hpSkill = HPSkillshot({type = "DelayLine", delay = Spells.Q.delay, range = Spells.Q.range, speed = Spells.Q.speed, collisionM = true, collisionH = true, width = Spells.Q.radius})
	end
end


function InitializePredictions()
	if divinePredLoaded then
		DPred = assert(DivinePred())
		if not DPred then 
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
		end
	end
	VP = VPrediction()
end

function CheckOrbWalker() 
	if _G.Reborn_Initialised then
		SACLoaded = true 
		Menu.orbwalker:addParam("info", "Detected SAC", SCRIPT_PARAM_INFO, "")
		_G.AutoCarry.Skills:DisableAll()
		Say("SAC Detected.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require("SxOrbWalk")
		SxOrbLoaded = true 
		_G.SxOrb:LoadToMenu(Menu.orbwalker)
		Say("SxOrb Detected.")
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


function OnLoad()
	DeclareVariables()

    Say("loading...")

    DelayAction(function() CheckOrbWalker() end, 10)

    if _G.PerformAutoUpdate then
    	AutoUpdate()
	end

	DrawMenu()
end

-- Checks same with FPS
function OnDraw()
	if Menu.drawings.draw then
		if Menu.drawings.drawQ and Spells.Q.ready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, 0x111111)
		end

		if Menu.drawings.drawW and Spells.W.ready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, 0x111111)
		end

		if Menu.drawings.drawE and Spells.E.ready then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, 0x111111)
		end

	end 
end


function CastQ(target)
	if Spells.Q.ready and target and target.type and GetDistanceSqr(target) <= Spells.Q.range * Spells.Q.range then
		if Menu.human.useHumanizer and (Cast.General > os.clock() or Cast.Q > os.clock()) then return end
		local castPos = PredictQ(target)
		if castPos and GetDistanceSqr(castPos) <= Spells.Q.range * Spells.Q.range then
			CastSpell(_Q, castPos.x, castPos.z)
		elseif not castPos and target.type == "Obj_AI_Minion" then
			CastSpell(_Q, target.x, target.z)
		end
	end
end

function CastW(target)
	if Spells.W.ready and target and target.type and GetDistanceSqr(target) <= Spells.W.range * Spells.W.range then
		if Menu.human.useHumanizer and (Cast.General > os.clock() or Cast.W > os.clock()) then return end
		CastSpell(_W, target)
	end
end

function CastE(target)
	if Spells.E.ready and target and target.type and GetDistanceSqr(target) <= Spells.E.range * Spells.E.range then
		if Menu.human.useHumanizer and (Cast.General > os.clock() or Cast.E > os.clock()) then return end
		CastSpell(_E, target)
	end
end

function OnTick()
	Checks()
	if not Menu.combo.useCombo then CheckAANotCombo() end
	if Menu.combo.useCombo then PerformCombo() end
	if (Menu.harass.harass or Menu.harass.harassToggle) and ManaManager("Harass") then PerformHarass() end
	if Menu.laneclear.laneclear and ManaManager("LaneClear") then PerformLaneClear() end
	if Menu.farm.farm and ManaManager("Farm") then PerformFarm() end
	if Menu.misc.stack.useStack then StackTearPassive() end
end

function OnApplyBuff(source, unit, buff) 
	if source and source.isMe and buff and buff.name and buff.name:find("ryzepassivecharged") then
		Spells.Passive.stacks = 1
		Spells.Passive.charged = true
	end
end

function OnUpdateBuff(unit, buff, stacks)
	if unit and unit.isMe and buff and buff.name and buff.name:find("ryzepassivestack") then
		Spells.Passive.stacks = stacks
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name then
		if buff.name:find("ryzepassivestack") then
			Spells.Passive.stacks = 0
		end
		if buff.name:find("ryzepassivecharged") then
			Spells.Passive.charged = false
		end
	end
end

function CanUseSpell(spell)
	return myHero:CanUseSpell(spell) == READY
end

function Checks()
	Spells.Q.ready = CanUseSpell(_Q)
	Spells.W.ready = CanUseSpell(_W) 
	Spells.E.ready = CanUseSpell(_E) 
	Spells.R.ready = CanUseSpell(_R) 

	enemyMinions:update()
	Qts:update()
	ts:update()

	Qtarget = Qts.target
	target = ts.target

	TargetCheck()
	SpellExpired()
	Collision()
end

function Collision() 
	local changed = false
	if Menu.combo.collision then
		if Spells.Passive.charged and Qtarget and minionCollision then
 			minionCollision = false 
 			changed = true
 		elseif not Spells.Passive.charged and not minionCollision then
 			minionCollision = true
 			changed = true
 		end
 	elseif not Menu.combo.collision and not minionCollision then
 		minionCollision = true
 		changed = true
 	end

 	if changed then
 		if hPredLoaded then
			hpSkill = HPSkillshot({type = "DelayLine", delay = Spells.Q.delay, range = Spells.Q.range, speed = Spells.Q.speed, collisionM = minionCollision, collisionH = minionCollision, width = Spells.Q.radius})
		end
		if divinePredLoaded then
			local intColl = 0
			if not minionCollision then
				intColl = math.huge 
			end
			lineSS = LineSS(Spells.Q.speed, Spells.Q.range, Spells.Q.radius, (Spells.Q.delay * 1000), intColl)
		end
	end
end

function TargetCheck()
	if Qtarget and target then
		if Qtarget ~= target then
			Qtarget = target
		end
	elseif target and not Qtarget then
		Qtarget = target
	end
	if target then
		if target.type then
			if target.type ~= myHero.type then
				target = nil
			end
		else
			target = nil
		end
	end
	if Qtarget then
		if Qtarget.type then
			if Qtarget.type ~= myHero.type then
				Qtarget = nil
			end
		else
			Qtarget = nil
		end
	end

end


-- Draw Menu
function DrawMenu()
	Menu = scriptConfig("Clarity Ryze - Team Clarity", "ClarityProductionsRyze")

	local menuName = "Clarity Ryze - "
	 -- Combo
	Menu:addSubMenu(menuName .. "Combo", "combo")
 	Menu.combo:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo:addParam("useCombo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 	Menu.combo:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo:addParam("useItems", "Item Usage", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo:addParam("disableAA", "Disable AA", SCRIPT_PARAM_LIST, 2, {"Always", "Target not in W range", "Never"})

 		-- Use Q in combo
 	Menu.combo:addSubMenu(Spells.Q.name .. " (Q)", "comboQ")
 	Menu.combo.comboQ:addParam("comboQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)

 		-- Use W in combo
 	Menu.combo:addSubMenu(Spells.W.name .. " (W)", "comboW")
 	Menu.combo.comboW:addParam("comboW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)

 		-- Use E in combo
 	Menu.combo:addSubMenu(Spells.E.name .. " (E)", "comboE")
 	Menu.combo.comboE:addParam("comboE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	
 		-- Use R in combo
 	Menu.combo:addSubMenu(Spells.R.name .. " (R)", "comboR")
 	Menu.combo.comboR:addParam("comboR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo.comboR:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo.comboR:addParam("comboRWay", "Types of Cast", SCRIPT_PARAM_LIST, 3, {"Hit x enemies", "Detonate Passive", "Hit OR Deto", "Hit AND Deto"})
 	Menu.combo.comboR:addParam("comboRCount", "x People to hit", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
 	Menu.combo.comboR:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo.comboR:addParam("checkManaLoops", "Use Below Loops", SCRIPT_PARAM_ONOFF, false)
 	Menu.combo.comboR:addParam("comborLoops", "Min Spells Loops", SCRIPT_PARAM_SLICE, 2, 0, 10, 0)
 	Menu.combo.comboR:addParam("info6", "Enough to mana", SCRIPT_PARAM_INFO, "to loop ALL spells x times")

 		-- Minion collision
 	Menu.combo:addParam("info46", "", SCRIPT_PARAM_INFO, "")
 	Menu.combo:addParam("collision", "Ignore Collision", SCRIPT_PARAM_ONOFF, false)
 	Menu.combo:addParam("info45", "This will ignore", SCRIPT_PARAM_INFO, "collision when passive is up.")

 	 -- Harass
	Menu:addSubMenu(menuName .. "Harass", "harass")
 	Menu.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("harassToggle", "Harrass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)

 	-- Farming
	Menu:addSubMenu(menuName .. "Farming", "farm")
	Menu.farm:addParam("farm", "Use Farm", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
	Menu.farm:addParam("farmQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmAA", "Only farm when AA is on CD", SCRIPT_PARAM_ONOFF, false)

 	-- LaneClear
 	Menu:addSubMenu(menuName .. "LaneClear", "laneclear")
 	Menu.laneclear:addParam("laneclear", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("U"))
 	Menu.laneclear:addParam("laneclearQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addParam("laneclearW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addParam("laneclearE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addSubMenu(Spells.R.name .. " (R)", "r")
 	Menu.laneclear.r:addParam("laneclearR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear.r:addParam("amount", "Amount of minions", SCRIPT_PARAM_SLICE, 1, 0, 20, 0)

 	Menu:addSubMenu(menuName .. "ManaMangers", "manamanagers")
 	Menu.manamanagers:addParam("manaManagerHarass", "Min Mana % to Harass", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)
 	Menu.manamanagers:addParam("manaManagerFarm", "Min Mana % to Farm", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)
 	Menu.manamanagers:addParam("manaManagerLaneClear", "Min Mana % to LaneClear", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)

 	Menu:addSubMenu(menuName .. "Humanizer", "human")
 	Menu.human:addParam("useHumanizer", "Activate Humanizer", SCRIPT_PARAM_ONOFF, false)
 	Menu.human:addParam("delayQ", "Delay between Qs", SCRIPT_PARAM_SLICE, 1.2, 0, 2, 3)
 	Menu.human:addParam("delayW", "Delay between Ws", SCRIPT_PARAM_SLICE, 1.2, 0, 2, 3)
 	Menu.human:addParam("delayE", "Delay between Es", SCRIPT_PARAM_SLICE, 1.2, 0, 2, 3)
 	Menu.human:addParam("delayGeneral", "Delay between spell casts", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 5)
 	Menu.human:addParam("delayRandom", "Randomizer", SCRIPT_PARAM_SLICE, 0.005, 0, 0.01, 5)

 	--Drawings
 	Menu:addSubMenu(menuName .. "Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)

 	Menu:addSubMenu(menuName .. "Prediction", "prediction")
 	if divinePredLoaded and hPredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "HPrediction", "SPrediction"})
 	elseif divinePredLoaded and hPredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "HPrediction"})
 	elseif divinePredLoaded and not hPredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction", "SPrediction"})
 	elseif divinePredLoaded and not hPredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "DivinePrediction"})
 	elseif hPredLoaded and not divinePredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction", "SPrediction"})
 	elseif hPredLoaded and not divinePredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "HPrediction"})
 	elseif not hPredLoaded and not divinePredLoaded and sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction", "SPrediction"})
 	elseif not hPredLoaded and not divinePredLoaded and not sPredLoaded then
 		Menu.prediction:addParam("predictionType", "Prediction", SCRIPT_PARAM_LIST, 1, {"VPrediction"})
 	end

 	--Misc
 	Menu:addSubMenu(menuName .. "Misc", "misc")
 	MenuMisc(Menu.misc, true)

 	Menu.misc:addSubMenu("Stack Tear/Passive", "stack")
 	Menu.misc.stack:addParam("useStack", "Use Stacking", SCRIPT_PARAM_ONOFF, false)
 	Menu.misc.stack:addParam("howStack", "How?", SCRIPT_PARAM_LIST, 1, {"Stack Tear", "Stack Passive", "Stack Tear & Passive"})
 	--Menu.misc.stack:addParam("tearStack", "Min Tear Stack", SCRIPT_PARAM_SLICE, 100, 0, 750, 10)
 	Menu.misc.stack:addParam("manaManager", "Min Mana % to Stack", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)
 	Menu.misc.stack:addParam("info2", "Spell used to stack", SCRIPT_PARAM_INFO, "Q")

 	Menu.misc:addSubMenu("Snare Under Turret", "underTurret")
 	Menu.misc.underTurret:addParam("useUnderTurret", "Use W", SCRIPT_PARAM_ONOFF, false)
 	for _, enemy in pairs(GetEnemyHeroes()) do
 		if enemy and enemy.type and enemy.type == myHero.type then
 			Menu.misc.underTurret:addParam(enemy.charName, "Snare " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
 		end
 	end

 	Menu.misc:addParam("useGapCloser", "Use Anti-GapCloser", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc:addParam("info3", "Spell Used:", SCRIPT_PARAM_INFO, "W")

 	-- OrbWalker
	Menu:addSubMenu(menuName .. "OrbWalker", "orbwalker")

	-- Add TS
	Menu:addTS(ts)

	-- debug
	Menu:addSubMenu(menuName .. "Debug", "debug")
  	Menu.debug:addParam("debug", "Use Debug", SCRIPT_PARAM_ONOFF, false)

	-- Permashow
  	Menu.harass:permaShow("harass")
  	Menu.farm:permaShow("farm")
  	Menu.laneclear:permaShow("laneclear")
  	Menu.drawings:permaShow("draw")

end

function OnProcessSpell(unit, spell)
	if unit and unit.type and unit.type == "obj_AI_Turret" and spell and spell.target then
		OnGainTurretFocus(unit, spell.target)
	end

	if unit and unit.isMe and spell and spell.name then
		if spell.name == Spells.Q.spellname or spell.name == Spells.W.spellname or spell.name == Spells.E.spellname or table.contains(Spells.R.spellnames, spell.name) then
			math.randomseed(os.time())
			math.random(0, Menu.human.delayRandom)
			local delay = math.random(0, Menu.human.delayRandom)
			Cast.General = os.clock() + (Menu.human.delayGeneral + delay)
		end
		if spell.name == Spells.Q.spellname or spell.name == Spells.Q.spellname2 then
			math.randomseed(os.time())
			math.random(0, Menu.human.delayRandom)
			local delay = math.random(0, Menu.human.delayRandom)
			Cast.Q = os.clock() + (Menu.human.delayQ + delay)
		elseif spell.name == Spells.W.spellname or spell.name == Spells.W.spellname2 then
			math.randomseed(os.time())
			math.random(0, Menu.human.delayRandom)
			local delay = math.random(0, Menu.human.delayRandom)
			Cast.W = os.clock() + (Menu.human.delayW + delay)
		elseif spell.name == Spells.E.spellname or Spells.E.spellname2 then
			math.randomseed(os.time())
			math.random(0, Menu.human.delayRandom)
			local delay = math.random(0, Menu.human.delayRandom)
			Cast.E = os.clock() + (Menu.human.delayE + delay)
		end
	end

	--Credits to Haz who got it from Manc
	if Menu.misc.useGapCloser and Spells.W.ready then
        local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q
        isAGapcloserUnit["JarvanIV"]  = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }
        isAGapcloserUnit["Malphite"]     = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms}

    	if unit and unit.type and unit.type == myHero.type and unit.team ~= myHero.team and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
	        if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
	            if spell.target ~= nil and spell.target.isMe or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
	                if Spells.W.ready and GetDistanceSqr(unit) <= Spells.W.range * Spells.W.range then
	                    CastSpell(_W, unit)
	                end
	            else
	                spellExpired = false
	                informationTable = {
						                spellSource = unit,
						                spellCastedTick = GetTickCount(),
						                spellStartPos = Point(spell.startPos.x, spell.startPos.z),
						                spellEndPos = Point(spell.endPos.x, spell.endPos.z),
						                spellRange = isAGapcloserUnit[unit.charName].range,
						                spellSpeed = isAGapcloserUnit[unit.charName].projSpeed
	                      				}
	            end
	        end     
	    end                        
    end
end                    
 

function OnGainTurretFocus(turret, unit)
	if turret and unit and unit.team and unit.team ~= myHero.team and unit.type and unit.type == myHero.type and ValidTarget(unit) and UnderTurret(unit, true) then
		if GetDistanceSqr(unit) <= (Spells.W.range * Spells.W.range) then
			if Menu.misc.underTurret.useUnderTurret then
		 		if Menu.misc.underTurret[unit.charName] then
		 			if Spells.W.ready then
		 				CastSpell(_W, unit)
		 			end
		 		end
		 	end
		end
	end
end

function SpellExpired()
    if Menu.misc.useGapCloser and not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange / informationTable.spellSpeed) * 1000 then
        local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
        local spellStartPosition = informationTable.spellStartPos + spellDirection
        local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
        local heroPosition = Point(myHero.x, myHero.z)
        local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                       
 		if lineSegment:distance(heroPosition) <= 300 and Spells.W.ready and informationTable.spellSource and informationTable.spellSource.type == myHero.type then
            CastSpell(_W, informationTable.spellSource)
        end
 
    else
        spellExpired = true
        informationTable = {}
    end
end

function HasItem(name)
	local item = nil
	for i = 6, 12, 1 do
		local n = myHero:getItem(i)
		if n and n.name and n.name:lower():find(name:lower()) then
			item = n
			break
		end
	end
	return item
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


 function StackTearPassive()
 	if CountEnemyHeroInRange((Spells.Q.range + 600)) == 0 then
 		local tear = HasItem("tearsdummyspell")
 	    local howStack = Menu.misc.stack.howStack
 	    if ManaManager("TearStack") and CheckMinTearStack() and Spells.Q.ready then
			if howStack == 1 then
	 			if tear then
	 				CastSpell(_Q, mousePos.x, mousePos.z)
	 			end
	 		elseif howStack == 2 then
	 			if Spells.Passive.stacks and Spells.Passive.stacks < 4 and not Spells.Passive.charged then
	 				CastSpell(_Q, mousePos.x, mousePos.z)
	 			end
	 		elseif howStack == 3 then
	 			if tear and Spells.Passive.stacks < 4 and not Spells.Passive.charged then
	 				CastSpell(_Q, mousePos.x, mousePos.z)
	 			end
	 		end
	 	end
 	end
 end

 function CheckMinTearStack()
 	--[[
 	local tear = HasItem("name")
 	local result = false
 	if tear and tear.stacks then
 		local stacks = tear.stacks
 		local menuStacks = Menu.misc.stack.tearStack 
 		if stacks >= menuStacks then
 			result = true
 		end
 	end
 	return result
 	--]]
 	return true
 end

 function ManaManager(string, spellTable)
 	local mana = myHero.mana
 	local maxMana = myHero.maxMana
 	if string == "TearStack" then
		if (mana / myHero.maxMana <= Menu.misc.stack.manaManager) then
			return false
		end
		return true 
 	elseif string == "Harass" then
 		if (mana / myHero.maxMana <= Menu.manamanagers.manaManagerHarass) then
			return false
		end
		return true
	elseif string == "Farm" then
		if (mana / myHero.maxMana <= Menu.manamanagers.manaManagerFarm) then
			return false
		end
		return true
	elseif string == "LaneClear" then
		if (mana / myHero.maxMana <= Menu.manamanagers.manaManagerLaneClear) then
			return false
		end
		return true
	else
		return true
 	end
 end

--- Credits to whoever made the UseItems, was too lazy to get the correct item IDS myself ----
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


function PredictQ(targ)
	if targ and targ.type and targ.type == "Obj_AI_Minion" then
		local cP, hitChance = VP:GetLineCastPosition(targ, Spells.Q.delay, Spells.Q.radius, Spells.Q.range, Spells.Q.speed, myHero, minionCollision)
		return cP, hitChance
	end

	local castPos = nil
	-- VPred
	if Menu.prediction.predictionType == 1 then
		local cP, hitChance = VP:GetLineCastPosition(targ, Spells.Q.delay, Spells.Q.radius, Spells.Q.range, Spells.Q.speed, myHero, minionCollision)
		castPos = cP
	-- DivinePred
	elseif divinePredLoaded and Menu.prediction.predictionType == 2 then
		local state, hitPos, perc = DPred:predict("skillShotQ", targ)
		if state == SkillShot.STATUS.SUCCESS_HIT then
			castPos = hitPos
		end
	-- HPred
	elseif (divinePredLoaded and hPredLoaded and Menu.prediction.predictionType == 3) or (hPredLoaded and not divinePredLoaded and Menu.prediction.predictionType == 2) then
		local cP, hitChance = HPred:GetPredict(hpSkill, targ, myHero)
		if hitChance >= 1 then
			castPos = cP
		end
	elseif sPredLoaded and ((divinePredLoaded and hPredLoaded and Menu.prediction.predictionType == 4) or ((divinePredLoaded or hPredLoaded) and Menu.prediction.predictionType == 3) or (not hPredLoaded and not divinePredLoaded and Menu.prediction.predictionType == 2)) then
		local CastPosition, Chance, PredPos = SPred:Predict(targ, Spells.Q.range, Spells.Q.speed, Spells.Q.delay, Spells.Q.radius, minionCollision, myHero)
		if CastPosition and Chance >= 1 then
			castPos = CastPosition
		end
	end
	return castPos
end



function PerformCombo() 
	if target and ValidTarget(target) then

		CheckAA()

		if Menu.combo.useItems then
			UseItems(target)
		end

		if Menu.combo.comboR.comboR and Spells.R.ready then
			CastR()
		end

		if Qtarget and ValidTarget(Qtarget) and Menu.combo.comboQ.comboQ and GetDistanceSqr(Qtarget) <= (Spells.Q.range * Spells.Q.range)  then
			CastQ(Qtarget)
		end

		if Menu.combo.comboW.comboW and Spells.W.ready and GetDistanceSqr(target) <= (Spells.W.range * Spells.W.range) and not (Menu.combo.comboE.comboE and Spells.E.ready and GetDistanceSqr(target) <= (Spells.E.range * Spells.E.range)) then
			CastW(target)
		end

		if Menu.combo.comboE.comboE and Spells.E.ready and GetDistanceSqr(target) <= (Spells.E.range * Spells.E.range) then
			CastE(target)
		end

	end
end

function EnableAA()
	if AAdisabled then
		if SxOrbLoaded then	
			_G.SxOrb:EnableAttacks()
			AAdisabled = false
		elseif SACLoaded then
			_G.AutoCarry.MyHero:AttacksEnabled(true)
			AAdisabled = false
		end
	end
end

function DisableAA()
	if not AAdisabled then
		if SxOrbLoaded then
			_G.SxOrb:DisableAttacks()
			AAdisabled = true
		elseif SACLoaded then
			_G.AutoCarry.MyHero:AttacksEnabled(false)
			AAdisabled = true
		end
	end
end

function CheckAA()
	if not SxOrbLoaded or SACLoaded then return end
	if Menu.combo.disableAA == 1 then
		if target then
			DisableAA()
		else
			EnableAA()
		end
	elseif Menu.combo.disableAA == 2 then
		if target and GetDistanceSqr(target) >= (Spells.W.range * Spells.W.range) and (Spells.W.ready or Spells.E.ready) then
			DisableAA()
		else
			EnableAA()
		end
	elseif Menu.combo.disableAA == 3 then
		EnableAA()
	end
end

function CheckAANotCombo()
	EnableAA()
end

function CastR()
	-- Hit x enemies
	local menuCount = Menu.combo.comboR.comboRCount
	if CheckRLoops() and Spells.R.ready and target then
	 	if Menu.combo.comboR.comboRWay == 1 then
	 		local enemyHeroes = CountEnemyHeroInRange(Spells.R.radius, target)
	 		if menuCount <= (enemyHeroes + 1) then
	 			CastSpell(_R)
	 		end
	 	-- Detonate passive
	 	elseif Menu.combo.comboR.comboRWay == 2 then
	 		if Spells.Passive.stacks == 4 then
	 			CastSpell(_R)
	 		end
	 	-- Both
	 	elseif Menu.combo.comboR.comboRWay == 3 then
	 		local enemyHeroes = CountEnemyHeroInRange(Spells.R.radius, target)
	 		if (enemyHeroes and type(enemyHeroes) == "number" and menuCount <= enemyHeroes) or (Spells.Passive.stacks == 4 or Spells.Passive.charged) then
	 			CastSpell(_R)
	 		end
		elseif Menu.combo.comboR.comboRWay == 4 then
	 		if Spells.Passive.stacks == 4 or Spells.Passive.charged then
		 		local menuCount = Menu.combo.comboR.comboRCount
		 		local enemyHeroes = CountEnemyHeroInRange(Spells.R.radius, target)
		 		if menuCount <= enemyHeroes then
		 			CastSpell(_R)
		 		end
		 	end
	 	end
	 end
end

function CheckRLoops()
	local Qmana = (myHero:GetSpellData(_Q).level and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_Q).mana) or 0
	local Wmana = (myHero:GetSpellData(_W).level and myHero:GetSpellData(_W).level >= 1 and myHero:GetSpellData(_W).mana) or 0
	local Emana = (myHero:GetSpellData(_E).level and myHero:GetSpellData(_E).level >= 1 and myHero:GetSpellData(_E).mana) or 0
	local totalMana = Qmana + Wmana + Emana

	return (Menu.combo.comboR.checkManaLoops and myHero.mana / totalMana >= Menu.combo.comboR.comborLoops) or true
end

function PerformHarass()
	if Qtarget and ValidTarget(Qtarget) then
		if Qtarget and Menu.harass.harassQ and Spells.Q.ready and GetDistanceSqr(Qtarget) <= Spells.Q.range * Spells.Q.range then
			CastQ(Qtarget)
		end
	end

	if target and ValidTarget(target) then
		if Menu.harass.harassW and Spells.W.ready and GetDistanceSqr(target) <= (Spells.W.range * Spells.W.range) and not (Menu.harass.harassE and Spells.E.ready and GetDistanceSqr(target) <= (Spells.E.range * Spells.E.range)) then
			CastW(target)
		end

		if Menu.harass.harassE and Spells.E.ready then
			CastE(target)
		end
	end
end

function SpellsReady()
	local x = 0
	for i, spell in pairs({_Q, _W, _E}) do
		if myHero:CanUseSpell(spell) == READY then
			x = x + 1
		end
	end
	return x > 2
end

function PerformLaneClear()
	local minionCount = 0
	local realMinion = nil

	-- Make sure there is at least one skill available
	if Spells.Q.ready or Spells.W.ready or Spells.E.ready then

		for i, minion in pairs(enemyMinions.objects) do
			local tempCount = 1
			if minion and GetDistance(minion) <= Spells.Q.range then
				for i, newMinion in pairs(enemyMinions.objects) do
					if newMinion and newMinion ~= minion and GetDistance(newMinion, minion) <= Spells.R.radius then
						tempCount = tempCount + 1
					end
				end
				if minionCount <= tempCount then
					minionCount = tempCount
					realMinion = minion
				end
			end
		end


		if Menu.laneclear.r.laneclearR and minionCount >= Menu.laneclear.r.amount then
			if Spells.R.ready and (SpellsReady() or Spells.Passive.charged or Spells.Passive.stacks > 3) then
				CastSpell(_R)
			end
		end

		for i, minion in pairs(enemyMinions.objects) do
			if minion then
				if Menu.laneclear.laneclearQ and Spells.Q.ready then
					local killableMinions = GetKillableMinions(enemyMinions.objects, Spells.Q.range, _Q, myHero)
					if killableMinions ~= nil and type(killableMinions) == "table" and #killableMinions >= 1 then
						for i, killMinion in pairs(killableMinions) do
							if killMinion and Spells.Q.ready and GetDistanceSqr(killMinion) <= Spells.Q.range * Spells.Q.range then
								CastSpell(_Q, killMinion)
								break
							end
						end
					else
						if Spells.Q.ready and GetDistanceSqr(minion) <= Spells.Q.range * Spells.Q.range then
							CastSpell(_Q, minion)
						end
					end
				end
				if Menu.laneclear.laneclearW and Spells.W.ready then
					local killableMinions = GetKillableMinions(enemyMinions.objects, Spells.W.range, _W, myHero)
					if killableMinions ~= nil and type(killableMinions) == "table"  and #killableMinions >= 1 then
						for i, killMinion in pairs(killableMinions) do
							if killMinion and Spells.W.ready and GetDistanceSqr(killMinion) <= Spells.W.range * Spells.W.range then
								CastSpell(_W, killMinion)
								break
							end
						end
					else
						if Spells.W.ready and GetDistanceSqr(minion) <= Spells.W.range * Spells.W.range then
							CastSpell(_W, minion)
						end
					end
				end
				if Menu.laneclear.laneclearE and Spells.E.ready then
					local killableMinions = GetKillableMinions(enemyMinions.objects, Spells.E.range, _E, myHero)
					if killableMinions ~= nil and type(killableMinions) == "table" and #killableMinions >= 1 then
						for i, killMinion in pairs(killableMinions) do
							if killMinion and Spells.E.ready and GetDistanceSqr(killMinion) <= Spells.E.range * Spells.E.range then
								CastSpell(_E, killMinion)
								break
							end
						end
					else
						if Spells.E.ready and GetDistanceSqr(minion) <= Spells.E.range * Spells.E.range then
							CastSpell(_E, minion)
						end
					end
				end
			end
		end
	end

end


function PerformFarm()
	if not orbWalkLoaded then return end
	if Menu.farm.farmAA and (SACLoaded and not _G.AutoCarry.Orbwalker:CanShoot()) then return end
	if Menu.farm.farmAA and (SxOrbLoaded and not _G.SxOrb:CanAttack()) then return end

	for i, minion in pairs(enemyMinions.objects) do
		if minion then
			if Menu.farm.farmQ and Spells.Q.ready and GetDistanceSqr(minion) <= Spells.Q.range * Spells.Q.range then
				if RyzeCalcDamage(_Q, minion) >= minion.health then
					local castPos = PredictQ(minion)
					if castPos then
						CastSpell(_Q, castPos.x, castPos.z)
						break
					end
				end
			end

			if Menu.farm.farmW and Spells.W.ready and GetDistanceSqr(minion) <= Spells.W.range * Spells.W.range then
				if RyzeCalcDamage(_W, minion) >= minion.health then
					CastSpell(_W, minion)
					break
				end
			end

			if Menu.farm.farmE and Spells.E.ready and GetDistanceSqr(minion) <= Spells.E.range * Spells.E.range then
				if RyzeCalcDamage(_E, minion) >= minion.health then
					CastSpell(_E, minion)
					break
				end
			end
		end
	end
end






function RyzeCalcDamage(spell, unit) 
	local level = myHero:GetSpellData(spell).level
	local damage = 0
	if spell == _Q then
		damage = 35 * level + 25 + .55 * myHero.ap + ((1.5 + (level * 0.5)) / 100) * myHero.maxMana
	elseif spell == _W then
		damage = 20 * level + 60 + 0.40 * myHero.ap + 0.025 * myHero.maxMana
	elseif spell == _E then
		damage = 16 * level + 16 + 0.20 * myHero.ap + 0.02 * myHero.maxMana
	end
	damage = myHero:CalcMagicDamage(unit, damage)

	return damage and damage or 0
end










function GetKillableMinions(minionTable, range, spell, source)
	assert(spell == _Q or spell == _W or spell == _E, "TotallyLib: Correct spell not detected")
	assert(minionTable and type(minionTable) == "table", "TotallyLib: Invalid table in: minionTable, first parameter")
	assert(source.type and source.type == myHero.type, "TotallyLib: Invalid Source. The type must be obj_AI_Hero")

	local range = range and range * range or myHero.range * myHero.range
	local minions = {}
	local source = source or myHero
	local dmg = 0
	for i, minion in ipairs(minionTable) do
		if GetDistanceSqr(minion) < range then
			if spell == _AA then
				dmg = myHero:CalcDamage(minion, myHero.totalDamage)
			elseif spell == _Q then
				dmg = RyzeCalcDamage(_Q, minion) 
			elseif spell == _W then
				dmg = RyzeCalcDamage(_W, minion) 
			elseif spell == _E then
				dmg = RyzeCalcDamage(_E, minion) 
			end 
			if dmg == nil then dmg = 0 end
			if minion.health < dmg then
				table.insert(minions, minion)
			end 
		end 
	end 
	return (minions and #minions >= 1 and minions) or nil
end 





-- [[ TotallyLib ]] -- 
class 'MenuMisc'
function MenuMisc:__init(Menu, includeSummoners)

	assert(Menu, "Menu not found. Not able to load the Menu")

 	Menu:addSubMenu("Auto Potions", "autopotions")
 	Menu.autopotions:addParam("usePotion", "Use Potions Automatically", SCRIPT_PARAM_ONOFF, true)
 	Menu.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 0.9, 2)
 	Menu.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 0.9, 2)


	Menu:addSubMenu("Zhyonas", "zhonyas")
 	Menu.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 	Menu.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 , 2)
 	
 	if includeSummoners == true then
		Summoners(Menu)
	end

	self.menu = Menu

	self.isRecalling = false

	AddTickCallback(function() self:OnTick() end)
	AddCreateObjCallback(function(obj) self:OnCreateObj(obj) end)
	AddDeleteObjCallback(function(obj) self:OnDeleteObj(obj) end)
	AddApplyBuffCallback(function(source, unit, buff) self:ApplyBuff(source, unit, buff) end)
	AddRemoveBuffCallback(function(unit, buff) self:RemoveBuff(unit, buff) end)
end 

function MenuMisc:ApplyBuff(source, unit, buff) 
	if source and source.isMe and buff and buff.name then
		if buff.name:find("RegenerationPotion") then
			self.healthActive = true 
		end
		if buff.name:find("FlaskOfCrystalWater") then
			self.manaActive = true 
		end
	end
end

function MenuMisc:RemoveBuff(unit, buff)
	if unit and unit.isMe and buff and buff.name then
		if buff.name:find("RegenerationPotion") then
			self.healthActive = false 
		end
		if buff.name:find("FlaskOfCrystalWater") then
			self.manaActive = false 
		end
	end
end


function MenuMisc:DrinkPotions()
	if not self.healthActive and not self.isRecalling and not InFountain() then
		local healthSlot = GetInventorySlotItem(2003)
		if healthSlot ~= nil then
			if (myHero.health / myHero.maxHealth <= self.menu.autopotions.health) then
				CastSpell(healthSlot)
			end 
		end 
	end
	if not self.manaActive and not self.isRecalling and not InFountain() then
		local manaSlot = GetInventorySlotItem(2004)
		if manaSlot ~= nil then
			if (myHero.mana / myHero.maxMana <= self.menu.autopotions.mana) then
				CastSpell(manaSlot)
			end 
		end 
	end 
end 
  
 function MenuMisc:CheckZhonyas()
 	local zhonyasSlot = GetInventorySlotItem(3157)
 	if zhonyasSlot ~= nil and IsSpellReady(zhonyasSlot) then
		if (myHero.health / myHero.maxHealth) <= self.menu.zhonyas.zhonyasunder then
			CastSpell(zhonyasSlot)
		end 
	end 	
 end 

function MenuMisc:OnCreateObj(obj)
	if obj and obj.valid and obj.name and obj.name:find("TeleportHome.troy") then
		if GetDistance(obj) <= 50 then
			self.isRecalling = true
		end
	end
end

function MenuMisc:OnDeleteObj(obj)
	if obj and obj.valid and obj.name and obj.name:find("TeleportHome.troy") then
		if GetDistance(obj) <= 50 then
			self.isRecalling = false
		end
	end
end

function MenuMisc:OnTick()
	if self.menu.autopotions.usePotion then self:DrinkPotions() end
	if self.menu.zhonyas.zhonyas then self:CheckZhonyas() end 

end




bufflist = {
		["zedulttargetmark"] = {spellname = "Death Mark", spell = "R", charName = "Zed"}, --correct
		["surpression"] = {spellname  = "Infinite Duress", spell = "R", charName = "Warwick"},   -- Only QSS
		["paranoiamisschance"] = {spellname = "Terrify", spell = "Q", charName = "Fiddlestick"}, --correct
		["puncturingtauntarmordebuff"] = {spellname = "Puncturing Taunt", spell = "E", charName = "Rammus"}, --
 		--["Teemo"] = {spellname = "Blinding Dart", spell = "R", charName = "Teemo"}, --
		--["Ahri"] = {spellname = "Charm", spell = "E", charName = "Ahri"}, --
		["curseofthesadmummy"] = {spellname = "Curse of the Sad Mummy", spell = "R", charName = "Amumu"}, --correct
		["enchantedcrystalarrow"] = {spellname = "Enchanted Crystal Arrow", spell = "R", charName = "Ashe"}, --correct
		["Malzahar"] = {spellname = "Nether Grasp", spell = "R", charName = "Malzahar"}, --
		--["Skarner"] = {spellname = "Impale", spell = "R", charName = "Skarner"}, --
		["veigarstun"] = {spellname = "Primordial Burst", spell = "E", charName = "Veigar"}, --correct
		["nasusw"] = {spellname = "Wither", spell = "W", charName = "Nasus"}
	}


class 'Summoners'

function Summoners:__init(menu)

	self.enemyNames = {}

	self:UpdateSummoners()

	if menu then
		self:LoadToMenu(menu)
	end

	AddTickCallback(function() self:OnTick() end)
	AddApplyBuffCallback(function(source, unit, buff) self:OnApplyBuff(source, unit, buff) end)

end 

function Summoners:LoadToMenu(menu)
	self.menu = menu
	if self.heal ~= nil then 
		self.menu:addSubMenu("Auto Heal", "autoheal")
		self.menu.autoheal:addParam("useHeal", "Use Summoner Heal", SCRIPT_PARAM_ONOFF, true)
		self.menu.autoheal:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
		self.menu.autoheal:addParam("helpHeal", "Use Heal to save teammates", SCRIPT_PARAM_ONOFF, false)
	end 

	if self.ignite ~= nil then
		self.menu:addSubMenu("Auto Ignite", "autoignite")
		self.menu.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, true)
		 	for i, enemy in ipairs(GetEnemyHeroes()) do
				self.menu.autoignite:addParam(enemy.charName, "Use Ignite On " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
		 	end 
	end 

	if self.barrier ~= nil then
		self.menu:addSubMenu("Auto Barrier", "autobarrier")
		self.menu.autobarrier:addParam("useBarrier", "Use Summoner Barrier", SCRIPT_PARAM_ONOFF, true)
		self.menu.autobarrier:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
	end 

	if self.cleanse ~= nil then
		self.menu:addSubMenu("Auto Cleanse", "autocleanse")
		self.menu.autocleanse:addParam("useCleanse", "Use Cleanse", SCRIPT_PARAM_ONOFF, true)
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if enemy then
				table.insert(self.enemyNames, enemy.charName)
			end
		end 
		local oneAdded = false
		for buff, data in ipairs(bufflist) do
			if buff and data and table.contains(self.enemyNames, data.charName) then
				oneAdded = true
				self.menu.autocleanse:addParam(buff, data.spellname .. " - " .. data.charName .. " (" .. data.spell .. ")", SCRIPT_PARAM_ONOFF, true)
			end
		end 
		if not oneAdded then
			self.menu.autocleanse:addParam("info", "ERROR", SCRIPT_PARAM_INFO, "No buffs found to be added")
		end 
	end 
end

function Summoners:OnApplyBuff(source, unit, buff)
	if self.cleanse ~= nil and self.menu.autocleanse.useCleanse and self.menu.autocleanse[buff.name] and unit and unit.isMe then
		if IsSpellReady(self.cleanse) then
			CastSpell(self.cleanse)
		end 
	end 
end


function Summoners:UpdateSummoners()
	self.heal = GetSummonerSlot("summonerheal")
   	self.ignite = GetSummonerSlot("summonerdot")
   	self.barrier = GetSummonerSlot("summonerbarrier")
   	self.cleanse = GetSummonerSlot("summonerboost")
end 


function Summoners:UseHeal()
	if IsSpellReady(self.heal) then
		if (myHero.health / myHero.maxHealth) <= self.menu.autoheal.amountOfHealth then
			CastSpell(self.heal)
		end 
	end 

	if self.menu.autoheal.helpHeal then
		for i, teammate in ipairs(GetAllyHeroes()) do
			if GetDistanceSqr(teammate, myHero) <= 700 * 700 then
				if (teammate.health / teammate.maxHealth) <= self.menu.autoheal.amountOfHealth then
					if IsSpellReady(self.heal) then
						CastSpell(self.heal)
					end 
				end 
			end 
		end 
	end
end

function Summoners:Ignite()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistance(enemy, myHero) < 600 and ValidTarget(enemy, 600) and self.menu.autoignite[enemy.charName] then
			if myHero:CanUseSpell(self.ignite) == READY  then
				if enemy.health < self:IgniteDamage() then
					CastSpell(self.ignite, enemy)
				end 
			end 
		end  
	end 
end

function Summoners:IgniteDamage()
	return (50 + (20 * myHero.level))
end


function Summoners:Barrier()
	if myHero:CanUseSpell(self.barrier) == READY then
		if ((myHero.health / myHero.maxHealth) <= self.menu.autobarrier.amountOfHealth) then
			CastSpell(self.barrier)
		end 
	end 
end


function Summoners:OnTick()
	if self.heal ~= nil and self.menu.autoheal.useHeal then self:UseHeal() end
	if self.ignite ~= nil and self.menu.autoignite.useIgnite then self:Ignite() end 
	if self.barrier ~= nil and self.menu.autobarrier.useBarrier then self:Barrier()	end
end

function GetSummonerSlot(name)
	return ((myHero:GetSpellData(SUMMONER_1).name:find(name) and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find(name) and SUMMONER_2))
end

function IsSpellReady(spell)
	return myHero:CanUseSpell(spell) == READY
end


class "SxScriptUpdate"
function SxScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function SxScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function SxScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function SxScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function SxScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function SxScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.0\r\nHost: sx-bol.eu\r\nUser-Agent: hDownload\r\n\r\n")
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') or self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if not self.OnlineVersion then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                if self.OnlineVersion > self.LocalVersion then
                    if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                        self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                    end
                    self:CreateSocket(self.ScriptPath)
                    self.DownloadStatus = 'Connect to Server for ScriptDownload'
                    AddTickCallback(function() self:DownloadUpdate() end)
                else
                    if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                        self.CallbackNoUpdate(self.LocalVersion)
                    end
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function SxScriptUpdate:DownloadUpdate()
    if self.GotSxScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') or self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('<sc'..'ript>')
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.File:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                self.GotSxScriptUpdate = true
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotSxScriptUpdate = true
    end
end