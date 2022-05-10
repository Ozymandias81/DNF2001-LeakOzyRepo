//=============================================================================
// dnSmokeEffect3.	Keith Schuler September 26, 2000
// White smoke for a few seconds. Used for sprinklers in Penthouse
//=============================================================================
class dnSmokeEffect3 expands dnSmokeEffect;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.150000
     MaximumParticles=0
     Lifetime=3.000000
     LifetimeVariance=0.250000
     InitialVelocity=(X=0.000000,Z=15.000000)
     InitialAcceleration=(X=0.000000,Z=0.000000)
     MaxVelocityVariance=(X=90.000000,Y=90.000000,Z=0.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     DrawScaleVariance=0.000000
     StartDrawScale=0.250000
     EndDrawScale=0.750000
     RotationVelocityMaxVariance=2.000000
     TriggerOnSpawn=True
     PulseSeconds=30.000000
     PulseSecondsVariance=2.000000
     AlphaStart=1.000000
     AlphaEnd=1.000000
     VisibilityRadius=768.000000
     VisibilityHeight=256.000000
     bHidden=False
     CollisionRadius=80.000000
     CollisionHeight=16.000000
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
}
