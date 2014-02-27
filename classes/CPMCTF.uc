class CPMCTF extends AOCCTF
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

	HUDType=class'CPMCTFHUD'
	PlayerControllerClass=class'CPMCTFPlayerController'
	DefaultPawnClass=class'CPMPawn'

	GlobCfg = class'CPMGlobalServerConfig'
	
	//TBS bugfix, lol.
	bWaitForTeams=true

	ModDisplayString="Chivalry+"
	ModeDisplayString="Capture The Flag"
}