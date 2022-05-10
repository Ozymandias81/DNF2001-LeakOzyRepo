//=============================================================================
// dnDebrisMesh_Glass1a_Bigger.	August 9, 2001
// Keith Schuler
// Added for the purpose of being spawned with TriggerSpawn by a mapper, instead of
// by the destruction of a decoration. Also made much bigger
//=============================================================================
class dnDebrisMesh_Glass1a_Bigger expands dnDebrisMesh_Glass1a;

defaultproperties
{
     PrimeCount=10
     MaximumParticles=10
     Lifetime=20.000000
     LifetimeVariance=5.000000
     BounceElasticity=0.350000
     StartDrawScale=3.000000
     EndDrawScale=3.000000
     Style=STY_Translucent
     Texture=Texture't_generic.Glass.brokenglass5RC'
     Skin=Texture't_generic.Glass.brokenglass5RC'
     bUnlit=True
}
