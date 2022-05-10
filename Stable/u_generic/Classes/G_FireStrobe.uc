//=============================================================================
// G_FireStrobe.	Keith Schuler	Jan 19, 2001
//=============================================================================
class G_FireStrobe expands Generic;

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Smoke_Small1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1a'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     ItemName="Fire Alarm Strobe"
     bFlammable=True
     CollisionRadius=2.000000
     CollisionHeight=5.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Mesh=DukeMesh'c_generic.firestrobe_whte'
}
