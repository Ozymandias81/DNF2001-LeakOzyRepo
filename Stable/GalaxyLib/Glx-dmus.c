/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at  2:25 on 11-11-1998 -ÄÄ

                         The 32 bit DirectMusic C source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                               .. MUSIC SYSTEM ..
                This document contains confidential information
                     Copyright (c) 1993-98 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-DMUS.C is Copyright  (c) 1993-98 by Carlo Vogelsang ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include <stdio.h>
#include <string.h>
#include <direct.h>
#include <windows.h>
#include <dsound.h>
#include <dmusici.h>
#include "hdr\galaxy.h"

#define MULTI_TO_WIDE(x,y) MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,y,-1,x,_MAX_PATH);

static IDirectMusic *g_pMusic=NULL;
static IDirectMusicPerformance* g_pPerf=NULL;
static IDirectMusicLoader *g_pLoader=NULL;
static IDirectMusicPort *g_pPort=NULL;
static IDirectMusicSegment *g_pMIDIsegs[16];

static IDirectMusicPerformance* CreatePerformance(void)
{
    IDirectMusicPerformance* pPerf;     

	if (FAILED(CoCreateInstance(&CLSID_DirectMusicPerformance,NULL,CLSCTX_INPROC,&IID_IDirectMusicPerformance,(void**)&pPerf)))
		pPerf=NULL;    
    return pPerf;
}

static BOOL InitializeSynth(IDirectMusic* pMusic,IDirectMusicPerformance* pPerf)
{    
	BOOL fReturn=FALSE;
	DMUS_PORTCAPS dmpc;
	DMUS_PORTPARAMS dmos;
	GUID guidSynthGUID;
	DWORD index=0;
	HRESULT hr;

	// Setup a synth port
	memset(&dmos,0,sizeof(dmos));
	dmpc.dwSize=sizeof(DMUS_PORTCAPS);
	dmos.dwSize=sizeof(DMUS_PORTPARAMS);
	pMusic->lpVtbl->GetDefaultPort(pMusic,&guidSynthGUID);
	pMusic->lpVtbl->CreatePort(pMusic,&guidSynthGUID,&dmos,&g_pPort,NULL);
	hr=g_pPort->lpVtbl->GetCaps(g_pPort,&dmpc);
	while (((dmpc.dwFlags&DMUS_PC_DLS)==0)&&((SUCCEEDED(hr))&&(hr!=S_FALSE)))
	{
		g_pPort->lpVtbl->Release(g_pPort);
		hr=pMusic->lpVtbl->EnumPort(pMusic,index++,&dmpc);
		if ((SUCCEEDED(hr)&&(hr!=S_FALSE)))
		{
			memcpy(&guidSynthGUID,&dmpc.guidPort,sizeof(GUID));
			pMusic->lpVtbl->CreatePort(pMusic,&guidSynthGUID,&dmos,&g_pPort,NULL);
		}
		else g_pPort=NULL;
	}
	if (SUCCEEDED(g_pPort->lpVtbl->Activate(g_pPort,TRUE)))
	{
		if (SUCCEEDED(pPerf->lpVtbl->AddPort(pPerf,g_pPort)))
		{
			if (SUCCEEDED(pPerf->lpVtbl->AssignPChannelBlock(pPerf,0,g_pPort,1))&&
				SUCCEEDED(pPerf->lpVtbl->AssignPChannelBlock(pPerf,1,g_pPort,1)))
				fReturn=TRUE;
		}
	}
	return fReturn;
}

static IDirectMusicLoader* CreateLoader(void)
{
    IDirectMusicLoader* pLoader;
 
    if (FAILED(CoCreateInstance(&CLSID_DirectMusicLoader,NULL,CLSCTX_INPROC,&IID_IDirectMusicLoader,(void**)&pLoader)))
        pLoader=NULL;
    return pLoader;
}

static IDirectMusicSegment* LoadSegment(IDirectMusicLoader* pLoader,char *szFileName)
{
    DMUS_OBJECTDESC ObjDesc; 
    IDirectMusicObject *pObjectSeg=NULL;
    IDirectMusicSegment *pSegment=NULL;
    char szDir[_MAX_PATH];
    WCHAR wszDir[_MAX_PATH];
 
    if(_getcwd(szDir,_MAX_PATH)==NULL)
    {
        // there was an error. Return NULL.
        return NULL;
    }
	if (pLoader)
	{
		MULTI_TO_WIDE(wszDir,szDir);
		pLoader->lpVtbl->SetSearchDirectory(pLoader,&GUID_DirectMusicAllTypes,wszDir,FALSE);
		//Describe object
		ObjDesc.guidClass=CLSID_DirectMusicSegment;
		ObjDesc.dwSize=sizeof(DMUS_OBJECTDESC);
		MULTI_TO_WIDE(ObjDesc.wszFileName,szFileName);
		ObjDesc.dwValidData=DMUS_OBJ_CLASS|DMUS_OBJ_FILENAME;
		//Load object and get segment
		if (pLoader->lpVtbl->GetObject(pLoader,&ObjDesc,&IID_IDirectMusicSegment,(void**)&pSegment)==S_OK)
		{
			//Download this segment's collection to performance
			pSegment->lpVtbl->SetParam(pSegment,&GUID_Download,-1,0,0,(void *)g_pPerf);
		}
		else pSegment=NULL;
	}
	return pSegment;
} // End of LoadSegment()

