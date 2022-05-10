//=============================================================================
// dnDebris_PokerChips_Black. 			November 3rd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_PokerChips_Black expands dnDebris;

// Shower of black poker chips

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=75
     MaximumParticles=75
     Lifetime=2.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=480.000000,Y=480.000000,Z=256.000000)
     LocalFriction=128.000000
     BounceElasticity=0.750000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.pokerchipspin.blakchipspin1aR'
     Textures(1)=Texture't_generic.pokerchipspin.blakchipspin1bR'
     Textures(2)=Texture't_generic.pokerchipspin.blakchipspin1cR'
     StartDrawScale=0.040000
     EndDrawScale=0.040000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     TimeWarp=0.825000
     Style=STY_Masked
     bUnlit=True
}
