class YOWeaponAttachment_Javelin extends AOCWeaponAttachment_Javelin;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_JavelinMelee'
	AttackTypeInfo(0)=(fBaseDamage=40.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=35.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=55.0, fForce=20000, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}