//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_XPackAbilitySet.uc
//  AUTHOR:  Russell Aasland  --  02/13/2017
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class IRB_AdditionalResistanceOrders_Abilities extends XMBAbility
	config(Abilities);
var config array<name> FLAMER_SKILLS;

var config int ILB_PROMETHIUM_FIRE_DMG_BONUS;
	
var config int ILB_CUTTHROAT_BONUS_CRIT_CHANCE;
var config int ILB_CUTTHROAT_BONUS_CRIT_DAMAGE;
var config int ILB_CUTTHROAT_BONUS_ARMOR_PIERCE;

var config int ILB_SHELLBUSTER_MOBILITY_BUFF;

var config int ILB_DAWN_MACHINES_MOBILITY_BUFF;
var config int ILB_DAWN_MACHINES_SHIELDS_BUFF;

var config int ILB_SAFETY_FIRST_SHIELDS_BUFF;
var config int ILB_HAZMAT_SHIELDS_BUFF;

var config int ILB_WITCH_HUNTER_PASSIVE_DMG;

var config float HACK_DEFENSE_DEBUFF;
var config float HACK_DEFENSE_DEBUFF_TUNDRA;

var config int ILB_MELEE_DMG_BUFF;
var config int ILB_VIP_SMOKES;
var config int ILB_VIP_FRAGS;

var config int ROOKIE_COMBAT_HP_BONUS;

var config int FIELD_COMMANDER_SHIELDING_BUFF;

var config int CHRYSSALID_AND_FACELESS_DEFENSE_BUFF;
var config int CHRYSSALID_AND_FACELESS_MOBILITY_BUFF;

var config int AVENGER_SUPERCHARGER_ELECTRIC_DAMAGE_BUFF;
	//UltrasonicLure
/// <summary>
/// Creates the set of default abilities every unit should have in X-Com 2
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{ 
	local array<X2DataTemplate> Templates;
	Templates.AddItem(ILBPocketFlamer());
	Templates.AddItem(Rocketeer());
	Templates.AddItem(FreeFragGrenades());
	Templates.AddItem(FreeSmokeGrenades());
	Templates.AddItem(FreeSmokeGrenadeSingular());
	Templates.AddItem(FreeUltrasonicLure());
	Templates.AddItem(ArcticEasyToHack());
	Templates.AddItem(WitchHunterBuff());
	Templates.AddItem(EasyToHack());
	Templates.AddItem(AridFastUnit());
	Templates.AddItem(PlatedVestShielding());
	Templates.AddItem(HazmatShielding());
	Templates.AddItem(AddTurretHackabilityDebuff());
	Templates.AddItem(RookieHpBuff());
	Templates.AddItem(IncreaseFlamethrowerDamageAndCharges());
	Templates.AddItem(ExtraMeleeDamage());
	Templates.AddItem(PistolShotsDealPoisonPassive());
	Templates.AddItem(AidProtocolRefund());
	Templates.AddItem(SiphonLifeEffect());

	// now, enemy abilities
	Templates.AddItem(CreateBrutePoison());
	Templates.AddItem(CreateBrutePoisonWeapon());
	Templates.AddItem(CreatePoisonImmunity());
	Templates.AddItem(CreateChryssalidAndFacelessBuff());
	Templates.AddItem(CreateLotsOfShieldingBuff());
	Templates.AddItem(Turbocharged());
	Templates.AddItem(CreateCrackdownAbility_Revenge());
	return Templates;
}

// Perk name:		Pyromaniac
// Perk effect:		Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission.
// Localized text:	"Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission."
// Config:			(AbilityName="XMBExample_Pyromaniac")
static function X2AbilityTemplate Turbocharged()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Turbocharged';
	Effect.RequiredDamageTypes.AddItem('Electrical');
	Effect.DamageBonus = default.AVENGER_SUPERCHARGER_ELECTRIC_DAMAGE_BUFF;

	// Create the template using a helper function
	Template = Passive('ILB_Turbocharged', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	return Template;
}



