//=============================================================================
// G_SecurityGlobe.
//=============================================================================
class G_SecurityGlobe expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     HealthMarkers(0)=(Threshold=199,PlaySequence=Rotate,ChangeMesh=DukeMesh'c_generic.secrcam1B')
     HealthMarkers(1)=(Threshold=50,PlaySequence=malfunction)
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Glass1d'
     NumberFragPieces=24
     FragBaseScale=0.300000
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_SecurityCam1')
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     Health=200
     ItemName="Security Globe"
     bTakeMomentum=False
     bDirectional=True
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_generic.secrcam1A'
     DrawScale=2.000000
}
