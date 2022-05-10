//=============================================================================
// dnMultibombFX_Explosion_LightDebris.                  June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnMultibombFX_Explosion_LightDebris expands dnMultibombFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=45
     MaximumParticles=45
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=512.000000)
     MaxVelocityVariance=(X=2048.000000,Y=2048.000000,Z=1024.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     ParticlesCollideWithWorld=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnMultibombFX_Explosion_LightDebris_White')
     AdditionalSpawn(1)=(SpawnClass=Class'dnMultibombFX_Explosion_HeavyDebris')
     AdditionalSpawn(2)=(SpawnClass=Class'dnMultibombFX_Explosion_Sparks')
     AdditionalSpawn(3)=(SpawnClass=Class'dnMultibombFX_Explosion_Embers')
     Textures(0)=Texture't_generic.bloodgibs.genbloodgib10RC'
     Textures(1)=Texture't_generic.bloodgibs.genbloodgib6RC'
     Textures(2)=Texture't_generic.bloodgibs.genbloodgib7RC'
     Textures(3)=Texture't_generic.bloodgibs.genbloodgib8RC'
     Textures(4)=Texture't_generic.bloodgibs.genbloodgib9RC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.050000
     EndDrawScale=0.050000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaRampMid=0.850000
     TimeWarp=0.750000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
     bUnlit=True
     bIgnoreBList=True
}
