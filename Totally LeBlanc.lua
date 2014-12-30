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



		Donations:
			Donations are ACCEPTED, but not required. I do this for fun.


--]]


if myHero.charName:lower() ~= "leblanc" then return end

local prodLoaded = false
local SxOrbloaded = false

-- Lib Updater
local REQUIRED_LIBS = {
	["SxOrbWalk"] = "https://raw.githubMenu.combo.comboRcontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["VPrediction"] = "https://raw.githubMenu.combo.comboRcontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
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

function DeclareVariables()
	-- Spells 
	Qready, Wready, Eready, Rready = false, false, false, false
	Spells = 	{
					["P"] = {name = "LeBlanc_Base_P_poof.troy"},
					["AA"] = {range = 525, name = "BasicAttack"},
					["Q"] = {name = "Sigil of Malice", spellname = "LeblancChaosOrb", range = 700, speed = 2000, markTimer = 3.5, activated = 0}, 
					["W"] = {name = "Distortion", spellname = "LeblancSlide", range = 600, radius = 250, speed = 2000, delay = 0.25, duration = 4, timeActivated = 0, isActivated = false, startPos = myHero.pos, endPos = myHero.pos}, 
					["E"] = {name = "Ethereal Chains", spellname = "LeblancSoulShackle", range = 950, speed = 1600, delay = 0.25, radius = 95}, 
					["R"] = {name = "Mimic", spellname = "LeblancMimic"},
					["WR"] = {duration = 4, spellname = "LeblancSlideM", timeActivated = 0, isActivated = false, startPos = myHero.pos, endPos = myHero.pos}
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
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 600)
	exampleTarget = nil

	-- Debug
	lastCheckedW, lastCheckedWR = nil, nil
	lastDebugCombo = os.clock() -- Avoid spam on pressing combo


	--MinionManager
	enemyMinions = minionManager(MINION_ENEMY, 600, myHero, MINION_SORT_HEALTH_DEC)


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
			print("1. LeBlanc: Variables loaded")
		 
	Summoners()
			print("2. LeBlanc: Summoners loaded")
		 
	SxOrb = SxOrbWalk()
			print("3. LeBlanc: OrbWalker loaded")
	SxOrb:DisableAttacks()
		 
	VP = VPrediction()
			print("4. LeBlanc: VPrediction loaded")

	NormalWPred = TargetPrediction(Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.width)
	NormalEPred = TargetPrediction(Spells.E.range, Spells.E.speed, Spells.E.delay, Spells.E.width)
			print("5. LeBlanc: Normal Prediction loaded")

		 

	if prodLoaded then
		Prod = ProdictManager.GetInstance()
			print("6. LeBlanc: Prodiction loaded")
		ProdW = Prod:AddProdictionObject(_W, Spells.W.range, Spells.W.speed, Spells.W.delay, Spells.W.radius)   -- (spell, range, missilespeed, delay, width)
		ProdE = Prod:AddProdictionObject(_E, Spells.E.range, Spells.E.speed, Spells.E.delay, Spells.W.radius)   -- (spell, range, missilespeed, delay, width)
	end 

	DrawMenu()

	if heroManager.iCount == 10 then
		arrangePrioritys()
		print("7. LeBlanc: Priority Table arranged")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
		print("7. LeBlanc: Priority table arranged")
    else
		print("ERROR: Couldn't arrange priorities. Too few champions")
	end

end

function OnDraw()
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

		if Menu.drawings.drawKillable then
			for i = 1, heroManager.iCount do
	 			local enemy = heroManager:getHero(i)
	 			if ValidTarget(enemy) then
	 				local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 35
					local PosY = barPos.y - 50  
					DrawText(KillText[i], 15, PosX, PosY, ARGB(255,255,204,0))
				end 
			end 
		end 

	end 
end 


function OnTick()


	SpellReadyChecks()

	target = GetOrbTarget()

	if Menu.settingsW.useOptional then
		WChecks()
	end 

	LeBlancSpecificSpellChecks()
	CalcDamage()

	if Menu.combo.combo then
		Combo()
	end 

	if Menu.harass.harass then
		Harass()
	end 

	if Menu.farm.farm and not Menu.combo.combo and not Menu.harass.harass then
		Farm() 
	end

	if Menu.laneclear.laneclear then
		LaneClear()
	end 

	if Menu.mixed.mixed then
		MixedMode()
		myHero:MoveTo(mousePos.x, mousePos.z)
	end 

	if Menu.killsteal.killsteal and not Menu.combo.combo then
		KillSteal()
	end 

	if Menu.misc.zhonyas.zhonyas then
		Zhonyas()
	end 

	if Menu.misc.autopotions.usePotion and not InFountain() then
 		DrinkPotions()

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
end


function OnCreateObj(obj)
	if obj.name == Spells.P.name and GetDistance(obj, myHero) <= 50 then
		clone = obj
		cloneActive = true
			if Menu.debug.useDebug then 
				print("Clone : " .. (cloneActive and "true" or "false"))
				print("Clone : " .. clone.name)
			end 
	end 
end


function OnDeleteObj(obj)
	if clone == obj then
		clone = nil
		cloneActive = false 
			if Menu.debug.useDebug then 
				print("Clone : " .. (cloneActive and "true" or "false"))
			end 
	end 
end

function OnProcessSpell(obj, spell)
    if obj.isMe and spell.name == Spells.W.spellname then
	    Spells.W.timeActivated = os.clock()
	    Spells.W.startPos = spell.startPos
	    Spells.W.endPos = spell.endPos
	    Spells.W.isActivated = true
		   	if Menu.debug.useDebug then
		   		print("Activated W:")
		   		print(Spells["W"])
		   	end 
    end

    if obj.isMe and spell.name == Spells.WR.spellname then
    	Spells.WR.timeActivated = os.clock()
	    Spells.WR.startPos = spell.startPos
	    Spells.WR.endPos = spell.endPos
	    Spells.WR.isActivated = true
		   	if Menu.debug.useDebug then
		   		print("Activated W by R: ")
		   		print(Spells["WR"])
		   	end 
	end

    if obj.isMe and spell.name:lower() == "leblancslidereturn" then
    	Spells.W.isActivated = false
    		if Menu.debug.useDebug then
		    	print("De-Activated W:")
		    	print(Spells["W"])
		    end 
    end 

    if obj.isMe and spell.name:lower() == "leblancslidereturnm" then
    	Spells.WR.isActivated = false
    		if Menu.debug.useDebug then
		    	print("De-Activated W by R")
		    	print(Spells["WR"])
		    end 
    end 


    if (obj.isMe and spell.name == Spells.Q.spellname) or (obj.isMe and spell.name == Spells.W.spellname) or (obj.isMe and spell.name == Spells.E.spellname) then
    	lastActivated = spell.name
	    	if Menu.debug.useDebug then
	    		print("Last casted spell: = " .. lastActivated)
	    	end 
    end 

end

function LeBlancSpecificSpellChecks()
	-- Making sure W isn't activated when timer is over
	if Spells.W.isActivated and Spells.W.timeActivated + Spells.W.duration < os.clock() then
		Spells.W.isActivated = false
			if Menu.debug.useDebug then
		    	print("Return W no longer active:")
		    	print(Spells["W"])
		    end 
	end 
	if Spells.WR.isActivated and Spells.WR.timeActivated + Spells.WR.duration < os.clock() then
		Spells.WR.isActivated = false
		lastCheckedWR = Spells["WR"]
			if Menu.debug.useDebug then
		    	print("Return W by R no longer active:")
		    	print(Spells["WR"])
		    end 
	end 

	-- W Activated Settings
		-- W and W by R activated
	if Menu.settingsW.useOptional then
		if Menu.settingsW.useOptionalW == 1 then
			if Spells.W.isActivated and Spells.WR.isActivated then
				local HeroInRange = CountEnemyHeroInRange(600)


				if #EnemiesNearWR < #EnemiesNearW and #EnemiesNearWR < HeroInRange then
					if not Qready and not Eready then
						CastSpell(_R)
					end 
				elseif #EnemiesNearW > #EnemiesNearWR and #EnemiesNearW < HeroInRange then
					if not Qready and not Eready then
						CastSpell(_W)
					end 
				end 
				-- Normal W
			elseif Spells.W.isActivated and not Spells.WR.isActivated then

				local HeroInRange = CountEnemyHeroInRange(600)

				if (#EnemiesNearW < HeroInRange) then
					if not Qready and not Eready then
						CastSpell(_W)
					end 
				end  


				-- W activated by using R
			elseif Spells.WR.isActivated and not Spells.W.isActivated then
				local HeroInRange = CountEnemyHeroInRange(600)

				if #EnemiesNearWR < HeroInRange then
					if not Qready and not Eready then
						CastSpell(_W)
					end 
				end 
			end 

		elseif Menu.settingsW.useOptionalW == 3 or Menu.settingsW.useOptionalW == 4 then

			if Spells.W.isActivated and Spells.WR.isActivated then
				-- Gotta put some checks here, dunno which
			elseif Spells.W.isActivated then
				if not Qready and not Eready and not Rready then
					CastSpell(_W)
				end 
			elseif Spells.WR.isActivated then
				if not Qready and not Eready then
					CastSpell(_W)
				end 
			end 

		end 
	end 
end 

function WChecks()
	if Spells.W.isActivated then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			local enemyrange = enemy.range and enemy.range * enemy.range or 600
			if Spells.W.isActivated and GetDistanceSqr(enemy, Spells.W.startPos) < enemyrange then
				table.insert(EnemiesNearW, enemy)
			end 
			if Spells.W.isActivated and GetDistanceSqr(enemy, Spells.W.startPos) > enemyrange then
				if table.contains(EnemiesNearW, enemy) then
					table.remove(EnemiesNearW, i)
				end 
			end 
		end 
	end
	if Spells.WR.isActivated then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			local enemyrange = enemy.range and enemy.range * enemy.range or 600
			if Spells.WR.isActivated and GetDistanceSqr(enemy, Spells.WR.startPos) < enemyrange then
				table.insert(EnemiesNearWR, enemy)
			end 
			if Spells.WR.isActivated and GetDistanceSqr(enemy, Spells.WR.startPos) > enemyrange then
				table.remove(EnemiesNearWR, i)
			end 
		end 
	end

	if not Spells.W.isActivated and #EnemiesNearW >= 1 then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if table.contains(EnemiesNearW, enemy) then
				table.remove(EnemiesNearW, i)
			end 
		end 
	end 

	if not Spells.WR.isActivated and #EnemiesNearWR >= 1 then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if table.contains(EnemiesNearWR, enemy) then
				table.remove(EnemiesNearWR, i)
			end 
		end 
	end 
end


function Combo()

	if target ~= nil and ValidTarget(target, 600) then

		exampleTarget = target

			if Menu.debug.useDebug and lastDebugCombo + 2 < os.clock() then
				print("Target: " .. target.charName)
				lastDebugCombo = os.clock()
		    end 

		if Menu.combo.comboItems then
			UseItems(target)
		end 
		---------------- Smart Combo --------------
		if Menu.combo.comboWay == 1 then
			SmartCombo(target)
		----------------- QRWE ------------------------
		elseif Menu.combo.comboWay == 2 then

			local WCast, ECast = GetPredictionReturn(target)

			if Menu.combo.comboQ and Qready then
				CastSpell(_Q, target)
			end 
			--and lastActivated.name == Spells.Q.spellname
			if Menu.combo.comboR and Rready then
				CastSpell(_R, target)
			end 
			if Menu.combo.comboW and Wready and WCast ~= nil and not Spells.W.isActivated then
				CastSpell(_W, WCast.x, WCast.z)
			end
			if ECast ~= nil and Menu.combo.comboE and Eready then
				CastSpell(_E, ECast.x, ECast.z)
			end  
		---------------- QWRE -----------------------
		elseif Menu.combo.comboWay == 3 then

			local WCast, ECast = GetPredictionReturn(target)

			if Menu.combo.comboQ and Qready then
				CastSpell(_Q, target)
			end 
			if WCast ~= nil and Wready and Menu.combo.comboW and not Spells.W.isActivated then
				CastSpell(_W, WCast.x, WCast.z)
			end
			-- and lastActivated.name == Spells.W.spellname
			if Menu.combo.comboR and Rready then
				CastSpell(_R, WCast.x, WCast.z)
			end 
			if ECast ~= nil and Eready and Menu.combo.comboE then
				CastSpell(_E, ECast.x, ECast.z)
			end 

		------------------ WQRE ----------------------
		elseif Menu.combo.comboWay == 4 then

			local WCast, ECast = GetPredictionReturn(target)

			if WCast ~= nil and Menu.combo.comboW and Wready and not Spells.W.isActivated then
				CastSpell(_W, WCast.x, WCast.z)
			end

			if Menu.combo.comboQ and Qready then
				CastSpell(_Q, target)
			end 
			--and lastActivated.name == Spells.Q.spellname
			if Menu.combo.comboR and Rready then
				CastSpell(_R, target)
			end 

			if ECast ~= nil and Menu.combo.comboE and Eready then
				CastSpell(_E, ECast.x, ECast.z)
			end  
		------------------- WRQE --------------------
		elseif Menu.combo.comboWay == 5 then

			local WCast, ECast = GetPredictionReturn(target)

			if WCast ~= nil and Wready and Menu.combo.comboW then
				CastSpell(_W, WCast.x, WCast.z)
			end
			--and lastActivated.name == Spells.W.spellname
			if Menu.combo.comboR and Rready then
				CastSpell(_R, WCast.x, WCast.z)
			end 

			if Menu.combo.comboQ and Qready then
				CastSpell(_Q, target)
			end 

			if ECast ~= nil and Eready and Menu.combo.comboE then
				CastSpell(_E, ECast.x, ECast.z)
			end  			
		end 

		-- Return to basic W if target is dead during combo
		if exampleTarget and exampleTarget.dead and Spells.W.isActivated and Menu.settingsW.useOptionalW == 2 or Menu.settingsW.useOptionalW == 4 then
			CastSpell(_W)
		end 

		exampleTarget = nil

	end 
end 


-- Harass (In progress)
function Harass()
	if target ~= nil and ValidTarget(target, 600) and ManaManager() then
			if Menu.debug.useDebug then
		    	print("Performing harass on: " .. target)
		  	end

		local WCast, ECast = GetPredictionReturn(target)

		if Menu.harass.harassQ and Qready then
			CastSpell(_Q, target)
		end 

		if WCast ~= nil and Wready and Menu.harass.harassW and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 

		if ECast ~= nil and Eready and Menu.harass.harassE then
			CastSpell(_E, ECast.x, ECast.z)
		end 

	end 
end 


-- In Progress
function Farm()
	enemyMinions:update()

	if Menu.farm.farmAA and SxOrb:CanAttack() == true then return end

	if Menu.farm.farmQ then
		for i, minion in ipairs(enemyMinions.objects) do
			if Menu.farm.farmRange and GetDistance(minion) > Spells.AA.range and GetDistance(minion) < Spells.Q.range then
				if Qready and getDmg("Q", minion, myHero) > minion.health then
					CastSpell(_Q, minion)
					break
				end 
			end 
			if not Menu.farm.farmRange and GetDistance(minion) < Spells.Q.range then
				if Qready and getDmg("Q", minion, myHero) > minion.health then
					CastSpell(_Q, minion)
					break
				end 
			end 
		end 
	end 

	if Menu.farm.farmW then
		for i, minion in ipairs(enemyMinions.objects) do
			if Menu.farm.farmRange and GetDistance(minion) > Spells.AA.range and GetDistance(minion) < Spells.W.range then
				if Wready and getDmg("W", minion, myHero) > minion.health then
					CastSpell(_W, minion.x, minion.z)
					CastSpell(_W)
					break
				end
			end 
			if not Menu.farm.farmRange and GetDistance(minion) < Spells.W.range then
				if Wready and getDmg("W", minion, myHero) > minion.health then
					CastSpell(_W, minion.x, minion.z)
					CastSpell(_W)
					break
				end
			end 
		end  
	end
end 

function LaneClear()
	enemyMinions:update()

	if Menu.laneclear.laneclearQ then
		for i, minion in ipairs(enemyMinions.objects) do
			if GetDistanceSqr(minion) < Spells.Q.range * Spells.Q.range then
				CastSpell(_Q, minion)
				break
			end 
		end
	end 
	if Menu.laneclear.laneclearW and Menu.laneclear.laneclearR and Rready and Wready then 
		if not Spells.W.isActivated and not Spells.WR.isActivated then
			local castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if castPosition ~= nil then
				CastSpell(_W, castPosition.x, castPosition.z)
			end 
			enemyMinions:update()
			castPosition, xTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if castPosition ~= nil then
				CastSpell(_R, castPosition.x, castPosition.z)
			end 
		end
		if Spells.W.isActivated then
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


function MixedMode()
	enemyMinions:update()
	if target ~=  nil and ValidTarget(target, 600) then
		if Menu.mixed.mixedLasthit then
			if Menu.mixed.mixedQ then
				local minionTable = GetKillableMinions(enemyMinions.objects, Spells.Q.range, _Q, myHero)
				if minionTable then
					for i, minion in ipairs(minionTable) do
						if Qready then
							CastSpell(_Q, minion)
							break
						end
					end 
				else
					if Qready then
						CastSpell(_Q, target)
					end 
				end 
			end 

			if Menu.mixed.mixedR then
				local minionTable = GetKillableMinions(enemyMinions.objects, Spells.W.range, _W, myHero)
				if not minionTable and Rready then
					CastSpell(_R, target)
				end 
			end 

			if Menu.mixed.mixedW then
				local minionTable = GetKillableMinions(enemyMinions.objects, Spells.W.range, _W, myHero)
				if minionTable then
					for i, minion in ipairs(minionTable) do
						if Wready then
							CastSpell(_W, minion)
							CastSpell(_W)
							break
						end
					end 
				else 
					if Wready then
						CastSpell(_W, target)
					end 
				end 
			end 
		else
			if Menu.mixed.mixedQ and Qready then
				CastSpell(_Q, target)
			end 
			if Menu.mixed.mixedR and Rready then
				CastSpell(_R, target)
			end 

			if Menu.mixed.mixedW and Wready then
				CastSpell(_W, target)
				CastSpell(_W)
			end 
		end 
	else
		if Menu.mixed.mixedLasthit then
			if Menu.mixed.mixedQ then
				local minionTable = GetKillableMinions(enemyMinions.objects, Spells.Q.range, _Q, myHero)
				if minionTable then
					for i, minion in ipairs(minionTable) do
						if Qready then
							CastSpell(_Q, minion)
							break
						end
					end 
				end
			end 
			if Menu.mixed.mixedW then
				local minionTable = GetKillableMinions(enemyMinions.objects, Spells.W.range, _W, myHero)
				for i, minion in ipairs(minionTable) do
					if Wready then
						CastSpell(_W, minion)
						break
					end
				end 
			end 

		else
			for i, minion in ipairs(enemyMinions.objects) do
				if Menu.mixed.mixedQ and GetDistanceSqr(minion) < Spells.Q.range * Spells.Q.range then
					if Qready then
						CastSpell(_Q, minion)
						break
					end 
				end 
			end 

			local castPosition, nTargets = GetBestAOEPosition(enemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if castPosition ~= nil then
				if Wready then
					CastSpell(_W, castPosition.x, castPosition.z)
				end 
			end 
		end 
	end 
end 


function KillSteal()
	for i, enemy in ipairs(GetEnemyHeroes()) do 
		if ValidTarget(enemy, 600) and not enemy.dead and enemy.visible and Menu.killsteal.enemies[enemy.charName] then
			local useR = Menu.killsteal.killstealR and Rready

			local Qdmg = ((Menu.killsteal.killstealQ and Qready and getDmg("Q", enemy, myHero)) or 0)
			local Qfulldmg = ((Menu.killsteal.killstealQ and Qready and getDmg("Q", enemy, myHero, 3)) or 0)
			local Wdmg = ((Menu.killsteal.killstealW and Wready and getDmg("W", enemy, myHero)) or 0)
			local Edmg = ((Menu.killsteal.killstealE and Eready and getDmg("E", enemy, myHero)) or 0)

			if useW or useE then
				WCast, ECast = GetPredictionReturn(enemy)
			end 

			if Qdmg > Wdmg and WCast ~= nil and Wdmg > enemy.health then
				CastSpell(_W, WCast.x, WCast.z)
				CastSpell(_W)
						if Menu.debug.useDebug then
							print("Entered FIRST of Killsteal on " .. tostring(enemy.charName):upper())
						end 
				break
			elseif Qdmg > enemy.health then
				CastSpell(_Q, enemy)
						if Menu.debug.useDebug then
							print("Entered SECOND of Killsteal on " .. tostring(enemy.charName):upper())
						end 
				break
			elseif ECast ~= nil and Edmg > enemy.health then
				CastSpell(_E, ECast.x, ECast.z)
						if Menu.debug.useDebug then
							print("Entered THIRD of Killsteal on " .. tostring(enemy.charName):upper())
						end
				break
			end 

			if useR and lastActivated == Spells.W.spellname and Qdmg > Wdmg and WCast ~= nil and Wdmg > enemy.health then
				CastSpell(_R, WCast.x, WCast.z)
				CastSpell(_R)
						if Menu.debug.useDebug then
							print("Entered FOURTH of Killsteal on " .. tostring(enemy.charName):upper())
						end
				break
			elseif useR and lastActivated == Spells.Q.spellname and Qdmg > enemy.health then
				CastSpell(_Q, enemy)
						if Menu.debug.useDebug then
							print("Entered FIFTH of Killsteal on " .. tostring(enemy.charName):upper())
						end
				break
			end 
		end 
	end 
end 



-- Obtain a target
function GetOrbTarget()
	ts:update()
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	if SxOrbloaded then return SxOrb:GetTarget() end 
	return ts.target
end 



-- Zhonyas settings: Will be updated and improved
function Zhonyas()
	local zSlot = GetInventorySlotItem(3157)
	if zSlot ~= nil and myHero:CanUseSpell(zSlot) == READY then
		local health = myHero.health
		local mana = myHero.mana
		local maxHealth = myHero.maxHealth
		if (health / maxHealth) <= Menu.misc.zhonyas.zhonyasunder then
			CastSpell(zSlot)
		end 
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
		local hSlot = GetInventorySlotItem(2003)
		if hSlot ~= nil then
			if (h / mH <= Menu.misc.autopotions.health) then
				CastSpell(hSlot)
			end 
		end 
	end
end 

function DrinkMana(m, mM) 
	if not HaveBuff(myHero, "FlaskOfCrystalWater") then
		local mSlot = GetInventorySlotItem(2004)
		if mSlot ~= nil then
			if (m / mM <= Menu.misc.autopotions.mana) then
				CastSpell(mSlot)
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
	if ((myHero.mana / myHero.maxMana) <= Menu.harass.harassMana) then
		return false
	end
	return true 
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
			local Qdmg = ((Qready and getDmg("Q", enemy, myHero)) or 0)
			local QdmgMark = (((Qready and ((Wready and not Spells.W.isActivated) or Eready or Rready)) and getDmg("Q", enemy, myHero, 3)) or 0)
			local Wdmg = ((Wready and not Spells.W.isActivated and getDmg("W", enemy, myHero)) or 0)
			local Edmg = ((Eready and getDmg("E", enemy, myHero)) or 0)


			if Qready and (Wready or Rready or Eready) and QdmgMark + Wdmg + Edmg > enemy.health then
				KillText[i] = "Killable"
			elseif (Wready and Rready) or Eready and Wdmg + Wdmg + Edmg > enemy.health then
				KillText[i] = "Killable" 
			elseif Qdmg > enemy.health then
				KillText[i] = "Killable" 
			elseif Qready or Wready or Eready or Rready then
				KillText[i] = "Harass him!"
			elseif not Qready and not Wready and not Eready and not Rready then
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

	-- Combo
	Menu:addSubMenu(name .. "Combo", "combo")
	Menu.combo:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.combo:addParam("comboWay", "Perform Combo:", SCRIPT_PARAM_LIST, 1, {"Smart", "QRWE", "QWRE", "WQRE", "WRQE"})
	Menu.combo:addParam("comboItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboW", "Use " .. Spells.W.name  .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboE", "Use " .. Spells.E.name  .. " (E)", SCRIPT_PARAM_ONOFF, true)
	Menu.combo:addParam("comboR", "Use " .. Spells.R.name  .. " (R)", SCRIPT_PARAM_ONOFF, true)

	-- W Settings
	Menu:addSubMenu(name .. "Settings: W", "settingsW")
	Menu.settingsW:addParam("useOptional", "Use Optional W Settings", SCRIPT_PARAM_ONOFF, true)
	Menu.settingsW:addParam("useOptionalW", "Return: ", SCRIPT_PARAM_LIST, 1, {"Smart", "Target dead", "Skills used", "Both"})


	 -- Harass
	Menu:addSubMenu(name .. "Harass", "harass")
 	Menu.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.harass:addParam("harassMana", "Mana Manager %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

	-- Farming
	Menu:addSubMenu(name .. "Farming", "farm")
	Menu.farm:addParam("farm", "Farming (K)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
	Menu.farm:addParam("farmQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
	Menu.farm:addParam("farmRange", "Minions outside AA range only", SCRIPT_PARAM_ONOFF, false)
	Menu.farm:addParam("farmAA", "Farm if AA is on CD", SCRIPT_PARAM_ONOFF, false)

	-- LaneClear
	Menu:addSubMenu(name .. "Laneclear", "laneclear")
	Menu.laneclear:addParam("laneclear", "LaneClear (X)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Menu.laneclear:addParam("laneclearQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.laneclear:addParam("laneclearW", "Use " .. Spells.W.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.laneclear:addParam("laneclearR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)

	-- Mixed Mode
	Menu:addSubMenu(name .. "Mixed", "mixed")
	Menu.mixed:addParam("mixed", "Mixed Mode (M)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
	Menu.mixed:addParam("mixedQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.mixed:addParam("mixedW", "Use " .. Spells.W.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu.mixed:addParam("mixedR", "Use " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, false)
	Menu.mixed:addParam("mixedLasthit", "Focus on Last Hit", SCRIPT_PARAM_ONOFF, false)


 	 -- Killsteal
	Menu:addSubMenu(name .. "KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealR", "Use " .. Spells.R.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
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
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawKillable", "Draw Killable Text", SCRIPT_PARAM_ONOFF, true)

 	Menu:addSubMenu(name .. "Prediction", "prediction")
 	if prodLoaded then
 		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "Prodiction"})
 	else
 		Menu.prediction:addParam("usePrediction", "Prediction Type:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction"})
 	end 
 	--Misc
 	Menu:addSubMenu(name .. "Misc", "misc")
 	
 	Menu.misc:addSubMenu("Auto Potions", "autopotions")
 	Menu.misc.autopotions:addParam("usePotion", "Use Potions Automatically", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 	Menu.misc.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)

 	if heal ~= nil then
	Menu.misc:addSubMenu("Auto Heal", "autoheal")
	Menu.misc.autoheal:addParam("useHeal", "Use Summoner Heal", SCRIPT_PARAM_ONOFF, true)
	Menu.misc.autoheal:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
	Menu.misc.autoheal:addParam("helpHeal", "Use Heal to save teammates", SCRIPT_PARAM_ONOFF, false)
	end 

	if ignite ~= nil then
	Menu.misc:addSubMenu("Auto Ignite", "autoignite")
	Menu.misc.autoignite:addParam("useIgnite", "Use Summoner Ignite", SCRIPT_PARAM_ONOFF, true)
	 	for i, enemy in ipairs(GetEnemyHeroes()) do
			Menu.misc.autoignite:addParam(enemy.charName, "Use Ignite On " .. enemy.charName, SCRIPT_PARAM_ONOFF, true)
	 	end 
	end 

	if barrier ~= nil then
	Menu.misc:addSubMenu("Auto Barrier", "autobarrier")
	Menu.misc.autobarrier:addParam("useBarrier", "Use Summoner Barrier", SCRIPT_PARAM_ONOFF, true)
	Menu.misc.autobarrier:addParam("amountOfHealth", "Under % of health", SCRIPT_PARAM_SLICE, 0, 0, 1, 2)
	end 

	Menu.misc:addSubMenu("Zhyonas", "zhonyas")
 	Menu.misc.zhonyas:addParam("zhonyas", "Auto Zhonyas", SCRIPT_PARAM_ONOFF, true)
 	Menu.misc.zhonyas:addParam("zhonyasunder", "Use Zhonyas under % health", SCRIPT_PARAM_SLICE, 0.20, 0, 1 ,2)

	--Orbwalker
	Menu:addSubMenu(name .. "OrbWalker", "orbwalker")
	SxOrb:LoadToMenu(Menu.orbwalker)

	Menu:addSubMenu(name .. "Debug", "debug")
	Menu.debug:addParam("useDebug", "Developer: Debug", SCRIPT_PARAM_ONOFF, false)

	 -- Always show
	 Menu.combo:permaShow("combo")
	 Menu.harass:permaShow("harass")
	 --Menu.killsteal:permaShow("killsteal")
	 Menu.farm:permaShow("farm")
	 Menu.laneclear:permaShow("laneclear")
	 Menu.mixed:permaShow("mixed")
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
	Bready = (barrier ~= nil and myHero:CanUseSpell(barrier) == READY)
	Iready = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	Fready = (flash ~= nil and myHero:CanUseSpell(flash) == READY)
	DFGslot = GetInventorySlotItem(3128)
	ZhonyasSot = GetInventorySlotItem(3157)
	ZhyonasReady = (ZhonyasSot ~= nil and myHero:CanUseSpell(ZhonyasSot))
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


-- Prediction return to make code look cleaner
function GetPredictionReturn(targ)
	-- Normal Prediction
	if Menu.prediction.usePrediction == 1 then

		local castPosE, collE, healthE = NormalEPred:GetPrediction(targ)
		if not collE then
			ECast = castPosE
		end 

		WCast = NormalWPred:GetPrediction(targ)

		return WCast, ECast

	-- VPrediction
	elseif Menu.prediction.usePrediction == 2 then
		ECast = VP:GetLineCastPosition(targ, Spells.E.delay, Spells.E.radius, Spells.E.range, Spells.E.speed, myHero, true)
		
		WCast = VP:GetCircularCastPosition(targ, Spells.W.delay, Spells.W.radius, Spells.W.range, Spells.W.speed)
		
		return WCast, ECast

	-- Prodiction
	elseif prodLoaded and Menu.prediction.usePrediction == 3 then
		
		ECast, info = ProdE:GetPrediction(targ)
		if info.mCollision() then
			ECast = nil
		end 
		
		WCast = ProdW:GetPrediction(targ)
		
		return WCast, ECast
	end

end


--- Smart Combo
function SmartCombo(targ)



	-- Damage to calculate best combo
	local Qdmg = getDmg("Q", targ, myHero) --Mark
	local QdmgProc = getDmg("Q", targ, myHero, 3) -- Mark procced
	local Wdmg = getDmg("W", targ, myHero)
	local Edmg = getDmg("E", targ, myHero)
	local RWdmg = getDmg("R", targ, myHero, 2)

	-- Possible W targets
	local pos, enemies, count = ReturnBestTargetPosition(3, Spells.W.range)


	if pos ~= nil and enemies ~= nil then
		if Menu.combo.comboW and Wready and Menu.combo.comboR and Rready then
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
						print("Found " .. count .. " perfect W targets")
					end 

			if count2 >= 3 then
				CastSpell(_W, pos.x, pos.z)
				CastSpell(_R, pos.x, pos.z)
					if Menu.debug.useDebug then
						print("Performing double W on mid laners/ad carries for perfect TEAMFIGHT")
					end
			end 
		end 
	end

	-- Way of prediction
	local WCast, ECast = GetPredictionReturn(targ)

	-- Actual combo
	if Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready and Menu.combo.comboE and Eready and Menu.combo.comboR and Rready and (QdmgProc + QdmgProc) > (RWdmg + Wdmg) then
		CastSpell(_Q, targ)
		CastSpell(_R, targ)
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered FIRST entry of Smart Combo")
					end 

	elseif Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready and Wready and Menu.combo.comboE and Eready and Menu.combo.comboR and Rready then

		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end
		if WCast ~= nil and not Spells.WR.isActivated then 
			CastSpell(_R, WCast.x, WCast.z)
		end 
		CastSpell(_Q, targ)
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered SECOND entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready and Menu.combo.comboR and Rready and QdmgProc + QdmgProc > Wdmg + Wdmg then
		CastSpell(_Q, targ)
		CastSpell(_R, targ)
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered THIRD entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready and Menu.combo.comboR and Rready then
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
		CastSpell(_R, targ)
		CastSpell(_Q, targ)
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered FOURTH entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready and Menu.combo.comboE and Eready then
		CastSpell(_Q, targ)
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered SIXTH entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboW and Wready then
		CastSpell(_Q, targ)
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered SEVENTH entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboR and Rready then
		CastSpell(_Q, targ)
		CastSpell(_R, targ)
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered 12th entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready and Menu.combo.comboE and Eready then
		CastSpell(_Q, targ)
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered THIRDTEENTH entry of Smart Combo")
					end 
	elseif Menu.combo.comboW and Wready and Menu.combo.comboE and Eready then
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end 
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered FOURTHEENTH entry of Smart Combo")
					end 
	elseif Menu.combo.comboQ and Qready then
		CastSpell(_Q, targ)
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered 15th entry of Smart Combo")
					end 
	elseif Menu.combo.comboW and Wready then
		if WCast ~= nil and not Spells.W.isActivated then
			CastSpell(_W, WCast.x, WCast.z)
		end
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered 16th entry of Smart Combo")
					end 
	elseif Menu.combo.comboE and Eready and lastActivated == Spells.Q.spellname then
		if ECast ~= nil then
			CastSpell(_E, ECast.x, ECast.z)
		end 
					-- Debug settings
					if Menu.debug.useDebug then
						print("Entered 17th entry of Smart Combo")
					end 
	end
end