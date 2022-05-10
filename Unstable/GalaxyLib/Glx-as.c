/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 15:53 on 31-01-1998 -ÄÄ

                         The 32 bit AS-Loader C source

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
  ³ This source file, GLX-AS.C is Copyright  (c)  1993-98 by Carlo Vogelsang. ³
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

glxSample * __cdecl glxLoadAS(glxSample *Sample,void *Stream,int Mode)
{
  glxSample *Status=GLX_NULL;
  glxChunk Chunk;
  glxForm Form;

  read(&Form,1,sizeof(Form),Stream);
  Form.Size-=4;
  while ((Form.Size!=0)&&(Status==GLX_NULL))
  {
    if (read(&Chunk,1,sizeof(Chunk),Stream)==sizeof(Chunk))
    {
      if (Chunk.FourCC==GLX_FOURCC_SAMP)
      {
        read(&Sample->Size,1,sizeof(Sample->Size),Stream);
        read(Sample->Message,1,Sample->Size,Stream);
		if (Sample->Articulation)
		{
		  Sample->Articulation=getmem(sizeof(glxArti));
		  read(Sample->Articulation,sizeof(glxArti),1,Stream);
		}
		if (LoadSample(Sample,Stream)==GLXERR_NOERROR)
          Status=Sample;
      }
      else seek(Stream,Chunk.Size,SEEK_CUR);
      seek(Stream,Chunk.Size&1,SEEK_CUR);
      Form.Size-=(((Chunk.Size+1)&~1)+8);
    }
  }
  return Status;
}

int glxSaveAS(glxSample *Sample,void *Stream,int Mode)
{
  int SampleSize,StreamSize=0;
  ubyte PadByte=0;
  glxChunk Chunk;
  glxForm Form;
  
  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=4;
  Form.Type=GLX_FOURCC_AS;		
  if (Stream)
	write(&Form,1,sizeof(Form),Stream);
  StreamSize+=sizeof(Form);
  if (Sample)
  {
    if (Sample->FourCC==GLX_FOURCC_SAMP)
    {
      if (Sample->Type&GLX_16BITSAMPLE)
        SampleSize=2;
      else
        SampleSize=1;
      Chunk.FourCC=GLX_FOURCC_SAMP;
	  Chunk.Size=4+Sample->Size+Sample->Length*SampleSize;
      if (Sample->Articulation)
		Chunk.Size+=sizeof(glxArti);
	  if (Stream)
	    write(&Chunk,sizeof(Chunk),1,Stream);
	  StreamSize+=sizeof(Chunk);    
      if (Stream)
	    write(&Sample->Size,1,4+Sample->Size,Stream);
      StreamSize+=(4+Sample->Size);
	  if (Sample->Articulation)
	  {
		if (Stream)
		  write(Sample->Articulation,sizeof(glxArti),1,Stream);
		StreamSize+=sizeof(glxArti);
	  }
      if (Sample->Data)
	  {
	    if (Stream)
		  write(Sample->Data,SampleSize,Sample->Length,Stream);
        StreamSize+=(Sample->Length*SampleSize);
	  }
      if (Stream)
		write(&PadByte,1,Chunk.Size&1,Stream);
	  StreamSize+=(Chunk.Size&1);
    }
  }
  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=StreamSize-8;
  Form.Type=GLX_FOURCC_AS;		
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
