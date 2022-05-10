//=============================================================================
// G_SinkFaucet.                              Created by Matt Wood Sept 3, 2000
//=============================================================================
class G_SinkFaucet expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Smoke'
     FragType(1)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebris_Metal1_Small'
     IdleAnimations(0)=offloop
     TriggerRetriggerDelay=0.400000
     TriggeredSpawn(0)=(ActorClass=Class'dnParticles.dnSinkFaucetWater',MountMeshItem=SpigotWater,SpawnOnce=True,TriggerWhenTriggered=True)
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_SinkFaucet_Broken')
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=TurnOn,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOnSequences(1)=(PlaySequence=onloop,Loop=True,Noise=Sound'a_generic.Water.SinkSmallLp1',NoiseIsAmbient=True,Radius=12.000000)
     ToggleOffSequences(0)=(PlaySequence=turnoff,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOffSequences(1)=(PlaySequence=offloop,Loop=True)
     ItemName="Faucet"
     bTakeMomentum=False
     bUseTriggered=True
     CollisionRadius=8.000000
     CollisionHeight=4.000000
     bCollideWorld=False
     Texture=Texture'm_generic.metalsink1RC'
     Mesh=DukeMesh'c_generic.SinkFaucet'
}
