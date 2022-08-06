class ILB_Utils extends X2StrategyElement_XpackResistanceActions config(ResCards);

	static function bool DoesSoldierHaveRocketLauncher(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'RocketLauncher');
	}
	static function bool DoesSoldierHaveGrenadeLauncher(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'grenade_launcher');
	}
	static function bool DoesSoldierHaveGremlin(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'gremlin');
	}

	static function bool DoesSoldierHaveBlade(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'sword') 
			|| DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'combatknife')
			|| DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'wristblade');
	}

	static function bool DoesSoldierHavePistol(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'pistol');
	}

	static function bool DoesSoldierHaveMindShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'psidefense');
	}

	static function bool DoesSoldierHaveDefensiveVest(XComGameState_Unit UnitState){
		return DoesSoldierHaveSpecificItem(UnitState, 'NanofiberVest');
	}

	static function bool DoesSoldierHaveShield(XComGameState_Unit UnitState){
		return DoesSoldierHaveItemOfWeaponOrItemClass(UnitState, 'shield');
	}

    static function bool DoesSoldierHaveBladeInPrimarySlot(XComGameState_Unit UnitState){
        return DoesSoldierHaveItemInPrimarySlot(UnitState, 'sword')
            || DoesSoldierHaveItemInPrimarySlot(UnitState, 'combatknife')
            || DoesSoldierHaveItemInPrimarySlot(UnitState, 'wristblade');
    }

    static function bool DoesSoldierHaveBladeInPrimaryOrSecondarySlot(XComGameState_Unit UnitState){
        return DoesSoldierHaveBladeInPrimarySlot(UnitState) || DoesSoldierHaveBladeInSecondarySlot(UnitState);
    }

    static function bool DoesSoldierHaveBladeInSecondarySlot(XComGameState_Unit UnitState){
        return DoesSoldierHaveItemInSecondarySlot(UnitState, 'sword')
            || DoesSoldierHaveItemInSecondarySlot(UnitState, 'combatknife')
            || DoesSoldierHaveItemInSecondarySlot(UnitState, 'wristblade');
    }
    
    static function XComGameState_Item GetEquippedBlade(XComGameState_Unit UnitState){
        local XComGameState_Item CurrentItem;
        local name CurrentWeaponCat;
        local array<name> BladedWeapons;
        BladedWeapons.AddItem('sword');
        BladedWeapons.AddItem('combatknife');
        BladedWeapons.AddItem('wristblade');

        foreach BladedWeapons(CurrentWeaponCat){
            CurrentItem = GetEquippedWeaponOfCategory(UnitState, CurrentWeaponCat);
            if(CurrentItem != none){
                return CurrentItem;
            }
        }
        return none;
    }
    
    static function XComGameState_Item GetEquippedWeaponOfCategory(XComGameState_Unit UnitState, name WeaponCategory){
        local XComGameState_Item CurrentItem;
        local array<XComGameState_Item> ItemList;

        ItemList=  UnitState.GetAllInventoryItems();
        foreach ItemList(CurrentItem){
            if(CurrentItem.GetWeaponCategory() == WeaponCategory){
                return CurrentItem;
            }
        }

        return none;
    }

    static function bool DoesSoldierHaveItemInPrimarySlot(XComGameState_Unit UnitState, name Classification){

        return UnitState.GetPrimaryWeapon().GetWeaponCategory() == Classification;
    }
    static function bool DoesSoldierHaveItemInSecondarySlot(XComGameState_Unit UnitState, name Classification){
        
        return UnitState.GetSecondaryWeapon().GetWeaponCategory() == Classification;
    }   

	//VALIDATED
	static function bool DoesSoldierHaveSpecificItem(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name ItemCat;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{
				// check item's type
				ItemCat =  ItemState.GetMyTemplate().DataName;
				if (ItemCat == Classification){
					return true;
				}
			}
		}
		return false;
	}
	
	static function bool DoesSoldierHaveArmorOfClass(XComGameState_Unit UnitState, name Classification){
	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local X2ArmorTemplate Armor;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{

				Armor = X2ArmorTemplate(ItemState.GetMyTemplate());
				if (Armor == none){
					continue;
				}
				if (Armor.ArmorClass == Classification){
					`LOG("Found armor of desired class " $ Classification);
					return true;
				}
				if (Armor.ArmorCat == Classification){
					`LOG("Found armor of desired armorcat " $ Classification);
					return true;
				}
				
			}
		}
		return false;
	}

	///VALIDATED.
	static function bool DoesSoldierHaveItemOfWeaponOrItemClass(XComGameState_Unit UnitState, name Classification)
	{	
		local XComGameStateHistory History;
		local StateObjectReference ItemRef;
		local XComGameState_Item ItemState;
		local name WeaponCat;
		local name ItemCat;
		`assert(UnitState != none);

		History = `XCOMHISTORY;
		`Log("SEARCHING for item of weapon or item cat: " $ string(Classification));

		foreach UnitState.InventoryItems(ItemRef)
		{
			ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
			if(ItemState != none)
			{
				WeaponCat=ItemState.GetWeaponCategory();
				`Log("Soldier has item of weaponcat: " $ WeaponCat);
				// check item's type
				if (WeaponCat == Classification){
					`Log("Soldier DOES have item of DESIRED weaponcat: " $ WeaponCat);
					return true;
				}

				ItemCat = ItemState.GetMyTemplate().ItemCat;
				`Log("Soldier has item of itemcat: " $ ItemCat);
				if (ItemCat == Classification){
					`Log("Soldier DOES have item of DESIRED itemcat: " $ ItemCat);
					return true;
				}
			}
		}
		return false;
	}

	static function bool SoldierHasPistol(XComGameState_Unit Unit){
		return DoesSoldierHaveItemOfWeaponOrItemClass(Unit, 'pistol');
	}

	static function XComGameState_StrategyCard GetCardState(StateObjectReference CardRef)
	{
		return XComGameState_StrategyCard(`XCOMHISTORY.GetGameStateForObjectID(CardRef.ObjectID));
	}

	//---------------------------------------------------------------------------------------


	static function bool IsPlotType(string plotTypeDesired){
	    local PlotDefinition PlotDef;
        local XComGameStateHistory History;
        local XComGameState_BattleData BattleData;
        local string plotType;


        History = `XCOMHISTORY;
        BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
        PlotDef = `PARCELMGR.GetPlotDefinition(BattleData.MapData.PlotMapName);
        plotType =  PlotDef.strType;

        if (plotType != plotTypeDesired){
                `log("Plot type is not " $ plotTypeDesired $ " but is instead" $ plotType);
				return false;
        }else{
            `log("Plot type is " $ plotTypeDesired );
			return true;
		}
	}


static function bool IsResistanceOrderActive(name ResistanceOrderName){
	local XComGameState_StrategyCard CardState;
	local StateObjectReference CardRef;
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;
	local XComGameState_Continent ContinentState;
	
	local XComGameState_HeadquartersResistance ResHQ;
	History = `XCOMHISTORY;
	//`Log("Checking over every single resistance order to see if it's the one we want; looking for: " $ ResistanceOrderName);
	// go over each card active for each faction
	
	ResHQ = GetResistanceHQ();

	// First, going over faction-agnostic card slots
	foreach ResHQ.WildCardSlots(CardRef)
	{
		if(CardRef.ObjectID != 0)
		{
			CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
			if (CardState.GetMyTemplateName() == ResistanceOrderName)
			{
				`Log("This card IS the card I want: " $ CardState.GetMyTemplateName() );
				return true;
			}
			else
			{
				//`Log("This faction order is NOT the one I want: " $ CardState.GetMyTemplateName());
			}
		}
	}

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		//`Log("Checking over every single order in this faction to see if it's the one we want: " $ FactionState.GetMyTemplateName());

		// for each faction checking each card slot in turn
		foreach FactionState.CardSlots(CardRef)
		{
			if(CardRef.ObjectID != 0)
			{
				CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(CardRef.ObjectID));
				if (CardState.GetMyTemplateName() == ResistanceOrderName)
				{
					`Log("This card IS the card I want: " $ CardState.GetMyTemplateName() );
					return true;
				}
				else
				{
					//`Log("This faction order is NOT the one I want: " $ FactionState.GetMyTemplateName());

				}
			}
		}
	}

	`LOG("Going over continent bonuses.");

	// go over continent bonuses
	foreach History.IterateByClassType(class'XComGameState_Continent', ContinentState){
		CardState = XComGameState_StrategyCard(History.GetGameStateForObjectID(ContinentState.ContinentBonusCard.ObjectID));
		if (CardState == none){
			`LOG("Couldn't find continent bonus for object id!");
		}
        `LOG("observed possible continent bonus: " $ CardState.GetMyTemplateName());

		if (CardState.GetMyTemplateName() == ResistanceOrderName){
			if (ContinentState.bContinentBonusActive){
				`LOG("successfully found targeted card as ACTIVE continent bonus: " $ ResistanceOrderName);
				return true;
			} else {
				`LOG("observed targeted card as INACTIVE continent bonus: " $ ResistanceOrderName);
			}
		}
	}

	
	return false;
}


static function XComGameState_HeadquartersResistance GetResistanceHQ()
{
	return XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
}