class JetskiDude extends RenderActor;

#exec OBJ LOAD FILE=..\Meshes\c_Characters.dmx
#exec OBJ LOAD FILE=..\Meshes\c_vehicles.dmx


var bool bDead;
var bool bCanDestroy;
var() int DestroyTime;

auto state Riding
{
	ignores Touch, Bump, HitWall, ZoneChange;
}

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	GotoState( 'Dying' );
}


state Dying
{
	ignores TakeDamage, Touch, Bump, Trigger;

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		if( NewZone.bWaterZone )
		{
			Mesh = None;

			if( bCanDestroy )
				Destroy();
			else 
	
		{
			
				buoyancy = RandRange( 400, 650 );
				SetPhysics( PHYS_Falling );
				bRotateToDesired = true;
				bFixedRotationDir=False;
				DesiredRotation = RotRand();
			}
		}
	}

	function Timer( optional int TimerNum )
	{
		bCanDestroy = true;
	}
	
	function BeginState()
	{
		SetTimer( DestroyTime, true );
	}

Begin:
	SetCollision( false, false, false );
	PlayAnim( 'Death_Back' );

	AttachActorToParent( none, false, false );
	AIJetSki( Owner ).GotoState( 'Crashing' );
	MountParent = None;
	SetOwner( None );
	Sleep( 0.1 );
	//Buoyancy = 1450;
	Buoyancy = 400;
	Velocity =  VRand() * 512;
	Velocity.Z = 300;
	SetPhysics( PHYS_Falling );
	FinishAnim();
	

}
function ZoneChange( ZoneInfo NewZone )
{}


DefaultProperties
{
    DestroyTime=3.000000
	bProjTarget=true
	bBlockActors=true
	bCollideWorld=true
	bCollideActors=true
	bBlockPlayers=true

	Mesh=DukeMesh'c_characters.jetskidude'
	Texture=Texture'm_vehicles.edf_refmap1BC'
	DrawType=DT_Mesh
	Physics=PHYS_MovingBrush
	VisibilityRadius=8000
    RotationRate=(Pitch=55000,Yaw=55000,Roll=55000)
	//	Buoyancy=201
}
