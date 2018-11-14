local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "sc_pr_shaman_elemental"
    local desc = "[8.0] Simulationcraft: PR_Shaman_Elemental"
    local code = [[
# Based on SimulationCraft profile "PR_Shaman_Elemental".
#	class=shaman
#	spec=elemental
#	talents=2303023

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=elemental)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=elemental)
AddCheckBox(opt_bloodlust SpellName(bloodlust) specialization=elemental)

AddFunction ElementalInterruptActions
{
 if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
 {
  if target.InRange(wind_shear) and target.IsInterruptible() Spell(wind_shear)
  if not target.Classification(worldboss) and target.RemainingCastTime() > 2 Spell(capacitor_totem)
  if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
  if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
  if target.InRange(hex) and not target.Classification(worldboss) and target.RemainingCastTime() > CastTime(hex) + GCDRemaining() and target.CreatureType(Humanoid Beast) Spell(hex)
 }
}

AddFunction ElementalUseItemActions
{
 Item(Trinket0Slot text=13 usable=1)
 Item(Trinket1Slot text=14 usable=1)
}

AddFunction ElementalBloodlust
{
 if CheckBoxOn(opt_bloodlust) and DebuffExpires(burst_haste_debuff any=1)
 {
  Spell(bloodlust)
  Spell(heroism)
 }
}

### actions.single_target

AddFunction ElementalSingletargetMainActions
{
 #flame_shock,if=!ticking|dot.flame_shock.remains<=gcd|talent.ascendance.enabled&dot.flame_shock.remains<(cooldown.ascendance.remains+buff.ascendance.duration)&cooldown.ascendance.remains<4&(!talent.storm_elemental.enabled|talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120)
 if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() or Talent(ascendance_talent) and target.DebuffRemaining(flame_shock_debuff) < SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) < 4 and { not Talent(storm_elemental_talent) or Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 } Spell(flame_shock)
 #elemental_blast,if=talent.elemental_blast.enabled&(talent.master_of_the_elements.enabled&buff.master_of_the_elements.up&maelstrom<60|!talent.master_of_the_elements.enabled)
 if Talent(elemental_blast_talent) and { Talent(master_of_the_elements_talent) and BuffPresent(master_of_the_elements_buff) and Maelstrom() < 60 or not Talent(master_of_the_elements_talent) } Spell(elemental_blast)
 #earthquake,if=active_enemies>1&spell_targets.chain_lightning>1&!talent.exposed_elements.enabled
 if Enemies() > 1 and Enemies() > 1 and not Talent(exposed_elements_talent) Spell(earthquake)
 #lightning_bolt,if=talent.exposed_elements.enabled&debuff.exposed_elements.up&maelstrom>=60&!buff.ascendance.up
 if Talent(exposed_elements_talent) and target.DebuffPresent(exposed_elements_debuff) and Maelstrom() >= 60 and not BuffPresent(ascendance_elemental_buff) Spell(lightning_bolt_elemental)
 #earth_shock,if=talent.master_of_the_elements.enabled&(buff.master_of_the_elements.up|maelstrom>=92)|!talent.master_of_the_elements.enabled
 if Talent(master_of_the_elements_talent) and { BuffPresent(master_of_the_elements_buff) or Maelstrom() >= 92 } or not Talent(master_of_the_elements_talent) Spell(earth_shock)
 #lightning_bolt,if=buff.wind_gust.stack>=14&!buff.lava_surge.up
 if BuffStacks(wind_gust_buff) >= 14 and not BuffPresent(lava_surge_buff) Spell(lightning_bolt_elemental)
 #lava_burst,if=cooldown_react|buff.ascendance.up
 if not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) Spell(lava_burst)
 #flame_shock,target_if=refreshable
 if target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #totem_mastery,if=talent.totem_mastery.enabled&(buff.resonance_totem.remains<6|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15))
 if Talent(totem_mastery_talent_elemental) and { TotemRemaining(totem_mastery_elemental) < 6 or TotemRemaining(totem_mastery_elemental) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } Spell(totem_mastery_elemental)
 #frost_shock,if=talent.icefury.enabled&buff.icefury.up
 if Talent(icefury_talent) and BuffPresent(icefury_buff) Spell(frost_shock)
 #lava_beam,if=talent.ascendance.enabled&active_enemies>1&spell_targets.lava_beam>1
 if Talent(ascendance_talent) and Enemies() > 1 and Enemies() > 1 Spell(lava_beam)
 #chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
 if Enemies() > 1 and Enemies() > 1 Spell(chain_lightning_elemental)
 #lightning_bolt
 Spell(lightning_bolt_elemental)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #flame_shock,moving=1,if=movement.distance>6
 if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
 #frost_shock,moving=1
 if Speed() > 0 Spell(frost_shock)
}

AddFunction ElementalSingletargetMainPostConditions
{
}