static function X2AbilityTemplate CreateLotsOfShieldingBuff()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;

	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_LotsOfShielding',"img:///UILibrary_PerkIcons.UIPerk_andromedon_robotbattlesuit", true, none);

	//DEFENSE
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'LotsOfShielding';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_ShieldHP, default.FIELD_COMMANDER_SHIELDING_BUFF); //todo: config

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	
	return Template;
}

static function X2AbilityTemplate CreateChryssalidAndFacelessBuff()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;

	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_FasterSavages',"img:///UILibrary_PerkIcons.UIPerk_andromedon_robotbattlesuit", true, none);

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'Faster';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Defense, default.CHRYSSALID_AND_FACELESS_DEFENSE_BUFF);
	Effect.AddPersistentStatChange(eStat_Mobility, default.CHRYSSALID_AND_FACELESS_MOBILITY_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	
	return Template;
}


static function X2AbilityTemplate CreateBrutePoison()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ApplyWeaponDamage            DamageEffect;
	local X2AbilityMultiTarget_Radius MultiTarget;
	local X2AbilityTrigger_EventListener		EventListener;
	local X2Effect_ApplyPoisonToWorld PoisonEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ILB_BrutePoison');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Defensive;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_burn";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.DamageTypes.AddItem('Poison');
	Template.AddTargetEffect(DamageEffect);

	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreatePoisonedStatusEffect());
	PoisonEffect = new class'X2Effect_ApplyPoisonToWorld';	
	Template.AddMultiTargetEffect(PoisonEffect);

	MultiTarget = new class'X2AbilityMultiTarget_Radius';
    MultiTarget.bUseWeaponRadius = true;
	MultiTarget.bExcludeSelfAsTargetIfWithinRadius = false;
	Template.AbilityMultiTargetStyle = MultiTarget;

	// This ability fires when the unit takes damage
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.bFrameEvenWhenUnitIsHidden = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate CreateBrutePoisonWeapon()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	ItemEffect = new class'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'ILB_BrutePoison_WPN'; //TODO: Make this not need wwl as dependency

	// Create the template using a helper function
	Template = Passive('ILB_GrantBrutePoisonWeapon', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

	return Template;
}


static function X2AbilityTemplate CreatePoisonImmunity()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger_UnitPostBeginPlay Trigger;
	local X2Effect_DamageImmunity DamageImmunity;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ILB_PoisonImmunity');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_immunities";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTargetStyle = default.SelfTarget;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	// Build the immunities
	DamageImmunity = new class'X2Effect_DamageImmunity';
	DamageImmunity.BuildPersistentEffect(1, true, true, true);
	DamageImmunity.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	DamageImmunity.ImmuneTypes.AddItem('Poison');
	DamageImmunity.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);

	Template.AddTargetEffect(DamageImmunity);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate SiphonLifeEffect(){

	local X2AbilityTemplate Template;
	local X2Effect_ApplyMedikitHeal Effect;
	local XMBCondition_AbilityName AbilityNameCondition;
	local XMBEffect_ConditionalStatChange ShieldingEffect;

	Effect = new class'X2Effect_ApplyMedikitHeal';
	Effect.IncreasedPerUseHP = 20; // heal to full
	Effect.PerUseHP = 20; // heal to full
	
	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('SKULLJACKAbility');
	AbilityNameCondition.IncludeAbilityNames.AddItem('SKULLMINEAbility');
	
	//Template = Passive('ILB_SiphonLife', "img:///UILibrary_PerkIcons.UIPerk_aidprotocol", true, Effect);
	Template = SelfTargetTrigger('ILB_SiphonLife', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect, 'AbilityActivated');
	
	
	AddTriggerTargetCondition(Template, AbilityNameCondition);
	//Effect.TriggeredEvent = 'SkullMiningHeal';

	ShieldingEffect = new class'XMBEffect_ConditionalStatChange';
	ShieldingEffect.EffectName = 'PlusSomeShielding';
	ShieldingEffect.Conditions.AddItem(AbilityNameCondition);

	// The effect doesn't expire
	ShieldingEffect.BuildPersistentEffect(1, true, false, false);
	ShieldingEffect.AddPersistentStatChange(eStat_ShieldHP, 3); //config


	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	// Create the template using a helper function
	return Template;
}

