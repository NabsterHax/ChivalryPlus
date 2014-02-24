class CPMKOTH extends AOCKOTH
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

//Testy
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
local int i;
	LogAlwaysInternal("Calling SetGameType in"@default.Class);
    for(i = 0; i < default.DefaultMapPrefixes.Length; ++i)
	{
		LogAlwaysInternal(default.DefaultMapPrefixes[i].Prefix@"="@default.DefaultMapPrefixes[i].GameType);
	}
	return super.SetGameType(MapName, Options, Portal);
}

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

	HUDType=class'CPMKOTHHUD'
	PlayerControllerClass=class'CPMKOTHPlayerController'
	DefaultPawnClass=class'CPMPawn'

	GlobCfg = class'CPMGlobalServerConfig'

	ModDisplayString="Chiv+ KOTH"
}