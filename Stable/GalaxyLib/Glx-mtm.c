/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at 12:23 on 16-01-1998 -ÄÄ

                         The 32 bit MTM-Loader C source

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
  ³ This source file, GLX-MTM.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* MTM Song-header */
{
  ubyte  Id[3];
  ubyte  Version;
  ubyte  Name[20];
  uword  Tracks;
  ubyte  Patterns;
  ubyte  SongLength;
  uword  CommentLength;
  ubyte  Instruments;
  ubyte  AttributeByte;
  ubyte  BeatsPerTrack;
  ubyte  TracksToPlay;
  ubyte  ChannelInfo[32];
} MTMSongHdr_Struct;

typedef struct                                  /* MTM Pattern-header */
{
  ubyte  Data[(3*64)*32];
} MTMPattHdr_Struct;

typedef struct                                  /* MTM Sample-header */
{
  ubyte  Name[22];
  udword Length;
  udword LoopStart;
  udword LoopEnd;
  ubyte  FineTune;
  ubyte  Volume;
  ubyte  Type;
} MTMSampHdr_Struct;

#pragma pack (pop)				/* Default alignment */

int __cdecl glxLoadMTM(void *Module)
{
  uword Finetuning[16]={8363, 8413, 8463, 8529, 8581, 8651, 8723, 8757,
			7895, 7941, 7985, 8046, 8107, 8169, 8232, 8280};
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Note,Instr,Command,CommandInfo;
  int ChannelCount;
  int InstNo,SampleNo,PatternNo,ChannelNo;
  MTMSongHdr_Struct *SongHdr;
  MTMSampHdr_Struct *SampHdr;
  MTMPattHdr_Struct *PattHdr;
  uword *TrackSequenceBuffer;
  udword FileHeaderPos;
  int Status,PatternRow;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(MTMSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(MTMSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(MTMPattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  FileHeaderPos=tell(Module);
  read(SongHdr,1,sizeof(MTMSongHdr_Struct),Module);
  memcpy(glxSongName,SongHdr->Name,20);
  glxSongLength=SongHdr->SongLength;
  ChannelCount=32;
  for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
    glxInitialPanning[ChannelNo]=SongHdr->ChannelInfo[ChannelNo]<<3;
  //Load instruments(=samples)
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
  {
    read(SampHdr,1,sizeof(MTMSampHdr_Struct),Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,22);
    memset(glxInstruments[0][InstNo]->Split,0,128);
    glxInstruments[0][InstNo]->Samples=1;
    glxInstruments[0][InstNo]->Sample[0].Length=SampHdr->Length;
    glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
    glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
    glxInstruments[0][InstNo]->Sample[0].C4Speed=Finetuning[SampHdr->FineTune&15];
    glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
    glxInstruments[0][InstNo]->Sample[0].Volume=SampHdr->Volume<<9;
	if (glxInstruments[0][InstNo]->Sample[0].Volume>GLX_MAXSMPVOLUME)
	  glxInstruments[0][InstNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;		
    glxInstruments[0][InstNo]->Sample[0].Type=((SampHdr->Type&1)<<2)|2;
    if (glxInstruments[0][InstNo]->Sample[0].Type&4)
    {
      glxInstruments[0][InstNo]->Sample[0].Length>>=1;
      glxInstruments[0][InstNo]->Sample[0].LoopStart>>=1;
      glxInstruments[0][InstNo]->Sample[0].LoopEnd>>=1;
    }
    if (glxInstruments[0][InstNo]->Sample[0].LoopEnd>2)
      glxInstruments[0][InstNo]->Sample[0].Type|=128|8;
    glxInstruments[0][InstNo]->Sample[0].Reserved=0;
  }
  read(glxOrders,1,128,Module);
  TrackSequenceBuffer=getmem(16384);
  seek(Module,FileHeaderPos+(194+(SongHdr->Instruments*37)+(SongHdr->Tracks*192)),SEEK_SET);
  read(TrackSequenceBuffer,1,(SongHdr->Patterns+1)*32*2,Module);
  //Load patterns(=note data)
  for (PatternNo=0;PatternNo<(SongHdr->Patterns+1);PatternNo++)
  {
    memset(PattHdr,0,6144);
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
    for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
      if (TrackSequenceBuffer[PatternNo*32+ChannelNo])
      {
        seek(Module,FileHeaderPos+(194+(SongHdr->Instruments*37)+(TrackSequenceBuffer[PatternNo*32+ChannelNo]-1)*192),SEEK_SET);
        read(PattHdr->Data+ChannelNo*192,1,192,Module);
      }
    for (PatternRow=0;PatternRow<64;PatternRow++)
    {
      PatternSrcPtr=PattHdr->Data+PatternRow*3;
      for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
      {
        Note=((PatternSrcPtr[0]&252)>>2);
        Instr=(((PatternSrcPtr[0]&3)<<4)+((PatternSrcPtr[1]&240)>>4));
        Command=(PatternSrcPtr[1]&15);
        CommandInfo=PatternSrcPtr[2];
        if (Note)
          Note+=37;
        if (Command==0x0c)
		{
		  if (CommandInfo>64)
			CommandInfo=64;
		  CommandInfo<<=1;
		  if (CommandInfo>127)
			CommandInfo=127;
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
        PatternSrcPtr+=192;
      }
      *PatternDestPtr++=0;
    }
    glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
  }
  freemem(TrackSequenceBuffer);
  seek(Module,FileHeaderPos+(194+(SongHdr->Instruments*37)+(SongHdr->Tracks*192)+((SongHdr->Patterns+1)*32*2)+SongHdr->CommentLength),SEEK_SET);
  //Load samples (for each instrument)
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
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
  freemem(SongHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
