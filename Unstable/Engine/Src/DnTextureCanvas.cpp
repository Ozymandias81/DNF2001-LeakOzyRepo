/*=============================================================================
	DnTextureCanvas.cpp: Run time modifiable texture code.
=============================================================================*/
#pragma warning( disable : 4201 )

// Smacker must be included first.
#pragma comment(lib,"smackw32.lib")

#include "EnginePrivate.h"

#pragma warning( disable : 4706 )

/*------------------------------------------------------------------------------
	UTextureCanvas implementation.
------------------------------------------------------------------------------*/

UTextureCanvas::UTextureCanvas()
{
	PaletteMap = new TMap< UTexture*, TArray< BYTE > >;
	SetDirty();
	bParametric = 1;  
	bRealtime   = 1;
}

void UTextureCanvas::Destroy()
{
	if(PaletteMap) delete PaletteMap;
	Super::Destroy();
}

void UTextureCanvas::Serialize( FArchive& Ar )
{
	UTexture::Serialize(Ar);
}

void UTextureCanvas::Init( INT  InUSize, INT  InVSize )
{
	VERIFY_CLASS_OFFSET(U,TextureCanvas,Dirty);

	// Init base class.
	UTexture::Init( InUSize, InVSize );

	// Create a custom palette. (All shades of white for now)
	Palette = new( GetOuter() )UPalette;
	for( INT  i=0; i<256; i++ )
		Palette->Colors.AddItem( FColor(i,i,i) );
	
	MipZero = Palette->Colors(128);
}

void UTextureCanvas::ConstantTimeTick()
{
	if(Dirty) 
	{	
		Dirty--;					// Decrement my dirty count.
		bRealtimeChanged = 1;
	} else
		bRealtimeChanged = 0;
}

IMPLEMENT_CLASS(UTextureCanvas);

void UTextureCanvas::Resize( INT InUSize, INT InVSize )
{
	UPalette *p;
	p=Palette;
	Init(InUSize,InVSize);
	Palette=p;	// Restore original palette
}

void UTextureCanvas::DrawStatic()
{
	static unsigned char StaticTable[1024];		// Precomputed static
	static bool initialized=false;
	int bytesToCopy=USize*VSize, bytesCopied, xIndex;
	BYTE *t=(BYTE *)&Mips(0).DataArray(0);

	SetDirty();

	// Build the random static table:
	if(!initialized)
	{
		initialized=true;
		
		for(int i=0;i<ARRAY_COUNT(StaticTable);i++)
		{
			StaticTable[i]=appRand();
			while(appRand()&1) ;		// Unfortunantly Needed to keep stdlib rand() more random.
		}
	}

	for(;bytesToCopy;t+=bytesCopied,bytesToCopy-=bytesCopied)
	{
		// Choose a random offset into the static table (But ensure that it's dword aligned):
		xIndex=(appRand()%ARRAY_COUNT(StaticTable))&0xFFFFFFFC;
		
		bytesCopied=Min<int>(bytesToCopy,ARRAY_COUNT(StaticTable)-xIndex);
		memcpy(t,StaticTable+xIndex,bytesCopied);
	}
}


// UTextureCanvas Interface:
void UTextureCanvas::DrawPixel ( int x, int y, unsigned char color )
{
	if(x<0||x>=USize||y<0||y>=USize) return; // Clip to coords

	SetDirty();
	*(((BYTE *)&Mips(0).DataArray(0))+(y*USize)+x)=color; 
}

void UTextureCanvas::DrawLine( int x1, int y1, int x2, int y2, unsigned char color )
{
	SetDirty();
}

int UTextureCanvas::DrawCharacter( UFont *font, int x, int y, char character, UBOOL masking)
{
	if(!font) return 0;
	SetDirty();
	return 0;

}

void UTextureCanvas::DrawTile( 
	FLOAT X, FLOAT Y, 
	FLOAT XL, FLOAT YL, 
	FLOAT U, FLOAT V, 
	FLOAT UL, FLOAT VL, 
	UTexture *Tex, FTextureInfo *Info, 
	UBOOL bMasked, UBOOL bUseColor, 
	BYTE ColorIndex 
)
{

	Tex->bRealtime=true;	// Prevent the used texture from being cached out again.
	Info->bRealtime=true;
	Info->Load();

	BYTE* SourceBitmap = Info->Mips[0]->DataPtr;
	BYTE* DestBitmap = &Mips(0).DataArray(0);

	if( X+XL < 0 || Y+YL < 0 || X > USize || Y > VSize)
		return;

	TArray<BYTE>* PalMap = NULL;
	
	if(!bUseColor)
	{
		PalMap = PaletteMap->Find(Tex);

		if(!PalMap)
		{
			TArray<BYTE> Temp(256);

			for(INT i=0;i<256;i++)
				Temp(i) = Palette->BestMatch(Tex->Palette->Colors(i), 0);

			PalMap = &PaletteMap->Set(Tex, Temp);
		}
	}

	INT DX1 = Min( Max( appRound(X), 0 ), USize-1 );
	U += ((FLOAT)DX1 - X) * (UL/XL);
	INT DX2 = Min( appRound(XL+X), USize-1 );
	INT DY1 = Min( Max( appRound(Y), 0 ), VSize-1 );
	V += ((FLOAT)DY1 - Y) * (VL/YL);
	INT DY2 = Min( appRound(YL+Y), VSize-1 );

	DWORD SrcUMask = Tex->USize-1; // Can assume power-of-two texture sizes.
	DWORD SrcVMask = Tex->VSize-1;

	INT DestBase = DY1 * USize;     

	INT XFixStep  = appRound( UL/XL * (FLOAT)(1 << 19) );
	INT FixU = appRound( U * (FLOAT)(1 << 19) ) - XFixStep;
	INT YFixStep  = appRound( VL/YL * (FLOAT)(1 << 19) );
	INT FixV = appRound( V * (FLOAT)(1 << 19) ) - YFixStep;

	INT YFixStart = FixV; 
	
	if ( bUseColor && bMasked )
	{       
		// Masked monochrome blitting using ColorIndex.
		for( INT DY=DY1; DY < DY2; DY++)
		{
			INT XFixStart = FixU;
			INT SrcYIndex = (SrcVMask & ((YFixStart+=YFixStep) >> 19)) * Tex->USize;
			for( INT DX=DX1; DX < DX2; DX++)
			{			       
				if( SourceBitmap[ SrcYIndex + (SrcUMask & ((XFixStart+=XFixStep) >> 19)) ] !=0 )
				{
					DestBitmap[ DestBase + DX ] = ColorIndex;
				}
			}
			DestBase += USize;
		}
	}
	else if ( !bMasked ) 
	{       
		// Unmasked textured blitting.
		for( INT DY=DY1; DY < DY2; DY++ )
		{
			INT XFixStart = FixU;
			INT SrcYIndex = (SrcVMask & ((YFixStart+=YFixStep) >> 19)) * Tex->USize;
			for( INT DX=DX1; DX < DX2; DX++ )
			{			       
				DestBitmap[ DestBase + DX ] = (*PalMap)(SourceBitmap[ SrcYIndex + (SrcUMask & ((XFixStart+=XFixStep) >> 19)) ]);
			}
			DestBase += USize;
		}	       
	}
	else 
	{       
		// Masked textured blitting. 
		for( INT DY=DY1; DY < DY2; DY++ )
		{
			INT XFixStart = FixU;
			INT SrcYIndex = (SrcVMask & ((YFixStart+=YFixStep) >> 19)) * Tex->USize;
			for( INT DX=DX1; DX < DX2; DX++ )
			{			       
				INT SourcePix = SourceBitmap[ SrcYIndex + (SrcUMask & ((XFixStart+=XFixStep) >> 19)) ];
				if( SourcePix )
				{
					DestBitmap[ DestBase + DX ] = (*PalMap)(SourcePix);
				}
			}
			DestBase += USize;
		}
	}
}

