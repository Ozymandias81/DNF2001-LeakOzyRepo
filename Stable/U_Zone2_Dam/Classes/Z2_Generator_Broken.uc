//=============================================================================
// Z2_Generator_Broken. 				November 7th, 2000 - Charlie Wiederhold
//=============================================================================
class Z2_Generator_Broken expands Z2_Generator;

#exec OBJ LOAD FILE=..\Textures\m_zone2_dam.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone2_dam.dmx

defaultproperties
{
     DamageThreshold=0
     FragType(3)=None
     FragType(4)=None
     IdleAnimations(0)=genexplo4idle
     SpawnOnDestroyed(1)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     ItemName="Broken Generator"
     Mesh=DukeMesh'c_zone2_dam.generator_explo'
}
