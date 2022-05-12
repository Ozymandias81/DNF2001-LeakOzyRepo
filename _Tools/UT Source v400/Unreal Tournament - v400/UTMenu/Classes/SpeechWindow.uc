class SpeechWindow extends NotifyWindow;

#exec TEXTURE IMPORT NAME=OrdersTop FILE=TEXTURES\Orders\OrdersTop.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersTop2 FILE=TEXTURES\Orders\OrdersTop2.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersMid FILE=TEXTURES\Orders\OrdersMid.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersMidL FILE=TEXTURES\Orders\OrdersMidL.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersMidLR FILE=TEXTURES\Orders\OrdersMidLR.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersMidR FILE=TEXTURES\Orders\OrdersMidR.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersBtm FILE=TEXTURES\Orders\OrdersBtm.PCX GROUP=Skins MIPS=OFF

#exec TEXTURE IMPORT NAME=OrdersTopArrow FILE=TEXTURES\Orders\OrdersTopArow.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=OrdersBtmArrow FILE=TEXTURES\Orders\OrdersBtmArow.PCX GROUP=Skins MIPS=OFF

#exec AUDIO IMPORT NAME=SpeechWindowClick FILE=SOUNDS\click4.wav GROUP=SpeechWindow

// Top list of options.
var SpeechButton TopButton;
var SpeechButton OptionButtons[32];
var SpeechButton BottomButton;
var localized string Options[32];
var int NumOptions;
var Class<SpeechButton> ButtonClass;

// Voice information.
var int CurrentType;

// Textures
var texture TopTexture;
var texture BottomTexture;

// XOffset
var float XOffset;
var bool bSlideIn, bSlideOut;

// Title
var localized string WindowTitle;

// SpeechChildren
var SpeechWindow SpeechChild;

var PlayerReplicationInfo IdentifyTarget;

// Fade control
var float FadeFactor;
var bool bFadeIn, bFadeOut;

function Created()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	bAlwaysOnTop = True;
	bLeaveOnScreen = True;

	Super.Created();

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	WinTop = 0;
	WinLeft = 0;
	WinWidth = Root.WinWidth;
	WinHeight = Root.WinHeight;

	TopButton = SpeechButton(CreateWindow(class'SpeechButton', 100, 100, 100, 100));
	TopButton.NotifyWindow = Self;
	TopButton.Text = WindowTitle;
	TopButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	TopButton.TextColor.R = 255;
	TopButton.TextColor.G = 255;
	TopButton.TextColor.B = 255;
	TopButton.XOffset = 20.0/1024.0 * XMod;
	TopButton.FadeFactor = 1.0;
	TopButton.bDisabled = True;
	TopButton.DisabledTexture = TopTexture;
	TopButton.bStretched = True;
	for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i] = SpeechButton(CreateWindow(ButtonClass, 100, 100, 100, 100));
		OptionButtons[i].NotifyWindow = Self;
		OptionButtons[i].Text = Options[i];
		OptionButtons[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
		OptionButtons[i].bLeftJustify = True;
		OptionButtons[i].TextColor.R = 255;
		OptionButtons[i].TextColor.G = 255;
		OptionButtons[i].TextColor.B = 255;
		OptionButtons[i].XOffset = 20.0/1024.0 * XMod;
		OptionButtons[i].FadeFactor = 1.0;
		OptionButtons[i].bHighlightButton = True;
		OptionButtons[i].OverTexture = texture'OrdersMid';
		OptionButtons[i].UpTexture = texture'OrdersMid';
		OptionButtons[i].DownTexture = texture'OrdersMid';
		OptionButtons[i].Type = i;
		OptionButtons[i].bStretched = True;
	}
	BottomButton = SpeechButton(CreateWindow(class'SpeechButton', 100, 100, 100, 100));
	BottomButton.NotifyWindow = Self;
	BottomButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	BottomButton.TextColor.R = 255;
	BottomButton.TextColor.G = 255;
	BottomButton.TextColor.B = 255;
	BottomButton.XOffset = 20.0/1024.0 * XMod;
	BottomButton.FadeFactor = 1.0;
	BottomButton.bDisabled = True;
	BottomButton.DisabledTexture = BottomTexture;
	BottomButton.bStretched = True;
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

	WinTop = 0;
	WinLeft = 0;
	WinWidth = Root.WinWidth;
	WinHeight = Root.WinHeight;

	XWidth = 256.0/1024.0 * XMod;
	YHeight = 32.0/768.0 * YMod;
	YPos = 164.0/768.0 * YMod;
	TopButton.SetSize(XWidth, YHeight);
	TopButton.WinLeft = XOffset;
	TopButton.WinTop = YPos;
	TopButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	for(i=0; i<NumOptions; i++)
	{
		OptionButtons[i].SetSize(XWidth, YHeight);
		OptionButtons[i].WinLeft = XOffset;
		OptionButtons[i].WinTop = YPos + (32.0/768.0*YMod)*(i+1);
		OptionButtons[i].MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	}
	BottomButton.SetSize(XWidth, YHeight);
	BottomButton.WinLeft = XOffset;
	BottomButton.WinTop = YPos + (32.0/768.0*YMod)*(NumOptions+1);
	BottomButton.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
}