INT
UTextureCanvas::DrawString
(
	UFont*			Font, 
	INT				DrawX, 
	INT				DrawY,
	const TCHAR*	Text, 
	UBOOL			bUseColor,
	BYTE			PaletteEntry
)
{
	FTextureInfo Info;

	INT LineX = 0;
	INT Page = -1;

	if (!Font)
		return 0;

	for( INT i=0; Text[i]; i++ )
	{
		INT Ch = (TCHAR)Text[i];

		INT NewPage = Ch / Font->CharactersPerPage;
		if( NewPage<Font->Pages.Num() && Font->Pages(NewPage).Texture )
		{
			INT        Index    = Ch - NewPage*Font->CharactersPerPage;
			FFontPage& PageInfo = Font->Pages(NewPage);
			if( Index<PageInfo.Characters.Num() )
			{
				if( NewPage!=Page )
				{
					if( Page!=-1 )
						Font->Pages(Page).Texture->Unlock( Info );
					Page = NewPage;
					PageInfo.Texture->Lock( Info, appSeconds(), 0, NULL );
				}
				FFontCharacter& Char = PageInfo.Characters( Index );

				if( bUseColor )
					DrawTile( DrawX+LineX, DrawY, Char.USize, Char.VSize, Char.StartU, Char.StartV, Char.USize, Char.VSize, PageInfo.Texture, &Info, 1, 1, PaletteEntry );
				else
					DrawTile( DrawX+LineX, DrawY, Char.USize, Char.VSize, Char.StartU, Char.StartV, Char.USize, Char.VSize, PageInfo.Texture, &Info, 1 );
				LineX += Char.USize;
			}
		}
	}

	if( Page!=-1 )
		Font->Pages(Page).Texture->Unlock( Info );

	return LineX;

}

void UTextureCanvas::GetCharSize( UFont* Font, TCHAR InCh, INT& Width, INT& Height )
{
	Width = 0;
	Height = 0;
	INT Ch    = (TCHAR)InCh;
	INT Page  = Ch / Font->CharactersPerPage;
	INT Index = Ch - Page * Font->CharactersPerPage;
	if( Page<Font->Pages.Num() && Index<Font->Pages(Page).Characters.Num() )
	{
		FFontCharacter& Char = Font->Pages(Page).Characters(Index);
		Width = Char.USize;
		Height = Char.VSize;
	}
}

inline double square( double d) { return d*d; }
inline unsigned char findClosestPaletteEntry(unsigned char palette[256][3],int re, int gr, int bl)
{
	int i;
	unsigned char closest=0;
	double distance=9999999999999.0;
	double currentDist;

	for(i=0;i<256;i++)
	{
		currentDist=(square(re-(int)palette[i][0])+square(gr-(int)palette[i][1])+square(bl-(int)palette[i][2]));
		if(currentDist<distance)
		{
			distance=currentDist;
			closest=i;
		}
	}

	return closest;
}
#if 0
static unsigned char *bitmapScale(unsigned char *b, unsigned char palette[256][3], int width, int height, int newWidth, int newHeight, UBOOL linear)
{
	unsigned char *newImage, *newImageBase, *pixel;
	float xStep, yStep;
	int x, y;
	float xPixel, yPixel;

	if(newWidth<10)  newWidth=10;
	if(newHeight<10) newHeight=10;

	newImageBase=newImage=(unsigned char *)appMalloc(newWidth*newHeight,TEXT("ScaleBuffer"));
	memset(newImageBase,0,newWidth*newHeight);

	xStep=(float)width/(float)newWidth;
	yStep=(float)height/(float)newHeight;

	for(y=0;y<newHeight;y++)
	{
		for(x=0;x<newWidth;x++)
		{
			if(x==y) *newImage=appRand()&0xFF; 
			else

			if(linear)
			{
				xPixel=x*xStep;
				yPixel=y*yStep;
			
				if(xPixel>=width) xPixel=width-1;
				else if(yPixel>=height) yPixel=height-1;
				
				pixel=b+((int)yPixel*width)+(int)xPixel;
				
				*newImage=*pixel;
			} 
			else	// Do bilinear:
			{
				int x2,y2;
				int red=0,green=0,blue=0,count=0;

				// Compute average color: psuedo bilinear filter (takes a little more into account)
				for(y2=(int)(y*yStep);y2<=(int)((y*yStep)+yStep);y2++)
					for(x2=(int)(x*xStep);x2<=(int)((x*xStep)+xStep);x2++)
					{
						xPixel=x2; yPixel=y2;
						
						if(xPixel>=width) xPixel=width-1;
						else if(yPixel>=height) yPixel=height-1;
				
						pixel=b+((int)yPixel*width)+(int)xPixel;

						red+=palette[*pixel][0];
						green+=palette[*pixel][1];
						blue+=palette[*pixel][2];
						
						count++;
					}

				if(count)
				{
					red/=count;
					green/=count;
					blue/=count;

					*newImage=findClosestPaletteEntry(palette,red,green,blue);
					// Find the closest match:
					//(*newImage)[red]=re;
					//(*newImage)[green]=gr;
					//(*newImage)[blue]=bl;
				} else
					*newImage=0;
			}

			newImage++;
		}
	}
	return newImageBase;
}
#endif
void UTextureCanvas::DrawBitmap( int x, int y, int left, int top, int right, int bottom, UTexture *t, UBOOL masking, UBOOL wrap, UBOOL scale )
{
	BYTE  *source,	  *dest;
	int	sourceIndexX, sourceIndexY,
	   	destIndexX,   destIndexY;
	unsigned char sourceByte;

	if(!t) return;
	
	SetDirty();
	
	t->bRealtime=true;	// Prevent the used texture from being cached out again.
	if( !t->bParametric  )
		t->Mips(0).DataArray.Load();

	dest  =(BYTE *)&Mips(0).DataArray(0);		
	source=(BYTE *)&t->Mips(0).DataArray(0);	

	if(!left&&!right) right=t->USize-1;		// If left==right==0 then draw full bitmap
	if(!top&&!bottom) bottom=t->VSize-1;	// If top==bottom==0 then draw full bitmap

	// When wrapping adjust coordinates accordingly:
	if(wrap)
	{
		if(USize) x%=USize;	// Wrap to screen coordinates.
		if(VSize) y%=VSize;	// Wrap to screen coordinates.
	} 

	for(sourceIndexY=top;sourceIndexY<=bottom;sourceIndexY++)
	{
		destIndexY=y+sourceIndexY-top;

		// clip line:
		if(destIndexY<0)
		{
			if(!wrap) continue;	// If not wrapping, skip.
			destIndexY+=VSize;	// Wrap around.
		}

		if(destIndexY>=VSize)
		{
			if(!wrap) continue;	// If not wrapping, skip.
			destIndexY-=VSize;	// Wrap around.
		}

		for(sourceIndexX=left;sourceIndexX<=right;sourceIndexX++)
		{
			destIndexX=x+sourceIndexX-left;

			// Clip or wrap pixel:
			if(destIndexX<0)
			{
				if(!wrap) continue;	// If not wrapping, skip.
				destIndexX+=USize;	// Wrap around.
			}

			if(destIndexX>=USize)
			{
				if(!wrap) continue;	// If not wrapping, skip.
				destIndexX-=USize;	// Wrap around.
			}

			sourceByte=*(source+(sourceIndexY*t->USize)+sourceIndexX);
			
			if(masking&&!sourceByte) continue;

			// Would this pixel be masked off?
			*(dest+(destIndexY*USize)+destIndexX)=sourceByte;
		}
	}
}

