//=============================================================================
// Z5_LaserBase. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_LaserBase expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=72.000000
     CollisionHeight=51.000000
     Mesh=DukeMesh'c_zone5_area51.T_laser2sah'
}
