//=============================================================================
// dnWallSmoke.                                                   created by AB 
//=============================================================================
class dnWallSmoke expands dnWallFX;

// General smoke effect class.
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.050000
     PrimeCount=1
     PrimeTimeIncrement=0.100000
     Lifetime=0.750000
     LifetimeVariance=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=64.000000,Z=64.000000)
     LocalFriction=1024.000000
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.050000
     EndDrawScale=0.200000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.175000
     PulseSecondsVariance=0.075000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.900000
     bHidden=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Modulated
     bUnlit=True
}
