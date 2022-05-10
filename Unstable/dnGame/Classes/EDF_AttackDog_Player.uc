class EDF_AttackDog_Player extends DukePlayer;

var		float		BiteDamage;
var		float		BiteTime;

event Bump( Actor Other )
{
	Super.Touch( Other );

	BroadcastMessage( "Bumped" @ Other );

	if ( ( Level.TimeSeconds > BiteTime ) && Other.IsA( 'Pawn' ) )
	{
		BiteTime = Level.TimeSeconds + default.BiteTime;
		Other.TakeDamage( BiteDamage, self, vect(0,0,0), vect(0,0,0), class'BiteDamage' );
	}
}

function PlayJump()
{
	PlayAllAnim( 'A_Jump',,0.1,true );
}

function PlayInAir()
{
	PlayAllAnim( 'A_JumpAir',,0.1,true );
}

function PlayLanded( float ImpactVel )
{
	PlayAllAnim( 'A_JumpLand',,0.1,true );
}

function PlayRunning()
{
	PlayAllAnim( 'A_Run',,0.1,true );
}

function PlayWalking()
{
	PlayAllAnim( 'A_Walk',,0.1,true );
}

function PlayTurning( float Yaw )
{
	// No turning anim needed
}

function PlayUpdateRotation( int Yaw )
{
	// No turning anim needed
}

function PlayWaiting()
{
	if ( FRand() > 0.3 )
		PlayAllAnim( 'A_IdleStandA',,0.1,true );
	else
		PlayAllAnim( 'A_IdleStandSniff',,0.1,true );
}

function PlayToWaiting( float TweenTime )
{
	PlayAllAnim( 'A_IdleStandA',,0.1,true );
}

function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	if ( FRand() > 0.5 )
		PlayAllAnim( 'A_DeathSideA',,0.1, false );
	else
		PlayAllAnim( 'A_DeathSideB',,0.1, false );
}

defaultproperties
{
	Mesh=c_characters.EDF_Dog	
	MultiSkins(0)=None
	MultiSkins(1)=None
	MultiSkins(2)=None
	MultiSkins(3)=None

    CollisionHeight=32.000000
	CollisionRadius=18.000000
	GroundSpeed=+00375.000000
	//PelvisRotationScale=-0.5
	//AbdomenRotationScale=-0.2
	//ChestRotationScale=-0.5
	Health=60
	MaxHealth=60
	JumpZ=500.0000
	BiteTime=1.5
	BiteDamage=40
	MyClassName="EDF Attack Dog"
}