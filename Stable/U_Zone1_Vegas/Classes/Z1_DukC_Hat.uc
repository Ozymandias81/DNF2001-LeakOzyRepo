//=============================================================================
// Z1_DukC_Hat.
// Keith Schuler 3/18/99 ======================================================
class Z1_DukC_Hat expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Inflatable'
     FragType(3)=Class'dnParticles.dnDebrisMesh_InflatableA'
     FragType(4)=Class'dnParticles.dnDebrisMesh_InflatableB'
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Light
     bLandUpright=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-1.150000,Y=1.750000,Z=-1.000000)
     BobDamping=0.982500
     ItemName="Hat"
     bFlammable=True
     CollisionRadius=9.000000
     CollisionHeight=3.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.DukC_hat'
}
