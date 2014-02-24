class CPMBombTarget extends AOCStaticMeshActor_Usable;

var(BombTarget) string                      FriendlyLabel;
var(BombTarget) float                       TimeInSecondsToArm;
var(BombTarget) float                       TimeInSecondsToDisarm;
var(BombTarget) float                       TimeInSecondsToExplode;
var(BombTarget) AnimationInfo               ArmAnimation;
var(BombTarget) AnimationInfo               DisarmAnimation;
var(BombTarget) bool                        bUseAnimations;
var             bool                        bIsArmed;
var()           bool                        bEnabled;
var()           float                       CurrentTimeArmed;
var             AOCPawn                     CurrentUser;
var             AOCPawn                     TheArmer;

replication
{
	if(bNetDirty)
		bIsArmed, bEnabled;
}

event Reset()
{
	local CPMSeqEvent_BombCleanup dmgEvent;
	local int idx;

	super.Reset();

	bIsArmed = false;
	bEnabled = true;
	CurrentTimeArmed = 0.f;
	CurrentUser = none;
	TheArmer = none;

	//Add cleanup event trigger.
	for (idx = 0; idx < GeneratedEvents.Length; idx++)
	{
		dmgEvent = CPMSeqEvent_BombCleanup(GeneratedEvents[idx]);
		if (dmgEvent != None)
		{
			dmgEvent.CheckActivate(self, self, false);
		}
	}
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (bIsArmed)
	{
		CurrentTimeArmed += DeltaTime;
		fCurrentProgressValue = CurrentTimeArmed;
		if (CurrentTimeArmed >= TimeInSecondsToExplode)
		{
			// Activate Completion
			BombExplode();
		}
	}
}

simulated function bool UtilizeObject(AOCPawn User, bool bUseDrop, optional name BoneHit = 'none')
{
	local EAOCFaction BomberTeam;
	BomberTeam = CPMLTSOPC(User.Controller).AttackingFaction;

	if (!bEnabled)
		return false;

	if (bUseDrop) //Start Arm/Disarm
	{
		if (CurrentUser != none)
			return false;

		if (bIsArmed && User.PawnFamily.default.FamilyFaction != BomberTeam)
		{
			//Handle bomb disarming
			CurrentUser = User;
			CPMLTSOPC(User.Controller).SetForceIgnoreRotation(true);
			AOCPlayerController(User.Controller).StartHintProgressBar(0.f, TimeInSecondsToDisarm);
			if (bUseAnimations)
				User.PlayPawnAnimation(DisarmAnimation,,false);
			else
				CPMLTSOPC(User.Controller).ArmingFrozen(TimeInSecondsToDisarm);
			SetTimer(TimeInSecondsToDisarm, false, 'BombDisarm');
			return true;
		}
		else if (!bIsArmed && User.PawnFamily.default.FamilyFaction == BomberTeam && CPMLTSOPC(User.Controller).MyBomb != none)
		{
			//Handle bomb arming
			CurrentUser = User;
			//AOCPlayerController(User.Controller).ReceiveChatMessage("","ARMING",EFAC_ALL,true);
			CPMLTSOPC(User.Controller).SetForceIgnoreRotation(true);
			AOCPlayerController(User.Controller).StartHintProgressBar(0.f, TimeInSecondsToArm);
			if (bUseAnimations)
				User.PlayPawnAnimation(ArmAnimation,,false);
			else
				CPMLTSOPC(User.Controller).ArmingFrozen(TimeInSecondsToArm);
			SetTimer(TimeInSecondsToArm, false, 'BombArm');
			return true;
		}
		return false;
	}
	else //Stop Arm/Disarm
	{
		//Same for both cases
		if(bUseAnimations)
		{
			User.ManualReset();
			if (WorldInfo.NetMode == NM_DedicatedServer)
				User.Client_ForceReset();
			User.RemoveDebuff(EDEBF_ANIMATION);
		}
		else
		{
			CPMLTSOPC(User.Controller).ArmingUnfrozen();
		}
		//AOCPlayerController(User.Controller).ReceiveChatMessage("","CANCEL ARMING",EFAC_ALL,true);
		CPMLTSOPC(User.Controller).SetForceIgnoreRotation(false);
		AOCPlayerController(User.Controller).StopHintProgressBar();
		CurrentUser = none;
		ClearTimer('BombArm');
		ClearTimer('BombDisarm');
	}
}

