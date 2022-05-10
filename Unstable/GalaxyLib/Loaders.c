/*ÄÄ- Internal revision no. 5.00b -ÄÄÄ Last revision at 16:50 on  2-02-1998 -ÄÄ

                              The 32 bit C Source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                                MUSIC SYSTEM 
                This document contains confidential information
                     Copyright (c) 1993-97 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, LOADERS.C is Copyright (C) 1993-98 by  Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <windows.h>
#include "hdr\galaxy.h"

#include "hdr\glx-mpa.h"
#include "hdr\glx-smp.h"
#include "hdr\glx-669.h"
#include "hdr\glx-ae.h"
#include "hdr\glx-ai.h"
#include "hdr\glx-am.h"
#include "hdr\glx-as.h"
#include "hdr\glx-au.h"
#include "hdr\glx-it.h"
#include "hdr\glx-xm.h"
//#include "hdr\glx-aif.h"
#include "hdr\glx-dls.h"
#include "hdr\glx-far.h"
#include "hdr\glx-mid.h"
#include "hdr\glx-mod.h"
#include "hdr\glx-mtm.h"
#include "hdr\glx-ptm.h"
#include "hdr\glx-s3m.h"
#include "hdr\glx-sf2.h"
#include "hdr\glx-st3.h"
#include "hdr\glx-stm.h"
#include "hdr\glx-ult.h"
#include "hdr\glx-wav.h"

/* Global user definable functions */

static void * __cdecl mymalloc(size_t size)
{
	return malloc(size);
}

static void * __cdecl myrealloc(void *mem,size_t size)
{
	return realloc(mem,size);
}

static void __cdecl myfree(void *mem)
{
	free(mem);
}

void *(__cdecl *getmem)(size_t size)=mymalloc;
void *(__cdecl *resizemem)(void *mem,size_t size)=myrealloc;
void  (__cdecl *freemem)(void *mem)=myfree;

static int __cdecl myfseek(void *source,long int offset,int mode)
{
	return fseek(source,offset,mode);
}

static size_t __cdecl myfread(void *dest,size_t size,size_t count,void *source)
{
	return fread(dest,size,count,source);
}

static size_t __cdecl myfwrite(void *source,size_t size,size_t count,void *dest)
{
	return fwrite(source,size,count,dest);
}

static long int __cdecl myftell(void *source)
{
	return ftell(source);
}

int (__cdecl *seek)(void *source,long int offset,int mode)=myfseek;
size_t (__cdecl *read)(void *dest,size_t size,size_t count,void *source)=myfread;
size_t (__cdecl *write)(void *source,size_t size,size_t count,void *dest)=myfwrite;
long int (__cdecl *tell)(void *source)=myftell;

/* Global data */

extern CRITICAL_SECTION DSPWorking;

/* Memory related seek,read,write and tell functions */

static int __cdecl mseek(glxMemory *Source,long int offset,int mode)
{
	switch (mode)
	{
		case SEEK_SET: 
			Source->DataPos=offset; 
			if (Source->DataPos>Source->Length)
				Source->DataPos=Source->Length;
			return 0; 
			break;
		case SEEK_CUR: 
			Source->DataPos+=offset;
			if (Source->DataPos>Source->Length)
				Source->DataPos=Source->Length;
			return 0; 
			break;
		case SEEK_END: Source->DataPos=Source->Length+offset;
			if (Source->DataPos>Source->Length)
				Source->DataPos=Source->Length;
			return 0; 
			break;
		default: 
			return 1; 
		    break;
	}
}

static size_t __cdecl mread(void *Dest,size_t size,size_t count,glxMemory *Source)
{
	if ((Source->Length-Source->DataPos)<(size*count))
		count=((Source->Length-Source->DataPos)/size);
	memcpy(Dest,Source->Data+Source->DataPos,(size*count));
	Source->DataPos+=(size*count);
	return count;
}

