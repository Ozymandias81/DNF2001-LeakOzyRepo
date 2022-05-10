//=============================================================================
// Earthquake.
// note - this just shakes the players.  Trigger other effects directly
//=============================================================================
class Earthquake extends Keypoint;

var() float Magnitude;
var() float Duration;
var() float Radius;
var() bool  bThrowPlayer;
var() float ImpactForce;
var   float EndTime, RemainingTime;

var() float Elasticity;
var() float RevibrateTime;
var() float RevibrateRandom;
var() float VibrationPeriod;

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;
	local vector throwVect;
	local SwayMover S;

	if ( bThrowPlayer )
	{
		throwVect = 0.18 * Magnitude * VRand();
		throwVect.Z = FMax(Abs(ThrowVect.Z), 120);
	}

	P = Level.PawnList;
	while ( P != None )
	{
		if ( P.bIsPlayerPawn && (VSize(Location-P.Location)<Radius) )
		{
			if ( bThrowPlayer && (P.Physics != PHYS_Falling ) )
				P.AddVelocity( throwVect );
			PlayerPawn(P).AddVibration( Magnitude / 5.0, Duration, Elasticity, VibrationPeriod );
		}
		P = P.nextPawn;
	}
	EndTime = Duration + Level.TimeSeconds;
	SetTimer( RevibrateTime + RevibrateRandom*FRand(), true, 1 );

	if ( bThrowPlayer && (duration > 0.5) )
	{
		RemainingTime = Duration;
		SetTimer( 0.5, false, 2 );
	}

	foreach AllActors( class'SwayMover', S, Event )
	{
		throwVect = 0.18 * Magnitude * VRand();
		S.Impact( ImpactForce, throwVect );
	}
}

function Timer( optional int TimerNum )
{
	local vector throwVect;
	local Pawn P;

	if ( TimerNum == 1 )
	{
		if ( Level.TimeSeconds > EndTime )
		{
			SetTimer( 0.0, false, 1 );
			return;
		}
		
		P = Level.PawnList;
		while ( P != None )
		{
			if ( P.bIsPlayerPawn && (VSize(Location-P.Location)<Radius) )
			{
				PlayerPawn(P).AddVibration( Magnitude / 5.0, Duration, Elasticity, VibrationPeriod );
			}
			P = P.nextPawn;
		}
		SetTimer( RevibrateTime + RevibrateRandom*FRand(), true, 1 );
	}
	else if ( TimerNum == 2 )
	{
		RemainingTime -= 0.5;
		throwVect = 0.15 * Magnitude * VRand();
		throwVect.Z = FMax( Abs(ThrowVect.Z), 120 );

		P = Level.PawnList;
		while ( P != None )
		{
			if ( (PlayerPawn(P) != None) && (VSize(Location - P.Location) < radius) )
			{
				if ( P.Physics != PHYS_Falling )
					P.AddVelocity( ThrowVect );
				P.BaseEyeHeight = FMin( P.Default.BaseEyeHeight, P.BaseEyeHeight * (0.5 + FRand()) );
			}
			P = P.nextPawn;
		}
				
		if ( RemainingTime > 0.5 )
			SetTimer( 0.5, false, 2 );
	}
}	

defaultproperties
{
	 ImpactForce=10000
     Magnitude=100.0
     duration=5.0
     radius=300.0
     bThrowPlayer=true
     bStatic=False
	 Elasticity=0.8
	 RevibrateTime=0.2
	 RevibrateRandom=0.3
	 VibrationPeriod=0.006
}
