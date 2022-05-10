//=============================================================================
// G_FireEffect2.	Keith Schuler September 15,2000
// Mesh fire effect with no particles. Mesh skin is a flic texture
// Includes ambient sound
//=============================================================================
class G_FireEffect2 expands Generic;

#exec OBJ LOAD FILE=..\sounds\a_ambient.dfx
#exec OBJ LOAD FILE=..\meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\textures\m_FX.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnGame.DOTTrigger_Fire')
     DontDie=True
     FragType(0)=None
     NumberFragPieces=0
     TriggerType=TT_PlayerProximity
     DamageOtherOnTouch=4
     DestroyedSound=None
     PendingSequences(0)=(PlaySequence=firegengrow2)
     CurrentPendingSequence=0
     bTumble=False
     bTakeMomentum=False
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_NeverBreak
     bTickNotRelevant=False
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_FX.firegen1RC'
     ItemName="Fire"
     bUnlit=True
     SoundVolume=255
     AmbientSound=Sound'a_ambient.Fire.FireLp64'
     bBlockActors=False
     bBlockPlayers=False
}
