//---------------------------------------------------------------------------------------
//  AUTHOR:  statusNone
//  PURPOSE: Manager class to control the delay of any reinforcements issued
//---------------------------------------------------------------------------------------
//  WOTCStrategyOverhaul Team
//---------------------------------------------------------------------------------------

class XComGameState_ILB_BlackMarketState extends XComGameState_BaseObject;

var bool bPopulatedBlackMarketWithResistanceOrders;

static function CreateSingletonIfNotExists(XComGameState NewGameState)
{

	if (GetSingleton(true) == none)
	{
		NewGameState.CreateNewStateObject(class'XComGameState_ILB_BlackMarketState');
		`LOG("ILB: Black market state singleton generated.  Shouldn't need to happen more than once.");
	}
}

static function HandleBlackMarketReset(XComGameState NewGameState){
	local XComGameState_ILB_BlackMarketState ILB_BlackMarketState;

	CreateSingletonIfNotExists(NewGameState);
	`LOG("ILB: Black market reset occurring!  Must reset ui screen listener accordingly.");

	ILB_BlackMarketState = GetSingleton();
	ILB_BlackMarketState = XComGameState_ILB_BlackMarketState(NewGameState.ModifyStateObject(class'XComGameState_ILB_BlackMarketState', ILB_BlackMarketState.ObjectID));

	ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders = false;
}

static function HandleBlackMarketScreenOpened(){
	local XComGameState NewGameState;
	local XComGameState_ILB_BlackMarketState ILB_BlackMarketState;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CI: Creating ILB Black Market manager singleton");
	CreateSingletonIfNotExists(NewGameState);

	ILB_BlackMarketState = GetSingleton();

	if (ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders){
		// we've done all we must

		`GAMERULES.SubmitGameState(NewGameState);
		`LOG("ILB: Black market update not necessary; already done for this month");
		return;
	}

	`LOG("ILB: Haven't populated black market yet!  Handling resistance orders.");
	ILB_BlackMarketState = XComGameState_ILB_BlackMarketState(NewGameState.ModifyStateObject(class'XComGameState_ILB_BlackMarketState', ILB_BlackMarketState.ObjectID));
	
	ILB_BlackMarketState.bPopulatedBlackMarketWithResistanceOrders = true;
	
	// HACK: Don't feel like refactoring at the moment.  Just gonna call event listener code as though I were handling the actual bm reset.
	class'IRB_NewResistanceOrders_EventListeners'.static.BlackMarketResetListener(GetBlackMarketState(NewGameState), none, NewGameState, 'DummyEvent', none);
	`GAMERULES.SubmitGameState(NewGameState);
}

static function XComGameState_ILB_BlackMarketState GetSingleton(optional bool AllowNull = false)
{
	return XComGameState_ILB_BlackMarketState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_ILB_BlackMarketState', AllowNull));
}

static function XComGameState_BlackMarket GetBlackMarketState(XComGameState NewGameState){
	local XComGameState_BlackMarket BM;

	BM = XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket', true));
	BM=  XComGameState_BlackMarket(NewGameState.ModifyStateObject(class'XComGameState_BlackMarket', BM.ObjectID));
	return BM;
}