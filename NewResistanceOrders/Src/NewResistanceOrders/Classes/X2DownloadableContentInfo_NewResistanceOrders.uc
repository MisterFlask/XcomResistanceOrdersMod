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

var config array<name> PISTOL_SKILLS;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
}

exec function SetCardToActiveInSlot(string cardname, int slot){

	local XComGameStateHistory History;
	local X2TacticalGameRuleset Rules;
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState NewGameState;
	local XComGameState_StrategyCard StrategyCard; 
	Rules = `TACTICALRULES;
	History = `XCOMHISTORY;
	
	StrategyCard = GetCardByName(cardname);
	
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
	local XComGameState NewGameState;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_StrategyCard CardState;
	local X2StrategyCardTemplate CurrentTemplate;
	local XComGameState_StrategyCard CurrentCard;
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

static event OnPostTemplatesCreated(){
	`LOG("ILB:  Updating Abilities");
	UpdateAbilities();
}

static function UpdateAbilities()
{

	local X2AbilityTemplateManager				AbilityManager;
	local X2AbilityTemplate						AbilityTemplate, PistolAbility;
	local X2Condition_AbilityProperty			AbilityCondition;
	local name									AbilityName;
	local X2Effect_PersistentStatChange			PoisonedEffect, PoisonEffect;	
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
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_HeadquartersResistance ResHQ;
	local X2StrategyElementTemplateManager TemplateManager;

	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();


	If (`HQGAME  != none && `HQPC != None && `HQPRES != none) // we're in strategy
	{
		//todo: random chance
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'ShowOfForce', 'Recover', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'LootChests', 'Recover', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Neutralize', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Neutralize', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'Terror', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'Retaliation', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BoobyTraps', 'HighExplosives', 'ProtectDevice', GeneratedMission);//todo: double check sitrep ID

		MissionState = XComGameState_MissionSite(SourceObject);
		
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_Intel', 'ResCard_SupplyRaidsForHacks', 'Hack', 30); 
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_SupplyRaid', 'ResCard_SupplyRaidsForHacks', 'Hack', 1); 
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_DoomReduction', 'ResCard_IncitePowerVacuum', 'Neutralize', 336); //336=2 weeks
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_AvengerPower', 'ResCard_PowerCellRepurposing', 'SecureUFO', 2); // Reward_HeavyWeapon/Reward_Grenade for hitting landed UFOs [Skirm] [include SupplyLineRaid]
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_HeavyWeapon', 'ResCard_PowerCellRepurposing', 'SecureUFO', 1); // Reward_HeavyWeapon/Reward_Grenade for hitting landed UFOs [Skirm] [include SupplyLineRaid]
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_Alloys', 'ResCard_EducatedVandalism', 'DestroyObject', 20); // Reward_Alloys : Educated Vandalism (skirms) [include SabotageTransmitter]
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_DoomReduction', 'ResCard_IncitePowerVacuum', 'NeutralizeFieldCommander', 336); //Reward_AvengerResComms [reaper]
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_Alloys', 'ResCard_EducatedVandalism', 'SabotageTransmitter', 20);
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_AvengerResComms', 'ResCard_YouOweMe', 'Extract', 2); // Reward_ReducedContact
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_Soldier', 'ResCard_MassivePopularity', 'Terror', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.
		AddRewardsToMissionFamilyIfResistanceCardActive(MissionState, GeneratedMission, 'Reward_Soldier', 'ResCard_MassivePopularity', 'ChosenRetaliation', 1); // Retaliation/terror missions grant an additional soldier when successfully completed.


		/*
		//Ugh.
		if (IRB_NewResistanceOrders_EventListeners.static.IsResistanceOrderActive('ResCard_TheOnesWhoKnock'))
		{
			`CI_Trace("ResCard_TheOnesWhoKnock is active; performing reward modification?");

			if (IsMissionFamily(GeneratedMission, 'NeutralizeFieldCommander')
					|| IsMissionFamily(GeneratedMission, 'Neutralize')){
				// rewards reference: https://github.com/Lucubration/XCOM2/blob/a24366aafaa50421c8cb2648b563e452c6717902/TestModWotc/TestModWotc/Src/XComGame/Classes/X2StrategyElement_DefaultRewards.uc
				`CI_Trace("ResCard_TheOnesWhoKnock is active AND NeutralizeFieldCommander or Neutralize is mission type; performing reward modification?");

				AddRewardsToMissionState(MissionState, 'Reward_Supply');
			}
			else
			{
				`CI_Trace("ResCard_TheOnesWhoKnock is active BUT  NeutralizeFieldCommander or Neutralize is NOT mission type; mission type is "$ GeneratedMissionData.Mission.MissionFamily);
			}
		}*/
	}

}


static function bool IsMissionFamily(
GeneratedMissionData MissionStruct, name MissionFamilyId)
{
	return MissionStruct.Mission.MissionFamily == string(MissionFamilyId);
}


static function AddSitrepToMissionFamilyIfResistanceCardsActive(name ResCard,
name Sitrep, name RequiredMissionFamily,out GeneratedMissionData GeneratedMission)
{
	if (GeneratedMission.SitReps.Find(Sitrep) != -1){
		`LOG("Sitrep already exists on mission, skipping: " $ Sitrep);
		// Sitrep is already there! TODO: Verify this logic works.
		return;
	}

	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionFamily) == GeneratedMission.Mission.MissionFamily)
		{
			GeneratedMission.SitReps.AddItem(Sitrep);
			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionFamily $ " for " $ ResCard $ " but was " $ GeneratedMission.Mission.MissionFamily);
	}
}

//AlienDataPad 
static function AddRewardsToMissionFamilyIfResistanceCardActive(XComGameState_MissionSite MissionState, GeneratedMissionData GeneratedMission, name RewardId, name ResCard, name RequiredMissionFamily, int Quantity)
{
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_HeadquartersResistance ResHQ;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("TempGameState");
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	
	if (class'IRB_NewResistanceOrders_EventListeners'.static.IsResistanceOrderActive(ResCard))
	{
		if (string(RequiredMissionFamily) == GeneratedMission.Mission.MissionFamily)
		{
			`LOG("Resistance card IS active for current mission: " $ ResCard $ "  | "  $ RequiredMissionFamily);
			
			RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardId));

			if (RewardTemplate != none)
			{		
				RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
				RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState)); //ignoring regionref
				RewardState.Quantity = Quantity;
				MissionState.Rewards.AddItem(RewardState.GetReference());
			}
			else
			{
				`Log("Can't find reward template!  " $ RewardId);
			}

			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
			
			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionFamily $ " for " $ ResCard $ " but was " $ GeneratedMission.Mission.MissionFamily);
	}

	`XCOMHISTORY.CleanupPendingGameState(NewGameState);

}
