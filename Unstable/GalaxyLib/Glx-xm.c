/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 12:50 on 18-01-1998 -ÄÄ

                         The 32 bit XM-Loader C source

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
  ³ This source file, GLX-XM.C is Copyright  (c)  1993-97 by Carlo Vogelsang. ³
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

typedef struct                                  /* XM File-header */
{
  ubyte  Id[17];
  ubyte  Name[20];
  ubyte  EOFMarker;
  ubyte  Tracker[20];
  uword  Version;
} XMFileHdr_Struct;

typedef struct                                  /* XM Song-header */
{
  uword  SongLength;
  uword  RestartPos;
  uword  Channels;
  uword  Patterns;
  uword  Instruments;
  uword  Flags;
  uword  Speed;
  uword  Tempo;
  ubyte  Orders[256];
} XMSongHdr_Struct;

typedef struct                                  /* XM Pattern-header */
{
  ubyte  Compression;
  uword  Rows;
  uword  DataSize;
  ubyte  Data[];
} XMPattHdr_Struct;

typedef struct                                  /* XM Instrument-header */
{
  ubyte  Name[22];
  ubyte  Type;
  uword  Samples;
  udword SampHdrSize;
  ubyte  Split[96];
  struct
  {
    uword Time;
    uword Volume;
  }      VEnvelope[12];
  struct
  {
    uword Time;
    uword Panning;
  }      PEnvelope[12];
  ubyte  VPoints;
  ubyte  PPoints;
  ubyte  VSPoint;
  ubyte  VLSPoint;
  ubyte  VLEPoint;
  ubyte  PSPoint;
  ubyte  PLSPoint;
  ubyte  PLEPoint;
  ubyte  VType;
  ubyte  PType;
  ubyte  VibType;
  ubyte  VibSweep;
  sbyte  VibDepth;
  sbyte  VibRate;
  uword  FadeOut;
  ubyte  Reserved[2];
} XMInstHdr_Struct;

