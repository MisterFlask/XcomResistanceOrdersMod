class ILB_LootTablePresetReward extends X2StrategyElement_DefaultRewards;
/*
static function XComGameState_Reward BuildMissionItemReward_AggressiveOpportunism()
{

}

static function X2DataTemplate CreateLootTableRewardTemplate_AggressiveOpportunism()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_LootTablePresetReward');
	Template.rewardObjectTemplateName = 'POI';
	
	Template.SetRewardByTemplateFn = SetLootTableReward;
	Template.GiveRewardFn = GiveLootTableReward;
	Template.GetRewardStringFn = GetLootTableRewardString;

	return Template;
}
static function X2DataTemplate CreateLootTableRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_LootTable');
	Template.rewardObjectTemplateName = 'POI';
	
	Template.SetRewardByTemplateFn = SetLootTableReward;
	Template.GiveRewardFn = GiveLootTableReward;
	Template.GetRewardStringFn = GetLootTableRewardString;
	Template.GenerateRewardFn = GenerateLootTableReward;
	return Template;
}
function SetLootTableReward_AggressiveOpportunism(XComGameState_Reward RewardState, name TemplateName)
{
	RewardState.RewardObjectTemplateName = TemplateName;
}
function GenerateLootTableReward_AggressiveOpportunism(){

}

function GiveLootTableReward_AggressiveOpportunism(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local X2ItemTemplateManager ItemTemplateManager;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2LootTableManager LootManager;
	local LootResults LootToGive;
	local name LootName;
	local int LootIndex, idx;

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);

	LootManager = class'X2LootTableManager'.static.GetLootTableManager();
	LootIndex = LootManager.FindGlobalLootCarrier(RewardState.GetMyTemplate().rewardObjectTemplateName);
	if (LootIndex >= 0)
	{
		LootManager.RollForGlobalLootCarrier(LootIndex, LootToGive);
	}

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach LootToGive.LootToBeCreated(LootName, idx)
	{
		ItemTemplate = ItemTemplateManager.FindItemTemplate(LootName);
		ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
		NewGameState.AddStateObject(ItemState);
		XComHQ.PutItemInInventory(NewGameState, ItemState);

		RewardState.RewardString $= ItemTemplate.GetItemFriendlyName();
		if (idx < (LootToGive.LootToBeCreated.Length - 1))
			RewardState.RewardString $= ", ";
	}	
}
function string GetLootTableRewardString_AggressiveOpportunism(XComGameState_Reward RewardState)
{
	return RewardState.RewardString;
} */