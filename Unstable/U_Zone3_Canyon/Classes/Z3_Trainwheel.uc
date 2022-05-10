//=============================================================================
// Z3_Trainwheel.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_Trainwheel expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionHeight=24.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.trainwheel'
}
