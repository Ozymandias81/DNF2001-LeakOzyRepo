/*=========================================================================================
	A3d_Unreal.cpp: Source file for A3D geometry additions to Unreal and Unreal Tournament
	Created for Aureal Semiconductor, Inc. by Scott T. Etherton and Micah Mason
==========================================================================================*/

#include <windows.h>
#include <mmsystem.h>
#include <assert.h>
#include "A3D.h"
#include "galaxy.h"
#ifdef _DEBUG
#include "stdio.h"
#endif

#ifdef _DEBUG
#if !defined(UNICODE)
#ifdef WCHAR
#undef WCHAR
#endif
#define WCHAR TCHAR
#endif
#endif



#define MAX_LEAVES	1500
#define TRUE      1
#define FALSE     0

#define HIGH_DETAIL_NODES 10

static A3D_GeomStatus  gGeomStatus =
{
  TRUE,     // Just initialized.
  400.0,    // Game units per meter
  720000,   // Maximum range of nodes to render (fMaxNodeDist)
  500,		  // Number of polygons to render
  100,      // Number of reflection polygons to render.
  8.5f,     // Reflection delay
  0.9f,     // Reflection Gain
  0.20f,    // Transmittance of default material (occfactor)
  60000,    // Leaf Transition Distance
  TRUE,     // Enable occlusion
  TRUE,     // Enable reflection

  // value = 2*(triangle square area) in game units
  1.0e6f,// * 400.0f,   // Small polygon size
  1.0e7f,// * 400.0f,  // Large polygon size

  // square tan of the angle of the poly.
  // tan squared(5.f*DEG2RAD)
  0.00765f, // Angle too small - throws out very narrow polygons
  1.2e9,   // fPolyReflectSize
  FALSE     // Disable materials.
};

static LPA3D3			    	gA3d;
static LPA3DLISTENER		gA3dListener;
static LPA3DGEOM		  	gA3dGeom;

static LPA3DMATERIAL		gDefMaterial;
static UBOOL			    	gbWaveTracing;
static UBOOL	    			gbA3D;
static A3DVAL    				gGain;

static float            a3dEqTypes[A3D_EQ_TYPE_MAX] =
{
	1.0f,	//	A3D_EQ_TYPE_DEFAULT
	0.1f	//	A3D_EQ_TYPE_WATER
};


struct A3DNodeInfo
{
  FBspNode*     pNode;
  IA3dList*     pList;
  FVector       vCenter;
  int           iNumPolys;
};

// Information about the current scene.
FSceneNode*             gpFrame;
FBspNode*               gNodes;
FVector*                gOrigin;

A3DNodeInfo             gNodeInfo[MAX_LEAVES];
int 	  		          	gTag;                     // Last polygon which was tagged.
DWORD	  		          	gPolyCount;
long	  		          	gNumLeaves;
long	  		          	gNumLeavesRendered;
DWORD	  		          	gNumReflect;
        

#ifdef _DEBUG
  long			          	gRejectedSize;
  long			          	gRejectedAngle;
  long			          	gRejectedLeaves;
  static int	        	gDebug_CacheHits;
  static int	        	gDebug_CacheMisses;
#endif

  
// Underwater variables.
A3D_EQ_TYPE		        	gEqType;
BOOL				            gWaterZone;

BOOL IsReflectionPoly (float fArea, A3D_GeomStatus *pGeomStatus);
BOOL IsTooSmall(FVector *v0, FVector *v1, FVector *v2, A3D_GeomStatus *pGeomStatus, float *pfArea);
BOOL CheckColinear(FVector *v0, FVector *v1, FVector *v2);
void RenderSortedNodes(IA3dGeom *pGeom, UModel *pCurModel, A3D_GeomStatus *pGeomStatus);
void SortAudioNodes(void);
static int CompareLeafDist(const void *e1, const void *e2);
BOOL IsNodeTransition(UModel *pCurModel, A3D_GeomStatus *pGeomStatus);

void A3D_UnrealRenderGeometry(FSceneNode *Frame);
void A3D_ComputeTransformMatrix (FCoords *Coords, float *matrix);
void A3D_RefreshGeometry(void);


// Cache-related functions.
BOOL Cache_Lookup(FBspNode *pNode, IA3dList** ppList, int *pNumPolys);
BOOL Cache_Store (FBspNode *pNode, IA3dList* pList, int numPolys);

BOOL Cache_Remove(FBspNode *pNode);
BOOL Cache_Update(void);
void Cache_Clear(void);


// =============================================================
// A3D_Update ()		Called once per frame to update the 
//                  the position matrix and the listener.
//
// =============================================================
void A3D_Update (FCoords &Coords)
{
  guard(A3D_Update);

  if (gA3dGeom && gA3d)
  {
    FCoords inverse = Coords;//.Inverse();
    float matrix[16];
    
    A3D_ComputeTransformMatrix (&Coords, matrix);

    // Rotate all sources and the listener into the world.
    gA3dGeom->LoadMatrix (matrix); // Rotation.

    // Bindlistener to the current matrix.
    gA3dGeom->BindListener();
  }
  unguard;
}


