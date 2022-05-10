/*=============================================================================
	UnCanvas.cpp: Unreal canvas rendering.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney
	* 31/3/99 Updated revision history - Jack Porter
=============================================================================*/

#include "EnginePrivate.h"

#ifdef _UNICODE
	typedef UNICHAR  TCHAR;
	typedef UNICHARU TCHARU;
#else
	typedef ANSICHAR  TCHAR;
	typedef ANSICHARU TCHARU;
#endif

/*-----------------------------------------------------------------------------
	UCanvas object management.
-----------------------------------------------------------------------------*/

void UCanvas::NotifyLevelChange()
{
//	GWarn->Logf( TEXT("Unloading TrueType fonts.") );
//	LoadedTTFonts.Empty();
}

void UCanvas::Shutdown()
{
	GLog->Logf( TEXT("Unloading TrueType fonts.") );
	LoadedTTFonts.Empty();
}

/*-----------------------------------------------------------------------------
	UCanvas scaled sprites.
-----------------------------------------------------------------------------*/

//
// Draw arbitrary aligned rectangle.
//
void UCanvas::DrawTile
(
	UTexture*		Texture,
	FLOAT			X,
	FLOAT			Y,
	FLOAT			XL,
	FLOAT			YL,
	FLOAT			U,
	FLOAT			V,
	FLOAT			UL,
	FLOAT			VL,
	FSpanBuffer*	SpanBuffer,
	FLOAT			Z,
	FPlane			Color,
	FPlane			Fog,
	DWORD			PolyFlags,
	DWORD			PolyFlagsEx,
	UBOOL			bilinear,
	FLOAT			alpha,
	FLOAT			rotation,
	FLOAT			rotationOffsetX, 
	FLOAT			rotationOffsetY
)
{
	check(Texture);
	//(ClipX, ClipY, OrgX, OrgY)
	// Compute clipping region.
	FLOAT ClipY0 = 0;
	FLOAT ClipY1 = Frame->FY;

	// Reject.
	if( XL<=0.f      || YL<=0.f      || 
		X+XL<=0.f    || Y+YL<=ClipY0 || 
		X>=Frame->FX || Y>=ClipY1    || 
		!Texture )
		return;

	if(!Viewport->RenDev->QueuePolygonDoes())
	{
		// Clip.
		if( X<0.f )			 { FLOAT C=X*UL/XL; U-=C; UL+=C; XL+=X; X=0.f; }
		if( Y<0.f )			 { FLOAT C=Y*VL/YL; V-=C; VL+=C; YL+=Y; Y=0.f; }
		if( XL>Frame->FX-X ) { UL+=(Frame->FX-X-XL)*UL/XL; XL=Frame->FX-X; }
		if( YL>Frame->FY-Y ) { VL+=(Frame->FY-Y-YL)*VL/YL; YL=Frame->FY-Y; }
	}

	// Draw it.
	FTextureInfo Info;
	
	// Update the texture's animaiton:
	if( !GIsEditor )
		Texture = Texture->Get( Viewport->CurrentTime );

	// Lock the texture for rendering:
	Texture->Lock( Info, Viewport->CurrentTime, -1, Viewport->RenDev );
	FLOAT UF = Info.UScale * Info.USize / Texture->USize; U *= UF; UL *= UF;
	FLOAT VF = Info.VScale * Info.VSize / Texture->VSize; V *= VF; VL *= VF;

	// Draw the tile:
	Viewport->RenDev->DrawTile( Frame, Info, 
								X, Y, 
								XL, YL, 
								U, V, 
								UL, VL, 
								SpanBuffer, 
								Z, 
								Color, Fog, 
								PolyFlags | (Texture->PolyFlags&PF_Masked) | (bilinear?0:PF_NoSmooth),
								PolyFlagsEx,
								alpha,
								rotation,
								rotationOffsetX,
								rotationOffsetY
	);
	Texture->Unlock( Info );
}

//
// Draw titling pattern.
//
void UCanvas::DrawPattern
(
	UTexture*		Texture,
	FLOAT			X,
	FLOAT			Y,
	FLOAT			XL,
	FLOAT			YL,
	FLOAT			Scale,
	FLOAT			OrgX,
	FLOAT			OrgY,
	FSpanBuffer*	SpanBuffer,
	FLOAT			Z,
	FPlane			Color,
	FPlane			Fog,
	DWORD			PolyFlags,
	DWORD			PolyFlagsEx
)
{
	DrawTile( Texture, X, Y, XL, YL, (X-OrgX)*Scale + Texture->USize, (Y-OrgY)*Scale + Texture->VSize, XL*Scale, YL*Scale, SpanBuffer, Z, Color, Fog, PolyFlags, PolyFlagsEx);
}

//
// Draw a scaled sprite.  Takes care of clipping.
// XSize and YSize are in pixels.
//
void UCanvas::DrawIcon
(
	UTexture*			Texture,
	FLOAT				ScreenX, 
	FLOAT				ScreenY, 
	FLOAT				XSize, 
	FLOAT				YSize, 
	FSpanBuffer*		SpanBuffer,
	FLOAT				Z,
	FPlane				Color,
	FPlane				Fog,
	DWORD				PolyFlags,
	DWORD				PolyFlagsEx,
	UBOOL				Bilinear,
	FLOAT				AlphaValue,
	FLOAT				rot

)
{
	DrawTile( Texture, ScreenX, ScreenY, XSize, YSize, 0, 0, Texture->USize, Texture->VSize, SpanBuffer, Z, Color, Fog, PolyFlags, PolyFlagsEx, Bilinear, AlphaValue, rot); 
}

// CDH...
void UCanvas::DrawLine(FVector P1, FVector P2, UBOOL Is3D)
{
	if (!Is3D)
		Viewport->RenDev->Draw2DLine(Frame, Color.Plane(), 0, P1, P2);
	else
	{
		Viewport->RenDev->Queue3DLine(Frame, Color.Plane(), LINE_DepthCued, P1, P2);	
		Viewport->RenDev->Queued3DLinesFlush(Frame);
	}
}
// ...CDH

