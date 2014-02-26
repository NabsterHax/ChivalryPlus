class CPMPawn extends AOCPawn;

// Fix for screwed up FPSpectate OwnerMesh - May cause performance issues? //
/*simulated function SetCharacterAppearanceFromInfo(class<AOCCharacterInfo> Info)
{
	local int i;
	local AnimSet TempSet;
	local MaterialInstanceConstant MIC;

	//`log("SetCharacterAppearanceFromInfo"@Info.Name@(Info == PawnCharacter));

	if(Info == PawnCharacter)
	{
		//Nothing to do, this has already been performed
		return;
	}

		PawnCharacter = Info;

		// AnimSets
		Mesh.AnimSets = Info.default.AnimSets;

		// 3P Mesh and materials
		//`log(Info.default.CharacterMesh@PawnCharacter.default.HeadMaterial@PawnCharacter.default.BodyMaterial);
		SetCharacterMeshInfo(Info.default.CharacterMesh, PawnCharacter.default.HeadMaterial, PawnCharacter.default.BodyMaterial);

		// First person arms mesh/material (if necessary)
		// Brady TODO: Do we need this?
		//if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled())
		//{
			//TeamMaterialArms = Info.static.GetFirstPersonArmsMaterial(TeamNum);
			//SetFirstPersonArmsInfo(Info.static.GetFirstPersonArms(), TeamMaterialArms);
		//}

		// PhysicsAsset
		// Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
		Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE;
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}

		//Overlay mesh for effects
		if (OverlayMesh != None)
		{
			OverlayMesh.SetSkeletalMesh(Info.default.CharacterMesh);
		}

		// Bone names
		LeftFootBone = Info.default.LeftFootBone;
		RightFootBone = Info.default.RightFootBone;
		TakeHitPhysicsFixedBones = Info.default.TakeHitPhysicsFixedBones;

		// sounds
		SoundGroupClass = Info.default.SoundGroupClass;

		DefaultMeshScale = Info.Default.DefaultMeshScale;
		Mesh.SetScale(DefaultMeshScale);
		BaseTranslationOffset = PawnCharacter.Default.BaseTranslationOffset;
		CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;

		if(Info.default.OverrideMeshAnimTree != none)
		{
			Mesh.SetAnimTreeTemplate(Info.default.OverrideMeshAnimTree);
		}
		if(Info.default.OverrideOwnerMeshAnimTree != none)
		{
			OwnerMesh.SetAnimTreeTemplate(Info.default.OverrideOwnerMeshAnimTree);
		}

		// Add Extra Third-Person Anim Sets to Regular Mesh
		foreach Info.default.ThirdPersonAnimSets(TempSet)
			Mesh.AnimSets.AddItem(TempSet);

		// Setup AnimSets for the Owner mesh
		OwnerMesh.AnimSets = Info.default.AnimSets;
		foreach Info.default.FirstPersonAnimSets(TempSet)
			OwnerMesh.AnimSets.AddItem(TempSet);

		//if( AOCPlayerController(Controller) != none && (IsLocallyControlled() || bIsBeingFPObserved) )
		//{
			//`log("Owner:"@Info.default.OwnerMesh);
			OwnerMesh.SetSkeletalMesh( Info.Default.OwnerMesh );
			

	PawnDecapMesh = PawnCharacter.default.DecapMesh;
	DecapMIC[0] = PawnCharacter.default.HeadMaterial;
	DecapMIC[1] = PawnCharacter.default.BodyMaterial;

	// initialize bone hierarchy here as well
	PawnBoneHierarchy = new class'AOCBoneHierarchy';
	PawnBoneHierarchy.InitializeHierarchy(PawnCharacter.default.BoneHierarchy);

	// initialize hit mask here
	// create texture for hit mask
	HitMaskTexture = class'TextureRenderTarget2D'.static.Create(256, 256, PF_G8, MakeLinearColor(0, 0, 0, 1));

	if ( HitMaskTexture!=none )
	{
		// Update HitMaskComponent with this texture
        HitMaskComponent.SetCaptureTargetTexture( HitMaskTexture );
	}

	// get first parameter
    MIC = Mesh.CreateAndSetMaterialInstanceConstant(0); // material you'd like to replace
    if ( MIC != none)
    {
        // Set new texture as FilterMask parameter
		if (HitMaskTexture != none)
			MIC.SetTextureParameterValue('FilterMask', HitMaskTexture); // use this texture to be used by your material
		MIC.SetScalarParameterValue('Decal', 1.0f);
		MIC.SetScalarParameterValue('BloodSkin', 0.0f);
		MICArray.AddItem(MIC);
    }

	MIC = OwnerMesh.CreateAndSetMaterialInstanceConstant(0);
	if(MIC != none)
	{
		MICArray.AddItem(MIC);
	}
	MIC = OwnerMesh.CreateAndSetMaterialInstanceConstant(1);
	if(MIC != none)
	{
		MICArray.AddItem(MIC);
	}
	
	Mesh.AttachComponentToSocket(ParryComponent, CameraSocket);
	ParryComponent.SetMaterial(0, Material'CHV_stoneshill_lightfx.Materials.Wall.Invisible');

	FootStepParticle[0] = new class'UTParticleSystemComponent';
	Mesh.AttachComponent(FootStepParticle[0], 'b_l_toe' );
	FootStepParticle[1] = new class'UTParticleSystemComponent';
	Mesh.AttachComponent(FootStepParticle[1], 'b_r_toe' );

	BlendPawnSpeedNode.Constraints[0] = BaseSpeed * SprintModifier - 5.0f;
	BlendPawnSpeedNode.Constraints[1] = BaseSpeed * SprintModifier;

	OwnerBlendPawnSpeedNode.Constraints[0] = BaseSpeed * SprintModifier - 5.0f;
	OwnerBlendPawnSpeedNode.Constraints[1] = BaseSpeed * SprintModifier;
}*/

