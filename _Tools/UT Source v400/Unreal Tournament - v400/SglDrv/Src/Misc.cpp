/*=============================================================================
	Misc.cpp: Misc functions for Unreal PowerVR driver.

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

FSGLStats Stats;
FSGLStats LastStats;

//*****************************************************************************
// Calculates a single gamma'd value.
//*****************************************************************************
static inline int GammaAdjustValue(int Value,double Gamma)
{
	guard (GammaAdjustValue);

	if (Gamma==1.0)
		return Value;
	else
		return (int) (appPow(Value/255.,1.0/Gamma) * 255.0 + 0.5);

	unguard;
}

//*****************************************************************************
// Private USGLRenderDevice functions.
//*****************************************************************************
//*****************************************************************************
// Updates the tables which are affected by a new gamma value.
//*****************************************************************************
void USGLRenderDevice::UpdateGammaTables(float Gamma)
{
	guard(USGLRenderDevice::UpdateGammaTables);

//todo: [USGLRenderDevice::UpdateGammaTables] Shouldn't need to keep gamma >= 1
//	if (Gamma<1.0f)
//		Gamma=1.0f;

	for (int i=0;i<0x100;i++)
	{
		GammaTable[i]=GammaAdjustValue(i,Gamma);
	}
	for (i=0;i<128;i++)
	{
		int I;

		I=i*2;
//		if (I>255)
//			I=255;
		IntensityAdjustTable[i]=
			GammaAdjustValue(I,Gamma*UNSGL_PCX_LIGHTMAP_GAMMA*(16.0/14.0))*14/16;
	}
	unguard;
}

#if 0
//*****************************************************************************
// Draws the outer edges of a polyon
//*****************************************************************************
void USGLRenderDevice::DrawPolygonOuterEdges(int NumVerts,PVERTEX Verts,DWORD Color)
{
	guard(USGLRenderDevice::DrawPolygonOuterEdges);

	SGLVERTEX LocalVerts[2];
	sgl_uint16 LineList[][2]={{0,1}};

	for (int i=0;i<NumVerts;i++)
	{
		if ((i+1)<NumVerts)
		{
			memcpy(&LocalVerts[0],&Verts[i],sizeof(SGLVERTEX)*2);
		}
		else
		{
			memcpy(&LocalVerts[0],&Verts[i],sizeof(SGLVERTEX));
			memcpy(&LocalVerts[1],&Verts[0],sizeof(SGLVERTEX));
		}
		LocalVerts[0].fInvW*=1.03f;
		if (LocalVerts[0].fInvW>1.0f)
			LocalVerts[0].fInvW=1.0f;
		LocalVerts[1].fInvW*=1.03f;
		if (LocalVerts[1].fInvW>1.0f)
			LocalVerts[1].fInvW=1.0f;

		LocalVerts[0].u32Colour=Color;
		LocalVerts[1].u32Colour=Color;

		sgltri_lines(&SglContext,1,LineList,LocalVerts);
	}

	unguard;
}

//*****************************************************************************
// Draws the inner edges of a polyon to show the fan.
//*****************************************************************************
void USGLRenderDevice::DrawPolygonInnerEdges(int NumVerts,PVERTEX Verts,DWORD Color)
{
	guard(USGLRenderDevice::DrawPolygonInnerEdges);

	SGLVERTEX LocalVerts[2];
	sgl_uint16 LineList[][2]={{0,1}};

	// Draw inner edges to show fan.
	for (int i=2;i<(NumVerts-1);i++)
	{
		memcpy(&LocalVerts[0],&Verts[0],sizeof(SGLVERTEX));
		memcpy(&LocalVerts[1],&Verts[i],sizeof(SGLVERTEX));

		LocalVerts[0].fInvW*=1.029f;
		if (LocalVerts[0].fInvW>1.0f)
			LocalVerts[0].fInvW=1.0f;
		LocalVerts[1].fInvW*=1.029f;
		if (LocalVerts[1].fInvW>1.0f)
			LocalVerts[1].fInvW=1.0f;

		LocalVerts[0].u32Colour=Color;
		LocalVerts[1].u32Colour=Color;

		sgltri_lines(&SglContext,1,LineList,LocalVerts);
	}

	unguard;
}
#endif
