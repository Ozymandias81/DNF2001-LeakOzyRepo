//=============================================================================
// Z1_StatueStuffedBoss.
//=============================================================================
class Z1_StatueStuffedBoss expands Zone1_Vegas;

// Keith Schuler 2/23/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     ItemName="Bad Ass"
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=275.000000
     CollisionHeight=200.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.stuffedboss'
}