/*-----------------------------------------------------------------------------
	Clip window.
-----------------------------------------------------------------------------*/

void UCanvas::SetClip( INT X, INT Y, INT XL, INT YL )
{
	CurX  = 0;
	CurY  = 0;
	OrgX  = X;
	OrgY  = Y;
	ClipX = XL;
	ClipY = YL;
}

/*-----------------------------------------------------------------------------
	UCanvas basic text functions.
-----------------------------------------------------------------------------*/

//
// Draw a character.
//
static inline void DrawChar
(
	DWORD			Flags,
	UCanvas*		Canvas,
	FTextureInfo&	Info,
	INT				X,
	INT				Y,
	INT				XL,
	INT				YL,
	INT				U, 
	INT				V, 
	INT				UL, 
	INT				VL, 
	FPlane			Color,
	FLOAT			XScale=1.0,
	FLOAT			YScale=1.0
)
{
	// Reject.
	DWORD PolyFlagsEx=0;
	FSceneNode* Frame=Canvas->Frame;

	if( !(Flags & PF_Invisible) && X+XL>0 && Y+YL>0 && X<Frame->X && Y<Frame->Y && XL>0 && YL>0 )
	{
		// Clip.
		if( X<0 )			{INT C=X*UL/XL; U-=C; UL+=C; XL+=X; X=0;}
		if( Y<0 )			{INT C=Y*VL/YL; V-=C; VL+=C; YL+=Y; Y=0;}
		if( XL>Frame->X-X )	{UL+=(Frame->X-X-XL)*UL/XL; XL=Frame->X-X;}
		if( YL>Frame->Y-Y )	{VL+=(Frame->Y-Y-YL)*VL/YL; YL=Frame->Y-Y;}

		// Adjust length for font scales.
		XL = appCeil( ((FLOAT) UL)*XScale );
		YL = appCeil( ((FLOAT) VL)*YScale );

		// Draw.
		Frame->Viewport->RenDev->DrawTile( Frame, Info, X, Y, XL, YL, U, V, UL, VL, NULL, Canvas->Z, Color, FPlane(0,0,0,0), Flags, PolyFlagsEx, /*false,*/ 1.0 );
	}
}

//
// Draw a string of characters.
// - returns pixels drawn
//
static inline INT DrawString
(
	DWORD			Flags, 
	UCanvas*		Canvas, 
	UFont*			Font, 
	INT				DrawX, 
	INT				DrawY,
	const TCHAR*	Text, 
	FPlane			Color, 
	UBOOL			bClip, 
	UBOOL			bHandleApersand,
	FLOAT			XScale=1.0,
	FLOAT			YScale=1.0
)
{
	// Font texture pages.
	FTextureInfo Infos[5];
	Infos[0].Texture=Infos[1].Texture=Infos[2].Texture=Infos[3].Texture=Infos[4].Texture=NULL;

	// Draw all characters in string.
	INT LineX = 0;
	INT bDrawUnderline = 0;
	INT UnderlineWidth = 0;
	for( INT i=0; Text[i]; i++ )
	{
		INT bUnderlineNext = 0;
		INT Ch = (TCHARU)Text[i];

		// Handle ampersand underlining.
		if( bHandleApersand )
		{
			if( bDrawUnderline )
				Ch = (TCHARU)('_');
			if( Text[i]=='&' )
			{
				if( !Text[i+1] )
					break; 
				if( Text[i+1]!='&' )
				{
					bUnderlineNext = 1;
					Ch = (TCHARU)Text[i+1];
				}
			}
		}

		// Process character if it's valid.
		INT NewPage = Ch / Font->CharactersPerPage;
		UTexture* Tex;
		if( NewPage<Font->Pages.Num() && (Tex=Font->Pages(NewPage).Texture)!=NULL )
		{
			INT        Index    = Ch - NewPage*Font->CharactersPerPage;
			FFontPage& PageInfo = Font->Pages(NewPage);
			if( Index<PageInfo.Characters.Num() )
			{
				// Get proper font page.
				FTextureInfo& Info = Infos[Min(NewPage,4)];
				if( Info.Texture!=Tex )
				{
					if( Info.Texture )
						Info.Texture->Unlock( Info );
					Tex->Lock( Info, Canvas->Viewport->CurrentTime, 0, Canvas->Viewport->RenDev );
				}
				FFontCharacter& Char = PageInfo.Characters(Index);

				// Compute character width.
				INT CharWidth;
				if( bDrawUnderline )
					CharWidth = Min(UnderlineWidth, Char.USize);
				else
					CharWidth = Char.USize;

				INT CharHeight = Char.VSize;

				// Prepare for clipping.
				INT X      = LineX + DrawX;
				INT Y      = DrawY;
				INT CU     = Char.StartU;
				INT CV     = Char.StartV;
				INT CUSize = CharWidth;
				INT CVSize = CharHeight;

				// Draw if it passes clip test.
				if
				(	(!bClip)
				||	(X+CUSize>0 && X<=Canvas->ClipX && Y+CVSize>0 && Y<=Canvas->ClipY) )
				{
					if( bClip )
					{
						if( X        < 0.f           ) { CU-=X; CUSize+=X; X=0;  }
						if( Y        < 0.f           ) { CV-=Y; CVSize+=Y; Y=0;  }
						if( X+CUSize > Canvas->ClipX ) { CUSize=(INT) (Canvas->ClipX-X); }
						if( Y+CVSize > Canvas->ClipY ) { CVSize=(INT) (Canvas->ClipY-Y); } 
					}
					INT CXL = appCeil( ((FLOAT) CUSize) * XScale );
					INT CYL = appCeil( ((FLOAT) CVSize) * YScale );
					DrawChar( Flags, Canvas, Info, (INT) (Canvas->OrgX+X), (INT) (Canvas->OrgY+Y), CXL, CYL, CU, CV, CUSize, CVSize, Color, XScale, YScale );
				}

				// Update underline status.
				if( bDrawUnderline )
					CharWidth = UnderlineWidth;

				if( !bUnderlineNext )
				{
					INT CXL = appCeil( ((FLOAT) CUSize) * XScale );
					LineX += (INT) (CXL + Canvas->SpaceX);
				}
				else
					UnderlineWidth = Char.USize;

				bDrawUnderline = bUnderlineNext;
			}
		}
	}

	// Unlock font pages.
	for( i=0; i<5; i++ )
		if( Infos[i].Texture )
			Infos[i].Texture->Unlock( Infos[i] );

	return LineX;
}

