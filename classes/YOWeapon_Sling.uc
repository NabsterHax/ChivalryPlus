class YOWeapon_Sling extends AOCWeapon_Sling;

`include(CPM/include/YOWeapon.uci)
DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	AttachmentClass=class'YOWeaponAttachment_Sling'
}