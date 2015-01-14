--[[
		Library designed to make my live easier
		Simply automatically integrates things I have in all my scripts to make life easier.
		It reduces code in my own scripts and makes it more readable.


		Changelog:
			* 0.1:
				Release

			* 0.2:
				Fixed a typo (unit > target)

			* 0.22
				Few more bug fixes

--]]

local version = 0.22
local AUTO_UPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/lib/TotallyLib.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = LIB_PATH.."TotallyLib.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>TotallyLib:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTO_UPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/TotallyLib.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available (v"..ServerVersion .. ")")
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

_G.TotallyLib_Loaded = true



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
end 


function MenuMisc:DrinkPotions()
	if not TargetHaveBuff("RegenerationPotion", myHero) and not self.isRecalling and not InFountain() then
		local healthSlot = GetInventorySlotItem(2003)
		if healthSlot ~= nil then
			if (myHero.health / myHero.maxHealth <= self.menu.autopotions.health) then
				CastSpell(healthSlot)
			end 
		end 
	end
	if not TargetHaveBuff("FlaskOfCrystalWater", myHero) and not self.isRecalling and not InFountain() then
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
	if obj.name:find("TeleportHome.troy") then
		if GetDistance(obj) <= 70 then
			self.isRecalling = true
		end
	end
end

function MenuMisc:OnDeleteObj(obj)
	if obj.name:find("TeleportHome.troy") then
		if GetDistance(obj) <= 70 then
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


ccobjectlist = {
				["LOC_fear.troy"] = "Fear",
				["LOC_Silence"] = "Silence",
				["LOC_Surpress"] = "Surpression"
				}



class 'Summoners'

function Summoners:__init(menu)

	self.enemyNames = {}

	self:UpdateSummoners()

	if menu then
		self:LoadToMenu(menu)
	end

	AddTickCallback(function() self:OnTick() end)
	AddCreateObjCallback(function(obj) self:OnCreateObj(obj) end)
	if VIP_USER then
		AdvancedCallback:bind("GainBuff", function(unit, buff) self:OnGainBuff(unit, buff) end)
	end 


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
		if VIP_USER then
			for i, enemy in ipairs(GetEnemyHeroes()) do
				table.insert(self.enemyNames, enemy.charName)
			end 
			local oneAdded = false
			for buff, data in pairs(bufflist) do
				if table.contains(self.enemyNames, data.charName) then
					oneAdded = true
					self.menu.autocleanse:addParam(buff, data.spellname .. " - " .. data.charName .. " (" .. data.spell .. ")", SCRIPT_PARAM_ONOFF, true)
				end
			end 
			if not oneAdded then
				self.menu.autocleanse:addParam("info", "ERROR", SCRIPT_PARAM_INFO, "No buffs found to be added")
			end 
		else
			for object, stuff in pairs(ccobjectlist) do
				self.menu.autocleanse:addParam(object, object .. " - " .. stuff, SCRIPT_PARAM_ONOFF, true)
			end
		end 
	end 
end

function Summoners:OnGainBuff(unit, buff)
	if VIP_USER and self.cleanse ~= nil and self.menu.autocleanse.useCleanse and self.menu.autocleanse[buff.name] and unit.isMe then
		if IsSpellReady(self.cleanse) then
			CastSpell(self.cleanse)
		end 
	end 
end

function Summoners:OnCreateObj(obj)
	if not VIP_USER and self.cleanse ~= nil and self.menu.autocleanse.useCleanse and self.menu.autocleanse[obj.name] and GetDistanceSqr(obj) < 2500 then
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
	self:IgniteDamage()
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
		if ((myHero.health / myHero.maxHealth) <= Menu.misc.autobarrier.amountOfHealth) then
			CastSpell(self.barrier)
		end 
	end 
end


function Summoners:OnTick()
	if self.heal ~= nil and self.menu.autoheal.useHeal then self:UseHeal() end
	if self.ignite ~= nil and self.menu.autoignite.useIgnite then self:Ignite() end 
	if self.barrier ~= nil and self.menu.autobarrier.useBarrier then self:Barrier()	end
end




class 'SpellHelper'

function SpellHelper:__init(VP, menu)
	self.Spells = {}
	if VP and menu then
		self.Predict = PredictionHelper(VP, menu)
	end
end

function SpellHelper:AddSpell(slot, range)
	self.Spells[slot] = {slot = slot, range = range, skillShot = false}
end

function SpellHelper:AddSkillShot(slot, range, delay, width, speed, collision, typeSkill)
	self.Spells[slot] = {slot = slot, range = range, delay = delay, width = width, speed = speed, collision = collision, typeSkill = typeSkill, skillShot = true}
end

function SpellHelper:Ready(slot)
	return IsSpellReady(self.Spells[slot].slot)
end 

