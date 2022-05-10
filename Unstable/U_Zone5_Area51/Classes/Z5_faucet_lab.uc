//=============================================================================
// Z5_faucet_lab.
//=============================================================================
class Z5_faucet_lab expands Zone5_Area51;

///=================================  Nov 24th, Matt Wood

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\m_zone5_area51.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx

// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(6)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(7)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     TriggeredSpawn(0)=(ActorClass=Class'dnParticles.dnLabFaucetWater',MountMeshItem=SpigotWater,SpawnOnce=True,TriggerWhenTriggered=True)
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Zone5_Area51.Z5_faucet_lab_Broken')
     PendingSequences(0)=(PlaySequence=faucetidleoff)
     CurrentPendingSequence=1
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=turnonA,Noise=Sound'a_generic.Water.Faucet23')
     ToggleOnSequences(1)=(PlaySequence=turnonB,Noise=Sound'a_generic.Water.SinkLargeLp1',NoiseIsAmbient=True,Radius=12.000000)
     ToggleOnSequences(2)=(PlaySequence=turnonC)
     ToggleOnSequences(3)=(PlaySequence=faucetidleon,Loop=True)
     ToggleOffSequences(0)=(PlaySequence=turnoffA)
     ToggleOffSequences(1)=(PlaySequence=turnoffB)
     ToggleOffSequences(2)=(PlaySequence=turnoffC)
     ToggleOffSequences(3)=(PlaySequence=turnoffD,Noise=Sound'a_generic.Water.Faucet23')
     ToggleOffSequences(4)=(PlaySequence=faucetidleoff,Loop=True)
     Health=0
     ItemName="Lab Faucet"
     bTakeMomentum=False
     bUseTriggered=True
     CollisionRadius=15.000000
     CollisionHeight=17.000000
     bCollideWorld=False
     Texture=Texture'm_zone5_area51.faucet_labchmRC'
     Mesh=DukeMesh'c_zone5_area51.faucet_lab'
     AnimSequence=faucetidleoff
}
