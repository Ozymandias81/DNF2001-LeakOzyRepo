class UDukeInGameWindow extends NotifyWindow;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx

// Top list of options.
var				UDukeInGameButton		TopButton;
var				UDukeInGameButton		OptionButtons[32];
var				UDukeInGameButton		BottomButton;
var localized	string					Options[32];
var				int						NumOptions;
var				Class<UDukeInGameButton>ButtonClass;
										
// Voice information.					
var				int						CurrentType;
										
// Textures								
var				texture					TopTexture;
var				texture					BottomTexture;
										
// XOffset								
var				float					XOffset;
var				bool					bSlideIn, bSlideOut;
										
// Title								
var localized	string					WindowTitle;
										
// Children
var				UDukeInGameWindow		ChildWindow;

var				PlayerReplicationInfo	IdentifyTarget;

// Fade control
var				float					FadeFactor;
var				bool					bFadeIn, bFadeOut;

// current key pressed for key based menu navigation
var				byte					currentkey;

var				sound					QMenuHL;
var				sound					QMenuUse;

function Created()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	bAlwaysOnTop = true;
	bLeaveOnScreen = true;

	Super.Created();

	W = Root.WinWidth / 4;
	H = W;

	if( W > 256 || H > 256 )
	{
		W = 256;
		H = 256;
	}

	XMod = 4 * W;
	YMod = 3 * H;

	WinTop		= 0;
	WinLeft		= 0;
	WinWidth	= Root.WinWidth;
	WinHeight	= Root.WinHeight;

	// Top of menu
	TopButton = UDukeInGameButton( CreateWindow( class'UDukeInGameButton', 100, 100, 100, 100 ) );
	TopButton.NotifyWindow = Self;
	TopButton.Text = WindowTitle;
	//TopButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	TopButton.TextColor.R = 255;
	TopButton.TextColor.G = 255;
	TopButton.TextColor.B = 255;
	TopButton.XOffset = 20.0/1024.0 * XMod;
	TopButton.FadeFactor = 1.0;
	TopButton.bDisabled = true;
	TopButton.DisabledTexture = TopTexture;
	TopButton.bStretched = true;
	
	// Menu options
	for (i=0; i<NumOptions; i++)
	{
		OptionButtons[i] = UDukeInGameButton( CreateWindow( ButtonClass, 100, 100, 100, 100 ) );
		OptionButtons[i].NotifyWindow		= Self;
		OptionButtons[i].Text				= Options[i];
		//OptionButtons[i].MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
		OptionButtons[i].bLeftJustify		= true;
		OptionButtons[i].TextColor.R		= 255;
		OptionButtons[i].TextColor.G		= 255;
		OptionButtons[i].TextColor.B		= 255;
		OptionButtons[i].XOffset			= 20.0/1024.0 * XMod;
		OptionButtons[i].FadeFactor			= 1.0;
		OptionButtons[i].bHighlightButton	= true;
		OptionButtons[i].OverTexture		= texture'WhiteTexture';
		OptionButtons[i].UpTexture			= texture'BlackTexture';
		OptionButtons[i].DownTexture		= texture'BlackTexture';
		OptionButtons[i].Type				= i;
		OptionButtons[i].bStretched			= true;
	}

	// Bottom of menu
	BottomButton = UDukeInGameButton(CreateWindow(class'UDukeInGameButton', 100, 100, 100, 100));
	BottomButton.NotifyWindow		= Self;
	//BottomButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	BottomButton.TextColor.R		= 255;
	BottomButton.TextColor.G		= 255;
	BottomButton.TextColor.B		= 255;
	BottomButton.XOffset			= 20.0/1024.0 * XMod;
	BottomButton.FadeFactor			= 1.0;
	BottomButton.bDisabled			= true;
	BottomButton.DisabledTexture	= BottomTexture;
	BottomButton.bStretched			= true;
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

	WinTop		= 0;
	WinLeft		= 0;
	WinWidth	= Root.WinWidth;
	WinHeight	= Root.WinHeight;

	XWidth		= 256.0 / 1024.0  * XMod;
	YHeight		= 32.0  / 768.0   * YMod;
	YPos		= 164.0 / 768.0   * YMod;

	TopButton.SetSize( XWidth, YHeight );
	TopButton.XOffset = 20.0/1024.0 * XMod;
	TopButton.WinLeft = XOffset;
	TopButton.WinTop  = YPos;
	//TopButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	
	for( i=0; i<NumOptions; i++ )
	{
		OptionButtons[i].SetSize(XWidth, YHeight);
		OptionButtons[i].XOffset = 20.0/1024.0 * XMod;
		OptionButtons[i].WinLeft = XOffset;
		OptionButtons[i].WinTop  = YPos + (32.0/768.0*YMod)*(i+1);
		//OptionButtons[i].MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
	}
	BottomButton.SetSize(XWidth, YHeight);
	BottomButton.XOffset = 20.0/1024.0 * XMod;
	BottomButton.WinLeft = XOffset;
	BottomButton.WinTop  = YPos + (32.0/768.0*YMod)*(NumOptions+1);
	//BottomButton.MyFont = class'UTLadderStub'.Static.GetStubClass().Static.GetBigFont(Root);
}

