class YOInventoryManager extends AOCInventoryManager;

simulated function SwitchWeapon(byte NewGroup)
{
	local class<AOCWeapon> DesiredWeapon; 
	local array<UTWeapon> WeaponList;
	local int NewIndex;

	// can't switch weapons when we are attacking
	if (bCanSwitchWeapons && (AOCPawn(Owner).Weapon == None || AOCWeapon(AOCPawn(Owner).Weapon).CanSwitch()))
	{
		if (AOCPawn(Owner).Weapon.IsInState('Reload'))
			AOCRangeWeapon(AOCPawn(Owner).Weapon).ForceOutOfReloadSwitch();

		CurrentWeaponGroup = NewGroup;
		// Get the list of weapons
		NewIndex = NewGroup - 1;

   		GetWeaponList(WeaponList,false,NewGroup);

		// Exit out if no weapons are in this list.
		if (WeaponList.Length<=0)
		{
			//`log("NO WEAPON IN LIST");
			AOCPawn(owner).bSwitchingWeapons = false;
			AOCPawn(Owner).PlaySound(AOCPawn(Owner).GenericCantDoSound, true);
			AOCPawn(Owner).OnActionFailed(EPlayerAction(EACT_WeaponChangedAny + int(NewGroup)));
			return;
		}

		if (NewGroup == 1 && (AOCPawn(Owner).Weapon.Class == AOCPawn(Owner).PrimaryWeapon || AOCPawn(Owner).Weapon.Class == AOCPawn(Owner).AlternatePrimaryWeapon) && AOCPawn(owner).AlternatePrimaryWeapon != class'AOCWeapon_None')
		{ 
			if(AOCWeapon_JavelinMelee(AOCPawn(Owner).Weapon) == none || AOCWeapon_JavelinMelee(AOCPawn(Owner).Weapon).TrySwitch())
			{
				DesiredWeapon = AOCWeapon(AOCPawn(Owner).Weapon).AlternativeMode;
			}
		}
		else if (NewGroup == 1)
			DesiredWeapon = AOCPawn(Owner).PrimaryWeapon;
		else if (NewGroup == 2)
			DesiredWeapon = AOCPawn(Owner).SecondaryWeapon;
		else if (NewGroup == 3)
			DesiredWeapon = AOCPawn(Owner).TertiaryWeapon;
		else if (NewGroup == 4)
			DesiredWeapon = class'YOWeapon_Fists';
		
		//`log("WANT TO CHANGE:"@DesiredWeapon@AOCPawn(Owner).Weapon.Class);
		if (DesiredWeapon == AOCPawn(Owner).Weapon.Class)
		{
			AOCPawn(owner).bSwitchingWeapons = false;
			AOCPawn(Owner).PlaySound(AOCPawn(Owner).GenericCantDoSound, true);
			AOCPawn(Owner).OnActionFailed(EPlayerAction(EACT_WeaponChangedAny + int(NewGroup)));
			return;
		}

		for (NewIndex=0;NewIndex<WeaponList.Length;NewIndex++)
		{
			if (WeaponList[NewIndex].Class == DesiredWeapon 
				&& (  (AOCRangeWeapon(WeaponList[NewIndex]) != none && AOCRangeWeapon(WeaponList[NewIndex]).AmmoCount > 0) 
					  || (AOCMeleeWeapon(WeaponList[NewIndex]) != none 
					      && (AOCRangeWeapon(AOCMeleeWeapon(WeaponList[NewIndex]).AlternativeModeInstance) == none
					         || AOCRangeWeapon(AOCMeleeWeapon(WeaponList[NewIndex]).AlternativeModeInstance).AmmoCount > 0))))
				break;
		}

		// Check Ammo
		//`log("CHECK AMMO"@AOCRangeWeapon(WeaponList[NewIndex]).AmmoCount);
		if (NewIndex >= WeaponList.Length)
		{
			AOCPawn(owner).bSwitchingWeapons = false;
			AOCPawn(Owner).PlaySound(AOCPawn(Owner).GenericCantDoSound, true);
			AOCPawn(Owner).OnActionFailed(EPlayerAction(EACT_WeaponChangedAny + int(NewGroup)));
			return;
		}

		//if (AOCPawn(Owner).StateVariables.bShieldEquipped && AOCWeapon_JavelinThrow(AOCPawn(Owner).Weapon) == none )
		//	AOCPawn(Owner).EquipShield(false);
		if (AOCPawn(Owner).Weapon.Class != class'AOCWeapon_Torch')
			AOCPawn(Owner).PreviousWeapon = class<AOCWeapon>(AOCPawn(Owner).Weapon.Class);

		//`log("SET WEAPON:"@WeaponList[NewIndex]@DesiredWeapon);
		SetCurrentWeapon(WeaponList[NewIndex]);
		AOCPawn(Owner).OnActionSucceeded(EPlayerAction(EACT_WeaponChangedAny + int(NewGroup)));
	}
	else 
	{
		//`log("CANT SWITCH"@AOCPawn(Owner).Weapon.GetStateName());
		AOCPawn(Owner).OnActionFailed(EPlayerAction(EACT_WeaponChangedAny + int(NewGroup)));
		AOCPawn(Owner).PlaySound(AOCPawn(Owner).default.GenericCantDoSound, true);
	}
}

DefaultProperties
{
}
