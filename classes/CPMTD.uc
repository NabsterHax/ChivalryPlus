class CPMTD extends AOCTD
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

//Required
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	local string prefix, ffatype;

	MapName = StripPlayOnPrefix(MapName);

	prefix = left(MapName,InStr(MapName,"-"));

	if(prefix ~= "AOCTD")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOTD' : class'CPMTD';
	}
	else if(prefix ~= "AOCLTSO")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOLTSO' : class'CPMLTSO';
	}
	else if(prefix ~= "AOCCTF")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOCTF' : class'CPMCTF';
	}
	else if(prefix ~= "AOCKOTH")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOKOTH' : class'CPMKOTH';
	}
	else if(prefix ~= "AOCLTS")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOLTS' : class'CPMLTS';
	}
	else if(prefix ~= "AOCDuel")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YODuel' : class'CPMDuel';
	}
	else if(prefix ~= "AOCFFA")
	{
		ffatype = ParseOption(Options, "FFAType");
		if(ffatype ~= "FFADuel")
		{
			return default.GlobCfg.default.YeOldeBalance ? class'YOFFADuel' : class'CPMFFADuel';
		}
		else if (ffatype ~= "SwordGame")
		{
			return default.GlobCfg.default.YeOldeBalance ? class'YOSwordGame' : class'CPMSwordGame';
		}
		else
		{
			return default.GlobCfg.default.YeOldeBalance ? class'YOFFA' : class'CPMFFA';
		}
	}
	else if(prefix ~= "AOCTO")
	{
		return default.GlobCfg.default.YeOldeBalance ? class'YOTeamObjective' : class'CPMTeamObjective';
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

	GlobCfg = class'CPMGlobalServerConfig'

	HUDType=class'CPMTDHUD'
	PlayerControllerClass=class'CPMTDPlayerController'
	//DefaultPawnClass=class'CPMPawn'

	ModDisplayString="Chivalry+"
	ModeDisplayString="Team Deathmatch"
}