AddFunction ElementalSingletargetShortCdActions
{
 unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() or Talent(ascendance_talent) and target.DebuffRemaining(flame_shock_debuff) < SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) < 4 and { not Talent(storm_elemental_talent) or Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 } } and Spell(flame_shock) or Talent(elemental_blast_talent) and { Talent(master_of_the_elements_talent) and BuffPresent(master_of_the_elements_buff) and Maelstrom() < 60 or not Talent(master_of_the_elements_talent) } and Spell(elemental_blast)
 {
  #stormkeeper,if=talent.stormkeeper.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
  if Talent(stormkeeper_talent) and { 0 < 3 or 600 > 50 } Spell(stormkeeper)
  #liquid_magma_totem,if=talent.liquid_magma_totem.enabled&(raid_event.adds.count<3|raid_event.adds.in>50)
  if Talent(liquid_magma_totem_talent) and { 0 < 3 or 600 > 50 } Spell(liquid_magma_totem)

  unless Enemies() > 1 and Enemies() > 1 and not Talent(exposed_elements_talent) and Spell(earthquake) or Talent(exposed_elements_talent) and target.DebuffPresent(exposed_elements_debuff) and Maelstrom() >= 60 and not BuffPresent(ascendance_elemental_buff) and Spell(lightning_bolt_elemental) or { Talent(master_of_the_elements_talent) and { BuffPresent(master_of_the_elements_buff) or Maelstrom() >= 92 } or not Talent(master_of_the_elements_talent) } and Spell(earth_shock) or BuffStacks(wind_gust_buff) >= 14 and not BuffPresent(lava_surge_buff) and Spell(lightning_bolt_elemental) or { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } and Spell(lava_burst) or target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Talent(totem_mastery_talent_elemental) and { TotemRemaining(totem_mastery_elemental) < 6 or TotemRemaining(totem_mastery_elemental) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Talent(icefury_talent) and BuffPresent(icefury_buff) and Spell(frost_shock)
  {
   #icefury,if=talent.icefury.enabled
   if Talent(icefury_talent) Spell(icefury)
  }
 }
}

AddFunction ElementalSingletargetShortCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() or Talent(ascendance_talent) and target.DebuffRemaining(flame_shock_debuff) < SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) < 4 and { not Talent(storm_elemental_talent) or Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 } } and Spell(flame_shock) or Talent(elemental_blast_talent) and { Talent(master_of_the_elements_talent) and BuffPresent(master_of_the_elements_buff) and Maelstrom() < 60 or not Talent(master_of_the_elements_talent) } and Spell(elemental_blast) or Enemies() > 1 and Enemies() > 1 and not Talent(exposed_elements_talent) and Spell(earthquake) or Talent(exposed_elements_talent) and target.DebuffPresent(exposed_elements_debuff) and Maelstrom() >= 60 and not BuffPresent(ascendance_elemental_buff) and Spell(lightning_bolt_elemental) or { Talent(master_of_the_elements_talent) and { BuffPresent(master_of_the_elements_buff) or Maelstrom() >= 92 } or not Talent(master_of_the_elements_talent) } and Spell(earth_shock) or BuffStacks(wind_gust_buff) >= 14 and not BuffPresent(lava_surge_buff) and Spell(lightning_bolt_elemental) or { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } and Spell(lava_burst) or target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Talent(totem_mastery_talent_elemental) and { TotemRemaining(totem_mastery_elemental) < 6 or TotemRemaining(totem_mastery_elemental) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Talent(icefury_talent) and BuffPresent(icefury_buff) and Spell(frost_shock) or Talent(ascendance_talent) and Enemies() > 1 and Enemies() > 1 and Spell(lava_beam) or Enemies() > 1 and Enemies() > 1 and Spell(chain_lightning_elemental) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock) or Speed() > 0 and Spell(frost_shock)
}

AddFunction ElementalSingletargetCdActions
{
 unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() or Talent(ascendance_talent) and target.DebuffRemaining(flame_shock_debuff) < SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) < 4 and { not Talent(storm_elemental_talent) or Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 } } and Spell(flame_shock)
 {
  #ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!talent.storm_elemental.enabled
  if Talent(ascendance_talent) and { TimeInCombat() >= 60 or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(lava_burst) > 0 and not Talent(storm_elemental_talent) and BuffExpires(ascendance_elemental_buff) Spell(ascendance_elemental)
  #ascendance,if=talent.ascendance.enabled&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&cooldown.storm_elemental.remains<=120
  if Talent(ascendance_talent) and { TimeInCombat() >= 60 or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(lava_burst) > 0 and SpellCooldown(storm_elemental) <= 120 and BuffExpires(ascendance_elemental_buff) Spell(ascendance_elemental)
 }
}

AddFunction ElementalSingletargetCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() or Talent(ascendance_talent) and target.DebuffRemaining(flame_shock_debuff) < SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) < 4 and { not Talent(storm_elemental_talent) or Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 } } and Spell(flame_shock) or Talent(elemental_blast_talent) and { Talent(master_of_the_elements_talent) and BuffPresent(master_of_the_elements_buff) and Maelstrom() < 60 or not Talent(master_of_the_elements_talent) } and Spell(elemental_blast) or Talent(stormkeeper_talent) and { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or Talent(liquid_magma_totem_talent) and { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or Enemies() > 1 and Enemies() > 1 and not Talent(exposed_elements_talent) and Spell(earthquake) or Talent(exposed_elements_talent) and target.DebuffPresent(exposed_elements_debuff) and Maelstrom() >= 60 and not BuffPresent(ascendance_elemental_buff) and Spell(lightning_bolt_elemental) or { Talent(master_of_the_elements_talent) and { BuffPresent(master_of_the_elements_buff) or Maelstrom() >= 92 } or not Talent(master_of_the_elements_talent) } and Spell(earth_shock) or BuffStacks(wind_gust_buff) >= 14 and not BuffPresent(lava_surge_buff) and Spell(lightning_bolt_elemental) or { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } and Spell(lava_burst) or target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Talent(totem_mastery_talent_elemental) and { TotemRemaining(totem_mastery_elemental) < 6 or TotemRemaining(totem_mastery_elemental) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Talent(icefury_talent) and BuffPresent(icefury_buff) and Spell(frost_shock) or Talent(icefury_talent) and Spell(icefury) or Talent(ascendance_talent) and Enemies() > 1 and Enemies() > 1 and Spell(lava_beam) or Enemies() > 1 and Enemies() > 1 and Spell(chain_lightning_elemental) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock) or Speed() > 0 and Spell(frost_shock)
}

### actions.precombat

AddFunction ElementalPrecombatMainActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #totem_mastery
 if InCombat() or not BuffPresent(ele_resonance_totem_buff) Spell(totem_mastery_elemental)
 #elemental_blast
 Spell(elemental_blast)
}

