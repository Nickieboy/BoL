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
local Qspell = {name = "Piercing Arrow", duration = 1.25, speed = 1900, width = 55}
local Qrangemin = 850
local Qrangemax = 1600
local Wspell = {name = "Blighted Quiver"}
local Espell = {name = "Hail Of Arrows", duration = 0, range = 925, speed = 1750, width = 0}
local Rspell = {name = "Chain of Corruption", duration = 0, range = 1075, speed = 1200, width = 100}
local AA = 600
local Qready = (myHero:CanUseSpell(_Q) == READY)
local Eready = (myHero:CanUseSpell(_E) == READY)
local Rready = (myHero:CanUseSpell(_Q) == READY)
local target = nil

-- Load when game loads
function OnLoad()
	VP = VPrediction()
	SOW = SOW(VP)
    print("NVarus succesfully loaded")
	STS = SimpleTS(STS_LESS_CAST_PHYSICAL)

	Menu()


	--Setting skillshots through SourceLib
	Q = Spell(_Q, Qrangemin, true)
	Q:SetSkillshot(VP, SKILLSHOT_LINEAR, Qspell.width, 0, Qspell.speed, false)
	Q:SetCharged("VarusQ", 5, Qrangemax, 2)
	Q:SetAOE(true)

	--Set E
	E = Spell(_E, Espell.range, false)
	Q:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Espell.width, 0.251, Espell.speed, false)
	E:SetAOE(true, 235)

	--Set R
	R = Spell(_R, Rspell.range, false)
	R:SetSkillshot(VP, SKILLSHOT_LINEAR, Rspell.width, 0, Rspell.speed, true)
	R:SetAOE(true)
end

-- Checks frequently
function OnTick()
	if Menu.harass.harass then
		Harass()
	end 
	Combo()
end

-- Checks same with FPS
function OnDraw()

end

function Combo()
end 

function Harass()
	target = STS:GetTarget(Qrangemax)
	if target and Menu.harass.harassQ then
		Q:Charge()
		local prediction = Q:GetPrediction(target)
		--[[while Q:IsCharging() == true do
			if (Q.range == myHero - target) then
				Q:Cast(prediction.x, prediction.z) 
				break
			end 
		end
		]]
		
		if Q:IsCharging() then
			local castPosition, hitChance, nTargets = Q:GetPrediction(target)
			if Q.range ~= Qrangemax and GetDistanceSqr(castPosition) < math.pow(Q.range - 200, 2) or Q.range == Q.rangemax and GetDistanceSqr(castPosition) < math.pow(Q.range, 2) then
			Q:Cast(prediction.x, prediction.z) 
		end 
		
	end 
end 



-- Draw Menu
function Menu()
	Menu = scriptConfig("NVarus by Nickieboy", "NVarus")

	 -- Combo
	Menu:addSubMenu("Combo", "combo")
 	Menu.combo:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 	Menu.combo:addParam("comboQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo:addParam("comboE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo:addParam("comboR", "Use " .. Rspell.name, SCRIPT_PARAM_ONOFF, true)

 	 -- Combo
	Menu:addSubMenu("Harass", "harass")
 	Menu.harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("harassQ", "Use " .. Qspell.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.harass:addParam("harassE", "Use " .. Espell.name .. " (E)", SCRIPT_PARAM_ONOFF, true)

 	 -- Combo
	Menu:addSubMenu("KillSteal", "killsteal")
 	Menu.killsteal:addParam("killsteal", "KillSteal", SCRIPT_PARAM_ONOFF, false)
 	Menu.killsteal:addParam("killstealQ", "Use " .. Qspell.name, SCRIPT_PARAM_ONOFF, true)
 	Menu.killsteal:addParam("killstealE", "Use " .. Espell.name, SCRIPT_PARAM_ONOFF, true)

 	--Misc
 	Menu:addSubMenu("Misc", "misc")
 	Menu.misc:addParam("packetCast", "Use Packets (VIP)", SCRIPT_PARAM_ONOFF, false)

 	Menu.misc:addSubMenu("Gapcloser", "gc")
	AntiGapcloser(Menu.misc.gc)
	Menu.misc:addSubMenu("Interrupter", "ai")
	Interrupter(Menu.misc.ai)

 	Menu:addSubMenu("OrbWalker", "orbwalker")
 	SOW:LoadToMenu(Menu.orbwalker)

	Menu:addSubMenu("Target Selector", "sts")
	STS:AddToMenu(Menu.sts)


  	Menu.combo:permaShow("combo")
  	Menu.harass:permaShow("harass")
  	Menu.killsteal:permaShow("killsteal")

end



