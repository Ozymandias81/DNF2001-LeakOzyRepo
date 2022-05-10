/*Ä- Internal revision no. 3.01b1 -ÄÄÄ Last revision at  2:09 on 13-01-1998 -ÄÄ

                         The 32 bit FAR-Loader C source

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
  ³ This source file, GLX-FAR.C is Copyright  (c)  1993-98 by Carlo Vogelsang ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"
#include "hdr\glx-smp.h"

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* FAR File-header */
{
  ubyte  Id[4];
  ubyte  Name[40];
  ubyte  EOFMarker[3];
  uword  RemHdrLength;
  ubyte  Version;
  ubyte  ChannelMap[16];
  ubyte  CurrentOctave;
  ubyte  CurrentVoice;
  ubyte  CurrentRow;
  ubyte  CurrentPattern;
  ubyte  CurrentOrder;
  ubyte  CurrentSample;
  ubyte  CurrentVolume;
  ubyte  CurrentTopScreen;
  ubyte  CurrentArea;
  ubyte  Speed;
  ubyte  ChannelPan[16];
  ubyte  MarkTop;
  ubyte  MarkBottom;
  ubyte  GridGran;
  ubyte  EditMode;
  uword  SongTextLength;
  ubyte  SongText[];
} FARFileHdr_Struct;

typedef struct                                  /* FAR Song-header */
{
  ubyte  Orders[256];
  ubyte  Patterns;
  ubyte  SongLength;
  ubyte  RestartPos;
  uword  PatternSizes[256];
} FARSongHdr_Struct;

typedef struct                                  /* FAR Pattern-header */
{
  ubyte  Rows;
  ubyte  Speed;
  ubyte  Data[];
} FARPattHdr_Struct;

