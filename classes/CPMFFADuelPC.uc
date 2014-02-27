class CPMFFADuelPC extends CPMFFAPlayerController;

var CPMFFADuelPawn LastLookedAtPawn;
var CPMFFADuelPawn LastBowedToPawn;
var bool bAlreadyBowing;

var CPMFFADuelPawn DuelOpponent;
var CPMFFADuelPawn ToBeDuelOpponent;
var CPMFFADuelPawn RequestedOpponent;

replication
{
	if(bNetDirty)
		DuelOpponent, RequestedOpponent;
}

reliable client function ShowDefaultGameHeader()
{
	if (AOCGRI(Worldinfo.GRI) == none)
	{
		SetTimer(0.1f, false, 'ShowDefaultGameHeader');
		return;
	}
	
	if (AOCBaseHUD(myHUD).ShowLargeHeaderText(true, "<font color=\"#FFCC00\">"$"Free Duel"$"</font>\n<font color=\"#B1D1FF\">"$"1v1 Combat The Classic Way"$"</font>", 6.f))
	{
		SetTimer(6.f, false, 'HideHeaderText');
	}

	//ReceiveLocalizedHeaderText("<font color=\"#FFCC00\">"$AOCFFAGRI(WorldInfo.GRI).FFAObjectiveName$"</font>\n<font color=\"#B1D1FF\">"@AOCFFAGRI(WorldInfo.GRI).FFAObjectiveDescription$"</font>");
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	//make sure our variables are reset for this new pawn
	LastLookedAtPawn=none;
	LastBowedToPawn=none;
	bAlreadyBowing=false;
	DuelOpponent=none;
	RequestedOpponent=none;
}

simulated event PlayerTick(float DeltaTime)
{
	local CPMFFADuelPawn Tmp;
	super.PlayerTick(DeltaTime);

	Tmp = GetPlayerLookingAt();
	if (Tmp != none && Tmp.IsAliveAndWell())
	{
		SetLastLookedAtPawn(Tmp);
	}

	if(LastLookedAtPawn != none)
	{
		if(HasBowed())
		{
			TryChallenge(LastLookedAtPawn);
			/*
			if (LastBowedToPawn != LastLookedAtPawn)
			{
				self.ReceiveChatMessage("", "You bowed to"@LastLookedAtPawn.PlayerReplicationInfo.PlayerName, EFAC_ALL, true);
			}
			LastBowedToPawn = LastLookedAtPawn;*/
		}
	}
}

reliable server function TryChallenge(CPMFFADuelPawn ChallengePawn)
{
	local CPMFFADuelPC PC;
	PC = CPMFFADuelPC(ChallengePawn.Controller);
	if(!ChallengePawn.IsAliveAndWell() || IsInDuel() || ChallengePawn == RequestedOpponent)
		return;

	if(PC.IsInDuel())
	{
		ReceiveChatMessage("", ChallengePawn.PlayerReplicationInfo.PlayerName@" is already in a duel! Stay back!", EFAC_ALL, true);
	}
	else
	{
		if(PC.Challenge(CPMFFADuelPawn(self.Pawn)))
		{
			RequestedOpponent=none;
			ReceiveChatMessage("", "You accepted"@ChallengePawn.PlayerReplicationInfo.PlayerName$"'s challenge!", EFAC_ALL, true);
			Pawn.HealDamage(AOCPawn(Pawn).HealthMax, self, none);
			AOCPawn(Pawn).RestartHealthRegen();
			AOCPawn(Pawn).Stamina = AOCPawn(Pawn).MaxStamina;
			AOCPawn(Pawn).ReplenishAmmo();
			ShowPreDuelHeader();
			ToBeDuelOpponent = ChallengePawn;
			SetTimer(2.f, false, 'BeginDuel');
			ClearTimer('RequestedOpponentTimeout');
		}
		else
		{
			ReceiveChatMessage("", "You challenged"@ChallengePawn.PlayerReplicationInfo.PlayerName@"to a duel!", EFAC_ALL, true);
			ClearTimer('RequestedOpponentTimeout');
			RequestedOpponent = ChallengePawn;
			SetTimer(5.f, false, 'RequestedOpponentTimeout');
		}
	}
}

