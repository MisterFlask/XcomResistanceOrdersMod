class ILB_Utils extends X2StrategyElement_XpackResistanceActions config(ResCards);

    struct ResistanceCardRewardMod{
		var name ApplicableMissionFamilyIfAny;
		var name ApplicableMissionSourceIfAny; //
        var name RewardApplied; //Reward_Supplies
        var int	RewardQuantity;
        var int	RewardVariance;
    };
    struct ResistanceCardSitrepMod{
		var name ApplicableMissionFamilyIfAny;
		var name ApplicableMissionSourceIfAny; //
        var name SitrepApplied;
    };
    struct ResistanceCardConfigValues{
        var name ResCardName;
        var string StringValue0;
        var string StringValue1;

        var int IntValue0; // magic integer
        var int IntValue1; // magic integer
        var int IntValue2; // magic integer
        var int Priority; // default is 0; highest priority wins
        var array<ResistanceCardRewardMod> RewardMods;
        var array<ResistanceCardSitrepMod> SitrepMods;
    };

    var config array<ResistanceCardConfigValues> ResistanceCardFlexibleConfigs;


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

    static function bool DoesSoldierHaveAbility(XComGameState_Unit UnitState, name AbilityName){
        if (UnitState.FindAbility(AbilityName).ObjectID <= 0){
            return false;
        }else{
            return true;
        }
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


static function ResistanceCardConfigValues ResCardConf(name ResCardId, int intValue1, int intValue2 = -1){
	local ResistanceCardConfigValues Values;
	Values.ResCardName = ResCardId;
	Values.StringValue0 = string(intValue1);
	Values.StringValue1 = string(intValue2);
	return Values;
}

static function XComGameState_HeadquartersResistance GetResistanceHQ()
{
	return XComGameState_HeadquartersResistance(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersResistance'));
}

// This function is criminally inefficient, I am so so sorry
static function array<ResistanceCardConfigValues> DedupeResistanceCardConfigs(array<ResistanceCardConfigValues> OriginalValues){
    local ResistanceCardConfigValues CandidateBestCardConfigs;
    local array<name> CardsAlreadyGrabbed;
    local ResistanceCardConfigValues Current;
    local array<ResistanceCardConfigValues> DedupedValues;
    
    foreach OriginalValues(Current){
        // below function grabs the highest-priority card matching the template name
        CandidateBestCardConfigs = GetResistanceCardConfigsForResCard(Current.ResCardName, OriginalValues);
        if (CardsAlreadyGrabbed.Find(CandidateBestCardConfigs.ResCardName) == -1){
            DedupedValues.AddItem(CandidateBestCardConfigs);
            CardsAlreadyGrabbed.AddItem(CandidateBestCardConfigs.ResCardName);
        }
    }
    
    return DedupedValues;
}

// returns the HIGHEST-PRIORITY versions of each res card config.
static function array<ResistanceCardConfigValues> GetResistanceCardConfigs(){
    local ResistanceCardConfigValues CurrentValue;
	local array<ResistanceCardConfigValues> ResistanceCardConfigs;

    foreach default.ResistanceCardFlexibleConfigs(CurrentValue){
        ResistanceCardConfigs.AddItem(CurrentValue);
    }

	//Costs 4 avenger power; only functions when not at power deficit. All soldiers' electric abilities deal 2 extra damage. 
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RemoteSuperchargers', class'ILB_AdditionalResistanceOrders_ResCards'.default.SUPERCHARGER_POWER_DRAIN, class'ILB_AdditionalResistanceOrders_Abilities'.default.AVENGER_SUPERCHARGER_ELECTRIC_DAMAGE_BUFF));// 
	//Lose 15% research speed.  Gain +3 resistance contacts
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_LabToCommsRepurposing', class'ILB_StrategicResCards'.default.LABS_TO_COMMS_RESEARCH_PENALTY, class'ILB_StrategicResCards'.default.LABS_TO_COMMS_COMMS_BONUS));
	//Gain +4 avenger power.  Guerilla Ops and Council missions have a +15% chance of an ADVENT crackdown sitrep
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_LeachPsionicLeylines', class'ILB_StrategicResCards'.default.LEACH_PSIONIC_LEYLINES_POWER_BONUS, 15));
	// ResCard_RescueUpperCrustContacts
	//Grants a monthly covert action that spawns a Swarm Defense Recover VIP mission.  This mission rewards 75-125 supply on completion instead of its typical reward.
	
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RescueUpperCrustContacts', 75, 125));
	
	// ResCard_StealSparkCore
	//"Grants a monthly covert action that spawns a Recover Item mission with an increased force level of between 0 and 1.  This mission rewards a Spark instead of its typical reward on completion."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_StealSparkCore', 0, 1));
	
	// ResCard_BrazenRecruitment
	/// "There is a +15% chance of an ADVENT crackdown..."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BrazenRecruitment',15,-1));

	//ResCard_BrazenCollection
	//Gain +25% extra supplies from drops.   There is a +15% chance of an ADVENT crackdown sitrep on all guerilla ops and council missions.
	
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BrazenCollection',class'ILB_StrategicResCards'.default.BRAZEN_COLLECTION_BONUS, 15));

	// ResCard_GrndlPowerDeal
	//Gain +5 Avenger power.   Also, gain -25% supplies from supply drops."
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_GrndlPowerDeal',class'ILB_StrategicResCards'.default.GRNDL_POWER_DEAL_POWER_BONUS, class'ILB_StrategicResCards'.default.GRNDL_POWER_DEAL_SUPPLY_PENALTY));

	// 
	//Black Market goods are at a 25% discount.  There is a +15% chance of an ADVENT crackdown on all guerilla ops and council missions
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_NotoriousSmugglers',class'ILB_StrategicResCards'.default.NOTORIOUS_SMUGGLERS_BLACK_MARKET_DISCOUNT, 15));

	/*
[ResCard_RadioFreeLily X2StrategyCardTemplate]
DisplayName="Radio Free Lily"
SummaryText="You gain +2 resistance contacts.  Retaliations are at +1 force level."

	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_RadioFreeLily',class'ILB_StrategicResCards'.default.RADIO_FREE_LILY_COMMS_BONUS, 1));

	/*
[ResCard_CouncilBounties X2StrategyCardTemplate]
DisplayName="Council Bounties"
SummaryText="Grants a monthly covert action that spawns a Neutralize Field Commander mission.  The field commander is tougher on this mission.  This mission rewards 75-125 supply on completion."
	*/
	//ResistanceCardConfigs.AddItem(ResCardConf('ResCard_CouncilBounties', 75, 125));
    // moved to flexible configs
	/*
	ResCard_PowerCellRepurposing
	Successfully securing UFOs grants the Avenger 2 additional power PERMANENTLY, as well as a random heavy weapon.  Destroy Device missions grant an additional 15 Elereum."
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_PowerCellRepurposing', 2, 15)); //todo

	/*
	ResCard_SupplyRaidsForHacks
	"Successful Hack missions generate a Supply Raid and grant 30 additional intel"
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_SupplyRaidsForHacks', 30, -1)); //todo

	/*
	ResCard_EducatedVandalism
	Destroy Object and Sabotage Transmitter missions grant additional 15 alien alloys on completion
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_EducatedVandalism', 15, -1)); //todo

	/*
	ResCard_IncitePowerVacuum
	Neutralize VIP and Neutralize Field Commander missions both reduce the Avatar counter by 14 days apiece.
	*/
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_IncitePowerVacuum', 14, -1)); //todo

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_YouOweMe', 40, -1)); //todo

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_HexHunterForMindShields', class'ILB_AdditionalResistanceOrders_Abilities'.default.ILB_WITCH_HUNTER_PASSIVE_DMG, -1));

	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_OberonExploit', (1 - class'ILB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF) * 100, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_Promethium', class'ILB_AdditionalResistanceOrders_Abilities'.default.ILB_PROMETHIUM_FIRE_DMG_BONUS, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_GrantRookiesPermaHp', class'ILB_AdditionalResistanceOrders_Abilities'.default.ROOKIE_COMBAT_HP_BONUS, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_MindTaker', (1 - class'ILB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF_MINDGORGER) * 100, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_BetterMelee', class'ILB_AdditionalResistanceOrders_Abilities'.default.ILB_MELEE_DMG_BUFF, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_SendInTheNextWave', 15, -1));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_MachineBuffsIfAridClimate', class'ILB_AdditionalResistanceOrders_Abilities'.default.ILB_DAWN_MACHINES_SHIELDS_BUFF, class'ILB_AdditionalResistanceOrders_Abilities'.default.ILB_DAWN_MACHINES_MOBILITY_BUFF));
	ResistanceCardConfigs.AddItem(ResCardConf('ResCard_MabExploit', (1 - class'ILB_AdditionalResistanceOrders_Abilities'.default.HACK_DEFENSE_DEBUFF_TUNDRA) * 100, -1));

	/*
[ X2StrategyCardTemplate]
SummaryText="Recover Resistance Operative missions and Extract VIP missions grant an extra 40 supply on successful completion."

[ResCard_MassivePopularity X2StrategyCardTemplate]
SummaryText="Gain a promotable Rookie on successful completion of a Retaliation mission."

[ResCard_TunnelRats X2StrategyCardTemplate]
SummaryText="Missions in the Sewers or Subways allow each soldier with a shotgun or assault rifle to reenter concealment once per mission, as per the Conceal ability."

[ResCard_ForgedPapers X2StrategyCardTemplate]
SummaryText="Missions in Small Towns allow each soldier to reenter concealment once per mission, as per the Conceal ability.  If you have at least 3 Skirmisher cards active, this also applies to City Centers."

[ResCard_FlashpointForGrenadiers X2StrategyCardTemplate]
SummaryText="Grenade launchers make flashbangs deal 2 Fire damage in addition to their regular effects."

[ResCard_HexHunterForMindShields X2StrategyCardTemplate]
SummaryText="Your soldiers with a Mind Shield gain the Witch Hunter perk (additional 2 passive damage vs. psionic enemies.)"

[ResCard_BladesGrantShellbust X2StrategyCardTemplate]
SummaryText="Your sword or knife-carrying soldiers gain Shellbust Stab (massive armor shred melee attack)"

// [ResCard_PracticalOccultism X2StrategyCardTemplate]
// SummaryText="Your Reapers can cloak themselves for an HP cost, and can also teleport to anywhere within squadsight, also with an HP cost."

// [ResCard_BetterMelee X2StrategyCardTemplate]
// SummaryText="Your soldiers all deal +1 melee damage.  Additionally, they have an increased likelihood to bleed out rather than die outright."

// [ResCard_Promethium X2StrategyCardTemplate]
// SummaryText="Flamethrower-based abilities deal 2 more damage.  Additionally, flamethrower-based abilities gain another charge.  (This also applies to fire-based chemthrower abilities.)"

// [ResCard_GrantRookiesPermaHp X2StrategyCardTemplate]
// SummaryText="Whenever you send a Rookie on a combat mission, they get a PERMANENT +2 max HP (once per rookie)."


// 	return ResistanceCardConfigs;
// }

// static function ResCardConf(name ResCardId, int intValue1, int intValue2 = -1)
// {
// 	local ResistanceCardConfigValues ResistanceCardConfigValues;

// 	ResistanceCardConfigValues.StringValue1 = string(intValue1);
// 	ResistanceCardConfigValues.StringValue2 = string(intValue2);

[ResCard_ResUnitIfRetaliation X2StrategyCardTemplate]
SummaryText="Gain a bonus Resistance soldier at the beginning of each Retaliation mission."

[ResCard_AdventUnitIfLessThanFullSquad X2StrategyCardTemplate]
SummaryText="Gain a bonus ADVENT soldier at the beginning of each mission where you're fielding fewer than six soldiers."

[ResCard_MabExploit X2StrategyCardTemplate]
SummaryText="In Tundra climates, all MECs and Turrets have -70% hack defense."

[ResCard_MachineBuffsIfAridClimate X2StrategyCardTemplate]
SummaryText="In non-Arid climates, your mechanical units gain +4 shielding.  In Arid climates, your mechanical units gain +3 mobility and +8 shielding.  Only applies to mechanical units that cannot take cover.  You can purchase MEC wrecks in the Black Market."

[ResCard_SendInTheNextWave X2StrategyCardTemplate]
SummaryText="Your recruits cost 15.  Rookies and Squaddies gain the Beatdown perk (deal a small amount of melee damage, but stun for a turn)"

[ResCard_OberonExploit X2StrategyCardTemplate]
SummaryText="ADVENT turrets lose -70% hack defense."

[ResCard_PracticalOccultism X2StrategyCardTemplate]
SummaryText="Your Reapers can cloak themselves for an HP cost, and can also teleport to anywhere within squadsight, also with an HP cost."

[ResCard_BetterMelee X2StrategyCardTemplate]
SummaryText="Your soldiers all deal +1 melee damage.  Additionally, they have an increased likelihood to bleed out rather than die outright."

[ResCard_Promethium X2StrategyCardTemplate]
SummaryText="Flamethrower-based abilities deal 2 more damage.  Additionally, flamethrower-based abilities gain another charge.  (This also applies to fire-based chemthrower abilities.)"

[ResCard_GrantRookiesPermaHp X2StrategyCardTemplate]
SummaryText="Whenever you send a Rookie on a combat mission, they get a PERMANENT +2 max HP (once per rookie)."

	*/
	return DedupeResistanceCardConfigs(ResistanceCardConfigs);
}

    static function ResistanceCardConfigValues GetResistanceCardConfig(name ResCardId){
        local array<ResistanceCardConfigValues> empty;
        return GetResistanceCardConfigsForResCard(ResCardId, empty);
    }

	static function ResistanceCardConfigValues GetResistanceCardConfigsForResCard(name ResCardName, array<ResistanceCardConfigValues> AllPossibleCards){
		local ResistanceCardConfigValues Current;
        local ResistanceCardConfigValues BestMatchingCard;
        BestMatchingCard.ResCardName = '';
        if (AllPossibleCards.Length == 0){
            AllPossibleCards = GetResistanceCardConfigs();
        }

		foreach AllPossibleCards(Current){
			if (ResCardName == Current.ResCardName){
				if (BestMatchingCard.ResCardName == ''){
                    BestMatchingCard = Current;
                }

                if (BestMatchingCard.Priority < Current.Priority){
                    BestMatchingCard = Current;
                }
			}
		}

		if (BestMatchingCard.ResCardName == ''){
			`LOG("ILB ERROR:  Cannot find res card matching name " $ ResCardName);
		}

		return BestMatchingCard;

	}


// returns a random contacted region
static function StateObjectReference ChooseRandomContactedRegion()
{
	local XComGameStateHistory History;
	local XComGameState_WorldRegion RegionState;
	local array<StateObjectReference> RegionRefs;

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_WorldRegion', RegionState)
	{
		if (RegionState.HaveMadeContact()){
			RegionRefs.AddItem(RegionState.GetReference());
		}
	}

	return RegionRefs[`SYNC_RAND_STATIC(RegionRefs.Length)];
}