function SpellHelper:InRange(slot, target)
	return GetDistanceSqr(target) < self.Spells[slot].range * self.Spells[slot].range
end

function SpellHelper:Cast(slot, target, value)

	if self.Spells[slot].skillShot then
		local castPosition = self.Predict:PredictSpell(target, self.Spells[slot].delay, self.Spells[slot].width, self.Spells[slot].range, self.Spells[slot].speed, self.Spells[slot].collision, self.Spells[slot].typeSkill)
		if castPosition ~= nil and self:Ready(self.Spells[slot].slot) and self:InRange(self.Spells[slot].slot, target) then
			CastSpell(self.Spells[slot].slot, castPosition.x, castPosition.z)
		end
	else
		if not value and target then
			if self:Ready(self.Spells[slot].slot) and self:InRange(self.Spells[slot].slot, target) then
				CastSpell(self.Spells[slot].slot, target)
			end
		elseif value and target then
			if self:Ready(self.Spells[slot].slot) and self:InRange(self.Spells[slot].slot, target) then
				CastSpell(self.Spells[slot].slot, target.x, value.z)
			end
		end
	end
end

function SpellHelper:CastAll(target, value)
	for i, info in ipairs(self.Spells) do
		self:Cast(info.slot, target, value)
	end
end

class 'PredictionHelper'
function PredictionHelper:__init(VP, menu)
	self.VP = VP
	if menu then
		self:LoadToMenu(menu)
	end
end

function PredictionHelper:LoadToMenu(Menu)
	Menu:addSubMenu("Prediction Type", "prediction")
	if VIP_USER and FileExist(LIB_PATH.."Prodiction.lua") then
		Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction", "Prodiction"})
	elseif self.VP then
		Menu.prediction:addParam("type", "Prediction:", SCRIPT_PARAM_LIST, 2, {"Normal", "VPrediction"})
	end
	Menu.prediction:addParam("hitchance", "Hitchance", SCRIPT_PARAM_LIST, 2, {"Low hitchance", "High HitChance", "Slowed", "Immobile"})
	
	self.menu = Menu
end

function PredictionHelper:PredictSpell(target, delay, radius, range, speed, collision, typeSkill)
	if self.menu.prediction.type == 1 then
		local castPosition, coll = TargetPrediction(range, speed, delay, radius):GetPrediction(target)
		if collision == true and not coll then
			return castPosition
		elseif not collision then
			return castPosition
		end 
	elseif self.menu.prediction.type == 2 then
		if typeSkill == "circaoe" then
			local castPosition, hitChance = self.VP:GetCircularAOECastPosition(target, delay, radius, range, speed, myHero, collision)
			if hitChance >= self.menu.prediction.hitchance then
				return castPosition
			end
		elseif typeSkill == "lineaoe" then
			local castPosition, hitChance = self.VP:GetLineAOECastPosition(target, delay, radius, range, speed, myHero)
		elseif typeSkill == "line" then
			local castPosition, hitChance = self.VP:GetCircularCastPosition(target, delay, radius, range, speed, myHero, collision)
			if hitChance >= self.menu.prediction.hitchance then
				return castPosition
			end
		elseif typeSkill == "circ" then
			local castPosition, hitChance = self.VP:GetCircularCastPosition(target, delay, radius, range, speed, myHero, collision)
			if hitChance >= self.menu.prediction.hitchance then
				return castPosition
			end
		end
	elseif self.menu.prediction.type == 3 then
		if typeSkill == "circaoe" then
			local castPosition, info = Prodiction.GetCircularAOEPrediction(target, range, speed, delay, radius, myHero)
			if collision and not info.mCollision() then
				return castPosition
			end
			if not collision then
				return castPosition
			end 
		elseif typeSkill == "lineaoe" then
			local castPosition, info = Prodiction.GetLineAOEPrediction(target, range, speed, delay, width, myHero)
			if collision and not info.mCollision() then
				return castPosition
			end
			if not collision then
				return castPosition
			end
		elseif typeSkill == "line" then
			local castPosition, info = Prodiction.GetPrediction(target, range, speed, delay, width, source)
			if collision and not info.mCollision() then
				return castPosition
			end
			if not collision then
				return castPosition
			end
		elseif typeSkill == "circ" then
			local castPosition, info = Prodiction.GetCircularCastPosition(target, delay, radius, range, speed, myHero, collision)
			if collision and not info.mCollision() then
				return castPosition
			end
			if not collision then
				return castPosition
			end
		end
	end
	return nil
end 


