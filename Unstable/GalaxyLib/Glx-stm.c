/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at 12:37 on 16-01-1998 -ÄÄ

                         The 32 bit STM-Loader C source

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
  ³ This source file, GLX-STM.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

#pragma pack (push,1) 				/* Turn off alignment */

typedef struct                                  /* STM Song-header */
{
  ubyte  Name[20];
  ubyte  Id[8];
  ubyte  EOFMarker;
  ubyte  Reserved1[4];
  ubyte  Patterns;
  ubyte  Volume;
  ubyte  Reserved2[13];
} STMSongHdr_Struct;

typedef struct                                  /* STM Pattern-header */
{
  ubyte  Data[(4*4)*64];
} STMPattHdr_Struct;

typedef struct                                  /* STM Sample-header */
{
  ubyte  Name[12];
  uword  Reserved1;
  uword  MemSeg;
  uword  Length;
  uword  LoopStart;
  uword  LoopEnd;
  ubyte  Volume;
  ubyte  Reserved2;
  uword  C4Speed;
  ubyte  Reserved3[6];
} STMSampHdr_Struct;

#pragma pack (pop)				/* Default alignment */

int __cdecl glxLoadSTM(void *Module)
{
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Note,Instr,Command,CommandInfo,VolumeByte;
  int InstCount,SampleCount,ChannelCount;
  int InstNo,SampleNo,PatternNo,ChannelNo,OrderNo;
  STMSongHdr_Struct *SongHdr;
  STMSampHdr_Struct *SampHdr;
  STMPattHdr_Struct *PattHdr;
  int Status,PatternRow;
  udword SampleFilePos[31];
  udword FileHeaderPos;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(STMSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(STMSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(STMPattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  FileHeaderPos=tell(Module);
  read(SongHdr,1,sizeof(STMSongHdr_Struct),Module);
  memcpy(glxSongName,SongHdr->Name,20);
  glxMusicVolume=SongHdr->Volume<<1;
  if (glxMusicVolume>127)
    glxMusicVolume=127;
  InstCount=31;
  ChannelCount=4;
  SampleNo=OrderNo=SampleCount=0;
  for (InstNo=0;InstNo<InstCount;InstNo++)
  {
    read(SampHdr,1,sizeof(STMSampHdr_Struct),Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
	glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,12);
    memset(glxInstruments[0][InstNo]->Split,0,128);
    glxInstruments[0][InstNo]->Samples=1;
    SampleFilePos[SampleNo]=SampHdr->MemSeg<<4;
    glxInstruments[0][InstNo]->Sample[0].Length=SampHdr->Length;
    glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
    glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
    glxInstruments[0][InstNo]->Sample[0].C4Speed=SampHdr->C4Speed;
    glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
    glxInstruments[0][InstNo]->Sample[0].Volume=SampHdr->Volume<<9;
	if (glxInstruments[0][InstNo]->Sample[0].Volume>GLX_MAXSMPVOLUME)
	  glxInstruments[0][InstNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;
    glxInstruments[0][InstNo]->Sample[0].Type=0;
    if (glxInstruments[0][InstNo]->Sample[0].LoopEnd!=65535)
      glxInstruments[0][InstNo]->Sample[0].Type=(128|8);
    glxInstruments[0][InstNo]->Sample[0].Reserved=0;
    SampleCount++;
    SampleNo++;
  }
  read(glxOrders,1,128,Module);
  while (glxOrders[OrderNo]!=99)
    OrderNo++;
  glxSongLength=(OrderNo-1);
  for (PatternNo=0;PatternNo<SongHdr->Patterns;PatternNo++)
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
	if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*4+1)*64+1)))
      return GLXERR_OUTOFPATTERNMEM;
	//Parse pattern
    *PatternDestPtr++=63;
    read(PatternSrcPtr,1,64*4*4,Module);
    for (PatternRow=0;PatternRow<64;PatternRow++)
    {
      for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
      {
        Note=PatternSrcPtr[0];
        Instr=(PatternSrcPtr[1]>>3);
        VolumeByte=(((PatternSrcPtr[1]&7)+((PatternSrcPtr[2]&240)>>1))<<1);
        Command=(PatternSrcPtr[2]&15);
        CommandInfo=PatternSrcPtr[3];
        if (Note)
          Note=((Note>>4)*12)+(Note&15)+36+1;
		if (VolumeByte>127)
		  VolumeByte=127;
        PatternFlagPtr=PatternDestPtr++;
        *PatternFlagPtr=ChannelNo;
        switch (Command)
        {
          case 1  : Command=0x0f; CommandInfo>>=4; break;
          case 2  : Command=0x0b; break;
          case 3  : Command=0x0d; break;
          case 4  : Command=0x0a; break;
          case 5  : Command=0x02; break;
          case 6  : Command=0x01; break;
          case 7  : Command=0x07; break;
          case 8  : Command=0x08; break;
          case 10 : Command=0x00; break;
          case 12 : Command=0x07; break;
          default : Command=CommandInfo=0; break;
        }
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
        if (VolumeByte<=64)
        {
          *PatternDestPtr++=VolumeByte;
          *PatternFlagPtr|=32;
        }
        if (*PatternFlagPtr&224)
          glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
        else
          PatternDestPtr=PatternFlagPtr;
        PatternSrcPtr+=4;
      }
      *PatternDestPtr++=0;
    }
    glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
  }
  //Load samples (for each instrument)
  for (InstNo=0;InstNo<InstCount;InstNo++)
    for (SampleNo=0;SampleNo<(glxInstruments[0][InstNo]->Samples&127);SampleNo++)
    {
      seek(Module,FileHeaderPos+SampleFilePos[InstNo],SEEK_SET);
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
        return Status;
    }
  for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
    glxInitialPanning[ChannelNo]=GLX_MIDINSPANNING;
  //Set global player variables
  glxPlayerMode=1|2;
  glxInitialSpeed=6;
  glxInitialTempo=125;
  glxMusicVoices++;
  glxMinPeriod=1814;
  glxMaxPeriod=13696;
  //Release header memory
  freemem(SongHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
