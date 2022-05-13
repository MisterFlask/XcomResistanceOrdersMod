//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_XPackAbilitySet.uc
//  AUTHOR:  Russell Aasland  --  02/13/2017
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class IRB_AdditionalResistanceOrders_Abilities extends XMBAbility
	config(Abilities);

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

var config int HACK_DEFENSE_DEBUFF;
var config int HACK_DEFENSE_DEBUFF_TUNDRA;

var config int ILB_MELEE_DMG_BUFF;
var config int ILB_VIP_SMOKES;
var config int ILB_VIP_FRAGS;

var config int ROOKIE_COMBAT_HP_BONUS;
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

	return Templates;
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
	return Passive('ILB_AidProtocolRefund', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}


//WOTC_APA_AidProtocol version of Multitasking


static function X2AbilityTemplate WitchHunterBuff()
{
	local X2AbilityTemplate Template;
	local ILB_X2Effect_WitchHunter Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_WitchHunter', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

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
	Template = Passive('ILB_HazmatShielding', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

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
	Template = Passive('ILB_PlatedShielding', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

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

static function array<name> GetNamesOfFlamethrowerAbilities(){
	local array<name> AbilitiesList;

	AbilitiesList.AddItem('AdvPurifierFlamethrower');
	AbilitiesList.AddItem('LWFlamethrower');
	AbilitiesList.AddItem('FireMZPocketFlamethrower');
	AbilitiesList.AddItem('FlamethrowerMk2');
	AbilitiesList.AddItem('Flamethrower');
	return AbilitiesList;
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
	Template = Passive('ILB_Rocketeer', "img:///UILibrary_PerkIcons.UIPerk_command", true);

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
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.AddDamageModifier(2);

	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames = GetNamesOfFlamethrowerAbilities();
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);
	
	SecondaryEffect = new class'XMBEffect_AddAbilityCharges';
	SecondaryEffect.AbilityNames = GetNamesOfFlamethrowerAbilities();
	SecondaryEffect.BonusCharges = 1;
	SecondaryEffect.bAllowUseAmmoAsCharges = true;


	Template= Passive('ILB_PromethiumFireDamageBonus', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect);
	AddSecondaryEffect(Template, SecondaryEffect);
	return Template;
}

static function X2AbilityTemplate ILBPocketFlamer()
{
	local X2AbilityTemplate Template;
	local MZ_Effect_AddSevenWeapon ItemEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'ILB_PocketFlamer');
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_flamethrower";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ItemEffect = new class'MZ_Effect_AddSevenWeapon';
	ItemEffect.DataName = 'IRB_SmallerFlamethrower';
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
	
	Template = Passive('ILB_RookieHpBuff', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

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
	Template = Passive('ILB_AdditionalMeleeDamage', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	return Template;
}

static function X2AbilityTemplate PistolShotsDealPoisonPassive(){

	local X2AbilityTemplate Template;
	Template = Passive('ILB_PistolShotsDealPoisonPassive', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);
	return Template;
}

static function X2AbilityTemplate ShellbusterMobilityBuff()
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;
	
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Mobility';

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
	
	// Create a condition that only applies the stat change when in the Tundra biome
	Condition = new class'X2Condition_MapProperty';
	Condition.AllowedBiomes.AddItem("Arid");

	// Add the condition to the stat change effect
	Effect.TargetConditions.AddItem(Condition);

	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_DawnMachines', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

	//DEFENSE
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Defense';

	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_ShieldHP, default.ILB_DAWN_MACHINES_SHIELDS_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	
	//SPEED
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'DawnMachines_Mobility';

	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_Mobility, default.ILB_DAWN_MACHINES_MOBILITY_BUFF);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);
	
	return Template;
}


// Perk name:		Aestas Exploit
// Perk effect:		-60 hack defense
// Localized text:	"You gain <Ability:+Defense/> Defense and <Ability:+Mobility/> Mobility in cold climates."
// Config:			(AbilityName="XMBExample_ArcticWarrior")
static function X2AbilityTemplate EasyToHack()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_EasyToHack', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'EasyToHack';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_HackDefense, default.HACK_DEFENSE_DEBUFF);

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
	Template = Passive('ILB_EasyToHackInTundra', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'ArcticEasyToHack';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	// The effect gives +10 Defense and +3 Mobility
	Effect.AddPersistentStatChange(eStat_HackDefense, default.HACK_DEFENSE_DEBUFF);

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
	
	static function X2AbilityTemplate FreeUltrasonicLure()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'UltrasonicLure';
		ItemEffect.BaseCharges = 1;
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


// Perk name:		Cutthroat
// Perk effect:		Your melee attacks against biological enemies ignore their armor, have increased critical chance, and do additional critical damage.
// Localized text:	"Your melee attacks against biological enemies ignore their armor, have a +<Ability:CUTTHROAT_BONUS_CRIT_CHANCE/> critical chance, and do +<Ability:CUTTHROAT_BONUS_CRIT_DAMAGE/> critical damage."
// Config:			(AbilityName="LW2WotC_Cutthroat")
static function X2AbilityTemplate Cutthroat()
{
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityProperty MeleeOnlyCondition;
	local X2Condition_UnitProperty OrganicCondition;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

    // The bonus adds critical hit chance
	Effect.AddToHitModifier(default.ILB_CUTTHROAT_BONUS_CRIT_CHANCE, eHit_Crit);

	// The bonus adds damage to critical hits
	Effect.AddDamageModifier(default.ILB_CUTTHROAT_BONUS_CRIT_DAMAGE, eHit_Crit);

    // The bonus ignores armor
    Effect.AddArmorPiercingModifier(default.ILB_CUTTHROAT_BONUS_ARMOR_PIERCE);
    
	// Only melee attacks
	MeleeOnlyCondition = new class'XMBCondition_AbilityProperty';
	MeleeOnlyCondition.bRequireMelee = true;
	Effect.AbilityTargetConditions.AddItem(MeleeOnlyCondition);
	
	// Only against organics
	OrganicCondition = new class'X2Condition_UnitProperty';
	OrganicCondition.ExcludeRobotic = true;
	Effect.AbilityTargetConditions.AddItem(OrganicCondition);

	// Create the template using a helper function
	return Passive('ILB_LW2WotC_Cutthroat', "img:///UILibrary_LW_PerkPack.LW_AbilityCutthroat", false, Effect);
}