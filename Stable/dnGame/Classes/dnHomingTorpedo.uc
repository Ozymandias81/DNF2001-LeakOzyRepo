//=============================================================================
// dnHomingTorpedo.
//=============================================================================
class dnHomingTorpedo expands dnHomingRocket;

#exec OBJ LOAD FILE=..\meshes\c_dnweapon.dmx

var () class<SoftParticleSystem> SplashEffect;
var SoftParticleSystem MyTrail;

function PostBeginPlay()
{
	MyTrail = Spawn( class'dnHTorpedo1trail', self );
	MyTrail.AttachActorToParent( self, true, true );
	MyTrail.SetPhysics( PHYS_MovingBrush );
	MyTrail.MountType = MOUNT_Actor;

	super.PostBeginPlay();
	Target = GetTarget();
}

function Actor GetTarget()
{
	local actor a;

	foreach allactors( class'Actor', A )
	{
		if( A.IsA( 'Mover' ) )
			return A;
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Explode( Location, normal( Location ) );
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
    // Only explode when we are in water
    if (Region.Zone.bWaterZone ) 
    {
    	if ( (Other != instigator) && !Other.IsA('Projectile') && !Other.IsA( 'AIJetski' ) ) 
	    	Explode( HitLocation, Normal(HitLocation-Other.Location) );
    }
}

function Timer(optional int TimerNum)
{
	// If I'm in a water zone, I've got full control:
	if ( Region.Zone.bWaterZone )
		Super.Timer();
	else
	{
		// Otherwise, just let normal physics take over
		if ( ApplyGravity )
		{
			Acceleration = Region.Zone.ZoneGravity;
		}
	}
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	// Am I entereing or leaving water?
	if ( Region.Zone.bWaterZone != NewZone.bWaterZone )
		if ( SplashEffect != none )
			Spawn ( SplashEffect,,,,rot(0,0,0) );
}

defaultproperties
{
    bProjTarget=true
	CollisionHeight=3
	CollisionRadius=18
    Mesh=DukeMesh'c_dnWeapon.missle_jetski'
	DrawScale=0.850000	
    LifeSpan=60.000000
	ApplyGravity=true
	TurnScaler=3.000
    Speed=300
    MaxSpeed=300
}