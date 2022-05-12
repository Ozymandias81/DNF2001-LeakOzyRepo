/*=============================================================================
	Texcnvrt.cpp: Routines for converting textures to an SGL format.

	Copyright 1997 NEC Electronics Inc.
	Based on code copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Jayeson Lee-Steere 

=============================================================================*/
// Precompiled header.
#pragma warning( disable:4201 )
#include <windows.h>
#include "Engine.h"
#include "UnRender.h"

// SGL includes.
#include "unsgl.h"

//*****************************************************************************
// Returns the SGL map type for the specified input values
//*****************************************************************************
BYTE USGLRenderDevice::GetSglMapType(DWORD TextureFlags,BOOL MipMapped)
{
	guard(USGLRenderDevice::GetSglMapType);
	
	if (TextureFlags & (SF_ColorKey | SF_AdditiveBlend | SF_ModulationBlend | SF_LightMap | SF_FogMap))
	{
		// Pretty much everthing special is a 4444 texture.
		if (MipMapped)
			return sgl_map_trans16_mm;
		else
			return sgl_map_trans16;
	}
	else
	{
		// Everything else is 555 texture.
		if (MipMapped)
			return sgl_map_16bit_mm;
		else
			return sgl_map_16bit;
	}

	unguard;
}

//*****************************************************************************
// Returns the SGL map size for the specified dimension
//*****************************************************************************
BYTE USGLRenderDevice::GetSglMapSize(int Dimensions)
{
	guard(USGLRenderDevice::GetSglMapSize);
	switch (Dimensions)
	{
		case 256:
			return sgl_map_256x256;
		case 128:
			return sgl_map_128x128;
		case 64:
			return sgl_map_64x64;
		case 32:
			return sgl_map_32x32;
		default:
			appErrorf(TEXT("Critical error: Texture dimension=%i"),Dimensions);
			return 0;
	}
	unguard;
}

//*****************************************************************************
// Returns the size of data for a texture of specified dimensions.
//*****************************************************************************
int USGLRenderDevice::GetSglDataSize(int Dimensions,BOOL MipMapped)
{
	guard(USGLRenderDevice::GetSglDataSize);

	if (!MipMapped)
	{
		return Dimensions*Dimensions;
	}
	else
	{
		switch (Dimensions)
		{
			case 256:
				return 256*256 + 128*128 + 64*64 + 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*2;
			case 128:
				return 128*128 + 64*64 + 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*2;
			case 64:
				return 64*64 + 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*2;
			case 32:
				return 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*2;
			default:
				appErrorf(TEXT("Critical error: Texture dimension=%i"),Dimensions);
				return 0;
		}
	}

	unguard;
}

//*****************************************************************************
// Returns the offset into sgl pixel data to access the specified mipmap level.
//*****************************************************************************
int USGLRenderDevice::MipMapOffset(int Dimensions,int Level)
{
	guard(USGLRenderDevice::MipMapOffset);
	switch (Dimensions>>Level)
	{
		case 256:
			return 128*128 + 64*64 + 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*1*2;
		case 128:
			return 64*64 + 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*1*2;
		case 64:
			return 32*32 + 16*16 + 8*8 + 4*4 + 2*2 + 1*1*2;
		case 32:
			return 16*16 + 8*8 + 4*4 + 2*2 + 1*1*2;
		case 16:
			return 8*8 + 4*4 + 2*2 + 1*1*2;
		case 8:
			return 4*4 + 2*2 + 1*1*2;
		case 4:
			return 2*2 + 1*1*2;
		case 2:
			return 1*1*2;
		case 1:
			return 1;
		default:
			return 0;
	}
	unguard;
}

//*****************************************************************************
// Returns how many levels there are for different sized textures.
//*****************************************************************************
int USGLRenderDevice::NumLevels(int Dimensions)
{
	guard(USGLRenderDevice::NumLevels);
	switch (Dimensions)
	{
		case 32:
			return 6;
		case 64:
			return 7;
		case 128:
			return 8;
		case 256:
			return 9;
		default:
			return 0;
	}
	unguard;
}

