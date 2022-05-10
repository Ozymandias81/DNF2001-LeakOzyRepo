//=============================================================================
// dnRobotShockFX_Spawner1. 				Feb 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRobotShockFX_Spawner1 expands dnRobotShockFX;

// Spawner for the shock effects

#exec OBJ LOAD FILE=..\Textures\t_test.dtx

defaultproperties
{
     AdditionalSpawn(0)=(Mount=True)
     SpawnPeriod=0.250000
     Lifetime=0.500000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Connected=True
     LineStartColor=(R=128,G=255,B=255)
     LineEndColor=(R=128,G=255,B=255)
     Textures(0)=Texture't_test.smokeeffects.charlieeffecttest1BC'
     StartDrawScale=0.400000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     AlphaStart=0.000000
     bBurning=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
