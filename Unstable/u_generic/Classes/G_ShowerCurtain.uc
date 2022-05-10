//=============================================================================
// G_ShowerCurtain. 					January 11th, 2001 - Charlie Wiederhold
//=============================================================================
class G_ShowerCurtain expands Generic;

#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     TriggerRadius=60.000000
     TriggerHeight=50.000000
     TriggerType=TT_PlayerProximityAndLookUse
     TriggerRetriggerDelay=1.500000
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DamageSequence=close_hit
     DamageSequenceOff=open_hit
     bSequenceToggle=True
     ToggleOnSequences(0)=(PlaySequence=Open,Noise=Sound'a_generic.ShowerCurtain.ShwrCurtOpen1')
     ToggleOnSequences(1)=(PlaySequence=openidle,loop=True)
     ToggleOffSequences(0)=(PlaySequence=Close,Noise=Sound'a_generic.ShowerCurtain.ShwrCurtClos1')
     ToggleOffSequences(1)=(PlaySequence=closeidle,loop=True)
     HealthPrefab=HEALTH_NeverBreak
     Mesh=DukeMesh'c_generic.ShowerCurtain'
     ItemName="Shower Curtain"
     bNotTargetable=True
     CollisionRadius=50.000000
     CollisionHeight=51.000000
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     bTakeMomentum=False
}
