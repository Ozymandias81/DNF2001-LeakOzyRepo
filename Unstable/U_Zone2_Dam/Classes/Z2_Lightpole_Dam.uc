//=============================================================================
// Z2_Lightpole_Dam.					November 8th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Lightpole_Dam expands Zone2_Dam;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=17.000000
     CollisionHeight=75.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone2_dam.lightpole_dam'
}
