//=============================================================================
// dnWall_Ice.                                                    created by AB
//=============================================================================
class dnWall_Ice expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallSmoke')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     MaximumParticles=3
     Lifetime=0.800000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=96.000000,Z=96.000000)
     BounceElasticity=0.250000
     LineStartColor=(R=232,G=142,B=113)
     LineEndColor=(R=255,G=253,B=176)
     Textures(0)=Texture't_generic.iceparticles.iceparticle1aRC'
     Textures(1)=Texture't_generic.iceparticles.iceparticle1bRC'
     Textures(2)=Texture't_generic.iceparticles.iceparticle1cRC'
     DrawScaleVariance=0.040000
     StartDrawScale=0.025000
     EndDrawScale=0.025000
     RotationVariance=32768.000000
     TriggerType=SPT_None
     PulseSeconds=0.001000
     AlphaEnd=0.000000
     bHidden=True
     TimeWarp=0.500000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