simulated function SetCharacterAppearanceFromInfo(class<AOCCharacterInfo> Info)
{
	local int i;
	local AnimSet TempSet;
	local MaterialInstanceConstant MIC;

	//`log("SetCharacterAppearanceFromInfo"@Info.Name@(Info == PawnCharacter));

	if(Info == PawnCharacter)
	{
		//Nothing to do, this has already been performed
		return;
	}

	if (Info != PawnCharacter)
	{
		PawnCharacter = Info;

		// AnimSets
		Mesh.AnimSets = Info.default.AnimSets;

		// 3P Mesh and materials
		//`log(Info.default.CharacterMesh@PawnCharacter.default.HeadMaterial@PawnCharacter.default.BodyMaterial);
		SetCharacterMeshInfo(Info.default.CharacterMesh, PawnCharacter.default.HeadMaterial, PawnCharacter.default.BodyMaterial);

		// First person arms mesh/material (if necessary)
		// Brady TODO: Do we need this?
		//if (WorldInfo.NetMode != NM_DedicatedServer && IsHumanControlled() && IsLocallyControlled())
		//{
			//TeamMaterialArms = Info.static.GetFirstPersonArmsMaterial(TeamNum);
			//SetFirstPersonArmsInfo(Info.static.GetFirstPersonArms(), TeamMaterialArms);
		//}

		// PhysicsAsset
		// Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
		Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE;
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}

		//Overlay mesh for effects
		if (OverlayMesh != None)
		{
			OverlayMesh.SetSkeletalMesh(Info.default.CharacterMesh);
		}

		// Bone names
		LeftFootBone = Info.default.LeftFootBone;
		RightFootBone = Info.default.RightFootBone;
		TakeHitPhysicsFixedBones = Info.default.TakeHitPhysicsFixedBones;

		// sounds
		//SoundGroupClass = class<UTPawnSoundGroup>(class'AOCGameEngine'.static.TBSLoadSeekfreeClass(Info.default.SoundGroupClassName));
		//class'AOCGameEngine'.static.SoundGroupClasses[ECLASS_Knight] = 
		SoundGroupClass = class<UTPawnSoundGroup>(FindObject(Info.default.SoundGroupClassName,class'Class'));
		//SoundGroupClass = class<UTPawnSoundGroup>(DynamicLoadObject(Info.default.SoundGroupClassName,class'Class'));

		DefaultMeshScale = Info.Default.DefaultMeshScale;
		Mesh.SetScale(DefaultMeshScale);
		BaseTranslationOffset = PawnCharacter.Default.BaseTranslationOffset;
		CrouchTranslationOffset = BaseTranslationOffset + CylinderComponent.Default.CollisionHeight - CrouchHeight;

		if(Info.default.OverrideMeshAnimTree != none)
		{
			Mesh.SetAnimTreeTemplate(Info.default.OverrideMeshAnimTree);
		}
		if(Info.default.OverrideOwnerMeshAnimTree != none)
		{
			OwnerMesh.SetAnimTreeTemplate(Info.default.OverrideOwnerMeshAnimTree);
		}

		// Add Extra Third-Person Anim Sets to Regular Mesh
		foreach Info.default.ThirdPersonAnimSets(TempSet)
			Mesh.AnimSets.AddItem(TempSet);

		// Setup AnimSets for the Owner mesh
		OwnerMesh.AnimSets = Info.default.AnimSets;
		foreach Info.default.FirstPersonAnimSets(TempSet)
			OwnerMesh.AnimSets.AddItem(TempSet);

		//if( AOCPlayerController(Controller) != none && (IsLocallyControlled() || bIsBeingFPObserved) )
		//{
		//	`log("Owner:"@Info.default.OwnerMesh);
			OwnerMesh.SetSkeletalMesh( Info.Default.OwnerMesh );
			//OwnerMesh.SetParentAnimComponent( Mesh );
		//}

	}

	PawnDecapMesh = PawnCharacter.default.DecapMesh;
	DecapMIC[0] = PawnCharacter.default.HeadMaterial;
	DecapMIC[1] = PawnCharacter.default.BodyMaterial;

	// initialize bone hierarchy here as well
	PawnBoneHierarchy = new class'AOCBoneHierarchy';
	PawnBoneHierarchy.InitializeHierarchy(PawnCharacter.default.BoneHierarchy);

	// initialize hit mask here
	// create texture for hit mask
	HitMaskTexture = class'TextureRenderTarget2D'.static.Create(256, 256, PF_G8, MakeLinearColor(0, 0, 0, 1));

	if ( HitMaskTexture!=none )
	{
		// Update HitMaskComponent with this texture
        HitMaskComponent.SetCaptureTargetTexture( HitMaskTexture );
	}

	// get first parameter
    MIC = Mesh.CreateAndSetMaterialInstanceConstant(0); // material you'd like to replace
    if ( MIC != none)
    {
        // Set new texture as FilterMask parameter
		if (HitMaskTexture != none)
			MIC.SetTextureParameterValue('FilterMask', HitMaskTexture); // use this texture to be used by your material
		MIC.SetScalarParameterValue('Decal', 1.0f);
		MIC.SetScalarParameterValue('BloodSkin', 0.0f);
		MICArray.AddItem(MIC);
    }

	MIC = OwnerMesh.CreateAndSetMaterialInstanceConstant(0);
	if(MIC != none)
	{
		MICArray.AddItem(MIC);
	}
	MIC = OwnerMesh.CreateAndSetMaterialInstanceConstant(1);
	if(MIC != none)
	{
		MICArray.AddItem(MIC);
	}
	
	Mesh.AttachComponentToSocket(ParryComponent, CameraSocket);
	ParryComponent.SetMaterial(0, Material'CHV_stoneshill_lightfx.Materials.Wall.Invisible');

	FootStepParticle[0] = new class'UTParticleSystemComponent';
	Mesh.AttachComponent(FootStepParticle[0], 'b_l_toe' );
	FootStepParticle[1] = new class'UTParticleSystemComponent';
	Mesh.AttachComponent(FootStepParticle[1], 'b_r_toe' );

	BlendPawnSpeedNode.Constraints[0] = BaseSpeed * SprintModifier - 5.0f;
	BlendPawnSpeedNode.Constraints[1] = BaseSpeed * SprintModifier;

	OwnerBlendPawnSpeedNode.Constraints[0] = BaseSpeed * SprintModifier - 5.0f;
	OwnerBlendPawnSpeedNode.Constraints[1] = BaseSpeed * SprintModifier;

	if(AOCAIController_NPC_Preview(Controller) != none)
	{
		Mesh.ForcedLodModel = 1;
	}
}

