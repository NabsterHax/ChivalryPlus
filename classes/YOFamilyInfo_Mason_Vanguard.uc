class YOFamilyInfo_Mason_Vanguard extends AOCFamilyInfo_Mason_Vanguard;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_Vanguard_properties.uci)

	FamilyID="Vanguard"
	Faction="Mason"
	FamilyFaction=EFAC_MASON

	SecondaryWeapons(0)=class'YOWeapon_Buckler_Mason'
	SecondaryWeapons(1)=class'YOWeapon_Heater_Mason'
}