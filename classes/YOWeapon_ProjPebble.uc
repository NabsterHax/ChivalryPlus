class YOWeapon_ProjPebble extends AOCWeapon_ProjPebble;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Proj = class'YOProj_Pebble'

	WeaponFontSymbol="n"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_arrbroad"
	WeaponSmallPortrait="SWF.weapon_select_arrbroad"
	
}