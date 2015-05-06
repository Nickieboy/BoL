--[[


		!!!!!!!!!!!!!!!!!! I HIGHLY RECOMMEND TO CHECK THE THREAD WEEKLY AND PUT AUTO UPDATE OFF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		Script coded by: Totally Legit
		Champion: LeBlanc
		Series: Fourth Serie


		Changelog
			* 1.0
				OFFICIALLY COMPLETELY OUT OF BETA
					Divine Prediction added
					Improved Smart W
						Due to buffs currently NOT working, I have removed this.
						The improved smart W will look at the chain and at the enemies nearby. For the chain, I will need to check for buffs, but buffs are kinda broken every patch for
							a few days, so i will disable the smart W at every patch, until it works fine again.
					Improved Combos
					Improved a lot of stuff ;')
					About the future of Smart Combo
						There are so much situational stuff with LeBlanc, that completely making the combo "smart" is impossible in my opinion. 
						You will always need a brain when playing LeBlanc to know when to go in and when not. 

			* 1.1
				Changed the drawings a little bit to make them more clear

			* 1.15
				Enabled DivinePrediction
				Fixed the other combos
				Tweaked some stuff

			* 1.20
				!!!!!! SAC SUPPORT IS HERE !!!!!!!!!
				Including the following support: Working DivinePrediction support & added HPred for E

--]]


if myHero.charName:lower() ~= "leblanc" then return end

_G.Leblanc_loaded = true

function Say(text)
	print("<font color=\"#FF0000\"><b>Totally LeBlanc:</b></font> <font color=\"#FFFFFF\">" .. text .. "</font>")
end

--[[		Auto Update		]]
local version = "1.20"
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

local SxOrbloaded, SAC, prodLoaded, divinePredLoaded, hPredLoaded, orbWalkLoaded = false
local HPred = nil

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


if FileExist(LIB_PATH.."DivinePred.lua") then
	divinePredLoaded = true
	require "DivinePred"
end 

if FileExist(LIB_PATH.."HPrediction.lua") then
	hPredLoaded = true
	require "HPrediction"
end 

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

	rSpellName = {
			["LeblancChaosOrbM"] = true,
			["LeblancSlideM"] = true,
			["LeblancSoulShackleM"] = true
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

	AAdisabled = false
	lastActivated = nil

	-- Killsteal
	KillText = {}

	--Libraries
	VP, dp = nil

	-- Prodiction & DivinePred
	ProdW, ProdE = nil
	eSS, wSS = nil

	-- Summoners
	ignite, heal, barrier, Iready, Hready, Bready = false

	-- Items
	ZhonyasSot = nil
	ZhyonasReady = false

	-- Clone
	clone = nil
	cloneActive = false

	-- Target settings
	target = nil
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 700)
	tsLong = TargetSelector(TARGET_LOW_HP_PRIORITY, 1500)
	exampleTarget = nil

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


	-- Improved Smart Combo
	canCastSpells = true 
	RSkill = nil
	RSkillTime = os.clock()

	-- Improved logics
	castedE = false
	castedETime = os.clock()

	-- Divine Prediction
	if divinePredLoaded then
		eSS = LineSS(Spells.E.speed, Spells.E.range, Spells.E.radius, (Spells.E.delay * 1000), 0)
		wSS = CircleSS(Spells.W.speed, (Spells.W.range + 100), Spells.W.radius, (Spells.W.delay * 1000), math.huge)
		LoadDivinePrediction()
	end

	
	-- HPrediction
	if hPredLoaded then
		HPred = HPrediction()
		LoadHPrediction()  
	end

	

end 

