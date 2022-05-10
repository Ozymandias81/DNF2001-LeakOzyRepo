//=============================================================================
// dnAcidRoundFX.                   Created by Charlie Wiederhold June 19, 2000
//=============================================================================
class dnAcidRoundFX expands SoftParticleSystem;

// Shotgun acid round effect.
// Does NOT do damage. 
// Spawns an individual acid round cloud.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var float AmbientTime;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Enable( 'Tick' );
}

function Tick( float Delta )
{
	Super.Tick( Delta );

	AmbientTime += Delta;
	if ( AmbientTime > 2.5 )
	{
		AmbientSound = None;
		Disable( 'Tick' );
	}
}

defaultproperties
{
	 AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnAcidRoundFX_Splash')
     Enabled=false
     DestroyWhenEmpty=true
     SpawnPeriod=0.200000
     PrimeCount=1
     PrimeTime=0.100000
     PrimeTimeIncrement=0.100000
     MaximumParticles=12
     Lifetime=2.000000
     LifetimeVariance=0.500000
     RelativeSpawn=true
     InitialVelocity=(X=8.000000,Z=20.000000)
     MaxVelocityVariance=(X=6.000000,Y=6.000000,Z=12.000000)
     MaxAccelerationVariance=(Z=12.000000)
     UseZoneGravity=false
     UseZoneVelocity=false
     Textures(0)=Texture't_generic.Smoke.greensmoke1aRC'
     StartDrawScale=0.100000
     EndDrawScale=0.200000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=true
     TriggerOnSpawn=true
     TriggerType=SPT_Pulse
     PulseSeconds=2.000000
     Style=STY_Translucent
     bUnlit=true
     CollisionRadius=0.000000
     CollisionHeight=0.000000
	 AmbientSound=sound'dnsWeapn.Shotgun.SGAcid15'
	 SoundRadius=64
	 SoundVolume=32
}
