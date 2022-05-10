/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at 12:44 on 16-01-1998 -ÄÄ

                         The 32 bit ULT-Loader C source

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
  ³ This source file, GLX-ULT.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* ULT File-header */
{
  ubyte  Id[14];
  ubyte  Version;
  ubyte  Name[32];
  ubyte  Reserved;
  ubyte  SongText[];
} ULTFileHdr_Struct;

typedef struct                                  /* ULT Song-header */
{
  ubyte  Orders[256];
  ubyte  Channels;
  ubyte  Patterns;
  ubyte  ChannelInfo[];
} ULTSongHdr_Struct;

typedef struct                                  /* ULT Pattern-header */
{
  ubyte  Track[320];
  ubyte  Data[(5*32)*64];
} ULTPattHdr_Struct;

typedef struct                                  /* ULT Sample-header */
{
  ubyte  Name[32];
  ubyte  DOSName[12];
  udword LoopStart;
  udword LoopEnd;
  udword SizeStart;
  udword SizeEnd;
  ubyte  Volume;
  ubyte  Type;
  sword  FineTune;
  uword  C2Speed[];
} ULTSampHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadULT(void *Module)
{
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Command1,Command2,CommandInfo1,CommandInfo2;
  ubyte Note,Instr,Command,CommandInfo;
  int InstNo,SampleNo,PatternNo,ChannelNo;
  int Status,PatternRow,TrackSize;
  int InstCount,SampleCount;
  ULTFileHdr_Struct *FileHdr;
  ULTSongHdr_Struct *SongHdr;
  ULTSampHdr_Struct *SampHdr;
  ULTPattHdr_Struct *PattHdr;
  struct
  {
    udword Offset;
    udword Size;
  } *TrackOffset;

  //Grab some memory for the headers
  if ((FileHdr=getmem(sizeof(ULTFileHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SongHdr=getmem(sizeof(ULTSongHdr_Struct)+32))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(ULTSampHdr_Struct)+2))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(ULTPattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  read(FileHdr,1,sizeof(ULTFileHdr_Struct),Module);
  seek(Module,FileHdr->Reserved*32,SEEK_CUR);
  if (FileHdr->Version>'4')
    return GLXERR_UNSUPPORTEDFORMAT;
  memcpy(glxSongName,FileHdr->Name,32);
  SampleNo=SampleCount=InstCount=0;
  //Load instruments(=samples)
  read(&InstCount,1,1,Module);
  for (InstNo=0;InstNo<InstCount;InstNo++)
  {
    SampHdr->C2Speed[0]=8363;
    read(SampHdr,1,sizeof(ULTSampHdr_Struct),Module);
    if (FileHdr->Version>='4')
      read(SampHdr->C2Speed,1,2,Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,28);
    memset(glxInstruments[0][InstNo]->Split,0,128);
    glxInstruments[0][InstNo]->Samples=1;
    glxInstruments[0][InstNo]->Sample[0].Length=(SampHdr->SizeEnd-SampHdr->SizeStart);
    glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
    glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
    glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
    glxInstruments[0][InstNo]->Sample[0].Volume=SampHdr->Volume<<7;
    glxInstruments[0][InstNo]->Sample[0].Type=128|(SampHdr->Type&28);
    glxInstruments[0][InstNo]->Sample[0].Reserved=0;
    glxInstruments[0][InstNo]->Sample[0].C4Speed=SampHdr->C2Speed[0]+SampHdr->FineTune;
    if (glxInstruments[0][InstNo]->Sample[0].Type&4)
    {
      glxInstruments[0][InstNo]->Sample[0].LoopStart>>=1;
      glxInstruments[0][InstNo]->Sample[0].LoopEnd>>=1;
    }
    SampleCount++;
    SampleNo++;
  }
  read(SongHdr,1,sizeof(ULTSongHdr_Struct),Module);
  memcpy(glxOrders,SongHdr->Orders,256);
  memset(SongHdr->ChannelInfo,7,32);
  if (FileHdr->Version>='3')
    read(SongHdr->ChannelInfo,1,SongHdr->Channels+1,Module);
  for (ChannelNo=0;ChannelNo<SongHdr->Channels+1;ChannelNo++)
    glxInitialPanning[ChannelNo]=SongHdr->ChannelInfo[ChannelNo]<<3;
  glxSongLength=0;
  while (glxOrders[glxSongLength]!=255)
    glxSongLength++;
  glxSongLength--;
  //Build track offset and size list
  TrackOffset=getmem((SongHdr->Channels+1)*(SongHdr->Patterns+1)*8);
  for (ChannelNo=0;ChannelNo<SongHdr->Channels+1;ChannelNo++)
    for (PatternNo=0;PatternNo<SongHdr->Patterns+1;PatternNo++)
    {
      TrackOffset[ChannelNo*(SongHdr->Patterns+1)+PatternNo].Offset=tell(Module);
      TrackSize=0;
      PatternRow=0;
      read(PattHdr->Track,1,320,Module);
      while (PatternRow<64)
      {
        if (PattHdr->Track[TrackSize]==0xFC)
        {
          PatternRow+=PattHdr->Track[TrackSize+1];
          TrackSize+=7;
        }
        else
        {
          PatternRow++;
          TrackSize+=5;
        }
      }
      seek(Module,TrackSize-320,SEEK_CUR);
      TrackOffset[ChannelNo*(SongHdr->Patterns+1)+PatternNo].Size=TrackSize;
    }
  //Load patterns(=note data)
  for (PatternNo=0;PatternNo<SongHdr->Patterns+1;PatternNo++)
  {
    //Get and expand pattern data
    for (ChannelNo=0;ChannelNo<SongHdr->Channels+1;ChannelNo++)
    {
      TrackSize=0;
      PatternRow=0;
      seek(Module,TrackOffset[ChannelNo*(SongHdr->Patterns+1)+PatternNo].Offset,SEEK_SET);
      read(PattHdr->Track,1,TrackOffset[ChannelNo*(SongHdr->Patterns+1)+PatternNo].Size,Module);
      while (PatternRow<64)
      {
        if (PattHdr->Track[TrackSize]==0xFC)
        {
          while (PattHdr->Track[TrackSize+1]--)
          {
            memcpy(PattHdr->Data+PatternRow*5+ChannelNo*320,PattHdr->Track+TrackSize+2,5);
            PatternRow++;
          }
          TrackSize+=7;
        }
        else
        {
          memcpy(PattHdr->Data+PatternRow*5+ChannelNo*320,PattHdr->Track+TrackSize,5);
          PatternRow++;
          TrackSize+=5;
        }
      }
    }
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
	if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*32+1)*64+1)))
      return GLXERR_OUTOFPATTERNMEM;
	//Parse pattern
    *PatternDestPtr++=63;
    for (PatternRow=0;PatternRow<64;PatternRow++)
    {
      PatternSrcPtr=PattHdr->Data+PatternRow*5;
      for (ChannelNo=0;ChannelNo<SongHdr->Channels+1;ChannelNo++)
      {
        Note=PatternSrcPtr[0];
        Instr=PatternSrcPtr[1];
        Command1=PatternSrcPtr[2]>>4;
        Command2=PatternSrcPtr[2]&15;
        CommandInfo1=PatternSrcPtr[4];
        CommandInfo2=PatternSrcPtr[3];
        if ((Note>0)&&(Note<73))
          Note+=36;
        else
          Note=0;
        Command=(Command1>Command2)?Command1:Command2;
        CommandInfo=(Command1>Command2)?CommandInfo1:CommandInfo2;
        switch (Command)
        {
          case 0x05: Command=CommandInfo=0; break;
          case 0x09: CommandInfo<<=2; break;
          case 0x0b: Command=0x0e; CommandInfo=(0x80|(CommandInfo&15)); break;
          case 0x0c: CommandInfo>>=1; break;
          case 0x0e: if ((CommandInfo&240)==0x80)
                       CommandInfo=(0xe0|(CommandInfo&15));
        }
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
        if (*PatternFlagPtr&224)
          glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
        else
          PatternDestPtr=PatternFlagPtr;
        PatternSrcPtr+=320;
      }
      *PatternDestPtr++=0;
    }
    glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
  }
  freemem(TrackOffset);
  //Load samples (for each instrument)
  for (InstNo=0;InstNo<InstCount;InstNo++)
    for (SampleNo=0;SampleNo<glxInstruments[0][InstNo]->Samples;SampleNo++)
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
        return Status;
  //Set global player variables
  glxPlayerMode=1|2;
  glxInitialSpeed=6;
  glxInitialTempo=125;
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
