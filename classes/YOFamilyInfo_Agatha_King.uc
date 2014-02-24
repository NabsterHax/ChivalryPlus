class YOFamilyInfo_Agatha_King extends AOCFamilyInfo_Agatha_King;

DefaultProperties
{
	`define InKingClass
		`include(CPM/include/YOFamilyInfo_Knight_properties.uci)
	`undefine(InKingClass)

	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA

	SecondaryWeapons(1)=class'YOWeapon_Heater_Agatha'
	SecondaryWeapons(2)=class'YOWeapon_TowerShield_Agatha'
	
	NewTertiaryWeapons(1)=(CWeapon=class'YOWeapon_TowerShield_Agatha')
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Agatha')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Kite_Agatha')

	NewPrimaryWeapons(9)=(CForceTertiary=(class'YOWeapon_Buckler_Agatha'))
	NewPrimaryWeapons(10)=(CForceTertiary=(class'YOWeapon_Buckler_Agatha'))

	FamilyID="King"
	Health=500
	
	ProjectileLocationModifiers(EHIT_Head) = 1.0

	KillBonus = 75
	AssistBonus = 15
	ClassReference=ECLASS_King
}
