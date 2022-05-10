//=============================================================================
// G_ShowerHead						  September 26th, 2000 - Charlie Wiederhold
//=============================================================================
class G_ShowerHead extends Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     FragType(2)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(5)=Class'dnParticles.dnDebris_Sparks1_Small'
     TriggerRetriggerDelay=0.500000
     TriggeredSpawn(0)=(ActorClass=Class'dnParticles.dnShowerWater',MountMeshItem=Mount1,SpawnOnce=True,TriggerWhenTriggered=True)
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_ShowerHead_Broken')
     PendingSequences(0)=(PlaySequence=offloop)
     CurrentPendingSequence=1
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=TurnOn,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOnSequences(1)=(PlaySequence=onloop,Noise=Sound'a_generic.Water.ShowerLp1',NoiseIsAmbient=True,Radius=14.000000)
     ToggleOffSequences(0)=(PlaySequence=turnoff,Noise=Sound'a_generic.Water.Faucet23',Radius=384.000000)
     ToggleOffSequences(1)=(PlaySequence=offloop)
     Health=0
     ItemName="Shower Head"
     bTakeMomentum=False
     bUseTriggered=True
     CollisionRadius=12.000000
     CollisionHeight=40.000000
     bCollideWorld=False
     Texture=Texture'm_generic.metalsink1RC'
     Mesh=DukeMesh'c_generic.ShowerNozzle'
     AnimSequence=faucetidleoff
}
