class YOFamilyInfo_Mason_Knight extends AOCFamilyInfo_Mason_Knight;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_Knight_properties.uci)

	FamilyID="Knight"
	Faction="Mason"
	FamilyFaction=EFAC_Mason

	SecondaryWeapons(1)=class'YOWeapon_Heater_Mason'
	SecondaryWeapons(2)=class'YOWeapon_TowerShield_Mason'

	NewTertiaryWeapons(1)=(CWeapon=class'YOWeapon_TowerShield_Mason')
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Mason')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Kite_Mason')

	NewPrimaryWeapons(9)=(CForceTertiary=(class'YOWeapon_Buckler_Mason'),CWeapon=class'YOWeapon_Flail',CheckLimitExpGroup=EEXP_FLAIL,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_FlailUse)
	NewPrimaryWeapons(10)=(CForceTertiary=(class'YOWeapon_Buckler_Mason'),CWeapon=class'YOWeapon_HFlail',CheckLimitExpGroup=EEXP_FLAIL,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_HFlailUse)
}