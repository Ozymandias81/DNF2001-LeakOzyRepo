//=============================================================================
// SnatcherNest.uc
//-----------------------------------------------------------------------------
// This is just an invisible actor.
//=============================================================================

class SnatcherNest expands Info;

var Snatcher NestLeader;
var Snatcher Minions[ 32 ];
/*
function PostBeginPlay()
{
	if( CreateBrood() )
	{
		SetTimer( 5.0, true );
	}
	else
		Destroy();
}

function ScatterBrood()
{
	local int CurrentIndex;

	for( CurrentIndex = 0; CurrentIndex <= 31; CurrentIndex++ )
	{
		if( Minions[ CurrentIndex ] != None )
		{
			Minions[ CurrentIndex ].GotoState( 'Roaming', 'Scatter' );
		}
		else
			break;
	}
}

function bool CreateBrood()
{
	local Snatcher S, CurrentSnatcher;
	local bool bPickedLeader;
	local int CurrentIndex;

	foreach allactors( class'Snatcher', S )
	{
		if( S.MyNest == self && !bPickedLeader && S.Health > 0 )
		{
			NestLeader = S;
			S.bIsLeader = true;
			// Make leader bigger.
			S.DrawScale = 1.5;
			bPickedLeader = true;
		}
		else if( S.MyNest == self )
		{
			Minions[ CurrentIndex ] = S;
			Minions[ CurrentIndex ].PulseFrequency = 0;
			CurrentIndex++;
		}
	}
	if( Minions[ 0 ] != None )
	{
		return true;
	}
	return false;
}

function Timer( optional int TimerNum )
{
	if( NestLeader != None )
	{
		//if( NestLeader.InterestActor != None )
		//{
		//	if( FRand() < 0.5 )
		//	{
		//		NestLeader.InterestActor = None;
		//	}
		//}
	}
	else
	{
		CreateBrood();
	}
}

function NotifyMinions( actor Other )
{
	local int CurrentIndex;

	for( CurrentIndex = 0; CurrentIndex <= 31; CurrentIndex++ )
	{
		if( Minions[ CurrentIndex ] != None )
		{
//			Minions[ CurrentIndex ].InterestActor = Other;
//			Minions[ CurrentIndex ].GotoState( 'Roaming', 'HandleOrders' );
		}
		else
			break;
	}
}
*/



	

DefaultProperties
{
}

