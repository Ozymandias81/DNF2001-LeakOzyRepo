//=============================================================================
// Z5_labscrn_screen.
//=============================================================================
class Z5_labscrn_screen expands Zone5_Area51;

///=====  mw, june 18th  ***HAPPY BIRTHDAY CHRIS!***
#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner2')
     LodScale=0.500000
     LodOffset=512.000000
     ItemName="Lab Screen"
     bTakeMomentum=False
     CollisionRadius=26.000000
     CollisionHeight=16.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone5_area51.labscrn_screen'
}
