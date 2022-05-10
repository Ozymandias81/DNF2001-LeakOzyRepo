/*Ä- Internal revision no. 4.00b -ÄÄÄÄ Last revision at 19:12 on 11-06-1999 -ÄÄ

                        The 32 bit definition headerfile

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                               .. MUSIC SYSTEM ..
                This document contains confidential information
                     Copyright (c) 1993-99 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-IMA.H is Copyright  (c) 1993-99 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#ifndef _GLXIMA_H
#define _GLXIMA_H

#include "hdr\galaxy.h"

#ifdef __cplusplus
extern "C" {
#endif

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct									 
{
	struct
	{
		short Sample;							// Current sample
		signed char Index;						// Current step_size index
		unsigned char Reserved;					// Reserved
	}	Channel[2];
	//additional infomation
	int Channels;								// Channels
	int SamplesPerFrame;						// Samples per frame
	int FrameSize;								// Framesize in bytes
	int BitsPerSample;							// Bits per sample
	//decoder variables
	int Samples;								// Samples left
	int	Index;									// Current sample
	short pcmsamples[2][4096];					// 16 bit PCM samples
} IMAAudioStream; 								// IMA Audio header

#pragma pack (pop)								/* Default alignment */

extern int			   __cdecl glxDecodeIMA(glxSample *Sample,void *IMAStream,int IMAStreamSize,short *LeftWaveStream,short *RightWaveStream,int WaveStreamSize,int *BytesRead,int *BytesWritten);

#ifdef __cplusplus
};
#endif

#endif
