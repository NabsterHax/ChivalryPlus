class YOWeapon_Heater extends AOCWeapon_Heater;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_Heatshield'
}