//*****************************************************************************
// Creates a 16 bit palette from the supplied FColor palette and texture flags
//*****************************************************************************
void USGLRenderDevice::CreateSglPalette(WORD *SglPalette,FColor *SrcPalette,
										INT PaletteSize,DWORD TextureFlags,
										FColor& MaxColor)
{
	guard(USGLRenderDevice::CreateSglPalette);
	CLOCK(Stats.PaletteTime);
	STATS_INC(Stats.Palettes);

	// Fix up the max color so we don't accidentally divide by zero.
	if (MaxColor.R < 1)
		MaxColor.R=1;
	if (MaxColor.G < 1)
		MaxColor.G=1;
	if (MaxColor.B < 1)
		MaxColor.B=1;
	if (TextureFlags & SF_NoScale)
		MaxColor.R=MaxColor.G=MaxColor.B=255;

	int ScaleR=0x10000*255/MaxColor.R;
	int ScaleG=0x10000*255/MaxColor.G;
	int ScaleB=0x10000*255/MaxColor.B;

	if (TextureFlags & SF_AdditiveBlend)
	{
		// Texture is an one,one translucency texture, so convert to 4444.
		for (int i=0;i<PaletteSize;i++)
		{
			int R,G,B,I,A;

			R=SrcPalette[i].R;
			G=SrcPalette[i].G;
			B=SrcPalette[i].B;
			I=Max(R,Max(G,B));
			A=255-I;
			// I=I+1, Scale= 256/I * (2*I+256)/(3*256)
			int TopScale=256*2*I + 256*258;
			int BottomScale=(I+1)*256*3;
			R=R*TopScale/BottomScale*ScaleR;
			G=G*TopScale/BottomScale*ScaleG;
			B=B*TopScale/BottomScale*ScaleB;
			SglPalette[i]=((R & 0xF00000) >> 12) | 
						  ((G & 0xF00000) >> 16) | 
						  ((B & 0xF00000) >> 20) |
						  ((A & 0xF0) << 8);
		}
		if (TextureFlags & SF_ColorKey)
			SglPalette[0]|=0xF000;
	}
	else if (TextureFlags & SF_ModulationBlend)
	{
		// NOTE: MaxColor has no effect on modulation blends since it is
		//       simulated with an alpha blend.
		for (int i=0;i<PaletteSize;i++)
		{
			int I=Max(SrcPalette[i].R,Max(SrcPalette[i].G,SrcPalette[i].B))*2;
			if (I > 0xFF)
				I=0xFF;
			SglPalette[i]=(I & 0xF0) << 8;
		}
		if (TextureFlags & SF_ColorKey)
			SglPalette[0]|=0xF000;
	}
	else if (TextureFlags & SF_ColorKey)
	{ 
		// Texture is an alpha texture, so convert to 4444.
		if (TextureFlags & SF_NoScale)
		{
			for (int i=0;i<PaletteSize;i++)
			{
				int R=SrcPalette[i].R;
				int G=SrcPalette[i].G;
				int B=SrcPalette[i].B;
				R&=0xF0;
				G&=0xF0;
				B&=0xF0;
				R=R << 4;
				B=B >> 4;
				SglPalette[i]=R + G + B;
			}
		}
		else
		{
			for (int i=0;i<PaletteSize;i++)
			{
				SglPalette[i]=(((SrcPalette[i].R*ScaleR) & 0xF00000) >> 12) |
							  (((SrcPalette[i].G*ScaleG) & 0xF00000) >> 16) |
							  (((SrcPalette[i].B*ScaleB) & 0xF00000) >> 20);
			}
		}
		SglPalette[0]|=0xF000;
	}
	else 
	{
		// Texture is not an alpha texture so convert to 555.
		if (TextureFlags & SF_NoScale)
		{
			for (int i=0;i<PaletteSize;i++)
			{
				int R=SrcPalette[i].R;
				int G=SrcPalette[i].G;
				int B=SrcPalette[i].B;
				R&=0xF8;
				G&=0xF8;
				B&=0xF8;
				R=R << 7;
				G=G << 2;
				B=B >> 3;
				SglPalette[i]=R + G + B;
			}
		}
		else
		{
			for (int i=0;i<PaletteSize;i++)
			{
				SglPalette[i]=(((SrcPalette[i].R*ScaleR) & 0xF80000) >> 9) |
							  (((SrcPalette[i].G*ScaleG) & 0xF80000) >> 14) |
							  (((SrcPalette[i].B*ScaleB) & 0xF80000) >> 19);
			}
		}
	}

	UNCLOCK(Stats.PaletteTime);
	unguard;
}

