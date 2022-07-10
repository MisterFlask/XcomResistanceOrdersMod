class ILB_DefaultSitreps extends X2SitRepEffect
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Sitreps;
	local X2DataTemplate CurrentItem;
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_HeavilyArmored','BlastPadding')); // ADVENT Crackdown: Hokmah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_Shadowstep','Shadowstep')); // ADVENT Crackdown: Binah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_ReturnFire','ReturnFire'));  // ADVENT Crackdown:  Chesed Cadre //TODO: Replace with return-fire-for-primaries
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_PoisonClouds','ILB_PoisonImmunity', 'ILB_BrutePoison'));  //ADVENT Crackdown:  Netzah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_TougherFieldCommander','BlastPadding', 'ILB_LotsOfShielding', 'AdvGeneralM1'));  //TODO: Fix so that it works for M2 and M3 also

	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 1, 'ILB_Sitrep_PlusOneForceLevel'));
	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 2, 'ILB_Sitrep_PlusTwoForceLevel'));
	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 3, 'ILB_Sitrep_PlusThreeForceLevel'));
	
	foreach Sitreps(CurrentItem){
		`LOG("found sitrep/effect: " $ CurrentItem.DataName);
	}

	return Sitreps;
}


static function name GetRandomForceLevelIncreaseSitrep(int maxForceLevel){
	local int RandomValue;

	RandomValue = Rand(maxForceLevel + 1);

	if (RandomValue == 0){
		return '';
	}
	if (RandomValue == 1){
		return 'ILB_Sitrep_PlusOneForceLevel';
	}
	if (RandomValue == 2){
		return 'ILB_Sitrep_PlusTwoForceLevel';
	}
	if (RandomValue == 3){
		return 'ILB_Sitrep_PlusThreeForceLevel';
	}

	return '';
}

static function array<name> CrackdownSitreps()
{
	local array<name> Sitreps;
	Sitreps.AddItem('ILB_Sitrep_AdventCrackdown_HeavilyArmored');
	Sitreps.AddItem('ILB_Sitrep_AdventCrackdown_Shadowstep');
	// Sitreps.AddItem('ILB_Sitrep_AdventCrackdown_PoisonClouds'); // TODO: Fix the fact that this doesn't actually make a poison cloud?
	// Sitreps.AddItem('ILB_Sitrep_AdventCrackdown_ReturnFire');//TODO: Replace with primary weapon perk
	return Sitreps;
}

static function X2SitRepEffectTemplate CreateForceLevelIncreaseByNEffectTemplate(out array<X2DataTemplate> Sitreps, int ForceLevelChange, name SitrepName)
{
	local X2SitRepEffect_ModifyForceLevel Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyForceLevel', Template, name(SitrepName $ "_Effect"));

	Template.ForceLevelModification = ForceLevelChange;
	Template.MaxForceLevel = 20;

	return Template;
}

static function X2SitRepEffectTemplate GrantAlienTeamAbilitySitrep(out array<X2DataTemplate> Sitreps, name SitrepName, name AbilityName, optional name SecondaryAbilityName = '', optional name SpecificTemplateThisAppliesTo = '')
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, name(SitrepName $ "_Effect"));
	
	Template.GrantToSoldiers = false;
	Template.Teams.AddItem(eTeam_Alien);

	Template.AbilityTemplateNames.AddItem(AbilityName);
	if (SecondaryAbilityName != ''){
		Template.AbilityTemplateNames.AddItem(SecondaryAbilityName);
	}
	
	if (SpecificTemplateThisAppliesTo != ''){
		Template.CharacterTemplateNames.AddItem(SpecificTemplateThisAppliesTo);
	}
	return Template;
}

