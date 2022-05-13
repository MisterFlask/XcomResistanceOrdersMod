// This is an Unreal Script
class ILB_HeavyWeapons extends XMBAbility config(Abilities);
var config WeaponDamageValue SMALLERFLAMETHROWER_BASEDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	Weapons.AddItem(SmallerFlamethrower());

	return Weapons;
}

//we're just copying the regular flamethrower template and making targeted edits, specifically to damage
static function X2DataTemplate SmallerFlamethrower(){
	local X2WeaponTemplate Template;
	Template = class'X2Item_HeavyWeapons'.static.Flamethrower();

	Template.SetTemplateName('ILB_SmallerFlamethrower');
	Template.BaseDamage = default.SMALLERFLAMETHROWER_BASEDAMAGE;
	Template.RewardDecks.RemoveItem('ExperimentalHeavyWeaponRewards');
	Template.Abilities.RemoveItem('Flamethrower');
	Template.Abilities.AddItem('IRB_SmallerFlamethrower');
	return Template;
}