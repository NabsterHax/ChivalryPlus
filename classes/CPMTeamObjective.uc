class CPMTeamObjective extends AOCTeamObjective
	implements(ICPMGame)
	implements(ICPMReadyUpGame);

var bool bAgathaRUP;
var bool bMasonRUP;
var bool bForceRUP; //True if admin has forced the game ready
var bool bAgathaPause;
var bool bMasonPause;
var class<CPMGlobalServerConfig> GlobCfg;

`include(CPM/include/CPMGame.uci)
`include(CPM/include/CPMReadyUpGame.uci)

function PerformOnFirstSpawn(Controller NewPlayer)
{
	ProModWelcome(NewPlayer);
	super.PerformOnFirstSpawn(NewPlayer);
}

DefaultProperties
{
	bAgathaRUP=false
	bMasonRUP=false
	bForceRUP=false
	bAgathaPause=false
	bMasonPause=false

	GlobCfg = class'CPMGlobalServerConfig'

	HUDType=class'CPMTeamObjectiveHUD'
	PlayerControllerClass=class'CPMTeamObjectivePC'
	DefaultPawnClass=class'CPMPawn'

	ModDisplayString="Chiv+ TO"
}