// =============================================================
// A3D_Update ()		Called once per frame to update the 
//                  the position matrix and the listener.
//
// =============================================================
void A3D_UpdateSource (IA3dSource *pSrc, BOOL JustStarted, BOOL Transform)
{
  guard(A3D_UpdateSource);

	if (pSrc)
	{
		if (gWaterZone)
		{
			pSrc->SetEq(a3dEqTypes[A3D_EQ_TYPE_WATER]);
		}
		else
			pSrc->SetEq(a3dEqTypes[A3D_EQ_TYPE_DEFAULT]);

		if (JustStarted)
		{
			pSrc->SetMinMaxDistance(2.0f, 5000.0f, A3D_AUDIBLE);
			pSrc->SetDistanceModelScale(7.0f);
		}

		// MM - leave sources spatialized in the world.  When menu is enabled, don't do this.
		if (Transform)
			if (gA3dGeom)
				gA3dGeom->BindSource(pSrc);
	}
  unguard;
}

// =============================================================
// RenderAudioGeometry()		
//
//   Called by the game engine to actually render all geometry.
// =============================================================
void A3D_RenderAudioGeometry(FSceneNode *Frame)
{
	guard(RenderAudioGeometry);

  if (gbWaveTracing)
  {
    glxLock();
  
    A3D_UnrealRenderGeometry(Frame);

    glxUnlock();
  }
  unguard;
}


// =============================================================
// A3D_ComputeTransformMatrix ()		
//
//   Computes a transform matrix given an FCoords struct.
// =============================================================
void A3D_ComputeTransformMatrix (FCoords *Coords, float *matrix)
{
   FVector dir(Coords->ZAxis);
   FVector up(Coords->YAxis);
   FVector norm;
   FVector translate = Coords->Origin / gGeomStatus.fUnitsPerMeter;

   // Calc the norm vector. 
   norm = dir ^ up;	 // LEFT hand rule

   matrix[0] = norm.X;
   matrix[1] = norm.Y;
   matrix[2] = norm.Z;
   matrix[3] = 0.f;

   matrix[4] = -up.X;
   matrix[5] = -up.Y;
   matrix[6] = -up.Z;
   matrix[7] = 0.f;

   matrix[8] = dir.X;
   matrix[9] = dir.Y;
   matrix[10]= dir.Z;
   matrix[11]= 0.f;

   matrix[12]= translate.X;
   matrix[13]= translate.Y;
   matrix[14]= translate.Z;
   matrix[15]= 1.f;
}


// =============================================================
// A3D_Exec ()		Handles A3D console cmds
//
// =============================================================
#define A3D_VARS_NO_HARDWARE       -2
#define A3D_VARS_NO_WAVETRACING    -1
#define A3D_VARS_OK                 1

UBOOL A3D_CheckCommandVars (FOutputDevice& Ar, UBOOL Use3dHardware)
{
  if (!Use3dHardware)
  {
    Ar.Logf( TEXT("A3D 2.0 vars cannot be changed unless Use3dHardware is enabled.") );
    return (A3D_VARS_NO_HARDWARE);
  }
  if (!gbWaveTracing)
  {
    Ar.Logf( TEXT("A3D 2.0 WaveTracing is currently DISABLED") );
	  return (A3D_VARS_NO_WAVETRACING);
  }

  return (A3D_VARS_OK);
}

