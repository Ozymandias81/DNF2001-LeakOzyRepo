//=============================================================================
// dnRocketFX_NukeTrail. 				   June 13th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRocketFX_NukeTrail expands dnRocketFX;

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     LifetimeVariance=0.200000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
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
     SpawnPeriod=0.012500
     MaximumParticles=0
     Lifetime=2.500000
     RelativeSpawn=True
     InitialVelocity=(X=32.000000,Y=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=32.000000,Y=0.000000,Z=0.000000)
     DrawScaleVariance=0.125000
     StartDrawScale=0.325000
     EndDrawScale=0.325000
     AlphaMid=1.000000
     bUseAlphaRamp=True
}
