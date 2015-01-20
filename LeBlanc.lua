--[[

		Script coded by: Totally Legit
		Champion: LeBlanc
		Series: Fourth Serie


		Changelog
			* 0.01 (20 Dec)
				Started coding
			* 0.02 (21 Dec)
				Figuring out LeBlancs W tactics by playing her
			* 0.021 (22 Dec)
				Working on full integrated debug
				Fixing bugs
				Adding makings of R technologies and W technologies
			* 0.03 (25 Dec)
				Working on Harass
				Working on Farm
				Got a kinda working smart combo already 
				Got Prod/Vpred and inbuild Pred alrdy :3
			* 0.04 (26 Dec)
				Somehow made it possible for the combo to bugsplat :3
				Made killsteal
				Fixed Prodiction
				Items used in combo
				Added double W in smart combo
			* 0.05 (27 Dec)
				Made Farm complete
				working on laneclear
				BoL down, can't test :(
			* 0.06 (28 Dec)
				Laneclear complete
				Mixed mode complete
				Finished Smart W somehow
					Probs not really Smart, but hey, it's something.
			* 0.07 (29 Dec)
				Killsteal done
				Thinking about autokill, but hmm, so many possibilities to avoid overkill
				Made laneclear and mixed smoother
				R doesn't cast :c
				Killtext (is inaccurate though)
			* 0.08 (30 dec)
				Rewrote some parts
				Suddenly getting huge fps spikes
				Suddenly W won't work
			* 0.09 (31 Dev)
				Smoother smartcombo
				Deleted unneccesary code
				Fixed Kill Text (Should now be accurate)
				Combo works perfectly
				Harass works
				Laneclear works
				Mixed more works
				Farm works
				Smart W return, idk
				Almost ready for release
				Only killsteal that has to be re-checked
				In killText, I'll maybe also add DFG, I'll think about that.
			* 0.1 (1 January)
				Happy New Year!
				Testing last stuff with a headache 
			* 0.2 (5 January)
				Deleted Mixed Mode
				Deleted Potions
				Deleted Health summoner support
				Deleted few other stuff
				Tweaked combination with Orbwalker
				Tweaked Smart W
				Tweaked Smart Combo
				Integration with SxOrbWalk tweaked
			* 0.3 (9 Jan)
				Few more tweaks and optimalizations
			* 0.5 (20 Jan)
				Thanks to Redprince I possibly found the issue of the 'ipairs nil' spam




		Donations:
			Donations are ACCEPTED, but not required. I do this for fun.


--]]


if myHero.charName:lower() ~= "leblanc" then return end

_G.Leblanc_loaded = true

