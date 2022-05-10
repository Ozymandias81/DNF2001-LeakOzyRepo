//=============================================================================
// Texture: An Unreal texture map.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Texture extends Bitmap
	safereplace
	native
	noexport;

// Subtextures.
var(Texture) texture BumpMap;		// Bump map to illuminate this texture with.
var(Texture) texture DetailTexture;	// Detail texture to apply.
var(Texture) texture MacroTexture;	// Macrotexture to apply, not currently used.

// Surface properties.
var(Texture) float Diffuse;			// Diffuse lighting coefficient.
var(Texture) float Specular;		// Specular lighting coefficient.
var(Texture) float Alpha;			// Alpha.
var(Texture) float DrawScale;       // Scaling relative to parent.
var(Texture) float Friction;		// Surface friction coefficient, 1.0=none, 0.95=some.
var(Texture) float MipMult;         // Mipmap multiplier.

// Sounds.
var transient class<Material> Material;		// Obsoleto toledo.		
var() name					  MaterialName;	// Name of material to use.
var() texture ChangeTextureOnHit;		// OBSOLETE: If true, switch to texture specified on hit.

// Poly Surface flags. !!out of date
var          bool bInvisible;			// 1
var(Surface) editconst bool bMasked;	// 2
var(Surface) bool bTransparent;			// 3
var          bool bNotSolid;			// 4
var(Surface) bool bEnvironment;			// 5
var          bool bSemisolid;			// 6
var(Surface) bool bModulate;			// 7
var(Surface) bool bFakeBackdrop;		// 8
var(Surface) bool bTwoSided;			// 9
var(Surface) bool bAutoUPan;			// 10 
var(Surface) bool bAutoVPan;			// 11
var(Surface) bool bNoSmooth;			// 12
var(Surface) bool bBigWavy;				// 13
var(Surface) bool bSmallWavy;			// 14
var(Surface) bool bWaterWavy;			// 15
var          bool bLowShadowDetail;		// 16
var          bool bNoMerge;				// 17
var(Surface) bool bCloudWavy;			// 18
var          bool bDirtyShadows;		// 19
var          bool bHighLedge;			// 20 
var          bool bSpecialLit;			// 21
var          bool bGouraud;				// 22
var(Surface) bool bUnlit;				// 23
var          bool bHighShadowDetail;	// 24
var          bool bPortal;				// 25
var          const bool bMirrored, bX2, bX3; // 26, 27, 28
var          const bool bX4, bX5, bX6, bX7;	 // 29, 30, 31, 32

// Texture flags.
var(Quality) private  bool bHighColorQuality;   // High color quality hint.
var(Quality) private  bool bHighTextureQuality; // High color quality hint.
var private           bool bRealtime;           // Texture changes in realtime.
var private           bool bParametric;         // Texture data need not be stored.
var private transient bool bRealtimeChanged;    // Changed since last render.
var private           bool bHasComp;			// Whether a compressed version exists.

// Level of detail set.
var(Quality) enum ELODSet
{
	LODSET_None,   // No level of detail mipmap tossing.
	LODSET_World,  // World level-of-detail set.
	LODSET_Skin,   // Skin level-of-detail set.
} LODSet;

// Animation.
var(Animation) texture AnimNext;
var(Animation) transient  texture AnimCurrent;	// NJS: Just want to look at it for debugging purposes.
var(Animation) byte    PrimeCount;
var transient  byte    PrimeCurrent;
var(Animation) float   MinFrameRate, MaxFrameRate;
var transient  float   Accumulator;

// Mipmaps.
var private native const array<int> Mips, CompMips;
var const ETextureFormat CompFormat;

var(Surface) bool bAlphaMap;
var			 bool bClip;
var			 bool bDepthFog;
var			 bool bFlatShade;
var(Surface) bool bLightenModulate;
var(Surface) bool bDarkenModulate;
var(Surface) bool bTranslucent2;
var			 bool PolyFlagsEx8;
var			 bool PolyFlagsEx9;
var			 bool PolyFlagsEx10;
var			 bool PolyFlagsEx11;
var			 bool PolyFlagsEx12;
var			 bool PolyFlagsEx13;
var			 bool PolyFlagsEx14;
var			 bool PolyFlagsEx15;
var			 bool PolyFlagsEx16;
var			 bool PolyFlagsEx17;
var			 bool PolyFlagsEx18;
var			 bool PolyFlagsEx19;
var			 bool PolyFlagsEx20;
var			 bool PolyFlagsEx21;
var			 bool PolyFlagsEx22;
var			 bool PolyFlagsEx23;
var			 bool PolyFlagsEx24;
var			 bool PolyFlagsEx25;
var			 bool PolyFlagsEx26;
var			 bool PolyFlagsEx27;
var			 bool PolyFlagsEx28;
var			 bool PolyFlagsEx29;
var			 bool PolyFlagsEx30;
var			 bool PolyFlagsEx31;
var			 bool PolyFlagsEx32;


// #if DNF
// NJS:
// CollisionCheck checks for a collision between this texture and 
// another texture. (Masking color doesn't collide) The offsets of the 
// textures from each other are supplied and the function returns true if they do collide.
intrinsic final function bool CollisionCheck( int x, int y, texture Other, int oX, int oY );

// DrawGetPixel returns the pixel at x,y in this TextureCanvas 
// if x and y are out of bounds, then this function returns 0
intrinsic final function byte GetPixel( int x, int y );
// #endif

// Sets the texture's material based on the fname:
final simulated function class<Material> GetMaterial()
{
	if((Material==none)&&(MaterialName!=''))
		Material=class<Material>(DynamicLoadObject("dnMaterial."$MaterialName, class'Class', false));

	return Material;
}

defaultproperties
{
	MipMult=1
	Diffuse=1
	Specular=1
	DrawScale=1
	Friction=1
	LODSet=LODSET_World
	ChangeTextureOnHit=none
}

