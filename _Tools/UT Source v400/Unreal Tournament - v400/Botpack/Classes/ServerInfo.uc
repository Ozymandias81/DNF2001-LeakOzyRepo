class ServerInfo extends Info;

var localized string ServerInfoText;
var localized string ContactInfoText;
var localized string NameText;
var localized string AdminText;
var localized string EMailText;
var localized string UnknownText;
var localized string MOTD;
var localized string ServerStatsText;
var localized string FragsLoggedText;
var localized string GamesHostedText;
var localized string VictimsText;
var localized string GameStatsText;
var localized string GameTypeText;
var localized string PlayersText;
var localized string FragsText;
var localized string TopPlayersText;
var localized string BestNameText;
var localized string BestFPHText;
var localized string BestRecordSetText;
var localized string BotText;

var FontInfo MyFonts;

function Destroyed()
{
	Super.Destroyed();
	if ( MyFonts != None )
		MyFonts.Destroy();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MyFonts = Spawn(class'FontInfo');
}

function RenderInfo( canvas C )
{
	local GameReplicationInfo GRI;
	GRI = PlayerPawn(Owner).GameReplicationInfo;

	DrawTitle(C);

	if (C.ClipX > 512)
	{
		DrawContactInfo(C, GRI);
		DrawMOTD(C, GRI);
		DrawServerStats(C, GRI);
		DrawGameStats(C, GRI);
		DrawLeaderBoard(C, GRI);
	} else {
		DrawShortContactInfo(C, GRI);
		DrawShortMOTD(C, GRI);
	}
}

function DrawTitle( canvas C )
{
	local float XL, YL;

	C.Font = MyFonts.GetHugeFont( C.ClipX );
	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.StrLen( ServerInfoText, XL, YL );
	C.SetPos( (C.ClipX - XL) / 2, YL );
	C.DrawText( ServerInfoText, True );
}

function DrawContactInfo( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( C.ClipX / 8, (C.ClipY / 8) );
	C.DrawText( ContactInfoText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( C.ClipX / 8, (C.ClipY / 8) + (YL+1) );
	C.DrawText( NameText, True);

	C.SetPos( C.ClipX / 8, (C.ClipY / 8) + (YL+1) + (YL2+1) );
	C.DrawText( AdminText, True);

	C.SetPos( C.ClipX / 8, (C.ClipY / 8) + (YL+1) + (YL2+1)*2 );
	C.DrawText( EMailText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.SetPos( (C.ClipX / 8) + XL2*2, (C.ClipY / 8) + (YL+1) );
	C.DrawText( GRI.ServerName, True);

	C.SetPos( (C.ClipX / 8) + XL2*2, (C.ClipY / 8) + (YL+1) + (YL2+1) );
	if (GRI.AdminName != "")
		C.DrawText( GRI.AdminName, True );
	else
		C.DrawText( UnknownText, True );

	C.SetPos( (C.ClipX / 8) + XL2*2, (C.ClipY / 8) + (YL+1) + (YL2+1)*2 );
	if (GRI.AdminEmail != "")
		C.DrawText( GRI.AdminEmail, True );
	else
		C.DrawText( UnknownText, True );
}

function DrawMOTD( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( (C.ClipX / 8)*5, C.ClipY / 8 );
	C.DrawText( MOTD, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.StrLen( GRI.MOTDLine1, XL2, YL2 );
	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8) + (YL+1) );
	C.DrawText( GRI.MOTDLine1, True );

	C.StrLen( GRI.MOTDLine2, XL2, YL2 );
	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8) + (YL+1) + (YL2+1) );
	C.DrawText( GRI.MOTDLine2, True );

	C.StrLen( GRI.MOTDLine3, XL2, YL2 );
	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8) + (YL+1) + (YL2+1)*2 );
	C.DrawText( GRI.MOTDLine3, True );

	C.StrLen( GRI.MOTDLine4, XL2, YL2 );
	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8) + (YL+1) + (YL2+1)*3 );
	C.DrawText( GRI.MOTDLine4, True );
}

function DrawServerStats( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;
	local TournamentGameReplicationInfo TGRI;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 );
	C.DrawText( ServerStatsText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GamesHostedText, True);

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( FragsLoggedText, True);

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*3 + (YL+1) + (YL2+1)*2 );
	C.DrawText( VictimsText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	TGRI = TournamentGameReplicationInfo(GRI);

	C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( TGRI.TotalGames, True);

	C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( TGRI.TotalFrags, True);

	C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*3 + (YL+1) + (YL2+1)*2 );
	C.DrawText( TGRI.TotalDeaths, True);
}

function DrawGameStats( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;
	local TournamentGameReplicationInfo TGRI;
	local int i, NumBots;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( "TEMP", XL, YL );

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 );
	C.DrawText( GameStatsText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GameTypeText, True);

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( PlayersText, True);

	C.SetPos( (C.ClipX / 8), (C.ClipY / 8)*3 + (YL+1) + (YL2+1)*2 );
	C.DrawText( FragsText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.SetPos( (C.ClipX / 8)*2, (C.ClipY / 8)*3 + (YL+1) );
	C.DrawText( GRI.GameName, True);

	for (i=0; i<32; i++)
		if ((GRI.PRIArray[i] != None) && (GRI.PRIArray[i].bIsABot))
			NumBots++;
	C.SetPos( (C.ClipX / 8)*2, (C.ClipY / 8)*3 + (YL+1) + (YL2+1) );
	C.DrawText( GRI.NumPlayers$"   ["$NumBots@BotText$"]", True);

	C.SetPos( (C.ClipX / 8)*2, (C.ClipY / 8)*3 + (YL+1) + (YL2+1)*2 );
	C.DrawText( GRI.SumFrags, True);
}

