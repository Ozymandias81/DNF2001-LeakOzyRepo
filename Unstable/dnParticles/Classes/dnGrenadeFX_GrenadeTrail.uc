//=============================================================================
// dnGrenadeFX_GrenadeTrail.                    Created by Charlie Wiederhold June 28th, 2000
//=============================================================================
class dnGrenadeFX_GrenadeTrail expands dnGrenadeFX;

// RPG Trail effect
// Does NOT do damage. 
// Spawns the residual smoke part of the effect

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.050000
     MaximumParticles=32
     Lifetime=1.500000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     InitialVelocity=(X=-32.000000,Z=64.000000)
     MaxVelocityVariance=(X=-32.000000,Y=0.000000,Z=64.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     DrawScaleVariance=0.250000
     StartDrawScale=0.100000
     EndDrawScale=0.750000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.000000
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
     bUnlit=True
     bIgnoreBList=True
}