UBOOL A3D_Exec( const TCHAR* Cmd, FOutputDevice& Ar, UBOOL Use3dHardware)
{
	guard(A3D_Exec);

  if( ParseCommand( &Cmd, TEXT("s_occfactor") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT hr;
      FLOAT f = appAtof(Cmd);

	    hr = gDefMaterial->SetTransmittance(f, .75f);

	    // Bind material
	    gA3dGeom->BindMaterial(gDefMaterial);

      if (hr < 0)
      {
        Ar.Logf( TEXT("A3D 2.0 occlusion factor could not be set to %f") , f);
        return 1;
      }
		  gGeomStatus.fTransmittance = f;
    }

    Ar.Logf( TEXT("A3D 2.0 occlusion factor: %f") , gGeomStatus.fTransmittance);

    return 1;
  }
  else
  if ( ParseCommand( &Cmd, TEXT("s_maxnodedist") ) )
  {
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT i = appAtoi(Cmd);

      if (i > 0)
      {
  		  gGeomStatus.fMaxNodeDist = i;
        A3D_RefreshGeometry();
      }
      else
        Ar.Logf( TEXT ("Error: bad value for s_maxleafdist.  Must be great then 0.") );

    }
    else
      Ar.Logf( TEXT("%i"), gGeomStatus.fMaxNodeDist );

    return 1;	
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_reflect") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT hr;
      INT i = appAtoi(Cmd);

      if (i != 0)
      {
  		  hr = gA3dGeom->Enable(A3D_1ST_REFLECTIONS);
        if (hr < 0)
        {
          Ar.Logf( TEXT("A3D 2.0 reflections could NOT be enabled.") );
		      gGeomStatus.bEnableReflection = 0;
          return 1;
        }
      }
      else
        hr = gA3dGeom->Disable(A3D_1ST_REFLECTIONS);

      gGeomStatus.bEnableReflection = (i != 0);
      A3D_RefreshGeometry();
    }

    if (gGeomStatus.bEnableReflection)
      Ar.Logf( TEXT("A3D 2.0 reflections: ENABLED") );
    else
      Ar.Logf( TEXT("A3D 2.0 reflections: DISABLED") );

    return 1;
	}
  else
  if( ParseCommand( &Cmd, TEXT("s_occlude") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT hr;
      INT i = appAtoi(Cmd);

      if (i != 0)
      {
  		  hr = gA3dGeom->Enable(A3D_OCCLUSIONS);
        if (hr < 0)
        {
          Ar.Logf( TEXT("A3D 2.0 occlusions could NOT be enabled.") );
		      gGeomStatus.bEnableOcclusion = 0;
          return 1;
        }
      }
      else
        gA3dGeom->Disable(A3D_OCCLUSIONS);

      gGeomStatus.bEnableOcclusion = (i != 0);
	  A3D_RefreshGeometry();
    }

    if (gGeomStatus.bEnableOcclusion)
      Ar.Logf( TEXT("A3D 2.0 occlusions: ENABLED") );
    else
      Ar.Logf( TEXT("A3D 2.0 occlusions: DISABLED") );

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_wavetracing") ) )
	{
    if (A3D_VARS_NO_HARDWARE == A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    INT hr;
    if (appStrlen (Cmd) != 0)
    {
      INT i = appAtoi(Cmd);
		  gbWaveTracing = (i != 0);
    }

    if (gbWaveTracing)
    {
      if (gGeomStatus.bEnableReflection)
        hr = gA3dGeom->Enable(A3D_1ST_REFLECTIONS);
      if (gGeomStatus.bEnableOcclusion)
        hr = gA3dGeom->Enable(A3D_OCCLUSIONS);
      
      Ar.Logf( TEXT("A3D 2.0 Wavetracing: ENABLED") );
    }
    else
    {
      hr = gA3dGeom->Disable(A3D_1ST_REFLECTIONS);
      hr = gA3dGeom->Disable(A3D_OCCLUSIONS);
      gA3d->Clear();
      gA3d->Flush();
      Ar.Logf( TEXT("A3D 2.0 Wavetracing: DISABLED") );
    }
    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_refgain") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT hr;
      FLOAT f = appAtof(Cmd);

    	hr = gA3dGeom->SetReflectionGainScale(f);
      if (hr < 0)
      {
        Ar.Logf( TEXT("A3D 2.0 reflection gain could not be set to %f") , f);
        return 1;
      }
		  gGeomStatus.fRefGain = f;
    }

    Ar.Logf( TEXT("A3D 2.0 reflection gain: %f") , gGeomStatus.fRefGain);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_refdelay") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT hr;
      FLOAT f = appAtof(Cmd);

      hr = gA3dGeom->SetReflectionDelayScale(f);
      if (hr < 0)
      {
        Ar.Logf( TEXT("A3D 2.0 reflection delay could not be set to %f") , f);
        return 1;
      }
      gGeomStatus.fRefDelay = f;
    }

    Ar.Logf( TEXT("A3D 2.0 reflection delay: %f") , gGeomStatus.fRefDelay);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_maxpoly") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT i = appAtoi(Cmd);
		  gGeomStatus.dwMaxPoly = i;

      // We may need to grow or shrink our poly collection.
      A3D_RefreshGeometry();
    }

    Ar.Logf( TEXT("A3D 2.0 maximum number of polygons: %i") , gGeomStatus.dwMaxPoly);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_maxreflectpoly") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT i = appAtoi(Cmd);
		  gGeomStatus.dwMaxReflect = i;

      // Have to re-grab all polys because the number of reflective polys has changed.
      A3D_RefreshGeometry();
    }

    Ar.Logf( TEXT("A3D 2.0 maximum number of reflection polygons: %i") , gGeomStatus.dwMaxReflect);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_polysmall") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      FLOAT f = appAtof(Cmd);
		  gGeomStatus.fPolyTooSmall = f;

      // Need to update our poly collection.
      A3D_RefreshGeometry();
    }

    Ar.Logf( TEXT("A3D 2.0 smallest polygon size: %f") , gGeomStatus.fPolyTooSmall);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_polylarge") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      FLOAT f = appAtof(Cmd);
		  gGeomStatus.fPolyAlwaysKeep = f;

      // Need to update our poly collection.
      A3D_RefreshGeometry();
    }

    Ar.Logf( TEXT("A3D 2.0 large polygon size: %f") , gGeomStatus.fPolyAlwaysKeep);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_polyreflect") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      FLOAT f = appAtof(Cmd);
		  gGeomStatus.fPolyReflectSize = f;

      // Need to update our poly collection.
      A3D_RefreshGeometry();
    }

    Ar.Logf( TEXT("A3D 2.0 reflection polygon size: %f") , gGeomStatus.fPolyReflectSize);

    return 1;
  }
  else
  if( ParseCommand( &Cmd, TEXT("s_a3dsources") ) )
	{
    if (A3D_VARS_OK != A3D_CheckCommandVars (Ar, Use3dHardware) )
      return 1;

    if (appStrlen (Cmd) != 0)
    {
      INT i = appAtoi(Cmd);
		  gbA3D = (i != 0);
    }

    if (gbA3D)
    {
      gA3d->SetOutputGain(gGain);
      Ar.Logf( TEXT("A3D 2.0 Sources: ENABLED") );
    }
    else
    {
      gA3d->SetOutputGain(0.0f);
      Ar.Logf( TEXT("A3D 2.0 Sources: DISABLED") );
    }
    return 1;
  }

	return 0;
	unguard;
}