function bool Challenge(CPMFFADuelPawn cPawn)
{
	//quick check to make sure the pawns we are interested in are still alive
	if(!DuelOpponent.IsAliveAndWell())
		DuelOpponent=none;
	if(!RequestedOpponent.IsAliveAndWell())
		RequestedOpponent=none;

	if(DuelOpponent != none)
		return false;

	if (RequestedOpponent == cPawn)
	{
		RequestedOpponent=none;
		ReceiveChatMessage("", cPawn.PlayerReplicationInfo.PlayerName@"accepted your duel request!", EFAC_ALL, true);
		Pawn.HealDamage(AOCPawn(Pawn).HealthMax, self, none);
		AOCPawn(Pawn).RestartHealthRegen();
		AOCPawn(Pawn).Stamina = AOCPawn(Pawn).MaxStamina;
		AOCPawn(Pawn).ReplenishAmmo();
		ShowPreDuelHeader();
		ToBeDuelOpponent = cPawn;
		SetTimer(2.f, false, 'BeginDuel');
		ClearTimer('RequestedOpponentTimeout');
		return true;
	}
	else
	{
		ReceiveChatMessage("", cPawn.PlayerReplicationInfo.PlayerName@"has challenged you to a duel!", EFAC_ALL, true);
		return false;
	}
}

function BeginDuel()
{
	if(ToBeDuelOpponent.IsAliveAndWell())
	{
		ShowDuelHeader();
		DuelOpponent = ToBeDuelOpponent;
	}
	ToBeDuelOpponent = none;
}

function bool IsInDuel()
{
	//quick check to make sure the pawns we are interested in are still alive
	if(!DuelOpponent.IsAliveAndWell())
		DuelOpponent=none;
	if(!RequestedOpponent.IsAliveAndWell())
		RequestedOpponent=none;
	if(!ToBeDuelOpponent.IsAliveAndWell())
		ToBeDuelOpponent=none;

	return (DuelOpponent != none || ToBeDuelOpponent != none);
}

function RequestedOpponentTimeout()
{
	RequestedOpponent=none;
}

reliable client function ShowPreDuelHeader()
{
	if(AOCBaseHUD(myHUD).ShowLargeHeaderText(true, "<font color=\"#0B610B\">"$"Get Ready..."$"</font>", 0.f))
		SetTimer(2.f, false, 'HideHeaderText');
	PlaySound(SoundCue'A_Meta.Duel_Ready',true);
}

reliable client function ShowDuelHeader()
{
	HideHeaderText();
	if (AOCBaseHUD(myHUD).ShowLargeHeaderText(true, "<font color=\"#0B610B\">"$"Fight!"$"</font>", 2.f))
		SetTimer(2.f, false, 'HideHeaderText');
	//PlaySound(SoundCue'A_Meta.rank_up',true);
	PlaySound(SoundCue'A_Meta.Duel_Fight',true);

	//Also gonna stick the timer start for the forfeit in here
	SetTimer(30.f, false, 'ForfeitReminder');
}

function ForfeitReminder()
{
	ReceiveChatMessage("", "If your opponent has run away, remember you can suicide (F10) to end the fight.", EFAC_ALL, true, true, "#648BB1");
}

reliable server function ServerClearForfeitTimer()
{
	ClientClearForfeitTimer();
}

reliable client function ClientClearForfeitTimer()
{
	ClearTimer('ForfeitReminder');
}

function bool HasBowed()
{
	if(!bAlreadyBowing && Pawn.GetViewRotation().Pitch < -12000)
	{
		bAlreadyBowing = true;
		return true;
	}
	else if (bAlreadyBowing && Pawn.GetViewRotation().Pitch > -12000)
	{
		bAlreadyBowing = false;
	}
	return false;
}

function SetLastLookedAtPawn(CPMFFADuelPawn newPawn)
{
	ClearTimer('LastLookedAtTimeout');
	LastLookedAtPawn = newPawn;
	SetTimer(3.f, false, 'LastLookedAtTimeout');
}

function LastLookedAtTimeout()
{
	LastLookedAtPawn = none;
}

function CPMFFADuelPawn GetPlayerLookingAt()
{
	local Actor myViewTarget;
	local Vector Loc,Norm;
	local Vector Start,End;

	Start = Pawn.GetPawnViewLocation();
	End = Pawn.GetPawnViewLocation() + Vector(Pawn.GetViewRotation()) * 600;
	myViewTarget = Trace( Loc, Norm, End, Start, true );
	
	return CPMFFADuelPawn(myViewTarget);
}

