class YOWeapon_ProjLeadBall extends AOCWeapon_ProjLeadBall;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)
	
	Proj = class'YOProj_LeadBall'

	WeaponFontSymbol="n"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_arrbroad"
	WeaponSmallPortrait="SWF.weapon_select_arrbroad"
	
}