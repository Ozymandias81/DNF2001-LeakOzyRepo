//=============================================================================
// Z1_StatueFountainWoman_Broken.	   November 28th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_StatueFountainWoman_Broken expands Z1_StatueFountainWoman;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnDestroyed(0)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     CollisionHeight=72.000000
     Mesh=DukeMesh'c_zone1_vegas.StatueGBroke'
}
