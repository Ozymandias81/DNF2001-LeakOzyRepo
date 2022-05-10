//=============================================================================
// Z5_Techfan1. 						November 10th, 2000 - Charlie Wiederhold
//=============================================================================
class Z5_Techfan1 expands Zone5_Area51;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     IdleAnimations(0)=spin
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=34.000000
     CollisionHeight=84.000000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     Mesh=DukeMesh'c_zone5_area51.techfan1'
}