function DrawLeaderBoard( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL;
	local int i;
	local TournamentGameReplicationInfo TGRI;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( TopPlayersText, XL, YL );

	C.SetPos( (C.ClipX - XL) / 2, (C.ClipY / 8)*5 );
	C.DrawText( "Top Players [Frags per Hour]", True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );

	C.SetPos( C.ClipX / 8, (C.ClipY / 8)*5 + (YL+1) );
	C.DrawText( BestNameText, True);

	C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*5 + (YL+1) );
	C.DrawText( BestFPHText, True);

	C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*5 + (YL+1) );
	C.DrawText( BestRecordSetText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	TGRI = TournamentGameReplicationInfo(GRI);
	for (i=0; i<3; i++)
	{
		C.SetPos( C.ClipX / 8, (C.ClipY / 8)*5 + (YL+1)*(i+2) );
		if ( TGRI.BestPlayers[i] != "" )
			C.DrawText( TGRI.BestPlayers[i], True);
		else
			C.DrawText( "--", True);

		C.SetPos( (C.ClipX / 8)*5, (C.ClipY / 8)*5 + (YL+1)*(i+2) );
		if ( TGRI.BestPlayers[i] != "" )
			C.DrawText( TGRI.BestFPHs[i], True);
		else
			C.DrawText( "--", True);

		C.SetPos( (C.ClipX / 8)*6, (C.ClipY / 8)*5 + (YL+1)*(i+2) );
		if ( TGRI.BestPlayers[i] != "" )
			C.DrawText( TGRI.BestRecordDate[i], True);
		else
			C.DrawText( "--", True);
	}
}

function DrawShortContactInfo( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( ContactInfoText, XL, YL );

	C.SetPos( (C.ClipX-XL)/2, (C.ClipY / 4) );
	C.DrawText( ContactInfoText, True);

	C.DrawColor.R = 0;
	C.DrawColor.G = 128;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.SetPos( C.ClipX / 4, (C.ClipY / 4) + (YL+1) );
	C.DrawText( NameText, True);

	C.SetPos( C.ClipX / 4, (C.ClipY / 4) + (YL+1) + (YL2+1) );
	C.DrawText( AdminText, True);

	C.SetPos( C.ClipX / 4, (C.ClipY / 4) + (YL+1) + (YL2+1)*2 );
	C.DrawText( EMailText, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.SetPos( (C.ClipX / 4) + XL2*2, (C.ClipY / 4) + (YL+1) );
	C.DrawText( GRI.ServerName, True);

	C.SetPos( (C.ClipX / 4) + XL2*2, (C.ClipY / 4) + (YL+1) + (YL2+1) );
	if (GRI.AdminName != "")
		C.DrawText( GRI.AdminName, True );
	else
		C.DrawText( UnknownText, True );

	C.SetPos( (C.ClipX / 4) + XL2*2, (C.ClipY / 4) + (YL+1) + (YL2+1)*2 );
	if (GRI.AdminEmail != "")
		C.DrawText( GRI.AdminEmail, True );
	else
		C.DrawText( UnknownText, True );
}

function DrawShortMOTD( canvas C, GameReplicationInfo GRI )
{
	local float XL, YL, XL2, YL2;

	C.DrawColor.R = 9;
	C.DrawColor.G = 151;
	C.DrawColor.B = 247;

	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen( MOTD, XL, YL );

	C.SetPos( (C.ClipX-XL)/2, C.ClipY/2 );
	C.DrawText( MOTD, True);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.Font = MyFonts.GetSmallFont( C.ClipX );
	C.StrLen( "TEMP", XL2, YL2 );

	C.StrLen( GRI.MOTDLine1, XL2, YL2 );
	C.SetPos( (C.ClipX/8)*3, (C.ClipY/2) + (YL+1) );
	C.DrawText( GRI.MOTDLine1, True );

	C.StrLen( GRI.MOTDLine2, XL2, YL2 );
	C.SetPos( (C.ClipX/8)*3, (C.ClipY/2) + (YL+1) + (YL2+1) );
	C.DrawText( GRI.MOTDLine2, True );

	C.StrLen( GRI.MOTDLine3, XL2, YL2 );
	C.SetPos( (C.ClipX/8)*3, (C.ClipY/2) + (YL+1) + (YL2+1)*2 );
	C.DrawText( GRI.MOTDLine3, True );

	C.StrLen( GRI.MOTDLine4, XL2, YL2 );
	C.SetPos( (C.ClipX/8)*3, (C.ClipY/2) + (YL+1) + (YL2+1)*3 );
	C.DrawText( GRI.MOTDLine4, True );
}

defaultproperties
{
	ServerInfoText="Server Info"
	ContactInfoText="Contact Info"
	NameText="Name:"
	AdminText="Admin:"
	EMailText="EMail:"
	UnknownText="Unknown"
	MOTD="Message of the Day"
	ServerStatsText="Server Stats"
	GamesHostedText="Games Hosted:"
	FragsLoggedText="Frags Logged:"
	VictimsText="Lives Claimed:"
	GameStatsText="Game Stats"
	GameTypeText="GameType:"
	PlayersText="Players:"
	FragsText="Total Frags:"
	TopPlayersText="Top Players [Frags per Hour]"
	BestNameText="Name"
	BestFPHText="Best FPH"
	BestRecordSetText="Record Set"
	BotText="Bots"
}