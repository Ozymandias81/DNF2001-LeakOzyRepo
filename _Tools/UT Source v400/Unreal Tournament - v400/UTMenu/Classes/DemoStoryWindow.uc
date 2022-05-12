class DemoStoryWindow extends UWindowWindow;

#exec TEXTURE IMPORT NAME=MediumU1 FILE=TEXTURES\U1.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=MediumU2 FILE=TEXTURES\U2.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=MediumU3 FILE=TEXTURES\U3.PCX GROUP=Skins MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=MediumU4 FILE=TEXTURES\U4.PCX GROUP=Skins MIPS=OFF FLAGS=2

var() localized string Title;
var() localized string Message[5];

var float YOffset2;

var float TimeCount;

event Tick(float Delta)
{
	Super.Tick(Delta);

	YOffset2 -= Delta*20;
}

function Created()
{
	local int i;
	local int W, H;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos;
	local color TextColor;

	Super.Created();

	Root.SetScale(1);

	bLeaveOnScreen = True;
	bAlwaysOnTop = True;
	class'UTLadder'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	YOffset2 = WinHeight;

	Root.Console.bBlackout = True;

	TimeCount = 0.1;
}

function Paint(Canvas C, float X, float Y)
{
	local int XOffset, YOffset;
	local int W, H, FontSize, i;
	local float XWidth, YHeight, XMod, YMod, XPos, YPos, XL, YL, YL2, XScale, YScale;
	local float OldClipX, OldClipY, OldOrgX, OldOrgY;

	class'UTLadder'.Static.SetupWinParams(Self, Root, W, H);

	XMod = 4*W;
	YMod = 3*H;

	XOffset = (WinWidth - (4 * W)) / 2;
	YOffset = (WinHeight - (3 * H)) / 2;

	OldClipX = C.ClipX;
	OldClipY = C.ClipY;
	OldOrgX = C.OrgX;
	OldOrgY = C.OrgY;

	// U symbol.
	XScale = 256.0/1024 * XMod;
	YScale = 256.0/768 * YMod;

	DrawStretchedTexture( C, C.ClipX/2 - XScale,      C.ClipY/2 - YScale,      XScale, YScale, texture'MediumU1' );
	DrawStretchedTexture( C, C.ClipX/2, C.ClipY/2 - YScale,      XScale, YScale, texture'MediumU2' );
	DrawStretchedTexture( C, C.ClipX/2 - XScale,      C.ClipY/2, XScale, YScale, texture'MediumU3' );
	DrawStretchedTexture( C, C.ClipX/2, C.ClipY/2, XScale, YScale, texture'MediumU4' );

	C.SetClip(WinWidth*2/3, WinHeight);
	C.SetOrigin(WinWidth/6, 0);

	C.Font = class'FontInfo'.Static.GetStaticBigFont( C.ClipX );
	FontSize = 18;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// Title...
	C.StrLen(Title, XL, YL);
	C.SetPos((C.ClipX - XL)/2, YOffset2 + YL2);
	C.DrawText(Title, False);
	YL2 += YL + FontSize;
	C.SetPos(0.0, YOffset2 + YL2);

	for (i=0; i<5; i++)
	{
		C.DrawText(Message[i], False);
		C.StrLen(Message[i], XL, YL);
		YL2 += YL + FontSize*3;
		C.SetPos(0.0, YOffset2 + YL2);
	}

	C.SetClip(OldClipX, OldClipY);
	C.SetOrigin(OldOrgX, OldOrgY);

	Root.Console.bBlackout = True;
}

function Close(optional bool bByParent)
{
	Root.Console.bBlackout = False;
	Root.Console.bLocked = False;
	Root.Console.bNoDrawWorld = Root.Console.ShowDesktop;
	UMenuRootWindow(Root).MenuBar.ShowWindow();
	Super.Close(bByParent);
}

defaultproperties
{
	Title="Congratulations!"
	Message(0)="Thank you for playing the demo version of Unreal Tournament.  So much more is in store for you in the full version of the game.  You'll get 50 levels of pure gaming excitement, all the weapons, new game modes and much, much more.  For complete information about pricing, availability and the latest news point your web browser to http://www.UnrealTournament.com."
	Message(1)=""
	Message(2)="This demo is based on a pre-release version of Unreal Tournament and you might experience problems with it.  We would sincerely appreciate your help in tracking down bugs.  Feel free to report any problems you encountered by sending an email to utbugs@epicgames.com."
	Message(3)="Thanks again for playing the Unreal Tournament demo!"
	Message(4)="Press [ESC] to continue."
}