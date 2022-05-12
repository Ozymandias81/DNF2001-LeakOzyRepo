class BloodSplat expands Scorch;

#exec TEXTURE IMPORT NAME=BloodSplat1 FILE=TEXTURES\DECALS\Blood_Splat_1.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat2 FILE=TEXTURES\DECALS\Blood_Splat_2.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat3 FILE=TEXTURES\DECALS\Blood_Splat_3.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat4 FILE=TEXTURES\DECALS\BloodSplat4.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat5 FILE=TEXTURES\DECALS\Blood_Splat_5.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat6 FILE=TEXTURES\DECALS\BSplat1-S.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat7 FILE=TEXTURES\DECALS\BloodSplat1.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat8 FILE=TEXTURES\DECALS\Blood_Splat_1.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat9 FILE=TEXTURES\DECALS\Spatter1.PCX LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat10 FILE=TEXTURES\DECALS\BloodSplat2.PCX LODSET=2

var texture Splats[10];

simulated function BeginPlay()
{
	if ( class'GameInfo'.Default.bLowGore || (Level.bDropDetail && (FRand() < 0.35)) )
	{
		destroy();
		return;
	}
	if ( Level.bDropDetail )
		Texture = splats[Rand(5)];
	else
		Texture = splats[Rand(10)];
	if ( !AttachDecal(100) )
		destroy();

}

defaultproperties
{
	bImportant=false
	splats(0)=texture'Botpack.BloodSplat1'
	splats(1)=texture'Botpack.BloodSplat2'
	splats(2)=texture'Botpack.BloodSplat3'
	splats(3)=texture'Botpack.BloodSplat4'
	splats(4)=texture'Botpack.BloodSplat5'
	splats(5)=texture'Botpack.BloodSplat6'
	splats(6)=texture'Botpack.BloodSplat7'
	splats(7)=texture'Botpack.BloodSplat8'
	splats(8)=texture'Botpack.BloodSplat9'
	splats(9)=texture'Botpack.BloodSplat10'
	MultiDecalLevel=0
	DrawScale=+0.35
	Texture=texture'Botpack.BloodSplat1'
	RemoteRole=ROLE_None
}
