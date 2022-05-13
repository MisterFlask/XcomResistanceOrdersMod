// This is an Unreal Script
// This is a modified version of the XMBEffect_AddUtilityItem
// Primary difference is that the inventory slot is configurable.
// Doing this implementation to allow the anarchist's heavy weapon skills to not require the weapons to be already equipped.
//
// based on code by: xylthixlm

class MZ_Effect_AddSevenWeapon extends X2Effect_Persistent;

///////////////////////
// Effect properties //
///////////////////////

var name DataName;							// The name of the item template to grant.
var int BaseCharges;						// Number of charges of the item to add.
var int BonusCharges;						// Number of extra charges of the item to add for each item of that type already in the inventory.
var bool bUseHighestAvailableUpgrade;		// If true, grant the highest available upgraded version of the item.
var array<name> SkipAbilities;				// List of abilities to not add
var EInventorySlot InvSlotEnum;				//which slot to put it in.
var int MaxCharges;

struct AbilityBonusAmmo {
	var name AbilityName;
	var int AmmoBonus;
};

var array<AbilityBonusAmmo> AbilityForBonusAmmo;

function AddBonusAmmoAbility(name AbilityName, int Ammo)
{
	local AbilityBonusAmmo	BonusAmmo;

	BonusAmmo.AbilityName = AbilityName;
	BonusAmmo.AmmoBonus = Ammo;

	AbilityForBonusAmmo.AddItem(BonusAmmo);
}


////////////////////
// Implementation //
////////////////////

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2ItemTemplate ItemTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Unit NewUnit;

	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	if (class'XMBEffectUtilities'.static.SkipForDirectMissionTransfer(ApplyEffectParameters))
		return;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	ItemTemplate = ItemTemplateMgr.FindItemTemplate(DataName);
	
	// Use the highest upgraded available version of the item
	if (bUseHighestAvailableUpgrade)
		`XCOMHQ.UpdateItemTemplateToHighestAvailableUpgrade(ItemTemplate);

	AddUtilityItem(NewUnit, ItemTemplate, NewGameState, NewEffectState);
}

simulated function AddUtilityItem(XComGameState_Unit NewUnit, X2ItemTemplate ItemTemplate, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2EquipmentTemplate EquipmentTemplate;
	local X2WeaponTemplate WeaponTemplate;
	local XComGameState_Item ItemState;
	local X2AbilityTemplateManager AbilityTemplateMan;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameStateHistory History;
	local name AbilityName;
	local array<SoldierClassAbilityType> EarnedSoldierAbilities;
	local XGUnit UnitVisualizer;
	local int idx;
	local int AmmoCount;
	local AbilityBonusAmmo	BonusAmmo;

	History = `XCOMHISTORY;

	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	EquipmentTemplate = X2EquipmentTemplate(ItemTemplate);
	if (EquipmentTemplate == none)
	{
		`RedScreen(`location $": Missing equipment template for" @ DataName);
		return;
	}

	AmmoCount = BaseCharges;
	foreach AbilityForBonusAmmo(BonusAmmo)
	{
		if ( NewUnit.HasSoldierAbility(BonusAmmo.AbilityName, true) )
		{
			AmmoCount += BonusAmmo.AmmoBonus;
		}
	}

	if (AmmoCount <= 0) { return; }
	if ( MaxCharges > 0 && AmmoCount > MaxCharges ) { AmmoCount = MaxCharges; }

	// Check for items that can be merged
	WeaponTemplate = X2WeaponTemplate(EquipmentTemplate);
	if (WeaponTemplate != none && WeaponTemplate.bMergeAmmo)
	{
		for (idx = 0; idx < NewUnit.InventoryItems.Length; idx++)
		{
			ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(NewUnit.InventoryItems[idx].ObjectID));
			if (ItemState == none)
				ItemState = XComGameState_Item(History.GetGameStateForObjectID(NewUnit.InventoryItems[idx].ObjectID));
			if (ItemState != none && !ItemState.bMergedOut && ItemState.GetMyTemplate() == WeaponTemplate)
			{
				ItemState = XComGameState_Item(NewGameState.ModifyStateObject(ItemState.class, ItemState.ObjectID));
				ItemState.Ammo += AmmoCount + ItemState.MergedItemCount * BonusCharges;
				return;
			}
		}
	}
	
	// No items to merge with, so create the item
	ItemState = EquipmentTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Ammo = AmmoCount;
	ItemState.Quantity = 0;  // Flag as not a real item

	// Temporarily turn off equipment restrictions so we can add the item to the unit's inventory
	NewUnit.bIgnoreItemEquipRestrictions = true;
	NewUnit.AddItemToInventory(ItemState, InvSlotEnum, NewGameState);
	NewUnit.bIgnoreItemEquipRestrictions = false;

	// Update the unit's visualizer to include the new item
	// Note: Normally this should be done in an X2Action, but since this effect is normally used in
	// a PostBeginPlay trigger, we just apply the change immediately.
	UnitVisualizer = XGUnit(NewUnit.GetVisualizer());
	UnitVisualizer.ApplyLoadoutFromGameState(NewUnit, NewGameState);

	NewEffectState.CreatedObjectReference = ItemState.GetReference();

	// Add equipment-dependent soldier abilities
	EarnedSoldierAbilities = NewUnit.GetEarnedSoldierAbilities();
	for (idx = 0; idx < EarnedSoldierAbilities.Length; ++idx)
	{
		AbilityName = EarnedSoldierAbilities[idx].AbilityName;
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);

		if (SkipAbilities.Find(AbilityName) != INDEX_NONE)
			continue;

		// Add utility-item abilities
		if (EarnedSoldierAbilities[idx].ApplyToWeaponSlot == InvSlotEnum &&
			EarnedSoldierAbilities[idx].UtilityCat == ItemState.GetWeaponCategory())
		{
			InitAbility(AbilityTemplate, NewUnit, NewGameState, ItemState.GetReference());
		}

		// Add grenade abilities
		if (AbilityTemplate.bUseLaunchedGrenadeEffects && X2GrenadeTemplate(EquipmentTemplate) != none)
		{
			InitAbility(AbilityTemplate, NewUnit, NewGameState, NewUnit.GetItemInSlot(EarnedSoldierAbilities[idx].ApplyToWeaponSlot, NewGameState).GetReference(), ItemState.GetReference());
		}
	}

	// Add abilities from the equipment item itself. Add these last in case they're overridden by soldier abilities.
	foreach EquipmentTemplate.Abilities(AbilityName)
	{
		if (SkipAbilities.Find(AbilityName) != INDEX_NONE)
			continue;

		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AbilityName);
		InitAbility(AbilityTemplate, NewUnit, NewGameState, ItemState.GetReference());
	}
}

