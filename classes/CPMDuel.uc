class CPMDuel extends AOCDuel
	implements(ICPMGame);

var class<CPMGlobalServerConfig> GlobCfg;

`include(CPM/include/CPMGame.uci);

DefaultProperties
{
	HUDType=class'CPMDuelHUD'
	PlayerControllerClass=class'CPMDuelPlayerController'
	DefaultPawnClass=class'CPMPawn'

	GlobCfg = class'CPMGlobalServerConfig'

	ModDisplayString="Chivalry+"
	ModeDisplayString="Duel"
}