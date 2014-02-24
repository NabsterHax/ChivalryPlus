class CPMBombTargetSlave extends AOCStaticMeshActor_Usable;

var(BombTargetSlave) CPMBombTarget Master;

simulated function bool CanBeUsed(optional int Faction, optional AOCPawn CheckUser, optional out int bHold)
{
	return Master.CanBeUsed(Faction, CheckUser, bHold);
}

simulated function bool UtilizeObject(AOCPawn User, bool bUseDrop, optional name BoneHit = 'none')
{
	return Master.UtilizeObject(User, bUseDrop, BoneHit);
}

simulated function EndUtilizeObject(AOCPawn User)
{
	Master.EndUtilizeObject(User);
}

DefaultProperties
{
	Master=none

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=TRUE
		AlwaysLoadOnClient=FALSE
		AlwaysLoadOnServer=FALSE
		SpriteCategoryName="Info"
	End Object
	Components.Add(Sprite)
}
