//=============================================================================
// Z1_Ps_CannonBarrel.
//=============================================================================
class Z1_Ps_CannonBarrel expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     ItemName="Cannon Barrel"
     bTakeMomentum=False
     CollisionHeight=8.000000
     bCollideWorld=False
     Physics=PHYS_MovingBrush
     Mesh=DukeMesh'c_zone1_vegas.ps_cannonbarrel'
}
