class ProtonCollisionActor extends RenderActor;

var EDFMinigun MyGun;
var dnSmokeEffect_RobotDmgA MySmoke;

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector momentum, class<DamageType> damageType )
{
	Health -= Damage;
	if( Health <= 0 )
	{
		MyGun.Health = 0;
		EDFHeavyWeps( Owner ).KillGun( MyGun );
	}
	else if( MySmoke == None && Health <= ( Default.Health * 0.5 ) )
		CreateDamageSmoke();

//	ProtonMonitor( Owner ).ProcessDamage( self );
//	Pawn( Owner ).TakeDamage( Damage, instigatedBy, HitLocation, momentum, damageType );
}

function CreateDamageSmoke()
{
	local int bone;
	local MeshInstance Minst;

	MySmoke = Spawn( class'dnSmokeEffect_RobotDmgA', self,, Location, Rotation );
	MySmoke.AttachActorToParent( self, false, false );
	
	//if( LastDamageBone == '' )
	//	MySmoke.MountMeshItem = 'Chest';
	//else
	//	MySmoke.MountMeshItem = LastDamageBone;
	MySmoke.MountType = MOUNT_Actor;
	MySmoke.SetPhysics( PHYS_MovingBrush );
}

DefaultProperties
{
    Health=85
	bCollideActors=true
	bCollideWorld=true
	bBlockPlayers=true
	bBlockActors=false
    bProjTarget=true
	CollisionRadius=12
	CollisionHeight=8
    bHidden=true
	HitPackageClass=class'HitPackage_Steel'
	HitPackageLevelClass=class'HitPackage_DukeLevel'
}
