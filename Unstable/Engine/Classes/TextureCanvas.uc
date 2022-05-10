//=============================================================================
// TextureCanvas. (NJS)
//=============================================================================
class TextureCanvas expands ProceduralTexture
		noexport
		native;

var transient const int PaletteMap;	// TMap<UTexture*, TArray<BYTE>>*
var transient byte Dirty;

// TextureCanvas natives:
native final function DrawPixel ( int x, int y, byte color );
native final function DrawLine  ( int x1, int y1, int x2, int y2, byte color );
native final function DrawString( font f, int x1, int y1, string formatString, optional bool proportional, optional bool wrap, optional bool masking, optional bool bUseColor, optional int PaletteEntry );
native final function DrawBitmap( int x,  int y, int left, int top, int right, int bottom, texture bMap, optional bool masking, optional bool wrap, optional bool scale );
native final function DrawClear ( byte color );
native final function DrawCircle( int x, int y, int radius, byte color, bool filled );
native final function DrawRectangle( int left, int top, int right, int bottom, byte color, bool filled );
native final function DrawStatic( );
native final function TextSize( string Text, out float XL, out float YL, Font Font );
native(456) final function ForceTick(float Delta);

final function DrawStringDropShadowed( font f, int x1, int y1, string formatString, optional bool proportional, optional bool wrap, optional bool masking, optional bool bUseColor, optional int PaletteEntry, optional int PaletteEntry2 )
{
	DrawString( f, x1+1, y1+1, formatString, proportional, wrap, masking, true, PaletteEntry2 );
	DrawString( f, x1, y1, formatString, proportional, wrap, masking, true, PaletteEntry );
}

defaultproperties
{
}