function ChangeToNewClass()
{
	local bool bIsCustomizationInfoValid;
	
	/*
	if(!AreWeaponsValidForCurrentFamilyInfo())
	{
		FindFirstAvailableLoadoutForCurrentFamilyInfo();
	}*/

	bIsCustomizationInfoValid = class'AOCCustomization'.static.AreCustomizationChoicesValidFor(CustomizationInfo, EFAC_FFA, CurrentFamilyInfo.default.ClassReference, PlayerReplicationInfo);

	if(bIsCustomizationInfoValid)
	{
		AOCPawn(Pawn).PawnInfo.myCustomization = CustomizationInfo;
	}
	else
	{
		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor1 = byte(CustomizationClass.static.GetDefaultTabardColorIndex(EFAC_FFA, 0));
		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor2 = byte(CustomizationClass.static.GetDefaultTabardColorIndex(EFAC_FFA, 1));
		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor3 = byte(CustomizationClass.static.GetDefaultTabardColorIndex(EFAC_FFA, 2));

		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor1 = byte(CustomizationClass.static.GetDefaultEmblemColorIndex(EFAC_FFA, 0));
		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor2 = byte(CustomizationClass.static.GetDefaultEmblemColorIndex(EFAC_FFA, 1));
		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor3 = byte(CustomizationClass.static.GetDefaultEmblemColorIndex(EFAC_FFA, 2));

		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor1 = byte(CustomizationClass.static.GetDefaultShieldColorIndex(EFAC_FFA, 0));
		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor2 = byte(CustomizationClass.static.GetDefaultShieldColorIndex(EFAC_FFA, 1));
		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor3 = byte(CustomizationClass.static.GetDefaultShieldColorIndex(EFAC_FFA, 2));
	}
	
	AOCPawn(Pawn).PawnInfo.myFamily = CurrentFamilyInfo;
	AOCPawn(Pawn).PawnInfo.myPrimary = PrimaryWeapon;
	AOCPawn(Pawn).PawnInfo.myAlternatePrimary = AltPrimaryWeapon;
	AOCPawn(Pawn).PawnInfo.mySecondary = SecondaryWeapon;
	AOCPawn(Pawn).PawnInfo.myTertiary = TertiaryWeapon;
	AOCPRI(Pawn.PlayerReplicationInfo).MyFamilyInfo = CurrentFamilyInfo;

	AOCPawn(Pawn).ReplicatedEvent('PawnInfo');
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

		// set the class to spawn to next
		//`log("CHANGED CLASS");
		//PreviousFamilyInfo=CurrentFamilyInfo;
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

		//if (bMarkNewTeam)
		//	ChangeToNewTeam();

		// change player to new team if it's a new team
		/*
		if (bMarkNewTeam && Pawn != none)
		{
			DrivenVehicle = Vehicle(Pawn);
			if( DrivenVehicle != None )
				DrivenVehicle.DriverLeave(true);

			AOCPawn(Pawn).ReplicatedHitInfo.DamageString = "Q"; 
			AOCPawn(Pawn).ReplicatedHitInfo.HitLocation = Pawn.Location;
			AOCPawn(Pawn).ReplicatedHitInfo.DamageType = class'AOCDmgType_Swing';
			AOCPawn(Pawn).ReplicatedHitInfo.BoneName = 'b_spine_C';
			AOCPawn(Pawn).ReplicatedHitInfo.AttackType = Attack_Overhead;
			//AOCPawn(Pawn).ReplicatedHitInfo.
			Pawn.Died(none, class'AOCDmgType_Swing', vect(0, 0, 0));

			SwitchToNewClassWeapons(InputFamily.default.FamilyFaction);

			if (bNegPoints)
			{
				AOCPRI(PlayerReplicationInfo).Score -= 10;
			}
			else
			{
				AOCPRI(PlayerReplicationInfo).Deaths -= 1;
			}
		}
		else
		{
			AOCGame(WorldInfo.Game).LocalizedPrivateMessage(self, 11, class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA",InputFamily.default.Faction, ""),
				class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA",InputFamily.default.FamilyID,""));
		}
		*/
	}
}

reliable server function FinishedChoosingLoadout()
{	
	local AOCLoadoutChangeVolume A;

	// Make sure we're no longer observer mode
	if (iObserving == 2)
		SwitchToObserverMode(0);

	SavedFamilyInfo = AOCPRI(PlayerReplicationInfo).ToBeClass;
		
	if (AOCPawn(Pawn) != none && !bMarkNewTeam)
	{
		//If we're in a LoadoutChangeVolume, ask Game to give us a new Pawn
		foreach Pawn.TouchingActors(class'AOCLoadoutChangeVolume', A)
		{ 	
			AOCGame(WorldInfo.Game).LoadoutChangeSpawnPlayer(self);
			return;
		}
	}
	
	if (AOCPawn(Pawn) != none && !IsInDuel())
	{
		AOCGame(WorldInfo.Game).LoadoutChangeSpawnPlayer(self);
	}
}

DefaultProperties
{
	LastLookedAtPawn=none
	LastBowedToPawn=none
	bAlreadyBowing=false

	DuelOpponent=none
	RequestedOpponent=none
}
