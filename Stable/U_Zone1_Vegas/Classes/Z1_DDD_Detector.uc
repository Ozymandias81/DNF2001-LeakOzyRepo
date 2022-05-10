//=============================================================================
// Z1_DDD_Detector. 					   July 31st, 2001 - Charlie Wiederhold
//=============================================================================
class Z1_DDD_Detector expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\textures\hud_effects.dtx

defaultproperties
{
     DrinkSound=None
     SpawnOnHit=None
     DestroyedSound=None
     CollisionRadius=1.000000
     CollisionHeight=0.000000
     bBlockActors=False
     bBlockPlayers=False
     bMeshLowerByCollision=False
     Physics=PHYS_Projectile
     PhysNoneOnStop=False
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'hud_effects.msgdwn_icon.stat_dwnlobj_04'
     Mesh=None
     DrawScale=0.125000
}
