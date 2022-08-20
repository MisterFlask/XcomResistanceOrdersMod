//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_ExampleWeapon.uc
//  AUTHOR:  Ryan McFall
//           
//	Demonstrates how to use the X2DownloadableContentInfo class to specify unique mod
//  behavior when the player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_NewResistanceOrders extends X2DownloadableContentInfo
	config(Abilities);
// Configurable list of abilities that should apply to the primary
// weapon. This is necessary because character template abilities
// can't be configured for a weapon slot, but some of those abilities
// need to be tied to a weapon slot to work.
//
// This is used in FinalizeUnitAbilitiesForInit() to patch existing
// abilities for non-XCOM units.
var config array<name> PISTOL_SKILLS;
var localized string ConsumableText;


static final function bool IsModActive(name ModName)
{
    local XComOnlineEventMgr    EventManager;
    local int                   Index;

    EventManager = `ONLINEEVENTMGR;

    for (Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--) 
    {
        if (EventManager.GetDLCNames(Index) == ModName) 
        {
            return true;
        }
    }
    return false;
}

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
}

function XComGameState_HeadquartersResistance GetResistanceHQ()
{
	return XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
}

exec function VerifyPlayableCards()
{
	local XComGameStateHistory History;
	local XComGameState_StrategyCard CurrentCard;
	local array<X2DataTemplate> RelevantRewardTemplates;
	local X2DataTemplate DataTemplate;
	local X2SitRepTemplate SitRepTemplate;
	local X2SitRepEffectTemplate SitRepEffectTemplate;
	local X2SitRepEffect_GrantAbilities SitRepGrantingAbilities;
	// templates for rewards
	local X2StrategyCardTemplate CurrentTemplate;
	local X2RewardTemplate RewardTemplate;
	local name TemplateName;
	local array<X2DataTemplate> AllSitrepEffectTemplates;
	local array<X2DataTemplate> AllSitRepTemplates;

	AllSitRepTemplates = class'ILB_DefaultSitrepsParent'.static.CreateTemplates();
	AllSitrepEffectTemplates = class'ILB_DefaultSitreps'.static.CreateTemplates();

	RelevantRewardTemplates = class'ILB_DefaultMissionRewards'.static.CreateTemplates();
	History = `XCOMHISTORY;

	`LOG("INFO:Checking all templates for errors.");
	
	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CurrentCard)
	{
		CurrentTemplate = CurrentCard.GetMyTemplate();
		`LOG("INFO:Checking Template for errors: " $ CurrentTemplate.DataName);

		if (CurrentTemplate.QuoteText == ""){
			`LOG("ERROR: QUOTETEXT EMPTY in Template " $ CurrentTemplate.DataName);
		}
		if (CurrentTemplate.Strength == 0){
			`LOG("ERROR: STRENGTH EMPTY in Template " $ CurrentTemplate.DataName);
		}
		if (CurrentTemplate.AssociatedEntity == ''){
			`LOG("ERROR: FACTION EMPTY in Template " $ CurrentTemplate.DataName);
		}
	}

	`LOG("now checking all reward templates for errors");

	foreach RelevantRewardTemplates(DataTemplate){
		RewardTemplate = X2RewardTemplate(DataTemplate);
		if (RewardTemplate.DisplayName == ""){
			`LOG("ERROR:  Reward template display name empty for " $ RewardTemplate.DataName);
		}
	}
	`LOG("checking all sitrep effects... ");

	foreach AllSitrepEffectTemplates(DataTemplate){
		SitRepEffectTemplate = X2SitRepEffectTemplate(DataTemplate);
		`LOG("checking sitrep effect: " $ SitRepEffectTemplate.DataName);

		if (SitRepEffectTemplate.FriendlyName == ""){
			`LOG("ERROR: Sitrep Effect template FriendlyName name empty for " $ SitRepEffectTemplate.DataName);
		}	

		SitRepGrantingAbilities = X2SitRepEffect_GrantAbilities(SitRepEffectTemplate);
		if (SitRepGrantingAbilities != none){
			`LOG("CHecking abilities of sitrep grant-abilities effect " $ SitRepGrantingAbilities.DataName);
			if (SitRepGrantingAbilities.AbilityTemplateNames.Length == 0){
				`LOG("ERROR:  No abilities set for sitrep template");
			}else{
				PrintAbilities(SitRepGrantingAbilities.AbilityTemplateNames);
			}
		}

	}
	`LOG("checking all sitreps... ");

	foreach AllSitRepTemplates(DataTemplate){
		SitRepTemplate = X2SitRepTemplate(DataTemplate);
		`LOG("checking sitrep: " $ SitRepTemplate.DataName);

		if (SitRepTemplate.FriendlyName == ""){
			`LOG("ERROR: Reward template display name empty for " $ SitRepTemplate.DataName);
		}
		if (SitRepTemplate.NegativeEffects.Length  == 0){
			`LOG("ERROR: Sitrep template negative effects is empty for " $ SitRepTemplate.DataName);
		}

		foreach SitRepTemplate.NegativeEffects(TemplateName){
			`LOG("Checking on sitrep effect owned by current sitrep (named above)... " $ TemplateName);

			SitRepEffectTemplate = class'X2SitRepEffectTemplateManager'.static.GetSitRepEffectTemplateManager().FindSitRepEffectTemplate ( TemplateName ) ;
			if (SitRepEffectTemplate == none){
				`LOG("ERROR:  Sitrep effect is not initialized for SitRepEffectTemplate " $ TemplateName);
			}
		}
	}


}

