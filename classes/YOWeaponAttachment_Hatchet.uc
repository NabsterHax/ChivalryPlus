class YOWeaponAttachment_Hatchet extends AOCWeaponAttachment_Hatchet;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_Hatchet'

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_1ha_Hatchet.WEP_Hatchet'
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.0
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_1ha_Hatchet.WEP_Hatchet'
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.0
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
	End Object

	
	AttackTypeInfo(0)=(fBaseDamage=65.0, fForce=20000, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=70.0, fForce=20000, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=30.0, fForce=22500, cDamageType=AOC.AOCDmgType_Blunt, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=120.0, fForce=42500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=1.0, fForce=22500, cDamageType=AOC.AOCDmgType_SwingBlunt, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)
	
	
}