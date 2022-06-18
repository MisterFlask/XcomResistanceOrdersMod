// This is an Unreal Script

//todo: Fix name
class DefaultCovertActions extends X2StrategyElement;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;
	CovertActions.AddItem(CreateGeneralCovertActionWithRewardTemplate('ILB_CovertAction_SpawnAiTheft', 'ILB_Reward_SparkMission'));
	return CovertActions;
}

static function X2DataTemplate CreateGeneralCovertActionWithRewardTemplate(name TemplateName, name RewardName)
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, TemplateName);

	Template.ChooseLocationFn = ChooseRandomRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";

	Template.Narratives.AddItem(name("CovertActionNarrative_" $ TemplateName));

	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Intel', 15));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');

	Template.Rewards.AddItem(RewardName);

	return Template;
}


private static function StrategyCostReward CreateOptionalCostSlot(name ResourceName, int Quantity)
{
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}
private static function CovertActionSlot CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	SoldierSlot.Rewards.AddItem('Reward_RankUp');
	SoldierSlot.iMinRank = iMinRank;
	SoldierSlot.bChanceFame = false;
	SoldierSlot.bRandomClass = bRandomClass;
	SoldierSlot.bFactionClass = bFactionClass;

	if (SlotName == 'CovertActionRookieStaffSlot')
	{
		SoldierSlot.bChanceFame = false;
	}

	return SoldierSlot;
}

static function AddCovertActionToFaction(XComGameState NewGameState, name CovertActionTemplateName, name FactionName){
	local X2CovertActionTemplate ActionTemplate;
	local XComGameState_ResistanceFaction FactionState;
	local X2StrategyElementTemplateManager StratMgr;
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	FactionState = GetFaction(FactionName, NewGameState);
	ActionTemplate = X2CovertActionTemplate(StratMgr.FindStrategyElementTemplate(CovertActionTemplateName));

	FactionState.CovertActions.AddItem(CreateCovertAction(NewGameState, ActionTemplate, FactionState.GetReference()));
}

//e.g. Faction_Skirmishers
static function XComGameState_ResistanceFaction GetFaction(name FactionName, XComGameState NewGameState){

	local XComGameState_ResistanceFaction FactionState;

	foreach NewGameState.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (FactionState.FactionName == string(FactionName)){
			return FactionState;
		}
	}
}

static function StateObjectReference CreateCovertAction(XComGameState NewGameState, X2CovertActionTemplate ActionTemplate, StateObjectReference FactionRef)
{
	local XComGameState_CovertAction ActionState;

	ActionState = ActionTemplate.CreateInstanceFromTemplate(NewGameState,FactionRef);
	ActionState.Spawn(NewGameState);
	ActionState.RequiredFactionInfluence = 1;
	ActionState.bNewAction = true;

	return ActionState.GetReference();
}

static function ChooseRandomRegion(XComGameState NewGameState, XComGameState_CovertAction ActionState, out array<StateObjectReference> ExcludeLocations)
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local array<StateObjectReference> RegionRefs;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (ExcludeLocations.Find('ObjectID', RegionState.GetReference().ObjectID) == INDEX_NONE)
		{
			RegionRefs.AddItem(RegionState.GetReference());
		}		
	}

	ActionState.LocationEntity = RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];
}