//OwnerMesh fix and shield handling // 
simulated function BecomeFirstPersonObserved(PlayerController PC)
{
	BecomeViewTarget(PC);
	
	bIsBeingFPObserved = true;
	CurrentObserver = PC;
	//DisplayDefaultCustomizationInfoOnPawn();
	//AOCPlayerController(GetALocalPlayerController()).ReceiveChatMessage("","Owner:"@PawnCharacter.default.OwnerMesh, EFAC_ALL, true);
	OwnerMesh.SetSkeletalMesh( PawnCharacter.default.OwnerMesh );
	AOCWeaponAttachment(CurrentWeaponAttachment).AttachTo(self);
	HandleShieldAttach();
	DisplayCustomizationInfoOnPawn();
}

simulated event EndViewTarget(PlayerController PC)
{
	AOCPlayerController(PC).SetBehindView(true);
	bIsBeingFPObserved = false;
	CurrentObserver = none;
}

// Fix for FPSpectate animations //
simulated function ResetBlends(optional float BlendOutTime = 0.3f, optional bool bReplicated = true)
{
	local int Index;

	if (bReplicated && WorldInfo.NetMode != NM_DedicatedServer && (IsLocallyControlled() && !bIsBot))
		return;

	//`log("RESET BLENDS BLEND OUT TIME:"@BlendOutTime);
	//`log("DO RESET BLENDS"@GetScriptTrace());
	// Deactivate every node0
	for(Index=0; Index < BlendAnimationListNode.Children.Length-1; Index++)
	{
		if (Index == EABLI_SOURCE)
			continue;
		AnimNodeBlend(BlendAnimationListNode.Children[Index].Anim).SetBlendTarget(0.0f, BlendOutTime);
		if (Index == EABLI_FULL)
			AnimNodeBlendPerBone(BlendAnimationListNode.Children[Index].Anim).BranchStartBoneName[0] = 'b_Root';
	}
	FullBodyAnimSlot.StopCustomAnim(0.0f);
	LowerHalfAnimSlot.StopCustomAnim(0.0f);
	TopHalfAnimSlot.StopCustomAnim(0.0f);
	//FullBodySlotDodge.StopCustomAnim(0.1f);
	

	//BlendAnimationListNode.SetActiveChild(EABLI_SOURCE, BlendOutTime);
	if (IsLocallyControlled() || bIsBeingFPObserved)
	{
		for(Index=0; Index < OwnerBlendAnimationListNode.Children.Length-1; Index++)
		{
			if (Index == EABLI_SOURCE || Index == EABLI_FULLROOT || Index == EABLI_FULLROOT_AB)
				continue;
			AnimNodeBlend(OwnerBlendAnimationListNode.Children[Index].Anim).SetBlendTarget(0.0f, BlendOutTime);
		}
		//OwnerBlendAnimationListNode.SetActiveChild(EABLI_SOURCE, BlendOutTime);
		OwnerFullBodySlot.StopCustomAnim(0.1f);
		//OwnerFullBodySlotDodge.StopCustomAnim(0.1f);
	}

	// Reset Animation on Weapon Attachment
	AOCWeaponAttachment(CurrentWeaponAttachment).ResetAnimation();
}

// For hiding customization //
simulated function DisplayCustomizationInfoOnPawn()
{
	local AOCPlayerController PC;
	PC = AOCPlayerController(WorldInfo.GetALocalPlayerController());
	if(ICPMReadyUpPC(PC) != None 
		&& ICPMPlayerController(PC).IsHidingCustomization())
		DisplayDefaultCustomizationInfoOnPawn();
	else
		super.DisplayCustomizationInfoOnPawn();
}

//For Bomb game-mode
reliable server function RequestBombHit(CPMBomb Bomb)
{
	if (Bomb.ReasonableTouch(self))
		Bomb.UserTouched(self);
}

DefaultProperties
{	
	CustomizationClass=class'CPMCustomization'
}
