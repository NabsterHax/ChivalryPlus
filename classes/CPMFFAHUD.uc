class CPMFFAHUD extends AOCFFAHUD;

`define InCPMFFAHUD
	`include(CPM/include/CPMBaseHUD.uci)
`undefine(InCPMFFAHUD)

/*exec function ShowTeamSelect(int ForceTeam)
{
	//`log("SHOW CLASS SELECT");
	//FinishSelectTeam(0);
	SelectedTeam=2; // Both teams get counted
	ShowClassSelect();
}

exec function ShowClassSelect()
{
		//`log("Display Class Select");
//	OpenUIScene(PlayerOwner, ClassSelectionTemplate);
	if (!AOCPlayerController(PlayerOwner).bCanChangeClass || AOCPlayerController(PlayerOwner).ScriptBlockedInputs[EINBLOCK_ClassSelect])
		return;

	SelectedTeam = 2;
	CharManager = none;
	CharManager = AOCGFx_CharacterSelManager(OpenGFxScene(CharManager, class'CPMGFx_CharacterSelManager',,,,true,false));
	CharManager.StartMenu = 1;
	CharManager.bSkipTeam = true;
	CharManager.Start();
}*/

DefaultProperties
{
	PawnClass=class'CPMPawn'
}
