//=============================================================================
// dnShellCaseMaster. (CDH)
// Master weapon shell casing particle system used by weapons
// Spawning actor must set its mesh to the correct shellcase mesh
//=============================================================================
class dnShellCaseMaster expands SoftParticleSystem;

defaultproperties
{
    spawnPeriod=0.000000
    MaximumParticles=50
    Lifetime=1.110000
    Bounce=True
    BounceElasticity=0.400000
    ParticlesCollideWithWorld=True
    Textures(0)=Texture'Engine.S_Actor'
    DrawType=DT_Mesh
    CollisionRadius=0.000000
    CollisionHeight=0.000000
    Enabled=False
	bHidden=True
	GroupID=152
	UpdateWhenNotVisible=True
	MaxDesiredActorLights=1
	CurrentDesiredActorLights=1
	SpawnCanDestroyOldest=True
}
