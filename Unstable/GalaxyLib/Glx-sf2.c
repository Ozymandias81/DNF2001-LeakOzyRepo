/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 13:03 on 21-03-1998 -ÄÄ

                         The 32 bit SF2-Loader C source

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
  ³ This source file, GLX-SF2.C  is Copyright (c) 1993-98 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include <math.h>
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* SF File-header */
{
  ubyte  Id[4];
  udword Size;
  ubyte  Type[4];
} SFFileHdr_Struct;

typedef struct                                  /* SF Chunk-header */
{
  ubyte  Id[4];
  udword Size;
} SFChunkHdr_Struct;

typedef struct                                  /* SF Preset-header */
{ char   Name[20];
  uword  Preset;
  uword  Bank;
  uword  BagIndex;
  udword Library;
  udword Genre;
  udword Morphology;
} SFPsetHdr_Struct;

typedef struct                                  /* SF Zone list-header */
{ uword  GenIndex;
  uword  ModIndex;
} SFPbagHdr_Struct;

typedef struct                                  /* SF Generator-header */
{ uword  Type;
  sword  Value;
} SFPGenHdr_Struct;

typedef struct                                  /* SF Instrument-header */
{ char   Name[20];
  uword  BagIndex;
} SFInstHdr_Struct;

typedef struct                                  /* SF Zone list-header */
{ uword  GenIndex;
  uword  ModIndex;
} SFIbagHdr_Struct;

typedef struct                                  /* SF Generator-header */
{ uword  Type;
  sword  Value;
} SFIGenHdr_Struct;

