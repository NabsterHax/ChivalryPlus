class YOWeapon_Buckler_Agatha extends AOCWeapon_Buckler_Agatha;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Buckler'
	OtherTeamWeapon(EFAC_MASON)=class'AOCWeapon_Buckler_Mason'
	WeaponFontSymbol="6"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_buckler_agatha"
	WeaponSmallPortrait="SWF.weapon_select_buckler_agatha"
	
}