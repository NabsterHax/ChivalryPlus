class YOWeaponAttachment_HFlail extends AOCWeaponAttachment_HFlail;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Flail'

	AttackTypeInfo(0)=(fBaseDamage=65.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=35, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}