int __cdecl glxInitDirectMusic(void)
{
	int fReturn=GLXERR_NOMUSICLOADED;
	
	if ((glxAudioOutput.Driver==GLX_DIRECTSOUND)&&(g_pPerf=CreatePerformance()))
	{
		if (g_pPerf->lpVtbl->Init(g_pPerf,&g_pMusic,(LPDIRECTSOUND)glxAudioOutput.Handle,NULL)==S_OK)
		{
			if (InitializeSynth(g_pMusic,g_pPerf))
			{	
				g_pLoader=CreateLoader();
				if (g_pLoader)
				{
					//Clear segment list
					memset(g_pMIDIsegs,0,sizeof(g_pMIDIsegs));
					//Set return code
					fReturn=GLXERR_NOERROR;
				}
			}
		}
	}
	return fReturn;
}

int __cdecl glxDeinitDirectMusic(void)
{
	if (g_pPerf)
	{
		// If there is any music playing, stop it.
		g_pPerf->lpVtbl->Stop(g_pPerf,NULL,NULL,0,0);
		if (g_pLoader)
		{
			// Release the loader object.
			g_pLoader->lpVtbl->Release(g_pLoader);
			g_pLoader=NULL;
		}
		if (g_pPort)
		{
			// Release the port object.
			g_pPort->lpVtbl->Release(g_pPort);
			g_pPort=NULL;
		}
		// CloseDown and Release the performance object.
		g_pPerf->lpVtbl->CloseDown(g_pPerf);
		g_pPerf->lpVtbl->Release(g_pPerf);
		g_pMusic=NULL;
		g_pPerf=NULL;
	}
    return GLXERR_NOERROR;
}

int __cdecl glxLoadDirectMusic(char *File,int Flags)
{
	char myFile[_MAX_PATH];
	int i;
	
	for (i=0;i<16;i++)
	{
		sprintf(myFile,"%s%i.sgt",strtok(File,"."),i);
		if (g_pMIDIsegs[i]=LoadSegment(g_pLoader,myFile))
		{
			//Set number of repeats(loops)
			g_pMIDIsegs[i]->lpVtbl->SetRepeats(g_pMIDIsegs[i],0xffff);
		}
	}
	return GLXERR_NOERROR;
}

int __cdecl glxUnloadDirectMusic(void)
{
	int i,fReturn=GLXERR_NOMUSICLOADED;

	for (i=0;i<16;i++)
	{
		if (g_pMIDIsegs[i])
		{
			// Unload this segment's collection
			g_pMIDIsegs[i]->lpVtbl->SetParam(g_pMIDIsegs[i],&GUID_Unload,-1,0,0,(void *)g_pPerf);
			// Release the segment.
			g_pMIDIsegs[i]->lpVtbl->Release(g_pMIDIsegs[i]);
			g_pMIDIsegs[i]=NULL;
			//Set number of repeats(loops)
			fReturn=GLXERR_NOERROR;
		}
	}
	return fReturn;
}

int __cdecl glxStartDirectMusic(void)
{
	IDirectMusicSegmentState *g_pSegState=NULL;
	int fReturn=GLXERR_BADPARAMETER;

	//Start playing segment
	if ((g_pMIDIsegs[0])&&(g_pPerf)&&(g_pPerf->lpVtbl->PlaySegment(g_pPerf,g_pMIDIsegs[0],DMUS_SEGF_BEAT,0,&g_pSegState)==S_OK))
	{
		//Set return code
		fReturn=GLXERR_NOERROR;
	}
	return fReturn;
}

int __cdecl glxStopDirectMusic(void)
{
	int i,fReturn=GLXERR_NOMUSICPLAYING;

	for (i=0;i<16;i++)
	{
		if (g_pMIDIsegs[i])
		{
			//Stop playing segment
			if ((g_pMIDIsegs[i])&&(g_pPerf)&&(g_pPerf->lpVtbl->Stop(g_pPerf,g_pMIDIsegs[i],NULL,0,DMUS_SEGF_BEAT)==S_OK))
			{
				//Set return code
				fReturn=GLXERR_NOERROR;
			}
		}
	}
	return fReturn;
}

int __cdecl glxControlDirectMusic(int Command,int Parameter)
{
	IDirectMusicSegmentState *g_pSegState=NULL;
	int fReturn=GLXERR_BADPARAMETER;

	if (Command==GLX_SETPOSITION)
	{
		//Start playing segment
		if ((g_pMIDIsegs[Parameter])&&(g_pPerf)&&(g_pPerf->lpVtbl->PlaySegment(g_pPerf,g_pMIDIsegs[Parameter],DMUS_SEGF_BEAT,0,&g_pSegState)==S_OK))
		{
			//Set return code
			fReturn=GLXERR_NOERROR;
		}
	}
	return fReturn;
}
