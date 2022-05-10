/*=============================================================================
	UnGenericDlgOptions.h: Option classes for generic dialogs
	Copyright 1997-2000 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall
=============================================================================*/

#pragma once

#include "Core.h"

extern UStruct* GColorStruct;

/*------------------------------------------------------------------------------
	UOptionsProxy
------------------------------------------------------------------------------*/
class UOptionsProxy : public UObject
{
	DECLARE_ABSTRACT_CLASS(UOptionsProxy,UObject,0)

	// Constructors.
	UOptionsProxy()
	{}

	virtual void InitFields()
	{
	}
	void StaticConstructor()
	{
	}
};
IMPLEMENT_CLASS(UOptionsProxy);

/*------------------------------------------------------------------------------
	UOptionsBrushScale
------------------------------------------------------------------------------*/
class UOptionsBrushScale : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsBrushScale,UOptionsProxy,0)

	FLOAT X, Y, Z;

	UOptionsBrushScale()
	{
	}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();

		new(GetClass(),TEXT("Z"), RF_Public)UFloatProperty(CPP_PROPERTY(Z), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Y"), RF_Public)UFloatProperty(CPP_PROPERTY(Y), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("X"), RF_Public)UFloatProperty(CPP_PROPERTY(X), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		X = 1;
		Y = 1;
		Z = 1;
	}
};
IMPLEMENT_CLASS(UOptionsBrushScale);

/*------------------------------------------------------------------------------
	UOptions2DShaper
------------------------------------------------------------------------------*/
class UOptions2DShaper : public UOptionsProxy
{
	DECLARE_CLASS(UOptions2DShaper,UOptionsProxy,0)

	UEnum* AxisEnum;

    BYTE Axis;

	UOptions2DShaper()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();

		new(GetClass(),TEXT("Axis"), RF_Public)UByteProperty(CPP_PROPERTY(Axis), TEXT(""), CPF_Edit, AxisEnum );
	}

	void StaticConstructor()
	{
		AxisEnum = new( GetClass(), TEXT("Axis") )UEnum( NULL );
		new(AxisEnum->Names)FName( TEXT("AXIS_X") );
		new(AxisEnum->Names)FName( TEXT("AXIS_Y") );
		new(AxisEnum->Names)FName( TEXT("AXIS_Z") );

		Axis = AXIS_Y;
	}
};
IMPLEMENT_CLASS(UOptions2DShaper);

/*------------------------------------------------------------------------------
	UOptions2DShaperSheet
------------------------------------------------------------------------------*/
class UOptions2DShaperSheet : public UOptions2DShaper
{
	DECLARE_CLASS(UOptions2DShaperSheet,UOptions2DShaper,0)

	UOptions2DShaperSheet()
	{}

	virtual void InitFields()
	{
		UOptions2DShaper::InitFields();
	}

	void StaticConstructor()
	{
	}
};
IMPLEMENT_CLASS(UOptions2DShaperSheet);

/*------------------------------------------------------------------------------
	UOptions2DShaperExtrude
------------------------------------------------------------------------------*/
class UOptions2DShaperExtrude : public UOptions2DShaper
{
	DECLARE_CLASS(UOptions2DShaperExtrude,UOptions2DShaper,0)

	INT Depth;

	UOptions2DShaperExtrude()
	{}

	virtual void InitFields()
	{
		UOptions2DShaper::InitFields();
		new(GetClass(),TEXT("Depth"), RF_Public)UIntProperty(CPP_PROPERTY(Depth), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		Depth = 256;
	}
};
IMPLEMENT_CLASS(UOptions2DShaperExtrude);

/*------------------------------------------------------------------------------
	UOptions2DShaperExtrudeToPoint
------------------------------------------------------------------------------*/
class UOptions2DShaperExtrudeToPoint : public UOptions2DShaper
{
	DECLARE_CLASS(UOptions2DShaperExtrudeToPoint,UOptions2DShaper,0)

	INT Depth;

	UOptions2DShaperExtrudeToPoint()
	{}

	virtual void InitFields()
	{
		UOptions2DShaper::InitFields();
		new(GetClass(),TEXT("Depth"), RF_Public)UIntProperty(CPP_PROPERTY(Depth), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		Depth = 256;
	}
};
IMPLEMENT_CLASS(UOptions2DShaperExtrudeToPoint);

/*------------------------------------------------------------------------------
	UOptions2DShaperExtrudeToBevel
------------------------------------------------------------------------------*/
class UOptions2DShaperExtrudeToBevel : public UOptions2DShaper
{
	DECLARE_CLASS(UOptions2DShaperExtrudeToBevel,UOptions2DShaper,0)

	INT Height, CapHeight;

	UOptions2DShaperExtrudeToBevel()
	{}

