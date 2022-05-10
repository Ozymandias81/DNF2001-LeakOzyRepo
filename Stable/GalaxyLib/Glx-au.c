/*Ä- Internal revision no. 3.01b1 -ÄÄÄ Last revision at  2:09 on 24-06-1997 -ÄÄ

                         The 32 bit AU-Loader C source

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
  ³ This source file, GLX-AU.C is  Copyright  (c)  1993-97 by Carlo Vogelsang ³
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

typedef struct                                  /* AU File-header */
{
  ubyte  Id[4];
  udword SampleOffset;
  udword Length;
  udword Type;
  udword C4Speed;
  udword Channels;
  ubyte  Data[];
} AUFileHdr_Struct;

#pragma pack (pop)								/* Default alignment */

glxSample * __cdecl glxLoadAU(glxSample *Sample,void *Effect,int Mode)
{
  glxSample *Status=GLX_NULL;
  AUFileHdr_Struct FileHdr;

  read(&FileHdr,1,sizeof(AUFileHdr_Struct),Effect);
  FileHdr.SampleOffset=(((FileHdr.SampleOffset&0xff)<<24)|((FileHdr.SampleOffset&0xff00)<<8)|((FileHdr.SampleOffset&0xff0000)>>8)|((FileHdr.SampleOffset&0xff000000)>>24));
  FileHdr.Length=(((FileHdr.Length&0xff)<<24)|((FileHdr.Length&0xff00)<<8)|((FileHdr.Length&0xff0000)>>8)|((FileHdr.Length&0xff000000)>>24));
  FileHdr.Type=(((FileHdr.Type&0xff)<<24)|((FileHdr.Type&0xff00)<<8)|((FileHdr.Type&0xff0000)>>8)|((FileHdr.Type&0xff000000)>>24));
  FileHdr.C4Speed=(((FileHdr.C4Speed&0xff)<<24)|((FileHdr.C4Speed&0xff00)<<8)|((FileHdr.C4Speed&0xff0000)>>8)|((FileHdr.C4Speed&0xff000000)>>24));
  FileHdr.Channels=(((FileHdr.Channels&0xff)<<24)|((FileHdr.Channels&0xff00)<<8)|((FileHdr.Channels&0xff0000)>>8)|((FileHdr.Channels&0xff000000)>>24));
  seek(Effect,FileHdr.SampleOffset-sizeof(AUFileHdr_Struct),SEEK_CUR);
  if ((FileHdr.Channels<3)&&(FileHdr.Type<4))
  {
    Sample->Panning=GLX_MIDSMPPANNING;
    Sample->Volume=GLX_MAXSMPVOLUME;
    Sample->Length=FileHdr.Length;
    Sample->LoopStart=0;
    Sample->LoopEnd=0;
    Sample->C4Speed=FileHdr.C4Speed;
    switch (FileHdr.Type)
    {
      case 1 : Sample->Type=132; break;
      case 2 : Sample->Type=0; break;
      case 3 : Sample->Type=4; break;
    }
    Sample->Type|=(FileHdr.Channels&2)<<5;
    if (LoadSample(Sample,Effect)==GLXERR_NOERROR)
      Status=Sample;
  }
  return Status;
}
