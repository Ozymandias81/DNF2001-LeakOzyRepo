/*-----------------------------------------------------------------------------
	GlassMover
-----------------------------------------------------------------------------*/
class GlassMover expands Mover;

var () class<GlassShatterEffect>	GlassParticleSystem;
var () GlassShatterEffect			GlassParticleSystemActor;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, 
					 Vector Momentum, class<DamageType> DamageType )
{
	local texture t;
	local vector SurfBase, SurfU, SurfV, SurfUSize, SurfVSize, IncomingHitVector;

	if ( GlassParticleSystemActor == none )
	{
		GlassParticleSystemActor = Spawn( GlassParticleSystem,,, HitLocation, Rotator(InstigatedBy.Location - HitLocation) );
		Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
	}
}

defaultproperties
{
	MoveTime=0.000000
	bTriggerOnceOnly=true
	bDamageTriggered=true
	bTranslucentMover=true
	InitialState=TriggerToggle
	GlassParticleSystem=class'GlassShatterEffect'
}
