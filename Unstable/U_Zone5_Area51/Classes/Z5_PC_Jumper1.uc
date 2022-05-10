//=============================================================================
// Z5_PC_Jumper1. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_PC_Jumper1 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bLandForward=True
     bLandBackwards=True
     LandFrontCollisionRadius=48.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=48.000000
     LandSideCollisionHeight=6.000000
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=-0.500000,Z=3.000000)
     ItemName="Jumper"
     bTakeMomentum=False
     CollisionRadius=21.000000
     CollisionHeight=25.000000
     Mesh=DukeMesh'c_zone5_area51.PC_Jumper1'
}
