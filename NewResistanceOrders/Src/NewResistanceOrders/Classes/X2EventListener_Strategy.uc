class X2EventListener_Strategy extends X2EventListener config(ResCards);

var config array<name> CONSUMABLE_RESISTANCE_ORDERS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateXComHQListeners());

	return Templates;
}


static function CHEventListenerTemplate CreateXComHQListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'XComHQListeners');

	Template.AddCHEvent('PreEndOfMonth', HandleResistanceOrders, ELD_Immediate, 90);
	Template.RegisterInStrategy = true;

	return Template;
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

			if(default.CONSUMABLE_RESISTANCE_ORDERS.Find(CardState.GetMyTemplateName()) != INDEX_NONE){

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

				if(default.CONSUMABLE_RESISTANCE_ORDERS.Find(CardState.GetMyTemplateName()) != INDEX_NONE)
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