static function X2AbilityTemplate AidProtocolRefund()
{
	local XMBEffect_AbilityCostRefund Effect;
	local XMBCondition_AbilityName AbilityNameCondition;
	
	// Create an effect that will refund the cost of attacks
	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'AidProtocolRefund';
	Effect.TriggeredEvent = 'AidProtocolRefund';

	// Only refund once per turn
	Effect.CountValueName = 'AidProtocolUsesThisTurn';
	Effect.MaxRefundsPerTurn = 1;

	// The bonus only applies to standard shots
	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('WOTC_APA_AidProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('AidProtocol');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	// Create the template using a helper function
	return Passive('ILB_AidProtocolRefund', "img:///UILibrary_PerkIcons.UIPerk_aidprotocol", true, Effect);
}
static function X2AbilityTemplate CreateCrackdownAbility_Revenge()
{
	local X2AbilityTemplate Template;
	local X2Effect_CoveringFire CoveringEffect;

	Template = PurePassive('ILB_CrackdownRevenge', "img:///UILibrary_XPACK_Common.PerkIcons.str_revenge", false, 'eAbilitySource_Perk', true);
	CoveringEffect = new class'X2Effect_CoveringFire';
	CoveringEffect.BuildPersistentEffect(1, true, false, false);
	CoveringEffect.EffectName = 'RevengeFire';
	CoveringEffect.DuplicateResponse = eDupe_Ignore;
	CoveringEffect.AbilityToActivate = 'OverwatchShot';
	CoveringEffect.GrantActionPoint = 'overwatch';
	CoveringEffect.MaxPointsPerTurn = 0;	// Infinite
	CoveringEffect.bDirectAttackOnly = true;
	CoveringEffect.bPreEmptiveFire = false;
	CoveringEffect.bOnlyDuringEnemyTurn = true;
	CoveringEffect.bOnlyWhenAttackMisses = true;
	CoveringEffect.ActivationPercentChance = 100; //always
	CoveringEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(CoveringEffect);
	return Template;
}

//WOTC_APA_AidProtocol version of Multitasking


static function X2AbilityTemplate WitchHunterBuff()
{
	local X2AbilityTemplate Template;
	local ILB_X2Effect_WitchHunter Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_WitchHunter', "img:///UILibrary_PerkIcons.UIPerk_sectoid_mindspin", true, none);

	// Create a persistent stat change effect
	Effect = new class'ILB_X2Effect_WitchHunter';
	Effect.Bonus = default.ILB_WITCH_HUNTER_PASSIVE_DMG; //todo: configs
	Effect.EffectName = 'Witch Hunter Passive';

	
	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	AddSecondaryEffect(Template, Effect);

	return Template;
}


static function X2AbilityTemplate HazmatShielding()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_HazmatShielding', "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest", true, none);

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'HazmatShielding';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_ShieldHP, default.ILB_HAZMAT_SHIELDS_BUFF);
	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	return Template;
}

static function X2AbilityTemplate PlatedVestShielding()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_PlatedShielding',"img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest", true, none);
	
	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'PlatedVestShielding';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	// The effect gives +10 Defense and +3 Mobility
	Effect.AddPersistentStatChange(eStat_ShieldHP, default.ILB_SAFETY_FIRST_SHIELDS_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	return Template;
}

///These are the abilities that benefit from Promethium Caches.
static function array<name> GetNamesOfFlamethrowerAbilities(){
	return default.FLAMER_SKILLS;
}



