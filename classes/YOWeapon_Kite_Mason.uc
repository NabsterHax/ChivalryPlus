class YOWeapon_Kite_Mason extends AOCWeapon_Kite_Mason;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Kite'
	OtherTeamWeapon(EFAC_AGATHA)=class'YOWeapon_Kite_Agatha'
	WeaponFontSymbol="N"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_kite_mason"
	WeaponSmallPortrait="SWF.weapon_select_kite_mason"
	
}