/*---------------------------------------------------------------------
 *
 * ia3d.h
 *
 *---------------------------------------------------------------------
 *
 * $Id: ia3d.h%v 1.1 1996/09/02 10:50:35 mike Exp mike $
 *
 *---------------------------------------------------------------------
 *
 * ia3d header file.  It's the part the outside world needs to see.
 *
 *---------------------------------------------------------------------
 *
 * AUREAL SEMICONDUCTOR, INC. PROPRIETARY AND CONFIDENTIAL
 * Copyright (c) 1996 Aureal Semiconductor, Inc. - All rights 
 * reserved. 
 *
 *---------------------------------------------------------------------
 */


#ifndef _IA3D_H_
#define _IA3D_H_

#ifdef __cplusplus
extern "C" {
#endif

// A3d Class ID! {D8F1EEE0-F634-11cf-8700-00A0245D918B}
DEFINE_GUID(CLSID_A3d, 
0xd8f1eee0, 0xf634, 0x11cf, 0x87, 0x0, 0x0, 0xa0, 0x24, 0x5d, 0x91, 0x8b);

// A3d Interface ID! {D8F1EEE1-F634-11cf-8700-00A0245D918B}
DEFINE_GUID(IID_IA3d,
0xd8f1eee1, 0xf634, 0x11cf, 0x87, 0x0, 0x0, 0xa0, 0x24, 0x5d, 0x91, 0x8b);

// GUID generated from UUGENID.EXE, Good until the year 3400 AD
// A3d Interface ID! {fb80d1e0-98d3-11d1-90fb-006008a1f441}
DEFINE_GUID(IID_IA3d2,
0xfb80d1e0, 0x98d3, 0x11d1, 0x90, 0xfb, 0x00, 0x60, 0x08, 0xa1, 0xf4, 0x41);


#ifndef _IA3DAPI_H_

// Values for bOutputMode
#define OUTPUT_MODE_STEREO 0x00000001
#define OUTPUT_MODE_QUAD   0x00000002

// Values for FrontXtalkMode and bRearXtalkMode
#define OUTPUT_HEADPHONES      0x00000001
#define OUTPUT_SPEAKERS_WIDE   0x00000002
#define OUTPUT_SPEAKERS_NARROW 0x00000003

// Values for Resource Management Mode
#define A3D_RESOURCE_MODE_OFF             0x00000000
#define A3D_RESOURCE_MODE_NOTIFY          0x00000001
#define A3D_RESOURCE_MODE_DYNAMIC         0x00000002
#define A3D_RESOURCE_MODE_DYNAMIC_LOOPERS 0x00000003
#define A3D_RESOURCE_MODE_LAST            0x00000003

// A3d Source Lock modes
#define A3D_FROMWRITECURSOR 0x00000001
#define A3D_ENTIREBUFFER    0x00000002

// Version Definitions for A3DCAPS 
#define A3D_CURRENT_VERSION IA3DVERSION_RELEASE20

#define IA3DVERSION_RELEASE10 10
#define IA3DVERSION_RELEASE12 12
#define IA3DVERSION_RELEASE20 20

// A3d Caps structure for A3d2 interface
// If Fail to get IA3d2 interface, version of DLL is IA3DVERSION_PRE12

typedef  struct __A3DCAPS_SOFTWARE
{
   DWORD dwSize;        // Use for internal version control
   DWORD dwVersion;     // For Backwards capablities purposes
   DWORD dwFlags;
   DWORD dwReserved;
   DWORD dwReserved2;
}  A3DCAPS_SOFTWARE, *LPA3DCAPS_SOFTWARE;

typedef  struct __A3DCAPS_HARDWARE
{
   DWORD dwSize;        // Use for internal version control
   DWORD dwFlags;
   DWORD dwReserved;
   DWORD dwReserved2;
}  A3DCAPS_HARDWARE, *LPA3DCAPS_HARDWARE;

#endif


// Declare the IA3d Interface.  It's not very complex at all.

#undef INTERFACE
#define INTERFACE IA3d

typedef struct IA3d *LPIA3D;

DECLARE_INTERFACE_(IA3d, IUnknown)
{
	// IUnknown 
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) PURE;
	STDMETHOD_(ULONG,AddRef)(THIS) PURE;
	STDMETHOD_(ULONG,Release)(THIS) PURE;

	// IA3d
	STDMETHOD(SetOutputMode)(THIS_ DWORD dwFrontXtalkMode,
	                               DWORD dwBackXtalkMode,
	                               DWORD dwQuadMode) PURE;
	STDMETHOD(GetOutputMode)(THIS_ DWORD *lpdwFrontXtalkMode,
	                               DWORD *lpdwBackXtalkMode,
	                               DWORD *lpdwQuadMode) PURE;

	STDMETHOD(SetResourceManagerMode)(THIS_ DWORD) PURE;
	STDMETHOD(GetResourceManagerMode)(THIS_ DWORD *) PURE;

	STDMETHOD(SetHFAbsorbFactor)(THIS_ FLOAT) PURE;
	STDMETHOD(GetHFAbsorbFactor)(THIS_ FLOAT *) PURE;

};


