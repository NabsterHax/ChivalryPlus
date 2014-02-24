class YOWeaponAttachment_Zweihander extends AOCWeaponAttachment_Zweihander;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Zweihander'
	AttackTypeInfo(0)=(fBaseDamage=90.0, fForce=20000, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=115.0, fForce=32000, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=70.0, fForce=32000, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=90.0, fForce=42500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=35500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
}