//=============================================================================
// G_Pipe1B.
//====================================Created Feb 24th, 1999 - Stephen Cole
class G_Pipe1B expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebris_Metal1_Small'
     SpawnOnHit=Class'dnParticles.dnBulletFX_CementSpawner'
     bTakeMomentum=False
     MassPrefab=MASS_Light
     bLandLeft=True
     bLandRight=True
     PlayerViewOffset=(X=1.000000,Y=-0.500000,Z=2.000000)
     Mesh=DukeMesh'c_generic.pipe1b'
     ItemName="Pipe Elbow"
     CollisionRadius=10.000000
     CollisionHeight=9.000000
}