//
// Get a character's dimensions.
//
static inline void GetCharSize( UFont* Font, TCHAR InCh, INT& Width, INT& Height, UBOOL IsTrueType )
{
	// Determine the character size.
	Width = 0;
	Height = 0;
	INT Ch    = (TCHARU)InCh;
	INT Page  = Ch / Font->CharactersPerPage;
	INT Index = Ch - Page * Font->CharactersPerPage;
	if( Page<Font->Pages.Num() && Index<Font->Pages(Page).Characters.Num() )
	{
		FFontCharacter& Char = Font->Pages(Page).Characters(Index);
		Width = Char.USize;
		if (IsTrueType)
		{
			UFontTrueType* FTT = (UFontTrueType*) Font;
			Height = *FTT->VHeights.Find(InCh);
		} else
			Height = Char.VSize;
	}
}

//
// Compute size and optionally print text with word wrap.
//!!For the next generation, redesign to ignore CurX,CurY.
//
void VARARGS UCanvas::WrappedPrint( ERenderStyle Style, INT& XL, INT& YL, UFont* Font, UBOOL Center, const TCHAR* Text, UBOOL Clip, FLOAT XScale, FLOAT YScale )
{
	//if( GIsEditor )
	//	return;
	if( ClipX<0 || ClipY<0 )
		return;
	if( (Font==LargeFont || Font==BigFont) && appStricmp(UObject::GetLanguage(),TEXT("INT")) )
		Font = MedFont;//BigFont;!!
	check(Font);
	FPlane DrawColor = Color.Plane();

	// Generate flags.
	DWORD PolyFlags
	=	(PF_Masked | PF_RenderHint)
	|(	(Style==STY_None       ) ? PF_Invisible
	:	(Style==STY_Translucent) ? PF_Translucent
	:	(Style==STY_Modulated  ) ? PF_Modulated
	:	                           0);

	// Check and see if this font is a TrueType.
	UBOOL IsTrueType = 0;
	for (TMap<FString, UFont*>::TIterator It(LoadedTTFonts); It; ++It)
	{
		if (It.Value() == Font)
			IsTrueType = 1;
	}

	// Process each word until the current line overflows.
	XL = YL = 0;
	do
	{
		INT iCleanWordEnd=0, iTestWord;
		INT TestXL=(INT)CurX, CleanXL=0;
		INT TestYL=0,    CleanYL=0;
		UBOOL GotWord=0;
		for( iTestWord=0; Text[iTestWord]!=0 && Text[iTestWord]!='\n'; )
		{
			INT ChW, ChH;
			GetCharSize(Font, Text[iTestWord], ChW, ChH, IsTrueType);
			ChW = appCeil( ((FLOAT) ChW) * XScale );
			ChH = appCeil( ((FLOAT) ChH) * YScale );
			TestXL              += (INT) (ChW + SpaceX);
			TestYL               = Max( TestYL, ChH + (INT)SpaceY );
			if( TestXL>ClipX )
				break;
			iTestWord++;
			UBOOL WordBreak = Text[iTestWord]==' ' || Text[iTestWord]=='\n' || Text[iTestWord]==0;
			if( WordBreak || !GotWord )
			{
				iCleanWordEnd = iTestWord;
				CleanXL       = TestXL;
				CleanYL       = TestYL;
				GotWord       = GotWord || WordBreak;
			}
		}
		if( iCleanWordEnd==0 )
			break;

		// Sucessfully split this line, now draw it.
		if( Style!=STY_None && OrgY+CurY<Frame->Y && OrgY+CurY+CleanYL>0 )
		{
			FString TextLine(Text);
			INT LineX = Center ? (INT) (CurX+(ClipX-CleanXL)/2) : (INT) (CurX);
			LineX += DrawString( PolyFlags, this, Font, LineX, (INT) CurY, *(TextLine.Left(iCleanWordEnd)), DrawColor, Clip, 0, XScale, YScale );
			CurX = LineX;
		}

		// Update position.
		CurX  = 0;
		CurY += CleanYL;
		YL   += CleanYL;
		XL    = Max(XL,CleanXL);
		Text += iCleanWordEnd;

		// Skip whitespace after word wrap.
		while( *Text==' ' )
			Text++;

	} while( *Text );
}

/*-----------------------------------------------------------------------------
	UCanvas derived text functions.
-----------------------------------------------------------------------------*/

//
// Calculate the size of a string built from a font, word wrapped
// to a specified region.
//
void UCanvas::WrappedStrLenf( UFont* Font, INT& XL, INT& YL, const TCHAR* Fmt, ... )
{
	TCHAR Text[4096];
	GET_VARARGS( Text, ARRAY_COUNT(Text), Fmt );

	WrappedPrint( STY_None, XL, YL, Font, 0, Text );
}

//
// Wrapped printf.
//
void VARARGS UCanvas::WrappedPrintf( UFont* Font, UBOOL Center, const TCHAR* Fmt, ... )
{
	TCHAR Text[4096];
	GET_VARARGS( Text, ARRAY_COUNT(Text), Fmt );

	INT XL=0, YL=0;
	WrappedPrint( STY_Normal, XL, YL, Font, Center, Text );
}