function Say(text)
	print("<font color=\"#FF0000\"><b>Totally LeBlanc:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end
--[[		Auto Update		]]
local version = "0.5"
local author = "Totally Legit"
local SCRIPT_NAME = "LeBlanc"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/LeBlanc.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/LeBlanc.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				Say("New version available "..ServerVersion)
				Say("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () Say("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				Say("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		Say("Error downloading version info")
	end
end

local prodLoaded = false
local SxOrbloaded = false

-- Lib Updater
local REQUIRED_LIBS = {
	["SxOrbWalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
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

-- Prodiction
if VIP_USER and FileExist(LIB_PATH.."Prodiction.lua") then
	require 'Prodiction'
	prodLoaded = true
end 
if FileExist(LIB_PATH.."SxOrbWalk.lua") then
	SxOrbloaded = true
end 



assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQINAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBBkBAAB2AgAAIAACCHwCAAAUAAAAEBgAAAGNsYXNzAAQIAAAAVHJhY2tlcgAEBwAAAF9faW5pdAAECgAAAFVwZGF0ZVdlYgAEGgAAAGNvdW50aW5nSG93TXVjaFVzZXJzSWhhdmUAAgAAAAEAAAADAAAAAQAFCAAAAEwAQADDAIAAAUEAAF1AAAJGgEAApQAAAF1AAAEfAIAAAwAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAAAgAAAAMAAAAAAAQGAAAABQAAAAwAQACDAAAAwUAAAB1AAAIfAIAAAgAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAYAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAAAAAAAAQAAAAUAAABzZWxmAAEAAAAAABAAAABAb2JmdXNjYXRlZC5sdWEACAAAAAEAAAABAAAAAQAAAAEAAAACAAAAAwAAAAIAAAADAAAAAQAAAAUAAABzZWxmAAAAAAAIAAAAAQAAAAUAAABfRU5WAAQAAAALAAAAAwAKIwAAAMYAQAABQQAA3YAAAQaBQABHwcABXQGAAB2BAABMAUECwUEBAAGCAQBdQQACWwAAABeAAYBMwUECwQECAAACAAFBQgIA1kGCA11BgAEXQAGATMFBAsGBAgAAAgABQUICANZBggNdQYABTIFDAsHBAwBdAYEBCMCBhgiAAYYIQIGFTAFEAl1BAAEfAIAAEQAAAAQIAAAAcmVxdWlyZQAEBwAAAHNvY2tldAAEBwAAAGFzc2VydAAEBAAAAHRjcAAECAAAAGNvbm5lY3QABBQAAABtYWlraWU2MS5zaW5uZXJzLmJlAAMAAAAAAABUQAQFAAAAc2VuZAAEKwAAAEdFVCAvdHJhY2tlci9pbmRleC5waHAvdXBkYXRlL2luY3JlYXNlP2lkPQAEKQAAACBIVFRQLzEuMA0KSG9zdDogbWFpa2llNjEuc2lubmVycy5iZQ0KDQoABCsAAABHRVQgL3RyYWNrZXIvaW5kZXgucGhwL3VwZGF0ZS9kZWNyZWFzZT9pZD0ABAIAAABzAAQHAAAAc3RhdHVzAAQIAAAAcGFydGlhbAAECAAAAHJlY2VpdmUABAMAAAAqYQAEBgAAAGNsb3NlAAAAAAABAAAAAAAQAAAAQG9iZnVzY2F0ZWQubHVhACMAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAcAAAAHAAAACAAAAAgAAAAJAAAACQAAAAkAAAAIAAAACQAAAAoAAAAKAAAACwAAAAsAAAALAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAUAAAAFAAAAc2VsZgAAAAAAIwAAAAIAAABhAAAAAAAjAAAAAgAAAGIAAAAAACMAAAACAAAAYwADAAAAIwAAAAIAAABkAAcAAAAjAAAAAQAAAAUAAABfRU5WAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEADQAAAAEAAAABAAAAAQAAAAEAAAADAAAAAQAAAAQAAAALAAAABAAAAAsAAAALAAAACwAAAAsAAAAAAAAAAQAAAAUAAABfRU5WAA=="), nil, "bt", _ENV))()



function DeclareVariables()
	-- Spells 
	Qready, Wready, Eready, Rready = false, false, false, false
	Spells = 	{
					["P"] = {name = "LeBlanc_Base_P_poof.troy"},
					["AA"] = {range = 525, name = "BasicAttack"},
					["Q"] = {name = "Sigil of Malice", spellname = "LeblancChaosOrb", range = 700, speed = 2000, markTimer = 3.5, activated = 0}, 
					["W"] = {name = "Distortion", spellname = "LeblancSlide", range = 600, radius = 250, speed = 2000, delay = 0.25, duration = 4, timeActivated = 0, isActivated = false, startPos = myHero.pos}, 
					["E"] = {name = "Ethereal Chains", spellname = "LeblancSoulShackle", range = 950, speed = 1600, delay = 0.25, radius = 95}, 
					["R"] = {name = "Mimic", spellname = "LeblancMimic", Qname = "LeblancChaosOrbM", Wname = "LeBlancSlideM",  Wreturnname = "leblancslidereturnm", Ename = "LeblancSoulShackleM"},
					["WR"] = {duration = 4, spellname = "LeblancSlideM", timeActivated = 0, isActivated = false, startPos = myHero.pos}
				}
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

	AAdisabled = false
	EnemiesNearW = {}
	EnemiesNearWR = {}
	lastActivated = nil

	-- OrbWalkers
	SACloaded, MMAloaded = false, false

	-- Killsteal
	KillText = {}

	--Libraries
	VP, SxOrb, Prod = nil, nil, nil

	-- Prodiction
	ProdW, ProdE = nil, nil

	-- Summoners
	ignite, heal, barrier, Iready, Hready, Bready = false, false, false, false, false, false

	-- Items
	DFGslot = nil
	ZhonyasSot = nil
	DFGready, ZhyonasReady = false

	-- Clone
	clone = nil
	cloneActive = false

	-- Target settings
	target = nil
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1000)
	exampleTarget = nil

	-- Debug
	lastCheckedW, lastCheckedWR = nil, nil
	lastDebugCombo = os.clock() -- Avoid spam on pressing combo
	lastWDebug = os.clock()
	lastWRDebug = os.clock()


	--MinionManager
	enemyMinions = minionManager(MINION_ENEMY, 600, myHero, MINION_SORT_HEALTH_DEC)

	-- Lag Free
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2


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



end 


function OnLoad()

	DeclareVariables()
			Say("Variables loaded")
		 
	Summoners()
			Say("Summoners loaded")
		 
	SxOrb = SxOrbWalk()
			Say("OrbWalker loaded")
		 
	VP = VPrediction()

	NormalWPred = TargetPrediction(Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.width)
	NormalEPred = TargetPrediction(Spells.E.range, Spells.E.speed, Spells.E.delay, Spells.E.width)

	if prodLoaded then
		Prod = ProdictManager.GetInstance()
		Say("Predictions loaded")
		ProdW = Prod:AddProdictionObject(_W, Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.radius)
		ProdE = Prod:AddProdictionObject(_E, Spells.E.range, Spells.E.speed, Spells.E.delay, Spells.W.radius)   
	end 

	Say("Succesfully Loaded - Please report any bugs on the thread. Give me all information: Keys used, Settings used, Region you're playing on, ...")

	DrawMenu()

	if heroManager.iCount == 10 then
		arrangePrioritys()
		--Say("Arranged Priorities")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
		--Say("Arranged Priorities")
    end

	-- TotallySeries Message
	serverMessage = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/announcements/totallyseries.txt")
	print("<font color=\"#000000\"><b>Totally Series (Latest News):</b></font> <font color=\"#ffaa00\">" .. tostring(serverMessage) .. "</font>")
end

function OnDraw()
	if myHero.dead then return end

	if Menu.drawings.draw then
		if Menu.drawings.drawQ and CanDrawSpell(_Q) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, RGB(255, 102, 102))
		end

		if Menu.drawings.drawW and CanDrawSpell(_W) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, RGB(255, 51, 153))
		end

		if Menu.drawings.drawE and CanDrawSpell(_E) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, RGB(255, 153, 153))
		end

		if Menu.drawings.drawKillable then
			for i = 1, heroManager.iCount do
	 			local enemy = heroManager:getHero(i)
	 			if ValidTarget(enemy) then
	 				local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 35
					local PosY = barPos.y - 50  
					DrawText(KillText[i], Menu.drawings.drawKillableWidth, PosX, PosY, ARGB(255,255,204,0))
				end 
			end 
		end 
	end 
end 

function CanDrawSpell(spell)
	if Menu.drawings.drawSpellReady then
		if spell == _Q then
			if not Qready then
				return false
			end
		elseif spell == _W then
			if not Wready then
				return false
			end
		elseif spell == _E then
			if not Eready then
				return false
			end
		end
	end
	return true
end


function OnTick()
	SpellReadyChecks()
	enemyMinions:update()
	target = GetOrbTarget()

	if Menu.settingsW.useOptional then
		WChecks()
		LeBlancSpecificSpellChecks()
	end 

	CalcDamage()

	if SxOrb:GetMode() == 1 then
		Combo()
	end 

	if Menu.combo.comboAA and SxOrb:GetMode() == 1 then
		if SxOrbLoaded and AAdisabled then
			SxOrb:EnableAttacks()
			AAdisabled = false
		end 
	end 

	if SxOrb:GetMode() == 1 and not Menu.combo.comboAA then
		if not AAdisabled then
			SxOrb:DisableAttacks()
			AAdisabled = true
		end 
	end

	if SxOrb:GetMode() == 2 then
		Harass()
	end 

	if Menu.keysettings.useFarm and not SxOrb:GetMode() == 1 and not SxOrb:GetMode() == 2 and not SxOrb:GetMode() == 3 then
		Farm() 
	end

	if SxOrb:GetMode() == 3 then
		LaneClear()
	end 

	if Menu.killsteal.killsteal and SxOrb:GetMode() == 0 then
		KillSteal()
	end 

	if Menu.misc.zhonyas.zhonyas and not InFountain() then
		Zhonyas()
	end 

	if ignite ~= nil then
		if Menu.misc.autoignite.useIgnite then
			UseIgnite()
		end 
	end 

end

function OnProcessSpell(obj, spell)
    if obj.isMe and spell.name == Spells.W.spellname then
	    Spells.W.startPos = spell.startPos
		   	if Menu.debug.useDebug then
		   		Say("Activated W:")
		   		print(Spells["W"])
		   	end 
    end

    if obj.isMe and spell.name == Spells.WR.spellname then
	    Spells.WR.startPos = spell.startPos
		   	if Menu.debug.useDebug then
		   		Say("Activated W by R: ")
		   		print(Spells["WR"])
		   	end 
	end

    if (obj.isMe and spell.name == Spells.Q.spellname) or (obj.isMe and spell.name == Spells.W.spellname) or (obj.isMe and spell.name == Spells.E.spellname) then
    	lastActivated = spell.name
	    	if Menu.debug.useDebug then
	    		Say("Last casted spell: = " .. lastActivated)
	    	end 
    end 

end

function LeBlancSpecificSpellChecks()
	-- W Activated Settings
		-- W and W by R activated
	if Menu.settingsW.useOptionalW == 1 then
		if wUsed() and wrUsed() then
			if #EnemiesNearWR < #EnemiesNearW and #EnemiesNearWR < CountEnemyHeroInRange(600) then
				if not Qready and not Eready then
					CastSpell(_R)
				end 
			elseif #EnemiesNearW > #EnemiesNearWR and #EnemiesNearW < CountEnemyHeroInRange(600) then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end 
			-- Normal W
		elseif wUsed() then
			if (#EnemiesNearW < CountEnemyHeroInRange(600)) then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end  
			-- W activated by using R
		elseif wrUsed() then
			if #EnemiesNearWR < CountEnemyHeroInRange(600) then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end 
		end 
	elseif Menu.settingsW.useOptionalW == 3 or Menu.settingsW.useOptionalW == 4 then
		if wUsed() and wrUsed() then
			if not Qready and not Eready then
				CastSpell(_W)
			end 
		elseif wUsed() then
			if not Qready and not Eready then
			CastSpell(_W)
			end 
		elseif wrUsed() then
			if not Qready and not Eready then
				CastSpell(_W)
			end 
		end 
	end 
end 

function WChecks()
	if wUsed() then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			local enemyrange = enemy.range and enemy.range * enemy.range or 600 * 600
			if GetDistanceSqr(enemy, Spells.W.startPos) < enemyrange and not table.contains(EnemiesNearW, enemy) then
				table.insert(EnemiesNearW, enemy)
			end 
			if GetDistanceSqr(enemy, Spells.W.startPos) > enemyrange then
				if table.contains(EnemiesNearW, enemy) then
					table.remove(EnemiesNearW, i)
				end 
			end 
		end 
	end
	if wrUsed() then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			local enemyrange = enemy.range and enemy.range * enemy.range or 600
			if GetDistanceSqr(enemy, Spells.WR.startPos) < enemyrange and not table.contains(EnemiesNearWR, enemy) then
				table.insert(EnemiesNearWR, enemy)
			end 
			if GetDistanceSqr(enemy, Spells.WR.startPos) > enemyrange then
				table.remove(EnemiesNearWR, i)
			end 
		end 
	end
	if not wUsed() and #EnemiesNearW >= 1 then
		for i, _ in ipairs(EnemiesNearW) do
			table.remove(EnemiesNearW, i)
		end 
	end 
	if not wrUsed() and #EnemiesNearWR then
		for i, _ in ipairs(EnemiesNearWR) do
			table.remove(EnemiesNearWR, i)
		end 
	end 
end


function Combo()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target, 600) then

		exampleTarget = target

			if Menu.debug.useDebug and lastDebugCombo + 2 < os.clock() then
				Say("Target: " .. target.charName)
				lastDebugCombo = os.clock()
		    end 

		if Menu.combo.comboItems then
			UseItems(target)
		end 
		---------------- Smart Combo --------------
		if Menu.combo.comboWay == 1 then
			combo = SmartCombo(target)
		----------------- QRWE ------------------------
		elseif Menu.combo.comboWay == 2 then
			combo = {_Q}
			DelayAction(function(target) combo = {_R, _W, _E} PerformCombo(combo, target) end, 0.5, {target})
		---------------- QWRE -----------------------
		elseif Menu.combo.comboWay == 3 then
			combo = {_Q, _W}
			DelayAction(function(target) combo = {_R, _E} PerformCombo(combo, target) end, 0.5, {target})
		------------------ WQRE ----------------------
		elseif Menu.combo.comboWay == 4 then
			combo = {_W, _Q}
			DelayAction(function(target) combo = {_R, _E} PerformCombo(combo, target) end, 0.5, {target})
		------------------- WRQE --------------------
		elseif Menu.combo.comboWay == 5 then
			combo = {_W}	
			DelayAction(function(target) combo = {_R, _Q, _E} PerformCombo(combo, target) end, 0.5, {target})
		end 

		PerformCombo(combo, target)

		-- Return to basic W if target is dead during combo
		if exampleTarget and exampleTarget.dead and wUsed() and Menu.settingsW.useOptional and (Menu.settingsW.useOptionalW == 2 or Menu.settingsW.useOptionalW == 4) then
			CastSpell(_W)
		end 

		exampleTarget = nil

	end 
end 


-- Harass (In progress)
function Harass()
	local castedW = false
	
	if target ~= nil and ValidTarget(target) and ManaManager() then
			if Menu.debug.useDebug then
		    	Say("Performing harass on: " .. target.charName)
		  	end
		if Menu.harass.harassQ then
			CastQ(target) 
		end 
		if Menu.harass.harassW then
			if CastW(target) then castedW = true end
		end 
		if Menu.harass.harassE then
			CastE(target)
		end 
		if castedW == true and wUsed() then CastSpell(_W) end
	end 
end 


-- In Progress
function Farm()
	local hasCasted = false

	if Menu.farm.farmAA and SxOrb:CanAttack() == true then return end

	if Menu.farm.farmQ then
		for i, minion in ipairs(enemyMinions.objects) do
			if Menu.farm.farmRange and GetDistanceSqr(minion) < Spells.AA.range * Spells.AA.range and GetDistanceSqe(minion) < Spells.Q.range * Spells.Q.range then
				if getDmg("Q", minion, myHero) > minion.health then
					if CastQ(minion, false) then hasCasted = true end 
				end 
				if hasCasted == true then break end 
			end 
			if not Menu.farm.farmRange and GetDistanceSqr(minion) < Spells.Q.range * Spells.Q.range then
				if getDmg("Q", minion, myHero) > minion.health then
					if CastQ(minion, false) then hasCasted = true end 
					if hasCasted then CastSpell(_W) end
				end 
				if hasCasted == true then break end 
			end 
		end 
	end 
	if hasCasted then return end 
	if Menu.farm.farmW then
		for i, minion in ipairs(enemyMinions.objects) do
			if Menu.farm.farmRange and GetDistanceSqr(minion) < Spells.AA.range * Spells.AA.range and GetDistanceSqr(minion) < Spells.W.range * Spells.W.range then
				if getDmg("W", minion, myHero) > minion.health then
					if CastW(minion, false) then 
						CastSpell(_W)
						hasCasted = true
						break
						return
					end 
				end
			end 
			if not Menu.farm.farmRange and GetDistanceSqr(minion) < Spells.W.range * Spells.W.range then
				if Wready and getDmg("W", minion, myHero) > minion.health then
					if CastW(minion, false) then
						CastSpell(_W)
						hasCasted = true
						break
					end
				end
			end 
		end  
	end
	if hasCasted then return end 
end 

function LaneClear()
	if Menu.laneclear.laneclearQ then
		for i, minion in ipairs(enemyMinions.objects) do
			if GetDistanceSqr(minion) < Spells.Q.range * Spells.Q.range then
				CastSpell(_Q, minion)
				break
			end 
		end
	end 
	if Menu.laneclear.laneclearW and Menu.laneclear.laneclearR and Rready and Wready then 
		if not wUsed() and not wrUsed() then
			local castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if castPosition ~= nil then
				CastSpell(_R, castPosition.x, castPosition.z)
			end

			castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if castPosition ~= nil then
				CastSpell(_W, castPosition.x, castPosition.z)
			end 
 
		end
		if wUsed() then
			CastSpell(_W)
		end 

	elseif Menu.laneclear.laneclearW and Wready then
		local castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
		if castPosition ~= nil then
			CastSpell(_W, castPosition.x, castPosition.z)
			CastSpell(_W) 
		end  

	elseif Menu.laneclear.laneclearR and Rready then
		local castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
		if castPosition ~= nil then
			CastSpell(_R, castPosition.x, castPosition.z)
			CastSpell(_R) 
		end 
	end 
end

function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do 
		if ValidTarget(enemy, 600) and not enemy.dead and enemy.visible and Menu.killsteal.enemies[enemy.charName] then
			local Qdmg = ((Qready and Menu.killsteal.killstealQ and SpellDmgCalculations("Q", enemy)) or 0)
			local RQdmg = ((Rready and lastActivated == Spells.Q.spellname and SpellDmgCalculations("RQ", enemy)) or 0)
			local QdmgMark = (((Qready or Rready) and (Menu.killsteal.killstealQ or Menu.killsteal.killstealR) and SpellDmgCalculations("QProc", enemy)) or 0)
			local Wdmg = ((Wready and Menu.killsteal.killstealW and SpellDmgCalculations("W", enemy)) or 0)
			local RWdmg = ((Rready and Menu.killsteal.killstealR and not wrUsed() and lastActivated == Spells.W.spellname and SpellDmgCalculations("RW", enemy)) or 0)
			local Edmg = ((Eready and Menu.killsteal.killstealE and SpellDmgCalculations("E", enemy)) or 0)
			if Qdmg > Wdmg and Wdmg > enemy.health then
				CastW(enemy)
						if Menu.debug.useDebug then
							Say("Entered FIRST entry of Killsteal on " .. tostring(enemy.charName):upper())
						end 
			elseif Qdmg > enemy.health then
				CastQ(enemy)
						if Menu.debug.useDebug then
							Say("Entered SECOND entry of Killsteal on " .. tostring(enemy.charName):upper())
						end 
			elseif ECast ~= nil and Edmg > enemy.health then
				CastE(enemy)
						if Menu.debug.useDebug then
							Say("Entered THIRD entry of Killsteal on " .. tostring(enemy.charName):upper())
						end
			elseif RQdmg > RWdmg and RWdmg > enemy.health then
				CastR(enemy, _W)
			elseif RQdmg > enemy.health then
				CastR(enemy, _Q)
			end 
		end 
	end 
end 

-- Obtain a target
function GetOrbTarget()
	ts:update()
	if SxOrbloaded then return SxOrb:GetTarget(1300) end 
	return ts.target
end 

-- Zhonyas settings: Will be updated and improved
function Zhonyas()
	local zSlot = GetInventorySlotItem(3157)
	if zSlot ~= nil and myHero:CanUseSpell(zSlot) == READY then
		if (myHero.health / myHero.maxHealth) <= Menu.misc.zhonyas.zhonyasunder then
			CastSpell(zSlot)
		end 
	end 
end


function UseIgnite()
	local iDmg = (50 + (20 * myHero.level))
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistance(enemy, myHero) < 600 and ValidTarget(enemy, 600) and Menu.misc.autoignite[enemy.charName] then
			if Iready then
				if enemy.health < iDmg then
					CastSpell(ignite, enemy)
				end 
			end 
		end  
	end 
end 

function ManaManager()
	if ((myHero.mana / myHero.maxMana) <= Menu.harass.harassMana) then
		return false
	end
	return true 
end 


function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end
 
function arrangePrioritys()
    for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 2)
		SetPriority(priorityTable.Support,  enemy, 3)
		SetPriority(priorityTable.Bruiser,  enemy, 4)
		SetPriority(priorityTable.Tank,     enemy, 5)
    end
