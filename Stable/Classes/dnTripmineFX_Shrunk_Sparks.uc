//=============================================================================
// dnTripmineFX_Shrunk_Sparks.             Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_Shrunk_Sparks expands dnTripmineFX_Shrunk;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the spark effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=8
     PrimeTime=0.100000
     PrimeTimeIncrement=0.100000
     MaximumParticles=24
     Lifetime=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=512.000000,Z=96.000000)
     InitialAcceleration=(X=-768.000000)
     MaxVelocityVariance=(X=384.000000,Y=768.000000,Z=768.000000)
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=255,G=255,B=255)
     LineEndColor=(R=255,G=255,B=255)
     LineStartWidth=1.010000
     LineEndWidth=1.010000
     Textures(0)=Texture't_generic.Sparks.spark1RC'
     Textures(1)=Texture't_generic.Sparks.spark2RC'
     Textures(2)=Texture't_generic.Sparks.spark3RC'
     Textures(3)=Texture't_generic.Sparks.spark4RC'
     StartDrawScale=24.000000
     EndDrawScale=24.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.400000
     Style=STY_Translucent
     bIgnoreBList=True
}
