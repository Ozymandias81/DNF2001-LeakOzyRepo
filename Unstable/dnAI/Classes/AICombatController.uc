/*=============================================================================
	AICombatController
	Author: Jess Crable

	This actor distributes orders to groups of attacking Grunts.
=============================================================================*/
class AICombatController extends Info;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

struct SPawnInfo
{
	var AIPawn	MyPawn;
	var float	LastRequestTime;
	var bool	bHunting;
};

var SPawnInfo PawnInfo[ 16 ];

var AIPawn			MyPawns[ 16 ];

struct SOccupiedInfo
{
	var CoverSpot	OccupiedPoint;
	var Pawn			OccupiedBy;
};

var SOccupiedInfo OccupiedInfo[ 32 ];
var CoverSpot	OccupiedPoints[ 32 ];
var bool			bSleeping;
	
var() bool	bHandSignalsEnabled						?( "Hand signals may be used by grunts." );
var() float	OrderFrequency							?( "How often (in seconds) orders may be distributed to Grunts." );

const MaxPawns = 15;
const MaxOccupiedPoints = 31;

function PostBeginPlay()
{
	// // // // log( "Combat Controller "$self$" spawned at "$Level.TimeSeconds );
	Initialize();
	// // // // log( "MY TAG IS "$Tag );
}


function WarnFriends( Pawn WarningPawn, Actor NewEnemy )
{
	local int i;
	// // // log( "*** WARN FRIENDS" );
	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn != None )
		{		
			if( PawnInfo[ i ].MyPawn.GetStateName() == 'Patrolling' && !Grunt( PawnInfo[ i ].MyPawn ).bPatrolIgnoreSeePlayer )
			{
				if( PawnInfo[ i ].MyPawn.Enemy == None )
				{
					// log( self$" Warning friend "$PawnInfo[ i ].MyPawn );
					PawnInfo[ i ].MyPawn.Enemy = NewEnemy;
					PawnInfo[ i ].MyPawn.GotoState( 'Acquisition' );
				}
			}
		}
		else
			break;
	}
}

function bool IsHunting( Pawn CheckPawn )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn == CheckPawn )
		{
			if( PawnInfo[ i ].bHunting )
				return true;
			else
				return false;
		}
	}
	return false;
}

function bool CanSetHunting()
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].bHunting )
		{
			// // // // log( "CanSetHunting returning FALSE" );
			return false;
		}
	}
	// // // // log( "CanSetHunting returning TRUE" );
	return true;
}

function UnsetHunting( Pawn HuntPawn )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn == HuntPawn )
		{
			// // // // log( "UnsetHunting "$HuntPawn );
			PawnInfo[ i ].bHunting = false;
			if( HuntPawn != None )
				Grunt( HuntPawn ).bCamping = false;
			break;
		}
	}
}

function bool SetHunting( Pawn HuntPawn )
{
	local int i;

	if( CanSetHunting() )
	{
		for( i = 0; i <= 15; i++ )
		{
			if( PawnInfo[ i ].MyPawn == HuntPawn )
			{
				// // // // log( "HuntPawn "$HuntPawn$" SET TO HUNTING" );
				PawnInfo[ i ].bHunting = true;
				return true;
			}
		}
	}
	return false;
}

/* Initialize only works for Pawns already in the game. It's up to the pawns to attempt to add themselves when
   they are spawned from a creature factory.*/
function Initialize()
{
	local int i;
	local Pawn P;
	local AIPawn AIP;

	for( P = Level.PawnList; P != None; P = P.NextPawn )
	{
		if( P.IsA( 'AIPawn' ) )
		{
			AIP = AIPawn( P );
			// // // // log( "Test: "$AIP.ControlTag );

			if( AIP.ControlTag == Tag )
			{
				PawnInfo[ i ].MyPawn = AIP;
				if( i > MaxPawns )
				{
					// // // // log( "** Error: Not enough slots in Controller Pawn array for tag "$Tag );
					break;
				}
				else
					i++;
			}
		}
	}
}

// Called by pawns spawned from CreatureFactories.
function bool AddPawn( AIPawn NewPawn )
{
	local int i;

	for( i = 0; i <= MaxPawns; i++ )
	{
		if( PawnInfo[ i ].MyPawn == None )
		{
			PawnInfo[ i ].MyPawn = NewPawn;
			return true;
		}
	}
	return false;
}

