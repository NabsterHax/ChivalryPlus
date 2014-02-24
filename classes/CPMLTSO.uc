class CPMLTSO extends AOCGame
	implements(ICPMGame)
	implements(ICPMReadyUpGame);

var class<CPMGlobalServerConfig> GlobCfg;

//RUP Vars
var bool bAgathaRUP;
var bool bMasonRUP;
var bool bForceRUP; //True if admin has forced the game ready
var bool bAgathaPause;
var bool bMasonPause;

//Game-mode Vars
var CPMBomb Bomb;
var array<CPMBombTarget> BombTargets;
var bool bBombArmed;

var TeamInfo MatchWinner;
var TeamInfo RoundWinner;
var TeamInfo RoundLoser;
var array<int> RoundScores;
var int RoundsToWin;
var int RoundsPlayed;
var int MaxRounds;
var Controller LastKiller;
var bool bSecondHalf;
var float MiniWarmupTime;
var bool bRoundAlreadyEnded;

var SoundCue AgathaWinSound;
var SoundCue MasonWinSound;

var bool bCheckStartOnline;


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

// Death based AB does nothing. Use interval based (aka round based for LTS).
function PerformDeathBasedAB(AOCPlayerController inPC)
{
}

function PostBeginPlay()
{
	local CPMBomb TmpBomb;
	local CPMBombTarget TmpBombTarget;
	local int i;

	super.PostBeginPlay();

	foreach AllActors(class'CPMBombTarget', TmpBombTarget)
	{
		BombTargets.AddItem(TmpBombTarget);
		TmpBombTarget.bEnabled=false;
	}
	
	i=0;
	foreach AllActors(class'CPMBomb', TmpBomb)
	{
		i++;
		Bomb = TmpBomb; 
		TmpBomb.DeactivateBomb();
	}
	if(i != 1)
		WarnAlwaysInternal("WRONG NUMBER OF BOMBS: THERE SHOULD BE EXACTLY ONE BOMB");
	
	CPMLTSOGRI(GameReplicationInfo).Bomb = Bomb;
	if (WorldInfo.NetMode == NM_Standalone)
		CPMLTSOGRI(GameReplicationInfo).ReplicatedEvent('Bomb');
}

function EAOCFaction GetWinningTeam()
{
	return EFAC_None;
}

function PerformOnFirstSpawn(Controller NewPlayer)
{
	ProModWelcome(NewPlayer);
	super.PerformOnFirstSpawn(NewPlayer);
	//TODO: Spawn message here - rounds left, objective, etc.
}

function PerformRealGameActions( AOCPlayerController PC)
{
	super.PerformRealGameActions(PC);
	CPMLTSOPC(PC).AttackingFaction = Bomb.BombingTeam; //Server
	CPMLTSOPC(PC).SetAttackingFaction(Bomb.BombingTeam); //Client!
}

//For detecting team wipes
function ScoreKill( Controller Killer, Controller Other )
{
	local Controller P;
	local TeamInfo OtherTeam;
	local bool bTeamDead;
	
	if (Killer != Other)
		LastKiller = Killer;

	//super.ScoreKill(Killer, Other);
	super.ScoreKill(Killer, Other);
	
	OtherTeam = Other.PlayerReplicationInfo.Team;
	bTeamDead = true;
	Other.PlayerReplicationInfo.bOutOfLives = true;

	//If the bomb is armed we don't care if an attacker dies.
	if(AOCPlayerController(Other) != none)
	{
		if (bBombArmed && AOCPlayerController(Other).CurrentFamilyInfo.default.FamilyFaction == Bomb.BombingTeam)
			return;
	}
	else if (bBombArmed && AOCAIController(Other).myPawnClass.default.FamilyFaction == Bomb.BombingTeam)
		return;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		if ( OtherTeam == P.PlayerReplicationInfo.Team )
		{
			if ( (P.PlayerReplicationInfo != None) && P.Pawn.IsAliveAndWell() )
			{
				bTeamDead = false;
			}
		}
	}

	if ( bTeamDead == true )
	{
		if (Killer != none )
			RoundWinner = Killer.PlayerReplicationInfo.Team;
		else
		{
			if (Other.PlayerReplicationInfo.Team == Teams[0])
				RoundWinner = Teams[1];
			else RoundWinner = Teams[0];
		}
		if (Other.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team)      //if last kill was suicide
		{
			// toggle round winner
			if ( RoundWinner == Teams[0] )
				RoundWinner = Teams[1];
			else
				RoundWinner = Teams[0];
		}
		RoundLoser = Other.PlayerReplicationInfo.Team;

		AOCEndRound();
	}
}

