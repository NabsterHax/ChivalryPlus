class CPMTeamObjectivePC extends AOCTeamObjectivePC
	implements(ICPMPlayerController)
	implements(ICPMReadyUpPC);

var class<CPMGlobalClientConfig> ClientCfg;
var float OriginalSpectatorCamSpeed;
var bool bForcedCustomization;

`include(CPM/include/CPMPlayerController.uci)
`include(CPM/include/CPMReadyUpPC.uci)

DefaultProperties
{
	ClientCfg = class'CPMGlobalClientConfig'
}
