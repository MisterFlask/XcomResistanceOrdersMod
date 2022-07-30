class ILB_Grimy_BonusDamage_Effect extends X2Effect_Persistent;

var float Bonus;
var name AbilityName;
var int BaseDamage, TierMult;
var bool bExcludeRobotic;
var bool bExcludeOrganic;
var bool bDOTOnly;
var bool bMainOnly;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) {
	local X2WeaponTemplate WeaponTemplate;

	if (AbilityState.GetMyTemplateName() != AbilityName) { return 0; }
	if (bExcludeRobotic && XComGameState_Unit(TargetDamageable).GetMyTemplate().bIsRobotic) { return 0; }
	if (bExcludeOrganic && !XComGameState_Unit(TargetDamageable).GetMyTemplate().bIsRobotic) { return 0; }
	if ( bDOTOnly && AppliedData.EffectRef.ApplyOnTickIndex < 0 ) { return 0; }
	if ( bMainOnly && AppliedData.EffectRef.ApplyOnTickIndex > -1) {return 0; }

	if ( BaseDamage > 0 && TierMult != 0) {
		if ( AbilityState.GetSourceWeapon() != none ) {
			WeaponTemplate = X2WeaponTemplate(AbilityState.GetSourceWeapon().GetMyTemplate());
			if (WeaponTemplate != none) {

				Switch ( WeaponTemplate.WeaponTech )
				{
					case 'Beam':
						return BaseDamage + TierMult * 4;
					case 'Coil':
						return BaseDamage + TierMult * 3;
					case 'Magnetic':
						return BaseDamage + TierMult * 2;
					case 'Laser':
						return BaseDamage + TierMult * 1;
					default:
						return BaseDamage;
				}
				
			}
		}
	}

	return CurrentDamage * Bonus;
}

defaultproperties
{
	BaseDamage = 0
	TierMult = 0
	Bonus = 0
	bExcludeRobotic = false;
	bExcludeOrganic = false;
	bDOTOnly = false
	bMainOnly = false
}