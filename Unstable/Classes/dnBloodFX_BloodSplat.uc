/*-----------------------------------------------------------------------------
	dnBloodFX_BloodSplat
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnBloodFX_BloodSplat extends dnDecal;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

function PostBeginPlay()
{
	Super.PostBeginPlay();

	DrawScale = 0.1 + 0.1*FRand();
}

defaultproperties
{
	Decals(0)=Texture't_generic.bloodsplatter1R'
	Decals(1)=Texture't_generic.bloodsplatter2R'
	Decals(2)=Texture't_generic.bloodsplatter3R'
    BehaviorArgument=4.0
    Behavior=DB_DestroyNotVisibleForArgumentSeconds
    MinSpawnDistance=2.0
    DrawScale=0.2
	RandomRotation=true
}
