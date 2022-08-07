class ILB_NewResistanceOrders_EventListeners extends X2EventListener config(ResCards) ;

var config int SOLDIER_COST_IN_SUPPLY;
var config int SOLDIER_COST_IN_SUPPLY_LWOTC;
var config int SPIDER_SUIT_INTEL_COST;
var config int EXO_SUIT_INTEL_COST;
var config int MEC_CORPSES_INTEL_COST;
var config int HAZMAT_VEST_INTEL_COST;
var config int PLATED_VEST_INTEL_COST;
var config int BRAZEN_RECRUITMENT_CHEAP_SOLDIER_COST;
var config int BRAZEN_RECRUITMENT_EXPENSIVE_SOLDIER_COST;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	`log("Registering Events template: ILB_AdditionalResistanceOrders_ResCards");


	Templates.AddItem( AddStrategyListeners() );
	Templates.AddItem( AddListenersForBlackMarketReset() ); // handling this via UI State Listener instead
	/// removing the black market listener ENTIRELY doesn't help anything; issue with ui state listener?
	return Templates;
}

static protected function X2EventListenerTemplate AddStrategyListeners()
{
	local CHEventListenerTemplate Template;
	`log("Registering Events: ILB_AdditionalResistanceOrders_ResCards");

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'ILB_ListenersForTech');
	Template.AddCHEvent('ResearchCompleted', OnResearchCompleted, ELD_Immediate, 99);
	Template.AddCHEvent('PostEndOfMonth', PostEndOfMonth, ELD_OnStateSubmitted, 99);
	Template.AddCHEvent('AllowActionToSpawnRandomly', AllowActionToSpawnRandomly, ELD_Immediate, 99);
	Template.AddCHEvent('StrategyMapMissionSiteSelected', StrategyMapMissionSiteSelected, ELD_Immediate, 99);
	Template.AddCHEvent('PreEndOfMonth', HandleResistanceOrders, ELD_Immediate, 99);

	Template.RegisterInStrategy = true;

	`log("On research complete listener CREATED for ILB_AdditionalResistanceOrders_ResCards");

	return Template;
}


static protected function EventListenerReturn StrategyMapMissionSiteSelected(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{

	local XComHQPresentationLayer HQPres;
	local UIMission MissionUI;
	local XComGameState_MissionSite MissionSite;

		
	MissionSite = XComGameState_MissionSite(EventSource);

	HQPres = `HQPRES;

	MissionUI = HQPres.Spawn(class'UIMission_ResCardCovertOpMission', HQPres);
	MissionUI.MissionRef = MissionSite.GetReference();
	HQPres.ScreenStack.Push(MissionUI);
	return ELR_NoInterrupt;
}

