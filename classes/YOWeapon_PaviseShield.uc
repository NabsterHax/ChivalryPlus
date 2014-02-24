class YOWeapon_PaviseShield extends AOCWeapon_PaviseShield;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	AttachmentClass=class'YOWeaponAttachment_PaviseShield'
}