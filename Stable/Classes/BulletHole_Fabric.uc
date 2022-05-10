//=============================================================================
// BulletHole_Fabric.
//=============================================================================
class BulletHole_Fabric expands dnDecal;

#exec OBJ LOAD FILE=..\Textures\m_dnWeapons.dtx

defaultproperties
{
     Decals(0)=Texture'm_dnweapon.bulletholes.bhole_fabric1cR'
     Decals(1)=Texture'm_dnweapon.bulletholes.bhole_fabric1bR'
     Decals(2)=Texture'm_dnweapon.bulletholes.bhole_fabric1cR'
     BehaviorArgument=4.000000
     Behavior=DB_DestroyNotVisibleForArgumentSeconds
     MinSpawnDistance=2.000000
     DrawScale=0.075000
}