void UTextureCanvas::DrawClear ( unsigned char color )
{
	SetDirty();
	// Just clear it out:
	appMemset((BYTE *)&Mips(0).DataArray(0),color,USize*VSize);
}

void UTextureCanvas::DrawCircle( int x, int y, int radius, unsigned char color, UBOOL filled )
{
	SetDirty();
}

void UTextureCanvas::DrawRectangle( int left, int top, int right, int bottom, unsigned char color, UBOOL filled )
{
	SetDirty();
}

void UTextureCanvas::execDrawPixel( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(x);
	P_GET_INT(y);
	P_GET_BYTE(color);
	P_FINISH;

	DrawPixel(x,y,color);
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawPixel );

void UTextureCanvas::execDrawLine( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(x1);
	P_GET_INT(y1);
	P_GET_INT(x2);
	P_GET_INT(y2);
	P_GET_BYTE(color);
	P_FINISH;

	DrawLine(x1,y1,x2,y2,color);
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawLine );

void UTextureCanvas::execDrawString( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UFont,font);
	P_GET_INT(x);
	P_GET_INT(y);
	P_GET_STR(s);
	P_GET_UBOOL(proportional);
	P_GET_UBOOL(wrap);
	P_GET_UBOOL(masking);
	P_GET_UBOOL_OPTX(bUseColor,0);
	P_GET_INT_OPTX(PaletteEntry,0);
	P_FINISH;

	DrawString(font, x, y, *s, bUseColor, PaletteEntry);
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawString );

void UTextureCanvas::execDrawBitmap( FFrame& Stack, RESULT_DECL )
{
	// Snag the parameters:
	P_GET_INT(x);
	P_GET_INT(y);
	P_GET_INT(left);
	P_GET_INT(top);
	P_GET_INT(right);
	P_GET_INT(bottom);
	P_GET_OBJECT(UTexture,t);
	P_GET_UBOOL(masking);
	P_GET_UBOOL(wrap);
	P_GET_UBOOL(scale);
	P_FINISH;

	DrawBitmap(x,y,left,top,right,bottom,t,masking,wrap,scale);
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawBitmap );

void UTextureCanvas::execDrawClear( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(color);
	P_FINISH;

	DrawClear(color);
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawClear );


void UTextureCanvas::execDrawCircle( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(x);
	P_GET_INT(y);
	P_GET_INT(radius);
	P_GET_BYTE(color);
	P_GET_UBOOL(filled);
	P_FINISH;

	DrawCircle( x, y, radius, color, filled );
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawCircle );


void UTextureCanvas::execDrawRectangle( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(left);
	P_GET_INT(top);
	P_GET_INT(right);
	P_GET_INT(bottom);
	P_GET_BYTE(color);
	P_GET_UBOOL(filled);
	P_FINISH;
	
	DrawRectangle(left, top, right, bottom, color, filled );
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawRectangle );

void UTextureCanvas::execDrawStatic( FFrame& Stack, RESULT_DECL )
{
	DrawStatic();
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execDrawStatic );

void UTextureCanvas::execTextSize( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(InText);
	P_GET_FLOAT_REF(XL);
	P_GET_FLOAT_REF(YL);
	P_GET_OBJECT(UFont, Font);
	P_FINISH;
	if( !Font )
	{
		Stack.Logf( TEXT("TextSize: No font") );
		return;
	}

	INT XLi = 0;
	INT YLi = 0;
	INT W, H;

	for( INT i=0; (*InText)[i]; i++)
	{
		GetCharSize( Font, (*InText)[i], W, H );
		
		XLi += W;
		if(YLi < H)
			YLi = H;	
	}
	
	*XL = XLi;
	*YL = YLi;
}
IMPLEMENT_FUNCTION( UTextureCanvas, INDEX_NONE, execTextSize );

void UTextureCanvas::execForceTick( FFrame& Stack, RESULT_DECL )
{
	// Snag the parameters:
	P_GET_FLOAT(Delta);
	P_FINISH;

	Tick(Delta);
}
IMPLEMENT_FUNCTION( UTextureCanvas, 456, execForceTick );

/*------------------------------------------------------------------------------
	UStaticTexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/
UStaticTexture::UStaticTexture() { }

void UStaticTexture::ConstantTimeTick()
{
	DrawStatic();
	UTextureCanvas::ConstantTimeTick();
}

IMPLEMENT_CLASS(UStaticTexture);

#ifdef CHRISSYPATCHY

/*------------------------------------------------------------------------------
	UViewportTexture - Renders a viewport view).
------------------------------------------------------------------------------*/

class UBufferViewport : public UViewport
{
	DECLARE_CLASS(UBufferViewport,UViewport,CLASS_Transient)
	DECLARE_WITHIN(UClient)

	INT					HoldCount;

	// Info saved during captures and fullscreen sessions.
	POINT				SavedCursor;
	INT					SavedX, SavedY;

	// Constructor.
	UBufferViewport();

	// UObject interface.
	void Destroy();

	// UViewport interface.
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar );
	void OpenWindow( DWORD ParentWindow, UBOOL Temporary, INT NewX, INT NewY, INT OpenX, INT OpenY );
	void CloseWindow();
	void Repaint( UBOOL Blit );
	UBOOL IsFullscreen();
	void SetModeCursor();
	void UpdateWindowFrame();
	void* GetWindow();
	void SetMouseCapture( UBOOL Capture, UBOOL Clip, UBOOL FocusOnly );
	void UpdateInput( UBOOL Reset );
	UBOOL Lock( FColor FogColor, float FogDensity, INT FogDistance, FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData=NULL, INT* HitSize=0 );
	void Unlock( UBOOL Blit );
	UBOOL ResizeViewport( DWORD BlitFlags, INT NewX=INDEX_NONE, INT NewY=INDEX_NONE, INT NewColorBytes=INDEX_NONE );

	// UWindowsViewport interface.
	void FindAvailableModes();
	void TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen );
};

IMPLEMENT_CLASS(UBufferViewport);

UViewportTexture::UViewportTexture()
{
	Format = TEXF_RGB32;
}

