
// source perk packs are:
//[extended perk pack wotc]https://docs.google.com/spreadsheets/d/1wZfTRMWsLDzrJAKO7otuto6o0t0PuzYF6Tv704AkZj0/edit#gid=0
// wotc abb perk pack
// mitzuri's perk pack
// (MAYBE stukov's war perk pack at some point) https://steamcommunity.com/workshop/filedetails/discussion/2728208078/3189112650405981173/
// NOT USING SHADOW OPS PERK PACK, due to undesired class changes

class IRB_AdditionalResistanceOrders_ResCards extends X2StrategyElement;
	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards v2");
		
		// Templates of the form "if condition X, grant soldier perk Y"
		Techs.AddItem(CreateTunnelRatsTemplate());
		Techs.AddItem(CreateFlashpointForGrenadiersTemplate());
		Techs.AddItem(CreateHexhunterForMindshieldsTemplate());
		Techs.AddItem(CreateNeedlepointBuffForPistolTemplate());
		Techs.AddItem(CreateAntimimeticScalesForVestsTemplate());
		Techs.AddItem(CreateMultitaskingForGremlinsTemplate());
		Techs.AddItem(CreateSmokerForLaunchersTemplate());
		Techs.AddItem(CreateCombatDrugsForMedikitTemplate());
		Techs.AddItem(CreatePocketFlamerForCannonsTemplate());
		Techs.AddItem(CreateBattleSpaceForBattleScannersTemplate());
		Techs.AddItem(CreatePistolGrantsEntrenchAbility());

		Techs.AddItem(CreateSwordsAndKnivesGrantShellbustAbility());
		Techs.AddItem(CreateGrantFirepowerForSparksTemplate());
		Techs.AddItem(CreateGrenadeLauncherGrantsWatchThemRunTemplate());
		Techs.AddItem(CreateHunterProtocolForAssaultAndBattlescanners());
		Techs.AddItem(CreateLongwatchForSnipers());

		Techs.AddItem(CreateBasiliskDoctrine());
		Techs.AddItem(CreateNoisemakerTemplate()); // will re-add after replacing the Shadow ops perk pack.
		
		Techs.AddItem(CreateDawnMachines());


		// There are event listeners attached to the names of these next ones, so they don't intrinsically do anything.
		// The following are for doubling the effects of proving grounds/research projects
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_HaasBioroidContacts'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_GlobalsecContacts'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_GlobalsecContactsII'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_GrndlContacts'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_GrndlContactsII'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ArgusSecurityContacts'));

		// Techs modifying missions generated; see the X2DownloadableContentInfo.
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_EyeForValue'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BigDamnHeroes'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BureaucraticInfighting'));

		// Black market techs
		Techs.AddItem(CreateVisceraCleanupDetail());
		Techs.AddItem(CreateSafetyFirst());
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_MeatMarket'));

		// Resistance orders with functions run at beginning of tac combat
		Techs.AddItem( GrantResistanceUnitAtCombatStartIfMoreThanOneNoob());
		Techs.AddItem( GrantResistanceUnitAtCombatStartIfRetaliation());
		Techs.AddItem( GrantAdventUnitAtCombatStartIfLessThanFullSquad());
		
		Techs.AddItem(CreateGrantAdventMecsColdWeatherVulnerability());;

		Techs.AddItem(CreateGrantVipsFragGrenades());
		return Techs;
	}
	
	//NOTE: This also includes event listeners for the black market parts
	static function X2DataTemplate CreateVisceraCleanupDetail()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_CleanupDetail');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantVisceraCleanupDetail;
		return Template; 
	}

	static function GrantVisceraCleanupDetail(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveSpecificItem('HazmatVest'))
		{
			AbilitiesToGrant.AddItem( 'ILB_HazmatShielding' ); 
		}
	}
	//NOTE: This also includes event listeners for the black market parts
	static function X2DataTemplate CreateSafetyFirst()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SafetyFirst');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantSafetyFirst;
		return Template; 
	}

	static function GrantSafetyFirst(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveSpecificItem('PlatedVest'))
		{
			AbilitiesToGrant.AddItem( 'ILB_PlatedShielding' ); 
		}
	}

	static function X2DataTemplate CreateGrantAdventMecsColdWeatherVulnerability()
		{
			local X2StrategyCardTemplate Template;

			`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_MabExploit');
			Template.Category = "ResistanceCard";
			Template.GetAbilitiesToGrantFn = GrantMabExploit;
			return Template; 
		}

		static function GrantMabExploit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
		{		
			if (IsAdventMEC(UnitState) || IsADVENTTurret(UnitState))
			{
				AbilitiesToGrant.AddItem( 'ILB_EasyToHackInTundra' ); 
			}
		}

	static function X2DataTemplate CreateDawnMachines()
		{
			local X2StrategyCardTemplate Template;

			`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_DawnMachines');
			Template.Category = "ResistanceCard";
			Template.GetAbilitiesToGrantFn = GrantDawnMachines;
			return Template; 
		}

		static function GrantDawnMachines(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
		{		

			if (UnitState.GetTeam() != eTeam_XCom){
				return;
			}
			if (UnitState.IsRobotic())
			{
				AbilitiesToGrant.AddItem( 'ILB_DawnMachines' ); 
			}
		}
	

	static function bool IsAdventMEC(XComGameState_Unit UnitState){
		return string(UnitState.GetMyTemplateName()) $= "MEC"; 
	}

	static function bool IsADVENTTurret(XComGameState_Unit UnitState){
		return string(UnitState.GetMyTemplateName()) $= "Turret"; 
	}


static function X2DataTemplate CreateGrantVipsFragGrenades()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_TunnelRats');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantVipsFragGrenades;
		return Template; 
	}

	static function GrantVipsFragGrenades(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetMyTemplateName() == 'FriendlyVIPCivilian'
			|| UnitState.GetMyTemplateName() == 'Scientist_VIP'
			|| UnitState.GetMyTemplateName() == 'Engineer_VIP')
		{
			AbilitiesToGrant.AddItem( 'ILB_TwoExtraFrags' ); 
		}
	}

	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function GrantResistanceUnitAtCombatStartIfMoreThanOneNoob(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_ResUnitIfMoreThanOneNoob');
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: " $ string(OrderName));
		Template.ModifyTacticalStartStateFn = RunCheckForResUnitIfNoobs;

		return Template; 
	}
	
	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function GrantResistanceUnitAtCombatStartIfRetaliation(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_ResUnitIfRetaliation');
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: " $ string(OrderName));
		Template.ModifyTacticalStartStateFn = RunCheckForResistanceUnitIfRetaliation;

		return Template; 
	}

	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function GranAdventUnitAtCombatStartIfLessThanFullSquad(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AdventUnitIfLessThanFullSquad');
		Template.Category = "ResistanceCard";
		`log("Created resistance order: " $ string(OrderName));
		Template.ModifyTacticalStartStateFn = RunCheckForAdvUnitIfFewerThanSix;

		return Template; 
	}

	static function RunCheckForResUnitIfNoobs(XComGameState StartState)
	{
		if (NumRookiesOrSquaddies(StartState) >= 2){
			GrantResistanceUnitAtCombatStart(StartState);
		}
	}
	
	static function RunCheckForAdvUnitIfFewerThanSix(XComGameState StartState)
	{
		if (NumSoldiersControlledByPlayer(StartState) < 6){
			GrantAdventUnitAtCombatStart(StartState);
		}
	}

	static function RunCheckForResistanceUnitIfRetaliation(){
		if (IsRetaliationMission(StartState)){
			GrantResistanceUnitAtCombatStart(StartState);
		}
	}
	
	static function bool IsRetaliationMission(XComGameState StartState){
		return GetMissionData().MissionSource == 'MissionSource_Retaliation';
	}


	//missionsource=MissionSource_Retaliation
	static function XComGameState_MissionSite GetMissionData()
	{
		local XComGameState_BattleData BattleData;
		local XComGameState_MissionSite MissionState;
		local XComGameStateHistory History;

		History = `XCOMHISTORY;
		BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		MissionState = GetMission();
	}

	simulated function XComGameState_MissionSite GetMission()
	{
		return XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	}

