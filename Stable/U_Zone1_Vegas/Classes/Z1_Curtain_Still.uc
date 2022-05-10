//=============================================================================
// Z1_Curtain_Still.						Keith Schuler 5/5/99
//=============================================================================
class Z1_Curtain_Still expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     HealthPrefab=HEALTH_NeverBreak
     Health=0
     bNotTargetable=True
     bTakeMomentum=False
     CollisionRadius=140.000000
     CollisionHeight=88.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.curtain_still'
}
