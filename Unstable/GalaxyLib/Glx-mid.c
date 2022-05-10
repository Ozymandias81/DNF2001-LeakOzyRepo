/*Ф- Internal revision no. 4.00y1 -ФФФ Last revision at  2:25 on 16-01-1998 -ФФ

                         The 32 bit MID-Loader C source

                лллппллл лллпллл ллл    лллпллл ллл  ллл ллл ллл
                ллл  ппп ллл ллл ллл    ллл ллл  пллллп  ллл ллл
                ллл мммм лллмллл ллл    лллмллл    лл     плллп
                ллл  ллл ллл ллл ллл    ллл ллл  мллллм    ллл
                лллммллл ллл ллл лллммм ллл ллл ллл  ллл   ллл

                                MUSIC SYSTEM 
                This document contains confidential information
                     Copyright (c) 1993-97 Carlo Vogelsang

  кФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФП
  ГлВБ COPYRIGHT NOTICE ББББББББББББББББББББББББББББББББББББББББББББББББББББВлГ
  УФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФД
  Г This source file, GLX-MID.C is Copyright  (c)  1993-97 by Carlo Vogelsang Г
  Г You may not copy, distribute,  duplicate or clone this file  in any form, Г
  Г modified or non-modified. It belongs to the author.  By copying this file Г
  Г you are violating laws and will be punished. I will knock your brains in  Г
  Г myself or you will be sued to death..                                     Г
  Г                                                                     Carlo Г
  РФ( How the fuck did you get this file anyway? )ФФФФФФФФФФФФФФФФФФФФФФФФФФФФй
*/
#include "hdr\galaxy.h"
#include "hdr\loaders.h"
#include "hdr\glx-smp.h"

#define BSWAP16(a) (((a&0xff)<<8)+((a&0xff00)>>8))
#define BSWAP32(a) (((a&0xff)<<24)+((a&0xff00)<<8)+((a&0xff0000)>>8)+((a&0xff000000)>>24))

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct                                  /* MID File-header */
{
  ubyte  Id[4];
  udword Size;
  uword  Format;								
  uword  Tracks;					
  sword  Division;
} MIDFileHdr_Struct;

typedef struct                                  /* MID Track-header */
{
  ubyte  Id[4];
  udword Size;
  ubyte	 Events[];
} MIDTrackHdr_Struct;

#pragma pack (pop)								/* Default alignment */

int __cdecl glxLoadMID(void *Stream)
{
  MIDFileHdr_Struct *FileHdr;
  MIDTrackHdr_Struct *TrackHdr;
  int Track,ChannelNo;
  
  //Grab some memory for the headers
  if ((FileHdr=getmem(sizeof(MIDFileHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  if ((TrackHdr=getmem(sizeof(MIDTrackHdr_Struct)))==NULL)
    return GLXERR_OUTOFMEMORY;
  //Load general file header and convert numbers
  read(FileHdr,1,sizeof(MIDFileHdr_Struct),Stream);
  FileHdr->Size=BSWAP32(FileHdr->Size);
  FileHdr->Format=BSWAP16(FileHdr->Format);
  FileHdr->Tracks=BSWAP16(FileHdr->Tracks);
  FileHdr->Division=BSWAP16(FileHdr->Division);
  //Check if supported type
  if ((FileHdr->Format==0)||(FileHdr->Format==1))
  {
	//Set global player variables
	glxPlayerMode=4;
	glxInitialSpeed=96;
	glxInitialTempo=120;
	glxMinPeriod=0;
	glxMaxPeriod=30720;
	glxMusicVoices=32;
	glxSongLength=0;
	if (FileHdr->Division<0)
	{
		//Upper byte is -Frames/sec, lower byte is divisions per frame
		glxInitialSpeed=FileHdr->Division&0xff;
		glxInitialTempo=-((FileHdr->Division>>8)*60);
	}
	else
		glxInitialSpeed=FileHdr->Division;
	//Setup pattern(s) 
	glxPatterns[0]=getmem(sizeof(glxPattern)+FileHdr->Tracks*sizeof(glxTrack));
	memset(glxPatterns[0],0,sizeof(glxPattern)+FileHdr->Tracks*sizeof(glxTrack));
	glxPatterns[0]->FourCC=GLX_FOURCC_PATT;
	glxPatterns[0]->Size=2+FileHdr->Tracks*sizeof(glxTrack);
	glxPatterns[0]->Tracks=FileHdr->Tracks;
	//Read track(s)    
	for (Track=0;Track<FileHdr->Tracks;Track++)
	{
		//Load general track header
		read(TrackHdr,1,sizeof(MIDTrackHdr_Struct),Stream);
		TrackHdr->Size=BSWAP32(TrackHdr->Size);
		//Grab memory for track and read it
		glxPatterns[0]->Track[Track].FourCC=GLX_FOURCC_TRAK;
		glxPatterns[0]->Track[Track].Size=sizeof(glxTrack)-8;
		glxPatterns[0]->Track[Track].Events=getmem(TrackHdr->Size);
		read(glxPatterns[0]->Track[Track].Events,1,TrackHdr->Size,Stream);
		//Update sequence
		glxOrders[0]=0;
	}
	// Set stereo/panning image
	for (ChannelNo=0;ChannelNo<glxMusicVoices;ChannelNo++)
		glxInitialPanning[ChannelNo]=64;
    freemem(TrackHdr);
    freemem(FileHdr);
    return GLXERR_NOERROR;
  }
  //Release header memory
  freemem(TrackHdr);
  freemem(FileHdr);
  return GLXERR_UNSUPPORTEDFORMAT;
}
