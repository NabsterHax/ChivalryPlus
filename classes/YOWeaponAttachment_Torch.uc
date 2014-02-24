class YOWeaponAttachment_Torch extends AOCWeaponAttachment_Torch;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Torch'

	AttackTypeInfo(0)=(fBaseDamage=20.0, fForce=22500, cDamageType=AOC.AOCDmgType_Generic, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=20.0, fForce=22500, cDamageType=AOC.AOCDmgType_Generic, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=20.0, fForce=22500, cDamageType=AOC.AOCDmgType_Generic, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=20.0, fForce=22500, cDamageType=AOC.AOCDmgType_Generic, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=1.0, fForce=22500, cDamageType=AOC.AOCDmgType_Generic, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
}