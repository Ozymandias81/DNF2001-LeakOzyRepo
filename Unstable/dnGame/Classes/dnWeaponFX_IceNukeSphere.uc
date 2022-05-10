//=============================================================================
// dnWeaponFX_IceNukeSphere. 				May 25th, 2001 - Charlie Wiederhold
//=============================================================================
class dnWeaponFX_IceNukeSphere expands dnWeaponFX;

#exec OBJ LOAD FILE=..\meshes\c_fx.dmx

var float			TimePassed;
var float			TimeToDie;

//=============================================================================
//	PreBeginPlay
//=============================================================================
function PreBeginPlay()
{
	TimeToDie = LifeSpan;
	Super.PreBeginPlay();
}
			
//=============================================================================
// Script updates:
// Periodic update:
//=============================================================================
function Tick(float DeltaTime)

{
	ScaleGlow = 1 - (TimePassed / TimeToDie);
	TimePassed	+= DeltaTime;
}


defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnFreezeRayFX_IceNuke_ResidualCold',SetMountOrigin=True,MountOrigin=(Z=64.000000),SurviveDismount=True)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnFreezeRayFX_IceNuke_IceSpray',SurviveDismount=True)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnFreezeRayFX_IceNuke_Flash')
     IdleAnimations(0)=None
     PendingSequences(0)=(PlaySequence=small)
     CurrentPendingSequence=0
     bNotTargetable=True
     LifeSpan=23.000000
     Skin=Texture't_firefx.icespray2.iceshardCRC'
     Mesh=DukeMesh'c_FX.efxsphere1'
}
