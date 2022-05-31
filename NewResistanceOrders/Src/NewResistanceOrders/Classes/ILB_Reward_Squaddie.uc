// This is an Unreal Script
class ILB_Reward_Squaddie extends X2StrategyElement
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Custom resource Rewards
	Rewards.AddItem(CreateSquaddieRewardTemplate());

	return Rewards;
}

static function X2DataTemplate CreateSquaddieRewardTemplate()
{
	local X2RewardTemplate Template;

	// Gives you a rookie instead of a promoted soldier
	`CREATE_X2Reward_TEMPLATE(Template, 'ILB_Reward_Squaddie');
	Template.rewardObjectTemplateName = 'Soldier';

	Template.GenerateRewardFn = GeneratePersonnelReward;
	Template.SetRewardFn = class'X2StrategyElement_DefaultRewards'.static.SetPersonnelReward;
	Template.GiveRewardFn = class'X2StrategyElement_DefaultRewards'.static.GivePersonnelReward;
	Template.GetRewardStringFn = class'X2StrategyElement_DefaultRewards'.static.GetPersonnelRewardString;
	Template.GetRewardImageFn = class'X2StrategyElement_DefaultRewards'.static.GetPersonnelRewardImage;
	Template.GetBlackMarketStringFn = class'X2StrategyElement_DefaultRewards'.static.GetSoldierBlackMarketString;
	Template.GetRewardIconFn = class'X2StrategyElement_DefaultRewards'.static.GetGenericRewardIcon;
	Template.CleanUpRewardFn = class'X2StrategyElement_DefaultRewards'.static.CleanUpUnitReward;
	Template.RewardPopupFn = class'X2StrategyElement_DefaultRewards'.static.PersonnelRewardPopup;

	return Template;
}

static function GeneratePersonnelReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference RegionRef)
{
	local XComGameState_Unit NewUnitState;
	local XComGameState_WorldRegion RegionState;
	local name nmCountry;
	
	// Grab the region and pick a random country
	nmCountry = '';
	RegionState = XComGameState_WorldRegion(`XCOMHISTORY.GetGameStateForObjectID(RegionRef.ObjectID));

	if(RegionState != none)
	{
		nmCountry = RegionState.GetMyTemplate().GetRandomCountryInRegion();
	}

	NewUnitState = class'X2StrategyElement_DefaultRewards'.static.CreatePersonnelUnit(NewGameState, RewardState.GetMyTemplate().rewardObjectTemplateName, nmCountry, true);
	
	NewUnitState.SetXPForRank(1);
	NewUnitState.StartingRank = 1;
	RewardState.RewardObjectReference = NewUnitState.GetReference();
}
