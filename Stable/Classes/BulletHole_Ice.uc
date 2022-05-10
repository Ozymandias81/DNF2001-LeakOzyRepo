//=============================================================================
// BulletHole_Ice.
//=============================================================================
class BulletHole_Ice expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

defaultproperties
{
     Decals(0)=Texture'm_dnweapon.bulletholes.bhole_mtl2aRC'
     Decals(1)=Texture'm_dnweapon.bulletholes.bhole_mtl2bRC'
     BehaviorArgument=4.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     MinSpawnDistance=2.000000
     DrawScale=0.075000
}
