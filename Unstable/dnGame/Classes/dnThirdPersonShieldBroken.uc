class dnThirdPersonShieldBroken extends dnThirdPersonShield;

simulated function PostBeginPlay()
{
	local int					i;
	local SoftParticleSystem	s;

	for ( i=0; i<ArrayCount( FragType ); i++ )
	{
		s = spawn ( FragType[i], self );
	}
}


simulated function Tick( float Delta )
{
	Super(dnDecoration).Tick( Delta );
}

defaultproperties
{
	 Health=1
	 HealthPrefab=HEALTH_Easy
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Glass1a'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Glass1b'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Glass1c'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Glass1d'
     FragType(6)=Class'dnParticles.dnDebris_Glass1'
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak57a'
     bLandBackwards=True
     LandFrontCollisionRadius=27.000000
     LandFrontCollisionHeight=2.000000
     Mesh=DukeMesh'c_characters.EDFshieldbrkn'
     ItemName="Riot Shield (Broken)"
     CollisionRadius=13.000000
     CollisionHeight=24.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
}
