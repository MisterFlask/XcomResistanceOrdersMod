class IRB_NewResistanceOrders_EventListeners extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	`log("Registering Events template: IRB_AdditionalResistanceOrders_ResCards");


	Templates.AddItem( AddListeners() );

	return Templates;
}

static protected function X2EventListenerTemplate AddListeners()
{
	local X2EventListenerTemplate Template;
	`log("Registering Events: IRB_AdditionalResistanceOrders_ResCards");

	`CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'KillTrackerListener');
	Template.AddEvent('ResearchCompleted', OnResearchCompleted);
	Template.RegisterInStrategy = true;

	`log("On research complete listener CREATED for IRB_AdditionalResistanceOrders_ResCards");

	return Template;
}


static function EventListenerReturn OnResearchCompleted(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameStateHistory History;
	local XComGameState_Tech TechState;
	local XComGameState_HeadquartersXCom XComHQ;
		
	`log("On research complete listener HIT for for IRB_AdditionalResistanceOrders_ResCards");

	if (GameState.GetContext().InterruptionStatus == eInterruptionStatus_Interrupt)
	{
		return ELR_NoInterrupt;
	}

	History = `XCOMHISTORY;
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	TechState = XComGameState_Tech(EventData); 
	if (TechState == none)
	{
		return ELR_NoInterrupt;
	}

	DuplicateRewardFromProjectIfResOrderEnabled('EXOSuit', 'ResCard_GrndlContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('SpiderSuit', 'ResCard_GlobalsecContacts', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WARSuit', 'ResCard_GrndlContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WraithSuit', 'ResCard_GlobalsecContacts',  TechState,GameState);

	DuplicateRewardFromProjectIfResOrderEnabled('ExperimentalAmmo', 'ResCard_GlobalsecContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('AdvancedGrenades', 'ResCard_GrndlContacts',  TechState,GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('HeavyWeapons', 'ResCard_ArgusSecurityContacts',  TechState,GameState);
	// advanced ammo
	// ADVENT datapad decryption: What should it grant?  Just additional intel?

	HandleHaasBioroidContacts(TechState.GetMyTemplateName(), TechState, GameState);

	return ELR_NoInterrupt;
}

public static function DuplicateRewardFromProjectIfResOrderEnabled(name TechName, name ResistanceOrderName, XComGameState_Tech Tech, XComGameState NewGameState){
	
	if (!IsResistanceOrderActive(ResistanceOrderName)){
		return;
	}

	if (Tech.GetMyTemplateName() != TechName){
		return;
	}
	`log("Tech matches duplicator resistance card, rerunning on tech complete function again");

	Tech.OnResearchCompleted(NewGameState);
}

public static function HandleHaasBioroidContacts(name TechName, XComGameState_Tech TechData, XComGameState GameState)
{
	if (!IsResistanceOrderActive('ResCard_HaasBioroidContacts')){
		return;
	}

	if (TechName == 'BuildSpark' || TechName == 'BuildExpSpark') // BuildExpSpark is from Mechatronic Warfare
	{
		`log("Creating additional spark as per resistance order.");
		class'X2StrategyElement_DLC_Day90Techs'.static.CreateSparkSoldier(GameState, TechData);
	}
	else if (TechName == 'MechanizedWarfare')
	{
		`log("Creating additional spark as per resistance order.");
		class'X2StrategyElement_DLC_Day90Techs'.static.CreateSparkSoldier(GameState, TechData); // MW creates spark soldier and equipment, but we don't have to create equipment twice.
	}
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

	History = `XCOMHISTORY;
	// go over each card active for each faction
	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		foreach FactionState.CardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0)
			{
				CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
				if (CardState.GetMyTemplateName() == ResistanceOrderName)
				{
					return true;
				}
			}
		}
	}

	return false;
}