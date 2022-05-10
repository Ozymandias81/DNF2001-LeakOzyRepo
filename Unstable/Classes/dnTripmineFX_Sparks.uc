//=============================================================================
// dnTripmineFX_Sparks.             Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_Sparks expands dnTripmineFX;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the spark effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=12
     PrimeTime=0.100000
     PrimeTimeIncrement=0.100000
     MaximumParticles=32
     Lifetime=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=1024.000000,Z=128.000000)
     InitialAcceleration=(X=-1024.000000)
     MaxVelocityVariance=(X=512.000000,Y=1024.000000,Z=1024.000000)
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=255,G=255,B=255)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=1.500000
     LineEndWidth=1.500000
     Textures(0)=Texture't_generic.Sparks.spark1RC'
     Textures(1)=Texture't_generic.Sparks.spark2RC'
     Textures(2)=Texture't_generic.Sparks.spark3RC'
     Textures(3)=Texture't_generic.Sparks.spark4RC'
     StartDrawScale=32.000000
     EndDrawScale=32.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.400000
     Style=STY_Translucent
     bIgnoreBList=True
}
