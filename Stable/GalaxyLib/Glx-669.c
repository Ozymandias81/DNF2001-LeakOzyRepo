/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at  1:46 on 16-01-1998 -ÄÄ

                         The 32 bit 669-Loader C source

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
  ³ This source file, GLX-669.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* 669 Song-header */
{
  ubyte  Id[2];
  ubyte  Name[108];
  ubyte  Instruments;
  ubyte  Patterns;
  ubyte  RestartPos;
  ubyte  Orders[128];
  ubyte  Speeds[128];
  ubyte  PatternLengths[128];
  ubyte  Samples[];
} E669SongHdr_Struct;

typedef struct                                  /* 669 Pattern-header */
{
  ubyte  Data[(3*8)*64];
} E669PattHdr_Struct;

typedef struct                                  /* 669 Sample-header */
{
  ubyte  Name[13];
  udword Length;
  udword LoopStart;
  udword LoopEnd;
} E669SampHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoad669(void *Module)
{
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Note,Instr,Volume,Command,CommandInfo;
  int InstNo,SampleNo,PatternNo,ChannelNo;
  int ChannelCount;
  E669SongHdr_Struct *SongHdr;
  E669SampHdr_Struct *SampHdr;
  E669PattHdr_Struct *PattHdr;
  int Status,PatternRow;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(E669SongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(E669SampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(E669PattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  read(SongHdr,1,sizeof(E669SongHdr_Struct),Module);
  memcpy(glxSongName,SongHdr->Name,32);
  memcpy(glxOrders,SongHdr->Orders,128);
  ChannelCount=8;
  //Load instruments(=samples)
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
  {
    read(SampHdr,1,sizeof(E669SampHdr_Struct),Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,13);
    memset(glxInstruments[0][InstNo]->Split,0,128);
    glxInstruments[0][InstNo]->Samples=1;
    glxInstruments[0][InstNo]->Sample[0].Length=SampHdr->Length;
    glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
    glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
    glxInstruments[0][InstNo]->Sample[0].C4Speed=8448;
    glxInstruments[0][InstNo]->Sample[0].Volume=60<<9;
    glxInstruments[0][InstNo]->Sample[0].Type=2;
    if (glxInstruments[0][InstNo]->Sample[0].LoopEnd!=0x0fffff)
      glxInstruments[0][InstNo]->Sample[0].Type|=128|8;
    glxInstruments[0][InstNo]->Sample[0].Reserved=0;
  }
  glxSongLength=0;
  while (glxOrders[glxSongLength]!=255)
    glxSongLength++;
  glxSongLength--;
  //Load patterns(=note data)
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
	if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*8+1)*64+1)))
      return GLXERR_OUTOFPATTERNMEM;
	//Parse pattern
    *PatternDestPtr++=SongHdr->PatternLengths[PatternNo]++;
    read(PatternSrcPtr,1,64*3*8,Module);
    for (PatternRow=0;PatternRow<SongHdr->PatternLengths[PatternNo];PatternRow++)
    {
      for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
      {
        Note=((PatternSrcPtr[0]&253)>>2)+37;
        Instr=(((PatternSrcPtr[0]&3)<<4)|((PatternSrcPtr[1]&240)>>4))+1;
        Volume=((PatternSrcPtr[1]&15)<<3);
        Command=((PatternSrcPtr[2]&240)>>4);
        CommandInfo=(PatternSrcPtr[2]&15);
        if (PatternSrcPtr[0]==0xfe)
          Note=Instr=0;
        if (PatternSrcPtr[0]==0xff)
        {
          Note=Instr=0;
          Volume=255;
        }
        if (PatternSrcPtr[2]==0xff)
          Command=CommandInfo=0;
        if ((PatternRow==0)&&(ChannelNo==0))
        {
          Command=5;
          CommandInfo=SongHdr->Speeds[PatternNo];
        }
        PatternSrcPtr+=3;
        PatternFlagPtr=PatternDestPtr++;
        *PatternFlagPtr=ChannelNo;
        switch (Command)
        {
          case 0  : Command=0x01; break;
          case 1  : Command=0x02; break;
          case 2  : Command=0x03; break;
          case 3  : Command=0x0e; CommandInfo|=0x10; break;
          case 4  : Command=0x04; CommandInfo=(CommandInfo<<4)|1; break;
          case 5  : Command=0x0f; break;
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
  //Load samples (for each instrument)
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
    for (SampleNo=0;SampleNo<glxInstruments[0][InstNo]->Samples;SampleNo++)
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
        return Status;
  for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo+=2)
  {
    glxInitialPanning[ChannelNo]=26;
    glxInitialPanning[ChannelNo+1]=102;
  }
  //Set global player variables
  glxPlayerMode=0|2;
  glxInitialSpeed=3;
  glxInitialTempo=80;
  glxMusicVoices++;
  glxMinPeriod=1814;
  glxMaxPeriod=13696;
  //Release header memory
  freemem(SongHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
