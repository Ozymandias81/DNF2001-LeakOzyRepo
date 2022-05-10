//=============================================================================
// dnTripmineFX_LineSmoke.          Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_LineSmoke expands dnTripmineFX;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the line smoke effect.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=16
     SpawnPeriod=0.300000
     PrimeTimeIncrement=0.000000
     MaximumParticles=16
     Lifetime=6.000000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=8.000000,Z=-16.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=8.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.500000
     EndDrawScale=1.250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.400000
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     CollisionRadius=16.000000
     CollisionHeight=384.000000
     bIgnoreBList=True
}
