/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 15:52 on 27-01-1998 -ÄÄ

                  The 32 bit BETA BETA BETA IT-Loader C source

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
  ³ This source file, GLX-IT.C is Copyright  (c)  1993-97 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include <memory.h>

#include "hdr\galaxy.h"
#include "hdr\loaders.h"
#include "hdr\glx-smp.h"

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* IT Song-header */
{
  ubyte  Id[4];
  ubyte  Name[26];
  ubyte  Reserved1[2];
  uword  SongLength;
  uword  Instruments;
  uword  Samples;
  uword  Patterns;
  uword  Tracker;
  uword  Compatible;
  uword  Flags;
  uword  Special;
  ubyte  Volume;
  ubyte  MasterMixVol;
  ubyte  Speed;
  ubyte  Tempo;
  ubyte  Separation;
  ubyte  Reserved2;
  uword  MessageLength;
  udword MessageOffset;
  ubyte  Reserved3[4];
  ubyte  ChannelPan[64];
  ubyte  ChannelVol[64];
  ubyte  Orders[];
} ITSongHdr_Struct;

typedef struct                                  /* IT Pattern-header */
{
  uword  DataSize;
  uword  Rows;
  ubyte  Reserved[4];
  ubyte  Data[];
} ITPattHdr_Struct;

typedef struct                                  /* IT Instrument-header */
{
  ubyte  Id[4];
  ubyte  DOSName[12];
  ubyte  Reserved1;
  ubyte  NNA;
  ubyte  DCT;
  ubyte  DCA;
  uword  FadeOut;
  ubyte  PPS;
  ubyte  PPC;
  ubyte  GlobalVolume;
  ubyte  Panning;
  ubyte  RV;
  ubyte  RP;
  uword  Tracker;
  ubyte  Samples;
  ubyte  Reserved2;
  ubyte  Name[26];
  ubyte  Reserved3[2];
  ubyte  MidiChan;
  ubyte  MidiProg;
  ubyte  Reserved4[2];
  struct
  {
    ubyte Note;
    ubyte Sample;
  }      NoteSample[120];
  ubyte  VType;
  ubyte  VPoints;
  ubyte  VLSPoint;
  ubyte  VLEPoint;
  ubyte  VSLSPoint;
  ubyte  VSLEPoint;
  struct
  {
    ubyte Volume;
    uword Time;
  }      VEnvelope[25];
  ubyte  VReserved;
  ubyte  PType;
  ubyte  PPoints;
  ubyte  PLSPoint;
  ubyte  PLEPoint;
  ubyte  PSLSPoint;
  ubyte  PSLEPoint;
  struct
  {
    sbyte Panning;
    uword Time;
  }      PEnvelope[25];
  ubyte  PReserved;
  ubyte  PtType;
  ubyte  PtPoints;
  ubyte  PtLSPoint;
  ubyte  PtLEPoint;
  ubyte  PtSLSPoint;
  ubyte  PtSLEPoint;
  struct
  {
    sbyte Pitch;
    uword Time;
  }      PtEnvelope[25];
  ubyte  PtReserved;
} ITInstHdr_Struct;