function EncroachedGrunt( CoverSpot OccupiedPoint, Pawn OccupiedBy, optional bool bEmergency )
{
	local int i;
	local CoverSpot TempCoverSpot;

	// log( OccupiedBy$" was encroached. CurrentCoverSpot was "$Grunt( OccupiedBy ).CurrentCoverSpot );

	for( i = 0; i <= 32; i++ )
	{
		if( OccupiedInfo[ i ].OccupiedPoint == OccupiedPoint )
		{
			TempCoverSpot = Grunt( OccupiedBy ).CurrentCoverSpot;
			Grunt( OccupiedBy ).CurrentCoverSpot = FindEmergencyCoverFor( Grunt( OccupiedBy ) );
			if( Grunt( OccupiedBy ).CurrentCoverSpot == TempCoverSpot || ( Grunt( Occupiedby ).CurrentCoverSpot == None && !bEmergency ) )
			{
				 // // log( "CurrentCoverSpot: "$Grunt( OccupiedBy ).CurrentCoverSpot );
				 // // log( "TempCoverSpot   : "$TempCoverSpot );
				 // // log( "bEmergency      : "$bEmergency );

				 // // log( "Found SAME coverspot." );
				Grunt( OccupiedBy ).ChooseAttackState();
			}
			else
			{
				// // log( "ENCROACH MOVE" );
			 // // log( "EnCrouch MoveToPoint 1 for "$OccupiedBy );

				FindCommunicationTargetFor( Grunt( OccupiedBy ) );
				OccupiedBy.GotoState( 'ControlledCombat', 'MoveToPoint' );
				SetPointOccupied( Grunt( OccupiedBy ).CurrentCoverSpot, OccupiedBy );
				Grunt( OccupiedBy ).bCoverOnAcquisition = false;
			}
			break;
		}
		if( OccupiedBy.GetStateName() == 'TakeHit'  )
		{
			Grunt( OccupiedBy ).PlayToWaiting( 0.12 );
			Grunt( OccupiedBy ).PlayWeaponIdle( 0.12 );
			Grunt( OccupiedBy ).ChooseAttackState();
		}
		// // // log( "Everything failed." );
	}
}


function SetPointUnoccupied( CoverSpot OccupiedPoint, Pawn OccupiedBy )
{
	local int i;

	// // // // log( "SetPointUnoccupied called for "$OccupiedBy );

	for( i = 0; i <= 31; i++ )
	{
		if( OccupiedInfo[ i ].OccupiedPoint == OccupiedPoint )
		{
			OccupiedInfo[ i ].OccupiedPOint = None;
			//Grunt( OccupiedBy ).CurrentCoverSpot.bOccupied = false;
			//Grunt( OccupiedBy ).CurrentCoverSpot.OccupiedBy = None;
			//Grunt( OccupiedBy ).CurrentCoverSpot = None;
		}
	}
}

function bool SetPointOccupied( CoverSpot OccupiedPoint, Pawn OccupiedBy )
{
	local int i;

	// // // // log( "Combat controller setting point "$OccupiedPoint$" to occupied" );

	for( i = 0; i <= 32; i++ )
	{
		if( OccupiedInfo[ i ].OccupiedPoint == None )
		{
			OccupiedInfo[ i ].OccupiedPoint = OccupiedPoint;
			OccupiedInfo[ i ].OccupiedBy = OccupiedBy;
			// // // // log( "=== Set point "$OccupiedInfo[ i ].OccupiedPoint$" to occupied by "$OccupiedBy );
			return true;
		}
	}
	return false;
}

function SetLastOrderTime( Pawn MyPawn )
{
	local int i;
	
	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn == MyPawn )
		{
			PawnInfo[ i ].LastRequestTime = Level.TimeSeconds;
		}
	}
}

