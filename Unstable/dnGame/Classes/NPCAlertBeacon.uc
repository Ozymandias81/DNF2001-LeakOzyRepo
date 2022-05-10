class NPCAlertBeacon extends Info;

var() float	PulseFrequency;
var() float WarnRadius;
var() name	WarningType;
var() actor WarningActor;

function PostBeginPlay()
{
	SetTimer( PulseFrequency, true );
}

simulated function Timer( optional int TimerNum )
{
	local Pawn P;

	if( WarningActor.IsA( 'LaserMine' ) && !LaserMine( WarningActor ).bArmed )
	{
		return;
	}

	foreach radiusactors( class'Pawn', P, WarnRadius )
	{
		if( PlayerPawn( WarningActor ) == None && WarningActor != None && FRand() < 0.45 )
		{
			if( P.LineOfSightTo( WarningActor ) )
			{
				P.AlertNPC( WarningActor );
			}
		}
	}
}

defaultproperties
{
     PulseFrequency=1.000000
     WarnRadius=1024
}
