// This is an Unreal Script

class ILB_UIBlackMarketScreenListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    `LOG("ILB: Screen initialized:" @ Screen.Class.Name,, 'UISL');
	if (Screen.Class.Name == 'UIBlackMarket_Buy' || Screen.Class.Name == 'UIBlackMarket')
	{
		class'XComGameState_ILB_BlackMarketState'.static.HandleBlackMarketScreenOpened();
	}
}