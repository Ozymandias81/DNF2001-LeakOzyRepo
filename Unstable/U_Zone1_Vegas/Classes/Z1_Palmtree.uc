//=============================================================================
// Z1_Palmtree.
//=============================================================================
class Z1_Palmtree expands Zone1_Vegas;

// Revised by Keith Schuler 2/24/99

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     NumberFragPieces=0
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     bNotTargetable=True
     bTakeMomentum=False
     bFlammable=True
     bMovable=False
     CollisionHeight=125.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.palm2'
}
