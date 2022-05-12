class UTBloodPool expands Scorch;

#exec TEXTURE IMPORT NAME=BloodPool6 FILE=TEXTURES\DECALS\BSplat1-S.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool7 FILE=TEXTURES\DECALS\BSplat5-S.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool8 FILE=TEXTURES\DECALS\BSplat2-S.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool9 FILE=TEXTURES\DECALS\Spatter2.PCX LODSET=2

var texture Splats[5];

simulated function BeginPlay()
{
	if ( class'GameInfo'.Default.bLowGore )
	{
		destroy();
		return;
	}
	
	if ( Level.bDropDetail )
		Texture = splats[2 + Rand(3)];
	else
		Texture = splats[Rand(5)];;
	if ( !AttachDecal(100) )
		destroy();
}

defaultproperties
{
	splats(0)=texture'Botpack.BloodPool6'
	splats(1)=texture'Botpack.BloodPool8'
	splats(2)=texture'Botpack.BloodPool9'
	splats(3)=texture'Botpack.BloodPool7'
	splats(4)=texture'Botpack.BloodSplat4'
	MultiDecalLevel=4
	DrawScale=+0.75
	Texture=texture'Botpack.BloodSplat1'
	RemoteRole=ROLE_None
}
