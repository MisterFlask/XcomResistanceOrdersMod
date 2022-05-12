//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ILB_BlackMarketState extends XComGameState_BaseObject;

var bool bPopulatedBlackMarketWithResistanceOrders;

static function CreateSingletonIfNotExists()
{
	local XComGameState NewGameState;

	if (GetSingleton(true) == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating ILB Black Market manager singleton");
		NewGameState.CreateNewStateObject(class'XComGameState_ILB_BlackMarketState');
		`GAMERULES.SubmitGameState(NewGameState);		
		`LOG("ILB: Black market state singleton generated.  Shouldn't need to happen more than once.");

	}
}

static function HandleBlackMarketReset(XComGameState NewGameState){
	local XComGameState_ILB_BlackMarketState ILB_BlackMarketState;

	CreateSingletonIfNotExists();
	`LOG("ILB: Black market reset occurring!  Must reset ui screen listener accordingly.");

	ILB_BlackMarketState = GetSingleton();
	ILB_BlackMarketState = XComGameState_ILB_BlackMarketState(NewGameState.ModifyStateObject(class'XComGameState_ILB_BlackMarketState', ILB_BlackMarketState.ObjectID));

	ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders = false;

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

}

static function HandleBlackMarketScreenOpened(){
	local XComGameState NewGameState;
	local XComGameState_ILB_BlackMarketState ILB_BlackMarketState;
	
	CreateSingletonIfNotExists();

	ILB_BlackMarketState = GetSingleton();

	if (ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders){
		// we've done all we must
		`LOG("ILB: Black market update not necessary; already done for this month");
		return;
	}

	`LOG("ILB: Haven't populated black market yet!  Handling resistance orders.");
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("ILB: Black market state.");
	ILB_BlackMarketState = XComGameState_ILB_BlackMarketState(NewGameState.ModifyStateObject(class'XComGameState_ILB_BlackMarketState', ILB_BlackMarketState.ObjectID));
	
	ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders = true;
	
	// HACK: Don't feel like refactoring at the moment.  Just gonna call event listener code as though I were handling the actual bm reset.
	class'IRB_NewResistanceOrders_EventListeners'.static.BlackMarketResetListener(GetBlackMarketState(), none, NewGameState, 'DummyEvent', none);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

static function XComGameState_ILB_BlackMarketState GetSingleton(optional bool AllowNull = false)
{
	return XComGameState_ILB_BlackMarketState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ILB_BlackMarketState', AllowNull));
}

static function XComGameState_BlackMarket GetBlackMarketState(){
	return XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket', true));
}