class YOFamilyInfo_Agatha_Vanguard extends AOCFamilyInfo_Agatha_Vanguard;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_Vanguard_properties.uci)

	FamilyID="Vanguard"
	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA

	SecondaryWeapons(0)=class'YOWeapon_Buckler_Agatha'
	SecondaryWeapons(1)=class'YOWeapon_Heater_Agatha'
}
