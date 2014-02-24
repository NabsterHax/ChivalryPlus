class YOWeaponAttachment_Mace extends AOCWeaponAttachment_Mace;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Mace'
	AttackTypeInfo(0)=(fBaseDamage=65, fForce=20000, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=65.0, fForce=20000, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=30.0, fForce=22500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}