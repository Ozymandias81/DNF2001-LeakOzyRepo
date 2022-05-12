class LadderCTFDemo expands Ladder;

defaultproperties
{
	Matches=10
	bTeamGame=True
	MapPrefix="CTF-"

	Maps(0)="Tutorial.unr"
	MapTitle(0)="CTF Tutorial"
	MapAuthors(0)="Cliff Bleszinski"
	MapDescription(0)="Learn the basic rules and systems of Capture the Flag in this special training environment. Test your skills against an untrained enemy team before entering the tournament proper."
	GoalTeamScore(0)=0
	RankedGame(0)=1
	MatchInfo(0)="Botpack.RatedMatchCTFTUT"

	Maps(1)="CoretDemo.unr"
	MapTitle(1)="Coret"
	MapAuthors(1)="Alan Willard 'Talisman'"
	MapDescription(1)="Built into a mountaintop on the Coret moon, this facility was once the waypoint between the Interstellar zonegate in orbit over the moon and the Zeto Research Station located half the moon away in the frozen wastes."
	RankedGame(1)=4
	GoalTeamScore(1)=3
	MatchInfo(1)="Botpack.RatedMatchCTFDemo1"
}