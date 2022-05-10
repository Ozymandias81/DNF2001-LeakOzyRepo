class TentacleSmall expands RenderActor;

var float ExistanceTime, RetractedTime;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

function Timer( optional int TimerNum )
{
	if( !bHidden )
	{
		if( ExistanceTime > 3.5 && FRand() < 0.25 )
		{
			GotoState( 'Swinging', 'Retracting' );
			ExistanceTime = 0;
			Disable( 'Timer' );
		}
		else
		{
			GotoState( 'Swinging', 'Animating' );
		}
	}
	else
	{
		if( RetractedTime > 3.5 && FRand() < 0.33 )
		{
			bHidden = false;
			RetractedTime = 0;
			GotoState( 'Swinging', 'Begin' );
		}
	}
}

function PostBeginPlay()
{
	SetTimer( Rand( 2 ) + FRand(), true );
}

function Tick( float DeltaTime )
{
	if( !bHidden )
		ExistanceTime += DeltaTime;
	else
		RetractedTime += DeltaTime;
	if( Owner == None )
	{
		Destroy();
	}
}

function LoopRandomAnim( optional int LoopSpeed )
{
	local int i;

	i = Rand( 2 );
	if( LoopSpeed == 0.0 )
		LoopSpeed = 1.0;

	Switch ( i )
	{
		Case 0:
			LoopAnim( 'IdleA', LoopSpeed );
			break;
		Case 1:
			LoopAnim( 'IdleB', LoopSpeed );
			break;
		Case 2:
			LoopAnim( 'IdleC', LoopSpeed );
			break;
	}
}

state Dying
{
Begin:
	Disable( 'Timer' );
	FinishAnim();
	LoopRandomAnim( 2.5 );
	Sleep( FRand() );
	FinishAnim();
	LoopRandomAnim( 2.5 );
	Sleep( 2 + FRand() );
	FinishAnim();
	LoopRandomAnim( 2.5 );
	FinishAnim();
	PlayAnim( 'Retract' );
	FinishAnim();
	Destroy();
}	

state Dormant
{
Begin:
	bHidden = true;
	Enable( 'Timer' );
	if( FRand() < 0.5 )
	{
		ChangeMesh();
	}
	SetTimer( Rand( 2 ) + FRand(), true );
}

function ChangeMesh()
{
	local int i;

	i = rand( 4 );

	Switch( i )
	{
		Case 0:
			Mesh = DukeMesh'c_characters.MiniTentacle';
			break;
		Case 1:
			Mesh = DukeMesh'c_characters.MouthTentacle';
			break;
		Case 2:
			Mesh = DukeMesh'c_characters.EyeTentacle';
			break;
		Case 3:
			Mesh = DukeMesh'c_characters.ForkTentacle';
			break;
		Default:
			Mesh = DukeMesh'c_characters.MiniTentacle';
			break;
	}
}

state TemporaryTentacle
{
Begin:
	ChangeMesh();
	bHidden = false;
	PlayAnim( 'Expand' );
	FinishAnim();
	LoopRandomAnim();
	Sleep( 1 + Rand( 3 ) + FRand() );
	PlayAnim( 'Retract' );
	FinishAnim();
	Destroy();
}

state Swinging
{
Retracting:
	PlayAnim( 'Retract' );
	FinishAnim();
	GotoState( 'Dormant' );
Begin:
	bHidden = false;
	PlayAnim( 'Expand' );
Animating:
	FinishAnim();
	LoopRandomAnim();
}

defaultproperties
{
     bHidden=true
     Physics=PHYS_MovingBrush
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_characters.MiniTentacle'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bHeated=True
     HeatIntensity=255.000000
     LightDetail=LTD_AmbientOnly
}
