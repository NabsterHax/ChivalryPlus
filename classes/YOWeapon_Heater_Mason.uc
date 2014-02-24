class YOWeapon_Heater_Mason extends AOCWeapon_Heater_Mason;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Heatshield'
	OtherTeamWeapon(EFAC_AGATHA)=class'YOWeapon_Heater_Agatha'
	WeaponFontSymbol="N"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_masonshield"
	WeaponSmallPortrait="SWF.weapon_select_masonshield"
	
}