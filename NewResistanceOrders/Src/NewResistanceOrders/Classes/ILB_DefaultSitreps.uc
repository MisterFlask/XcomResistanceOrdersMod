// This is an Unreal Script

class ILB_DefaultSitreps extends X2StrategyElement
	dependson(X2RewardTemplate)
	config(GameData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Sitreps;
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep('ILB_Sitrep_AdventCrackdown_HeavilyArmored','BlastPadding')); // ADVENT Crackdown: Hokmah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep('ILB_Sitrep_AdventCrackdown_Shadowstep','Shadowstep')); // ADVENT Crackdown: Binah Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep('ILB_Sitrep_AdventCrackdown_IncendiaryRounds','IncendiaryRounds'));  // ADVENT Crackdown:  Chesed Cadre
	Sitreps.AddItem(GrantAlienTeamAbilitySitrep('ILB_Sitrep_AdventCrackdown_PoisonClouds','ILB_PoisonImmunity', 'ILB_BrutePoison'));  //ADVENT Crackdown:  Netzah Cadre

	return Sitreps;
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

static function X2SitRepEffectTemplate GrantAlienTeamAbilitySitrep(name SitrepName, name AbilityName, optional name SecondaryAbilityName = '')
{
	local X2SitRepEffect_GrantAbilities Template;

	`CREATE_X2TEMPLATE(class'X2SitRepEffect_GrantAbilities', Template, SitrepName);

	Template.AbilityTemplateNames.AddItem(AbilityName);
	Template.GrantToSoldiers = false;
	Template.Teams.AddItem(eTeam_Alien);
	if (SecondaryAbilityName != ''){
		Template.AbilityTemplateNames.AddItem(SecondaryAbilityName);
	}
	return Template;
}

