class YOWeaponAttachment_DoubleAxe extends AOCWeaponAttachment_DoubleAxe;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_DoubleAxe'
	AttackTypeInfo(0)=(fBaseDamage=85, fForce=30000, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=95, fForce=30000, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=45.0, fForce=35000, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=40500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}