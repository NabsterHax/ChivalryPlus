class CPMSwordGameGRI extends AOCFFAGRI;

var CPMSwordGamePRI LeadingPlayerPRI;
var CPMSwordGamePRI LastLeadingPlayerPRI;
var int LoadoutListLength;
var bool bPreserveHealthAndStamina;

replication
{		
	if (bNetInitial)
		LoadoutListLength, bPreserveHealthAndStamina;
	if (bNetDirty)
		LeadingPlayerPRI, LastLeadingPlayerPRI;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'LeadingPlayerPRI')
	{
		if (LeadingPlayerPRI != LastLeadingPlayerPRI && Role == Role_Authority)
		{
			CPMSwordGame(WorldInfo.Game).NotifyNewLeader(LeadingPlayerPRI);
		}
		LastLeadingPlayerPRI = LeadingPlayerPRI;
	}
}

simulated function float  RetrieveObjectiveCompletionPercentage()
{
	return LeadingPlayerPRI.CurrentLoadoutNumber / LoadoutListLength;
}

simulated function string RetrieveObjectiveName(EAOCFaction Faction)
{
	return "Sword Game";
}

simulated function string RetrieveObjectiveDescription(EAOCFaction Faction)
{
	return "Kill players to earn new loadouts.";
}

simulated function string RetrieveObjectiveStatusText(EAOCFaction Faction)
{
	local string Text;
	local CPMSwordGamePC PC;
	
	Text = (LeadingPlayerPRI != none ? LeadingPlayerPRI.PlayerName : "???")$":"@string(LeadingPlayerPRI.CurrentLoadoutNumber+1)$"/"$string(LoadoutListLength)$"\n";

	// This function should be called locally - should be able to get a local PC
	PC = CPMSwordGamePC(GetALocalPlayerController());
	if (PC != none)
	{
		Text = Text$"Your Level:"@string(PC.CurrentLoadoutNumber+1)$"/"$string(LoadoutListLength)$"\n";
		Text = Text$"Kills to next level:"@string(PC.KillsRemaining);
	}

	return Text;
}

DefaultProperties
{
}
