class YODodge extends AOCDodge;

// Attacks in first half of dodge fix //
simulated function StartDodgeSM(byte direction, byte WeaponId)
{
	local AnimationInfo Inf;

	CurrentWeaponId = WeaponId;

	// Create Animation Info and pass to Pawn
	// Root Motion will be handled by the animation system.
	DodgeDir = direction;
	Inf = OwnerPawn.CreateAnimationInfo(name(AllDirAnimations[DodgeDir].DodgeAnims[0]), true, true, false,,true);

	// Replace REPL with proper name
	Inf.AnimationName = name(Repl(string(Inf.AnimationName), "REPL", GetWeaponIdentifier(), true));
	Inf.fBlendOutTime = -1.f;
	Inf.fBlendInTime = 0.0f;
	Inf.bIsDodge = true;
	Inf.bUseRMM = true;

	OwnerPawn.ResetRMM();
	if (OwnerPawn.Weapon.IsInState('Flinch'))
	{
		OwnerPawn.Weapon.GotoState('Active');
	}

	OwnerPawn.ChangePawnState(ESTATE_DODGE); // Pawn State needs to be ESTATE_DODGE for the AnimTree to pickup the 'Down' state while in PHYS_Falling.
	OwnerPawn.HandlePawnAnim(false, Inf);

	OwnerPawn.StateVariables.bCanJump = false;
	OwnerPawn.StateVariables.bCanParry = false;

	// Stamina
	OwnerPawn.ConsumeStamina(OwnerPawn.PawnFamily.default.iDodgeCost);

	// Play dodge sound
	class<AOCPawnSoundGroup>(OwnerPawn.SoundGroupClass).Static.PlayAOCDodgeSound(OwnerPawn, OwnerPawn.AOCGetMaterialBelowFeet());

	// Once Animation Ends we want to set state to Falling
	bNotifyOnAnimEnd = true;

	bPlayStop = false;

	// Queue up attacks during the first half of dodge
	//AttackQueue = Attack_Null;
	//bQueueDodgeAttack = true;
	//OwnerPawn.SetTimer(fAnimationLength * 0.5f, false, 'EndDodgeQueue');
}

DefaultProperties
{
}
