//=============================================================================
// TriggerSpawn. (NJS)
//
// TriggerSpawn creates an object of type <actorType> whenever it is triggered.
//=============================================================================
class TriggerSpawn expands Triggers;

#exec Texture Import File=Textures\TriggerSpawn.pcx Name=S_TriggerSpawn Mips=Off Flags=2

var () class<actor> actorType;
var () name         actorTag;
var () name			actorEvent;

var () bool		AssignLifeSpan;
var () float		NewLifeSpan;
var () bool			AssignDrawScale;
var () float		NewDrawScale;
var () bool			AssignPhysics;
var () EPhysics     NewPhysics;
var () bool			AssignVelocity;
var () vector		NewVelocity;
var () bool			AssignAcceleration;
var () vector		NewAcceleration;
var () bool			AssignSpeed;
var () float		NewSpeed;
var () bool         AssignAccelerationSpeed;
var () float		NewAccelerationSpeed;
var () vector		VelocityVariance;

var(CollisionAssign) bool AssignCollisionRadius; 
var(CollisionAssign) float NewCollisionRadius;
var(CollisionAssign) bool AssignCollisionHeight;
var(CollisionAssign) float NewCollisionHeight;

// Collision flags.
var(CollisionAssign) bool 		AssignbCollideActors;
var(CollisionAssign) const bool NewbCollideActors;
var(CollisionAssign) bool       AssignbCollideWorld;
var(CollisionAssign) bool       NewbCollideWorld;
var(CollisionAssign) bool       AssignbBlockActors;
var(CollisionAssign) bool       NewbBlockActors;
var(CollisionAssign) bool       AssignbBlockPlayers;
var(CollisionAssign) bool       NewbBlockPlayers;
var(CollisionAssign) bool       AssignbProjTarget;
var(CollisionAssign) bool       NewbProjTarget;

var () name			SpawnWhenInCollisionRadius;
var () float		DelayToNextSpawn;

var () name			TargetActorName;
var () bool			TargetNearestPawn;
var () float		SpawnDelay;
var () float		SpawnDelayVariance;

var () bool			DestroyAfterSpawn;

var () bool			bTossDecoration;

var float LastSpawn;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	LastSpawn = 0;

	if ( SpawnWhenInCollisionRadius != '' )
		Enable( 'Touch' );
	else
		Disable( 'Touch' );
}

function Timer(optional int TimerNum)
{
	DoSpawn();
	Enable( 'Trigger' );
}

function actor DoSpawn()
{
	local actor a, a2;
	local pawn p;
	local actor Targets[32];
	local int TargetCount;

	a = none;

	// Check to see if I can spawn:
	if ( LastSpawn + DelayToNextSpawn > Level.TimeSeconds )
		return None;
	LastSpawn = Level.TimeSeconds;

	if ( bool(actorType) )				// If the actor is real..
	{
		a = Spawn( actorType, , actorTag );	// Create an actor of this type with my rotation and location.	
		a.Event = actorEvent;

		if(AssignLifeSpan)			a.LifeSpan=NewLifeSpan;
		if(AssignPhysics)			a.SetPhysics(NewPhysics);
		if(AssignVelocity)			a.Velocity=NewVelocity;
		if(AssignAcceleration)		a.Acceleration=NewAcceleration;
		if(AssignSpeed)				a.Velocity=vector(Rotation)*NewSpeed;
		if(AssignAccelerationSpeed)	a.Acceleration=vector(Rotation)*NewAccelerationSpeed;
		if(AssignDrawScale)			a.DrawScale=NewDrawScale;
		a.Velocity.X+=VelocityVariance.X*frand();
		a.Velocity.Y+=VelocityVariance.Y*frand();
		a.Velocity.Z+=VelocityVariance.Z*frand();
		
		if(AssignCollisionRadius) 	a.CollisionRadius=NewCollisionRadius;
		if(AssignCollisionHeight)	a.CollisionHeight=NewCollisionHeight;
		if(AssignbCollideActors)		a.SetCollision(NewbCollideActors,,);
		if(AssignbBlockActors)		a.SetCollision(,bBlockActors,);
		if(AssignbBlockPlayers)		a.SetCollision(,,bBlockPlayers);
		if(AssignbCollideWorld)		a.bCollideWorld=NewbCollideWorld;
		if(AssignbProjTarget)		a.bProjTarget=NewbProjTarget;

		if(bTossDecoration && a.IsA('Decoration'))
			Decoration(a).Tossed();

		if ( TargetNearestPawn )
		{
			foreach allactors(class'Pawn',p)
			{
				break;
			}
			a.Target=p;
		}
		else if ( TargetActorName != '' )
		{
			TargetCount=0;

			foreach allactors( class'Actor', a2, TargetActorName )
			{
				Targets[TargetCount]=a2;
				TargetCount++;
				if ( TargetCount == ArrayCount(Targets) )
					break;
			}

			if ( TargetCount != 0 )
				a.Target = Targets[Rand(TargetCount)];
		}
	}

	if ( DestroyAfterSpawn )
		Destroy();

	return a;
}

function Touch( actor Other )
{
	if ( Other.tag == SpawnWhenInCollisionRadius )
		DoSpawn();
}

function Trigger(actor Other, pawn EventInstigator)
{
	if ( SpawnDelay == 0 )
		DoSpawn();
	else
	{
		SetTimer( SpawnDelay+(frand()*SpawnDelayVariance-SpawnDelayVariance/2), false );
		Disable( 'Trigger' );
	}
}

defaultproperties
{
     bDirectional=true
     Texture=Texture'Engine.S_TriggerSpawn'
}
