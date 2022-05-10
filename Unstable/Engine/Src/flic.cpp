#include "EnginePrivate.h"
#include "flic.h"
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>

#pragma pack(1)

void *flicMalloc(size_t size)
{
	return appMalloc(size,TEXT("FlicMalloc"));
}


/* Data structure for animation */
struct TFAnimation
{
   short Source;              /* Animation source:
                              *     0  -  From file
                              *     1  -  From handle
                              *     2  -  From memory */
   FILE *Handle;              /* File handle (for sources 0 and 1) */
   long StartOffset;          /* Start offset (for sources 0 and 1) */
   TFUByte *Address;          /* Address (for source 2) */
   size_t NowOffset;          /* Current offset (for source 2) */
   short Width;               /* Width of animation */
   short Height;              /* Height of animation */
   unsigned long Speed;       /* 60ths of a second to delay between frames */
   short NumFrames;           /* Number of frames in animation */
   short CurFrame;            /* Number of current frame */
   TFStatus UserBuffers;      /* TF_TRUE if user supplied buffers */
   TFUByte *Frame;            /* Pointer to frame buffer or NULL */
   TFUByte (*Palette)[256][3];/* Pointer to palette buffer or NULL */
   TFAnimation *Prev;         /* Pointer to previous animation or NULL */
   TFAnimation *Next;         /* Pointer to next animation or NULL */
   TFStatus LoopFlag;         /* TF_TRUE if to be looped */
   TFPaletteFunction PaletteFunction;  /* Palette update function or NULL */
   unsigned char paletteDirty;
};

TFAnimation *TF_FirstAnimation=NULL;      /* Pointer to first open animation */

static TFStatus TFAnimation_DecodeHeader(TFAnimation *animation, TFUByte *header);
static void TFAnimation_InitCommon(TFAnimation *animation);

/**************************************************************************
  TFAnimation *TFAnimation_NewFile(char *name);

  Opens new FLI/FLC animation file and returns pointer to animation
  structure. Sets frame pointer to first frame and reads animation
  information. Doesn't allocate memory for frame buffer nor palette
  buffer. Returns NULL on failure (file could not be read or file
  is not 256 color FLI/FLC animation).
**************************************************************************/
TFAnimation *TFAnimation_NewFile(char *name)
{
   TFAnimation *animation;
   FILE *file;
   TFUByte *header;

   /* Allocate memory for new animation structure */
   if((animation=(struct TFAnimation *)flicMalloc(sizeof(TFAnimation)))==NULL)
      appErrorf(TEXT("Memory allocation error in TFAnimation_NewFile()"));

   /* Try to open file */
   if((file=fopen(name, "rb"))==NULL)
      return NULL;

   /* Decode animation header */
   if((header=(unsigned char *)flicMalloc(128))==NULL)
   {
      appFree(animation);
      fclose(file);
      appErrorf(TEXT("Memory allocation error."));
   }
   if(fread(header, 128, 1, file)!=1)
   {
      appFree(animation);
      appFree(header);
      fclose(file);
      appErrorf(TEXT("Error reading file"));
   }
   if(TFAnimation_DecodeHeader(animation, header)==TF_FAILURE)
   {
      appFree(animation);
      appFree(header);
      fclose(file);
      appErrorf(TEXT("Failed to decode animation header"));
   }

   /* Initialize rest of the animation structure */
   animation->Source=0;
   animation->Handle=file;
   animation->StartOffset=0;
   TFAnimation_InitCommon(animation);

   /* Link animation to animation list */
   animation->Prev=NULL;
   animation->Next=TF_FirstAnimation;
   TF_FirstAnimation=animation;

   /* Return pointer to new animation */
   return(animation);
}

/**************************************************************************
*  TFAnimation *TFAnimation_NewHandle(FILE *handle);
*
*  Works exactly like the previous function except that the animation is
*  read from current position of given file handle.
**************************************************************************/
TFAnimation *TFAnimation_NewHandle(FILE *handle)
{
   TFAnimation *animation;
   TFUByte *header;

   /* Allocate memory for animation structure */
   if((animation=(TFAnimation *)flicMalloc(sizeof(TFAnimation)))==NULL)
      appErrorf(TEXT("Memory allocation error"));

   /* Allocate memory for animation header */

   if((header=(unsigned char *)flicMalloc(128))==NULL)
      appErrorf(TEXT("Memory allocation error"));

   /* Decode animation header */
   if(fread( header, 128, 1, handle)!=1)
   {
      appFree(animation);
      appFree(header);
      appErrorf(TEXT("Error reading file"));
   }
   if(TFAnimation_DecodeHeader(animation, header)==TF_FAILURE)
   {
      appFree(animation);
      appFree(header);
      appErrorf(TEXT("Animation format error in TFAnimation_NewHandle()"));
   }

   /* Initialize rest of the animation */
   animation->Source=1;
   animation->Handle=handle;
   animation->StartOffset=ftell(handle);
   TFAnimation_InitCommon(animation);

   /* Link animation to animation list */
   animation->Prev=NULL;
   animation->Next=TF_FirstAnimation;
   TF_FirstAnimation=animation;

   /* Return pointer to animation */
   return(animation);
}

