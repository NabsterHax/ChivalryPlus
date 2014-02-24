class CPMSwordGamePRI extends AOCFFAPRI;

var int CurrentLoadoutNumber;

replication
{
	if (bNetDirty)
		CurrentLoadoutNumber;
}

DefaultProperties
{
}
