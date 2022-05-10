/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 12:30 on 16-01-1998 -ÄÄ

                         The 32 bit S3M-Loader C source

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
  ³ This source file, GLX-S3M.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* S3M Song-header */
{
  ubyte  Name[28];
  ubyte  EOFMarker;
  ubyte  Version;
  ubyte  Reserved1[2];
  uword  SongLength;
  uword  Instruments;
  uword  Patterns;
  uword  Flags;
  uword  Tracker;
  uword  FileInfo;
  ubyte  Id[4];
  ubyte  Volume;
  ubyte  Speed;
  ubyte  Tempo;
  ubyte  MasterMixVol;
  ubyte  UltraClick;
  ubyte  DefaultPan;
  ubyte  Reserved2[8];
  uword  Special;
  ubyte  ChannelInfo[32];
  ubyte  Orders[];
} S3MSongHdr_Struct;

typedef struct                                  /* S3M Pattern-header */
{
  uword  DataSize;
  ubyte  Data[];
} S3MPattHdr_Struct;

typedef struct                                  /* S3M Sample-header */
{
  ubyte  Version;
  ubyte  DOSName[12];
  ubyte  TermSeg;
  uword  MemSeg;
  udword Length;
  udword LoopStart;
  udword LoopEnd;
  ubyte  Volume;
  ubyte  Reserved1;
  ubyte  Packing;
  ubyte  Type;
  udword C4Speed;
  ubyte  Reserved2[12];
  ubyte  Name[28];
  ubyte  Id[4];
} S3MSampHdr_Struct;

#pragma pack (pop)				/* Default alignment */