typedef struct                                  /* FAR Sample-header */
{
  ubyte  Name[32];
  udword Length;
  ubyte  FineTune;
  ubyte  Volume;
  udword LoopStart;
  udword LoopEnd;
  ubyte  Type;
  ubyte  LoopType;
} FARSampHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadFAR(void *Module)
{
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Note,Instr,Volume,Command,CommandInfo;
  int InstCount,ChannelCount;
  int InstNo,PatternNo,ChannelNo;
  FARFileHdr_Struct *FileHdr;
  FARSongHdr_Struct *SongHdr;
  FARSampHdr_Struct *SampHdr;
  FARPattHdr_Struct *PattHdr;
  int Status,PatternRow;
  ubyte SampMap[8];

  //Grab some memory for the headers
  if ((FileHdr=getmem(sizeof(FARFileHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SongHdr=getmem(sizeof(FARSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(FARSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(FARPattHdr_Struct)+((4*16)*64)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  read(FileHdr,1,sizeof(FARFileHdr_Struct),Module);
  seek(Module,FileHdr->SongTextLength,SEEK_CUR);
  memcpy(glxSongName,FileHdr->Name,32);
  ChannelCount=16;
  for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
    glxInitialPanning[ChannelNo]=(FileHdr->ChannelPan[ChannelNo]<<3);
  read(SongHdr,1,sizeof(FARSongHdr_Struct),Module);
  seek(Module,FileHdr->RemHdrLength-(869+FileHdr->SongTextLength),SEEK_CUR);
  memcpy(glxOrders,SongHdr->Orders,256);
  glxSongLength=SongHdr->SongLength-1;
  InstCount=64;
  //Load patterns(=note data)
  for (PatternNo=0;PatternNo<255;PatternNo++)
  {
    if (SongHdr->PatternSizes[PatternNo])
    {
      PatternSrcPtr=PattHdr->Data;
	  //Initialise pattern
	  glxPatterns[PatternNo]=getmem(sizeof(glxPattern)+sizeof(glxTrack));
	  memset(glxPatterns[PatternNo],0,sizeof(glxPattern)+sizeof(glxTrack));
	  glxPatterns[PatternNo]->FourCC=GLX_FOURCC_PATT;
	  glxPatterns[PatternNo]->Size=2+sizeof(glxTrack);
	  glxPatterns[PatternNo]->Tracks=1;
	  //Grab memory for track
	  glxPatterns[PatternNo]->Track[0].FourCC=GLX_FOURCC_TRAK;
	  glxPatterns[PatternNo]->Track[0].Size=sizeof(glxTrack)-8;
	  if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*16+1)*64+1)))
        return GLXERR_OUTOFPATTERNMEM;
	  //Parse pattern
      read(PattHdr,1,SongHdr->PatternSizes[PatternNo],Module);
      *PatternDestPtr++=(PattHdr->Rows+2-1);
      for (PatternRow=0;PatternRow<PattHdr->Rows+2;PatternRow++)
      {
        for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
        {
          Note=PatternSrcPtr[0];
          Volume=((((PatternSrcPtr[2]-1)<<2)|((PatternSrcPtr[2]-1)>>6))<<1);
          Command=((PatternSrcPtr[3]&240)>>4);
          CommandInfo=(PatternSrcPtr[3]&15);
          if (Note)
          {
       	    Note+=48;
            Instr=(PatternSrcPtr[1]+1);
          }
          else
            Instr=0;
		  if (Volume>127)
			Volume=127;
          if ((PatternRow==0)&&(ChannelNo==0))
          {
            Command=0x0f;
            CommandInfo=PattHdr->Speed;
          }
          if (Command!=0x0f)
            Command=CommandInfo=0;
          PatternSrcPtr+=4;
          PatternFlagPtr=PatternDestPtr++;
          *PatternFlagPtr=ChannelNo;
          if (Command||CommandInfo)
       	  {
            *PatternDestPtr++=CommandInfo;
            *PatternDestPtr++=Command;
            *PatternFlagPtr|=128;
          }
          if (Note||Instr)
          {
            *PatternDestPtr++=Instr;
            *PatternDestPtr++=Note;
            *PatternFlagPtr|=64;
          }
          if (Volume!=255)
          {
            *PatternDestPtr++=Volume;
            *PatternFlagPtr|=32;
          }
          if (*PatternFlagPtr&224)
            glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
          else
            PatternDestPtr=PatternFlagPtr;
        }
        *PatternDestPtr++=0;
      }
      glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
    }
  }
  //Load instruments(=samples)
  read(SampMap,1,8,Module);
  for (InstNo=0;InstNo<InstCount;InstNo++)
  {
    if ((SampMap[InstNo>>3])&(1<<(InstNo%8)))
    {
      read(SampHdr,1,sizeof(FARSampHdr_Struct),Module);
      if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
        return GLXERR_OUTOFMEMORY;
      memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
      glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
      glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
      glxInstruments[0][InstNo]->Program=InstNo;
      memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,28);
      memset(glxInstruments[0][InstNo]->Split,0,128);
      glxInstruments[0][InstNo]->Samples=1;
      glxInstruments[0][InstNo]->Sample[0].Length=SampHdr->Length;
      glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
      glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
      glxInstruments[0][InstNo]->Sample[0].C4Speed=8287;
      glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
	  glxInstruments[0][InstNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;
      glxInstruments[0][InstNo]->Sample[0].Type=128|((SampHdr->Type&1)<<2)|(SampHdr->LoopType&8);
      glxInstruments[0][InstNo]->Sample[0].Reserved=0;
      if (glxInstruments[0][InstNo]->Sample[0].Type&4)
      {
        glxInstruments[0][InstNo]->Sample[0].Length>>=1;
        glxInstruments[0][InstNo]->Sample[0].LoopStart>>=1;
        glxInstruments[0][InstNo]->Sample[0].LoopEnd>>=1;
      }
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[0]),Module))
        return Status;
    }
  }
  //Set global player variables
  glxPlayerMode=0|2;
  glxInitialSpeed=FileHdr->Speed;
  glxInitialTempo=80;
  glxMusicVoices++;
  glxMinPeriod=1814;
  glxMaxPeriod=13696;
  //Release header memory
  freemem(FileHdr);
  freemem(SongHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