simulated function InitAbility(X2AbilityTemplate AbilityTemplate, XComGameState_Unit NewUnit, XComGameState NewGameState, optional StateObjectReference ItemRef, optional StateObjectReference AmmoRef)
{
	local XComGameState_Ability OtherAbility;
	local StateObjectReference AbilityRef;
	local XComGameStateHistory History;
	local X2AbilityTemplateManager AbilityTemplateMan;
	local name AdditionalAbility;

	History = `XCOMHISTORY;
	AbilityTemplateMan = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	// Check for ability overrides
	foreach NewUnit.Abilities(AbilityRef)
	{
		OtherAbility = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

		if (OtherAbility.GetMyTemplate().OverrideAbilities.Find(AbilityTemplate.DataName) != INDEX_NONE)
			return;
	}

	AbilityRef = `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, ItemRef, AmmoRef);

	// Add additional abilities
	foreach AbilityTemplate.AdditionalAbilities(AdditionalAbility)
	{
		AbilityTemplate = AbilityTemplateMan.FindAbilityTemplate(AdditionalAbility);

		// Check for overrides of the additional abilities
		foreach NewUnit.Abilities(AbilityRef)
		{
			OtherAbility = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

			if (OtherAbility.GetMyTemplate().OverrideAbilities.Find(AbilityTemplate.DataName) != INDEX_NONE)
				return;
		}

		AbilityRef = `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, NewUnit, NewGameState, ItemRef, AmmoRef);
	}
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	if (RemovedEffectState.CreatedObjectReference.ObjectID > 0)
		NewGameState.RemoveStateObject(RemovedEffectState.CreatedObjectReference.ObjectID);
}

function UnitEndedTacticalPlay(XComGameState_Effect EffectState, XComGameState_Unit UnitState)
{
	local XComGameState NewGameState;

	NewGameState = UnitState.GetParentGameState();

	if (EffectState.CreatedObjectReference.ObjectID > 0)
		NewGameState.RemoveStateObject(EffectState.CreatedObjectReference.ObjectID);
}

defaultproperties
{
	BaseCharges = 1
	bUseHighestAvailableUpgrade = true
	InvSlotEnum = eInvSlot_Utility
}