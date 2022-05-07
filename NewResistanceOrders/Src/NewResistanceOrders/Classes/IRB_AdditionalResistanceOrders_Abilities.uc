//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_XPackAbilitySet.uc
//  AUTHOR:  Russell Aasland  --  02/13/2017
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class IRB_AdditionalResistanceOrders_Abilities extends XMBAbility
	config(GameCore);

	
var config int ILB_CUTTHROAT_BONUS_CRIT_CHANCE;
var config int ILB_CUTTHROAT_BONUS_CRIT_DAMAGE;
var config int ILB_CUTTHROAT_BONUS_ARMOR_PIERCE;

	//UltrasonicLure
/// <summary>
/// Creates the set of default abilities every unit should have in X-Com 2
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{ 
	local array<X2DataTemplate> Templates;

	Templates.AddItem(FreeFragGrenades());
	Templates.AddItem(FreeUltrasonicLure());
	Templates.AddItem(ArcticEasyToHack());
	Templates.AddItem(EasyToHack());
	Templates.AddItem(AridFastUnit());
	Templates.AddItem(PlatedVestShielding());
	Templates.AddItem(HazmatShielding());
	Templates.AddItem(AddTurretHackabilityDebuff());
	return Templates;
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
	Effect.EffectName = 'AridFast';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	// The effect gives +10 Defense and +3 Mobility
	Effect.AddPersistentStatChange(eStat_Mobility, 4);

	// Create a condition that only applies the stat change when in the Tundra biome
	Condition = new class'X2Condition_MapProperty';
	Condition.AllowedBiomes.AddItem("Arid");

	// Add the condition to the stat change effect
	Effect.TargetConditions.AddItem(Condition);

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
	Effect.AddPersistentStatChange(eStat_ShieldHP, 1);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle, but only if it meets the condition.
	AddSecondaryEffect(Template, Effect);

	return Template;
}

static function X2AbilityTemplate AridFastUnit()
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;
	local X2Condition_MapProperty Condition;
	
	// Create the template as a passive with no effect. This ensures we have an ability icon all the time.
	Template = Passive('ILB_DawnMachines', "img:///UILibrary_PerkIcons.UIPerk_command", true, none);

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'HazmatShielding';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	Effect.AddPersistentStatChange(eStat_ShieldHP, 1);

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

	Effect.AddPersistentStatChange(eStat_HackDefense, -60);

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
	Effect.AddPersistentStatChange(eStat_HackDefense, -60);

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



	static function X2AbilityTemplate FreeFragGrenades()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'FragGrenade';
		ItemEffect.BaseCharges = 2;
		// Create the template using a helper function
		Template = Passive('ILB_DangerousVips', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

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