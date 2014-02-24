class YOWeapon_ProjBroadhead extends AOCWeapon_ProjBroadhead;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Proj = class'YOProj_BroadheadArrow'

	WeaponFontSymbol="H"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_arrbroad"
	WeaponSmallPortrait="SWF.weapon_select_arrbroad"
	
}