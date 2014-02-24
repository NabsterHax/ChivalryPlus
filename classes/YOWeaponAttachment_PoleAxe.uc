class YOWeaponAttachment_PoleAxe extends AOCWeaponAttachment_PoleAxe;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_PoleAxe'
	AttackTypeInfo(0)=(fBaseDamage=70.0, fForce=32500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=90.0, fForce=32500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=80.0, fForce=32500, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=35500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}