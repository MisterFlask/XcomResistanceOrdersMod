// This is an Unreal Script

class IRB_AdditionalResistanceOrders_ResCards extends X2StrategyElement;

	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards");
		Techs.AddItem(CreateTunnelRatsTemplate());
		return Techs;
	}
	
	//////// TUNNEL RATS
	static function X2DataTemplate CreateTunnelRatsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_TunnelRats');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantTunnelRatsBuff;
		return Template; 
	}

	static function GrantTunnelRatsBuff(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (IsPlotType("Tunnels_Sewer") || IsPlotType("Tunnels_Subway"))
		{	
			AbilitiesToGrant.AddItem( 'Phantom' ); 
		}
	}
	//////// FLASHPOINTS
	static function X2DataTemplate CreateFlashpointForGrenadiersTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_FlashpointForGrenadiers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantFlashpointBuffIfLauncher;
		return Template; 
	}

	static function GrantFlashpointBuffIfLauncher(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (DoesSoldierHaveItem(UnitState, 'GrenadeLauncher')){
			AbilitiesToGrant.AddItem( 'GrimyFlashpoint' ); 
		}
	}
	
	//////// HEXHUNTER
	static function X2DataTemplate CreateHexhunterForMindshieldsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_HexHunterForMindShields');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHexhunterIfMindshield;
		return Template; 
	}
	

	static function GrantHexhunterIfMindshield(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if(DoesSoldierHaveMindShield(UnitState))
		{
			AbilitiesToGrant.AddItem( 'GrimyHexHunter' ); 
		}
	}

	//////// NEEDLEPOINTS
	static function X2DataTemplate CreateNeedlepointBuffForPistolTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_NeedlepointForPistols');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantNeedlepointBuffIfPistol;
		return Template; 
	}

	static function GrantNeedlepointBuffIfPistol(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (SoldierHasPistol(UnitState))
		{
			AbilitiesToGrant.AddItem( 'GrimyNeedlePointPassive' ); 
		}
	}

	///antimemetic scales
	static function X2DataTemplate CreateAntimimeticScalesForVestsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AntimimeticScalesForVests);
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantAntimemeticBuffsIfVest;
		return Template; 
	}

	static function GrantAntimemeticBuffsIfVest(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (DoesSoldierHaveNanoscaleVest(UnitState))
		{
			AbilitiesToGrant.AddItem( 'Phantom' );
			AbilitiesToGrant.AddItem( 'Shadowstep' ); 
		}
	}

	// multitasking for gremlins
	static function X2DataTemplate CreateMultitaskingForGremlinsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_MultitaskingForGremlins');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantMultitaskingIfGremlin;
		return Template; 
	}

	static function  GrantMultitaskingIfGremlin(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin'))
		{
			AbilitiesToGrant.AddItem( 'Multitasking' );
		}
	}

	// smoker for launchers
	static function X2DataTemplate CreateSmokerForLaunchersTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SmokerForLaunchers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantSmokerIfLauncher;
		return Template; 
	}

	static function GrantSmokerIfLauncher(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'grenade_launcher'))
		{
			AbilitiesToGrant.AddItem( 'ShadowOps_SmokeAndMirrors_LW2' );
		}
	}
	
	// combat drugs
	static function X2DataTemplate CreateCombatDrugsForMedikitTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_CombatDrugsForMedikit');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantCombatDrugsIfMedikit;
		return Template; 
	}
	// pistol grants ShadowOps_Entrench

	static function GrantCombatDrugsIfMedikit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if(DoesSoldierHaveSpecificItem('Medikit'))
		{
			AbilitiesToGrant.AddItem( 'ShadowOps_CombatDrugs' );
		}
	}

	// combat drugs
	static function X2DataTemplate CreateCombatDrugsForMedikitTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_CombatDrugsForMedikit');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantCombatDrugsIfMedikit;
		return Template; 
	}

	static function GrantCombatDrugsIfMedikit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if(DoesSoldierHaveSpecificItem('Medikit'))
		{
			AbilitiesToGrant.AddItem( 'ShadowOps_CombatDrugs' );
		}
	}

	// pocket flamer for cannons
	static function X2DataTemplate CreatePocketFlamerForCannonsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_FlamerForCannon');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantPocketFlamerIfCannon;
		return Template; 
	}

	static function GrantPocketFlamerIfCannon(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'cannon')){
			AbilitiesToGrant.AddItem( 'PocketFlamer' );
		}
	}

	// battlespace for battle scanners
	static function X2DataTemplate CreateBattleSpaceForBattleScannersTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BattlespaceForBattleScanners');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantBattleSpaceIfBattleScanner;
		return Template; 
	}

	static function GrantBattleSpaceIfBattleScanner(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if(DoesSoldierHaveSpecificItem('Battlescanner'))
		{
			AbilitiesToGrant.AddItem( 'Battlespace' );
		}
	}

	//Lacerate for swords/knives

	// gain rocketeer if you're wearing heavy armor
	//ShadowOps_Rocketeer
	// Take Under for swords/knivese
	// sniper rifles gain Bullfighter
	// sniper/vektor rifles gain Anatomy
	// skulljacks gain Interrogator
	// pistols gain Entrench
	//ShadowOps_NoiseMaker granted to GREMLINs.
	// ShadowOps_Tracking granted to Battle Scanners.
	// wraith/spider suits grant Surprise.
	// grenade launcher grants F_WatchThemRun
	// cannons grant F_Havoc
	// TODO:  static function IsSoldierASpark(XComGameState_Unit UnitState){
	// TODO:  TargetUnit must be Robotic
	// !TargetUnit.IsRobotic()
	// TODO:  Add check for xcom soldier
	// Create spark with time and supplies, no other resources (Weyland-Yutani contacts)
	// Convert supplies + time in proving grounds into Elereum Cores
	// Convert supplies + time in proving grounds into Elereum Shards
	
	static function DoesSoldierHaveRocketLauncher(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'RocketLauncher');
	}

	static function DoesSoldierHaveGremlin(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin');
	}

	static function DoesSoldierHaveSword(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sword') || DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'combatknife');
	}

	static function DoesSoldierHaveMindShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'psidefense');
	}

	static function DoesSoldierHaveNanoscaleVest(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'NanofiberVest');
	}

	static function DoesSoldierHaveShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'shield');
	}
	
	static function DoesSoldierHavePistol(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'pistol');
	}

	static function DoesSoldierHaveSpecificItem(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local XComGameState_Unit UnitState;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name ItemCat;
		UnitState = XComGameState_Unit(InTrack.StateObject_NewState);
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{
				// check item's type
				ItemCat =  ItemState.GetMyTemplate().DataName;
				if (ItemCat == Classification){
					return true;
				}
			}
		}
		return false;
	}

	static function DoesSoldierHaveItemOfWeaponOrItemClass(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local XComGameState_Unit UnitState;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name WeaponCat;
		local name ItemCat;
		UnitState = XComGameState_Unit(InTrack.StateObject_NewState);
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{
				WeaponCat=ItemState.GetWeaponCategory();
				// check item's type
				if (WeaponCat == Classification){
					return true;
				}

				ItemCat = ItemState.GetMyTemplate().ItemCat;
				if (ItemCat == Classification){
					return true;
				}
			}
		}
		return false;
	}

	static function DoesSoldierHaveItem(XComGameState_Unit UnitState, name ItemName)
	{
		return UnitState.HasItemOfTemplateType(ItemName);
	}

	static function XComGameState_StrategyCard GetCardState(StateObjectReference CardRef)
	{
		return XComGameState_StrategyCard(`XCOMHISTORY.GetGameStateForObjectID(CardRef.ObjectID));
	}

	//---------------------------------------------------------------------------------------


	static function bool IsPlotType(string plotTypeDesired){
	    local PlotDefinition PlotDef;
        local XComGameStateHistory History;
        local XComGameState_BattleData BattleData;
        local string plotType;


        History = `XCOMHISTORY;
        BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
        PlotDef = `PARCELMGR.GetPlotDefinition(BattleData.MapData.PlotMapName);
        plotType =  PlotDef.strType;

        if (plotType != plotTypeDesired){
                `log("Plot type is not " $ plotTypeDesired $ " but is instead" $ plotType);
				return false;
        }else{
            `log("Plot type is " $ plotTypeDesired );
			return true;
		}
	}


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