AddFunction ElementalPrecombatMainPostConditions
{
}

AddFunction ElementalPrecombatShortCdActions
{
}

AddFunction ElementalPrecombatShortCdPostConditions
{
 { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Spell(elemental_blast)
}

AddFunction ElementalPrecombatCdActions
{
 unless { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental)
 {
  #fire_elemental
  Spell(fire_elemental)
  #potion
  if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 }
}

AddFunction ElementalPrecombatCdPostConditions
{
 { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Spell(elemental_blast)
}

### actions.aoe

AddFunction ElementalAoeMainActions
{
 #flame_shock,if=spell_targets.chain_lightning<4,target_if=refreshable
 if Enemies() < 4 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earthquake
 Spell(earthquake)
 #lava_burst,if=(buff.lava_surge.up|buff.ascendance.up)&spell_targets.chain_lightning<4
 if { BuffPresent(lava_surge_buff) or BuffPresent(ascendance_elemental_buff) } and Enemies() < 4 Spell(lava_burst)
 #elemental_blast,if=talent.elemental_blast.enabled&spell_targets.chain_lightning<4
 if Talent(elemental_blast_talent) and Enemies() < 4 Spell(elemental_blast)
 #lava_beam,if=talent.ascendance.enabled
 if Talent(ascendance_talent) Spell(lava_beam)
 #chain_lightning
 Spell(chain_lightning_elemental)
 #lava_burst,moving=1,if=talent.ascendance.enabled
 if Speed() > 0 and Talent(ascendance_talent) Spell(lava_burst)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #frost_shock,moving=1
 if Speed() > 0 Spell(frost_shock)
}

AddFunction ElementalAoeMainPostConditions
{
}

AddFunction ElementalAoeShortCdActions
{
 #stormkeeper,if=talent.stormkeeper.enabled
 if Talent(stormkeeper_talent) Spell(stormkeeper)
 #liquid_magma_totem,if=talent.liquid_magma_totem.enabled
 if Talent(liquid_magma_totem_talent) Spell(liquid_magma_totem)
}

AddFunction ElementalAoeShortCdPostConditions
{
 Enemies() < 4 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or { BuffPresent(lava_surge_buff) or BuffPresent(ascendance_elemental_buff) } and Enemies() < 4 and Spell(lava_burst) or Talent(elemental_blast_talent) and Enemies() < 4 and Spell(elemental_blast) or Talent(ascendance_talent) and Spell(lava_beam) or Spell(chain_lightning_elemental) or Speed() > 0 and Talent(ascendance_talent) and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(frost_shock)
}

AddFunction ElementalAoeCdActions
{
 unless Talent(stormkeeper_talent) and Spell(stormkeeper)
 {
  #ascendance,if=talent.ascendance.enabled&(talent.storm_elemental.enabled&cooldown.storm_elemental.remains<120&cooldown.storm_elemental.remains>15|!talent.storm_elemental.enabled)
  if Talent(ascendance_talent) and { Talent(storm_elemental_talent) and SpellCooldown(storm_elemental) < 120 and SpellCooldown(storm_elemental) > 15 or not Talent(storm_elemental_talent) } and BuffExpires(ascendance_elemental_buff) Spell(ascendance_elemental)
 }
}

AddFunction ElementalAoeCdPostConditions
{
 Talent(stormkeeper_talent) and Spell(stormkeeper) or Talent(liquid_magma_totem_talent) and Spell(liquid_magma_totem) or Enemies() < 4 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or { BuffPresent(lava_surge_buff) or BuffPresent(ascendance_elemental_buff) } and Enemies() < 4 and Spell(lava_burst) or Talent(elemental_blast_talent) and Enemies() < 4 and Spell(elemental_blast) or Talent(ascendance_talent) and Spell(lava_beam) or Spell(chain_lightning_elemental) or Speed() > 0 and Talent(ascendance_talent) and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(frost_shock)
}

### actions.default

AddFunction ElementalDefaultMainActions
{
 #totem_mastery,if=talent.totem_mastery.enabled&buff.resonance_totem.remains<2
 if Talent(totem_mastery_talent_elemental) and TotemRemaining(totem_mastery_elemental) < 2 and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } Spell(totem_mastery_elemental)
 #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
 if Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } ElementalAoeMainActions()

 unless Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeMainPostConditions()
 {
  #run_action_list,name=single_target
  ElementalSingletargetMainActions()
 }
}

AddFunction ElementalDefaultMainPostConditions
{
 Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeMainPostConditions() or ElementalSingletargetMainPostConditions()
}

AddFunction ElementalDefaultShortCdActions
{
 unless Talent(totem_mastery_talent_elemental) and TotemRemaining(totem_mastery_elemental) < 2 and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental)
 {
  #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
  if Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } ElementalAoeShortCdActions()

  unless Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeShortCdPostConditions()
  {
   #run_action_list,name=single_target
   ElementalSingletargetShortCdActions()
  }
 }
}

AddFunction ElementalDefaultShortCdPostConditions
{
 Talent(totem_mastery_talent_elemental) and TotemRemaining(totem_mastery_elemental) < 2 and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeShortCdPostConditions() or ElementalSingletargetShortCdPostConditions()
}

