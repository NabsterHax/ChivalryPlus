class CPMFFA extends AOCFFA
	implements(ICPMGame);

var class<CPMGlobalServerConfig> GlobCfg;

`include(CPM/include/CPMGame.uci)

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
	HUDType=class'CPMFFAHUD'
	PlayerControllerClass=class'CPMFFAPlayerController'
	DefaultPawnClass=class'CPMPawn'

	GlobCfg = class'CPMGlobalServerConfig'

	ModDisplayString="Chiv+ FFA                     "
}