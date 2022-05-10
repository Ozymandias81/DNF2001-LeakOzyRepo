//=============================================================================
// BulletHole_FreezeRay.
//=============================================================================
class BulletHole_FreezeRay expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Decals(0)=Texture't_generic.iceparticles.icepatch2aRC'
     Decals(1)=Texture't_generic.iceparticles.icepatch2bRC'
     BehaviorArgument=1.000000
     Behavior=DB_DestroyAfterArgumentSeconds
     MinSpawnDistance=1.000000
     DrawScale=0.100000
}
