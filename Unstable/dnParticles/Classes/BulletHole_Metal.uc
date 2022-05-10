//=============================================================================
// BulletHole_Metal.
//=============================================================================
class BulletHole_Metal expands dnDecal;

defaultproperties
{
     Decals(0)=Texture'm_dnWeapon.bulletholes.bhole_mtl1aRC'
     Decals(1)=Texture'm_dnWeapon.bulletholes.bhole_mtl1bRC'
     BehaviorArgument=4.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     MinSpawnDistance=2.000000
     DrawScale=0.090000
}
