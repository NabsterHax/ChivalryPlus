class YOWeapon_AgathaFlag extends AOCWeapon_AgathaFlag;

`include(CPM/include/YOWeapon.uci)
`include(CPM/include/YOMeleeWeapon.uci)

DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	AttachmentClass=class'YOWeaponAttachment_AgathaFlag'
}