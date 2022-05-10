class EDFShield extends MountableDecoration;

var bool bCanPlayDamage;
var float TimeBetweenDamage;
var float DamageTimer;
var() int ShieldHealth;
var() bool bUseShieldHealth;

function PostbeginPlay()
{
	bCanPlayDamage = true;
	TimeBetweenDamage = 0.25;
	Super.PostBeginPlay();
}

function Tick( float DeltaTime )
{
	if( !bCanPlayDamage )
	{
		DamageTimer += DeltaTime;
		if( DamageTimer > TimeBetweenDamage )
		{
			bCanPlayDamage = true;
			DamageTimer = 0;
		}
	}
	Super.Tick( DeltaTime );
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if(SpawnOnHit!=none)
	{
		Spawn(SpawnOnHit, Self, '', HitLocation, rotator(HitLocation - Location));
		if( FRand() < 0.25 )
			Spawn( class'dnParticles.dnWallSpark', Self, '', HitLocation, rotator( HitLocation - Location ) );

	}
	if( bUseShieldHealth )
	{
		ShieldHealth -= 5;
		if( ShieldHealth <= 0 )
		{
			HumanNPC( Owner ).RemoveMountable( self );
			AttachActorToParent( none, false, false );
			Tossed();
			Velocity += VRand() * 528;
			Velocity.Z = 200;
			HumanNPC( Owner ).MyShield = None;	
			HumanNPC( Owner ).bShieldUser = false;
			HumanNPC( Owner ).PlayToWaiting( 0.2 );
			SetOwner( None );
			return;
		}	
	}
	/*if( HitLocation.Z > Location.Z )
	{
		log( "Playing1" );
		// T L M R
	//	if( HumanNPC( Owner ).GetSequence( 1 ) == 'T_ShieldIdle' )
			HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitT',, 0.1, false );
	}
	else
	if( HitLocation.Z == Location.Z )
	{
		log( "Playing2" );
		//if( HumanNPC( Owner ).GetSequence( 1 ) == 'T_ShieldIdle' )
			HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitM',, 0.1, false );
	}
	else
	if( HitLocation.Z < Location.Z )
	{
		//if( HumanNPC( Owner ).GetSequence( 1 ) == 'T_ShieldIdle' )
		log( "Playing3" );
		HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitB',, 0.1, false );
	}*/
	if( Pawn( Owner ) != None )
	{
	if( bCanPlayDamage && Pawn( Owner ).bFire == 0  )
	{
	if( FRand() < 0.5 && Pawn( Owner ).bFire == 0 )
	{
	if( HitLocation.X > Location.X )
	{
		HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitR',, 0.12, false );
	}

	else if( HitLocation.X < Location.X )
	{
		HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitL',, 0.12, false );
	}
	else if( HitLocation.X == Location.X )
	{
		HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitM',, 0.12, false );
	}
	}
	else if( Pawn( Owner ).bFire == 0 )
	{
		if( HitLocation.Z > Location.Z )
			HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitT',, 0.12, false );
		if( HitLocation.Z == Location.Z )
			HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitM',, 0.12, false );
		if( HitLocation.Z < Location.Z )
			HumanNPC( Owner ).PlayTopAnim( 'T_ShieldHitB',, 0.12, false );
	}
	if( Pawn( Owner ).GetStateName() == 'RangedAttack' )
	{
		Pawn( Owner ).GotoState( 'RangedAttack', 'PlayShieldDam' );
	}
	}
//	bCanPlayDamage = false;
	}
	//log( "TookDamage" );
	//BroadcastMessage( "ShieldTooKDamage" );
}

function Landed(vector HitNormal)
{
	Stopped();
	Super.Landed( HitNormal );
}

event Stopped()
{
	local RiotShield RiotReplacement;

	RiotReplacement = spawn(class'RiotShield');
	RiotReplacement.SetLocation( Location );
	RiotReplacement.SetRotation( Rotation );
	Destroy();
}

function Tossed(optional bool Dropped)
{
	local EDFShield_Broken BrokenShield;
	if ( FRand() > 0.2 )
	{
		BrokenShield = spawn(class'EDFShield_Broken');
		BrokenShield.SetLocation( Location );
		BrokenShield.SetRotation( Rotation );
		BrokenShield.Tossed( Dropped );
		Destroy();
	}
	else
		Super.Tossed( Dropped );
}

function TakeHitDamage( vector HitLocation, vector HitNormal,
						int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
						texture HitMeshTex, float HitDamage, Actor HitInstigator,
						class<DamageType> HitDamageType, vector HitMomentum )
{
	if ( HitInstigator.bIsPawn &&
		 (Pawn(HitInstigator).Weapon.AmmoType != None) &&
		 Pawn(HitInstigator).Weapon.AmmoType.ArmorPiercing()
		)
	{
		// Armor piercing ammo can penetrate the shield.
		HitDamage /= 5;
		HitMeshBone = 'None';
	}

	Super.TakeHitDamage( HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitDamage, HitInstigator, HitDamageType, HitMomentum );
}

defaultproperties
{
	//CollisionHeight=20
	//CollisionRadius=13
    ShieldHealth=25
	CollisionHeight=24
	CollisionRadius=13
	bLandBackwards=true
	LandFrontCollisionRadius=27
	LandFrontCollisionHeight=2
	bCollideActors=true
	bCollideWorld=true
	bProjTarget=true
	Mesh=DukeMesh'c_characters.EDFshield'
	Texture=Texture'm_characters.edfshieldglassR'
	LODMode=LOD_Disabled
	DrawType=DT_Mesh
	HealthPrefab=HEALTH_NeverBreak
	MountAngles=(Pitch=0,Yaw=-800,Roll=32768)
	MountMeshItem=Forearm_L
	MountOrigin=(X=0.500000,Y=-6.500000,Z=1.400000)
	MountType=MOUNT_MeshBone
	Physics=PHYS_MovingBrush
	SpawnOnHit=class'dnParticles.dnbulletfx_glassspawner'
//	Rotation=(Pitch=0,Roll=0,Yaw=32632)
	HitPackageClass=class'HitPackage_Shield'
    bUseShieldHealth=false
}
