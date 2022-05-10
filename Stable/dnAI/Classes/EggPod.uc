class EggPod extends AIPawn;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

/*================================================================
	Sequences:
	
	BirthL
	BirthM
	BirthR
	Grow
	IdleA
	PainA
================================================================*/
var() int		MaxItems			?("Maximum number of items from this factory at any time.");
var() int		Capacity			?("Maximum number of items ever buildable (-1 = no limit).");
var() float		Interval			?("Average time interval between spawnings.");	
var() name		ItemTag				?("Tag given to items produced at this factory.");
var() bool		bGrowOnSpawn		?("Play the grow animation when spawned.");
var() bool		bSeePlayerActivate	?("I will activate when receiving a see player event.");
var   int		NumItems;
var   Snatcher	NewbornSnatcher;
var	  name		TempMountMeshItem;
// classischildof damagetype and return
var   Snatcher  ActiveSnatchers[ 32 ];

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	Momentum *= 0;

	if( ClassIsChildOf( DamageType, class'PoisonDamage' ) )
		return;
	else
	{
		Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
		WarnBrood( InstigatedBy );
		PlayAllAnim( 'PainA',, 0.1, false );
	}
}

function WarnBrood( Pawn Instigator )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( ActiveSnatchers[ i ] != None )
		{
			if( ActiveSnatchers[ i ].Enemy == None )
			{
				ActiveSnatchers[ i ].Enemy = Instigator;
				ActiveSnatchers[ i ].GotoState( 'Attacking' );
			}
		}
	}
}

function AnimEnd()
{
	if( GetSequence( 0 ) == 'PainA' )
		PlayAllAnim( 'IdleA',, 0.1, true );
}

function Carcass SpawnCarcass( optional class<DamageType> DamageType, optional vector HitLocation, optional vector Momentum )
{
	local carcass carc;

	carc = Spawn(CarcassType);
//	carc.InitFor( self );
	Carc.SetLocation( Location );
	Carc.SetCollisionSize( CollisionRadius*2, CollisionHeight );
	Carc.DesiredRotation		= Rotation;
	Carc.DesiredRotation.Roll	= 0;
	Carc.DesiredRotation.Pitch	= 0;
	Carc.Mass					= Mass;
	Carc.bMeshLowerByCollision	= bMeshLowerByCollision;
	if ( carc == None )
		return None;
	
	return carc;
}

function AddSnatcher( Snatcher NewSnatcher )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( ActiveSnatchers[ i ] == None )
		{
			ActiveSnatchers[ i ] = NewSnatcher;
			break;
		}
	}
}

function int GetActiveCount()
{
	local int i, Count;

	for( i = 0; i <= 31; i++ )
	{
		if( ActiveSnatchers[ i ] != None )
		{
			Count++;
		}
	}

	return Count;
}

function RemoveSnatcher( Snatcher OldSnatcher )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( ActiveSnatchers[ i ] == OldSnatcher )
		{
			ActiveSnatchers[ i ] = None;
			break;
		}
	}
}

function EvaluateGas()
{
	local int RandChoice;
	local SoftParticleSystem SmokeEffect;
	local name TempMountMeshItem;

	RandChoice = Rand( 3 );

	Switch( RandChoice )
	{
		Case 0:
			TempMountMeshItem = 'Mount1';
			break;
		Case 1:
			TempMountMeshItem = 'Mount2';
			break;
		Case 2:
			TempMountMeshItem = 'Mount3';
			break;
	}

	SmokeEffect = Spawn( class'dnSmokeEffect_HoseSpray' );
	SmokeEffect.AttachActorToParent( self, true, true );
	SmokeEffect.SetPhysics( PHYS_MovingBrush );
	SmokeEffect.MountType = MOUNT_MeshSurface;
	SmokeEffect.MountMeshItem = TempMountMeshItem;
	SmokeEffect.LifeSpan = 2;
	SmokeEffect.Trigger( self, self );
}

