class OctaPlayer extends DukePlayer;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetPlayerSpeed( 0.5 );
}

function StartWalk()
{
	Super.StartWalk();	
	SetPhysics( PHYS_Flying );	
}

function ClientRestart()
{
	Super.ClientRestart();

	// OctaPlayer is flying!
	SetControlState( CS_Flying );
}

function PlayTurning( float Yaw )
{
	// No turning anim needed
}

function PlayUpdateRotation( int Yaw )
{
	// No turning anim needed
}

function PlayFlying()
{
	PlayAllAnim( 'RUN_F',,0.1,true );
}

function PlayWaiting()
{
	if ( FRand() > 0.5 )
		PlayAllAnim( 'IDLEA',,0.1,true );
	else
		PlayAllAnim( 'IDLEB',,0.1,true );
}

function PlayToWaiting( float TweenTime )
{
	if ( FRand() > 0.5 )
		PlayAllAnim( 'IDLEA',,TweenTime,true );
	else
		PlayAllAnim( 'IDLEB',,TweenTime,true );
}

function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	PlayAllAnim( 'DeathA',,0.1, false );
}

function WpnPlayActivate()
{
}


defaultproperties
{
	bCanFly=true
	Mesh=c_characters.Octobrain
	ImmolationClass="dnGame.dnPawnImmolation_Octabrain"
    CollisionHeight=51.000000
	CollisionRadius=32.000000
	PelvisRotationScale=-0.5
	AbdomenRotationScale=-0.2
	ChestRotationScale=-0.5
	Health=200
	MaxHealth=200
}