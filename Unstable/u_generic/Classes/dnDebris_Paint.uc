//=============================================================================
// dnDebris_Paint.
//=============================================================================
class dnDebris_Paint expands dnDebris_Glass1;

#exec OBJ LOAD FILE=..\textures\t_generic.dtx

defaultproperties
{
     PrimeCount=20
     MaximumParticles=20
     MaxVelocityVariance=(X=920.000000,Y=920.000000,Z=292.000000)
     MaxAccelerationVariance=(X=100.000000,Y=100.000000,Z=100.000000)
     DieOnBounce=True
     ParticlesCollideWithActors=True
     UseLines=True
     ConstantLength=True
     LineStartColor=(R=150,G=150,B=150)
     LineEndColor=(R=147,G=147,B=147)
     LineStartWidth=4.000000
     LineEndWidth=3.000000
     Textures(0)=Texture't_generic.Paint.paintdrop3RC'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     Textures(4)=None
     Textures(5)=None
     DrawScaleVariance=1.000000
     StartDrawScale=16.000000
     EndDrawScale=24.000000
     SpawnOnBounceChance=10000.000000
     SpawnOnDeathChance=10000.000000
     SpawnOnDeath=Class'U_Generic.Paintsplatter'
}
