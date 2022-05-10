//=============================================================================
// dnWeaponFX_EMPSphere. 				   Feb. 21st, 2001 - Charlie Wiederhold
//=============================================================================
class dnWeaponFX_EMPSphere expands dnWeaponFX;

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
	if (Physics != PHYS_MovingBrush)
		SetPhysics(PHYS_MovingBrush);
	ScaleGlow = 1 - (TimePassed / TimeToDie);
	TimePassed	+= DeltaTime;
}


defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2')
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount1,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount2,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount12,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=mount4,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount5,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(6)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount18,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(7)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount25,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(8)=(ActorClass=Class'dnParticles.dnEMPFX_Spawner2',MountType=MOUNT_MeshSurface,MountMeshItem=Mount8,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(9)=(MountType=MOUNT_MeshSurface,MountMeshItem=Mount12,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(10)=(MountType=MOUNT_MeshSurface,MountMeshItem=Mount10,AppendToTag=Targets,TakeParentTag=True)
     MountOnSpawn(11)=(MountType=MOUNT_MeshSurface,MountMeshItem=Mount11,AppendToTag=Targets,TakeParentTag=True)
     IdleAnimations(0)=Expand2
     LifeSpan=1.050000
     Mesh=DukeMesh'c_FX.efxsphere1'
     bNotTargetable=True
     AmbientSound=Sound'dnsWeapn.EMP.EMPPulse1'
     IndependentRotation=True
}
