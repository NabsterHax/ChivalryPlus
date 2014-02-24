class YOWeapon_TowerShield_Agatha extends AOCWeapon_TowerShield_Agatha;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	Shield=class'YOShield_TowerShield'
	OtherTeamWeapon(EFAC_MASON)=class'YOWeapon_TowerShield_Mason'
	WeaponFontSymbol=">"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_tower_agatha"
	WeaponSmallPortrait="SWF.weapon_select_tower_agatha"
	
}