static size_t __cdecl mwrite(void *Source,size_t size,size_t count,glxMemory *Dest)
{
	if ((Dest->Length-Dest->DataPos)<(size*count))
		count=((Dest->Length-Dest->DataPos)/size);
	memcpy(Dest->Data+Dest->DataPos,Source,(size*count));
	Dest->DataPos+=(size*count);
	return count;
}

static long int __cdecl mtell(glxMemory *Source)
{
	return (Source->DataPos);
}

int __cdecl glxLoadEffects(void *Stream,int Flags)
{
	ubyte HdrBuffer[12];

	if (Stream==NULL)
		return GLXERR_BADPARAMETER;
	if (Flags&GLX_LOADFROMSTREAM)
	{	
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_LOADFROMMEMORY)
	{	
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	read(HdrBuffer,1,12,Stream);
	seek(Stream,-12,SEEK_CUR);
	if (!memcmp(HdrBuffer+8,"AE  ",4))
		return glxLoadAE(Stream,Flags);
	return GLXERR_UNSUPPORTEDFORMAT;
}

int __cdecl glxLoadMusic(void *Stream,int Flags)
{
	ubyte HdrBuffer[48];

	if (Stream==NULL)
		return GLXERR_BADPARAMETER;
	if (glxMusicVoices)
		return GLXERR_MUSICLOADED;
	if (glxResetMusic()==GLXERR_MUSICPLAYING)
		return GLXERR_MUSICPLAYING;
	if (Flags&GLX_LOADFROMSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_LOADFROMMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	read(HdrBuffer,1,48,Stream);
	seek(Stream,-48,SEEK_CUR);
	if (!memcmp(HdrBuffer,"MThd",4))
		return glxLoadMID(Stream);
	if (!memcmp(HdrBuffer,"MTM",3))
		return glxLoadMTM(Stream);
	if (!memcmp(HdrBuffer,"FARş",4))
		return glxLoadFAR(Stream);
	//if (!memcmp(HdrBuffer,"IMPM",4))
	//	return glxLoadIT(Stream);
	if (!memcmp(HdrBuffer+8,"AM  ",4))
		return glxLoadAM(Stream,Flags);
	if (!memcmp(HdrBuffer+44,"SCRM",4))
		return glxLoadS3M(Stream);
	if (!memcmp(HdrBuffer+44,"PTMF",4))
		return glxLoadPTM(Stream);
	if (!memcmp(HdrBuffer,"MAS_UTrack_V00",14))
		return glxLoadULT(Stream);
	if (!memcmp(HdrBuffer,"Extended Module: ",17))
		return glxLoadXM(Stream);
	if ((!memcmp(HdrBuffer,"if",2))||(!memcmp(HdrBuffer,"JN",2)))
		return glxLoad669(Stream);
	if ((!memcmp(HdrBuffer+20,"!Scream!",8))||(!memcmp(HdrBuffer+20,"BMOD2STM",8)))
		return glxLoadSTM(Stream);
	else
		return glxLoadMOD(Stream);
}

glxSample * __cdecl glxLoadSample(void *Stream,int Flags)
{
	ubyte HdrBuffer[80];
	glxSample *Sample;

	if (Stream==NULL)
		return GLX_NULL;
	if (Flags&GLX_LOADFROMSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_LOADFROMMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	if ((Sample=getmem(sizeof(glxSample)))!=NULL)
	{
		memset(Sample,0,sizeof(glxSample));
		read(HdrBuffer,1,80,Stream);
		seek(Stream,-80,SEEK_CUR);
		if (!memcmp(HdrBuffer+8,"AS  ",4))
			return glxLoadAS(Sample,Stream,Flags);
		if (!memcmp(HdrBuffer,".snd",4))
			return glxLoadAU(Sample,Stream,Flags);
	//  if (!memcmp(HdrBuffer+8,"AIFF",4))
//			return glxLoadAIF(Sample,Stream,Flags);
		if (!memcmp(HdrBuffer+8,"WAVE",4))
			return glxLoadWAV(Sample,Stream,Flags);
		if (!memcmp(HdrBuffer+76,"SCRS",4))
			return glxLoadST3(Sample,Stream,Flags);
		//try MPEG audio stream   
		return glxLoadMPA(Sample,Stream,Flags);
	}
	return GLX_NULL;
}

int __cdecl glxLoadInstrument(int Instrument,void *Stream,int Flags)
{
	ubyte HdrBuffer[12];

	if (Stream==NULL)
		return GLXERR_BADPARAMETER;
	if (Flags&GLX_LOADFROMSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_LOADFROMMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	read(HdrBuffer,1,12,Stream);
	seek(Stream,-12,SEEK_CUR);
	if (!memcmp(HdrBuffer+8,"AI  ",4))
		return glxLoadAI(Instrument,Stream,Flags);
	if (!memcmp(HdrBuffer+8,"sfbk",4))
	    return glxLoadSF2(Instrument,Stream,Flags);
	if (!memcmp(HdrBuffer+8,"WAVE",4))
		return glxLoadWAV2(Instrument,Stream,Flags);
	if (!memcmp(HdrBuffer+8,"DLS ",4))
		return glxLoadDLS(Instrument,Stream,Flags);
	return GLXERR_UNSUPPORTEDFORMAT;
}

glxSample * __cdecl glxLoadInstrumentSample(int Instrument,int Sample,void *Stream,int Flags)
{
	glxSample *TempSample;

	if (glxInstruments[(Instrument&128)>>7][Instrument&127])
	{
		if ((TempSample=glxLoadSample(Stream,Flags))!=NULL)
		{
			if (Sample>=glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples)
			{
				glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples=(Sample+1);
				glxInstruments[(Instrument&128)>>7][Instrument&127]=resizemem(glxInstruments[(Instrument&128)>>7][Instrument&127],sizeof(glxInstrument)+sizeof(glxSample)*glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples);
			}
			memcpy(&glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample],TempSample,sizeof(glxSample));
			freemem(TempSample);
			return &glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample];
		}
	}
	return GLX_NULL;
}

int __cdecl glxSaveEffects(void *Stream,int Flags)
{
	if (Flags&GLX_SAVETOSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_SAVETOMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	return glxSaveAE(Stream,Flags);
}

int __cdecl glxSaveMusic(void *Stream,int Flags)
{
	if (glxMusicVoices==0)
		return GLXERR_NOMUSICLOADED;
	if (Flags&GLX_LOADFROMSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_LOADFROMMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	return glxSaveAM(Stream,Flags);
}

int __cdecl glxSaveSample(glxSample *Sample,void *Stream,int Flags)
{
	if (Flags&GLX_SAVETOSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_SAVETOMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	return glxSaveAS(Sample,Stream,Flags);
}

int __cdecl glxSaveInstrument(int Instrument,void *Stream,int Flags)
{
	if (Flags&GLX_SAVETOSTREAM)
	{
		seek=myfseek;
		read=myfread;
		write=myfwrite;
		tell=myftell;
	}
	if (Flags&GLX_SAVETOMEMORY)
	{
		seek=mseek;
		read=mread;
		write=mwrite;
		tell=mtell;
	}
	return glxSaveAI(Instrument,Stream,Flags);
}

int __cdecl glxSaveInstrumentSample(int Instrument,int Sample,void *Stream,int Flags)
{
	if (glxInstruments[(Instrument&128)>>7][Instrument&127])
	{
		if (Sample<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples)
			return glxSaveSample(&glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample],Stream,Flags);
	}
	return 0;
}

int __cdecl glxUnloadMusic(void)
{
	unsigned int BankNo,InstNo,PatternNo,TrackNo;

	if (!glxMusicEnabled)
	{
		glxLock();
		for (PatternNo=0;PatternNo<256;PatternNo++)
			if (glxPatterns[PatternNo])
			{
				for (TrackNo=0;TrackNo<glxPatterns[PatternNo]->Tracks;TrackNo++)
					freemem(glxPatterns[PatternNo]->Track[TrackNo].Events);
				freemem(glxPatterns[PatternNo]);
				glxPatterns[PatternNo]=NULL;
			}
		for (BankNo=0;BankNo<GLX_TOTALBANKS;BankNo++)
			for (InstNo=0;InstNo<GLX_TOTALINSTR;InstNo++)
				glxUnloadInstrument((BankNo<<7)+(InstNo&127));
		glxMusicVoices=0;
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_MUSICPLAYING;
}

int __cdecl glxUnloadSample(glxSample *Sample)
{
	int Voice;

	if (Sample)
	{
		if (Sample->FourCC==GLX_FOURCC_SAMP)
		{
			glxLock();
			for (Voice=0;Voice<GLX_TOTALVOICES;Voice++)
			{
				if ((glxVoices[Voice].Active)&&(glxVoices[Voice].Flags&GLX_MASTER)&&(glxVoices[Voice].SmpHdr==Sample))
				{
					if (glxVoices[Voice].Flags&GLX_POSITIONAL)
						glxStopSample3D(&glxVoices[Voice]);
					else
						glxStopSample(&glxVoices[Voice]);
				}
			}
			if (Sample->Articulation)
			{
				freemem(Sample->Articulation);
				Sample->Articulation=NULL;
			}
			if (Sample->Data)
			{
				freemem(Sample->Data);
				Sample->Data=NULL;
			}
			freemem(Sample);
			glxUnlock();
			return GLXERR_NOERROR;
		}	
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxUnloadInstrument(int Instrument)
{
	int Voice,SampleNo;

	if (glxInstruments[(Instrument&128)>>7][Instrument&127])
	{
		if (glxInstruments[(Instrument&128)>>7][Instrument&127]->FourCC==GLX_FOURCC_INST)
		{
			glxLock();
			for (Voice=0;Voice<GLX_TOTALVOICES;Voice++)
			{
				if (glxVoices[Voice].InstNo==Instrument)
					glxVoices[Voice].Active=0;
			}
			for (SampleNo=0;SampleNo<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples;SampleNo++)
			{
				if (glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[SampleNo].Data)
				{
					freemem(glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[SampleNo].Data);
					glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[SampleNo].Data=NULL;
				}
			}
			freemem(glxInstruments[(Instrument&128)>>7][Instrument&127]);
			glxInstruments[(Instrument&128)>>7][Instrument&127]=NULL;
			glxUnlock();
			return GLXERR_NOERROR;
		}
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxUnloadInstrumentSample(int Instrument,int Sample)
{
	if (glxInstruments[(Instrument&128)>>7][Instrument&127])
	{
		if (Sample<Sample<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples)
		{
			if (glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample].Data)
				freemem(glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample].Data);
			memset(&glxInstruments[(Instrument&128)>>7][Instrument&127]->Sample[Sample],0,sizeof(glxSample));
			if (Sample==(Sample<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples-1))
			{
				glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples--;
				glxInstruments[(Instrument&128)>>7][Instrument&127]=resizemem(glxInstruments[(Instrument&128)>>7][Instrument&127],sizeof(glxInstrument)+sizeof(glxSample)*glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples);
				return GLXERR_NOERROR;
			}
		}
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxSetMemInterface(void *newmalloc,void *newrealloc,void *newfree)
{
	getmem=(newmalloc ? newmalloc : mymalloc);
	resizemem=(newrealloc ? newrealloc : myrealloc);
	freemem=(newfree ? newfree : myfree);
	return GLXERR_NOERROR;
}

int __cdecl glxSetIOInterface(void *newread,void *newseek,void *newtell,void *newwrite)
{
	read=(newread ? newread : myfread);
	seek=(newseek ? newseek : myfseek);
	tell=(newtell ? newtell : myftell);
	write=(newwrite ? newwrite : myfwrite);
	return GLXERR_NOERROR;
}
