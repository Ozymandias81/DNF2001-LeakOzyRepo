//=============================================================================
// G_FireEffect1. Keith Schuler September 14, 2000
// General purpose particle fire effect with mesh ember base
// Spawns mounted particle systems dnSmokeEffect1 and dnFireEffect1
//=============================================================================
class G_FireEffect1 expands Generic;

#exec OBJ LOAD FILE=..\system\dnParticles.u
#exec OBJ LOAD FILE=..\sounds\a_ambient.dfx
#exec OBJ LOAD FILE=..\meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\textures\m_FX.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnFireEffect1',SetMountOrigin=True,MountOrigin=(Z=42.000000))
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnSmokeEffect1',SetMountOrigin=True,MountOrigin=(Z=52.000000))
     MountOnSpawn(2)=(ActorClass=Class'dnGame.DOTTrigger_Fire')
     DontDie=True
     DestroyedSound=None
     bTumble=False
     bTakeMomentum=False
     MassPrefab=MASS_Ultralight
     Physics=PHYS_Falling
     bDirectional=True
     Mesh=DukeMesh'c_FX.firebottom'
     ItemName="Fire"
     SoundVolume=255
     AmbientSound=Sound'a_ambient.Fire.FireLp64'
     CollisionHeight=1.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
}
