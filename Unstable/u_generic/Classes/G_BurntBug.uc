//=============================================================================
// G_BurntBug.
//=============================================================================
class G_BurntBug expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 14th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//AllenB

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebrisMesh_MetalMedium1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_MetalMedium1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_MetalMedium1b'
     FragType(3)=Class'dnParticles.dnDebrisMesh_MetalMedium1c'
     FragType(4)=Class'dnParticles.dnDebris_Smoke'
     FragType(5)=Class'dnParticles.dnDebris_Metal1'
     FragType(6)=Class'dnParticles.dnDebris_Metal1'
     FragType(7)=Class'dnParticles.dnDebris_Sparks1_Large'
     NumberFragPieces=0
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     bTumble=False
     bTakeMomentum=False
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_Hard
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.burntbug'
     ItemName="Burned Up Car"
     DrawScale=1.200000
     ScaleGlow=50.000000
     CollisionRadius=108.000000
     CollisionHeight=30.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mass=1000.000000
     Health=0
}
