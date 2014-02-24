class CPMDuelHUD extends AOCDuelHUD;

`define InCPMFFAHUD //FFAHUD because CPMBaseHUD.uci is already set up for that and I couldn't be bothered changing it
	`include(CPM/include/CPMBaseHUD.uci)
`undefine(InCPMFFAHUD)

exec function ShowTeamSelect(int ForceTeam)
{
	ShowClassSelect();
}

exec function ShowClassSelect()
{
	if (!AOCPlayerController(PlayerOwner).bCanChangeClass || AOCPlayerController(PlayerOwner).ScriptBlockedInputs[EINBLOCK_ClassSelect])
		return;

	AOCDuelPlayerController(PlayerOwner).ForceSetDuelStatus(DS_Selection);
	SelectedTeam = 2;
	CharManager = none;
	CharManager = AOCGFx_CharacterSelManager(OpenGFxScene(CharManager, class'AOCGFx_CharacterSelManager',,,,true,false));
	CharManager.StartMenu = 1;
	CharManager.bSkipTeam = true;
	CharManager.Start();
}

function ShowPostDuelScreen(int YourScore, int OppScore, string Opp_Name)
{
	Hud.MainHud.EndChat(false);
	super.ShowPostDuelScreen(YourScore, OppScore, Opp_Name);
}

DefaultProperties
{
}
