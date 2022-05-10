//=============================================================================
// dnGrenadeFX_Shrunk_Explosion_LightDebris.                  June 30th, 2000 - Charlie Wiederhold
//=============================================================================
class dnGrenadeFX_Shrunk_Explosion_LightDebris expands dnGrenadeFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=25
     MaximumParticles=25
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=768.000000)
     MaxVelocityVariance=(X=1000.000000,Y=1000.000000,Z=512.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     ParticlesCollideWithWorld=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnGrenadeFX_Shrunk_Explosion_LightDebris_White')
     AdditionalSpawn(1)=(SpawnClass=Class'dnGrenadeFX_Shrunk_Explosion_HeavyDebris')
     AdditionalSpawn(2)=(SpawnClass=Class'dnGrenadeFX_Shrunk_Explosion_Embers')
     Textures(0)=Texture't_generic.bloodgibs.genbloodgib10RC'
     Textures(1)=Texture't_generic.bloodgibs.genbloodgib6RC'
     Textures(2)=Texture't_generic.bloodgibs.genbloodgib7RC'
     Textures(3)=Texture't_generic.bloodgibs.genbloodgib8RC'
     Textures(4)=Texture't_generic.bloodgibs.genbloodgib9RC'
     DrawScaleVariance=0.0250000
     StartDrawScale=0.03250000
     EndDrawScale=0.03250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     AlphaMid=1.000000
     AlphaRampMid=0.850000
     TimeWarp=0.750000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Masked
     bUnlit=True
     bIgnoreBList=True
}
