
// source perk packs are:
//[extended perk pack wotc]https://docs.google.com/spreadsheets/d/1wZfTRMWsLDzrJAKO7otuto6o0t0PuzYF6Tv704AkZj0/edit#gid=0
// wotc abb perk pack
// mitzuri's perk pack
// (MAYBE stukov's war perk pack at some point) https://steamcommunity.com/workshop/filedetails/discussion/2728208078/3189112650405981173/
// NOT USING SHADOW OPS PERK PACK, due to undesired class changes

class IRB_AdditionalResistanceOrders_ResCards extends X2StrategyElement config(ResCards);


var config int SUPERCHARGER_POWER_DRAIN;

	static function array<X2DataTemplate> CreateTemplates()
	{		
		local array<X2DataTemplate> Techs;

		`log("Creating resistance cards for IRB_AdditionalResistanceOrders_ResCards v2");
		
		// Templates of the form "if condition X, grant soldier perk Y"
		Techs.AddItem(CreateTunnelRatsTemplate());
		Techs.AddItem(CreateCityTravelPapersTemplate());
		Techs.AddItem(CreateMedikitQuickpatchTemplate());
		Techs.AddItem(CreateFlashpointForGrenadiersTemplate());
		Techs.AddItem(CreateHexhunterForMindshieldsTemplate());
		Techs.AddItem(CreateNeedlepointBuffForPistolTemplate());
		Techs.AddItem(CreateAntimimeticScalesForVestsTemplate());
		Techs.AddItem(CreateFreeAidForGremlinsTemplate());
		Techs.AddItem(CreateSmokerForLaunchersTemplate());
		Techs.AddItem(CreateCombatDrugsForMedikitTemplate());
		//Techs.AddItem(CreatePocketFlamerForCannonsTemplate());
		Techs.AddItem(CreateBattleSpaceForBattleScannersTemplate());
		Techs.AddItem(CreateCannonGrantsEntrenchAbility());
		Techs.AddItem(CreateTemplarMagicBuff());
		Techs.AddItem(CreateSwordsAndKnivesGrantShellbustAbility());
		Techs.AddItem(CreateGrantFirepowerForSparksTemplate());
		Techs.AddItem(CreateGrenadeLauncherGrantsWatchThemRunTemplate());
		Techs.AddItem(CreateHunterProtocolForAssaultAndBattlescanners());
		Techs.AddItem(CreateLongwatchForSnipers());

		Techs.AddItem(CreateGrantTurretsWeakHackDefense());
		Techs.AddItem(CreateColdWeatherHackDefenseDebuff());

		Techs.AddItem(CreateBasiliskDoctrine());
		Techs.AddItem(CreateNoisemakerTemplate()); // will re-add after replacing the Shadow ops perk pack.
		
		Techs.AddItem(CreateMindtakerProtocol());
		Techs.AddItem(CreateSolShells());

		// There are event listeners attached to the names of these next ones, so they don't intrinsically do anything.
		// The following are for doubling the effects of proving grounds/research projects
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_HaasBioroidContacts'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_GlobalsecContacts'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ExperimentalAmmoDoubling'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ExperimentalGrenadeDoubling'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ExoSuitDoubling'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_ExperimentalHeavyWeaponDoubling'));

		// Techs modifying missions generated; see the X2DownloadableContentInfo.
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_EyeForValue'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BoobyTraps'));

		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BigDamnHeroes'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_BureaucraticInfighting'));

		// now, blank resistance orders that affect mission rewards
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_PowerCellRepurposing'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_SupplyRaidsForHacks'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_EducatedVandalism'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_IncitePowerVacuum'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_YouOweMe'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_MassivePopularity'));
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_StolenShippingSchedules'));

		// Black market techs
		Techs.AddItem(CreateVisceraCleanupDetail());
		Techs.AddItem(CreateSafetyFirst());
		Techs.AddItem(CreateBlankResistanceOrder('ResCard_MeatMarket'));

		// Resistance orders with functions run at beginning of tac combat
		Techs.AddItem( GrantResistanceUnitAtCombatStartIfMoreThanOneNoob());
		Techs.AddItem( GrantResistanceUnitAtCombatStartIfRetaliation());
		Techs.AddItem( CreateGrantAdventUnitAtCombatStartIfLessThanFullSquad());
		
		Techs.AddItem(CreateGrantVipsGrenades());
		Techs.AddItem(CreateColdWeatherHackDefenseDebuff());
		Techs.AddItem(CreateGeneralMeleeBuff());
		Techs.AddItem(CreateFlamethrowerBuffCard());
		Techs.AddItem(CreateBloodPillarForPsi());
		Techs.AddItem(CreatePracticalOccultism());
		Techs.AddItem(CreateGrantRookiesPermaHp());
		Techs.AddItem(CreateCheaperSoldiersWithBeatdown());
		Techs.AddItem(CreateDawnMachines());
		Techs.AddItem(CreateRemoteSuperchargers());

		//Techs.AddItem(CreateSiphonLife());
		//Techs.AddItem(CreateBlankResistanceOrder('ResCard_AggressiveOpportunism'));

		return Techs;
	}

	static function X2DataTemplate CreateSiphonLife(){
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SiphonLife');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantSiphonLife;
		return Template; 
	}
		
	static function GrantSiphonLife(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom)
		{
			return;
		}

		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'skulljack'))
		{
			AbilitiesToGrant.AddItem('ILB_SiphonLife');
		}
	}

	static function X2DataTemplate CreateRemoteSuperchargers(){
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_RemoteSuperchargers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantRemoteSuperchargers;
		Template.OnActivatedFn = ActivateSuperchargers;
		Template.OnDeactivatedFn = DeactivateSuperchargers;
		return Template; 
	}

	//---------------------------------------------------------------------------------------
	static function ActivateSuperchargers(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
	{
		local XComGameState_HeadquartersXCom XComHQ;

		XComHQ = GetNewXComHQState(NewGameState);

		XComHQ.BonusPowerProduced -= default.SUPERCHARGER_POWER_DRAIN;
		XComHQ.HandlePowerOrStaffingChange(NewGameState);
	}
	//---------------------------------------------------------------------------------------
	static function DeactivateSuperchargers(XComGameState NewGameState, StateObjectReference InRef)
	{
		local XComGameState_HeadquartersXCom XComHQ;

		XComHQ = GetNewXComHQState(NewGameState);
		XComHQ.BonusPowerProduced += default.SUPERCHARGER_POWER_DRAIN;
		XComHQ.HandlePowerOrStaffingChange(NewGameState);
	}


	static function GrantRemoteSuperchargers(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (IsNegativePower()){
			`LOG("Negative power output found; not granting supercharger abilities");
			return;
		}

		AbilitiesToGrant.AddItem('ILB_Turbocharged');

		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'arcthrower')){
			AbilitiesToGrant.AddItem( 'MZArcElectrocute' ); 
		}
		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin')){
			AbilitiesToGrant.AddItem( 'MZChainingJolt' ); 
		}
	}
	
	static function X2DataTemplate CreateCityTravelPapersTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_ForgedPapers');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantCityTravelPapers;
		return Template; 
	}

	static function GrantCityTravelPapers(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (IsPlotType("SmallTown"))
		{	
			AbilitiesToGrant.AddItem( 'Stealth' ); 
		}

		if (IsPlotType("CityCenter")  && class'IRB_NewResistanceOrders_EventListeners'.static.NumSkirmisherCardsActive() >= 3){
			AbilitiesToGrant.AddItem( 'Stealth' ); 
		}
	}

	static function X2DataTemplate CreateTemplarMagicBuff()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AdditionalTemplarPower');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantTemplarMagicBuff;
		return Template; 
	}

	static function GrantTemplarMagicBuff(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (DoesSoldierHaveArmorOfClass(UnitState,'templar'))
		{
			AbilitiesToGrant.AddItem( 'MZStormForce' );
			//AbilitiesToGrant.AddItem('MZArcCleaveTemplar'); //animation's broken
			//AbilitiesToGrant.AddItem('MZAbyssalPistolShot'); // doesn't work with autopistol
			AbilitiesToGrant.AddItem( 'MZForkedLightning' );

		}
	}
	static function X2DataTemplate CreateMindtakerProtocol()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_Mindtaker');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantMindtakerProtocol;
		return Template; 
	}

	static function GrantMindtakerProtocol(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom)
		{
			if (!UnitState.IsRobotic()){
				AbilitiesToGrant.AddItem('ILB_EasyToHack');
			}
			return;
		}

		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'skulljack'))
		{
			AbilitiesToGrant.AddItem('Interrogator');
		}
	}
	
	static function X2DataTemplate CreateSolShells()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SolShells');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantSolShells;
		return Template; 
	}

	static function GrantSolShells(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'shotgun'))
		{
			AbilitiesToGrant.AddItem('GrimyGrapeShot');
		}
	}
	
	static function X2DataTemplate CreateCheaperSoldiersWithBeatdown()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_SendInTheNextWave');
		Template.Category = "ResistanceCard";
		Template.OnDeactivatedFn = class'X2StrategyElement_XpackResistanceActions'.static.DeactivateRecruitingCenters;
		Template.OnActivatedFn = class'X2StrategyElement_XpackResistanceActions'.static.ActivateRecruitingCenters;
		Template.GetAbilitiesToGrantFn = GrantBeatdown;
		return Template; 
	}

	static function GrantBeatdown(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}

		if (IsRookie(UnitState) || IsSquaddie(UnitState))
		{
			AbilitiesToGrant.AddItem( 'Beatdown' );
		}
	}

	static function X2DataTemplate CreateFlamethrowerBuffCard()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_Promethium');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantPromethium;
		return Template; 
	}

	static function GrantPromethium(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCOM){
			return;
		}
		AbilitiesToGrant.AddItem( 'ILB_PromethiumFireDamageBonus' );
	}

	static function X2DataTemplate CreateGeneralMeleeBuff()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BetterMelee');
		Template.Category = "ResistanceCard";
		Template.OnActivatedFn = ActivateStayWithMe;
		Template.OnDeactivatedFn = DeactivateStayWithMe;

		Template.GetAbilitiesToGrantFn = GrantGeneralMeleeBuff;
		return Template; 
	}

	static function GrantGeneralMeleeBuff(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		AbilitiesToGrant.AddItem( 'ILB_AdditionalMeleeDamage' );

	}
	//---------------------------------------------------------------------------------------
	static function ActivateStayWithMe(XComGameState NewGameState, StateObjectReference InRef, optional bool bReactivate = false)
	{
		AddSoldierUnlock(NewGameState, 'StayWithMeUnlock');
	}
	//---------------------------------------------------------------------------------------
	static function DeactivateStayWithMe(XComGameState NewGameState, StateObjectReference InRef)
	{
		RemoveSoldierUnlock(NewGameState, 'StayWithMeUnlock');
	}

	static function X2DataTemplate CreateBloodPillarForPsi()
	{
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_BloodPillarForPsi');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantBloodPillarForPsi;
		return Template;
	}

	static function GrantBloodPillarForPsi(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'psiamp')
			|| DoesSoldierHaveArmorOfClass(UnitState,'templar'))
		{
			AbilitiesToGrant.AddItem( 'MZBloodPillar' );
		}
	}

	static function X2DataTemplate CreatePracticalOccultism()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_PracticalOccultism');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantPracticalOccultism;
		return Template; 
	}

	static function GrantPracticalOccultism(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (DoesSoldierHaveArmorOfClass(UnitState, 'reaper'))
		{
			AbilitiesToGrant.AddItem( 'MZBloodTeleport' ); 
			AbilitiesToGrant.AddItem( 'MZCloakOfShadows' ); 
		}
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
		if (DoesSoldierHaveSpecificItem(UnitState, 'HazmatVest'))
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
		if (DoesSoldierHaveSpecificItem(UnitState, 'PlatedVest'))
		{
			AbilitiesToGrant.AddItem( 'ILB_PlatedShielding' ); 
		}
	}

	static function X2DataTemplate CreateColdWeatherHackDefenseDebuff()
		{
			local X2StrategyCardTemplate Template;

			`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_MabExploit');
			Template.Category = "ResistanceCard";
			Template.GetAbilitiesToGrantFn = GrantMabExploit;
			return Template; 
		}

		static function GrantMabExploit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
		{		
			if (IsADVENTTurret(UnitState) || IsAdventMEC(UnitState))
			{
				AbilitiesToGrant.AddItem( 'ILB_EasyToHackInTundra' ); 
			}
		}


	static function X2DataTemplate CreateGrantTurretsWeakHackDefense()
		{
			local X2StrategyCardTemplate Template;

			`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_OberonExploit');
			Template.Category = "ResistanceCard";
			Template.GetAbilitiesToGrantFn = GrantOberonExploit;
			return Template; 
		}

		static function GrantOberonExploit(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
		{		
			if (IsADVENTTurret(UnitState))
			{
				AbilitiesToGrant.AddItem( 'ILB_EasyToHack' ); 
			}
		}

	static function X2DataTemplate CreateDawnMachines()
		{
			local X2StrategyCardTemplate Template;

			`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_MachineBuffsIfAridClimate');
			Template.Category = "ResistanceCard";
			Template.GetAbilitiesToGrantFn = GrantDawnMachines;
			return Template; 
		}

		static function GrantDawnMachines(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
		{		

			if (UnitState.GetTeam() != eTeam_XCom){
				return;
			}
			if (UnitState.IsRobotic() && !UnitState.CanTakeCover())
			{
				AbilitiesToGrant.AddItem( 'ILB_DawnMachines' ); 
			}
		}
	
	
	static function bool DoesTemplateHaveString(XComGameState_Unit UnitState, string str){
		return InStr(UnitState.GetMyTemplateName(), str) >= 0; 
	}

	static function bool IsAdventMEC(XComGameState_Unit UnitState){

		`LOG("Unit name: " $ UnitState.GetMyTemplateName() $ " ; is this a MEC?  " $ InStr(UnitState.GetMyTemplateName(), "MEC"));
		return InStr(UnitState.GetMyTemplateName(), "MEC") >= 0; 
	}

	static function bool IsADVENTTurret(XComGameState_Unit UnitState){
		`LOG("Unit name: " $ UnitState.GetMyTemplateName() $ " ; is this a Turret?  " $ InStr(UnitState.GetMyTemplateName(), "Turret"));

		return InStr(UnitState.GetMyTemplateName(), "Turret") >= 0; 
	}
	

static function X2DataTemplate CreateGrantRookiesPermaHp()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_GrantRookiesPermaHp');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantRookiesPermaHp;
		return Template; 
	}

	static function GrantRookiesPermaHp(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{		
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if (IsRookie(UnitState)) // Rookies always get the hp buff
		{
			AbilitiesToGrant.AddItem( 'ILB_RookieHpBuff' ); 
		}
	}


static function X2DataTemplate CreateGrantVipsGrenades()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_VeryIncandescentPersons');
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
			AbilitiesToGrant.AddItem( 'ILB_DangerousVips_Frag' ); 
			AbilitiesToGrant.AddItem( 'ILB_DangerousVips_Smoke' ); 
		}
	}

	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function X2DataTemplate GrantResistanceUnitAtCombatStartIfMoreThanOneNoob(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_ResUnitIfMoreThanOneNoob');
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: ResCard_ResUnitIfMoreThanOneNoob");
		Template.ModifyTacticalStartStateFn = RunCheckForResUnitIfNoobs;

		return Template; 
	}
	
	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function X2DataTemplate GrantResistanceUnitAtCombatStartIfRetaliation(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_ResUnitIfRetaliation');
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: ResCard_ResUnitIfRetaliation");
		Template.ModifyTacticalStartStateFn = RunCheckForResistanceUnitIfRetaliation;

		return Template; 
	}

	// grant resistance unit if two or more characters selected for combat are squaddies or rookies
	static function X2DataTemplate CreateGrantAdventUnitAtCombatStartIfLessThanFullSquad(){		
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_AdventUnitIfLessThanFullSquad');
		Template.Category = "ResistanceCard";
		`log("Created resistance order: ResCard_AdventUnitIfLessThanFullSquad");
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

	static function RunCheckForResistanceUnitIfRetaliation(XComGameState StartState){
		`LOG("Mission started; mission type is " $ GetMissionData(StartState).GeneratedMission.Mission.MissionFamily);
		if (IsRetaliationMission(StartState)){
			`Log("Retaliation mission detected; granting resistance order");
			GrantResistanceUnitAtCombatStart(StartState);
		}
	}
	
	/// Why doesn't this work?
	static function bool IsRetaliationMission(XComGameState StartState){
		local GeneratedMissionData Mission;
		Mission = GetMissionData(StartState).GeneratedMission;

		return Mission.Mission.MissionFamily == "ChosenRetaliation"
				|| Mission.Mission.MissionFamily == "Terror";
	}


	//missionsource=MissionSource_Retaliation
	static function XComGameState_MissionSite GetMissionData(XComGameState StartState)
	{
		local XComGameState_BattleData BattleData;
		local XComGameState_MissionSite MissionState;
		local XComGameStateHistory History;

		History = `XCOMHISTORY;
		BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
		MissionState = GetMission(StartState);
		return MissionState;
	}

	static function bool IsNegativePower(){
		local XComGameState NewGameState;
		local XComGameStateHistory CachedHistory;
		local XComGameState_HeadquartersXCom XComHQ;

		CachedHistory = `XCOMHISTORY;
		NewGameState = CachedHistory.GetGameStateFromHistory();
		XComHQ = GetNewXComHQState(NewGameState);
		return XComHQ.GetPowerConsumed() > XComHQ.GetPowerProduced();
	}

	simulated static function XComGameState_MissionSite GetMission(XComGameState StartState)
	{
		local XComGameState_HeadquartersXCom XComHQ;
		foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
			break;
		return XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(XComHQ.MissionRef.ObjectID));
	}

