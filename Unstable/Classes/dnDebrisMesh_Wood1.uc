//=============================================================================
// dnDebrisMesh_Wood1. 				  September 21st, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Wood1 expands dnDebris;

// Root of the wood mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=3
     MaximumParticles=3
     Lifetime=5.000000
     LifetimeVariance=2.000000
     InitialVelocity=(Z=256.000000)
     MaxVelocityVariance=(X=512.000000,Y=512.000000,Z=384.000000)
     LocalFriction=128.000000
     BounceElasticity=0.625000
     Bounce=True
     ParticlesCollideWithWorld=True
     DrawScaleVariance=0.500000
     RotationVariance3d=(Pitch=65535,Yaw=65535,Roll=65535)
     TriggerType=SPT_None
     LodMode=LOD_Disabled
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_FX.Gib_WoodA'
     LightDetail=LTD_NormalNoSpecular
}
