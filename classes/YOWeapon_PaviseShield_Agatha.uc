class YOWeapon_PaviseShield_Agatha extends AOCWeapon_PaviseShield_Agatha;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	AttachmentClass=class'YOWeaponAttachment_PaviseShield_Agatha'
	OtherTeamWeapon(EFAC_MASON)=class'AOCWeapon_PaviseShield_Mason'
	WeaponFontSymbol=">"
	WeaponReach=100
	WeaponLargePortrait="SWF.weapon_select_pavise_agatha"
	WeaponSmallPortrait="SWF.weapon_select_pavise_agatha"
	PlaceAnimation=(AnimationName=3p_pavise_equipup,ComboAnimation=,AssociatedSoundCue=SoundCue'A_Combat_Locomotion.jav_draw',bFullBody=false,bCombo=false,bLoop=false,bForce=false,UniqueShieldSound=none,fModifiedMovement=0.0,fAnimationLength=1.1,fBlendInTime=0.10,fBlendOutTime=0.10,bLastAnimation=false)
	
}