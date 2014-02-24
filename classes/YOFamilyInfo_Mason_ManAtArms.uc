class YOFamilyInfo_Mason_ManAtArms extends AOCFamilyInfo_Mason_ManAtArms;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_ManAtArms_properties.uci)

	FamilyID="Man-At-Arms"
	Faction="Mason"
	FamilyFaction=EFAC_MASON

	SecondaryWeapons(0)=class'YOWeapon_Buckler_Mason'
	SecondaryWeapons(1)=class'YOWeapon_Heater_Mason'
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Mason')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Heater_Mason')
}