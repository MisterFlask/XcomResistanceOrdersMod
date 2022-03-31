// This is an Unreal Script

class IRB_AdditionalResistanceOrders_ResCards extends X2StrategyElement;

	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards");
		Techs.AddItem(CreateHostileWildernessTemplate());
		return Techs;
	}

	static function X2DataTemplate CreateHostileWildernessTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_HostileWilderness');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHostileWildernessBuff;
		return Template; 
	}

	static function GrantHostileWildernessBuff(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		AbilitiesToGrant.AddItem( 'HostileWilderness_Buff' ); // this will apply a debuff to the robot
	}

	static function XComGameState_StrategyCard GetCardState(StateObjectReference CardRef)
	{
		return XComGameState_StrategyCard(`XCOMHISTORY.GetGameStateForObjectID(CardRef.ObjectID));
	}

	//---------------------------------------------------------------------------------------
	static function string GetSummaryTextReplaceInt(StateObjectReference InRef)
	{
		local XComGameState_StrategyCard CardState;
		local X2StrategyCardTemplate CardTemplate;
		local XGParamTag ParamTag;

		CardState = GetCardState(InRef);

		if(CardState == none)
		{
			return "Error in GetSummaryText function";
		}

		CardTemplate = CardState.GetMyTemplate();
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		ParamTag.IntValue0 = CardTemplate.GetMutatorValueFn();
		return `XEXPAND.ExpandString(CardTemplate.SummaryText);
	}
	//---------------------------------------------------------------------------------------
	static function AddSoldierUnlock(XComGameState NewGameState, name UnlockTemplateName)
	{
		local XComGameState_HeadquartersXCom XComHQ;
		local X2StrategyElementTemplateManager StratMgr;
		local X2SoldierUnlockTemplate UnlockTemplate;

		XComHQ = GetNewXComHQState(NewGameState);
		StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
		UnlockTemplate = X2SoldierUnlockTemplate(StratMgr.FindStrategyElementTemplate(UnlockTemplateName));

		if(UnlockTemplate != none)
		{
			XComHQ.AddSoldierUnlockTemplate(NewGameState, UnlockTemplate, true);
		}
	}
	//---------------------------------------------------------------------------------------
	static function RemoveSoldierUnlock(XComGameState NewGameState, name UnlockTemplateName)
	{
		local XComGameState_HeadquartersXCom XComHQ;

		XComHQ = GetNewXComHQState(NewGameState);
		XComHQ.RemoveSoldierUnlockTemplate(UnlockTemplateName);
	}

	static function XComTeamSoldierSpawnTacticalStartModifier(name CharTemplateName, XComGameState StartState)
	{
		local X2CharacterTemplate Template;
		local XComGameState_Unit SoldierState;
		local XGCharacterGenerator CharacterGenerator;
		local XComGameState_Player PlayerState;
		local TSoldier Soldier;
		local XComGameState_HeadquartersXCom XComHQ;

		// generate a basic resistance soldier unit
		Template = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate( CharTemplateName );
		`assert(Template != none);

		SoldierState = Template.CreateInstanceFromTemplate(StartState);
		SoldierState.bMissionProvided = true;

		if (Template.bAppearanceDefinesPawn)
		{
			CharacterGenerator = `XCOMGRI.Spawn(Template.CharacterGeneratorClass);
			`assert(CharacterGenerator != none);

			Soldier = CharacterGenerator.CreateTSoldier( );
			SoldierState.SetTAppearance( Soldier.kAppearance );
			SoldierState.SetCharacterName( Soldier.strFirstName, Soldier.strLastName, Soldier.strNickName );
			SoldierState.SetCountry( Soldier.nmCountry );
		}

		// assign the player to him
		foreach StartState.IterateByClassType(class'XComGameState_Player', PlayerState)
		{
			if(PlayerState.GetTeam() == eTeam_XCom)
			{
				SoldierState.SetControllingPlayer(PlayerState.GetReference());
				break;
			}
		}

		// give him a loadout
		SoldierState.ApplyInventoryLoadout(StartState);

		foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
			break;

		XComHQ.Squad.AddItem( SoldierState.GetReference() );
		XComHQ.AllSquads[0].SquadMembers.AddItem( SoldierState.GetReference() );
	}

	static function bool IsSplitMission( XComGameState StartState )
	{
		local XComGameState_BattleData BattleData;

		foreach StartState.IterateByClassType( class'XComGameState_BattleData', BattleData )
			break;

		return (BattleData != none) && BattleData.DirectTransferInfo.IsDirectMissionTransfer;
	}

	static function DeactivateAllCardsNotInPlay(XComGameState NewGameState)
	{
		local XComGameStateHistory History;
		local XComGameState_HeadquartersResistance ResHQ;
		local XComGameState_ResistanceFaction FactionState;
		local XComGameState_StrategyCard CardState;
		local array<StateObjectReference> AllOldCards, AllNewCards;
		local StateObjectReference CardRef;
		local int idx;

		History = `XCOMHISTORY;
		AllOldCards.Length = 0;
		AllNewCards.Length = 0;
		ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));

		// Grab all old and new cards
		foreach ResHQ.OldWildCardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0 && AllOldCards.Find('ObjectID', CardRef.ObjectID) == INDEX_NONE)
			{
				AllOldCards.AddItem(CardRef);
			}
		}

		foreach ResHQ.WildCardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0 && AllNewCards.Find('ObjectID', CardRef.ObjectID) == INDEX_NONE)
			{
				AllNewCards.AddItem(CardRef);
			}
		}

		foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
		{
			foreach FactionState.OldCardSlots(CardRef)
			{
				if(CardRef.ObjectID != 0 && AllOldCards.Find('ObjectID', CardRef.ObjectID) == INDEX_NONE)
				{
					AllOldCards.AddItem(CardRef);
				}
			}

			foreach FactionState.CardSlots(CardRef)
			{
				if(CardRef.ObjectID != 0 && AllNewCards.Find('ObjectID', CardRef.ObjectID) == INDEX_NONE)
				{
					AllNewCards.AddItem(CardRef);
				}
			}
		}

		// Find old cards that are not in the new list
		for(idx = 0; idx < AllOldCards.Length; idx++)
		{
			if(AllNewCards.Find('ObjectID', AllOldCards[idx].ObjectID) != INDEX_NONE)
			{
				AllOldCards.Remove(idx, 1);
				idx--;
			}
		}

		// Deactivate old cards
		foreach AllOldCards(CardRef)
		{
			CardState = XComGameState_StrategyCard(NewGameState.ModifyStateObject(class'XComGameState_StrategyCard', CardRef.ObjectID));
			CardState.DeactivateCard(NewGameState);
		}
	}
	

	static function bool IsCardInPlay(XComGameState_StrategyCard CardState)
	{
		local XComGameStateHistory History;
		local XComGameState_HeadquartersResistance ResHQ;
		local XComGameState_ResistanceFaction FactionState;

		History = `XCOMHISTORY;
		ResHQ = XComGameState_HeadquartersResistance(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));


		if(ResHQ.WildCardSlots.Find('ObjectID', CardState.ObjectID) != INDEX_NONE)
		{
			return true;
		}

		foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
		{
			if(FactionState.CardSlots.Find('ObjectID', CardState.ObjectID) != INDEX_NONE)
			{
				return true;
			}
		}

		return false;
	}
	
//#############################################################################################
//----------------   HELPER FUNCTIONS  --------------------------------------------------------
//#############################################################################################

static function XComGameState_HeadquartersXCom GetNewXComHQState(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom NewXComHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', NewXComHQ)
	{
		break;
	}

	if (NewXComHQ == none)
	{
		NewXComHQ = XComGameState_HeadquartersXCom(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		NewXComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', NewXComHQ.ObjectID));
	}

	return NewXComHQ;
}

static function XComGameState_HeadquartersResistance GetNewResHQState(XComGameState NewGameState)
{
	local XComGameState_HeadquartersResistance NewResHQ;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersResistance', NewResHQ)
	{
		break;
	}

	if (NewResHQ == none)
	{
		NewResHQ = XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
		NewResHQ = XComGameState_HeadquartersResistance(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersResistance', NewResHQ.ObjectID));
	}

	return NewResHQ;
}

static function XComGameState_BlackMarket GetNewBlackMarketState(XComGameState NewGameState)
{ 
	local XComGameState_BlackMarket NewBlackMarket; 

	foreach NewGameState.IterateByClassType(class'XComGameState_BlackMarket', NewBlackMarket)
	{
		break;
	}

	if (NewBlackMarket == none)
	{
		NewBlackMarket = XComGameState_BlackMarket(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BlackMarket'));
		NewBlackMarket = XComGameState_BlackMarket(NewGameState.ModifyStateObject(class'XComGameState_BlackMarket', NewBlackMarket.ObjectID));
	}

	return NewBlackMarket;
}