// =============================================================
// RenderNode()		Render a leaf of a BSP tree.
//
// =============================================================
static IA3dList* RenderNode(
	IA3dGeom		*pGeom, 
	FBspNode		*pNode,		// view or source leaf
	UModel			*pWorld,	// world model
	A3D_GeomStatus	*pGeomStatus)
{
	FVector tPos;
  long firstVert;

  // For triangulating the surface poly
  int v0, v1, v2;
  int j;
  int nEdges;

  FVert* pFirstVert;
  float fScaleFactor = 1.0f / gGeomStatus.fUnitsPerMeter;

	int numPolys = 0;
	IA3dList* pList = NULL;
	HRESULT hr;
	BOOL ok;
  
  if (gNumLeavesRendered >= MAX_LEAVES)
    return NULL;

  // First, try and find this leaf in the cache.
	if (Cache_Lookup (pNode, &pList, &numPolys))
	{
		assert(pList);

#ifdef _DEBUG
		gDebug_CacheHits++;
#endif

    // As far as we're concerned this leaf has been rendered.
	  gNodeInfo[gNumLeavesRendered].pList = pList;
    gNodeInfo[gNumLeavesRendered].iNumPolys = numPolys;
    gPolyCount += numPolys;
  	gNumLeavesRendered++;

    // Render all planars.
    if (pNode->iPlane != INDEX_NONE)
      return (RenderNode (pGeom, &gNodes[pNode->iPlane], pWorld, pGeomStatus));
    else
      return (pList);    
	}

#ifdef _DEBUG
	gDebug_CacheMisses++;
#endif

	numPolys = 0;
  pList = NULL;

	firstVert = pNode->iVertPool;
  pFirstVert = &pWorld->Verts (pNode->iVertPool);
  v0 = pFirstVert->pVertex;
  nEdges = pNode->NumVertices;

  // Just do simple fan - triangle
  for (j = 2; j < nEdges; j++)
  {
    float fArea;
    
    v1 = pFirstVert[j-1].pVertex;
    v2 = pFirstVert[j].pVertex;
    
    // Throw out colinear point.
    if (CheckColinear(&pWorld->Points(v0),
      &pWorld->Points(v1),
      &pWorld->Points(v2)))
    {
      continue;
    }
    
    // Throw out small polys
    if (IsTooSmall(&pWorld->Points(v0),
      &pWorld->Points(v1),
      &pWorld->Points(v2),
      pGeomStatus, &fArea))
    {
      continue;
    }
    
    // Once we get to this point in the code, a polygon is going to be
    // rendered.  It may not happen right here but it will happen.
    gPolyCount++;
    numPolys++;

    // May be time to allocate a list.  Some leafs have nothing but tiny polys 
    // in them.  Therefore we don't even create a list for them.
    if (!pList)
    {
      // Didn't have a cached list, had to create a new one.
      hr = pGeom->NewList(&pList);
    
      // Should never happen.
      if (FAILED (hr))
      {
        OutputDebugString (TEXT ("RenderNode critically failed to create a list!!!!\n"));
        return NULL;
      }
    
      // Begin the list
      pList->Begin();
      pGeom->BindMaterial(gDefMaterial);
      pGeom->Begin(A3D_TRIANGLES);
    }

    // If this is a reflection poly, tag it as such.
    if (IsReflectionPoly (fArea, pGeomStatus))
      pGeom->SetRenderMode(A3DPOLY_RENDERMODE_OCCLUSIONS | A3DPOLY_RENDERMODE_1ST_REFLECTIONS);
    else
      pGeom->SetRenderMode(A3DPOLY_RENDERMODE_OCCLUSIONS);

    pGeom->Tag(gTag++);
  
    // Don't do any rotating, just bring all geometry into the same scale as the sources.
    tPos = pWorld->Points(v0) * fScaleFactor;
    pGeom->Vertex3f(tPos.X, tPos.Y, tPos.Z);
  
    tPos = pWorld->Points(v1) * fScaleFactor;
    pGeom->Vertex3f(tPos.X, tPos.Y, tPos.Z);
  
    tPos = pWorld->Points(v2) * fScaleFactor;
    pGeom->Vertex3f(tPos.X, tPos.Y, tPos.Z);
  }

  if (pList)
  {
  	// End the list
    pGeom->End();
    pList->End();
    
    // Store the new list in the cache.
    ok = Cache_Store(pNode, pList, numPolys);
    if (!ok)
    {
      pList->Release();
      pList = NULL;
    }
    else
    {
      //	Store the new list in the appropriate gNodeInfo space.
      gNodeInfo[gNumLeavesRendered].pList = pList;
      gNumLeavesRendered++;
    }
  }
  
  return (pList);
}


// =============================================================
// IsReflectionPoly()		Is this poly ok for a reflection?
//
// =============================================================
BOOL IsReflectionPoly (float fArea, A3D_GeomStatus *pGeomStatus)
{
	if (fArea < pGeomStatus->fPolyReflectSize)
		return FALSE;

	return TRUE;
}


// =============================================================
// IsTooSmall()		Check if a poly is too small for audio
//					or angle too thin.
//
// =============================================================

