// This is an Unreal Script

class ILB_StrategicResCards extends X2StrategyElement_XpackResistanceActions config(ResCards);

	var config int BRAZEN_COLLECTION_BONUS;
	var config int LABS_TO_COMMS_COMMS_BONUS;
	var config int LABS_TO_COMMS_RESEARCH_PENALTY;
	var config int XENO_FIELD_RESEARCH_RESEARCH_BONUS;
	var config int RADIO_FREE_LILY_COMMS_BONUS;
	var config int GRNDL_POWER_DEAL_POWER_BONUS;
	var config int LEACH_PSIONIC_LEYLINES_POWER_BONUS;
	var config int GRNDL_POWER_DEAL_SUPPLY_PENALTY;
	var config int NOTORIOUS_SMUGGLERS_BLACK_MARKET_DISCOUNT;


	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards (strategic)");
		
		// Templates of the form "if condition X, grant soldier perk Y"
		// Disadvantageous mission sitreps?  -2 turns to complete, +1 force level, +1 squad size, no starting concealment
		Techs.AddItem(CreateBrazenCollection());
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BrazenRecruitment')); //
		Techs.AddItem(CreateLabsToCommsRepurposing());

		Techs.AddItem(CreateXenobiologicalFieldResearch());
		Techs.AddItem(CreateRadioFreeLily());
		Techs.AddItem(CreateNotoriousSmugglers());
		Techs.AddItem(CreateGrndlPowerDeal());
		Techs.AddItem(CreateLeachPsionicLeylines());

		Techs.AddItem(CreateBlankResistanceOrder('ResCard_CouncilBounties')); //
		// Techs.AddItem(CreateBlankResistanceOrder('ResCard_PoweredArmorHeist')); //
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_RescueUpperCrustContacts')); // swarm mission grants you supplies
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_RescueFriendlyPolitician')); // swarm mission grants you res contact
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_StealSparkCore'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ItsAboutSendingAMessage'));


		return Techs;
	}
	static function X2DataTemplate CreateLeachPsionicLeylines()
	{
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_LeachPsionicLeylines');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateLeach;
		Template.OnDeactivatedFn = DeactivateLeach;
		Template.CanBeRemovedFn = CanHiddenReservesBeRemoved;
		//todo: Chryssalid/Faceless buff
		return Template;
	}
//---------------------------------------------------------------------------------------
static function ActivateLeach(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);

	// Add a research bonus for each lab already created, then set the flag so it will work for all future labs built
	XComHQ.BonusPowerProduced += default.LEACH_PSIONIC_LEYLINES_POWER_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function DeactivateLeach(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.BonusPowerProduced -= default.LEACH_PSIONIC_LEYLINES_POWER_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}

	static function X2DataTemplate CreateXenobiologicalFieldResearch()
	{
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_XenobiologicalFieldResearch');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateXenobiology;
		Template.OnDeactivatedFn = DeactivateXenobiology;
		Template.GetAbilitiesToGrantFn = GrantXenobiologyChryssalidAndFacelessBuff;
		return Template;
	}
//---------------------------------------------------------------------------------------
static function ActivateXenobiology(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);

	// Add a research bonus for each lab already created, then set the flag so it will work for all future labs built
	XComHQ.ResearchEffectivenessPercentIncrease += default.XENO_FIELD_RESEARCH_RESEARCH_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}

	static function GrantXenobiologyChryssalidAndFacelessBuff(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{				
		local bool IsChryssalid;
		local bool IsFaceless;
		IsChryssalid = InStr(UnitState.GetMyTemplateName(), "Chryssalid") >= 0; 
		IsFaceless = InStr(UnitState.GetMyTemplateName(), "Faceless") >= 0;

		if (IsChryssalid || IsFaceless)
		{
			AbilitiesToGrant.AddItem( 'ILB_FasterSavages' ); 
		}
	}

//---------------------------------------------------------------------------------------
static function DeactivateXenobiology(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.ResearchEffectivenessPercentIncrease -= default.XENO_FIELD_RESEARCH_RESEARCH_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}

	static function X2DataTemplate CreateLabsToCommsRepurposing()
	{
		local X2StrategyCardTemplate Template;
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_LabToCommsRepurposing');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateLabsToComms;
		Template.OnDeactivatedFn = DeactivateLabsToComms;
		Template.CanBeRemovedFn = CanRemoveIncreasedResistanceContactsOrder;

		return Template;
}
//---------------------------------------------------------------------------------------
static function ActivateLabsToComms(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);

	// Add a research bonus for each lab already created, then set the flag so it will work for all future labs built
	XComHQ.ResearchEffectivenessPercentIncrease -= default.LABS_TO_COMMS_RESEARCH_PENALTY;
	XComHQ.BonusCommCapacity += default.LABS_TO_COMMS_COMMS_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function DeactivateLabsToComms(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.ResearchEffectivenessPercentIncrease += default.LABS_TO_COMMS_RESEARCH_PENALTY;
	XComHQ.BonusCommCapacity -= default.LABS_TO_COMMS_COMMS_BONUS;
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
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
	ResistanceHQ.SupplyDropPercentIncrease -= default.GRNDL_POWER_DEAL_SUPPLY_PENALTY;
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
	ResistanceHQ.SupplyDropPercentIncrease += default.GRNDL_POWER_DEAL_SUPPLY_PENALTY;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.PowerOutputBonus -= GetValueGrndlPowerCollection();

	XComHQ.DeterminePowerState();
	XComHQ.HandlePowerOrStaffingChange(NewGameState);
}
//---------------------------------------------------------------------------------------
static function int GetValueGrndlPowerCollection()
{
	return default.GRNDL_POWER_DEAL_POWER_BONUS;
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
	return default.NOTORIOUS_SMUGGLERS_BLACK_MARKET_DISCOUNT;
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
		ResistanceHQ.SupplyDropPercentIncrease += default.BRAZEN_COLLECTION_BONUS;
	}

	//---------------------------------------------------------------------------------------
	static function DeactivateBrazenCollection(XComGameState NewGameState, StateObjectReference InRef)
	{
		local XComGameState_HeadquartersResistance ResistanceHQ;

		ResistanceHQ = GetNewResHQState(NewGameState);
		ResistanceHQ.SupplyDropPercentIncrease -= default.BRAZEN_COLLECTION_BONUS;
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
	XComHQ.BonusCommCapacity += default.RADIO_FREE_LILY_COMMS_BONUS;
}
//---------------------------------------------------------------------------------------
static function DeactivateRadioFreeLily(XComGameState NewGameState, StateObjectReference InRef)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = GetNewXComHQState(NewGameState);
	XComHQ.BonusCommCapacity -= default.RADIO_FREE_LILY_COMMS_BONUS;
}

static function X2DataTemplate CreateBlankResistanceOrder(name OrderName)
{
	local X2StrategyCardTemplate Template;
		
	`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, OrderName);
	Template.Category = "ResistanceCard";
	`log("Created blank resistance order: "  $ OrderName);
	return Template; 
}