void UViewportTexture::Init( INT InUSize, INT InVSize )
{

	Super::Init(InUSize, InVSize);
	
	Mips.Empty();
	new(Mips)FMipmap(UBits,VBits);
	Mips(0).DataArray.Empty(); Mips(0).DataArray.Shrink();
	Mips(0).DataArray.Add(USize*VSize*4);
	for( int i=0; i<USize*VSize*4; i++ )
		Mips(0).DataArray(i) = 0;

}

void UViewportTexture::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	if( (Ar.IsSaving() || Ar.IsLoading()) && (TextureFlags & TF_Parametric) )
	{
		for( INT i=0; i<Mips.Num(); i++ )
		{
			INT Size = Mips(i).USize * Mips(i).VSize * 4;
			Mips(i).DataArray.Empty    ( Size );
			Mips(i).DataArray.AddZeroed( Size );
		}
	}
}

void UViewportTexture::ConstantTimeTick()
{
	static int blocky = 0;	
	if (blocky)
		return;
	blocky++;

	//DrawStatic();
	UEngine* Engine=NULL;
	for (TObjectIterator<UEngine> It; It; ++It)
	{
		if (It->Client && It->Client->Viewports(0) && It->Client->Viewports(0)->Actor)
		{
			Engine = *It;
			break;
		}
	}

	UBOOL isDirty = 0;
	if (Engine)
	{
		static INT prevIndexTest = -1;

		APlayerPawn* viewActor = Engine->Client->Viewports(0)->Actor;
		INT index = ((INT)(appSeconds())) % viewActor->GetLevel()->Actors.Num();
		AActor* locActor = viewActor;
		for( INT iActor=index-1; iActor>=0; iActor-- )
		{
			AActor* TestActor = /*Cast<AActor>*/( viewActor->GetLevel()->Actors(iActor) );
			if( TestActor ) 
			{
				locActor = TestActor;
				if (1)//(prevIndexTest != index)
				{
					prevIndexTest = index;
					isDirty = 1;
				}
				break;
			}
		}
		if (isDirty)
		{
			//UViewport* Viewport = Engine->Client->NewViewport( NAME_None );
			static UViewport* Viewport = NULL;
			if (!Viewport)
			{
				Viewport = new(Engine->Client, NAME_None)UBufferViewport();
				Viewport->Actor = viewActor;
				Viewport->Input->Init( Viewport );
				Viewport->OpenWindow( 0, 1, USize, VSize, INDEX_NONE, INDEX_NONE );
			}
			Viewport->Actor = viewActor;

			//debugf("locActor: %s", locActor->GetName());
			APlayerPawn* prevActor = viewActor;

			if (GIsEditor)
			{
				prevActor->GetLevel()->SpawnViewActor( Viewport );
				prevActor = Viewport->Actor;
			}
			else
			{
				prevActor = NULL;
			}
			Viewport->Actor = viewActor;
			if (Viewport->Actor)
			{
				DWORD oldShowFlags;
				INT oldRendMap;
				FVector oldLocation;
				FRotator oldRotation, oldViewRotation;

				oldLocation = Viewport->Actor->Location;
				oldRotation = Viewport->Actor->Rotation;
				oldViewRotation = Viewport->Actor->ViewRotation;
				Viewport->Actor->Location = locActor->Location;
				Viewport->Actor->Rotation = locActor->Rotation;
				Viewport->Actor->ViewRotation = locActor->Rotation;

				oldShowFlags = Viewport->Actor->ShowFlags;
				oldRendMap = Viewport->Actor->RendMap;
				Viewport->Actor->RendMap = REN_DynLight;//REN_PlainTex;

				if (GIsEditor)
				{
					Viewport->Actor->ShowFlags = SHOW_PlayerCtrl | SHOW_Frame | SHOW_MovingBrushes | SHOW_Actors | SHOW_Brush | SHOW_Menu;
				}

				Viewport->Repaint( 0 );

				appMemcpy(&Mips(0).DataArray(0), Viewport->ScreenPointer, USize*VSize*4);
				INT count = USize*VSize;//*4;
				BYTE* ptr = &Mips(0).DataArray(0);
				for (INT i=0; i<count; i++)//,ptr+=4)
				{
					*ptr++ >>= 2;
					*ptr++ >>= 2;
					*ptr++ >>= 2;
					*ptr++;
				}

				Viewport->Actor->ShowFlags = oldShowFlags;
				Viewport->Actor->RendMap = oldRendMap;

				Viewport->Actor->Location = oldLocation;
				Viewport->Actor->Rotation = oldRotation;
				Viewport->Actor->ViewRotation = oldViewRotation;
			}

			Viewport->Actor = prevActor;
		}
	}

	if (isDirty)
		SetDirty();
	UTextureCanvas::ConstantTimeTick();
	if (isDirty)
		TextureFlags |= TF_RealtimeChanged;

	blocky--;
}

IMPLEMENT_CLASS(UViewportTexture);

UBufferViewport::UBufferViewport()
:	UViewport()
{
	ColorBytes  = 4;
	SavedCursor.x = -1;
}

void UBufferViewport::Destroy()
{
	Super::Destroy();
	if (ScreenPointer)
	{
		appFree(ScreenPointer);
		ScreenPointer = NULL;
	}
}

UBOOL UBufferViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	if( UViewport::Exec( Cmd, Ar ) )
	{
		return 1;
	}
	else if( ParseCommand(&Cmd,TEXT("GetCurrentRes")) )
	{
		Ar.Logf( TEXT("%ix%i"), SizeX, SizeY );
		return 1;
	}
	/*
	else if( ParseCommand(&Cmd,TEXT("SetRes")) )
	{
		INT X=appAtoi(Cmd), Y=appAtoi(appStrchr(Cmd,'x') ? appStrchr(Cmd,'x')+1 : appStrchr(Cmd,'X') ? appStrchr(Cmd,'X')+1 : TEXT(""));
		if( X && Y )
		{
			HoldCount++;
			RenDev->SetRes( X, Y, ColorBytes, 0 );
			HoldCount--;
		}
		return 1;
	}
	*/
	else return 0;
}

void UBufferViewport::OpenWindow( DWORD InParentWindow, UBOOL IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY )
{
	check(Actor);
	check(!HoldCount);
	UBOOL DoRepaint=0;

	ColorBytes    = 4;
	SizeX         = NewX;
	SizeY         = NewY;
	ScreenPointer = (BYTE*)appMalloc( ColorBytes * NewX * NewY, TEXT("BufferViewportData") );
	debugf( NAME_Log, TEXT("Opened buffer viewport") );
	if( !RenDev )
		TryRenderDevice( TEXT("ini:Engine.Engine.WindowedRenderDevice"), SizeX, SizeY, ColorBytes, 0 );
	check(RenDev);
	UpdateWindowFrame();
	if(DoRepaint)
		Repaint( 1 );
}

void UBufferViewport::CloseWindow()
{
	if (ScreenPointer)
	{
		appFree(ScreenPointer);
		ScreenPointer = NULL;
	}
	//RenDev = NULL;
}

void UBufferViewport::Repaint( UBOOL Blit )
{
	GetOuterUClient()->Engine->Draw( this, Blit );
}