AddFunction ElementalDefaultCdActions
{
 #bloodlust,if=azerite.ancestral_resonance.enabled
 if HasAzeriteTrait(ancestral_resonance_trait) ElementalBloodlust()
 #potion
 if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 #wind_shear
 ElementalInterruptActions()

 unless Talent(totem_mastery_talent_elemental) and TotemRemaining(totem_mastery_elemental) < 2 and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental)
 {
  #fire_elemental,if=!talent.storm_elemental.enabled
  if not Talent(storm_elemental_talent) Spell(fire_elemental)
  #storm_elemental,if=talent.storm_elemental.enabled
  if Talent(storm_elemental_talent) Spell(storm_elemental)
  #earth_elemental,if=cooldown.fire_elemental.remains<120&!talent.storm_elemental.enabled|cooldown.storm_elemental.remains<120&talent.storm_elemental.enabled
  if SpellCooldown(fire_elemental) < 120 and not Talent(storm_elemental_talent) or SpellCooldown(storm_elemental) < 120 and Talent(storm_elemental_talent) Spell(earth_elemental)
  #use_items
  ElementalUseItemActions()
  #blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
  if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) or SpellCooldown(ascendance_elemental) > 50 Spell(blood_fury_apsp)
  #berserking,if=!talent.ascendance.enabled|buff.ascendance.up
  if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) Spell(berserking)
  #fireblood,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
  if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) or SpellCooldown(ascendance_elemental) > 50 Spell(fireblood)
  #ancestral_call,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
  if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) or SpellCooldown(ascendance_elemental) > 50 Spell(ancestral_call)
  #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
  if Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } ElementalAoeCdActions()

  unless Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeCdPostConditions()
  {
   #run_action_list,name=single_target
   ElementalSingletargetCdActions()
  }
 }
}

AddFunction ElementalDefaultCdPostConditions
{
 Talent(totem_mastery_talent_elemental) and TotemRemaining(totem_mastery_elemental) < 2 and { InCombat() or not BuffPresent(ele_resonance_totem_buff) } and Spell(totem_mastery_elemental) or Enemies() > 2 and { Enemies() > 2 or Enemies() > 2 } and ElementalAoeCdPostConditions() or ElementalSingletargetCdPostConditions()
}

### Elemental icons.

AddCheckBox(opt_shaman_elemental_aoe L(AOE) default specialization=elemental)

AddIcon checkbox=!opt_shaman_elemental_aoe enemies=1 help=shortcd specialization=elemental
{
 if not InCombat() ElementalPrecombatShortCdActions()
 unless not InCombat() and ElementalPrecombatShortCdPostConditions()
 {
  ElementalDefaultShortCdActions()
 }
}

AddIcon checkbox=opt_shaman_elemental_aoe help=shortcd specialization=elemental
{
 if not InCombat() ElementalPrecombatShortCdActions()
 unless not InCombat() and ElementalPrecombatShortCdPostConditions()
 {
  ElementalDefaultShortCdActions()
 }
}

AddIcon enemies=1 help=main specialization=elemental
{
 if not InCombat() ElementalPrecombatMainActions()
 unless not InCombat() and ElementalPrecombatMainPostConditions()
 {
  ElementalDefaultMainActions()
 }
}

AddIcon checkbox=opt_shaman_elemental_aoe help=aoe specialization=elemental
{
 if not InCombat() ElementalPrecombatMainActions()
 unless not InCombat() and ElementalPrecombatMainPostConditions()
 {
  ElementalDefaultMainActions()
 }
}

AddIcon checkbox=!opt_shaman_elemental_aoe enemies=1 help=cd specialization=elemental
{
 if not InCombat() ElementalPrecombatCdActions()
 unless not InCombat() and ElementalPrecombatCdPostConditions()
 {
  ElementalDefaultCdActions()
 }
}

AddIcon checkbox=opt_shaman_elemental_aoe help=cd specialization=elemental
{
 if not InCombat() ElementalPrecombatCdActions()
 unless not InCombat() and ElementalPrecombatCdPostConditions()
 {
  ElementalDefaultCdActions()
 }
}

### Required symbols
# ancestral_call
# ancestral_resonance_trait
# ascendance_elemental
# ascendance_elemental_buff
# ascendance_talent
# battle_potion_of_intellect
# berserking
# blood_fury_apsp
# bloodlust
# capacitor_totem
# chain_lightning_elemental
# earth_elemental
# earth_shock
# earthquake
# ele_resonance_totem_buff
# elemental_blast
# elemental_blast_talent
# exposed_elements_debuff
# exposed_elements_talent
# fire_elemental
# fireblood
# flame_shock
# flame_shock_debuff
# frost_shock
# heroism
# hex
# icefury
# icefury_buff
# icefury_talent
# lava_beam
# lava_burst
# lava_surge_buff
# lightning_bolt_elemental
# liquid_magma_totem
# liquid_magma_totem_talent
# master_of_the_elements_buff
# master_of_the_elements_talent
# quaking_palm
# storm_elemental
# storm_elemental_talent
# stormkeeper
# stormkeeper_talent
# totem_mastery_elemental
# totem_mastery_talent_elemental
# war_stomp
# wind_gust_buff
# wind_shear
]]
    OvaleScripts:RegisterScript("SHAMAN", "elemental", name, desc, code, "script")
end
do
    local name = "sc_pr_shaman_enhancement"
    local desc = "[8.0] Simulationcraft: PR_Shaman_Enhancement"
    local code = [[
# Based on SimulationCraft profile "PR_Shaman_Enhancement".
#	class=shaman
#	spec=enhancement
#	talents=3201033

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)


AddFunction OCPool60
{
 not Talent(overcharge_talent) or Enemies() > 1 or Talent(overcharge_talent) and Enemies() == 1 and { SpellCooldown(lightning_bolt_enhancement) >= 2 * GCD() or Maelstrom() > 60 }
}

AddFunction OCPool70
{
 not Talent(overcharge_talent) or Enemies() > 1 or Talent(overcharge_talent) and Enemies() == 1 and { SpellCooldown(lightning_bolt_enhancement) >= 2 * GCD() or Maelstrom() > 70 }
}

AddFunction OCPool80
{
 not Talent(overcharge_talent) or Enemies() > 1 or Talent(overcharge_talent) and Enemies() == 1 and { SpellCooldown(lightning_bolt_enhancement) >= 2 * GCD() or Maelstrom() > 80 }
}

AddFunction furyCheck25
{
 not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 25
}

AddFunction furyCheck35
{
 not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 35
}

AddFunction furyCheck45
{
 not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 45
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=enhancement)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=enhancement)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=enhancement)
AddCheckBox(opt_bloodlust SpellName(bloodlust) specialization=enhancement)

