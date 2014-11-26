--[[ Varus Script by Nickieboy
		Script 
]]

if myHero.charName ~= "Varus" then return end

-- Download information

local REQUIRED_LIBS = {
	["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
	["SourceLib"] = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
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

-- Local Variables
local version = 1.00
local author = "Nickieboy"
local Qspell = {name = "Piercing Arrow", duration = 1.25, speed = 1900, width = 60, delay = 0}
local Qrangemin = 850
local Qrangemax = 1800
local Wspell = {name = "Blighted Quiver"}
local Espell = {name = "Hail Of Arrows", duration = 0, range = 925, speed = 1750, width = 50, delay = 0.240}
local Rspell = {name = "Chain of Corruption", duration = 0, range = 1075, speed = 2000, width = 100, delay = 0.250}
local AA = 600
local Qready = (myHero:CanUseSpell(_Q) == READY)
local Eready = (myHero:CanUseSpell(_E) == READY)
local Rready = (myHero:CanUseSpell(_Q) == READY)
local Qtarget, Etarget, Rtarget, AAtarget = nil
local EnemyMinions = minionManager(MINION_ENEMY, 625, myHero, MINION_SORT_HEALTH_ASC)
local farmMinions = 0

local myPos = myHero.pos
local targetPos = nil
local newPos = nil
local newTargetPos = nil


-- Load when game loads
function OnLoad()
	VP = VPrediction()
	SOW = SOW(VP)
	WPManager = WayPointManager()
    print("NVarus succesfully loaded")
	STS = SimpleTS(STS_LESS_CAST_PHYSICAL)

	Menu()


	--Setting skillshots through SourceLib
	Q = Spell(_Q, Qrangemin, true)
	Q:SetSkillshot(VP, SKILLSHOT_LINEAR, Qspell.width, Q.delay, Qspell.speed, false)
	Q:SetCharged("VarusQ", 4, Qrangemax, 1.3)
	Q:SetAOE(true)

	--Set E
	E = Spell(_E, Espell.range, false)
	E:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Espell.width, E.delay, Espell.speed, false)
	E:SetAOE(true)

	--Set R
	R = Spell(_R, Rspell.range, false)
	R:SetSkillshot(VP, SKILLSHOT_LINEAR, Rspell.width, R.delay, Rspell.speed, false)
	R:SetAOE(true)
end

-- Checks frequently
function OnTick()
	if Menu.harass.harass then
		Harass()
	end 
	if Menu.combo.combo then
		Combo()
	end 

	if Menu.misc.skinChanger.skinChanger and skinChanged() then
		GenModelPacket("Varus", Menu.misc.skinChanger.skinChangerSlice)
        lastSkin = Menu.misc.skinChanger.skinChangerSlice
	end 

	if Menu.misc.autopotions.usePotion then
		DrinkPotions()
	end 

	if Menu.laneclear.laneclear then 
		LaneClear()
	end 
end

-- Checks same with FPS
function OnDraw()
	if Menu.drawings.draw then
		if Menu.drawings.drawAA then
			DrawCircle(myHero.x, myHero.y, myHero.z, AA, 0x111111)
		end 

		if Menu.drawings.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, 1200, 0x111111)
		end

		if Menu.drawings.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, Espell.range, 0x111111)
		end

		if Menu.drawings.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, Rspell.range, 0x111111)
		end

	end 
end

function Combo()

	Qtarget = STS:GetTarget(Qrangemax)
	Etarget = STS:GetTarget(Espell.range)
	Rtarget = STS:GetTarget(Rspell.range)
	if Menu.combo then
		if Menu.combo.comboQ then
			if Qtarget and Qready then
				if Q:IsCharging() then

					local castPosition, hitChance, nTargets = Q:GetPrediction(Qtarget)
					if Q.range ~= Qrangemax and GetDistanceSqr(castPosition) < math.pow(Q.range - 200, 2) then
						Send2ndQPacket(castPosition)
					end 
				else
					Q:Charge()
				end 
				
			end
		end 

		if Menu.combo.comboE and not Menu.combo.comboEFurther then
			if Etarget and Eready  then
				E:Cast(Etarget.x, Etarget.z)
			end 
		end 
		if Menu.combo.comboEFurther and not Menu.combo.comboE then
			EnemyMovingFurtherAway(E, 760, Etarget)
			--if IsRunningAway(Etarget) then
			--	if Eready then
			--		E:Cast(Etarget)
			--	end 
			--end 
		end 

		if Menu.combo.comboR then
			if Rtarget and Rready then
				R:Cast(Rtarget)
			end 
		end 
	end
