class UIMission_ResCardCovertOpMission extends UIMission_ResOps;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	FindMission('MissionSource_ILBOptional');

	BuildScreen();
}

simulated function Name GetLibraryID()
{
	return 'XPACK_Alert_MissionBlades';
}


//-------------- EVENT HANDLING --------------------------------------------------------

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function bool CanTakeMission()
{
	return true;
}

simulated function EUIState GetLabelColor()
{
	return eUIState_Normal;
}

//==============================================================================

defaultproperties
{
	InputState = eInputState_Consume;
	Package = "/ package/gfxXPACK_Alerts/XPACK_Alerts";
}