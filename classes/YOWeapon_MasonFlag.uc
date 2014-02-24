class YOWeapon_MasonFlag extends AOCWeapon_MasonFlag;

`include(CPM/include/YOWeapon.uci)
`include(CPM/include/YOMeleeWeapon.uci)

DefaultProperties
{
	`include(CPM/include/YOWeapon_properties.uci)

	AttachmentClass=class'YOWeaponAttachment_MasonFlag'
}