// prints out if all the abilities exist nad what they ares
static function PrintAbilities(array<name> AbilityNames){
	local name TemplateName;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	
	foreach AbilityNames(TemplateName){
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(TemplateName);
		if (AbilityTemplate != none)
		{	
			`LOG("Successfully verified : " $ TemplateName);
		}else{
			`LOG("COULD NOT verify: " $ TemplateName);
		}
	}
}

exec function ActivateAllCards()
{
	local XComGameStateHistory History;
	local XComGameState_StrategyCard CurrentCard;
	History = `XCOMHISTORY;

	`LOG("INFO:Checking all templates for errors.");
	
	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CurrentCard)
	{
		ActivatePolicyCard(string(CurrentCard.GetMyTemplateName()));
	}
}
function ActivatePolicyCard( string PolicyName )
{
	local XComGameStateHistory History;
	local X2StrategyElementTemplateManager TemplateManager;
	local X2StrategyCardTemplate PolicyTemplate;
	local XComGameState NewGameState;
	local XComGameState_StrategyCard PolicyState;
	local XComGameState_HeadquartersResistance ResHQ;

	History = `XCOMHISTORY;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	PolicyTemplate = X2StrategyCardTemplate( TemplateManager.FindStrategyElementTemplate( name(PolicyName) ) );

	if (PolicyTemplate == none)
		return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: ActivatePolicyCard");

	PolicyState = PolicyTemplate.CreateInstanceFromTemplate( NewGameState );
	PolicyState.bDrawn = true;

	ResHQ = XComGameState_HeadquartersResistance( History.GetSingleGameStateObjectForClass( class'XComGameState_HeadquartersResistance' ) );
	ResHQ = XComGameState_HeadquartersResistance( NewGameState.ModifyStateObject( class'XComGameState_HeadquartersResistance', ResHQ.ObjectID ) );

	ResHQ.WildCardSlots.AddItem( PolicyState.GetReference() );

	PolicyState.ActivateCard( NewGameState );

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}


/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
}


exec function RunOnPostTemplatesCreated(){
	OnPostTemplatesCreated();
}

static event OnPostTemplatesCreated(){
	`LOG("ILB:  Updating Abilities");
	UpdateAbilities();
	UpdateResOrderDescriptions();
}



