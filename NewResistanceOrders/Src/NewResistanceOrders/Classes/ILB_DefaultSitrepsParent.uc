class ILB_DefaultSitrepsParent extends X2SitRep;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Sitreps;

	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_AdventCrackdown_HeavilyArmored')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_AdventCrackdown_Shadowstep')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_AdventCrackdown_ReturnFire')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_AdventCrackdown_PoisonClouds')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_TougherFieldCommander')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_PlusOneForceLevel')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_PlusTwoForceLevel')); 
	Sitreps.AddItem(CreateNegativeSitrepMatchingName('ILB_Sitrep_PlusThreeForceLevel')); 

	return Sitreps;
}

static function X2SitRepTemplate CreateNegativeSitrepMatchingName(name TemplateName){
	local X2SitRepTemplate  Template;
	`CREATE_X2TEMPLATE(class'X2SitRepTemplate', Template, TemplateName);
	Template.NegativeEffects.AddItem(name(TemplateName $ "_Effect"));
	Template.bNegativeEffect = true;
	Template.ValidMissionFamilies.AddItem("NONE"); // this is a dummy value intended to prevent spawning randomly
	return Template;
}