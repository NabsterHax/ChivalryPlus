class CPMBomb extends SkeletalMeshActor
	implements(IAOCDeathListener)
	placeable;

// Reference to Mesh
var LightEnvironmentComponent LightEnv;

var Vector LastGoodLocation;

// Team that is allowed to pick up and plant this Bomb
var(Bomb) EAOCFaction           BombingTeam;

// User who just dropped this - don't let them pick up for a second
struct JustDropInfo
{
	var AOCPawn P;
	var float Time;

	structdefaultproperties
	{
		Time=1.f;
	}
};
var array<JustDropInfo>     JustDroppedUser;

// Notify Flags (Replication)
var repnotify AOCPawn CurrentUser;
var repnotify bool bReset;

// Original Spawn Location (Where to reset bomb to each round)
var Vector OriginalLocation;  
var Rotator OriginalRotation;

// State Variables
var bool bEnabled;
var bool bCanDrop;

var repnotify Vector RepLoc;

replication
{
	if (Role == ROLE_Authority && bNetDirty)
		CurrentUser, bReset, bEnabled, RepLoc;
}

simulated event ReplicatedEvent( name VarName )
{
	//`log("REPLICATED EVENT"@VarName@CurrentUser@bReset);
	if (VarName == 'CurrentUser')
	{
		if (CurrentUser == none)
		{
			//SetBase(none);
			SetRotation(Rotator(Vect(0.f, 0.f, 0.f)));
			bCollideWorld = true;
			SetPhysics(PHYS_Falling);
		}
	}
	else if (VarName == 'bReset')
	{
		if (bReset)
		{
			SetRotation(Rotator(Vect(0.f, 0.f, 0.f)));
			bCollideWorld = false;
			SetPhysics(PHYS_None);
		}
	}       
	else if (VarName == 'RepLoc')
	{
		SetPhysics(PHYS_None);
		//`log("REPLICATE LOCATION"@RepLoc);
		SetLocation(RepLoc);
	}
	else
		super.ReplicatedEvent(VarName);
}

//
// Initialization and Cleanup
//
simulated event PreBeginPlay()
{
	OriginalLocation = Location;
	OriginalRotation = Rotation;
	super.PreBeginPlay();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	bCollideWorld = false;
	SetPhysics(PHYS_None);
}

function ActivateBomb()
{
	ResetBomb();
	SetHidden(false);
	bEnabled=true;
	SetCollision(true, true);
}

function ToggleResetBomb()
{
	bReset = false;
}

function ResetBomb()
{	
	bReset = true;
	SetTimer(0.1f, false, 'ToggleResetBomb');
	bCollideWorld = false;
	SetPhysics(PHYS_None);
	SetCollision(false, false);
	SetLocation(OriginalLocation);
	SetRotation(OriginalRotation);
	SetCollision(true, true);
	RepLoc = OriginalLocation;
}

function DeactivateBomb()
{
	SetHidden(true);
	bEnabled=false;
}

//
// Utilization of Bomb
//
/** Use/discard the object, whatever it is. Returns whether or not it should stay in Pawn memory.
 */
simulated event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	local CPMPawn User;
	User = CPMPawn(Other);
	//`log("BUMP BUMP"@Other@User);
	if (User == none)
		return;

	if ( Role == ROLE_Authority)
		UserTouched(User);
	else
		User.RequestBombHit(self);
	
}

function bool ReasonableTouch(AOCPawn Pawn)
{   
	local Vector Check1, Check2;
	Check1 = Location;
	Check2 = Pawn.Location;
	Check1.Z = 0.f;
	Check2.Z = 0.f;

	if (VSize(Check1 - Check2) >= 40.f)
		return false;

	return true;
}

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local CPMPawn User;
	User = CPMPawn(Other);
	//`log("TOUCH TOUCH"@Other@User);
	if (User == none)
		return;

	if ( Role == ROLE_Authority)
		UserTouched(User);
	else
		User.RequestBombHit(self);
}

function bool UserInJustDropped(AOCPawn User)
{
	local JustDropInfo Inf;
	foreach JustDroppedUser(Inf)
	{
		if (Inf.P == User)
			return true;
	}
	return false;
}