function BombArm()
{
	local CPMSeqEvent_BombTargetArm dmgEvent;
	local int idx;

	if (CurrentUser == none || !CurrentUser.IsAliveAndWell())
		return;

	//AOCPlayerController(CurrentUser.Controller).ReceiveChatMessage("","ARMED!!",EFAC_ALL,true);
	CurrentUser.RewardObjPoints(10);
	CPMLTSOPC(CurrentUser.Controller).MyBomb.SuccessfulPlant();
	//CPMLTSOGRI(WorldInfo.GRI).Bomb.SuccessfulPlant();
	AOCPlayerController(CurrentUser.Controller).PerformedUseAction();
	TheArmer = CurrentUser;
		
	bIsArmed = true;
	//CPMLTSO(WorldInfo.Game).AddBombArmTime(TimeInSecondsToExplode);
	
	//Set off armed events...
	for (idx = 0; idx < GeneratedEvents.Length; idx++)
	{
		dmgEvent = CPMSeqEvent_BombTargetArm(GeneratedEvents[idx]);
		if (dmgEvent != None)
		{
			dmgEvent.CheckActivate(self, TheArmer, false);
		}
	}

	CPMLTSO(WorldInfo.Game).NotifyPlayersBombArmed();
}

function BombDisarm()
{
	local CPMSeqEvent_BombTargetDisarm dmgEvent;
	local int idx;

	if (CurrentUser == none || !CurrentUser.IsAliveAndWell())
		return;

	bIsArmed = false;
	
	for (idx = 0; idx < GeneratedEvents.Length; idx++)
	{
		dmgEvent = CPMSeqEvent_BombTargetDisarm(GeneratedEvents[idx]);
		if (dmgEvent != None)
		{
			dmgEvent.CheckActivate(self, CurrentUser, false);
		}
	}

	if (CurrentUser != none)
	{
		CurrentUser.RewardObjPoints(10);
		AOCPlayerController(CurrentUser.Controller).PerformedUseAction();
	}

	// Kick user off -- shouldn't have to be check anywyas.
	if (CurrentUser != none)
		AOCPlayerController(CurrentUser.Controller).PerformedUseAction();

	CPMLTSO(WorldInfo.Game).BombEndGame(false, self);
}

function BombExplode()
{
	//Explode events and attackers win the round!
	local CPMSeqEvent_BombTargetExplode dmgEvent;
	local int idx;
	bEnabled = false;
	bIsArmed = false;

	for (idx = 0; idx < GeneratedEvents.Length; idx++)
	{
		dmgEvent = CPMSeqEvent_BombTargetExplode(GeneratedEvents[idx]);
		if (dmgEvent != None)
		{
			dmgEvent.CheckActivate(self, TheArmer, false);
		}
	}
	
	// Kick user off -- shouldn't have to be check anywyas.
	if (CurrentUser != none)
		AOCPlayerController(CurrentUser.Controller).PerformedUseAction();

	CPMLTSO(WorldInfo.Game).BombEndGame(true, self);
}

simulated function EndUtilizeObject(AOCPawn User)
{
	if (User != CurrentUser)
		return;
	//Hopefully this works...
	AOCPlayerController(User.Controller).PerformedUseAction();
}

simulated function bool CanBeUsed(optional int Faction, optional AOCPawn CheckUser, optional out int bHold)
{
	local EAOCFaction BomberTeam;
	BomberTeam = CPMLTSOPC(CheckUser.Controller).AttackingFaction;
	/*if(WorldInfo.NetMode == NM_CLIENT)
		CPMLTSOPC(CheckUser.Controller).ReceiveChatMessage("", "Check can use CLIENT:"@BomberTeam,EFAC_ALL,true);
	else
		CPMLTSOPC(CheckUser.Controller).ReceiveChatMessage("", "Check can use SERVER:"@BomberTeam,EFAC_ALL,true);*/

	bHold  = 1;
	return  (bEnabled && 
			((bIsArmed && EAOCFaction(Faction) != BomberTeam && (CurrentUser == CheckUser || CurrentUser == none)) || 
			(!bIsArmed && EAOCFaction(Faction) == BomberTeam && CPMLTSOPC(CheckUser.Controller).MyBomb != none)));
}

DefaultProperties
{
	FriendlyLabel="Bomb"
	TimeInSecondsToArm=5.f
	TimeInSecondsToDisarm=7.f
	TimeInSecondsToExplode=90.f

	bUseAnimations=false

	SupportedEvents(1)=class'CPMSeqEvent_BombTargetExplode'
	SupportedEvents(2)=class'CPMSeqEvent_BombTargetDisarm'
	SupportedEvents(3)=class'CPMSeqEvent_BombTargetArm'
	SupportedEvents(4)=class'CPMSeqEvent_BombCleanup'

	bIsArmed=false
	bEnabled=true
	CurrentTimeArmed=0.f
	CurrentUser=none
	TheArmer=none

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=TRUE
		AlwaysLoadOnClient=FALSE
		AlwaysLoadOnServer=FALSE
		SpriteCategoryName="Info"
	End Object
	Components.Add(Sprite)
}
