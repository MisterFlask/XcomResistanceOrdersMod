// This is an Unreal Script
class ILB_HeavyWeapons extends XMBAbility config(Abilities);

var config WeaponDamageValue SMALLERFLAMETHROWER_BASEDAMAGE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	//Weapons.AddItem(SmallerFlamethrower());
	//Weapons.AddItem(class'X2Ability_HeavyWeapons'.static.Flamethrower('ILB_FireSmallerFlamethrower'));
	return Weapons;
}

//we're just copying the regular flamethrower template and making targeted edits, specifically to damage
/*

TODO ON THIS:  REMOVE THING WHERE I'M INSTANTIATING OTHER TEMPLATE THEN MODIFYING, I AM TOLD THIS IS BAD
static function X2DataTemplate SmallerFlamethrower(){
	local X2WeaponTemplate Template;
	`LOG("Registering small flamethrower");
	Template = class'X2Item_HeavyWeapons'.static.Flamethrower();
	
	Template.InventorySlot = eInvSlot_SeptenaryWeapon;
	Template.StowedLocation = eSlot_HeavyWeapon;
	Template.SetTemplateName('ILB_SmallerFlamethrower');
	Template.BaseDamage = default.SMALLERFLAMETHROWER_BASEDAMAGE;
	Template.RewardDecks.RemoveItem('ExperimentalHeavyWeaponRewards');
	Template.Abilities.RemoveItem('Flamethrower');
	Template.Abilities.AddItem('ILB_FireSmallerFlamethrower');
	return Template;
}
*/