class YOWeaponAttachment_Fists extends AOCWeaponAttachment_Fists;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Fists'
	AttackTypeInfo(0)=(fBaseDamage=30, fForce=22500, cDamageType=AOC.AOCDmgType_Fists, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=35, fForce=22500, cDamageType=AOC.AOCDmgType_Fists, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=20, fForce=22500, cDamageType=AOC.AOCDmgType_Fists, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=50.0, fForce=22500, cDamageType=AOC.AOCDmgType_Fists, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Fists, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
}