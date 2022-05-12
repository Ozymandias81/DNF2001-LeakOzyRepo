//=============================================================================
// LadderDM
//=============================================================================
class LadderDM extends Ladder;

defaultproperties
{
	Matches=14
	bTeamGame=False
	MapPrefix="DM-"

	Maps(0)="Tutorial.unr"
	MapTitle(0)="DM Tutorial"
	MapAuthors(0)="Cliff Bleszinski"
	MapDescription(0)="Learn the basic rules of Deathmatch in this special training environment. Test your skills against an untrained enemy before entering the tournament proper."
	FragLimits(0)=3
	RankedGame(0)=1
	MatchInfo(0)="Botpack.RatedMatchDMTUT"

	Maps(1)="Oblivion.unr"
	MapTitle(1)="Oblivion"
	MapAuthors(1)="Juan Pancho Eekels"
	MapDescription(1)="The ITV Oblivion is one of Liandri's armored transport ships. It transports new contestants via hyperspace jump from the Initiation Chambers to their first events on Earth. Little do most fighters know, however, that the ship itself is a battle arena."
	FragLimits(1)=10
	RankedGame(1)=1
	MatchInfo(1)="Botpack.RatedMatchDM1"

	Maps(2)="Stalwart.unr"
	MapTitle(2)="Stalwart"
	MapAuthors(2)="Alan Willard 'Talsiman'"
	MapDescription(2)="Jerl Liandri purchased this old mechanic's garage as a possible tax dump for his fledgling company, Liandri Mining. Now, Liandri Corp. has converted it into a battle arena. While not very complex, it still manages to claim more lives than the slums of the city in which it lies."
	FragLimits(2)=10
	RankedGame(2)=2
	MatchInfo(2)="Botpack.RatedMatchDM2"

	Maps(3)="Fractal.unr"
	MapTitle(3)="Fractal"
	MapAuthors(3)="Dave Ewing"
	MapDescription(3)="LMC public polls have found that the majority of Tournament viewers enjoy fights in 'Real Life' locations. This converted plasma reactor is one such venue. Fighters should take care, as the plasma energy beams will become accessible through the 'Fractal Portal' if any of the yellow LED triggers on the floor are shot."
	FragLimits(3)=15
	RankedGame(3)=2
	MatchInfo(3)="Botpack.RatedMatchDM4"

	Maps(4)="Turbine.unr"
	MapTitle(4)="Turbine"
	MapAuthors(4)="Cliff Bleszinski"
	MapDescription(4)="A decaying water-treatment facility that has been purchased for use in the Tourney, the Turbine Facility offers an extremely tight and fast arena for combatants which ensures that there is no running, and no hiding, from certain death."
	FragLimits(4)=15
	RankedGame(4)=2
	MatchInfo(4)="Botpack.RatedMatchDM3"

	Maps(5)="Codex.unr"
	MapTitle(5)="Codex"
	MapAuthors(5)="Cliff Bleszinski"
	MapDescription(5)="The Codex of Wisdom was to be a fantastic resource for knowledge seeking beings all across the galaxy. It was to be the last place in known space where one could access rare books in their original printed form. However, when the construction crew accidentally tapped into a magma flow, the project was aborted and sold to Liandri at a bargain price for combat purposes."
	FragLimits(5)=20
	RankedGame(5)=3
	MatchInfo(5)="Botpack.RatedMatchDM5"

	Maps(6)="Pressure.unr"
	MapTitle(6)="Pressure"
	MapAuthors(6)="Pancho Eekels"
	MapDescription(6)="The booby trap is a time honored tradition and a favorite among Tournament viewers. Many Liandri mining facilities offer such 'interactive' hazards."
	FragLimits(6)=20
	RankedGame(6)=3
	MatchInfo(6)="Botpack.RatedMatchDM6"

	Maps(7)="Grinder.unr"
	MapTitle(7)="Grinder"
	MapAuthors(7)="Myscha the Sleddog"
	MapDescription(7)="A former Liandri smelting facility, this complex has proven to be one of the bloodiest arenas for tournament participants. Lovingly called the Heavy Metal Grinder, those who enter can expect nothing less than brutal seek and destroy action."
	FragLimits(7)=20
	RankedGame(7)=3
	MatchInfo(7)="Botpack.RatedMatchDM7"

	Maps(8)="Kgalleon.unr"
	MapTitle(8)="Galleon"
	MapAuthors(8)="Juan Pancho Eekels"
	MapDescription(8)="The indigenous people of Koos World are waterborne and find there to be no more fitting an arena than this ancient transport galleon."
	FragLimits(8)=25
	RankedGame(8)=3
	MatchInfo(8)="Botpack.RatedMatchDM11"

	Maps(9)="Tempest.unr"
	MapTitle(9)="Tempest"
	MapAuthors(9)="Cliff Bleszinski"
	MapDescription(9)="The Tempest Facility was built specifically for the Tournament. It was designed strictly for arena combat, with multi-layered areas and tiny hiding spots. It is a personal training arena of Xan Kriegor and sits high above the sprawling Reconstructed New York City."
	FragLimits(9)=25
	RankedGame(9)=4
	MatchInfo(9)="Botpack.RatedMatchDM8"

	Maps(10)="Barricade.unr"
	MapTitle(10)="Barricade"
	MapAuthors(10)="Cliff Bleszinski"
	MapDescription(10)="A mysterious and ancient alien castle that hovers above an electrical storm, Orion's Barricade makes for a delightfully dangerous arena of battle."
	FragLimits(10)=25
	RankedGame(10)=4
	MatchInfo(10)="Botpack.RatedMatchDM9"

	Maps(11)="Liandri.unr"
	MapTitle(11)="Liandri"
	MapAuthors(11)="Alan Willard 'Talisman'"
	MapDescription(11)="A textbook Liandri ore processing facility located at Earth's Mohorovicic discontinuity roughly below Mexico. Phased ion shields hold back the intense heat and pressure characteristic of deep lithosphere mining."
	FragLimits(11)=30
	RankedGame(11)=4
	MatchInfo(11)="Botpack.RatedMatchDM10"

	Maps(12)="Conveyor.unr"
	MapTitle(12)="Conveyor"
	MapAuthors(12)="Shane Caudle"
	MapDescription(12)="This refinery makes for a particularly well balanced arena. A multilevel central chamber keeps fighters on their toes while the nearby smelting tub keeps them toasty."
	FragLimits(12)=30
	RankedGame(12)=5
	MatchInfo(12)="Botpack.RatedMatchDM12"

	Maps(13)="Peak.unr"
	MapTitle(13)="Peak"
	MapAuthors(13)="Juan Pancho Eekels"
	MapDescription(13)="Originally built by the Nipi Monks in Nepal to escape moral degradation, this serene and beautiful place once called for meditation; until Liandri acquired it for perfect tournament conditions."
	FragLimits(13)=30
	RankedGame(13)=6
	MatchInfo(13)="Botpack.RatedMatchDM13"
}