//TODO: Reset the bomb and targets (done), _events_ and everything waaah!
//      Maybe add ready up per round? Automatic, but option to unready.
function StartRound()
{
	local controller PC;
	local bool bAgathaTeamReady;
	local bool bMasonTeamReady;
	local CPMBombTarget TmpBombTarget;

	// Initialise the bomb and targets
	Bomb.ActivateBomb();
	//CPMLTSOGRI(WorldInfo.GRI).Bomb.ActivateBomb();
	//Bomb.bNetDirty=true;
	foreach BombTargets(TmpBombTarget)
		TmpBombTarget.Reset();
	bBombArmed = false;
	bRoundAlreadyEnded = false;


	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if (AOCPlayerController(PC) != none)
		{
			AOCPlayerController(PC).WarmupUnfrozen();
			
			if (AOCPlayerController(PC).bReady)
			{
				PC.PlayerReplicationInfo.bOutOfLives = false;
			}
			else
				PC.PlayerReplicationInfo.bOutOfLives = true;
		}
		else if (AOCAICombatController(PC) != none)
			PC.PlayerReplicationInfo.bOutOfLives = false;
	}
	RoundWinner = none;

	bAgathaTeamReady = false;
	bMasonTeamReady = false;

	// Pass Info to GRI
	CPMLTSOGRI(GameReplicationInfo).RoundsNeededToWin = RoundsToWin;
	CPMLTSOGRI(GameReplicationInfo).AgathaRoundsWon =RoundScores[0];
	CPMLTSOGRI(GameReplicationInfo).MasonRoundsWon =RoundScores[1];

	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if (AOCPlayerController(PC) != none && AOCPlayerController(PC).IsVoluntarySpectator())
			continue;

		if ( Teams[EFAC_Agatha] == PC.PlayerReplicationInfo.Team)
		{
			if ( (PC.PlayerReplicationInfo != None) && !PC.PlayerReplicationInfo.bOutOfLives )
			{
				bAgathaTeamReady = true;
			}
		}
	}

	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if (AOCPlayerController(PC) != none && AOCPlayerController(PC).IsVoluntarySpectator())
			continue;

		if ( Teams[EFAC_Mason] == PC.PlayerReplicationInfo.Team )
		{
			if ( (PC.PlayerReplicationInfo != None) && !PC.PlayerReplicationInfo.bOutOfLives )
			{
				bMasonTeamReady = true;
			}
		}
	}
	
	//Could build RUP system into this. At the moment, only works in warmup!
	if ( bMasonTeamReady && bAgathaTeamReady )
	{
		TimeLeft = RoundTime * 60;
		foreach WorldInfo.AllControllers(class'Controller', PC)
		{
			AOCPlayerController(PC).InitializeTimer(TimeLeft, true);
			AOCPlayerController(PC).SetWaitingForPlayers(false);
			SetTimer((RoundTime - 1) * 60, false, 'RevealAllPawns');
			PC.PlayerReplicationInfo.bOutOfLives = false;
		}

		// new spawn wave timer
		ClearTimer('SpawnQueueTimer');
		SetTimer(SpawnWaveInterval, true, 'SpawnQueueTimer');

		if (!IsInState('AOCRoundInProgress'))
			gotostate( 'AOCRoundInProgress' );
	}
	else
	{
		TimeLeft = 10;
		foreach WorldInfo.AllControllers(class'Controller', PC)
		{
			AOCPlayerController(PC).InitializeTimer(TimeLeft, false);
			AOCPlayerController(PC).SetWaitingForPlayers(true);
			PC.PlayerReplicationInfo.bOutOfLives = false;
		}
		
		if (!IsInState('AOCPreRound'))
			GotoState('AOCPreRound');
	}

	//PerformAutoBalance(); //Do we EVER want this??
	bAOCGameEnded = false;
	bFreezePlayersDuringWarmup = false;
}

