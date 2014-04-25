--[[--------------------------------------------------------------------
    Ovale Spell Priority
    Copyright (C) 2013 Johnny C. Lam

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License in the LICENSE
    file accompanying this program.
--]]--------------------------------------------------------------------

local _, Ovale = ...

do
	local OvaleCondition = Ovale.OvaleCondition
	local OvaleData = Ovale.OvaleData
	local OvaleState = Ovale.OvaleState

	local Compare = OvaleCondition.Compare
	local ComputeParameter = OvaleCondition.ComputeParameter
	local ParseCondition = OvaleCondition.ParseCondition
	local state = OvaleState.state

	-- Return the non-critical-strike damage of a spell, given the player's current stats.
	local function GetDamage(spellId)
		-- TODO: Use target's debuffs in this calculation.
		local ap = state.snapshot.attackPower or 0
		local sp = state.snapshot.spellBonusDamage or 0
		local mh = state.snapshot.mainHandWeaponDamage or 0
		local oh = state.snapshot.offHandWeaponDamage or 0
		local bdm = state.snapshot.baseDamageMultiplier or 1
		local dm = state:GetDamageMultiplier(spellId) or 1
		local combo = state.combo or 0
		return OvaleData:GetDamage(spellId, ap, sp, mh, oh, combo) * bdm * dm
	end

	-- Return the damage reduction from armor, assuming the target is boss-level.
	local BOSS_ARMOR = 24835
	local WEAKENED_ARMOR_DEBUFF = 113746

	local function BossArmorDamageReduction(target)
		local aura = state:GetAura(target, WEAKENED_ARMOR_DEBUFF, "HARMFUL")
		local armor = BOSS_ARMOR
		if state:IsActiveAura(aura) then
			armor = armor * (1 - 0.04 * aura.stacks)
		end
		local constant = 4037.5 * state.level - 317117.5
		if constant < 0 then
			constant = 0
		end
		return armor / (armor + constant)
	end

	--- Get the current estimated damage of a spell on the target if it is a critical strike.
	-- @name CritDamage
	-- @paramsig number or boolean
	-- @param id The spell ID.
	-- @param operator Optional. Comparison operator: less, atMost, equal, atLeast, more.
	-- @param number Optional. The number to compare against.
	-- @param target Optional. Sets the target to check. The target may also be given as a prefix to the condition.
	--     Defaults to target=player.
	--     Valid values: player, target, focus, pet.
	-- @return The estimated critical strike damage of the given spell.
	-- @return A boolean value for the result of the comparison.
	-- @see Damage, LastDamage, LastEstimatedDamage

	local function CritDamage(condition)
		local spellId, comparator, limit = condition[1], condition[2], condition[3]
		local target = ParseCondition(condition, "target")
		local value = ComputeParameter(spellId, "damage", state)
		if not value then
			value = GetDamage(spellId)
		end
		-- Reduce by armor damage reduction for physical attacks.
		local si = OvaleData:GetSpellInfo(spellId)
		if si and si.physical then
			value = value * (1 - BossArmorDamageReduction(target))
		end
		-- TODO: Need to account for increased crit effect from meta-gems.
		local critFactor = 2
		local value = critFactor * value
		return Compare(value, comparator, limit)
	end

	OvaleCondition:RegisterCondition("critdamage", false, CritDamage)

	--- Get the current estimated damage of a spell on the target.
	-- The calculated damage takes into account the current attack power, spellpower, weapon damage and combo points (if used).
	-- The damage is computed from information for the spell set via SpellInfo(...):
	--
	-- damage = base + bonusmainhand * MH + bonusoffhand * OH + bonusap * AP + bonuscp * CP + bonusapcp * AP * CP + bonussp * SP
	-- @name Damage
	-- @paramsig number or boolean
	-- @param id The spell ID.
	-- @param operator Optional. Comparison operator: less, atMost, equal, atLeast, more.
	-- @param number Optional. The number to compare against.
	-- @param target Optional. Sets the target to check. The target may also be given as a prefix to the condition.
	--     Defaults to target=player.
	--     Valid values: player, target, focus, pet.
	-- @return The estimated damage of the given spell on the target.
	-- @return A boolean value for the result of the comparison.
	-- @see CritDamage, LastDamage, LastEstimatedDamage
	-- @usage
	-- if {target.Damage(rake) / target.LastEstimateDamage(rake)} >1.1
	--     Spell(rake)

	local function Damage(condition)
		local spellId, comparator, limit = condition[1], condition[2], condition[3]
		local target = ParseCondition(condition, "target")
		local value = ComputeParameter(spellId, "damage", state)
		if not value then
			value = GetDamage(spellId)
		end
		-- Reduce by armor damage reduction for physical attacks.
		local si = OvaleData:GetSpellInfo(spellId)
		if si and si.physical then
			value = value * (1 - BossArmorDamageReduction(target))
		end
		return Compare(value, comparator, limit)
	end

	OvaleCondition:RegisterCondition("damage", false, Damage)
end
