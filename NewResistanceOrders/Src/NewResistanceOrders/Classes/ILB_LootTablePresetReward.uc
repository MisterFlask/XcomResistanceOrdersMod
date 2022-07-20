// This is an Unreal Script
// This allows generating an item reward known ahead of time to the player.

class ILB_LootTablePresetReward extends X2StrategyElement
	dependson(X2RewardTemplate)
	config(GameData);

static function XComGameState_Reward BuildMissionItemReward_AggressiveOpportunism(XComGameState NewGameState){
	return BuildMissionItemRewardBasedOnLootTable(NewGameState, 'ResCard_AggressiveOpportunism_Loot');
}

static function XComGameState_Reward BuildMissionItemRewardBasedOnLootTable(XComGameState NewGameState,  name GlobalLootCarrierName ){
	
	return BuildMissionItemReward(NewGameState, GetItemTemplateNameFromGlobalLootCarrier(GlobalLootCarrierName));
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
	//NewGameState.AddStateObject(RewardState); 

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);
	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	//NewGameState.AddStateObject(ItemState); 
	RewardState.RewardObjectReference = ItemState.GetReference();

	return RewardState;
}

static function name GetItemTemplateNameFromGlobalLootCarrier(name GlobalLootCarrierName){
	
	local X2ItemTemplateManager ItemMgr;
	local array<XComGameState_Item> ItemList;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2LootTableManager LootManager;
	local LootResults Loot;
	local int LootIndex, idx, i;
	local bool bFound;

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	LootManager = class'X2LootTableManager'.static.GetLootTableManager();
	LootIndex = LootManager.FindGlobalLootCarrier(GlobalLootCarrierName);

	if(LootIndex >= 0)
	{
		LootManager.RollForGlobalLootCarrier(LootIndex, Loot);
	}

	ItemTemplate = ItemMgr.FindItemTemplate(Loot.LootToBeCreated[0]);
	return ItemTemplate.DataName;
}