function SlideOutWindow()
{
	SetButtonTextures( -1, false, false );
	XOffset		= 0;
	bSlideOut	= true;
	bSlideIn	= false;
	
	if ( ChildWindow != None )
		ChildWindow.FadeOut();

	ChildWindow = None;
	CurrentKey = -1;
}

function SlideInWindow()
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if ( W > 256 || H > 256 )
	{
		W = 256;
		H = 256;
	}	

	XMod = 4 * W;
	YMod = 3 * H;

	XOffset		= -256.0/1024.0 * XMod;
	bSlideIn	= true;
	bSlideOut	= false;

	ShowWindow();

	IdentifyTarget	= None;
	//NumOptions		= Default.NumOptions - 1;
	//OptionButtons[NumOptions].HideWindow();
	
	/*
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
	*/
}

function FadeIn()
{
	FadeFactor = 0;
	bFadeIn = true;
}

function FadeOut()
{
	FadeFactor = 100;
	bFadeOut = true;
	SetButtonTextures( -1, false, false );
	ChildWindow = None;
	CurrentKey = -1;
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
			bSlideIn = false;
		}
	}

	if ( bSlideOut )
	{
		XOffset -= Delta*800;

		if ( XOffset <= -256.0/1024.0 * XMod )
		{
			XOffset = -256.0/1024.0 * XMod;
			bSlideOut = false;

			if ( NextSiblingWindow == None )
			{

				HideWindow();
				// Have to set this bool to true for some god forsaken reason
				Root.Console.bCloseForSureThisTime = true;
				Root.Console.CloseUWindow();
				Root.Console.bQuickKeyEnable = false;
			} 
			else
			{
				HideWindow();
			}
		}
	}

	if ( bFadeIn )
	{
		FadeFactor += Delta * 700;
		if ( FadeFactor > 100 )
		{
			FadeFactor = 100;
			bFadeIn = false;
		}  
	}

	if ( bFadeOut )
	{
		FadeFactor -= Delta * 700;
		if (FadeFactor <= 0)
		{
			FadeFactor = 0;
			bFadeOut = false;
			HideWindow();

		}
	}
}

