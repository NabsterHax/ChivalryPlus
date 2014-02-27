class CPMLTSOPC extends AOCPlayerController
	implements(ICPMPlayerController)
	implements(ICPMReadyUpPC);

var float OriginalSpectatorCamSpeed;

var CPMBomb MyBomb;
var EAOCFaction AttackingFaction;

var bool bHasMoved;
var int RoundStartTime;

var class<CPMGlobalClientConfig> ClientCfg;
var bool bForcedCustomization;

`include(CPM/include/CPMPlayerController.uci)
`include(CPM/include/CPMReadyUpPC.uci)

replication
{
	if (bNetDirty)
		MyBomb;
}

//testing

/*
exec function DumpBombInfo()
{
	//AOCPlayerController(CurrentUser.Controller).ReceiveChatMessage("","CLIENT", EFAC_ALL, true);

	ReceiveChatMessage("","CLIENT, MyBomb:"@MyBomb.Name, EFAC_ALL, true);
	ReceiveChatMessage("","CLIENT, GameBomb:"@CPMLTSOGRI(WorldInfo.GRI).Bomb.Name, EFAC_ALL, true);
	ReceiveChatMessage("","CLIENT, GameBombLoc:"@CPMLTSOGRI(WorldInfo.GRI).Bomb.Location, EFAC_ALL, true);
	
	ServerDumpBombInfo();
}

reliable server function ServerDumpBombInfo()
{
	ReceiveChatMessage("","SERVER, MyBomb:"@MyBomb.Name, EFAC_ALL, true);
	ReceiveChatMessage("","SERVER, GameBomb:"@CPMLTSOGRI(WorldInfo.GRI).Bomb.Name, EFAC_ALL, true);
	ReceiveChatMessage("","SERVER, GameBombLoc:"@CPMLTSOGRI(WorldInfo.GRI).Bomb.Location, EFAC_ALL, true);
}

exec function TestProgBar(float Max)
{
	StartHintProgressBar(0.f, Max);
}
exec function TestHintCrosshairOne(bool bShow)
{
	AOCBaseHUD(myHUD).SetOverrideHintCrosshair(bShow, EHX_Default, "Disarm");
}
exec function TestHintCrosshairTwo(bool bShow)
{
	AOCBaseHUD(myHUD).SetOverrideHintCrosshair(bShow, EHX_Use, "Disarm");
}
exec function PRIFaction()
{
	self.ReceiveChatMessage("", "PRI:"@AOCPRI(PlayerReplicationInfo).MyFamilyInfo.default.FamilyFaction,EFAC_ALL,true);
}*/

reliable client function SetAttackingFaction(EAOCFaction Fact)
{
	AttackingFaction = Fact;
	AOCBaseHUD(myHUD).SetAttackingTeam(Fact);
}

// Drop Bomb
exec function DropCarryItem()
{
	// Make sure MyBomb got replicated first
	if (!ScriptBlockedInputs[EINBLOCK_DropItem] && MyBomb != none && MyBomb.CurrentUser == Pawn)
	{
		ServerDropBomb();	
	}
}

reliable server function ServerDropBomb()
{
	// Check if we are currently holding the bomb
	if (MyBomb != none)
	{
		MyBomb.DropBomb(AOCPawn(Pawn));
	}
}

reliable client function SetBomb(CPMBomb Bomb)
{
	CPMLTSOHUD(myHUD).CreateBomb(Bomb);
}

/*
event PlayerTick(float DeltaTime)
{
	super.PlayerTick(DeltaTime);
	
	if(WorldInfo.GRI == none)
		return;

	SetBomb(CPMLTSOGRI(WorldInfo.GRI).Bomb);
}

exec function TestSetBomb()
{
	CPMLTSOHUD(myHud).CreateBomb(CPMLTSOGRI(WorldInfo.GRI).Bomb);
}*/


//If we don't have an arm/disarm animation we need to freeze the player instead
function ArmingFrozen(float MaxDuration)
{
	if(Pawn != none && AOCPawn(Pawn) != none)
	{
		AOCPawn(Pawn).ChangePawnState(ESTATE_FROZEN);
	}

	SetTimer(MaxDuration, false, 'ArmingUnfrozen');
}

function ArmingUnfrozen()
{
	ClearTimer('ArmingUnfrozen');
	if(AOCPawn(Pawn) != none)
	{
		AOCPawn(Pawn).ChangePawnState(ESTATE_IDLE);
	}
}