state Spawning
{
	function BeginState()
	{
	}

	function Timer( optional int TimerNum )
	{
		VomitSnatcher();
	}

	function SetTempMountMeshItem()
	{
		local int RandChoice;

		RandChoice = Rand( 3 );

		Switch( RandChoice )
		{
			Case 0:
				TempMountMeshItem = 'Mount1';
				PlayAllAnim( 'BirthL',, 0.1, false );
				break;
			Case 1:
				TempMountMeshItem = 'Mount2';
				PlayAllAnim( 'BirthM',, 0.1, false );
				break;
			Case 2:
				TempMountMeshItem = 'Mount3';
				PlayAllAnim( 'BirthR',, 0.1, false );
				break;
		}
	}

	function VomitSnatcher()
	{
		SetCollision( false, false, false );
		NewbornSnatcher = spawn( class'Snatcher', self );
		NewbornSnatcher.SetCollision( false, false, false );
		SetCollision( true, true, true );
		NewbornSnatcher.SetCollisionSize( NewbornSnatcher.CollisionRadius, 0 );
		NewbornSnatcher.AttachActorToParent( self, true, true );
		NewbornSnatcher.RotationRate.Pitch = 0;
		NewbornSnatcher.GotoState( '' );
		NewbornSnatcher.MountMeshItem =	TempMountMeshItem;
		NewbornSnatcher.MountType =	MOUNT_MeshSurface;
		NewbornSnatcher.SetPhysics( PHYS_MovingBrush );
		NewbornSnatcher.Acceleration = vect( 120, -190, 120 );
		NewbornSnatcher.Acceleration = vector( Rotation )  * 200;
		NewbornSnatcher.GotoState( 'Birth' );
		NewbornSnatcher.MasterPod = self;
		AddSnatcher( NewbornSnatcher );
	}

Begin:
	if( NumItems < MaxItems )
	{
		SetTempMountMeshItem();
		Timer();
		FinishAnim( 0 );
		PlayAllAnim( 'IdleA',, 0.1, true );
		NumItems++;
		Capacity--;
		if( Interval > 0.0 )
		{
			Sleep( Interval );
			Goto( 'Begin' );
		}	
	}
	else
	{
IdleLoop:
		NumItems = GetActiveCount();
		if( NumItems >= MaxItems )
		{
			Sleep( Interval );
			Goto( 'IdleLoop' );
		}
		else
			Goto( 'Begin' );
	}
}

function PostBeginPlay()
{
	if( bGrowOnSpawn )
		bHidden = true;
}

auto state Startup
{
	function BeginState()
	{
		// log( self$" entered Startup state" );
	}

Begin:
	SetPhysics( PHYS_Falling );
	WaitForLanding();
	if( bGrowOnSpawn )
		GotoState( 'Growing' );
	else
		GotoState( 'Idling' );
}

state Growing
{
	function BeginState()
	{
		// log( self$" entered Growing state." );
	}

Begin:
	bHidden = false;
	PlayAllAnim( 'Grow',, 0.1, false );
	FinishAnim( 0 );
	GotoState( 'Idling' );
}

// PodBirthA

state Idling
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Actor A;

		if( Event != '' )
		{
			foreach allactors( class 'Actor', A, Event )
			{
				if( A != Self )
					A.Trigger( self, EventInstigator );
			}
		}
		GotoState('Spawning');
	}

	function SeePlayer( actor Seen )
	{
		GotoState( 'Spawning' );
	}

	function BeginState()
	{
		// log( self$" entered Idling state." );
		SetCallbackTimer( 7.5, true, 'EvaluateGas' );

		if( !bSeePlayerActivate )
			Disable( 'SeePlayer' );
		else
			Enable( 'SeePlayer' );
	}

Begin:
	PlayAllAnim( 'IdleA',, 0.1, true );
	Sleep( 2.0 );
}


DefaultProperties
{
     GroundSpeed=0.000000
     AirSpeed=0.000000
     bSeePlayerActivate=true
     DrawType=DT_Mesh
     Mesh=dukemesh'c_characters.EggPod_LRG'
	 Interval=2.000000
	 MaxItems=2
     Capacity=1000
     Health=33
     CarcassType=class'EggPodCarcass'
}