static function EventListenerReturn PostEndOfMonth(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding Covert Action To Geoscape Due To Res Card");
	
	`LOG("hit the post-end-of-month listener; adding necessary covert actions to all factions");
	
	AddCovertActionToFactionConditionalOnResCard(NewGameState, 'ILB_CovertAction_SpawnAiTheft', 'Faction_Skirmishers', 'ResCard_StealSparkCore');
	AddCovertActionToFactionConditionalOnResCard(NewGameState, 'ILB_CovertAction_ItsAboutSendingAMessage', 'Faction_Reapers', 'ResCard_ItsAboutSendingAMessage');
	AddCovertActionToFactionConditionalOnResCard(NewGameState, 'ILB_CovertAction_SwarmDefenseForSupplies', 'Faction_Templars', 'ResCard_RescueUpperCrustContacts');
	AddCovertActionToFactionConditionalOnResCard(NewGameState, 'ILB_CovertAction_SwarmDefenseForResistanceContact', 'Faction_Reapers', 'ResCard_RescueFriendlyPolitician');
	AddCovertActionToFactionConditionalOnResCard(NewGameState, 'ILB_CovertAction_CouncilBounties', 'Faction_Reapers', 'ResCard_CouncilBounties');

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;

}

static function EventListenerReturn AllowActionToSpawnRandomly(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local X2CovertActionTemplate Template;

	Tuple = XComLWTuple(EventData);
	Template = X2CovertActionTemplate(Tuple.Data[1].o);
	`LOG("Checking on if " $ Template.DataName $ " is disallowed from spawning randomly due to rule that nothing starting with ILB_ spawns randomly.");//todo: hack

	if (InStr(string(Template.DataName), "ILB_") != -1) //todo: this is a hack, but baaaasically suffices for our purposes
	{
		`LOG("Forbidding " $ Template.DataName $ " from spawning randomly due to rule that nothing starting with ILB_ spawns randomly.");//todo: hack
		Tuple.Data[0].b = false;
	}
}

static function AddCovertActionToFactionConditionalOnResCard(XComGameState GameState, name CovertActionName, name FactionName, name ResCardName)
{

	if (IsResistanceOrderActive(ResCardName)){

		class'DefaultCovertActions'.static.AddCovertActionToFaction(GameState, CovertActionName, FactionName);
	}


}

static protected function X2EventListenerTemplate AddListenersForBlackMarketReset()
{
	local CHEventListenerTemplate Template;
	`log("Registering Events: ILB_AdditionalResistanceOrders_ResCards");

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'ILB_ListenersForBlackMarket');
	Template.AddCHEvent('BlackMarketGoodsReset', SetStateFlagForScreenListener, ELD_Immediate, 99);
	Template.RegisterInStrategy = true;

	`log("On research complete listener CREATED for ILB_AdditionalResistanceOrders_ResCards");

	return Template;
}

static function EventListenerReturn SetStateFlagForScreenListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData){
	class'XComGameState_ILB_BlackMarketState'.static.HandleBlackMarketReset(GameState);
	return ELR_NoInterrupt;
}

static function EventListenerReturn OnResearchCompleted(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Tech TechState;
		
	`log("On research complete listener HIT for for ILB_AdditionalResistanceOrders_ResCards");

	TechState = XComGameState_Tech(EventData); 
	if (TechState == none)
	{
		`log("ERROR: TechState is NONE when tech complete listener is hit.");
		return ELR_NoInterrupt;
	}

	DuplicateRewardFromProjectIfResOrderEnabled('EXOSuit', 'ResCard_ExoSuitDoubling', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('SpiderSuit', 'ResCard_GlobalsecContacts', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WARSuit', 'ResCard_ExoSuitDoubling', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WraithSuit', 'ResCard_GlobalsecContacts',  TechState,GameState);

	DuplicateRewardFromProjectIfResOrderEnabled('ExperimentalAmmo', 'ResCard_ExperimentalAmmoDoubling', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('ExperimentalGrenade', 'ResCard_ExperimentalGrenadeDoubling',  TechState,GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('AdvancedGrenade', 'ResCard_ExperimentalGrenadeDoubling',  TechState,GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('HeavyWeapons', 'ResCard_ExperimentalHeavyWeaponDoubling',  TechState,GameState);
	// DuplicateRewardFromProjectIfResOrderEnabled('Skulljack', 'ResCard_Mindtaker',  TechState,GameState);
	// ADVENT datapad decryption: What should it grant?  Just additional intel?

	HandleHaasBioroidContacts(TechState.GetMyTemplateName(), TechState, GameState);

	return ELR_NoInterrupt;
}


/// NOTE: we perform retrieval of modifiable game state + submission in the caller of this method, not here.
static function EventListenerReturn BlackMarketResetListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (IsResistanceOrderActive('ResCard_SafetyFirst')){
		AddItemToBlackMarket('PlatedVest', 1, default.PLATED_VEST_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}
	
	if (IsResistanceOrderActive('ResCard_CleanupDetail')){
		AddItemToBlackMarket('HazmatVest', 1, default.HAZMAT_VEST_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}

	if(IsResistanceOrderActive('ResCard_SurpriseForSpiderOrWraithSuit')){
		AddItemToBlackMarket('LightPlatedArmor', 1, default.SPIDER_SUIT_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}
	
	if (IsResistanceOrderActive('ResCard_FirepowerForSparks')){
		AddItemToBlackMarket('CorpseAdventMEC', 2, default.MEC_CORPSES_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}

	if (IsResistanceOrderActive('ResCard_MachineBuffsIfAridClimate')){
		AddItemToBlackMarket('CorpseAdventMEC', 2, default.MEC_CORPSES_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}

	if (IsResistanceOrderActive('ResCard_BrazenRecruitment')){
		AddGeneratedSoldierToBlackMarket(EventData, EventSource, GameState, Event, CallbackData, default.BRAZEN_RECRUITMENT_CHEAP_SOLDIER_COST);
		//AddGeneratedSoldierToBlackMarket(EventData, EventSource, GameState, Event, CallbackData, default.BRAZEN_RECRUITMENT_EXPENSIVE_SOLDIER_COST);
	}
	
	if (IsResistanceOrderActive('ResCard_MeatMarket')){
		AddGeneratedSoldierToBlackMarket(EventData, EventSource, GameState, Event, CallbackData);
		AddGeneratedSoldierToBlackMarket(EventData, EventSource, GameState, Event, CallbackData);
		AddGeneratedSoldierToBlackMarket(EventData, EventSource, GameState, Event, CallbackData);
	}
	return ELR_NoInterrupt;
}

static function AddItemToBlackMarket(
		name ItemToAdd, int NumToAdd, int Price,
		Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData){
	local X2StrategyElementTemplateManager StratMgr;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_BlackMarket MarketState;
	local XComGameState_Reward RewardState;
	local X2RewardTemplate RewardTemplate;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local Commodity ForSaleItem;

	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	MarketState = XComGameState_BlackMarket(EventData);
	
	if (MarketState == none) return;

	// Get the latest pending state
	MarketState = XComGameState_BlackMarket(NewGameState.ModifyStateObject(class'XComGameState_BlackMarket', MarketState.ObjectID));

	// Create the item
	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemTemplateMgr.FindItemTemplate(ItemToAdd);
	ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Quantity = NumToAdd;
	
	// Create the reward
	StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Item'));
	RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);
	
	RewardState.SetReward(ItemState.GetReference());
	

	// Fill out the commodity (default)
	ForSaleItem.RewardRef = RewardState.GetReference();
	ForSaleItem.Image = RewardState.GetRewardImage();
	ForSaleItem.CostScalars = MarketState.GoodsCostScalars;
	ForSaleItem.DiscountPercent = MarketState.GoodsCostPercentDiscount;

	// Fill out the commodity (custom)
	ForSaleItem.Title = string(NumToAdd) $ " " $ ItemTemplate.GetItemFriendlyName();
	ForSaleItem.Desc = "Not generally available via the black market, but for a resourceful commander, such things are possible."; //todo: figure out localization
	ForSaleItem.Cost = GetForSaleItemCost(Price); 

	// Add to sale
	MarketState.ForSaleItems.AddItem(ForSaleItem);
	// We are done
	return;
}

	// base game cost is 70
	static function AddGeneratedSoldierToBlackMarket(
		Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData, optional int SoldierSupplyCostOverride = -1){
		local X2StrategyElementTemplateManager StratMgr;
		local XComGameState_BlackMarket MarketState;
		local XComGameState_Reward RewardState;
		local X2RewardTemplate RewardTemplate;
		local Commodity ForSaleItem;
		//local XComPhotographer_Strategy Photo;	

		//Photo = `GAME.StrategyPhotographer; //TODO: Compilation error with strategy photographer, can skip for now

		MarketState = XComGameState_BlackMarket(EventData);
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

		RewardTemplate = X2RewardTemplate(StratMgr.FindStrategyElementTemplate('Reward_Soldier'));
	
		// Get the latest pending state
		MarketState = XComGameState_BlackMarket(NewGameState.ModifyStateObject(class'XComGameState_BlackMarket', MarketState.ObjectID));

		// Only give the personnel reward if it is available for the player
		if (RewardTemplate.IsRewardAvailableFn == none || RewardTemplate.IsRewardAvailableFn())
		{
			RewardState = RewardTemplate.CreateInstanceFromTemplate(NewGameState);

			NewGameState.AddStateObject(RewardState); 

			RewardState.GenerateReward(NewGameState, , MarketState.Region);
			ForSaleItem.RewardRef = RewardState.GetReference();

			ForSaleItem.Title = RewardState.GetRewardString();
			if (SoldierSupplyCostOverride != -1){
				ForSaleItem.Cost = GetForSaleItemCostInSupply(SoldierSupplyCostOverride); 
			}
			else if (IsModActive('LongWarOfTheChosen')){
				ForSaleItem.Cost = GetForSaleItemCostInSupply(default.SOLDIER_COST_IN_SUPPLY_LWOTC); 
			}else{
				ForSaleItem.Cost = GetForSaleItemCostInSupply(default.SOLDIER_COST_IN_SUPPLY); 
			}


			ForSaleItem.Desc = "The Meat Market giveth; and the Meat Market taketh away.";
			ForSaleItem.Image = RewardState.GetRewardImage();
			ForSaleItem.CostScalars = class'XComGameState_BlackMarket'.default.GoodsCostScalars;
			ForSaleItem.DiscountPercent = class'XComGameState_BlackMarket'.default.GoodsCostPercentDiscount;

			/*if (ForSaleItem.Image == "")
			{
				if (!Photo.HasPendingHeadshot(RewardState.RewardObjectReference, OnUnitHeadCaptureFinished))
				{
					Photo.AddHeadshotRequest(RewardState.RewardObjectReference, 'UIPawnLocation_ArmoryPhoto', 'SoldierPicture_Head_Armory', 512, 512, OnUnitHeadCaptureFinished, class'X2StrategyElement_DefaultSoldierPersonalities'.static.Personality_ByTheBook());
				}
			}*///TODO: fix photo

			MarketState.ForSaleItems.AddItem(ForSaleItem);
		}
	}

	public static function DuplicateRewardFromProjectIfResOrderEnabled(name TechName, name ResistanceOrderName, XComGameState_Tech Tech, XComGameState NewGameState)
	{
	
		`Log("checking techname " $ TechName $ " against " $ Tech.GetMyTemplateName());
		if (Tech.GetMyTemplateName() != TechName){
			return;
		}

		`Log("checking techname " $ TechName $ " for res order " $ ResistanceOrderName);
		if (!IsResistanceOrderActive(ResistanceOrderName)){
			`Log("Resistance order inactive; bailing.  " $ ResistanceOrderName);
			return;
		}

		`log("Tech matches duplicator resistance card, rerunning on-tech-complete function again");
		Tech.OnResearchCompleted(NewGameState);

		// IS THIS CORRECT?
		// If I don't have this here it looks like the extra rewards for the tech just don't get added.
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}

public static function HandleHaasBioroidContacts(name TechName, XComGameState_Tech TechData, XComGameState GameState)
{
	if (TechName != 'BuildSpark' && TechName != 'MechanizedWarfare'){
		return;
	}

	if (!IsResistanceOrderActive('ResCard_HaasBioroidContacts')){
		return;
	}

	`log("Creating additional spark as per resistance order.");
	class'X2StrategyElement_DLC_Day90Techs'.static.CreateSparkSoldier(GameState, TechData);
}

static private function bool IsModActive(name DLCName)
{
    local XComOnlineEventMgr    EventManager;
    local int                    Index;

    EventManager = `ONLINEEVENTMGR;

    for(Index = EventManager.GetNumDLC() - 1; Index >= 0; Index--)    
    {
        if(EventManager.GetDLCNames(Index) == DLCName)    
        {
			`LOG("Mod IS active: "$ DLCName);
            return true;
        }
    }
	`LOG("Mod IS NOT active: "$ DLCName);
    return false;
}

static function int NumReaperCardsActive(){
	return NumCardsActiveOfFaction('Faction_Reapers');
}
static function int NumTemplarCardsActive(){
	return NumCardsActiveOfFaction('Faction_Templars');
}
static function int NumSkirmisherCardsActive(){
	return NumCardsActiveOfFaction('Faction_Skirmishers');
}

static function int NumCardsActiveOfFaction(name FactionName){
	local XComGameState_StrategyCard CardState;
	local StateObjectReference CardRef;
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local int FactionCardsFound;
	
	local XComGameState_HeadquartersResistance ResHQ;

	FactionCardsFound=0;
	History = `XCOMHISTORY;
	`Log("Checking over every single resistance faction to see if it's the one we want; looking for: " $ FactionName);
	// go over each card active for each faction
	
	ResHQ = GetResistanceHQ();

	// First, going over faction-agnostic card slots
	foreach ResHQ.WildCardSlots(CardRef)
	{
		if(CardRef.ObjectID != 0)
		{
			CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
			if (CardState.GetMyTemplate().AssociatedEntity == FactionName){
				FactionCardsFound++;
			}
		}
	}

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		`Log("Checking over every single order in this faction to see if it's the one we want: " $ FactionState.GetMyTemplateName());

		// for each faction checking each card slot in turn
		foreach FactionState.CardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0)
			{
				CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
				if (CardState.GetMyTemplate().AssociatedEntity == FactionName){
					FactionCardsFound++;
				}
			}
		}
	}
	`Log("Discovered quantity of cards for faction: " $ FactionName $ " : " $ FactionCardsFound);
	return FactionCardsFound;
}

static function bool IsResistanceOrderActive(name ResistanceOrderName){
	local XComGameState_StrategyCard CardState;
	local StateObjectReference CardRef;
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_Continent ContinentState;
	
	local XComGameState_HeadquartersResistance ResHQ;
	History = `XCOMHISTORY;
	//`Log("Checking over every single resistance order to see if it's the one we want; looking for: " $ ResistanceOrderName);
	// go over each card active for each faction
	
	ResHQ = GetResistanceHQ();

	// First, going over faction-agnostic card slots
	foreach ResHQ.WildCardSlots(CardRef)
	{
		if(CardRef.ObjectID != 0)
		{
			CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
			if (CardState.GetMyTemplateName() == ResistanceOrderName)
			{
				`Log("This card IS the card I want: " $ CardState.GetMyTemplateName() );
				return true;
			}
			else
			{
				//`Log("This faction order is NOT the one I want: " $ CardState.GetMyTemplateName());
			}
		}
	}

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		//`Log("Checking over every single order in this faction to see if it's the one we want: " $ FactionState.GetMyTemplateName());

		// for each faction checking each card slot in turn
		foreach FactionState.CardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0)
			{
				CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
				if (CardState.GetMyTemplateName() == ResistanceOrderName)
				{
					`Log("This card IS the card I want: " $ CardState.GetMyTemplateName() );
					return true;
				}
				else
				{
					//`Log("This faction order is NOT the one I want: " $ FactionState.GetMyTemplateName());

				}
			}
		}
	}

	`LOG("Going over continent bonuses.");

	// go over continent bonuses
	foreach History.IterateByClassType(class'XComGameState_Continent', ContinentState){
		CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(ContinentState.ContinentBonusCard.ObjectID));
		if (CardState == none){
			`LOG("Couldn't find continent bonus for object id!");
		}
        `LOG("observed possible continent bonus: " $ CardState.GetMyTemplateName());

		if (CardState.GetMyTemplateName() == ResistanceOrderName){
			if (ContinentState.bContinentBonusActive){
				`LOG("successfully found targeted card as ACTIVE continent bonus: " $ ResistanceOrderName);
				return true;
			} else {
				`LOG("observed targeted card as INACTIVE continent bonus: " $ ResistanceOrderName);
			}
		}
	}

	
	return false;
}


static function XComGameState_HeadquartersResistance GetResistanceHQ()
{
	return XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
}

static function StrategyCost GetForSaleItemCost(int IntelAmount)
{
	local StrategyCost Cost;
	local ArtifactCost ResourceCost;
	
	ResourceCost.ItemTemplateName = 'Intel';
	ResourceCost.Quantity = IntelAmount;
	Cost.ResourceCosts.AddItem(ResourceCost);

	return Cost;
}
static function StrategyCost GetForSaleItemCostInSupply(int SupplyCost)
{
	local StrategyCost Cost;
	local ArtifactCost ResourceCost;
	
	ResourceCost.ItemTemplateName = 'Supplies';
	ResourceCost.Quantity = SupplyCost;
	Cost.ResourceCosts.AddItem(ResourceCost);

	return Cost;
}


//Disable and return all consumable cards
static function EventListenerReturn HandleResistanceOrders(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID, Object CallbackData)
{
	local XComGameState_StrategyCard CardState;
	local XComGameState_HeadquartersResistance ResHQ;
	local StateObjectReference WildCardRef, FactionRef;
	local int i;
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> RemovedWildCards;

	
	ResHQ = class'UIUtilities_Strategy'.static.GetResistanceHQ();
	ResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', ResHQ.ObjectID));


	for(i=0; i< ResHQ.WildCardSlots.Length; i++)
	{
		if(ResHQ.WildCardSlots[i].ObjectID != 0)
		{
			CardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', ResHQ.WildCardSlots[i].ObjectID));

			if(class'X2EventListener_Strategy'.default.CONSUMABLE_RESISTANCE_ORDERS.Find(CardState.GetMyTemplateName()) != INDEX_NONE){

				RemovedWildCards.AddItem(ResHQ.WildCardSlots[i]);
				ResHQ.RemoveCardFromSlot(i);
				CardState.bDrawn = false;
			}
		}
	}


	foreach ResHq.Factions(FactionRef)
	{
		FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionRef.ObjectID));
		for(i=0; i< FactionState.CardSlots.Length; i++) 
		{
			if(FactionState.CardSlots[i].ObjectID != 0)
			{
				CardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', ResHQ.WildCardSlots[i].ObjectID));

				if(class'X2EventListener_Strategy'.default.CONSUMABLE_RESISTANCE_ORDERS.Find(CardState.GetMyTemplateName()) != INDEX_NONE)
				{
					FactionState.RemoveCardFromSlot(i);
					CardState.bDrawn = false;
				}
			}
		}
		// All "Available" card data is saved in faction states, so to remove wild cards properly we need to find them there
		foreach RemovedWildCards(WildCardRef)
		{
			for (i = FactionState.PlayableCards.Length -1; i >= 0; i--)
			{
				if(FactionState.PlayableCards[i].ObjectID == WildCardRef.ObjectID)
				{
					FactionState.PlayableCards.RemoveItem(FactionState.PlayableCards[i]);
				}
			}
		}
	}

	ResHQ.DeactivateRemovedCards(NewGameState);

	return ELR_NoInterrupt;
}