function SlideOutWindow()
{
	SetButtonTextures(-1, False, False);
	XOffset = 0;
	bSlideOut = True;
	bSlideIn = False;
	if (SpeechChild != None)
		SpeechChild.FadeOut();
}

function SlideInWindow()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	XOffset = -256.0/1024.0 * XMod;
	bSlideIn = True;
	bSlideOut = False;
	ShowWindow();

	IdentifyTarget = None;
	NumOptions = Default.NumOptions - 1;
	OptionButtons[NumOptions].HideWindow();
	if (GetPlayerOwner().MyHUD.IsA('ChallengeHUD'))
	{
		if (( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget != None ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget.Team == GetPlayerOwner().PlayerReplicationInfo.Team ) &&
			( ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyFadeTime > 2.0 ))
		{
			IdentifyTarget = ChallengeHUD(GetPlayerOwner().MyHUD).IdentifyTarget;
			NumOptions = Default.NumOptions;
			OptionButtons[Default.NumOptions - 1].ShowWindow();
		}
	}
}

function FadeIn()
{
	FadeFactor = 0;
	bFadeIn = True;
}

function FadeOut()
{
	FadeFactor = 100;
	bFadeOut = True;
	SetButtonTextures(-1, False, False);
}

function Tick(float Delta)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	if (bSlideIn)
	{
		XOffset += Delta*800;
		if (XOffset >= 0)
		{
			XOffset = 0;
			bSlideIn = False;
		}
	}

	if (bSlideOut)
	{
		XOffset -= Delta*800;
		if (XOffset <= -256.0/1024.0 * XMod)
		{
			XOffset = -256.0/1024.0 * XMod;
			bSlideOut = False;
			if (NextSiblingWindow == None)
			{
				HideWindow();
				Root.Console.CloseUWindow();
				Root.Console.bQuickKeyEnable = False;
			} else
				HideWindow();
		}
	}

	if (bFadeIn)
	{
		FadeFactor += Delta * 700;
		if (FadeFactor > 100)
		{
			FadeFactor = 100;
			bFadeIn = False;
		}  
	}

	if (bFadeOut)
	{
		FadeFactor -= Delta * 700;
		if (FadeFactor <= 0)
		{
			FadeFactor = 0;
			bFadeOut = False;
			HideWindow();
		}
	}
}

function Notify(UWindowWindow B, byte E)
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if(W > 256 || H > 256)
	{
		W = 256;
		H = 256;
	}

	XMod = 4*W;
	YMod = 3*H;

	switch (E)
	{
		case DE_Click:
			GetPlayerOwner().PlaySound(sound'SpeechWindowClick', SLOT_Interact);
			switch (B)
			{
				case OptionButtons[0]:
				case OptionButtons[1]:
				case OptionButtons[3]:
				case OptionButtons[4]:
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(CreateWindow(class'SpeechChildWindow', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					break;
				case OptionButtons[2]:
				case OptionButtons[6]:
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(CreateWindow(class'OrdersChildWindow', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					OrdersChildWindow(SpeechChild).TargetPRI = IdentifyTarget;
					break;
				case OptionButtons[5]:
					SetButtonTextures(SpeechButton(B).Type, False, True);
					HideChildren();
					CurrentType = SpeechButton(B).Type;
					SpeechChild = SpeechWindow(CreateWindow(class'PhysicalChildWindow', 100, 100, 100, 100));
					SpeechChild.FadeIn();
					break;
			}
			break;
	}
}

function HideChildren()
{
	if (SpeechChild != None)
		SpeechChild.HideWindow();
}

function SetButtonTextures(int i, optional bool bLeft, optional bool bRight, optional bool bPreserve)
{
	local int j;

	for (j=0; j<NumOptions; j++)
	{
		if (j == i)
		{
			if (bLeft && bRight)
			{
				OptionButtons[j].OverTexture = texture'OrdersMidLR';
				OptionButtons[j].UpTexture = texture'OrdersMidLR';
				OptionButtons[j].DownTexture = texture'OrdersMidLR';
			} else if (bRight) {
				OptionButtons[j].OverTexture = texture'OrdersMidR';
				OptionButtons[j].UpTexture = texture'OrdersMidR';
				OptionButtons[j].DownTexture = texture'OrdersMidR';
			} else if (bLeft) {
				OptionButtons[j].OverTexture = texture'OrdersMidL';
				OptionButtons[j].UpTexture = texture'OrdersMidL';
				OptionButtons[j].DownTexture = texture'OrdersMidL';
			}
		} else {
			if (bPreserve && j == 0)
			{
				// Do nothing.
			} else {
				OptionButtons[j].OverTexture = texture'OrdersMid';
				OptionButtons[j].UpTexture = texture'OrdersMid';
				OptionButtons[j].DownTexture = texture'OrdersMid';
			}
		}
	}
}

defaultproperties
{
	WindowTitle="Orders"
	Options(0)="Acknowledge"
	Options(1)="Friendly Fire"
	Options(2)="Orders"
	Options(3)="Taunts"
	Options(4)="Other/Misc"
	Options(5)="Gesture"
	Options(6)="Order This Bot"
	NumOptions=7
	TopTexture=texture'OrdersTop'
	BottomTexture=texture'OrdersBtm'
	ButtonClass=class'SpeechButton'
}

