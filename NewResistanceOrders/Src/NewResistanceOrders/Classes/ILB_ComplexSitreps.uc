class ILB_ComplexSitreps extends X2SitRepEffect config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	// granted abilities
	Templates.AddItem(CreateBureaucraticInfightingTempAdventSoldierEffectTemplate());
    return Templates;
}
static function X2SitRepEffectTemplate CreateBureaucraticInfightingTempAdventSoldierEffectTemplate()
{
	local X2SitRepEffect_ModifyTacticalStartState Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'ILB_BureaucraticInfightingSitrepEffect');

	Template.ModifyTacticalStartStateFn = GrantAdventUnitAtCombatStart;
	
	return Template;
}
static function X2SitRepEffectTemplate CreateVolunteerArmyEffectTemplate()
{
	local X2SitRepEffect_ModifyTacticalStartState Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyTacticalStartState', Template, 'ILB_VolunteerArmyEffect');

	Template.ModifyTacticalStartStateFn = VolunteerArmyTacticalStartModifier;
	
	return Template;
}

static function VolunteerArmyTacticalStartModifier(XComGameState StartState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local name VolunteerCharacterTemplate;

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}
	`assert(XComHQ != none);

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
		VolunteerCharacterTemplate = class'X2StrategyElement_XpackResistanceActions'.default.VolunteerArmyCharacterTemplate;
	}

	XComTeamSoldierSpawnTacticalStartModifier(VolunteerCharacterTemplate, StartState);
}

static function XComTeamSoldierSpawnTacticalStartModifier(name CharTemplateName, XComGameState StartState)
{
	local X2CharacterTemplate CharacterTemplate;
	local array<X2AbilityTemplate> Abilities;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Unit SoldierState;
	local XGCharacterGenerator CharacterGenerator;
	local XComGameState_Player PlayerState;
	local TSoldier Soldier;
	local XComGameState_HeadquartersXCom XComHQ;

	// generate a basic resistance soldier unit
	CharacterTemplate = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager().FindCharacterTemplate(CharTemplateName);
	`assert(CharacterTemplate != none);

	SoldierState = CharacterTemplate.CreateInstanceFromTemplate(StartState);
	SoldierState.bMissionProvided = true;
	Abilities = GetTempSoldierAbilities();

	if (CharacterTemplate.bAppearanceDefinesPawn)
	{
		CharacterGenerator = `XCOMGRI.Spawn(CharacterTemplate.CharacterGeneratorClass);
		`assert(CharacterGenerator != none);

		Soldier = CharacterGenerator.CreateTSoldier();
		SoldierState.SetTAppearance(Soldier.kAppearance);
		SoldierState.SetCharacterName(Soldier.strFirstName, Soldier.strLastName, Soldier.strNickName);
		SoldierState.SetCountry(Soldier.nmCountry);
	}
	
	foreach StartState.IterateByClassType(class'XComGameState_Player', PlayerState)
	{
		if(PlayerState.GetTeam() == eTeam_XCom)
		{
			SoldierState.SetControllingPlayer(PlayerState.GetReference());
			break;
		}
	}

	SoldierState.ApplyInventoryLoadout(StartState);

	foreach StartState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if (!SoldierState.IsSoldier())
	{
		foreach Abilities(AbilityTemplate)
		{
			class'X2TacticalGameRuleset'.static.InitAbilityForUnit(AbilityTemplate, SoldierState, StartState);			
		}
	}

	XComHQ.Squad.AddItem(SoldierState.GetReference());
	XComHQ.AllSquads[0].SquadMembers.AddItem(SoldierState.GetReference());
}


	static function bool IsSplitMission( XComGameState StartState )
	{
		local XComGameState_BattleData BattleData;

		foreach StartState.IterateByClassType( class'XComGameState_BattleData', BattleData )
			break;

		return (BattleData != none) && BattleData.DirectTransferInfo.IsDirectMissionTransfer;
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

static function array<X2AbilityTemplate> GetTempSoldierAbilities()
{
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplateManager Manager;

	Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Templates.AddItem(Manager.FindAbilityTemplate('Evac'));
	Templates.AddItem(Manager.FindAbilityTemplate('PlaceEvacZone'));
	Templates.AddItem(Manager.FindAbilityTemplate('LiftOffAvenger'));

	Templates.AddItem(Manager.FindAbilityTemplate('Loot'));
	Templates.AddItem(Manager.FindAbilityTemplate('CarryUnit'));
	Templates.AddItem(Manager.FindAbilityTemplate('PutDownUnit'));

	Templates.AddItem(Manager.FindAbilityTemplate('Interact_PlantBomb'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_TakeVial'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_StasisTube'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_MarkSupplyCrate'));
	Templates.AddItem(Manager.FindAbilityTemplate('Interact_ActivateAscensionGate'));

	Templates.AddItem(Manager.FindAbilityTemplate('DisableConsumeAllPoints'));

	Templates.AddItem(Manager.FindAbilityTemplate('Revive'));
	Templates.AddItem(Manager.FindAbilityTemplate('Panicked'));
	Templates.AddItem(Manager.FindAbilityTemplate('Berserk'));
	Templates.AddItem(Manager.FindAbilityTemplate('Obsessed'));
	Templates.AddItem(Manager.FindAbilityTemplate('Shattered'));

	return Templates;
}