/*-----------------------------------------------------------------------------
	UCanvas object functions.
-----------------------------------------------------------------------------*/

void UCanvas::Init( UViewport* InViewport )
{
	Viewport = InViewport;
}
void UCanvas::Update( FSceneNode* InFrame )
{
	// Call UnrealScript to reset.
	eventReset();

	// Copy size parameters from viewport.
	Frame = InFrame;
	ClipX = Frame->X;
	X = (INT) ClipX;
	ClipY = Frame->Y;
	Y = (INT) ClipY;
}

/*-----------------------------------------------------------------------------
	UCanvas natives.
-----------------------------------------------------------------------------*/

void UCanvas::execStrLen( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(InText);
	P_GET_FLOAT_REF(XL);
	P_GET_FLOAT_REF(YL);
	P_FINISH;

	INT XLi, YLi;
	INT OldCurX, OldCurY;
	OldCurX = (INT) CurX;
	OldCurY = (INT) CurY;
	CurX = 0;
	CurY = 0;
	WrappedStrLenf( Font, XLi, YLi, TEXT("%s"), *InText );
	CurY = OldCurY;
	CurX = OldCurX;
	*XL = XLi;
	*YL = YLi;
}
IMPLEMENT_FUNCTION( UCanvas, 464, execStrLen );

void UCanvas::execDrawText( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(InText);
	P_GET_UBOOL_OPTX(CR,1);
	P_GET_UBOOL_OPTX(Wrap,1);
	P_GET_UBOOL_OPTX(Clip,0);
	P_GET_FLOAT_OPTX(XScale,1.0);
	P_GET_FLOAT_OPTX(YScale,1.0);
	P_FINISH;
	if( !Font )
	{
		Stack.Logf( TEXT("DrawText: No font") );
		return;
	}
	INT XL=0, YL=0;
	if( Style!=STY_None )
	{
		if (Wrap)
			WrappedPrint( (ERenderStyle)Style, XL, YL, Font, bCenter, *InText, Clip, XScale, YScale );
		else {
			FPlane DrawColor = Color.Plane();
			DWORD PolyFlags
			=	(PF_Masked | PF_RenderHint)
			|(	(Style==STY_None       ) ? PF_Invisible
			:	(Style==STY_Translucent) ? PF_Translucent
			:	(Style==STY_Modulated  ) ? PF_Modulated
			:	                           0);
			DrawString( PolyFlags, this, Font, (INT) CurX, (INT) CurY, *InText, DrawColor, Clip, 0, XScale, YScale );
		}
	}
	CurX += XL;
	CurYL = Max(CurYL,(FLOAT)YL);
	if( CR )
	{
		CurX  = 0;
		CurY += CurYL;
		CurYL = 0;
	}
}
IMPLEMENT_FUNCTION( UCanvas, 465, execDrawText );

void UCanvas::execDrawTile( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UTexture,Tex);
	P_GET_FLOAT(XL);
	P_GET_FLOAT(YL);
	P_GET_FLOAT(U);
	P_GET_FLOAT(V);
	P_GET_FLOAT(UL);
	P_GET_FLOAT(VL);
	P_GET_FLOAT_OPTX(rotation,0);
	P_GET_FLOAT_OPTX(rotationOffsetX,0);
	P_GET_FLOAT_OPTX(rotationOffsetY,0);
	P_GET_UBOOL_OPTX(bilinear,1);
	P_GET_FLOAT_OPTX(alpha,1.0);
	P_GET_UBOOL_OPTX(mirrorHoriz,0);
	P_GET_UBOOL_OPTX(mirrorVert,0);
	P_FINISH;
	DWORD PolyFlagsEx=0;
	if(mirrorHoriz) PolyFlagsEx|=PFX_MirrorHorizontal;
	if(mirrorVert)  PolyFlagsEx|=PFX_MirrorVertical;

	if(!alpha) alpha=1;
	if( !Tex )
	{
		Stack.Logf( TEXT("DrawTile: Missing Texture") );
		return;
	}
	if( Style!=STY_None ) DrawTile
	(
		Tex,
		OrgX+CurX,
		OrgY+CurY,
		XL,
		YL,
		U,
		V,
		UL,
		VL,
		NULL,
		Z,
		Color.Plane(),
		FPlane(0,0,0,0),
		PF_TwoSided | (Style==STY_Masked ? PF_Masked : Style==STY_Translucent ? PF_Translucent : Style==STY_Modulated ? PF_Modulated : 0) | (bNoSmooth ? PF_NoSmooth : 0),
		PolyFlagsEx,
		bilinear, 
		alpha,
		rotation,
		rotationOffsetX, 
		rotationOffsetY//,
		//mirrorHoriz,
		//mirrorVert
	);

	CurX += XL + SpaceX;
	CurYL = Max(CurYL,YL);
}
IMPLEMENT_FUNCTION( UCanvas, 466, execDrawTile );

void UCanvas::execDrawLine( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(P1);
	P_GET_VECTOR(P2);
	P_GET_UBOOL_OPTX(Is3D, 0);
	P_FINISH;

	DrawLine(P1, P2, Is3D);
}
IMPLEMENT_FUNCTION( UCanvas, 479, execDrawLine );

void UCanvas::execDrawActor( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(AActor, Actor);
	P_GET_UBOOL(WireFrame);
	P_GET_UBOOL_OPTX(ClearZ, 0);
	P_FINISH;

	INT OldRendMap;
	OldRendMap = Viewport->Actor->RendMap;
	if( WireFrame )
		Viewport->Actor->RendMap = REN_Wire;
	Actor->bHidden = 0;
	if( ClearZ )
		Viewport->RenDev->ClearZ( Frame );
	Render->DrawActor( Frame, Actor );
	Actor->bHidden = 1;
	Viewport->Actor->RendMap = OldRendMap;
}
IMPLEMENT_FUNCTION( UCanvas, 467, execDrawActor );

