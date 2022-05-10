//=============================================================================
// Z5_PC_ChipSocket. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_PC_ChipSocket expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=36.000000
     CollisionHeight=5.000000
     Mesh=DukeMesh'c_zone5_area51.PC_chipsocket'
}
