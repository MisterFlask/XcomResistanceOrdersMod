
class MissionGenerator extends XComGameState_GeoscapeEntity;


// WOTC TODO: There has to be a better way to implement this than copy all the
// relevant code from XComGameState_MissionSite with a few changes!
static function SetMissionData(name MissionFamily, XComGameState_MissionSite MissionState, X2RewardTemplate MissionReward, XComGameState NewGameState, bool bUseSpecifiedLevelSeed, int LevelSeedOverride)
{
	local GeneratedMissionData EmptyData;
	local XComTacticalMissionManager MissionMgr;
	local XComParcelManager ParcelMgr;
	local string Biome, MapName;
	// LWOTC vars
	local XComHeadquartersCheatManager CheatManager;
	local PlotDefinition SelectedPlotDef;
	local PlotTypeDefinition PlotTypeDef;
	local array<name> SourceSitReps;
	local name SitRepName;
	local array<name> SitRepNames;
	local String AdditionalTag;
	// End LWOTC vars
	// Variables for Issue #157
	local array<X2DownloadableContentInfo> DLCInfos; 
	local int i; 
	// Variables for Issue #157

	MissionMgr = `TACTICALMISSIONMGR;
	ParcelMgr = `PARCELMGR;

	MissionState.GeneratedMission = EmptyData;
	MissionState.GeneratedMission.MissionID = MissionState.ObjectID;
	
	MissionState.GeneratedMission.Mission = GetMissionDefinitionForFamily(MissionFamily);

	MissionState.GeneratedMission.LevelSeed = (bUseSpecifiedLevelSeed) ? LevelSeedOverride : class'Engine'.static.GetEngine().GetSyncSeed();
	MissionState.GeneratedMission.BattleDesc = "";

	// LWOTC - copied from WOTC `XComGameState_MissionSite.SetMissionData()`
	//
	// This block basically adds support for adding SitReps
	MissionState.GeneratedMission.SitReps.Length = 0;
	SitRepNames.Length = 0;

	// Add additional required plot objective tags
	foreach MissionState.AdditionalRequiredPlotObjectiveTags(AdditionalTag)
	{
		MissionState.GeneratedMission.Mission.RequiredPlotObjectiveTags.AddItem(AdditionalTag);
	}

	MissionState.GeneratedMission.SitReps = MissionState.GeneratedMission.Mission.ForcedSitreps;
	SitRepNames = MissionState.GeneratedMission.Mission.ForcedSitreps;

	// Add Forced SitReps from Cheats
	CheatManager = XComHeadquartersCheatManager(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().CheatManager);
	if (CheatManager != none && CheatManager.ForceSitRepTemplate != '')
	{
		MissionState.GeneratedMission.SitReps.AddItem(CheatManager.ForceSitRepTemplate);
		SitRepNames.AddItem(CheatManager.ForceSitRepTemplate);
		CheatManager.ForceSitRepTemplate = '';
	}

	MissionState.GeneratedMission.MissionQuestItemTemplate = MissionMgr.ChooseQuestItemTemplate(MissionState.Source, MissionReward, MissionState.GeneratedMission.Mission, (MissionState.DarkEvent.ObjectID > 0));

	if(MissionState.GeneratedMission.Mission.sType == "")
	{
		`LOG("GetMissionDefinitionForFamily() failed to generate a mission with: \n"
						$ " Family: " $ MissionFamily);
	}

	// find a plot that supports the biome and the mission
	Biome = class'X2StrategyGameRulesetDataStructures'.static.GetBiome(MissionState.Get2DLocation());

	// do a weighted selection of our plot
	MissionState.GeneratedMission.Plot = SelectPlotDefinition(MissionState.GeneratedMission.Mission, Biome);
	MissionState.GeneratedMission.Biome = ParcelMgr.GetBiomeDefinition(Biome);

	// Start Issue #157
	DLCInfos = `ONLINEEVENTMGR.GetDLCInfos(false);
	for(i = 0; i < DLCInfos.Length; ++i)
	{
		DLCInfos[i].PostSitRepCreation(MissionState.GeneratedMission, MissionState);
	}
	// End Issue #157

	// Now that all sitreps have been chosen, add any sitrep tactical tags to the mission list
	MissionState.UpdateSitrepTags();

	// Add the Chosen to the mission if required. We do this after the sit
	// reps are set up to ensure we don't get Chosen and Rulers together.
	// MaybeAddChosenToMission(MissionState);

	if(MissionState.GetMissionSource().BattleOpName != "")
	{
		MissionState.GeneratedMission.BattleOpName = MissionState.GetMissionSource().BattleOpName;
	}
	else
	{
		MissionState.GeneratedMission.BattleOpName = class'XGMission'.static.GenerateOpName(false);
	}

	MissionState.GenerateMissionFlavorText();
}

static function MissionDefinition GetMissionDefinitionForFamily(name MissionFamily)
{
	local X2CardManager CardManager;
	local MissionDefinition MissionDef;
	local array<string> DeckMissionTypes;
	local string MissionType;
	local XComTacticalMissionManager MissionMgr;

	MissionMgr = `TACTICALMISSIONMGR;
	// LWOTC: Testing this line to see whether it helps even out the
	// plots selected for missions so players don't see the same two
	// types of plot all the time.
	MissionMgr.CacheMissionManagerCards();  
	CardManager = class'X2CardManager'.static.GetCardManager();

	// now that we have a mission family, determine the mission type to use
	CardManager.GetAllCardsInDeck('MissionTypes', DeckMissionTypes);
	foreach DeckMissionTypes(MissionType)
	{
		if(MissionMgr.GetMissionDefinitionForType(MissionType, MissionDef))
		{
			if(MissionDef.MissionFamily == string(MissionFamily) 
				|| (MissionDef.MissionFamily == "" && MissionDef.sType == string(MissionFamily))) // missions without families are their own family
			{
				CardManager.MarkCardUsed('MissionTypes', MissionType);
				return MissionDef;
			}
		}
	}

	`Redscreen("AlienActivity: Could not find a mission type for MissionFamily: " $ MissionFamily);
	return MissionMgr.arrMissions[0];
}
//---------------------------------------------------------------------------------------
// Code (next 3 functions) copied from XComGameState_MissionSite
//
/*static function SelectBiomeAndPlotDefinition(XComGameState_MissionSite MissionState, out string Biome, out PlotDefinition SelectedDef, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local MissionDefinition MissionDef;
	local string PrevBiome;
	local array<string> ExcludeBiomes;

	ParcelMgr = `PARCELMGR;
	ExcludeBiomes.Length = 0;

	MissionDef = MissionState.GeneratedMission.Mission;
	Biome = SelectBiome(MissionState, ExcludeBiomes);
	PrevBiome = Biome;

	while(!SelectPlotDefinition(MissionDef, Biome, SelectedDef, ExcludeBiomes, SitRepNames))
	{
		Biome = SelectBiome(MissionState, ExcludeBiomes);

		if(Biome == PrevBiome)
		{
			`LOG("Could not find valid plot for mission!\n" $ " MissionType: " $ MissionDef.MissionName);
			SelectedDef = ParcelMgr.arrPlots[0];
			return;
		}

		PrevBiome=Biome; // natively apparently this goes for an infinite loop?  Weird.
	}

	`LOG("Selected plot '" $ SelectedDef.MapName $ "' with biome '" $ Biome $ "'");
}*/

//---------------------------------------------------------------------------------------
static function string SelectBiome(XComGameState_MissionSite MissionState, out array<string> ExcludeBiomes)
{
	local string Biome;
	local int TotalValue, RollValue, CurrentValue, idx, BiomeIndex;
	local array<BiomeChance> BiomeChances;
	local string TestBiome;

	if (MissionState.GeneratedMission.Mission.ForcedBiome != "")
	{
		return MissionState.GeneratedMission.Mission.ForcedBiome;
	}

	// Grab Biome from location
	Biome = class'X2StrategyGameRulesetDataStructures'.static.GetBiome(MissionState.Get2DLocation());

	if (ExcludeBiomes.Find(Biome) != INDEX_NONE)
	{
		Biome = "";
	}

	// Grab "extra" biomes which we could potentially swap too (used for Xenoform)
	BiomeChances = class'X2StrategyGameRulesetDataStructures'.default.m_arrBiomeChances;

	// Not all plots support these "extra" biomes, check if excluded
	foreach ExcludeBiomes(TestBiome)
	{
		BiomeIndex = BiomeChances.Find('BiomeName', TestBiome);

		if (BiomeIndex != INDEX_NONE)
		{
			BiomeChances.Remove(BiomeIndex, 1);
		}
	}

	// If no "extra" biomes just return the world map biome
	if (BiomeChances.Length == 0)
	{
		return Biome;
	}

	// Calculate total value of roll to see if we want to swap to another biome
	TotalValue = 0;

	for (idx = 0; idx < BiomeChances.Length; idx++)
	{
		TotalValue += BiomeChances[idx].Chance;
	}

	// Chance to use location biome is remainder of 100
	if (TotalValue < 100)
	{
		TotalValue = 100;
	}

	// Do the roll
	RollValue = Rand(TotalValue);
	CurrentValue = 0;

	for (idx = 0; idx < BiomeChances.Length; idx++)
	{
		CurrentValue += BiomeChances[idx].Chance;

		if (RollValue < CurrentValue)
		{
			Biome = BiomeChances[idx].BiomeName;
			break;
		}
	}

	return Biome;
}
//---------------------------------------------------------------------------------------
/*static function bool SelectPlotDefinition(MissionDefinition MissionDef, string Biome, out PlotDefinition SelectedDef, out array<string> ExcludeBiomes, optional array<name> SitRepNames)
{
	local XComParcelManager ParcelMgr;
	local array<PlotDefinition> ValidPlots;
	local X2SitRepTemplateManager SitRepMgr;
	local name SitRepName;
	local X2SitRepTemplate SitRep;
	local int AllowPlot;  // int so it can be used as an `out` parameter

	ParcelMgr = `PARCELMGR;
	ParcelMgr.GetValidPlotsForMission(ValidPlots, MissionDef, Biome);
	SitRepMgr = class'X2SitRepTemplateManager'.static.GetSitRepTemplateManager();

	// pull the first one that isn't excluded from strategy, they are already in order by weight
	foreach ValidPlots(SelectedDef)
	{
		AllowPlot = 1;
		foreach SitRepNames(SitRepName)
		{
			SitRep = SitRepMgr.FindSitRepTemplate(SitRepName);

			if (SitRep != none && SitRep.ExcludePlotTypes.Find(SelectedDef.strType) != INDEX_NONE)
			{
				AllowPlot = 0;
			}
		}
		if (TriggerOverridePlotValidForMission(MissionDef, SelectedDef, AllowPlot))
		{
			if (AllowPlot == 1) return true;
		}
		else if (AllowPlot == 1 && !SelectedDef.ExcludeFromStrategy)
		{
			return true;
		}

	}

	ExcludeBiomes.AddItem(Biome);
	return false;
}*/


private static function PlotDefinition SelectPlotDefinition(MissionDefinition MissionDef, string Biome)
{
	local XComParcelManager ParcelMgr;
	local array<PlotDefinition> ValidPlots;
	local PlotDefinition SelectedDef;

	ParcelMgr = `PARCELMGR;
	ParcelMgr.GetValidPlotsForMission(ValidPlots, MissionDef, Biome);

	// pull the first one that isn't excluded from strategy, they are already in order by weight
	foreach ValidPlots(SelectedDef)
	{
		if(!SelectedDef.ExcludeFromStrategy)
		{
			return SelectedDef;
		}
	}

	`LOG("Could not find valid plot for mission!");

	return ParcelMgr.arrPlots[0];
}