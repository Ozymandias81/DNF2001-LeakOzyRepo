class UTStatLogFile expands StatLogFile;

function LogPlayerInfo(Pawn Player)
{
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"TeamName"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.TeamName);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Team"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.Team);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"TeamID"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.TeamID);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Ping"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.Ping);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"IsABot"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.PlayerReplicationInfo.bIsABot);
	LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Skill"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Player.Skill);
	if (Bot(Player) != None)
		LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Novice"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Bot(Player).bNovice);
	else
		LogEventString(GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Novice"$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$"False");
}
