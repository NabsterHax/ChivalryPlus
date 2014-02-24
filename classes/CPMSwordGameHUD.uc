class CPMSwordGameHUD extends AOCFFAHUD;

exec function ShowClassSelect()
{
	//CPMSwordGamePC(PlayerOwner).ReceiveChatMessage("", "Show Team Sel,"@CPMSwordGamePC(PlayerOwner).CurrentFamilyInfo@CPMSwordGamePC(PlayerOwner).IsVoluntarySpectator(), EFAC_ALL, true);
	if (AOCPlayerController(PlayerOwner).CurrentFamilyInfo == class'AOCFamilyInfo_None' && !AOCPlayerController(PlayerOwner).IsVoluntarySpectator())
		CPMSwordGamePC(PlayerOwner).RequestSetup();
}

DefaultProperties
{
}