BOOL IsTooSmall(
	FVector *v0,		// in, vertex 0
	FVector *v1,		// in, vertex 1
	FVector *v2,		// in, vertex 2
	A3D_GeomStatus *pGeomStatus,
	float *pfArea)
{
	FVector v_1_0;
	FVector v_2_0;
	FVector vcross;
	float fArea;

	v_1_0 = *v1 - *v0;
	v_2_0 = *v2 - *v0;
	vcross = v_1_0 ^ v_2_0;

	// Cross is the 2 times the area of our triangle.
	fArea = vcross.SizeSquared();
	*pfArea = fArea;
	if (fArea < pGeomStatus->fPolyTooSmall)
	{
#ifdef _DEBUG
		gRejectedSize++;
#endif
		return TRUE;
	} 
		
#ifdef USE_ANGLE_FILTERS
	else if (fArea > pGeomStatus->fPolyAlwaysKeep)
	{
		return FALSE;
	}

	// Check for a nice angle.
	// do V10 and V20
	float fdotdot = v_1_0 | v_2_0;
	fdotdot *= fdotdot;

	if (fdotdot != 0.f)
	{
		if (fArea/fdotdot < pGeomStatus->fPolyAngleTooSmall)
		{
#ifdef _DEBUG
			gRejectedAngle++;
#endif
			return TRUE;
		}
	}
  
	// do V12 and V10 angle
	FVector v_1_2;
	v_1_2 = *v1 - *v2;
	vcross = v_1_2 ^ v_1_0;
	fArea = vcross.SizeSquared();
	fdotdot = v_1_2 | v_1_0;
   fdotdot *= fdotdot;
  
   if (fdotdot != 0.f)
	{
		if (fArea/fdotdot < pGeomStatus->fPolyAngleTooSmall)
		{
#ifdef _DEBUG
			gRejectedAngle++;
#endif
			return TRUE;
		}
	}
  
	// do V12 and V20 angle
	vcross = v_1_2 ^ v_2_0;
	fArea = vcross.SizeSquared();
	fdotdot = v_1_2 | v_2_0;
	fdotdot *= fdotdot;

	if (fdotdot != 0.f)
	{
		if (fArea/fdotdot < pGeomStatus->fPolyAngleTooSmall)
		{
#ifdef _DEBUG
			gRejectedAngle++;
#endif
			return TRUE;
		}
	}
#endif

	return FALSE;
}

// =============================================================
// CheckColinear()		Check if a poly is colinear.
//
// =============================================================

BOOL CheckColinear(
	FVector *v0,		// in, vertex 0
	FVector *v1,		// in, vertex 1
	FVector *v2)		// in, vertex 2
{
	FVector v_1_0;
	FVector v_2_0;
	FVector vcross;

	v_1_0 = *v1 - *v0;
	v_2_0 = *v2 - *v0;
	vcross = v_1_0 ^ v_2_0;

	// if cross product is zero point is colinear
	if (vcross.SizeSquared() < A3D_EPSILON)
		return TRUE;

	return FALSE;
}


void RecurseVisAudioNodes (LPA3DGEOM A3dGeom, FBspNode* Node, UModel *CurWorld, A3D_GeomStatus *pGeomStatus, QWORD ActiveZoneMask)
{
  FBspSurf* Poly	= &gpFrame->Level->Model->Surfs(Node->iSurf);
  DWORD PolyFlags	= Poly->PolyFlags | gpFrame->Viewport->ExtraPolyFlags;
  int i;

  if (gpFrame->Viewport)
    PolyFlags |= gpFrame->Viewport->ExtraPolyFlags;
  
	if (gNumLeaves >= MAX_LEAVES)
    return;

  // Zone mask rejection.
  if( ! (Node->ZoneMask & ActiveZoneMask) )
    return;
 
  if (Node->NumVertices               // Make sure this node has vertices to render
    && !(PolyFlags & PF_Portal)       // Don't want to render portals.
    )     
  {
    FVert* Verts = &CurWorld->Verts (Node->iVertPool );
    gNodeInfo[gNumLeaves].vCenter = FVector (0.0f, 0.0f, 0.0f);
    for( i=0; i<Node->NumVertices; i++ )
    {
      gNodeInfo[gNumLeaves].vCenter += CurWorld->Points( Verts[i].pVertex );
    }
    
    gNodeInfo[gNumLeaves].vCenter /= Node->NumVertices;
      
    FVector dv = gNodeInfo[gNumLeaves].vCenter - *gOrigin;
    float dsquared = dv.SizeSquared();
    
    if (!gGeomStatus.bJustInitialized && dsquared < gGeomStatus.fMaxNodeDist)
    {
      gNodeInfo[gNumLeaves].pNode = Node;
      gNodeInfo[gNumLeaves].pList = NULL;
      gNumLeaves++;
    }

    // Add adjacent nodes.
    if (Node->iPlane != INDEX_NONE)
    {
      RecurseVisAudioNodes (A3dGeom, &gNodes[Node->iPlane], CurWorld, pGeomStatus, ActiveZoneMask);
    }

  }
  else
  {
#ifdef _DEBUG
    gRejectedLeaves++;
#endif
  }
  
  // Check the back nodes
  if (Node->iBack != INDEX_NONE)
    RecurseVisAudioNodes (A3dGeom, &gNodes[Node->iBack], CurWorld, pGeomStatus, ActiveZoneMask);
  
  // Check front nodes
  if (Node->iFront != INDEX_NONE)
    RecurseVisAudioNodes (A3dGeom, &gNodes[Node->iFront], CurWorld, pGeomStatus, ActiveZoneMask);
}


