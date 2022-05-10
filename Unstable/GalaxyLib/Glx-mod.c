/*Ä- Internal revision no. 4.00y1 -ÄÄÄ Last revision at  2:25 on 16-01-1998 -ÄÄ

                         The 32 bit MOD-Loader C source

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
  ³ This source file, GLX-MOD.C is Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* MOD File-header */
{
  ubyte  Name[20];
} MODFileHdr_Struct;

typedef struct                                  /* MOD Song-header */
{
  ubyte  SongLength;
  ubyte  RestartPos;
  ubyte  Orders[128];
  ubyte  Id[4];
} MODSongHdr_Struct;

typedef struct                                  /* MOD Pattern-header */
{
  ubyte  Data[(4*32)*64];
} MODPattHdr_Struct;

typedef struct                                  /* MOD Sample-header */
{
  ubyte  Name[22];
  ubyte  LengthHi;
  ubyte  LengthLo;
  ubyte  FineTune;
  ubyte  Volume;
  ubyte  LoopStartHi;
  ubyte  LoopStartLo;
  ubyte  LoopLengthHi;
  ubyte  LoopLengthLo;
} MODSampHdr_Struct;

#pragma pack (pop)				/* Default alignment */

int __cdecl glxLoadMOD(void *Module)
{
  static uword PeriodTable[97]={4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,
								4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,4095,
								1712,1616,1525,1440,1357,1281,1209,1141,1077,1017, 961, 907,
								856, 808, 762, 720, 678, 640, 604, 570, 538, 508, 480, 453,
								428, 404, 381, 360, 339, 320, 302, 285, 269, 254, 240, 226,
								214, 202, 190, 180, 170, 160, 151, 143, 135, 127, 120, 113,
								107, 101,  95,  90,  85,  80,  76,  71,  67,  64,  60,  57,
								  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0};
  static uword Finetuning[16]={8363, 8413, 8463, 8529, 8581, 8651, 8723, 8757,
							   7895, 7941, 7985, 8046, 8107, 8169, 8232, 8280};
  ubyte MODPanSettings[4]={26,102,102,26};
  ubyte *PatternSrcPtr,*PatternDestPtr,*PatternFlagPtr;
  ubyte Note,Instr,Command,CommandInfo;
  uword Period;
  int InstCount,PatternCount,ChannelCount;
  int InstNo,SampleNo,PatternNo,ChannelNo,OrderNo;
  MODFileHdr_Struct *FileHdr;
  MODSongHdr_Struct *SongHdr;
  MODSampHdr_Struct *SampHdr;
  MODPattHdr_Struct *PattHdr;
  int Status,PatternRow;

  //Grab some memory for the headers
  if ((FileHdr=getmem(sizeof(MODFileHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SongHdr=getmem(sizeof(MODSongHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((SampHdr=getmem(sizeof(MODSampHdr_Struct)*31))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((PattHdr=getmem(sizeof(MODPattHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load general file header
  read(FileHdr,1,sizeof(MODFileHdr_Struct),Module);
  read(SampHdr,sizeof(MODSampHdr_Struct),31,Module);
  read(SongHdr,1,sizeof(MODSongHdr_Struct),Module);
  //Check if supported type
  Status=GLXERR_UNSUPPORTEDFORMAT;
  if (memcmp(SongHdr->Id,"M.K.",4)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=4;
  }
  if (memcmp(SongHdr->Id,"M!K!",4)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=4;
  }
  if (memcmp(SongHdr->Id,"FLT4",4)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=4;
  }
  if (memcmp(SongHdr->Id,"CD81",4)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=8;
  }
  if (memcmp(SongHdr->Id+1,"CHN",3)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=(SongHdr->Id[0]-'0');
  }
  if (memcmp(SongHdr->Id+2,"CH",2)==0)
  {
    Status=GLXERR_NOERROR;
    ChannelCount=(10*(SongHdr->Id[0]-'0')+SongHdr->Id[1]-'0');
  }
  if (Status==GLXERR_UNSUPPORTEDFORMAT)
    return GLXERR_UNSUPPORTEDFORMAT;
  memcpy(glxSongName,FileHdr->Name,20);
  glxSongLength=SongHdr->SongLength-1;
  memcpy(glxOrders,SongHdr->Orders,128);
  for (PatternCount=OrderNo=0;OrderNo<128;OrderNo++)
    if (PatternCount<glxOrders[OrderNo])
      PatternCount=glxOrders[OrderNo];
  PatternCount++;
  InstCount=31;
  //Load instruments headers
  for (InstNo=0;InstNo<InstCount;InstNo++)
  {
    if ((glxInstruments[0][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample)))==NULL)
      return GLXERR_OUTOFMEMORY;
    memset(glxInstruments[0][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
    glxInstruments[0][InstNo]->FourCC=GLX_FOURCC_INST;
    glxInstruments[0][InstNo]->Size=sizeof(glxInstrument)-8;
    glxInstruments[0][InstNo]->Program=InstNo;
    memcpy(glxInstruments[0][InstNo]->Message,SampHdr[InstNo].Name,22);
    memset(glxInstruments[0][InstNo]->Split,0,128);
    glxInstruments[0][InstNo]->Samples=1;
    glxInstruments[0][InstNo]->Sample[0].Length=((SampHdr[InstNo].LengthHi<<9)+(SampHdr[InstNo].LengthLo<<1));
    glxInstruments[0][InstNo]->Sample[0].C4Speed=Finetuning[SampHdr[InstNo].FineTune&15];
    glxInstruments[0][InstNo]->Sample[0].Panning=GLX_MIDSMPPANNING;
	glxInstruments[0][InstNo]->Sample[0].Volume=SampHdr[InstNo].Volume<<9;
	if (glxInstruments[0][InstNo]->Sample[0].Volume>GLX_MAXSMPVOLUME)
      glxInstruments[0][InstNo]->Sample[0].Volume=GLX_MAXSMPVOLUME;
    glxInstruments[0][InstNo]->Sample[0].LoopStart=glxInstruments[0][InstNo]->Sample[0].LoopEnd=((SampHdr[InstNo].LoopStartHi<<9)+(SampHdr[InstNo].LoopStartLo<<1));
    glxInstruments[0][InstNo]->Sample[0].LoopEnd+=((SampHdr[InstNo].LoopLengthHi<<9)+(SampHdr[InstNo].LoopLengthLo<<1));
    if (glxInstruments[0][InstNo]->Sample[0].LoopEnd>2)
      glxInstruments[0][InstNo]->Sample[0].Type=128|8;
    else
      glxInstruments[0][InstNo]->Sample[0].Type=0;
    glxInstruments[0][InstNo]->Sample[0].Reserved=0;
  }
  //Load patterns(=note data)
  for (PatternNo=0;PatternNo<PatternCount;PatternNo++)
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
    read(PatternSrcPtr,1,64*4*ChannelCount,Module);
    for (PatternRow=0;PatternRow<64;PatternRow++)
    {
      for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
      {
        Period=(((PatternSrcPtr[0]&15)<<8)+(PatternSrcPtr[1]));
        Instr=((PatternSrcPtr[0]&16)+((PatternSrcPtr[2]&240)>>4));
        Command=(PatternSrcPtr[2]&15);
        CommandInfo=PatternSrcPtr[3];
        Note=0;
        if (Period)
        {
          while (Period<PeriodTable[Note])
            Note++;
          Note+=12;
        }
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
        PatternSrcPtr+=4;
      }
      *PatternDestPtr++=0;
    }
    glxPatterns[PatternNo]->Track[0].Events=resizemem(glxPatterns[PatternNo]->Track[0].Events,(PatternDestPtr-glxPatterns[PatternNo]->Track[0].Events));
  }
  // Load samples
  for (InstNo=0;InstNo<InstCount;InstNo++)
    for (SampleNo=0;SampleNo<glxInstruments[0][InstNo]->Samples;SampleNo++)
      if (Status=LoadSample(&(glxInstruments[0][InstNo]->Sample[SampleNo]),Module))
        return Status;
  // Set stereo/panning image
  for (ChannelNo=0;ChannelNo<ChannelCount;ChannelNo++)
    glxInitialPanning[ChannelNo]=MODPanSettings[ChannelNo&3];
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