// Perk name:		Rocketeer
// Perk effect:		Your equipped heavy weapon gets an additional use.
// Localized text:	"Your equipped heavy weapon gets an additional use."
// Config:			(AbilityName="XMBExample_Rocketeer")
static function X2AbilityTemplate Rocketeer()
{
	local XMBEffect_AddItemCharges Effect;
	local X2AbilityTemplate Template;

	// Create an effect that adds a charge to the equipped heavy weapon
	Effect = new class'XMBEffect_AddItemCharges';
	Effect.ApplyToSlots.AddItem(eInvSlot_HeavyWeapon);
	Effect.PerItemBonus = 1;

	// The effect isn't an X2Effect_Persistent, so we can't use it as the effect for Passive(). Let
	// Passive() create its own effect.
	Template = Passive('ILB_Rocketeer', "img:///UILibrary_PerkIcons.UIPerk_firerocket", true);
	Template.Hostility = eHostility_Neutral;

	// Add the XMBEffect_AddItemCharges as an extra effect.
	AddSecondaryEffect(Template, Effect);

	return Template;
}

static function X2AbilityTemplate IncreaseFlamethrowerDamageAndCharges()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBEffect_AddAbilityCharges SecondaryEffect;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local XMBCondition_AbilityName AbilityNameCondition;
	local X2AbilityTemplate Template;

	local XMBEffect_ConditionalBonus EffectForChemthrowers;
	local XMBCondition_WeaponName ConditionForChemthrowers;

	EffectForChemthrowers = new class'XMBEffect_ConditionalBonus';
	EffectForChemthrowers.AddDamageModifier(1);
	
	ConditionForChemthrowers = new class'XMBCondition_WeaponName';
	ConditionForChemthrowers.IncludeWeaponNames.AddItem('chemthrower');
	EffectForChemthrowers.AbilityTargetConditions.AddItem(ConditionForChemthrowers);

	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(1);

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames = GetNamesOfFlamethrowerAbilities();
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);
	
	SecondaryEffect = new class'XMBEffect_AddAbilityCharges';
	SecondaryEffect.AbilityNames = GetNamesOfFlamethrowerAbilities();
	SecondaryEffect.BonusCharges = 1;
	SecondaryEffect.bAllowUseAmmoAsCharges = true;


	Template= Passive('ILB_PromethiumFireDamageBonus', "img:///UILibrary_PerkIcons.UIPerk_flamethrower", false, Effect);
	AddSecondaryEffect(Template, SecondaryEffect);
	AddSecondaryEffect(Template, EffectForChemthrowers);
	return Template;
}

