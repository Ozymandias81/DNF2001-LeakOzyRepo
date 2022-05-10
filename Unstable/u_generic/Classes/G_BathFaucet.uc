//=============================================================================
// G_BathFaucet.                              Created by Matt Wood Sept 3, 2000
//=============================================================================
class G_BathFaucet expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

defaultproperties
{
     DamageThreshold=50
     FragType(1)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1_Small'
     IdleAnimations(0)=offloop
     TriggerRetriggerDelay=0.800000
     TriggeredSpawn(0)=(ActorClass=Class'dnParticles.dnBathFaucetWater',MountMeshItem=SpigotWater,SpawnOnce=True,TriggerWhenTriggered=True)
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_BathFaucet_Broken')
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=turnonA,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOnSequences(1)=(PlaySequence=turnonB,Noise=Sound'a_generic.Water.SinkLargeLp1',NoiseIsAmbient=True,Radius=16.000000)
     ToggleOnSequences(2)=(PlaySequence=onloop,Loop=True)
     ToggleOffSequences(0)=(PlaySequence=turnoff,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOffSequences(1)=(PlaySequence=offloop,Loop=True)
     PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     ItemName="Faucet"
     bTakeMomentum=False
     bUseTriggered=True
     CollisionRadius=17.000000
     CollisionHeight=17.000000
     bCollideWorld=False
     Texture=Texture'm_generic.metalsink1RC'
     Mesh=DukeMesh'c_generic.BathFaucetA'
}
