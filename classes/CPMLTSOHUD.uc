class CPMLTSOHUD extends AOCBaseHUD;

var CPMBomb Bomb;

`include(CPM/include/CPMBaseHUD.uci)

function CreateBomb(CPMBomb TheBomb)
{
	Bomb = TheBomb;
	AddDynamicHUDMarker(Bomb, "Bomb", "");
}

function DisplayMatchTime( int Time, bool Enabled )
{
	//minutes seconds time
	local string MSTime;
	if (!CheckCanUseSB())
		return;

	if (Time < 0)
		Time = 0;

	MSTime = ParseTime(Time);
	HUD.Scoreboard.UpdateTimerText(MSTime);
}

function UpdateDynamicHUDMarkers()
{
	local DynHUDMarkerInfo Inf;
	local int i, ClosestBox;
	local Vector RelLoc, MyLoc;
	local Rotator rot;
	local float ClosestDistance;
	foreach MyDynamicHUDMarkers(Inf, i)
	{
		if (Inf.RelAct != none)
		{
			// Set Marker location
			if (Overlay != none)
			{
				if(Bomb != none && Inf.RelAct == Bomb)
				{
					//AOCPlayerController(PlayerOwner).ReceiveChatMessage("", "Updating Bomb"@Bomb.bEnabled@AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction == Bomb.BombingTeam, EFAC_ALL, true);
					RelLoc = Bomb.GetHUDMarkerLocation() + Vect(0,0,75.f);
					// Make sure we can actually see the object + bomb isn't planted
					if (AOCPlayerController(PlayerOwner).CheckCanSeeObjectAtLocation(RelLoc, Inf.RelAct.fMaxDistanceForHUDShow) && bDrawMarkers
							&& Bomb.bEnabled && AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction == Bomb.BombingTeam)
						Overlay.UpdateHUDMarker(i, Canvas.Project(RelLoc), true, AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction,
							Inf.RelAct.bUseProgressBar, Inf.RelAct.fCurrentProgressValue, Inf.RelAct.fMaxValueProgress);
					else
						Overlay.UpdateHUDMarker(i, Canvas.Project(RelLoc), false, EFAC_NONE);
				}
				else
				{
					RelLoc = Inf.RelAct.Location;
					RelLoc.Z += 100.f;
				
					// Make sure we can actually see the object
					if (AOCPlayerController(PlayerOwner).CheckCanSeeObject(Inf.RelAct, Inf.RelAct.fMaxDistanceForHUDShow) && bDrawMarkers)
						Overlay.UpdateHUDMarker(i, Canvas.Project(RelLoc), true, AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction,
							Inf.RelAct.bUseProgressBar, Inf.RelAct.fCurrentProgressValue, Inf.RelAct.fMaxValueProgress);
					else
						Overlay.UpdateHUDMarker(i, Canvas.Project(RelLoc), false, EFAC_NONE);
				}
			}
		}
	}

	foreach WorldDynamicHUDMarkers(Inf, i)
	{
		//`log("UPDATE WORLD HUD MARKER"@Inf.RelAct@AOCHUDMarker(Inf.RelAct).Enabled@AOCHUDMarker(Inf.RelAct).bUseForSpecificPawn);
		if (Inf.RelAct != none)
		{
			if (Overlay != none)
			{
				RelLoc = Inf.RelAct.Location;
				RelLoc.Z += 25.f;
				// Make sure we can actually see the object
				if (AOCHUDMarker(Inf.RelAct) != none && AOCPlayerController(PlayerOwner).CheckCanSeeObject(Inf.RelAct, Inf.RelAct.fMaxDistanceForHUDShow) && bDrawMarkers && AOCHUDMarker(Inf.RelAct).Enabled)
				{
					if ((AOCHUDMarker(Inf.RelAct).bUseForSpecificPawn && ((AOCPawn(PlayerOwner.Pawn) != none && AOCHUDMarker(Inf.RelAct).CheckPID(AOCPawn(PlayerOwner.Pawn).iUniquePawnID))
						|| (AOCSW_Base(PlayerOwner.Pawn) != none && AOCHUDMarker(Inf.RelAct).CheckPID( AOCPawn(AOCSW_Base(PlayerOwner.Pawn).Driver).iUniquePawnID)))) || !AOCHUDMarker(Inf.RelAct).bUseForSpecificPawn)
					{
						//`log("CHECK HUD MARKER BL"@AOCHUDMarker(Inf.RelAct).bDoNotShowToSpecificPawn@ AOCSW_Base(PlayerOwner.Pawn).DriverID@AOCHUDMarker(Inf.RelAct).BlacklistID[0]);
						if (AOCHUDMarker(Inf.RelAct).bDoNotShowToSpecificPawn && ((AOCPawn(PlayerOwner.Pawn) != none && AOCHUDMarker(Inf.RelAct).CheckInBlacklist(AOCPawn(PlayerOwner.Pawn).iUniquePawnID))
							|| (AOCSW_Base(PlayerOwner.Pawn) != none && AOCHUDMarker(Inf.RelAct).CheckInBlacklist( AOCSW_Base(PlayerOwner.Pawn).DriverID))))
						{
							Overlay.UpdateWorldHUDMarker(i, Canvas.Project(RelLoc), false, EFAC_NONE);
						}
						else
							Overlay.UpdateWorldHUDMarker(i, Canvas.Project(RelLoc), true, AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction,
								Inf.RelAct.bUseProgressBar, Inf.RelAct.fCurrentProgressValue, Inf.RelAct.fMaxValueProgress);
					}
					else
						Overlay.UpdateWorldHUDMarker(i, Canvas.Project(RelLoc), false, EFAC_NONE);
				}
				else if (AOCHUDMarker(Inf.RelAct) == none && AOCPlayerController(PlayerOwner).CheckCanSeeObject(Inf.RelAct, Inf.RelAct.fMaxDistanceForHUDShow) && bDrawMarkers && Inf.RelAct.bInitialHaveHUDMarker)
				{
					Overlay.UpdateWorldHUDMarker(i, Canvas.Project(RelLoc), (!Inf.RelAct.bUseHUDMarkerExtension || (Inf.RelAct.bUseHUDMarkerExtension && Inf.RelAct.bInitialHaveHUDMarker)), AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction,
								Inf.RelAct.bUseProgressBar, Inf.RelAct.fCurrentProgressValue, Inf.RelAct.fMaxValueProgress);
				}
				else
					Overlay.UpdateWorldHUDMarker(i, Canvas.Project(RelLoc), false, EFAC_NONE);
			}
		}
	}

	ClosestBox = 0;
	ClosestDistance = 100000.f;
	if (bIsLowAmmo)
	{
		PlayerOwner.GetPlayerViewPoint(MyLoc, rot);
		foreach AmmoBoxMarkers(Inf, i)
		{
			if (VSize(Inf.RelAct.Location -  MyLoc) < ClosestDistance)
			{
				ClosestDistance = VSize(Inf.RelAct.Location -  MyLoc);
				ClosestBox = i;
			}
		}
	}

	foreach AmmoBoxMarkers(Inf, i)
	{
		if (Inf.RelAct != none && Overlay != none)
		{
			RelLoc = Inf.RelAct.Location;
			RelLoc.Z += 75.f;
			if (AOCPlayerController(PlayerOwner).CheckCanSeeObject(Inf.RelAct, -1.f) && bDrawMarkers && i == ClosestBox)
				Overlay.UpdateAmmoBoxMarkers(i, Canvas.Project(RelLoc), bIsLowAmmo, AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction);
			else
				Overlay.UpdateAmmoBoxMarkers(i, Canvas.Project(RelLoc), false, AOCPlayerController(PlayerOwner).CurrentFamilyInfo.default.FamilyFaction);
		}
	}

	if (Overlay != none)
	{
		Overlay.UpdateAllFriendHUDMarkers(bDrawMarkers);
	}
}

function RequestAttackingTeam()
{
	SetAttackingTeam(CPMLTSOPC(PlayerOwner).AttackingFaction);	
	//CPMLTSOPC(PlayerOwner).ReceiveChatMessage("","Setting attacking team:"@CPMLTSOGRI(WorldInfo.GRI).Bomb.BombingTeam,EFAC_ALL,true);
}

function SetAttackingTeam(EAOCFaction Fac)
{
	if (CharManager.TeamSelection == none)
		return;

	CharManager.TeamSelection.SetAttackingTeam(Fac);
}

DefaultProperties
{
	PawnClass=class'CPMPawn'
}
