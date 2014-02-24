class YOPawn extends CPMPawn;

// Temporary burn DPS fix //
simulated function SetPawnOnFire(ParticleSystem FirePS, Controller Cont, optional Actor InflictedBy = none, optional class<AOCDamageType> dmgType = none, optional float OverrideTime = 0.0f)
{
	//`log("SET PAWN ON FIRE"@BurningPSComp);

	// record that pawn is on fire
	if (Role == ROLE_Authority && !bIsBurning)
	{
		bIsBurning=true;

		if(dmgType != none && class<AOCDmgType_BoilingOilBurn>(dmgType) != none)
		{
			BurnStatus = EBURN_Oil;
		}
		else
		{
			BurnStatus = EBURN_Fire;
		}

		LastBurnHit = Cont;

		if (IsAliveAndWell())
			PlayPawnOnFireSound();

		if (WorldInfo.NetMode == NM_STANDALONE)
		{
			handleFireParticles();
			StartFireSkinEffect();
		}
		
		//setting self on fire doesn't override inflicted by (prevents players from suiciding by fire to prevent fire kill by another)
		if(SetOnFireBy == none)
		{
			if(InflictedBy == none)
			{
				SetOnFireBy = Controller;
			}
		}
		else
		{
			if(InflictedBy == none)
				SetOnFireBy = Controller;
			else
				SetOnFireBy = Cont;
		}
	}
	
	// Check damage type
	if (dmgType == none)
	{
		// Default AOCDmgType_Burn damage over time
		burnDamage = 7.0f; //class'AOCDmgType_Burn'.default.DamageOverTime; -- Crusty get on those class constants!
		if (OverrideTime > 0.0f)
		{
			SetTimer(OverrideTime, false, 'StopFireOnPawn');
		}
		else
		{
			SetTimer(class'AOCDmgType_Burn'.default.DOTTime, false, 'StopFireOnPawn');
		}

		if (!bIsBot)
			ToggleFirePE(true);
	}
	else
	{
		// Custom burn damage over time
		burnDamage = dmgType.default.DamageOverTime;
		SetTimer(dmgType.default.DOTTime, false, 'StopFireOnPawn');

		if (!bIsBot)
		{
			if (class<AOCDmgType_BoilingOilBurn>(dmgType) != none)
			{				
				ToggleOilPE(true);
			}
			else
			{
				ToggleFirePE(true);
			}
		}
	}
}

//Make the pawn use CPMs Dodge class
simulated function VerifyDodgeSMInitialize()
{
	if (DodgeSM == none)
	{
		// Create Dodge Object
		DodgeSM = new(Outer) class'YODodge';
		DodgeSM.OwnerPawn = self;
	}
}

//Sprint lockout fix //
function StartSprintRecovery()
{
	/*if(IsTimerActive('EndSprintRecovery'))
	{
		ClearTimer('EndSprintRecovery');
	}
	bForceNoSprint = true;
	SetTimer(0.5f, false, 'EndSprintRecovery');*/
}

