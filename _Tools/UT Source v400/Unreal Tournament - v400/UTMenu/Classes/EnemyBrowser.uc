class EnemyBrowser extends MeshBrowser;

var TeamBrowser TeamWindow;

function SetTeamVars()
{
	bTeamGame = Ladder.Default.bTeamGame;
	bEnemy = True;
}

function SetInitialBot(class<Bot> InitialBot)
{
	if (bTeamGame)
		InitialBot.static.SetMultiSkin(MeshWindow.MeshActor, 
			RMI.GetBotSkin(0, bTeamGame, bEnemy, GetPlayerOwner()), 
			RMI.GetBotFace(0, bTeamGame, bEnemy, GetPlayerOwner()), 
			1);
	else
		InitialBot.static.SetMultiSkin(MeshWindow.MeshActor, 
			RMI.GetBotSkin(0, bTeamGame, bEnemy, GetPlayerOwner()), 
			RMI.GetBotFace(0, bTeamGame, bEnemy, GetPlayerOwner()), 
			RMI.GetBotTeam(0, bTeamGame, bEnemy, GetPlayerOwner()));
}

function SetNumNames()
{
	NumNames = MatchInfo.Default.NumBots-MatchInfo.Default.NumAllies;
}

function Notify(UWindowWindow B, byte E)
{
	local int i;
	local string MeshName, SkinName;
	local Class<TournamentPlayer> TournamentClass;

	switch (E)
	{
		case DE_Click:
		case DE_DoubleClick:
			for (i=0; i<8; i++)
			{
				if (B == Names[i])
				{
					if (!Names[i].bDisabled)
						NameSelected(i);
					return;
				}
			}
			switch (B)
			{
				case NextButton:
					NextPressed();
					break;
				case BackButton:
					BackPressed();
					break;
				case DescScrollup:
					DescArea.ScrollingOffset--;
					if (DescArea.ScrollingOffset < 0)
						DescArea.ScrollingOffset = 0;
					break;
				case DescScrolldown:
					DescArea.ScrollingOffset++;
					if (DescArea.ScrollingOffset > 10)
						DescArea.ScrollingOffset = 10;
					break;
				case Title1:
					TitleClicked();
					break;
			}
			break;
	}
}

function NextPressed()
{
	local string MapName;

	MapName = Ladder.Default.MapPrefix$Ladder.Static.GetMap(Match); 
	CloseUp();
	StartMap(MapName, Match, GameType);
}

function BackPressed()
{
	if (!Ladder.Default.bTeamGame)
	{
		LadderWindow.ShowWindow();
		Close();
	} else {
		HideWindow();
		TeamWindow.ShowWindow();
	}
}

function NameSelected(int i)
{
	local Class<Bot> SelectedEnemy;
	local Class<RatedMatchInfo> MatchInfo;
	
	MeshWindow.bRotate = False;
	MeshWindow.ViewRotator = rot(0, 32768, 0);
	MeshWindow.FaceButton.ShowWindow();
	MeshWindow.CenterRotator = rot(0, 0, 0);

	Selected = i;

	MatchInfo = Ladder.Static.GetMatchConfigType(Match);
	SelectedEnemy = class<Bot>(DynamicLoadObject(RMI.GetBotClassName(i, bTeamGame, True, GetPlayerOwner()), Class'Class'));
	MeshWindow.SetMeshString(SelectedEnemy.Default.SelectionMesh);
	MeshWindow.ClearSkins();
	if (bTeamGame)
		SelectedEnemy.static.SetMultiSkin(MeshWindow.MeshActor, RMI.GetBotSkin(i, bTeamGame, True, GetPlayerOwner()), RMI.GetBotFace(i, bTeamGame, True, GetPlayerOwner()), 1);
	else
		SelectedEnemy.static.SetMultiSkin(MeshWindow.MeshActor, RMI.GetBotSkin(i, bTeamGame, True, GetPlayerOwner()), RMI.GetBotFace(i, bTeamGame, True, GetPlayerOwner()), RMI.GetBotTeam(i, bTeamGame, True, GetPlayerOwner()));
	DescArea.Clear();
	DescArea.AddText(NameString$" "$RMI.GetBotName(i, bTeamGame, True, GetPlayerOwner()));
	DescArea.AddText(ClassString$" "$RMI.GetBotClassification(i, bTeamGame, True, GetPlayerOwner()));
	DescArea.AddText("");
	DescArea.AddText(RMI.GetBotDesc(i, bTeamGame, True, GetPlayerOwner()));
}

function StartMap(string StartMap, int Rung, string GameType)
{
	local int Team;
	local Class<GameInfo> GameClass;

	GameClass = Class<GameInfo>(DynamicLoadObject(GameType, Class'Class'));
	GameClass.Static.ResetGame();

	if ((GameType == "Botpack.DeathMatchPlus") ||
		(GameType == "Botpack.DeathMatchPlusTest"))
		Team = 255;
	else
		Team = 0;

	StartMap = StartMap
				$"?Game="$GameType
				$"?Mutator="
				$"?Tournament="$Rung
				$"?Name="$GetPlayerOwner().PlayerReplicationInfo.PlayerName
				$"?Team="$Team;

	Root.SetMousePos((Root.WinWidth*Root.GUIScale)/2, (Root.WinHeight*Root.GUIScale)/2);
	Root.Console.CloseUWindow();
	GetPlayerOwner().ClientTravel(StartMap, TRAVEL_Absolute, True);
}

function Close(optional bool bByParent)
{
	if (Ladder.Default.bTeamGame)
		TeamWindow.Close();

	RMI = None;

	Super.Close(bByParent);
}

function TitleClicked()
{
	MeshWindow.SetNoAnimMesh(mesh(DynamicLoadObject(TeamMesh, Class'mesh')));
	MeshWindow.MeshActor.Texture = TeamTex;
	MeshWindow.MeshActor.bMeshEnviroMap = True;
	MeshWindow.MeshActor.DrawScale = 0.13 * 0.35;
	MeshWindow.bRotate = True;
	MeshWindow.bFace = False;
	MeshWindow.FaceButton.HideWindow();
	MeshWindow.ViewRotator = rot(0, 32768, 0);
	MeshWindow.CenterRotator = rot(0, 0, 0);

	Selected = -1;
	DescArea.Clear();
	DescArea.AddText(RMI.GetTeamName(True, GetPlayerOwner()));
	DescArea.AddText("");
	DescArea.AddText(RMI.GetTeamBio(True, GetPlayerOwner()));
}

defaultproperties
{
	NameString="Name:"
	ClassString="Classification:"
	EmptyText=""
	BrowserName="Enemy Roster"
	BGName1(0)="UTMenu.CC11"
	BGName1(1)="UTMenu.CC12"
	BGName1(2)="UTMenu.CC13"
	BGName1(3)="UTMenu.CC14"
	BGName2(0)="UTMenu.CC21"
	BGName2(1)="UTMenu.CC22"
	BGName2(2)="UTMenu.CC23"
	BGName2(3)="UTMenu.CC24"
	BGName3(0)="UTMenu.CC31"
	BGName3(1)="UTMenu.CC32"
	BGName3(2)="UTMenu.CC33"
	BGName3(3)="UTMenu.CC34"
	TeamMesh="Botpack.DomB"
	TeamTex=texture'BlueSkin2'
}