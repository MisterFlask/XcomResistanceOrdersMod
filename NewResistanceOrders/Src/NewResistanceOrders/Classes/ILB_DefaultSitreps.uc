// This is an Unreal Script

class ILB_DefaultSitreps extends X2StrategyElement
	dependson(X2SitRepTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Sitreps;
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_HeavilyArmored','BlastPadding')); // ADVENT Crackdown: Hokmah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_Shadowstep','Shadowstep')); // ADVENT Crackdown: Binah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_ReturnFire','IncendiaryRounds'));  // ADVENT Crackdown:  Chesed Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_AdventCrackdown_PoisonClouds','ILB_PoisonImmunity', 'ILB_BrutePoison'));  //ADVENT Crackdown:  Netzah Cadre
	
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep(Sitreps, 'ILB_Sitrep_TougherFieldCommander','BlastPadding', 'ILB_LotsOfShielding'));  //ADVENT Crackdown:  Netzah Cadre

	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 1, 'ILB_Sitrep_PlusOneForceLevel'));
	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 2, 'ILB_Sitrep_PlusTwoForceLevel'));
	Sitreps.AddItem(CreateForceLevelIncreaseByNEffectTemplate(Sitreps, 3, 'ILB_Sitrep_PlusThreeForceLevel'));
	
	return Sitreps;
}

static function X2SitRepTemplate GetBlankSitrepWithSameNamedSitrepEffect(name SitRepName){
	local X2SitRepTemplate Template;
	`CREATE_X2TEMPLATE(class'X2SitRepTemplate', Template, SitRepName);
	Template.bNegativeEffect = true;
	Template.NegativeEffects.AddItem(SitRepName);
	return Template;
}


static function name GetRandomForceLevelIncreaseSitrep(){
	local int RandomValue;

	RandomValue = Rand(4);

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

static function array<name> CrackdownSitreps(){
	local X2DataTemplate Template;
	local array<name> Sitreps;
	local array<X2DataTemplate> Templates;
	Templates = CreateTemplates();

	foreach Templates(Template){
		Sitreps.AddItem(Template.DataName);
	}
	return Sitreps;
}
static function X2SitRepEffectTemplate CreateForceLevelIncreaseByNEffectTemplate(out array<X2DataTemplate> Sitreps, int ForceLevelChange, name SitrepName)
{
	local X2SitRepEffect_ModifyForceLevel Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_ModifyForceLevel', Template, SitrepName);

	Template.ForceLevelModification = ForceLevelChange;
	Template.MaxForceLevel = 20;
	Sitreps.AddItem(GetBlankSitrepWithSameNamedSitrepEffect(SitrepName));

	return Template;
}

static function X2SitRepEffectTemplate GrantAlienTeamAbilitySitrep(out array<X2DataTemplate> Sitreps, name SitrepName, name AbilityName, optional name SecondaryAbilityName = '', optional name SpecificTemplateThisAppliesTo = '')
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, SitrepName);
	
	Template.AbilityTemplateNames.AddItem(AbilityName);
	Template.GrantToSoldiers = false;
	if (SpecificTemplateThisAppliesTo != ''){
		Template.CharacterTemplateNames.AddItem(SpecificTemplateThisAppliesTo);
	}
	Template.Teams.AddItem(eTeam_Alien);
	if (SecondaryAbilityName != ''){
		Template.AbilityTemplateNames.AddItem(SecondaryAbilityName);
	}

	Sitreps.AddItem(GetBlankSitrepWithSameNamedSitrepEffect(SitrepName));
	return Template;
}

