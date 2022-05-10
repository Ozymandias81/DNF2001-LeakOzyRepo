//=============================================================================
// Z1_AirVentHose2. 					 October 9th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_AirVentHose2 expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=27.000000
     CollisionHeight=9.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.air_vent_hose2'
}
