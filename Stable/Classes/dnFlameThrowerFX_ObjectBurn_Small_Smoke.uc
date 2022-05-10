//=============================================================================
// dnFlameThrowerFX_ObjectBurn_Small_Smoke 	June 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlameThrowerFX_ObjectBurn_Small_Smoke expands dnFlameThrowerFX;

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.250000
     Lifetime=2.250000
     LifetimeVariance=0.500000
     InitialVelocity=(Z=16.000000)
     MaxVelocityVariance=(X=4.000000,Y=4.000000)
     RealtimeVelocityVariance=(Z=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp4aRC'
     DrawScaleVariance=0.050000
     StartDrawScale=0.075000
     EndDrawScale=0.250000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=4.000000
     PulseSecondsVariance=1.000000
     CollisionRadius=4.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     Style=STY_Modulated
     bUnlit=True
}
