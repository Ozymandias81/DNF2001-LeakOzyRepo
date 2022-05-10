/*Ä- Internal revision no. 5.00b -ÄÄÄÄ Last revision at 19:12 on 12-05-1998 -ÄÄ

                         The 32 bit AM-Loader C source

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
  ³ This source file, GLX-AM.C is Copyright  (c)  1993-98 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

int __cdecl glxLoadAM(void *Stream,int Mode)
{
  udword PatternSize,StreamSize;
  ubyte Status=GLXERR_NOERROR;
  ubyte PatternNo,StreamNo;
  glxChunk Chunk;
  glxForm Form;

  read(&Form,1,sizeof(Form),Stream);
  Form.Size-=4;
  while ((Form.Size!=0)&&(Status==GLXERR_NOERROR))
  {
    if (read(&Chunk,1,sizeof(Chunk),Stream)==sizeof(Chunk))
    {
      if (Chunk.FourCC==GLX_FOURCC_INIT)
      {
        read(glxSongName,1,sizeof(glxSongName),Stream);
        read(glxAuthorName,1,sizeof(glxAuthorName),Stream);
		read(&glxPlayerMode,1,sizeof(glxPlayerMode),Stream);
        read(&glxMusicVoices,1,sizeof(glxMusicVoices),Stream);
        read(&glxInitialSpeed,1,sizeof(glxInitialSpeed),Stream);
        read(&glxInitialTempo,1,sizeof(glxInitialTempo),Stream);
        read(&glxMinPeriod,1,sizeof(glxMinPeriod),Stream);
        read(&glxMaxPeriod,1,sizeof(glxMaxPeriod),Stream);
        read((void *)&glxMusicVolume,1,sizeof(glxMusicVolume),Stream);
        read(glxInitialPanning,1,glxMusicVoices,Stream);
      }
      else if (Chunk.FourCC==GLX_FOURCC_ORDR)
      {
        read(&glxSongLength,1,sizeof(glxSongLength),Stream);
        read(glxOrders,1,(glxSongLength+1),Stream);
      }
      else if (Chunk.FourCC==GLX_FOURCC_PATT)
      {
        read(&PatternNo,1,sizeof(PatternNo),Stream);
        read(&PatternSize,1,sizeof(PatternSize),Stream);
		glxPatterns[PatternNo]=getmem(sizeof(glxPattern)+sizeof(glxTrack));
		memset(glxPatterns[PatternNo],0,sizeof(glxPattern)+sizeof(glxTrack));
		glxPatterns[PatternNo]->FourCC=GLX_FOURCC_PATT;
		glxPatterns[PatternNo]->Size=2+sizeof(glxTrack);
		glxPatterns[PatternNo]->Tracks=1;
		glxPatterns[PatternNo]->Track[0].FourCC=GLX_FOURCC_TRAK;
		glxPatterns[PatternNo]->Track[0].Size=sizeof(glxTrack)-8;
		glxPatterns[PatternNo]->Track[0].Events=getmem(PatternSize);
        read(glxPatterns[PatternNo]->Track[0].Events,1,PatternSize,Stream);
      }
      else if (Chunk.FourCC==GLX_FOURCC_STRM)
      {
        read(&StreamNo,1,sizeof(StreamNo),Stream);
        read(&StreamSize,1,sizeof(StreamSize),Stream);
		glxPatterns[StreamNo]=getmem(sizeof(glxPattern)+sizeof(glxTrack));
		memset(glxPatterns[StreamNo],0,sizeof(glxPattern)+sizeof(glxTrack));
		glxPatterns[StreamNo]->FourCC=GLX_FOURCC_PATT;
		glxPatterns[StreamNo]->Size=2+sizeof(glxTrack);
		glxPatterns[StreamNo]->Tracks=1;
		glxPatterns[StreamNo]->Track[0].FourCC=GLX_FOURCC_TRAK;
		glxPatterns[StreamNo]->Track[0].Size=sizeof(glxTrack)-8;
		glxPatterns[StreamNo]->Track[0].Events=getmem(StreamSize);
        read(glxPatterns[StreamNo]->Track[0].Events,1,StreamSize,Stream);
      }
      else if ((Chunk.FourCC==GLX_FOURCC_RIFF)||(Chunk.FourCC==GLX_FOURCC_LIST))
      {
        seek(Stream,-sizeof(Chunk),SEEK_CUR);
        glxLoadInstrument(-1,Stream,Mode);
		seek(Stream,-(Chunk.Size&1),SEEK_CUR);
	  }
      else seek(Stream,Chunk.Size,SEEK_CUR);
      seek(Stream,Chunk.Size&1,SEEK_CUR);
      Form.Size-=(((Chunk.Size+1)&~1)+8);
    }
    else
      Status=GLXERR_UNSUPPORTEDFORMAT;
  }
  return Status;
}

int glxSaveAM(void *Stream,int Mode)
{
  ubyte Flag,Tag,BankNo,InstNo,PatternNo,OrderNo,PadByte=0;
  char PattUsed[256],InstUsed[2][128];
  int StreamSize=0,PatternSize;
  ubyte *PatternSrcPtr;
  ubyte PatternRow;
  glxChunk Chunk;
  glxForm Form;

  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=4;
  Form.Type=GLX_FOURCC_AM;		
  if (Stream)
	write(&Form,1,sizeof(Form),Stream);
  StreamSize+=sizeof(Form);
  Chunk.FourCC=GLX_FOURCC_INIT;
  Chunk.Size=(32+32+1+1+2+2+2+2+1+glxMusicVoices);
  if (Stream)
  {
    write(&Chunk,1,sizeof(Chunk),Stream);
    write(glxSongName,1,sizeof(glxSongName),Stream);
    write(glxAuthorName,1,sizeof(glxAuthorName),Stream);
    write(&glxPlayerMode,1,sizeof(glxPlayerMode),Stream);
    write(&glxMusicVoices,1,sizeof(glxMusicVoices),Stream);
    write(&glxInitialSpeed,1,sizeof(glxInitialSpeed),Stream);
    write(&glxInitialTempo,1,sizeof(glxInitialTempo),Stream);
    write(&glxMinPeriod,1,sizeof(glxMinPeriod),Stream);
    write(&glxMaxPeriod,1,sizeof(glxMaxPeriod),Stream);
    write((void *)&glxMusicVolume,1,sizeof(glxMusicVolume),Stream);
    write(glxInitialPanning,1,glxMusicVoices,Stream);
	write(&PadByte,1,Chunk.Size&1,Stream);
  }
  StreamSize+=(sizeof(Chunk)+32+32+1+1+2+2+2+2+1+glxMusicVoices+(Chunk.Size&1));
  Chunk.FourCC=GLX_FOURCC_ORDR;
  Chunk.Size=(1+glxSongLength+1);
  if (Stream)
  {
    write(&Chunk,1,sizeof(Chunk),Stream);
    write(&glxSongLength,1,sizeof(glxSongLength),Stream);
    write(glxOrders,1,glxSongLength+1,Stream);
	write(&PadByte,1,Chunk.Size&1,Stream);
  }
  StreamSize+=(sizeof(Chunk)+1+glxSongLength+1+(Chunk.Size&1));
  memset(InstUsed,0,sizeof(InstUsed));
  memset(PattUsed,0,sizeof(PattUsed));
  for (OrderNo=0;OrderNo<=glxSongLength;OrderNo++)
  {
    PatternNo=glxOrders[OrderNo];
    if ((PatternNo<254)&&((PatternSrcPtr=glxPatterns[PatternNo]->Track[0].Events)!=NULL)&&(PattUsed[PatternNo]==0))
    {
      PatternSize=0;
	  PattUsed[PatternNo]=1;
      if ((glxPlayerMode&2)==0)
      {
        while (!((PatternSrcPtr[PatternSize]==128)&&(PatternSrcPtr[PatternSize+2]==0)&&(PatternSrcPtr[PatternSize+3]==0)))
        {
          Flag=PatternSrcPtr[PatternSize++];
		  Tag=PatternSrcPtr[PatternSize++];
          if (Flag&128)
            PatternSize+=2;
          if (Flag&64)
          {
            switch(PatternSrcPtr[PatternSize++])
            {
              case 0x00: InstUsed[(PatternSrcPtr[PatternSize]&128)>>7][PatternSrcPtr[PatternSize]&127]=1;
                         PatternSize++;   //Program
                         break;
              case 0x01: PatternSize++;   //Panning
                         break;
              case 0x02: PatternSize++;   //Volume
                         break;
              case 0x03: PatternSize++;   //Modulation
                         break;
              case 0x04: PatternSize+=2;  //Pitch bend
                         break;
              case 0x05: PatternSize++;   //Speed
                         break;
              case 0x06: PatternSize+=2;  //Tempo
                         break;
              case 0x07: PatternSize++;   //Portamento
                         break;
              case 0x08: PatternSize+=2;  //Portamento speed
                         break;
              case 0x09: PatternSize++;   //Reverb
                         break;
              case 0x0a: PatternSize++;   //Chorus
                         break;
              default  : break;

            }
          }
          else
          {
            if ((PatternSrcPtr[PatternSize]&128)==0)
            {
              InstUsed[(PatternSrcPtr[PatternSize+2]&128)>>7][PatternSrcPtr[PatternSize+2]&127]=1;
              PatternSize+=5;
            }
            else
              PatternSize+=2;
          }
        }
        PatternSize+=4;
		Chunk.FourCC=GLX_FOURCC_STRM;
  	    Chunk.Size=(1+4+PatternSize);
        if (Stream)
        {
		  write(&Chunk,1,sizeof(Chunk),Stream);
          write(&PatternNo,1,sizeof(PatternNo),Stream);
          write(&PatternSize,1,sizeof(PatternSize),Stream);
          write(glxPatterns[PatternNo]->Track[0].Events,1,PatternSize,Stream);
		  write(&PadByte,1,Chunk.Size&1,Stream);
        }
        StreamSize+=(sizeof(Chunk)+1+4+PatternSize+(Chunk.Size&1));
      }
      else
      {
        PatternRow=(PatternSrcPtr[PatternSize++]+1);
        while (PatternRow)
        {
          Flag=PatternSrcPtr[PatternSize++];
		  if (Flag)
		  {
		    if (Flag&128)
              PatternSize+=2;
            if (Flag&64)
			{
              if (PatternSrcPtr[PatternSize]!=0)
                InstUsed[((PatternSrcPtr[PatternSize]-1)&128)>>7][(PatternSrcPtr[PatternSize]-1)&127]=1;
              PatternSize+=2;
			}
            if (Flag&32)
              PatternSize++;
		  }
		  else
            PatternRow--;
        }
		Chunk.FourCC=GLX_FOURCC_PATT;
        Chunk.Size=(1+4+PatternSize);
        if (Stream)
        {
          write(&Chunk,1,sizeof(Chunk),Stream);
          write(&PatternNo,1,sizeof(PatternNo),Stream);
          write(&PatternSize,1,sizeof(PatternSize),Stream);
          write(glxPatterns[PatternNo]->Track[0].Events,1,PatternSize,Stream);
	      write(&PadByte,1,Chunk.Size&1,Stream);
        }
        StreamSize+=(sizeof(Chunk)+1+4+PatternSize+(Chunk.Size&1));
      }
    }
  }
  for (BankNo=0;BankNo<GLX_TOTALBANKS;BankNo++)
  {
    for (InstNo=0;InstNo<GLX_TOTALINSTR;InstNo++)
      if (InstUsed[BankNo][InstNo])
		StreamSize+=glxSaveInstrument((BankNo<<7)+(InstNo&127),Stream,Mode);
  }
  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=StreamSize-8;
  Form.Type=GLX_FOURCC_AM;		
  if (Stream)
  {
    seek(Stream,-StreamSize,SEEK_CUR);
	write(&Form,1,sizeof(Form),Stream);
    seek(Stream,StreamSize-sizeof(Form),SEEK_CUR);
    write(&PadByte,1,Form.Size&1,Stream);
  }
  StreamSize+=(Form.Size&1);
  return StreamSize;
}
