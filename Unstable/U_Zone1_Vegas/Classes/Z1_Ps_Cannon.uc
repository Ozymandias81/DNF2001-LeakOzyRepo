//=============================================================================
// Z1_Ps_Cannon.
//=============================================================================
class Z1_Ps_Cannon expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     ItemName="Cannon"
     bTakeMomentum=False
     CollisionRadius=48.000000
     CollisionHeight=18.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.ps_cannon'
}