function BombEndGame(bool BombExplode, optional CPMBombTarget Target)
{
	//End the game on bomb explode/disarm
	if (BombExplode)
	{
		if (Bomb.BombingTeam == EFAC_Agatha)
			RoundWinner = Teams[EFAC_Agatha];
		else
			RoundWinner = Teams[EFAC_Mason];
		
		BroadcastMessage(none, Target.FriendlyLabel@"has been destroyed!", EFAC_ALL, true, true, "#FFA500");
	}
	else
	{
		if (Bomb.BombingTeam == EFAC_Agatha)
			RoundWinner = Teams[EFAC_Mason];
		else
			RoundWinner = Teams[EFAC_Agatha];

		BroadcastMessage(none, Target.FriendlyLabel@"has been disarmed!", EFAC_ALL, true, true, "#FFA500");
	}

	AOCEndRound();
}

function RevealAllPawns()
{
	local AOCPawn Pawn;
	foreach WorldInfo.AllPawns(class'AOCPawn', Pawn)
	{
		Pawn.bAlwaysRelevant = true;
	}
}

function RestartPlayer(Controller NewPlayer)
{
	if (AOCPlayerController(NewPlayer) != none)
		AOCPlayerController(NewPlayer).RemoveCombatHUDElements();
	if ( !NewPlayer.PlayerReplicationInfo.bOutOfLives )
		super.RestartPlayer(NewPlayer);
}

function UpdateScores(){}

//TODO: Make team swaps when half time!
//  	Sort out team-swapping stuff and keeping scores and whatnot!
function AOCEndRound()
{
	//local PlayerReplicationInfo PRI;
	//local AOCPRI myPRI;
	//local int MasonTeamAlive;
	//local int AgathaTeamAlive;
	/*local CPMBombTarget TmpBomb;
	local bool bArmed;
	
	bArmed = false;
	foreach WorldInfo.AllActors(class'CPMBombTarget', TmpBomb)
		if (TmpBomb.bIsArmed)
			bArmed = true;*/

	local Controller P;

	//This is a fail-safe to stop the round "ending" twice. Shouldn't be necessary but w/e.
	if (bRoundAlreadyEnded)
		return;
	else
		bRoundAlreadyEnded = true;

	if (TimeLeft <= 120)
	{
		foreach WorldInfo.AllControllers(class'Controller', P)
		{
			if (AOCPlayerController(P) != none)
			{
				AOCPlayerController(P).StopLowTimeMusic();
			}
		}
	}
	

	if ( RoundWinner != none )
	{
		RoundsPlayed++;
		RoundScores[RoundWinner.TeamIndex]++;
		if( RoundWinner.TeamIndex == 0 )
		{
			BroadcastSound(AgathaWinSound);
			BroadcastSystemMessage(7, class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "AgathaKnights", "AOCUI"),,EFAC_ALL);
			UpdateEvents(0);
		}
		else
		{
			BroadcastSound(MasonWinSound);
			BroadcastSystemMessage(7, class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "MasonOrder", "AOCUI"),,EFAC_ALL);
			UpdateEvents(1);
		}
		if ( RoundScores[RoundWinner.TeamIndex] == RoundsToWin )
		{
			MatchWinner = RoundWinner;
			if (LastKiller != none && LastKiller.PlayerReplicationInfo.Team == MatchWinner )
				EndGame( LastKiller.PlayerReplicationInfo, "TeamScoreLimit" );
			else
				EndGame( GetFirstPRIFromTeam(MatchWinner), "TeamScoreLimit" );
			return;
		}
		else if (RoundScores[RoundWinner.TeamIndex] == RoundsToWin - 1)
		{
			if (RoundWinner.TeamIndex == 0)
			{
				BroadcastSystemMessage(8, class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "AgathaKnights", "AOCUI"),,EFAC_ALL);
			}
			else
			{
				BroadcastSystemMessage(8, class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "MasonOrder", "AOCUI"),,EFAC_ALL);
			}
		}
	}
	else    //nobody won last round
	{
		// In the case where a 'draw' happens, defending team always wins.
		if (Bomb.BombingTeam == EFAC_Agatha)
			RoundWinner = Teams[EFAC_Mason];
		else
			RoundWinner = Teams[EFAC_Agatha];
		AOCEndRound();
		/*foreach GameReplicationInfo.PRIArray(PRI)
		{
			myPRI = AOCPRI(PRI);
			if (myPRI.CurrentHealth <= 0)
				continue;

			if (myPRI.MyFamilyInfo.default.FamilyFaction == EFAC_AGATHA)
				AgathaTeamAlive += 1;
			else if (myPRI.MyFamilyInfo.default.FamilyFaction == EFAC_MASON)
				MasonTeamAlive += 1;
		}

		if (AgathaTeamAlive > MasonTeamAlive)
		{
			RoundWinner = Teams[0];
			AOCEndRound();
			return;
		}
		else if (MasonTeamAlive > AgathaTeamAlive)
		{
			RoundWinner = Teams[1];
			AOCEndRound();
			return;
		}
		else // Now it's really a draw.
		{
			RoundsPlayed++;
			BroadcastSystemMessage(9,,,EFAC_ALL);
		}*/
	}
	
	//If neither team won more rounds than the other, draw.
	if(RoundsPlayed == MaxRounds)
	{
		EndGame(none, "Draw");
		return;
	}

	if (RoundsPlayed >= RoundsToWin-1 && !bSecondHalf)
		NotifyPlayersHalfTime(true);

	UpdateScores();
	/** Will need to display Round-end screen first 
	 */
	GotoState('AOCPostRound');
}

