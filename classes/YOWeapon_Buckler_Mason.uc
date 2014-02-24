class YOWeapon_Buckler_Mason extends AOCWeapon_Buckler_Mason;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Buckler'
	OtherTeamWeapon(EFAC_AGATHA)=class'YOWeapon_Buckler_Agatha'
	WeaponFontSymbol="6"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_buckler_mason"
	WeaponSmallPortrait="SWF.weapon_select_buckler_mason"
	
}