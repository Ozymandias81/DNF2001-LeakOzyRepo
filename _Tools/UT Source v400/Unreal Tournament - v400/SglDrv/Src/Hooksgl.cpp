/*=============================================================================
	HookSGL.cpp: Source file for dynamically linking SGL.LIB

	Copyright 1997 NEC Electronics Inc.
	Based on code Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Jayeson Lee-Steere from code by Tim Sweeney
		* 970112 JLS - Started changes to use new hardware interface.

=============================================================================*/
// Precompiled header.
#pragma warning( disable:4201 )
#include <windows.h>
#include "Engine.h"
#include "UnRender.h"

#include "hooksgl.h"

//*****************************************************************************
// Find an entry point into SGL.DLL.
//*****************************************************************************
FARPROC USGL::Find(char *Name)
{
	guard(USGL::Find);

	FARPROC Result = GetProcAddress(hModule,Name);
	
	if (Result==NULL)
	{
		Ok = 0;
		appErrorf(TEXT("SGL can't find function: %s"),Name);
		return NULL;
	}
	else
	{
		return Result;
	}
	unguard;
}

//*****************************************************************************
// Try to import all SGL Direct functions from SGL.DLL.
// Returns 1 if success, 0 if failure.
//*****************************************************************************
int USGL::HookSGL()
{
	guard(USGL::HookSGL);

	// See if we have already associated, and if so, don't bother doing it again.
	if (hModule)
		return Ok;

	// Load library.
	hModule = LoadLibrary(TEXT("SGL.DLL"));
	if (!hModule)
		return 0;
	debugf( NAME_Init, TEXT("Found PowerVR SGL.DLL") );
	Ok = 1;

#define SGL_GET(FuncName) *(FARPROC *)&FuncName = Find(#FuncName);
#if WIN32
	SGL_GET(sgl_get_win_versions);
	SGL_GET(sgl_use_ddraw_mode);
	SGL_GET(sgl_use_address_mode);
	SGL_GET(sgl_use_eor_callback);
#endif
	// Device routines
	SGL_GET(sgl_get_errors);
	SGL_GET(sgl_create_screen_device);
	SGL_GET(sgl_get_device);
	SGL_GET(sgl_delete_device);
	// Texture routines
	SGL_GET(sgl_create_texture);
	SGL_GET(sgl_preprocess_texture);
	SGL_GET(sgl_texture_size);
	SGL_GET(sgl_set_texture);
	SGL_GET(sgl_direct_set_texture);
//	SGL_GET(sgl_set_texture_extended);
	SGL_GET(sgl_delete_texture);
	SGL_GET(sgl_get_free_texture_mem);
//	SGL_GET(sgl_get_free_texture_mem_info);
	// Random number generator.
	SGL_GET(sgl_rand);
	SGL_GET(sgl_srand);
	// Version information.
	SGL_GET(sgl_get_versions);
	// Windows texture extensions
	SGL_GET(ConvertBMPtoSGL);
	SGL_GET(LoadBMPTexture);
	SGL_GET(FreeBMPTexture);
	SGL_GET(FreeAllBMPTextures);
	// sgltri_ functions
	SGL_GET(sgltri_startofframe);
	SGL_GET(sgltri_triangles);
	SGL_GET(sgltri_quads);
	SGL_GET(sgltri_points);
	SGL_GET(sgltri_lines);
	SGL_GET(sgltri_shadow);
	SGL_GET(sgltri_render);
	SGL_GET(sgltri_rerender);
	SGL_GET(sgltri_isrendercomplete);
	// .INI files/registry reading routines.
	SGL_GET(sgl_get_ini_string);
	SGL_GET(sgl_get_ini_int);
#undef SGL_GET

	return Ok;
	unguard;
}

//*****************************************************************************
// Unloads SGL library.
//*****************************************************************************
void USGL::UnhookSGL()
{
	guard(USGL::UnhookSGL);

	if (hModule)
	{
		FreeLibrary(hModule);
		hModule=NULL;
	}

	unguard;
}

//*****************************************************************************
// Returns a string for a SGL error.
//*****************************************************************************
char *USGL::GetSGLErrorString(int ErrorValue)
{
	guard(USGL::GetSGLErrorString);

	switch (ErrorValue)
	{
		case sgl_no_err:
			return "sgl_no_err";
		case sgl_err_no_mem:
			return "sgl_err_no_mem";
		case sgl_err_no_name:
			return "sgl_err_no_name";
		case sgl_err_bad_name:
			return "sgl_err_bad_name";
		case sgl_err_bad_parameter:
			return "sgl_err_bad_parameter";
		case sgl_err_cyclic_reference:
			return "sgl_err_cyclic_reference";
		case sgl_err_list_too_deep:
			return "sgl_err_list_too_deep";
		case sgl_err_too_many_planes:
			return "sgl_err_too_many_planes";
		case sgl_err_no_convex:
			return "sgl_err_no_convex";
		case sgl_err_no_mesh:
			return "sgl_err_no_mesh";
		case sgl_err_bad_index:
			return "sgl_err_bad_index";
		case sgl_err_failed_init:
			return "sgl_err_failed_init";
		case sgl_err_bad_device:
			return "sgl_err_bad_device";
		case sgl_err_texture_memory_full:
			return "sgl_err_texture_memory_full";
		case sgl_err_colinear_plane_points:
			return "sgl_err_colinear_plane_points";
		case sgl_err_no_board_found:
			return "sgl_err_no_board_found";
		case sgl_err_no_library_found:
			return "sgl_err_no_library_found";
		case sgl_warn_colinear_face_points:
			return "sgl_warn_colinear_face_points";
		case sgl_warn_colinear_uvs:
			return "sgl_warn_colinear_uvs";
		case sgl_warn_large_uvs:
			return "sgl_warn_large_uvs";
		case sgl_warn_noncoplanar_quad:
			return "sgl_warn_noncoplanar_quad";
		default:
			return "Unknown";
	}

	unguard;
}