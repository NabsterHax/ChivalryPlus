class CPMSwordGame extends CPMFFA;

struct Loadout
{
	var class<AOCFamilyInfo> Family;
	var class<AOCWeapon> Weapon;
	var int KillsToLevel;
	var bool bUnskippable;

	structdefaultproperties
	{
		Family=class'AOCFamilyInfo_None';
		Weapon=class'AOCWeapon_None';
		KillsToLevel=1;
		bUnskippable=false;
	}
};
var config bool bPreserveHealthAndStamina;
var config bool bFistsStealLevels;
var config bool bLateJoinerHandicap;
var config bool bNoTimeLimit;
var config array<Loadout> LoadoutList;

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
    return default.class;
}

function PerformOnFirstSpawn(Controller NewPlayer)
{
	super(AOCGame).PerformOnFirstSpawn(NewPlayer);
	ProModWelcome(NewPlayer);
	AOCPlayerController(NewPlayer).ReceiveChatMessage("", "Sword Game: Kill people to get new loadouts! It's a race to the finish!", EFAC_ALL, true, true, "#04B404");
	if(bFistsStealLevels)
		AOCPlayerController(NewPlayer).ReceiveChatMessage("", "Kill people with your fists to steal one of their levels!", EFAC_ALL, true, true, "#04B404");

}

function PreBeginPlay()
{
	super.PreBeginPlay();
	CPMSwordGameGRI(WorldInfo.GRI).LoadoutListLength = LoadoutList.Length;
	CPMSwordGameGRI(WorldInfo.GRI).bPreserveHealthAndStamina = bPreserveHealthAndStamina;
}

function bool CheckWin(int LoadoutNum, CPMSwordGamePC CheckPC)
{
	local AOCPlayerController PC;
	//Also check for milestones :P
	if (LoadoutNum == LoadoutList.Length - 1)
	{
		foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
		{
			PC.ReceiveChatMessage("", CheckPC.PlayerReplicationInfo.PlayerName@"has reached the final level!", EFAC_ALL, true);
		}
		return false;
	}
	else if (LoadoutNum == LoadoutList.Length)
	{
		EndGame(CheckPC.PlayerReplicationInfo, "LoadoutLimit");
		return true;
	}
	return false;
}

function NotifyNewLeader(AOCPRI NewLeader)
{
	local AOCPlayerController PC;
	foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
	{
		PC.ReceiveChatMessage("", NewLeader.PlayerName@"had taken the lead!", EFAC_ALL, true);
	}
}

function SetupNewPlayer(CPMSwordGamePC NewPlayer)
{
	local int LoadoutNum;
	if (bLateJoinerHandicap && bGameStarted)
		LoadoutNum = FindLowestLoadoutNum();
	else
		LoadoutNum = 0;

	//NewPlayer.ReceiveChatMessage("", "Setting up. Num:"@LoadoutNum@"Fam:"@LoadoutList[LoadoutNum].Family@"Wep:"@LoadoutList[LoadoutNum].Weapon,EFAC_ALL,true);
	
	NewPlayer.SetLoadout(LoadoutNum);
	NewPlayer.SetReady(true);
}

event Tick(float DeltaTime)
{
	local CPMSwordGamePC PC;
	super.Tick(DeltaTime);
	
	foreach WorldInfo.AllControllers(class'CPMSwordGamePC', PC)
	{
		PC.CheckLevelUp();
	}
}

