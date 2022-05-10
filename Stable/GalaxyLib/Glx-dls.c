/*Ä- Internal revision no. 4.00b -ÄÄÄ Last revision at 12:05 on 21-03-1998 -ÄÄ

                         The 32 bit DLS-Loader C source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                                MUSIC SYSTEM 
                This document contains confidential information
                     Copyright (c) 1993-96 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-DLS.C  is Copyright (c) 1993-98 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "math.h"
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* DLS File-header */
{
  ubyte  Id[4];
  udword Size;
  ubyte  Type[4];
} DLSFileHdr_Struct;

typedef struct                                  /* DLS List-header */
{
  ubyte  Id[4];
  udword Size;
  ubyte  Type[4];
} DLSListHdr_Struct;

typedef struct                                  /* DLS Chunk-header */
{
  ubyte  Id[4];
  udword Size;
} DLSChunkHdr_Struct;

typedef struct                                  /* DLS Colh-header */
{
  udword Instruments;
} DLSColhHdr_Struct;

typedef struct                                  /* DLS Ptbl-header */
{
  udword Size;
  udword Cues;
  struct
  {
    udword Offset;
  }      Cue[];
} DLSPtblHdr_Struct;

typedef struct                                  /* DLS Insh-header */
{
  udword Regions;
  struct
  {
     udword Bank;
     udword Instrument;
  }      Locale;
} DLSInshHdr_Struct;

typedef struct                                  /* DLS Regh-header */
{
  struct
  {
    uword Low;
    uword High;
  }      RangeKey;
  struct
  {
    uword Low;
    uword High;
  }      RangeVelocity;
  uword  Options;
  uword  KeyGroup;
} DLSReghHdr_Struct;

typedef struct                                  /* DLS Wsmp-header */
{
  udword Size;
  uword  Note;
  sword  Finetune;
  sdword Attenuation;
  udword Options;
  udword Loops;
  struct
  {
    udword Size;
    udword Type;
    udword Start;
    udword Length;
  }      Loop[1];								// DLS Level 1 defines one loop !
} DLSWsmpHdr_Struct;

typedef struct                                  /* DLS Wlnk-header */
{
  uword  Options;
  uword  PhaseGroup;
  udword Channel;
  udword TableIndex;
} DLSWlnkHdr_Struct;

typedef struct                                  /* DLS Art1-header */
{
  udword Size;
  udword ConnectionBlocks;
  struct
  {
    uword  Source;
    uword  Control;
    uword  Destination;
    uword  Transform;
    sdword Scale;
  }      ConnectionBlock[];
} DLSArt1Hdr_Struct;

typedef struct                                  /* DLS/WAV Fmt-header */
{
  uword  Format;                                // 1=PCM Format
  uword  Channels;
  udword SamplesPerSec;
  udword BytesPerSec;
  uword  BlockAlign;
  uword  BitsPerSample;
  ubyte  Data[];
} DLSFmtHdr_Struct;

typedef struct
{
	DLSReghHdr_Struct    Hdr;
	DLSWsmpHdr_Struct    Wsmp;
	DLSWlnkHdr_Struct    Wlnk;
	DLSArt1Hdr_Struct * *Art1;
} DLSReg_Struct;