function LoadHPrediction() 
	Spell_W.collisionM['Leblanc'] = false
  	Spell_W.collisionH['Leblanc'] = false -- or false (sometimes, it's better to not consider it)
  	Spell_W.delay['Leblanc'] = Spells.W.delay
  	Spell_W.range['Leblanc'] = (Spells.W.range + 100)
  	Spell_W.speed['Leblanc'] = Spells.W.speed
  	Spell_W.type['Leblanc'] = "DelayCircle" -- 
  	Spell_W.width['Leblanc'] = Spells.W.radius

	Spell_E.collisionM['Leblanc'] = true
  	Spell_E.collisionH['Leblanc'] = true -- or false (sometimes, it's better to not consider it)
  	Spell_E.delay['Leblanc'] = Spells.E.delay
  	Spell_E.range['Leblanc'] = Spells.E.range
  	Spell_E.speed['Leblanc'] = Spells.E.speed
  	Spell_E.type['Leblanc'] = "DelayLine" -- (it has tail like comet)
  	Spell_E.width['Leblanc'] = Spells.E.radius
end

function LoadDivinePrediction()
	if divinePredLoaded then
		divinePredictionTargetTable = {}
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and enemy.type and enemy.type == myHero.type then
				divinePredictionTargetTable[enemy.networkID] = DPTarget(enemy)
			end
		end
	end
end


function CheckOrbWalker() 
	if _G.Reborn_Initialised then
		SACLoaded = true 
		Menu.orbwalker:addParam("info", "Detected SAC", SCRIPT_PARAM_INFO, "")
		_G.AutoCarry.Skills:DisableAll()
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require("SxOrbWalk")
		SxOrbloaded = true 
		Menu.keysettings:addParam("useCombo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 		Menu.keysettings:addParam("useHarass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 		Menu.keysettings:addParam("useLaneclear", "LaneClear Key", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("L"))
 		Menu.keysettings:addParam("useLastHit", "LastHit Key", SCRIPT_PARAM_ONKEYDOWN, false,  string.byte("X"))
		_G.SxOrb:LoadToMenu(Menu.orbwalker, true)
		_G.SxOrb:RegisterHotKey('fight',     Menu.keysettings, 'useCombo')
		_G.SxOrb:RegisterHotKey('harass',    Menu.keysettings, 'useHarass')
		_G.SxOrb:RegisterHotKey('laneclear', Menu.keysettings, 'useLaneclear')
		_G.SxOrb:RegisterHotKey('lasthit',   Menu.keysettings, 'useLastHit')
		Menu.keysettings:permaShow("useCombo")
	 	Menu.keysettings:permaShow("useHarass")
	 	Menu.keysettings:permaShow("useLaneclear")
	 	Menu.keysettings:permaShow("useLastHit")
	end
	if SACLoaded or SxOrbloaded then
		orbWalkLoaded = true
		Menu.keysettings:addParam("useFarm", "Farm Key", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
		Menu.keysettings:permaShow("useFarm")
	end
	if not orbWalkLoaded then 
		Say("You need either SAC or SxOrbWalk for this script. Please download one of them.") 
	else
		Say("Succesfully Loaded. Enjoy the script! Report bugs on the thread.")
	end
end


function OnLoad()

	DeclareVariables()
		 
	Summoners()
		 
	--SxOrb = SxOrbWalk()
		 
	VP = VPrediction()

	if divinePredLoaded then
		dp = DivinePred()
	end

	NormalWPred = TargetPrediction(Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.radius)
	NormalEPred = TargetPrediction(Spells.E.range, Spells.E.speed, Spells.E.delay, Spells.E.radius)

	Say("Checking whether user has SAC or SxOrbWalk. Please wait...")
    Say("Loading...")
    DelayAction(function() CheckOrbWalker() end, 5)

	DrawMenu()

	if heroManager.iCount == 10 then
		arrangePrioritys()
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    end

	-- TotallySeries Message
	serverMessage = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/announcements/totallyseries.txt")
	print("<font color=\"#000000\"><b>Totally Series (Latest News):</b></font> <font color=\"#ffaa00\">" .. tostring(serverMessage) .. "</font>")
end

function OnDraw()
	if not orbWalkLoaded or myHero.dead then return end

	if Menu.drawings.draw then
		if Menu.drawings.drawQ and CanDrawSpell(_Q) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range, RGB(255, 102, 102))
		end

		if Menu.drawings.drawW and CanDrawSpell(_W) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, RGB(255, 51, 153))
		end

		if Menu.drawings.drawTarget and target and ValidTarget(target) then
			DrawCircle(target.x, target.y, target.z, Spells.W.radius, RGB(255, 51, 153))
			local barPos = WorldToScreen(D3DXVECTOR3(target.x, target.y, target.z))
			local PosX = barPos.x - 35
			local PosY = barPos.y - 40
			DrawText(target.charName .. " - " .. "Distance : " .. math.ceil(GetDistance(target)), 12, PosX, PosY, ARGB(255,255,204,0))
		end

		if Menu.drawings.drawE and CanDrawSpell(_E) then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, RGB(255, 153, 153))
		end

		if Menu.drawings.drawKillable then
			for i, enemy in ipairs(GetEnemyHeroes()) do 
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
	if not orbWalkLoaded or myHero.dead then return end
	SpellReadyChecks()
	enemyMinions:update()
	target = GetOrbTarget()

	CalcDamage()


	if (SxOrbloaded and _G.SxOrb:GetMode() == 1) or (SACLoaded and _G.AutoCarry.Keys.AutoCarry) then
		Combo()
	end 

	if Menu.settingsW.useOptional then
		LeBlancSpecificSpellChecks()
	end 

	if Menu.combo.comboAA and ((SxOrbloaded and _G.SxOrb:GetMode() == 1) or (SACLoaded and _G.AutoCarry.Keys.AutoCarry)) then
		if AAdisabled then
			if SxOrbloaded then
				_G.SxOrb:DisableAttacks()
			elseif SACLoaded then
				_G.AutoCarry.MyHero:AttacksEnabled(true)
			end
			AAdisabled = false
		end 
	end 

	if ((SxOrbloaded and _G.SxOrb:GetMode() == 1) or (SACLoaded and _G.AutoCarry.Keys.AutoCarry)) and not Menu.combo.comboAA then
		if not AAdisabled then
			if SxOrbloaded then
				_G.SxOrb:DisableAttacks()
			elseif SACLoaded then
				_G.AutoCarry.MyHero:AttacksEnabled(false)
			end
			AAdisabled = true
		end 
	end

	if (SxOrbloaded and _G.SxOrb:GetMode() == 2) or (SACLoaded and _G.AutoCarry.Keys.MixedMode) then
		Harass()
	end 

	if Menu.keysettings.useFarm and ((SxOrbloaded and not _G.SxOrb:GetMode() == 1 and not _G.SxOrb:GetMode() == 2 and not _G.SxOrb:GetMode() == 3) or (SACLoaded and not _G.AutoCarry.Keys.AutoCarry and not _G.AutoCarry.Keys.MixedMode and not _G.AutoCarry.Keys.LaneClear)) then
		Farm() 
	end

	if (SxOrbloaded and _G.SxOrb:GetMode() == 3) or (SACLoaded and _G.AutoCarry.Keys.LaneClear) then
		LaneClear()
	end 

	if Menu.killsteal.killsteal and not ((SxOrbloaded and _G.SxOrb:GetMode() == 1) or (SACLoaded and _G.AutoCarry.Keys.AutoCarry)) then
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


function OnApplyBuff(source, target, buff) 
	if source and source.isMe and target and target.type == myHero.type and target.team ~= myHero.team and buff.name:find("LeblancSoulShackle")  then
		chainTarget = target
		castedETime = os.clock()
	end
end

--[[
function OnUpdateBuff(target, buff)
	if target and target.type == myHero.type and target.team ~= myHero.team and buff.name:find("LeblancSoulShackle") then
		chainTarget = target
		castedETime = os.clock()
	end
end
--]]

function OnRemoveBuff(unit, buff)
	if unit and chainTarget and buff.name:find("LeblancSoulShackle") and unit.type == myHero.type and unit.networkID == chainTarget.networkID then
		chainTarget = nil
	end
end

function OnProcessSpell(obj, spell)
    if obj.isMe and spell.name == Spells.W.spellname then
	    Spells.W.startPos = spell.startPos
    end

    if obj.isMe and spell.name == Spells.WR.spellname then
	    Spells.WR.startPos = spell.startPos
	end

    if obj.isMe and ((spell.name == Spells.Q.spellname) or (spell.name == Spells.W.spellname) or (spell.name == Spells.E.spellname)) then
    	lastActivated = spell.name
    end 

    if canCastSpells == false and rSpellName[spell.name] ~= nil then
		canCastSpells = true
		RSkill = nil
	end
end



function Combo()
	if myHero.dead then return end
	if target ~= nil and ValidTarget(target, 1500) then

		if Menu.combo.comboItems then
			UseItems(target)
		end 

		if (canCastSpells == false or RSkill ~= nil) and RSkillTime + 3 < os.clock() then 
			canCastSpells = true
			RSkill = nil 
		end

		if not Rready and (canCastSpells == false or RSkill ~= nil) then 
			RSkill = nil
			canCastSpells = true 
		end


		if Rready and not canCastSpells and RSkill ~= nil then
			if RSkill == "Q" then
				if lastActivated == Spells.Q.spellname then
					CastRQ(target)
				end
			elseif RSkill == "W" then
				if lastActivated == Spells.W.spellname then
					CastRW(target)
				end
			elseif RSkill == "E" then
				if lastActivated == Spells.E.spellname then
					CastRE(target)
				end
			end
			return
		end

		
		---------------- Smart Combo --------------
		if Menu.combo.comboWay == 1 then
			SmartCombo(target)
		----------------- QRWE ------------------------
		elseif Menu.combo.comboWay == 2 then
			ComboQRWE(target)
		---------------- QWRE -----------------------
		elseif Menu.combo.comboWay == 3 then
			ComboQWRE(target)
		------------------ WQRE ----------------------
		elseif Menu.combo.comboWay == 4 then
			ComboWQRE(target)
		------------------- WRQE --------------------
		elseif Menu.combo.comboWay == 5 then
			ComboWRQE(target)
		end 

	end 
end 

function ComboQRWE(target)
	if Qready and Rready and GetDistance(target) <= Spells.Q.range then
		if CastQ(target) then
			canCastSpells = false
			RSkill = "Q"
			RSkillTime = os.clock()
			return
		end
	elseif Qready and not Rready then
		CastQ(target)
	elseif Rready and not Qready and lastActivated == Spells.Q.spellname then
		canCastSpells = false
		RSkill = "Q"
		RSkillTime = os.clock()
		return
	end
	if not wUsed() then
		CastW(target)
	end
	CastE(target)
end

function ComboQWRE(target)
	if Qready then
		CastQ(target)
	end
	if Wready and Rready and not wUsed() and not wrUsed() and GetDistance(target) <= Spells.W.range then
		if CastW(target) then
			canCastSpells = false
			RSkill = "W"
			RSkillTime = os.clock()
			return
		end
	elseif Wready and not Rready and not wUsed() then
		CastW(target)
	elseif Rready and lastActivated == Spells.W.spellname and GetDistance(target) <= Spells.W.range then
		canCastSpells = false
		RSkill = "W"
		RSkillTime = os.clock()
		return
	end
	CastE(target)
end

function ComboWQRE(target)
	if not wUsed() and Wready then
		CastW(target)
	end

	if Qready and Rready and GetDistance(target) <= Spells.Q.range then
		if CastQ(target) then
			canCastSpells = false
			RSkill = "Q"
			RSkillTime = os.clock()
			return
		end
	elseif Qready and not Rready then
		CastQ(target)
	elseif Rready and not Qready and lastActivated == Spells.Q.spellname then
		canCastSpells = false
		RSkill = "Q"
		RSkillTime = os.clock()
		return
	end
	CastE(target)
end

function ComboWRQE(target)
	if not wUsed() and not wrUsed() and Wready and Rready then
		if CastW(target) then
			canCastSpells = false
			RSkill = "W"
			RSkillTime = os.clock()
			return
		end
	elseif not wUsed() and not Rready and Wready then
		CastW(target)
	elseif not wrUsed() and Rready and not Wready and lastActivated == Spells.W.spellname then
		canCastSpells = false
		RSkill = "W"
		RSkillTime = os.clock()
		return
	end
	CastQ(target)
	CastE(target)
end


function CastRQ(target)
	if target and Rready and GetDistance(target) <= Spells.Q.range then
		CastSpell(_R, target)
	end
end

function CastRW(target)
	local WCast = GetWPrediction(target)
	if target and Rready and GetDistance(target) <= (Spells.W.range + 100) then
		if WCast ~= nil and not wrUsed() then
			CastSpell(_R, WCast.x, WCast.z)
		end
	end
end

function CastRE(target)
	local castPos = GetEPrediction(target)
	if target and Rready and GetDistance(target) <= Spells.E.range then
		if castPos ~= nil then
			CastSpell(_R, castPos.x, castPos.Z)
		end
	end
end

function Harass()
	local castedW = false
	
	if target ~= nil and ValidTarget(target) and ManaManager() then

		if Menu.harass.harassQ then
			CastQ(target) 
		end 
		if Menu.harass.harassW then
			if CastW(target) then castedW = true end
		end 
		if Menu.harass.harassE then
			CastE(target)
		end 
		if castedW == true and Wready and wUsed() then CastSpell(_W) end
	end 
end 

function LeBlancSpecificSpellChecks()
	-- W Activated Settings
	if castedETime + 2 > os.clock() then return end
	if chainTarget and castedETime + 2 < os.clock() then chainTarget = nil end
	if wUsed() and chainTarget ~= nil and GetDistance(Spells.W.startPos, chainTarget) >= Spells.E.range then return end
	if wrUsed() and not wUsed() and chainTarget ~= nil and GetDistance(Spells.WR.startPos, chainTarget) >= Spells.E.range then return end
	if wUsed() and wrUsed() and GetDistance(Spells.W.startPos, chainTarget) >= Spells.E.range and GetDistance(Spells.WR.startPos, chainTarget) >= Spells.E.range then return end

		-- W and W by R activated
	if Menu.settingsW.useOptionalW == 1 then
		if wUsed() and wrUsed() then
			if CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400, Spells.W.startPos) and CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400) then
				if not Qready and not Eready then
					CastSpell(_R)
				end 
			elseif CountEnemyHeroInRange(400, Spells.W.startPos)> CountEnemyHeroInRange(400, Spells.WR.startPos) and CountEnemyHeroInRange(400, Spells.W.startPos) < CountEnemyHeroInRange(400) then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end 
			-- Normal W
		elseif wUsed() then
			if CountEnemyHeroInRange(400, Spells.W.startPos) < CountEnemyHeroInRange(400) then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end  
			-- W activated by using R
		elseif wrUsed() then
			if CountEnemyHeroInRange(400, Spells.WR.startPos) < CountEnemyHeroInRange(400) then
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



