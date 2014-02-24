class YOFamilyInfo_Agatha_ManAtArms extends AOCFamilyInfo_Agatha_ManAtArms;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_ManAtArms_properties.uci)

	FamilyID="Man-At-Arms"
	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA

	SecondaryWeapons(0)=class'YOWeapon_Buckler_Agatha'
	SecondaryWeapons(1)=class'YOWeapon_Heater_Agatha'
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Agatha')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Heater_Agatha')
}
