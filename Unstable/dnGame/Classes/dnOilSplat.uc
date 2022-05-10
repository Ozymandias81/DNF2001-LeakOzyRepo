/*-----------------------------------------------------------------------------
	dnBloodSplat
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnOilSplat extends dnBloodSplat;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
	Decals(0)=Texture't_generic.genoilspill4'
	Decals(1)=Texture't_generic.genoilspill5'
	Decals(2)=Texture't_generic.genoilspill6'
    BehaviorArgument=4.0
    Behavior=DB_DestroyNotVisibleForArgumentSeconds
    MinSpawnDistance=2.0
    DrawScale=0.2
	RandomRotation=true
}