void UCanvas::execDrawClippedActor( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(AActor, Actor);
	P_GET_UBOOL(WireFrame);
	P_GET_INT(X);
	P_GET_INT(Y);
	P_GET_INT(XB);
	P_GET_INT(YB);
	P_GET_UBOOL_OPTX(ClearZ, 0);
	P_FINISH;
	
	INT OldX, OldY, OldXB, OldYB;
	INT OldRendMap;

	OldX = Frame->X;
	OldY = Frame->Y;
	OldXB = Frame->XB;
	OldYB = Frame->YB;

	Frame->X = X;
	Frame->Y = Y;
	Frame->XB = XB;
	Frame->YB = YB;

	FVector V(0,0,0);
	FRotator R(0,0,0);

	Frame->ComputeRenderCoords( V, R );
	Frame->ComputeRenderSize();

	OldRendMap = Viewport->Actor->RendMap;
	if (WireFrame)
		Viewport->Actor->RendMap = REN_Wire;
	Actor->bHidden = 0;
	if (ClearZ)
		Viewport->RenDev->ClearZ(Frame);
	Render->DrawActor(Frame, Actor);
	Actor->bHidden = 1;
	Viewport->Actor->RendMap = OldRendMap;
	
	Frame->X = OldX;
	Frame->Y = OldY;
	Frame->XB = OldXB;
	Frame->YB = OldYB;
	Frame->ComputeRenderSize();
}
IMPLEMENT_FUNCTION( UCanvas, 471, execDrawClippedActor );

void UCanvas::execDrawTileClipped( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UTexture,Tex);
	P_GET_FLOAT(XL);
	P_GET_FLOAT(YL);
	P_GET_FLOAT(U);
	P_GET_FLOAT(V);
	P_GET_FLOAT(UL);
	P_GET_FLOAT(VL);
	P_GET_FLOAT(fAlpha);
	P_GET_UBOOL(bBilinear);
	P_GET_FLOAT(rotation);
	P_FINISH;

	DWORD PolyFlagsEx=0;
	if( !Tex )
	{
		Stack.Logf( TEXT("DrawTileClipped: Missing Texture") );
		return;
	}

	// Clip to ClipX and ClipY
	if( XL > 0 && YL > 0 )
	{		
		if( CurX<0 )		{FLOAT C=CurX*UL/XL; U-=C; UL+=C; XL+=CurX; CurX=0;}
		if( CurY<0 )		{FLOAT C=CurY*VL/YL; V-=C; VL+=C; YL+=CurY; CurY=0;}
		if( XL>ClipX-CurX ) {UL+=(ClipX-CurX-XL)*UL/XL; XL=ClipX-CurX;}
		if( YL>ClipY-CurY ) {VL+=(ClipY-CurY-YL)*VL/YL; YL=ClipY-CurY;}
	
		if( Style!=STY_None )  
		{ 
			DWORD dwFlags = PF_TwoSided;
			

			if(Style==STY_Masked)		dwFlags |= PF_Masked;
			if(Style==STY_Translucent)	dwFlags |= PF_Translucent;
			if(Style==STY_Modulated)	dwFlags |= PF_Modulated;
			if(bNoSmooth)				dwFlags |= PF_NoSmooth;

			DrawTile
			(
				Tex,
				OrgX+CurX, OrgY+CurY,
				XL, YL,
				U, V,
				UL, VL,
				NULL,
				Z,
				Color.Plane(), FPlane(0,0,0,0),
				dwFlags,
				PolyFlagsEx,
				bBilinear,
				fAlpha,
				rotation
			);
		}

		CurX += XL + SpaceX;
		CurYL = Max(CurYL,YL);
	}
}
IMPLEMENT_FUNCTION( UCanvas, 468, execDrawTileClipped );

void UCanvas::execDrawTextClipped( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(InText);
	P_GET_UBOOL_OPTX(CheckHotKey, 0);
	P_FINISH;

	if( !Font )
	{
		Stack.Logf( TEXT("DrawTextClipped: No font") );
		return;
	}

	if( (Font==LargeFont || Font==BigFont) && appStricmp(UObject::GetLanguage(),TEXT("INT")) )
		Font = MedFont;//BigFont;//!!
	check(Font);

	// Generate flags.
	DWORD PolyFlags
	=	(PF_Masked | PF_RenderHint)
	|(	(Style==STY_None       ) ? PF_Invisible
	:	(Style==STY_Translucent) ? PF_Translucent
	:	(Style==STY_Modulated  ) ? PF_Modulated
	:	                           0);

	FPlane DrawColor = Color.Plane();
	DrawString( PolyFlags, this, Font, (INT) CurX, (INT) CurY, *InText, DrawColor, 1, CheckHotKey );
}
IMPLEMENT_FUNCTION( UCanvas, 469, execDrawTextClipped );

void UCanvas::execTextSize( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(InText);
	P_GET_FLOAT_REF(XL);
	P_GET_FLOAT_REF(YL);
	P_GET_FLOAT_OPTX(XScale,1.0);
	P_GET_FLOAT_OPTX(YScale,1.0);
	P_FINISH;

	if( !Font )
	{
		Stack.Logf( TEXT("TextSize: No font") );
		return;
	}

	UBOOL IsTrueType = 0;
	for (TMap<FString, UFont*>::TIterator It(LoadedTTFonts); It; ++It)
	{
		if (It.Value() == Font)
			IsTrueType = 1;
	}

	INT XLi = 0;
	INT YLi = 0;
	INT W, H;

	for( INT i=0; (*InText)[i]; i++)
	{
		GetCharSize( Font, (*InText)[i], W, H, IsTrueType );
		
		XLi += appCeil( ((FLOAT) W)*XScale );
		if (YLi < H)
			YLi = appCeil( ((FLOAT) H)*YScale );
	}
	
	*XL = XLi;
	*YL = YLi;
}
IMPLEMENT_FUNCTION( UCanvas, 470, execTextSize );

