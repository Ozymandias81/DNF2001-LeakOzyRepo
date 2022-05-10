//=============================================================================
// dnDebrisMesh_Inflatable.			  September 22nd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebrisMesh_Inflatable expands dnDebris;

// Root of the inflatable mesh debris spawners. Normal sized chunks

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     SpawnNumber=0
     PrimeCount=3
     MaximumParticles=3
     Lifetime=4.000000
     LifetimeVariance=1.500000
     InitialVelocity=(Z=384.000000)
     MaxVelocityVariance=(X=640.000000,Y=640.000000,Z=384.000000)
     RealtimeAccelerationVariance=(X=3084.000000,Y=3084.000000,Z=1024.000000)
     LocalFriction=945.000000
     BounceElasticity=0.100000
     ParticlesCollideWithWorld=True
     DrawScaleVariance=0.150000
     StartDrawScale=0.500000
     EndDrawScale=0.500000
     RotationVariance3d=(Pitch=65535,Yaw=65535,Roll=65535)
     TriggerType=SPT_None
     LodMode=LOD_Disabled
     TimeWarp=0.750000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_FX.Gib_MetalA'
     LightDetail=LTD_NormalNoSpecular
}
