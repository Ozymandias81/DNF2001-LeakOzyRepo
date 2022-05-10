/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at  2:06 on 31-01-1998 -ÄÄ

                         The 32 bit AI-Loader C source

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
  ³ This source file, GLX-AI.C is Copyright  (c)  1993-98 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

int __cdecl glxLoadAI(int Instrument,void *Stream,int Mode)
{
  int SampleNo,Status=GLXERR_NOERROR;
  ubyte BankNo,InstNo;
  glxChunk Chunk;
  glxForm Form;
  udword Size;

  read(&Form,1,sizeof(Form),Stream);  
  Form.Size-=4;
  while ((Form.Size!=0)&&(Status==GLXERR_NOERROR))
  {
    if (read(&Chunk,1,sizeof(Chunk),Stream)==sizeof(Chunk))
    {
      if (Chunk.FourCC==GLX_FOURCC_INST)
      {
        read(&Size,1,sizeof(Size),Stream);
		read(&BankNo,1,sizeof(BankNo),Stream);
        read(&InstNo,1,sizeof(InstNo),Stream);
        if (Instrument!=-1)
        {
          BankNo=((Instrument&128)>>7);
          InstNo=Instrument&127;
        }
        glxInstruments[BankNo][InstNo]=getmem(sizeof(glxInstrument));
        glxInstruments[BankNo][InstNo]->FourCC=GLX_FOURCC_INST;
        glxInstruments[BankNo][InstNo]->Size=Size;
        glxInstruments[BankNo][InstNo]->Bank=BankNo;
        glxInstruments[BankNo][InstNo]->Program=InstNo;
        read(glxInstruments[BankNo][InstNo]->Message,1,glxInstruments[BankNo][InstNo]->Size-2,Stream);
        glxInstruments[BankNo][InstNo]=resizemem(glxInstruments[BankNo][InstNo],sizeof(glxInstrument)+(glxInstruments[BankNo][InstNo]->Samples*sizeof(glxSample)));
		for (SampleNo=0;SampleNo<glxInstruments[BankNo][InstNo]->Samples;SampleNo++)
          glxLoadInstrumentSample((BankNo<<7)+(InstNo&127),SampleNo,Stream,Mode);
	  }
      else seek(Stream,Chunk.Size,SEEK_CUR);
      seek(Stream,Chunk.Size&1,SEEK_CUR);
      Form.Size-=(((Chunk.Size+1)&~1)+8);
    }
    else
      return GLXERR_UNSUPPORTEDFORMAT;
  }
  return Status;
}

int glxSaveAI(int Instrument,void *Stream,int Mode)
{
  int StreamSize=0,SampleNo;
  ubyte PadByte=0;
  glxChunk Chunk;
  glxForm Form;

  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=4;
  Form.Type=GLX_FOURCC_AI;		
  if (Stream)
    write(&Form,1,sizeof(Form),Stream);
  StreamSize+=sizeof(Form);
  if (glxInstruments[(Instrument&128)>>7][Instrument&127])
  {
    if (glxInstruments[(Instrument&128)>>7][Instrument&127]->FourCC==GLX_FOURCC_INST)
    {
	  Chunk.FourCC=GLX_FOURCC_INST;
	  Chunk.Size=4+glxInstruments[(Instrument&128)>>7][Instrument&127]->Size;
      for (SampleNo=0;SampleNo<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples;SampleNo++)
		Chunk.Size+=glxSaveInstrumentSample(Instrument,SampleNo,NULL,Mode);
	  if (Stream)
        write(&Chunk,sizeof(Chunk),1,Stream);
	  StreamSize+=sizeof(Chunk);    
      if (Stream)
        write(&glxInstruments[(Instrument&128)>>7][Instrument&127]->Size,1,4+glxInstruments[(Instrument&128)>>7][Instrument&127]->Size,Stream);
      StreamSize+=(4+glxInstruments[(Instrument&128)>>7][Instrument&127]->Size);
      for (SampleNo=0;SampleNo<glxInstruments[(Instrument&128)>>7][Instrument&127]->Samples;SampleNo++)
		StreamSize+=glxSaveInstrumentSample(Instrument,SampleNo,Stream,Mode);
      if (Stream)
		write(&PadByte,1,Chunk.Size&1,Stream);
	  StreamSize+=(Chunk.Size&1);
    }
  }
  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=StreamSize-8;
  Form.Type=GLX_FOURCC_AI;		
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
