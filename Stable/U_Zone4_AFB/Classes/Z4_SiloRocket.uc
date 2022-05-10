//=============================================================================
// Z4_SiloRocket.						November 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z4_SiloRocket expands Zone4_AFB;

#exec OBJ LOAD FILE=..\Textures\m_zone4_afb.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone4_afb.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=48.000000
     CollisionHeight=360.000000
     Mesh=DukeMesh'c_zone4_afb.SiloRocket'
}
