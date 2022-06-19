// This is an Unreal Script
class ILB_DefaultMissionRewards extends X2StrategyElement_DefaultRewards 
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateSparkRewardTemplate());
	Templates.AddItem(CreateSparkMissionRewardTemplate());

	return Templates;
}

static function X2DataTemplate CreateSparkMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_SparkMission');

	Template.GiveRewardFn = GiveSparkCoreHeistReward;
	Template.GetRewardStringFn = GetMissionRewardString;

	return Template;
}

function GiveSparkCoreHeistReward(
XComGameState NewGameState,
XComGameState_Reward RewardState,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){
	GiveRiskyMissionReward(NewGameState, RewardState, 'ShowOfForce', 'ILB_Reward_Spark', 'Recover', false, AuxRef);
}

function GiveRiskyMissionReward(
XComGameState NewGameState,
XComGameState_Reward RewardState,
name NegativeSitrepName,
name NewRewardName,
name MissionFamilyName,
bool ReplaceExistingReward,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1)
{
	local XComGameState_MissionSite MissionState;
	local XComGameState_WorldRegion RegionState;
	local XComGameState_Reward MissionRewardState;
	local X2RewardTemplate RewardTemplate;
	local X2StrategyElementTemplateManager StratMgr;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local StateObjectReference RegionRef;

	`LOG("Generating possibly-risky mission reward");

	RegionRef = ChooseRandomRegion(NewGameState);

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(RegionRef.ObjectID));	

	MissionRewards.Length = 0;
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(NewRewardName));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.GenerateReward(NewGameState);
	//NewGameState.AddStateObject(MissionRewardState);
	MissionRewards.AddItem(MissionRewardState);

	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));
	//NewGameState.AddStateObject(MissionState);

	MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));
	
	MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	
	if (ReplaceExistingReward)
	{
		MissionRewards.Length = 0;
	}

	MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);
	MissionState.PickPOI(NewGameState);

	MissionState.GeneratedMission.Mission.MissionFamily = string(MissionFamilyName);
	MissionState.GeneratedMission.SitReps.AddItem(NegativeSitrepName);

	RewardState.RewardObjectReference = MissionState.GetReference();
	`LOG("FINISHED generating possibly-risky mission reward");
}

///////////////STEAL SPARK REWARD TEMPLATE FOLLOWS////////////////////////////////////////
static function X2DataTemplate CreateSparkRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_Spark');

	Template.GenerateRewardFn = GenerateStealSparkReward;
	Template.SetRewardFn = SetStealSparkReward;
	Template.GiveRewardFn = GiveStealSparkReward;
	Template.GetRewardStringFn = GetStealSparkRewardString;
	Template.CleanUpRewardFn = CleanUpStealSparkReward;

	return Template;
}

static function GenerateStealSparkReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	local XComGameState_CovertAction ActionState;

	ActionState = XComGameState_CovertAction(NewGameState.GetGameStateForObjectID(AuxRef.ObjectID));
	if (ActionState != none) ActionState.StoredRewardRef = RewardState.GetReference();

	RewardState.RewardObjectReference = CreateSparkSoldier(NewGameState);
}

static function SetStealSparkReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	RewardState.RewardObjectReference = RewardObjectRef;
}

static function GiveStealSparkReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{	
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit Unit;
	`LOG("Attempting giving of steal-spark-reward");

	XComHQ = `XCOMHQ;
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	XComHQ.AddToCrew(NewGameState, Unit);
}

static function string GetStealSparkRewardString(XComGameState_Reward RewardState)
{
	local XComGameState_Unit Unit;

	`LOG("Attempting generation of steal-spark-reward description");
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	
	return RewardState.GetMyTemplate().DisplayName $":" @Unit.GetSoldierShortRankName() @Unit.GetFullName();
}

static protected function CleanUpStealSparkReward(XComGameState NewGameState, XComGameState_Reward RewardState)
{
	// Do literary nothing. Literary.	
}

// HELPERS
static function StateObjectReference CreateSparkSoldier(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit NewSparkState;
	local int NewRank, idx;	
	`LOG("Attempting generation of steal-spark-reward contents");

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	// Create the necessary Spark Equipments 
	class'X2Helpers_DLC_Day90'.static.CreateSparkEquipment(NewGameState);	

	// Let's not break [WOTC] Expanded ROBOTICS Repair Facility v3
	if (!class'X2DownloadableContentInfo_NewResistanceOrders'.static.IsModActive('WOTC_MoreEngineeringRepairSlots'))
	{
		FacilityState = XComHQ.GetFacilityByName('Storage');
		if (FacilityState != none && FacilityState.GetNumLockedStaffSlots() > 0)
		{
			// Unlock the Repair SPARK staff slot in Engineering
			FacilityState.UnlockStaffSlot(NewGameState);
		}
	}

	// Create a Spark from the Character Pool (will be randomized if no Sparks have been created)
	ProfileSettings = `XPROFILESETTINGS;
	NewSparkState = `CHARACTERPOOLMGR.CreateCharacter(NewGameState, ProfileSettings.Data.m_eCharPoolUsage, 'SparkSoldier');
	NewSparkState.RandomizeStats();
	NewSparkState.ApplyInventoryLoadout(NewGameState);

	// Rank ups
	NewRank = GetPersonnelRewardRank(true, false);	
	NewSparkState.SetXPForRank(NewRank);
	NewSparkState.StartingRank = NewRank;

	// idx starts at 1 because Sparks do not start with Rookie (CharTemplate.DefaultSoldierClass = 'Spark')
	for (idx = 1; idx < NewRank; idx++)
	{		
		NewSparkState.RankUpSoldier(NewGameState);
	}

	// Make sure the new Spark has the best gear available (will also update to appropriate armor customizations)
	NewSparkState.ApplySquaddieLoadout(NewGameState);
	NewSparkState.ApplyBestGearLoadout(NewGameState);

	NewSparkState.kAppearance.nmPawn = 'XCom_Soldier_Spark';
	NewSparkState.kAppearance.iAttitude = 2;	// Force the attitude to be Normal
	NewSparkState.UpdatePersonalityTemplate();	// Grab the personality based on the one set in kAppearance
	NewSparkState.SetStatus(eStatus_Active);
	NewSparkState.bNeedsNewClassPopup = false;

	return NewSparkState.GetReference();	
}


static function StateObjectReference ChooseRandomRegion(XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local array<StateObjectReference> RegionRefs;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		RegionRefs.AddItem(RegionState.GetReference());
	}

	return RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];
}