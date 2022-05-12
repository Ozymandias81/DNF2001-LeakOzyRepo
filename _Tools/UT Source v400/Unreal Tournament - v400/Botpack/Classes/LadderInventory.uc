class LadderInventory extends Inventory;

// Game
var travel int			Slot;					// Savegame slot.

// Ladder
var travel int			TournamentDifficulty;
var travel int			PendingChange;			// Pending Change 
												// 0 = None  1 = DM
												// 2 = CTF   3 = DOM
												// 4 = AS
var travel int			PendingRank;
var travel int			PendingPosition;
var travel int			LastMatchType;
var travel Class<Ladder> CurrentLadder;

// Deathmatch
var travel int			DMRank;						// Rank in the ladder.
var travel int			DMPosition;					// Position in the ladder.

// Capture the Flag
var travel int			CTFRank;
var travel int			CTFPosition;

// Domination
var travel int			DOMRank;
var travel int			DOMPosition;

// Assault
var travel int			ASRank;
var travel int			ASPosition;

// Challenge
var travel int			ChalRank;
var travel int			ChalPosition;

// TeamInfo
var travel class<RatedTeamInfo> Team;

var travel int			Face;
var travel string		Sex;

var travel string		SkillText;
		
function Reset()
{
	TournamentDifficulty = 0;
	PendingChange = 0;
	PendingRank = 0;
	PendingPosition = 0;
	LastMatchType = 0;
	CurrentLadder = None;
	DMRank = 0;
	DMPosition = 0;
	CTFRank = 0;
	CTFPosition = 0;
	DOMRank = 0;
	DOMPosition = 0;
	ASRank = 0;
	ASPosition = 0;
	ChalRank = 0;
	ChalPosition = 0;
	Face = 0;
	Sex = "";
}

function TravelPostAccept()
{
	if (DeathMatchPlus(Level.Game) != None)
	{
		Log("LadderInventory: Calling InitRatedGame");
		DeathMatchPlus(Level.Game).InitRatedGame(Self, PlayerPawn(Owner));
	}
}

function GiveTo( Pawn Other )
{
	Log(Self$" giveto "$Other);
	Super.GiveTo( Other );
}

function Destroyed()
{
	Log("Something destroyed a LadderInventory!");
	Super.Destroyed();
}

defaultproperties
{
	TournamentDifficulty=1
	bDisplayableInv=False
	bActivatable=False
	bHidden=True
}