static function UpdateResOrderDescriptions()
{
	local X2StrategyElementTemplateManager		StrategyTemplateMgr;
	local X2StrategyCardTemplate CardTemplate;
	local array<Name> TemplateNames;
	local Name TemplateName;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate;

	`LOG("Updating res order descriptions");

	StrategyTemplateMgr	= class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	StrategyTemplateMgr.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
 		StrategyTemplateMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
		foreach DataTemplates(DataTemplate)
		{
			CardTemplate = X2StrategyCardTemplate(DataTemplate);

			if(CardTemplate != none 
			// chosen actions are a subclass of card templates, so we need to check for that
			&& X2ChosenActionTemplate(DataTemplate) == none)
			{
				CardTemplate.GetSummaryTextFn = GetSummaryTextExpanded;
			}
		}
	}
}

static function string GetSummaryTextExpanded(StateObjectReference InRef)
{
	local XComGameState_StrategyCard CardState;
	local X2StrategyCardTemplate CardTemplate;
	local XGParamTag ParamTag;
	local X2AbilityTag AbilityTag;
	local string ConsumableString;
	local array<ResistanceCardConfigValues> Configs;
	local ResistanceCardConfigValues CurrentConfig;
	Configs = class'ILB_Utils'.static.GetResistanceCardConfigs();

	CardState = GetCardState(InRef);

	if(CardState == none)
	{
		return "Error in GetSummaryText function";
	}

	CardTemplate = CardState.GetMyTemplate();
	CurrentConfig=class'ILB_Utils'.static.GetResistanceCardConfigsForResCard(CardTemplate.DataName, Configs);
	if (CurrentConfig.ResCardName != ''){
		`Log("Observed config for res card: " $ CurrentConfig.ResCardName $ " : " $ CurrentConfig.StringValue0 $ " :  " $ CurrentConfig.StringValue1);
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		ParamTag.StrValue0 = CurrentConfig.StringValue0;
		ParamTag.StrValue1 = CurrentConfig.StringValue1;
		ParamTag.IntValue0 = CurrentConfig.IntValue0;
		ParamTag.IntValue1 = CurrentConfig.IntValue1;
	}

    if(CardTemplate.GetMutatorValueFn != none)
	{
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		ParamTag.IntValue0 = CardTemplate.GetMutatorValueFn();
	}


	AbilityTag = X2AbilityTag(`XEXPANDCONTEXT.FindTag("Ability"));
	AbilityTag.ParseObj = CardState;

	ConsumableString = "";
	if (class'X2EventListener_Strategy'.default.CONSUMABLE_RESISTANCE_ORDERS.Find(CardState.GetMyTemplateName()) != INDEX_NONE)
	{
		ConsumableString = default.ConsumableText;
	}


	return `XEXPAND.ExpandString(ConsumableString $ CardTemplate.SummaryText);
}

static function XComGameState_StrategyCard GetCardState(StateObjectReference CardRef)
{
	return XComGameState_StrategyCard(`XCOMHISTORY.GetGameStateForObjectID(CardRef.ObjectID));
}

static function UpdateAbilities()
{

	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						PistolAbility;
	local X2Condition_AbilityProperty			AbilityCondition;
	local name									AbilityName;
	local X2Effect_PersistentStatChange			PoisonEffect;	
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	// Poison Effect
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('ILB_PistolShotsDealPoisonPassive'); //PistolShotsDealPoisonPassive is the name of the ability
	PoisonEffect = class'X2StatusEffects'.static.CreatePoisonedStatusEffect();
	PoisonEffect.EffectTickedFn = none;
	PoisonEffect.TargetConditions.AddItem(AbilityCondition);

	foreach default.PISTOL_SKILLS(AbilityName) 
	{
		`LOG("adding poison effect to pistol skill " $ AbilityName);
		PistolAbility = AbilityManager.FindAbilityTemplate(AbilityName);
		if ( PistolAbility != none )
		{
			PistolAbility.AddTargetEffect(PoisonEffect);
		}
	}
}

