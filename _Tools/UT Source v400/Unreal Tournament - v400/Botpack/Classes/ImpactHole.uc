//=============================================================================
// pock.
//=============================================================================
class ImpactHole expands Scorch;

#exec TEXTURE IMPORT NAME=impactcrack FILE=TEXTURES\DECALS\ImpactMark.PCX LODSET=2

simulated function BeginPlay()
{
	if ( !AttachDecal(100) )
		destroy();
}

defaultproperties
{
	MultiDecalLevel=2
	DrawScale=+0.5
	Texture=texture'Botpack.ImpactCrack'
    bHighDetail=True
    DrawScale=0.400000
}