function CoverSpot FindEmergencyCoverFor( AIPawn OrderPawn )
{
	local CoverSpot NP;

	// // // log( "FIND EMERGENCY COVER FOR "$OrderPawn );

	if( OrderPawn.GetStateName() == 'Patrolling' )
		return None;

/*	if( Grunt( OrderPawn ).CurrentCoverSpot != None && Grunt( OrderPawn ).CurrentCoverSpot.NextLogicalSpotTag != '' )
	{
	// // // log( "FIND EMERGENCY COVER FOR 2 "$OrderPawn );

		// // // log( "Already have a coverspot, checking next logical coverspot" );

		foreach allactors( class'CoverSpot', NP )
		{
			if( !NP.bOccupied && Grunt( OrderPawn ).CurrentCoverSpot.NextLogicalSpotTag == NP.Tag && Grunt( OrderPawn ).EvaluateCoverSpot( NP ) )
			{
				// // // log( "Special returning "$NP );
				return NP;
			}
		}
	}
*/
	foreach allactors( class'CoverSpot', NP )
	{
	// // // log( "FIND EMERGENCY COVER FOR 3 "$OrderPawn );

		// // // // log( "FindEmergencyCover checking Spot "$NP );
		// // // // log( "Dist 1: "$VSize( OrderPawn.Location - NP.Location ) );
		// // log( "TEsting: "$NP );
		// // log( "Test Occupied: "$NP.bOccupied );
		 // // log( "Test Eval    : "$Grunt( OrderPawn ).EvaluateCoverSpot( NP ) );
		
	//if( !NP.bOccupied /*!IsOccupied( NP ) &&*/ &&  Grunt( OrderPawn ).EvaluateCoverSpot( NP ) && ( !NP.bMustSeeEnemyFrom || HumanNPC( OrderPawn ).CanSeeEnemyFrom( NP.Location ) ) )
	if( !NP.bOccupied /*!IsOccupied( NP ) &&*/ &&  Grunt( OrderPawn ).EvaluateCoverSpot( NP ) ) //&& ( !HumanNPC( OrderPawn ).CanSeeEnemyFrom( NP.Location ) ) )
		 {
			 log( "FindEmergencyCoverFor "$OrderPawn$" returning "$NP );
			return NP;
		}
	}
	// // log( "FindEmergencyCover returning NONE retest: "$Grunt( OrderPawn ).EvaluateCoverSpot( NP ) );

	return None;
}

function CoverSpot FindCoverFor( AIPawn OrderPawn )
{
	local CoverSpot NP;

	// // // // log( "** Find Cover for "$OrderPawn$" called with CoverTag of "$OrderPawn.CoverTag );
	if( OrderPawn.CoverTag != '' )
	{
		foreach allactors( class'CoverSpot', NP )
		{
			// // // // log( "Checking coverspot "$NP$" with tag "$NP.Tag );

			if( OrderPawn.CoverTag == NP.Tag && !IsOccupied( NP ) && ( VSize( OrderPawn.Location - NP.Location ) > 72 ) )
			{
				log( "FindCoverFor "$OrderPawn$" returning "$Grunt( OrderPawn ).GetClosestCoverSpot() );
				return Grunt( OrderPawn ).GetClosestCoverSpot();
			}
		}
	}
	// // // // log( "** Find Cover for "$OrderPawn$" returning NONE" );
	return None;
}

function bool IsOccupied( CoverSpot TestPoint )
{
	local int i;

	for( i = 0; i <= 31; i++ )
	{
		if( OccupiedInfo[ i ].OccupiedPoint == TestPoint || TestPoint.bOccupied )
		{
			// // // // log( "Is Occupied returning true" );
			return true;
		}
	}
	return false;
}

function SetOccupied( float OccupiedTime )
{
	Enable( 'Timer' );
	
	bSleeping = true;
	SetTimer( OccupiedTime, false );
}

function Timer( optional int TimerNum )
{
	// // // // log( "Combat Controller waking up." );
	Disable( 'Timer' );
	bSleeping = false;
}

function bool CheckLastOrderTime( AIPawn CheckPawn )
{
	local int i;

	if( CheckPawn.bCamping )
		return false;

	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn == CheckPawn )
		{
			if( Level.TimeSeconds - PawnInfo[ i ].LastRequestTime > 3 )
			{
				// // // // log( "Check last order time returning true for "$checkpawn );
				return true;
			}
			else
			{
				// // // // log( "check last order time returning false for "$checkpawn );
				return false;
			}
		}
	}
	// // // // log( "Check last order time returning flase 2 for "$checkpawn );
	return false;
}

function float GetLastOrderTime( Pawn OrderPawn )
{
	local int i;

	for( i = 0; i <= 15; i++ )
	{
		if( PawnInfo[ i ].MyPawn == OrderPawn )
		{
			return PawnInfo[ i ].LastRequestTime;
		}
	}
	return 0.0;
}

