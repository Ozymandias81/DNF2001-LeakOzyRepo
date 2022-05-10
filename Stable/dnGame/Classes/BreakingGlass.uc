/*-----------------------------------------------------------------------------
	BreakingGlass
	Author: From Unreal, in here for Level Desginers dependent on old stuff.
-----------------------------------------------------------------------------*/
class BreakingGlass extends ExplodingWall;

var() float ParticleSize;
var() float Numparticles;

auto state Exploding
{
	singular function TakeDamage( int NDamage, Pawn InstigatedBy, Vector HitLocation,
						Vector Momentum, class<DamageType> DamageType)
	{
		if ( !bOnlyTriggerable ) 
			Explode( InstigatedBy, Momentum );
	}

	function BeginState()
	{
		Super.BeginState();
		NumGlassChunks = NumParticles;
		GlassParticleSize = ParticleSize;
	}
}

defaultproperties
{
     ParticleSize=+00000.750000
     ExplosionSize=+00100.000000
     Numparticles=+00016.000000
     ExplosionDimensions=+00090.000000
     GlassTexture=Engine.Cloudcast
     NumWallChunks=0
     NumWoodChunks=0
     DrawType=DT_Sprite
     CollisionRadius=+00045.000000
     CollisionHeight=+00045.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     Physics=PHYS_None
     RemoteRole=ROLE_SimulatedProxy
}
