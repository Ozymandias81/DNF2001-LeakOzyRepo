//=============================================================================
// G_Flashlight. 					   November 30th, 2000 - Charlie Wiederhold
//=============================================================================
class G_Flashlight expands MountableDecoration;

#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

function Tossed( optional bool bDropped )
{
	Super.Tossed( bDropped );
	bNotTargetable = false;
}

function ZoneChange( ZoneInfo NewZone )
{
	Super(dnDecoration).ZoneChange( NewZone );
}

function BaseChange()
{
	Super(dnDecoration).BaseChange();
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( MountParent == None )
		Super(dnDecoration).TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType );
	else
		Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType );
}


defaultproperties
{
     HealthPrefab=HEALTH_NeverBreak
     bNotTargetable=false
     MountOnSpawn(0)=(ActorClass=Class'dnLight_FlashlightAmbient',SetMountOrigin=True,MountOrigin=(X=8.000000))
     MountOnSpawn(1)=(ActorClass=Class'dnLight_FlashlightBeam')
     FragType(0)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Small'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     DestroyedSound=Sound'a_impact.Glass.GlassBreak73'
     MassPrefab=MASS_Light
     bLandLeft=True
     bLandRight=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionRadius=18.000000
     LandFrontCollisionHeight=6.000000
     LandSideCollisionRadius=18.000000
     LandSideCollisionHeight=6.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=-1.500000,Y=-1.000000,Z=-0.250000)
     BobDamping=0.950000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.Flashlight'
     ItemName="Flashlight"
     CollisionRadius=18.000000
     CollisionHeight=6.000000
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     MountType=MOUNT_MeshBone
     DismountPhysics=PHYS_Falling
     MountOrigin=(X=-1.500000,Y=7.000000,Z=-6.000000)
     MountAngles=(Pitch=-8192,Yaw=14000)
     MountMeshItem=Hand_R
	 bCollideWorld=true
	 bCollideActors=true
	 bBlockPlayers=true
	 bBlockActors=true
	 bProjTarget=true
}