// IA3d2 interface derived from IA3d

#undef INTERFACE
#define INTERFACE IA3d2

typedef struct IA3d2 *LPIA3D2;

DECLARE_INTERFACE_(IA3d2, IUnknown)
{
	// IUnknown 
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID *ppvObj) PURE;
	STDMETHOD_(ULONG,AddRef)(THIS) PURE;
	STDMETHOD_(ULONG,Release)(THIS) PURE;

	// IA3d
	STDMETHOD(SetOutputMode)(THIS_ DWORD dwFrontXtalkMode,
	                               DWORD dwBackXtalkMode,
	                               DWORD dwQuadMode) PURE;
	STDMETHOD(GetOutputMode)(THIS_ DWORD *lpdwFrontXtalkMode,
	                               DWORD *lpdwBackXtalkMode,
	                               DWORD *lpdwQuadMode) PURE;

	STDMETHOD(SetResourceManagerMode)(THIS_ DWORD) PURE;
	STDMETHOD(GetResourceManagerMode)(THIS_ DWORD *) PURE;

	STDMETHOD(SetHFAbsorbFactor)(THIS_ FLOAT) PURE;
	STDMETHOD(GetHFAbsorbFactor)(THIS_ FLOAT *) PURE;

	// New Methods inaddition to old ones
	STDMETHOD(RegisterVersion)(THIS_ DWORD dwVersionNr) PURE;     
	STDMETHOD(GetSoftwareCaps)(THIS_ LPA3DCAPS_SOFTWARE lpCaps) PURE;
	STDMETHOD(GetHardwareCaps)(THIS_ LPA3DCAPS_HARDWARE lpCaps) PURE;
};


// The library function that gets things going.  It returns an interface
// pointer to DirectSound.

#define A3D_OK         1 /* A3dCreate returns this upon detection of A3D Dll */
#define A3D_OK_OLD_DLL 2 /* A3dCreate returns this upon detection of A3D Dll */
                         /* but user's version is older than expected. */

// Usefull Macros for C

#if !defined(__cplusplus) || defined(CINTERFACE)
#define IA3d_QueryInterface(p,a,b)       (p)->lpVtbl->QueryInterface(p,a,b)
#define IA3d_AddRef(p)                   (p)->lpVtbl->AddRef(p)
#define IA3d_Release(p)                  (p)->lpVtbl->Release(p)
#define IA3d_SetOutputMode(p,a,b,c)      (p)->lpVtbl->SetOutputMode(p,a,b,c)
#define IA3d_GetOutputMode(p,a,b,c)      (p)->lpVtbl->GetOutputMode(p,a,b,c)
#define IA3d_SetResourceManagerMode(p,a) (p)->lpVtbl->SetResourceManagerMode(p,a)
#define IA3d_GetResourceManagerMode(p,a) (p)->lpVtbl->GetResourceManagerMode(p,a)
#define IA3d_SetHFAbsorbFactor(p,a)      (p)->lpVtbl->SetHFAbsorbFactor(p,a)
#define IA3d_GetHFAbsorbFactor(p,a)      (p)->lpVtbl->GetHFAbsorbFactor(p,a)

// C function def
#define IA3d2_QueryInterface(p,a,b)       (p)->lpVtbl->QueryInterface(p,a,b)
#define IA3d2_AddRef(p)                   (p)->lpVtbl->AddRef(p)
#define IA3d2_Release(p)                  (p)->lpVtbl->Release(p)
#define IA3d2_SetOutputMode(p,a,b,c)      (p)->lpVtbl->SetOutputMode(p,a,b,c)
#define IA3d2_GetOutputMode(p,a,b,c)      (p)->lpVtbl->GetOutputMode(p,a,b,c)
#define IA3d2_SetResourceManagerMode(p,a) (p)->lpVtbl->SetResourceManagerMode(p,a)
#define IA3d2_GetResourceManagerMode(p,a) (p)->lpVtbl->GetResourceManagerMode(p,a)
#define IA3d2_SetHFAbsorbFactor(p,a)      (p)->lpVtbl->SetHFAbsorbFactor(p,a)
#define IA3d2_GetHFAbsorbFactor(p,a)      (p)->lpVtbl->GetHFAbsorbFactor(p,a)
#define IA3d2_RegisterVersion(p,a)        (p)->lpVtbl->RegisterVersion(p,a)
#define IA3d2_GetSoftwareCaps(p,a)        (p)->lpVtbl->GetSoftwareCaps(p,a)
#define IA3d2_GetHardwareCaps(p,a)        (p)->lpVtbl->GetHardwareCaps(p,a)
	
