class ILB_Grimy_Effect_BonusWeaponDamage extends X2Effect_Persistent;

var int Bonus;
var array<name> WeaponNames;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	if ( WeaponNames.Find(AbilityState.GetSourceWeapon().GetMyTemplateName()) != INDEX_NONE || WeaponNames.Find(AbilityState.GetSourceAmmo().GetMyTemplateName()) != INDEX_NONE ) {
		return Bonus;
	}
	return 0;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Allow
}