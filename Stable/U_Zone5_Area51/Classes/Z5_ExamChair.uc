//=============================================================================
// Z5_ExamChair. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_ExamChair expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=52.000000
     CollisionHeight=41.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone5_area51.exam_chair'
}
