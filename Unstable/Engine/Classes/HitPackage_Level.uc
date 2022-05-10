/*-----------------------------------------------------------------------------
	HitPackage_Level
	Author: Brandon Reinhart

	Used when the shot hits world geometry.  This is a special hit package.
-----------------------------------------------------------------------------*/
class HitPackage_Level extends HitPackage;

var class<Effects> RicochetClass;

simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local vector ShotOrigin, Direction;
	local trigger t;

	ShotOrigin.X = ShotOriginX;
	ShotOrigin.Y = ShotOriginY;
	ShotOrigin.Z = ShotOriginZ;

	Direction = Normal( Location - ShotOrigin );
	End = Location + Direction*10;
	Start = ShotOrigin;

	BeamStart.X = TraceOriginX;
	BeamStart.Y = TraceOriginY;
	BeamStart.Z = TraceOriginZ;
}

// Everything spawned here should have no remote role.
simulated function Deliver()
{
	if ( Level.NetMode == NM_DedicatedServer )
		return;

	MakeNoise( 1.0 );

	// Draw a beam if necessary.
	if ( bTraceBeam )
		SpawnTraceBeam( Location, vect(TraceOriginX, TraceOriginY, TraceOriginZ) );
	else if ( bLaserBeam )
	{
		TraceHitCategory = 1;
		SpawnLaserBeam( Location, vect(TraceOriginX, TraceOriginY, TraceOriginZ) );
	}

	// Spawn a richochet if necessary.
	if ( bRicochet )
		spawn( RicochetClass,,,Location );

	if ( Level.NetMode != NM_Client )
		return;

	// Do client effects.
	TraceFire( Instigator, 0.0, 0.0, false, true, true, true, bNoCreationSounds );
}
