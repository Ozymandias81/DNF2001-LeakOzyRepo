class DirectionalBlast expands Scorch;

#exec TEXTURE IMPORT NAME=directionalblast FILE=TEXTURES\DECALS\Blast2-S.PCX LODSET=2

simulated event BeginPlay()
{
	SetTimer(1.0, false);
}

simulated function DirectionalAttach(vector Dir, vector Norm)
{
	SetRotation(rotator(Norm));
	if( !AttachDecal(100, Dir) )	// trace 100 units ahead in direction of current rotation
	{
		//Log("Couldn't set decal to surface");
		Destroy();
	}
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+1.3
	Texture=texture'Botpack.directionalblast'
}
