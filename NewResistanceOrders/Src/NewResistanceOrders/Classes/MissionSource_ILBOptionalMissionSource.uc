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

	Template.WasMissionSuccessfulFn = OneStrategyObjectiveCompleted;


	//Template.RewardDeck.AddItem('Reward_None'); /// we do these manually
	// todo
	return Template;
}

function ILBOnSuccess(XComGameState NewGameState, XComGameState_MissionSite MissionState)
{
	local array<int> ExcludeIndices;

	ExcludeIndices = GetILBExcludeRewards(MissionState);
	MissionState.bUsePartialSuccessText = (ExcludeIndices.Length > 0);
	GiveRewards_ILB(NewGameState, MissionState, ExcludeIndices);
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
	local array<int> ExcludeIndices;

	return ExcludeIndices;
}

static function bool DidWeCaptureAVip(XComGameState_MissionSite MissionState){
local XComGameStateHistory History;
	local XComGameState_BattleData BattleData;
	local int idx;

	History = `XCOMHISTORY;
	BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	`assert(BattleData.m_iMissionID == MissionState.ObjectID);

	for(idx = 0; idx < BattleData.MapData.ActiveMission.MissionObjectives.Length; idx++)
	{
		if(BattleData.MapData.ActiveMission.MissionObjectives[idx].ObjectiveName == 'Capture' &&
		   BattleData.MapData.ActiveMission.MissionObjectives[idx].bCompleted)
		{
			`LOG("Successfully captured VIP");
			return true;
		}
	}

	`LOG("Did NOT capture a VIP on this mission");
	return false;
}

static function XComGameState_Reward BuildMissionItemReward(XComGameState NewGameState, Name TemplateName)
{
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Reward RewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local X2ItemTemplateManager ItemMgr;
	local X2ItemTemplate ItemTemplate;
	local XComGameState_Item ItemState;

	// create the item reward
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Item'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(RewardState); // Is this correct?

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);
	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	NewGameState.AddStateObject(ItemState); // Is this correct?
	RewardState.RewardObjectReference = ItemState.GetReference();

	return RewardState;
}

static function GiveRewards_ILB(XComGameState NewGameState, XComGameState_MissionSite MissionState, optional array<int> ExcludeIndices)
{
	local XComGameStateHistory History;
	local XComGameState_Reward RewardState;
	local int idx;

	History = `XCOMHISTORY;

	// First Check if we need to exclude some rewards
	for(idx = MissionState.Rewards.Length - 1; idx >= 0; idx--)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[idx].ObjectID));
		if(RewardState != none)
		{
			if(ExcludeIndices.Find(idx) != INDEX_NONE)
			{
				RewardState.CleanUpReward(NewGameState);
				MissionState.Rewards.Remove(idx, 1);
			}
		}
	}
	
	if (DidWeCaptureAVIP(MissionState))
	{
		MissionState.Rewards.AddItem(BuildMissionItemReward(NewGameState, 'AdventDatapad').GetReference());
	}

	class'XComGameState_HeadquartersResistance'.static.SetRecapRewardString(NewGameState, MissionState.GetRewardAmountStringArray());

	// @mnauta: set VIP rewards string is deprecated, leaving blank
	class'XComGameState_HeadquartersResistance'.static.SetVIPRewardString(NewGameState, "" /*REWARDS!*/);

	for(idx = 0; idx < MissionState.Rewards.Length; idx++)
	{
		RewardState = XComGameState_Reward(History.GetGameStateForObjectID(MissionState.Rewards[idx].ObjectID));

		// Give rewards
		if(RewardState != none)
		{
			RewardState.GiveReward(NewGameState);
		}
	}

	MissionState.Rewards.Length = 0;
}
