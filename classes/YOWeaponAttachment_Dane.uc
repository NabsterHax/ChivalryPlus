class YOWeaponAttachment_Dane extends AOCWeaponAttachment_Dane;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Dane'
	AttackTypeInfo(0)=(fBaseDamage=60.0, fForce=22500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=75.0, fForce=25000, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=25.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=105.0, fForce=42500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=32500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}