int __cdecl glxLoadS3M(void *Module)
{
  ubyte S3MNote,S3MInstr,S3MCommand,S3MCommandInfo,S3MVolumeByte;
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Flag,Note,Instr,Command,CommandInfo,VolumeByte;
  int InstNo,SampleNo,PatternNo,ChannelNo,OrderNo;
  S3MSongHdr_Struct *SongHdr;
  S3MSampHdr_Struct *SampHdr;
  S3MPattHdr_Struct *PattHdr;
  int Status,PatternRow;
  ubyte OldInstNo[32],OldVolumeByte[32];
  ubyte OldCommand[32],OldCommandInfo[32];
  uword InstrumentFilePos[100];
  uword PatternFilePos[100];
  udword FileHeaderPos;
  ubyte MaxChannel;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(S3MSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(S3MSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(S3MPattHdr_Struct)+((6*32+1)*64)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  FileHeaderPos=tell(Module);
  read(SongHdr,1,sizeof(S3MSongHdr_Struct),Module);
  if (SongHdr->Version!=0x10)
    return GLXERR_UNSUPPORTEDFORMAT;
  memcpy(glxSongName,SongHdr->Name,28);
  glxSongLength=(unsigned char)SongHdr->SongLength;
  glxMusicVolume=SongHdr->Volume<<1;
  if (glxMusicVolume>127)
    glxMusicVolume=127;
  glxInitialSpeed=SongHdr->Speed;
  glxInitialTempo=SongHdr->Tempo;
  read(glxOrders,1,SongHdr->SongLength,Module);
  read(InstrumentFilePos,2,SongHdr->Instruments,Module);
  read(PatternFilePos,2,SongHdr->Patterns,Module);
  if (SongHdr->DefaultPan==252)
    read(glxInitialPanning,1,32,Module);
  MaxChannel=SampleNo=OrderNo=0;
  while ((SongHdr->ChannelInfo[MaxChannel]!=255)&&(MaxChannel<32))
  {
    if (SongHdr->MasterMixVol&128)
      if ((SongHdr->DefaultPan==252)&&(glxInitialPanning[MaxChannel]&32))
        glxInitialPanning[MaxChannel]=(glxInitialPanning[MaxChannel]&15)<<3;
      else
        if (SongHdr->ChannelInfo[MaxChannel]<=7)
          glxInitialPanning[MaxChannel]=26;
        else
          glxInitialPanning[MaxChannel]=102;
    else
      glxInitialPanning[MaxChannel]=GLX_MIDINSPANNING;
    MaxChannel++;
  }
  while ((glxOrders[OrderNo]!=255)&&(OrderNo<256))
    OrderNo++;
  if (OrderNo<glxSongLength)
    glxSongLength=OrderNo;
  glxSongLength--;
  //Load instruments(=samples)
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
  {
    seek(Module,FileHeaderPos+(InstrumentFilePos[InstNo]<<4),SEEK_SET);
    read(SampHdr,1,sizeof(S3MSampHdr_Struct),Module);
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=(sizeof(glxInstrument)-8);
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr->Name,28);
    if (memcmp(SampHdr->Id,"SCRS",4)==0)
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
      glxInstruments[0][InstNo]->Sample[0].Type=128|(SongHdr->FileInfo&2);
      glxInstruments[0][InstNo]->Sample[0].Type|=SampHdr->Type&4;
      glxInstruments[0][InstNo]->Sample[0].Type|=(SampHdr->Type&1)<<3;
      glxInstruments[0][InstNo]->Sample[0].Reserved=0;
      glxInstruments[0][InstNo]->Sample[0].C4Speed=SampHdr->C4Speed;
      seek(Module,FileHeaderPos+(SampHdr->MemSeg<<4),SEEK_SET);
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[0]),Module))
        return Status;
      SampleNo++;
    }
  }
  memset(OldCommand,0,32);
  memset(OldCommandInfo,0,32);
  memset(OldInstNo,0,32);
  memset(OldVolumeByte,0,32);
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
      seek(Module,FileHeaderPos+(PatternFilePos[PatternNo]<<4),SEEK_SET);
      read(PattHdr,1,sizeof(S3MPattHdr_Struct),Module);
      read(PatternSrcPtr,1,PattHdr->DataSize,Module);
      for (PatternRow=0;PatternRow<64;PatternRow++)
      {
        while (PatternSrcPtr[0])
        {
          Note=Instr=Command=CommandInfo=0;
          Flag=*PatternSrcPtr++;
          ChannelNo=(Flag&31);
          VolumeByte=255;
          if (Flag&32)
          {
            S3MNote=*PatternSrcPtr++;
            S3MInstr=*PatternSrcPtr++;
            if (S3MNote==254)
            {
              Note=128;
              VolumeByte=0;
            }
            else
            {
              if (S3MNote<=0x7b)
                Note=(((S3MNote>>4)*12)+(S3MNote&15))+12+1;
              if (S3MInstr==0xff)
                S3MInstr=OldInstNo[ChannelNo];
              OldInstNo[ChannelNo]=S3MInstr;
              Instr=S3MInstr;
            }
          }
          if (Flag&64)
          {
            S3MVolumeByte=*PatternSrcPtr++;
            if (S3MVolumeByte==0xff)
              S3MVolumeByte=OldVolumeByte[ChannelNo];
			else
			  S3MVolumeByte<<=1;
            if (S3MVolumeByte>127)
              S3MVolumeByte=127;
            OldVolumeByte[ChannelNo]=S3MVolumeByte;
            VolumeByte&=S3MVolumeByte;
          }
          if (Flag&128)
          {
            S3MCommand=*PatternSrcPtr++;
            S3MCommandInfo=*PatternSrcPtr++;
            if (S3MCommand==0xff)
              S3MCommand=OldCommand[ChannelNo];
            OldCommand[ChannelNo]=S3MCommand;
            switch(S3MCommand)
            {
              case 0x01 : if (S3MCommandInfo>0x20)
                            S3MCommandInfo=0x20;
                          Command=0x0f; CommandInfo=S3MCommandInfo;
                          break;
              case 0x02 : Command=0x0b; CommandInfo=S3MCommandInfo; break;
              case 0x03 : Command=0x0d; CommandInfo=S3MCommandInfo; break;
              case 0x04 : if (S3MCommandInfo==0)
                            S3MCommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=S3MCommandInfo;
                          if (((S3MCommandInfo&15)==15)&&(S3MCommandInfo&240))
                          {
                            Command=0x0e;
                            CommandInfo=(0xa0|(S3MCommandInfo>>4));
                          }
                          else
                            if ((S3MCommandInfo>0xf0)&&(S3MCommandInfo<0xff))
                            {
                              Command=0x0e;
                              CommandInfo=(0xb0|(S3MCommandInfo&15));
                            }
                            else
                            {
                              Command=0x0a;
                              CommandInfo=S3MCommandInfo;
                              if (CommandInfo&15)
                                CommandInfo&=15;
                            }
                          break;
              case 0x05 : if (S3MCommandInfo==0)
                            S3MCommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=S3MCommandInfo;
                          if (S3MCommandInfo>=0xf0)
                          {
                            Command=0x0e;
                            CommandInfo=(0x20|(S3MCommandInfo&15));
                          }
                          else if (S3MCommandInfo>=0xe0)
                          {
                            Command=0x0e;
                            CommandInfo=(0x20|(((S3MCommandInfo&15)+2)>>2));
                          }
                          else
                          {
                            Command=0x02;
                            CommandInfo=S3MCommandInfo;
                          }
                          break;
              case 0x06 : if (S3MCommandInfo==0)
              	            S3MCommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=S3MCommandInfo;
                          if (S3MCommandInfo>=0xf0)
                          {
                            Command=0x0e;
                            CommandInfo=(0x10|(S3MCommandInfo&15));
                          }
                          else
                            if (S3MCommandInfo>=0xe0)
                            {
                              Command=0x0e;
                              CommandInfo=(0x10|(((S3MCommandInfo&15)+2)>>2));
                            }
                            else
                            {
                              Command=0x01;
                              CommandInfo=S3MCommandInfo;
                            }
                          break;
              case 0x07 : Command=0x03; CommandInfo=S3MCommandInfo; break;
              case 0x08 : Command=0x04; CommandInfo=S3MCommandInfo; break;
              case 0x0a : Command=0x00; CommandInfo=S3MCommandInfo; break;
              case 0x0b : if (S3MCommandInfo==0)
              	            S3MCommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=S3MCommandInfo;
              	          Command=0x06; CommandInfo=S3MCommandInfo; break;
              case 0x0c : if (S3MCommandInfo==0)
              	            S3MCommandInfo=OldCommandInfo[ChannelNo];
                          OldCommandInfo[ChannelNo]=S3MCommandInfo;
              	          Command=0x05; CommandInfo=S3MCommandInfo; break;
              case 0x0f : Command=0x09; CommandInfo=S3MCommandInfo; break;
              case 0x11 : Command=0x0e; CommandInfo=(0x90|(S3MCommandInfo&15)); break;
              case 0x12 : Command=0x07; CommandInfo=S3MCommandInfo; break;
              case 0x13 : Command=0x0e;
              		  CommandInfo=S3MCommandInfo;
              		  switch(S3MCommandInfo&240)
              		  {
                            case 0x00 : break;
                            case 0x10 : CommandInfo=(0x30|(S3MCommandInfo&15)); break;
                            case 0x30 : CommandInfo=(0x40|(S3MCommandInfo&15)); break;
                            case 0x40 : CommandInfo=(0x70|(S3MCommandInfo&15)); break;
                            case 0x80 : break;
                            case 0x90 : Command=8; CommandInfo=0xa4; break;
                            case 0xb0 : CommandInfo=(0x60|(S3MCommandInfo&15)); break;
                            case 0xc0 : break;
                            case 0xd0 : break;
                            case 0xe0 : break;
                            case 0xf0 : break;
                            default   : Command=CommandInfo=0; break;
		          }
		          break;
              case 0x14 : if (S3MCommandInfo>=0x20)
              	          {
                            Command=0x0f; CommandInfo=S3MCommandInfo;
                          }
                          break;
              case 0x15 : Command=0x04; CommandInfo=((S3MCommandInfo&240)|(((S3MCommandInfo&15)+2)>>2)); break;
              case 0x18 : Command=0x08; CommandInfo=S3MCommandInfo; break;
              default   : Command=CommandInfo=0; break;
            }
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
          if ((((*PatternFlagPtr)&224)==0)||(ChannelNo>MaxChannel))
            PatternDestPtr=PatternFlagPtr;
          else
            glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
        }
        PatternSrcPtr++;
        *PatternDestPtr++=0;
      }
      glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
    }
  }
  //Set global player variables
  glxPlayerMode=1|2;
  glxMusicVoices++;
  if (SongHdr->Flags&16)
  {
    glxMinPeriod=1814;
    glxMaxPeriod=13696;
  }
  else
  {
    glxMinPeriod=453;
    glxMaxPeriod=65280;
  }
  //Release header memory
  freemem(SongHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
