//=============================================================================
// dnGasMineFX_Spawner. 				November 1st, 2000 - Charlie Wiederhold
//=============================================================================
class dnGasMineFX_Spawner expands dnGasMineFX;

// Creates the jet effect of gas coming out of a nozel
// Spawns the main gas cloud that hangs around until it is turned off

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     MaximumParticles=8
     Lifetime=1.000000
     RelativeSpawn=True
     InitialVelocity=(X=96.000000,Z=48.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000,Z=16.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.greensmoke1aRC'
     StartDrawScale=0.000000
     EndDrawScale=0.750000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.750000
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
