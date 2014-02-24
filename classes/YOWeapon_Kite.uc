class YOWeapon_Kite extends AOCWeapon_Kite;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Kite'
}