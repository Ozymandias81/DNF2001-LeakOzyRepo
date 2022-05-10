/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at 12:24 on 16-01-1998 -ÄÄ

                         The 32 bit PTM-Loader C source

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
  ³ This source file, GLX-PTM.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* PTM Song-header */
{
  ubyte  Name[28];
  ubyte  EOFMarker;
  uword  Version;
  ubyte  Reserved1;
  uword  SongLength;
  uword  Instruments;
  uword  Patterns;
  uword  Channels;
  uword  Flags;
  uword  Reserved2;
  ubyte  Id[4];
  ubyte  Reserved3[16];
  ubyte  ChannelInfo[32];
  ubyte  Orders[256];
  uword  PattSeg[128];
} PTMSongHdr_Struct;

typedef struct                                  /* PTM Pattern-header */
{
  ubyte  Data[((6*32+1)*64)];
} PTMPattHdr_Struct;

typedef struct                                  /* PTM Sample-header */
{
  ubyte  Type;
  ubyte  DOSName[12];
  ubyte  Volume;
  uword  C4Speed;
  uword  MemSeg;
  udword Offset;
  udword Length;
  udword LoopStart;
  udword LoopEnd;
  udword GUSBegin;
  udword GUSLoopStart;
  udword GUSLoopEnd;
  ubyte  GUSLoop;
  ubyte  Reserved1;
  ubyte  Name[28];
  ubyte  Id[4];
} PTMSampHdr_Struct;

#pragma pack (pop)				/* Default alignment */