static function GrantAdventUnitAtCombatStart(XComGameState StartState)
{
	local XComGameState_BattleData BattleData;
	local XComGameState_HeadquartersXCom XComHQ;
	local DoubleAgentData DoubleAgent;
	local int CurrentForceLevel, Rand;
	local array<name> PossibleTemplates;

	if (IsSplitMission( StartState ))
		return;

	foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
		break;

	`assert( XComHQ != none );

	if (XComHQ.TacticalGameplayTags.Find( 'NoDoubleAgent' ) != INDEX_NONE)
		return;

	foreach StartState.IterateByClassType( class'XComGameState_BattleData', BattleData )
	{
		break;
	}

	`assert( BattleData != none );

	CurrentForceLevel = BattleData.GetForceLevel( );
	foreach default.DoubleAgentCharacterTemplates( DoubleAgent )
	{
		if ((CurrentForceLevel < DoubleAgent.MinForceLevel) ||
			(CurrentForceLevel > DoubleAgent.MaxForceLevel))
		{
			continue;
		}

		PossibleTemplates.AddItem( DoubleAgent.TemplateName );
	}


	if (PossibleTemplates.Length > 0)
	{
		Rand = `SYNC_RAND_STATIC( PossibleTemplates.Length );
		XComTeamSoldierSpawnTacticalStartModifier( PossibleTemplates[ Rand ], StartState );
	}
	else
	{
		`redscreen("Double Agent Policy unable to find any potential templates for Force Level " @ CurrentForceLevel );
	}
}

	static int NumSoldiersControlledByPlayer(XComGameState StartState)
	{
		local XComGameStateHistory History;
		local XComGameState_HeadquartersXCom XComHQ;
		local XComGameState_Unit UnitState;
		local XComGameState_ResistanceFaction FactionState;
		local int idx, NumWounded, NumDead, NumSquad, NumCaptured;
		local int NumSoldiers;
		History = `XCOMHISTORY;
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		NumSoldiers=0;
		for(idx = 0; idx < XComHQ.Squad.Length; idx++)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[idx].ObjectID));

			if(UnitState != none)
			{
				if (Unit.IsPlayerControlled() && Unit.IsSoldier())
				{
					NumSoldiers++;
				}
			}
		}
		return NumSoldiers;
	}

	static int NumRookiesOrSquaddies(XComGameState StartState)
	{
		local XComGameStateHistory History;
		local XComGameState_HeadquartersXCom XComHQ;
		local XComGameState_Unit UnitState;
		local XComGameState_ResistanceFaction FactionState;
		local int idx, NumWounded, NumDead, NumSquad, NumCaptured;
		local int NumSoldiers;
		History = `XCOMHISTORY;
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		NumSoldiers=0;
		for(idx = 0; idx < XComHQ.Squad.Length; idx++)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(XComHQ.Squad[idx].ObjectID));

			if(UnitState != none)
			{
				if (Unit.IsPlayerControlled() && Unit.IsSoldier())
				{
					if (Unit.GetSoldierRank() <= 1) // rookies start at 0, squaddies=1
					{
						NumSoldiers++;;
					}
				}
			}
		}
		return NumSoldiers;
	}

	static function GrantResistanceUnitAtCombatStart(XComGameState StartState)
	{
		local XComGameState_HeadquartersXCom XComHQ;
		local name VolunteerCharacterTemplate;

		foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
			break;
		`assert( XComHQ != none );

		if (XComHQ.TacticalGameplayTags.Find( 'NoVolunteerArmy' ) != INDEX_NONE)
			return;

		if (XComHQ.IsTechResearched('PlasmaRifle'))
		{
			VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplateM3;
		}
		else if (XComHQ.IsTechResearched('MagnetizedWeapons'))
		{
			VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplateM2;
		}
		else
		{
			VolunteerCharacterTemplate = default.VolunteerArmyCharacterTemplate;
		}

		X2StrategyElement_XpackResistanceActions.static.XComTeamSoldierSpawnTacticalStartModifier( VolunteerCharacterTemplate, StartState );
	}

	
	static function X2DataTemplate CreateBlankResistanceOrder(name OrderName)
	{
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, OrderName);
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: "  $ string(OrderName));
		return Template; 
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

		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (IsPlotType("Tunnels_Sewer") || IsPlotType("Tunnels_Subway"))
		{	
			AbilitiesToGrant.AddItem( 'Phantom' ); 
		}
	}
	//////// FLASHPOINT for grenadiers
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'grenade_launcher')){
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (SoldierHasPistol(UnitState))
		{
			AbilitiesToGrant.AddItem( 'GrimyNeedlePointPassive' ); 
		}
	}

	///antimemetic scales
	static function X2DataTemplate CreateAntimimeticScalesForVestsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AntimimeticScalesForVests');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantAntimemeticBuffsIfVest;
		return Template; 
	}

	static function GrantAntimemeticBuffsIfVest(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveDefensiveVest(UnitState))
		{
			AbilitiesToGrant.AddItem( 'Shadowstep' ); //todo: split into its own thing
		}
	}
	
	///antimemetic scales
	static function X2DataTemplate CreateAntimimeticScalesForVestsIITemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AntimimeticScalesForVestsII');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantAntimemeticBuffsIfVestII;
		return Template; 
	}

	static function GrantAntimemeticBuffsIfVestII(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveDefensiveVest(UnitState))
		{
			AbilitiesToGrant.AddItem( 'Phantom' );
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'grenade_launcher'))
		{
			AbilitiesToGrant.AddItem( 'MZFogWall' );
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'heal'))
		{
			AbilitiesToGrant.AddItem( 'F_CombatDrugs' ); //https://docs.google.com/spreadsheets/d/1wZfTRMWsLDzrJAKO7otuto6o0t0PuzYF6Tv704AkZj0/edit#gid=0
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
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
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if(DoesSoldierHaveSpecificItem(UnitState, 'Battlescanner'))
		{
			AbilitiesToGrant.AddItem( 'Battlespace' );
		}
	}

	static function X2DataTemplate CreatePistolGrantsEntrenchAbility()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_PistolForEntrench');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantPistolForEntrench;
		return Template; 
	}

	static function GrantPistolForEntrench(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'pistol') || DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'autopistol'))
		{
			AbilitiesToGrant.AddItem( 'Entrench' );//https://docs.google.com/spreadsheets/d/11nKVN8Rd4MoIOtBbkmzLkwq7NWb0ZI8Q2VNAD16mFTE/edit#gid=0
		}
	}
	

	// MZShellbustStab for swords/knives
	static function X2DataTemplate CreateSwordsAndKnivesGrantShellbustAbility()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BladesGrantShellbust');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantShellbustIfSword;
		return Template; 
	}

	static function GrantShellbustIfSword(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveSword(UnitState))
		{
			AbilitiesToGrant.AddItem( 'MZShellbustStab' );
		}
	}
	
	// Grenade launcher grants Watch Them Run
	static function X2DataTemplate CreateGrenadeLauncherGrantsWatchThemRunTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_GrenadeLauncherGrantsWatchThemRun');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantWatchThemRunIfGrenadeLauncher;
		return Template; 
	}

	static function GrantWatchThemRunIfGrenadeLauncher(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveGrenadeLauncher(UnitState))
		{
			AbilitiesToGrant.AddItem( 'WatchThemRun' );//todo: verify
		}
	}

	// grants sparks (mechanical units) Walk Fire and ABB_Cannonade.
	static function  X2DataTemplate CreateGrantFirepowerForSparksTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_FirepowerForSparks');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHeavyWeaponUseAndWalkFireIfSpark;
		return Template; 
	}

	static function GrantHeavyWeaponUseAndWalkFireIfSpark(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(UnitState.IsRobotic())
		{
			AbilitiesToGrant.AddItem( 'ABB_Cannonade' );
			AbilitiesToGrant.AddItem( 'WalkFire' );
		}
	}

	//ShadowOps_NoiseMaker granted to GREMLINs.  TODO: Shadow Ops Perk Pack is a no go because it changes the classes.
	static function X2DataTemplate CreateNoisemakerTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_Noisemaker');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHeavyWeaponUseAndWalkFireIfSpark;
		return Template; 
	}

	static function GrantNoisemakerIfGremlin(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveGremlin(UnitState) )
		{
			AbilitiesToGrant.AddItem( 'ILB_FreeUltrasonicLure' );
		}
	}
	
	//ShadowOps_NoiseMaker granted to GREMLINs.  TODO: Shadow Ops Perk Pack is a no go because it changes the classes.
	static function X2DataTemplate CreateMedikitQuickpatchTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_QuickpatchForMedikit');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantQuickpatchIfMedikit;
		return Template; 
	}

	static function GrantQuickpatchIfMedikit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'heal') )
		{
			AbilitiesToGrant.AddItem( 'F_QuickPatch' );
		}
	}
	
	//ShadowOps_NoiseMaker granted to GREMLINs.  TODO: Shadow Ops Perk Pack is a no go because it changes the classes.
	static function X2DataTemplate CreateSurpriseIfSpiderSuitOrWraithSuit()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SurpriseForSpiderOrWraithSuit');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantSurpriseIfArmor;
		return Template; 
	}

	static function GrantSurpriseIfArmor(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveSpecificItem(UnitState, 'SpiderSuit') || DoesSoldierHaveSpecificItem(UnitState, 'WraithSuit') )
		{
			AbilitiesToGrant.AddItem( 'F_FirstStrike' );
			AbilitiesToGrant.AddItem( 'F_QuickFeet' );
		}
	}
	
	
	//ShadowOps_NoiseMaker granted to GREMLINs.  TODO: Shadow Ops Perk Pack is a no go because it changes the classes.
	static function X2DataTemplate CreateLongwatchForSnipers()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_LongwatchForSnipers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantLongwatchIfSniper;
		return Template; 
	}

	static function GrantLongwatchIfSniper(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sniper_rifle') )
		{
			AbilitiesToGrant.AddItem( 'LongWatch' );
		}
	}
	static function X2DataTemplate CreateHunterProtocolForAssaultAndBattlescanners()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_LongwatchForSnipers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHunterProtocolToAssaultRiflesAndBattlescanners;
		return Template; 
	}

	static function GrantHunterProtocolToAssaultRiflesAndBattlescanners(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'assault_rifle') ||  DoesSoldierHaveSpecificItem(UnitState, 'BattleScanner'))
		{
			AbilitiesToGrant.AddItem( 'LongWatch' );
		}
	}
	
	static function X2DataTemplate CreateBasiliskDoctrine()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BasiliskDoctrine');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantBasiliskDoctrine;
		return Template; 
	}

	static function GrantBasiliskDoctrine(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'bullpup'))
		{
			AbilitiesToGrant.AddItem( 'Shredder' );
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'wristblade'))
		{
			AbilitiesToGrant.AddItem( 'TakeUnder' );
		}
	}

	//TODO: Doesn't work yet
	static function X2DataTemplate CreateHavanaProtocol()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BasiliskDoctrine');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantHavanaProtocol;
		return Template; 
	}

	static function GrantHavanaProtocol(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'holotargeter'))
		{
			//TODO
		}
	}
	
    //SKV_Shield_5HP for mechanical units (or alternatively SKV_AlloyCarbidePlating ) (Adaptive armor?)
	// wraith/spider suits grant Surprise. (F_FirstStrike) 
	// cannons grant F_Havoc
	// EXO and WAR suits grant armor and decrease mobility. (SKV_ExtraPlating)
	// Skulljacks grant +2 melee damage.
	// gremlins grant F_Recharge (killing enemy grants -1 to all cooldowns)
	// EXO and WAR suits grant Riot Control
	// Wraith/Spider suits grant F_QuickFeet and F_Preservation
	// Medikits grant F_QuickPatch [no action cost]
	// research breakthroughs also yield an Elereum Core (research-sharing agreements)
	// Labs(Workshops) grant 1 free Resistance Contact
	// Labs(Workshops) grant 3 additional Power
	// NBN Corporate Contacts:  Grants 25 supply and 25 intel each time you kill a Chosen or an ADVENT Field Commander.  ("Someone is always watching" --unofficial NBN corporate motto)
	// City Center: Gain phantom. [Secret Identities] [As you can see from our paperwork, we're a rock band, which explains our large amount of equipment in otherwise-suspicious opaque cases. --Cpl. Jane Kelly]
	// City Center: Gain Tracking as per perk.  [Guess who got admin access to the municipal security network?]
	// bBreakthrough researches grant 50 intel on completion (Jinteki Corporate Contacts)
	// Melange Mining Corp Contacts:  On excavating machinery, gain 2 free Turret Wrecks and MEC Wrecks.  SPARKs gain 3 shield at mission start.
	// Melange Mining Corp Contacts II:  On excavating machinery, gain 4 free Turret Wrecks and MEC Wrecks.  SPARKs gain 5 shield at mission start.
	// Convert supplies + time in proving grounds into Elereum Cores [15 days, 20 supply, grants 1 core]
	// Convert supplies + time in proving grounds into Elereum Shards [15 days, 20 supply, grants 30 shards]
	// Refraction Fields grant Evasive.
	// stukov's war perk pack: is there a shield?

	static function bool DoesSoldierHaveRocketLauncher(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'RocketLauncher');
	}
	static function bool DoesSoldierHaveGrenadeLauncher(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'grenade_launcher');
	}
	static function bool DoesSoldierHaveGremlin(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin');
	}

	static function bool DoesSoldierHaveSword(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sword') || DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'combatknife');
	}

	static function bool DoesSoldierHavePistol(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'pistol');
	}

	static function bool DoesSoldierHaveMindShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'psidefense');
	}

	static function bool DoesSoldierHaveDefensiveVest(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'NanofiberVest');
	}

	static function bool DoesSoldierHaveShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'shield');
	}


	//VALIDATED
	static function bool DoesSoldierHaveSpecificItem(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name ItemCat;
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

	static function bool DoesSoldierHaveArmorOfClass(XComGameState_Unit UnitState, name Classification){
	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local X2ArmorTemplate Armor;
		local name WeaponCat;
		local name ItemCat;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{

				Armor = X2ArmorTemplate(ItemState.GetMyTemplate());
				if (Armor == none){
					continue;
				}
				if (Armor.ArmorClass == Classification){
					return true;
				}
			}
		}
		return false;
	}

	///VALIDATED.
	static function bool DoesSoldierHaveItemOfWeaponOrItemClass(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name WeaponCat;
		local name ItemCat;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		`Log("SEARCHING for item of weapon or item cat: " $ string(Classification));

		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{
				WeaponCat=ItemState.GetWeaponCategory();
				`Log("Soldier has item of weaponcat: " $ WeaponCat);
				// check item's type
				if (WeaponCat == Classification){
					`Log("Soldier DOES have item of DESIRED weaponcat: " $ WeaponCat);
					return true;
				}

				ItemCat = ItemState.GetMyTemplate().ItemCat;
				`Log("Soldier has item of itemcat: " $ ItemCat);
				if (ItemCat == Classification){
					`Log("Soldier DOES have item of DESIRED itemcat: " $ ItemCat);
					return true;
				}
			}
		}
		return false;
	}

	static function bool SoldierHasPistol(XComGameState_Unit Unit){
		return DoesSoldierHaveItemOfWeaponOrItemClass(Unit, 'pistol');
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