static function ResistanceCardConfigValues CardConf(name CardName){
	return class'ILB_Utils'.static.GetResistanceCardConfig(CardName);
}


exec static function PrintAllResCardConfigs(){
	local array<ResistanceCardConfigValues> Configs;
	local ResistanceCardConfigValues CurrentConfig;
	local ResistanceCardRewardMod CurrentRewardMod;
	local ResistanceCardSitrepMod CurrentSitrepMod;
	Configs = class'ILB_Utils'.static.GetResistanceCardConfigs();
	foreach Configs(CurrentConfig)
	{
		`LOG("ILB Config at priority " $ CurrentConfig.Priority $ " for res card " $ CurrentConfig.ResCardName);
		`LOG("ILB: Config: " $ CurrentConfig.ResCardName $ " : " $ CurrentConfig.StringValue0 $ " :  " $ CurrentConfig.StringValue1);
		foreach CurrentConfig.RewardMods(CurrentRewardMod){
			`LOG("ILB: Reward Mod: " $ CurrentRewardMod.ApplicableMissionFamilyIfAny $ " : " $ CurrentRewardMod.ApplicableMissionSourceIfAny $ " :  " $ CurrentRewardMod.RewardApplied $ " : " $ CurrentRewardMod.RewardQuantity);
		}		

		foreach CurrentConfig.SitrepMods(CurrentSitrepMod){
			`LOG("ILB: Sitre[] Mod: " $ CurrentSitrepMod.ApplicableMissionFamilyIfAny $ " : " $ CurrentSitrepMod.ApplicableMissionSourceIfAny $ " :  " $ CurrentSitrepMod.SitrepApplied);
		}
	}
}

