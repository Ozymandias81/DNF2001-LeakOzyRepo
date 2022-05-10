/*-----------------------------------------------------------------------------
	dnAlienBloodSplat
-----------------------------------------------------------------------------*/
class dnAlienBloodSplat extends dnBloodSplat;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
	Decals(0)=Texture't_generic.alienblood1rc'
	Decals(1)=Texture't_generic.alienblood5rc'
	Decals(2)=Texture't_generic.alienblood4rc'
    BehaviorArgument=4.0
    Behavior=DB_DestroyNotVisibleForArgumentSeconds
    MinSpawnDistance=2.0
    DrawScale=0.2
	RandomRotation=true
}
