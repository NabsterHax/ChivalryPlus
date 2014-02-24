class CPMLTSOGRI extends AOCGRI;

var repnotify CPMBomb Bomb;
var repnotify CPMBombTarget BombTargets;

var int AgathaRoundsWon;
var int MasonRoundsWon;
var int RoundsNeededToWin;

replication
{
	if(!bNetInitial)
		Bomb, BombTargets;
	if(bNetDirty)
		AgathaRoundsWon, MasonRoundsWon, RoundsNeededToWin;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'Bomb')
	{
		//CPMLTSOPC(GetALocalPlayerController()).ReceiveChatMessage("", "Setting up the bomb", EFAC_All, true);
		CPMLTSOPC(GetALocalPlayerController()).SetBomb(Bomb);
	}
	/*else if (VarName == 'BombTargets')
	{
		CPMLTSOPC(GetALocalPlayerController()).SetBombTargets(BombTargets);
	}*/
	else
		super.ReplicatedEvent(VarName);
}

function RequestSyncGametypeHUD(AOCPlayerController PC)
{
	CPMLTSOPC(PC).SetBomb(Bomb);
}

simulated function float  RetrieveObjectiveCompletionPercentage()
{
	local AOCPlayerController PC;
	PC = AOCPlayerController(GetALocalPlayerController());
	if (PC != none)
	{   
		if (AOCPRI(PC.PlayerReplicationInfo).MyFamilyInfo.default.FamilyFaction == EFAC_AGATHA)
		{
			return float(AgathaRoundsWon) / RoundsNeededToWin;
		}
		else
		{
			return float(MasonRoundsWon) / RoundsNeededToWin;
		}
	}
}

simulated function string RetrieveObjectiveName(EAOCFaction Faction)
{
	local CPMLTSOPC PC;
	PC = CPMLTSOPC(GetALocalPlayerController());
	if (PC.AttackingFaction == PC.CurrentFamilyInfo.default.FamilyFaction)
		return "Destroy the bomb sites";
	else
		return "Defend the bomb sites";
}

simulated function string RetrieveObjectiveDescription(EAOCFaction Faction)
{
	local CPMLTSOPC PC;
	PC = CPMLTSOPC(GetALocalPlayerController());
	if (PC.AttackingFaction == PC.CurrentFamilyInfo.default.FamilyFaction)
		return "Detonate the bomb or kill the entire enemy team to win";
	else
		return "Defuse the bomb or kill the entire enemy team to win";
}

simulated function string RetrieveObjectiveStatusText(EAOCFaction Faction)
{
	local string Text;
	//local int MasonTeamAlive;
	//local int AgathaTeamAlive;
	//local PlayerReplicationInfo PRI;
	//local AOCPRI myPRI;
	
	/*MasonTeamAlive = 0;
	AgathaTeamAlive = 0;
	foreach PRIArray(PRI)
	{
		myPRI = AOCPRI(PRI);
		if (myPRI.CurrentHealth <= 0)
			continue;

		if (myPRI.MyFamilyInfo.default.FamilyFaction == EFAC_AGATHA)
			AgathaTeamAlive += 1;
		else if (myPRI.MyFamilyInfo.default.FamilyFaction == EFAC_MASON)
			MasonTeamAlive += 1;
	}*/

	//Text = "Agathians Alive:"@string(AgathaTeamAlive)$"/"$string(AgathaSize)$"\nMasons Alive:"@string(MasonTeamAlive)$"/"$string(MasonSize)$"\n";
	Text = "Agatha Rounds:"@string(AgathaRoundsWon)$"/"$string(RoundsNeededToWin)$"\nMason Rounds:"@string(MasonRoundsWon)$"/"$string(RoundsNeededToWin);
	return Text;
}

simulated function string RetrieveObjectiveImg(EAOCFaction Faction)
{
	return "img://Objective_Icons.objective_icon_kill";
}

simulated function bool   CheckPreviousObjectiveExist()
{
	return false;
}

simulated function bool   CheckNextObjectiveExist()
{
	return false;
}


DefaultProperties
{
}
