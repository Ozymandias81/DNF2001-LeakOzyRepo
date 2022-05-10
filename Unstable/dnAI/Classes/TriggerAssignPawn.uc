//=============================================================================
// TriggerAssignPawn.
//=============================================================================
class TriggerAssignPawn expands TriggerAssign;

#exec OBJ LOAD FILE=..\Textures\DukeED_Gfx.dtx

// Defaults to using enemy tag; optional NewEnemyClass and UseEnemyClass will use a classname instead of the tag.
// Pawn Properties:
var( Pawn ) bool	UseNewEnemy;
var( Pawn ) name	NewEnemyTag;
var( Pawn ) class< Actor > NewEnemyClass;
var( Pawn ) bool	UseEnemyClass;
var( Pawn ) bool	bFixedEnemy;
var( Pawn ) bool	UseFixedEnemy;
var( Pawn ) bool	bAlwaysUseTentacles;
var( Pawn ) bool	bUseAlwaysUseTentacles;
var( Pawn ) bool	AssignSnatched;
var( Pawn ) bool	bPawnSnatched;
var( Pawn ) bool	AssignAggressiveToPlayer;
var( Pawn ) bool	bAggressiveToPlayer;
var( Pawn ) name	TopAnimation;
var( Pawn ) name	BottomAnimation;
var( Pawn ) name	AllAnimation;
var( Pawn ) Sound	SoundToPlay;
var( Pawn ) Name	FocusTag;
var( Pawn ) bool	AssignFocusOnPlayer;
var( Pawn ) bool	bFocusOnPlayer;
var( Pawn ) bool	AssignMouthExpression;
var( Pawn ) bool	AssignBrowExpression;
var( Pawn ) bool	AssignUseTrigEvent;
var( Pawn ) name	UseTriggerEvent;
var( Pawn ) bool	UseEventEnabled;
var( Pawn ) bool	AssignUseEvent;

var( Pawn ) bool	UseNewHateTag;
var( Pawn ) name	NewHateTag;
var( Pawn ) int		NewHealth;
var( Pawn ) bool	UseNewHealth;
var( Pawn ) bool	UseNPCInvulnerable;
var( Pawn ) bool	bNPCInvulnerable;
var( Pawn ) bool	UseNewIdlingAnim;
var( Pawn ) name	NewIdlingAnim;
var( Pawn ) bool	AssignJumpCower;
var( Pawn ) bool	bJumpCower;
var( Pawn ) bool	bPanicking;
var( Pawn ) bool	UsebPanicking;
var( Pawn ) int		WipeSearchableItems[5];
var( Pawn ) bool	bVisiblySnatched;
var( Pawn ) bool	UseVisiblySnatched;

var( PawnFace ) EFacialExpression	FacialExpression;
var( PawnFace ) bool				bUseFacialExpression;
var( PawnFace ) bool				bMakeFaceDefault;

var( AIFollow ) bool bStopWhenReached;
var( AIFollow ) bool UseStopWhenReached;
var( AIFollow ) float FollowOffset;
var( AIFollow ) bool UseFollowOffset;
var( AIFollow ) bool UseFollowTag;
var( AIFollow ) name FollowTag;
var( AIFollow ) bool bWalkFollow;
var( AIFollow ) bool UseWalkFollow;
var( AIFollow ) bool bTriggerFollow;
var( AIFollow ) bool bWanderAfterFollow;
var( AIFollow ) name FollowEvent;
var( AIFollow ) bool bFollowEventOnceOnly;

//var( Pawn ) sound	SoundToPlay;

enum EMouthExpression
{
	MOUTH_Normal,
	MOUTH_Smile,
	MOUTH_Frown,
};

enum EBrowExpression
{
	BROW_Normal,
	BROW_Raised,
	BROW_Lowered,
};

var( Pawn ) EMouthExpression	MouthExpression;
var( Pawn ) EBrowExpression		BrowExpression;

function SetNPCEnemy( HumanNPC NPC, optional name EnemyTag, optional class< Actor > EnemyClass )
{
	local actor A;

	if( EnemyTag != '' )
	{
		foreach allactors( class'Actor', A, EnemyTag )
		{
			NPC.bFixedEnemy = true;
			NPC.Enemy = A;
			NPC.PlayToWaiting();
			NPC.GotoState( 'Attacking' );
			break;
		}
	}
	else if( EnemyClass != None )
	{
		foreach allactors( EnemyClass, A )
		{
			NPC.bFixedEnemy = true;
			NPC.Enemy = A;
			NPC.PlayToWaiting();
			NPC.GotoState( 'Attacking' );
			break;
		}
	}
}

