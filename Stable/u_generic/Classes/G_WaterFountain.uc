//=============================================================================
// G_WaterFountain.
//===============================================Created Feb 24th, 1999 - Stephen Cole
class G_WaterFountain expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Generic1b'
     TriggerRetriggerDelay=2.000000
     HealOnTrigger=5
     bDrinkSoundOnHeal=True
     DestroyedSound=Sound'a_impact.metal.ImpactMtl07'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_WaterFountain_Broken')
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=TurnOn,Noise=Sound'a_generic.SodaFountain.SodaFtnRun')
     ToggleOnSequences(1)=(PlaySequence=onloop,Loop=True)
     ToggleOffSequences(0)=(PlaySequence=turnoff)
     ToggleOffSequences(1)=(PlaySequence=offloop,Loop=True)
     bNotifyUnUsed=True
     ItemName="Water Fountain"
     bTakeMomentum=False
     bUseTriggered=True
     CollisionRadius=15.000000
     CollisionHeight=23.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.water_fountain'
     AnimSequence=offloop
}
