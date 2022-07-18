// This is an Unreal Script
class ILB_HeavyWeapons extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;
	Weapons.AddItem(CreateBrutePoison_WPN());
	//Weapons.AddItem(SmallerFlamethrower());
	//Weapons.AddItem(class'X2Ability_HeavyWeapons'.static.Flamethrower('ILB_FireSmallerFlamethrower'));
	return Weapons;
}

// This weapon, when added to a soldier's' utility items, will cause that soldier to emit poison when damaged.
static function X2DataTemplate CreateBrutePoison_WPN()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'ILB_BrutePoison_WPN');

	Template.ItemCat = 'defense';
	Template.WeaponCat = 'utility';
	Template.strImage = "img:///UILibrary_StrategyImages.InventoryIcons.Inv_SmokeGrenade";
	Template.EquipSound = "StrategyUI_Grenade_Equip";
	Template.GameArchetype = "WP_Grenade_Gas.WP_Grenade_Gas";
	Template.CanBeBuilt = false;	

	//Template.iRange = 14;
	Template.iRadius = 3;
	Template.iClipSize = 1;
	Template.InfiniteAmmo = true;

	Template.iSoundRange = 6;
	Template.bSoundOriginatesFromOwnerLocation = true;

	Template.BaseDamage.DamageType = 'Poison';

	Template.InventorySlot = eInvSlot_Utility;
	Template.StowedLocation = eSlot_None;
	Template.Abilities.AddItem('ILB_BrutePoison');

	return Template;
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