//*****************************************************************************
// Converts an 8 bit rectangular texture with a 16 bit palette to a 
// preprocessed SGL texture.
//*****************************************************************************
void USGLRenderDevice::ConvertTextureData(int Dimensions,
										  int TargetXSize,int TargetYSize,
										  int XSize,int YSize,
										  WORD *Target,BYTE *Src,WORD *SglPalette)
{
	guard(USGLRenderDevice::ConvertTextureData);
	CLOCK(Stats.TextureTime);
	STATS_INC(Stats.Textures);

	if (Dimensions<=8/* || XSize!=Dimensions || YSize!=Dimensions*/)
	{
		// If the dimensions are small, just use an unoptimized routine.
		int XCount,YCount,XStep,YStep,XMask,YMask;

		// Calculate X and Y count.
		XCount=Max(XSize,Dimensions);
		YCount=Max(YSize,Dimensions);
		// Calcluate X and Y step.
		XStep=Max(1,XSize/TargetXSize);
		YStep=Max(1,YSize/TargetYSize);
		// Calculate X and Y mask.
		XMask=XSize-1;
		YMask=YSize-1;
		// Do conversion
		for (int Y=0,YOffset=0;Y<YCount;Y+=YStep,YOffset=(YOffset+UNSGL_INC_Y_ADD) & UNSGL_INC_Y_AND)
		{
			for (int X=0,XOffset=0;X<XCount;X+=XStep,XOffset=(XOffset+UNSGL_INC_X_ADD) & UNSGL_INC_X_AND)
			{
				Target[XOffset | YOffset]=SglPalette[Src[(Y&YMask)*XSize + (X&XMask)]];
			}
		}
	}
	else
	{
		// Optimized routine designed to write in consecutive order for improved write back
		// cache efficiency.
		int Indexes[8];
		int Counts[8];
		int Offset[8];
		int Offsets[8][4];
	
		// Set up counts.
		for (int i=0,Bit=1;i<8;i++,Bit=Bit<<1)
		{
			if (Bit >= Dimensions)
				Counts[i]=1;
			else
				Counts[i]=4;
		}

		// Set up offsets.
		int XMask=XSize-1;
		int YMask=YSize-1;
		int XStep=Max(1,XSize/TargetXSize);
		int YStep=Max(1,YSize/TargetYSize);
		for (i=0;i<8;i++)
		{
			int StepX=((1<<i)*XStep) & XMask;
			int StepY=((1<<i)*YStep) & YMask;
			Offsets[i][0]=0;						// Top left.
			Offsets[i][1]=XSize*StepY;				// Bottom left.
			Offsets[i][2]=StepX;					// Top right.
			Offsets[i][3]=XSize*StepY + StepX;		// Bottom right.
		}

		// Now convert the data. This pretty routine writes in consecutive order which
		// is supposed to be the most efficient way to do it.
		for (Indexes[7]=0;Indexes[7]<Counts[7];Indexes[7]++)
		{
			Offset[7]=Offsets[7][Indexes[7]];
			for (Indexes[6]=0;Indexes[6]<Counts[6];Indexes[6]++)
			{
				Offset[6]=Offset[7] + Offsets[6][Indexes[6]];
				for (Indexes[5]=0;Indexes[5]<Counts[5];Indexes[5]++)
				{
					Offset[5]=Offset[6] + Offsets[5][Indexes[5]];
					for (Indexes[4]=0;Indexes[4]<Counts[4];Indexes[4]++)
					{
						Offset[4]=Offset[5] + Offsets[4][Indexes[4]];
						for (Indexes[3]=0;Indexes[3]<Counts[3];Indexes[3]++)
						{
							Offset[3]=Offset[4] + Offsets[3][Indexes[3]];
							for (Indexes[2]=0;Indexes[2]<Counts[2];Indexes[2]++)
							{
								Offset[2]=Offset[3] + Offsets[2][Indexes[2]];

								Target[0]=SglPalette[Src[Offset[2] + Offsets[1][0] + Offsets[0][0]]];
								Target[1]=SglPalette[Src[Offset[2] + Offsets[1][0] + Offsets[0][1]]];
								Target[2]=SglPalette[Src[Offset[2] + Offsets[1][0] + Offsets[0][2]]];
								Target[3]=SglPalette[Src[Offset[2] + Offsets[1][0] + Offsets[0][3]]];

								Target[4]=SglPalette[Src[Offset[2] + Offsets[1][1] + Offsets[0][0]]];
								Target[5]=SglPalette[Src[Offset[2] + Offsets[1][1] + Offsets[0][1]]];
								Target[6]=SglPalette[Src[Offset[2] + Offsets[1][1] + Offsets[0][2]]];
								Target[7]=SglPalette[Src[Offset[2] + Offsets[1][1] + Offsets[0][3]]];

								Target[8]=SglPalette[Src[Offset[2] + Offsets[1][2] + Offsets[0][0]]];
								Target[9]=SglPalette[Src[Offset[2] + Offsets[1][2] + Offsets[0][1]]];
								Target[10]=SglPalette[Src[Offset[2] + Offsets[1][2] + Offsets[0][2]]];
								Target[11]=SglPalette[Src[Offset[2] + Offsets[1][2] + Offsets[0][3]]];

								Target[12]=SglPalette[Src[Offset[2] + Offsets[1][3] + Offsets[0][0]]];
								Target[13]=SglPalette[Src[Offset[2] + Offsets[1][3] + Offsets[0][1]]];
								Target[14]=SglPalette[Src[Offset[2] + Offsets[1][3] + Offsets[0][2]]];
								Target[15]=SglPalette[Src[Offset[2] + Offsets[1][3] + Offsets[0][3]]];

								Target+=16;
							}
						}
					}
				}
			}
		}
	}

	UNCLOCK(Stats.TextureTime);
	unguard;
}

