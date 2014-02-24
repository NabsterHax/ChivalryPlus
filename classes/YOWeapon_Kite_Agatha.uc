class YOWeapon_Kite_Agatha extends AOCWeapon_Kite_Agatha;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Kite'
	OtherTeamWeapon(EFAC_MASON)=class'YOWeapon_Kite_Mason'
	WeaponFontSymbol="N"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_kite_agatha"
	WeaponSmallPortrait="SWF.weapon_select_kite_agatha"
	
}