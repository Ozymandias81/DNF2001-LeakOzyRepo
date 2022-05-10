//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	noexport;

// Objects.
#exec Font Import File=Textures\SmallFont.bmp Name=SmallFont
#exec Font Import File=Textures\MedFont.pcx   Name=MedFont
#exec Font Import File=Textures\LargeFont.pcx Name=LargeFont
#exec Font Import File=Textures\BigFont.pcx   Name=BigFont

#exec Font Import File=Textures\MedFont2BC.pcx   Name=MedFont2BC

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var const int SizeX, SizeY;  // Zero-based actual dimensions.

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;            // Medium system font.
var font BigFont;            // Big system font.
var font LargeFont;          // Large system font.

// Internal.
var const viewport Viewport; // Viewport that owns the canvas.
var const int FramePtr;      // Scene frame pointer.
var const int RenderPtr;	 // Render device pointer, only valid during UGameEngine::Draw
var const int LoadedTTFonts[5]; // TMap<FString, UTextureCanvas*>

// native functions.
native(464) final function StrLen( coerce string String, out float XL, out float YL );
native(465) final function DrawText( coerce string Text, optional bool CR, optional bool Wrap, optional bool Clip, optional float XScale, optional float YScale );
native(466) final function DrawTile( texture Tex, float XL, float YL, float U, float V, float UL, float VL, optional float rotation,  optional float rotationOffsetX, optional float rotationOffsetY, optional bool bilinear, optional float alpha, optional bool mirrorHoriz, optional bool mirrorVert  );
native(467) final function DrawActor( Actor A, bool WireFrame, optional bool ClearZ );
native(468) final function DrawTileClipped( texture Tex, float XL, float YL, float U, float V, float UL, float VL, float fAlpha, bool bBilinear, float Rotation );
native(469) final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey );
native(470) final function TextSize( coerce string String, out float XL, out float YL, optional float XScale, optional float YScale );
native(471) final function DrawClippedActor( Actor A, bool WireFrame, int X, int Y, int XB, int YB, optional bool ClearZ );
native(479) final function DrawLine( vector P1, vector P2, optional bool Is3D );
native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );
native(481) final function GetScreenBounds( Actor A, out float X1, out float X2, out float Y1, out float Y2, optional bool Collision );
native(482) final function Font CreateTTFont( string TrueTypeFont, int PointSize, optional int FontWeight );
native(483) final function GetRenderBoundingBox( Actor A, out vector Min, out vector Max );
native(484) final function DrawCylinder( vector Location, float Radius, float Height );
native      final function SetClampMode( bool bClamp );

// Windows Font Weights
const FW_DONTCARE		= 0;
const FW_THIN			= 100;
const FW_EXTRALIGHT		= 200;
const FW_ULTRALIGHT		= 200;
const FW_LIGHT			= 300;
const FW_NORMAL			= 400;
const FW_REGULAR		= 400;
const FW_MEDIUM			= 500;
const FW_SEMIBOLD		= 600;
const FW_DEMIBOLD		= 600;
const FW_BOLD			= 700;
const FW_EXTRABOLD		= 800;
const FW_ULTRABOLD		= 800;
const FW_HEAVY			= 900;
const FW_BLACK			= 900;

// UnrealScript functions.
event Reset()
{
	Font        = Default.Font;
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
}
final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}
final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}
final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
}
final function DrawPattern( texture Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawScaledIcon( texture Tex, float ScaleX, float ScaleY, optional bool bNoBilinear )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*ScaleX, Tex.VSize*ScaleY, 0, 0, Tex.USize, Tex.VSize,,,,!bNoBilinear );
}
final function DrawScaledIconClipped( texture Tex, float ScaleX, float ScaleY, optional bool bNoBilinear )
{
	if ( Tex != None )
		DrawTileClipped( Tex, Tex.USize*ScaleX, Tex.VSize*ScaleY, 0, 0, Tex.USize, Tex.VSize, 1.0, !bNoBilinear, 0.0 );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawTextDropShadowed( coerce string Text, optional bool CR, optional bool Wrap, optional bool Clip )
{
	local float OldX, OldY;
	local color OldDrawColor;
	local byte OldStyle;
	OldX = CurX; OldY = CurY;
	OldDrawColor = DrawColor;
	OldStyle = Style;
	SetPos( CurX+1, CurY+1 );
	DrawColor.R = 0; DrawColor.G = 0; DrawColor.B = 0;
	Style = 1;
	DrawText( Text, CR, Wrap, Clip );
	SetPos( OldX, OldY );
	DrawColor = OldDrawColor;
	Style = OldStyle;
	DrawText( Text, CR, Wrap, Clip );
}

defaultproperties
{
     Style=1
	 Z=1
     DrawColor=(R=127,G=127,B=127)
     SmallFont=Font'Engine.SmallFont'
//     MedFont=Font'Engine.MedFont'
	 MedFont=Font'Engine.dancenation_font1BC'
	 BigFont=Font'Engine.dancenation_font1BC'
//     BigFont=Font'Engine.BigFont'
     LargeFont=Font'Engine.LargeFont'
}
