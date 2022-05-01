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

class X2DownloadableContentInfo_NewResistanceOrders extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
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
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'ShowOfForce', 'Recover', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BureaucraticInfighting', 'InformationWarSitRep', 'Recover', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_BigDamnHeroes', 'ResistanceContacts', 'Neutralize', GeneratedMission);
	
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Extract', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Rescue', GeneratedMission);
		AddSitrepToMissionFamilyIfResistanceCardsActive('ResCard_EyeForValue', 'LootChests', 'Neutralize', GeneratedMission);
	
		// MissionState = XComGameState_MissionSite(SourceObject);
		
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


static function IsMissionFamily(
GeneratedMissionData MissionStruct, name MissionFamilyId){
	return MissionStruct.Mission.MissionFamily == MissionFamilyId;
}


static function AddSitrepToMissionFamilyIfResistanceCardsActive(name ResCard,
name Sitrep, name RequiredMissionFamily,out GeneratedMissionData GeneratedMission)
{
	if (GeneratedMission.SitReps.Find(Sitrep) != -1){
		`LOG("Sitrep already exists on mission, skipping: " $ Sitrep);
		// Sitrep is already there! TODO: Verify this logic works.
		return;
	}

	if (IRB_NewResistanceOrders_EventListeners.static.IsResistanceOrderActive(ResCard))
	{
		if (RequiredMissionFamily == GeneratedMission.Mission.MissionFamily)
		{
			GeneratedMission.SitReps.AddItem(Sitrep);
			return;
		}
		`LOG("Mission family needed to have been " $ RequiredMissionFamily $ " for " $ ResCard $ " but was " $ GeneratedMission.Mission.MissionFamily);
	}
}
/*
static function AddRewardsToMissionState(XComGameState_MissionSite MissionState, name RewardId)
{
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_HeadquartersResistance ResHQ;
	local X2StrategyElementTemplateManager TemplateManager;
	local XComGameState AddToGameState;

	AddToGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("TempGameState");
	TemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();

	RewardTemplate = X2RewardTemplate(TemplateManager.FindStrategyElementTemplate(RewardId));

	if (RewardTemplate != none)
	{		
		RewardState = RewardTemplate.CreateInstanceFromTemplate(AddToGameState);
		RewardState.GenerateReward(NewGameState, ResHQ.GetMissionResourceRewardScalar(RewardState)); //ignoring regionref
		MissionState.Rewards.AddItem(RewardState.GetReference());
	}
	else
	{
		`Log("Can't find reward template!  " $ RewardId)
	}

	`XCOMGAME.GameRuleset.SubmitGameState(AddToGameState);
	//History.CleanupPendingGameState(AddToGameState);


}
*/