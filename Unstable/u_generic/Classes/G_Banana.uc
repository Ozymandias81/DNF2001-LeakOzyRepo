//=============================================================================
// G_Banana.
//=============================================================================
// AllenB append Stephen Cole
class G_Banana expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=6,PlaySequence=bannana_squish)
     HealthMarkers(1)=(Threshold=4,PlaySequence=bannana_sprin_sqish)
     FragType(0)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(5)=Class'dnParticles.dnDebris_Fabric1'
     NumberFragPieces=0
     SpawnOnHit=None
     DestroyedSound=Sound'a_impact.Debris.ImpactDeb008'
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_UseHealthVar
     bLandUpright=True
     bLandUpsideDown=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.250000,Y=-0.500000,Z=-0.500000)
     Health=7
     ItemName="Banana"
     bFlammable=True
     CollisionRadius=8.000000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.nanner'
     AnimSequence=bannana_idle
}
