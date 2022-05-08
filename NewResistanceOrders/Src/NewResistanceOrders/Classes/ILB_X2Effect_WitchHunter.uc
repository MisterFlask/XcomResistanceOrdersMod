class ILB_X2Effect_WitchHunter extends X2Effect_Persistent;

var float Bonus;

// Deal 2 more damage if target has any level of psi offense
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local float PsiOffense;
	
	PsiOffense = XComGameState_Unit(TargetDamageable).GetMaxStat(eStat_PsiOffense);
	if (PsiOffense <= 1){
		return 0;
	}else{
		return Bonus;
	}

}