UBOOL UBufferViewport::IsFullscreen() { return 0; }
void UBufferViewport::SetModeCursor() { /*SetCursor(LoadCursor(NULL,IDC_CROSS));*/ }
void UBufferViewport::UpdateWindowFrame() {}
void* UBufferViewport::GetWindow() { return NULL; }
void UBufferViewport::SetMouseCapture( UBOOL Capture, UBOOL Clip, UBOOL OnlyFocus ) {}
void UBufferViewport::UpdateInput( UBOOL Reset ) {}
UBOOL UBufferViewport::Lock( FColor FogColor, float FogDensity, INT FogDistance, FPlane FlashScale, FPlane FlashFog, FPlane ScreenClear, DWORD RenderLockFlags, BYTE* HitData, INT* HitSize )
{
	if( HoldCount || !SizeX || !SizeY || !RenDev )
      	return 0;
	Stride = SizeX;
	return UViewport::Lock(FogColor, FogDensity, FogDistance,FlashScale,FlashFog,ScreenClear,RenderLockFlags,HitData,HitSize);
}
void UBufferViewport::Unlock( UBOOL Blit )
{
	Super::Unlock( Blit );
}

UBOOL UBufferViewport::ResizeViewport( DWORD NewBlitFlags, INT InNewX, INT InNewY, INT InNewColorBytes )
{
	return 1;
}

void UBufferViewport::FindAvailableModes() {}

void UBufferViewport::TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes, UBOOL Fullscreen )
{
	// Shut down current rendering device.
	if( RenDev )
	{
		RenDev->Exit();
		delete RenDev; RenDev = NULL;
	}

	// Find device driver.
	UClass* RenderClass = UObject::StaticLoadClass( URenderDevice::StaticClass(), NULL, ClassName, NULL, LOAD_KeepImports, NULL );
	if( RenderClass )
	{
		HoldCount++;
		RenDev = ConstructObject<URenderDevice>( RenderClass, this );
		if ( RenDev->Init( this, NewX, NewY, NewColorBytes, Fullscreen ) )
		{
		}
		else
		{
			debugf( NAME_Log, LocalizeError("Failed3D") );
			delete RenDev;
			RenDev = NULL;
		}
		HoldCount--;
	}
}

#endif

/*------------------------------------------------------------------------------
	UFlicTexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/
UFlicTexture::UFlicTexture() 
{ 
	previousFrame=currentFrame=0;
	handle=NULL;	// Init the handle.
	eventSource=NULL;
	oldFilename = TEXT("");//appStrcpy(oldFilename,TEXT(""));
	filename = TEXT("");//appStrcpy(filename,TEXT(""));
	loop=spool=pause=false;
}

// One time initialization:
void UFlicTexture::Init( INT  InUSize, INT  InVSize )
{
	VERIFY_CLASS_OFFSET(U,FlicTexture,filename);

	UTextureCanvas::Init( InUSize, InVSize );
}
void UFlicTexture::Serialize( FArchive& Ar )
{
	UTextureCanvas::Serialize(Ar);	// Serialize mommy
}

void UFlicTexture::SetFrame( int frameNumber )
{
	TFAnimationInfo info;
	TFAnimation_GetInfo(handle, &info);		

	// Is this really just an increment?
	if(frameNumber==info.CurFrame+1)
		frameNumber=-1;

	if(frameNumber==-1)	TFFrame_Decode(handle);		
	else
	{
		if(frameNumber<0) frameNumber=0; // Clamp lower bounds
		else if(frameNumber>=info.NumFrames) 
		{
			if(loop) frameNumber%=info.NumFrames;
			else     frameNumber=info.NumFrames/*-1*/;
		}

		TFFrame_Seek(handle, frameNumber);
	}

	// If I have per frame triggering on, then trigger the event.
	// FIXME - inabit
	if(eventSource&&(newFrameEvent!=NAME_None))
		eventSource->eventGlobalTrigger(newFrameEvent, NULL, NULL);

	// Set current frame information:
	TFAnimation_GetInfo(handle, &info);				// Grab current anim info.
	previousFrame=currentFrame=info.CurFrame;		// Update current frame.

	time=0;				// Reset frame time
	SetDirty();			// Mark as dirty.
}

void __fastcall UFlicTexture::Tick( FLOAT DeltaSeconds )
{
	TFAnimationInfo info;
	UBOOL filenameChanged=appStricmp(*filename,*oldFilename);

	if(!handle||filenameChanged)	// Do I need to load a new flic?
	{
		if(handle)		// Do I need to unload the old file?
		{
			TFAnimation_GetInfo(handle, &info);					// Find the palette
			appFree(info.Palette);								// Free it.
			TFAnimation_Delete(handle);							// Delete animation handle
			handle=NULL;										// Clear out the handle.
		}

		oldFilename = filename;									// Save the new filename.

		if(!*filename) return;									// NUL string
		TCHAR loadFilename[256];								// The load filename
		appStrcpy(loadFilename,TEXT("..\\textures\\flc\\"));	// NJS: FIXME! Grab it from the flic directory.
		appStrcat(loadFilename,*filename);						// Append the filename to the path.

		if(spool)
		{
			if(!(handle=TFAnimation_NewFile(TCHAR_TO_ANSI(loadFilename))))	// Open the file.
				return;
		} else	// Load from memory
		{
			char *buffer;
			FILE *fh;
			long size;

			if(!(fh=fopen(TCHAR_TO_ANSI(loadFilename),"rb"))) 
				return;

			fseek(fh,0,SEEK_END);
			size=ftell(fh);
			fseek(fh,0,SEEK_SET);

			buffer=(char *)appMalloc(size,TEXT("Flic"));
			fread(buffer,1,size,fh);
			fclose(fh);

			if(!(handle=TFAnimation_NewMem(buffer)))	// Open the file.
				return;
		}

		if (!Mips(0).DataArray.Num())
			Mips(0).DataArray.Load();
		TFBuffers_Set(handle, (BYTE *)&Mips(0).DataArray(0),appMalloc(768,TEXT("FlicPalette")));
		
		SetFrame(currentFrame); 
		SetDirty();
	}

	TFAnimation_SetLooping(handle, loop);			// Set looping to user option.
	TFAnimation_GetInfo(handle, &info);				// Grab current anim info.

	if(!frameDelay)									// Has the user specified an overlay?
		frameDuration=(float)info.Speed/1000.0;
	else											// Set to the user specified time.
		frameDuration=frameDelay;

	if(previousFrame!=currentFrame)	// Is the user jumping around?
		SetFrame(currentFrame);
	else if(!pause)		// If I'm not paused, decode the next frame:
	{
		time+=DeltaSeconds;
		if(handle&&(time>=frameDuration))
			SetFrame(-1);				// Next Frame 
	}

	UTextureCanvas::Tick(DeltaSeconds);
}

IMPLEMENT_CLASS(UFlicTexture);