end

function arrangePrioritysTT()
    for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 1)
		SetPriority(priorityTable.Support,  enemy, 2)
		SetPriority(priorityTable.Bruiser,  enemy, 2)
		SetPriority(priorityTable.Tank,     enemy, 3)
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

function CalcDamage()
	for i = 1, heroManager.iCount do
		local enemy = heroManager:getHero(i)
		if ValidTarget(enemy) then
			local Qdmg = ((Qready and SpellDmgCalculations("Q", enemy)) or 0)
			local RQdmg = ((Qready and lastActivated == Spells.Q.spellname and SpellDmgCalculations("RQ", enemy)) or 0)
			local QdmgMark = (((Qready or Rready) and SpellDmgCalculations("QProc", enemy)) or 0)
			local Wdmg = ((Wready and SpellDmgCalculations("W", enemy)) or 0)
			local RWdmg = ((Rready and not wrUsed() and lastActivated == Spells.W.spellname and SpellDmgCalculations("RW", enemy)) or 0)
			local Edmg = ((Eready and SpellDmgCalculations("E", enemy)) or 0)
			local iDmg = ((Iready and (50 + (20 * myHero.level))) or 0)

			if myHero.damage > enemy.health then
				KillText[i] = "MURDER HIM"
			elseif Wdmg > Qdmg and Qdmg > enemy.health then
				KillText[i] = "Q = kill"
			elseif Wdmg > enemy.health then
				KillText[i] = "W = kill"
			elseif Edmg > enemy.health then
				KillText[i] = "E = kill"
			elseif Qdmg + iDmg > enemy.health then
				KillText[i] = "Q + Igite = kill"
			elseif Wdmg + iDmg > enemy.health then
				KillText[i] = "W + Igite = kill"
			elseif Qdmg + QdmgMark + Wdmg > enemy.health then
				KillText[i] = "Q + W = kill"
			elseif Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + E = kill"
			elseif Qdmg + RQdmg + QdmgMark > enemy.health then
				KillText[i] = "Q + R = kill" 
			elseif Wdmg + RWdmg > enemy.health then
				KillText[i] = "W + R = kill"
			elseif Qdmg + RQdmg + QdmgMark + iDmg > enemy.health then
				KillText[i] = "Q + R + Ignite = kill" 
			elseif Qdmg + QdmgMark + Wdmg + RWdmg > enemy.health then
				KillText[i] = "Q + W + R = kill"
			elseif Qdmg + RQdmg + QdmgMark + QdmgMark + Wdmg > enemy.health then
				KillText[i] = "Q + R + W = kill"
			elseif Qdmg + RQdmg + QdmgMark + QdmgMark + Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + R + W + E = kill"
			elseif Qdmg + QdmgMark + Wdmg + RWdmg + Edmg > enemy.health then
				KillText[i] = "Q + W + R + E = kill"
			elseif Qready or Wready or Eready then
				KillText[i] = "Harass him!"
			else
				KillText[i] = "Spells on CD"
			end 
		end 
	end 