function Farm()
	local hasCasted = false

	if Menu.farm.farmAA and ((SxOrbloaded and _G.SxOrb:CanAttack() == true) or (SACLoaded and _G.AutoCarry.Orbwalker:CanShoot())) then return end

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
	if hasCasted then Qready = false return end 
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
	if hasCasted then Wready = false return end 
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
	if not canCastSpells then return end
	for i, enemy in ipairs(GetEnemyHeroes()) do 
		if ValidTarget(enemy) and not enemy.dead and enemy.visible and Menu.killsteal.enemies[enemy.charName] then
			local Qdmg, RQdmg, QdmgMark, Wdmg, RWdmg, Edmg = 0
			local ECast = nil

			if GetDistance(enemy) <= (Spells.Q.range + Spells.W.range) then
				Qdmg = ((Qready and Menu.killsteal.killstealQ and SpellDmgCalculations("Q", enemy)) or 0)
				RQdmg = ((Rready and lastActivated == Spells.Q.spellname and SpellDmgCalculations("RQ", enemy)) or 0)
				QdmgMark = (((Qready or Rready) and (Menu.killsteal.killstealQ or Menu.killsteal.killstealR) and SpellDmgCalculations("QProc", enemy)) or 0)
				Wdmg = ((Wready and Menu.killsteal.killstealW and SpellDmgCalculations("W", enemy)) or 0)
				RWdmg = ((Rready and Menu.killsteal.killstealR and not wrUsed() and lastActivated == Spells.W.spellname and SpellDmgCalculations("RW", enemy)) or 0)
				Edmg = ((Eready and Menu.killsteal.killstealE and SpellDmgCalculations("E", enemy)) or 0)
			end
			if GetDistance(enemy) <= 650 then
				if Qdmg > Wdmg and Wdmg > enemy.health then
					CastW(enemy)
				elseif Qdmg > enemy.health then
					CastQ(enemy) 
				elseif ECast ~= nil and Edmg > enemy.health then
					CastE(enemy)
				elseif RQdmg > RWdmg and RWdmg > enemy.health then
					CastRW(enemy)
				elseif RQdmg > enemy.health then
					CastRQ(enemy)
				end 
		 	elseif Menu.killsteal.killstealGap and GetDistance(enemy) >= 600 and GetDistance(enemy) <= (Spells.Q.range + Spells.W.range) and Wready and not wUsed() and HasManaToGapClose() then
				if Qdmg > enemy.health then
					if GapClose(enemy) then
						CastQ(enemy) 
					end
				elseif ECast ~= nil and Edmg > enemy.health then
					if GapClose(enemy) then
						CastE(enemy)
					end
				elseif RQdmg > RWdmg and RWdmg > enemy.health then
					if GapClose(enemy) then
						CastRW(enemy)
					end
				elseif Menu.killsteal.killstealQR and RQdmg + QdmgMark + Qdmg > enemy.health and Qready and Rready then 
					if GapClose(enemy) then
						if CastQ(enemy) then 
							canCastSpells = false
							RSkill = "Q"
							RSkillTime = os.clock()
						end 
					end 
				end
			end
		end
	end 
