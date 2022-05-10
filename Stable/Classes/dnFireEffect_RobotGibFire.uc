//=============================================================================
// dnFireEffect_RobotGibFire. 			   March 7th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFireEffect_RobotGibFire expands dnFireEffect;

// Fire effect for the gibs of a destroyed metal creature
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.250000
     Lifetime=0.000000
     InitialVelocity=(X=0.000000,Y=0.000000,Z=0.000000)
     InitialAcceleration=(Y=0.000000,Z=0.000000)
     DieOnLastFrame=True
     DrawScaleVariance=0.250000
     StartDrawScale=0.500000
     EndDrawScale=0.625000
     AlphaEnd=0.000000
     SystemAlphaScaleVelocity=-0.400000
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Disable
     CollisionRadius=16.000000
     CollisionHeight=16.000000
}
