//=============================================================================
// Z2_DCrane_Lower. 					November 6th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_DCrane_Lower expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=154.000000
     CollisionHeight=31.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone2_dam.dcrane_lower'
}
