//=============================================================================
// MusicTrigger.
//=============================================================================
class MusicTrigger expands Triggers;

var() string TrackName;
var() bool   Instant;
var() float  CrossfadeSeconds;
var() bool   OnceOnly;
var() bool   Push; 
var() bool   ShowTrigger;

function Trigger( actor Other, pawn EventInstigator )
{
	if(ShowTrigger)
	{
		BroadcastMessage("MusicTrigger: TrackName: "$TrackName$" Instant:"$Instant$" CrossfadeSeconds:"$CrossfadeSeconds);
	}

	MusicPlay(TrackName,Instant,CrossfadeSeconds,Push);
	if(OnceOnly)
	{
		SetCollision(false,false,false);
		disable('Trigger');
	}	
}

defaultproperties
{
	ShowTrigger=false
}