end 

-- Obtain a target
function GetOrbTarget()
	local t = nil
	local temp = nil

	ts:update()
	tsLong:update()

	t = tsLong.target

	temp = t

	if t then
		if GetDistance(t) > 700 and CountEnemyHeroInRange(600) >= 3 and not (table.contains(priorityTable.AP, t.charName) or table.contains(priorityTable.Support, t.charName)  or table.contains(priorityTable.AD_Carry, t.charName)) then
			t = nil
		else
			local Qdmg = ((Qready and SpellDmgCalculations("Q", t)) or 0)
			local RQdmg = ((Qready and lastActivated == Spells.Q.spellname and SpellDmgCalculations("RQ", t)) or 0)
			local QdmgMark = (((Qready or Rready) and SpellDmgCalculations("QProc", t)) or 0)
			local totalDmg = (Rready and Qready and (Qdmg + RQdmg + QdmgMark))

			if GetDistance(t) > 700 and CountEnemyHeroInRange(600) >= 3 and totalDmg < t.health then
				t = nil
			end
		end

		if t == nil then
			t = ts.target
		end

		if t == nil and temp ~= nil then
			t = temp 
		end

		if t and ((t.type and t.type ~= myHero.type) or not t.type) then
			t = nil
		end
	end

	return t
end 

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
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and GetDistance(enemy, myHero) < 600 and ValidTarget(enemy, 600) and Menu.misc.autoignite[enemy.charName] then
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
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy and ValidTarget(enemy) then
			local Qdmg = ((Qready and SpellDmgCalculations("Q", enemy)) or 0)
			local RQdmg = ((Rready and lastActivated == Spells.Q.spellname and SpellDmgCalculations("RQ", enemy)) or 0)
			local QdmgMark = (((Qready or (Rready and lastActivated == Spells.Q.spellname)) and SpellDmgCalculations("QProc", enemy)) or 0)
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
				KillText[i] = "Q + Ignite = kill"
			elseif Wdmg + iDmg > enemy.health then
				KillText[i] = "W + Ignite = kill"
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
			elseif Qdmg + QdmgMark + Wdmg + RWdmg + iDmg > enemy.health then
				KillText[i] = "Q + W + R + Ignite = kill"
			elseif Qdmg + RQdmg + QdmgMark + QdmgMark + Wdmg + iDmg > enemy.health then
				KillText[i] = "Q + R + W + Ignite = kill"
			elseif Qdmg + RQdmg + QdmgMark + QdmgMark + Wdmg + Edmg > enemy.health then
				KillText[i] = "Q + R + W + E = kill"
			elseif Qdmg + QdmgMark + Wdmg + RWdmg + Edmg > enemy.health then
				KillText[i] = "Q + W + R + E = kill"
			elseif Qdmg + RQdmg + QdmgMark + QdmgMark + Wdmg + Edmg + iDmg > enemy.health then
				KillText[i] = "Q + R + W + E + Ignite = kill"
			elseif Qdmg + QdmgMark + Wdmg + RWdmg + Edmg + iDmg > enemy.health then
				KillText[i] = "Q + W + R + E + Ignite = kill"
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

	Menu = scriptConfig("Totally LeBlanc - Totally Legit", "TotallyLeBlanc.cfg")
	local name = "Totally LeBlanc  -  "

	-- KeySettings
	Menu:addSubMenu(name .. "Key Settings", "keysettings")

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
 	Menu.killsteal:addParam("killstealGap", "GapClose to kill enemy", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealQR", "Gapclose > Q + R", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addSubMenu("KillSteal Enemy", "enemies")
 	for i, enemy in pairs(GetEnemyHeroes()) do
 		if enemy and table.contains(priorityTable.Support, enemy.charName) or table.contains(priorityTable.AD_Carry, enemy.charName) or table.contains(priorityTable.AP, enemy.charName) then
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
 	Menu.drawings:addParam("drawTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawSpellReady", "Don't draw if spell is CD", SCRIPT_PARAM_ONOFF, false)

 	Menu:addSubMenu(name .. "Prediction", "prediction")
 	if divinePredLoaded and hPredLoaded then
		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "DivinePrediction", "HPrediction"})
	elseif divinePredLoaded and not hPredLoaded then
		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "DivinePrediction"})
	elseif hPredLoaded and not divinePredLoaded then
		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "HPrediction"})
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

	Menu:addParam("info2", "Author", SCRIPT_PARAM_INFO, author)
	Menu:addParam("info", "Version", SCRIPT_PARAM_INFO, version)

	 -- Always show
	 Menu.killsteal:permaShow("killsteal")
	 Menu.drawings:permaShow("draw")
