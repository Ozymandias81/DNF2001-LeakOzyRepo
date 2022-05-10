//=============================================================================
// G_WallClock.
//=============================================================================
class G_WallClock expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 16th, 1998 - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     FragBaseScale=0.400000
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.500000)
     BobDamping=0.900000
     ItemName="Wall Clock"
     bTakeMomentum=False
     bFlammable=True
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     Mesh=DukeMesh'c_generic.wallclock'
}