end 

function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end


function DrawMenu()

	Menu = scriptConfig("Totally LeBlanc by Nickieboy", "TotallyLeBlanc.cfg")
	local name = "Totally LeBlanc  -  "

	-- KeySettings
	Menu:addSubMenu(name .. "Key Settings", "keysettings")
 	Menu.keysettings:addParam("useCombo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 	Menu.keysettings:addParam("useHarass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.keysettings:addParam("useLaneclear", "LaneClear Key", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("L"))
 	Menu.keysettings:addParam("useLastHit", "LastHit Key", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("X"))
 	Menu.keysettings:addParam("useFarm", "Farm Key", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
 	SxOrb:RegisterHotKey('fight',     Menu.keysettings, 'useCombo')
	SxOrb:RegisterHotKey('harass',    Menu.keysettings, 'useHarass')
	SxOrb:RegisterHotKey('laneclear', Menu.keysettings, 'useLaneclear')
	SxOrb:RegisterHotKey('lasthit',   Menu.keysettings, 'useLastHit')

	-- Combo
	Menu:addSubMenu(name .. "Combo", "combo")
	Menu.combo:addParam("comboWay", "Perform Combo:", SCRIPT_PARAM_LIST, 1, {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"})
	Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboAA", "Use AAs", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboGap", "Use W to GapClose", SCRIPT_PARAM_ONOFF, true)

	-- W Settings
	Menu:addSubMenu(name .. "Settings: W", "settingsW")
	Menu.settingsW:addParam("useOptional", "Use Optional W Settings", SCRIPT_PARAM_ONOFF, true)
	Menu.settingsW:addParam("useOptionalW", "Return: ", SCRIPT_PARAM_LIST, 1, {"Smart", "Target dead", "Skills used", "Both"})

	 -- Harass
	Menu:addSubMenu(name .. "Harass", "harass")
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassMana", "Mana Manager %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

	-- Farming
	Menu:addSubMenu(name .. "Farming", "farm")
	Menu.farm:addParam("farmQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmRange", "Minions outside AA range only", SCRIPT_PARAM_ONOFF, false)
	Menu.farm:addParam("farmAA", "Farm if AA is on CD", SCRIPT_PARAM_ONOFF, false)

	-- LaneClear
	Menu:addSubMenu(name .. "Laneclear", "laneclear")
	Menu.laneclear:addParam("laneclearQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.laneclear:addParam("laneclearW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.laneclear:addParam("laneclearR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)

 	 -- Killsteal
	Menu:addSubMenu(name .. "KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addSubMenu("KillSteal Enemy", "enemies")
 	for i, enemy in ipairs(GetEnemyHeroes()) do
 		if table.contains(priorityTable.Support, enemy.charName) or table.contains(priorityTable.AD_Carry, enemy.charName) or table.contains(priorityTable.AP, enemy.charName) then
			Menu.killsteal.enemies:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, true)
		else
			Menu.killsteal.enemies:addParam(enemy.charName, enemy.charName, SCRIPT_PARAM_ONOFF, false)
		end 
 	end 

 	--Drawings
 	Menu:addSubMenu(name .. "Drawings", "drawings")

 	Menu.drawings:addSubMenu("Lag-Free Circles", "lfc")
 	Menu.drawings.lfc:addParam("useLFC", "Use Lag-Free Circles", SCRIPT_PARAM_ONOFF, false)
 	Menu.drawings.lfc:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 300, 75, 2000, 0)

 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawKillable", "Draw Killable Text", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawKillableWidth", "Draw Killable Width", SCRIPT_PARAM_SLICE, 10, 5, 20, 0)
 	Menu.drawings:addParam("drawSpellReady", "Don't draw if spell is CD", SCRIPT_PARAM_ONOFF, false)

 	Menu:addSubMenu(name .. "Prediction", "prediction")
 	if prodLoaded then
 		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "Prodiction"})
 	else
 		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction"})
 	end 

 	--Misc
 	Menu:addSubMenu(name .. "Misc", "misc")

	if ignite ~= nil then
		Menu.misc:addSubMenu("Auto Ignite", "autoignite")
		Menu.misc.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, true)
		 	for i, enemy in ipairs(GetEnemyHeroes()) do
				Menu.misc.autoignite:addParam(enemy.charName, "Use Ignite On " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
		 	end 
	end 

	Menu.misc:addSubMenu("Zhyonas", "zhonyas")
 	Menu.misc.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)

	--Orbwalker
	Menu:addSubMenu(name .. "OrbWalker", "orbwalker")
	SxOrb:LoadToMenu(Menu.orbwalker, true)

	Menu:addSubMenu(name .. "Debug", "debug")
	Menu.debug:addParam("useDebug", "Developer: Debug", SCRIPT_PARAM_ONOFF, false)

	Menu:addParam("info2", "Author", SCRIPT_PARAM_INFO, author)
	Menu:addParam("info", "Version", SCRIPT_PARAM_INFO, version)

	 -- Always show
	 Menu.keysettings:permaShow("useCombo")
	 Menu.keysettings:permaShow("useHarass")
	 Menu.keysettings:permaShow("useLaneclear")
	 Menu.keysettings:permaShow("useLastHit")
	 Menu.keysettings:permaShow("useFarm")
	 Menu.killsteal:permaShow("killsteal")
	 Menu.drawings:permaShow("draw")
