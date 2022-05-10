//=============================================================================
// dnDebrisMesh_Metal1.  			  September 20th, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Metal1 expands dnDebris;

// Root of the metal mesh debris spawners. Normal sized chunks

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
     InitialVelocity=(Z=316.000000)
     MaxVelocityVariance=(X=640.000000,Y=640.000000,Z=316.000000)
     LocalFriction=256.000000
     BounceElasticity=0.325000
     Bounce=True
     ParticlesCollideWithWorld=True
     DrawScaleVariance=0.500000
     RotationVariance3d=(Pitch=65535,Yaw=65535,Roll=65535)
     TriggerType=SPT_None
     LodMode=LOD_Disabled
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_FX.Gib_MetalA'
     LightDetail=LTD_NormalNoSpecular
}
