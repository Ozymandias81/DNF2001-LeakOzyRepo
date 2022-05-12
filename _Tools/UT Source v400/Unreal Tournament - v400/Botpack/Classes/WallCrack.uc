class WallCrack expands Scorch;

#exec TEXTURE IMPORT NAME=WallCrack1 FILE=TEXTURES\DECALS\Flak_crk1.PCX LODSET=2
#exec TEXTURE IMPORT NAME=WallCrack2 FILE=TEXTURES\DECALS\Flak_crk2.PCX LODSET=2

simulated function BeginPlay()
{
	if ( FRand() < 0.5 )
		Texture = texture'Botpack.WallCrack1';
	else
		Texture = texture'Botpack.WallCrack2';
	if ( !AttachDecal(100) )
		destroy();
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.4
	Texture=texture'Botpack.WallCrack1'
}