end 



function Summoners()
	heal = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") and SUMMONER_2))
   	ignite = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2))
   	barrier = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerbarrier") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerbarrier") and SUMMONER_2))
   	flash = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") and SUMMONER_2))
end 

function SpellReadyChecks()
	Qready = myHero:CanUseSpell(_Q) == READY
	Wready = myHero:CanUseSpell(_W) == READY
	Eready = myHero:CanUseSpell(_E) == READY
	Rready = myHero:CanUseSpell(_R) == READY
	Hready = (heal ~= nil and myHero:CanUseSpell(heal) == READY)
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

	-- Lag Free Circles
	if Menu.drawings.lfc.useLFC then 
		_G.DrawCircle = DrawCircle2
	else
		_G.DrawCircle = _G.oldDrawCircle 
	end

end 
 

function ReturnBestTargetPosition(min_targets, ra)
	local count, enemies, pos = 0, {}, nil
	local range = (ra and ra * ra) or (myHero.range * myHero.range)

	for i, enemy in ipairs(GetEnemyHeroes()) do
		if GetDistanceSqr(enemy, myHero) <= range then
			enemies = {}
			table.insert(enemies, enemy.charName)
			count = 0
			for i, Tenemy in ipairs(GetEnemyHeroes()) do
				if enemy ~= Tenemy then
					if GetDistance(Tenemy, enemy) < Spells.W.radius then
						count = count + 1
						table.insert(enemies, Tenemy.charName)
					end 
				end 
			end

			if count >= min_targets then
				pos = enemy.pos
				break
			end
		end 
	end 
	return pos, enemies, count
