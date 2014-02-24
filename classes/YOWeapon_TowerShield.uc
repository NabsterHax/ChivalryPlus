class YOWeapon_TowerShield extends AOCWeapon_TowerShield;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_TowerShield'
}