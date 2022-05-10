//=============================================================================
// dnParachuteBomb (NJS)
//=============================================================================
class dnParachuteBomb extends dnProjectile;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

var () float	ParachuteOpenVelocityDivisor;
var () float	ParachuteOpenGravityDivisor;
var () float	PreOpenDelay;
var    float	SpawnTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Acceleration = Region.Zone.ZoneGravity;
	PlayAnim( 'parachute_in' );
	SpawnTime = Level.TimeSeconds;
}

function AnimEnd()
{
	if ( AnimSequence == 'parachute_in' )
	{
		if ( SpawnTime + PreOpenDelay <= Level.TimeSeconds )
			PlayAnim( 'Open' );
		else
			PlayAnim( 'parachute_in' );
	}
	else if ( AnimSequence == 'Open' )
	{
		PlayAnim( 'Idle' );
		Velocity /= ParachuteOpenVelocityDivisor;
		Acceleration = Region.Zone.ZoneGravity / ParachuteOpenGravityDivisor;

	}
	else if ( AnimSequence == 'Idle' )
	{
		PlayAnim( 'Idle' );
	}
}

simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	if ( (Other != instigator) && !Other.IsA('Projectile') ) 
		Explode( HitLocation, Normal(HitLocation-Other.Location) );
}

defaultproperties
{
     speed=900.0
     MaxSpeed=1600.0
     Damage=75.0
	 DamageRadius=220.0
	 DamageClass=class'ExplosionDamage'
     MomentumTransfer=80000
//     ExplosionDecal=Class'Botpack.BlastMark'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     Mesh=DukeMesh'c_dnWeapon.parachute_bomb'
     AmbientGlow=96
     bUnlit=True
     SoundRadius=14
     SoundVolume=255
     SoundPitch=100
//     AmbientSound=Sound'Botpack.RocketLauncher.RocketFly1'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightRadius=6
     bBounce=True
	 ParachuteOpenVelocityDivisor=20
	 ParachuteOpenGravityDivisor=8
	 PreOpenDelay=0.4
}
