//=============================================================================
// dnFireworks2. ( AHB3d )
//=============================================================================
class dnFireworks2 expands dnFireworks;

// Launching Firwork, explodes in the air upward
// Does NOT do damage.
// Uses dnFireworks2a and dnFireworks2b

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnOnDestruction(0)=(SpawnClass=Class'dnParticles.dnFireworks2a')
     SpawnPeriod=0.020000
     PrimeTime=0.200000
     PrimeTimeIncrement=0.100000
     Lifetime=0.500000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000)
     BounceElasticity=0.000000
     Textures(0)=Texture't_generic.lensflares.bluelensflare1B'
     StartDrawScale=0.400000
     EndDrawScale=0.300000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=2.000000
     PulseSecondsVariance=0.100000
     bStasis=True
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     bUnlit=True
     VisibilityRadius=16384.000000
     VisibilityHeight=16384.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBounce=True
     bFixedRotationDir=True
     Mass=5.000000
     DestroyOnDismount=True
}
