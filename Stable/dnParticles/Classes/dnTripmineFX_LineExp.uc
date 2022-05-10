//=============================================================================
// dnTripmineFX_LineExp.            Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_LineExp expands dnTripmineFX;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the line explosion effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=16
     PrimeTimeIncrement=0.000000
     MaximumParticles=0
     Lifetime=1.500000
     RelativeSpawn=True
     InitialVelocity=(X=16.000000,Z=-64.000000)
     MaxVelocityVariance=(X=24.000000,Y=48.000000,Z=48.000000)
     Textures(0)=Texture't_explosionFx.explosions.X_fi_001'
     DieOnLastFrame=True
     StartDrawScale=0.750000
     EndDrawScale=1.500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance3d=(Pitch=65535,Yaw=65535,Roll=65535)
     PulseSeconds=0.000000
     AlphaEnd=0.000000
     CollisionRadius=1.250000
     CollisionHeight=192.000000
}
