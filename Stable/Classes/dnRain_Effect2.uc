//=============================================================================
// dnRain_Effect2.
//=============================================================================
class dnRain_Effect2 expands dnRainFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     GroupID=66
     SpawnNumber=30
     PrimeCount=40
     PrimeTime=0.250000
     MaximumParticles=610
     Lifetime=2.000000
     SpawnAtHeight=True
     InitialVelocity=(X=75.000000,Z=-675.000000)
     InitialAcceleration=(Z=1.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     RealtimeVelocityVariance=(Z=1.000000)
     UseZoneGravity=False
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=72,G=72,B=72)
     LineEndColor=(R=69,G=69,B=69)
     LineStartWidth=1.100000
     LineEndWidth=1.100000
     Textures(0)=Texture't_generic.Rain.genrain1RC'
     DrawScaleVariance=25.000000
     StartDrawScale=0.000001
     EndDrawScale=30.000000
     UpdateWhenNotVisible=True
     VisibilityRadius=8000.000000
     VisibilityHeight=8000.000000
     bHidden=True
     CollisionRadius=768.000000
     CollisionHeight=128.000000
     Style=STY_Translucent
}
