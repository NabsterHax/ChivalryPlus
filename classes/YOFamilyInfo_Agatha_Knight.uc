class YOFamilyInfo_Agatha_Knight extends AOCFamilyInfo_Agatha_Knight;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_Knight_properties.uci)

	FamilyID="Knight"
	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA

	SecondaryWeapons(1)=class'YOWeapon_Heater_Agatha'
	SecondaryWeapons(2)=class'YOWeapon_TowerShield_Agatha'
	
	NewTertiaryWeapons(1)=(CWeapon=class'YOWeapon_TowerShield_Agatha')
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Agatha')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Kite_Agatha')

	NewPrimaryWeapons(9)=(CForceTertiary=(class'YOWeapon_Buckler_Agatha'),CWeapon=class'YOWeapon_Flail',CheckLimitExpGroup=EEXP_FLAIL,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_FlailUse)
	NewPrimaryWeapons(10)=(CForceTertiary=(class'YOWeapon_Buckler_Agatha'),CWeapon=class'YOWeapon_HFlail',CheckLimitExpGroup=EEXP_FLAIL,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_HFlailUse)
}