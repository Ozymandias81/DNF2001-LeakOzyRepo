class SnatcherRubble extends dnDecoration;

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx

//SnatcherRubble_Dirt (Down, Idle, Up)

//SnatcherRubble_Rocks (Down, Idle, Up)

function TakeDamage( int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> damageType )
{
}
/*
function PostBeginPlay()
{
	local Texture T;
	local class<Material> M;
	LoopAnim( 'Down' );
	T = TraceTexture( Owner.Location + vect( 0, 0, -Owner.CollisionHeight - 20 ), Owner.Location );
	MultiSkins[ 0 ] = T;
	M = T.GetMaterial();
	if( !M.Default.bBurrowableDirt )
		Mesh = DukeMesh'SnatcherRubble_Dirt';

	//if( Rocks( M ) != None || Cement_Clean( M ) != None )
	//	Mesh = DukeMesh'SnatcherRubble_Rocks';
}
*/
auto state Mound
{
	function DeadCheck()
	{
		if( !PlayerCanSeeMe() )
			GotoState( 'Mound', 'KillSelf' );
	}

KillSelf:
	PlayAnim( 'Down' );
	FinishAnim();
	Destroy();

Begin:
	PlayAnim( 'Up' );
	FinishAnim();
	LoopAnim( 'Idle' );
	SetCallbackTimer( 12.5, true, 'DeadCheck' );
}

DefaultProperties
{
	DrawType=DT_Mesh
	mesh=Dukemesh'SnatcherRubble_Rocks'
	bBlockPlayers=false
	bBlockActors=false
	CollisionHeight=0
	CollisionRadius=0
	bProjTarget=false
	LightType=LTD_NormalNoSpecular
}


