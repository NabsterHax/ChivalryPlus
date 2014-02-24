class YOFFADuelPawn extends YOPawn;

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local AOCPRI PRI;
	local int i;
	local AOCAmmoDrop Drop;
	local EAOCFaction KillerTeam, KilledTeam;
	//`log("PAWN JUST DIED BY"@Killer);
	if (AOCPlayerController(Controller) != none  && AOCPlayerController(Controller).bJustSuicided && LastPawnToHurtYou != none)
	{
		AOCPlayerController(Controller).bJustSuicided = false;
		Killer = LastPawnToHurtYou;
	}
	else if (AOCPlayerController(Controller) != none  && AOCPlayerController(Controller).bJustSuicided)
	{
		AOCPlayerController(Controller).bJustSuicided = false;
		Killer = none; // make sure noone gets points for dis.
	}
	else if (Killer == none && LastPawnToHurtYou != none)
	{
		Killer = LastPawnToHurtYou;
	}

	if (AOCTeamObjectivePC(Controller) != none)
		AOCTeamObjectivePC(Controller).bCanChangeClass = true; // will only have 1 life as king.

	if (AOCPlayerController(Killer) != none)
		KillerTeam = AOCPlayerController(Killer).CurrentFamilyInfo.default.FamilyFaction;
	else if (AOCAIController(Killer) != none)
		KillerTeam = AOCAIController(Killer).myPawnClass.default.FamilyFaction;

	if (AOCPlayerController(Controller) != none)
		KilledTeam = AOCPlayerController(Controller).CurrentFamilyInfo.default.FamilyFaction;
	else if (AOCAIController(Controller) != none)
		KilledTeam = AOCAIController(Controller).myPawnClass.default.FamilyFaction;
 
	// Distribute assists points as necessary
	foreach ContributingDamagers(PRI)
	{
		if (PRI != AOCPRI(PlayerReplicationInfo) && PRI != AOCPRI(Killer.PlayerReplicationInfo))
		{
			// Make sure not on same team or the game is a FFA game
			if (KilledTeam != KillerTeam && AOCFFA(WorldInfo.Game) == none )//AOCGame(WorldInfo.Game).CurrentGametypeNum != AOC_GAMETYPE_FFA)
			{
				PRI.NumAssists += 1;
				PRI.ObjPoints += PawnFamily.default.AssistBonus;
				PRI.Score += 5 + PawnFamily.default.AssistBonus;
				AOCPRI(PlayerReplicationInfo).OwnerController.StatWrapper.IncrementAssistStat();
			}
		}
	}

	// Spawn les ammos
	for (i = 0; i < MAXIMUM_STORED_PROJECTILE_TYPES; i++)
	{
		//`log("Struck by projectile drop"@StruckByProjectiles[i].ProjectileOwner);
		if (StruckByProjectiles[i].ProjectileOwner != none)
		{
			Drop = Spawn(class'AOCAmmoDrop', self,,Location, Rotation);
			Drop.AmmoOwner = StruckByProjectiles[i].ProjectileOwner;
			Drop.AmmoType = StruckByProjectiles[i].ProjectileType;
			Drop.AmmoToGive = StruckByProjectiles[i].ProjectileCount;
			Drop.bReady = true;

			StruckByProjectiles[i].ProjectileOwner = none;
		}
	}

	// Notify remote console
	if (Killer == None || Killer.Pawn == Self)
	{
		AOCGame(WorldInfo.Game).RemoteConsole.GameEvent_Suicide(PlayerReplicationInfo);
	}
	else
	{
		AOCGame(WorldInfo.Game).RemoteConsole.GameEvent_Kill(Killer.PlayerReplicationInfo, PlayerReplicationInfo, AOCWeapon(Killer.Pawn.Weapon));
		//In FFA Duel kills grant you full health
		Killer.Pawn.HealDamage(AOCPawn(Killer.Pawn).HealthMax, Killer, none);
		AOCPawn(Killer.Pawn).RestartHealthRegen();
		AOCPawn(Killer.Pawn).Stamina = AOCPawn(Killer.Pawn).MaxStamina;
		CPMFFADuelPC(Killer).ServerClearForfeitTimer();
		CPMFFADuelPC(Controller).ServerClearForfeitTimer();
	}

	super(UTPawn).Died(Killer, DamageType, HitLocation);

	return true;
}