function FindCommunicationTargetFor( Grunt OrderGrunt )
{
	local int i;

	if( !bHandSignalsEnabled )
		return;

	// // // // log( "PawnInfo[ i ].MyPawn: "$PawnInfo[ i ].MyPawn );
	// // // // log( "OrderGrunt: "$OrderGrunt );

	for( i = 0; i <= 15; i++ )
	{
		// // // log( "FindCommTarg 1" );
		if( OrderGrunt == None )
			break;
		// // // log( "FindCommTarg 2" );
		if( PawnInfo[ i ].MyPawn != None && PawnInfo[ i ].MyPawn != OrderGrunt && PawnInfo[ i ].MyPawn.LineOfSightTo( OrderGrunt ) )
		{
		// // // log( "FindCommTarg 3" );
			if( !PawnInfo[ i ].MyPawn.IsInState( 'Reloading' ) && PawnInfo[ i ].MyPawn.MoveTimer < 0.0 )
			{
		// // // log( "FindCommTarg 4" );
				OrderGrunt.bWaitForOrder = true;
		// // // log( "FindCommTarg 5" );
		// // // log( "Test 5: "$OrderGrunt );
		// // // log( "Test 5a: "$Grunt( PawnInfo[ i ].MyPawn ) );
		if( Grunt( PawnInfo[ i ].MyPawn ) != None ) 		
		{
			Grunt( PawnInfo[ i ].MyPawn ).OrderTarget = OrderGrunt;
			Grunt( PawnInfo[ i ].MyPawn ).GotoState( 'GiveOrder' );
		}
					// // // log( "FindCommTarg 7" );
				break;
			}
		}
	}
}

