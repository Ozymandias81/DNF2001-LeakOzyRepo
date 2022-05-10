/*=============================================================================
	UnObj.cpp: Utility functions related to object definitions in UnObj.h
	Copyright 2001-2002 3D Realms, Inc. All Rights Reserved.

	Revision history:
		* Created by Nick Shaffner
=============================================================================*/

#include "EnginePrivate.h"

// Tables for associating a poly flag's name with it's value, and vice versa:
#define REGISTER_POLYFLAG(NAME) { NAME, _T( #NAME ) }

struct PolyflagNameLookup
{
	DWORD Value; // The flag's value
	TCHAR *Name; // It's associated name
};

static PolyflagNameLookup PolyFlagNames[] =
{
	// Individual PolyFlags:
	REGISTER_POLYFLAG(PF_Invisible),
	REGISTER_POLYFLAG(PF_Masked),			
	REGISTER_POLYFLAG(PF_Translucent),	 	
	REGISTER_POLYFLAG(PF_NotSolid),			
	REGISTER_POLYFLAG(PF_Environment),   	
	REGISTER_POLYFLAG(PF_ForceViewZone),	
	REGISTER_POLYFLAG(PF_Semisolid),	  	
	REGISTER_POLYFLAG(PF_Modulated), 		
	REGISTER_POLYFLAG(PF_FakeBackdrop),		
	REGISTER_POLYFLAG(PF_TwoSided),			
	REGISTER_POLYFLAG(PF_AutoUPan),		 	
	REGISTER_POLYFLAG(PF_AutoVPan), 		
	REGISTER_POLYFLAG(PF_NoSmooth),			
	REGISTER_POLYFLAG(PF_SmallWavy),		
	REGISTER_POLYFLAG(PF_MeshUVClamp),		
	REGISTER_POLYFLAG(PF_Flat),				
	REGISTER_POLYFLAG(PF_LowShadowDetail),	
	REGISTER_POLYFLAG(PF_NoMerge),			
	REGISTER_POLYFLAG(PF_ExtendedSurface),	
	REGISTER_POLYFLAG(PF_ExtendedPoly),		
	REGISTER_POLYFLAG(PF_BrightCorners),	
	REGISTER_POLYFLAG(PF_SpecialLit),		
	REGISTER_POLYFLAG(PF_NoBoundRejection), 
	REGISTER_POLYFLAG(PF_Unlit),			
	REGISTER_POLYFLAG(PF_HighShadowDetail),	
	REGISTER_POLYFLAG(PF_Portal),			
	REGISTER_POLYFLAG(PF_Mirrored),			
	REGISTER_POLYFLAG(PF_Memorized ),    	
	REGISTER_POLYFLAG(PF_Selected),      	
	REGISTER_POLYFLAG(PF_Highlighted),      
	REGISTER_POLYFLAG(PF_FlatShaded),		
	REGISTER_POLYFLAG(PF_EdProcessed), 		
	REGISTER_POLYFLAG(PF_EdCut),       		
	REGISTER_POLYFLAG(PF_RenderFog),		
	REGISTER_POLYFLAG(PF_Occlude),			
	REGISTER_POLYFLAG(PF_RenderHint),       
	REGISTER_POLYFLAG(PF_NoOcclude),		
	REGISTER_POLYFLAG(PF_NoEdit),			
	REGISTER_POLYFLAG(PF_NoImport),			
	REGISTER_POLYFLAG(PF_AddLast),			
	REGISTER_POLYFLAG(PF_NoAddToBSP),		
	REGISTER_POLYFLAG(PF_NoShadows),		
	REGISTER_POLYFLAG(PF_Transient),

	// Composite polyflags:
	REGISTER_POLYFLAG(PF_NoOcclude),	
	REGISTER_POLYFLAG(PF_NoEdit),		
	REGISTER_POLYFLAG(PF_NoImport),		
	REGISTER_POLYFLAG(PF_AddLast),		
	REGISTER_POLYFLAG(PF_NoAddToBSP),	
	REGISTER_POLYFLAG(PF_NoShadows),	
	REGISTER_POLYFLAG(PF_Transient),	
   	REGISTER_POLYFLAG(PF_All)
};

static PolyflagNameLookup PolyFlagNamesEx[] =
{
	// Individual PolyFlagsEx:
	REGISTER_POLYFLAG(PFX_AlphaMap),
	REGISTER_POLYFLAG(PFX_Clip),
	REGISTER_POLYFLAG(PFX_DepthFog),
	REGISTER_POLYFLAG(PFX_FlatShade),
	REGISTER_POLYFLAG(PFX_LightenModulate),
	REGISTER_POLYFLAG(PFX_DarkenModulate),
	REGISTER_POLYFLAG(PFX_Translucent2),
	REGISTER_POLYFLAG(PFX_MirrorHorizontal),
	REGISTER_POLYFLAG(PFX_MirrorVertical),

	// Composite polyflags:
	REGISTER_POLYFLAG(PFX_NoOcclude),
	REGISTER_POLYFLAG(PFX_All)
};

#undef REGISTER_POLYFLAG

FString ENGINE_API GetPolyFlagsString(DWORD PolyFlags, DWORD PolyFlagsEx)
{
	FString ReturnValue;
	bool AtLeastOne=false;

	// Accumulate the active poly flags:
	for(int i=0;i<ARRAY_COUNT(PolyFlagNames);i++)
		if((PolyFlags&PolyFlagNames[i].Value)==PolyFlagNames[i].Value)
		{
			if(AtLeastOne) ReturnValue+=_T(", ");
			AtLeastOne=true;
			ReturnValue+=FString(PolyFlagNames[i].Name);
		}

	// Accumulate the active extended poly flags:
	for(i=0;i<ARRAY_COUNT(PolyFlagNamesEx);i++)
		if((PolyFlagsEx&PolyFlagNamesEx[i].Value)==PolyFlagNamesEx[i].Value)
		{
			if(AtLeastOne) ReturnValue+=_T(", ");
			AtLeastOne=true;
			ReturnValue+=FString(PolyFlagNamesEx[i].Name);
		}
	return ReturnValue;
}