void UCanvas::execDrawPortal( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(X);
	P_GET_INT(Y);
	P_GET_INT(Width);
	P_GET_INT(Height);
	P_GET_OBJECT(AActor,CamActor);
	P_GET_VECTOR(CamLocation);
	P_GET_ROTATOR(CamRotation);
	P_GET_INT_OPTX(FOV, 90);
	P_GET_UBOOL_OPTX(ClearZ, 1);
	P_FINISH;

	FSceneNode* NewNode;
	FScreenBounds Bounds;
	
	FLOAT SavedFovAngle = Viewport->Actor->FovAngle;
	AWeapon *SavedWeapon=Viewport->Actor->Weapon;
	Viewport->Actor->Weapon=NULL;

	Viewport->Actor->FovAngle = FOV;
	NewNode = Render->CreateMasterFrame
	(
		Viewport,
		CamLocation,
		CamRotation,
		&Bounds
	);
	check( NewNode );

	NewNode->XB = X;
	NewNode->YB = Y;
	NewNode->X = Width;
	NewNode->Y = Height;
	NewNode->ComputeRenderSize();

	if( ClearZ )
		GRenderDevice->ClearZ( NewNode );

	Render->DrawWorld( NewNode );
	Render->FinishMasterFrame();

	Viewport->Actor->Weapon  =SavedWeapon;
	Viewport->Actor->FovAngle=SavedFovAngle;
}
IMPLEMENT_FUNCTION( UCanvas, 480, execDrawPortal );

void UCanvas::execGetScreenBounds( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(VisibleActor);
	P_GET_FLOAT_REF(X1);
	P_GET_FLOAT_REF(X2);
	P_GET_FLOAT_REF(Y1);
	P_GET_FLOAT_REF(Y2);
	P_GET_UBOOL_OPTX(Collision,0);
	P_FINISH;

	*X1 = 0.f;
	*X2 = 0.f;
	*Y1 = 0.f;
	*Y2 = 0.f;

//	if (!VisibleActor->Mesh)
//		return;

	FScreenBounds ScreenBounds;
	FBox Bounds;
	if (Collision)
		Bounds = VisibleActor->GetPrimitive()->GetCollisionBoundingBox( VisibleActor );
	else
		Bounds = VisibleActor->GetPrimitive()->GetRenderBoundingBox( VisibleActor, 0 );
	
	if (!GRender->BoundVisible(Frame, &Bounds, NULL, ScreenBounds))
		return;

	*X1 = ScreenBounds.MinX;
	*X2 = ScreenBounds.MaxX;
	*Y1 = ScreenBounds.MinY;
	*Y2 = ScreenBounds.MaxY;
}
IMPLEMENT_FUNCTION( UCanvas, 481, execGetScreenBounds );

void UCanvas::execGetRenderBoundingBox( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(VisibleActor);
	P_GET_VECTOR_REF(Min);
	P_GET_VECTOR_REF(Max);
	P_FINISH;

	FBox Bounds = VisibleActor->GetPrimitive()->GetRenderBoundingBox( VisibleActor, 0 );

	*Min = Bounds.Min;
	*Max = Bounds.Max;
}
IMPLEMENT_FUNCTION( UCanvas, 483, execGetRenderBoundingBox );

void UCanvas::execDrawCylinder( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Loc);
	P_GET_FLOAT(Radius);
	P_GET_FLOAT(Height);
	P_FINISH;

	GRender->DrawCylinder( Frame, FPlane(Color.R,Color.G,Color.B,0), LINE_Transparent, Loc, Radius, Height );
}
IMPLEMENT_FUNCTION( UCanvas, 484, execDrawCylinder );

void UCanvas::execSetClampMode( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL(bClamp);
	P_FINISH;

	if (bClamp)
		GRender->Engine->Client->Viewports(0)->RenDev->SetTextureClampMode( 1 );
	else
		GRender->Engine->Client->Viewports(0)->RenDev->SetTextureClampMode( 0 );
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetClampMode );

#define FNT_FONTCHARS 96
static char CharMap[FNT_FONTCHARS] =
"abcdefghijklmnopqrstuvwxyz0123456789-=[]\\;',./` "
"ABCDEFGHIJKLMNOPQRSTUVWXYZ)!@#$%^&*(_+{}|:\"<>?~";

#define LIT_LEFT			0x00000001
#define LIT_UPPERLEFT		0x00000002
#define LIT_UP				0x00000004
#define LIT_UPPERRIGHT		0x00000008
#define LIT_RIGHT			0x00000010
#define LIT_BOTTOMRIGHT		0x00000020
#define LIT_DOWN			0x00000040
#define LIT_BOTTOMLEFT		0x00000080