function AllowDrop()
{
	bCanDrop = true;
}

function UserTouched(AOCPawn User)
{
	//ResetFlag
	if (!bEnabled ||  UserInJustDropped(User) || User.Health <= 0 || CurrentUser != none)
		return;
	else if(User.PawnFamily.default.FamilyFaction != BombingTeam)
	{
		return;
	}
	
	//AOCGame(WorldInfo.Game).BroadcastSystemMessage(iLocFlagHasBeenPickedUp,GetLocalizedTeamName(),class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA", User.PlayerReplicationInfo.PlayerName, ""));
	
	LastGoodLocation = User.Location;
	User.bAlwaysRelevant = true;	
	bCanDrop=false;
	SetTimer(1.f, false, 'AllowDrop');
	bReset = false;
	// Pick up Flags
	SetHidden(true);
	SetHardAttach(true);
	SetBase(User,,User.Mesh, 'b_Head');
	bCollideWorld = false;
	SetPhysics(PHYS_None);
	CurrentUser = User;
	AOCPRI(CurrentUser.PlayerReplicationInfo).bCanPerformAB = false;
	// Give user a flag weapon
	/*if (TeamToCapture == EFAC_AGATHA)
		User.GiveUserWeapon(bInvertWeapon ? MasonWeapon : AgathaWeapon);
	else
		User.GiveUserWeapon(bInvertWeapon ? AgathaWeapon : MasonWeapon);*/
	
	ClearTimer('ResetBomb');
	User.AddDeathListener(self);
	SetCollision(false, false);
	CPMLTSOPC(User.Controller).MyBomb = self;
	CPMLTSOPC(User.Controller).ReceiveChatMessage("", "You picked up the bomb!", EFAC_ALL, true);
	bNetDirty = true;
}


function DropBomb(AOCPawn User, optional bool bComplete = false)
{
	local JustDropInfo Inf;

	if (!bComplete && (!bCanDrop || (User.Physics == PHYS_Falling && User.Health > 0)))
		return;

	User.bAlwaysRelevant = false;
	User.RemoveDeathListener(self);
	SetBase(none);
	SetHardAttach(false);
	SetRotation(Rotator(Vect(0.f, 0.f, 0.f)));
	RepLoc = LastGoodLocation + Vect(0.0f, 0.f, 50.f);
	SetLocation(RepLoc);
	SetHidden(false);
	bCollideWorld = true;
	SetPhysics(PHYS_Falling);

	SetCollision(true, true, true);

	CPMLTSOPC(User.Controller).MyBomb = none;
	Inf.P = User;
	JustDroppedUser.AddItem(Inf);
	AOCPRI(CurrentUser.PlayerReplicationInfo).bCanPerformAB = true;
	CurrentUser = none;
	bNetDirty = true;

	// Notify the game
	//if (!bComplete)
		//AOCGame(WorldInfo.Game).BroadcastSystemMessage(0, class'AOCSystemMessages'.static.CreateLocalizationdata("INVALIDDATA", User.PlayerReplicationInfo.PlayerName, ""),GetLocalizedTeamName(), EFAC_ALL);
	
	bCanDrop = false;
}


function ResetJustDropped(float Delta)
{
	local int i;
	for (i = 0; i < JustDroppedUser.Length; i++)
	{
		JustDroppedUser[i].Time -= Delta;
		if (JustDroppedUser[i].Time <= 0.f)
		{
			JustDroppedUser.Remove(i, 1);
			i--;
		}
	}


}

//
// Completion
//

//For putting the bomb out of play for the rest of the round
function SuccessfulPlant()
{
	DropBomb(CurrentUser, true);
	DeactivateBomb();
	ResetBomb();
	//Game notified by bomb target --makes more sense.
}

// Check For User Death
function PawnHasDied(Actor myInstigator)
{
	if (CurrentUser != none)
		DropBomb(CurrentUser);
}

function class<Actor> GetInterfaceClass()
{
	return class'CPMBomb';
}

