class YOWeaponAttachment_MorningStar extends AOCWeaponAttachment_MorningStar;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_MorningStar'
	AttackTypeInfo(0)=(fBaseDamage=60.0, fForce=20500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70.0, fForce=22500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=22500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=25500, cDamageType=AOC.AOCDmgType_PierceBlunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}