end

-- Self made AOE
function GetBestAOEPosition(objects, range, radius, source)
	assert(objects and type(objects) == "table", "Totally LeBlanc: Invalid Objects in function GetBestAOEPosition")
	local pos = nil 
	local count2 = 0
	local source = source or myHero
	local range = (range and range * range) or myHero

	for i, object in ipairs(objects) do
		if GetDistanceSqr(object, source) < range then
			local count = 0
			for i, ob in ipairs(objects) do
				if GetDistanceSqr(ob, object) <= radius * radius then
					count = count + 1
				end 
			end 
			if count > count2 then
				count2 = count
				pos = object.pos
			end 
		end
	end 

	return pos, count2
end 

function GetKillableMinions(minionTable, range, spell, source)
	assert(spell == _Q or spell == _W or spell == _E, "Totally LeBlanc: Correct spell not detected")
	assert(minionTable and type(minionTable) == "table", "Totally LeBlanc: Invalid table in: minionTable, first parameter")
	local range = range and range * range or myHero
	local minions = {}
	local source = source or myHero
	local dmg = 0
	for i, minion in ipairs(minionTable) do
		if GetDistanceSqr(minion) < range then
			if spell == _Q then
				dmg = getDmg("Q", minion, source)
			end 
			if spell == _W then
				dmg = getDmg("W", minion, source)
			end 
			if spell == _E then
				dmg = getDmg("E", minion, source)
			end 
			if minion.health < dmg then
				table.insert(minions, minion)
			end 
		end 
	end 
	return minions