// Check if we're in the air to force ourselves down 
simulated event Tick(float DeltaTime)
{
	//unused local vars
	//local Vector HitLoc, HitNorm;
	//local Actor HitAct;

	super.Tick(DeltaTime);

	if ( Role == ROLE_Authority)
	{
		ResetJustDropped(DeltaTime);
	}

	// Sometimes we might be stuck in the air... 
	if(Role == ROLE_Authority)
	{
		if (bEnabled && CurrentUser == none)
		{
			bCollideWorld = true;
			SetPhysics(PHYS_Falling);
		}
		else
		{
			bCollideWorld = false;
			SetPhysics(PHYS_None);
			if(Location != OriginalLocation)
			{
				SetLocation(OriginalLocation);
				SetRotation(OriginalRotation);
			}
		}
	}	

	if (CurrentUser != none)
	{
		LastGoodLocation = CurrentUser.Location + Vect(0.f, 0.f, 20.f);
		SetHidden(true);
		//SetLocation(LastGoodLocation);
	}
	
	// NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPE?
	if (!bHidden)
		bEnabled = true; // Double check this.

	if (bEnabled && ( bHidden || Role == ROLE_Authority) && CurrentUser == none)
	{
		SetHidden(false);
		SetCollision(true, true, true);
	}

	//if (bEnabled && TeamToCapture == EFAC_AGATHA)
	//	`log("CURRENT LOCATION???"@Location@OriginalLocation@bCollideActors@bBlockActors@CurrentUser);
}


simulated function LocalizationData GetLocalizedTeamName()
{
	/*if( bInvertWeapon && TeamToCapture == EFAC_Agatha || !bInvertWeapon && TeamToCapture == EFAC_Mason )
	{
		return class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "AgathaKnights", "AOCUI");
	}
	else
	{
		return class'AOCSystemMessages'.static.CreateLocalizationdata("Common", "MasonOrder", "AOCUI");
	}*/
}

simulated function vector GetHUDMarkerLocation()
{
	if(CurrentUser != none)
	{
		return CurrentUser.Location;
	}
	else
	{
		return Location;
	}
}

defaultproperties
{
	bNoDelete=true
	bCollideActors=true
	bCollideWorld=false
	bBlockActors=false
	bAlwaysRelevant=true
	CollisionType=COLLIDE_TouchAll

	bReplicateMovement=true
	bSkipActorPropertyReplication=false

	Begin Object Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnv=MyLightEnvironment

	Begin Object Name=SkeletalMeshComponent0
		bHasPhysicsAssetInstance=true
		PhysicsAsset=PhysicsAsset'ctf_Banners.Mesh.S_CTF_Flag_Physics'
		PhysicsWeight=1
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		BlockActors=false
		CollideActors=true
		BlockRigidBody=true
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		bUpdateSkelWhenNotRendered=true
		bIgnoreControllersWhenNotRendered=FALSE
		bSkipAllUpdateWhenPhysicsAsleep=FALSE
	End Object
	CollisionComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	// sprite for editor
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
	BombingTeam=EFAC_NONE
	RemoteRole=ROLE_SimulatedProxy
	bEnabled=false
	
	bNoEncroachCheck=true
	CurrentUser=none
	bReset=false
	bCanDrop=false
	RepLoc=(X=0.f,Y=0.f,Z=0.f)
	//LastLocCheckTime=0.f
	bCanTeleport=true
	Physics = PHYS_None
}


/*class CPMBomb extends SkeletalMeshActor
	implements(IAOCDeathListener);

// Reference to Mesh
var LightEnvironmentComponent LightEnv;

var Vector LastGoodLocation;

// Team which can pick up this bomb
var(Bomb) EAOCFaction BombingTeam;

// User who just dropped this - don't let them pick up for a second
struct JustDropInfo
{
	var AOCPawn P;
	var float Time;

	structdefaultproperties
	{
		Time=1.f;
	}
};
var array<JustDropInfo> JustDroppedUser;

// Original Spawn Location (Where to reset bomb to after time goes by)
var Vector OriginalLocation;  
var Rotator OriginalRotation;

// State Variables
var bool bEnabled;



DefaultProperties
{
}
*/