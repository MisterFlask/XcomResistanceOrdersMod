// This is an Unreal Script

class ILB_StrategicResCards extends X2StrategyElement_XpackResistanceActions;
	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards (strategic)");
		
		// Templates of the form "if condition X, grant soldier perk Y"
		// Disadvantageous mission sitreps?  -2 turns to complete, +1 force level, +1 squad size, no starting concealment
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_StealSparkCore'));
		Techs.AddItem(CreateBrazenCollection());
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BrazenRecruitment')); 
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_RescueRichPerson')); // swarm mission grants you supplies
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_RescueFriendlyPolitician')); // swarm mission grants you res contact
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_RescueFriendlyRetinue')); // res contacts mission, just grants you the soldiers and a heavy weapon
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_AcquirePowerSource')); // Recover supply mission

		Techs.AddItem(CreateRadioFreeLily());
		Techs.AddItem(CreateNotoriousSmugglers());
		Techs.AddItem(CreateGrndlPowerDeal());
		// Techs.AddItem(RemotelyChargedBackpacks());
		// Techs.AddItem(RemotelyChargedSparks());
		// Techs.AddItem(CreateChargedPsionics()); // adds Teleportation and Blink to templars + psions; costs 5 power.
		// Techs.AddItem(CreateLeylinePowerSource()); // adds power at cost of 15% chance crackdown; also, crackdowns have a 50% chance of including Psionic Storm sitrep.  
		return Techs;
	}


	static function X2DataTemplate CreateGrndlPowerDeal(){
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_GrndlPowerDeal');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateGrndlPowerCollection;
		Template.OnDeactivatedFn = DeactivateGrndlPowerCollection;
		Template.GetMutatorValueFn = GetValueGrndlPowerCollection;
		Template.GetSummaryTextFn = GetSummaryTextReplaceInt;
		Template.CanBeRemovedFn = CanHiddenReservesBeRemoved;

		return Template;
}
//---------------------------------------------------------------------------------------
static function ActivateGrndlPowerCollection(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_HeadquartersResistance ResistanceHQ;
	
	ResistanceHQ = GetNewResHQState(NewGameState);
	ResistanceHQ.SupplyDropPercentIncrease -= 20;
	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.PowerOutputBonus += GetValueGrndlPowerCollection();
	XComHQ.DeterminePowerState();
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function DeactivateGrndlPowerCollection(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;
	
	local XComGameState_HeadquartersResistance ResistanceHQ;
	
	ResistanceHQ = GetNewResHQState(NewGameState);
	ResistanceHQ.SupplyDropPercentIncrease += 20;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.PowerOutputBonus -= GetValueGrndlPowerCollection();

	XComHQ.DeterminePowerState();
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function int GetValueGrndlPowerCollection()
{
	return 4;
}
	
	static function X2DataTemplate CreateNotoriousSmugglers(){
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_NotoriousSmugglers');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateNotoriousSmugglers;
		Template.OnDeactivatedFn = DeactivateNotoriousSmugglers;
		Template.GetMutatorValueFn = GetValueNotoriousSmugglers;
		Template.GetSummaryTextFn = GetSummaryTextReplaceInt;
		Template.CanBePlayedFn = BlackMarketCardsCanBePlayed;
		return Template;
	}

//---------------------------------------------------------------------------------------
static function ActivateNotoriousSmugglers(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_BlackMarket BlackMarket;

	BlackMarket = GetNewBlackMarketState(NewGameState);
	BlackMarket.GoodsCostPercentDiscount += GetValueNotoriousSmugglers();
	BlackMarket.UpdateForSaleItemDiscount();
}
//---------------------------------------------------------------------------------------
static function DeactivateNotoriousSmugglers(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_BlackMarket BlackMarket;

	BlackMarket = GetNewBlackMarketState(NewGameState);
	BlackMarket.GoodsCostPercentDiscount -= GetValueNotoriousSmugglers();
	BlackMarket.UpdateForSaleItemDiscount();
}
//---------------------------------------------------------------------------------------
static function int GetValueNotoriousSmugglers()
{
	return 25;
}
//---------------------------------------------------------------------------------------
static function bool BlackMarketCardsCanBePlayed(StateObjectReference InRef, optional XComGameState NewGameState = none)
{
	local XComGameState_BlackMarket BlackMarketState;

	BlackMarketState = XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket'));
	if (BlackMarketState != none && BlackMarketState.NumTimesAppeared > 0)
	{
		// Card is available if the Black Market has appeared at least once in the game
		return true;
	}

	return false;
}
	/// Core concept:  Awesome, yet provokes ADVENT crackdowns of various stripes in a random 20% of non-golden-path missions.
	static function X2DataTemplate CreateBrazenCollection(){
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BrazenCollection');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateBrazenCollection;
		Template.OnDeactivatedFn = DeactivateBrazenCollection;
		return Template;
	}//---------------------------------------------------------------------------------------
	
	static function ActivateBrazenCollection(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
	{
		local XComGameState_HeadquartersResistance ResistanceHQ;

		ResistanceHQ = GetNewResHQState(NewGameState);
		ResistanceHQ.SupplyDropPercentIncrease += 20;
	}

	//---------------------------------------------------------------------------------------
	static function DeactivateBrazenCollection(XComGameState NewGameState, StateObjectReference InRef)
	{
		local XComGameState_HeadquartersResistance ResistanceHQ;

		ResistanceHQ = GetNewResHQState(NewGameState);
		ResistanceHQ.SupplyDropPercentIncrease -= 20;
	}
	
	
static function X2DataTemplate CreateRadioFreeLily()
{
	local X2StrategyCardTemplate Template;

	`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_RadioFreeLily');
	Template.Category = "ResistanceCard";
	Template.OnActivatedFn = ActivateRadioFreeLily;
	Template.OnDeactivatedFn = DeactivateRadioFreeLily;
	Template.CanBeRemovedFn = CanRemoveIncreasedResistanceContactsOrder;

	return Template;
}

static function bool CanRemoveIncreasedResistanceContactsOrder(StateObjectReference InRef, optional StateObjectReference ReplacementRef)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_StrategyCard CardState, ReplacementCardState;
	local bool bCanBeRemoved;

	History = `XCOMHISTORY;
	CardState = GetCardState(InRef);
	ReplacementCardState = GetCardState(ReplacementRef);
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("DON'T SUBMIT: CARD PREVIEW STATE");
	DeactivateAllCardsNotInPlay(NewGameState);
	CardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', CardState.ObjectID));

	if(WasCardInPlay(CardState))
	{
		CardState.DeactivateCard(NewGameState);
	}

	if(ReplacementCardState != none)
	{
		ReplacementCardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', ReplacementCardState.ObjectID));
		ReplacementCardState.ActivateCard(NewGameState);
	}

	XComHQ = GetNewXComHQState(NewGameState);
	bCanBeRemoved = (XComHQ.GetRemainingContactCapacity() >= 0);
	History.CleanupPendingGameState(NewGameState);

	return bCanBeRemoved;
}
//---------------------------------------------------------------------------------------
static function ActivateRadioFreeLily(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.BonusCommCapacity += 3;
}
//---------------------------------------------------------------------------------------
static function DeactivateRadioFreeLily(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.BonusCommCapacity -= 3;
}

static function X2DataTemplate CreateBlankResistanceOrder(name OrderName)
{
	local X2StrategyCardTemplate Template;
		
	`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, OrderName);
	Template.Category = "ResistanceCard";
	`log("Created blank resistance order: "  $ OrderName);
	return Template; 
}