static function X2AbilityTemplate ILBPocketFlamer()
{
	local X2AbilityTemplate Template;
	local MZ_Effect_AddSevenWeapon ItemEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ILB_PocketFlamer');
	
	`LOG("Registering ability: grant small flamethrower");
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ItemEffect = new class'MZ_Effect_AddSevenWeapon';
	ItemEffect.DataName = 'ILB_SmallerFlamethrower';
	ItemEffect.BaseCharges = 2;
	ItemEffect.InvSlotEnum = eInvSlot_SeptenaryWeapon;
	ItemEffect.BuildPersistentEffect(1, false, false, , eGameRule_PlayerTurnBegin); 
	Template.AddTargetEffect(ItemEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}


// Perk name:		Reverse Engineering
// Perk effect:		When you kill an enemy robotic unit you gain a permanent Hacking increase of 5.
// Localized text:	"When you kill an enemy robotic unit you gain a permanent Hacking increase of <Ability:Hacking/>."
// Config:			(AbilityName="XMBExample_ReverseEngineering")
static function X2AbilityTemplate RookieHpBuff()
{
	local XMBEffect_PermanentStatChange Effect;
	local X2AbilityTemplate Template;
	local X2Condition_UnitProperty Condition;

	Effect = new class'XMBEffect_PermanentStatChange';
	Effect.AddStatChange(eStat_HP, default.ROOKIE_COMBAT_HP_BONUS);

	// Create a triggered ability that activates whenever the unit gets a kill
	
	Template = Passive('ILB_RookieHpBuff', "img:///UILibrary_PerkIcons.UIPerk_fieldmedic", true, Effect);

	return Template;
}

static function X2AbilityTemplate ExtraMeleeDamage()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;
	local XMBCondition_AbilityProperty MeleeOnlyCondition;
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'Extra Melee Damage';
	Effect.AddDamageModifier(default.ILB_MELEE_DMG_BUFF, eHit_Success);

	MeleeOnlyCondition = new class'XMBCondition_AbilityProperty';
	MeleeOnlyCondition.bRequireMelee = true;
	Effect.AbilityTargetConditions.AddItem(MeleeOnlyCondition);

	// Create the template using a helper function
	Template = Passive('ILB_AdditionalMeleeDamage', "img:///UILibrary_PerkIcons.UIPerk_muton_punch", true, Effect);

	return Template;
}

static function X2AbilityTemplate PistolShotsDealPoisonPassive(){

	local X2AbilityTemplate Template;
	Template = Passive('ILB_PistolShotsDealPoisonPassive', "img:///UILibrary_PerkIcons.UIPerk_poisonspit", true, none);
	return Template;
}

static function X2AbilityTemplate ShellbusterMobilityBuff()
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;
	
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'Shellbuster_mobility';

	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.AddPersistentStatChange(eStat_Mobility, default.ILB_SHELLBUSTER_MOBILITY_BUFF);

	// Create the template using a helper function
	Template = Passive('ILB_ShellbusterMobilityBuff', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	return Template;
}


static function X2AbilityTemplate AridFastUnit()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;

	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_DawnMachines',"img:///UILibrary_PerkIcons.UIPerk_andromedon_robotbattlesuit", true, none);

	//DEFENSE
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Defense';
	// Add the condition to the stat change effect
	Condition = new class'X2Condition_MapProperty';
	Condition.AllowedBiomes.AddItem("Arid");
	Effect.TargetConditions.AddItem(Condition);

	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_ShieldHP, default.ILB_DAWN_MACHINES_SHIELDS_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	
	//SPEED
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Mobility';

	Effect.BuildPersistentEffect(1, true, false, false);
	// Add the condition to the stat change effect
	Condition = new class'X2Condition_MapProperty';
	Condition.AllowedBiomes.AddItem("Arid");
	Effect.TargetConditions.AddItem(Condition);

	Effect.AddPersistentStatChange(eStat_Mobility, default.ILB_DAWN_MACHINES_MOBILITY_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	

	/// Now: Evergreen +4 shielding
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Shield_Evergreen';
	Effect.AddPersistentStatChange(eStat_ShieldHP, default.ILB_DAWN_MACHINES_SHIELDS_BUFF);
	
	AddSecondaryEffect(Template, Effect);

	return Template;
}


// Perk name:		Oberon Exploit
// Perk effect:		-60 hack defense
// Localized text:	"You gain <Ability:+Defense/> Defense and <Ability:+Mobility/> Mobility in cold climates."
// Config:			(AbilityName="XMBExample_ArcticWarrior")
static function X2AbilityTemplate EasyToHack()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_EasyToHack', "img:///UILibrary_PerkIcons.UIPerk_hack", true, none);

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'EasyToHack';
	Effect.BuffCategory = ePerkBuff_Penalty;

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_HackDefense, default.HACK_DEFENSE_DEBUFF, MODOP_PostMultiplication);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	return Template;
}




// Perk name:		Mab Exploit
// Perk effect:		-60 hack defense in cold climates
// Localized text:	"You gain <Ability:+Defense/> Defense and <Ability:+Mobility/> Mobility in cold climates."
// Config:			(AbilityName="XMBExample_ArcticWarrior")
static function X2AbilityTemplate ArcticEasyToHack()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_EasyToHackInTundra', "img:///UILibrary_PerkIcons.UIPerk_hack", true, none);
	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.BuffCategory = ePerkBuff_Penalty;
	Effect.EffectName = 'ArcticEasyToHack';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_HackDefense, default.HACK_DEFENSE_DEBUFF, MODOP_PostMultiplication);

	// Create a condition that only applies the stat change when in the Tundra biome
	Condition = new class'X2Condition_MapProperty';
	Condition.AllowedBiomes.AddItem("Tundra");

	// Add the condition to the stat change effect
	Effect.TargetConditions.AddItem(Condition);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	return Template;
}



	static function X2AbilityTemplate FreeSmokeGrenades()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'SmokeGrenade';
		ItemEffect.BaseCharges = default.ILB_VIP_SMOKES;
		// Create the template using a helper function
		Template = Passive('ILB_DangerousVips_Smoke', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

		return Template;
	}

	static function X2AbilityTemplate FreeFragGrenades()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'FragGrenade';
		ItemEffect.BaseCharges = default.ILB_VIP_FRAGS;
		// Create the template using a helper function
		Template = Passive('ILB_DangerousVips_Frag', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

		return Template;
	}

	static function X2AbilityTemplate FreeSmokeGrenadeSingular()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'SmokeGrenade';

		Template = Passive('ILB_FreeSmokeGrenadeSingular',
		 "img:///UILibrary_PerkIcons.UIPerk_grenade_smoke", ///todo: verify perk icon
		  true,
		   ItemEffect);

		return Template;
	}


	static function X2AbilityTemplate FreeUltrasonicLure()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'UltrasonicLure';
		// Create the template using a helper function
		Template = Passive('ILB_FreeUltrasonicLure', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

		return Template;
	}

// Helper method for quickly defining a non-pure passive. Works like PurePassive, except it also 
// takes an X2Effect_Persistent.
static function X2AbilityTemplate Passive(name DataName, string IconImage, optional bool bCrossClassEligible = false, optional X2Effect Effect = none)
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus ConditionalBonusEffect;
	local XMBEffect_ConditionalStatChange ConditionalStatChangeEffect;
	local X2Effect_Persistent PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, DataName);
	Template.IconImage = IconImage;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	PersistentEffect = X2Effect_Persistent(Effect);
	ConditionalBonusEffect = XMBEffect_ConditionalBonus(Effect);
	ConditionalStatChangeEffect = XMBEffect_ConditionalStatChange(Effect);

	if (ConditionalBonusEffect != none && !AlwaysRelevant(ConditionalBonusEffect))
	{
		ConditionalBonusEffect.BuildPersistentEffect(1, true, false, false);
		ConditionalBonusEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, true,,Template.AbilitySourceName);
		ConditionalBonusEffect.bHideWhenNotRelevant = true;

		PersistentEffect = new class'X2Effect_Persistent';
		PersistentEffect.EffectName = name(DataName $ "_Passive");
	}
	else if (ConditionalStatChangeEffect != none)
	{
		ConditionalStatChangeEffect.BuildPersistentEffect(1, true, false, false);
		ConditionalStatChangeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, true,,Template.AbilitySourceName);

		PersistentEffect = new class'X2Effect_Persistent';
		PersistentEffect.EffectName = name(DataName $ "_Passive");
	}
	else if (PersistentEffect == none)
	{
		PersistentEffect = new class'X2Effect_Persistent';
	}

	PersistentEffect.BuildPersistentEffect(1, true, false, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	if (Effect != PersistentEffect && Effect != none)
		Template.AddTargetEffect(Effect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = bCrossClassEligible;

	return Template;
}

static function X2AbilityTemplate AddTurretHackabilityDebuff()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ILB_TurretHackDefenseDebuff');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	//
	Template.AddTargetEffect( class'X2StatusEffects'.static.CreateHackDefenseChangeStatusEffect( -60 ) ); //todo: config

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

/*
static function X2AbilityTemplate IncreaseTeamworkCharges()
{
	local XMBEffect_ConditionalBonus Effect;
	local X2Condition_UnitProperty UnitPropertyCondition;
	local X2AbilityTemplate Template;

	Effect = new class'XMBEffect_AddAbilityCharges';
	Effect.AbilityNames.AddItem('BondmateTeamwork');
	Effect.AbilityNames.AddItem('BondmateTeamwork_Improved');
	Effect.BonusCharges = 1;
	Effect.bAllowUseAmmoAsCharges = true;

	Template = Passive('ILB_MoreChargesForTeamwork', "img:///UILibrary_PerkIcons.UIPerk_flamethrower", false, Effect);
	AddSecondaryEffect(Template, SecondaryEffect);
	return Template;
}
*/