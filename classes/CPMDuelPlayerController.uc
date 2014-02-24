class CPMDuelPlayerController extends AOCDuelPlayerController
	implements(ICPMPlayerController);

var float OriginalSpectatorCamSpeed;
var class<CPMGlobalClientConfig> ClientCfg;
var bool bForcedCustomization;

`include(CPM/include/CPMPlayerController.uci)

DefaultProperties
{
	ClientCfg = class'CPMGlobalClientConfig'
	CustomizationClass=class'CPMCustomization'
}
