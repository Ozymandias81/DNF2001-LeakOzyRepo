//=============================================================================
// Z3_SolarPanel.						November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z3_SolarPanel expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone3_canyon.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=385.000000
     CollisionHeight=64.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone3_canyon.solarpanel1'
}
