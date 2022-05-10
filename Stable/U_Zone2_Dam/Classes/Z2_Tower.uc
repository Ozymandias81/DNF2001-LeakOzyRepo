//=============================================================================
// Z2_Tower.							November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Tower expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=145.000000
     CollisionHeight=138.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone2_dam.tower1_dam'
}
