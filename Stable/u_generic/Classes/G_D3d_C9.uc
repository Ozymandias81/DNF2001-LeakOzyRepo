//=============================================================================
// G_D3d_C9.	ab
//=============================================================================
class G_D3d_C9 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_zone4_afb.dmx
#exec OBJ LOAD FILE=..\textures\m_zone4_afb.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=1
     FragType(0)=Class'dnParticles.dnDebris_Metal1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1c'
     NumberFragPieces=0
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Spawner1')
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_UseHealthVar
     bLandForward=True
     bPushable=True
     PlayerViewOffset=(X=0.700000,Y=1.500000,Z=1.500000)
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone4_afb.D3d_C9'
     ItemName="C9 Canister"
     CollisionRadius=10.000000
     CollisionHeight=26.500000
     Mass=100.000000
     Health=25
}
