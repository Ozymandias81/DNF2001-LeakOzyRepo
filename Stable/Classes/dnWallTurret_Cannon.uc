//=============================================================================
// dnWallTurret_Cannon.
//=============================================================================

// Cole

class dnWallTurret_Cannon expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=0.400000
     RelativeSpawn=True
     SpawnAtRadius=True
     InitialVelocity=(X=500.000000,Z=0.000000)
     MaxVelocityVariance=(X=1500.000000,Y=1500.000000)
     MaxAccelerationVariance=(X=200.000000,Y=200.000000)
     RealtimeVelocityVariance=(X=1500.000000,Y=1500.000000)
     Textures(0)=Texture't_generic.metalshards.metalshard1aRC'
     Textures(1)=Texture't_generic.metalshards.metalshard1bRC'
     Textures(2)=Texture't_generic.metalshards.metalshard1cRC'
     Textures(3)=Texture't_generic.metalshards.metalshard1dRC'
     StartDrawScale=0.190000
     EndDrawScale=0.000001
     AlphaEnd=0.000000
     RotationVariance=32768.000000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     Style=STY_Masked
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     TimeWarp=0.500000
}
