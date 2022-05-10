/*Ä- Internal revision no. 5.00b -ÄÄÄÄ Last revision at 12:48 on 15-02-1999 -ÄÄ

                        The 32 bit WAV-Loader C source

                ÛÛÛßßÛÛÛ ÛÛÛßÛÛÛ ÛÛÛ    ÛÛÛßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
                ÛÛÛ  ßßß ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ßÛÛÛÛß  ÛÛÛ ÛÛÛ
                ÛÛÛ ÜÜÜÜ ÛÛÛÜÛÛÛ ÛÛÛ    ÛÛÛÜÛÛÛ    ÛÛ     ßÛÛÛß
                ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ    ÛÛÛ ÛÛÛ  ÜÛÛÛÛÜ    ÛÛÛ
                ÛÛÛÜÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÜÜÜ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ   ÛÛÛ

                                MUSIC SYSTEM 
                This document contains confidential information
                     Copyright (c) 1993-99 Carlo Vogelsang

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Û²± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²Û³
  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
  ³ This source file, GLX-WAV.C  is  Copyright (c) 1993-99 by Carlo Vogelsang ³
  ³ You may not copy, distribute,  duplicate or clone this file  in any form, ³
  ³ modified or non-modified. It belongs to the author.  By copying this file ³
  ³ you are violating laws and will be punished. I will knock your brains in  ³
  ³ myself or you will be sued to death..                                     ³
  ³                                                                     Carlo ³
  ÀÄ( How the fuck did you get this file anyway? )ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"
#include "hdr\glx-mpa.h"
#include "hdr\glx-smp.h"
#include "hdr\glx-ima.h"
#include "hdr\glx-voc.h"

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* WAV File-header */
{
  ubyte  Id[4];
  udword Size;
  ubyte  Type[4];
} WAVFileHdr_Struct;

typedef struct                                  /* WAV Fmt-header */
{
  uword  Format;                                // 0x0001=PCM/0x0011=IMA-ADPCM/0x0055=MP3
  uword  Channels;
  udword SamplesPerSec;
  udword BytesPerSec;
  uword  BlockAlign;
  uword  BitsPerSample;
} WAVFmtHdr_Struct;

typedef struct									/* WAV FmtEx-header */
{
  uword  Size;
  uword  SamplesPerBlock;
} WAVFmtExHdr_Struct;

typedef struct                                  /* WAV Smpl-header */
{
  udword Manufacturer;
  udword Product;
  udword SamplePeriod;                          // (1/SamplesPerSec) in NSec
  udword Note;                                  // 0..60..127
  udword FineTune;                              // 0..1 Semitone
  udword SMPTEFormat;
  udword SMPTEOffest;
  udword Loops;
  udword SamplerData;
  struct
  {
    udword Identifier;
    udword Type;
    udword Start;
    udword End;
    udword Fraction;
    udword Count;
  }      Loop[1];
} WAVSmplHdr_Struct;

typedef struct                                  /* WAV Chunk-header */
{
  ubyte  Id[4];
  udword Size;
} WAVChunkHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int	__cdecl glxDecodeWAV(glxSample *Sample,void *WAVStream,int WAVStreamSize,short *LeftWaveStream,short *RightWaveStream,int WaveStreamSize,int *BytesRead,int *BytesWritten)
{
	int Channels,OutSamples,OutSample,SampleSize;

	if (WAVStream)
	{
		Channels=(Sample->Type&GLX_STEREOSAMPLE?2:1);
		SampleSize=(Sample->Type&GLX_16BITSAMPLE?2:1);
		//Initialize WAVE stream (assume 16 bit samples)
		WAVStreamSize/=(SampleSize*Channels);
		WaveStreamSize/=SampleSize;
		*BytesRead=0;
		*BytesWritten=0;
		//Start decoding the requested amounth of samples
		if ((LeftWaveStream)||(RightWaveStream))
		{
			OutSamples=(WaveStreamSize<WAVStreamSize?WaveStreamSize:WAVStreamSize);
			if (SampleSize==1)
			{
				for (OutSample=0;OutSample<OutSamples;OutSample++)
				{
					if (LeftWaveStream)
					{
						((char *)LeftWaveStream)[OutSample]=((unsigned char *)WAVStream)[0]-128;
					}
					if (RightWaveStream)
					{
						if (Channels==1)
							((char *)RightWaveStream)[OutSample]=((unsigned char *)WAVStream)[0]-128;
						else					
							((char *)RightWaveStream)[OutSample]=((unsigned char *)WAVStream)[1]-128;
					}
					((unsigned char *)WAVStream)+=Channels;
				}
			}
			else
			{
				for (OutSample=0;OutSample<OutSamples;OutSample++)
				{
					if (LeftWaveStream)
					{
						LeftWaveStream[OutSample]=((short *)WAVStream)[0];
					}
					if (RightWaveStream)
					{
						if (Channels==1)
							RightWaveStream[OutSample]=((short *)WAVStream)[0];
						else					
							RightWaveStream[OutSample]=((short *)WAVStream)[1];
					}
					((short *)WAVStream)+=Channels;
				}
			}
			*BytesRead+=(OutSamples*SampleSize*Channels);
			*BytesWritten+=(OutSamples*SampleSize);
		}
	}
	return GLXERR_NOERROR;
}