end 

-- Harass
function Harass()
	if Menu.harass.harass then 
		Qtarget = STS:GetTarget(Qrangemax)
		if Qtarget and Menu.harass.harassQ then
			if Q:IsCharging() then
				local castPosition, hitChance, nTargets = Q:GetPrediction(Qtarget)
				if Q.range ~= Qrangemax and GetDistanceSqr(castPosition) < math.pow(Q.range - 200, 2) then
					Send2ndQPacket(castPosition)
				end 
			else
				Q:Charge()
			end 
			
		end 
	end 
end 

--Laneclear
function LaneClear()
	if Menu.laneclear.laneclear then
		EnemyMinions:update()
		if #EnemyMinions.objects >= 3 then
		farmMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) end)
			if Menu.laneclear.laneclearQ and Qready then
				if Q:IsCharging() then
					local farmPos, farmHit = GetBestLineFarmPosition(Qrangemax, Qspell.width, farmMinions)
					if farmPos then
						if Q.range ~= Qrangemax and GetDistanceSqr(farmPos) < math.pow(Q.range - 200, 2) then
							Send2ndQPacket(farmPos)
						end 
					end 
				else
					Q:Charge()
				end 
			end 
		
			if Menu.laneclear.laneclearE and Eready then
				local farmPos2, farmHit2 = GetBestCircularFarmPosition(Espell.range, 50, EnemyMinions.objects)
				if farmHit2 >= 3 then
					E:Cast(farmPos2.x, farmPos2.z)
				end 
			end 
		end 
	end 
end 

function Send2ndQPacket(to)
	local packet = CLoLPacket(0xE6)
	packet:EncodeF(myHero.networkID)
	packet:Encode1(190)
	packet:Encode1(0)
	packet:EncodeF(to.x)
	packet:EncodeF(to.y)
	packet:EncodeF(to.z)
	packet.dwArg1 = 1
	packet.dwArg2 = 0
	SendPacket(packet)
end

function EnemyMovingFurtherAway(spell, range, target)
	print("Entering function")
	if (target and ValidTarget(target, range)) then
		print("Target Valid")
		local distance = GetDistance(target, myHero)
		print("Distance " .. distance)
		DelayAction(function()
			print("Entering delay")
			if (ValidTarget(target, range)) then
				print("Target still valid")
				local newDistance = GetDistance(target, myHero)
				if (newDistance > distance and myHero:CanUseSpell(_E) == READY) then
					E:Cast(target.x, target.z)
				end
			end
		end, 1)
	end
