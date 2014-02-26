class CPMLTS extends AOCLTS
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

	HUDType=class'CPMLTSHUD'
	PlayerControllerClass=class'CPMLTSPlayerController'
	DefaultPawnClass=class'CPMPawn'

	GlobCfg = class'CPMGlobalServerConfig'

	ModDisplayString="Chiv+ LTS                     "
}