/*------------------------------------------------------------------------------
	UAVITexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/
UAVITexture::UAVITexture() 
{ 
	previousFrame=currentFrame=0;
	handle=NULL;	// Init the handle.
	eventSource=NULL;
	oldFilename = TEXT("");//appStrcpy(oldFilename,TEXT(""));
	filename = TEXT("");//appStrcpy(filename,TEXT(""));
	loop=spool=pause=false;
}

// One time initialization:
void UAVITexture::Init( INT  InUSize, INT  InVSize )
{

	VERIFY_CLASS_OFFSET(U,AVITexture,filename);

	UTextureCanvas::Init( InUSize, InVSize );

}
void UAVITexture::Serialize( FArchive& Ar )
{
	Super::Serialize(Ar);	// Serialize mommy

	return;
}

void UAVITexture::SetFrame( int frameNumber )
{
}

void __fastcall UAVITexture::Tick( FLOAT DeltaSeconds )
{
	UBOOL filenameChanged=appStricmp(*filename,*oldFilename);

	if(!handle||filenameChanged)	// Do I need to load a new flic?
	{
		if(handle)		// Do I need to unload the old file?
		{
			// ... Free the previous avi...
			handle=NULL;										// Clear out the handle.
		}

		oldFilename=filename;									// Save the new filename.

		if(!*filename) return;									// NUL string
		TCHAR loadFilename[256];								// The load filename
		appStrcpy(loadFilename,TEXT("..\\textures\\flc\\"));	// NJS: FIXME! Grab it from the flic directory.
		appStrcat(loadFilename,*filename);						// Append the filename to the path.

		if (!Mips(0).DataArray.Num())
			Mips(0).DataArray.Load();
		
		/* Load the flic: */
		SetDirty();
	}

	if(!frameDelay)									// Has the user specified an overlay?
		frameDuration=1000.f;
	else											// Set to the user specified time.
		frameDuration=frameDelay;

	if(!pause)		// If I'm not paused, decode the next frame:
	{
		time+=DeltaSeconds;
		if(handle&&(time>=frameDuration))
		{
			SetDirty();

			//SetFrame(-1);				// Next Frame 
		}
	}

	Super::Tick(DeltaSeconds);


}

IMPLEMENT_CLASS(UAVITexture);


/*------------------------------------------------------------------------------
	USmackerTexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/
USmackerTexture::USmackerTexture() 
{ 
	previousFrame=currentFrame=0;
	handle=NULL;	// Init the handle.
	eventSource=NULL;
	oldFilename = TEXT("");
	filename = TEXT("");
	loop=spool=pause=false;
	frameDuration=0;
	frameDelay=0;
	time=0;
}

// One time initialization:
void USmackerTexture::Init( INT  InUSize, INT  InVSize )
{

	VERIFY_CLASS_OFFSET(U,SmackerTexture,filename);

	UTextureCanvas::Init( InUSize, InVSize );
	time=0;

}

void USmackerTexture::Serialize( FArchive& Ar )
{
	Super::Serialize(Ar);		// Serialize mommy
	Ar << *((&currentFrame)+1);	// Serialize the flags out

	if(Ar.IsLoading())
	{
		time=0;
	}
}

void USmackerTexture::DumpHeader()
{
	if(!handle)
		debugf(_T("NULL Handle"));
	Smack *s=(Smack *)handle;
	
	if(s->Version!='2KMS')
		debugf(_T("Smack handle mismatch!"));
	
	debugf(_T("Width:%i Height:%i Frames:%i CurrentFrame:%i"),s->Width,s->Height,s->Frames,s->FrameNum);
	debugf(_T("MSPerFrame:%i"),s->MSPerFrame);

}

// A negative frame number means advance by that number of frames
void USmackerTexture::SetFrame( int frameNumber )
{
	if(!handle) return;

	// Special case advance by one frame:
	if(frameNumber==-1)
	{
		if(!loop&&(((Smack*)handle)->FrameNum>=((Smack*)handle)->Frames/*-1*/))
			return;

		SmackDoFrame((Smack*)handle);

		if(((Smack*)handle)->NewPalette)
			SetPalette();
		
		if(loop||(((Smack*)handle)->FrameNum<((Smack*)handle)->Frames-1))
		{
			SmackNextFrame((Smack*)handle);
		} else
			time=0;

		previousFrame=currentFrame=((Smack*)handle)->FrameNum;

		SetDirty();
		return;
	} else if(frameNumber<-1)
	{
		// Check for looping:
		if(!loop&&((((Smack*)handle)->FrameNum+(-frameNumber)-1)>=((Smack*)handle)->Frames-1))
			return;


		SetFrame((((Smack*)handle)->FrameNum-1)+-frameNumber);
		return;	
	}


	frameNumber++;	// Smacker frames are 1 based. 
	if((unsigned)frameNumber>=((Smack *)handle)->Frames+1) frameNumber=((Smack *)handle)->Frames+1;
	
	//frameNumber++;
	DWORD ClosestKeyFrame=SmackGetKeyFrame((Smack *)handle,frameNumber,SMACKGETKEYPREVIOUS);
	if(!ClosestKeyFrame) ClosestKeyFrame++;

	// Am I already closer than any keyframe?
	if((ClosestKeyFrame<=((Smack*)handle)->FrameNum)&&(((Smack*)handle)->FrameNum<(DWORD)frameNumber))
	{
		SmackDoFrame((Smack *)handle);

		SetPalette();
		ClosestKeyFrame=((Smack*)handle)->FrameNum;
	// Nope, jump to the closest keyframe:
	} else
	{
		// Goto the closest keyframe:
		SmackSoundOnOff((Smack *)handle,0);
		SmackGoto((Smack*)handle,ClosestKeyFrame);
		SmackSoundOnOff((Smack *)handle,1);
		SmackDoFrame((Smack *)handle);
		SetPalette();

		//SetFrame(frameNumber-1);
		// Decompress the keyframe:

		//SmackNextFrame((Smack *)handle);
		ClosestKeyFrame=((Smack*)handle)->FrameNum;
	}


	// And decompress remaining frames :
	for(INT frame=ClosestKeyFrame+1;frame<frameNumber;frame++)
	{

		SmackDoFrame((Smack *)handle);
		if(((Smack*)handle)->NewPalette)
			SetPalette();

		SmackNextFrame((Smack *)handle);
	}
	
	// No way of knowing if we passed a palette change, so force it to always set:
	SetPalette();

	previousFrame=currentFrame=((Smack*)handle)->FrameNum;
	SetDirty();
}


