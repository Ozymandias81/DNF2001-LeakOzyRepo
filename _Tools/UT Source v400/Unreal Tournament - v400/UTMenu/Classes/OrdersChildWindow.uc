class OrdersChildWindow expands SpeechWindow;

var int OptionOffset;
var int MinOptions;

var int OtherOffset[32];

var PlayerReplicationInfo TargetPRI;

function Created()
{
	local int i, j;
	local int W, H;
	local float XMod, YMod;
	local color TextColor;
	local class<ChallengeVoicePack> V;

	V = class<ChallengeVoicePack>(GetPlayerOwner().PlayerReplicationInfo.VoiceType);

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

	j = 0;
	for (i=0; i<9; i++)
	{
		if (V.Static.GetOrderString(i, GetPlayerOwner().GameReplicationInfo.GameName) != "")
			OtherOffset[j++] = i;
	}
	NumOptions = j;

	Super.Created();

	for (i=0; i<NumOptions; i++)
		OptionButtons[i].Text = V.Static.GetOrderString(OtherOffset[i], GetPlayerOwner().GameReplicationInfo.GameName);

	TopButton.OverTexture = texture'OrdersTopArrow';
	TopButton.UpTexture = texture'OrdersTopArrow';
	TopButton.DownTexture = texture'OrdersTopArrow';
	TopButton.WinLeft = 0;
	BottomButton.OverTexture = texture'OrdersBtmArrow';
	BottomButton.UpTexture = texture'OrdersBtmArrow';
	BottomButton.DownTexture = texture'OrdersBtmArrow';
	BottomButton.WinLeft = 0;

	MinOptions = Min(8,NumOptions);

	WinTop = (196.0/768.0 * YMod) + (32.0/768.0 * YMod)*(CurrentType-1);
	WinLeft = 256.0/1024.0 * XMod;
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

	Super(NotifyWindow).BeforePaint(C, X, Y);

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	XWidth = 256.0/1024.0 * XMod;
	YHeight = 32.0/768.0 * YMod;

	TopButton.SetSize(XWidth, YHeight);
	TopButton.WinTop = 0;
	TopButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	if (OptionOffset > 0)
		TopButton.bDisabled = False;
	else
		TopButton.bDisabled = True;

	for(i=0; i<OptionOffset; i++)
	{
		OptionButtons[i].HideWindow();
	}
	for(i=OptionOffset; i<MinOptions+OptionOffset; i++)
	{
		OptionButtons[i].ShowWindow();
		OptionButtons[i].SetSize(XWidth, YHeight);
		OptionButtons[i].WinLeft = 0;
		OptionButtons[i].WinTop = (32.0/768.0*YMod)*(i+1-OptionOffset);
	}
	for(i=MinOptions+OptionOffset; i<NumOptions; i++)
	{
		OptionButtons[i].HideWindow();
	}

	BottomButton.SetSize(XWidth, YHeight);
	BottomButton.WinTop = (32.0/768.0*YMod)*(MinOptions+1);
	BottomButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	if (NumOptions > MinOptions+OptionOffset)
		BottomButton.bDisabled = False;
	else
		BottomButton.bDisabled = True;
}

function Paint(Canvas C, float X, float Y)
{
	local int i;

	Super.Paint(C, X, Y);

	// Text
	for(i=0; i<NumOptions; i++)
	{
		OptionButtons[i].FadeFactor = FadeFactor/100;
	}
}

function FadeOut()
{
	FadeFactor = 100;
	bFadeOut = True;
	if (SpeechChild != None)
		SpeechChild.FadeOut();
}

function Notify(UWindowWindow B, byte E)
{
	local int i;

	switch (E)
	{
		case DE_DoubleClick:
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			for (i=0; i<NumOptions; i++)
			{
				if (B == OptionButtons[i])
				{
					if (!GetPlayerOwner().GameReplicationInfo.bTeamGame)
					{
						Root.GetPlayerOwner().Speech(2, OtherOffset[i], 0);
						return;
					} else if ((TargetPRI != None) && (CurrentType == 6)) {
						Root.GetPlayerOwner().Speech(2, OtherOffset[i], TargetPRI.TeamID);
						return;
					} else {
						if (i == 0)
							SetButtonTextures(0, True, True);
						else {
							SetButtonTextures(0, True, False);
							SetButtonTextures(i, False, True, True);
						}
						HideChildren();
						SpeechChild = SpeechWindow(ParentWindow.CreateWindow(class'TargetChildWindow', 100, 100, 100, 100));
						SpeechChild.CurrentType = i+2;
						TargetChildWindow(SpeechChild).Message = OtherOffset[i];
						SpeechChild.FadeIn();
					}
				}
			}
			if (B == TopButton)
			{
				if (NumOptions > 8)
				{
					if (OptionOffset > 0)
						OptionOffset--;
				}
			}
			if (B == BottomButton)
			{
				if (NumOptions > 8)
				{
					if (NumOptions - OptionOffset > 8)
						OptionOffset++;
				}
			}
			break;
	}
}

function HideWindow()
{
	Super.HideWindow();

	if (SpeechChild != None)
		SpeechChild.HideWindow();
}

defaultproperties
{
	WindowTitle=""
	TopTexture=texture'OrdersTop2'
}