/// <summary>
/// Called from XComGameState_Missionsite:SetMissionData
/// lets mods add SitReps with custom spawn rules to newly generated missions
/// Advice: Check for present Strategy game if you dont want this to affect TQL/Multiplayer/Main Menu 
/// Example: If (`HQGAME  != none && `HQPC != None && `HQPRES != none) ...
/// </summary>
static function PostSitRepCreation(out GeneratedMissionData GeneratedMission, optional XComGameState_BaseObject SourceObject)
{
	// todo: look into options for injured soldier sitrep
	
	local XComGameState_MissionSite MissionState;
	local XComGameState NewGameState;
	local name CurrentSitrepName;
	local array<name> SitrepList;
	local XComGameStateHistory CachedHistory;
	local ResistanceCardRewardMod CurrentRewardMod;
	local ResistanceCardConfigValues CurrentConfig;
	local array<ResistanceCardConfigValues> Configs;
	Configs = class'ILB_Utils'.static.GetResistanceCardConfigs();

	//NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("TempGameState");
	CachedHistory = `XCOMHISTORY;
	NewGameState = CachedHistory.GetGameStateFromHistory();

	MissionState = XComGameState_MissionSite(SourceObject);

	if (MissionState == none){
		MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(GeneratedMission.MissionID));
	}

	if (MissionState == none){
		`LOG("ERROR: Could not find mission state for mission id " $ GeneratedMission.MissionID);
	}

	If (`HQGAME  != none && `HQPC != None && `HQPRES != none) // we're in strategy
	{
		// first, go through the rewards for each res card config
		foreach Configs(CurrentConfig)
		{
			foreach CurrentConfig.RewardMods(CurrentRewardMod){
				if (CurrentRewardMod.ApplicableMissionFamilyIfAny != ''){
					AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, CurrentRewardMod.RewardApplied, CurrentConfig.ResCardName, CurrentRewardMod.ApplicableMissionFamilyIfAny, 30); //TODO: Remove this and add an ADVENT soldier to Bureaucratic Infighting
				}
			}
		}

		//todo: random chance
		//AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'ShowOfForce', 'Recover', GeneratedMission);
		//AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'LootChests', 'Recover', GeneratedMission);

		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Neutralize', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Neutralize', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'Terror', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'Retaliation', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'ChosenRetaliation', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'ProtectDevice', GeneratedMission);

		AddSitrepToMissionSourceIfResistanceCardsActive(MissionState, 'ResCard_AggressiveOpportunism', 'ILB_DecreaseTimer1Sitrep', 'MissionSource_GuerillaOp', GeneratedMission);
	    //AddRewardsToMissionSourceIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ResCard_AggressiveOpportunism', 'MissionSource_GuerillaOp', class'ILB_LootTablePresetReward'.static.BuildMissionItemReward_AggressiveOpportunism(NewGameState)); //TODO: Remove this and add an ADVENT soldier to Bureaucratic Infighting

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Intel', 'ResCard_SupplyRaidsForHacks', 'Hack', 30); 
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_SupplyRaid', 'ResCard_SupplyRaidsForHacks', 'Hack', 1); 
		
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ILB_Reward_Squaddie', 'ResCard_MassivePopularity', 'Terror', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ILB_Reward_Squaddie', 'ResCard_MassivePopularity', 'ChosenRetaliation', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Ammo', 'ResCard_StolenShippingSchedules', 'SupplyLineRaid', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Grenade', 'ResCard_StolenShippingSchedules', 'SupplyLineRaid', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.

		AddCrackdownSitrepsBasedOnResistanceCardsActive(MissionState, GeneratedMission);
		AddRandomizedEffectsToMission(MissionState, GeneratedMission);
		`LOG("enumerating sitreps selected for mission");
		SitrepList = GeneratedMission.SitReps;
		foreach SitrepList(CurrentSitrepName)
		{
			`LOG("Sitrep selected for mission: " $ GeneratedMission.BattleOpName $ " : " $ CurrentSitrepName);
		}

	}
}

static function bool IsMissionSourceEligibleForRandomizedSitreps(name MissionSource){
	return MissionSource == 'MissionSource_GuerillaOp' 
		|| MissionSource == 'MissionSource_Council'
		|| MissionSource == 'MissionSource_ActivityCI' // generic covert infiltration mission source
		|| MissionSource == 'MissionSource_LWSGenericMissionSource';
}

static function AddRandomizedEffectsToMission(XComGameState_MissionSite MissionState, out GeneratedMissionData GeneratedMission)
{
	local ResistanceCardConfigValues CurrentConfig;
	// local array<ResistanceCardConfigValues> Configs;
	local int Roll;
	local name MissionSource;
	// Configs = class'ILB_Utils'.static.GetResistanceCardConfigs();
	MissionSource = MissionState.GetMissionSource().DataName; // e.g. 'MissionSource_GuerillaOp'
	// First: handle retaliation crackdowns

	if (!(IsMissionSourceEligibleForRandomizedSitreps(MissionSource))) // generic LWOTC mission source
	{
		return;
	}

	if (IsResCardActive('ResCard_BureaucraticInfighting'))
	{
		CurrentConfig = class'ILB_Utils'.static.GetResistanceCardConfig('ResCard_BureaucraticInfighting');
		Roll = Rand(100);

		`LOG("Roll performed for bureaucratic infighting! " $ Roll $ " vs max threshold (% chance) of " $ CurrentConfig.IntValue0);
		if (Roll < CurrentConfig.IntValue0)
		{ //todo: configs
			GeneratedMission.SitReps.AddItem('ILB_BureaucraticInfightingSitrep');
			GeneratedMission.SitReps.AddItem('ShowOfForce');
			GeneratedMission.SitReps.AddItem('LootChests');
		}
	}
}