void __fastcall USmackerTexture::Tick( FLOAT DeltaSeconds )
{
	PolyFlags &= ~PF_Masked;

	if(DeltaSeconds>0.2f) DeltaSeconds=0.2f;
	if(!handle||appStricmp(*filename,*oldFilename))	// Do I need to load a new flic?
	{
		time=0;
		DeltaSeconds=0.01f;
		if(handle)		// Do I need to unload the old file?
		{
			SmackClose((Smack*)handle);		// ... Free the previous smack...
			handle=NULL;					// Clear out the handle.
		}

		oldFilename=filename;									// Save the new filename.

		if(!*filename) return;									// NUL string
		TCHAR loadFilename[256];								// The load filename
		appStrcpy(loadFilename,TEXT("..\\textures\\smk\\"));	// NJS: FIXME! Grab it from the flic directory.
		appStrcat(loadFilename,*filename);						// Append the filename to the path.

		if (!Mips(0).DataArray.Num())
			Mips(0).DataArray.Load();

		//TFBuffers_Set(handle, (BYTE *)&Mips(0).DataArray(0),appMalloc(768,TEXT("FlicPalette")));
		if(GIsMMX) SmackUseMMX(1);
		DWORD flags=SMACKTRACKS;
		if(!spool)		flags|=SMACKPRELOADALL;
		if(interlaced)	flags|=SMACKYINTERLACE;
		if(doubled)		flags|=SMACKYDOUBLE;

		handle=(void *)SmackOpen(TCHAR_TO_ANSI(loadFilename),flags,0/*SMACKAUTOEXTRA*/);

		if(handle)
		{
			if((((Smack *)handle)->Width>(unsigned)USize)
			 ||(((Smack *)handle)->Height>(unsigned)VSize))
				appErrorf(_T("Smack has larger dimensions than the texture"));

			//currentFrame=0; 
			previousFrame=0;
			appMemset(&Mips(0).DataArray(0),0,USize*VSize);
			

			SmackToBuffer((Smack*)handle, !centered?0:((USize-((Smack *)handle)->Width)/2), !centered?0:((VSize-((Smack *)handle)->Height)/2), USize, VSize, &Mips(0).DataArray(0), 0);
			
			// Initialize the palette:
			Palette = new( GetOuter() )UPalette;
			for( INT  i=0; i<256; i++ )
			{
				Palette->Colors.AddItem( FColor(0,0,0) );
				Palette->Colors(i).A=255;
			}
			SetPalette();
		}

		/* Load the flic: */
		if(restartOnLoad) {	currentFrame=0; previousFrame=-1; }
		SetFrame(currentFrame); 
		SetDirty();
	}

	if(!frameDelay)	frameDuration=0;			// Has the user specified an overlay?
	else			frameDuration=frameDelay;	// Set to the user specified time.
		
	if(previousFrame!=currentFrame)	// Is the user jumping around?
		SetFrame(currentFrame);
	else if(!pause)		// If I'm not paused, decode the next frame:
	{
		time+=DeltaSeconds;
		if(handle)
		{
			INT ProcessFrames=0;

			if(frameDuration)
			{
				// The cheap way for now:
				ProcessFrames=(INT)(time/frameDuration);
				time=fmod(time,frameDuration);
				
				if(ProcessFrames)
					SetFrame(-ProcessFrames);				// Next Frame 
			} else
			{
				if(!SmackWait((Smack*)handle))
					SetFrame(-1);
			}
		}
	} else
		time=0;
	
	Super::Tick(DeltaSeconds);
}

void USmackerTexture::SetPalette()	// Sets the palette from the smack.
{
	if(!handle||!Palette) return;

	
	for( INT i=0; i<256; i++ )
	{
		Palette->Colors(i).R=((Smack *)handle)->Palette[(i*3)+0];
		Palette->Colors(i).G=((Smack *)handle)->Palette[(i*3)+1];
		Palette->Colors(i).B=((Smack *)handle)->Palette[(i*3)+2];
	}
}

IMPLEMENT_CLASS(USmackerTexture);

void USmackerTexture::execGetFrameCount( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	Smack* s = (Smack*) handle;
	if ( s )
		*(INT*)Result = s->Frames;
	else
		*(INT*)Result = 100;
}
IMPLEMENT_FUNCTION( USmackerTexture, INDEX_NONE, execGetFrameCount );

#ifdef FIXME_Inabit


/*------------------------------------------------------------------------------
	UTerminalTexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/

UTerminalTexture::UTerminalTexture() 
{ 
	TerminalFont=NULL; 
	CursorRow=CursorColumn=Rows=Columns=0; 
	ClearColor=0;
	TerminalClear();
}

void UTerminalTexture::Serialize( FArchive& Ar )
{
	UTextureCanvas::Serialize(Ar);
	Ar << TerminalFont << ClearColor   << FlashingCursor << CursorCharacter 
	   << CursorRow    << CursorColumn << Rows           << Columns; 
	
	for(int i=0;i<ARRAY_COUNT(ScreenData);i++)
		Ar << ScreenData[i];
}

void UTerminalTexture::Init( INT  InUSize, INT  InVSize )
{
	VERIFY_CLASS_OFFSET(U,TerminalTexture,TerminalFont);

	UTextureCanvas::Init( InUSize, InVSize );
	TerminalResize();
}

void UTerminalTexture::ConstantTimeTick()
{
	TerminalDraw();							// Draw the terminal to the texture
	UTextureCanvas::ConstantTimeTick();		// Update UTextureCanvas

	// Flash the cursor when appropriate:
	if(FlashingCursor&&((int)(appSeconds()*2))&1)
		ScreenData[CursorRow*Columns+CursorColumn]=' ';
	else
		ScreenData[CursorRow*Columns+CursorColumn]=CursorCharacter;
}

IMPLEMENT_CLASS(UTerminalTexture);

void UTerminalTexture::TerminalResize()
{

	if(!TerminalFont) { Rows=Columns=0; }
	else
	{
		int u, v;
		TerminalFont->GetMaxCharSize( u, v );
		Rows=VSize/v;
		Columns=USize/u;
	}

}

// Clear the terminal to all spaces:
void UTerminalTexture::TerminalClear()
{

	appMemset(ScreenData,' ',ARRAY_COUNT(ScreenData));
	SetDirty();

}

void UTerminalTexture::TerminalDraw()
{

	DrawClear(ClearColor);
	TerminalResize();	// Check for resizing

	if(!TerminalFont||!Rows||!Columns) return;

	// Draw the bastardo:
	int r, c, x, y, u, v, xStart, yStart;
	TerminalFont->GetMaxCharSize( u, v ); 

	// Calculate the center of the texture:
	xStart=(USize%u)/2;
	yStart=(VSize%v)/2;

	// Draw the terminal non-proportionally:
	for(r=0,y=yStart;r<Rows;r++,y+=v)
		for(c=0,x=xStart;c<Columns;c++,x+=u)
			DrawCharacter( TerminalFont, x, y, ScreenData[r*Columns+c]);

}

void UTerminalTexture::TerminalAddChar(char character)
{

	if(!Rows||!Columns||!TerminalFont) return;

	// If this wasn't a control character, set it:
	if(character!='\r'&&character!='\n')
	{
		ScreenData[CursorRow*Columns+CursorColumn]=character;
	}

	// Advance to next position:
	if(character=='\r'||character=='\n')
	{
		// Move to next row, and reset column to zero.
		CursorRow++; CursorColumn=0; 
	} else 
	{
		CursorColumn++;

		// Have I gone past the right hand part of the screen?
		if(CursorColumn>=Columns) { CursorColumn=0; CursorRow++; }
	}

	// Have I gone past the bottom of the screen?
	if(CursorRow>=Rows)
	{
		// Scroll everything up one:
		memmove(&ScreenData[0],&ScreenData[Columns],ARRAY_COUNT(ScreenData)-Columns);
		CursorRow=Rows-1;

		// Clear out the new row:
		memset(&ScreenData[(Rows-1)*Columns],' ',Columns);
	}


}

void UTerminalTexture::TerminalAddText(char *string)
{
	
	// Process each character:
	for(;*string;string++)
		TerminalAddChar(*string);


}

GLOBALREGISTER_INTRINSIC( UTerminalTexture, EX_TerminalAddText, TerminalAddText )
{
	
	P_THIS(UTerminalTexture);
	P_GET_STRING(s);
	P_FINISH;

	This->TerminalAddText(s);


}

GLOBALREGISTER_INTRINSIC( UTerminalTexture, EX_TerminalClear, TerminalClear )
{
	
	P_THIS(UTerminalTexture);
	This->TerminalClear();
}

/*------------------------------------------------------------------------------
	UCommandPromptTexture (Simple texture derived from texture canvas).
	(NJS: Executing a command currently causes the engine to loose focus.)
------------------------------------------------------------------------------*/
UCommandPromptTexture::UCommandPromptTexture() 
{ 

}