void RenderVisNodes (LPA3D3 A3d, LPA3DGEOM A3dGeom, LPA3DMATERIAL A3dMaterial, UModel *pCurModel, A3D_GeomStatus *pGeomStatus)
{
  if (IsNodeTransition(pCurModel, pGeomStatus))
  {
    int i;
      
    // Free up the high detail nodes.
    for (i=0; i < HIGH_DETAIL_NODES; i++)
      Cache_Remove (gNodeInfo[i].pNode);

    // Cache needs to be updated every time we begin a new batch of 
    // Cache_Stores().
    Cache_Update ();
    
    gA3d->Clear();	//	Has to be done before making lists. I don't know why...

    // Bind material
    A3dGeom->BindMaterial(A3dMaterial);
    
    // Begin count of polygon
    gPolyCount = 0;
    gNumLeavesRendered = 0;
    
    int iViewZone			= gpFrame->ZoneNumber;
    QWORD ActiveZoneMask	= ((QWORD)1) << iViewZone;
    
    if (! iViewZone)
      return;

    A3dGeom->LoadIdentity();

    // Render nodes in the current visible space.
    gNumLeaves = 0;

    RecurseVisAudioNodes (A3dGeom, &pCurModel->Nodes(0), pCurModel, pGeomStatus, ActiveZoneMask);

    SortAudioNodes();

    RenderSortedNodes(A3dGeom, pCurModel, pGeomStatus);

    DWORD numPoly = 0;
    for (i = 0; i < gNumLeavesRendered && numPoly < pGeomStatus->dwMaxPoly; i++)
    {
      if (gNodeInfo[i].pList)
      {
        int polys;
        polys = gNodeInfo[i].pList->Call();
        numPoly += polys;
      }
    }
  }
}

void A3D_UnrealRenderGeometry(FSceneNode *Frame)
{
  UViewport	*Viewport;
  UModel	*Model;
  long      Zone;

	if (!Frame || !gA3dGeom)
    return;

	Model = Frame->Level->Model;
	if (!Model || !Model->Nodes.Num())
    return;

	gNodes		= &Model->Nodes(0);
	gOrigin		= &Frame->Coords.Origin;
  

	Zone = Frame->ZoneNumber;
	Viewport = Frame->Viewport;

	if (gGeomStatus.bJustInitialized)
  {
    gTag = 1;
    Cache_Clear();
	}

  // DEBUGGING
#ifdef _DEBUG
	gDebug_CacheHits = 0;
	gDebug_CacheMisses = 0;
#endif

	gpFrame = Frame;

  // Check for underwater scene.
	if (Viewport && Viewport->Actor)
	{
		Zone = Frame->Viewport->Actor->Region.ZoneNumber;

		BOOL isWaterZone;

		if (!Viewport->Actor->Region.Zone || !Viewport->Actor->HeadRegion.Zone->bWaterZone || Viewport->Actor->bShowMenu)
			isWaterZone = FALSE;
		else
			isWaterZone = TRUE;

		if (isWaterZone != gWaterZone)
		{
			gWaterZone = isWaterZone;
      if (isWaterZone)
        A3D_UnrealSetEq (A3D_EQ_TYPE_WATER);
      else
        A3D_UnrealSetEq (A3D_EQ_TYPE_DEFAULT);
		}
	}

	RenderVisNodes(gA3d, gA3dGeom, gDefMaterial, Model, &gGeomStatus);

	// We're no longer just initialized.
	gGeomStatus.bJustInitialized = FALSE;
}

void A3D_UnrealInit(LPIA3D3 A3d, LPA3DLISTENER A3dListener)
{
	guard(A3D_UnrealInit);

	HRESULT			hr;

  if (!A3d || !A3dListener)	return;

	A3d->GetOutputGain(&gGain);

	gbA3D = 1;
	gbWaveTracing = 1;

	gA3d = A3d;
	gA3dListener = A3dListener;

	if (!SUCCEEDED(gA3d->QueryInterface(IID_IA3dGeom, (void **) &gA3dGeom)) || !gA3dGeom)
		return;

  gGeomStatus.bJustInitialized = TRUE;


	// Enable occlusions and reflections
	if (gGeomStatus.bEnableOcclusion)
	{
		hr = gA3dGeom->Enable(A3D_OCCLUSIONS);
	}

	if (gGeomStatus.bEnableReflection)
	{
		hr = gA3dGeom->Enable(A3D_1ST_REFLECTIONS);
	}

	// Set reflection info
	hr = gA3d->SetMaxReflectionDelayTime (7.0f);
	hr = gA3dGeom->SetReflectionDelayScale (gGeomStatus.fRefDelay);
	hr = gA3dGeom->SetReflectionGainScale (gGeomStatus.fRefGain);

	// Create a default material
	hr = gA3dGeom->NewMaterial(&gDefMaterial);

	// Set it's material property
	hr = gDefMaterial->SetTransmittance (gGeomStatus.fTransmittance, .75f);
	hr = gDefMaterial->SetReflectance (.85f, .85f);

	// Bind material
	gA3dGeom->BindMaterial(gDefMaterial);

	A3D_UnrealSetEq(A3D_EQ_TYPE_DEFAULT);

	unguard;
}

void A3D_UnrealDestroy(void)
{
	guard(A3D_UnrealDestroy);
	Cache_Clear();
	if (gA3dGeom)
	{
		gA3dGeom->Release();
		gA3dGeom = NULL;
	}

	unguard;
}


// =============================================================
// IsValidLeafTransition()		Check if there is a valid leaf
//								transition for sake of efficency
//								and smooth audio reflections.
//
// =============================================================
BOOL IsNodeTransition(UModel *pCurModel, A3D_GeomStatus *pGeomStatus)
{
	// has listener move a good distance
	static FVector LastLeafPos;

  FVector dv;
  dv = LastLeafPos - *gOrigin;

	float dsquared = dv.SizeSquared();

	if (!gGeomStatus.bJustInitialized && dsquared < pGeomStatus->fLeafTransDistSq)
		return FALSE;

	LastLeafPos = *gOrigin;

  return TRUE;
}


