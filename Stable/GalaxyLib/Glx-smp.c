/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 12:33 on 31-01-1998 -ÄÄ

                       The 32 bit Sample-Loader C source

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
  ³ This source file, GLX-SMP.C   is Copyright (c) 1993-97 by Carlo Vogelsang ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"

int __cdecl LoadSample(glxSample *Sample,void *Source)
{
  udword CurrSample,ExtraSpace=31,SampleSize;
  ubyte *StereoFix,LoopInvert=0;
  sword Amplitude=0;
  sdword i;

  /* Fix all illegal and erronous combinations */
  if (Sample->Type&GLX_16BITSAMPLE)
    SampleSize=2;
  else
    SampleSize=1;
  if ((Sample->Type&GLX_LOOPED)==0)
    Sample->Type&=0xe7;
  if (Sample->Volume>GLX_MAXSMPVOLUME)
    Sample->Volume=GLX_MAXSMPVOLUME;
  if (Sample->LoopEnd>Sample->Length)
    Sample->LoopEnd=Sample->Length;
  if (Sample->LoopEnd==Sample->LoopStart)
    Sample->Type&=0xe7;
  /* Read all NON zero length samples into memory */
  if (Sample->Length==0)
    return GLXERR_NOERROR;
  /* Allocate memory for sample, exit if not enough memory */
  if ((Sample->Data=getmem((Sample->Length+ExtraSpace)*SampleSize))==NULL)
    return GLXERR_OUTOFSAMPLEMEM;
  /* Read sample into memory */
  if (read(Sample->Data,SampleSize,Sample->Length,Source)!=Sample->Length)
    return GLXERR_DAMAGEDFILE;
  /* Validate sample structure */
  Sample->FourCC=GLX_FOURCC_SAMP;
  Sample->Size=sizeof(glxSample)-8;
  /* Convert sample to signed PCM samples */
  if (Sample->Type&0x43)
  {
    if ((Sample->Type&GLX_STEREOSAMPLE)&&((Sample->Reserved&128)==0))
    {
      StereoFix=getmem(Sample->Length*SampleSize);
      memcpy(StereoFix,Sample->Data,Sample->Length*SampleSize);
      for (CurrSample=0;CurrSample<(Sample->Length/2);CurrSample++)
      {
        if (Sample->Type&GLX_16BITSAMPLE)
        {
          ((sword *)Sample->Data)[CurrSample]=((sword *)StereoFix)[CurrSample*2];
          ((sword *)Sample->Data)[CurrSample+(Sample->Length/2)]=((sword *)StereoFix)[CurrSample*2+1];
        }
        else
        {
          ((sbyte *)Sample->Data)[CurrSample]=StereoFix[CurrSample*2];
          ((sbyte *)Sample->Data)[CurrSample+(Sample->Length/2)]=StereoFix[CurrSample*2+1];
        }
      }
      freemem(StereoFix);
    }
    for (CurrSample=0;CurrSample<(Sample->Length);CurrSample++)
    {
      if (Sample->Type&GLX_DELTA)
      {
        if (Sample->Type&GLX_16BITSAMPLE)
        {
          if (Sample->Type&32)
          {
            Amplitude+=((sword *)Sample->Data)[CurrSample];
            ((sword *)Sample->Data)[CurrSample]=Amplitude;
          }
          else
          {
            Amplitude+=((sbyte *)Sample->Data)[CurrSample<<1];
            ((sbyte *)Sample->Data)[CurrSample<<1]=(sbyte)Amplitude;
            Amplitude+=((sbyte *)Sample->Data)[(CurrSample<<1)+1];
            ((sbyte *)Sample->Data)[(CurrSample<<1)+1]=(sbyte)Amplitude;
          }
        }
        else
        {
          Amplitude+=((sbyte *)Sample->Data)[CurrSample];
          ((sbyte *)Sample->Data)[CurrSample]=(sbyte)Amplitude;
        }
      }
      if (Sample->Type&GLX_UNSIGNED)
	  {
        if (Sample->Type&GLX_16BITSAMPLE)
		  ((sword *)Sample->Data)[CurrSample]-=(sword)32768;
		else
          ((sbyte *)Sample->Data)[CurrSample]-=(sbyte)128;
	  }
    }
    if ((Sample->Reserved&1)==0)
    {
      Sample->Type&=~0x03;
      Sample->Reserved|=128;
    }
  }
  if (Sample->Type&GLX_LOOPED)
  {
	if (Sample->Type&GLX_BIDILOOP)
	{
		for (i=0;i<ExtraSpace;i++)
		{
			if (Sample->Type&GLX_16BITSAMPLE)
				((sword *)Sample->Data)[Sample->LoopEnd+i]=((sword *)Sample->Data)[Sample->LoopEnd-i-1];
			else
				((sbyte *)Sample->Data)[Sample->LoopEnd+i]=((sbyte *)Sample->Data)[Sample->LoopEnd-i-1];
		}
	}
	else
	{
		for (i=0;i<ExtraSpace;i++)
		{
			if (Sample->Type&GLX_16BITSAMPLE)
				((sword *)Sample->Data)[Sample->LoopEnd+i]=((sword *)Sample->Data)[Sample->LoopStart+i];
			else
				((sbyte *)Sample->Data)[Sample->LoopEnd+i]=((sbyte *)Sample->Data)[Sample->LoopStart+i];
		}
	}
  }
  else
  {
	for (CurrSample=Sample->Length,i=32;CurrSample<(Sample->Length+ExtraSpace);CurrSample++,i--)	
	{
		if (Sample->Type&GLX_16BITSAMPLE)
			((sword *)Sample->Data)[CurrSample]=((((sword *)Sample->Data)[Sample->Length-1]*i)/32);
		else
			((sbyte *)Sample->Data)[CurrSample]=((((sbyte *)Sample->Data)[Sample->Length-1]*i)/32);
	}
  }
  for (i=0;i<32;i++)	
  {
	if (Sample->Type&GLX_16BITSAMPLE)
		((sword *)Sample->Data)[i]=((((sword *)Sample->Data)[i]*i)/32);
	else
		((sbyte *)Sample->Data)[i]=((((sbyte *)Sample->Data)[i]*i)/32);
  }
  /* We're done */
  return GLXERR_NOERROR;
}
