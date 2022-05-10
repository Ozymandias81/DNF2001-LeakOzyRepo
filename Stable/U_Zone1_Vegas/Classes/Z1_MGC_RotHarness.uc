//=============================================================================
// Z1_MGC_RotHarness. 					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_MGC_RotHarness expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=55.000000
     CollisionHeight=54.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.mgc_rotharness'
}