// =============================================================
// CompareLeafDist
static int CompareLeafDist(const void *e1, const void *e2)
{
  A3DNodeInfo *node1 = (A3DNodeInfo *)e1;
  A3DNodeInfo *node2 = (A3DNodeInfo *)e2;
	float dsq1;
	float dsq2 ;

  dsq1 = FDistSquared (node1->vCenter, *gOrigin);
  dsq2 = FDistSquared (node2->vCenter, *gOrigin);

	if (dsq1 > dsq2)
		return 1;

	if (dsq1 < dsq2)
		return -1;

	return 0;
}


void RenderSortedNodes(IA3dGeom *pGeom, UModel *pCurModel, A3D_GeomStatus *pGeomStatus)
{
	int i;

  //	Careful we don't wrap around, this seems reasonably high...
	if (gTag >= 0xffff0000)
    gTag = 1;

  gNumReflect = 0;

#ifdef _DEBUG
  gRejectedSize  = 0;
  gRejectedAngle = 0;
  gRejectedLeaves = 0;
#endif

	for (i = 0; i < gNumLeaves; i++)
	{
		if (gPolyCount >= pGeomStatus->dwMaxPoly || gNumLeavesRendered >= MAX_LEAVES)
			break;

    // render the first several nodes in much higher detail.
		if (i <= HIGH_DETAIL_NODES)
		{
			// Render the current leaf with more detail then the other leaves.
			pGeomStatus->fPolyTooSmall *= .01f;
			pGeomStatus->fPolyReflectSize *= .1f;

      // Free up any low detail versions of this node.
      Cache_Remove (gNodeInfo[i].pNode);

			RenderNode (pGeom, gNodeInfo[i].pNode, pCurModel, pGeomStatus);
			pGeomStatus->fPolyTooSmall *= 100.0f;
			pGeomStatus->fPolyReflectSize *= 10.0f;
		}
		else
		{
			RenderNode (pGeom, gNodeInfo[i].pNode, pCurModel, pGeomStatus);
		}
	}

  // DEBUGGING
#ifdef _DEBUG
  {
    WCHAR buff[256];
    appSprintf (buff, TEXT ("Leaves %4i  Rejected %i  Polys %4i  Rejected %4i  Reflect\n"), gNumLeaves, gRejectedLeaves, gPolyCount, gRejectedSize, gNumReflect);
    OutputDebugString (buff);
  }
  {
    WCHAR buff[256];
    appSprintf (buff, TEXT ("Cache results: %i hits\t%i misses\t%5.2f%% Success\tRendered: %i Leaves %i Polys\n"), 
      gDebug_CacheHits, gDebug_CacheMisses, (float)gDebug_CacheHits / (gDebug_CacheHits + gDebug_CacheMisses),
      gNumLeavesRendered, gPolyCount);
    OutputDebugString (buff);
  }
#endif
}

void SortAudioNodes(void)
{
	qsort (gNodeInfo, gNumLeaves, sizeof(A3DNodeInfo), CompareLeafDist);
}

void A3D_UnrealSetEq(A3D_EQ_TYPE Type)
{
	((LPA3D4)gA3d)->SetEq(a3dEqTypes[Type]);
	gEqType = Type;
}


// A3D_RefreshGeometry
//
//  Makes sure all the geometry currently being rendered is up to date.
//  If any internal state has changed this is a how to reflect that
//  change.
void A3D_RefreshGeometry()
{
  gGeomStatus.bJustInitialized = TRUE;
}


// =============================================================
// LEAF CACHING
//
//  The following code is used to cache lists built from leafs.
//  The goal is to minimize the amount of new geometry sent to
//  the api every time a leaf transition occurs.
// =============================================================


// CACHE INTERNAL CONSTANTS
// ------------------------
#define NODES_PER_BUCKET  32
#define NUM_BUCKETS 64
#define CACHE_TIME_TO_LIVE 3

// CACHE INTERNAL DATA STRUCTURES
// ------------------------------
typedef struct CacheEntry_t
{
  IA3dList* pList;    // Array of A3D lists.  This is the data bound to the Node key.
  FBspNode* pNode;    // Associated Node.  This is the key we're hashing on.
  DWORD     dwTime;   // Last time this Node was looked up or stored.
  int       numPolys; // Number of polys in this list.
} CacheEntry;

typedef struct CacheBucket_t
{
  int numEntries;                         // Last used Node in this bucket.
  CacheEntry entries[NODES_PER_BUCKET]; // Array of cached data.
} CacheBucket;


// CACHE INTERNAL DECLARATIONS
// ---------------------------
BOOL Cache_FindInBucket (CacheBucket *pBucket, FBspNode *pNode, CacheEntry **ppEntry);
BOOL Cache_FindHole (CacheBucket *pBucket, CacheEntry **ppEntry);
int Cache_Hashcode (FBspNode *pNode);
BOOL Cache_FreeEntry (CacheEntry *pEntry);  // Called to blank this entry out.

// CACHE INTERNAL GLOBALS
// ----------------------

static CacheBucket gCache[NUM_BUCKETS];
static DWORD g_dwCacheTime = 0;



