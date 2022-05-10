//=============================================================================
// dnFlamethrowerFX_Shrunk_PersonBurn_Footstep_Smoke 	June 27th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_Shrunk_PersonBurn_Footstep_Smoke expands dnFlamethrowerFX_Shrunk;

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.250000
     Lifetime=2.250000
     LifetimeVariance=0.500000
     InitialVelocity=(Z=4.000000)
     MaxVelocityVariance=(X=2.000000,Y=2.000000)
     RealtimeVelocityVariance=(Z=10.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp4aRC'
     DrawScaleVariance=0.006250
     StartDrawScale=0.020000
     EndDrawScale=0.040000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=3.000000
     PulseSecondsVariance=0.750000
     CollisionRadius=1.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     Style=STY_Modulated
     bUnlit=True
     bIgnoreBList=True
}
