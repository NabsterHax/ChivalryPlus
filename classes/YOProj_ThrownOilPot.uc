class YOProj_ThrownOilPot extends AOCProj_ThrownOilPot;

function checkNearPlayersToBurn()
{
	local AOCPawn P;
	local AOCStaticMeshActor_PaviseShield Pavise;
	local float distFromPawn;

	foreach WorldInfo.AllPawns(class'AOCPawn', P)
	{
	//	`log("CHECK PAWN"@P.IsAliveAndWell()@P.bInfiniteHealth);
		if (P.IsAliveAndWell() && !P.bInfiniteHealth && P.RealityID == RealityID)
		{
			distFromPawn = VSizeSq(Location - P.Location);
			//`log("DIST FROM PAWN"@distFromPawn@fFireRadius@P);
			if (distFromPawn <= fFireRadius && bBurnFirstTick)
			{
				P.SetPawnOnFire(FirePS, OwnerPawn.Controller, OwnerPawn);
			}
			else if (distFromPawn <= fFireRadius && !P.bIsBurning)
			{
				//P.SetPawnOnFire(FirePS, OwnerPawn.Controller, OwnerPawn,, WalkOverBurnTime);
				P.ReplicatedHitInfo.DamageString = "L";
                P.TakeDamage(int(7.0 * 0.20), OwnerPawn.Controller, vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), class'AOCDmgType_Burn',, OwnerPawn);
			}
		}
	}


	// Check for nearby pavise shields
	foreach WorldInfo.AllActors(class'AOCStaticMeshActor_PaviseShield', Pavise)
	{
		if (Pavise.Health > 0)
		{
			Pavise.AOCTakeDamage(9999, Pavise.Location, Vect(0.f, 0.f, 0.f), none, class'AOCDmgType_Burn');
		}
	}

	bBurnFirstTick = false;
}

DefaultProperties
{
}