// CACHE EXTERNAL FUNCTIONS
// ------------------------
BOOL Cache_Lookup (FBspNode *pNode, IA3dList** ppList, int *pNumPolys)
{
  int hashcode;
  CacheBucket *pBucket;
  CacheEntry *pEntry = NULL;

  hashcode = Cache_Hashcode (pNode);
  pBucket = &gCache[hashcode];

  if (! Cache_FindInBucket (pBucket, pNode, &pEntry))
  {
    return FALSE;
  }

  *pNumPolys = pEntry->numPolys;
  *ppList = pEntry->pList;
  pEntry->dwTime = g_dwCacheTime; // timestamp this entry.
  return TRUE;
}


BOOL Cache_Store (FBspNode *pNode, IA3dList* pList, int numPolys)
{
  int hashcode;
  CacheBucket *pBucket;
  CacheEntry *pEntry = NULL;

  hashcode = Cache_Hashcode (pNode);
  pBucket = &gCache[hashcode];

  // Do we have room for this Node?
  if (pBucket->numEntries >= NODES_PER_BUCKET)
  {
    // DEBUGGING
#ifdef _DEBUG
    WCHAR buff[256];
    appSprintf (buff, TEXT ("Cache_Store: no room left in bucket %5i !!!!\n"), hashcode);
		OutputDebugString (buff);
#endif

    return FALSE;
  }

  // Find a hole to slip this Node into.
  if (!Cache_FindHole (pBucket, &pEntry))
  {
    // DEBUGGING
#ifdef _DEBUG
    WCHAR buff[256];
    appSprintf (buff, TEXT ("Cache_Store: could not find a hole in bucket %5i !!!!\n"), hashcode);
		OutputDebugString (buff);
#endif

    return FALSE;
  }

  pEntry->pNode = pNode;
  pEntry->pList = pList;
  pEntry->dwTime = g_dwCacheTime;
  pEntry->numPolys = numPolys;

  return TRUE;
}


// Cache_Remove
//
//  Don't worry about reducing the numEntries count,
//  this will happen next time Cache_Clean is called.
BOOL Cache_Remove (FBspNode *pNode)
{
  int hashcode;
  CacheBucket *pBucket;
  CacheEntry *pEntry = NULL;

  hashcode = Cache_Hashcode (pNode);
  pBucket = &gCache[hashcode];

  if (! Cache_FindInBucket (pBucket, pNode, &pEntry))
    return FALSE;

  Cache_FreeEntry (pEntry);

  return TRUE;
}

// Cache_Update
//
//  Run through every entry in the cache and clean out all old values.
//  Also, pack the arrays.
BOOL Cache_Update ()
{
  int bucket;

  for (bucket = 0; bucket < NUM_BUCKETS; bucket++)
  {
    int entry;
    int numHoles; // The number of empty holes in front of the current
                  // entry.  All entries after this one are moved back
                  // by this amount, thus packing the bucket.

    CacheBucket *pBucket = &gCache[bucket];

    numHoles = 0; // So far, don't move anything.
    for (entry = 0; entry < pBucket->numEntries; entry++)
    {
      CacheEntry *pEntry = &pBucket->entries[entry];

      // 4 cases: the entry is empty; the entry is old; the entry 
      // has to move back to fill hole(s); nothing to do.
      if (!pEntry->pNode)
        numHoles++;
      else
      if (g_dwCacheTime - pEntry->dwTime > CACHE_TIME_TO_LIVE)
      {
        numHoles++;
        Cache_FreeEntry (pEntry);  // Called to blank this entry out.
      }
      else if (numHoles > 0)
        pBucket->entries[entry - numHoles] = *pEntry;
    }

    pBucket->numEntries -= numHoles;
        
  }

  // Increment the time
  g_dwCacheTime++;

  // In the event that we ever get this far, reset the cache.
  if (g_dwCacheTime > 0xfffffff0)
    Cache_Clear();

  return TRUE;
}


void Cache_Clear ()
{
  // Everything in the cache is now old.
  ZeroMemory (&gCache, sizeof (CacheBucket) * NUM_BUCKETS);
  g_dwCacheTime = 0;
}


// CACHE INTERNAL FUNCTIONS
// ------------------------

int Cache_Hashcode (FBspNode *pNode)
{
	DWORD Val = (DWORD)pNode;
  DWORD HashIndex = (Val + (Val >> 3) + (Val >> 6)) & (NUM_BUCKETS - 1);
	return (HashIndex);
}

BOOL Cache_FindInBucket (CacheBucket *pBucket, FBspNode *pNode, CacheEntry **ppEntry)
{
  int i;

  // Linear search for the Node.  One thing nice about 
  // small arrays is how fast linear searches are.
  for (i = 0; i < pBucket->numEntries; i++)
  {
    if (pBucket->entries[i].pNode == pNode)
    {
      *ppEntry = &pBucket->entries[i];
      return TRUE;
    }
  }

  return FALSE;
}


BOOL Cache_FindHole (CacheBucket *pBucket, CacheEntry **ppEntry)
{
  // Just fill the last slot.  Faster this way.
  if (pBucket->numEntries < NODES_PER_BUCKET)
  {
    *ppEntry = &pBucket->entries[pBucket->numEntries];
    pBucket->numEntries++;

    return TRUE;
  }

  return FALSE;
}

// Called to blank this entry out.
BOOL Cache_FreeEntry (CacheEntry *pEntry)
{
  // Release the list and blank out the info struct.
  if (pEntry->pList)
  {
    pEntry->pList->Release();
    pEntry->pList = NULL;
  }

  pEntry->pNode = NULL;
  pEntry->dwTime = 0;

  return TRUE;
}


