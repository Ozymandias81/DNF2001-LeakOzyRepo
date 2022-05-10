//=============================================================================
// dnRocketFX_RocketTrail.                    Created by Charlie Wiederhold August 30, 2000
//=============================================================================
class dnRocketFX_RocketTrail expands dnRocketFX;

// RPG Trail effect
// Does NOT do damage. 
// Spawns the residual smoke part of the effect

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.050000
     MaximumParticles=32
     Lifetime=1.400000
     LifetimeVariance=0.200000
     RelativeSpawn=True
     InitialVelocity=(X=-64.000000,Y=0.000000,Z=128.000000)
     MaxVelocityVariance=(X=-64.000000,Y=0.000000,Z=128.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.750000
     StartDrawScale=0.500000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=0.125000
     TriggerType=SPT_Enable
     AlphaEnd=0.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