reliable client function SetForceIgnoreRotation(bool bIgnore)
{
	bForceIgnoreRotation = bIgnore;
}

reliable client function ShowHalfTimeHeader(bool bShow)
{
	AOCBaseHUD(myHUD).ShowLargeHeaderText(bShow, "HALF TIME", 10.f);
}

reliable client function ShowBombArmedHeader()
{
	AOCBaseHUD(myHUD).ShowLargeHeaderText(true, "The bomb has been armed!", 3.f);
	SetTimer(3.f, false, 'HideHeaderText');
	//Start bom armed noise
}

reliable client function ShowDefaultGameHeader()
{
	if (AOCGRI(Worldinfo.GRI) == none)
	{
		SetTimer(0.1f, false, 'ShowDefaultGameHeader');
		return;
	}
	
	if (AOCBaseHUD(myHUD).ShowLargeHeaderText(true, "<font color=\"#FFCC00\">"$CPMLTSOGRI(WorldInfo.GRI).RetrieveObjectiveName(CurrentFamilyInfo.default.FamilyFaction)$"</font>\n<font color=\"#B1D1FF\">"$CPMLTSOGRI(WorldInfo.GRI).RetrieveObjectiveDescription(CurrentFamilyInfo.default.FamilyFaction)$"</font>", 6.f))
	{
		SetTimer(6.f, false, 'HideHeaderText');
	}

	//ReceiveLocalizedHeaderText("<font color=\"#FFCC00\">"$AOCFFAGRI(WorldInfo.GRI).FFAObjectiveName$"</font>\n<font color=\"#B1D1FF\">"@AOCFFAGRI(WorldInfo.GRI).FFAObjectiveDescription$"</font>");
}

function SwapTeam()
{
	local int Offset, i;
	local class<AOCFamilyInfo> InputFamily;
	local vehicle DrivenVehicle;
	local class<AOCPawn> PawnClass;
	local SCustomizationChoice CustomizationChoices;

	PawnClass = class<AOCPawn>(AOCGame(WorldInfo.Game).DefaultPawnClass);

	if(CurrentFamilyInfo.default.FamilyFaction == EFAC_Agatha)
			Offset = 5;
		else
			Offset = -5;

	for (i = 0; 
		i < PawnClass.default.AllClasses.Length 
		&& PawnClass.default.AllClasses[i] != CurrentFamilyInfo; 
		++i);
	i += Offset;

	InputFamily = PawnClass.default.AllClasses[i];

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

	CurrentFamilyInfo=InputFamily;

	DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
		DrivenVehicle.DriverLeave(true);
	
	AOCPRI(PlayerReplicationInfo).ToBeClass = InputFamily;
	SwitchToNewClassWeapons(InputFamily.default.FamilyFaction);
	
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	
	if ( Role == ROLE_Authority)
	{
		bHasMoved = false;
		SetTimer(60.f, false, 'KillAFKPawn');
	}

	SetForceIgnoreRotation(false);
}

function KillAFKPawn()
{
	//Suicide();
}

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		super.PlayerMove(DeltaTime);
		if ( Role == ROLE_Authority)
		{
			if (!bHasMoved && bMoving)
			{
				bHasMoved = true;
				ClearTimer('KillAFKPawn');
			}
		}
	}
}

reliable server function SetReady(bool bAmReady)
{
	super.SetReady(bAmReady);
	if(IsInState('PlayerWaiting') && bAmReady)
	{
		GenericSwitchToObs(true);
	}
}

function Reset()
{
	local bool lPossessYet;
	//`log("PRE RESET LTS PC"@bPossessedAPawn);
	lPossessYet = bPossessedAPawn;
	super.Reset();
	bPossessedAPawn = lPossessYet;
	//`log("RESET LTS PC"@bPossessedAPawn);
	WaitDelay = WorldInfo.TimeSeconds + 10;
	SetForceIgnoreRotation(false);
}

function PawnDied(Pawn P)
{
	super(UTPlayerController).PawnDied(P);
	//`log("LTS SWITCH TO OBS");
	SetForceIgnoreRotation(false);
	RemoveCombatHUDElements();
	PlayDeathPPEffects();
	PawnDiedSwitchToObs();
}

DefaultProperties
{
	bHasMoved = false
	RoundStartTime = 0

	bRequestedHUD=false

	ClientCfg = class'CPMGlobalClientConfig'
}
