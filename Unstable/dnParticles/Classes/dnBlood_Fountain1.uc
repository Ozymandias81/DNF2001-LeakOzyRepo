//=============================================================================
// dnBlood_Fountain1. (CDH)
//=============================================================================
class dnBlood_Fountain1 expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     BSPOcclude=False
     GroupID=999
     SpawnPeriod=0.005000
     MaximumParticles=12
     Lifetime=2.000000
     LifetimeVariance=0.500000
     RelativeSpawn=True
     SpawnAtRadius=True
     InitialVelocity=(Z=200.000000)
     MaxVelocityVariance=(X=80.000000,Y=80.000000)
     Bounce=True
     DieOnBounce=True
     ParticlesCollideWithWorld=True
     //Textures(0)=Texture't_generic.blooddrops.blooddrop2aRC'
     //Textures(1)=Texture't_generic.blooddrops.blooddrop2bRC'
     //Textures(2)=Texture't_generic.blooddrops.blooddrop2cRC'
     //Textures(3)=Texture't_generic.blooddrops.blooddrop2dRC'
     //Textures(4)=Texture't_generic.blooddrops.blooddrop2eRC'
     //Textures(5)=Texture't_generic.blooddrops.blooddrop2fRC'
     //Textures(6)=Texture't_generic.bloodsplats.bloodsplat1aRC'
     //Textures(7)=Texture't_generic.bloodsplats.bloodsplat2aRC'
     StartDrawScale=0.100000
     EndDrawScale=0.400000
     UpdateWhenNotVisible=True
	 bHidden=true
     LifeSpan=10.000000
     Style=STY_None
     CollisionRadius=1.000000
}
