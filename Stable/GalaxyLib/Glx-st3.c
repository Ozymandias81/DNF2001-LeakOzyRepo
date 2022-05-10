/*Ä- Internal revision no. 3.01b1 -ÄÄÄ Last revision at 12:35 on 26-06-1997 -ÄÄ

                         The 32 bit ST3-Loader C source

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
  ³ This source file, GLX-ST3.C is  Copyright  (c) 1993-97 by Carlo Vogelsang ³
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

glxSample * __cdecl glxLoadST3(glxSample *Sample,void *Effect,int Mode)
{
  ubyte ST3Hdr[80];
  glxSample *Status=GLX_NULL;

  read(ST3Hdr,1,80,Effect);
  if (ST3Hdr[0]==1)
  {
    Sample->Length=(*((udword *)(ST3Hdr+16)));
    Sample->LoopStart=(*((udword *)(ST3Hdr+20)));
    Sample->LoopEnd=(*((udword *)(ST3Hdr+24)));
    Sample->C4Speed=(*((udword *)(ST3Hdr+32)));
    Sample->Panning=GLX_MIDSMPPANNING;
	Sample->Volume=ST3Hdr[28]<<9;
	if (Sample->Volume>GLX_MAXSMPVOLUME)
	  Sample->Volume=GLX_MAXSMPVOLUME;
    Sample->Type=(2|(ST3Hdr[31]&4)|((ST3Hdr[31]&1)<<3));
    if (((ST3Hdr[31]&2)==0)&&(LoadSample(Sample,Effect)==GLXERR_NOERROR))
      Status=Sample;
  }
  return Status;
}
