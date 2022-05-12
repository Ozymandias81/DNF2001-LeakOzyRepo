class LavaZone extends ZoneInfo;

#exec AUDIO IMPORT FILE="Sounds\Generic\GoopE1.WAV" NAME="LavaEx" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\GoopJ1.WAV" NAME="LavaEn" GROUP="Generic"
//#exec AUDIO IMPORT FILE="Sounds\Generic\uLava1.WAV" NAME="InLava" GROUP="Generic"
//	AmbientSound=InLava

defaultproperties
{
	DamagePerSec=40
	DamageType=Burned
	bPainZone=True
	bWaterZone=True
	bDestructive=True
	bNoInventory=true
    ViewFog=(X=0.5859375,Y=0.1953125,Z=0.078125)
	EntryActor=UnrealShare.FlameExplosion
	ExitActor=UnrealShare.FlameExplosion
	EntrySound=UnrealShare.LavaEn
	ExitSound=UnrealShare.LavaEx
}