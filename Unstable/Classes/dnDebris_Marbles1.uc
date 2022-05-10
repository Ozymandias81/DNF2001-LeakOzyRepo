//=============================================================================
// dnDebris_Marbles1.                 September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_Marbles1 expands dnDebris;

// Root of the marble debris spawners. Good bit of marbles.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=45
     MaximumParticles=45
     Lifetime=3.000000
     LifetimeVariance=1.000000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=256.000000)
     LocalFriction=128.000000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.marbles.marble10RC'
     Textures(1)=Texture't_generic.marbles.marble11RC'
     Textures(2)=Texture't_generic.marbles.marble1RC'
     Textures(3)=Texture't_generic.marbles.marble2RC'
     Textures(4)=Texture't_generic.marbles.marble3RC'
     Textures(5)=Texture't_generic.marbles.marble4RC'
     Textures(6)=Texture't_generic.marbles.marble5RC'
     Textures(7)=Texture't_generic.marbles.marble6RC'
     Textures(8)=Texture't_generic.marbles.marble7RC'
     Textures(9)=Texture't_generic.marbles.marble8RC'
     Textures(10)=Texture't_generic.marbles.marble9RC'
     StartDrawScale=0.100000
     EndDrawScale=0.100000
     RotationVariance=65535.000000
     TriggerType=SPT_None
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     Style=STY_Masked
}
