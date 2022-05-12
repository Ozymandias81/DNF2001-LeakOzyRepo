class UMenuScreenshotCW expands UWindowDialogClientWindow;

var Texture Screenshot;
var string MapTitle;
var string MapAuthor;
var string IdealPlayerCount;

var localized string PlayersText;

function SetMap(string MapName)
{
	local int i;
	local LevelSummary L;

	i = InStr(Caps(MapName), ".UNR");
	if(i != -1)
		MapName = Left(MapName, i);

	Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture'));
	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));
	if(L != None)
	{
		MapTitle = L.Title;
		MapAuthor = L.Author;
		IdealPlayerCount = L.IdealPlayerCount;
	}
	else
	{
		MapTitle = "";
		MapAuthor = "";
		IdealPlayerCount = "";
	}
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	Screenshot = None;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	if(Screenshot != None)
	{
		W = Min(WinWidth, Screenshot.USize);
		H = Min(WinHeight, Screenshot.VSize);
		
		if(W > H)
			W = H;
		if(H > W)
			H = W;

		X = (WinWidth - W) / 2;
		Y = (WinHeight - H) / 2;
		
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		DrawStretchedTexture(C, X, Y, W, H, Screenshot);

		C.Font = Root.Fonts[F_Normal];

		if(IdealPlayerCount != "")
		{
			TextSize(C, IdealPlayerCount@PlayersText, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*2;
			ClipText(C, X, Y, IdealPlayerCount@PlayersText);
		}

		if(MapAuthor != "")
		{
			TextSize(C, MapAuthor, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*3;
			ClipText(C, X, Y, MapAuthor);
		}
		
		if(MapTitle != "")
		{		
			TextSize(C, MapTitle, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*4;
			ClipText(C, X, Y, MapTitle);
		}
	}
}

defaultproperties
{
	PlayersText="Players"
}