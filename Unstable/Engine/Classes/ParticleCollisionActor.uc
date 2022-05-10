/*-----------------------------------------------------------------------------
	ParticleCollisionActor
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ParticleCollisionActor extends Item
	native;

var bool				bInUse;
var int					ParticleIndex;
var SoftParticleSystem	MyParticleSystem;

// Valid during Update()
var float				pLifetime;
var float				pLifetimeRemaining;

event Locked()
{
}

event Unlocked()
{
}

event Update()
{
}

defaultproperties
{
	RemoteRole=ROLE_None
	bHidden=true
	CollisionRadius=10
	CollisionHeight=10
}