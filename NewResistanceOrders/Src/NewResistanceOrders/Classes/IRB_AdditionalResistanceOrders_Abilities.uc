//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_XPackAbilitySet.uc
//  AUTHOR:  Russell Aasland  --  02/13/2017
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class IRB_AdditionalResistanceOrders_Abilities extends X2Ability
	config(GameCore);

	//UltrasonicLure
/// <summary>
/// Creates the set of default abilities every unit should have in X-Com 2
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{ 
	local array<X2DataTemplate> Templates;

	Templates.AddItem(FreeFragGrenades());
	Templates.AddItem(FreeUltrasonicLure());

	return Templates;
}


	static function X2AbilityTemplate FreeFragGrenades()
	{
		local X2AbilityTemplate Template;
		local XMBEffect_AddUtilityItem ItemEffect;

		ItemEffect = new class'XMBEffect_AddUtilityItem';
		ItemEffect.DataName = 'FragGrenade';
		ItemEffect.BaseCharges = 2;
		// Create the template using a helper function
		Template = Passive('ILB_TwoExtraFrags', "img:///UILibrary_PerkIcons.UIPerk_grenade_flash", true, ItemEffect);

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
