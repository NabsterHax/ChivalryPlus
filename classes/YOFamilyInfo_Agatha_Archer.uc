class YOFamilyInfo_Agatha_Archer extends AOCFamilyInfo_Agatha_Archer;

DefaultProperties
{
	`include(CPM/include/YOFamilyInfo_Archer_properties.uci)

	FamilyID="Archer"
	Faction="Agatha"
	FamilyFaction=EFAC_AGATHA

	NewPrimaryWeapons(3)=(CWeapon=class'YOWeapon_Crossbow',CForceTertiary=(class'YOWeapon_PaviseShield_Agatha',class'YOWeapon_ExtraAmmo'),CheckLimitExpGroup=EEXP_XBOWS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_CrossbowUse)
	NewPrimaryWeapons(4)=(CWeapon=class'YOWeapon_LightCrossbow',CForceTertiary=(class'YOWeapon_PaviseShield_Agatha',class'YOWeapon_ExtraAmmo'),CheckLimitExpGroup=EEXP_XBOWS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_LightCrossbowUse)
	NewPrimaryWeapons(5)=(CWeapon=class'YOWeapon_HeavyCrossbow',CForceTertiary=(class'YOWeapon_PaviseShield_Agatha',class'YOWeapon_ExtraAmmo'),CheckLimitExpGroup=EEXP_XBOWS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_HeavyCrossbowUse)
	NewPrimaryWeapons(6)=(CWeapon=class'YOWeapon_JavelinMelee',CForceTertiary=(class'YOWeapon_Buckler_Agatha'),CheckLimitExpGroup=EEXP_JAVS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_JavelinUse)
	NewPrimaryWeapons(7)=(CWeapon=class'YOWeapon_ShortSpearMelee',CForceTertiary=(class'YOWeapon_Buckler_Agatha'),CheckLimitExpGroup=EEXP_JAVS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_ShortSpearUse)
	NewPrimaryWeapons(8)=(CWeapon=class'YOWeapon_HeavyJavelinMelee',CForceTertiary=(class'YOWeapon_Buckler_Agatha'),CheckLimitExpGroup=EEXP_JAVS,UnlockExpLevel=0.f,CorrespondingDuelProp=EDUEL_HeavyJavelinUse)
	NewTertiaryWeapons(0)=(CWeapon=class'YOWeapon_PaviseShield_Agatha',bEnabledDefault=false)
	NewTertiaryWeapons(2)=(CWeapon=class'YOWeapon_Buckler_Agatha',bEnabledDefault=false)
}