//=============================================================================
// dnRocketFX_Burn.               Created by Charlie Wiederhold August 30, 2000
//=============================================================================
class dnRocketFX_Burn expands dnRocketFX;

// RPG Trail effect
// Does NOT do damage. 
// Spawns the hot part of the residual smoke effect 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

simulated function PostBeginPlay()
{
	Super(ParticleSystem).PostBeginPlay();

	PreviousSystem=none;
	NextSystem=Level.ParticleSystems;
	Level.ParticleSystems=self;
}

simulated function PostNetInitial()
{
	Super(ParticleSystem).PostNetInitial();
}

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     LifetimeVariance=0.200000
     RelativeSpawn=True
     UseZoneGravity=False
     UseZoneVelocity=False
     DrawScaleVariance=0.750000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Enable
     AlphaEnd=0.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
     AdditionalSpawn(0)=(Mount=True,MountOrigin=(Y=5.500000,Z=-12.000000))
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnRocketFX_RocketTrail',Mount=True)
     SpawnPeriod=0.025000
     MaximumParticles=10
     Lifetime=0.150000
     InitialVelocity=(X=256.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000)
     Textures(0)=Texture't_generic.particle_efx.pflare4ABC'
     StartDrawScale=4.000000
     EndDrawScale=8.000000
     TriggerAfterSeconds=0.075000
     bBurning=True
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     DestroyOnDismount=True
}