function CombatDecision( AIPawn OrderPawn )
{
	local Grunt OrderGrunt;
	local NPC	OrderNPC;

	// // // broadcastmessage( "%% Combat Decision called for "$OrderPawn );
	// // // log( "%% Combat Decision 1 for "$self );
	if( OrderPawn.bForcedAttack ) //|| Grunt( OrderPawn ).bKneelAtStartup )
	{
		// // // log( "%% Combat Decision 2 for "$self );
		// // // broadcastmessage( "Combat Decision rejecting orders for "$OrderPawn );
		return;
	}

	if( bSleeping )
	{
		 // // // log( "%% Combat Decision 3 for "$self );
		 // // // broadcastmessage( "Combat Controller sleeping, aborting for "$OrderPawn );
		return;
	}
	
	if( Grunt( OrderPawn ) != None )
	{
		 // // // log( "%% Combat Decision 4 for "$self );
		OrderGrunt = Grunt( OrderPawn );
		 // // // log( "%% Combat Decision 4a for "$self );
		// // // log( "Test 4a: OrderGrunt: "$OrderGrunt );

		if( OrderGrunt != None && OrderGrunt.bCoverOnAcquisition )
		{
			 // // // log( "%% Combat Decision 5 for "$self );
			// // // broadcastmessage( "Combat Controller decision 1 "$OrderPawn );

			OrderGrunt.CurrentCoverSpot = FindCoverFor( OrderPawn );
			OrderGrunt.bCoverOnAcquisition = false;
			//if( FRand() < 0.25 )
			if( OrderGrunt.CurrentCoverSpot != None )
			{
				// // // log( "EnCrouch MoveToPoint 2 for "$OrderGrunt );
				FindCommunicationTargetFor( OrderGrunt );
				OrderGrunt.GotoState( 'ControlledCombat', 'MoveToPoint' );
				SetPointOccupied( OrderGrunt.CurrentCoverSpot, OrderGrunt );
				OrderGrunt.bCoverOnAcquisition = false;
			}
		}
		else if( Ordergrunt != None && ( !OrderGrunt.bCamping || OrderGrunt.CanSee( OrderGrunt.Enemy ) ) && OrderGrunt.CurrentCoverSpot != None && OrderGrunt.CurrentCoverSpot.bStrafeCover )
		{
			 // // // log( "%% Combat Decision 6 for "$self );
			 // // // broadcastmessage( "Combat Controller decision 3 "$OrderPawn );

			SetPointUnoccupied( OrderGrunt.CurrentCoverSpot, OrderGrunt );

			if( FRand() < 0.5 )
			{
				 // // // log( "%% Combat Decision 7 for "$self );
				OrderGrunt.GotoState( 'DodgeSideStep' );
			}
			else 
			{
				 // // // log( "%% Combat Decision 8 for "$self );
				OrderGrunt.GotoState( 'DodgeRoll' );
			}
		}
		else if( OrderGrunt != None && OrderGrunt.CurrentCoverSpot == None && OrderGrunt.CoverTag != '' )
		{
			// // // broadcastmessage( "Combat Controller decision 4 "$OrderPawn );
			 // // // log( "%% Combat Decision 9 for "$self );
			OrderGrunt.CurrentCoverSpot = FindCoverFor( OrderPawn );
			if( OrderGrunt.CurrentCoverSpot != None )
			{
				 // // // log( "%% Combat Decision 10 for "$self );
				//if( FRand() < 0.25 )
					FindCommunicationTargetFor( OrderGrunt );
				// // // log( "EnCrouch MoveToPoint 3 for "$OrderGrunt );

					OrderGrunt.GotoState( 'ControlledCombat', 'MoveToPoint' );
				SetPointOccupied( OrderGrunt.CurrentCoverSpot, OrderGrunt );
			}
//		}
			else
			{
				 // // // log( "%% Combat Decision 11 for "$self );
				if( OrderGrunt.GetPostureState() != PS_Crouching && !OrderGrunt.bCrouchShiftingDisabled && FRand() < 0.17 )
				{
					// // // broadcastmessage( "FORCING CROUCH" );
					 // // // log( "%% Combat Decision 12 for "$self );
					OrderGrunt.GotoState( 'ControlledCombat', 'Crouch' );
					OrderGrunt.bKneelAtStartup = true;
				}
				else if( OrderGrunt.GetPostureState() == PS_Crouching && !OrderGrunt.bCrouchShiftingDisabled && FRand() < 0.33 )
				{
					// // // broadcastmessage( "FORCING STAND" );
					 // // // log( "%% Combat Decision 13 for "$self );
					OrderGrunt.GotoState( 'ControlledCombat', 'Stand' );
					OrderGrunt.bKneelAtStartup = false;
				}
		
				//// // // broadcastmessage( "Combat Controller decision 6 "$OrderPawn );
				else if( FRand() < 0.3 )
				{
					// // // log( "%% Combat Decision 15 for "$self );
					SetOccupied( OrderFrequency );
					SetLastOrderTime( OrderPawn );
					OrderGrunt.ChooseAttackState();
					return;
				}
//				else
//				{
					// // // log( "%% Combat Decision 16 for "$self );
					if( SetHunting( OrderGrunt ) && !OrderGrunt.CanSee( OrderGrunt.Enemy ) )
					{
							 // // // log( "%% Combat Decision 17 for "$self );
						 // // // broadcastmessage( "HUNTING 1" );
							OrderGrunt.GotoState( 'Hunting' );
							SetOccupied( OrderFrequency );
							SetLastOrderTime( OrderPawn );
						return;
				}
//				}
			}
		}
		
		else if( !OrderGrunt.CanSee( OrderGrunt.Enemy ) && OrderGrunt.GetPostureState() != PS_Crouching && !OrderGrunt.bCrouchShiftingDisabled && FRand() < 0.33 )
		{
			 // // // log( "%% Combat Decision 18 for "$self );
			// // // broadcastmessage( "FORCING CROUCH" );
			OrderGrunt.GotoState( 'ControlledCombat', 'Crouch' );
			OrderGrunt.bKneelAtStartup = true;
		}
		else if( OrderGrunt.GetPostureState() == PS_Crouching && !OrderGrunt.bCrouchShiftingDisabled && FRand() < 0.33 )
		{
			// // // broadcastmessage( "FORCING STAND" );
			 // // // log( "%% Combat Decision 19 for "$self );
			OrderGrunt.GotoState( 'ControlledCombat', 'Stand' );
			OrderGrunt.bKneelAtStartup = false;
		}
		else if( SetHunting( OrderGrunt ) && !OrderGrunt.CanSee( OrderGrunt.Enemy ) && !Ordergrunt.bCamping && OrderGrunt.CoverController == None )
		{
				 // // // log( "%% Combat Decision 20 for "$self );
			// // // broadcastmessage( "HUNTING 2" );
				OrderGrunt.GotoState( 'Hunting' );
		}
		// // // log( "%% Combat Decision 25 for "$self );
		SetLastOrderTime( OrderPawn );
				// // // log( "%% Combat Decision 26 for "$self );
	}
	else if( NPC( OrderPawn ) != None )
	{
		// // // log( "%% Combat Decision 27 for "$self );
		OrderNPC = NPC( OrderPawn );
	}
			// // // log( "%% Combat Decision 28 for "$self );
	SetOccupied( OrderFrequency );
	// // // // log( "%% Combat Decision 21 for "$self );
}

DefaultProperties
{
     bHandSignalsEnabled=true
     OrderFrequency=0.500000
     Texture=Texture'DukeED_Gfx.AICombatController'
}