static function AddCrackdownSitrepsBasedOnResistanceCardsActive(XComGameState_MissionSite MissionState, out GeneratedMissionData GeneratedMission){
	local int PercentageCrackdownChance;
	local int CrackdownRoll;
	local name MissionSource;
	local string MissionFamily;
	local bool RelevantMissionSourceForRandomCrackdown;
	local name CrackdownSitrepAdded;
	RelevantMissionSourceForRandomCrackdown = false;
	MissionSource = MissionState.GetMissionSource().DataName; // e.g. 'MissionSource_GuerillaOp'
	MissionFamily = MissionState.GeneratedMission.Mission.MissionFamily;
	// First: handle retaliation crackdowns

	if (IsResCardActive('ResCard_RadioFreeLily') && IsRetaliation(MissionFamily))
	{
		`LOG("Adding plus one force level sitrep due to retaliation + Radio Free Lily");
		GeneratedMission.SitReps.AddItem('ILB_Sitrep_PlusOneForceLevel');
	}

	if (IsMissionSourceEligibleForRandomizedSitreps(MissionSource)) // generic LWOTC mission source
	{
		RelevantMissionSourceForRandomCrackdown = true;
		`LOG("Relevant mission detected for crackdown rolls; now, we roll.");
	}

	// now we handle generic crackdowns based on res cards selected
	if (RelevantMissionSourceForRandomCrackdown){
	
		/// calculation of crackdown chance based on active resistance cards.
		/// should ensure none of these can be continent bonuses.
		PercentageCrackdownChance = 0;

		if (IsResCardActive('ResCard_NotoriousSmugglers')){
			PercentageCrackdownChance += 15;
		}
		if (IsResCardActive('ResCard_BrazenCollection')){
			PercentageCrackdownChance += 15;
		}
		if (IsResCardActive('ResCard_BrazenRecruitment')){
			PercentageCrackdownChance += 15;
		}
		if (IsResCardActive('ResCard_LeachPsionicLeylines')){
			PercentageCrackdownChance += 15;
		}

		`LOG("Total percent crackdown chance based on res cards active: " $ PercentageCrackdownChance);
		CrackdownRoll = Rand(100);
		`LOG("Crackdown Roll (1-100): " $ CrackdownRoll);

		if (CrackdownRoll < PercentageCrackdownChance)
		{
		
			CrackdownSitrepAdded = GrabRandomCrackdownSitrep();
			`LOG("Added crackdown " $ CrackdownSitrepAdded $ " to mission " $ GeneratedMission.Mission.MissionFamily $ ":" $ GeneratedMission.BattleOpName);
			GeneratedMission.SitReps.AddItem(CrackdownSitrepAdded);
		}
		else
		{
			`LOG("Elected not to use crackdown sitrep on eligible mission.");
		}
	}else{
		`LOG("Mission type excluded from crackdown due to being " $ MissionSource);
	}

}
/*

	static function PrintEffectsOfAbilitySitrep(array<name> SitReps){
		foreach class'X2SitreptemplateManager'.static.IterateEffects(class'X2SitRepEffect_GrantAbilities', SitRepEffect, SitReps)
		{
			SitRepEffect.GetAbilitiesToGrant(self, GrantedAbilityNames);
			for (i = 0; i < GrantedAbilityNames.Length; ++i)
			{
				AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(GrantedAbilityNames[i]);
				if( AbilityTemplate != none &&
					(!AbilityTemplate.bUniqueSource || arrData.Find('TemplateName', AbilityTemplate.DataName) == INDEX_NONE) &&
				   AbilityTemplate.ConditionsEverValidForUnit(self, false) )
				{
					Data = EmptyData;
					Data.TemplateName = AbilityTemplate.DataName;
					Data.Template = AbilityTemplate;
					arrData.AddItem(Data);
				}
			}
		}
	
	}
	*/

static function bool IsRetaliation(string MissionFamily){
	return MissionFamily == "Terror" || MissionFamily == "Retaliation" || MissionFamily == "ChosenRetaliation";
}

static function name GrabRandomCrackdownSitrep(){
	local int DieRoll;
	local array<name> CrackdownSitreps;

	CrackdownSitreps = class'ILB_DefaultSitreps'.static.CrackdownSitreps();
    DieRoll = Rand(CrackdownSitreps.length);
	`LOG("Returning sitrep to be used in mission: " $ CrackdownSitreps[DieRoll]);
	return CrackdownSitreps[DieRoll];
}

static function bool IsResCardActive(name ResCardName){
	return class'ILB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCardName);
}

static function bool IsMissionFamily(
GeneratedMissionData MissionStruct, name MissionFamilyId)
{
	return MissionStruct.Mission.MissionFamily == string(MissionFamilyId);
}

static function AddSitrepToMissionSourceIfResistanceCardsActive(XComGameState_MissionSite MissionState, name ResCard,
name Sitrep, name RequiredMissionSource,out GeneratedMissionData GeneratedMission)
{
	local name MissionSource;
	local string LwVariantOfMissionSourceAsString;

	MissionSource = MissionState.GetMissionSource().DataName;
	LwVariantOfMissionSourceAsString = string(RequiredMissionSource) $ "_LW"; //todo: specialty check for LWOTC


	if (GeneratedMission.SitReps.Find(Sitrep) != -1){
		`LOG("Sitrep already exists on mission, skipping: " $ Sitrep);
		// Sitrep is already there! TODO: Verify this logic works.
		return;
	}

	if (class'ILB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionSource) == string(MissionSource)
			|| LwVariantOfMissionSourceAsString == string(MissionSource))
		{
			GeneratedMission.SitReps.AddItem(Sitrep);
			`LOG("Mission family was satisfied: " $ RequiredMissionSource $ " for " $ ResCard );

			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionSource $ " for " $ ResCard $ " but was " $ MissionSource);
	}
}