static function GrantAdventUnitAtCombatStart(XComGameState StartState)
{
	local XComGameState_BattleData BattleData;
	local XComGameState_HeadquartersXCom XComHQ;
	local DoubleAgentData DoubleAgent;
	local int CurrentForceLevel, Rand;
	local array<name> PossibleTemplates;

	`LOG("Granting ADVENT unit.");
	if (IsSplitMission( StartState ))
		return;

	foreach StartState.IterateByClassType( class'XComGameState_HeadquartersXCom', XComHQ )
		break;

	`assert( XComHQ != none );

	if (XComHQ.TacticalGameplayTags.Find( 'NoDoubleAgent' ) != INDEX_NONE){
		`LOG("NoDoubleAgent tag found, bailing");
		return;
	}

	foreach StartState.IterateByClassType( class'XComGameState_BattleData', BattleData )
	{
		break;
	}

	`assert( BattleData != none );

	CurrentForceLevel = BattleData.GetForceLevel( );
	foreach class'X2StrategyElement_XpackResistanceActions'.default.DoubleAgentCharacterTemplates( DoubleAgent )
	{
		if ((CurrentForceLevel < DoubleAgent.MinForceLevel) ||
			(CurrentForceLevel > DoubleAgent.MaxForceLevel))
		{
			continue;
		}

		PossibleTemplates.AddItem( DoubleAgent.TemplateName );
	}

	`LOG("Attempting to spawn tac start modifier (advent unit)");

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

	static function int NumSoldiersControlledByPlayer(XComGameState StartState)
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
				if (UnitState.IsPlayerControlled() && UnitState.IsSoldier())
				{
					NumSoldiers++;
				}
			}
		}
		`LOG("Discovered soldiers: " $ NumSoldiers);
		return NumSoldiers;
	}
	
	static function bool IsSquaddie(XComGameState_Unit UnitState){
		local int SoldierRank;
		SoldierRank = UnitState.GetSoldierRank() ;
		`LOG("Soldier rank (checking for squaddie, rank 1) detected for soldier " $ UnitState.GetFullName() $ ": " $ SoldierRank);
		return UnitState.GetSoldierRank() == 1;
	}

	static function bool IsRookie(XComGameState_Unit UnitState){
		local int SoldierRank;
		SoldierRank = UnitState.GetSoldierRank() ;
		`LOG("Soldier rank (checking for rookie, rank 0) detected for soldier " $ UnitState.GetFullName() $ ": " $ SoldierRank);
		return UnitState.GetSoldierRank() == 0;
	}



	static function int NumRookiesOrSquaddies(XComGameState StartState)
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
				if (UnitState.IsPlayerControlled() && UnitState.IsSoldier())
				{
					if (UnitState.GetSoldierRank() <= 1) // rookies start at 0, squaddies=1
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

		if (XComHQ.TacticalGameplayTags.Find( 'NoVolunteerArmy' ) != INDEX_NONE){
			`LOG("NoVolunteerArmy tag found, bailing");
			return;
		}
		if (XComHQ.IsTechResearched('PlasmaRifle'))
		{
			VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplateM3;
		}
		else if (XComHQ.IsTechResearched('MagnetizedWeapons'))
		{
			VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplateM2;
		}
		else
		{
			VolunteerCharacterTemplate =  class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplate;
		}
		`LOG("Attempting to spawn tac start modifier (volunteer)");

		class'X2StrategyElement_XpackResistanceActions'.static.XComTeamSoldierSpawnTacticalStartModifier( VolunteerCharacterTemplate, StartState );
	}

	
	static function X2DataTemplate CreateBlankResistanceOrder(name OrderName)
	{
		local X2StrategyCardTemplate Template;
		
		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, OrderName);
		Template.Category = "ResistanceCard";
		`log("Created blank resistance order: "  $ OrderName);
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
			if (DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'shotgun')
				|| DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'assault_rifle')){
				AbilitiesToGrant.AddItem( 'Stealth' ); 
			}
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
			AbilitiesToGrant.AddItem( 'ILB_WitchHunter' ); 
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
			AbilitiesToGrant.AddItem( 'ILB_PistolShotsDealPoisonPassive' );
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
	static function X2DataTemplate CreateFreeAidForGremlinsTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_MultitaskingForGremlins');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantFreeAidIfGremlin;
		return Template; 
	}

	static function  GrantFreeAidIfGremlin(XComGameState_Unit UnitState, out array<name> AbilitiesToGrant)
	{	
		if (UnitState.GetTeam() != eTeam_XCom){
			return;
		}
		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin'))
		{
			AbilitiesToGrant.AddItem( 'ILB_AidProtocolRefund' ); 
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
			AbilitiesToGrant.AddItem( 'ILB_FreeSmokeGrenadeSingular' );
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
			AbilitiesToGrant.AddItem( 'ILB_PocketFlamer' );
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
			AbilitiesToGrant.AddItem( 'TargetDefinition' );
		}
	}

	static function X2DataTemplate CreateCannonGrantsEntrenchAbility()
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

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sniper_rifle'))
		{
			AbilitiesToGrant.AddItem( 'DeepCover' );//https://docs.google.com/spreadsheets/d/11nKVN8Rd4MoIOtBbkmzLkwq7NWb0ZI8Q2VNAD16mFTE/edit#gid=0
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
			// done in DLCInfo
			//AbilitiesToGrant.AddItem( 'MZShellbustStab' );
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
			AbilitiesToGrant.AddItem( 'F_WatchThemRun' );//todo: verify
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
			AbilitiesToGrant.AddItem( 'ILB_Rocketeer' );
			AbilitiesToGrant.AddItem( 'WalkFire' );
		}
	}

	//ShadowOps_NoiseMaker granted to GREMLINs.  TODO: Shadow Ops Perk Pack is a no go because it changes the classes.
	static function X2DataTemplate CreateNoisemakerTemplate()
	{
		local X2StrategyCardTemplate Template;

		`CREATE_X2TEMPLATE(class'X2StrategyCardTemplate', Template, 'ResCard_Noisemaker');
		Template.Category = "ResistanceCard";
		Template.GetAbilitiesToGrantFn = GrantNoisemakerIfGremlin;
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

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'cannon') )
		{
			AbilitiesToGrant.AddItem( 'Sentinel' );
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

		if(DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'assault_rifle') &&  DoesSoldierHaveSpecificItem(UnitState, 'BattleScanner'))
		{
			AbilitiesToGrant.AddItem( 'EverVigilant' );
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

		if(DoesSoldierHaveArmorOfClass(UnitState, 'skirmisher'))
		{
			//AbilitiesToGrant.AddItem( 'Shredder' );
			//AbilitiesToGrant.AddItem( 'TakeUnder' );
			// doing this in DLCInfo since it requires binding to an offensive ability
		}
	}
	
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
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sword') 
			|| DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'combatknife')
			|| DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'wristblade');
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
	
	static function bool DoesSoldierHavePsiRating(XComGameState_Unit UnitState){
	
		local XComGameStateHistory History;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		if (UnitState.GetCurrentStat(eStat_PsiOffense) >= 10){
			return true;
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
					`LOG("Found armor of desired class " $ Classification);
					return true;
				}
				if (Armor.ArmorCat == Classification){
					`LOG("Found armor of desired armorcat " $ Classification);
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

	static function XComGameState_Unit XComTeamSoldierSpawnTacticalStartModifier(name CharTemplateName, XComGameState StartState)
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

		return SoldierState;
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