int __cdecl glxLoadPTM(void *Module)
{
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Flag,Note,Instr,Command,CommandInfo,VolumeByte;
  ubyte PTMVolumeByte;
  int InstNo,SampleNo,PatternNo,ChannelNo,OrderNo;
  PTMSongHdr_Struct *SongHdr;
  PTMSampHdr_Struct *SampHdr;
  PTMPattHdr_Struct *PattHdr;
  int Status,PatternRow;
  ubyte OldCommand[32],OldCommandInfo[32];
  udword FileHeaderPos,InsHeaderPos;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(PTMSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(PTMSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(PTMPattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  FileHeaderPos=tell(Module);
  read(SongHdr,1,sizeof(PTMSongHdr_Struct),Module);
  if (SongHdr->Version!=0x203)
    return GLXERR_UNSUPPORTEDFORMAT;
  memcpy(glxSongName,SongHdr->Name,28);
  glxSongLength=(SongHdr->SongLength-1);
  memcpy(glxOrders,SongHdr->Orders,256);
  for (ChannelNo=0;ChannelNo<SongHdr->Channels;ChannelNo++)
    glxInitialPanning[ChannelNo]=SongHdr->ChannelInfo[ChannelNo]<<3;
  //Load instruments(=samples)
  SampleNo=0;
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
  {
    read(SampHdr,1,sizeof(PTMSampHdr_Struct),Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,28);
    if (SampHdr->Type&1)
    {
      memset(&(glxInstruments[0][InstNo]->Sample[0]),0,sizeof(glxSample));
      glxInstruments[0][InstNo]->Samples=1;
      memset(glxInstruments[0][InstNo]->Split,0,128);
      memcpy(glxInstruments[0][InstNo]->Sample[0].Message,SampHdr->Name,28);
      glxInstruments[0][InstNo]->Sample[0].Length=SampHdr->Length;
      glxInstruments[0][InstNo]->Sample[0].LoopStart=SampHdr->LoopStart;
      glxInstruments[0][InstNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
	  glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
      glxInstruments[0][InstNo]->Sample[0].Volume=SampHdr->Volume<<9;
	  if (glxInstruments[0][InstNo]->Sample[0].Volume>GLX_MAXSMPVOLUME)
		glxInstruments[0][InstNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;
      glxInstruments[0][InstNo]->Sample[0].Type=128|1;
      glxInstruments[0][InstNo]->Sample[0].Type|=(SampHdr->Type&16)>>2;
      glxInstruments[0][InstNo]->Sample[0].Type|=(SampHdr->Type&12)<<1;
      glxInstruments[0][InstNo]->Sample[0].Reserved=0;
      glxInstruments[0][InstNo]->Sample[0].C4Speed=SampHdr->C4Speed;
      if (glxInstruments[0][InstNo]->Sample[0].Type&4)
      {
        glxInstruments[0][InstNo]->Sample[0].Length>>=1;
        glxInstruments[0][InstNo]->Sample[0].LoopStart>>=1;
        glxInstruments[0][InstNo]->Sample[0].LoopEnd>>=1;
      }
      InsHeaderPos=tell(Module);
      if (SampleNo==0)
        SongHdr->PattSeg[SongHdr->Patterns]=(unsigned short)(SampHdr->Offset>>4);
      seek(Module,FileHeaderPos+(SampHdr->Offset),SEEK_SET);
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[0]),Module))
        return Status;
      seek(Module,FileHeaderPos+InsHeaderPos,SEEK_SET);
      SampleNo++;
    }
  }
  memset(OldCommand,0,32);
  memset(OldCommandInfo,0,32);
  //Load patterns(=note data)
  for (OrderNo=0;OrderNo<=glxSongLength;OrderNo++)
  {
    PatternNo=glxOrders[OrderNo];
    if ((PatternNo<254)&&(glxPatterns[PatternNo]==NULL))
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
	  if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*32+1)*64+1)))
        return GLXERR_OUTOFPATTERNMEM;
	  //Parse pattern
      *PatternDestPtr++=63;
      seek(Module,FileHeaderPos+(SongHdr->PattSeg[PatternNo]<<4),SEEK_SET);
      read(PatternSrcPtr,1,(SongHdr->PattSeg[PatternNo+1]-SongHdr->PattSeg[PatternNo])<<4,Module);
      for (PatternRow=0;PatternRow<64;PatternRow++)
      {
        while (PatternSrcPtr[0])
        {
          VolumeByte=255;
          Note=Instr=Command=CommandInfo=0;
          Flag=*PatternSrcPtr++;
          ChannelNo=(Flag&31);
          if (Flag&32)
          {
            Note=*PatternSrcPtr++;
            Instr=*PatternSrcPtr++;
            if (Note==254)
            {
              Note=128;
              VolumeByte=0;
            }
            else
              if (Note>96)
                Note=0;
              else
                Note+=12;
          }
          if (Flag&64)
          {
            Command=*PatternSrcPtr++;
            CommandInfo=*PatternSrcPtr++;
			if (Command==0x0c)
			{
			  if (CommandInfo>64)
				CommandInfo=64;
			  CommandInfo<<=1;
			  if (CommandInfo>127)
				CommandInfo=127;
			}
            if (Command>15)
              Command=CommandInfo=0;
            switch(Command)
            {
              case 0x01 : if (CommandInfo==0)
                            CommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=CommandInfo;
                          if (CommandInfo>=0xf0)
                          {
                            Command=0x0e;
                            CommandInfo=(0x20|(CommandInfo&15));
                          }
                          else
                            if (CommandInfo>=0xe0)
                            {
                              Command=0x0e;
                              CommandInfo=(0x20|(((CommandInfo&15)+2)>>2));
                            }
                            else
                              Command=0x02;
                          break;
              case 0x02 : if (CommandInfo==0)
              	            CommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=CommandInfo;
                          if (CommandInfo>=0xf0)
                          {
                            Command=0x0e;
                            CommandInfo=(0x10|(CommandInfo&15));
                          }
                          else
                            if (CommandInfo>=0xe0)
                            {
                              Command=0x0e;
                              CommandInfo=(0x10|(((CommandInfo&15)+2)>>2));
                            }
                            else
                              Command=0x01;
                          break;
              case 0x0a : if (CommandInfo==0)
                            CommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=CommandInfo;
                         if (((CommandInfo&15)==15)&&(CommandInfo&240))
                          {
                            Command=0x0e;
                            CommandInfo=(0xa0|(CommandInfo>>4));
                          }
                          else
                            if ((CommandInfo>0xf0)&&(CommandInfo<0xff))
                            {
                              Command=0x0e;
                              CommandInfo=(0xb0|(CommandInfo&15));
                            }
                            else
                            {
                              if (CommandInfo&15)
                                CommandInfo&=15;
                            }
                          break;
              case 0x0e : switch(CommandInfo&240)
              		  {
                            case 0x10 : CommandInfo=(0x20|(CommandInfo&15)); break;
                            case 0x20 : CommandInfo=(0x10|(CommandInfo&15)); break;
		          }
		          break;
            }
          }
          if (Flag&128)
          {
            PTMVolumeByte=((*PatternSrcPtr++)<<1);
            if (PTMVolumeByte>127)
              PTMVolumeByte=127;
            VolumeByte&=PTMVolumeByte;
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
          if (VolumeByte!=255)
          {
            *PatternDestPtr++=VolumeByte;
            *PatternFlagPtr|=32;
          }
          if (*PatternFlagPtr&224)
            glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
          else
            PatternDestPtr=PatternFlagPtr;
        }
        PatternSrcPtr++;
        *PatternDestPtr++=0;
      }
      glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
    }
  }
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