typedef struct                                  /* IT Sample-header */
{
  ubyte  Id[4];
  ubyte  DOSName[12];
  ubyte  Reserved;
  ubyte  GlobalVolume;
  ubyte  Type;
  ubyte  Volume;
  ubyte  Name[26];
  ubyte  Convert;
  ubyte  Panning;
  udword Length;
  udword LoopStart;
  udword LoopEnd;
  udword C5Speed;
  udword SLoopStart;
  udword SLoopEnd;
  udword Offset;
  ubyte  VibSpeed;
  ubyte  VibDepth;
  ubyte  VibRate;
  ubyte  VibWave;
} ITSampHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadIT(void *Module)
{
  static ubyte OldNote[64],OldInstNo[64],OldVolumeByte[64];
  static ubyte OldCommand[64],OldCommandInfo[64],OldFlag[64];
  static udword SampleFilePos[256],PatternFilePos[256];
  static udword InstrumentFilePos[128];
  static ubyte InstRemap[256];
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Flag,Note,Instr,Command,CommandInfo,VolumeByte;
  ubyte ITVolumeByte;
  int InstNo,SampleNo,PatternNo,ChannelNo,OrderNo;
  ITSongHdr_Struct *SongHdr;
  ITInstHdr_Struct *InstHdr;
  ITSampHdr_Struct *SampHdr;
  ITPattHdr_Struct *PattHdr;
  int Status,PatternRow,i,Amp;
  udword FileHeaderPos;

  //Grab some memory for the headers
  if ((SongHdr=getmem(sizeof(ITSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((InstHdr=getmem(sizeof(ITInstHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(ITSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(ITPattHdr_Struct)+((7*32)*256)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load song header
  FileHeaderPos=tell(Module);
  read(SongHdr,1,sizeof(ITSongHdr_Struct),Module);
  memcpy(glxSongName,SongHdr->Name,26);
  memset(PatternFilePos,0,256*4);
  glxMusicVolume=SongHdr->Volume;
  if (glxMusicVolume>127)
    glxMusicVolume=127;
  glxInitialSpeed=SongHdr->Speed;
  glxInitialTempo=SongHdr->Tempo;
  glxSongLength=(SongHdr->SongLength>255)?255:SongHdr->SongLength;
  read(glxOrders,1,glxSongLength,Module);
  seek(Module,SongHdr->SongLength-glxSongLength,SEEK_CUR);
  read(InstrumentFilePos,4,SongHdr->Instruments,Module);
  read(SampleFilePos,4,SongHdr->Samples,Module);
  read(PatternFilePos,4,SongHdr->Patterns,Module);
  for (i=0;i<32;i++)
    if (SongHdr->ChannelPan[i]<=64)
    { 
	  glxInitialPanning[i]=SongHdr->ChannelPan[i]<<1;
	  if (glxInitialPanning[i]>127)
        glxInitialPanning[i]=127;
	}
    else
      glxInitialPanning[i]=128|32;
  OrderNo=0;
  while ((glxOrders[OrderNo]!=255)&&(OrderNo<256))
    OrderNo++;
  if (OrderNo<glxSongLength)
    glxSongLength=OrderNo;
  glxSongLength--;
  //Load Instruments and samples if in instrument mode
  if (SongHdr->Flags&4)
  {
    for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
    {
      seek(Module,FileHeaderPos+InstrumentFilePos[InstNo],SEEK_SET);
      read(InstHdr,1,sizeof(ITInstHdr_Struct),Module);
      if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)))==NULL)
        return GLXERR_OUTOFMEMORY;
      memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument));
      glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
      glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
      glxInstruments[0][InstNo]->Program=InstNo;
      memcpy(glxInstruments[0][InstNo]->Message,InstHdr->Name,26);
      if (memcmp(InstHdr->Id,"IMPI",4)==0)
      {
        InstHdr->Samples=0;
		memset(InstRemap,0,256);
        for (i=0;i<120;i++)
          if (InstHdr->NoteSample[i].Sample)
          {
            if (InstRemap[InstHdr->NoteSample[i].Sample-1]==0)
              InstRemap[InstHdr->NoteSample[i].Sample-1]=((InstHdr->Samples++)+1);
            glxInstruments[0][InstNo]->Split[i]=((InstRemap[InstHdr->NoteSample[i].Sample-1])-1);
          }
		for (i=0;i<10;i++)
        {
          glxInstruments[0][InstNo]->Articulation.Volume[i].Time=InstHdr->VEnvelope[i].Time;
		  glxInstruments[0][InstNo]->Articulation.Volume[i].Value=Amp=InstHdr->VEnvelope[i].Volume<<9;
		  if (Amp>GLX_MAXSMPVOLUME)
            glxInstruments[0][InstNo]->Articulation.Volume[i].Value=GLX_MAXSMPVOLUME; 
        }
		glxInstruments[0][InstNo]->Articulation.VolFadeOut=InstHdr->FadeOut<<5;
        if (glxInstruments[0][InstNo]->Articulation.VolFadeOut>GLX_MAXSMPVOLUME)
          glxInstruments[0][InstNo]->Articulation.VolFadeOut=GLX_MAXSMPVOLUME; 
        for (i=0;i<10;i++)
        {
          glxInstruments[0][InstNo]->Articulation.Pitch[i].Time=InstHdr->PtEnvelope[i].Time;
	      glxInstruments[0][InstNo]->Articulation.Pitch[i].Value=Amp=InstHdr->PtEnvelope[i].Pitch<<7;
		  if (Amp>GLX_MAXSMPPANNING)
            glxInstruments[0][InstNo]->Articulation.Pitch[i].Value=GLX_MAXSMPPANNING; 
        }
        for (i=0;i<10;i++)
        {
          glxInstruments[0][InstNo]->Articulation.Panning[i].Time=InstHdr->PEnvelope[i].Time;
	      glxInstruments[0][InstNo]->Articulation.Panning[i].Value=Amp=InstHdr->PEnvelope[i].Panning<<10;
		  if (Amp>GLX_MAXSMPPANNING)
            glxInstruments[0][InstNo]->Articulation.Panning[i].Value=GLX_MAXSMPPANNING; 
        }
        glxInstruments[0][InstNo]->Articulation.VolFlag=((InstHdr->VType&1)|((InstHdr->VType&2)<<1)|((InstHdr->VType&4)>>1));
        glxInstruments[0][InstNo]->Articulation.VolSize=(InstHdr->VPoints&15);
        glxInstruments[0][InstNo]->Articulation.VolSustain=(InstHdr->VSLSPoint&15);
        glxInstruments[0][InstNo]->Articulation.VolLS=(InstHdr->VLSPoint&15);
        glxInstruments[0][InstNo]->Articulation.VolLE=(InstHdr->VLEPoint&15);
        glxInstruments[0][InstNo]->Articulation.PitFlag=((InstHdr->PtType&1)|((InstHdr->PtType&2)<<1)|((InstHdr->PType&4)>>1));
        glxInstruments[0][InstNo]->Articulation.PitSize=(InstHdr->PtPoints&15);
        glxInstruments[0][InstNo]->Articulation.PitSustain=(InstHdr->PtSLEPoint&15);
        glxInstruments[0][InstNo]->Articulation.PitLS=(InstHdr->PtLSPoint&15);
        glxInstruments[0][InstNo]->Articulation.PitLE=(InstHdr->PtLEPoint&15);
        glxInstruments[0][InstNo]->Articulation.PanFlag=((InstHdr->PType&1)|((InstHdr->PType&2)<<1)|((InstHdr->PType&4)>>1));
        glxInstruments[0][InstNo]->Articulation.PanSize=(InstHdr->PPoints&15);
        glxInstruments[0][InstNo]->Articulation.PanSustain=(InstHdr->PSLEPoint&15);
        glxInstruments[0][InstNo]->Articulation.PanLS=(InstHdr->PLSPoint&15);
        glxInstruments[0][InstNo]->Articulation.PanLE=(InstHdr->PLEPoint&15);
        if ((glxInstruments[0][InstNo]=resizemem(glxInstruments[0][InstNo],sizeof(glxInstrument)+InstHdr->Samples*sizeof(glxSample)))==NULL)
          return GLXERR_OUTOFMEMORY;
        for (SampleNo=0;SampleNo<InstHdr->Samples;SampleNo++)
        {
          i=0;
          while (InstRemap[i]!=(SampleNo+1))
            i++;
          seek(Module,FileHeaderPos+SampleFilePos[i],SEEK_SET);
          read(SampHdr,1,sizeof(ITSampHdr_Struct),Module);
          memset(&(glxInstruments[0][InstNo]->Sample[SampleNo]),0,sizeof(glxSample));
          glxInstruments[0][InstNo]->Samples++;
          memcpy(glxInstruments[0][InstNo]->Sample[SampleNo].Message,SampHdr->Name,22);
          if (SampHdr->Length)
          {
            glxInstruments[0][InstNo]->Sample[SampleNo].Length=SampHdr->Length;
            glxInstruments[0][InstNo]->Sample[SampleNo].LoopStart=SampHdr->LoopStart;
            glxInstruments[0][InstNo]->Sample[SampleNo].LoopEnd=SampHdr->LoopEnd;
			glxInstruments[0][InstNo]->Sample[SampleNo].Volume=SampHdr->Volume<<9;
			if (glxInstruments[0][InstNo]->Sample[SampleNo].Volume>GLX_MAXSMPVOLUME)
			  glxInstruments[0][InstNo]->Sample[SampleNo].Volume=GLX_MAXSMPVOLUME;
			glxInstruments[0][InstNo]->Sample[SampleNo].Type=GLX_ALWAYSLOOP|((SampHdr->Type&2)<<1)|((SampHdr->Type&16)>>1);
            glxInstruments[0][InstNo]->Sample[SampleNo].Type|=((SampHdr->Type&64)>>2)|((SampHdr->Panning&128)>>2);
            glxInstruments[0][InstNo]->Sample[SampleNo].Type|=(((SampHdr->Convert&1)^1)<<1);
		    glxInstruments[0][InstNo]->Sample[SampleNo].Panning=(SampHdr->Panning&127)<<9;
			if (glxInstruments[0][InstNo]->Sample[SampleNo].Panning>GLX_MAXSMPPANNING)
			  glxInstruments[0][InstNo]->Sample[SampleNo].Panning=GLX_MAXSMPPANNING;
            glxInstruments[0][InstNo]->Sample[SampleNo].Reserved=0;
            glxInstruments[0][InstNo]->Sample[SampleNo].C4Speed=SampHdr->C5Speed;
            seek(Module,FileHeaderPos+SampHdr->Offset,SEEK_SET);
            if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
              return Status;
          }
        }
      }
    }
  }
  else
  {
    for (SampleNo=0;SampleNo<SongHdr->Samples;SampleNo++)
    {
      seek(Module,FileHeaderPos+SampleFilePos[SampleNo],SEEK_SET);
      read(SampHdr,1,sizeof(ITSampHdr_Struct),Module);
      if ((glxInstruments[0][SampleNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
        return GLXERR_OUTOFMEMORY;
      memset(glxInstruments[0][SampleNo],0,sizeof(glxInstrument));
      glxInstruments[0][SampleNo]->FourCC=GLX_FOURCC_INST;
      glxInstruments[0][SampleNo]->Size=sizeof(glxInstrument)-8;
      glxInstruments[0][SampleNo]->Program=SampleNo;
      memcpy(glxInstruments[0][SampleNo]->Message,SampHdr->Name,26);
      if (memcmp(SampHdr->Id,"IMPS",4)==0)
      {
        memset(&(glxInstruments[0][SampleNo]->Sample[0]),0,sizeof(glxSample));
        glxInstruments[0][SampleNo]->Samples=1;
        memset(glxInstruments[0][SampleNo]->Split,0,128);
        memcpy(glxInstruments[0][SampleNo]->Sample[0].Message,SampHdr->Name,26);
        glxInstruments[0][SampleNo]->Sample[0].Length=SampHdr->Length;
        glxInstruments[0][SampleNo]->Sample[0].LoopStart=SampHdr->LoopStart;
        glxInstruments[0][SampleNo]->Sample[0].LoopEnd=SampHdr->LoopEnd;
		glxInstruments[0][SampleNo]->Sample[0].Volume=SampHdr->Volume<<9;
		if (glxInstruments[0][SampleNo]->Sample[0].Volume>GLX_MAXSMPVOLUME)
		  glxInstruments[0][SampleNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;
        glxInstruments[0][SampleNo]->Sample[0].Type=GLX_ALWAYSLOOP|((SampHdr->Type&2)<<1)|((SampHdr->Type&16)>>1);
        glxInstruments[0][SampleNo]->Sample[0].Type|=((SampHdr->Type&64)>>2)|((SampHdr->Panning&128)>>2);
        glxInstruments[0][SampleNo]->Sample[0].Type|=(((SampHdr->Convert&1)^1)<<1);
	    glxInstruments[0][SampleNo]->Sample[0].Panning=(SampHdr->Panning&127)<<9;
		if (glxInstruments[0][SampleNo]->Sample[0].Panning>GLX_MAXSMPPANNING)
		  glxInstruments[0][SampleNo]->Sample[0].Panning=GLX_MAXSMPPANNING;
        glxInstruments[0][SampleNo]->Sample[0].Reserved=0;
        glxInstruments[0][SampleNo]->Sample[0].C4Speed=SampHdr->C5Speed;
        seek(Module,FileHeaderPos+SampHdr->Offset,SEEK_SET);
        if (Status=LoadSample(&(glxInstruments[0][SampleNo]->Sample[0]),Module))
          return Status;
      }
    }
  }
  memset(OldNote,0,64);
  memset(OldCommand,0,64);
  memset(OldCommandInfo,0,64);
  memset(OldInstNo,0,64);
  memset(OldVolumeByte,0,64);
  memset(OldFlag,0,64);
  //Pattern loader
  for (OrderNo=0;OrderNo<glxSongLength+1;OrderNo++)
  {
    PatternNo=glxOrders[OrderNo];
    if ((PatternNo<254)&&(glxPatterns[PatternNo]==NULL)&&(PatternFilePos[PatternNo]))
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
	  if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*32+1)*256+1)))
        return GLXERR_OUTOFPATTERNMEM;
	  //Parse pattern
      seek(Module,FileHeaderPos+PatternFilePos[PatternNo],SEEK_SET);
      read(PattHdr,1,sizeof(ITPattHdr_Struct),Module);
      read(PatternSrcPtr,1,PattHdr->DataSize,Module);
      PatternRow=PattHdr->Rows-1;
      *PatternDestPtr++=PatternRow;
      do
      {
        while (PatternSrcPtr[0])
        {
          Note=Instr=Command=CommandInfo=0;
          Flag=*PatternSrcPtr++;
          ChannelNo=(Flag-1)&63;
          VolumeByte=255;
          if (Flag&128)
            Flag=*PatternSrcPtr++;
          else
            Flag=OldFlag[ChannelNo];
          OldFlag[ChannelNo]=Flag;
          if (Flag&1)
          {
            Note=*PatternSrcPtr++;
            if (Note<120)
              Note++;
            if (Note==254)
              Note=VolumeByte=0;
            if (Note==255)
              Note=128;
            OldNote[ChannelNo]=Note;
          }
          if (Flag&2)
          {
            Instr=*PatternSrcPtr++;
            OldInstNo[ChannelNo]=Instr;
          }
          if (Flag&4)
          {
            ITVolumeByte=*PatternSrcPtr++;
			if (ITVolumeByte<=64)
            {
			  ITVolumeByte<<=1;
			  if (ITVolumeByte>127)
				ITVolumeByte=127;
			  VolumeByte&=ITVolumeByte;
			}
            OldVolumeByte[ChannelNo]=ITVolumeByte;
          }
          if (Flag&8)
          {
            OldCommand[ChannelNo]=Command=*PatternSrcPtr++;
            CommandInfo=*PatternSrcPtr++;
            if ((Command!=1)&&(Command!=11)&&(Command!=12)&&((Command<4)||(Command>6)))
              OldCommandInfo[ChannelNo]=CommandInfo;
          }
          if (Flag&16)
            Note=OldNote[ChannelNo];
          if (Flag&32)
            Instr=OldInstNo[ChannelNo];
          if (Flag&64)
          {
            ITVolumeByte=OldVolumeByte[ChannelNo];
            if (ITVolumeByte<=127)
              VolumeByte&=ITVolumeByte;
          }
          if (Flag&128)
          {
            Command=OldCommand[ChannelNo];
            CommandInfo=OldCommandInfo[ChannelNo];
          }
          switch(Command)
          {
            case 0x01 : if (CommandInfo==0)
                          CommandInfo=OldCommandInfo[ChannelNo];
                        OldCommandInfo[ChannelNo]=CommandInfo;
                        if (CommandInfo>0x20)
                          CommandInfo=0x20;
                        Command=0x0f;
                        break;
            case 0x02 : Command=0x0b; break;
            case 0x03 : Command=0x0d; break;
            case 0x04 : if (CommandInfo==0)
                          CommandInfo=OldCommandInfo[ChannelNo];
                        OldCommandInfo[ChannelNo]=CommandInfo;
                        if (((CommandInfo&15)==15)&&(CommandInfo&240))
                        {
                          Command=0x0e;
                          CommandInfo=(0xa0|(CommandInfo>>4));
                        }
                        else if (CommandInfo>=0xf1)
                        {
                          Command=0x0e;
                          CommandInfo=(0xb0|(CommandInfo&15));
                        }
                        else
                        {
                          Command=0x0a;
                          if (CommandInfo&15)
                            CommandInfo&=15;
                        }
                        break;
            case 0x05 : if (CommandInfo==0)
                          CommandInfo=OldCommandInfo[ChannelNo];
                        OldCommandInfo[ChannelNo]=CommandInfo;
                        if (CommandInfo>=0xf0)
                        {
                          Command=0x0e;
                          CommandInfo=(0x20|(CommandInfo&15));
                        }
                        else if (CommandInfo>=0xe0)
                        {
                          Command=0x0e;
                          CommandInfo=(0x20|(((CommandInfo&15)+2)>>2));
                        }
                        else
                        {
                          Command=0x02;
                        }
                        break;
            case 0x06 : if (CommandInfo==0)
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
                          {
                            Command=0x01;
                          }
                        break;
            case 0x07 : Command=0x03; break;
            case 0x08 : Command=0x04; break;
            case 0x0a : Command=0x00; break;
            case 0x0b : if (CommandInfo==0)
            	          CommandInfo=OldCommandInfo[ChannelNo];
                        OldCommandInfo[ChannelNo]=CommandInfo;
            	        Command=0x06; break;
            case 0x0c : if (CommandInfo==0)
            	          CommandInfo=OldCommandInfo[ChannelNo];
                        OldCommandInfo[ChannelNo]=CommandInfo;
            	        Command=0x05; break;
            case 0x0f : Command=0x09; break;
            case 0x11 : Command=0x0e; CommandInfo=(0x90|(CommandInfo&15)); break;
            case 0x12 : Command=0x07; break;
            case 0x13 : Command=0x0e;
          		switch(CommandInfo&240)
            		{
                          case 0x00 : break;
                          case 0x10 : CommandInfo=(0x30|(CommandInfo&15)); break;
                          case 0x30 : CommandInfo=(0x40|(CommandInfo&15)); break;
                          case 0x40 : CommandInfo=(0x70|(CommandInfo&15)); break;
                          case 0x80 : break;
                          case 0x90 : Command=8; CommandInfo=0xa4; break;
                          case 0xb0 : CommandInfo=(0x60|(CommandInfo&15)); break;
                          case 0xc0 : break;
                          case 0xd0 : break;
                          case 0xe0 : break;
                          case 0xf0 : break;
                          default   : Command=0; CommandInfo=0; break;
                        }
                        break;
            case 0x14 : if (CommandInfo>=0x20)
                          Command=0x0f;
                        break;
            case 0x18 : Command=0x08; break;
            default   : Command=CommandInfo=0; break;
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
          if ((*PatternFlagPtr&224)&&(ChannelNo<32))
            glxMusicVoices=(ChannelNo>glxMusicVoices)?ChannelNo:glxMusicVoices;
          else
            PatternDestPtr=PatternFlagPtr;
        }
        PatternSrcPtr++;
        *PatternDestPtr++=0;
      } while (PatternRow--);
      glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
    }
  }
  //Set global player variables
  glxPlayerMode=(((SongHdr->Flags&8)>>3)^1)|2;
  glxMusicVoices++;
  glxMinPeriod=453;
  glxMaxPeriod=65280;
  //Release header memory
  freemem(SongHdr);
  freemem(InstHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
