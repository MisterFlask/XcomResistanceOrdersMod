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

struct ResistanceCardConfigValues{
	var name ResCardName;
	var string StringValue0;
	var string StringValue1;
};

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

exec function SetCardToActiveInSlot(string cardname, int slot){

	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState NewGameState;
	local XComGameState_StrategyCard StrategyCard; 	StrategyCard = GetCardByName(cardname);
	
	if (StrategyCard == none){
		`LOG("Couldn't find strategy card.  Bummer.");
		return;
	}
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Place Card in Slot");
	ResHQ = GetResistanceHQ();
	ResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID));
	ResHQ.PlaceCardInSlot(StrategyCard.GetReference(), slot);
	
	//todo
	//Rules.ApplyResistancePoliciesToStartState(NewGameState);
}


function XComGameState_HeadquartersResistance GetResistanceHQ()
{
	return XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
}

function XComGameState_StrategyCard GetCardByName(string nam){
	local XComGameStateHistory History;
	local XComGameState_StrategyCard CurrentCard;
	local X2StrategyCardTemplate CurrentTemplate;
 
	foreach History.IterateByClassType(class'XComGameState_StrategyCard', CurrentCard)
	{
		CurrentTemplate = CurrentCard.GetMyTemplate();
		if (string(CurrentTemplate.DataName) == nam){
			return CurrentCard;
		}
	}
	return none;
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
	local X2StrategyElementTemplateManager TemplateManager;
	local X2RewardTemplate RewardTemplate;
	local name TemplateName;
	local array<X2DataTemplate> AllSitrepEffectTemplates;
	local array<X2DataTemplate> AllSitRepTemplates;

	AllSitRepTemplates = class'ILB_DefaultSitrepsParent'.static.CreateTemplates();
	AllSitrepEffectTemplates = class'ILB_DefaultSitreps'.static.CreateTemplates();

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
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
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_StrategyCard CardState;
	local X2StrategyCardTemplate CurrentTemplate;
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


static function array<ResistanceCardConfigValues> GetResistanceCardConfigs(){
	local array<ResistanceCardConfigValues> ResistanceCardConfigs;

	//Costs 4 avenger power; only functions when not at power deficit. All soldiers' electric abilities deal 2 extra damage. 
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RemoteSuperchargers', class'IRB_AdditionalResistanceOrders_ResCards'.default.SUPERCHARGER_POWER_DRAIN, class'IRB_AdditionalResistanceOrders_Abilities'.default.AVENGER_SUPERCHARGER_ELECTRIC_DAMAGE_BUFF));// 
	//Gain +20% research speed.  Chryssalids and Faceless are both faster and harder to hit
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_XenobiologicalFieldResearch', class'ILB_StrategicResCards'.default.XENO_FIELD_RESEARCH_RESEARCH_BONUS, -1));
	//Lose 15% research speed.  Gain +3 resistance contacts
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_LabToCommsRepurposing', class'ILB_StrategicResCards'.default.LABS_TO_COMMS_RESEARCH_PENALTY, class'ILB_StrategicResCards'.default.LABS_TO_COMMS_COMMS_BONUS));
	//Gain +4 avenger power.  Guerilla Ops and Council missions have a +15% chance of an ADVENT crackdown sitrep
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_LeachPsionicLeylines', class'ILB_StrategicResCards'.default.LEACH_PSIONIC_LEYLINES_POWER_BONUS, 15));
	// ResCard_RescueUpperCrustContacts
	//Grants a monthly covert action that spawns a Swarm Defense Recover VIP mission.  This mission rewards 75-125 supply on completion instead of its typical reward.
	
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RescueUpperCrustContacts', 75, 125));
	
	// ResCard_StealSparkCore
	//"Grants a monthly covert action that spawns a Recover Item mission with an increased force level of between 0 and 1.  This mission rewards a Spark instead of its typical reward on completion."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_StealSparkCore', 0, 1));
	
	// ResCard_BrazenRecruitment
	/// "There is a +15% chance of an ADVENT crackdown..."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BrazenRecruitment',15,-1));

	//ResCard_BrazenCollection
	//Gain +25% extra supplies from drops.   There is a +15% chance of an ADVENT crackdown sitrep on all guerilla ops and council missions.
	
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BrazenCollection',class'ILB_StrategicResCards'.default.BRAZEN_COLLECTION_BONUS, 15));

	// ResCard_GrndlPowerDeal
	//Gain +5 Avenger power.   Also, gain -25% supplies from supply drops."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_GrndlPowerDeal',class'ILB_StrategicResCards'.default.GRNDL_POWER_DEAL_POWER_BONUS, class'ILB_StrategicResCards'.default.GRNDL_POWER_DEAL_SUPPLY_PENALTY));

	// 
	//Black Market goods are at a 25% discount.  There is a +15% chance of an ADVENT crackdown on all guerilla ops and council missions
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_NotoriousSmugglers',class'ILB_StrategicResCards'.default.NOTORIOUS_SMUGGLERS_BLACK_MARKET_DISCOUNT, 15));

	/*
[ResCard_RadioFreeLily X2StrategyCardTemplate]
DisplayName="Radio Free Lily"
SummaryText="You gain +2 resistance contacts.  Retaliations are at +1 force level."

	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RadioFreeLily',class'ILB_StrategicResCards'.default.RADIO_FREE_LILY_COMMS_BONUS, 1));

	/*
[ResCard_CouncilBounties X2StrategyCardTemplate]
DisplayName="Council Bounties"
SummaryText="Grants a monthly covert action that spawns a Neutralize Field Commander mission.  The field commander is tougher on this mission.  This mission rewards 75-125 supply on completion."
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_CouncilBounties', 75, 125));

	/*
	ResCard_PowerCellRepurposing
	Successfully securing UFOs grants the Avenger 2 additional power PERMANENTLY, as well as a random heavy weapon.  Destroy Device missions grant an additional 15 Elereum."
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_PowerCellRepurposing', 2, 15)); //todo

	/*
	ResCard_SupplyRaidsForHacks
	"Successful Hack missions generate a Supply Raid and grant 30 additional intel"
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_SupplyRaidsForHacks', 30, -1)); //todo

	/*
	ResCard_EducatedVandalism
	Destroy Object and Sabotage Transmitter missions grant additional 15 alien alloys on completion
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_EducatedVandalism', 15, -1)); //todo

	/*
	ResCard_IncitePowerVacuum
	Neutralize VIP and Neutralize Field Commander missions both reduce the Avatar counter by 14 days apiece.
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_IncitePowerVacuum', 14, -1)); //todo

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_YouOweMe', 40, -1)); //todo

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_HexHunterForMindShields', class'IRB_AdditionalResistanceOrders_Abilities'.default.ILB_WITCH_HUNTER_PASSIVE_DMG, -1));

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_OberonExploit', class'IRB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_Promethium', class'IRB_AdditionalResistanceOrders_Abilities'.default.ILB_PROMETHIUM_FIRE_DMG_BONUS, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_GrantRookiesPermaHp', class'IRB_AdditionalResistanceOrders_Abilities'.default.ROOKIE_COMBAT_HP_BONUS, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BureaucraticInfighting', 30, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_MindTaker', class'IRB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF_MINDGORGER, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BetterMelee', class'IRB_AdditionalResistanceOrders_Abilities'.default.ILB_MELEE_DMG_BUFF, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_SendInTheNextWave', 15, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_DawnMachines', class'IRB_AdditionalResistanceOrders_Abilities'.default.ILB_DAWN_MACHINES_SHIELDS_BUFF, class'IRB_AdditionalResistanceOrders_Abilities'.default.ILB_DAWN_MACHINES_MOBILITY_BUFF));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_MabExploit', class'IRB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF_TUNDRA, -1));

	/*
[ X2StrategyCardTemplate]
SummaryText="Recover Resistance Operative missions and Extract VIP missions grant an extra 40 supply on successful completion."

[ResCard_MassivePopularity X2StrategyCardTemplate]
SummaryText="Gain a promotable Rookie on successful completion of a Retaliation mission."

[ResCard_TunnelRats X2StrategyCardTemplate]
SummaryText="Missions in the Sewers or Subways allow each soldier with a shotgun or assault rifle to reenter concealment once per mission, as per the Conceal ability."

[ResCard_ForgedPapers X2StrategyCardTemplate]
SummaryText="Missions in Small Towns allow each soldier to reenter concealment once per mission, as per the Conceal ability.  If you have at least 3 Skirmisher cards active, this also applies to City Centers."

[ResCard_FlashpointForGrenadiers X2StrategyCardTemplate]
SummaryText="Grenade launchers make flashbangs deal 2 Fire damage in addition to their regular effects."

[ResCard_HexHunterForMindShields X2StrategyCardTemplate]
SummaryText="Your soldiers with a Mind Shield gain the Witch Hunter perk (additional 2 passive damage vs. psionic enemies.)"

[ResCard_BladesGrantShellbust X2StrategyCardTemplate]
SummaryText="Your sword or knife-carrying soldiers gain Shellbust Stab (massive armor shred melee attack)"

// [ResCard_PracticalOccultism X2StrategyCardTemplate]
// SummaryText="Your Reapers can cloak themselves for an HP cost, and can also teleport to anywhere within squadsight, also with an HP cost."

// [ResCard_BetterMelee X2StrategyCardTemplate]
// SummaryText="Your soldiers all deal +1 melee damage.  Additionally, they have an increased likelihood to bleed out rather than die outright."

// [ResCard_Promethium X2StrategyCardTemplate]
// SummaryText="Flamethrower-based abilities deal 2 more damage.  Additionally, flamethrower-based abilities gain another charge.  (This also applies to fire-based chemthrower abilities.)"

// [ResCard_GrantRookiesPermaHp X2StrategyCardTemplate]
// SummaryText="Whenever you send a Rookie on a combat mission, they get a PERMANENT +2 max HP (once per rookie)."


// 	return ResistanceCardConfigs;
// }

// static function ResCardConf(name ResCardId, int intValue1, int intValue2 = -1)
// {
// 	local ResistanceCardConfigValues ResistanceCardConfigValues;

// 	ResistanceCardConfigValues.StringValue1 = string(intValue1);
// 	ResistanceCardConfigValues.StringValue2 = string(intValue2);

[ResCard_ResUnitIfRetaliation X2StrategyCardTemplate]
SummaryText="Gain a bonus Resistance soldier at the beginning of each Retaliation mission."

[ResCard_AdventUnitIfLessThanFullSquad X2StrategyCardTemplate]
SummaryText="Gain a bonus ADVENT soldier at the beginning of each mission where you're fielding fewer than six soldiers."

[ResCard_MabExploit X2StrategyCardTemplate]
SummaryText="In Tundra climates, all MECs and Turrets have -70% hack defense."

[ResCard_MachineBuffsIfAridClimate X2StrategyCardTemplate]
SummaryText="In non-Arid climates, your mechanical units gain +4 shielding.  In Arid climates, your mechanical units gain +3 mobility and +8 shielding.  Only applies to mechanical units that cannot take cover.  You can purchase MEC wrecks in the Black Market."

[ResCard_SendInTheNextWave X2StrategyCardTemplate]
SummaryText="Your recruits cost 15.  Rookies and Squaddies gain the Beatdown perk (deal a small amount of melee damage, but stun for a turn)"

[ResCard_OberonExploit X2StrategyCardTemplate]
SummaryText="ADVENT turrets lose -70% hack defense."

[ResCard_PracticalOccultism X2StrategyCardTemplate]
SummaryText="Your Reapers can cloak themselves for an HP cost, and can also teleport to anywhere within squadsight, also with an HP cost."

[ResCard_BetterMelee X2StrategyCardTemplate]
SummaryText="Your soldiers all deal +1 melee damage.  Additionally, they have an increased likelihood to bleed out rather than die outright."

[ResCard_Promethium X2StrategyCardTemplate]
SummaryText="Flamethrower-based abilities deal 2 more damage.  Additionally, flamethrower-based abilities gain another charge.  (This also applies to fire-based chemthrower abilities.)"

[ResCard_GrantRookiesPermaHp X2StrategyCardTemplate]
SummaryText="Whenever you send a Rookie on a combat mission, they get a PERMANENT +2 max HP (once per rookie)."

	*/

	return ResistanceCardConfigs;
}

static function ResistanceCardConfigValues ResCardConf(name ResCardId, int intValue1, int intValue2 = -1){
	local ResistanceCardConfigValues Values;
	Values.ResCardName = ResCardId;
	Values.StringValue0 = string(intValue1);
	Values.StringValue1 = string(intValue2);
	return Values;
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

	static function ResistanceCardConfigValues GetResistanceCardConfigsForResCard(name ResCardName, array<ResistanceCardConfigValues> AllPossibleCards){
		local ResistanceCardConfigValues Current;

		foreach AllPossibleCards(Current){
			if (ResCardName == Current.ResCardName){
				return Current;
			}
		}

		Current.ResCardName = '';
		return Current;

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
	Configs = GetResistanceCardConfigs();

	CardState = GetCardState(InRef);

	if(CardState == none)
	{
		return "Error in GetSummaryText function";
	}

	CardTemplate = CardState.GetMyTemplate();
	CurrentConfig=GetResistanceCardConfigsForResCard(CardTemplate.DataName, Configs);
	if (CurrentConfig.ResCardName != ''){
		`Log("Observed config for res card: " $ CurrentConfig.ResCardName $ " : " $ CurrentConfig.StringValue0 $ " :  " $ CurrentConfig.StringValue1);
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		ParamTag.StrValue0 = CurrentConfig.StringValue0;
		ParamTag.StrValue1 = CurrentConfig.StringValue1;
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
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState NewGameState;
	local name CurrentSitrepName;
	local array<name> SitrepList;
	local XComGameStateHistory CachedHistory;

	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	
	//NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("TempGameState");
	CachedHistory = `XCOMHISTORY;
	NewGameState = CachedHistory.GetGameStateFromHistory();
	If (`HQGAME  != none && `HQPC != None && `HQPRES != none) // we're in strategy
	{
		//todo: random chance
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'ShowOfForce', 'Recover', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'LootChests', 'Recover', GeneratedMission);
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Intel', 'ResCard_BureaucraticInfighting', 'Recover', 30); //TODO: Remove this and add an ADVENT soldier to Bureaucratic Infighting

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
		// AddRewardsToMissionSourceIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ResCard_AggressiveOpportunism', 'MissionSource_GuerillaOp', class'ILB_LootTablePresetReward'.static.BuildMissionItemReward_AggressiveOpportunism(NewGameState)); //TODO: Remove this and add an ADVENT soldier to Bureaucratic Infighting


		MissionState = XComGameState_MissionSite(SourceObject);

		if (MissionState == none){
			MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(GeneratedMission.MissionID));
		}

		if (MissionState == none){
			`LOG("ERROR: Could not find mission state for mission id " $ GeneratedMission.MissionID);
		}
			

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Supplies', 'ResCard_YouOweMe', 'Extract', 40); 
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Supplies', 'ResCard_YouOweMe', 'SwarmDefense', 40);

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_TechRush', 'ResCard_TechRushForHacks', 'Hack', 1); 

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Intel', 'ResCard_SupplyRaidsForHacks', 'Hack', 30); 
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_SupplyRaid', 'ResCard_SupplyRaidsForHacks', 'Hack', 1); 
		
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_DoomReduction', 'ResCard_IncitePowerVacuum', 'Neutralize', 336); //336 hours =2 weeks
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_DoomReduction', 'ResCard_IncitePowerVacuum', 'NeutralizeFieldCommander', 336); //Reward_AvengerResComms [reaper]

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Elereum', 'ResCard_PowerCellRepurposing', 'DestroyDevice', 15); 
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_AvengerPower', 'ResCard_PowerCellRepurposing', 'SecureUFO', 2); // Reward_HeavyWeapon/Reward_Grenade for hitting landed UFOs [Skirm] [include SupplyLineRaid]
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_HeavyWeapon', 'ResCard_PowerCellRepurposing', 'SecureUFO', 1); // Reward_HeavyWeapon/Reward_Grenade for hitting landed UFOs [Skirm] [include SupplyLineRaid]

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Alloys', 'ResCard_EducatedVandalism', 'DestroyObject', 15); // Reward_Alloys : Educated Vandalism (skirms) [include SabotageTransmitter]
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Alloys', 'ResCard_EducatedVandalism', 'SabotageTransmitter', 15);

		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ILB_Reward_Squaddie', 'ResCard_MassivePopularity', 'Terror', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'ILB_Reward_Squaddie', 'ResCard_MassivePopularity', 'ChosenRetaliation', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Ammo', 'ResCard_StolenShippingSchedules', 'SupplyLineRaid', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		AddRewardsToMissionFamilyIfResistanceCardActive(NewGameState, MissionState, GeneratedMission, 'Reward_Grenade', 'ResCard_StolenShippingSchedules', 'SupplyLineRaid', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.

		AddCrackdownSitrepsBasedOnResistanceCardsActive(MissionState, GeneratedMission);
		
		`LOG("enumerating sitreps selected for mission");
		SitrepList = GeneratedMission.SitReps;
		foreach SitrepList(CurrentSitrepName)
		{
			`LOG("Sitrep selected for mission: " $ GeneratedMission.BattleOpName $ " : " $ CurrentSitrepName);
		}

	}

	//`GAMERULES.SubmitGameState(NewGameState);
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

	if (MissionSource == 'MissionSource_GuerillaOp' 
		|| MissionSource == 'MissionSource_Council'
		|| MissionSource == 'MissionSource_ActivityCI' // generic covert infiltration mission source
		|| MissionSource == 'MissionSource_LWSGenericMissionSource') // generic LWOTC mission source
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
	return class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCardName);
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

	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
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

	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
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
	
	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
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

	
	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
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
	if (`XENGINE.IsMultiplayerGame()) { return; }

	CharTemplate = UnitState.GetMyTemplate();
	if (CharTemplate == none)
		return;

	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	CurrentBladedWeapon = class'ILB_Utils'.static.GetEquippedBlade(UnitState);
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
}

