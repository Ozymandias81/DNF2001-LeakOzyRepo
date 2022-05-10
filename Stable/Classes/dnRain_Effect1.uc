//=============================================================================
// dnRain_Effect1.
//=============================================================================

// Cole

class dnRain_Effect1 expands dnRainFX;

defaultproperties
{
     GroupID=66
     SpawnNumber=2
     SpawnPeriod=0.005000
     PrimeTime=0.100000
     MaximumParticles=1000
     Lifetime=1.000000
     SpawnAtHeight=True
     InitialVelocity=(X=75.000000,Z=-400.000000)
     InitialAcceleration=(Z=1.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     RealtimeVelocityVariance=(Z=1.000000)
     UseZoneGravity=False
     UseLines=True
     LineStartColor=(R=169,G=169,B=175)
     LineEndColor=(R=169,G=169,B=175)
     Textures(0)=Texture't_generic.Rain.genrain1RC'
     Textures(1)=Texture't_generic.Rain.genrain2RC'
     Textures(2)=Texture't_generic.Rain.genrain5RC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.150000
     EndDrawScale=0.250000
     UpdateWhenNotVisible=True
     VisibilityRadius=8000.000000
     VisibilityHeight=8000.000000
     bHidden=True
     CollisionRadius=768.000000
     CollisionHeight=64.000000
     Style=STY_Translucent
}