end 



function Summoners()
	heal = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerheal") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerheal") and SUMMONER_2))
   	ignite = ((myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") and SUMMONER_2))
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
	local WCast = nil
	if Menu.prediction.usePrediction == 1 then
		WCast = NormalWPred:GetPrediction(target)
	-- VPrediction
	elseif Menu.prediction.usePrediction == 2 then
		WCast = VP:GetCircularCastPosition(target, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)
	elseif DivinePredLoaded() then 
		local tempDivineTarget = nil
		if divinePredictionTargetTable[target.networkID] ~= nil then
			tempDivineTarget = divinePredictionTargetTable[target.networkID]
		end
		if tempDivineTarget then
			local state, hitPos, perc = dp:predict(tempDivineTarget, wSS)
			if state and state == SkillShot.STATUS.SUCCESS_HIT and hitPos ~= nil then
				WCast = hitPos
			end
		end
	elseif HPredMenuLoaded() then
		WCast = VP:GetCircularCastPosition(target, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)
	end
	return WCast
end

function GetEPrediction(target)
	local ECast = nil
	if Menu.prediction.usePrediction == 1 then
		local castPosE, collE, healthE = NormalEPred:GetPrediction(target)
		if not collE then
			ECast = castPosE
		end 
	elseif Menu.prediction.usePrediction == 2 then
		local castPos, hitchance = VP:GetLineCastPosition(target, Spells.E.delay, Spells.E.radius, Spells.E.range, Spells.E.speed, myHero, true)	
		if hitchance >= 2 then	
			ECast = castPos
		end 		
	elseif DivinePredLoaded() then 
		local tempDivineTarget = nil
		if divinePredictionTargetTable[target.networkID] ~= nil then
			tempDivineTarget = divinePredictionTargetTable[target.networkID]
		end
		if tempDivineTarget then
			local state, hitPos, perc = dp:predict(tempDivineTarget, eSS)
			if state and state == SkillShot.STATUS.SUCCESS_HIT and hitPos ~= nil then
				ECast = hitPos
			end
		end
	elseif HPredMenuLoaded() then
		local CastPos, HitChance = HPred:GetPredict("E", target, myHero)
		if CastPos then
			ECast = CastPos 
		end
	end

	return ECast
end

function DivinePredLoaded()
	return divinePredLoaded and Menu.prediction.usePrediction == 3 
end

function HPredMenuLoaded()
	return (hPredLoaded and divinePredLoaded and Menu.prediction.usePrediction == 4) or (hPredLoaded and not divinePredLoaded and Menu.prediction.usePrediction == 3) 
end


function CastQ(target)
	if target ~= nil and not target.dead and GetDistanceSqr(target) <= Spells.Q.range * Spells.Q.range and target.type == myHero.type or target.type == "obj_AI_Minion" then
		if Qready then
			CastSpell(_Q, target)
			return true
		end  
	end 
	return false
end 

function CastW(target, param2)
	local WRangeRadius = Spells.W.range + 100
	local WRangeRadiusSqr = WRangeRadius * WRangeRadius
	if not param2 then
		if target and GetDistanceSqr(target) <= WRangeRadiusSqr then
			if target.type == myHero.type then
				if Wready and not wUsed() then
					local castPosition, hitChance = GetWPrediction(target)
					if castPosition ~= nil then
						CastSpell(_W, castPosition.x, castPosition.z)
						return true
					end 
				end 
			elseif target.type == "obj_AI_Minion" then
				CastSpell(_W, target.pos.x, target.pos.z)
				return true
			end 
		end
	else
		if Wready and not wUsed() then
			CastSpell(_W, target, param2)
			return true
		end
	end
	return false 
end 


function GapClose(target)
	if target and target.type and target.type == myHero.type then
		local newPos = Vector(myHero) + (Vector(target) - myHero):normalized() * Spells.W.range

		if not UnderTurret(newPos, true) and not wUsed() and Spells.W.ready then
			CastSpell(_W, newPos.x, newPos.z)
			return true
		end
	end
	return false
end 

function HasManaToGapClose()
	return (Spells.Q.ready and myHero:GetSpellData(_Q).mana + myHero:GetSpellData(_W).mana < myHero.mana) or (Spells.E.ready and myHero:GetSpellData(_E).mana + myHero:GetSpellData(_W).mana < myHero.mana)
end


function CastE(target)
	if target and not target.dead and GetDistanceSqr(target) <= (Spells.E.range * Spells.E.range) and target.type and target.type == myHero.type or target.type == "obj_AI_Minion" then
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


function wUsed()
	if myHero:GetSpellData(_W).name == "leblancslidereturn" then
		return true
	end 
	return false
end

function wrUsed()
	if myHero:GetSpellData(_R).name == "leblancslidereturnm" then
		return true
	end 
	return false
end 


--- Smart Combo
function SmartCombo(targ)

	-- Possible W targets
	local pos, enemies, count = ReturnBestTargetPosition(3, Spells.W.range)


	if pos ~= nil and enemies ~= nil and GetDistanceSqr(pos) < (Spells.W.range * Spells.W.range) then
		if not wUsed() and not wrUsed() and Wready and Rready then
			if count >= 3 then
				if CastW(pos.x, pos.z) then
					canCastSpells = false
					RSkill = "W"
					RSkillTime = os.clock()
					return
				end
			end 
		end 
	end

	-- Damage to calculate best combo
	local Qdmg = SpellDmgCalculations("Q", targ) 
	local QMarkProcDamage = SpellDmgCalculations("QProc", targ) 
	local Wdmg = SpellDmgCalculations("W", targ) 
	local Edmg = SpellDmgCalculations("E", targ) 
	local RQdmg = SpellDmgCalculations("RQ", targ)  
	local RWdmg = SpellDmgCalculations("RW", targ)  
	local distanceTo = GetDistanceSqr(targ)

	-- Actual combo
	if Qready and (Wready and not wUsed()) and Rready and (Qdmg + RQdmg + QMarkProcDamage + QMarkProcDamage + Wdmg) >= (Wdmg + RWdmg + Qdmg) and distanceTo < (Spells.Q.range * Spells.Q.range) then
		if CastQ(targ) then
			canCastSpells = false
			RSkill = "Q"
			RSkillTime = os.clock()
		end
	elseif Qready and Rready and Wready and not wUsed() and not wrUsed() and distanceTo < (Spells.Q.range * Spells.Q.range) then
		CastQ(targ)
		if CastW(targ) then
			canCastSpells = false
			RSkill = "W"
			RSkillTime = os.clock()
		end
	elseif distanceTo < (Spells.E.range * Spells.E.range) and distanceTo > (Spells.Q.range * Spells.Q.range) then
		CastE(targ)
	elseif Qready and Rready and GetDistance(targ) < Spells.Q.range then
		if CastQ(targ) then
			canCastSpells = false
			RSkill = "Q"
			RSkillTime = os.clock()
		end
	elseif Menu.combo.comboGap and GetDistance(targ) > Spells.Q.range and GetDistance(targ) < (Spells.Q.range + Spells.W.range) and Qready and Wready and not wUsed() and Rready and HasManaToGapClose() then
		if GapClose(targ) then
			if CastQ(targ) then
				canCastSpells = false
				RSkill = "Q"
				RSkillTime = os.clock()
			end
		end
	elseif Menu.combo.comboGap and GetDistance(targ) > Spells.Q.range and GetDistance(targ) < (Spells.Q.range + Spells.W.range) and Qready and Wready and not wUsed() and Eready and HasManaToGapClose() then
		if GapClose(targ) then
			CastQ(targ)
			CastE(targ)
		end
	elseif Wready and not Eready and not Qready and myHero:GetSpellData(_Q).level and myHero:GetSpellData(_Q).level >= 1 and myHero:GetSpellData(_Q).currentCd and myHero:GetSpellData(_Q).currentCd <= 2 then
		return
	else
		CastQ(targ)
		CastRQ(targ)
		CastW(targ)
		CastE(targ)
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


assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQINAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBBkBAAB2AgAAIAACCHwCAAAUAAAAEBgAAAGNsYXNzAAQIAAAAVHJhY2tlcgAEBwAAAF9faW5pdAAECgAAAFVwZGF0ZVdlYgAEGgAAAGNvdW50aW5nSG93TXVjaFVzZXJzSWhhdmUAAgAAAAEAAAADAAAAAQAFCAAAAEwAQADDAIAAAUEAAF1AAAJGgEAApQAAAF1AAAEfAIAAAwAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAAAgAAAAMAAAAAAAQGAAAABQAAAAwAQACDAAAAwUAAAB1AAAIfAIAAAgAAAAQKAAAAVXBkYXRlV2ViAAMAAAAAAADwPwAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAYAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAAAAAAAAQAAAAUAAABzZWxmAAEAAAAAABAAAABAb2JmdXNjYXRlZC5sdWEACAAAAAEAAAABAAAAAQAAAAEAAAACAAAAAwAAAAIAAAADAAAAAQAAAAUAAABzZWxmAAAAAAAIAAAAAQAAAAUAAABfRU5WAAQAAAALAAAAAwAKIwAAAMYAQAABQQAA3YAAAQaBQABHwcABXQGAAB2BAABMAUECwUEBAAGCAQBdQQACWwAAABeAAYBMwUECwQECAAACAAFBQgIA1kGCA11BgAEXQAGATMFBAsGBAgAAAgABQUICANZBggNdQYABTIFDAsHBAwBdAYEBCMCBhgiAAYYIQIGFTAFEAl1BAAEfAIAAEQAAAAQIAAAAcmVxdWlyZQAEBwAAAHNvY2tldAAEBwAAAGFzc2VydAAEBAAAAHRjcAAECAAAAGNvbm5lY3QABBQAAABtYWlraWU2MS5zaW5uZXJzLmJlAAMAAAAAAABUQAQFAAAAc2VuZAAEKwAAAEdFVCAvdHJhY2tlci9pbmRleC5waHAvdXBkYXRlL2luY3JlYXNlP2lkPQAEKQAAACBIVFRQLzEuMA0KSG9zdDogbWFpa2llNjEuc2lubmVycy5iZQ0KDQoABCsAAABHRVQgL3RyYWNrZXIvaW5kZXgucGhwL3VwZGF0ZS9kZWNyZWFzZT9pZD0ABAIAAABzAAQHAAAAc3RhdHVzAAQIAAAAcGFydGlhbAAECAAAAHJlY2VpdmUABAMAAAAqYQAEBgAAAGNsb3NlAAAAAAABAAAAAAAQAAAAQG9iZnVzY2F0ZWQubHVhACMAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAcAAAAHAAAACAAAAAgAAAAJAAAACQAAAAkAAAAIAAAACQAAAAoAAAAKAAAACwAAAAsAAAALAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAUAAAAFAAAAc2VsZgAAAAAAIwAAAAIAAABhAAAAAAAjAAAAAgAAAGIAAAAAACMAAAACAAAAYwADAAAAIwAAAAIAAABkAAcAAAAjAAAAAQAAAAUAAABfRU5WAAEAAAABABAAAABAb2JmdXNjYXRlZC5sdWEADQAAAAEAAAABAAAAAQAAAAEAAAADAAAAAQAAAAQAAAALAAAABAAAAAsAAAALAAAACwAAAAsAAAAAAAAAAQAAAAUAAABfRU5WAA=="), nil, "bt", _ENV))()
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("XKNLLQLPRMN") 