// !BR
// Create a UFont from a Windows TrueType font.
void UCanvas::execCreateTTFont( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(FontName);
	P_GET_INT(FontSize);
	P_GET_INT_OPTX(FontWeight,400);
	P_FINISH;

	// Determine if this font already exists.
	FString FontKey = FString::Printf(TEXT("%s%i%i"), *FontName, FontSize, FontWeight);
	UFont** SearchFont = LoadedTTFonts.Find(FontKey);
	if (SearchFont != NULL)
	{
		// Yes, it exists set this font and return.
		*(UFont**)Result = *SearchFont;
		return;
	}

	// No, this font has not yet been loaded.  Load it now.
	HFONT F = TCHAR_CALL_OS(
		CreateFont(-FontSize, 0, 0, 0, FontWeight, 0, 0, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, *FontName),
		CreateFontA(-FontSize, 0, 0, 0, FontWeight, 0, 0, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY, DEFAULT_PITCH, TCHAR_TO_ANSI(*FontName)) );
	if (F == NULL)
		return;

	// Create font and its texture.
	UFontTrueType* NewFont = (UFontTrueType*)StaticConstructObject( UFontTrueType::StaticClass(), (UObject*)GetTransientPackage(), NAME_None, RF_Native );

	// Create palette.
	UPalette* Palette = (UPalette*)StaticConstructObject( UPalette::StaticClass(), (UObject*)GetTransientPackage(), NAME_None, RF_Native );
	Palette->Colors.Empty();
	Palette->Colors.AddZeroed(NUM_PAL_COLORS);
	for( INT i=0; i<256; i++ )
	{
		Palette->Colors(i).R = i;
		Palette->Colors(i).G = i;
		Palette->Colors(i).B = i;
		Palette->Colors(i).A = i;
	}

	// Set up some bitmap info.
	BITMAPINFO* pBI = (BITMAPINFO*)appMalloc(sizeof(BITMAPINFO), TEXT("FontImport"));
	pBI->bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
	pBI->bmiHeader.biWidth         = 256;
	pBI->bmiHeader.biHeight        = 256;
	pBI->bmiHeader.biPlanes        = 1;
	pBI->bmiHeader.biBitCount      = 24;
	pBI->bmiHeader.biCompression   = BI_RGB; 
	pBI->bmiHeader.biSizeImage     = 0;      
	pBI->bmiHeader.biXPelsPerMeter = 0;      
	pBI->bmiHeader.biYPelsPerMeter = 0;      
	pBI->bmiHeader.biClrUsed       = 0;      
	pBI->bmiHeader.biClrImportant  = 0;      

	// Determine max metrics.
	void* pvBmp;
	HDC DC = CreateCompatibleDC( NULL );
	HBITMAP tempB = CreateDIBSection((HDC)NULL, pBI, DIB_RGB_COLORS, &pvBmp, NULL, 0);
	SelectObject(DC, tempB);
	SelectObject(DC, F);
	SetMapMode(DC, MM_TEXT);
	SetWindowExtEx(DC, 256, 256, NULL);
	TEXTMETRICA tm;
	INT MetricError = GetTextMetricsA( DC, &tm );
	if (MetricError == 0)
		GWarn->Logf( TEXT("Failed to get text metrics: %s [%s]"), appGetSystemErrorMessage(), *FontKey );
	NewFont->CharactersPerPage = (256*256)/(tm.tmHeight * tm.tmMaxCharWidth);
	DeleteDC(DC);

//	GWarn->Logf( TEXT("Metrics for %s"), *FontKey );
//	GWarn->Logf( TEXT("Height: %i Ascent: %i Descent: %i"), tm.tmHeight, tm.tmAscent, tm.tmDescent );
//	GWarn->Logf( TEXT("iLeading: %i eLeading: %i Weight: %i"), tm.tmInternalLeading, tm.tmExternalLeading, tm.tmWeight );
//	GWarn->Logf( TEXT("AveCharWidth: %i MaxCharWidth: %i Overhang: %i"), tm.tmAveCharWidth, tm.tmMaxCharWidth, tm.tmOverhang );

	// Render all font characters into texture.
	INT      N         =64;
	INT*     X         =(INT    *)appAlloca(N*sizeof(INT    ));
	INT*     Y         =(INT    *)appAlloca(N*sizeof(INT    ));
	INT*     RowHeight =(INT    *)appAlloca(N*sizeof(INT    ));
	HBITMAP* B         =(HBITMAP*)appAlloca(N*sizeof(HBITMAP));
	HDC*     dc        =(HDC    *)appAlloca(N*sizeof(HDC    ));

	for( i=0; i<N; i++ )
	{
		X [i] = Y[i] = RowHeight[i] = 0;
		B [i] = NULL;
		dc[i] = NULL;
	}
	for( INT k=0; k<FNT_FONTCHARS-1; k++ )
	{
		INT Ch = CharMap[k];

		// Create font page if needed.
		INT Page  = Ch / NewFont->CharactersPerPage;
		INT Index = Ch - NewFont->CharactersPerPage * Page;
		if( Page >= NewFont->Pages.Num() )
			NewFont->Pages.AddZeroed( 1 + Page - NewFont->Pages.Num() );
		FFontPage* PageInfo = &NewFont->Pages(Page);
		if( Index >= PageInfo->Characters.Num() )
			PageInfo->Characters.AddZeroed( 1 + Index - PageInfo->Characters.Num() );

		// Create mem DC to draw the font characters to.
		if( !B[Page] )
		{
			dc[Page] = CreateCompatibleDC( NULL );
			if( !dc[Page] )
			{
				GWarn->Logf( TEXT("CreateCompatibleDC failed: %s"), appGetSystemErrorMessage() );
				return;
			}

			B[Page] = CreateDIBSection((HDC)NULL, pBI, DIB_RGB_COLORS, &pvBmp,	NULL, 0);  
			if( !B[Page] )
			{
				GWarn->Logf( TEXT("CreateDIBSection failed: %s"), appGetSystemErrorMessage() );
				return;
			}

			SelectObject( dc[Page], B[Page] );
			SelectObject( dc[Page], F );
			SetMapMode( dc[Page], MM_TEXT );
			SetWindowExtEx( dc[Page], 256, 256, NULL );
			SetTextColor( dc[Page], 0x00000000 );
			SetBkColor( dc[Page], 0x00ffffff );
			HBRUSH White = CreateSolidBrush(0x00ffffff);
			RECT   r     = {0, 0, 256, 256};
			FillRect( dc[Page], &r, White );
		}

		GLYPHMETRICS gm, gm2;
		_MAT2 mat2;
		mat2.eM11.fract = 0;
		mat2.eM11.value = 1;
		mat2.eM12.fract = 0;
		mat2.eM12.value = 0;
		mat2.eM21.fract = 0;
		mat2.eM21.value = 0;
		mat2.eM22.fract = 0;
		mat2.eM22.value = 1;
		INT res = GetGlyphOutlineA( dc[Page], Ch, GGO_METRICS, &gm, sizeof(gm2), &gm2, &mat2 );
		if( res == GDI_ERROR )
			GWarn->Logf( TEXT("GetGlyphOutlineA failed: %s"), appGetSystemErrorMessage() );

		SIZE Size;
		TCHAR Tmp[5]={Ch,0};
		GetTextExtentPoint32( dc[Page], Tmp, 1, &Size );

		// If it doesn't fit right here, advance to next line.
		if( Size.cx + X[Page] > 256)
		{
			Y[Page]         = Y[Page] + RowHeight[Page];
			RowHeight[Page] = 0;
			X[Page]         = 0;
		}

		// Set font character information.
		INT SizeY = tm.tmAscent - gm.gmptGlyphOrigin.y + gm.gmBlackBoxY - tm.tmInternalLeading;
		PageInfo->Characters(Index).StartU = X[Page];
		PageInfo->Characters(Index).StartV = Y[Page] + tm.tmInternalLeading;
		PageInfo->Characters(Index).USize  = Size.cx;
		PageInfo->Characters(Index).VSize  = SizeY;
		NewFont->VHeights.Set(Ch, SizeY );

		// Draw character into font.
		RowHeight[Page] = tm.tmHeight;
		if( Y[Page]+RowHeight[Page]>256 )
		{
			// This character won't fit on this page!
			GWarn->Logf( TEXT("Font vertical size exceeded maximum of 256 at character %i"), Index );
			return;
		}
		TextOut( dc[Page], X[Page], Y[Page], Tmp, 1 );
		X[Page] = X[Page] + Size.cx + 1;
	}

	// Create textures.
	for( INT n=0; n<NewFont->Pages.Num(); n++ )
	{
		FFontPage* PageInfo = &NewFont->Pages(n);
		if( PageInfo->Characters.Num() )
		{
			// Create texture for page.
			PageInfo->Texture = (UTextureCanvas*)StaticConstructObject( UTextureCanvas::StaticClass(), (UObject*)GetTransientPackage(), NAME_None, RF_Native );
			PageInfo->Texture->Init( 256, 1<<appCeilLogTwo(Y[n]+RowHeight[n]) );
			PageInfo->Texture->PolyFlags = PF_Masked;
			PageInfo->Texture->PostLoad();
			PageInfo->Texture->Palette = Palette;

			// Copy bitmap data to texture page.
			for (INT _y=0; _y<PageInfo->Texture->VSize; _y++)
			{
				for (INT _x=0; _x<PageInfo->Texture->USize; _x++)
				{
					INT col = 0;
//					INT lit = 0;
/*
					// Test Left.
					if (_x-1 >= 0)
					{
						COLORREF c = GetPixel(dc[n], _x-1, _y);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_LEFT;
					}

					// Test Upper Left.
					if ((_x-1 >= 0) && (_y-1 >= 0))
					{
						COLORREF c = GetPixel(dc[n], _x-1, _y-1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_UPPERLEFT;
					}

					// Test Up.
					if (_y-1 >= 0)
					{
						COLORREF c = GetPixel(dc[n], _x, _y-1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_UP;
					}

					// Test Upper Right.
					if ((_x+1 < PageInfo->Texture->USize) && (_y-1 >= 0 ))
					{
						COLORREF c = GetPixel(dc[n], _x+1, _y-1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_UPPERRIGHT;
					}

					// Test Right.
					if (_x+1 < PageInfo->Texture->USize)
					{
						COLORREF c = GetPixel(dc[n], _x+1, _y);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_RIGHT;
					}

					// Test Bottom Right.
					if ((_x+1 < PageInfo->Texture->USize) && (_y+1 < PageInfo->Texture->VSize))
					{
						COLORREF c = GetPixel(dc[n], _x+1, _y+1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_BOTTOMRIGHT;
					}

					// Test Down.
					if (_y+1 < PageInfo->Texture->VSize)
					{
						COLORREF c = GetPixel(dc[n], _x, _y+1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_DOWN;
					}

					// Test Bottom Left.
					if ((_x-1 >= 0) && (_y+1 < PageInfo->Texture->VSize))
					{
						COLORREF c = GetPixel(dc[n], _x-1, _y+1);
						if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
							lit |= LIT_BOTTOMLEFT;
					}

					// Are we a top left corner?
					if ((lit & LIT_UPPERLEFT) && (lit & LIT_UP) && (lit & LIT_LEFT))
						col += 30;
					// Are we a top right corner?
					if ((lit & LIT_UPPERRIGHT) && (lit & LIT_UP) && (lit & LIT_RIGHT))
						col += 30;
					// Are we a bottom left corner?
					if ((lit & LIT_BOTTOMLEFT) && (lit & LIT_DOWN) && (lit & LIT_LEFT))
						col += 30;
					// Are we a bottom right corner?
					if ((lit & LIT_BOTTOMRIGHT) && (lit & LIT_DOWN) && (lit & LIT_RIGHT))
						col += 30;
*/
					// If lit, max brightness.
					COLORREF c = GetPixel(dc[n], _x, _y);
					if ((c != CLR_INVALID) && (255 - GetRValue(c) > 0))
						col = 100;

					if (col != 0)
						PageInfo->Texture->Mips(0).DataArray( _x + _y * PageInfo->Texture->USize) = 255 * (col/100.f);
				}
			}
		}
		if( dc[n] )
			DeleteDC( dc[n] );
		if( B[n] )
			DeleteObject( B[n] );
	}

	// Free the bitmap info.
	appFree( pBI );
	
	LoadedTTFonts.Set(*FontKey, NewFont);
	*(UFont**)Result = (UFont*) NewFont;
}
IMPLEMENT_FUNCTION( UCanvas, 482, execCreateTTFont );

IMPLEMENT_CLASS(UCanvas);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