typedef struct
{
  char				   Name[32];
  DLSInshHdr_Struct    Hdr;
  DLSReg_Struct	*	  *Reg;
  DLSArt1Hdr_Struct * *Art1; 
} DLSIns_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadDLS(int InsNo,void *Stream,int Mode)
{
  int Status=0,Ins,Bank,Key,ListType,i,j,k,l,WaveSize;
  DLSChunkHdr_Struct ChunkHdr;
  DLSFileHdr_Struct FileHdr;
  DLSListHdr_Struct ListHdr;
  DLSColhHdr_Struct ColhHdr;
  DLSPtblHdr_Struct *PtblHdr;
  DLSFmtHdr_Struct FmtHdr;
  DLSIns_Struct * *Inst;
  char *WavePool,*Wave;
  int PitchEnvAmp,smp;

  read(&FileHdr,1,sizeof(DLSFileHdr_Struct),Stream);
  while ((!feof((FILE *)Stream))||(WavePool==NULL))
  {
    if (read(&ChunkHdr,1,sizeof(DLSChunkHdr_Struct),Stream))
    {
      if (!memcmp(ChunkHdr.Id,"LIST",4))
      {
		read(ListHdr.Type,1,sizeof(ListHdr.Type),Stream);
        if (!memcmp(ListHdr.Type,"lins",4))
		{
          i=-1;
          ListType=1;
		  Inst=getmem(sizeof(DLSIns_Struct *));
		}
        else if (!memcmp(ListHdr.Type,"ins ",4))
		{
          i++;
		  ListType=2;
		  Inst=resizemem(Inst,(i+1)*sizeof(DLSIns_Struct *));
		  Inst[i]=getmem(sizeof(DLSIns_Struct));
		  memset(Inst[i],0,sizeof(DLSIns_Struct));
		}
        else if (!memcmp(ListHdr.Type,"lrgn",4))
		{
          j=-1;
		  ListType=3;
		  Inst[i]->Reg=getmem(sizeof(DLSReg_Struct *));	
		}
        else if (!memcmp(ListHdr.Type,"rgn ",4))
		{
          j++;
          ListType=4;
		  Inst[i]->Reg=resizemem(Inst[i]->Reg,(j+1)*sizeof(DLSReg_Struct *));
		  Inst[i]->Reg[j]=getmem(sizeof(DLSReg_Struct));
		  memset(Inst[i]->Reg[j],0,sizeof(DLSReg_Struct));
		}
        else if (!memcmp(ListHdr.Type,"lart",4))
		{
          k=-1;
  		  if (Inst[i]->Hdr.Locale.Bank&0x80000000)
		  {	
		    ListType=5;
		    Inst[i]->Reg[j]->Art1=getmem(sizeof(DLSArt1Hdr_Struct *));
		  }
		  else
		  {
			ListType=6;
			Inst[i]->Art1=getmem(sizeof(DLSArt1Hdr_Struct *));
		  }
		}
	    else if (!memcmp(ListHdr.Type,"wvpl",4))
		{
		  ListType=7;
	      WavePool=getmem(ChunkHdr.Size-4);
		  read(WavePool,1,ChunkHdr.Size-4,Stream);
		}
	  }
      else if (!memcmp(ChunkHdr.Id,"insh",4))
      {
        read(&Inst[i]->Hdr,1,sizeof(DLSInshHdr_Struct),Stream);
        seek(Stream,ChunkHdr.Size-sizeof(DLSInshHdr_Struct),SEEK_CUR);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
      else if (!memcmp(ChunkHdr.Id,"rgnh",4))
      {
        read(&Inst[i]->Reg[j]->Hdr,1,sizeof(DLSReghHdr_Struct),Stream);
        seek(Stream,ChunkHdr.Size-sizeof(DLSReghHdr_Struct),SEEK_CUR);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
      else if (!memcmp(ChunkHdr.Id,"wsmp",4))
      {
        read(&Inst[i]->Reg[j]->Wsmp,1,sizeof(DLSWsmpHdr_Struct),Stream);
        seek(Stream,ChunkHdr.Size-sizeof(DLSWsmpHdr_Struct),SEEK_CUR);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
	  }
      else if (!memcmp(ChunkHdr.Id,"wlnk",4))
      {
        read(&Inst[i]->Reg[j]->Wlnk,1,sizeof(DLSWlnkHdr_Struct),Stream);
        seek(Stream,ChunkHdr.Size-sizeof(DLSWlnkHdr_Struct),SEEK_CUR);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
      else if (!memcmp(ChunkHdr.Id,"art1",4))
      {
		k++;
  		if (ListType==5)
		{
  		  Inst[i]->Reg[j]->Art1=resizemem(Inst[i]->Reg[j]->Art1,(k+1)*sizeof(DLSArt1Hdr_Struct *));
  		  Inst[i]->Reg[j]->Art1[k]=getmem(ChunkHdr.Size);
  		  read(Inst[i]->Reg[j]->Art1[k],1,ChunkHdr.Size,Stream);
		}
  		else
		{
		  Inst[i]->Art1=resizemem(Inst[i]->Art1,(k+1)*sizeof(DLSArt1Hdr_Struct *));
		  Inst[i]->Art1[k]=getmem(ChunkHdr.Size);
		  read(Inst[i]->Art1[k],1,ChunkHdr.Size,Stream);
		}
		seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
	  else if (!memcmp(ChunkHdr.Id,"colh",4))
      {
        read(&ColhHdr,1,sizeof(DLSColhHdr_Struct),Stream);
        seek(Stream,ChunkHdr.Size-sizeof(DLSColhHdr_Struct),SEEK_CUR);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
      else if (!memcmp(ChunkHdr.Id,"ptbl",4))
	  {
        PtblHdr=getmem(ChunkHdr.Size);
		read(PtblHdr,1,ChunkHdr.Size,Stream);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      }
	  else if (!memcmp(ChunkHdr.Id,"INAM",4))
	  {
        if (ChunkHdr.Size>32)
		{
		  read(Inst[i]->Name,1,32,Stream);
          seek(Stream,ChunkHdr.Size-32,SEEK_CUR);
		}
		else
		  read(Inst[i]->Name,1,ChunkHdr.Size,Stream);
        seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
	  }
	  else seek(Stream,((ChunkHdr.Size+1)&~1),SEEK_CUR);
    }
  }
  //Done reading all important chunks, now start converting..
  for (i=0;i<ColhHdr.Instruments;i++)
  {
	if ((Inst[i]->Hdr.Locale.Bank&0x7fff)==0)	
    {
	  //get midi location (only variation zero)
	  Bank=Inst[i]->Hdr.Locale.Bank>>31;
	  Ins=Inst[i]->Hdr.Locale.Instrument&127;
	  //initialise instrument structure
	  glxInstruments[Bank][Ins]=getmem(sizeof(glxInstrument));
	  memset(glxInstruments[Bank][Ins],0,sizeof(glxInstrument));
	  glxInstruments[Bank][Ins]->FourCC=GLX_FOURCC_INST;
	  glxInstruments[Bank][Ins]->Size=sizeof(glxInstrument)-8;
	  glxInstruments[Bank][Ins]->Bank=Bank;
	  glxInstruments[Bank][Ins]->Program=Ins;
	  memcpy(glxInstruments[Bank][Ins]->Message,Inst[i]->Name,32);
	  //process regions
	  for (j=0;j<Inst[i]->Hdr.Regions;j++)
	  {
  	    //process rgnh
 	    for (Key=(Inst[i]->Reg[j]->Hdr.RangeKey.Low&0x7f);Key<=(Inst[i]->Reg[j]->Hdr.RangeKey.High&0x7f);Key++)
  		  glxInstruments[Bank][Ins]->Split[Key]=glxInstruments[Bank][Ins]->Samples;
	    glxInstruments[Bank][Ins]=resizemem(glxInstruments[Bank][Ins],sizeof(glxInstrument)+(glxInstruments[Bank][Ins]->Samples+1)*sizeof(glxSample));
	    memset(&(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples]),0,sizeof(glxSample));
	    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].FourCC=GLX_FOURCC_SAMP;
	    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Size=sizeof(glxSample)-8;
		glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Panning=GLX_MIDSMPPANNING;
	    //process wlnk which points to a wave
	    Wave=WavePool+PtblHdr->Cue[Inst[i]->Reg[j]->Wlnk.TableIndex].Offset;
		WaveSize=0;
		do
		{
		  memcpy(&ChunkHdr,Wave,sizeof(DLSChunkHdr_Struct));
		  Wave+=sizeof(DLSChunkHdr_Struct);
		  WaveSize-=sizeof(DLSChunkHdr_Struct);
		  if (!memcmp(ChunkHdr.Id,"LIST",4))
		  {
			memcpy(ListHdr.Type,Wave,sizeof(ListHdr.Type));
		    Wave+=sizeof(ListHdr.Type);
			if (!memcmp(ListHdr.Type,"wave",4))
			  WaveSize=ChunkHdr.Size;
			WaveSize-=sizeof(ListHdr.Type);
		  }
		  else if (!memcmp(ChunkHdr.Id,"fmt ",4))
		  {
		    memcpy(&FmtHdr,Wave,sizeof(DLSFmtHdr_Struct));
		    if (FmtHdr.Format==1)
			{
			  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].C4Speed=(FmtHdr.SamplesPerSec);
			  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=(FmtHdr.Channels==2?0x40:0x00);
			  //glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=(FmtHdr.BitsPerSample==8?0x02:0x00);
			  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=(FmtHdr.BitsPerSample==16?0x04:0x00);
			}
		    Wave+=((ChunkHdr.Size+1)&~1); 	
		    WaveSize-=((ChunkHdr.Size+1)&~1);
		  }
		  else if (!memcmp(ChunkHdr.Id,"wsmp",4))
		  {
		    if (Inst[i]->Reg[j]->Wsmp.Size==0)
			{
		  	  memcpy(&Inst[i]->Reg[j]->Wsmp,Wave,sizeof(DLSWsmpHdr_Struct));
			  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].C4Speed=(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].C4Speed*pow(2.0,(60.0-(Inst[i]->Reg[j]->Wsmp.Note-Inst[i]->Reg[j]->Wsmp.Finetune/100.0))/12.0));
			  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Volume=(32767.0*pow(10.0,(Inst[i]->Reg[j]->Wsmp.Attenuation/(200.0*65536.0))));
			  if (Inst[i]->Reg[j]->Wsmp.Loops==1)
			  {
			    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].LoopStart=Inst[i]->Reg[j]->Wsmp.Loop[0].Start;
			    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].LoopEnd=Inst[i]->Reg[j]->Wsmp.Loop[0].Start+Inst[i]->Reg[j]->Wsmp.Loop[0].Length;
			    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=0x88;
			  }
			  else
			    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type&=~0x88;
			}
		    Wave+=((ChunkHdr.Size+1)&~1); 	
		    WaveSize-=((ChunkHdr.Size+1)&~1);
		  }
		  else if (!memcmp(ChunkHdr.Id,"data",4)) 
		  {
		    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Length=((ChunkHdr.Size/FmtHdr.BlockAlign)*FmtHdr.Channels);
		    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Data=getmem(ChunkHdr.Size+32*FmtHdr.BlockAlign);
		    if ((glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type&4)==0)
              for (smp=0;smp<ChunkHdr.Size;smp++)
			    ((sbyte *)glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Data)[smp]=((ubyte *)Wave)[smp]-128; 
			else
			  memcpy(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Data,Wave,ChunkHdr.Size);
			memset((char *)(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Data)+ChunkHdr.Size,0,32*FmtHdr.BlockAlign);
		    Wave+=((ChunkHdr.Size+1)&~1); 	
		    WaveSize-=((ChunkHdr.Size+1)&~1);
		  }
		  else if (!memcmp(ChunkHdr.Id,"INAM",4))
		  {
            if (ChunkHdr.Size>32)
		      memcpy(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Message,Wave,32);
			else
			  memcpy(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Message,Wave,ChunkHdr.Size);
		    Wave+=((ChunkHdr.Size+1)&~1); 	
		    WaveSize-=((ChunkHdr.Size+1)&~1);
		  }
		  else
		  {
			Wave+=((ChunkHdr.Size+1)&~1);
		    WaveSize-=((ChunkHdr.Size+1)&~1);
		  }
		} while (WaveSize);
	    //process wsmp (region wsmp overrides sample wsmp)
	    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].C4Speed=(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].C4Speed*pow(2.0,(60.0-(Inst[i]->Reg[j]->Wsmp.Note-Inst[i]->Reg[j]->Wsmp.Finetune/100.0))/12.0));
	    glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Volume=(32767.0*pow(10.0,(Inst[i]->Reg[j]->Wsmp.Attenuation/(200.0*65536.0))));
	    if (Inst[i]->Reg[j]->Wsmp.Loops==1)
		{
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].LoopStart=Inst[i]->Reg[j]->Wsmp.Loop[0].Start;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].LoopEnd=Inst[i]->Reg[j]->Wsmp.Loop[0].Start+Inst[i]->Reg[j]->Wsmp.Loop[0].Length;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=0x88;
		}
	    else
	  	  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type&=~0x88;
	    //process local articulation
		if (Inst[i]->Reg[j]->Art1)
		{	
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation=getmem(sizeof(glxArti));
		  memset(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation,0,sizeof(glxArti));
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VibSpeed=64*5;        
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->TremSpeed=64*5;        
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VolFlag=3;       
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VolSize=2;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VolSustain=2;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[0].Time=0;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[0].Value=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[1].Time=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[1].Value=32767;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Time=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Value=32767;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->PitFlag=3;       
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->PitSize=2;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->PitSustain=2;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[0].Time=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[0].Value=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Time=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Value=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Time=0;
          glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Value=0;
		  PitchEnvAmp=0;
		  for (k=0;k<1;k++)
		  {  
			for (l=0;l<Inst[i]->Reg[j]->Art1[k]->ConnectionBlocks;l++)
			{
			  switch (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Destination)
			  {
			    case 0x0001://LFO Attenuation depth
							if ((Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0x0001)&&(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Control==0x0000))
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->TremDepth=(32767.0*(pow(10.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(200.0*65536.0)))-1.0));
							break;
				case 0x0003://LFO Pitch depth
							if ((Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0x0001)&&(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Control==0x0000))
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VibDepth=(256.0*((Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/65536.0)/100.0));
							else if ((Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0x0005)&&(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Control==0x0000))
							  PitchEnvAmp=((256.0*(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/65536.0))/100.0);
							break;
				case 0x0004://Default panning (for drums)
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							{
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Panning=((32767.0*((Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(10.0*65536.0))+50.0))/100.0);
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Type|=32;
							}
							break;
				case 0x0104://LFO Frequency
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VibSpeed=glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->TremSpeed=(64.0*440.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/65536.0-6900.0)/1200.0));
							break;
				case 0x0105://LFO Delay
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VibDelay=glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->TremDelay=(1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))));
							break;
				case 0x0206://EG1 Attack
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							{
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[1].Time=(1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))));
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[1].Value=32767;
							}
							break;
				case 0x0207://EG1 Decay
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Time=((1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))))/(5.0*log(10.0)));
							break;
				case 0x020a://EG1 SustainLev
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Value=(32767.0*pow(10.0,(((96.0*(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(10.0*65536.0)))/100.0)-96.0)/20.0));
							break;
				case 0x0209://EG1 Release
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->VolFadeOut=(32767.0/((1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))))/(5.0*log(10.0))));
							break;
				case 0x030a://EG2 Attack
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							{
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Time=(1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))));
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Value=32767;
							}
							break;
				case 0x030b://EG2 Decay
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Time=((1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))))/(5.0*log(10.0)));
							break;
				case 0x030e://EG2 SustainLev
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Value=((32767.0*(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(10.0*65536.0)))/100);
							break;
				case 0x030d://EG2 Release
							if (Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Source==0)
							  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->PitFadeOut=(32767.0/((1000.0*pow(2.0,(Inst[i]->Reg[j]->Art1[k]->ConnectionBlock[l].Scale/(1200.0*65536.0))))/(5.0*log(10.0))));
							break;
			  }
			}
		  }
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Time=((glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Time*(32767-glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Value))/32768);
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[2].Time+=glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Volume[1].Time;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Time=((glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Time*(32767-glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Value))/32768);
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Time+=glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Time;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Value=(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[1].Value*PitchEnvAmp)>>15;
		  glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Value=(glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples].Articulation->Pitch[2].Value*PitchEnvAmp)>>15;
        }	    
	    glxInstruments[Bank][Ins]->Samples++;
	  }
	  //process GLOBAL articulation
	  if (Inst[i]->Art1)
	  {	
		glxInstruments[Bank][Ins]->Articulation.VibSpeed=64*5;        
		glxInstruments[Bank][Ins]->Articulation.TremSpeed=64*5;        
		glxInstruments[Bank][Ins]->Articulation.VolFlag=3;       
		glxInstruments[Bank][Ins]->Articulation.VolSize=2;
        glxInstruments[Bank][Ins]->Articulation.VolSustain=2;
        glxInstruments[Bank][Ins]->Articulation.Volume[0].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Volume[0].Value=0;
        glxInstruments[Bank][Ins]->Articulation.Volume[1].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Volume[1].Value=32767;
        glxInstruments[Bank][Ins]->Articulation.Volume[2].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Volume[2].Value=32767;
		glxInstruments[Bank][Ins]->Articulation.PitFlag=3;       
		glxInstruments[Bank][Ins]->Articulation.PitSize=2;
        glxInstruments[Bank][Ins]->Articulation.PitSustain=2;
        glxInstruments[Bank][Ins]->Articulation.Pitch[0].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Pitch[0].Value=0;
        glxInstruments[Bank][Ins]->Articulation.Pitch[1].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Pitch[1].Value=0;
        glxInstruments[Bank][Ins]->Articulation.Pitch[2].Time=0;
        glxInstruments[Bank][Ins]->Articulation.Pitch[2].Value=0;
		PitchEnvAmp=0;
		for (j=0;j<1;j++)
		{  
	 	  for (k=0;k<Inst[i]->Art1[j]->ConnectionBlocks;k++)
		  {
		    switch (Inst[i]->Art1[j]->ConnectionBlock[k].Destination)
			{
			  case 0x0001://LFO Attenuation depth
						  if ((Inst[i]->Art1[j]->ConnectionBlock[k].Source==0x0001)&&(Inst[i]->Art1[j]->ConnectionBlock[k].Control==0x0000))
							glxInstruments[Bank][Ins]->Articulation.TremDepth=(32767.0*(pow(10.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(200.0*65536.0)))-1.0));
						  break;
			  case 0x0003://LFO Pitch depth
						  if ((Inst[i]->Art1[j]->ConnectionBlock[k].Source==0x0001)&&(Inst[i]->Art1[j]->ConnectionBlock[k].Control==0x0000))
							glxInstruments[Bank][Ins]->Articulation.VibDepth=(256.0*((Inst[i]->Art1[j]->ConnectionBlock[k].Scale/65536.0)/100.0));
						  else if ((Inst[i]->Art1[j]->ConnectionBlock[k].Source==0x0005)&&(Inst[i]->Art1[j]->ConnectionBlock[k].Control==0x0000))
						    PitchEnvAmp=((256.0*(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/65536.0))/100.0);
						  break;
			  case 0x0104://LFO Frequency
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
							glxInstruments[Bank][Ins]->Articulation.VibSpeed=glxInstruments[Bank][Ins]->Articulation.TremSpeed=(64.0*440.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/65536.0-6900.0)/1200.0));
                          break;
			  case 0x0105://LFO Delay
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						    glxInstruments[Bank][Ins]->Articulation.VibDelay=glxInstruments[Bank][Ins]->Articulation.TremDelay=(1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))));
						  break;
			  case 0x0206://EG1 Attack
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						  {
						    glxInstruments[Bank][Ins]->Articulation.Volume[1].Time=(1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))));
                            glxInstruments[Bank][Ins]->Articulation.Volume[1].Value=32767;
						  }
						  break;
			  case 0x0207://EG1 Decay
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						    glxInstruments[Bank][Ins]->Articulation.Volume[2].Time=((1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))))/(5.0*log(10.0)));
						  break;
			  case 0x020a://EG1 SustainLev
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						    glxInstruments[Bank][Ins]->Articulation.Volume[2].Value=(32767.0*pow(10.0,(((96.0*(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(10.0*65536.0)))/100.0)-96.0)/20.0));
						  break;
			  case 0x0209://EG1 Release
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
                            glxInstruments[Bank][Ins]->Articulation.VolFadeOut=(32767.0/((1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))))/(5.0*log(10.0))));
						  break;
			  case 0x030a://EG2 Attack
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						  {
						    glxInstruments[Bank][Ins]->Articulation.Pitch[1].Time=(1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))));
                            glxInstruments[Bank][Ins]->Articulation.Pitch[1].Value=32767;
						  }
						  break;
			  case 0x030b://EG2 Decay
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
						    glxInstruments[Bank][Ins]->Articulation.Pitch[2].Time=((1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))))/(5.0*log(10.0)));
						  break;
			  case 0x030e://EG2 SustainLev
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
                            glxInstruments[Bank][Ins]->Articulation.Pitch[2].Value=((32767.0*(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(10.0*65536.0)))/100);
						  break;
			  case 0x030d://EG2 Release
						  if (Inst[i]->Art1[j]->ConnectionBlock[k].Source==0)
                            glxInstruments[Bank][Ins]->Articulation.PitFadeOut=(32767.0/((1000.0*pow(2.0,(Inst[i]->Art1[j]->ConnectionBlock[k].Scale/(1200.0*65536.0))))/(5.0*log(10.0))));
						  break;
			}
		  }
	    }
        glxInstruments[Bank][Ins]->Articulation.Volume[2].Time=((glxInstruments[Bank][Ins]->Articulation.Volume[2].Time*(32767-glxInstruments[Bank][Ins]->Articulation.Volume[2].Value))/32768);
		glxInstruments[Bank][Ins]->Articulation.Volume[2].Time+=glxInstruments[Bank][Ins]->Articulation.Volume[1].Time;
        glxInstruments[Bank][Ins]->Articulation.Pitch[2].Time=((glxInstruments[Bank][Ins]->Articulation.Pitch[2].Time*(32767-glxInstruments[Bank][Ins]->Articulation.Pitch[2].Value))/32768);
		glxInstruments[Bank][Ins]->Articulation.Pitch[2].Time+=glxInstruments[Bank][Ins]->Articulation.Pitch[1].Time;
		glxInstruments[Bank][Ins]->Articulation.Pitch[1].Value=(glxInstruments[Bank][Ins]->Articulation.Pitch[1].Value*PitchEnvAmp)>>15;
		glxInstruments[Bank][Ins]->Articulation.Pitch[2].Value=(glxInstruments[Bank][Ins]->Articulation.Pitch[2].Value*PitchEnvAmp)>>15;
	  }
	}
  }
  //Free all temp. allocated memory
  for (i=0;i<ColhHdr.Instruments;i++)
  {
    if (Inst[i]!=NULL)
	{
	  if (Inst[i]->Reg!=NULL)
	  {
	    for (j=0;j<Inst[i]->Hdr.Regions;j++)
		{
          if (Inst[i]->Reg[j]!=NULL)
		  {
	        if (Inst[i]->Reg[j]->Art1!=NULL)
			{
  			  for (k=0;k<1;k++)
			  {
  				if (Inst[i]->Reg[j]->Art1[k]!=NULL)
  				  freemem(Inst[i]->Reg[j]->Art1[k]);  
			  }
			  freemem(Inst[i]->Reg[j]->Art1);
			}
			freemem(Inst[i]->Reg[j]);  
		  }
		}
	    freemem(Inst[i]->Reg);
	  }
	  if (Inst[i]->Art1!=NULL)
	  {
  	    for (j=0;j<1;j++)
   	    {
  	      if (Inst[i]->Art1[j]!=NULL)
  	        freemem(Inst[i]->Art1[j]);  
		}
	    freemem(Inst[i]->Art1);
	  }
	  freemem(Inst[i]);
	}
  }
  freemem(Inst);
  freemem(PtblHdr);
  freemem(WavePool);
  return Status;
}
