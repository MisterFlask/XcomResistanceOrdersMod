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

static function GenerateSupplyReward(){
//https://github.com/Lucubration/XCOM2/blob/a24366aafaa50421c8cb2648b563e452c6717902/TestModWotc/TestModWotc/Src/XComGame/Classes/X2StrategyElement_DefaultTechs.uc
}


//EVENT CARDS

// intel for breakthroughs
// supply for killing chosen
// elereum cores and shards from killing facilities
// Alien Collection: knocking out and abducting Sectoids, Sneks gains supply.
// ADVENT Collection: knocking out and abducting ADVENT gains supply
// Interrogator feat; also Skulljacks grant +2 melee damage

/////// Covert Infiltration
// 1-2 new guaranteed ADVENT smash n grab missions per month [LOOTERS]
// 1 guaranteed new SPARK heist event chain per month (if one is not in progress)

// X2Effect_SpawnGhost 



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

	DuplicateRewardFromProjectIfResOrderEnabled('EXOSuit', 'ResCard_GrndlContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('SpiderSuit', 'ResCard_GlobalsecContacts', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WARSuit', 'ResCard_GrndlContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('WraithSuit', 'ResCard_GlobalsecContacts',  TechState,GameState);

	DuplicateRewardFromProjectIfResOrderEnabled('ExperimentalAmmo', 'ResCard_GlobalsecContactsII', TechState, GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('AdvancedGrenades', 'ResCard_GrndlContacts',  TechState,GameState);
	DuplicateRewardFromProjectIfResOrderEnabled('HeavyWeapons', 'ResCard_ArgusSecurityContacts',  TechState,GameState);
	// ADVENT datapad decryption: What should it grant?  Just additional intel?

	HandleHaasBioroidContacts(TechState.GetMyTemplateName(), TechState, GameState);

	return ELR_NoInterrupt;
}

public static function DuplicateRewardFromProjectIfResOrderEnabled(name TechName, name ResistanceOrderName, XComGameState_Tech Tech, XComGameState NewGameState){
	
	`Log("checking techname " $ TechName $ " against " $ Tech.GetMyTemplateName());
	if (Tech.GetMyTemplateName() != TechName){
		return;
	}

	`Log("checking techname " $ TechName $ " for res order " $ ResistanceOrderName);
	if (!IsResistanceOrderActive(ResistanceOrderName)){
		`Log("Resistance order inactive; bailing.  " $ ResistanceOrderName);
		return;
	}

	`log("Tech matches duplicator resistance card, rerunning on tech complete function again");
	Tech.OnResearchCompleted(NewGameState);

	// IS THIS CORRECT?
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

public static function HandleHaasBioroidContacts(name TechName, XComGameState_Tech TechData, XComGameState GameState)
{
	if (!IsResistanceOrderActive('ResCard_HaasBioroidContacts')){
		return;
	}

	if (TechName == 'BuildSpark' || TechName == 'MechanizedWarfare') //TODO: BuildExpSpark is from Mechatronic Warfare; figure out how to integrate without dependency?
	{
		`log("Creating additional spark as per resistance order.");
		class'X2StrategyElement_DLC_Day90Techs'.static.CreateSparkSoldier(GameState, TechData);
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
	
	local XComGameState_HeadquartersResistance ResHQ;
	History = `XCOMHISTORY;
	`Log("Checking over every single resistance order to see if it's the one we want; looking for: " $ ResistanceOrderName);
	// go over each card active for each faction
	
	ResHQ = GetResistanceHQ();

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