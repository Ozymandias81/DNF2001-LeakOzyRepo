/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 15:53 on  4-06-1998 -ÄÄ

                         The 32 bit AE-Loader C source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                               .. MUSIC SYSTEM ..
                This document contains confidential information
                     Copyright (c) 1993-96 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-AE.C is Copyright  (c)  1993-98 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

int __cdecl glxLoadAE(void *Stream,int Mode)
{
  int Status=GLXERR_NOERROR;
  glxChorus Chorus;
  glxReverb Reverb;
  glxChunk Chunk;
  glxForm Form;

  read(&Form,1,sizeof(Form),Stream);
  Form.Size-=4;
  while ((Form.Size!=0)&&(Status==GLX_NULL))
  {
    if (read(&Chunk,1,sizeof(Chunk),Stream)==sizeof(Chunk))
    {
	  if (Chunk.FourCC==GLX_FOURCC_RVRB)
      {
		read(&Reverb.Size,1,sizeof(Reverb.Size),Stream);
        read(&Reverb.Time,1,Reverb.Size,Stream);
		glxSetMusicReverb(&Reverb);
		glxSetSampleReverb(&Reverb);
      }
      else if (Chunk.FourCC==GLX_FOURCC_CHRS)
	  {
		read(&Chorus.Size,1,sizeof(Chorus.Size),Stream);
        read(&Chorus.Time,1,Chorus.Size,Stream);
		//glxSetMusicChorus(&Chorus);
		//glxSetSampleChorus(&Chorus);
	  }
	  else seek(Stream,Chunk.Size,SEEK_CUR);
      seek(Stream,Chunk.Size&1,SEEK_CUR);
      Form.Size-=(((Chunk.Size+1)&~1)+8);
    }
  }
  return Status;
}

int glxSaveAE(void *Stream,int Mode)
{
  int StreamSize=0;
  ubyte PadByte=0;
  glxChunk Chunk;
  glxForm Form;
  
  if (Stream)
  {
    Form.FourCC=GLX_FOURCC_RIFF;
	Form.Size=4;
	Form.Type=GLX_FOURCC_AE;		
	write(&Form,1,sizeof(Form),Stream);
  }
  StreamSize+=sizeof(Form);
  if (glxMusicReverb.FourCC==GLX_FOURCC_RVRB)
  {
    Chunk.FourCC=GLX_FOURCC_RVRB;
	Chunk.Size=4+glxMusicReverb.Size;
	if (Stream)
	  write(&Chunk,sizeof(Chunk),1,Stream);
	StreamSize+=sizeof(Chunk);    
    if (Stream)
	  write(&glxMusicReverb.Size,1,4+glxMusicReverb.Size,Stream);
    StreamSize+=(4+glxMusicReverb.Size);
    if (Stream)
	  write(&PadByte,1,Chunk.Size&1,Stream);
	StreamSize+=(Chunk.Size&1);
  }
  if (glxMusicChorus.FourCC==GLX_FOURCC_CHRS)
  {
    Chunk.FourCC=GLX_FOURCC_CHRS;
	Chunk.Size=4+glxMusicChorus.Size;
	if (Stream)
	  write(&Chunk,sizeof(Chunk),1,Stream);
	StreamSize+=sizeof(Chunk);    
    if (Stream)
	  write(&glxMusicChorus.Size,1,4+glxMusicChorus.Size,Stream);
    StreamSize+=(4+glxMusicChorus.Size);
    if (Stream)
	  write(&PadByte,1,Chunk.Size&1,Stream);
	StreamSize+=(Chunk.Size&1);
  }
  Form.FourCC=GLX_FOURCC_RIFF;
  Form.Size=StreamSize-8;
  Form.Type=GLX_FOURCC_AE;		
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
