class CPMSwordGamePC extends CPMFFAPlayerController;

var int CurrentLoadoutNumber;
var int KillsRemaining;
var float TmpHealth, TmpStamina; //percentages
var bool bUpdateHealthAndStamina; //Set previous health and stam on possess
var bool bLevelUpOnActive;

replication
{
	if (bNetDirty)
		CurrentLoadoutNumber, KillsRemaining;
}

//TESTING
/*exec function TestSetLoadout(int i)
{
	S_SetLoadout(CurrentLoadoutNumber+i);
}
reliable server function S_SetLoadout(int i)
{
	SetLoadout(i);
}*/

reliable server function RequestSetup()
{
	CPMSwordGame(WorldInfo.Game).SetupNewPlayer(self);
}

function SetLoadout(int LoadoutNum, optional bool SpawnNow=true)
{
	local Loadout NewLoadout;
	local class<AOCWeapon> SpecialTertiary, SpecialAltPrim;
	
	//Check if we've won!
	if(CPMSwordGame(WorldInfo.Game).CheckWin(LoadoutNum, self))
		return;

	//Take note of Health and Stamina percentage
	if(CPMSwordGameGRI(WorldInfo.GRI).bPreserveHealthAndStamina)
	{
		TmpHealth = AOCPRI(Pawn.PlayerReplicationInfo).CurrentHealth / Pawn.HealthMax;
		TmpStamina = AOCPawn(Pawn).Stamina / AOCPawn(Pawn).MaxStamina;
	}

	if (LoadoutNum < 0)
		LoadoutNum = 0;

	NewLoadout = CPMSwordGame(WorldInfo.Game).LoadoutList[LoadoutNum];
	CurrentLoadoutNumber = LoadoutNum;
	CPMSwordGamePRI(PlayerReplicationInfo).CurrentLoadoutNumber = LoadoutNum;
	SpecialTertiary = class'AOCWeapon_None';
	SpecialAltPrim = class'AOCWeapon_None';

	if (class<AOCWeapon_Longbow>(NewLoadout.Weapon) != none)
		SpecialTertiary = class'AOCWeapon_ProjBodkin';
	else if (class<AOCWeapon_JavelinMelee>(NewLoadout.Weapon) != none)
		SpecialAltPrim = class<AOCWeapon_JavelinMelee>(NewLoadout.Weapon).default.AlternativeMode;

	SetNewClass(NewLoadout.Family);
	SetWeapons(NewLoadout.Weapon, SpecialAltPrim, class'AOCWeapon_None', SpecialTertiary);
	KillsRemaining = NewLoadout.KillsToLevel;
	if (SpawnNow && Pawn.IsAliveAndWell())
	{
		//CPMSwordGame(WorldInfo.Game).LoadoutChangeSpawnPlayer(self);
		bLevelUpOnActive = true;
		bUpdateHealthAndStamina = true;
	}

	//Check if we're the new leader
	if (LoadoutNum > CPMSwordGameGRI(WorldInfo.GRI).LeadingPlayerPRI.CurrentLoadoutNumber)
	{
		CPMSwordGameGRI(WorldInfo.GRI).LeadingPlayerPRI = CPMSwordGamePRI(PlayerReplicationInfo);
	}
}

function CheckLevelUp()
{
	if (bLevelUpOnActive && Pawn.IsAliveAndWell() && AOCPawn(Pawn).Weapon.IsInState('Active'))
	{
		CPMSwordGame(WorldInfo.Game).LoadoutChangeSpawnPlayer(self);
		bLevelUpOnActive = false;
	}
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	if (bUpdateHealthAndStamina)
	{
		inPawn.Health = Clamp(int(inPawn.HealthMax * TmpHealth), 1, inPawn.HealthMax);
		AOCPRI(inPawn.PlayerReplicationInfo).CurrentHealth = inPawn.Health;
		AOCPawn(inPawn).Stamina = Clamp(int(AOCPawn(inPawn).MaxStamina * TmpStamina), 0, AOCPawn(inPawn).MaxStamina);
		bUpdateHealthAndStamina = false;
	}
}

function LevelStolen(Controller Killer)
{
	ReceiveChatMessage("", Killer.PlayerReplicationInfo.PlayerName@"stole a level from you!", EFAC_ALL, true, true, "#FF0000");
	SetLoadout(CurrentLoadoutNumber-1, false); //Steal a level, or just a kill?
}

function ScoreSteal(Controller Other)
{
	ReceiveChatMessage("", "You stole a level from"@Other.PlayerReplicationInfo.PlayerName$"!", EFAC_ALL, true, true, "#2EFE2E");
	PlaySound(SoundCue'A_Meta.rank_up',false);
	SetLoadout(CurrentLoadoutNumber+1);
}

function ScoreKill()
{
	KillsRemaining--;
	if (KillsRemaining <= 0 && !bLevelUpOnActive)
	{
		ReceiveChatMessage("", "You reached the next level!", EFAC_ALL, true, true, "#2EFE2E");
		PlaySound(SoundCue'A_Meta.rank_up',false);
		SetLoadout(CurrentLoadoutNumber+1);
	}
}

function PunishSuicide()
{
	ReceiveChatMessage("", "You lost a level from suiciding.", EFAC_ALL, true, true, "#FF0000");
	SetLoadout(CurrentLoadoutNumber-1, false); //Steal a level, or just a kill?
}

reliable client function ShowDefaultGameHeader()
{
	if (AOCGRI(Worldinfo.GRI) == none)
	{
		SetTimer(0.1f, false, 'ShowDefaultGameHeader');
		return;
	}

	ReceiveLocalizedHeaderText("<font color=\"#FFCC00\">Sword Game</font>\n<font color=\"#B1D1FF\">Kill players to earn new loadouts.</font>");
}

function SetNewClass(class<AOCFamilyInfo> InputFamily, optional bool bNegPoints = true, optional bool bForceSwitch = false, optional SCustomizationChoice CustomizationChoices )
{
	local class<AOCFamilyInfo> OldFamily;
	//local vehicle DrivenVehicle;
	
	if(CustomizationChoices.Character == -1 || CurrentFamilyInfo != InputFamily)
	{
		bWaitingForCustomizationInfo = true;
		ClientUpdateCustomizationInfo(InputFamily.default.FamilyFaction, InputFamily.default.ClassReference);
	}
	else
	{
		bWaitingForCustomizationInfo = false;
		CustomizationInfo = CustomizationChoices;
	}

	AOCPRI(PlayerReplicationInfo).ToBeClass = InputFamily;
	if (CurrentFamilyInfo!=InputFamily)
	{
		if (CurrentFamilyInfo.default.FamilyFaction != InputFamily.default.FamilyFaction && (bNegPoints ||  bForceSwitch))
		{
			//`log("NEW TEAM"@bReady);
			bMarkNewTeam = true;
		}

		if (!bNegPoints && !bForceSwitch)
		{
			// We want to request a forward spawn
			SetTimer(10.f, false, 'RequestImmediateRespawn');
		}

		OldFamily = CurrentFamilyInfo;
		CurrentFamilyInfo=InputFamily;
		// If we're changing to another class on another team then try to find new weapons
		if (bForceSwitch)
		{
			if (OldFamily.default.ClassReference != CurrentFamilyInfo.default.ClassReference)
			{
				FindFirstAvailableLoadoutForCurrentFamilyInfo();
			}
		}
	}
}

function bool AreWeaponsValidForCurrentFamilyInfo()
{
	return true;
}

DefaultProperties
{
	CurrentLoadoutNumber=-1
	TmpHealth=1.0
	TmpStamina=1.0
	bLevelUpOnActive=false
}
