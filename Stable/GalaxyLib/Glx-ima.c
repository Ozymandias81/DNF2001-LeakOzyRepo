/*Ä- Internal revision no. 5.00b -ÄÄÄÄ Last revision at 19:12 on 11-06-1999 -ÄÄ

                  The 32 bit IMA ADPCM Audio-Decoder C source

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
  ³ This source file, GLX-IMA.C is Copyright  (c) 1993-99 by Carlo Vogelsang. ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"							// Galaxy header
#include "hdr\loaders.h"						// Loaders header
#include "hdr\glx-ima.h"

//Decode entire frame

static int decodeframe(void *Stream,IMAAudioStream *Header)
{
	static const long step_size[89]={
		   7,    8,    9,   10,   11,   12,   13,   14,   16,   17,   19,   21,   23,   25,   28,   31,
	      34,   37,   41,   45,   50,   55,   60,   66,   73,   80,   88,   97,  107,  118,  130,  143,
	     157,  173,  190,  209,  230,  253,  279,  307,  337,  371,  408,  449,  494,  544,  598,  658,
	     724,  796,  876,  963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024,
	    3327, 3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493,10442,11487,12635,13899,
	   15289,16818,18500,20350,22358,24633,27086,29794,32767
	};
	static const long codeword_3[8]={
		2, 6, 10, 14,
	   -2,-6,-10,-14
	};
	static const long codeword_4[16]={
		1, 3, 5, 7, 9, 11, 13, 15,
	   -1,-3,-5,-7,-9,-11,-13,-15,
	};
	static const long index_adjust_3[8]={
       -1,-1, 1, 2, 
       -1,-1, 1, 2
	};
	static const long index_adjust_4[16]={
       -1,-1,-1,-1, 2, 4, 6, 8,
       -1,-1,-1,-1, 2, 4, 6, 8
	};
	int Channel,Position,i,j;
	long Sample,Index,Temp;
	unsigned long *Source;
	
	//Setup pointer to actual block data
	Source=(unsigned long *)Stream;
	//Process block-header(s)
	for (Channel=0;Channel<Header->Channels;Channel++)
	{
		//Copy channel block-header
		Header->Channel[Channel].Sample=Header->pcmsamples[Channel][0]=(short)(Source[0]&0xffff);
		Header->Channel[Channel].Index=(signed char)((Source[0]>>16)&255);
		//Check step_index
		if (Header->Channel[Channel].Index<0) Header->Channel[Channel].Index=0; 
		else if (Header->Channel[Channel].Index>88) Header->Channel[Channel].Index=88;
		//Advance source position
		Source++;
	}
	//Select decoder mode (3 or 4 bits per sample)
	if (Header->BitsPerSample==3)
	{
		for (Position=1;Position<Header->SamplesPerFrame;Position+=32)
		{
			for (Channel=0;Channel<Header->Channels;Channel++)
			{
				//Get local variables
				Sample=Header->Channel[Channel].Sample;
				Index=Header->Channel[Channel].Index;
				for (j=0;j<3;j++)
				{
					//Get DWORD from source
					Temp=*Source;
					for (i=0;i<10;i+=2)
					{
						//Decode lower nibble
						Sample+=((step_size[Index]*codeword_3[Temp&7])/8);
						Index+=index_adjust_3[Temp&7];
						if (Sample<-32768) Sample=-32768;
						else if (Sample>32767) Sample=32767;
						if (Index<0) Index=0; 
						else if (Index>88) Index=88;
						Header->pcmsamples[Channel][Position+i]=(short)Sample;
						Temp>>=3;
						//Decode upper nibble
						Sample+=((step_size[Index]*codeword_3[Temp&7])/8);
						Index+=index_adjust_3[Temp&7];
						if (Sample<-32768) Sample=-32768;
						else if (Sample>32767) Sample=32767;
						if (Index<0) Index=0; 
						else if (Index>88) Index=88;
						Header->pcmsamples[Channel][Position+i+1]=(short)Sample;
						Temp>>=3;
					}
				}
				//Store local variables
				Header->Channel[Channel].Index=(signed char)Index;
				Header->Channel[Channel].Sample=(short)Sample;
				//Advance position
				Source++;
			}
		}
  }
	else if (Header->BitsPerSample==4)
	{
		for (Position=1;Position<Header->SamplesPerFrame;Position+=8)
		{
			for (Channel=0;Channel<Header->Channels;Channel++)
			{
				//Get local variables
				Sample=Header->Channel[Channel].Sample;
				Index=Header->Channel[Channel].Index;
				//Get DWORD from source
				Temp=*Source;
				for (i=0;i<8;i+=2)
				{
					//Decode lower nibble
					Sample+=((step_size[Index]*codeword_4[Temp&15])/8);
					Index+=index_adjust_4[Temp&15];
					if (Sample<-32768) Sample=-32768;
					else if (Sample>32767) Sample=32767;
					if (Index<0) Index=0; 
					else if (Index>88) Index=88;
					Header->pcmsamples[Channel][Position+i]=(short)Sample;
					Temp>>=4;
					//Decode upper nibble
					Sample+=((step_size[Index]*codeword_4[Temp&15])/8);
					Index+=index_adjust_4[Temp&15];
					if (Sample<-32768) Sample=-32768;
					else if (Sample>32767) Sample=32767;
					if (Index<0) Index=0; 
					else if (Index>88) Index=88;
					Header->pcmsamples[Channel][Position+i+1]=(short)Sample;
					Temp>>=4;
				}
				//Store local variables
				Header->Channel[Channel].Index=(signed char)Index;
				Header->Channel[Channel].Sample=(short)Sample;
				//Advance position
				Source++;
			}
		}
	}
	return Header->SamplesPerFrame;
}

int	__cdecl glxDecodeIMA(glxSample *Sample,void *IMAStream,int IMAStreamSize,short *LeftWaveStream,short *RightWaveStream,int WaveStreamSize,int *BytesRead,int *BytesWritten)
{
	int OutSamples,StreamPos;
	IMAAudioStream *Header;
	
	if ((IMAStream)&&(Sample))
	{
		//Initialize header
		Header=(IMAAudioStream *)Sample->Articulation;
		//Initialize WAVE stream (assume 16 bit samples)
		WaveStreamSize>>=1;
		*BytesRead=StreamPos=0;
		*BytesWritten=0;
		//Calculate complete frames in stream and resize stream
		if (Header->FrameSize) IMAStreamSize=((IMAStreamSize/Header->FrameSize)*Header->FrameSize);
		//Start decoding the requested amounth of samples
		while ((WaveStreamSize)&&(StreamPos<IMAStreamSize))
		{
			if (!Header->Samples)
			{
				Header->Samples=decodeframe(((char *)IMAStream)+StreamPos,Header);
				StreamPos+=Header->FrameSize;
				Header->Index=0;
			}
			OutSamples=(WaveStreamSize<Header->Samples?WaveStreamSize:Header->Samples);
			if ((LeftWaveStream)||(RightWaveStream))
			{
				if (LeftWaveStream)
				{
					memcpy(LeftWaveStream,&Header->pcmsamples[0][Header->Index],OutSamples*2);
					LeftWaveStream+=OutSamples;
				}
				if (RightWaveStream)
				{
					if (Header->Channels==1)
						memcpy(RightWaveStream,&Header->pcmsamples[0][Header->Index],OutSamples*2);
					else
						memcpy(RightWaveStream,&Header->pcmsamples[1][Header->Index],OutSamples*2);
					RightWaveStream+=OutSamples;
				}
				*BytesWritten+=(OutSamples*2);
			}
			Header->Index+=OutSamples;
			Header->Samples-=OutSamples;
			WaveStreamSize-=OutSamples;
		}
		*BytesRead=StreamPos;
		return GLXERR_NOERROR;
	}
	else if (Sample)
	{
		//Initialize header
		Header=(IMAAudioStream *)Sample->Articulation=getmem(sizeof(IMAAudioStream));
		memset(Header,0,sizeof(IMAAudioStream));
		return GLXERR_NOERROR;
	}
	return GLXERR_NOERROR;
}
