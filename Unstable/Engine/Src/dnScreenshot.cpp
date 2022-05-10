//========================================================================================
//	dnScreenshot.cpp
//	John Pollard
//		Screenshot support code for script
//========================================================================================
#include "EnginePrivate.h"		// Big momma include

UBOOL			GWaitingForScreenshot;
UBOOL			GScreenshotReady;
UTexture		*GTempTexture;

//========================================================================================
//	FillTextureToFit
//========================================================================================
static void FillTextureToFit(FColor *Src, int SrcWidth, int SrcHeight, UTexture *Dst)
{
	int		SrcX, SrcY, StepX, StepY, x, y;

	StepX = SrcWidth*65536 / Dst->USize;
	StepY = SrcHeight*65536 / Dst->VSize;
	
	SrcY = 0;

	DWORD	*DstBits = (DWORD*)&Dst->Mips(0).DataArray(0);
	FColor	*SrcBits = Src;

	for(y=0;y<Dst->VSize;y++)
	{
		DWORD	*pDst;
		FColor	*pSrc;

		pDst = &DstBits[y * Dst->USize];

		pSrc = &SrcBits[(SrcY>>16) * SrcWidth];

		SrcX = 0;

		for(x=0;x<Dst->USize;x++)
		{
			//pDst[x] = pSrc[SrcX>>16].TrueColor() | 0xff000000;
			// Swizzle the bits
			//DWORD Color = pSrc[SrcX>>16].TrueColor();
			//pDst[x] = ((Color&0x000000ff)<<16) | (Color&0x0000ff00) | ((Color&0x00ff0000)>>16) | 0xff000000;
			DWORD Color = pSrc[SrcX>>16].FlatColor;
			pDst[x] = Color | 0xff000000;

			SrcX += StepX;
		}

		SrcY += StepY;
	}
	
	Dst->bRealtimeChanged = 1;
}

//========================================================================================
//	FillTexture
//========================================================================================
static void FillTexture(FColor *Src, int SrcWidth, int SrcHeight, UTexture *Dst)
{
	if (SrcWidth != Dst->USize || SrcHeight != Dst->VSize)
	{
		FillTextureToFit(Src, SrcWidth, SrcHeight, Dst);
		return;
	}

	int				w, h;
	DWORD			*pDstBits = (DWORD*)&Dst->Mips(0).DataArray(0);
	FColor			*pSrcBits = Src;

	for (h=0; h< 128; h++)
	{
		for (w=0; w< 128; w++)
		{
			// Swizzle the bits
			//DWORD Color = pSrcBits[h*SrcWidth+w].TrueColor();
			//*pDstBits++ = ((Color&0x000000ff)<<16) | (Color&0x0000ff00) | ((Color&0x00ff0000)>>16) | 0xff000000;
			DWORD Color = pSrcBits[h*SrcWidth+w].FlatColor;
			*pDstBits++ = Color | 0xff000000;
		}
	}

	Dst->bRealtimeChanged = 1;
}

//========================================================================================
//	dnScreenshot_FillScreenshotTexture
//========================================================================================
void dnScreenshot_FillScreenshotTexture(UViewport *Viewport, UBOOL bFrontBuffer)
{
	FMemMark		Mark(GMem);

	//	Fill in screenshot here using the current contents of front/back buffer
	FColor* Buf = new(GMem,Viewport->SizeX*Viewport->SizeY)FColor;

	Viewport->RenDev->ReadPixels( Buf, !bFrontBuffer);

	FillTexture(Buf, Viewport->SizeX, Viewport->SizeY, GTempTexture);

	GScreenshotReady = true;
	Mark.Pop();
}

//========================================================================================
//	AActor::execScreenshot
//========================================================================================
void AActor::execScreenshot( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL(bNoMenus);
	P_FINISH;

	if (bNoMenus)
	{
		// Queue up the screenshot so we can take it of the backbuffer, before the menus have drawn...
		GWaitingForScreenshot = true;
		GScreenshotReady = false;
	}
	else
	{
		// Take a screenshot of the front buffer
		dnScreenshot_FillScreenshotTexture(GetLevel()->Engine->Audio->GetViewport(), true);
	}
	
	// Point them to the global texture used for screenshots
	*(UTexture**)Result = GTempTexture;
}

//========================================================================================
//	AActor::execScreenShotIsValid
//========================================================================================
void AActor::execScreenShotIsValid( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(UBOOL*)Result = GScreenshotReady;
}
