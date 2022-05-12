/*=============================================================================
	Texture.cpp: Texture handling functions for the PowerVR SGL driver.

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
// Create some default textures so things don't go too ugly if we
// run out of texture memory. This is also a performance enhancement
// since we can always leave texturing enabled.
//*****************************************************************************
void USGLRenderDevice::CreateDefaultTextures(void)
{
#define MIN_TEXTURE_SIZE 32

	guard(USGLRenderDevice::CreateDefaultTextures);

	sgl_intermediate_map Map;
	sgl_map_pixel Pixels[MIN_TEXTURE_SIZE*MIN_TEXTURE_SIZE];

	// Init struct.
	Map.id[0]='I';
	Map.id[1]='M';
	Map.id[2]='A';
	Map.id[3]='P';
	Map.x_dim=Map.y_dim=MIN_TEXTURE_SIZE;
	Map.pixels=Pixels;

	// Create default texture map.
	memset(Pixels,127,sizeof(Pixels));
	DefaultTextureMap=
		sgl_create_texture(sgl_map_16bit,sgl_map_32x32,sgl_mipmap_generate_none,FALSE,&Map,NULL);
	// Create default light map.
	memset(Pixels,255,sizeof(Pixels));
	DefaultLightMap=
		sgl_create_texture(sgl_map_trans16,sgl_map_32x32,sgl_mipmap_generate_none,FALSE,&Map,NULL);
	// Make default fog map same as default light map.
	DefaultFogMap=DefaultLightMap;

	if (DefaultTextureMap<=0 || DefaultLightMap<=0 || DefaultFogMap<=0)
		appErrorf(TEXT("SGL: Failed to load default texture(s)."));

	unguard;
}

//*****************************************************************************
// Init the caching
//*****************************************************************************
void USGLRenderDevice::InitCaching(void)
{
	guard(USGLRenderDevice::Init);

	StartCacheObjectList=NULL;
	EndCacheObjectList=NULL;
	DeletionQueue=NULL;
	LastFrameReloadAtFullSizeTried=0;

	unguard;
}

//*****************************************************************************
// Frees all textures immediately. All frames must be rendered off before this is called.
//*****************************************************************************
void USGLRenderDevice::ShutDownCaching(void)
{
	guard(USGLRenderDevice::ShutDown);

	USGLCacheObject *Object,*NextObject;

	// Walk cache object list and freeing all textures and memory allocated to the object.
	for (Object=StartCacheObjectList;Object!=NULL;Object=NextObject)
	{
		// Get this before we free everything.
		NextObject=Object->Next;
		// Free texture.
		sgl_delete_texture(Object->SglTextureName);
		// Free object.
		delete Object;
	}

	unguard;
}

//*****************************************************************************
// Returns a pointer to an object with matching CacheID, otherwise returns NULL.
//*****************************************************************************
USGLRenderDevice::USGLCacheObject *USGLRenderDevice::GetObjectFromTexture(QWORD CacheID)
{
	guard(USGLRenderDevice::GetObjectFromTexture);

	// Walk the cache object tree.
	for (USGLCacheObject *Object=StartCacheObjectList;Object!=NULL;Object=Object->Next)
	{
		if (Object->CacheID==CacheID)
			break;
	}
	// Return ptr to object.
	return Object;

	unguard;
}

//*****************************************************************************
// Inserts a cache object into the start of the list.
//*****************************************************************************
void USGLRenderDevice::AddCacheObjectToStartOfList(USGLCacheObject *Object)
{
	guard(USGLRenderDevice::AddCacheObjectToStartOfList);

	if (StartCacheObjectList==NULL)
	{
		// First object to be added to the list, so init everything.
		StartCacheObjectList=EndCacheObjectList=Object;
		Object->Next=Object->Previous=NULL;
	}
	else
	{
		// Already something in the list so insert it at the start.
		Object->Previous=NULL;
		Object->Next=StartCacheObjectList;
		StartCacheObjectList->Previous=Object;
		StartCacheObjectList=Object;
	}

	unguard;
}

//*****************************************************************************
// Removes a cache object from the list.
//*****************************************************************************
void USGLRenderDevice::RemoveCacheObjectFromList(USGLCacheObject *Object)
{
	guard(USGLRenderDevice::RemoveCacheObjectFromList);

	// Unhook from previous.
	if (Object->Previous==NULL)
	{
		// At start of list.
		StartCacheObjectList=Object->Next;
	}
	else
	{
		// Not at start of list.
		Object->Previous->Next=Object->Next;
	}

	// Unhook from next.
	if (Object->Next==NULL)
	{
		// At end of list.
		EndCacheObjectList=Object->Previous;
	}
	else
	{
		// Not at end of list.
		Object->Next->Previous=Object->Previous;
	}

	unguard;
}

//*****************************************************************************
// Unloads a SGL texture. If it is still in use, adds it to the deletion queue.
//*****************************************************************************
void USGLRenderDevice::UnloadSglTexture(DWORD LastFrameUsed, int SglTextureName)
{
	guard(USGLRenderDevice::UnloadSglTexture);

	// See if still in use by one of the frames.
	if (LastFrameUsed < (CurrentFrame-1))
	{
		// We can delete it.
		sgl_delete_texture(SglTextureName);
	}
	else
	{
		// Can't delete it, so add to deletion queue.
		// Create new item.
		USGLDeletionQueueItem *Item=new USGLDeletionQueueItem;

		// Set variables.
		Item->LastFrameUsed=LastFrameUsed;
		Item->SglTextureName=SglTextureName;

		// Insert into list.
		Item->Next=DeletionQueue;
		DeletionQueue=Item;
	}

	unguard;
}

//*****************************************************************************
// Walks the cache object list and unloads all textures. Any textures which
// are still in use are added to the deletion queue.
//*****************************************************************************
void USGLRenderDevice::UnloadAllTextures(void)
{
	guard(USGLRenderDevice::UnloadAllTextures);

	USGLCacheObject *Object,*NextObject;

	// Walk cache object list and freeing all textures and memory allocated to the object.
	for (Object=StartCacheObjectList;Object!=NULL;Object=NextObject)
	{
		// Get this before we free everything.
		NextObject=Object->Next;
		// Free texture.
		UnloadSglTexture(Object->LastFrameUsed,Object->SglTextureName);
		// Unhook from chain.
		RemoveCacheObjectFromList(Object);
		// Free object.
		delete Object;
	}

	unguard;
}

//*****************************************************************************
// Frees any textures which are in the deletion queue and no longer in use.
//*****************************************************************************
void USGLRenderDevice::FreeQueuedTextures(void)
{
	guard(USGLRenderDevice::FreeQueuedTextures);

	USGLDeletionQueueItem *Item, *NextItem, *PreviousItem;

	// Walk deletion queue and delete anything that we can get rid of.
	for (Item=DeletionQueue, PreviousItem=NULL;Item!=NULL;Item=NextItem)
	{
		// Get this now in case we free the item.
		NextItem=Item->Next;
	
		// See if we can delete it.
		if (Item->LastFrameUsed < (CurrentFrame-1))
		{
			// We can delete it, so delete texture.
			sgl_delete_texture(Item->SglTextureName);
			// Unhook from the list.
			if (PreviousItem==NULL)
				DeletionQueue=NextItem;
			else
				PreviousItem->Next=NextItem;
			// Free memory for item.
			delete Item;
		}
		else
		{
			// Need to hang on to this one, so make it the PreviousItem.
			PreviousItem=Item;
		}
	}

	unguard;
}

//*****************************************************************************
// Creates a pre-processed SGL texture and tries to upload it.
//*****************************************************************************
BOOL USGLRenderDevice::LoadTexture(FTextureInfo &Texture,DWORD Flags,
								   USGLCacheObject *CacheObject,BOOL AttemptingReloadAtFullSize)
{
	guard(USGLRenderDevice::LoadTexture);

	INT Dimensions;
	BOOL MipMapped=(Texture.NumMips>1 && !(Flags & (SF_LightMap | SF_FogMap)));
	BOOL ReloadCandidate=!MipMapped && !Texture.bRealtime;

	// Calclate dimensions of texture
	Dimensions=Min(UNSGL_MAX_TEXTURE_DIMENSION,Max(Texture.USize,Texture.VSize));

	// Limit "rectangularness"
	if (!(Flags & (SF_LightMap | SF_FogMap)))
	{
		if (Dimensions>Texture.VSize*UNSGL_MAX_UV_RATIO)
			Dimensions=Texture.VSize*UNSGL_MAX_UV_RATIO;
		if (Dimensions>Texture.USize*UNSGL_MAX_UV_RATIO)
			Dimensions=Texture.USize*UNSGL_MAX_UV_RATIO;
		// On PCX2, prevent textures from being too large.
		if( MipMapped || Texture.bRealtime )
			Dimensions=Min(128,Dimensions);
	}
	else
	{
		Dimensions=Min(128,Dimensions);
#ifdef DOSTATS
		if (Texture.USize*Texture.VSize > Stats.LargestLMU*Stats.LargestLMV)
			Stats.LargestLMU=Texture.USize,Stats.LargestLMV=Texture.VSize;
		if (Max(Texture.USize,Texture.VSize) > Stats.LargestLMDim)
			Stats.LargestLMDim=Max(Texture.USize,Texture.VSize);
#endif
	}

	// Make sure not too small.
	Dimensions=Max(UNSGL_MIN_TEXTURE_DIMENSION,Dimensions);
	// Make sure not too large
	Dimensions=Min(256,Dimensions);

	// Alloc memory for texture
	FMemMark Mark(GMem);
	WORD *Pixels=New<WORD>(GMem,GetSglDataSize(Dimensions,MipMapped));

	// Set up structure for SGL texture
	sgl_intermediate_map SglMap;
	SglMap.id[0]='P';
	SglMap.id[1]='T';
	SglMap.id[2]=GetSglMapType(Flags,MipMapped);
	SglMap.id[3]=GetSglMapSize(Dimensions);
	SglMap.x_dim=Dimensions;
	SglMap.y_dim=Dimensions;
	SglMap.pixels=(sgl_map_pixel *)Pixels;

	// Set up palette if necessary.
	WORD *SglPalette=NULL;
	if (!(Flags & (SF_LightMap | SF_FogMap)))
	{
		SglPalette=New<WORD>(GMem,NUM_PAL_COLORS);
		CreateSglPalette(SglPalette,Texture.Palette,NUM_PAL_COLORS,Flags,*(Texture.MaxColor));
	}

	// Finished conversion, so try and load texture
	int TmpSglTextureName=0;
	BOOL TmpNotLoadedAtFullSize=FALSE;

	if (MipMapped)
	{
		// Mipmapped texture.
		// We need to calculate initial X and Y sizes so we can maintain correct aspect
		// ratio between the mipmaps.
		int TargetXSize=Min(Dimensions,Texture.USize);
		int TargetYSize=Min(Dimensions,Texture.VSize);
		
		// Convert data to format we want.
		for (int i=0;i<NumLevels(Dimensions);i++,TargetXSize=Max(1,TargetXSize>>1),TargetYSize=Max(1,TargetYSize>>1))
		{
			// Select most suitable mip level.
			for (int Level=Min(i,Texture.NumMips-1);Level<Texture.NumMips-1;Level++)
				if (Texture.Mips[Level]->USize<=TargetXSize || Texture.Mips[Level]->VSize<=TargetYSize)
					break;
			ConvertTextureData(Dimensions>>i,
							   TargetXSize,TargetYSize,	
							   Texture.Mips[Level]->USize,Texture.Mips[Level]->VSize,
							   Pixels+MipMapOffset(Dimensions,i),
							   Texture.Mips[Level]->DataPtr,SglPalette);
		}
	}
	else
	{
		// Non-mipmapped texture
		// Convert data to format we want.
		if (Flags & SF_LightMap)
			ConvertLightMapData(Dimensions,
								Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
								Texture.UClamp,Texture.VClamp,
								Pixels,Texture.Mips[0]->DataPtr,*(Texture.MaxColor));
		else if (Flags & SF_FogMap)
			ConvertFogMapData(Dimensions,
							  Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
							  Texture.UClamp,Texture.VClamp,
							  Pixels,Texture.Mips[0]->DataPtr,*(Texture.MaxColor));
		else
			ConvertTextureData(Dimensions,
							   Min(Dimensions,Texture.USize),Min(Dimensions,Texture.VSize),
							   Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
							   Pixels,Texture.Mips[0]->DataPtr,SglPalette);
	}

	// Data is converted so now try and load the texture.
	while (1)
	{
		// Get SGL to load our new texture
		CLOCK(Stats.TextureLoadTime);
		TmpSglTextureName=sgl_create_texture((sgl_map_types)SglMap.id[2],
											 (sgl_map_sizes)SglMap.id[3],
											 sgl_mipmap_generate_none,
											 FALSE,
											 &SglMap,
											 NULL);
		UNCLOCK(Stats.TextureLoadTime);
		// If load was successful, break;
		if (TmpSglTextureName>0)
			break;

		// Try unloading an existing texture which is unused to make room.
		if (EndCacheObjectList==NULL)
		{
			// None left to unload.
			break;
		}
		else if (EndCacheObjectList->LastFrameUsed < (CurrentFrame-1))
		{
			USGLCacheObject *CacheObject=EndCacheObjectList;

			// Remove from list of loaded textures.
			RemoveCacheObjectFromList(CacheObject);
			// Unload SGL Texture.
			UnloadSglTexture(CacheObject->LastFrameUsed,CacheObject->SglTextureName);
			// Delete object.
			delete CacheObject;
		}
		else
		{
			// None left which are unused.
			break;
		}
	}

	// See if we have had a sucessful load yet 
	// (providing we aren't trying to reload at full size).
	// Don't even bother for Fog/Light maps as these are already tiny.
	if (TmpSglTextureName<=0 && !AttemptingReloadAtFullSize &&
		!(Flags & (SF_LightMap | SF_FogMap)))
	{
		// Failed to load so try shrinking texture size
		TmpNotLoadedAtFullSize=TRUE;
		for (Dimensions/=2;Dimensions>=32;Dimensions/=2)
		{
			// Convert data to smaller size if necessary.
			if (!MipMapped)
			{
				if (Flags & SF_LightMap)
					ConvertLightMapData(Dimensions,
										Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
										Texture.UClamp,Texture.VClamp,
										Pixels,Texture.Mips[0]->DataPtr,*(Texture.MaxColor));
				else if (Flags & SF_FogMap)
					ConvertFogMapData(Dimensions,
									  Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
									  Texture.UClamp,Texture.VClamp,
									  Pixels,Texture.Mips[0]->DataPtr,*(Texture.MaxColor));
				else
					ConvertTextureData(Dimensions,
									   Min(Dimensions,Texture.USize),Min(Dimensions,Texture.VSize),
									   Texture.Mips[0]->USize,Texture.Mips[0]->VSize,
									   Pixels,Texture.Mips[0]->DataPtr,SglPalette);
			}
			// Update this since dimensions have changed.
			SglMap.id[3]=GetSglMapSize(Dimensions);

			// Get SGL to load our new texture
			CLOCK(Stats.TextureLoadTime);
			TmpSglTextureName=sgl_create_texture((sgl_map_types)SglMap.id[2],
												 (sgl_map_sizes)SglMap.id[3],
												 sgl_mipmap_generate_none,
												 FALSE,
												 &SglMap,
												 NULL);
			UNCLOCK(Stats.TextureLoadTime);
			// Exit the loop if load successful.
			if (TmpSglTextureName>0)
				break;
		}
	}

	Mark.Pop();

	// If the load was successful, return info, else return failure code
	if (TmpSglTextureName>0)
	{
		// Max colour. This is put in the vertex color to
		// scale the final color back down again.
		if (Flags & SF_LightMap)
			CacheObject->MaxColor=SGLColor(Texture.MaxColor->B*2,Texture.MaxColor->G*2,Texture.MaxColor->R*2);
		else if (Flags & SF_ModulationBlend)
			CacheObject->MaxColor=SGLColor(0,0,0);
		else if (Flags & (SF_NoScale | SF_FogMap))
			CacheObject->MaxColor=SGLColor(255,255,255,255);
		else 
//			CacheObject->MaxColor=SGLColor(Texture.MaxColor.R,Texture.MaxColor.G,Texture.MaxColor.B);
			CacheObject->MaxColor=SGLColor(255,255,255,255);
		// SGL Texture name.	
		CacheObject->SglTextureName=TmpSglTextureName;
		// U/V Scale values.
		if (Texture.USize>=Dimensions)
			CacheObject->UScale=1.0f / (Texture.USize * Texture.UScale); 
		else
			CacheObject->UScale=1.0f / (((float)Dimensions) * Texture.UScale);
		if (Texture.VSize>=Dimensions)
			CacheObject->VScale=1.0f / (Texture.VSize * Texture.VScale);
		else
			CacheObject->VScale=1.0f / (((float)Dimensions) * Texture.VScale);
		// Set dimensions
		CacheObject->Dimensions=Dimensions;
		// Indicates if this texture is suitable to try and reload at full size.
		CacheObject->ReloadCandidate=ReloadCandidate;
		// Set the flag to indicate if the texture is loaded at full size or not.
		CacheObject->NotLoadedAtFullSize=TmpNotLoadedAtFullSize;
		// NOTE: The LastFrameUsed field will be updated by the SetTexture code since
		// this needs to be done every frame the texture is used, not just when the
		// texture is loaded.
		return TRUE;
	}
	else
	{
		return FALSE;
	}

	unguard;
}

//*****************************************************************************
// Sets the specified texture. If it is not loaded or has changed, the
// texture will be loaded.
//*****************************************************************************
void USGLRenderDevice::SetTexture(FTextureInfo& Texture,DWORD Flags,QWORD CacheID,
								  USGLTexInfo &Info)
{
	guard(USGLRenderDevice::SetTexture);

	USGLCacheObject *CacheObject=NULL;
	
	// Get existing cache object for this texture if any.
	CacheObject=GetObjectFromTexture(CacheID);

	// See if there was already an existing cache object.
	if (CacheObject==NULL)
	{
		// Create a new object.
		CacheObject=new USGLCacheObject;
		CacheObject->CacheID=CacheID;

		// Attempt to load the texture.
		if (LoadTexture(Texture,Flags,CacheObject,FALSE/*Not trying to reload at full size*/)==FALSE)
		{
			// Failed to load so delete object.
			delete CacheObject;
			CacheObject=NULL;
		}
	}
	else 
	{
		// Using existing texture object.
		// Unhook it from the object list. We put it back at the end unless something
		// goes wrong. This way, the most recently used textures are always at the
		// top of the list.
		RemoveCacheObjectFromList(CacheObject);

		// If the texture has changed then it must be reloaded.
		if( Texture.bRealtimeChanged ||
			((Flags&(SF_LightMap|SF_FogMap)) && (GET_COLOR_DWORD(*Texture.MaxColor)==0xffffffff)) )
		{
			// Unload existing texture.
			UnloadSglTexture(CacheObject->LastFrameUsed,CacheObject->SglTextureName);

			// Attempt to reload the texture.
			if (LoadTexture(Texture,Flags,CacheObject,FALSE/*Not trying to reload at full size*/)==FALSE)
			{
				// Failed to load so delete object.
				delete CacheObject;
				CacheObject=NULL;
			}
		}
		else if (CacheObject->NotLoadedAtFullSize && CacheObject->ReloadCandidate &&
				 CacheObject->LastFrameUsed!=CurrentFrame &&
				 LastFrameReloadAtFullSizeTried!=CurrentFrame)
		{
			// We need to try and reload this texture at full size.
			// At most we do one reload try per frame and only on non-mipmapped textures
			// since these are the only critical ones and hopfully this won't hurt performance
			// too much.
			LastFrameReloadAtFullSizeTried=CurrentFrame;
			int OldSglTextureName=CacheObject->SglTextureName;

			// Attempt to reload the texture.
			CLOCK(Stats.ReloadTime);
			STATS_INC(Stats.Reloads);
			BOOL Status=LoadTexture(Texture,Flags,CacheObject,TRUE);
			UNCLOCK(Stats.ReloadTime);
			if (Status==TRUE)
			{
				// Reload was fine so unload old texture.
				UnloadSglTexture(CacheObject->LastFrameUsed,OldSglTextureName);
			}
		}
	}

	// See if we still have a cache object. If so, all is good. 
	// Fill in Info structure appropriately.
	if (CacheObject!=NULL)
	{
		Info.CacheID=CacheID;
		Info.MaxColor=CacheObject->MaxColor;
		Info.SglTextureName=CacheObject->SglTextureName;
		Info.UScale=CacheObject->UScale;
		Info.VScale=CacheObject->VScale;
		Info.Dimensions=CacheObject->Dimensions;
		// Set this so we don't unload it too early or try to reload this frame.
		CacheObject->LastFrameUsed=CurrentFrame;
		// Insert into the start of the loaded chain.
		AddCacheObjectToStartOfList(CacheObject);
	}
	else
	{
		debugf(NAME_Log,TEXT("SGL::SetTexture - Load failed. CacheId=0x%08X%08X, flags=0x%08X"),
			   (int)(Texture.CacheID>>32), (int)(Texture.CacheID),Flags);
		Info.CacheID=CacheID;
		// Set stuff to some default so the effect of failed texture loads are consistent.
		Info.MaxColor.D=0xFFFFFFFF;
		if (Flags & SF_LightMap)
			Info.SglTextureName=DefaultLightMap;
		else if (Flags & SF_FogMap)
			Info.SglTextureName=DefaultFogMap;
		else 
			Info.SglTextureName=DefaultTextureMap;
		Info.UScale=1.0f/(Texture.USize * Texture.UScale);
		Info.VScale=1.0f/(Texture.VSize * Texture.VScale);
		Info.Dimensions=Min(256,Max(Texture.USize,Texture.VSize));
	}

	unguard;
}