// Make sure we don't take falling damage! //
simulated function TakeFallingDamage()
{
	local float EffectiveSpeed;
	local float damageAmount;
	local bool landedOnSoftSurface;
	local name surfaceType;
	local UTPlayerController UTPC;

	if (Velocity.Z < -0.5 * MaxFallSpeed)
	{
		// ForceFeedback
		UTPC = UTPlayerController(Controller);
		if(UTPC != None && LocalPlayer(UTPC.Player) != None)
		{
			UTPC.ClientPlayForceFeedbackWaveform(FallingDamageWaveForm);
		}
		
		// Take damage and play Landing sounds
		if ( Role == ROLE_Authority )
		{
			MakeNoise(1.0);
			if (Velocity.Z < -1 * MaxFallSpeed)
			{
				EffectiveSpeed = Velocity.Z;
				surfaceType = GetMaterialBelowFeet();
				landedOnSoftSurface = (TouchingWaterVolume() || surfaceType=='Water' || 
																surfaceType=='ShallowWater' || surfaceType=='Cloth');
				if (landedOnSoftSurface)
				{
					EffectiveSpeed += 100;
				}
				if (EffectiveSpeed < -1 * MaxFallSpeed)
				{
					damageAmount = -100 * (EffectiveSpeed + MaxFallSpeed)/MaxFallSpeed;
					if (!landedOnSoftSurface)
					{
						ReplicatedHitInfo.DamageString = "2";
						ReplicatedHitInfo.HitLocation = Location;
						ReplicatedHitInfo.DamageType = class'AOCDmgType_Generic';
						ReplicatedHitInfo.BoneName = 'b_spine_C';
						//TakeDamage(damageAmount, None, Location, vect(0,0,0), class'AOCDmgType_Generic');
					}
					else
					{
						// Take half damage if landed on soft surface (water/cloth)
						if (damageAmount > 25)
						{
							ReplicatedHitInfo.DamageString = "2";
							ReplicatedHitInfo.HitLocation = Location;
							ReplicatedHitInfo.DamageType = class'AOCDmgType_Generic';
							ReplicatedHitInfo.BoneName = 'b_spine_C';
							//TakeDamage(damageAmount*0.5, None, Location, vect(0,0,0), class'AOCDmgType_Generic');
						}
					}

					if (damageAmount > 80)
					{
						class<AOCPawnSoundGroup>(SoundGroupClass).Static.PlayAOCFallingDamageLandSound(self, FallDmg_Hard);
					}
					else if (damageAmount > 30)
					{
						class<AOCPawnSoundGroup>(SoundGroupClass).Static.PlayAOCFallingDamageLandSound(self, FallDmg_Moderate);
					}
					else
					{
						class<AOCPawnSoundGroup>(SoundGroupClass).Static.PlayAOCFallingDamageLandSound(self, FallDmg_Light);
					}
				}
			}
		}
	}
	else if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
	else if ( Velocity.Z < -0.8 * JumpZ )
		MakeNoise(0.2);
}

// Stop pawn taking damage from source other than his duel opponent //
reliable server function AttackOtherPawn(HitInfo Info, string DamageString, optional bool bCheckParryOnly = false, optional bool bBoxParrySuccess, optional bool bHitShield = false, optional SwingTypeImpactSound LastHit = ESWINGSOUND_Slash, optional bool bQuickKick = false)
{
	if (CPMFFADuelPC(Info.HitActor.Controller) != none) 
		if(CPMFFADuelPawn(Info.HitActor) != CPMFFADuelPC(Controller).DuelOpponent)
			return;
	super.AttackOtherPawn(Info, DamageString, bCheckParryOnly, bBoxParrySuccess, bHitShield, LastHit, bQuickKick);
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo myHitInfo, optional Actor DamageCauser)
{
	if(CPMFFADuelPC(InstigatedBy) != none)
		if(CPMFFADuelPawn(InstigatedBy.Pawn) != CPMFFADuelPC(Controller).DuelOpponent)
			return;

	if(Health - Damage <= 0)
	{
		AOCPlayerController(Controller).ReceiveChatMessage("", AOCPlayerController(InstigatedBy).PlayerReplicationInfo.PlayerName$" has defeated"@AOCPlayerController(Controller).PlayerReplicationInfo.PlayerName$" with"@AOCPRI(AOCPlayerController(InstigatedBy).PlayerReplicationInfo).CurrentHealth$"hp remaining.", EFAC_ALL, true, true, "#648BB1");
		AOCPlayerController(InstigatedBy).ReceiveChatMessage("", AOCPlayerController(InstigatedBy).PlayerReplicationInfo.PlayerName$" has defeated"@AOCPlayerController(Controller).PlayerReplicationInfo.PlayerName$" with"@AOCPRI(AOCPlayerController(InstigatedBy).PlayerReplicationInfo).CurrentHealth$"hp remaining.", EFAC_ALL, true, true, "#648BB1");
	}
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, myHitInfo, DamageCauser);
}

DefaultProperties
{
}
