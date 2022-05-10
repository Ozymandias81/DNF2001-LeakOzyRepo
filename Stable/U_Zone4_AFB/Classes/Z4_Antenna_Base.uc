//=============================================================================
// Z4_Antenna_Base. 					November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z4_Antenna_Base expands Zone4_AFB;

#exec OBJ LOAD FILE=..\Textures\m_zone4_afb.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone4_afb.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=100.000000
     CollisionHeight=61.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone4_afb.ant01'
}