AddFunction EnhancementInterruptActions
{
 if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
 {
  if target.InRange(wind_shear) and target.IsInterruptible() Spell(wind_shear)
  if target.Distance(less 5) and not target.Classification(worldboss) Spell(sundering)
  if not target.Classification(worldboss) and target.RemainingCastTime() > 2 Spell(capacitor_totem)
  if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
  if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
  if target.InRange(hex) and not target.Classification(worldboss) and target.RemainingCastTime() > CastTime(hex) + GCDRemaining() and target.CreatureType(Humanoid Beast) Spell(hex)
 }
}

AddFunction EnhancementUseItemActions
{
 Item(Trinket0Slot text=13 usable=1)
 Item(Trinket1Slot text=14 usable=1)
}

AddFunction EnhancementBloodlust
{
 if CheckBoxOn(opt_bloodlust) and DebuffExpires(burst_haste_debuff any=1)
 {
  Spell(bloodlust)
  Spell(heroism)
 }
}

AddFunction EnhancementGetInMeleeRange
{
 if CheckBoxOn(opt_melee_range) and not target.InRange(stormstrike)
 {
  if target.InRange(feral_lunge) Spell(feral_lunge)
  Texture(misc_arrowlup help=L(not_in_melee_range))
 }
}

### actions.precombat

AddFunction EnhancementPrecombatMainActions
{
 #lightning_shield
 Spell(lightning_shield)
}

AddFunction EnhancementPrecombatMainPostConditions
{
}

AddFunction EnhancementPrecombatShortCdActions
{
}

AddFunction EnhancementPrecombatShortCdPostConditions
{
 Spell(lightning_shield)
}

AddFunction EnhancementPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
}

AddFunction EnhancementPrecombatCdPostConditions
{
 Spell(lightning_shield)
}

### actions.opener

AddFunction EnhancementOpenerMainActions
{
 #rockbiter,if=maelstrom<15&time<gcd
 if Maelstrom() < 15 and TimeInCombat() < GCD() Spell(rockbiter)
}

AddFunction EnhancementOpenerMainPostConditions
{
}

AddFunction EnhancementOpenerShortCdActions
{
}

AddFunction EnhancementOpenerShortCdPostConditions
{
 Maelstrom() < 15 and TimeInCombat() < GCD() and Spell(rockbiter)
}

AddFunction EnhancementOpenerCdActions
{
}

AddFunction EnhancementOpenerCdPostConditions
{
 Maelstrom() < 15 and TimeInCombat() < GCD() and Spell(rockbiter)
}

### actions.filler

AddFunction EnhancementFillerMainActions
{
 #rockbiter,if=maelstrom<70&!buff.strength_of_earth.up
 if Maelstrom() < 70 and not BuffPresent(strength_of_earth_buff) Spell(rockbiter)
 #crash_lightning,if=talent.crashing_storm.enabled&variable.OCPool60
 if Talent(crashing_storm_talent) and OCPool60() Spell(crash_lightning)
 #lava_lash,if=variable.OCPool80&variable.furyCheck45
 if OCPool80() and furyCheck45() Spell(lava_lash)
 #rockbiter
 Spell(rockbiter)
 #flametongue
 Spell(flametongue)
}

AddFunction EnhancementFillerMainPostConditions
{
}

AddFunction EnhancementFillerShortCdActions
{
}

AddFunction EnhancementFillerShortCdPostConditions
{
 Maelstrom() < 70 and not BuffPresent(strength_of_earth_buff) and Spell(rockbiter) or Talent(crashing_storm_talent) and OCPool60() and Spell(crash_lightning) or OCPool80() and furyCheck45() and Spell(lava_lash) or Spell(rockbiter) or Spell(flametongue)
}

AddFunction EnhancementFillerCdActions
{
}

AddFunction EnhancementFillerCdPostConditions
{
 Maelstrom() < 70 and not BuffPresent(strength_of_earth_buff) and Spell(rockbiter) or Talent(crashing_storm_talent) and OCPool60() and Spell(crash_lightning) or OCPool80() and furyCheck45() and Spell(lava_lash) or Spell(rockbiter) or Spell(flametongue)
}

### actions.core

AddFunction EnhancementCoreMainActions
{
 #earthen_spike,if=variable.furyCheck25
 if furyCheck25() Spell(earthen_spike)
 #sundering,if=active_enemies>=3
 if Enemies() >= 3 Spell(sundering)
 #stormstrike,cycle_targets=1,if=azerite.lightning_conduit.enabled&!debuff.lightning_conduit.up&active_enemies>1&(buff.stormbringer.up|(variable.OCPool70&variable.furyCheck35))
 if HasAzeriteTrait(lightning_conduit_trait) and not target.DebuffPresent(lightning_conduit_debuff) and Enemies() > 1 and { BuffPresent(stormbringer_buff) or OCPool70() and furyCheck35() } Spell(stormstrike)
 #stormstrike,if=buff.stormbringer.up|(buff.gathering_storms.up&variable.OCPool70&variable.furyCheck35)
 if BuffPresent(stormbringer_buff) or BuffPresent(gathering_storms_buff) and OCPool70() and furyCheck35() Spell(stormstrike)
 #crash_lightning,if=active_enemies>=3&variable.furyCheck25
 if Enemies() >= 3 and furyCheck25() Spell(crash_lightning)
 #lightning_bolt,if=talent.overcharge.enabled&active_enemies=1&variable.furyCheck45&maelstrom>=40
 if Talent(overcharge_talent) and Enemies() == 1 and furyCheck45() and Maelstrom() >= 40 Spell(lightning_bolt_enhancement)
 #stormstrike,if=variable.OCPool70&variable.furyCheck35
 if OCPool70() and furyCheck35() Spell(stormstrike)
 #sundering
 Spell(sundering)
 #crash_lightning,if=talent.forceful_winds.enabled&active_enemies>1&variable.furyCheck25
 if Talent(forceful_winds_talent) and Enemies() > 1 and furyCheck25() Spell(crash_lightning)
 #flametongue,if=talent.searing_assault.enabled
 if Talent(searing_assault_talent) Spell(flametongue)
 #lava_lash,if=talent.hot_hand.enabled&buff.hot_hand.react
 if Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) Spell(lava_lash)
 #crash_lightning,if=active_enemies>1&variable.furyCheck25
 if Enemies() > 1 and furyCheck25() Spell(crash_lightning)
}

