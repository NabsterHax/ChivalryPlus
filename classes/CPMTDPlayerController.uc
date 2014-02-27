class CPMTDPlayerController extends AOCTDPlayerController
	implements(ICPMPlayerController)
	implements(ICPMReadyUpPC);

var float OriginalSpectatorCamSpeed;
var class<CPMGlobalClientConfig> ClientCfg;
var bool bForcedCustomization;

`include(CPM/include/CPMPlayerController.uci)
`include(CPM/include/CPMReadyUpPC.uci)

DefaultProperties
{
	ClientCfg = class'CPMGlobalClientConfig'
}