end 

-- Return number of Ally in range
function AllyHeroInRange(range, object)
    object = object or myHero
    range = range and range * range or myHero.range * myHero.range
    local AllyHeroInRange = 0
    for i = 1, heroManager.iCount, 1 do
        local hero = heroManager:getHero(i)
        if hero.team == object.team and GetDistanceSqr(object, hero) <= range then
            AllyHeroInRange = AllyHeroInRange + 1
        end
    end
    return AllyHeroInRange
end


function GetWPrediction(target)
	if Menu.prediction.usePrediction == 1 then
		WCast = NormalWPred:GetPrediction(target)
		return WCast
	-- VPrediction
	elseif Menu.prediction.usePrediction == 2 then
		WCast = VP:GetCircularCastPosition(target, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)
		return WCast
	-- Prodiction
	elseif prodLoaded and Menu.prediction.usePrediction == 3 then
		WCast = ProdW:GetPrediction(target)
		return WCast
	end
end

function GetEPrediction(target)
	-- Normal Prediction
	if Menu.prediction.usePrediction == 1 then
		local castPosE, collE, healthE = NormalEPred:GetPrediction(target)
		if not collE then
			ECast = castPosE
		end 
		return ECast
	-- VPrediction
	elseif Menu.prediction.usePrediction == 2 then
		local ECast, hitchance = VP:GetLineCastPosition(target, Spells.E.delay, Spells.E.radius, Spells.E.range, Spells.E.speed, myHero, true)	
		if hitchance >= 2 then	
			return ECast
		end 
	-- Prodiction
	elseif prodLoaded and Menu.prediction.usePrediction == 3 then
		local ECast, info = ProdE:GetPrediction(target)
		if not info.mCollision() then
			return ECast
		end 		
	end
end

function PerformCombo(comboTable, target)
	if not comboTable and not type(comboTable) == "table" then return end

	for i, spell in ipairs(comboTable) do
		if spell == _Q then
			CastQ(target, false)
		elseif spell == _W then
			CastW(target, false)
		elseif spell == _E then
			CastE(target, false)
		elseif spell == _R then
			CastR(target)
		end 
	end 
end 

function CastQ(target, castedByR)
	local castedByR = ((castedByR and castedByR == true and Rready) or nil)
	if target ~= nil and not target.dead and GetDistanceSqr(target) <= Spells.Q.range * Spells.Q.range and target.type == myHero.type or target.type == "obj_AI_Minion" then
		if castedByR then
			CastSpell(_R, target)
			return true
		else
			if Qready then
				CastSpell(_Q, target)
				return true
			end 
		end 
	end 
end 

function CastW(target, castedByR)
	local WRangeRadius = Spells.W.range + 100
	local WRangeRadiusSqr = WRangeRadius * WRangeRadius
	local castedByR = (castedByR and castedByR == true and Rready and not wrUsed()) or nil
	if not target.dead and GetDistanceSqr(target) <= WRangeRadiusSqr then
		if target.type == myHero.type then
			if castedByR then
				local castPosition, hitChance = GetWPrediction(target)
				if castPosition ~= nil then
					CastSpell(_R, castPosition.x, castPosition.z)
					return true
				end
			else 
				 if Wready and not wUsed() then
					local castPosition, hitChance = GetWPrediction(target)
					if castPosition ~= nil then
						CastSpell(_W, castPosition.x, castPosition.z)
						return true
					end 
				end 
			end 
		elseif target.type == "obj_AI_Minion" then
			if castedByR then
				CastSpell(_R, target.pos.x, target.pos.z)
				return true
			else
				CastSpell(_W, target.pos.x, target.pos.z)
				return true
			end 
		end 
	end
	return false 
end 

function GapClose(spell, range, target)
	local range = range and range  or myHero.range

	if spell == _W then
		local newPos = Vector(myHero.visionPos) + (Vector(target) - myHero.visionPos):normalized() * range

		if not isWall(D3DXVECTOR3(newPos.x, newPos.y, newPos.z)) and not UnderTurret(newPos, true) then
			CastSpell(_W, newPos.x, newPos.z)
			return true
		end
	end

	return false

end 

function CastE(target, castedByR)
	local castedByR = (castedByR and castedByR == true and Rready) or nil
	if not target.dead and GetDistanceSqr(target) <= Spells.E.range * Spells.E.range and target.type == myHero.type or target.type == "obj_AI_Minion" then
		if castedByR then
			local castPosition = GetEPrediction(target)
			if castPosition ~= nil then
				CastSpell(_R, castPosition.x, castPosition.z)
				return true
			end
		else
			if Eready then
				local castPosition = GetEPrediction(target)
				if castPosition ~= nil then
					CastSpell(_E, castPosition.x, castPosition.z)
					return true
				end 
			end 
		end 
		return false
	end 
	return false
end 