#else                                    
#define IA3d_QueryInterface(p,a,b)       (p)->QueryInterface(a,b)
#define IA3d_AddRef(p)                   (p)->AddRef()
#define IA3d_Release(p)                  (p)->Release()
#define IA3d_SetOutputMode(p,a,b,c)      (p)->SetOutputMode(a,b,c)
#define IA3d_GetOutputMode(p,a,b,c)      (p)->GetOutputMode(a,b,c)
#define IA3d_SetResourceManagerMode(p,a) (p)->SetResourceManagerMode(a)
#define IA3d_GetResourceManagerMode(p,a) (p)->GetResourceManagerMode(a)
#define IA3d_SetHFAbsorbFactor(p,a)      (p)->SetHFAbsorbFactor(a)
#define IA3d_GetHFAbsorbFactor(p,a)      (p)->GetHFAbsorbFactor(a)

// C++ function def
#define IA3d2_QueryInterface(p,a,b)       (p)->QueryInterface(a,b)
#define IA3d2_AddRef(p)                   (p)->AddRef()
#define IA3d2_Release(p)                  (p)->Release()
#define IA3d2_SetOutputMode(p,a,b,c)      (p)->SetOutputMode(a,b,c)
#define IA3d2_GetOutputMode(p,a,b,c)      (p)->GetOutputMode(a,b,c)
#define IA3d2_SetResourceManagerMode(p,a) (p)->SetResourceManagerMode(a)
#define IA3d2_GetResourceManagerMode(p,a) (p)->GetResourceManagerMode(a)
#define IA3d2_SetHFAbsorbFactor(p,a)      (p)->SetHFAbsorbFactor(a)
#define IA3d2_GetHFAbsorbFactor(p,a)      (p)->GetHFAbsorbFactor(a)
#define IA3d2_RegisterVersion(p,a)        (p)->RegisterVersion(a)
#define IA3d2_GetSoftwareCaps(p,a)        (p)->GetSoftwareCaps(a)
#define IA3d2_GetHardwareCaps(p,a)        (p)->GetHardwareCaps(a)

#endif

// Convenience Macro A3D_REGISTER_VERSION()
// Register version for backwards compatibility
// Pass in any COM object from CLSID_A3d

#if !defined(__cplusplus) || defined(CINTERFACE)
#define A3D_UNKNOWN_QI(pU,I,ppI) (SUCCEEDED((pU)->lpVtbl->QueryInterface(pU,&I,ppI)))
#else
#define A3D_UNKNOWN_QI(pU,I,ppI) (SUCCEEDED((pU)->QueryInterface(I,ppI)))
#endif

#define A3D_REGISTER_VERSION(p)\
{\
LPIA3D2 __pIA3d2__=NULL;\
IUnknown *__pU__ = (IUnknown *)p;\
\
	if (p)\
	{\
		if (A3D_UNKNOWN_QI(__pU__,IID_IA3d2,(void **)&__pIA3d2__))\
		{\
			IA3d2_RegisterVersion(__pIA3d2__,A3D_CURRENT_VERSION);\
			IA3d2_Release(__pIA3d2__);\
		}\
	}\
\
}

// Helper functions in ia3d.lib

extern HRESULT WINAPI A3dInitialize(void);
extern void    WINAPI A3dUninitialize(void);

#ifndef _A3DDLL
extern HRESULT WINAPI A3dCreate(GUID * lpGUID, /* in, driver Guid, NULL ok    */
	                             void **ppDS,  /* out, Direct Sound pointer   */
	                             IUnknown FAR *pUnkOuter);  /* in,  Outer COM */
	                                                        /* object, for    */
	                                                        /* Aggregate only */
	                                                        /* NULL oK */
#endif // #ifndef _A3DDLL


#ifdef __cplusplus
};
#endif

#endif // _IA3D_H_