simulated function bool DetectSuccessfulParry(out HitInfo Info, out int bParry, bool bCheckParryOnly, int ParryLR)
{
	local int StaminaDamage;
	//`log("DETECT:"@Info.DamageType@Info.HitActor.StateVariables.bIsActiveShielding@Info.HitComp@Info.HitActor.ShieldMesh@Info.HitActor.Mesh);
	if (Info.DamageType.default.bIsProjectile && (!Info.HitActor.StateVariables.bIsActiveShielding || Info.HitComp != Info.HitActor.ShieldMesh || Info.HitComp != Info.HitActor.BackShieldMesh))
		return false;

	bParry = 1;
	StaminaDamage = 0;
	
	// make the weapon [and thus the pawn] go into a deflect state
	if ( !Info.DamageType.default.bIsProjectile )
	{
		AOCWeapon(Weapon).ActivateDeflect(Info.HitActor.StateVariables.bIsParrying);
		AOCWeaponAttachment( CurrentWeaponAttachment ).PlayParriedSound();
		
		DisableSprint(true);
		StartSprintRecovery();
	}	
	
	// opponent has a successful parry
	AOCWeapon(Info.HitActor.Weapon).NotifySuccessfulParry(Info.AttackType, ParryLR);
	
	if(Info.HitActor.StateVariables.bIsActiveShielding)
	{
		AOCWeaponAttachment( Info.HitActor.CurrentWeaponAttachment ).PlayParrySound(true);
		
		// do a stamina loss only if it's a melee attack
		if (!Info.DamageType.default.bIsProjectile)
		{
			StaminaDamage = Info.HitActor.ShieldClass.NewShield.static.CalculateParryDamage(Info.HitDamage);
		
			if (!Info.HitActor.HasEnoughStamina(StaminaDamage))
			{
				StaminaDamage = Info.HitActor.Stamina; 
				Info.HitActor.ConsumeStamina(StaminaDamage);
				// Regain 30 stamina
				Info.HitActor.ConsumeStamina(-30.f);
				AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), true, true, AOCWeapon(Weapon).bTwoHander);
				Info.HitDamage = 0.0f;
				
				AOCGame(WorldInfo.Game).DisplayDebugDamage(Info.HitActor, self, EDAM_Stamina, StaminaDamage);
				return true;
			}
			
			Info.HitActor.ConsumeStamina(StaminaDamage);
		}
		
		//Parry means health damage is completely negated
		Info.HitDamage = 0.0f;
		
		AOCGame(WorldInfo.Game).DisplayDebugDamage(Info.HitActor, self, EDAM_Stamina, StaminaDamage);
		
		// flinch if it's a kick
		if (Info.AttackType == Attack_Shove)
			AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), true, true, false);
	}
	else if(Info.HitActor.StateVariables.bIsParrying)
	{
		AOCWeaponAttachment( Info.HitActor.CurrentWeaponAttachment ).PlayParrySound(false);
		
		StaminaDamage = AOCWeapon(Info.HitActor.Weapon).CalculateParryDamage(AOCWeapon(Info.Instigator.Weapon), Info.AttackType);
			
		if (!Info.HitActor.HasEnoughStamina(StaminaDamage))
		{
			StaminaDamage = Info.HitActor.Stamina;
			Info.HitActor.ConsumeStamina(StaminaDamage);
			// Regain 30 stamina
			Info.HitActor.ConsumeStamina(-30.f);
			AOCWeapon(Info.HitActor.Weapon).ActivateFlinch(true, Info.HitActor.GetHitDirection(Location), true, true, AOCWeapon(Weapon).bTwoHander);
			Info.HitDamage = 0.0f;
			return true;
		}
			
		AOCGame(WorldInfo.Game).DisplayDebugDamage(Info.HitActor, self, EDAM_Stamina, StaminaDamage);
		
		Info.HitActor.ConsumeStamina(StaminaDamage);
		
		//Parry means health damage is completely negated
		Info.HitDamage = 0.0f;
	}

	return true;

}

//Stamina Regen //
simulated function RegenStamina()
{
    if(((Weapon == none) || !bRegenStamina) || StateVariables.bIsSprinting)
    {
        return;
    }

    if((((Stamina < MaxStamina) && !bIsCrouching) && Weapon.IsInState('Active')) && PawnState != 3)
    {
        Stamina += 1.0;
    }

    else
    {

        if(((Stamina < MaxStamina) && Weapon.IsInState('Active')) && PawnState != 3)
        {
            Stamina += 1.60;
        }
    }
}

// Chase Mechanic, low stamina sound //

simulated function StartDrafting()
{
	if (IsChasingEnemy())
	{
		AddDebuff(false, EDEBF_DRAFT, 1.2f, 2.0f, false);
	}
	else
	{
		RemoveDebuff(EDEBF_DRAFT);
		ClearTimer('StartDrafting');
	}
}

simulated function bool IsChasingEnemy()
{
	local AOCPawn Tmp;
	foreach VisibleCollidingActors(class'AOCPawn', Tmp, 450.f)
	{
		if(Tmp.Health > 0  
			&& Tmp.PawnFamily.default.FamilyFaction != PawnFamily.default.FamilyFaction 
			&& Acos(GetForwardDirection() dot Normal(Tmp.Location - Location)) <= Pi / 4.f    // Facing the enemy
			//&& Acos(GetForwardDirection() dot Tmp.GetForwardDirection()) <= Pi / 4.f          // Both facing the same direction
			)
		{
			return true;
		}
	}
	return false;
}