function CastR(target, castOnly)

	if castOnly then
		if castOnly == _Q and not target.dead then
			if lastActivated == Spells.Q.spellname then
				if CastQ(target, true) then return true end 
			end 
		elseif castOnly == _W and not target.dead then
			if lastActivated == Spells.Q.spellname then
				if CastW(target, true) then return true end 
			end 
		end 
		return false
	else 
		if not target.dead then
			if lastActivated == Spells.Q.spellname then
				if CastQ(target, true) then return true end 
			elseif lastActivated == Spells.W.spellname then
				if CastW(target, true) then return true end 
			end
		end 
	end 
	return false
end

function wUsed()
	if myHero:GetSpellData(_W).name == "leblancslidereturn" then
					if Menu.debug.useDebug and lastWDebug + 1 < os.clock() then
						Say("Seems like W has been USED")
						lastWDebug = os.clock()
					end
		return true
	end 
	return false
end
function wrUsed()
	if myHero:GetSpellData(_R).name == "leblancslidereturnm" then
				if Menu.debug.useDebug and lastWRDebug + 1 < os.clock() then
					Say("Seems like WR has been USED")
					lastWRDebug = os.clock()
				end
		return true
	end 
	return false
end 


--- Smart Combo
function SmartCombo(targ)
	-- Damage to calculate best combo
	local Qdmg = SpellDmgCalculations("Q", targ) 
	local QMarkProcDamage = SpellDmgCalculations("QProc", targ) 
	local Wdmg = SpellDmgCalculations("W", targ) 
	local Edmg = SpellDmgCalculations("E", targ) 
	local RQdmg = SpellDmgCalculations("RQ", targ)  
	local RWdmg = SpellDmgCalculations("RW", targ)  
	local combo = {}
	local distanceTo = GetDistanceSqr(targ)

	-- Possible W targets
	local pos, enemies, count = ReturnBestTargetPosition(3, Spells.W.range)


	if pos ~= nil and enemies ~= nil and GetDistanceSqr(pos) < Spells.W.range * Spells.W.range then
		if useW and useR and not wUsed() and not wrUsed() then
			local count2 = 0
			-- Looping through AP table to find match
			for i, name in ipairs(priorityTable.AP) do
				if table.contains(enemies, name) then
					count2 = count2 + 1
				end 
			end
			-- Looping through AD table to find a match
			for i, name in ipairs(priorityTable.AD_Carry) do
				if table.contains(enemies, name) then
					count2 = count2 + 1
				end 
			end 
					-- Debug settings
					if Menu.debug.useDebug then
						Say("Found " .. count .. " perfect W targets")
					end 

			if count2 >= 3 then
				CastSpell(_W, pos.x, pos.z)
				CastSpell(_R, pos.x, pos.z)
					if Menu.debug.useDebug then
						Say("Performing double W on mid laners/ad carries for perfect TEAMFIGHT")
					end
			end 
		end 
	end
				if Menu.debug.useDebug then
					Say("Damage 1: " .. (Qdmg + RQdmg + QMarkProcDamage + QMarkProcDamage + Wdmg))
					Say("Damage 2: " .. (Wdmg + RWdmg + Qdmg))
				end
	-- Actual combo
	if Qready and (Wready and not wUsed()) and Rready and (Qdmg + RQdmg + QMarkProcDamage + QMarkProcDamage + Wdmg) >= (Wdmg + RWdmg + Qdmg) and distanceTo < Spells.Q.range * Spells.Q.range then
				if Menu.debug.useDebug then
					Say("Entered FIRST entry of smart combo")
				end
		combo = {_Q, _R, _W, _E}
		return combo
	elseif Qready and Rready and Wready and distanceTo < Spells.Q.range * Spells.Q.range then
				if Menu.debug.useDebug then
					Say("Entered SECOND entry of smart combo")
				end
		combo = {_Q, _W, _R, _E}
		return combo
	elseif distanceTo < Spells.E.range * Spells.E.range and distanceTo > Spells.Q.range * Spells.Q.range then
			if Menu.debug.useDebug then
				Say("Entered THIRD entry of smart combo")
			end

		combo = {_E, _W, _Q, _R}

		return combo

	elseif Menu.combo.comboGap and distanceTo > Spells.E.range * Spells.E.range and GetDistance(targ) < (Spells.Q.range + Spells.W.range) then

		if not wUsed() then
			if GapClose(_W, Spells.W.range, targ) then
				combo = {_E, _Q, _R}
						if Menu.debug.useDebug then
							Say("Entered FOURTH entry of smart combo")
						end
			else 
				combo = {_Q, _R, _W, _E} 
			end
			return combo
		end 
	else 
		combo = {_Q, _R, _W, _E}
					if Menu.debug.useDebug then
						Say("Entered FIFTH entry of smart combo")
					end
		return combo
	end
end


function SpellDmgCalculations(parameter, target)
	local dmg = 0

	if parameter == "Q" then
		dmg = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap 
	elseif parameter == "W" then
		dmg = 40 * myHero:GetSpellData(_W).level + 45 + 0.6 * myHero.ap
	elseif parameter == "E" then
		dmg = 25 * myHero:GetSpellData(_E).level + 15 + 0.5 * myHero.ap
	elseif parameter == "RQ" then
		dmg = 100 * myHero:GetSpellData(_R).level + 0.65 * myHero.ap
	elseif parameter == "RW" then
		dmg = 150 * myHero:GetSpellData(_R).level + 0.975 * myHero.ap 
	elseif parameter == "RE" then
		dmg = 100 * myHero:GetSpellData(_W).level + 0.65 * myHero.ap
	elseif parameter == "QProc" then
		dmg = 25 * myHero:GetSpellData(_Q).level + 30 + 0.4 * myHero.ap
	end 

	return myHero:CalcMagicDamage(target, dmg)
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8, round(180 / math.deg((math.asin((chordlength / (2 * radius)))))))
	quality = 2 * math.pi / quality
	radius = radius * .92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
			points[#points + 1] = D3DXVECTOR2(c.x, c.y)
		end
		DrawLines2(points, width or 1, 4294967295)
	end

function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))

	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
		DrawCircleNextLvl(x, y, z, radius, 1, color, Menu.drawings.lfc.CL) 
	end
end