	virtual void InitFields()
	{
		UOptions2DShaper::InitFields();
		new(GetClass(),TEXT("Height"), RF_Public)UIntProperty(CPP_PROPERTY(Height), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("CapHeight"), RF_Public)UIntProperty(CPP_PROPERTY(CapHeight), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		Height = 128;
		CapHeight = 32;
	}
};
IMPLEMENT_CLASS(UOptions2DShaperExtrudeToBevel);

/*------------------------------------------------------------------------------
	UOptions2DShaperRevolve
------------------------------------------------------------------------------*/
class UOptions2DShaperRevolve : public UOptions2DShaper
{
	DECLARE_CLASS(UOptions2DShaperRevolve,UOptions2DShaper,0)

	INT SidesPer360, Sides;

	UOptions2DShaperRevolve()
	{}

	virtual void InitFields()
	{
		UOptions2DShaper::InitFields();
		new(GetClass(),TEXT("SidesPer360"), RF_Public)UIntProperty(CPP_PROPERTY(SidesPer360), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Sides"), RF_Public)UIntProperty(CPP_PROPERTY(Sides), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		SidesPer360 = 12;
		Sides = 3;
	}
};
IMPLEMENT_CLASS(UOptions2DShaperRevolve);

/*------------------------------------------------------------------------------
	UOptions2DShaperBezierDetail
------------------------------------------------------------------------------*/
class UOptions2DShaperBezierDetail : public UOptionsProxy
{
	DECLARE_CLASS(UOptions2DShaperBezierDetail,UOptionsProxy,0)

	INT DetailLevel;

	UOptions2DShaperBezierDetail()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();
		new(GetClass(),TEXT("DetailLevel"), RF_Public)UIntProperty(CPP_PROPERTY(DetailLevel), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		DetailLevel = 10;
	}
};
IMPLEMENT_CLASS(UOptions2DShaperBezierDetail);

/*------------------------------------------------------------------------------
	UOptionsSurfBevel
------------------------------------------------------------------------------*/
class UOptionsSurfBevel : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsSurfBevel,UOptionsProxy,0)

	INT Depth, Bevel;

	UOptionsSurfBevel()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();
		new(GetClass(),TEXT("Depth"), RF_Public)UIntProperty(CPP_PROPERTY(Depth), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Bevel"), RF_Public)UIntProperty(CPP_PROPERTY(Bevel), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		Depth = 16;
		Bevel = 16;
	}
};
IMPLEMENT_CLASS(UOptionsSurfBevel);

/*------------------------------------------------------------------------------
	UOptionsTexAlign
------------------------------------------------------------------------------*/
class UOptionsTexAlign : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsTexAlign,UOptionsProxy,0)

	UEnum* TAxisEnum;

    BYTE TAxis;

	UOptionsTexAlign()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();
	}

	void StaticConstructor()
	{
		TAxisEnum = new( GetClass(), TEXT("TAxis") )UEnum( NULL );
		new(TAxisEnum->Names)FName( TEXT("TAXIS_X") );
		new(TAxisEnum->Names)FName( TEXT("TAXIS_Y") );
		new(TAxisEnum->Names)FName( TEXT("TAXIS_Z") );
		new(TAxisEnum->Names)FName( TEXT("TAXIS_WALLS") );
		new(TAxisEnum->Names)FName( TEXT("TAXIS_AUTO") );

		TAxis = TAXIS_AUTO;
	}
};
IMPLEMENT_CLASS(UOptionsTexAlign);

/*------------------------------------------------------------------------------
	UOptionsTexAlignPlanar
------------------------------------------------------------------------------*/
class UOptionsTexAlignPlanar : public UOptionsTexAlign
{
	DECLARE_CLASS(UOptionsTexAlignPlanar,UOptionsTexAlign,0)

	UOptionsTexAlignPlanar()
	{}

	virtual void InitFields()
	{
		UOptionsTexAlign::InitFields();
		new(GetClass(),TEXT("TAxis"), RF_Public)UByteProperty(CPP_PROPERTY(TAxis), TEXT(""), CPF_Edit, TAxisEnum );
	}

	void StaticConstructor()
	{
	}
};
IMPLEMENT_CLASS(UOptionsTexAlignPlanar);

/*------------------------------------------------------------------------------
	UOptionsTexAlignCylinder
------------------------------------------------------------------------------*/
class UOptionsTexAlignCylinder : public UOptionsTexAlign
{
	DECLARE_CLASS(UOptionsTexAlignCylinder,UOptionsTexAlign,0)

	INT UTile, VTile;

	UOptionsTexAlignCylinder()
	{}

