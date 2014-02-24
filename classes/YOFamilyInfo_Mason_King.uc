class YOFamilyInfo_Mason_King extends AOCFamilyInfo_Mason_King;

DefaultProperties
{
	`define InKingClass
		`include(CPM/include/YOFamilyInfo_Knight_properties.uci)
	`undefine(InKingClass)

	Faction="Mason"
	FamilyFaction=EFAC_Mason

	SecondaryWeapons(1)=class'YOWeapon_Heater_Mason'
	SecondaryWeapons(2)=class'YOWeapon_TowerShield_Mason'

	NewTertiaryWeapons(1)=(CWeapon=class'YOWeapon_TowerShield_Mason')
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Mason')
	NewTertiaryWeapons(3)=(CWeapon=class'YOWeapon_Kite_Mason')

	NewPrimaryWeapons(9)=(CForceTertiary=(class'YOWeapon_Buckler_Mason'))
	NewPrimaryWeapons(10)=(CForceTertiary=(class'YOWeapon_Buckler_Mason'))

	FamilyID="King"
	Health=500
	
	ProjectileLocationModifiers(EHIT_Head) = 1.0

	KillBonus = 75
	AssistBonus = 15
	ClassReference=ECLASS_King
}