static function AddSitrepToMissionFamilyIfResistanceCardsActive(name ResCard,
name Sitrep, name RequiredMissionFamily,out GeneratedMissionData GeneratedMission)
{
	local string LwVariantOfMissionFamilyAsString;
	LwVariantOfMissionFamilyAsString = string(RequiredMissionFamily) $ "_LW";

	if (GeneratedMission.SitReps.Find(Sitrep) != -1){
		`LOG("Sitrep already exists on mission, skipping: " $ Sitrep);
		// Sitrep is already there! TODO: Verify this logic works.
		return;
	}

	if (class'ILB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionFamily) == GeneratedMission.Mission.MissionFamily
			|| LwVariantOfMissionFamilyAsString == GeneratedMission.Mission.MissionFamily)
		{
			GeneratedMission.SitReps.AddItem(Sitrep);
			`LOG("Mission family was satisfied: " $ RequiredMissionFamily $ " for " $ ResCard );

			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionFamily $ " for " $ ResCard $ " but was " $ GeneratedMission.Mission.MissionFamily);
	}
}

static function AddRewardsToMissionFamilyIfResistanceCardActive(XComGameState NewGameState, XComGameState_MissionSite MissionState, GeneratedMissionData GeneratedMission, name RewardId, name ResCard, name RequiredMissionFamily, int Quantity)
{
	local string LwVariantOfMissionFamilyAsString;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_HeadquartersResistance ResHQ;
	local X2StrategyElementTemplateManager TemplateManager;

	LwVariantOfMissionFamilyAsString = string(RequiredMissionFamily) $ "_LW";

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	
	if (class'ILB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionFamily) == GeneratedMission.Mission.MissionFamily
			|| LwVariantOfMissionFamilyAsString == GeneratedMission.Mission.MissionFamily)
		{
			`LOG("Resistance card IS active for current mission: " $ ResCard $ "  | "  $ RequiredMissionFamily);
			
			RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardId));

			if (RewardTemplate != none)
			{

				RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState)); //ignoring regionref
				RewardState.Quantity = Quantity;
				MissionState.Rewards.AddItem(RewardState.GetReference());
				`Log("Added reward template due to resistance card to mission!  " $ RewardId);
				
			}
			else
			{
				`Log("Can't find reward template!  " $ RewardId);
			}

			
			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionFamily $ " for " $ ResCard $ " but was " $ GeneratedMission.Mission.MissionFamily);
	}
}

static function AddRewardsToMissionSourceIfResistanceCardActive(XComGameState NewGameState, XComGameState_MissionSite MissionState, GeneratedMissionData GeneratedMission, name ResCard, name RequiredMissionSource, XComGameState_Reward RewardState)
{
	local string LwVariantOfMissionSourceAsString;
	local name MissionSource;
	MissionSource = MissionState.GetMissionSource().DataName;
	LwVariantOfMissionSourceAsString = string(RequiredMissionSource) $ "_LW";

	
	if (class'ILB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionSource) == string(MissionSource)
			|| LwVariantOfMissionSourceAsString == string(MissionSource))
		{
			`LOG("Resistance card IS active for current mission: " $ ResCard $ "  | "  $ RequiredMissionSource);
			
			MissionState.Rewards.AddItem(RewardState.GetReference());
			`Log("Added reward template due to resistance card to mission!  " $ RewardState.GetMyTemplateName());
				
			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionSource $ " for " $ ResCard $ " but was " $ MissionSource);
	}



}


static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay){
	
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateMan;
	local AbilitySetupData Data, EmptyData;
	local X2CharacterTemplate CharTemplate;
	local XComGameState_Item CurrentBladedWeapon;
	local XComGameState_Item CurrentPsiAmp;
	if (`XENGINE.IsMultiplayerGame()) { return; }

	CharTemplate = UnitState.GetMyTemplate();
	if (CharTemplate == none)
		return;

	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	CurrentBladedWeapon = class'ILB_Utils'.static.GetEquippedBlade(UnitState);
	CurrentPsiAmp = class'ILB_Utils'.static.GetEquippedWeaponOfCategory(UnitState, 'psiamp');
	if (class'ILB_Utils'.static.IsResistanceOrderActive('ResCard_BladesGrantShellbust'))
	{
		if (CurrentBladedWeapon != none){
			AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('ShiningCentaurShieldrenderTechnique');
			Data.Template=  AbilityTemplate;
			Data.TemplateName=AbilityTemplate.DataName;
			Data.SourceWeaponRef = CurrentBladedWeapon.GetReference();
			SetupData.AddItem(Data);
			`Log(" >>> Binding ability '" $ Data.TemplateName $ "' to secondary weapon for unit " $ UnitState.GetMyTemplateName());
		}
	}

	if (class'ILB_Utils'.static.IsResistanceOrderActive('ResCard_BasiliskDoctrine'))
	{
		if (class'ILB_Utils'.static.DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'wristblade')){

			`Log(" >>> Binding ability '" $ Data.TemplateName $ "' to secondary weapon for unit " $ UnitState.GetMyTemplateName());
			if (CurrentBladedWeapon != none){
				AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('TakeUnder');
				Data.Template=  AbilityTemplate;
				Data.TemplateName=AbilityTemplate.DataName;
				Data.SourceWeaponRef = CurrentBladedWeapon.GetReference();
				SetupData.AddItem(Data);	
			}

			Data = EmptyData;
			AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('Shredder');
			Data.Template=  AbilityTemplate;
			Data.TemplateName=AbilityTemplate.DataName;
			Data.SourceWeaponRef = UnitState.GetPrimaryWeapon().GetReference();
			
			SetupData.AddItem(Data);
			`Log(" >>> Binding ability '" $ Data.TemplateName $ "' to secondary weapon for unit " $ UnitState.GetMyTemplateName());
		}
	}
	if (class'ILB_Utils'.static.IsResistanceOrderActive('ResCard_InfohazardWeaponization'))
	{
		if (class'ILB_Utils'.static.DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'psiamp')){

			`Log(" >>> Binding ability '" $ Data.TemplateName $ "' to psi amp weapon for unit " $ UnitState.GetMyTemplateName());
			if (CurrentPsiAmp != none){
				AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate('Insanity');
				Data.Template=  AbilityTemplate;
				Data.TemplateName=AbilityTemplate.DataName;
				Data.SourceWeaponRef = CurrentPsiAmp.GetReference();
				SetupData.AddItem(Data);	
			}
		}
	}
}