	virtual void InitFields()
	{
		UOptionsTexAlign::InitFields();
		new(GetClass(),TEXT("VTile"), RF_Public)UIntProperty(CPP_PROPERTY(VTile), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("UTile"), RF_Public)UIntProperty(CPP_PROPERTY(UTile), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		UTile = VTile = 1;
	}
};
IMPLEMENT_CLASS(UOptionsTexAlignCylinder);

/*------------------------------------------------------------------------------
	UOptionsNewTerrainLayer
------------------------------------------------------------------------------*/
class UOptionsNewTerrainLayer : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsNewTerrainLayer,UOptionsProxy,0)

	FString Package, Group, Name;
	INT AlphaWidth, AlphaHeight;
	FColor AlphaFill, ColorFill;
	INT UScale, VScale;

	UOptionsNewTerrainLayer()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();
		new(GetClass(),TEXT("VScale"), RF_Public)UIntProperty(CPP_PROPERTY(VScale), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("UScale"), RF_Public)UIntProperty(CPP_PROPERTY(UScale), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("ColorFill"), RF_Public)UStructProperty(CPP_PROPERTY(ColorFill), TEXT(""), CPF_Edit, GColorStruct );
		new(GetClass(),TEXT("AlphaFill"), RF_Public)UStructProperty(CPP_PROPERTY(AlphaFill), TEXT(""), CPF_Edit, GColorStruct );
		new(GetClass(),TEXT("AlphaWidth"), RF_Public)UIntProperty(CPP_PROPERTY(AlphaWidth), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("AlphaHeight"), RF_Public)UIntProperty(CPP_PROPERTY(AlphaHeight), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Name"), RF_Public)UStrProperty(CPP_PROPERTY(Name), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Group"), RF_Public)UStrProperty(CPP_PROPERTY(Group), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Package"), RF_Public)UStrProperty(CPP_PROPERTY(Package), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		AlphaWidth = 256;
		AlphaHeight = 256;
		UScale = 1;
		VScale = 1;
		Package = TEXT("MyLevel");
		Name = TEXT("Layer");
		ColorFill = FColor(127,127,127,0);
	}
};
IMPLEMENT_CLASS(UOptionsNewTerrainLayer);

/*------------------------------------------------------------------------------
	UOptionsNewTerrainDecoLayer
------------------------------------------------------------------------------*/
class UOptionsNewTerrainDecoLayer : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsNewTerrainDecoLayer,UOptionsProxy,0)

	FString Package, Group, Name;
	INT AlphaWidth, AlphaHeight;
	FColor AlphaFill;

	UOptionsNewTerrainDecoLayer()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();
		new(GetClass(),TEXT("AlphaFill"), RF_Public)UStructProperty(CPP_PROPERTY(AlphaFill), TEXT(""), CPF_Edit, GColorStruct );
		new(GetClass(),TEXT("AlphaWidth"), RF_Public)UIntProperty(CPP_PROPERTY(AlphaWidth), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("AlphaHeight"), RF_Public)UIntProperty(CPP_PROPERTY(AlphaHeight), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Name"), RF_Public)UStrProperty(CPP_PROPERTY(Name), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Group"), RF_Public)UStrProperty(CPP_PROPERTY(Group), TEXT(""), CPF_Edit );
		new(GetClass(),TEXT("Package"), RF_Public)UStrProperty(CPP_PROPERTY(Package), TEXT(""), CPF_Edit );
	}

	void StaticConstructor()
	{
		AlphaWidth = 256;
		AlphaHeight = 256;
		Package = TEXT("MyLevel");
		Name = TEXT("DecoLayer");
	}
};
IMPLEMENT_CLASS(UOptionsNewTerrainDecoLayer);

/*------------------------------------------------------------------------------
	UOptionsMapScale
------------------------------------------------------------------------------*/
class UOptionsMapScale : public UOptionsProxy
{
	DECLARE_CLASS(UOptionsMapScale,UOptionsProxy,0)

	FLOAT Factor;
	BITFIELD bAdjustLights, bScaleSprites, bScaleLocations, bScaleCollision;

	UOptionsMapScale()
	{}

	virtual void InitFields()
	{
		UOptionsProxy::InitFields();

		new(GetClass(),TEXT("Scale Collision?"),RF_Public)UBoolProperty (CPP_PROPERTY(bScaleCollision),TEXT(""),CPF_Edit );
		new(GetClass(),TEXT("Scale Locations?"),RF_Public)UBoolProperty (CPP_PROPERTY(bScaleLocations),TEXT(""),CPF_Edit );
		new(GetClass(),TEXT("Scale Sprites?"),RF_Public)UBoolProperty (CPP_PROPERTY(bScaleSprites),TEXT(""),CPF_Edit );
		new(GetClass(),TEXT("Adjust Lights?"),RF_Public)UBoolProperty (CPP_PROPERTY(bAdjustLights),TEXT(""),CPF_Edit );
		new(GetClass(),TEXT("Factor"), RF_Public)UFloatProperty(CPP_PROPERTY(Factor),TEXT(""),CPF_Edit );
	}

	void StaticConstructor()
	{
		Factor = 1.0f;
		bAdjustLights = 1;
		bScaleSprites = 0;
		bScaleLocations = 1;
		bScaleCollision = 1;
	}
};
IMPLEMENT_CLASS(UOptionsMapScale);

/*----------------------------------------------------------------------------
	The End.
----------------------------------------------------------------------------*/