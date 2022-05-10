//=============================================================================
// TriggerAssignNode.uc
//
// Used to manipulate pathnode properties.
//=============================================================================
class TriggerAssignNode expands TriggerAssign;

var( Node ) bool	UseCoverPoint ?("Determines whether or not to use the bCoverPoint flag.");
var( Node ) bool	bCoverPoint ?("If true, the node will be flagged as a Cover Point.");
var( Node ) bool	UseDuckPoint ?("Determines whether or not to use the bDuckPoint flag.");
var( Node ) bool	bDuckPoint ?("If true, the node will be flagged as a Duck Point.");
var( Node ) bool	UseExitOnCantSee ?("Determines whether or not to use the bExitOnCantSee flag.");
var( Node ) bool	bExitOnCantSee ?("If false, the NPC will remain at Cover Point even after line of\nsight is lost. No hunting occurs.");
var( Node ) bool	UseExitDistance ?("Determines whether or not to use the bExitOnDistance flag.");
var( Node ) bool	bExitOnDistance ?("If true, Covering NPC will hunt enemy once enemy is passed the\nExitDistance threshhold.");
var( Node ) float	ExitDistance ?("Distance (in units) enemy needs to be away before Covering NPC begins hunt.");
var( Node ) bool	UseOffsetDistance ?("Determines whether to use the OffsetDistance value.");
var( Node ) float	OffsetDistance ?("If used, OffsetDistance is a distance NPC can be from this point\nfor it to still be considered reached.");
var( Node ) bool	UseExitWhenClose ?("Determines whether or not to use the bExitWhenClose flag.");
var( Node ) bool	bExitWhenClose ?("If used, NPC will abandon a Cover or Duck Point when enemy is too close.");
var( Node ) bool	UseExtraCost ?("Determines whether or not to use the Extra Cost flag.");
var( Node ) float	ExtraCost ?("Extra cost added to node. Very high values result in NPC not being\nable to build a path. Useful to keep NPCs temporarily out of\nan area.");

var( Node ) bool	bKickNPCOffNode ?("Forcibly removes NPC from a Cover Point or Duck Point.");

function Trigger( actor Other, pawn EventInstigator )
{
	local NavigationPoint NavPoint;

//	log( "Trigger "$self$" triggered." );

	Super.Trigger( Other, EventInstigator );

	if( Event != '' )
	{
		for( NavPoint = Level.NavigationPointList; NavPoint != None; NavPoint = NavPoint.NextNavigationPoint )
		{
			if( NavPoint.Tag == Event )
			{
			//	log( "--- "$self$" adjusting navpoint "$NavPoint );

				if( UseCoverPoint )
					NavPoint.bCoverPoint = bCoverPoint;
				if( UseDuckPoint )
					NavPoint.bDuckPoint = bDuckPoint;
				if( UseExitOnCantSee )
					NavPoint.bExitOnCantSee = bExitOnCantSee;
				if( UseExitDistance )
				{
					NavPoint.bExitOnDistance = bExitOnDistance;
					NavPoint.ExitDistance = ExitDistance;
				}
				if( UseExitWhenClose )
					NavPoint.bExitWhenClose = bExitWhenClose;
				if( UseExtraCost )
					NavPoint.ExtraCost += ExtraCost;
				if( UseOffsetDistance )
					NavPoint.Offsetdistance = OffsetDistance;
			}
			if( bKickNPCOffNode )
			{
				RemoveNPCFrom( NavPoint );
			}	
		}
	}
}

function RemoveNPCFrom( NavigationPoint NP )
{
	local Pawn P;
	local Grunt NPC;

	for( P = Level.PawnList; P != None; P = P.NextPawn )
	{
		NPC = Grunt( P );

		if( NPC != None )
		{
			if( NPC.MyCoverPoint == NP )
			{
				//log( "--- "$self$" kicking NPC ( "$NPC$" ) off of CoverPoint "$NP );
				NPC.MyCoverPoint = None;
				NPC.bAtDuckPoint = false;
				NPC.bAtCoverPoint = false;
				// Do we really want this? (below)
				if( NPC.Enemy != None )
					NPC.bCoverOnAcquisition = true;
			}
		}
	}
}


defaultproperties
{
     Texture=Texture'Engine.S_TriggerAssign'
}