typedef struct                                  /* XM Sample-header */
{
  udword Length;
  udword LoopStart;
  udword LoopLength;
  ubyte  Volume;
  sbyte  FineTune;
  ubyte  Type;
  ubyte  Panning;
  sbyte  RelativeNote;
  ubyte  Reserved;
  ubyte  Name[22];
} XMSampHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadXM(void *Module)
{
  static udword Finetuning[192]={
  32, 34, 36, 38, 41, 43, 46, 48, 51, 54, 58, 61, 65, 69, 73, 77, 82, 87, 92, 97,
  103, 109, 116, 123, 130, 138, 146, 155, 164, 174, 184, 195, 207, 219, 232, 246,
  261, 276, 293, 310, 329, 348, 369, 391, 414, 439, 465, 493, 522, 553, 586, 621,
  658, 697, 739, 783, 829, 879, 931, 986, 1045, 1107,  1173,  1243,  1317,  1395,
  1478,  1566,  1659, 1758, 1862, 1973, 2090, 2215, 2346, 2486, 2634, 2790, 2956,
  3132, 3318, 3516, 3725, 3946, 4181, 4430, 4693, 4972, 5268, 5581,  5913,  6265,
  6637,  7032,  7450,  7893,  8363, 8860, 9387, 9945, 10536, 11163, 11827, 12530,
  13275, 14064, 14901, 15787, 16726, 17720, 18774, 19890,  21073,  22326,  23654,
  25060,  26550,  28129,  29802, 31574, 33452, 35441, 37548, 39781, 42146, 44653,
  47308, 50121, 53101, 56259, 59604, 63148, 66904, 70882,  75097,  79562,  84293,
  89306,  94616,  100242, 106203, 112518, 119209, 126297, 133808, 141764, 150194,
  159125, 168587, 178612, 189233, 200485, 212406, 225037, 238418, 252595, 267616,
  283529, 300388, 318250, 337175, 357224, 378466, 400970, 424813, 450074, 476837,
  505191, 535232, 567058, 600777, 636501, 674350, 714449, 756932, 801941, 849627,
  900149, 953675, 1010383, 1070464, 1134117, 1201555, 1273003, 1348700,  1428898,
  1513864, 1603883, 1699255, 1800298, 1907350, 2020766};
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Flag,Note,Instr,Command,CommandInfo,Volume;
  int InstNo,SampleNo,PatternNo,ChannelNo;
  XMFileHdr_Struct *FileHdr;
  XMSongHdr_Struct *SongHdr;
  XMInstHdr_Struct *InstHdr;
  XMSampHdr_Struct *SampHdr;
  XMPattHdr_Struct *PattHdr;
  int Status,PatternRow;
  udword HeaderSize;
  int Key,Amp;

  //Grab some memory for the headers
  if ((FileHdr=getmem(sizeof(XMFileHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SongHdr=getmem(sizeof(XMSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((InstHdr=getmem(sizeof(XMInstHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(XMSampHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(XMPattHdr_Struct)+((6*32)*256)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load general file header
  read(FileHdr,1,sizeof(XMFileHdr_Struct),Module);
  if (FileHdr->Version!=0x104)
    return GLXERR_UNSUPPORTEDFORMAT;
  memcpy(glxSongName,FileHdr->Name,20);
  //Load song header
  read(&HeaderSize,1,4,Module);
  read(SongHdr,1,sizeof(XMSongHdr_Struct),Module);
  seek(Module,HeaderSize-sizeof(XMSongHdr_Struct)-4,SEEK_CUR);
  glxSongLength=SongHdr->SongLength-1;
  glxPlayerMode=(SongHdr->Flags^1)|2;
  glxInitialSpeed=(unsigned char)SongHdr->Speed;
  glxInitialTempo=(unsigned char)SongHdr->Tempo;
  memset(glxInitialPanning,GLX_MIDINSPANNING,SongHdr->Channels);
  memcpy(glxOrders,SongHdr->Orders,256);
  SampleNo=0;
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
	if (!(PatternDestPtr=glxPatterns[PatternNo]->Track[0].Events=getmem((6*32+1)*256+1)))
      return GLXERR_OUTOFPATTERNMEM;
	//Parse pattern
    read(&HeaderSize,1,4,Module);
    read(PattHdr,1,sizeof(XMPattHdr_Struct),Module);
    seek(Module,HeaderSize-sizeof(XMPattHdr_Struct)-4,SEEK_CUR);
    read(PatternSrcPtr,1,PattHdr->DataSize,Module);
    PatternRow=PattHdr->Rows-1;
    *PatternDestPtr++=PatternRow;
    do
    {
      for (ChannelNo=0;ChannelNo<SongHdr->Channels;ChannelNo++)
      {
        Volume=0xd0;
        Note=Instr=Command=CommandInfo=0;
        Flag=*PatternSrcPtr++;
        if (Flag&128)
        {
          if (Flag&1)
            Note=*PatternSrcPtr++;
          if (Flag&2)
            Instr=*PatternSrcPtr++;
          if (Flag&4)
            Volume=*PatternSrcPtr++;
          if (Flag&8)
            Command=*PatternSrcPtr++;
          if (Flag&16)
            CommandInfo=*PatternSrcPtr++;
        }
        else
        {
          Note=Flag;
          Instr=*PatternSrcPtr++;
 		  Volume=*PatternSrcPtr++;
          Command=*PatternSrcPtr++;
          CommandInfo=*PatternSrcPtr++;
        }
        if (Command==0x08)
           CommandInfo>>=1;
        if (Command==0x0c)
		{
		  if (CommandInfo>64)
			CommandInfo=64;
		  CommandInfo<<=1;
		  if (CommandInfo>127)
			CommandInfo=127;
		}
        if ((Command==28)||(Command==34))
           Command=8;
        if (Command==0x14)
           Note=97;
        if (Command>0x0f)
          Command=CommandInfo=0;
        if ((Command==0)&&(CommandInfo==0))
          switch(Volume>>4)
          {
            case 6  : Command=0x0a; CommandInfo=Volume&15; break;
            case 7  : Command=0x0a; CommandInfo=(Volume&15)<<4; break;
            case 8  : Command=0x0e; CommandInfo=(0xb0|(Volume&15)); break;
            case 9  : Command=0x0e; CommandInfo=(0xa0|(Volume&15)); break;
            case 10 : Command=0x04; CommandInfo=(Volume&15)<<4; break;
            case 11 : Command=0x04; CommandInfo=Volume&15; break;
            case 12 : Command=0x0e; CommandInfo=(0x80|(Volume&15)); break;
            case 15 : Command=0x03; CommandInfo=(Volume&15)<<4; break;
          }
        Volume-=0x10;
		if (Volume>64)
		  Volume=255;
		else
		{
		  Volume<<=1;
		  if (Volume>127)
			Volume=127;				
		}
        if (Note==97)
          Note=128;
        else
        {
          if (Note>97)
            Note=0;
          else
            if (Note!=0)
              Note+=12;
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
    } while(PatternRow--);
    glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
  }
  //Load instruments and samples
  for (InstNo=0;InstNo<SongHdr->Instruments;InstNo++)
  {
    read(&HeaderSize,1,4,Module);
    if ((HeaderSize-4)<sizeof(XMInstHdr_Struct))
      read(InstHdr,1,HeaderSize-4,Module);
    else
    {
      read(InstHdr,1,sizeof(XMInstHdr_Struct),Module);
      seek(Module,HeaderSize-sizeof(XMInstHdr_Struct)-4,SEEK_CUR);
    }
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+InstHdr->Samples*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,InstHdr->Name,22);
    if (InstHdr->Samples)
    {
      for (Key=0;Key<96;Key++)
        glxInstruments[0][InstNo]->Split[Key+12]=InstHdr->Split[Key];
      glxInstruments[0][InstNo]->Articulation.VibType=InstHdr->VibType;
      glxInstruments[0][InstNo]->Articulation.VibDelay=InstHdr->VibSweep;
      glxInstruments[0][InstNo]->Articulation.VibDepth=(InstHdr->VibDepth<<2);
      glxInstruments[0][InstNo]->Articulation.VibSpeed=(InstHdr->VibRate<<8);
	  glxInstruments[0][InstNo]->Articulation.VolFlag=InstHdr->VType&15;
      glxInstruments[0][InstNo]->Articulation.VolSize=(InstHdr->VPoints&15)-1;
      glxInstruments[0][InstNo]->Articulation.VolSustain=InstHdr->VSPoint&15;
      glxInstruments[0][InstNo]->Articulation.VolLS=InstHdr->VLSPoint&15;
      glxInstruments[0][InstNo]->Articulation.VolLE=InstHdr->VLEPoint&15;
      glxInstruments[0][InstNo]->Articulation.PanFlag=InstHdr->PType&15;
      glxInstruments[0][InstNo]->Articulation.PanSize=(InstHdr->PPoints&15)-1;
      glxInstruments[0][InstNo]->Articulation.PanSustain=InstHdr->PSPoint&15;
      glxInstruments[0][InstNo]->Articulation.PanLS=InstHdr->PLSPoint&15;
      glxInstruments[0][InstNo]->Articulation.PanLE=InstHdr->PLEPoint&15;
      for (Key=0;Key<10;Key++)
      {
        glxInstruments[0][InstNo]->Articulation.Volume[Key].Time=InstHdr->VEnvelope[Key].Time;
        glxInstruments[0][InstNo]->Articulation.Volume[Key].Value=Amp=InstHdr->VEnvelope[Key].Volume<<9;
		if (Amp>GLX_MAXSMPVOLUME)
		  glxInstruments[0][InstNo]->Articulation.Volume[Key].Value=GLX_MAXSMPVOLUME;
      }
      glxInstruments[0][InstNo]->Articulation.VolFadeOut=((InstHdr->FadeOut+1)>>1);
      for (Key=0;Key<10;Key++)
      {
        glxInstruments[0][InstNo]->Articulation.Panning[Key].Time=InstHdr->PEnvelope[Key].Time;
        glxInstruments[0][InstNo]->Articulation.Panning[Key].Value=Amp=(InstHdr->PEnvelope[Key].Panning-32)<<10;
		if (Amp>GLX_MAXSMPPANNING)
		  glxInstruments[0][InstNo]->Articulation.Panning[Key].Value=GLX_MAXSMPPANNING;
      }
      SampleNo=0;
      while(InstHdr->Samples--)
      {
        read(SampHdr,1,InstHdr->SampHdrSize,Module);
        memset(&(glxInstruments[0][InstNo]->Sample[SampleNo]),0,sizeof(glxSample));
        glxInstruments[0][InstNo]->Samples++;
        memcpy(glxInstruments[0][InstNo]->Sample[SampleNo].Message,SampHdr->Name,22);
        if (SampHdr->Length)
        {
          glxInstruments[0][InstNo]->Sample[SampleNo].Length=SampHdr->Length;
          glxInstruments[0][InstNo]->Sample[SampleNo].LoopStart=glxInstruments[0][InstNo]->Sample[SampleNo].LoopEnd=SampHdr->LoopStart;
       	  glxInstruments[0][InstNo]->Sample[SampleNo].LoopEnd+=SampHdr->LoopLength;
          glxInstruments[0][InstNo]->Sample[SampleNo].Volume=SampHdr->Volume<<9;
		  if (glxInstruments[0][InstNo]->Sample[SampleNo].Volume>GLX_MAXSMPVOLUME)
			glxInstruments[0][InstNo]->Sample[SampleNo].Volume=GLX_MAXSMPVOLUME;
   		  glxInstruments[0][InstNo]->Sample[SampleNo].C4Speed=Finetuning[97+SampHdr->RelativeNote]-Finetuning[95+SampHdr->RelativeNote];
          glxInstruments[0][InstNo]->Sample[SampleNo].C4Speed=((glxInstruments[0][InstNo]->Sample[SampleNo].C4Speed*(128+SampHdr->FineTune))/256);
   		  glxInstruments[0][InstNo]->Sample[SampleNo].C4Speed+=Finetuning[95+SampHdr->RelativeNote];
    	  glxInstruments[0][InstNo]->Sample[SampleNo].Type=(SampHdr->Type&3)<<3;
          if (glxInstruments[0][InstNo]->Sample[SampleNo].Type&GLX_BIDILOOP)
            glxInstruments[0][InstNo]->Sample[SampleNo].Type|=GLX_LOOPED;
    	  glxInstruments[0][InstNo]->Sample[SampleNo].Type|=(SampHdr->Type&16)>>2;
          glxInstruments[0][InstNo]->Sample[SampleNo].Type|=GLX_ALWAYSLOOP|GLX_PANNING|GLX_DELTA;
          glxInstruments[0][InstNo]->Sample[SampleNo].Panning=(SampHdr->Panning<<7);
          glxInstruments[0][InstNo]->Sample[SampleNo].Reserved=0;
          if (glxInstruments[0][InstNo]->Sample[SampleNo].Type&GLX_16BITSAMPLE)
          {
            glxInstruments[0][InstNo]->Sample[SampleNo].Length>>=1;
            glxInstruments[0][InstNo]->Sample[SampleNo].LoopStart>>=1;
            glxInstruments[0][InstNo]->Sample[SampleNo].LoopEnd>>=1;
          }
        }
        SampleNo++;
      }
      for (SampleNo=0;SampleNo<glxInstruments[0][InstNo]->Samples;SampleNo++)
        if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
          return Status;
    }
  }
  //Set global player variables
  glxMusicVoices++;
  glxMinPeriod=453;
  glxMaxPeriod=65280;
  //Release header memory
  freemem(FileHdr);
  freemem(SongHdr);
  freemem(InstHdr);
  freemem(SampHdr);
  freemem(PattHdr);
  return GLXERR_NOERROR;
}
