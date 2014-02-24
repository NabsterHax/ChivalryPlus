class YOWeaponAttachment_Dagesse extends AOCWeaponAttachment_Dagesse;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Dagesse'
	AttackTypeInfo(0)=(fBaseDamage=40.0, fForce=10000, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=45.0, fForce=10000, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=50.0, fForce=10000, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=65.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}