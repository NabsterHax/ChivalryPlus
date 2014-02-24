class YOWeaponAttachment_ThrustDagger extends AOCWeaponAttachment_ThrustDagger;

`include(CPM/include/YOWeaponAttachment.uci)

DefaultProperties
{
	WeaponClass=class'YOWeapon_ThrustDagger'

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_dag_ThrustDagger.WEP_thrustingdagger'
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.0
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
	End Object

	Begin Object Name=SkeletalMeshComponent2
		SkeletalMesh=SkeletalMesh'WP_dag_ThrustDagger.WEP_thrustingdagger'
		//Translation=(Z=1)
		//Rotation=(Roll=-400)
		Scale=1.0
		bUpdateSkelWhenNotRendered=true
		bForceRefPose=0
		bIgnoreControllersWhenNotRendered=false
		bOverrideAttachmentOwnerVisibility=false
	End Object

	AttackTypeInfo(0)=(fBaseDamage=30.0, fForce=10000, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(1)=(fBaseDamage=45.0, fForce=10000, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(2)=(fBaseDamage=40.0, fForce=10000, cDamageType=AOC.AOCDmgType_Pierce, iWorldHitLenience=6)
	AttackTypeInfo(3)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(4)=(fBaseDamage=0.0, fForce=22500, cDamageType=AOC.AOCDmgType_Swing, iWorldHitLenience=6)
	AttackTypeInfo(5)=(fBaseDamage=5.0, fForce=45500.0, cDamageType=AOC.AOCDmgType_Shove, iWorldHitLenience=12)

}