/** Called every tick. Currently used to do the following:
 *  -Handle Movement Debuffs
 *  -Projectile spread
 *  -Other things that no one's added to this comment
 *  
 *  CHIVPLUS: 
 *  Currently changes chase mechanic at //Drafting
 */
simulated event Tick( float DeltaTime )
{
	local float Value, height, radius;
	local EMoveDir MoveDir;
	local Actor TraceObject;
	local vector HitLocation;
	local vector HitNormal;
	local vector ActorEyes;
	local vector TraceEndpoint;
	local vector ActorRotVector;
	local TraceHitInfo myHitInfo;
	local vector RealStartLoc;
	local float DesiredSpread;
	local int LastHealth;
	local Actor ControllerViewTarget;
	local MaterialInstanceConstant MIC;
	
	//Attempting to solve issue where all pawns (other than friends) become non-net-relevant. I assume this is because SrcLocation in IsNetRelevant( ) is wrong, and this happens if the PlayerController's ViewTarget isn't the pawn
	//The ViewTarget can be set incorrectly by some RPCs and who knows what else. I don't have the time to pick through and figure out everything that could break it, and I can't even repro this issue...
	if(Role == ROLE_Authority && PlayerController(Controller) != none && Controller.Pawn == self)
	{
		ControllerViewTarget = PlayerController(Controller).GetViewTarget();
	
		if(ControllerViewTarget != self && CameraActor(ControllerViewTarget) == none)
		{
			PlayerController(Controller).SetViewTarget(self);
		}
	}
	
	//BegVelocity = Velocity;
	CheckUpdateSSSC();
	
	if (Role == ROLE_Authority && AOCPlayerController(Controller) != none && AOCPlayerController(Controller).bIsWarmupFrozen && PawnState != ESTATE_FROZEN)
	{
		PawnState = ESTATE_FROZEN;
	}

	// check on stamina
	if (Role == ROLE_Authority && Stamina <= 0 && bRegenStamina)
	{
		//`log("RESUME STAMINA REGEN TIMER");
		bRegenStamina = false;
		SetTimer(3.0f, false, 'ResumeStaminaRegen');
	}

	PlayLowStaminaLoop(Stamina < MaxStamina * 0.3f && Health > 0.0f);

	if(PawnState == ESTATE_FROZEN)
	{
		GroundSpeed = 0;
	}
	else
	{
		// check for movement debuffs first
		ModifyVelocity(DeltaTime, Velocity);

		// handle movement debuffs - has to come after ModifyVelocity
		HandleDebuffs(DeltaTime);
	}

	if (Role == ROLE_Authority)
	{
		UpdateSprint();
	}

	super(UTPawn).Tick( DeltaTime );

	// only if we're on fire
	if (Role == ROLE_Authority && bIsBurning && WorldInfo.TimeSeconds - LastDOTTime >= DOTTimeInterval)
	{
		ReplicatedHitInfo.DamageString = "L";
		TakeDamage(burnDamage, LastBurnHit, Vect(0,0,0),vect(0,0,0), class'AOCDmgType_Burn', , SetOnFireBy);
		LastDOTTime = WorldInfo.TimeSeconds;

		if (Health <= 0)
		{
			// Notify attack attack he got a kill for achievement :)
			AOCPlayerController(SetOnFireBy).NotifyFireStarterProgress();
		}
	}

	// check on server what object is in front of us (within a certain distance) to check for usable items and update the player controller
	if (Role == ROLE_Authority && !bIsBot && Controller != none && AOCPlayerController(Controller) != none)
	{
		// from the eyes, go out some 100? units to see if there's any object within reach that we can use
		ActorEyes = GetPawnViewLocation();
		ActorRotVector = Normal(Vector(GetViewRotation()));
		TraceEndpoint = ActorEyes + 200.0f * ActorRotVector;
		TraceObject = Trace(HitLocation, HitNormal, TraceEndpoint, ActorEyes, true,, myHitInfo);
		//`log("TRACE OBJECT"@TraceObject);
		// log object - whether it's none or not will be checked later
		if (TraceObject != none && IAOCUsable(TraceObject) != none && IAOCUsable(TraceObject).CanBeUsed(PawnFamily.default.FamilyFaction, self))
		{
			AOCPlayerController(Controller).ObjectCanBeUsed.Object = IAOCUsable(TraceObject);
			AOCPlayerController(Controller).ObjectCanBeUsed.HitInfo = myHitInfo;
		}
		else
			AOCPlayerController(Controller).ObjectCanBeUsed.Object = none;
	}

	if (Role == ROLE_Authority && !bIsBot)
	{
		if (!bPlayHeartbeat && Health < HealthMax * 0.20f && Health > 0.0f)
		{
			PlayHeartbeat(true);
			bPlayHeartbeat = true;
			AOCPlayerController(Controller).ToggleDyingSoundEffect(true);

		}
		else if (bPlayHeartbeat && Health >= HealthMax * 0.20f)
		{
			PlayHeartbeat(false);
			bPlayHeartbeat = false;
			AOCPlayerController(Controller).ToggleDyingSoundEffect(false);
		}
	}

	if (IsLocallyControlled() && !bIsBot)
	{
		if (Health < HealthMax * 0.40f && Health > 0.0f)
		{
			ToggleInjurePE(true);
		}
		else if (Health >= HealthMax * 0.40f)
		{
			ToggleInjurePE(false);
		}
	}

	if ( Role < ROLE_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		if (PlayerReplicationInfo != none)
		{
			// Blood Skin
			fTargetBloodSkinVar = 1.0f - float(AOCPRI(PlayerReplicationInfo).CurrentHealth) / HealthMax;
			fBloodSkinVar = FClamp(FInterpTo(fBloodSkinVar, fTargetBloodSkinVar, 1.0f, 0.03f), 0.0f, 1.0f);
			HandleBloodSkin();
		}
	}

	PreviousSocketLoc = RealStartLoc;
	PreviousVelocitySpeed = VSize(Velocity);

	rPreviousRotation = Rotation;
	bPreviousRotSet = true;

	// determine if we're moving or not by comparing location
	if (PawnState == ESTATE_PUSH && !bIsBot)
	{
		if (Role < ROLE_Authority || WorldInfo.NetMode == NM_STANDALONE)
		{
			bPawnIsMoving = vPreviousLocation != Location;
			if (WorldInfo.NetMode != NM_STANDALONE)
				UpdatePushableVars(bPawnIsMoving, Location);
		}
	}

	// If we're falling start a timer to check how long we fall
	if (Physics == PHYS_Falling && Worldinfo.NetMode != NM_DedicatedServer)
	{
		if (!bHasShouted && !IsTimerActive('FallingDeathTimerActivation'))
		{
			SetTimer(0.5f, false, 'FallingDeathTimerActivation');
		}
	}
	else if(bHasShouted)
	{
		PlayAOCFallingDeathShoutSound(false);	
	}

	// Drafting
	if (Role == ROLE_Authority && WorldInfo.TimeSeconds - LastCheckSprintTime > 1.f)
	{
		if(StateVariables.bIsSprinting && !IsTimerActive('StartDrafting'))
		{
			if (IsChasingEnemy())
			{
				StartDrafting();//SetTimer(1.0f, true, 'StartDrafting');
			}

			LastCheckSprintTime = WorldInfo.TimeSeconds;
		}
	}
	
	vPreviousLocation = Location;

	if (AOCWeaponAttachment(CurrentWeaponAttachment) != none && Role == ROLE_Authority)
		AOCWeaponAttachment(CurrentWeaponAttachment).PawnState = PawnState;
		
	/* Projectile spread modifier */
	if (Role < ROLE_Authority || WorldInfo.NetMode == NM_Standalone)
	{
		if (AOCWeapon_Sling(Weapon) != none && Weapon.IsInState('Hold'))
		{
			DesiredSpread = PawnFamily.Default.fCrouchingSpread + ( PawnFamily.Default.fSprintingSpread - PawnFamily.Default.fCrouchingSpread) * 
				(1.f - (WorldInfo.TimeSeconds - AOCWeapon_Sling(Weapon).StartChargeTime) / AOCWeapon_Sling(Weapon).TimeToFullyCharge);
		}
		else if(StateVariables.bIsSprinting)
		{
			DesiredSpread = PawnFamily.Default.fSprintingSpread;
		}
		else if(Physics == PHYS_Falling)
		{
			DesiredSpread = PawnFamily.Default.fFallingSpread;
		}
		else if(bIsCrouching)
		{
			DesiredSpread = PawnFamily.Default.fCrouchingSpread;
		}
		else
		{
			DesiredSpread = PawnFamily.Default.fWalkingSpread * (VSize(Velocity)/BaseSpeed) + PawnFamily.Default.fStandingSpread * FMax(0.f, 1.f - (VSize(Velocity)/BaseSpeed));
		}
	 
		if(DesiredSpread > fCurrentSpreadModifier)
		{
			fCurrentSpreadModifier = FMin(DesiredSpread, fCurrentSpreadModifier + PawnFamily.Default.fSpreadPenaltyPerSecond * DeltaTime);
		}
		else if(DesiredSpread < fCurrentSpreadModifier)
		{
			fCurrentSpreadModifier = FMax(DesiredSpread, fCurrentSpreadModifier - PawnFamily.Default.fSpreadRecoveryPerSecond * DeltaTime);
		}
		// Notify HUD of Spread modifier change
		if (Controller != none && AOCPlayerController(Controller) != none && WorldInfo.NetMode != NM_DedicatedServer)
			AOCBaseHUD(AOCPlayerController(Controller).myHUD).UpdateSpreadRangeCrosshair(fCurrentSpreadModifier, MinProjSpread, MaxProjSpread);
	}
	if (WorldInfo.NetMode != NM_DedicatedServer && bInWater)
	{
		if (WorldInfo.TimeSeconds - timeSinceLastSplash > 1.12f)
		{
			MoveDir = MovingWhichWay(Value);
			if (!(Value ~= 0.0f))
			{
				GetBoundingCylinder(radius, height);
				class'AOCWaterVolume'.static.spawnSplashEffect(Location, height, MoveDir, Value, GroundSpeed);
				timeSinceLastSplash = WorldInfo.TimeSeconds;
			}  
		}
	}

	// Hide Weapons if we are using a Siege weapon
	if (CurrentWeaponAttachment != none)
		AOCWeaponAttachment(CurrentWeaponAttachment).Mesh.SetHidden(PawnState == ESTATE_SIEGEWEAPON);

	// Check Hand Placement
	if ( (Role < ROLE_Authority || WorldInfo.NetMode == NM_Standalone) && LeftArmControl != none && RightArmControl != none)
		ChangeHandPlacements(HandPlacementInfo.bUseHandPlacement, HandPlacementInfo.LeftHandVector, HandPlacementInfo.RightHandVector);

	if (bDelayDeathOneTick)
		ActualPlayDying(DeathDamageType, DeathHitLoc, DeathbForceUseAnimation, DeathInfo);
	if (bDelayForceDropOneTick)
		ForceStopDeathAnim();

	if(fDesiredOilSkinVar > 0.f || fDesiredBurnSkinVar > 0.f)
	{
		if (PlayerReplicationInfo != none)
		{
			LastHealth = AOCPRI(PlayerReplicationInfo).CurrentHealth;
		}
		else
			LastHealth = Health;

		if(LastHealth > fLastHealth)
		{
			fDesiredOilSkinVar = FClamp(fDesiredOilSkinVar - (LastHealth- fLastHealth) * fOilRecoverPerHealth, 0.0f, FClamp(1.0f - (LastHealth / 100.0f), 0.0f, 1.0f));
			fDesiredBurnSkinVar = FClamp(fDesiredOilSkinVar - (LastHealth - fLastHealth) * fFireRecoverPerHealth, 0.0f, FClamp(1.0f - (LastHealth / 100.0f), 0.0f, 1.0f));
		}
	}
	
	if(fDesiredOilSkinVar != fOilSkinVar)
	{
		if(fDesiredOilSkinVar > fOilSkinVar)
		{
			fOilSkinVar = FInterpConstantTo(fOilSkinVar, fDesiredOilSkinVar, DeltaTime, health>0 ? fBurnRate : fBurnRate * 2.0);
		}
		else
		{
			fOilSkinVar = FInterpConstantTo(fOilSkinVar, fDesiredOilSkinVar, DeltaTime, fBurnRecoverRate);
		}

		foreach MICArray(MIC)
		{
			MIC.SetScalarParameterValue('bOil', fOilSkinVar);
		}
	}
	if(fDesiredBurnSkinVar != fBurnSkinVar)
	{
		if(fDesiredBurnSkinVar > fBurnSkinVar)
		{
			fBurnSkinVar = FInterpConstantTo(fBurnSkinVar, fDesiredBurnSkinVar, DeltaTime, health>0 ? fBurnRate : fBurnRate * 2.0);
		}
		else
		{
			fBurnSkinVar = FInterpConstantTo(fBurnSkinVar, fDesiredBurnSkinVar, DeltaTime, fBurnRecoverRate);
		}
		
		foreach MICArray(MIC)
		{
			MIC.SetScalarParameterValue('bBurned', fBurnSkinVar);
		}
	}
	
	if (PlayerReplicationInfo != none)
		fLastHealth = AOCPRI(PlayerReplicationInfo).CurrentHealth;
	else
		fLastHealth = Health;

	// TO Specific
	if (AOCTeamObjectivePC(Controller) != none && AOCTeamObjectivePC(Controller).MyAssassinationObjective != none && Health > 0)
	{
		//`log("SET KING HEALTH"@Health);
		AOCTeamObjectivePC(Controller).MyAssassinationObjective.LastKingHealth = Health;
	}


	/*
	if (WorldInfo.NetMode == NM_Client)
	{
		LocalPC = AOCPlayerController(GetALocalPlayerController());
		if (LocalPC != none)
		{
			// Make sure PC actually wants the pawn to show
			if (LocalPC.CheckRequestShowAllSteamFriends())
			{
				if (LocalPC.CurrentFamilyInfo.default.FamilyFaction == PawnFamily.default.FamilyFaction 
					&& LocalPC.SteamFriendPRI.Find(PlayerReplicationInfo) != INDEX_NONE && !bSteamFriendMarkerHandled)
				{
					// Add our selves to the PC's HUD
					LocalPC.AddFriendMarkerToHUD(self);

					bSteamFriendMarkerHandled = true;
				}
			}
			else if (!LocalPC.CheckRequestShowAllSteamFriends())
			{
				// At this point we want to set handled to false so that we'll be added again once player toggles the markers on
				bSteamFriendMarkerHandled = false;
			}
		}
	}*/

	//TickPointsTimers(DeltaTime);
	
	//Anti ballista crazy-arms bug
	if(Base == none || AOCSW_Base(Base) == none)
	{
		HandPlacementInfo.bUseHandPlacement = false;
	};

	if (PawnState == ESTATE_DODGE && Physics == PHYS_Falling)
	{
		Velocity.X /= 1.1f;
		Velocity.Y /= 1.1f;
	}
}

