class CPMFFADuel extends CPMFFA;

var config bool bNoTimeLimit;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return default.class;
}

function PerformOnFirstSpawn(Controller NewPlayer)
{
	super(AOCGame).PerformOnFirstSpawn(NewPlayer);
	ProModWelcome(NewPlayer);
	AOCPlayerController(NewPlayer).ReceiveChatMessage("", "Free Duel: 1v1 combat the classic way.\n Face someone directly and bow to challenge them to a duel!", EFAC_ALL, true, true, "#04B404");
	//LocalizedPrivateMessage(PlayerController(NewPlayer),2,,,true, "#04B404");
}

function StartRound()
{
	local AOCPlayerController PC;
	TimeLeft = 817;
	GameStartTime = WorldInfo.TimeSeconds;
	bGameStarted = true;
	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PC.InitializeTimer(TimeLeft, false);
		PC.SetWaitingForPlayers(False);
		PC.WarmupUnfrozen();
	}

	// new spawn wave timer
	ClearTimer('SpawnQueueTimer');
	SpawnQueueTimer();
	SetTimer(SpawnWaveInterval, true, 'SpawnQueueTimer');

	//PerformAutoBalance();
	SetTimer(fAutoBalanceInterval, true, 'PerformAutoBalance');
	
	bAOCGameEnded=false;

	gotostate( 'AOCRoundInProgress' );
}

function RequestTime(AOCPlayerController PC)
{
	PC.InitializeTimer(TimeLeft, false);
}

State AOCRoundInProgress
{
	function Timer()
	{
		super(UTTeamGame).Timer();
		
		if (TimeLeft == 0)
		{
			AOCEndRound();
		}

		if(bNoTimeLimit)
		{
			TimeLeft=817;
		}
		else
		{
			TimeLeft--;
		}

		CheckTimerNotifications();

		if (NumBotsToSpawn > 0)
		{
			AddBots(1);
			NumBotsToSpawn--;
		}
		if (NumDummyBotsToSpawn > 0)
		{
			AddDummies(1);
			NumDummyBotsToSpawn--;
		}
	}
}

DefaultProperties
{
	//HUDType=class'CPMFFADuelHUD'
	PlayerControllerClass=class'CPMFFADuelPC'
	DefaultPawnClass=class'CPMFFADuelPawn'

	GameReplicationInfoClass=class'CPMFFADuelGRI'

	MinimumRespawnTime = 0
	RoundTime=40 // doesn't work...

	ModDisplayString="Chivalry+"
	ModeDisplayString="Free Duel"
}