IMPLEMENT_CLASS(UCommandPromptTexture);


void UCommandPromptTexture::TerminalAddText(char *command)
{
	FILE *handle;

	char commandFixed[1024];
	char buffer[4096];

	// Echo the command:
	UTerminalTexture::TerminalAddText(command);
	UTerminalTexture::TerminalAddText("Fargonargus!\n");

	// Format the command:
	strcpy(commandFixed,command);
	if(strchr(commandFixed,'\r'))
		*((char *)strchr(commandFixed,'\r'))='\0';

	if(strchr(commandFixed,'\n'))
		*((char *)strchr(commandFixed,'\n'))='\0';

	appSprintf(buffer,"%s > \\temp.txt\n",commandFixed);
	system(buffer);
	
	if(handle=fopen("\\temp.txt","rb"))
	{
		while(fgets(buffer,ARRAY_COUNT(buffer),handle))
			UTerminalTexture::TerminalAddText(buffer);

		fclose(handle);
		remove("\\temp.txt");
	} 

}



/*------------------------------------------------------------------------------
	UTerminalTexture (Simple texture derived from texture canvas).
------------------------------------------------------------------------------*/
static WSADATA ws;
static UBOOL   wsInitialized;

UTelnetTexture::UTelnetTexture() 
{ 

	Socket=SOCKET_ERROR;

	// Try to initialize winsock
	if(!wsInitialized)					// Is winsock initialized?
		if(!WSAStartup(0x101,&ws))		// Start it up.
			wsInitialized=true;			// Mark as initialized.

}

void UTelnetTexture::Serialize( FArchive& Ar )
{
	UTerminalTexture::Serialize(Ar);
	Ar << LocalEcho << CrLf;
}

void UTelnetTexture::Init( INT  InUSize, INT  InVSize )
{

	VERIFY_CLASS_OFFSET(U,TelnetTexture,LocalEcho);

	UTerminalTexture::Init( InUSize, InVSize );


}

void UTelnetTexture::ConstantTimeTick()
{
	char buffer[512];

	if(TelnetReceiveText(buffer, ARRAY_COUNT(buffer)))
		UTerminalTexture::TerminalAddText(buffer);

	UTerminalTexture::ConstantTimeTick(); // Update UTerminalTexture


}
IMPLEMENT_CLASS(UTelnetTexture);

void UTelnetTexture::TerminalAddText(char *text)
{

	if(!text) return;	 // Ensure command is valid
	text=appRmlws(text); // Remove leading whitespace
	if(!*text) return;	 // Make sure there's something left.

	if((*text)=='@') TelnetCommand(text+1); // is this a command?
	else			 TelnetSendText(text);

}

UBOOL UTelnetTexture::TelnetConnect(char *address)
{
	struct sockaddr_in Sa;
	struct hostent *H;
    unsigned long True=1;             /* An in memory representation of True */
	int port=23;
	char buffer[256];
	char *colonIndex;

	if(!address||!TelnetDisconnect()) return false;	// Make sure I'm disconnected.

	// Make address writeable:
	strcpy(buffer,appRmlws(address)); address=buffer;

	// Strip any CR/LF at the end:
	if(strchr(address,'\r')) *(strchr(address,'\r'))='\0';
	if(strchr(address,'\n')) *(strchr(address,'\n'))='\0';

	// See if I include a port specification:
	if((colonIndex=appStrchr(buffer,':')))
	{		 
		*colonIndex='\0'; colonIndex=appRmlws(colonIndex+1);
		port=atoi(colonIndex);
	}

	Socket=socket(AF_INET,SOCK_STREAM,0);
    if(FAILED(ioctlsocket(Socket,FIONBIO,&True)))        /* Set non-blocking */
    {  
		UTerminalTexture::TerminalAddText("\nTelnet: Couldn't set non blocking mode\n"); 
		return false; 
	}

	Sa.sin_family=AF_INET;
	Sa.sin_port=htons(port);

	H=gethostbyname(address);
	if(!H) 
	{ 
		UTerminalTexture::TerminalAddText("\nTelnet: Host not available (");
		UTerminalTexture::TerminalAddText(address);
		UTerminalTexture::TerminalAddText(")\n");
		return false; 
	}

	// Connect:
	Sa.sin_addr.s_addr=*((unsigned long *)H->h_addr);
	connect(Socket,(struct sockaddr *)&Sa,sizeof(Sa));

	UTerminalTexture::TerminalAddText("\nConnecting:");
	UTerminalTexture::TerminalAddText(address);
	UTerminalTexture::TerminalAddText("\n");

	return true;
}

UBOOL UTelnetTexture::TelnetDisconnect()
{
	if(Socket!=SOCKET_ERROR)
	{
		closesocket(Socket);
		Socket=SOCKET_ERROR;
	}

	return true;
}

// Send text to the socket.
UBOOL UTelnetTexture::TelnetSendText  (char *text)
{
	char SendBuffer[4096];

	if(!text||!wsInitialized||Socket==SOCKET_ERROR) return false;

	// Should I echo?
	if(LocalEcho) UTerminalTexture::TerminalAddText(text); 

	// Should I add a CR/LF pair?
	appStrcpy(SendBuffer,text);
	if(CrLf) appStrcat(SendBuffer,"\r\n");

	if(send(Socket,SendBuffer,appStrlen(SendBuffer),0) == SOCKET_ERROR )
		return false;

	return true;
}

// Receive text if there is any pending:
UBOOL UTelnetTexture::TelnetReceiveText(char *buffer, int bufferMaxSize)
{
	int i;

	if(!wsInitialized||Socket==SOCKET_ERROR) return false;

	if(FAILED(i=recv(Socket,buffer,bufferMaxSize-1,0)))
	{
		*buffer='\0';
		return false;
	} 
	
	buffer[i]='\0';
	return true;
}

// Process a Telnet terminal command string:
UBOOL UTelnetTexture::TelnetCommand  (char *command)
{
	command=appRmlws(command);

	if(!strnicmp(command,"connect",appStrlen("connect")))	// Is this a connection command?
		return TelnetConnect(appRmlws(command+appStrlen("connect")));
	else if(!strnicmp(command,"disconnect",appStrlen("disconnect")))
		return TelnetDisconnect();
	else if(!strnicmp(command,"echo",appStrlen("echo")))
		UTerminalTexture::TerminalAddText(command+appStrlen("echo"));


	return false;
}
#endif

/*------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------*/