typedef struct                                  /* SF Sample-header */
{
  char   Name[20];
  udword Start;
  udword End;
  udword LoopStart;
  udword LoopEnd;
  udword SampleRate;
  ubyte  Key;
  sbyte  Finetune;
  uword  SampleLink;
  uword  SampleType;
} SFSmplHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadSF2(int InsNo,void *Stream,int Mode)
{
  int PVDelay,PVAttack,PVHold,PVDecay,PVSustainLev,PVRelease;
  int PMDelay,PMAttack,PMHold,PMDecay,PMSustainLev,PMRelease;
  int PAttenuation,PPanning;
  int GVDelay,GVAttack,GVHold,GVDecay,GVSustainLev,GVRelease;
  int GMDelay,GMAttack,GMHold,GMDecay,GMSustainLev,GMRelease;
  int GAttenuation,GPanning,GVibDelay,GVibSpeed,GVibDepth;
  int GTremDelay,GTremSpeed,GTremDepth;
  int VDelay,VAttack,VHold,VDecay,VSustainLev,VRelease;
  int MDelay,MAttack,MHold,MDecay,MSustainLev,MRelease;
  int Attenuation,Panning,VibDelay,VibSpeed,VibDepth;
  int TremDelay,TremSpeed,TremDepth;
  int Status=0,Ins,PNo=0,Bank,Key,i,j,k,l,newroot,globalzone;
  float IRootKey,PRootKey,PitchEnvAmp;
  sword *SampleData,*RealData;
  SFInstHdr_Struct *Instrument;
  SFPsetHdr_Struct *Preset;
  SFIGenHdr_Struct *InstGen;
  SFPGenHdr_Struct *PsetGen;
  SFChunkHdr_Struct ChunkHdr;
  SFFileHdr_Struct FileHdr;
  SFSmplHdr_Struct *Sample;
  SFIbagHdr_Struct *IZone;
  SFPbagHdr_Struct *PZone;
  glxSample SampleHdr;

  read(&FileHdr,1,sizeof(SFFileHdr_Struct),Stream);
  FileHdr.Size=((FileHdr.Size+1)&~1)-4;
  while (FileHdr.Size>sizeof(SFChunkHdr_Struct))
  {
    if (read(&ChunkHdr,1,sizeof(SFChunkHdr_Struct),Stream))
    {
      if (!memcmp(ChunkHdr.Id,"LIST",4))
      {
        FileHdr.Size-=12;
        seek(Stream,4,SEEK_CUR);
        read(&ChunkHdr,1,sizeof(SFChunkHdr_Struct),Stream);
      }
      if (!memcmp(ChunkHdr.Id,"smpl",4))
      {
        if ((SampleData=getmem(ChunkHdr.Size))!=NULL)
          read(SampleData,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"phdr",4))
      {
        if ((Preset=getmem(ChunkHdr.Size))!=NULL)
          read(Preset,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"pbag",4))
      {
        if ((PZone=getmem(ChunkHdr.Size))!=NULL)
          read(PZone,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"pgen",4))
      {
        if ((PsetGen=getmem(ChunkHdr.Size))!=NULL)
          read(PsetGen,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"inst",4))
      {
        if ((Instrument=getmem(ChunkHdr.Size))!=NULL)
          read(Instrument,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"ibag",4))
      {
        if ((IZone=getmem(ChunkHdr.Size))!=NULL)
          read(IZone,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"igen",4))
      {
        if ((InstGen=getmem(ChunkHdr.Size))!=NULL)
          read(InstGen,1,ChunkHdr.Size,Stream);
      }
      else if (!memcmp(ChunkHdr.Id,"shdr",4))
      {
        if ((Sample=getmem(ChunkHdr.Size))!=NULL)
          read(Sample,1,ChunkHdr.Size,Stream);
      }
      else seek(Stream,ChunkHdr.Size,SEEK_CUR);
      seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
      FileHdr.Size-=(((ChunkHdr.Size+1)&~1)+8);
    }
  }
  //Done reading all important chunks, now start converting..
  while (memcmp(Preset[PNo].Name,"EOP",3)!=0)
  {
    if (((Preset[PNo].Bank==0)||(Preset[PNo].Bank==128))&&(Preset[PNo].Preset<GLX_TOTALINSTR))
    {
      Ins=Preset[PNo].Preset;
      Bank=Preset[PNo].Bank;
      if (Preset[PNo].Bank==128)
        Bank=1;
      if (glxInstruments[Bank][Ins]==NULL)
      {
        glxInstruments[Bank][Ins]=getmem(sizeof(glxInstrument));
        memset(glxInstruments[Bank][Ins],0,sizeof(glxInstrument));
        glxInstruments[Bank][Ins]->FourCC=GLX_FOURCC_INST;
        glxInstruments[Bank][Ins]->Size=sizeof(glxInstrument)-8;
        glxInstruments[Bank][Ins]->Bank=Bank;
        glxInstruments[Bank][Ins]->Program=Ins;
        memcpy(glxInstruments[Bank][Ins]->Message,Preset[PNo].Name,20);
      }
      //Init default PRESET values for envelope
      PAttenuation=0;
	  PPanning=0;
	  PVDelay=PMDelay=0;
      PVAttack=PMAttack=0;
      PVHold=PMHold=0;
      PVDecay=PMDecay=0;
      PVSustainLev=PMSustainLev=0;
      PVRelease=PMRelease=0;
      PRootKey=0.0;
      //Now build PRESET according to generators
      for (i=Preset[PNo].BagIndex;i<Preset[PNo+1].BagIndex;i++)
      {
        for (j=PZone[i].GenIndex;j<PZone[i+1].GenIndex;j++)
        {
          //Handle all generators within one PRESET zone
          switch (PsetGen[j].Type)
          {
            case 25://Delay (mod env)
                    if (PsetGen[j].Value<5000)
                      PMDelay=PsetGen[j].Value;
                    else
                      PMDelay=5000;
                    break;
            case 26://Attack (mod env)
                    if (PsetGen[j].Value<8000)
                      PMAttack=PsetGen[j].Value;
                    else
                      PMAttack=8000;
                    break;
            case 27://Hold (mod env)
                    if (PsetGen[j].Value<5000)
                      PMHold=PsetGen[j].Value;
                    else
                      PMHold=5000;
                    break;
            case 28://Decay (mod env)
                    if (PsetGen[j].Value<8000)
                      PMDecay=PsetGen[j].Value;
                    else
                      PMDecay=8000;
                    break;
            case 29://Sustain (mod env)
                    if (PsetGen[j].Value>0)
                      PMSustainLev=PsetGen[j].Value;
                    else
                      PMSustainLev=0;
                    break;
            case 30://Release (mod env)
                    if (PsetGen[j].Value<8000)
                      PMRelease=PsetGen[j].Value;
                    else
                      PMRelease=8000;
                    break;
            case 33://Delay (vol env)
                    if (PsetGen[j].Value<5000)
                      PVDelay=PsetGen[j].Value;
                    else
                      PVDelay=5000;
                    break;
            case 34://Attack (vol env)
                    if (PsetGen[j].Value<8000)
                      PVAttack=PsetGen[j].Value;
                    else
                      PVAttack=8000;
                    break;
            case 35://Hold (vol env)
                    if (PsetGen[j].Value<5000)
                      PVHold=PsetGen[j].Value;
                    else
                      PVHold=5000;
                    break;
            case 36://Decay (vol env)
                    if (PsetGen[j].Value<8000)
                      PVDecay=PsetGen[j].Value;
                    else
                      PVDecay=8000;
                    break;
            case 37://Sustain (vol env)
                    if (PsetGen[j].Value>0)
                      PVSustainLev=PsetGen[j].Value;
                    else
                      PVSustainLev=0;
                    break;
            case 38://Release (vol env)
                    if (PsetGen[j].Value<8000)
                      PVRelease=PsetGen[j].Value;
                    else
                      PVRelease=8000;
                    break;
            case 41://Instrument ID, build instrument from zones
				    GAttenuation=0;
					GPanning=0;
					GVibDelay=-12000;
					GVibSpeed=0;
					GVibDepth=0;
					GTremDelay=-12000;
					GTremSpeed=0;
					GTremDepth=0;
					GVDelay=GMDelay=-12000;
					GVAttack=GMAttack=-12000;
					GVHold=GMHold=-12000;
					GVDecay=GMDecay=-12000;
					GVSustainLev=GMSustainLev=0;
				    GVRelease=GMRelease=-12000;
					for (k=Instrument[PsetGen[j].Value].BagIndex;k<Instrument[PsetGen[j].Value+1].BagIndex;k++)
                    {
					  Attenuation=GAttenuation;
					  Panning=GPanning;
					  VibDelay=GVibDelay;
					  VibSpeed=GVibSpeed;
					  VibDepth=GVibDepth;
					  TremDelay=GTremDelay;
					  TremSpeed=GTremSpeed;
					  TremDepth=GTremDepth;
					  VDelay=GVDelay;
					  MDelay=GMDelay;
					  VAttack=GVAttack;
					  MAttack=GMAttack;
					  VHold=GVHold;
					  MHold=GMHold;
					  VDecay=GVDecay;
					  MDecay=GMDecay;
					  VSustainLev=GVSustainLev;
					  MSustainLev=GMSustainLev;
					  VRelease=GVRelease;
					  MRelease=GMRelease;
					  IRootKey=PRootKey;
					  PitchEnvAmp=0;
					  newroot=0;
					  globalzone=1;
                      memset(&SampleHdr,0,sizeof(glxSample));
                      SampleHdr.FourCC=GLX_FOURCC_SAMP;
                      SampleHdr.Size=sizeof(glxSample)-8;
					  SampleHdr.Articulation=getmem(sizeof(glxArti));
                      memset(SampleHdr.Articulation,0,sizeof(glxArti));
					  //Handle all zones within one instrument
                      for (l=IZone[k].GenIndex;l<IZone[k+1].GenIndex;l++)
                      {
                        //Handle all generators within one zone
                        switch (InstGen[l].Type)
                        {
                          case  0://StartAddressOffset (Low)
                                  ((sdword)SampleHdr.Data)+=InstGen[l].Value;
                                  break;
                          case  1://EndAddressOffset (Low)
                                  SampleHdr.Length+=InstGen[l].Value;
                                  break;
                          case  2://LoopStartAddressOffset
                                  SampleHdr.LoopStart+=InstGen[l].Value;
                                  break;
                          case  3://LoopEndAddressOffset
                                  SampleHdr.LoopEnd+=InstGen[l].Value;
                                  break;
                          case  4://StartAddressOffset (High)
                                  ((sdword)SampleHdr.Data)+=InstGen[l].Value<<15;
                                  break;
                          case  6://Vibrato LFO to pitch (Vibrato depth)
                                  VibDepth=InstGen[l].Value;
                                  break;
						  case  7://Pitch envelope scale
								  PitchEnvAmp=((256*InstGen[l].Value)/100);
								  break;
                          case 12://EndAddressOffset (High)
                                  SampleHdr.Length+=InstGen[l].Value<<15;
                                  break;
                          case 13://Modulation LFO to volume (Tremolo depth)
                                  TremDepth=InstGen[l].Value;
                                  break;
                          case 17://Panning
                                  Panning=InstGen[l].Value;
								  SampleHdr.Type|=32;
                                  break;
                          case 21://Modulation LFO delay (Tremolo delay)
                                  TremDelay=InstGen[l].Value;
                                  break;
                          case 22://Modulation LFO freq. (Tremolo speed)
                                  TremSpeed=InstGen[l].Value;
                                  break;
                          case 23://Vibrato LFO delay (Vibrato delay)
                                  VibDelay=InstGen[l].Value;
                                  break;
                          case 24://Vibrato LFO freq. (Vibrato speed)
                                  VibSpeed=InstGen[l].Value;
                                  break;
						  case 25://Delay (mod env)
								  if (InstGen[l].Value<5000)
								    MDelay=InstGen[j].Value;
								  else
									MDelay=5000;
								  break;
						  case 26://Attack (mod env)
								  if (InstGen[l].Value<8000)
									MAttack=InstGen[l].Value;
								  else
									MAttack=8000;
								  break;
						  case 27://Hold (mod env)
								  if (InstGen[l].Value<5000)
									MHold=InstGen[l].Value;
								  else
									MHold=5000;
								  break;
						  case 28://Decay (mod env)
								  if (InstGen[l].Value<8000)
									MDecay=InstGen[l].Value;
								  else
									MDecay=8000;
								  break;
						  case 29://Sustain (mod env)
								  if (InstGen[l].Value>0)
									MSustainLev=InstGen[l].Value;
								  else
									MSustainLev=0;
								  break;
						  case 30://Release (mod env)
								  if (InstGen[l].Value<8000)
									MRelease=InstGen[l].Value;
								  else
									MRelease=8000;
								  break;
						  case 33://Delay (vol env)
								  if (InstGen[l].Value<5000)
									VDelay=InstGen[l].Value;
								  else
									VDelay=5000;
								  break;
						  case 34://Attack (vol env)
								  if (InstGen[l].Value<8000)
									VAttack=InstGen[l].Value;
								  else
									VAttack=8000;
								  break;
						  case 35://Hold (vol env)
								  if (InstGen[l].Value<5000)
									VHold=InstGen[l].Value;
								  else
									VHold=5000;
								  break;
						  case 36://Decay (vol env)
								  if (InstGen[l].Value<8000)
									VDecay=InstGen[l].Value;
								  else
									VDecay=8000;
								  break;
						  case 37://Sustain (vol env)
								  if (InstGen[l].Value>0)
									VSustainLev=InstGen[l].Value;
								  else
									VSustainLev=0;
								  break;
						  case 38://Release (vol env)
								  if (InstGen[l].Value<8000)
									VRelease=InstGen[l].Value;
								  else
									VRelease=8000;
								  break;
                          case 43://Key range
                                  for (Key=(InstGen[l].Value&0x7f);Key<=((InstGen[l].Value>>8)&0x7f);Key++)
           							if (!glxInstruments[Bank][Ins]->Split[Key])
										glxInstruments[Bank][Ins]->Split[Key]=glxInstruments[Bank][Ins]->Samples;
                                  break;
                          case 45://LoopStartAddressOffset (High)
                                  SampleHdr.LoopStart+=InstGen[l].Value<<15;
                                  break;
                          case 47://Velocity
                                  break;
                          case 48://Initial attenuation
                                    if (InstGen[l].Value>0)
                                      Attenuation=InstGen[l].Value;
                                    else
                                      Attenuation=0;
                                  break;
                          case 50://LoopEndAddressOffset (High)
                                  SampleHdr.LoopEnd+=InstGen[l].Value<<15;
                                  break;
                          case 51://finetune (semitones)
                                  IRootKey-=InstGen[l].Value;
                                  break;
                          case 52://finetune (cents)
                                  IRootKey-=(InstGen[l].Value/100.0);
                                  break;
                          case 53://Sample ID (mark zone as NON global)
                                  globalzone=0;
								  if ((Sample[InstGen[l].Value].SampleType&32768)==0)
                                  {
									//Build sample structure  
									memcpy(SampleHdr.Message,Sample[InstGen[l].Value].Name,20);
                                    if ((PAttenuation+Attenuation)>0)
                                      SampleHdr.Volume=((float)GLX_MAXSMPVOLUME*pow(10.0,-((PAttenuation+Attenuation)*0.375)/200.0));
                                    else
                                      SampleHdr.Volume=GLX_MAXSMPVOLUME;
									SampleHdr.Type|=GLX_16BITSAMPLE;
									SampleHdr.Panning=GLX_MIDSMPPANNING+((GLX_MIDSMPPANNING*(PPanning+Panning))/500);
									SampleHdr.Length+=(Sample[InstGen[l].Value].End-Sample[InstGen[l].Value].Start);
                                    SampleHdr.LoopStart+=(Sample[InstGen[l].Value].LoopStart-Sample[InstGen[l].Value].Start);
                                    SampleHdr.LoopEnd+=(Sample[InstGen[l].Value].LoopEnd-Sample[InstGen[l].Value].Start);
                                    if (newroot)
                                      SampleHdr.C4Speed+=(Sample[InstGen[l].Value].SampleRate*pow(2.0,(60.0-(                             IRootKey-Sample[InstGen[l].Value].Finetune/100.0))/12.0));
                                    else
                                      SampleHdr.C4Speed+=(Sample[InstGen[l].Value].SampleRate*pow(2.0,(60.0-(Sample[InstGen[l].Value].Key+IRootKey-Sample[InstGen[l].Value].Finetune/100.0))/12.0));
                                    //Copy sample data
									RealData=SampleHdr.Data;
                                    SampleHdr.Data=getmem((SampleHdr.Length+32)<<1);
                                    memcpy(SampleHdr.Data,SampleData+((sdword)RealData)+Sample[InstGen[l].Value].Start,SampleHdr.Length<<1);
									memset(((sword *)SampleHdr.Data)+SampleHdr.Length,0,32<<1);
									//Build articulation data
									SampleHdr.Articulation->VibDelay=(1000.0*pow(2.0,VibDelay/1200.0));
									SampleHdr.Articulation->VibDepth=((256*VibDepth)/100);
									SampleHdr.Articulation->VibSpeed=(64.0*(8.176*pow(2.0,VibSpeed/1200.0)));
                                    SampleHdr.Articulation->TremDelay=(1000.0*pow(2.0,TremDelay/1200.0));
                                    SampleHdr.Articulation->TremDepth=(32767.0*(pow(10.0,TremDepth/200.0)-1.0));
									SampleHdr.Articulation->TremSpeed=(64.0*(8.176*pow(2.0,TremSpeed/1200.0)));
									//Build volume envelope
                                    SampleHdr.Articulation->VolFlag=3;
									SampleHdr.Articulation->VolSize=4;
									SampleHdr.Articulation->VolSustain=4;
                                    if ((PVDelay+VDelay)<5000)
                                      SampleHdr.Articulation->Volume[1].Time=(1000.0*pow(2.0,(PVDelay+VDelay)/1200.0));
                                    else
                                      SampleHdr.Articulation->Volume[1].Time=(1000.0*18.0);
                                    if ((PVAttack+VAttack)<8000)
                                      SampleHdr.Articulation->Volume[2].Time=(1000.0*pow(2.0,(PVAttack+VAttack)/1200.0));
                                    else
                                      SampleHdr.Articulation->Volume[2].Time=(1000.0*102.0);
                                    if ((PVHold+VHold)<5000)
                                      SampleHdr.Articulation->Volume[3].Time=(1000.0*pow(2.0,(PVHold+VHold)/1200.0));
                                    else
                                      SampleHdr.Articulation->Volume[3].Time=(1000.0*18.0);
                                    if ((PVDecay+VDecay)<8000)
                                      SampleHdr.Articulation->Volume[4].Time=((1000.0*pow(2.0,(PVDecay+VDecay)/1200.0))/(5.0*log(10.0)));
                                    else
                                      SampleHdr.Articulation->Volume[4].Time=(1000.0*9.4);
									SampleHdr.Articulation->Volume[2].Value=32767;
									SampleHdr.Articulation->Volume[3].Value=32767;
                                    if ((PVSustainLev+VSustainLev)>0)
                                      SampleHdr.Articulation->Volume[4].Value=(32767.0*pow(10.0,-(PVSustainLev+VSustainLev)/200.0));
                                    else
                                      SampleHdr.Articulation->Volume[4].Value=32767;
									SampleHdr.Articulation->Volume[4].Time=((SampleHdr.Articulation->Volume[4].Time*(32767-SampleHdr.Articulation->Volume[4].Value))/32768);
                                    SampleHdr.Articulation->Volume[2].Time+=SampleHdr.Articulation->Volume[1].Time;
                                    SampleHdr.Articulation->Volume[3].Time+=SampleHdr.Articulation->Volume[2].Time;
                                    SampleHdr.Articulation->Volume[4].Time+=SampleHdr.Articulation->Volume[3].Time;
                                    if ((PVRelease+VRelease)>-7500)
									  SampleHdr.Articulation->VolFadeOut=(32767.0/((1000.0*pow(2.0,(PVRelease+VRelease)/1200.0))/(5.0*log(10.0))));
									else
									  SampleHdr.Articulation->VolFadeOut=32767;
									//Build pitch envelope
									SampleHdr.Articulation->PitFlag=3;
									SampleHdr.Articulation->PitSize=4;
									SampleHdr.Articulation->PitSustain=4;
									if ((PMDelay+MDelay)<5000)
                                      SampleHdr.Articulation->Pitch[1].Time=(1000.0*pow(2.0,(PMDelay+MDelay)/1200.0));
									else
                                      SampleHdr.Articulation->Pitch[1].Time=(1000.0*18.0);
                                    if ((PMAttack+MAttack)<8000)
                                      SampleHdr.Articulation->Pitch[2].Time=(1000.0*pow(2.0,(PMAttack+MAttack)/1200.0));
                                    else
                                      SampleHdr.Articulation->Pitch[2].Time=(1000.0*102.0);
                                    if ((PMHold+MHold)<5000)
                                      SampleHdr.Articulation->Pitch[3].Time=(1000.0*pow(2.0,(PMHold+MHold)/1200.0));
                                    else
                                      SampleHdr.Articulation->Pitch[3].Time=(1000.0*18.0);
                                    if ((PMDecay+MDecay)<8000)
                                      SampleHdr.Articulation->Pitch[4].Time=((1000.0*pow(2.0,(PMDecay+MDecay)/1200.0))/(5.0*log(10.0)));
                                    else
                                      SampleHdr.Articulation->Pitch[4].Time=(1000.0*9.4);
									SampleHdr.Articulation->Pitch[2].Value=PitchEnvAmp;
									SampleHdr.Articulation->Pitch[3].Value=PitchEnvAmp;
									if ((PMSustainLev+MSustainLev)>0)
                                      SampleHdr.Articulation->Pitch[4].Value=(PitchEnvAmp*pow(10.0,-(PMSustainLev+MSustainLev)/200.0));
                                    else
                                      SampleHdr.Articulation->Pitch[4].Value=PitchEnvAmp;
                                    SampleHdr.Articulation->Pitch[4].Time=((SampleHdr.Articulation->Pitch[4].Time*(32767-SampleHdr.Articulation->Pitch[4].Value))/32768);
                                    SampleHdr.Articulation->Pitch[2].Time+=SampleHdr.Articulation->Pitch[1].Time;
                                    SampleHdr.Articulation->Pitch[3].Time+=SampleHdr.Articulation->Pitch[2].Time;
                                    SampleHdr.Articulation->Pitch[4].Time+=SampleHdr.Articulation->Pitch[3].Time;
                                    if ((PMRelease+MRelease)>-7500)
									  SampleHdr.Articulation->PitFadeOut=(32767.0/((1000.0*pow(2.0,(PMRelease+MRelease)/1200.0))/(5.0*log(10.0))));
									else
									  SampleHdr.Articulation->PitFadeOut=32767;
									//Update instrument structure
                                    glxInstruments[Bank][Ins]=resizemem(glxInstruments[Bank][Ins],sizeof(glxInstrument)+(glxInstruments[Bank][Ins]->Samples+1)*sizeof(glxSample));
                                    memcpy(&glxInstruments[Bank][Ins]->Sample[glxInstruments[Bank][Ins]->Samples],&SampleHdr,sizeof(glxSample));
                                    glxInstruments[Bank][Ins]->Samples++;
                                  }
                                  l=IZone[k+1].GenIndex;
                                  break;
                          case 54://Sample mode (looping)
                                  if (InstGen[l].Value==2)
                                    InstGen[l].Value=0;
                                  SampleHdr.Type|=((InstGen[l].Value&1)<<3);
                                  SampleHdr.Type|=(((InstGen[l].Value&2)<<6)^128);
                                  break;
                          case 58://New root key
                                  newroot=1;
                                  IRootKey+=InstGen[l].Value;
                                  break;
                        }
                      }
                      //Finished another instrument zone !!
					  if (globalzone)
					  {
  						GAttenuation=Attenuation;
						GPanning=Panning;
						GVibDelay=VibDelay;
						GVibSpeed=VibSpeed;
						GVibDepth=VibDepth;
						GTremDelay=TremDelay;
						GTremSpeed=TremSpeed;
						GTremDepth=TremDepth;
						GVDelay=VDelay;
						GMDelay=MDelay;
						GVAttack=VAttack;
						GMAttack=MAttack;
						GVHold=VHold;
						GMHold=MHold;
						GVDecay=VDecay;
						GMDecay=MDecay;
						GVSustainLev=VSustainLev;
						GMSustainLev=MSustainLev;
						GVRelease=VRelease;
						GMRelease=MRelease;
					  }
					}
                    j=PZone[i+1].GenIndex;
                    break;
			case 43://Key range
                    for (Key=(PsetGen[j].Value&0x7f);Key<=((PsetGen[j].Value>>8)&0x7f);Key++)
                      if (!glxInstruments[Bank][Ins]->Split[Key])
						glxInstruments[Bank][Ins]->Split[Key]=glxInstruments[Bank][Ins]->Samples;
                    break;
            case 51://finetune (semitones)
                    PRootKey-=PsetGen[j].Value;
                    break;
            case 52://finetune (cents)
                    PRootKey-=(PsetGen[j].Value/100.0);
                    break;
          }
        }
      }
    }
    PNo++;
  }
  freemem(Sample);
  freemem(InstGen);
  freemem(PsetGen);
  freemem(IZone);
  freemem(PZone);
  freemem(Preset);
  freemem(Instrument);
  freemem(SampleData);
  return Status;
}
