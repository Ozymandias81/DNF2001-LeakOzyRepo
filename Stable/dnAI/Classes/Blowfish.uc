/*=============================================================================
	Blowfish
	Author: Jess Crable

=============================================================================*/
class Blowfish expands Fish;

#exec obj load file=..\meshes\c_zone1_vegas.dmx
#exec obj load file=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local actor SmokeTrail;

	SmokeTrail = spawn( class'dnm16grenadetrail' );
	SmokeTrail.AttachActorToParent( self, false, false );
	SmokeTrail.MountType = MOUNT_Actor;
	SmokeTrail.SetPhysics( PHYS_MovingBrush );

	GotoState( 'Deflating' );
}


auto state Startup
{
Begin:
	
	SetPhysics( PHYS_Falling );	
	WaitForLanding();
	LoopAnim( 'Blow_TransitDown' );
	Sleep( 5.0 );
	SetPhysics( PHYS_Flying );
	
	MoveTo( Location + vect( 0, 0, 42 ) );
	Sleep( 2.0 );
}

state Deflating
{
	function Tick( float DeltaTime )
	{
		DrawScale -= 0.01;
		if( DrawScale <= 0.0 )
			Destroy();
	}

Begin:
AirSpeed=20000;
GroundSpeed=20000;
AccelRate=10000;

Moving:
Destination = Location + ( VRand() * 64 );
if( Destination.Z <= 0 && FRand() < 0.8 )
{
	Destination.Z *= -1;
}
MoveTo( Destination );

	Goto( 'Moving' );
}

DefaultProperties
{
	Health=10000
	AirSpeed=64
	GroundSpeed=64
	AccelRate=50
	Mesh=DukeMesh'c_zone1_vegas.blowfish'
	DrawScale=11
	bProjTarget=true
}
