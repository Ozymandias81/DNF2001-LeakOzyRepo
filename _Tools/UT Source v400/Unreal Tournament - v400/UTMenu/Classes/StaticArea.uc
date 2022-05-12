class StaticArea expands UWindowWindow;

#exec TEXTURE IMPORT NAME=VScreenStatic FILE=TEXTURES\Static\ScreenStatic.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=HScreenStatic1 FILE=TEXTURES\Static\HStatic1.PCX GROUP=Skins MIPS=OFF
#exec TEXTURE IMPORT NAME=HScreenStatic3 FILE=TEXTURES\Static\HStatic3.PCX GROUP=Skins MIPS=OFF

var float HStaticOffset, HStaticScale;
var bool bHPanStatic;
var texture HStaticTexture;
var bool HStaticLoop;
var float HStaticWidth;

var float VStaticOffset, VStaticScale;
var bool bVPanStatic;
var texture VStaticTexture;

function Paint(canvas C, float X, float Y)
{
	C.DrawColor.R = 50;
	C.DrawColor.G = 50;
	C.DrawColor.B = 50;
	C.Style = GetPlayerOwner().ERenderStyle.STY_Translucent;
	if (bVPanStatic)
		DrawStretchedTexture(C, 0, VStaticOffset, WinWidth, 32, VStaticTexture);
	if (bHPanStatic)
		DrawStretchedTexture(C, HStaticOffset, 0, HStaticWidth, WinHeight, HStaticTexture);
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function Tick(float Delta)
{
	if (bVPanStatic)
	{
		VStaticOffset += Delta * VStaticScale;
		if (VStaticOffset > WinHeight)
		{
			bVPanStatic = False;
			VStaticOffset = -32;
		}
	}

	if (bHPanStatic)
	{
		HStaticOffset += Delta * HStaticScale;
		if (HStaticOffset > WinWidth)
		{
			if (!HStaticLoop)
				bHPanStatic = False;
			HStaticOffset = -32;
		}
	}
}

function bool CheckMousePassThrough(float X, float Y)
{
	return True;
}

defaultproperties
{
	VStaticScale=1.0
	VStaticOffset=-32
	VStaticTexture=texture'utmenu.VScreenStatic'
	HStaticScale=1.0
	HStaticOffset=-32
	HStaticTexture=texture'utmenu.HScreenStatic1'
	HStaticWidth=32
}