itemlist = {
	["Athene's Unholy Grail"] = 3174,
	["Avarice Blade"] = 3093,
	["Blade of The Ruined King"] = 3153,
	["bortk"] = 3153,
	["Crystalline Flask"] = 2041,
	["Deathire Grasp"] = 3128,
	["DFG"] = 3124,
	["Dervish Blade"] = 3137,
	["Zhonya's Hourglass"] = 3157,
	["zhonyas"] = 3003,
	["zhonya's"] = 3003,
	["Randuin's Omen"] = 3143,
	["Hextech Gunblade"] = 3146,
	["Bilgdewater Cutlass"] = 3144,
	["Ravenous Hydra"] = 3074,
	["hydra"] = 3074,
	["Tiamat"] = 3077,
	["Youmuu's Ghostblade"] = 3142,
	["Blackfire Torch"] = 3188,
	["Health Potion"] = 2003,
	["Mana Potion"] = 2004,
	["Ichor of Rage"] = "",
	["Oracle's Extract"] = 2047,
	["Stealth Ward"] = 2044,
	["Vision Ward"] = 2043,
	["Sightstone"] = 2049,
	["Ruby Sightstone"] = 2045,
	["Total Biscuit of Rejuvenation"] = 2009
}


class 'ItemHelper'
function ItemHelper:__init(name)
	self.name = name
	self.id = self.list[name]
end


function ItemHelper:GetId()
	if self.id then
		return self.id
	end
end

function ItemHelper:IsCastable()
	if self.id then
		return GetInventoryItemIsCastable(self.id)
	end
end

function ItemHelper:GetSlot()
	if self.id then
		return GetInventorySlotItem(self.id)
	end
end







function IsSpellReady(spell)
	return myHero:CanUseSpell(spell) == READY
end

-- Thank you Hellsing/Honda for the idea of this, save so much lines and makes everything much smoother
function GetSummonerSlot(name)
	return ((myHero:GetSpellData(SUMMONER_1).name:find(name) and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find(name) and SUMMONER_2))
end



-- Return number of Ally in range
function CountAllyHeroInRange(range, object)
	assert(range and type(range) == "number", "TotallyLib: Invalid range. Range must be specified AND it must be a number")
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


--[[
		Returns Vector object in a certain position (Useful for: Flash, Orbwalk within mouse range, Gapclosing...)
		@param target 	--- 	Must be target or the largest position of what you are trying to achieve
		@param range 	--- 	Must be range between you and possible newPosition (Not range between you & target)
		@param Source 	--- 	Must be a source, either myHero or a different
--]]
function VectorHelper(target, range, source)
	return (Vector(source.visionPos) + (Vector(target) - source.visionPos):normalized() * range)
end


--[[
	Calculates the position to hit as many objects as possible within a recent radius limited between a range
	Returns the position (of the object)
	Returns the count (Of many objects it will hit)
--]]
function GetBestAOEPosition(objects, range, radius, source)
	assert(objects and type(objects) == "table", "TotallyLib: Invalid Objects in function GetBestAOEPosition")
	local pos = nil 
	local count2 = 0
	local source = source or myHero
	local range = (range and range * range) or myHero.range * myHero.range

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

function CountEnemies(min_targets, range)
	local min_targets = min_targets and min_targets or 0
	assert(type(min_targets) == "number", "TotallyLib: First Parameter must be a number")
	local count, enemies, pos = 0, {}, nil
	local range = (range and range * range) or (myHero.range * myHero.range)

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


--[[ Calculates all minions that can be killed through a spell
	Damage is calculated through Spell Damage Library (Build-in)
	
	Returns the minions as a table

-- ]]
function GetKillableMinions(minionTable, range, spell, source)
	assert(spell == _Q or spell == _W or spell == _E, "TotallyLib: Correct spell not detected")
	assert(minionTable and type(minionTable) == "table", "TotallyLib: Invalid table in: minionTable, first parameter")
	assert(source == myHero.type, "TotallyLib: Invalid Source. The type must be obj_AI_Hero")

	local range = range and range * range or myHero
	local minions = {}
	local source = source or myHero
	local dmg = 0
	for i, minion in ipairs(minionTable) do
		if GetDistanceSqr(minion) < range then
			if spell == _AA then
				dmg = CalcDamage(minion, myHero.damage)
			elseif spell == _Q then
				dmg = CalcMagicDamage(minion, getDmg("Q", minion, source))
			elseif spell == _W then
				dmg = CalcMagicDamage(minion, getDmg("W", minion, source)) 
			elseif spell == _E then
				dmg = CalcMagicDamage(minion, getDmg("E", minion, source))
			end 
			if minion.health < dmg then
				table.insert(minions, minion)
			end 
		end 
	end 
	return minions
end 


function CountMinions(objectTable, range)
	assert(objectTable and type(objectTable) == "table", "TotallyLib: Invalid table in: objectTable, first parameter")
	local range = range and range * range or myHero.range * myHero.range
    local count = 0
    for i, object in ipairs(objectTable) do
        if ValidTarget(object) and GetDistanceSqr(myHero, object) <= range then
            count = count + 1
        end
    end
    return count
end  