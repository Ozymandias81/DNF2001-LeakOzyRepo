//=============================================================================
// BulletHole_Glass.
//=============================================================================
class BulletHole_Glass expands dnDecal;

defaultproperties
{
     Decals(0)=Texture'm_dnWeapon.bulletholes.bhole_glass1bRC'
     BehaviorArgument=4.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     MinSpawnDistance=2.000000
     Style=STY_Translucent
     DrawScale=0.100000
}