//*****************************************************************************
// Converts a 24 bit light map texture to a preprocessed SGL texture.
//*****************************************************************************
void USGLRenderDevice::ConvertLightMapData(int Dimensions,
										   int XSize,int YSize,int XClamp,int YClamp,
										   WORD *Target,FRainbowPtr Src,FColor& MaxColor)
{
	guard(USGLRenderDevice::ConvertLightMapData);
	CLOCK(Stats.LightMapTime);
	STATS_INC(Stats.LightMaps);

    // Find max brightness if not yet computed.
    if( GET_COLOR_DWORD(MaxColor)==0xffffffff )
    {
		STATS_INC(Stats.LightMaxColors);
		CLOCK(Stats.LightMaxColorTime);
        
		DWORD* Tmp = Src.PtrDWORD;
        DWORD  Max = 0x01010101;
        for( INT i=0; i<YClamp; i++ )
        {
                for( INT j=0; j<XClamp; j++ )
                {
                        DWORD Flow = (Max - *Tmp) & 0x80808080;
                        if (Flow)
                        {
                                DWORD MaxMask = Flow - (Flow >> 7);
                                Max = (*Tmp & MaxMask) | (Max & (0x7f7f7f7f - MaxMask)) ;
                        }
                        Tmp++;
                }
                Tmp += XSize - XClamp;
        }
        GET_COLOR_DWORD(MaxColor) = Max;
        check(!(Max&0x00808080));

		UNCLOCK(Stats.LightMaxColorTime);
    }

	int XStep=Max(1,XSize/Dimensions);
	int YStep=Max(1,YSize/Dimensions);
	int PtrStep=YStep*XSize;

	// On PCX2 we do a simulation with regular SRC_ALPHA, INV_SRC_ALPHA blending.
	// The texure is converted to ARGB 4444.
	// Calculate the maximum intensity.
	int MaxI=Max(MaxColor.R,Max(MaxColor.G,MaxColor.B));
	// Calculate the scaling value.
	int ScaleVal=(0x100*255*14/16)/IntensityAdjustTable[MaxI];
	// Precalculate scaled values.
	INT ScaleI[128], ColorScaleR[128], ColorScaleG[128], ColorScaleB[128], i;

	for( i=0; i<=MaxI; i++ )
	{
		int I = (IntensityAdjustTable[i]*ScaleVal)&0xF000;
		ScaleI[i] = I;
		int TopScale = 0x200*2*255;
		int BottomScale = (0x0F-(I>>12));
		ColorScaleR[i] = TopScale / (BottomScale * MaxColor.R);
		ColorScaleG[i] = TopScale / (BottomScale * MaxColor.G);
		ColorScaleB[i] = TopScale / (BottomScale * MaxColor.B);
	}
	
	// Convert the data.
	for( int y=0,YOffset=0; y<YClamp; y+=YStep,YOffset=(YOffset + UNSGL_INC_Y_ADD) & UNSGL_INC_Y_AND )
	{
		for( int x=0,XOffset=0; x<XClamp; x+=XStep,XOffset=(XOffset + UNSGL_INC_X_ADD) & UNSGL_INC_X_AND)
		{
			INT I=Max(Src.PtrBYTE[2],Max(Src.PtrBYTE[0],Src.PtrBYTE[1]));
			int R=Src.PtrBYTE[0] * ColorScaleR[I];
			if (R>0x0000FFFF)
				R=0x0000FFFF;
			int G=Src.PtrBYTE[1] * ColorScaleG[I];
			if (G>0x0000FFFF)
				G=0x0000FFFF;
			int B=Src.PtrBYTE[2] * ColorScaleB[I];
			if (B>0x0000FFFF)
				B=0x0000FFFF;
			int A=ScaleI[I];
			Target[YOffset | XOffset]=(((R)&0x0000F000)>>12) |
									  (((G)&0x0000F000)>>8 ) |
									  (((B)&0x0000F000)>>4 ) |
									  A;
			Src.PtrDWORD+=XStep;
		}
		Src.PtrDWORD -= x;
		Src.PtrDWORD += PtrStep;
	}

	UNCLOCK(Stats.LightMapTime);
	unguard;
}

