//=============================================================================
// TeamTrigger: triggers for all except pawns with matching team
//=============================================================================
class TeamTrigger extends Trigger;

var() byte Team;
var() bool bTimed;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( bTimed )
		SetTimer(2.5, true);
}

function Timer()
{
	local Pawn P;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if ( (abs(Location.Z - P.Location.Z) < CollisionHeight + P.CollisionHeight)
			&& (VSize(Location - P.Location) < CollisionRadius) )
			Touch(P);
	SetTimer(2.5, true);
}

function bool IsRelevant( actor Other )
{
	if( !bInitiallyActive || !Level.Game.IsA('TeamGamePlus') || (Other.Instigator == None) 
		|| TeamGamePlus(Level.Game).IsOnTeam(Other.Instigator, Team) )
		return false;
	Super.IsRelevant(Other);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	if ( (InstigatedBy != None) && Level.Game.IsA('TeamGamePlus')
		&& !TeamGamePlus(Level.Game).IsOnTeam(InstigatedBy, Team) )
		Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}