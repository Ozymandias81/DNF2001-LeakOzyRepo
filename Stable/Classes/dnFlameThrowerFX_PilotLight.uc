//=============================================================================
// dnFlameThrowerFX_PilotLight.
//=============================================================================
class dnFlameThrowerFX_PilotLight expands dnFlameThrowerFX;

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.010000
     PrimeCount=1
     PrimeTimeIncrement=0.010000
     MaximumParticles=30
     Lifetime=0.200000
     LifetimeVariance=0.002000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=50.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=2.000000,Z=2.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.LensFlares.blu_glow1'
     StartDrawScale=0.125000
     EndDrawScale=0.100000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     PulseSeconds=0.100000
     AlphaVariance=0.250000
     AlphaStart=0.500000
     AlphaMid=0.500000
     AlphaEnd=0.000000
     bHidden=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     bUnlit=True
}
