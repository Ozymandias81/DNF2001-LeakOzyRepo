//=============================================================================
// Z1_FuseDecoration.	Keith Schuler November 3, 2000
//=============================================================================
class Z1_FuseDecoration expands Zone1_Vegas;

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SElec_Spawner3')
     HealthPrefab=HEALTH_NeverBreak
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionHeight=4.000000
     LandSideCollisionHeight=4.000000
     ItemName="Fuse (200 amps)"
     bTakeMomentum=False
     CollisionRadius=4.000000
     CollisionHeight=18.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_zone1_vegas.fuse'
     AnimSequence=glow_on
}
