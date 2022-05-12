class TargetChildWindow expands SpeechWindow;

var int OptionOffset;
var int MinOptions;

var localized string AllString;
var int Message;

var SpeechMiniDisplay MiniDisplay;

var bool bSelectLast;

var int OptionTeamIDs[16];

function Created()
{
	local int i, j;
	local int W, H;
	local float XMod, YMod;
	local color TextColor;
	local PlayerReplicationInfo PRI;
	local string Names[32];

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	CurrentType = SpeechWindow(ParentWindow).CurrentType;

	NumOptions = 1;
	for (i=0; i<32; i++)
		Options[i] = "";
	for (i=0; i<32; i++)
	{
		PRI = GetPlayerOwner().GameReplicationInfo.PRIArray[i];
		if (PRI != None)
		{
			if ( (PRI.Team == GetPlayerOwner().PlayerReplicationInfo.Team) && (PRI != GetPlayerOwner().PlayerReplicationInfo) )
			{
				NumOptions++;
				Names[PRI.TeamID] = PRI.PlayerName;
			}
		}
	}

	Super.Created();

	OptionButtons[0].Text = AllString;
	j = 1;
	for (i=0; i<32; i++)
	{
		if (Names[i] != "")
		{
			OptionButtons[j].Text = Names[i];
			OptionTeamIDs[j] = i;
			j++;
		}
	}

	MiniDisplay = SpeechMiniDisplay(Root.CreateWindow(class'SpeechMiniDisplay', 100, 100, 100, 100));
	MiniDisplay.WinWidth = 256.0/1024.0 * XMod;
	MiniDisplay.WinHeight = 256.0/768.0 * YMod;

	TopButton.OverTexture = texture'OrdersTopArrow';
	TopButton.UpTexture = texture'OrdersTopArrow';
	TopButton.DownTexture = texture'OrdersTopArrow';
	TopButton.WinLeft = 0;
	BottomButton.OverTexture = texture'OrdersBtm';
	BottomButton.UpTexture = texture'OrdersBtm';
	BottomButton.DownTexture = texture'OrdersBtm';
	BottomButton.WinLeft = 0;

	MinOptions = Min(8,NumOptions);

	WinTop = (196.0/768.0 * YMod) + (32.0/768.0 * YMod)*(CurrentType-1);
	WinLeft = 512.0/1024.0 * XMod;
	WinWidth = 256.0/1024.0 * XMod;
	WinHeight = (32.0/768.0 * YMod)*(MinOptions+2);

	SetButtonTextures(0, True, False);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop, XL, YL;
	local color TextColor;
	local int i;

	Super.BeforePaint(C, X, Y);

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	WinTop = (196.0/768.0 * YMod) + (32.0/768.0 * YMod)*(CurrentType-1);
	WinLeft = 512.0/1024.0 * XMod;
	WinWidth = 256.0/1024.0 * XMod;
	WinHeight = (32.0/768.0 * YMod)*(NumOptions+2);

	XWidth = 256.0/1024.0 * XMod;
	YHeight = 32.0/768.0 * YMod;

	TopButton.SetSize(XWidth, YHeight);
	TopButton.WinTop = 0;
	TopButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	if (OptionOffset > 0)
		TopButton.bDisabled = False;
	else
		TopButton.bDisabled = True;

	for(i=0; i<NumOptions; i++)
	{
		OptionButtons[i].SetSize(XWidth, YHeight);
		OptionButtons[i].WinLeft = 0;
		OptionButtons[i].WinTop = (32.0/768.0*YMod)*(i+1);
	}

	BottomButton.SetSize(XWidth, YHeight);
	BottomButton.WinTop = (32.0/768.0*YMod)*(NumOptions+1);
	BottomButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	BottomButton.bDisabled = True;
}

function Paint(Canvas C, float X, float Y)
{
	local int i;

	Super.Paint(C, X, Y);

	// Text
	for(i=0; i<NumOptions; i++)
		OptionButtons[i].FadeFactor = FadeFactor/100;
}

function HideWindow()
{
	Super.HideWindow();

	if (MiniDisplay != None)
		MiniDisplay.HideWindow();
}

function Notify(UWindowWindow B, byte E)
{
	local int i;

	switch (E)
	{
		case DE_MouseEnter:
			for (i=0; i<NumOptions; i++)
			{
				if (B == OptionButtons[i])
				{
					MiniDisplay.WinTop = OptionButtons[i].WinTop + WinTop;
					MiniDisplay.WinLeft = WinLeft + WinWidth + WinWidth/10;
					MiniDisplay.Reset();
					if (i > 0)
						MiniDisplay.FillInfo(i, OptionButtons[i].Text);
				}
			}
			break;
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0; i<NumOptions; i++)
			{
				if ( B == OptionButtons[i] )
				{
					if ( i == 0 )
						Root.GetPlayerOwner().Speech(SpeechWindow(ParentWindow).CurrentType, Message, -1);
					else 
						Root.GetPlayerOwner().Speech(SpeechWindow(ParentWindow).CurrentType, Message, OptionTeamIDs[i]);
				}
			}
			break;
	}
}

defaultproperties
{
	WindowTitle=""
	TopTexture=texture'OrdersTop2'
	AllString="All"
}