//*****************************************************************************
// Converts a 24 bit fog map texture to a preprocessed SGL texture.
//*****************************************************************************
void USGLRenderDevice::ConvertFogMapData(int Dimensions,
										 int XSize,int YSize,int XClamp,int YClamp,
										 WORD *Target,FRainbowPtr Src,FColor& MaxColor)
{
	guard(USGLRenderDevice::ConvertFogMapData);
	
	CLOCK(Stats.FogMapTime);
	STATS_INC(Stats.FogMaps);

	int XStep=Max(1,XSize/Dimensions);
	int YStep=Max(1,YSize/Dimensions);
	int PtrStep=YStep*XSize;

	// Convert 8-8-8 fog maps to 5-5-5.
	for( int y=0,YOffset=0; y<YClamp; y+=YStep,YOffset=(YOffset + UNSGL_INC_Y_ADD) & UNSGL_INC_Y_AND )
	{
		for( int x=0,XOffset=0; x<XClamp; x+=XStep,XOffset=(XOffset + UNSGL_INC_X_ADD) & UNSGL_INC_X_AND)
		{
			INT B=Src.PtrBYTE[0];
			INT G=Src.PtrBYTE[1];
			INT R=Src.PtrBYTE[2];
			INT I=Max(R,Max(B,G));
			if (I==0)
				I=1;
			B=B*255/I;
			G=G*255/I;
			R=R*255/I;
			I=255-12-(I*2);
			if (I<0)
				I=0;
			Target[YOffset | XOffset]=
				((B & 0xF0) >> 4) +
				((G & 0xF0)     ) +
				((R & 0xF0) << 4) +
				((I & 0xF0) << 8);
			Src.PtrDWORD+=XStep;
		}
		Src.PtrDWORD -= x;
		Src.PtrDWORD += PtrStep;
	}

	UNCLOCK(Stats.FogMapTime);
	unguard;
}
