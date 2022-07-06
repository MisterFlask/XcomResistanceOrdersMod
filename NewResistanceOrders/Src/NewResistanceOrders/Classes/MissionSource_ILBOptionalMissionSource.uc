class MissionSource_ILBOptionalMissionSource extends X2StrategyElement_DefaultMissionSources;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> MissionSources;
	MissionSources.AddItem(CreateIlbOptionalTemplate());
	return MissionSources;
}

static function X2DataTemplate CreateIlbOptionalTemplate()
{
	local X2MissionSourceTemplate Template;
	local RewardDeckEntry DeckEntry;
	`LOG("Creating the MissionSource_ILBOptional Mission Source Template");

	`CREATE_X2TEMPLATE(class'X2MissionSourceTemplate', Template, 'MissionSource_ILBOptional');
	Template.bIncreasesForceLevel = false;
	Template.bShowRewardOnPin = true;

	Template.OnSuccessFn = ILBOnSuccess;
	Template.OnFailureFn = ILBOnFailure;
	Template.OnExpireFn = ILBOnExpire;

	Template.DifficultyValue = 1;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.GorillaOps";
	Template.MissionImage = "img:///UILibrary_StrategyImages.X2StrategyMap.Alert_Guerrilla_Ops";

	Template.GetMissionDifficultyFn = GetMissionDifficultyFromMonth;
	Template.SpawnMissionsFn = SpawnGuerillaOpsMissions;
	Template.MissionPopupFn = GuerillaOpsPopup;

	Template.WasMissionSuccessfulFn = StrategyObjectivePlusSweepCompleted;


	//Template.RewardDeck.AddItem('Reward_None'); /// we do these manually
	// todo
	return Template;
}

function ILBOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local array<int> ExcludeIndices;

	ExcludeIndices = GetILBExcludeRewards(MissionState);
	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	GiveRewards(NewGameState, MissionState, ExcludeIndices);
	SpawnPointOfInterest(NewGameState, MissionState);
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsCompleted');
}

function ILBOnFailure(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{	
	MissionState.RemoveEntity(NewGameState);
	class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsFailed');
}
function ILBOnExpire(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{

	class'XComGameState_HeadquartersResistance'.static.DeactivatePOI(NewGameState, MissionState.POIToSpawn);
	class'XComGameState_HeadquartersResistance'.static.RecordResistanceActivity(NewGameState, 'ResAct_CouncilMissionsFailed');
}

function array<int> GetILBExcludeRewards(XComGameState_MissionSite MissionState)
{
	local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local array<int> ExcludeIndices;
	local int idx;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	`assert(BattleData.m_iMissionID == MissionState.ObjectID);

	// Specifically dealing with neutralize-vip missions.
	// This assumes that the second item is ALWAYS the one having to do with the VIP.
	for(idx = 0; idx < BattleData.MapData.ActiveMission.MissionObjectives.Length; idx++)
	{
		if(BattleData.MapData.ActiveMission.MissionObjectives[idx].ObjectiveName == 'Capture' &&
		   !BattleData.MapData.ActiveMission.MissionObjectives[idx].bCompleted)
		{
			ExcludeIndices.AddItem(1);
		}
	}

	return ExcludeIndices;
}