// This is an Unreal Script
class ILB_DefaultMissionRewards extends X2StrategyElement_DefaultRewards 
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(CreateSparkRewardTemplate());

	Templates.AddItem(CreateSparkMissionRewardTemplate());
	Templates.AddItem(CreateSwarmDefenseMissionReward_GrantsSupplies());
	Templates.AddItem(CreateSwarmDefenseMissionReward_GrantsResistanceContact());
	Templates.AddItem(CreateCouncilBountyMissionReward_GrantsSupplies());

	Templates.AddItem(CreateMissionFlavorTextTemplate('ILB_RescueRichPerson'));
	Templates.AddItem(CreateMissionFlavorTextTemplate('ILB_RescueFriendlyPolitician'));
	Templates.AddItem(CreateMissionFlavorTextTemplate('ILB_StealSparkCore'));
	Templates.AddItem(CreateMissionFlavorTextTemplate('ILB_CouncilBounties'));
	return Templates;
}

static function X2DataTemplate CreateMissionFlavorTextTemplate(name TemplateName){
	local X2DataTemplate Template;
	`CREATE_X2TEMPLATE(class'X2MissionFlavorTextTemplate', Template, TemplateName);

	return Template;
}
static function X2DataTemplate CreateCouncilBountyMissionReward_GrantsSupplies()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_CouncilBounties');

	Template.GiveRewardFn = GiveCouncilBountiesReward;
	Template.GetRewardStringFn = GetMissionRewardString;

	return Template;
}


function GiveCouncilBountiesReward(
XComGameState NewGameState,
XComGameState_Reward RewardState,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){
	GiveRiskyMissionReward(NewGameState, RewardState, 'ILB_Sitrep_TougherFieldCommander', 
	 'Reward_Supplies', 'NeutralizeFieldCommander', 
	 false, 'ILB_CouncilBounties', AuxRef);
}
static function X2DataTemplate CreateSparkMissionRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_SparkMission');

	Template.GiveRewardFn = GiveSparkCoreHeistReward;
	Template.GetRewardStringFn = GetMissionRewardString;

	return Template;
}

static function X2RewardTemplate CreateSwarmDefenseMissionReward_GrantsSupplies(){

	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_SwarmDefenseForSupplies');

	Template.GiveRewardFn = GiveSwarmDefenseForSuppliesMission;
	Template.GetRewardStringFn = GetMissionRewardString;

	return Template;
}


static function X2RewardTemplate CreateSwarmDefenseMissionReward_GrantsResistanceContact(){

	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_SwarmDefenseForResistanceContact');

	Template.GiveRewardFn = GiveSwarmDefenseForResistanceContactMission;
	Template.GetRewardStringFn = GetMissionRewardString;

	return Template;
}

function GiveSwarmDefenseForSuppliesMission(
XComGameState NewGameState,
XComGameState_Reward RewardState,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Reward MissionRewardState;
	local X2StrategyElementTemplateManager StratMgr;
	local name NewRewardName;

	NewRewardName = 'Reward_Supplies';

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(NewRewardName));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.Quantity = 111;
	MissionRewardState.GenerateReward(NewGameState, , ChooseRandomRegion());
	GiveRiskyMissionRewardWithDefinedReward(NewGameState,
		RewardState,
		'',
		MissionRewardState,
		'SwarmDefense',
		false,
		'ILB_RescueRichPerson',
		AuxRef,
		bOrder,
		OrderHours);
}

public function name GrabRandomCrackdownSitrep(){
	return class'X2DownloadableContentInfo_NewResistanceOrders'.static.GrabRandomCrackdownSitrep();
}

public function name GetForceLevelSitrep(){
	return class'ILB_DefaultSitreps'.static.GetRandomForceLevelIncreaseSitrep();//0-3
}

function GiveSwarmDefenseForResistanceContactMission(
XComGameState NewGameState,
XComGameState_Reward RewardState,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){
	GiveRiskyMissionReward(NewGameState, RewardState, '', 'Reward_AvengerResComms', 'SwarmDefense', true, 'ILB_RescueFriendlyPolitician', AuxRef);
}

function GiveSparkCoreHeistReward(
XComGameState NewGameState,
XComGameState_Reward RewardState,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){
	GiveRiskyMissionReward(NewGameState, RewardState, GetForceLevelSitrep(), 'ILB_Reward_Spark', 'Recover', true, 'ILB_StealSparkCore', AuxRef);
}


function GiveRiskyMissionRewardWithDefinedReward(
XComGameState NewGameState,
XComGameState_Reward JustTheMission,
name NegativeSitrepName,
XComGameState_Reward MissionSpecificRewardState,
name MissionFamilyName,
bool ReplaceExistingReward,
name FlavorTextTemplateName,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1){

	local XComGameState_MissionSite MissionState;
	local X2MissionSourceTemplate MissionSource;
	local array<XComGameState_Reward> MissionRewards;
	local float MissionDuration;
	local StateObjectReference RegionRef;
	local XComGameState_WorldRegion localRegion;
	local X2MissionFlavorTextTemplate FlavorTextTemplate;
	local XComParcelManager ParcelMgr;
	local X2StrategyElementTemplateManager StratMgr;
	local Vector2D LocVector;

	ParcelMgr = `PARCELMGR;
	`LOG("Generating possibly-risky mission reward");

	RegionRef = ChooseRandomRegion();

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	//RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(RegionRef.ObjectID));	
	

	MissionState = XComGameState_MissionSite(NewGameState.CreateStateObject(class'XComGameState_MissionSite'));

	localRegion = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(RegionRef.ObjectID));
	
	if(localRegion != none){
		MissionState.Continent = localRegion.GetContinent().GetReference();
		MissionState.Region = localRegion.GetReference();
		LocVector = localRegion.GetRandom2DLocationInRegion();
		MissionState.Location.X = LocVector.X;
		MissionState.Location.Y = LocVector.Y;
	}

	//NewGameState.AddStateObject(MissionState);

	// MissionSource = X2MissionSourceTemplate(StratMgr.FindStrategyElementTemplate('MissionSource_GuerillaOp'));
	// `LOG("Finished generating missionState and missionSource");

	//MissionDuration = float((default.MissionMinDuration + `SYNC_RAND_STATIC(default.MissionMaxDuration - default.MissionMinDuration + 1)) * 3600);
	
	//NewGameState.AddStateObject(MissionRewardState);

	//MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , , , , false);
	//MissionState.BuildMission(MissionSource, RegionState.GetRandom2DLocationInRegion(), RegionState.GetReference(), MissionRewards, true, true, , MissionDuration);

	// so once more we set mission data.  In this case, by excluding every mission family EXCEPT the desired one
	//SetMissionData(MissionRewards[0].GetMyTemplate(), bUseSpecifiedLevelSeed, LevelSeedOverride);
	//SetMissionData(name MissionFamily, XComGameState_MissionSite MissionState, X2RewardTemplate MissionReward, XComGameState NewGameState, bool bUseSpecifiedLevelSeed, int LevelSeedOverride)
	`LOG("Setting mission data using " $ MissionFamilyName $ ": ");
	MissionState.Source = 'MissionSource_GuerillaOp';
	class'MissionGenerator'.static.SetMissionData(MissionFamilyName, MissionState, MissionSpecificRewardState.GetMyTemplate(), NewGameState, false, 0);
	
	MissionState.Available = true;
	MissionState.Expiring = true;
	
	MissionState.TimerStartDateTime = `STRATEGYRULES.GameTime;
	MissionState.TimeUntilDespawn  = 500000.0;
	MissionState.SetProjectedExpirationDateTime(MissionState.TimerStartDateTime);

	//todo: redo sitreps so that they don't reflect the OLD mission family
	//MissionState.GeneratedMission.Plot = MissionState.SelectPlotDefinition(MissionState.GeneratedMission.Mission, MissionState.GeneratedMission.Biome.strType);
	//MissionState.GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(MissionState.GeneratedMission.Biome.strType);
	//MissionState.Rewards.AddItem(MissionRewardState);
	
	MissionState.PickPOI(NewGameState);
	
	if (NegativeSitrepName != ''){
		MissionState.GeneratedMission.SitReps.AddItem(NegativeSitrepName);
	}

	//RewardState.RewardObjectReference = MissionState.GetReference();
	`LOG("FINISHED generating possibly-risky mission reward");
	
	MissionState.Rewards.AddItem(MissionSpecificRewardState.GetReference());
	
	if (MissionSource.bIntelHackRewards)
	{
		MissionState.PickIntelOptions();
	}

	FlavorTextTemplate = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().GetMissionFlavorText(MissionState, , FlavorTextTemplateName);
	MissionState.SuccessText = FlavorTextTemplate.CouncilSpokesmanSuccessText[0];
	MissionState.FailureText = FlavorTextTemplate.CouncilSpokesmanFailureText[0];

}

function GiveRiskyMissionReward(
XComGameState NewGameState,
XComGameState_Reward JustTheMission,
name NegativeSitrepName,
name NewRewardName,
name MissionFamilyName,
bool ReplaceExistingReward,
name FlavorTextTemplateName,
optional StateObjectReference AuxRef,
optional bool bOrder = false,
optional int OrderHours = -1)
{
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Reward MissionRewardState;
	local X2StrategyElementTemplateManager StratMgr;


	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate(NewRewardName));
	MissionRewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	MissionRewardState.Quantity = 1;
	MissionRewardState.GenerateReward(NewGameState, , ChooseRandomRegion());
	GiveRiskyMissionRewardWithDefinedReward(NewGameState,
		JustTheMission,
		NegativeSitrepName,
		MissionRewardState,
		MissionFamilyName,
		ReplaceExistingReward,
		FlavorTextTemplateName,
		AuxRef,
		bOrder,
		OrderHours);
}


static function StateObjectReference ChooseRandomRegion()
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

	//`LOG("Attempting generation of steal-spark-reward description");
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
