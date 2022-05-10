//=============================================================================
// Z1_Ps_CannonBall.
//=============================================================================
class Z1_Ps_CannonBall expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     HealthPrefab=HEALTH_NeverBreak
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=4.000000
     LandFrontCollisionHeight=4.000000
     LandSideCollisionRadius=4.000000
     LandSideCollisionHeight=4.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.500000,Y=-0.625000,Z=1.000000)
     BobDamping=0.900000
     Health=0
     ItemName="Cannon Ball"
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bProjTarget=True
     Physics=PHYS_Falling
     Mass=150.000000
     Mesh=DukeMesh'c_zone1_vegas.ps_cannonball'
}