function SwapTeamsAndScores()
{
	local AOCPlayerController PC;
	local int TmpScore;

	//Swap teams
	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		CPMLTSOPC(PC).SwapTeam();
	}

	//Swap scores
	TmpScore = RoundScores[0];
	RoundScores[0] = RoundScores[1];
	RoundScores[1] = TmpScore;
	CPMLTSOGRI(GameReplicationInfo).RoundsNeededToWin = RoundsToWin;
	CPMLTSOGRI(GameReplicationInfo).AgathaRoundsWon =RoundScores[0];
	CPMLTSOGRI(GameReplicationInfo).MasonRoundsWon =RoundScores[1];
}

function NotifyPlayersHalfTime(bool bShow)
{
	local CPMLTSOPC PC;
	foreach WorldInfo.AllControllers(class'CPMLTSOPC', PC)
	{
		PC.ShowHalfTimeHeader(bShow);
		if(bShow)
		{
			if (PC.CurrentFamilyInfo.default.FamilyFaction == Bomb.BombingTeam)
				PC.ReceiveChatMessage("", "Half Time: Your team is now defending", EFAC_ALL, true);
			else
				PC.ReceiveChatMessage("", "Half Time: Your team is now attacking", EFAC_ALL, true);
		}
	}
}

function NotifyPlayersBombArmed()
{
	local CPMLTSOPC PC;
	foreach WorldInfo.AllControllers(class'CPMLTSOPC', PC)
	{
		PC.ShowBombArmedHeader();
		PC.StopLowTimeMusic();
	}
	bBombArmed = true;
}

/*function AddBombArmTime(float fTimeToExplode)
{
	Timeleft += fTimeToExplode + 5.f;
}*/

function PlayerReplicationInfo GetFirstPRIFromTeam( TeamInfo Team )
{
	local Controller PC;
	foreach WorldInfo.AllControllers(class'Controller', PC)
	{
		if (PC.PlayerReplicationInfo.Team == Team)
			return PC.PlayerReplicationInfo;
	}
	return none;
}