AddFunction EnhancementCoreMainPostConditions
{
}

AddFunction EnhancementCoreShortCdActions
{
}

AddFunction EnhancementCoreShortCdPostConditions
{
 furyCheck25() and Spell(earthen_spike) or Enemies() >= 3 and Spell(sundering) or HasAzeriteTrait(lightning_conduit_trait) and not target.DebuffPresent(lightning_conduit_debuff) and Enemies() > 1 and { BuffPresent(stormbringer_buff) or OCPool70() and furyCheck35() } and Spell(stormstrike) or { BuffPresent(stormbringer_buff) or BuffPresent(gathering_storms_buff) and OCPool70() and furyCheck35() } and Spell(stormstrike) or Enemies() >= 3 and furyCheck25() and Spell(crash_lightning) or Talent(overcharge_talent) and Enemies() == 1 and furyCheck45() and Maelstrom() >= 40 and Spell(lightning_bolt_enhancement) or OCPool70() and furyCheck35() and Spell(stormstrike) or Spell(sundering) or Talent(forceful_winds_talent) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(searing_assault_talent) and Spell(flametongue) or Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) and Spell(lava_lash) or Enemies() > 1 and furyCheck25() and Spell(crash_lightning)
}

AddFunction EnhancementCoreCdActions
{
}

AddFunction EnhancementCoreCdPostConditions
{
 furyCheck25() and Spell(earthen_spike) or Enemies() >= 3 and Spell(sundering) or HasAzeriteTrait(lightning_conduit_trait) and not target.DebuffPresent(lightning_conduit_debuff) and Enemies() > 1 and { BuffPresent(stormbringer_buff) or OCPool70() and furyCheck35() } and Spell(stormstrike) or { BuffPresent(stormbringer_buff) or BuffPresent(gathering_storms_buff) and OCPool70() and furyCheck35() } and Spell(stormstrike) or Enemies() >= 3 and furyCheck25() and Spell(crash_lightning) or Talent(overcharge_talent) and Enemies() == 1 and furyCheck45() and Maelstrom() >= 40 and Spell(lightning_bolt_enhancement) or OCPool70() and furyCheck35() and Spell(stormstrike) or Spell(sundering) or Talent(forceful_winds_talent) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(searing_assault_talent) and Spell(flametongue) or Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) and Spell(lava_lash) or Enemies() > 1 and furyCheck25() and Spell(crash_lightning)
}

### actions.cds

AddFunction EnhancementCdsMainActions
{
}

AddFunction EnhancementCdsMainPostConditions
{
}

AddFunction EnhancementCdsShortCdActions
{
}

AddFunction EnhancementCdsShortCdPostConditions
{
}