glxSample * __cdecl glxLoadWAV(glxSample *Sample,void *Stream,int Flags)
{
	WAVChunkHdr_Struct ChunkHdr;
	glxSample *Status=GLX_NULL;
	WAVFileHdr_Struct FileHdr;
	WAVSmplHdr_Struct SmplHdr;
	WAVFmtHdr_Struct FmtHdr;
	WAVFmtExHdr_Struct FmtExHdr;
	int i;

	read(&FileHdr,1,sizeof(WAVFileHdr_Struct),Stream);
	FileHdr.Size=((FileHdr.Size+1)&~1);
	FileHdr.Size-=4;
	while ((FileHdr.Size!=0)&&(read(&ChunkHdr,1,sizeof(WAVChunkHdr_Struct),Stream)))
	{
		if (!memcmp(ChunkHdr.Id,"fmt ",4))
		{
			read(&FmtHdr,1,sizeof(WAVFmtHdr_Struct),Stream);
			if (FmtHdr.Format!=0x0001)
			{
				read(&FmtExHdr,1,sizeof(WAVFmtExHdr_Struct),Stream);
				seek(Stream,ChunkHdr.Size-sizeof(WAVFmtHdr_Struct)-sizeof(WAVFmtExHdr_Struct),SEEK_CUR);
			} else seek(Stream,ChunkHdr.Size-sizeof(WAVFmtHdr_Struct),SEEK_CUR);
		}
		else if (!memcmp(ChunkHdr.Id,"data",4))
		{
			if (FmtHdr.Format==0x0001)
			{
				Sample->FourCC=GLX_FOURCC_SAMP;
				Sample->Size=sizeof(glxSample)-8;
				Sample->Panning=GLX_MIDSMPPANNING;
				Sample->Volume=GLX_MAXSMPVOLUME;
				Sample->Type=(FmtHdr.Channels==2?GLX_STEREOSAMPLE:GLX_PANNING)|(FmtHdr.BitsPerSample==16?GLX_16BITSAMPLE:0);
				Sample->Reserved=32768;
				Sample->Length=(ChunkHdr.Size/FmtHdr.BlockAlign);
				Sample->LoopStart=0;
				Sample->LoopEnd=0;
				Sample->C4Speed=FmtHdr.SamplesPerSec;
				if (Flags&GLX_LOADASSTREAMING)
				{
					Sample->Type|=GLX_STREAMINGAUDIO;
					Sample->Data=getmem(Sample->Reserved);
					Status=Sample;
					return Status;
				}
				else if (Sample->Data=getmem(ChunkHdr.Size+31))
				{
					read(Sample->Data,FmtHdr.BlockAlign,Sample->Length,Stream);
					memset(((char *)Sample->Data)+ChunkHdr.Size,0,31);
					if ((FmtHdr.BitsPerSample==8)&&(FmtHdr.Channels==1))
						for (i=0;i<Sample->Length;i++)
							((char *)Sample->Data)[i]-=128;
//
//Test code !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//						for (i=0;i<(Sample->Length-160);i+=160)
//							lpAnalysis(((short *)Sample->Data)+i,((short *)Sample->Data)+i);
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!						
					Status=Sample;
				}
			}
			else if (FmtHdr.Format==0x0011)
			{
				Sample->Articulation=getmem(sizeof(IMAAudioStream));
				memset(Sample->Articulation,0,sizeof(IMAAudioStream));
				((IMAAudioStream *)Sample->Articulation)->BitsPerSample=FmtHdr.BitsPerSample;
				((IMAAudioStream *)Sample->Articulation)->Channels=FmtHdr.Channels;
				((IMAAudioStream *)Sample->Articulation)->SamplesPerFrame=FmtExHdr.SamplesPerBlock;
				((IMAAudioStream *)Sample->Articulation)->FrameSize=FmtHdr.BlockAlign;
				Sample->FourCC=GLX_FOURCC_SAMP;
				Sample->Size=sizeof(glxSample)-8;
				Sample->Panning=GLX_MIDSMPPANNING;
				Sample->Volume=GLX_MAXSMPVOLUME;
				Sample->Type=(GLX_IMAADPCM|(FmtHdr.Channels==2?GLX_STEREOSAMPLE:GLX_PANNING)|GLX_16BITSAMPLE);
				Sample->Reserved=32768;
				Sample->Length=ChunkHdr.Size;
				Sample->LoopStart=0;
				Sample->LoopEnd=0;
				Sample->C4Speed=FmtHdr.SamplesPerSec;
				if (Flags&GLX_LOADASSTREAMING)
				{
					Sample->Type|=GLX_STREAMINGAUDIO;
					Sample->Data=getmem(Sample->Reserved);
					Status=Sample;
					return Status;
				}
				else if (Sample->Data=getmem(ChunkHdr.Size+31))
				{
					Sample->Reserved=32768;
					read(Sample->Data,1,Sample->Length,Stream);
					memset(((char *)Sample->Data)+ChunkHdr.Size,0,31);
					Status=Sample;
				}
			}
			else if (FmtHdr.Format==0x0055)
				return glxLoadMPA(Sample,Stream,Flags);
		}
		else if (!memcmp(ChunkHdr.Id,"smpl",4))
		{
			read(&SmplHdr,1,sizeof(WAVSmplHdr_Struct),Stream);
			seek(Stream,ChunkHdr.Size-sizeof(WAVSmplHdr_Struct),SEEK_CUR);
			if (SmplHdr.Loops!=0)
			{
				Sample->Type|=(SmplHdr.Loop[0].Type&1?GLX_BIDILOOP|GLX_LOOPED:GLX_LOOPED);
				Sample->LoopStart=SmplHdr.Loop[0].Start;
				Sample->LoopEnd=SmplHdr.Loop[0].End;
			}
		}
		else seek(Stream,ChunkHdr.Size,SEEK_CUR);
		seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
		FileHdr.Size-=(((ChunkHdr.Size+1)&~1)+8);
	}
	return Status;
}