function SetCreatureEnemy( Pawn aCreature, optional name EnemyTag, optional class< Actor > EnemyClass )
{
	local actor A;

	if( EnemyTag != '' )
	{
		foreach allactors( class'Actor', A, EnemyTag )
		{
			aCreature.bFixedEnemy = true;
			aCreature.Enemy = A;
			if( aCreature.IsA( 'Turrets' ) )
				AIPawn( aCreature ).Activate( A );
			else
			if( aCreature.IsA( 'Snatcher' ) )
				aCreature.GotoState( 'Snatcher' );
			else 
				aCreature.GotoState( 'Hunting' );
			break;
		}
	}
	else if( EnemyClass != None )
	{
		foreach allactors( EnemyClass, A )
		{
			aCreature.bFixedEnemy = true;
			aCreature.Enemy = A;
			if( aCreature.IsA( 'Turrets' ) )
				AIPawn( aCreature ).Activate( A );
			else
			if( aCreature.IsA( 'Snatcher' ) )
				aCreature.GotoState( 'Snatcher' );
			else
				aCreature.GotoState( 'Hunting' );
			break;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local Pawn P;
	local HumanNPC NPC;
	local int i;

	Super.Trigger( Other, EventInstigator );

	if( Event != '' )
	{
		for( P = Level.PawnList; P != None; P = P.NextPawn )
		{
			if( P.Tag == Event )
			{
				if( bUseAlwaysUseTentacles )
				{
					AIPawn( P ).bAlwaysUseTentacles = bAlwaysUseTentacles;
				}
				if( UsebPanicking )
				{
					AIPawn( P ).bPanicking = bPanicking;
				}

				if( FollowEvent != '' )
				{
					AIPawn( P ).FollowEvent = FollowEvent;
					AIPawn( P ).bFollowEventOnceOnly = bFollowEventOnceOnly;
				}

				if( AssignSnatched )
				{
					P.bSnatched = bPawnSnatched;
				}
				if( UseFixedEnemy )
				{
					P.bFixedEnemy = bFixedEnemy;
				}

				if( UseNewEnemy )
				{
					if( !UseEnemyClass )
					{
						if( P.IsA( 'HumanNPC' ) )
						{
							SetNPCEnemy( HumanNPC( P ), NewEnemyTag );
						}
						else
							SetCreatureEnemy( P, NewEnemyTag );
					}
					else
					{
						if( P.IsA( 'HumanNPC' ) )
							SetNPCEnemy( HumanNPC( P ),, NewEnemyClass );
						else	
							SetCreatureEnemy( P,, NewEnemyClass );
					}
				}
				if( P.IsA( 'Turrets' ) )
				{
					if( UseNewHateTag )
					{
						AIPawn( P ).HateTag = NewHateTag;
						AIPawn( P ).TriggerHate();
					}
				}

				if( P.IsA( 'HumanNPC' ) )
				{
					NPC = HumanNPC( P );
					
					if( UseVisiblySnatched )
						NPC.bVisiblySnatched = bVisiblySnatched;

					if( bUseFacialExpression )
					{	
						NPC.SetFacialExpression( FacialExpression, bMakeFaceDefault );
					}

					if( bWanderAfterFollow )
					{
						NPC.bWanderAfterFollow = true;
					}

					if( UseStopWhenReached )
					{
						NPC.bStopWhenReached = bStopWhenReached;
					}	
					if( UseFollowTag )
					{
						NPC.FollowTag = FollowTag;
					}
					if( UseFollowOffset )
					{
						NPC.FollowOffset = FollowOffset;
					}
					if( UseWalkFollow )
					{
						NPC.bWalkFollow = bWalkFollow;
					}

					if( UseNewIdlingAnim )
					{
						NPC.InitialIdlingAnim = NewIdlingAnim;
					}	
	
					if( AssignJumpCower )
					{
						NPC.bJumpCower = bJumpCower;
					}

					if( UseNewHealth )
					{
						NPC.Health = NewHealth;
					}
				
					if( UseNPCInvulnerable )
					{
						NPC.bNPCInvulnerable = bNPCInvulnerable;
					}

					if( UseNewHateTag )
					{
						NPC.HateTag = NewHateTag;
					}

					if(	AssignUseEvent )
					{
						NPC.bCanBeUsed = UseEventEnabled;
					}

					if( AssignAggressiveToPlayer )
					{
						NPC.bAggressiveToPlayer = AssignAggressiveToPlayer;
					}
					if( AssignFocusOnPlayer )
					{
						NPC.bFocusOnPlayer = bFocusOnPlayer;
					}
					if( AssignMouthExpression )
					{
						if( MouthExpression == MOUTH_Normal )
							NPC.SetMouthExpression( 0 );
						if( MouthExpression == MOUTH_Smile )
							NPC.SetMouthExpression( 1 );
						if( MouthExpression == MOUTH_Frown )
							NPC.SetMouthExpression( 2 );
					}	
					if( AssignBrowExpression )
					{
						if( BrowExpression == BROW_Normal )
							NPC.SetBrowExpression( 0 );
						if( BrowExpression == BROW_Raised )
							NPC.SetBrowExpression( 1 );
						if( BrowExpression == BROW_Lowered )
							NPC.SetBrowExpression( 2 );
					}
					if(	AssignUseTrigEvent )
					{
						NPC.UseTriggerEvent = UseTriggerEvent;
					}
					for (i=0; i<5; i++)
					{
						if (WipeSearchableItems[i] > 0)
							NPC.SearchableItems[i] = none;
					}
				/* Not necessary?
					NPC.PendingTopAnimation = TopAnimation;
					NPC.PendingBottomAnimation = BottomAnimation;
					NPC.PendingAllAnimation = AllAnimation;
					NPC.PendingSound = SoundToPlay;
					NPC.PendingFocusTag = FocusTag;
					NPC.TransitionToControlledState();
				*/
					if( bTriggerFollow )
					{
						NPC.TriggerFollow();
					}
				}
			}
		}
	}
}

defaultproperties
{
     //Texture=Texture'DukeED_Gfx.TriggerAssignPawn'
	Texture=Texture'Engine.S_TriggerAssign'
}
