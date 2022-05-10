//=============================================================================
// dnElectricalTrail_Sparks.
//=============================================================================
class dnElectricalTrail_Sparks expands dnMissileTrail;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnElectricalTrail_LightningA',Mount=True)
     SpawnPeriod=0.009000
     Lifetime=0.600000
     LifetimeVariance=0.200000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=-10.000000)
     MaxAccelerationVariance=(Z=-10.000000)
     RealtimeVelocityVariance=(Z=-10.000000)
     UseZoneGravity=False
     Textures(0)=FireTexture'm_dnWeapon.ElectricalProj1_MW'
     DrawScaleVariance=0.300000
     StartDrawScale=0.600000
     EndDrawScale=0.300000
     RotationInitial=25000.000000
     RotationVariance=35000.000000
     TriggerType=SPT_Disable
     AlphaStart=0.500000
     AlphaMid=0.750000
     AlphaEnd=0.300000
     AlphaRampMid=0.300000
     VisibilityRadius=8000.000000
     VisibilityHeight=8000.000000
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     Style=STY_Translucent
}
