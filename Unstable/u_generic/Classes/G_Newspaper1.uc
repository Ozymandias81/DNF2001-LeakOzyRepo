//=============================================================================
// G_Newspaper1.
//==========================================Created Feb 24th, 1999 - Stephen Cole
class G_Newspaper1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Paper1'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_Easy
     ItemName="Newspaper"
     bFlammable=True
     CollisionRadius=16.000000
     CollisionHeight=1.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.newspaper1'
}
