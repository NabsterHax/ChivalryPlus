class YOWeaponAttachment_Bardiche extends AOCWeaponAttachment_Bardiche;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Bardiche'
	AttackTypeInfo(0)=(fBaseDamage=80.0, fForce=32500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=100.0, fForce=22500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=22500, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=85.0, fForce=42500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=35500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}