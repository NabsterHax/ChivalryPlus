class YOWeapon_ProjBodkin extends AOCWeapon_ProjBodkin;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Proj = class'YOProj_BodkinArrow'

	WeaponFontSymbol="n"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_arrbodkin"
	WeaponSmallPortrait="SWF.weapon_select_arrbodkin"
	
}