class CPMCustomizationContent extends AOCCustomizationContent;

static function int GetDefaultCharacterIDFor(int Team, int PawnClass)
{
	//`log("GetDefaultCharacterIDFor"@Team@PawnClass);
	switch(PawnClass)
	{
	case ECLASS_Archer:
		return Team == EFAC_Agatha ? default.Characters.Find(class'AOCCharacterInfo_Agatha_Archer') : default.Characters.Find(class'AOCCharacterInfo_Mason_Archer');
		break;
	case ECLASS_ManAtArms:
		return Team == EFAC_Agatha ? default.Characters.Find(class'AOCCharacterInfo_Agatha_ManAtArms') : default.Characters.Find(class'AOCCharacterInfo_Mason_ManAtArms');
		break;
	case ECLASS_Vanguard:
		return Team == EFAC_Agatha ? default.Characters.Find(class'CPMCharacterInfo_Agatha_Vanguard') : default.Characters.Find(class'CPMCharacterInfo_Mason_Vanguard');
		break;
	case ECLASS_Knight:
		return Team == EFAC_Agatha ? default.Characters.Find(class'CPMCharacterInfo_Agatha_Knight') : default.Characters.Find(class'CPMCharacterInfo_Mason_Knight');
		break;
	case ECLASS_King:
		return Team == EFAC_Agatha ? default.Characters.Find(class'CPMCharacterInfo_Agatha_King') : default.Characters.Find(class'CPMCharacterInfo_Mason_King');
		break;
	case ECLASS_Peasant:
	default:
		return default.Characters.Find(class'AOCCharacterInfo_Peasant');
	};
}

DefaultProperties
{
	//Characters.Remove(class'AOCCharacterInfo_Skeleton')
	Characters.Remove(class'AOCCharacterInfo_Skeleton')
	Characters.Remove(class'AOCCharacterInfo_Agatha_Archer')
	Characters.Remove(class'AOCCharacterInfo_Agatha_King')
	Characters.Remove(class'AOCCharacterInfo_Agatha_Knight')
	Characters.Remove(class'AOCCharacterInfo_Agatha_ManAtArms')
	Characters.Remove(class'AOCCharacterInfo_Agatha_Vanguard')
	Characters.Remove(class'AOCCharacterInfo_Mason_Archer')
	Characters.Remove(class'AOCCharacterInfo_Mason_King')
	Characters.Remove(class'AOCCharacterInfo_Mason_Knight')
	Characters.Remove(class'AOCCharacterInfo_Mason_ManAtArms')
	Characters.Remove(class'AOCCharacterInfo_Mason_Vanguard')
	Characters.Remove(class'AOCCharacterInfo_Peasant')
	Characters.Remove(class'AOCCharacterInfo_Playable_Peasant')
	Characters.Remove(class'AOCCharacterInfo_Playable_Skeleton')

	//This ordering shouldn't change. Nothing terrible will happen as long (as the server and clients have the same ordering), but users' customization choices will be altered.
	Characters.Add(class'AOCCharacterInfo_Skeleton') //Placeholder invalid entry
	Characters.Add(class'AOCCharacterInfo_Skeleton')
	Characters.Add(class'AOCCharacterInfo_Agatha_Archer')
	Characters.Add(class'CPMCharacterInfo_Agatha_King')
	Characters.Add(class'CPMCharacterInfo_Agatha_Knight')
	Characters.Add(class'AOCCharacterInfo_Agatha_ManAtArms')
	Characters.Add(class'CPMCharacterInfo_Agatha_Vanguard')
	Characters.Add(class'AOCCharacterInfo_Mason_Archer')
	Characters.Add(class'CPMCharacterInfo_Mason_King')
	Characters.Add(class'CPMCharacterInfo_Mason_Knight')
	Characters.Add(class'AOCCharacterInfo_Mason_ManAtArms')
	Characters.Add(class'CPMCharacterInfo_Mason_Vanguard')
	Characters.Add(class'AOCCharacterInfo_Peasant')
	Characters.Add(class'AOCCharacterInfo_Playable_Peasant')
	Characters.Add(class'AOCCharacterInfo_Playable_Skeleton')
}