//remove dodge cooldown for now...
simulated function DisableDodge()
{
	// prevent user from dodging for 0.5 sec (not) 
	StateVariables.bDodgeDebuffActive = true;
	SetTimer(0.2f, false, nameof(EnableDodge));
}


DefaultProperties
{
	InventoryManagerClass=class'YOInventoryManager'

	//No more bubble
	Begin Object Name=OuterCylinder
		CollisionRadius=+0043.000000
		CollisionHeight=+0065.000000
		BlockNonZeroExtent=false
		BlockZeroExtent=false
		BlockActors=false
		CollideActors=false
		bDrawBoundingBox=false
		BlockNonTeamActors=false
	End Object
	Components.Add(OuterCylinder)

	AllClasses.Empty;

	AllClasses(ECLASS_Archer)=class'YOFamilyInfo_Agatha_Archer'
	AllClasses(ECLASS_ManAtArms)=class'YOFamilyInfo_Agatha_ManAtArms'
	AllClasses(ECLASS_Vanguard)=class'YOFamilyInfo_Agatha_Vanguard'
	AllClasses(ECLASS_Knight)=class'YOFamilyInfo_Agatha_Knight'
	AllClasses(ECLASS_SiegeEngineer)=class'YOFamilyInfo_Agatha_Archer' //changed from class'CPMFamilyInfo_Agatha_SiegeEngineer' to avoid warning spam
	// test comment
	// same order as above for Masons, but we cant do maths in the thingys.
	AllClasses(5)=class'YOFamilyInfo_Mason_Archer'
	AllClasses(6)=class'YOFamilyInfo_Mason_ManAtArms'
	AllClasses(7)=class'YOFamilyInfo_Mason_Vanguard'
	AllClasses(8)=class'YOFamilyInfo_Mason_Knight'
	AllClasses(9)=class'YOFamilyInfo_Mason_Archer'
}