//Not how the base game uses these.
function UpdateEvents(int flag)
{
	local int Idx;
	local array<SequenceObject> Events;
	local AOCSeqEvent_RoundOver RoundOverEvent;
	local array<int> ActivateIndices;

	if (WorldInfo.GetGameSequence() != None)
	{
		WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'AOCSeqEvent_RoundOver',TRUE,Events);
		for (Idx = 0; Idx < Events.Length; Idx++)
		{
			RoundOverEvent = AOCSeqEvent_RoundOver(Events[Idx]);
			if (RoundOverEvent != None)
			{
				ActivateIndices[0] = flag;
				RoundOverEvent.CheckActivate( self, none, false, ActivateIndices );
				
			}
		}
	}
}

function CheckTimerNotifications()
{
	//local int MaxTime;
	//local AOCPlayerController PC;
	//MaxTime = RoundTime * 60;

	/*if (TimeLeft == MaxTime / 2)
	{
		// Half-time notification
		foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		{
			PC.ClientPlaySound(HalftimeSound);
		}
		BroadcastSystemMessage(19,,,EFAC_ALL);
	}
	else if (TimeLeft == 300) // 5 Minutes left notification
	{
		foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		{
			PC.ClientPlaySound(FiveMinuteSound);
		}
		BroadcastSystemMessage(20, class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA", "5", ""),,EFAC_ALL);
	}
	else if (TimeLeft == 120) // 2 minute left sound
	{
		foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		{
			PC.PlayAudioComponentOnPermanent(OneMinuteSound);
		}
	}*/
	if (TimeLeft == 60) // 1 minute left notification
	{
		BroadcastSystemMessage(20, class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA", "1", ""),,EFAC_ALL);
	}
}

State AOCRoundInProgress
{
	function Timer()
	{
		//super.Timer();
		
		if (TimeLeft == 0 && !bBombArmed)
		{
			AOCEndRound();
		}
		
			TimeLeft--;

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

	function PerformOnSpawn(Controller C)
	{
		C.PlayerReplicationinfo.bOutOfLives = false;
	}

	function BeginState( Name PreviousStateName )
	{
		if (!bCheckStartOnline)
			StartOnlineGame();
		bCheckStartOnline = true;
		bGameStarted = true;
		SpawnQueueTimer();
		firstSpawn = false;
	}

	function bool PlayerCanRestart( PlayerController aPlayer )
	{
		return false;
	}

	function bool AddPlayerToQueue( controller PC, optional bool bSpawnNextTime = false )
	{
		return false;
	}

	function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
	{
		global.NotifyKilled(Killer, Killed, KilledPawn, damageType);
		Killed.PlayerReplicationInfo.bOutOfLives = true;
	}
}

Auto State AOCPreRound
{
	function BeginState( Name PreviousStateName )
	{
		local Controller PC;

		TimeToNextRound = TimeBetweenRounds;
		foreach WorldInfo.AllControllers(class'Controller', PC)
		{
			if (AOCPlayerController(PC) != none)
			{
				if (AOCPlayerController(PC).bReady)
				{
					PC.PlayerReplicationInfo.bOutOfLives = false;
				}
				else
					PC.PlayerReplicationInfo.bOutOfLives = true;
			}
			else if (AOCAICombatController(PC) != none)
				PC.PlayerReplicationInfo.bOutOfLives = false;
		}
	}
}

//Almost identical to AOCPreRound, yay!
state AOCMiniWarmup
{
	function BeginState( Name PreviousStateName )
	{
		local Controller PC;
		//`log("START AOCPREROUND"@TimeBetweenRounds);
		TimeToNextRound = MiniWarmupTime;
		foreach WorldInfo.AllControllers(class'Controller', PC)
		{
			AOCPlayerController(PC).InitializeTimer(TimeToNextRound, false);
			AOCPlayerController(PC).SetWaitingForPlayers(true);
			PC.PlayerReplicationInfo.bOutOfLives = false;
		}
	}

	function ScoreKill( Controller Killer, Controller Other )
	{
	}

	function RequestTime(AOCPlayerController PC)
	{
		if (ShouldCountDown())
			PC.InitializeTimer(TimeToNextRound, true);
		else
			PC.InitializeTimer(TimeToNextRound, false);
	}

	function Timer()
	{
		local AOCPlayerController PC;

		
		if ( ShouldCountDown() )
		{
			//`log("PRE-ROUND TIMER");
			if (TimeToNextRound == 0)
			{
				ResetLevel();
				StartRound();
				return;
			}

			TimeToNextRound--;
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				PC.InitializeTimer(TimeToNextRound, true);
				if(true)
				{
					PC.WarmupFrozen(TimeToNextRound);
				}
			}
		}
		else
		{
			TimeToNextRound = TimeBetweenRounds;
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				PC.InitializeTimer(TimeToNextRound, false);
				PC.SetWaitingForPlayers(true);
			}
		}
		
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
	
	function float SpawnWait(AIController B)
	{
		return 10.0;
	}
}

state AOCPostRound extends AOCPreRound
{
	function BeginState( Name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		CPMLTSOGRI(GameReplicationInfo).RoundsNeededToWin = RoundsToWin;
		CPMLTSOGRI(GameReplicationInfo).AgathaRoundsWon =RoundScores[0];
		CPMLTSOGRI(GameReplicationInfo).MasonRoundsWon =RoundScores[1];
	}

	function Timer()
	{
		local AOCPlayerController PC;

		
		if ( ShouldCountDown() )
		{
			//`log("PRE-ROUND TIMER");
			if (TimeToNextRound == 0)
			{
				ResetLevel();
				GotoState('AOCMiniWarmup');
				return;
			}

			TimeToNextRound--;
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				PC.InitializeTimer(TimeToNextRound, true);
				if(bFreezePlayersDuringWarmup)
				{
					PC.WarmupFrozen(TimeToNextRound);
				}
			}
		}
		else
		{
			TimeToNextRound = TimeBetweenRounds;
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				PC.InitializeTimer(TimeToNextRound, false);
				PC.SetWaitingForPlayers(true);
			}
		}
		
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

	function bool AddPlayerToQueue( controller PC, optional bool bSpawnNextTime = false )
	{
		if (TimeToNextRound == 0)
			return super.AddPlayerToQueue(PC, bSpawnNextTime);
		return false;
	}

	function EndState(Name NextStateName)
	{
		if (RoundsPlayed >= RoundsToWin-1 && !bSecondHalf)
		{
			bSecondHalf = true;
			SwapTeamsAndScores();
			NotifyPlayersHalfTime(false);
		}
	}
}

