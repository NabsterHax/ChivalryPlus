class YOWeapon_Heater_Agatha extends AOCWeapon_Heater_Agatha;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Heatshield'
	OtherTeamWeapon(EFAC_MASON)=class'YOWeapon_Heater_Mason'
	WeaponFontSymbol="N"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_agathashield"
	WeaponSmallPortrait="SWF.weapon_select_agathashield"
	
}