event bool KeyEvent( byte Key, byte Action, FLOAT Delta )
{
	local byte B;
	
	if ( CurrentKey == Key )
	{
		if ( Action == 3 ) // IST_Release
			CurrentKey = -1;
		return false;
	}

	if ( ChildWindow != None )
		return ChildWindow.KeyEvent(Key, Action, Delta);

	if ( Key == 38 )
	{
		CurrentKey = Key;
		Notify( TopButton, DE_Click );
		return true;
	}

	if ( Key == 40 )
	{
		CurrentKey = Key;
		Notify( BottomButton, DE_Click );
		return true;
	}
		
	B = Key - 48;
	
	if ( B == 0 )
		B = 9;
	else
		B -= 1;

	if ( ( B >= 0 ) && ( B < 10 ) )
	{
		CurrentKey = Key;
		Notify( OptionButtons[B], DE_Click );
		return true;
	}

	return false;		
}

function Notify( UWindowWindow B, byte E )
{
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, YOffset, BottomTop;
	local color TextColor;
	local int i;

	W = Root.WinWidth / 4;
	H = W;

	if ( W > 256 || H > 256 )
	{
		W = 256;
		H = 256;
	}

	XMod = 4 * W;
	YMod = 3 * H;

	switch (E)
	{
		case DE_Click:
			GetPlayerOwner().PlaySound( QMenuUse, SLOT_Interface );
			switch (B)
			{			

			case OptionButtons[0]: // Ack
			case OptionButtons[1]: // FF
			case OptionButtons[3]: // Taunts
			case OptionButtons[4]: // Other
				//SetButtonTextures( UDukeInGameButton( B ).Type, false, true );
				CurrentType = UDukeInGameButton( B ).Type;
				HideChildren();
				ChildWindow = UDukeInGameWindow( CreateWindow( class'UDukeInGameWindowSpeech', 100, 100, 100, 100 ) );
				ChildWindow.FadeIn();
				break;

			case OptionButtons[2]: // Orders

				break;

			case OptionButtons[6]: // Class changes
				CurrentType = UDukeInGameButton( B ).Type;
				HideChildren();
				ChildWindow = UDukeInGameWindow( CreateWindow( class'UDukeInGameWindowClasses', 100, 100, 100, 100 ) );
				ChildWindow.FadeIn();
				break;

			case OptionButtons[5]: // Gesture
				break;
			
			case OptionButtons[7]: //Change Teams
				//SetButtonTextures( UDukeInGameButton( B ).Type, false, true );
				CurrentType = UDukeInGameButton( B ).Type;
				HideChildren();
				ChildWindow = UDukeInGameWindow( CreateWindow( class'UDukeInGameWindowTeams', 100, 100, 100, 100 ) );
				ChildWindow.FadeIn();
				break;

			case OptionButtons[8]: //Spectator
				//SetButtonTextures( UDukeInGameButton( B ).Type, false, true );
				CurrentType = UDukeInGameButton( B ).Type;
				HideChildren();
				ChildWindow = UDukeInGameWindow( CreateWindow( class'UDukeInGameWindowSpectator', 100, 100, 100, 100 ) );
				ChildWindow.FadeIn();
				break;
			}
			break;
		case DE_MouseEnter:
			GetPlayerOwner().PlaySound( QMenuHL, SLOT_Interface );
			break;
	}
}

function HideChildren()
{
	if ( ChildWindow != None )
		ChildWindow.HideWindow();
}

function SetButtonTextures(int i, optional bool bLeft, optional bool bRight, optional bool bPreserve)
{
	/*
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
	*/
}

defaultproperties
{
	WindowTitle="Quick Menu"
	Options(0)="Acknowledge"
	Options(1)="Friendly Fire"
	Options(2)="Orders"
	Options(3)="Taunts"
	Options(4)="Other/Misc"
	Options(5)="Gesture"
	Options(6)="Change Class"
	Options(7)="Change Teams"
	Options(8)="Spectator"

	NumOptions=9
    QMenuHL=Sound'a_generic.Menu.QMenuHL1'
    QMenuUse=Sound'a_generic.Menu.QMenuUse1'
	TopTexture=Texture't_generic.logo.genlogoedf1'
	BottomTexture=Texture't_generic.logo.genlogoedf1'
	ButtonClass=class'UDukeInGameButton'
}