function Timer(){}



DefaultProperties
{
	bAgathaRUP=false
	bMasonRUP=false
	bForceRUP=false
	bAgathaPause=false
	bMasonPause=false

	bBombArmed=false

	GameReplicationInfoClass=class'CPMLTSOGRI'
	PlayerReplicationInfoClass=class'CPMLTSOPRI'
	HUDType=class'CPMLTSOHUD'

	DefaultPawnClass=class'CPMPawn'
	PlayerControllerClass=class'CPMLTSOPC'

	GlobCfg = class'CPMGlobalServerConfig'

	bSecondHalf=false
	MatchWinner = none
	RoundWinner = none
	RoundLoser = none
	RoundScores[0] = 0
	RoundScores[1] = 0
	RoundsToWin = 11 // Should be (MaxRounds/2)+1
	RoundsPlayed = 0
	MaxRounds = 20 //This should be even
	TimeBetweenRounds = 10
	MiniWarmupTime = 5
	RoundTime = 3
	SpawnWaveInterval = 1

	AgathaWinSound=SoundCue'A_Meta.obj_complete_agatha'
	MasonWinSound=SoundCue'A_Meta.obj_complete_mason'
	bCheckStartOnline=false

	bWaitForTeams=true //change to true after testing!

	ModDisplayString="Chiv+ LTSO"
}