end
--[[function EnemyMovingFurtherAway(range, target) 
	print("Going in function")
	myPos = myHero.pos

	if target then -- Don't need to check if target is valid because STS:GetTarget() does it automatically so you can just make sure it returned something.
		targetPos = target.pos
		--print("myPos = " .. myPos .. "  targetPos = " .. targetPos)
		print("Target = true, going into DelayAction")
		DelayAction(newPosition(target), 0.5)
		print("Ended function")
	end 
end 

function newPosition(target)
if (ValidTarget(target, range)) then --Check to make sure target is valid because if he isn't you WILL be spammed with errors.
				print ("Entered ValidTarget")
				newPos = myHero.pos
				newTargetPos = target.pos

				print("myPos " .. myPos.z)
				print("MyNewPos " .. newPos.z)
				print("oldEnemyPos " .. targetPos.z)
				print("newEnemyPos " .. newTargetPos.z)
				print("OldDistance " .. GetDistance(newTargetPos, newPos))
				print("NewDistance " .. GetDistance(targetPos, myPos))

				if GetDistance(newTargetPos, newPos) >= GetDistance(targetPos, myPos) then
					print("Entered Distance grows bigger")
					if (myHero:CanUseSpell(_E) == READY) then
						print("Casted E")
						E:Cast(target.x, target.z)
					end 
				end
			end
end 
]]
function IsRunningAway(unit)
	local waypoints = WPManager:GetWayPoints(unit)
	if (waypoints and #waypoints > 0) then
		return (GetDistance(waypoints[0], myHero) > GetDistance(unit, myHero))
	else
		return false
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


-- Gapcloser (SourceLib TriggerCallbacks)
function castStunGapClosing(unit, spell)
	if Rready and GetDistance(unit) <= R.range then
		R:Cast(unit)
	end
end 

--Interuptable (SourceLib TriggerCallbacks)
function castStunInterruptable(unit, spell) 
	if Rready and GetDistance(unit) <= R.range then
		R:Cast(unit)
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


-- Draw Menu
function Menu()
	Menu = scriptConfig("NVarus by Nickieboy", "NVarus")

	 -- Combo
	Menu:addSubMenu("Combo", "combo")
 	Menu.combo:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 	Menu.combo:addParam("comboQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo:addParam("comboE", "Use " .. Espell.name .. " (E) instantly", SCRIPT_PARAM_ONOFF, false)
 	Menu.combo:addParam("comboEFurther", "Use " .. Espell.name .. " (E) not instantly", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo:addParam("EFurther", "E Further", SCRIPT_PARAM_INFO, "^ Only use E when enemy goes further away")
 	Menu.combo:addParam("comboR", "Use " .. Rspell.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	 -- Harass
	Menu:addSubMenu("Harass", "harass")
 	Menu.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("harassQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)

 	Menu:addSubMenu("LaneClear", "laneclear")
 	Menu.laneclear:addParam("laneclear", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("U"))
 	Menu.laneclear:addParam("laneclearQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addParam("laneclearE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)

 	 -- Combo
	Menu:addSubMenu("KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Qspell.name, SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealE", "Use " .. Espell.name, SCRIPT_PARAM_ONOFF, true)

 	--Orbwalker
 	Menu:addSubMenu("OrbWalker", "orbwalker")
 	SOW:LoadToMenu(Menu.orbwalker)

 	--Drawings
 	Menu:addSubMenu("Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, false)
 	Menu.drawings:addParam("drawAA", "Draw Attack Speed", SCRIPT_PARAM_ONOFF, false)
 	Menu.drawings:addParam("drawQ", "Draw " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, false)
 	Menu.drawings:addParam("drawE", "Draw " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, false)
 	Menu.drawings:addParam("drawR", "Draw " .. Rspell.name .. " (R)", SCRIPT_PARAM_ONOFF, false)

 	--Misc
 	Menu:addSubMenu("Misc", "misc")
 	
 	Menu.misc:addSubMenu("Auto Potions", "autopotions")
 	Menu.misc.autopotions:addParam("usePotion", "Use Potions Automatically", SCRIPT_PARAM_ONOFF, false)
 	Menu.misc.autopotions:addParam("health", "Health under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 	Menu.misc.autopotions:addParam("mana", "Mana under %", SCRIPT_PARAM_SLICE, 0.25, 0, 1, 2)
 	
 	Menu.misc:addSubMenu("Skin Changer", "skinChanger")
 	Menu.misc.skinChanger:addParam("skinChanger", "Change Skin (VIP", SCRIPT_PARAM_ONOFF, false)
 	Menu.misc.skinChanger:addParam("skinChangerSlice", "Change Skin", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)

 	Menu.misc:addSubMenu("Gapcloser", "gc")
	AntiGapcloser(Menu.misc.gc, castStunGapClosing)
	Menu.misc:addSubMenu("Interrupter", "ai")
	Interrupter(Menu.misc.ai, castStunInterruptable)


	Menu:addSubMenu("Target Selector", "sts")
	STS:AddToMenu(Menu.sts)


  	Menu.combo:permaShow("combo")
  	Menu.harass:permaShow("harass")
  	Menu.killsteal:permaShow("killsteal")

end