/**************************************************************************
*  TFAnimation *TFAnimation_NewMem(void *rawdata);
*
*  Works exactly like the two previous functions except that the animation
*  is read from given memory position.
**************************************************************************/
TFAnimation *TFAnimation_NewMem(void *rawdata)
{
   TFAnimation *animation;
   TFUByte *header=(unsigned char *)rawdata;

   /* Allocate memory for animation structure */
   if((animation=(struct TFAnimation *)flicMalloc(sizeof(TFAnimation)))==NULL)
      appErrorf(TEXT("Memory allocation error in TFAnimation_NewMem()"));

   /* Decode animation header */
   if(TFAnimation_DecodeHeader(animation, header)==TF_FAILURE)
   {
      appFree(animation);
      appErrorf(TEXT("Animation format error in TFAnimation_NewMem()\n"));
      return(NULL);
   }

   /* Initialize rest of the animation */
   animation->Source=2;
   animation->Address=header;
   animation->NowOffset=128;
   TFAnimation_InitCommon(animation);

   /* Link animation to animation list */
   animation->Prev=NULL;
   animation->Next=TF_FirstAnimation;
   TF_FirstAnimation=animation;

   /* Return pointer to animation */
   return(animation);
}

/**************************************************************************
*  TFStatus TFAnimation_Delete(TFAnimation *animation);
*
*  Deletes given animation structure. Returns always TF_SUCCESS.
**************************************************************************/
TFStatus TFAnimation_Delete(TFAnimation *animation)
{
   /* Unlink animation from animation list */
   if(animation->Prev!=NULL) animation->Prev->Next=animation->Next;
   else TF_FirstAnimation=animation->Next;
   if(animation->Next!=NULL) animation->Next=animation->Prev;

   /* Free possible non-user allocated buffers */
   if(animation->UserBuffers==TF_FALSE)
   {
      if(animation->Frame!=NULL)   appFree(animation->Frame);
      if(animation->Palette!=NULL) appFree(animation->Palette);
   }

   /* If animation was opened by filename, close file */
   if(animation->Source==0) fclose(animation->Handle);

   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFAnimation_DeleteAll(void);
*  Deletes all existing animation structures. Returns always TF_SUCCESS.
**************************************************************************/
TFStatus TFAnimation_DeleteAll()
{
   /* Delete all animations */
   while(TF_FirstAnimation!=NULL)
   {
      if(TFAnimation_Delete(TF_FirstAnimation)==TF_FAILURE)
      {
         appErrorf(TEXT("Unknown error in TFAnimation_DeleteAll()"));
         return(TF_FAILURE);
      }
   }
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFAnimation_GetInfo(TFAnimation *animation, TFAnimationInfo *info);
*
*  Fills user supplied info structure with animation information. Returns
*  always TF_SUCCESS.
**************************************************************************/
TFStatus TFAnimation_GetInfo(TFAnimation *animation, TFAnimationInfo *info)
{
   /* Fill user supplied info structure */
   info->Width=animation->Width;
   info->Height=animation->Height;
   info->NumFrames=animation->NumFrames;
   info->CurFrame=animation->CurFrame;
   info->Speed=animation->Speed;
   info->Frame=animation->Frame;
   info->Palette=animation->Palette;
   info->LoopFlag=animation->LoopFlag;
   info->paletteChanged=animation->paletteDirty;
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFAnimation_SetLooping(TFAnimation *animation, TFStatus state);
*
*  Enables/disables animation looping. If state is TF_TRUE looping is enabled
*  and if it is TF_FALSE looping is disabled. Returns always TF_SUCCESS.
**************************************************************************/
TFStatus TFAnimation_SetLooping(TFAnimation *animation, TFStatus state)
{
   animation->LoopFlag=state;
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFAnimation_SetPaletteFunction(TFAnimation *animation,
*                                          TFPaletteFunction update_func);
*
*  Sets palette update function for animation. Every time palette changes
*  in animation this user specified function is called with new palette.
*  If this function is called with NULL, update function is disabled.
**************************************************************************/
TFStatus TFAnimation_SetPaletteFunction(TFAnimation *animation,TFPaletteFunction update_func)
{
   animation->PaletteFunction=update_func;
   return(TF_SUCCESS);
}

/*************************************************************************
*  Internal functions
*************************************************************************/
static TFStatus TFAnimation_DecodeHeader(TFAnimation *animation,TFUByte *header)
{
   /* Read information from animation header */
   animation->NumFrames=*(TFUWord *)(header+6);
   animation->Width=*(TFUWord *)(header+8);
   animation->Height=*(TFUWord *)(header+10);
   animation->Speed=*(unsigned long *)(header+16);
   if(*(TFUWord *)(header+12) != 8) return(TF_FAILURE);
   return(TF_SUCCESS);
}

static void TFAnimation_InitCommon(TFAnimation *animation)
{
   animation->UserBuffers=TF_FALSE;
   animation->Frame=NULL;
   animation->Palette=NULL;
   animation->PaletteFunction=NULL;
   animation->CurFrame=0;
}

/**************************************************************************
*  TFStatus TFBuffers_Set(TFAnimation *animation, void *framebuffer,
*                         void *palettebuffer);
*
*  With this function you can set frame buffer for frame data and palette
*  buffer for palette data. If there are no buffers set, animation can not
*  be decoded. If this function is called with NULL pointers, buffers will
*  be removed. Returns always TF_SUCCESS.
*
*  NOTICE! Buffers set with this function are not automatically freed when
*  animation structure is deleted.
*
*  Frame buffer size must be <width>*<height> bytes and palette buffer size
*  must be 768 bytes.
**************************************************************************/

TFStatus TFBuffers_Set(TFAnimation *animation, void *framebuffer,
                       void *palettebuffer)
{
   /* Check if need to free previously allocated buffers */

   if(animation->UserBuffers==TF_FALSE)
   {
      if(animation->Frame!=NULL) appFree(animation->Frame);
      if(animation->Palette!=NULL) appFree(animation->Palette);
   }

   /* Set new buffers */
   animation->UserBuffers=TF_TRUE;
   animation->Frame=(unsigned char *)framebuffer;
   animation->Palette=(unsigned char (*)[256][3])palettebuffer;

   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFBuffers_Alloc(TFAnimation *animation);
*
*  This function allocates frame buffer and palette buffer for animation.
*  If there are no buffers set, animation can not be decoced. Function
*  returns TF_SUCCESS on success and TF_FAILURE on failure. Buffers allocated
*  with this function are automatically freed when animation structure is
*  deleted.
**************************************************************************/
TFStatus TFBuffers_Alloc(TFAnimation *animation)
{
   /* Allocate those buffers that need to be allocated */
   if(animation->UserBuffers==TF_TRUE)
   {
      animation->Frame=NULL;
      animation->Palette=NULL;
   }

   if(animation->Frame==NULL)   animation->Frame=(unsigned char *)flicMalloc((long)animation->Width*(long)animation->Height);
   if(animation->Palette==NULL) animation->Palette=(unsigned char (*)[256][3])flicMalloc(768);
   animation->UserBuffers=TF_FALSE;

   /* Check if allocation was succesfull */
   if(animation->Frame==NULL||animation->Palette==NULL)
      appErrorf(TEXT("Memory allocation error in TFBuffers_Alloc()"));
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFBuffers_Free(TFAnimation *animation);
*
*  This function frees buffers allocated with TFBuffers_Alloc(). Function
*  returns TF_SUCCESS on success and TF_FAILURE on failure.
**************************************************************************/
TFStatus TFBuffers_Free(TFAnimation *animation)
{
   /* Check if there are buffers to be freed */
   if(animation->UserBuffers==TF_TRUE)
      appErrorf(TEXT("User supplied buffers present in TFBuffers_Free()"));

   /* Free allocated buffers */
   if(animation->Frame!=NULL) appFree(animation->Frame);
   if(animation->Palette!=NULL) appFree(animation->Palette);
   animation->Frame=NULL;
   animation->Palette=NULL;

   return(TF_SUCCESS);
}

static TFUDWord TFFile_GetDWord(FILE *handle);
static void TFChunk_Decode(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_COLOR(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_LC(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_BLACK(TFAnimation *animation);
static void TFChunk_Decode_FLI_BRUN(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_COPY(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_DELTA(TFAnimation *animation, TFUByte *chunk);
static void TFChunk_Decode_FLI_256_COLOR(TFAnimation *animation, TFUByte *chunk);

/**************************************************************************
*  TFStatus TFFrame_Decode(TFAnimation *animation);
*
*  Decodes next frame of animation. Returns TF_SUCCESS on success and
*  TF_FAILURE on failure. Function can fail if there are no buffers allocated
*  or if there are no more frames left. After decoding new frame can be read
*  from frame buffer as a raw color indexed data. The new palette can be read
*  from palette buffer.
**************************************************************************/
TFStatus TFFrame_Decode(TFAnimation *animation)
{
   TFUByte *frame;
   size_t chunk_length;
   int num_chunks;
   size_t offset;

   /* Check if buffers exist */
   if(animation->Palette==NULL||animation->Frame==NULL)
      appErrorf(TEXT("No buffers present"));

   animation->paletteDirty=0;

   /* Check if end of animation */
   if(animation->CurFrame>=animation->NumFrames)
   {
      if(animation->LoopFlag==TF_FALSE)
         return(TF_FAILURE);
      else TFFrame_Reset(animation);
   }

   /* Load frame to memory if necessary */
   if(animation->Source!=2)
   {
      long frame_offset;
      size_t frame_length;
      TFUWord magic;

      /* Read frame length */
      frame_offset=ftell(animation->Handle);
      frame_length=TFFile_GetDWord(animation->Handle);
      magic=(TFUWord)getc(animation->Handle);
      magic|=(TFUWord)getc(animation->Handle)<<8;
      fseek(animation->Handle,frame_offset,SEEK_SET);
      if(magic!=0xF1FA)
      {
         animation->CurFrame++;
         fseek(animation->Handle, frame_length, SEEK_CUR);
         return(TF_SUCCESS);
      }

      /* Allocate memory for frame */
      if((frame=(unsigned char *)flicMalloc(frame_length))==NULL)
      {
         appErrorf(TEXT("Memory allocation error"));
         return(TF_FAILURE);
      }

      /* Read frame to memory */
      fread(frame, frame_length, 1, animation->Handle);
   } else
   {
      frame=animation->Address+animation->NowOffset;
      animation->NowOffset+=*(TFUDWord *)(frame);
      if(*(TFUWord *)(frame+sizeof(TFUDWord))!=0xF1FA)
      {
         animation->CurFrame++;
         return(TF_SUCCESS);
      }
   }
   animation->CurFrame++;

   /* Go through all junks */
   num_chunks=*(TFUWord *)(frame+6);
   offset=16;
   while(num_chunks-->0)
   {
      /* Process one chunk */
      chunk_length=*(TFUDWord *)(frame+offset);
      TFChunk_Decode(animation, frame+offset);
      offset+=chunk_length;
   }

   if(animation->Source!=2) appFree(frame);
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFFrame_Reset(TFAnimation *animation);
*
*  Resets frame count of animation so that the next frame to be decoded is
*  the first frame of animation. Returns TF_SUCCESS on success and
*  TF_FAILURE on failure.
**************************************************************************/
TFStatus TFFrame_Reset(TFAnimation *animation)
{
   /* Reset frame counter */
   animation->CurFrame=0;
   if(animation->Source!=2) fseek(animation->Handle,animation->StartOffset+128,SEEK_SET);
   else animation->NowOffset=128;
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFStatus TFFrame_Seek(TFAnimation *animation, int frame);
*
*  Seeks animation to given frame. This function can be very slow because
*  FLIC animations can not be decoded backwards and only way to go
*  backwards is to start decoding from beginning. Also if you are seeking
*  forward it can take time to decode frames which are skipped.
**************************************************************************/
TFStatus TFFrame_Seek(TFAnimation *animation, int frame)
{
   /* Check if need to seek from the start */
   if(frame<animation->CurFrame) TFFrame_Reset(animation);

   /* Seek forward */
   while(animation->CurFrame<frame)
      if(TFFrame_Decode(animation)==TF_FAILURE)
         appErrorf(TEXT("Decoding error in TFFrame_Seek()"));
   return(TF_SUCCESS);
}

/**************************************************************************
*  TFUDWord TFFile_GetDWord(FILE *handle);
*
*  Reads dword from file.
**************************************************************************/
static TFUDWord TFFile_GetDWord(FILE *handle)
{
   TFUDWord result;
   result= (long)getc(handle);
   result|=(long)getc(handle)<<8;
   result|=(long)getc(handle)<<16;
   result|=(long)getc(handle)<<24;
   return(result);
}

/**************************************************************************
*  void TFChunk_Decode(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes one chunk of the frame.
**************************************************************************/
static void TFChunk_Decode(TFAnimation *animation, TFUByte *chunk)
{
   TFUWord type;

   /* Get chunk type */
   type=*(TFUWord *)(chunk+4);

   /* Process chunk */
   switch(type)
   {
      default:    /* Unknown type, skip */
         break;

      case 11:    /* FLI_COLOR */
         TFChunk_Decode_FLI_COLOR(animation, chunk);
         break;

      case 12:    /* FLI_LC */
         TFChunk_Decode_FLI_LC(animation, chunk);
         break;

      case 13:    /* FLI_BLACK */
         TFChunk_Decode_FLI_BLACK(animation);
         break;

      case 15:    /* FLI_BRUN */
         TFChunk_Decode_FLI_BRUN(animation, chunk);
         break;

      case 16:    /* FLI_COPY */
         TFChunk_Decode_FLI_COPY(animation, chunk);
         break;

      case 7:     /* FLI_DELTA */
         TFChunk_Decode_FLI_DELTA(animation, chunk);
         break;

      case 4:     /* FLI_256_COLOR */
         TFChunk_Decode_FLI_256_COLOR(animation, chunk);
         break;
   }
}

/*************************************************************************
*  void TFChunk_Decode_FLI_COLOR(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes FLI_COLOR chunk.
*************************************************************************/
static void TFChunk_Decode_FLI_COLOR(TFAnimation *animation, TFUByte *chunk)
{
   int color=0, num_packets;
   size_t offset=8;
   int numcol, i;

   /* Go through color packets */
   num_packets=*(TFUWord *)(chunk+6);
   while(num_packets-->0)
   {
      color += *(TFUByte *)(chunk+offset++);
      numcol = *(TFUByte *)(chunk+offset++);
      if(numcol==0) numcol=256;
      while(numcol-->0)
      {
         for(i=0; i<3; i++)
            (*animation->Palette)[color][i]=*(TFUByte *)(chunk+offset++);
         color++;
      }
   }

   animation->paletteDirty=1;

   /* Call palette update function if present */
   if(animation->PaletteFunction!=NULL)
      animation->PaletteFunction(animation,animation->Palette);
}

/*************************************************************************
*  void TFChunk_Decode_FLI_LC(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes FLI_LC chunk.
*************************************************************************/
static void TFChunk_Decode_FLI_LC(TFAnimation *animation, TFUByte *chunk)
{
   TFUByte *line;
   int skip_lines, num_lines;
   size_t offset=10;

   /* Skip unchanged lines */
   skip_lines=*(TFUWord *)(chunk+6);
   line=animation->Frame+animation->Width*skip_lines;

   /* Decode changed lines */
   num_lines=*(TFUWord *)(chunk+8);
   while(num_lines-->0)
   {
      int num_packets;
      size_t line_offset=0;
      int size_count;

      /* Decode one packet at time */
      num_packets=*(TFUByte *)(chunk+offset++);
      while(num_packets-->0)
      {
         /* Skip unchanged bytes */
         line_offset+=*(TFUByte *)(chunk+offset++);

         /* Decode changed bytes */
         size_count=*(TFSByte *)(chunk+offset++);
         if(size_count>=0)
         {
            /* Copy data to the screen */
            while(size_count-->0)
               *(line+line_offset++) = *(chunk+offset++);
         } else
         {
            TFUByte color;

            /* Draw single color to the screen */
            color=*(chunk+offset++);
            while(size_count++<0)
               *(line+line_offset++) = color;
         }
      }

      /* Move to next line */
      line=line+animation->Width;
   }
}

/*************************************************************************
*  void TFChunk_Decode_FLI_BLACK(TFAnimation *animation);
*
*  Decodes FLI_BLACK chunk.
*************************************************************************/
static void TFChunk_Decode_FLI_BLACK(TFAnimation *animation)
{
   size_t frame_size;

   frame_size=(size_t)animation->Width * (size_t)animation->Height;
   memset(animation->Frame, 0, frame_size);
}

/*************************************************************************
*  void TFChunk_Decode_FLI_BRUN(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes FLI_BRUN chunk.
*************************************************************************/
static void TFChunk_Decode_FLI_BRUN(TFAnimation *animation, TFUByte *chunk)
{
   unsigned char *line=animation->Frame;
   size_t offset=6;
   int line_count;

   /* Decode picture line by line */
   for(line_count=0; line_count<animation->Height; line_count++)
   {
      size_t line_offset=0;
      int num_packets;


      /* Go through all the packets */
      num_packets=*(unsigned char *)(chunk+offset++);

	  //while(num_packets-->0)
	  while((int)line_offset<animation->Width)
	  {
		  int size_count;

		  /* Decode packet */
		  size_count=*(signed char *)(chunk+offset++);
		  if(size_count>=0)
		  {
			  unsigned char color;

				/* Fill with single color */
				color=*(unsigned char *)(chunk+offset++);
				while(size_count-->0)
					*(line+line_offset++)=color;
			} else
			{
				/* Copy color data */
				while(size_count++<0)
					*(line+line_offset++)=*(unsigned char *)(chunk+offset++);
			}
		}

      /* Move to next line */
      line+=animation->Width;
   }
}

/***************************************************************************
*  void TFChunk_Decode_FLI_COPY(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes FLI_COPY chunk.
***************************************************************************/
void TFChunk_Decode_FLI_COPY(TFAnimation *animation, TFUByte *chunk)
{
   /* Copy data from chunk to frame */
   memcpy(animation->Frame, chunk+6, (size_t)animation->Width * (size_t)animation->Height);
}

/*************************************************************************
*  void TFChunk_Decode_FLI_DELTA(TFAnimation *animation, TFUByte *chunk);
*
*  Decodes FLI_DELTA chunk.
*************************************************************************/
static void TFChunk_Decode_FLI_DELTA(TFAnimation *animation, TFUByte *chunk)
{
   TFUWord num_lines;
   size_t offset=8;
   TFUByte *line=animation->Frame;

   /* Go through each line */
   num_lines=*(TFUWord *)(chunk+6);
   while(num_lines>0)
   {
      TFSWord num_packets;
      size_t line_offset=0;

      /* Get number of packets */
      num_packets=*(TFSWord *)(chunk+offset);
      offset+=2;

      /* If negative skip that many lines otherwise decode packets */
      if(num_packets<0) line+=animation->Width*(-num_packets);
      else
      {
         while(num_packets-->0)
         {
            int size_count;

            /* Skip unchanged pixels */
            line_offset+=*(TFUByte *)(chunk+offset++);

            /* Decode changed pixels */
            size_count=*(TFSByte *)(chunk+offset++);
            if(size_count>=0)
            {
               /* Copy color data */
               while(size_count-->0)
               {
                  *(TFUWord *)(line+line_offset)=*(TFUWord *)(chunk+offset);
                  line_offset+=2;
                  offset+=2;
               }
            } else
            {
               TFUWord color;

               /* Fill with one color */
               color=*(TFUWord *)(chunk+offset);
               offset+=2;
               while(size_count++<0)
               {
                  *(TFUWord *)(line+line_offset)=color;
                  line_offset+=2;
               }
            }
         }

         /* Move to next line */

         line+=animation->Width;
         num_lines--;
      }
   }
}

/**************************************************************************
  void TFChunk_Decode_FLI_256_COLOR(TFAnimation *animation, TFUByte *chunk);
  Decodes FLI_256_COLOR chunk.
**************************************************************************/
void TFChunk_Decode_FLI_256_COLOR(TFAnimation *animation, TFUByte *chunk)
{
   size_t offset=8;
   TFUWord num_packets;
   int color=0;

   /* Go through each packet */

   num_packets=*(TFUWord *)(chunk+6);
   while(num_packets-->0)
   {
      int num_colors;

      /* Skip unchanged colors */
      color+=*(TFUByte *)(chunk+offset++);

      /* Decode changed colors */
      num_colors=*(TFUByte *)(chunk+offset++);
      if(num_colors==0) num_colors=256;
      while(num_colors-->0)
      {
         int i;

         for(i=0; i<3; i++)
            (*animation->Palette)[color][i]=*(TFUByte *)(chunk+offset++) >> 2;
         color++;
      }
   }

   animation->paletteDirty=1;

   /* Call palette update function if present */
   if(animation->PaletteFunction!=NULL) 
		animation->PaletteFunction(animation,animation->Palette);
}






