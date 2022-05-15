class IRB_NewResistanceOrders_EventListeners extends X2EventListener config(ResCards) ;

var config int SOLDIER_COST_IN_SUPPLY;
var config int SPIDER_SUIT_INTEL_COST;
var config int EXO_SUIT_INTEL_COST;
var config int FIVE_MEC_CORPSES_INTEL_COST;
var config int HAZMAT_VEST_INTEL_COST;
var config int PLATED_VEST_INTEL_COST;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	`log("Registering Events template: IRB_AdditionalResistanceOrders_ResCards");


	Templates.AddItem( AddListenersForTech() );
	Templates.AddItem( AddListenersForBlackMarketReset() ); // handling this via UI State Listener instead

	return Templates;
}

static protected function X2EventListenerTemplate AddListenersForTech()
{
	local CHEventListenerTemplate Template;
	`log("Registering Events: IRB_AdditionalResistanceOrders_ResCards");

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'ILB_ListenersForTech');
	Template.AddCHEvent('ResearchCompleted', OnResearchCompleted, ELD_Immediate, 99);
	Template.RegisterInStrategy = true;

	`log("On research complete listener CREATED for IRB_AdditionalResistanceOrders_ResCards");

	return Template;
}

static protected function X2EventListenerTemplate AddListenersForBlackMarketReset()
{
	local CHEventListenerTemplate Template;
	`log("Registering Events: IRB_AdditionalResistanceOrders_ResCards");

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'ILB_ListenersForBlackMarket');
	Template.AddCHEvent('BlackMarketGoodsReset', SetStateFlagForScreenListener, ELD_Immediate, 99);
	Template.RegisterInStrategy = true;

	`log("On research complete listener CREATED for IRB_AdditionalResistanceOrders_ResCards");

	return Template;
}

static function EventListenerReturn SetStateFlagForScreenListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData){
	class'XComGameState_ILB_BlackMarketState'.static.HandleBlackMarketReset(GameState);
	return ELR_NoInterrupt;
}

static function EventListenerReturn OnResearchCompleted(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;
	local XComGameState_HeadquartersXCom XComHQ;
		
	`log("On research complete listener HIT for for IRB_AdditionalResistanceOrders_ResCards");

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
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
	// ADVENT datapad decryption: What should it grant?  Just additional intel?

	HandleHaasBioroidContacts(TechState.GetMyTemplateName(), TechState, GameState);

	return ELR_NoInterrupt;
}

static function EventListenerReturn BlackMarketResetListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (IsResistanceOrderActive('ResCard_SafetyFirst')){
		AddItemToBlackMarket('PlatedVest', 1, default.PLATED_VEST_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}
	
	if (IsResistanceOrderActive('ResCard_CleanupDetail')){
		AddItemToBlackMarket('HazmatVest', 1, default.HAZMAT_VEST_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}
	
	if (IsResistanceOrderActive('ResCard_HaasBioroidContacts')){
		AddItemToBlackMarket('CorpseAdventMEC', 5, default.FIVE_MEC_CORPSES_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
	}

	if(IsResistanceOrderActive('ResCard_SurpriseForSpiderOrWraithSuit')){
		AddItemToBlackMarket('LightPlatedArmor', 1, default.SPIDER_SUIT_INTEL_COST, EventData, EventSource, GameState, Event, CallbackData);
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
		Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData){
		local X2StrategyElementTemplateManager StratMgr;
		local X2ItemTemplateManager ItemTemplateMgr;
		local XComGameState_BlackMarket MarketState;
		local XComGameState_Reward RewardState;
		local X2RewardTemplate RewardTemplate;
		local XComGameState_Item ItemState;
		local X2ItemTemplate ItemTemplate;
		local Commodity ForSaleItem;
		local int AdditionalSoldierDiscount;
		//local XComPhotographer_Strategy Photo;	

		//Photo = `GAME.StrategyPhotographer; //TODO: Compilation error with strategy photographer, can skip for now

		AdditionalSoldierDiscount = 20;
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
			ForSaleItem.Cost = GetForSaleItemCostInSupply(default.SOLDIER_COST_IN_SUPPLY); // todo: move this to config
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

static function bool IsResistanceOrderActive(name ResistanceOrderName){
	local XComGameState_StrategyCard CardState;
	local StateObjectReference CardRef;
	local bool bCardPlayed;
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState NewGameState;
	local array<Name> ExclusionList;
	local int NumActionsToAdd;
	
	local XComGameState_HeadquartersResistance ResHQ;
	History = `XCOMHISTORY;
	`Log("Checking over every single resistance order to see if it's the one we want; looking for: " $ ResistanceOrderName);
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
				`Log("This faction order is NOT the one I want: " $ FactionState.GetMyTemplateName());
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
				if (CardState.GetMyTemplateName() == ResistanceOrderName)
				{
					`Log("This card IS the card I want: " $ CardState.GetMyTemplateName() );
					return true;
				}
				else
				{
					`Log("This faction order is NOT the one I want: " $ FactionState.GetMyTemplateName());

				}
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