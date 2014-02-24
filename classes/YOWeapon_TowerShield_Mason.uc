class YOWeapon_TowerShield_Mason extends AOCWeapon_TowerShield_Mason;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_TowerShield'
	OtherTeamWeapon(EFAC_AGATHA)=class'YOWeapon_TowerShield_Agatha'
	WeaponFontSymbol=">"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_tower_mason"
	WeaponSmallPortrait="SWF.weapon_select_tower_mason"
	
}