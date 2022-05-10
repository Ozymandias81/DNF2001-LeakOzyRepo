//=============================================================================
// Z2_DCrane_Higher. 					November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_DCrane_Higher expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=250.000000
     CollisionHeight=32.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone2_dam.dcrane_higher'
}
