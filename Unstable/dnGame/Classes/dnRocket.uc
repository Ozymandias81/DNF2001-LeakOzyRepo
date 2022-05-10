/*-----------------------------------------------------------------------------
	dnRocket
	Author: Everybody has raped this code.
-----------------------------------------------------------------------------*/
class dnRocket extends dnProjectile;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsweapn.dfx

var int NumExtraRockets;
var () class<SoftParticleSystem> TrailClass;
var () vector  TrailMountOrigin;
var () rotator TrailMountAngles;

var SoftParticleSystem Trail;

var () struct EAdditionalMountedActors
{ 
	var () class<actor> ActorClass;		// Class to spawn.
	var actor			ActorObject;	// Actual object instance.
	var () vector		MountOrigin;	// Translation mount offset.
	var () rotator		MountAngles;	// Angular mount offset.
} AdditionalMountedActors[4];

var () bool DestroyOnWaterTouch;

var () class<actor> SpawnOnWaterTouch[4];

simulated function PostBeginPlay()
{
	local vector Dir;
	local int i;
	local rotator r;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * 50;
	if ( Region.Zone.bWaterZone )
	{
		//bHitWater = True;
		Velocity = 0.6 * Velocity;
	}

	if ( (TrailClass != None) && (Trail == None) )
	{
		Trail = spawn(TrailClass);
		Trail.SetPhysics(PHYS_MovingBrush);
		Trail.AttachActorToParent(self, true, true);
		Trail.MountOrigin=TrailMountOrigin;
		Trail.MountAngles=TrailMountAngles;
	}

	for ( i=0; i<ArrayCount(AdditionalMountedActors); i++ )
	{
		if ( AdditionalMountedActors[i].ActorClass != none )
		{
			AdditionalMountedActors[i].ActorObject=spawn( AdditionalMountedActors[i].ActorClass );
			AdditionalMountedActors[i].ActorObject.SetPhysics( PHYS_MovingBrush );
			AdditionalMountedActors[i].ActorObject.AttachActorToParent( self, true, true );
			AdditionalMountedActors[i].ActorObject.MountOrigin=AdditionalMountedActors[i].MountOrigin;
			AdditionalMountedActors[i].ActorObject.MountAngles=AdditionalMountedActors[i].MountAngles;
			AdditionalMountedActors[i].ActorObject.bHidden = true;
		}	
	}

	SetTimer( 0.07, true, 2 );
}

simulated function Destroyed()
{
	local int i;

	if ( Trail != none )
	{
		Trail.Enabled = false;
		Trail.DestroyWhenEmpty = true;
		Trail.TriggerType = SPT_None;
		for ( i=0; i<8; i++ )
		{
			if ( Trail.AdditionalSpawn[i].SpawnActor != None )
			{
				SoftParticleSystem(Trail.AdditionalSpawn[i].SpawnActor).Enabled = false;
				SoftParticleSystem(Trail.AdditionalSpawn[i].SpawnActor).DestroyWhenEmpty = true;
				SoftParticleSystem(Trail.AdditionalSpawn[i].SpawnActor).TriggerType = SPT_None;
			}
		}
		Trail = none;
	}

	for ( i=0; i<ArrayCount(AdditionalMountedActors); i++ )
	{
		if ( AdditionalMountedActors[i].ActorObject != none )
		{
			AdditionalMountedActors[i].ActorObject.Destroy();
			AdditionalMountedActors[i].ActorObject = none;
		}
	}

	Super.Destroyed();
}

simulated function Timer( optional int TimerNum )
{
	local int i;

	// Delay a very short time before igniting effects (so they are properly mounted).
	if ( TimerNum == 2 )
	{
		if ( Trail != None )
		{
			Trail.Enabled = true;
			Trail.InitializeParticleSystem();
		}
		for( i=0; i<ArrayCount(AdditionalMountedActors); i++ )
		{
			if ( AdditionalMountedActors[i].ActorClass != none )
				AdditionalMountedActors[i].ActorObject.bHidden = false;
		}
		SetTimer( 0.0, false, 2 );
		return;
	}

	Super.Timer( TimerNum );
}

simulated function ZoneChange( Zoneinfo NewZone )
{
//	local waterring w;
	local int i;

	
	if ( !NewZone.bWaterZone )
		return;

	if ( Level.NetMode != NM_DedicatedServer )
	{
//		w = Spawn(class'WaterRing',,,,rot(16384,0,0));
		//w.DrawScale = 0.2;
//		w.RemoteRole = ROLE_None;
	}		
	for( i=0; i<ArrayCount(SpawnOnWaterTouch); i++ )
	{
		if( SpawnOnWaterTouch[i] != none )
			Spawn( SpawnOnWaterTouch[i] );
	}

	if ( DestroyOnWaterTouch )
	{
		Destroy();
		return;
	}
}

simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	if ( (Other != instigator) && !Other.IsA('Projectile') ) 
		Explode( HitLocation, Normal(HitLocation-Other.Location) );
}

defaultproperties
{
	 DamageClass=class'RocketDamage'
	 DamageRadius=220.0
     TrailClass=Class'dnParticles.dnRocketFX_Burn'
	 AdditionalMountedActors(0)=(ActorClass=Class'dnGame.dnWeaponFX',MountOrigin=(X=-12.000000,Z=-6.000000),MountAngles=(Yaw=-16384))
     ExplosionClass=Class'dnParticles.dnRocketFX_Explosion_Flash'
     speed=900.000000
     MaxSpeed=1600.000000
     Damage=100.000000
     MomentumTransfer=80000
     LodMode=LOD_Disabled
     LifeSpan=6.000000
     bBounce=True
     RemoteRole=ROLE_SimulatedProxy
     Mesh=DukeMesh'c_dnWeapon.rpg_rocket'
     bUnlit=True
     AmbientGlow=96
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=92
     LightRadius=6
     SoundRadius=64
     SoundVolume=255
     SoundPitch=100
     AmbientSound=Sound'dnsWeapn.missile.MBurn09'
	 bBurning=true
	 bShadowCast=true
	 bShadowReceive=true
}