class YOWeapon_Buckler extends AOCWeapon_Buckler;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield = class'YOShield_Buckler'
}