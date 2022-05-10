/*-----------------------------------------------------------------------------
	RespawnMarker
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class RespawnMarker extends RenderActor
	abstract;

var float ChangeTime;
var int   MyState;

function StateChanged()
{
}

function Tick( float DeltaTime )
{
	if ( bHidden )
	{
		Disable( 'Tick' );
		return;
	}

	if ( Level.TimeSeconds > ChangeTime )
	{
		MyState++;
		StateChanged();
		ChangeTime = Level.TimeSeconds + Default.ChangeTime;
	}
}

function Hide()
{
	bHidden = true;
	Disable( 'Tick' );	
}

function Show( float RespawnTime )
{
	Default.ChangeTime	= RespawnTime / 3;
	ChangeTime			= Level.TimeSeconds + Default.ChangeTime;
	bHidden				= false;
	MyState				= 0;
	Mesh				= Default.Mesh;
	
	StateChanged();
	
	Enable( 'Tick' );
}

defaultproperties
{
	Physics=PHYS_None
}