function ScoreKill(Controller Killer, Controller Other)
{
	//local int NewHighScore;

	//`log("SCORE KILL"@Killer@Other@GetScriptTrace());
	AOCPRI(Killer.PlayerReplicationInfo).Score += 2;
	AOCPRI(Killer.PlayerReplicationInfo).NumKills += 1;
	Killer.PlayerReplicationInfo.bForceNetUpdate = TRUE;

	if (!isFirstBlood)
	{
		isFirstBlood = true;
		BroadcastSystemMessage(3,class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA",  Killer.PlayerReplicationInfo.PlayerName, ""), 
			class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA", Other.PlayerReplicationInfo.PlayerName, ""), EFAC_ALL);
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills )
		CheckScore(Killer.PlayerReplicationInfo);
}

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	super.Killed(Killer, KilledPlayer, KilledPawn, damageType);
	if (Killer == None || Killer == KilledPlayer) //Dishonourable death!
	{
		CPMSwordGamePC(KilledPlayer).PunishSuicide();
		return;
	}
	
	//Replenish killer's ammo...
	AOCPawn(Killer.Pawn).ReplenishAmmo();
	
	//Advance killer's level, give other penalties
	if (bFistsStealLevels && class<AOCDmgType_Fists>(damageType) != none && class<AOCWeapon_Fists>(LoadoutList[CPMSwordGamePC(Killer).CurrentLoadoutNumber].Weapon) == none)
	{
		if (!LoadoutList[CPMSwordGamePC(Killer).CurrentLoadoutNumber].bUnskippable)
		{
			CPMSwordGamePC(Killer).ScoreSteal(KilledPlayer);
		}
		else
		{
			CPMSwordGamePC(Killer).ReceiveChatMessage("", "You can't skip this weapon using fists!", EFAC_ALL, true);
		}
		CPMSwordGamePC(KilledPlayer).LevelStolen(Killer);
	}
	else
	{
		//dirty check to make sure players don't level 2 times with and delayed oil pot kill.
		if (class<AOCDmgType_Burn>(damageType) != none && class<AOCWeapon_OilPot>(LoadoutList[CPMSwordGamePC(Killer).CurrentLoadoutNumber].Weapon) == none)
			return;

		CPMSwordGamePC(Killer).ScoreKill();
	}
}

function int FindLowestLoadoutNum()
{
	local CPMSwordGamePC PC;
	local int MinNum;
	MinNum = 1000000;
	foreach WorldInfo.AllControllers(class'CPMSwordGamePC', PC)
	{
		//Exclude players without a loadout
		if (PC.CurrentLoadoutNumber != -1 && PC.CurrentLoadoutNumber < MinNum)
			MinNum = PC.CurrentLoadoutNumber;
	}

	if (MinNum != 1000000)
		return MinNum;
	else
		return 0;
}

function StartRound()
{
	super(AOCGame).StartRound();
}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
	//local int HighestScore;
	local PlayerReplicationInfo PRI;
	//local PlayerController P;
	local AOCPlayerController PC;

	if (IsTimerActive('NotifyEndGame') || IsTimerActive('ActualEndGame'))
		return;

	//HighestScore = -1000000;
	if(Reason ~= "TimeLimit")
	{
		bGameEnded=true;
		if ( bGameEnded )
		{
			// Find winner
			PRI = CPMSwordGameGRI(WorldInfo.GRI).LeadingPlayerPRI;
			
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				TeamWinner = PRI.PlayerName;
				PC.PreEndGame(AOCPRI(PRI).MyFamilyInfo.default.FamilyFaction, GetCurrentMap(), PRI.GetPlayerNameForMarkup()@"has won!", , PRI);
			}
			SetTimer(7.0f, false, 'NotifyEndGame');
			SetTimer(25.0f, false, 'ActualEndGame');
		}
	}
	else if (Reason ~= "LoadoutLimit")
	{
		bGameEnded=true;
		if(bGameEnded)
		{
			foreach WorldInfo.AllControllers(class'AOCPlayerController', PC)
			{
				TeamWinner = Winner.PlayerName;
				PC.PreEndGame(AOCPRI(Winner).MyFamilyInfo.default.FamilyFaction, GetCurrentMap(), Winner.GetPlayerNameForMarkup()@"has won!", , Winner);
			}
			SetTimer(7.0f, false, 'NotifyEndGame');
			SetTimer(25.0f, false, 'ActualEndGame');
		}
	}
}

function AOCEndRound()
{
	//Just end it
	EndGame( GetHighestScoreFromTeam( GetWinningTeam() ), "TimeLimit" );
}

function RequestTime(AOCPlayerController PC)
{
	if (bNoTimeLimit)
		PC.InitializeTimer(TimeLeft, false);
	else
		super.RequestTime(PC);
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
			TimeLeft=817;
		else
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
}

DefaultProperties
{
	HUDType=class'CPMSwordGameHUD'
	GameReplicationInfoClass=class'CPMSwordGameGRI'
	PlayerReplicationInfoClass=class'CPMSwordGamePRI'

	PlayerControllerClass=class'CPMSwordGamePC'
	DefaultPawnClass=class'CPMPawn'

	SpawnWaveInterval = 1
	MinimumRespawnTime = 3

	ModDisplayString="Chiv+ SwordGame                     "
}
