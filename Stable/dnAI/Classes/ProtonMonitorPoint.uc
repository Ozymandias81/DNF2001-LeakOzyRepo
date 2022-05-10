class ProtonMonitorPoint extends SpecialNavPoint;

var bool bTaken;

var() bool				bAutoInitialize ?( "Auto initialize the reachable points." );
var() name				AccessiblePointTags[ 16 ];
var SpecialNavPoint		AccessiblePoints[ 16 ];
	var ProtonGun Gun1, Gun2, Gun3, Gun4;

function PostBeginPlay()
{
	AutoInitializePoints();
	DumpReachablePoints();
	SetTimer( 2.0, false );
}

function Timer( optional int TimerNum )
{
	SetCollisionSize( Default.CollisionRadius, Default.CollisionHeight );
	SetCollision( Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers );
}

function bool CanSeePoint( SpecialNavPoint TestPoint )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local vector StartX, StartY, StartZ;
	local vector X, Y, Z, FinalOne, FinalTwo, STart, X2, Y2, Z2;
	local vector Loc1, Loc2, Loc3, Loc4, Loc5, Loc6, Loc7, Loc8;

	// Turn on collision settings for this point and point to be tested. They'll be automatically
	// turned off again by a timer in 2 seconds (blech).
	TestPoint.SetCollision( true, true, true );
	TestPoint.bProjTarget = true;
	TestPoint.SetcollisionSize( 128, 128 );
	SetcollisionSize( 128, 128 );
	SetCollision( true, true, true );
	bProjTarget = true;

	// Get 4 points roughly the size of the ProtonMonitor at this point and TestPoint location
	// and trace from each point to see if the monitor will fit through.
	GetAxes( rotator( normal( TestPoint.Location - Location ) ), X,Y,Z );

	Loc1 = Location + ( ( 128 ) * Y );
	Loc2 = Location - ( ( 128 ) * Y );
	Loc3 = Location + ( ( 128 ) * Z );
	Loc4 = Location - ( ( 128 ) * Z );

	GetAxes( rotator( normal( Location - TestPoint.Location ) ), X2, Y2, Z2 );

	Loc5 = TestPoint.Location + ( ( 128 ) * Y2 );
	Loc6 = TestPoint.Location - ( ( 128 ) * Y2 );
	Loc7 = TestPoint.Location + ( ( 128 ) * Z2 );
	Loc8 = TestPoint.Location - ( ( 128 ) * Z2 );

	HitActor = Trace( HitLocation, HitNormal, Loc5, Loc1, true );
	
	if( HitActor == TestPoint )
	{
		HitActor = Trace( HitLocation, HitNormal, Loc6, Loc2, true );
		if( HitActor == TestPoint )
		{
			HitActor = Trace( HitLocation, HitNormal, Loc7, Loc3, true );
			if( HitActor == TestPoint )
			{
				HitActor = Trace( HitLocation, HitNormal, Loc8, Loc4, true );
			}
			if( HitActor == TestPoint )
			{
				return true;
			}
		}
	}
	return false;
}

function int GetReachablePointCount()
{
	local int i, Count;

	Count = 1;

	for( i = 0; i <= 15; i++ )
	{
		if( AccessiblePoints[ i ] != None )
		{
			Count++;
		}
		else
			break;
	}
	return Count;
}

function SpecialNavPoint GetRandomReachablePoint()
{
	local int i;

	i = Rand( GetReachablePointCount() - 1 );
	//log( "GetRandomReachablePoint for "$self$" is returning "$AccessiblePoints[ i ] );
	return AccessiblePoints[ i ];
}


function AutoInitializePoints()
{
	local int i;
	local SpecialNavPoint CurrentPoint;
	local actor HitActor;
	local vector HitLocation, HitNormal;
	
	foreach allactors( class'SpecialNavPoint', CurrentPoint )
	{
		if( CurrentPoint != self )
		{
			if( CanSeePoint( CurrentPoint ) )
			{
				AccessiblePoints[ i ] = CurrentPoint;
				if( i > 15 )
					break;
				else
					i++;
			}
		}
	}
}

function InitializePoints()
{
	local int i;
	local int r;

	for( i = 0; i <= 15; i++ )
	{
		if( AccessiblePointTags[ i ] != '' )
		{
			AccessiblePoints[ i ] = SpecialNavPoint( FindActorTagged( class'SpecialNavPoint', AccessiblePoints[ i ].Tag ) );	
		}
	}
}

function DumpReachablePoints()
{
	local int i;

	log( "=================================" );
	log( "Reachable Points for "$self );
	log( "=================================" );
	for( i = 0; i <= 15; i++ )
	{
		if( AccessiblePoints[ i ] != None )
		{
			log( AccessiblePoints[ i ]$" is accessible to me." );
		}
	}
	log( "=================================" );
}

DefaultProperties
{
     bDirectional=true
}
