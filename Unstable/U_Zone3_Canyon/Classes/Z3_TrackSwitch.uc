//=============================================================================
// Z3_TrackSwitch.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_TrackSwitch expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     ItemName="Track Switch"
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=50.000000
     CollisionHeight=40.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone3_canyon.trackswitch'
     AmbientGlow=2
}