int glxLoadWAV2(int Instrument,void *Stream,int Flags)
{
	int BankNo,InstNo;
	WAVChunkHdr_Struct ChunkHdr;
	WAVFileHdr_Struct FileHdr;
	WAVSmplHdr_Struct SmplHdr;
	int Status=GLXERR_NOERROR;
	WAVFmtHdr_Struct FmtHdr;
	WAVFmtExHdr_Struct FmtExHdr;
	glxSample *Sample;
	int i;

	read(&FileHdr,1,sizeof(WAVFileHdr_Struct),Stream);
	FileHdr.Size=((FileHdr.Size+1)&~1);
	FileHdr.Size-=4;
	if (Instrument!=-1)
	{
		BankNo=((Instrument&128)>>7);
		InstNo=Instrument&127;
	}
	else
	{
		BankNo=0;
		InstNo=0;
	}
	glxInstruments[BankNo][InstNo]=getmem(sizeof(glxInstrument)+1*sizeof(glxSample));
	memset(glxInstruments[BankNo][InstNo],0,sizeof(glxInstrument)+1*sizeof(glxSample));
	glxInstruments[BankNo][InstNo]->FourCC=GLX_FOURCC_INST;
	glxInstruments[BankNo][InstNo]->Size=sizeof(glxInstrument)-8;
	glxInstruments[BankNo][InstNo]->Bank=BankNo;
	glxInstruments[BankNo][InstNo]->Program=InstNo;
	Sample=&glxInstruments[BankNo][InstNo]->Sample[0];
	while ((FileHdr.Size!=0)&&(read(&ChunkHdr,1,sizeof(WAVChunkHdr_Struct),Stream)))
	{
		if (!memcmp(ChunkHdr.Id,"fmt ",4))
		{
			read(&FmtHdr,1,sizeof(WAVFmtHdr_Struct),Stream);
			if (FmtHdr.Format!=0x0001)
			{
				read(&FmtExHdr,1,sizeof(WAVFmtExHdr_Struct),Stream);
				seek(Stream,ChunkHdr.Size-sizeof(WAVFmtHdr_Struct)-sizeof(WAVFmtExHdr_Struct),SEEK_CUR);
			} else seek(Stream,ChunkHdr.Size-sizeof(WAVFmtHdr_Struct),SEEK_CUR);
		}
		else if (!memcmp(ChunkHdr.Id,"data",4))
		{
			if (FmtHdr.Format==0x0001)
			{
				Sample->FourCC=GLX_FOURCC_SAMP;
				Sample->Size=sizeof(glxSample)-8;
				Sample->Panning=GLX_MIDSMPPANNING;
				Sample->Volume=GLX_MAXSMPVOLUME;
				Sample->Length=(ChunkHdr.Size/FmtHdr.BlockAlign);
				Sample->Type=(FmtHdr.Channels==2?GLX_STEREOSAMPLE:GLX_PANNING)|(FmtHdr.BitsPerSample==16?GLX_16BITSAMPLE:0);
				Sample->Reserved=32768;
				Sample->LoopStart=0;
				Sample->LoopEnd=0;
				Sample->C4Speed=FmtHdr.SamplesPerSec;
				if (Flags&GLX_LOADASSTREAMING)
				{
					glxInstruments[BankNo][InstNo]->Samples++;
					Sample->Type|=GLX_STREAMINGAUDIO;
					Sample->Data=getmem(Sample->Reserved);
					Status=(int)Sample;
					return Status;
				}
				else if (Sample->Data=getmem(ChunkHdr.Size+31))
				{
					read(Sample->Data,FmtHdr.BlockAlign,Sample->Length,Stream);
					memset(((char *)Sample->Data)+ChunkHdr.Size,0,31);
					glxInstruments[BankNo][InstNo]->Samples++;
					if (FmtHdr.BitsPerSample==8)
						for (i=0;i<Sample->Length;i++)
							((char *)Sample->Data)[i]-=128;
					Status=(int)Sample;
				}
			}
			else if (FmtHdr.Format==0x0011)
			{
				Sample->Articulation=getmem(sizeof(IMAAudioStream));
				memset(Sample->Articulation,0,sizeof(IMAAudioStream));
				((IMAAudioStream *)Sample->Articulation)->BitsPerSample=FmtHdr.BitsPerSample;
				((IMAAudioStream *)Sample->Articulation)->Channels=FmtHdr.Channels;
				((IMAAudioStream *)Sample->Articulation)->SamplesPerFrame=FmtExHdr.SamplesPerBlock;
				((IMAAudioStream *)Sample->Articulation)->FrameSize=FmtHdr.BlockAlign;
				Sample->FourCC=GLX_FOURCC_SAMP;
				Sample->Size=sizeof(glxSample)-8;
				Sample->Panning=GLX_MIDSMPPANNING;
				Sample->Volume=GLX_MAXSMPVOLUME;
				Sample->Type=(GLX_IMAADPCM|(FmtHdr.Channels==2?GLX_STEREOSAMPLE:GLX_PANNING)|GLX_16BITSAMPLE);
				Sample->Reserved=32768;
				Sample->Length=ChunkHdr.Size;
				Sample->LoopStart=0;
				Sample->LoopEnd=0;
				Sample->C4Speed=FmtHdr.SamplesPerSec;
				if (Flags&GLX_LOADASSTREAMING)
				{
					Sample->Type|=GLX_STREAMINGAUDIO;
					Sample->Data=getmem(Sample->Reserved);
					Status=(int)Sample;
					return Status;
				}
				else if (Sample->Data=getmem(ChunkHdr.Size+31))
				{
					read(Sample->Data,1,Sample->Length,Stream);
					memset(((char *)Sample->Data)+ChunkHdr.Size,0,31);
					Status=(int)Sample;
				}
			}
		}
		else if (!memcmp(ChunkHdr.Id,"smpl",4))
		{
			read(&SmplHdr,1,sizeof(WAVSmplHdr_Struct),Stream);
			seek(Stream,ChunkHdr.Size-sizeof(WAVSmplHdr_Struct),SEEK_CUR);
			if (SmplHdr.Loops!=0)
			{
				Sample->LoopStart=SmplHdr.Loop[0].Start;
				Sample->LoopEnd=SmplHdr.Loop[0].End;
				Sample->Type|=((SmplHdr.Loop[0].Type&1)<<4)|GLX_LOOPED;
			}
		}
		else seek(Stream,ChunkHdr.Size,SEEK_CUR);
		seek(Stream,ChunkHdr.Size&1,SEEK_CUR);
		FileHdr.Size-=(((ChunkHdr.Size+1)&~1)+8);
	}
	return Status;
}