AddFunction EnhancementCdsCdActions
{
 #bloodlust,if=azerite.ancestral_resonance.enabled
 if HasAzeriteTrait(ancestral_resonance_trait) EnhancementBloodlust()
 #berserking,if=(talent.ascendance.enabled&buff.ascendance.up)|(talent.elemental_spirits.enabled&feral_spirit.remains>5)|(!talent.ascendance.enabled&!talent.elemental_spirits.enabled)
 if Talent(ascendance_talent_enhancement) and BuffPresent(ascendance_enhancement_buff) or Talent(elemental_spirits_talent) and TotemRemaining(sprit_wolf) > 5 or not Talent(ascendance_talent_enhancement) and not Talent(elemental_spirits_talent) Spell(berserking)
 #blood_fury,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
 if Talent(ascendance_talent_enhancement) and { BuffPresent(ascendance_enhancement_buff) or SpellCooldown(ascendance_enhancement) > 50 } or not Talent(ascendance_talent_enhancement) and { TotemRemaining(sprit_wolf) > 5 or SpellCooldown(feral_spirit) > 50 } Spell(blood_fury_apsp)
 #fireblood,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
 if Talent(ascendance_talent_enhancement) and { BuffPresent(ascendance_enhancement_buff) or SpellCooldown(ascendance_enhancement) > 50 } or not Talent(ascendance_talent_enhancement) and { TotemRemaining(sprit_wolf) > 5 or SpellCooldown(feral_spirit) > 50 } Spell(fireblood)
 #ancestral_call,if=(talent.ascendance.enabled&(buff.ascendance.up|cooldown.ascendance.remains>50))|(!talent.ascendance.enabled&(feral_spirit.remains>5|cooldown.feral_spirit.remains>50))
 if Talent(ascendance_talent_enhancement) and { BuffPresent(ascendance_enhancement_buff) or SpellCooldown(ascendance_enhancement) > 50 } or not Talent(ascendance_talent_enhancement) and { TotemRemaining(sprit_wolf) > 5 or SpellCooldown(feral_spirit) > 50 } Spell(ancestral_call)
 #potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
 if { BuffPresent(ascendance_enhancement_buff) or not Talent(ascendance_talent_enhancement) and TotemRemaining(sprit_wolf) > 5 or target.TimeToDie() <= 60 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
 #feral_spirit
 Spell(feral_spirit)
 #ascendance,if=cooldown.strike.remains>0
 if SpellCooldown(windstrike) > 0 and BuffExpires(ascendance_enhancement_buff) Spell(ascendance_enhancement)
 #earth_elemental
 Spell(earth_elemental)
}

AddFunction EnhancementCdsCdPostConditions
{
}

### actions.buffs

AddFunction EnhancementBuffsMainActions
{
 #crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
 if not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() Spell(crash_lightning)
 #rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
 if Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 Spell(rockbiter)
 #fury_of_air,if=!ticking&maelstrom>=20
 if not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() >= 20 Spell(fury_of_air)
 #flametongue,if=!buff.flametongue.up
 if not BuffPresent(flametongue_buff) Spell(flametongue)
 #frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck25
 if Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck25() Spell(frostbrand)
 #flametongue,if=buff.flametongue.remains<4.8+gcd
 if BuffRemaining(flametongue_buff) < 4.8 + GCD() Spell(flametongue)
 #frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8+gcd&variable.furyCheck25
 if Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 + GCD() and furyCheck25() Spell(frostbrand)
 #totem_mastery,if=buff.resonance_totem.remains<2
 if TotemRemaining(totem_mastery_enhancement) < 2 and { InCombat() or not BuffPresent(enh_resonance_totem_buff) } Spell(totem_mastery_enhancement)
}

AddFunction EnhancementBuffsMainPostConditions
{
}

AddFunction EnhancementBuffsShortCdActions
{
}

AddFunction EnhancementBuffsShortCdPostConditions
{
 not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() >= 20 and Spell(fury_of_air) or not BuffPresent(flametongue_buff) and Spell(flametongue) or Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck25() and Spell(frostbrand) or BuffRemaining(flametongue_buff) < 4.8 + GCD() and Spell(flametongue) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 + GCD() and furyCheck25() and Spell(frostbrand) or TotemRemaining(totem_mastery_enhancement) < 2 and { InCombat() or not BuffPresent(enh_resonance_totem_buff) } and Spell(totem_mastery_enhancement)
}

AddFunction EnhancementBuffsCdActions
{
}

AddFunction EnhancementBuffsCdPostConditions
{
 not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() >= 20 and Spell(fury_of_air) or not BuffPresent(flametongue_buff) and Spell(flametongue) or Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck25() and Spell(frostbrand) or BuffRemaining(flametongue_buff) < 4.8 + GCD() and Spell(flametongue) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 + GCD() and furyCheck25() and Spell(frostbrand) or TotemRemaining(totem_mastery_enhancement) < 2 and { InCombat() or not BuffPresent(enh_resonance_totem_buff) } and Spell(totem_mastery_enhancement)
}

### actions.asc

AddFunction EnhancementAscMainActions
{
 #crash_lightning,if=!buff.crash_lightning.up&active_enemies>1&variable.furyCheck25
 if not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() Spell(crash_lightning)
 #rockbiter,if=talent.landslide.enabled&!buff.landslide.up&charges_fractional>1.7
 if Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 Spell(rockbiter)
 #windstrike
 Spell(windstrike)
}

AddFunction EnhancementAscMainPostConditions
{
}

AddFunction EnhancementAscShortCdActions
{
}

AddFunction EnhancementAscShortCdPostConditions
{
 not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 and Spell(rockbiter) or Spell(windstrike)
}

AddFunction EnhancementAscCdActions
{
}

AddFunction EnhancementAscCdPostConditions
{
 not BuffPresent(crash_lightning_buff) and Enemies() > 1 and furyCheck25() and Spell(crash_lightning) or Talent(landslide_talent) and not BuffPresent(landslide_buff) and Charges(rockbiter count=0) > 1.7 and Spell(rockbiter) or Spell(windstrike)
}

### actions.default

AddFunction EnhancementDefaultMainActions
{
 #call_action_list,name=opener
 EnhancementOpenerMainActions()

 unless EnhancementOpenerMainPostConditions()
 {
  #call_action_list,name=asc,if=buff.ascendance.up
  if BuffPresent(ascendance_enhancement_buff) EnhancementAscMainActions()

  unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscMainPostConditions()
  {
   #call_action_list,name=buffs
   EnhancementBuffsMainActions()

   unless EnhancementBuffsMainPostConditions()
   {
    #call_action_list,name=cds
    EnhancementCdsMainActions()

    unless EnhancementCdsMainPostConditions()
    {
     #call_action_list,name=core
     EnhancementCoreMainActions()

     unless EnhancementCoreMainPostConditions()
     {
      #call_action_list,name=filler
      EnhancementFillerMainActions()
     }
    }
   }
  }
 }
}

AddFunction EnhancementDefaultMainPostConditions
{
 EnhancementOpenerMainPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscMainPostConditions() or EnhancementBuffsMainPostConditions() or EnhancementCdsMainPostConditions() or EnhancementCoreMainPostConditions() or EnhancementFillerMainPostConditions()
}

AddFunction EnhancementDefaultShortCdActions
{
 #variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
 #variable,name=furyCheck35,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>35))
 #variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
 #variable,name=OCPool80,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>80)))
 #variable,name=OCPool70,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>70)))
 #variable,name=OCPool60,value=(!talent.overcharge.enabled|active_enemies>1|(talent.overcharge.enabled&active_enemies=1&(cooldown.lightning_bolt.remains>=2*gcd|maelstrom>60)))
 #auto_attack
 EnhancementGetInMeleeRange()
 #call_action_list,name=opener
 EnhancementOpenerShortCdActions()

 unless EnhancementOpenerShortCdPostConditions()
 {
  #call_action_list,name=asc,if=buff.ascendance.up
  if BuffPresent(ascendance_enhancement_buff) EnhancementAscShortCdActions()

  unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscShortCdPostConditions()
  {
   #call_action_list,name=buffs
   EnhancementBuffsShortCdActions()

   unless EnhancementBuffsShortCdPostConditions()
   {
    #call_action_list,name=cds
    EnhancementCdsShortCdActions()

    unless EnhancementCdsShortCdPostConditions()
    {
     #call_action_list,name=core
     EnhancementCoreShortCdActions()

     unless EnhancementCoreShortCdPostConditions()
     {
      #call_action_list,name=filler
      EnhancementFillerShortCdActions()
     }
    }
   }
  }
 }
}

AddFunction EnhancementDefaultShortCdPostConditions
{
 EnhancementOpenerShortCdPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscShortCdPostConditions() or EnhancementBuffsShortCdPostConditions() or EnhancementCdsShortCdPostConditions() or EnhancementCoreShortCdPostConditions() or EnhancementFillerShortCdPostConditions()
}

AddFunction EnhancementDefaultCdActions
{
 #wind_shear
 EnhancementInterruptActions()
 #use_items
 EnhancementUseItemActions()
 #call_action_list,name=opener
 EnhancementOpenerCdActions()

 unless EnhancementOpenerCdPostConditions()
 {
  #call_action_list,name=asc,if=buff.ascendance.up
  if BuffPresent(ascendance_enhancement_buff) EnhancementAscCdActions()

  unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscCdPostConditions()
  {
   #call_action_list,name=buffs
   EnhancementBuffsCdActions()

   unless EnhancementBuffsCdPostConditions()
   {
    #call_action_list,name=cds
    EnhancementCdsCdActions()

    unless EnhancementCdsCdPostConditions()
    {
     #call_action_list,name=core
     EnhancementCoreCdActions()

     unless EnhancementCoreCdPostConditions()
     {
      #call_action_list,name=filler
      EnhancementFillerCdActions()
     }
    }
   }
  }
 }
}

AddFunction EnhancementDefaultCdPostConditions
{
 EnhancementOpenerCdPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscCdPostConditions() or EnhancementBuffsCdPostConditions() or EnhancementCdsCdPostConditions() or EnhancementCoreCdPostConditions() or EnhancementFillerCdPostConditions()
}

### Enhancement icons.

AddCheckBox(opt_shaman_enhancement_aoe L(AOE) default specialization=enhancement)

AddIcon checkbox=!opt_shaman_enhancement_aoe enemies=1 help=shortcd specialization=enhancement
{
 if not InCombat() EnhancementPrecombatShortCdActions()
 unless not InCombat() and EnhancementPrecombatShortCdPostConditions()
 {
  EnhancementDefaultShortCdActions()
 }
}

AddIcon checkbox=opt_shaman_enhancement_aoe help=shortcd specialization=enhancement
{
 if not InCombat() EnhancementPrecombatShortCdActions()
 unless not InCombat() and EnhancementPrecombatShortCdPostConditions()
 {
  EnhancementDefaultShortCdActions()
 }
}

AddIcon enemies=1 help=main specialization=enhancement
{
 if not InCombat() EnhancementPrecombatMainActions()
 unless not InCombat() and EnhancementPrecombatMainPostConditions()
 {
  EnhancementDefaultMainActions()
 }
}

AddIcon checkbox=opt_shaman_enhancement_aoe help=aoe specialization=enhancement
{
 if not InCombat() EnhancementPrecombatMainActions()
 unless not InCombat() and EnhancementPrecombatMainPostConditions()
 {
  EnhancementDefaultMainActions()
 }
}

AddIcon checkbox=!opt_shaman_enhancement_aoe enemies=1 help=cd specialization=enhancement
{
 if not InCombat() EnhancementPrecombatCdActions()
 unless not InCombat() and EnhancementPrecombatCdPostConditions()
 {
  EnhancementDefaultCdActions()
 }
}

AddIcon checkbox=opt_shaman_enhancement_aoe help=cd specialization=enhancement
{
 if not InCombat() EnhancementPrecombatCdActions()
 unless not InCombat() and EnhancementPrecombatCdPostConditions()
 {
  EnhancementDefaultCdActions()
 }
}

### Required symbols
# ancestral_call
# ancestral_resonance_trait
# ascendance_enhancement
# ascendance_enhancement_buff
# ascendance_talent_enhancement
# battle_potion_of_agility
# berserking
# blood_fury_apsp
# bloodlust
# capacitor_totem
# crash_lightning
# crash_lightning_buff
# crashing_storm_talent
# earth_elemental
# earthen_spike
# elemental_spirits_talent
# enh_resonance_totem_buff
# feral_lunge
# feral_spirit
# fireblood
# flametongue
# flametongue_buff
# forceful_winds_talent
# frostbrand
# frostbrand_buff
# fury_of_air
# fury_of_air_debuff
# fury_of_air_talent
# gathering_storms_buff
# hailstorm_talent
# heroism
# hex
# hot_hand_buff
# hot_hand_talent
# landslide_buff
# landslide_talent
# lava_lash
# lightning_bolt_enhancement
# lightning_conduit_debuff
# lightning_conduit_trait
# lightning_shield
# overcharge_talent
# quaking_palm
# rockbiter
# searing_assault_talent
# stormbringer_buff
# stormstrike
# strength_of_earth_buff
# sundering
# totem_mastery_enhancement
# war_stomp
# wind_shear
# windstrike
]]
    OvaleScripts:RegisterScript("SHAMAN", "enhancement", name, desc, code, "script")
end
