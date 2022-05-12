//
// Fast Heckbert quantiser for creating paletted textures from
// high/true colour input textures
//
// Alpha weighting is going to be a tricky thing - unlike the RGB weightings
// which are well defined, the importance of the alpha channel probably has to
// have the highest weighting of all. However, because it affects all the other
// components its correct weighting is almost certainly some product of the alpha
// value itself and the colours it encompasses, rather than a fixed value...
//
// Some code based on source from the Independent JPEG group
// Copyright (C) 1991-1998, Thomas G. Lane.
//
//
// A. Pomianowski
//

#include "EnginePrivate.h"
#include <stdlib.h>

#include "Palette.h"

#pragma warning( disable : 4706 )

// Define to help optimise palettes for alpha images - if defined, then during histogram
// compilation, all texels with alpha(after quantisation) of 0 are mapped to 0. This can
// reduce the colour space considerably. The only problem is that it assumes that the alpha
// channel is always used. If this is not the case then the optimisation is invalid.
// It also might cause border effects around alpha transparency when bilinear interpolation is
// on, so if this is the case we might have to leave it out

//#define ALPHA_OPTIMISE


// Histogram sufficient to contain 16 bits of colour entries
static unsigned long histogram[65536];

// Flags to indicate colours that are represented in the palette
static unsigned long    in_pal[65536];


// Possible later optimisation (?) - store out the total colour count
// of the input image after quantisation so that if it is less than 256
// we can simply assign colours
static int   colour_count;

// Flag to indicate whether to consider alpha data in the palette
static UBOOL  alpha_data = false;

/*
 * Quantisation functions.
 *
 * To reduce the colour space to a manageable size we quantise it to 16 bits
 * initially, compiling a histogram of entries as we go. We choose the colour
 * cube that best fits our source data
 *
 * Each function (apart from the 16 bit one) also allocates a new copy of the
 * image at 16 bit resolution because this speeds up inner loops later on.
 *
 */




// For 8888 source data, our best quantised palette format is RGB4444
unsigned short *Histogram8888(unsigned long  *data,
                              int            width,
                              int            height)
{
   int   i;
   unsigned long int item;
   unsigned short *qd;

   i = width * height;
   qd = (unsigned short*) appMalloc(i*sizeof(short), TEXT("Histogram8888"));

#define ADATA(a) ((a & 0xf0000000) >> 16)
#define RDATA(a) ((a & 0x00f00000) >> 12)
#define GDATA(a) ((a & 0x0000f000) >> 8)
#define BDATA(a) ((a & 0x000000f0) >> 4)

   while(i)
      {
      i--;
      item = data[i];
#ifdef ALPHA_OPTIMISE
      if(!ADATA(item))
         item = qd[i] = 0;
      else
         item = qd[i] = (unsigned short)(ADATA(item) + RDATA(item) + GDATA(item) + BDATA(item));
#else
      item = qd[i] = (unsigned short)(ADATA(item) + RDATA(item) + GDATA(item) + BDATA(item));
#endif
      if(!histogram[item])
         colour_count++;
      histogram[item]++;
      }

   return(qd);
}



//
// 24 bit source data, unpacked
//
//
unsigned short *HistogramX888(unsigned long *data,
                              int width,
                              int height)
{
   int   i;
   unsigned long int item;
   unsigned short *qd;

   // For X888 source data our best palette format is RGB565

   i = width * height;
   qd = (unsigned short*) appMalloc(i*sizeof(short), TEXT("HistogramX888"));
#undef RDATA
#undef GDATA
#undef BDATA
#define RDATA(a) ((a & 0x00f80000) >> 8)
#define GDATA(a) ((a & 0x0000fc00) >> 5)
#define BDATA(a) ((a & 0x000000f8) >> 3)

   while(i)
      {
      i--;
      item = data[i];
      item = qd[i] = (unsigned short)(RDATA(item) + GDATA(item) + BDATA(item));
      if(!histogram[item])
         colour_count++;
      histogram[item]++;
      }

   return(qd);
}




//
// 24bit source data, packed RGB
//
//
//
unsigned short *Histogram888(unsigned char *data,
                             int width,
                             int height)
{
   int   i,j,k;
   unsigned long  r,g,b;
   unsigned long item;
   unsigned short *qd;

   // Our best palette format is RGB565
   i = width*height*3;
   qd = (unsigned short*) appMalloc(width*height*sizeof(short), TEXT("Histogram888"));
   j=0;
   k=0;
   while(j<i)
      {
      r = data[j++];
      g = data[j++];
      b = data[j++];
      r = r & 0xf8;
      g = g & 0xfc;
      b = b & 0xf8;
      item = (r<<8) | (g<<3) | (b>>3);
      qd[k] = (unsigned short)item;
      if(!histogram[item])
         colour_count++;
      histogram[item]++;
      k++;
      }

   return(qd);
}



//
// 16 bit input maps
// These are all easy - just assign the quantities directly into the histogram
//
unsigned short *Histogram16Bit(unsigned short *data,
                               int width,
                               int height,
                               int format)
{
   int   i;

   i = width * height;

   switch(format)
      {
      case  RGB_565:
         while(i)
            {
            i--;
            if(!histogram[data[i]])
               colour_count++;
            histogram[data[i]]++;
            }
         break;
      case  ARGB_1555:
         while(i)
            {
            i--;
#ifdef   ALPHA_OPTIMISE
            if(!(data[i] & 0x8000))
               data[i] = 0;
#endif
            if(!histogram[data[i]])
               colour_count++;
            histogram[data[i]]++;
            }
         break;
      case  ARGB_4444:
         while(i)
            {
            i--;
#ifdef   ALPHA_OPTIMISE
            if(!(data[i] & 0xF000))
               data[i] = 0;
#endif
            if(!histogram[data[i]])
               colour_count++;
            histogram[data[i]]++;
            }
         break;
      }

   return(data);
}





// Ok, here is the really interesting stuff - assignment of colours
//
// Our basic unit is a box that contains an area of the colourspace.
//
// We subdivide boxes as we go to get to our desired number of colours
//

typedef struct
{
   /* The bounds of the box (inclusive); expressed as histogram indexes */
   int amin, amax;
   int rmin, rmax;
   int gmin, gmax;
   int bmin, bmax;

   /* The volume of the box */
   long volume;

   /* The number of nonzero histogram cells within this box */
   long colour_count;

}  box;

// List of data for boxes (256 palette entries maximum)
box   boxlist[256];



// Weighting factors for the colour components. These are integer approximations
// of the correct factors in an RGB colour space, but they should be good enough.
// We can change everything to use float later if necessary, but I don't think
// it is, and it will slow things down in the inner loops _badly_
//
// NB. For some reason the correct weightings don't seem to produce very good results
// so maybe I have made a mistake somewhere.

unsigned long  ascale = 400;
unsigned long  rscale = 200;      //400
unsigned long  gscale = 300;
unsigned long  bscale = 100;      //500



// Defines for extracting colours into 8 bit values
#define  ACOMP4444(c)   (((c) & 0xf000) >> 8)
#define  RCOMP4444(c)   (((c) & 0x0f00) >> 4)
#define  GCOMP4444(c)   ((c)  & 0x00f0)
#define  BCOMP4444(c)   (((c) & 0x000f) << 4)

#define  ACOMP1555(c)   (((c) & 0x8000) ? 0xff : 0x0)
#define  RCOMP1555(c)   (((c) & 0x7c00) >> 7)
#define  GCOMP1555(c)   (((c) & 0x03e0) >> 2)
#define  BCOMP1555(c)   (((c) & 0x001f) << 3)

#define  RCOMP565(c)   (((c) & 0xf800) >> 8)
#define  GCOMP565(c)   (((c) & 0x07e0) >> 3)
#define  BCOMP565(c)   (((c) & 0x001f) << 3)




//
// Set the colour weightings that will be used for deciding how the
// colourspace boxes will be split.
//
// This allows some tuning of the palettisation for individual images
//

void  SetupColourWeightings(float aw, float rw, float gw, float bw)
{
   ascale   = 100 * aw;
   rscale   = 100 * rw;
   gscale   = 100 * gw;
   bscale   = 100 * bw;
}



//
// Attempt to bias colour weightings for a given image to achieve really good
// quantisation, after colourspace reduction to 16 bits
//
//

void  OptimiseColourWeightings(unsigned short *picture, int  format, int width, int height)
{
   int   i;
   double   a,r,g,b,max;
   float    basea,baser,baseg,baseb;

   basea = 4.0;
   baser = 2.0;
   baseg = 3.0;
   baseb = 1.0;

   a = 0.0;
   r = 0.0;
   g = 0.0;
   b = 0.0;

   i = width*height;

   switch(format)
      {
      case  RGB_565:
         while(i--)
            {
            r += RCOMP565(picture[i]);
            g += GCOMP565(picture[i]);
            b += BCOMP565(picture[i]);
            }
         max = r;
         if(g > max)
            max = g;
         if(b > max)
            max = b;
         r = (r * baser) / max;
         g = (g * baseg) / max;
         b = (b * baseb) / max;
         SetupColourWeightings(0.0, r, g, b);
         break;
      case  ARGB_1555:
         while(i--)
            {
            r += RCOMP1555(picture[i]);
            g += GCOMP1555(picture[i]);
            b += BCOMP1555(picture[i]);
            }
         max = r;
         if(g > max)
            max = g;
         if(b > max)
            max = b;
         r = (r * baser) / max;
         g = (g * baseg) / max;
         b = (b * baseb) / max;
         SetupColourWeightings(basea, r, g, b);
         break;
      case  ARGB_4444:
         while(i--)
            {
            r += RCOMP4444(picture[i]);
            g += GCOMP4444(picture[i]);
            b += BCOMP4444(picture[i]);
            }
         max = r;
         if(g > max)
            max = g;
         if(b > max)
            max = b;
         r = (r * baser) / max;
         g = (g * baseg) / max;
         b = (b * baseb) / max;
         SetupColourWeightings(basea, r, g, b);
         break;
      default:
         break;
      }
}






// Multipliers and shift values to correctly position
// the colour components
int   amul,rmul,gmul,bmul;
int   ashift,rshift,gshift,bshift;




box *FindMostPopulatedBox(box *boxlist, int numboxes)
/* Find the splittable box with the largest color population */
/* Returns NULL if no splittable boxes remain */
{
   box *boxp;
   int i;
   long maxc = 0;

   box *which = NULL;
  
   for (i = 0, boxp = boxlist; i < numboxes; i++, boxp++)
      {
      if (boxp->colour_count > maxc && boxp->volume > 0)
         {
         which = boxp;
         maxc = boxp->colour_count;
         }
      }
  return which;
}








box *FindBoxWithLargestVolume(box *boxlist, int numboxes)
/* Find the splittable box with the largest (scaled) volume */
/* Returns NULL if no splittable boxes remain */
{
   box *boxp;
   int i;
   long maxv = 0;
   box *which = NULL;
  
   for (i = 0, boxp = boxlist; i < numboxes; i++, boxp++)
      {
      if (boxp->volume > maxv)
         {
         which = boxp;
         maxv = boxp->volume;
         }
      }

   return which;
}









void UpdateBoxInfo(box *bptr)
/* Shrink the min/max bounds of a box to enclose only nonzero elements, */
/* and recompute its volume and population */
{
   unsigned long *histdata;
   int r,g,b;
   int rmin,rmax,gmin,gmax,bmin,bmax;
   unsigned long dist0,dist1,dist2;
   long ccount;
  
   rmin = bptr->rmin;
   rmax = bptr->rmax;
   gmin = bptr->gmin;
   gmax = bptr->gmax;
   bmin = bptr->bmin;
   bmax = bptr->bmax;
  
   // I'm using gotos here to escape from the inner loops. This code comes
   // directly from the IJPEG groups' source.
   // Although I don't like gotos, in this case they are the only quick
   // way of performing this operation - any other method requires adding
   // additional conditions to the loops which will be slow, and compromise
   // branch prediction. Whereas the gotos are 100% predictable...

   if (rmax > rmin)
      {
      for (r = rmin; r <= rmax; r++)
         {
         for (g = gmin; g <= gmax; g++)
            {
	         histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
	         for (b = bmin; b <= bmax; b++)
               {
	            if (*histdata++)
                  {
	               bptr->rmin = rmin = r;
	               goto get_rmax;
	               }
               }
            }
         }
      }

 get_rmax:
   if (rmax > rmin)
      {
      for (r = rmax; r >= rmin; r--)
         {
         for (g = gmin; g <= gmax; g++)
            {
	         histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
	         for (b = bmin; b <= bmax; b++)
               {
	            if (*histdata++)
                  {
	               bptr->rmax = rmax = r;
	               goto get_gmin;
                  }
               }
            }
         }
      }

 get_gmin:
   if (gmax > gmin)
      {
      for (g = gmin; g <= gmax; g++)
         {
         for (r = rmin; r <= rmax; r++)
            {
	         histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
	         for (b = bmin; b <= bmax; b++)
               {
	            if (*histdata++)
                  {
	               bptr->gmin = gmin = g;
	               goto get_gmax;
	               }
               }
            }
         }
      }

get_gmax:
   if (gmax > gmin)
      {
      for (g = gmax; g >= gmin; g--)
         {
         for (r = rmin; r <= rmax; r++)
            {
	         histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
	         for (b = bmin; b <= bmax; b++)
               {
	            if (*histdata++)
                  {
	               bptr->gmax = gmax = g;
	               goto get_bmin;
	               }
               }
            }
         }
      }

get_bmin:
   if (bmax > bmin)
      {
      for (b = bmin; b <= bmax; b++)
         {
         for (r = rmin; r <= rmax; r++)
            {
	         histdata = &(histogram[(r<<rshift) + (gmin << gshift) + b]);
	         for (g = gmin; g <= gmax; g++, histdata += (bmul+1))
               {
	            if (*histdata)
                  {
	               bptr->bmin = bmin = b;
	               goto get_bmax;
	               }
               }
            }
         }
      }

get_bmax:
   if (bmax > bmin)
      {
      for (b = bmax; b >= bmin; b--)
         {
         for (r = rmin; r <= rmax; r++)
            {
	         histdata = &(histogram[(r<<rshift) + (gmin << gshift) + b]);
	         for (g = gmin; g <= gmax; g++, histdata += (bmul+1))
               {
	            if (*histdata)
                  {
	               bptr->bmax = bmax = b;
	               goto got_all;
	               }
               }
            }
         }
      }

got_all:

  /*
   * Update box volume.
   * We use 2-norm rather than real volume here; this biases the method
   * against making long narrow boxes, and it has the side benefit that
   * a box is splittable iff norm > 0.
   */

   dist0 = (rmax - rmin) * rscale;
   dist1 = (gmax - gmin) * gscale;
   dist2 = (bmax - bmin) * bscale;

   bptr->volume = dist0*dist0 + dist1*dist1 + dist2*dist2;

   
   /* Now scan the volume of the box and compute its population */
   ccount = 0;

   for(r = rmin; r <= rmax; r++)
      {
      for (g = gmin; g <= gmax; g++)
         {
         histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
         for (b = bmin; b <= bmax; b++, histdata++)
            {
            if (*histdata)
         	   ccount++;
	         }
         }
      }

   if(ccount == 0)
      debugf(TEXT("Unpopulated box!\n"));

   bptr->colour_count = ccount;
}














void UpdateBoxInfoWithAlpha(box *bptr)
/* Shrink the min/max bounds of a box to enclose only nonzero elements, */
/* and recompute its volume and population */
{
   unsigned long *histdata;
   int a,r,g,b;
   int amin,amax,rmin,rmax,gmin,gmax,bmin,bmax;
   unsigned long dist0,dist1,dist2,dist3;
   long ccount;

   
   amin = bptr->amin;
   amax = bptr->amax;
   rmin = bptr->rmin;
   rmax = bptr->rmax;
   gmin = bptr->gmin;
   gmax = bptr->gmax;
   bmin = bptr->bmin;
   bmax = bptr->bmax;
  
   // I'm using gotos here to escape from the inner loops. This code comes
   // directly from the IJPEG groups' source.
   // Although I don't like gotos, in this case they are the only quick
   // way of performing this operation - any other method requires adding
   // additional conditions to the loops which will be slow, and compromise
   // branch prediction. Whereas the gotos are 100% predictable...


   if(amax > amin)
      {
      for(a = amin; a <= amax; a++)
         {
         for(r = rmin; r <= rmax; r++)
            {
            for(g = gmin; g <= gmax; g++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->amin = amin = a;
	                  goto get_amax;
	                  }
                  }
               }
            }
         }
      }

get_amax:
   if (amax > amin)
      {
      for (a = amax; a >= amin; a--)
         {
         for(r = rmin; r <= rmax; r++)
            {
            for (g = gmin; g <= gmax; g++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->amax = amax = a;
	                  goto get_rmin;
                     }
                  }
               }
            }
         }
      }


get_rmin:
   if (rmax > rmin)
      {
      for (r = rmin; r <= rmax; r++)
         {
         for(a = amin; a <= amax; a++)
            {
            for (g = gmin; g <= gmax; g++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->rmin = rmin = r;
	                  goto get_rmax;
	                  }
                  }
               }
            }
         }
      }

get_rmax:
   if (rmax > rmin)
      {
      for (r = rmax; r >= rmin; r--)
         {
         for(a = amin;a <= amax; a++)
            {
            for (g = gmin; g <= gmax; g++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->rmax = rmax = r;
	                  goto get_gmin;
                     }
                  }
               }
            }
         }
      }

 get_gmin:
   if (gmax > gmin)
      {
      for (g = gmin; g <= gmax; g++)
         {
         for(a = amin; a <= amax; a++)
            {
            for (r = rmin; r <= rmax; r++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->gmin = gmin = g;
	                  goto get_gmax;
	                  }
                  }
               }
            }
         }
      }

get_gmax:
   if (gmax > gmin)
      {
      for (g = gmax; g >= gmin; g--)
         {
         for(a = amin; a <= amax; a++)
            {
            for (r = rmin; r <= rmax; r++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
	            for (b = bmin; b <= bmax; b++)
                  {
	               if (*histdata++)
                     {
	                  bptr->gmax = gmax = g;
	                  goto get_bmin;
	                  }
                  }
               }
            }
         }
      }

get_bmin:
   if (bmax > bmin)
      {
      for (b = bmin; b <= bmax; b++)
         {
         for(a = amin; a <= amax; a++)
            {
            for (r = rmin; r <= rmax; r++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (gmin << gshift) + b]);
	            for (g = gmin; g <= gmax; g++, histdata += (bmul+1))
                  {
	               if (*histdata)
                     {
	                  bptr->bmin = bmin = b;
	                  goto get_bmax;
	                  }
                  }
               }
            }
         }
      }

get_bmax:
   if (bmax > bmin)
      {
      for (b = bmax; b >= bmin; b--)
         {
         for(a = amin; a <= amax; a++)
            {
            for (r = rmin; r <= rmax; r++)
               {
	            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (gmin << gshift) + b]);
	            for (g = gmin; g <= gmax; g++, histdata += (bmul+1))
                  {
	               if (*histdata)
                     {
	                  bptr->bmax = bmax = b;
	                  goto got_all;
	                  }
                  }
               }
            }
         }
      }

got_all:

  /*
   * Update box volume.
   * We use 2-norm rather than real volume here; this biases the method
   * against making long narrow boxes, and it has the side benefit that
   * a box is splittable iff norm > 0.
   */

   dist0 = (amax - amin) * ascale;
   dist1 = (rmax - rmin) * rscale;
   dist2 = (gmax - gmin) * gscale;
   dist3 = (bmax - bmin) * bscale;

   bptr->volume = dist0*dist0 + dist1*dist1 + dist2*dist2 + dist3*dist3;


   /* Now scan the volume of the box and compute its population */
   ccount = 0;

   for(a = amin; a<= amax; a++)
      {
      for(r = rmin; r <= rmax; r++)
         {
         for (g = gmin; g <= gmax; g++)
            {
            histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
            for (b = bmin; b <= bmax; b++, histdata++)
               {
               if (*histdata)
         	      ccount++;
	            }
            }
         }
      }

   if(ccount == 0)
      debugf(TEXT("Unpopulated box!\n"));

   bptr->colour_count = ccount;
}











//
// Compute a palette, reserving colour 0 for colour key if required
//
//

void  ComputePalette(unsigned short *paldata, int nentries, int nboxes, int has_key)
{
   // For each box, compute the mean colour of the box.
   // We then assign this colour into paldata[box]

   unsigned long *histdata,*inpaldata;
   int r,g,b;
   int rmin,rmax,gmin,gmax,bmin,bmax;
   long count;
   unsigned long total;
   unsigned long rtotal;
   unsigned long gtotal;
   unsigned long btotal;
   box   *bptr;
   int i;
   int   boffset = 0;

   // If we have a colour key then reserve colour 0 in the palette as the
   // colour key entry. we know that the quantiser has already reduced the
   // number of boxes we have created
   if(has_key)
      {
      nboxes-=1;
      boffset = 1;
      }
   else
      boffset = 0;
   
   for(i=0;i<nboxes;i++)
      {
      total = 0;
      rtotal = 0;
      gtotal = 0;
      btotal = 0;
      bptr = &boxlist[i];

      rmin = bptr->rmin;
      rmax = bptr->rmax;
      gmin = bptr->gmin;
      gmax = bptr->gmax;
      bmin = bptr->bmin;
      bmax = bptr->bmax;

      // Scan this box, and get and weight its colour contributions.
      // For all items in the box, indicate that they are represented by this
      // colour palette entry...
      for (r = rmin; r <= rmax; r++)
         {
         for (g = gmin; g <= gmax; g++)
            {
            histdata = &(histogram[(r<<rshift) + (g<<gshift) + bmin]);
            inpaldata = &(in_pal[(r<<rshift) + (g<<gshift) + bmin]);
            for (b = bmin; b <= bmax; b++)
               {
	            if(count = *histdata)
                  {
	               total += count;
	               rtotal += r * count;
	               gtotal += g * count;
	               btotal += b * count;
	               }
               // Rework this histogram entry to be an inverse lookup to the palette entry
               // And note that it is represented in the palette for mipmapping
               *histdata = i+boffset;
               *inpaldata = 1;
               histdata++;
               inpaldata++;
               }
            }
         }

      // Work out the average colour for the cell, weighted by the number of pixels
      // using the colours
      if(total)
         {
         r = rtotal / total;
         g = gtotal / total;
         b = btotal / total;
         // Create the palette entry
         paldata[i+boffset] = (r << rshift) | (g << gshift) | (b << bshift);
         }
      else
         paldata[i+boffset] = 0;
      }
}







//
// Compute a palette, taking alpha data into account
//
//
//
//
//

void  ComputeAlphaPalette(unsigned short  *paldata,
                          int             nentries,
                          int             nboxes)
{
   // For each box, compute the mean colour of the box.
   // We then assign this colour into paldata[box]

   unsigned long *histdata,*inpaldata;
   int a,r,g,b;
   int amin,amax,rmin,rmax,gmin,gmax,bmin,bmax;
   long count;
   unsigned long total;
   unsigned long atotal;
   unsigned long rtotal;
   unsigned long gtotal;
   unsigned long btotal;
   box   *bptr;
   int i;
   
   for(i=0;i<nboxes;i++)
      {
      total = 0;
      atotal = 0;
      rtotal = 0;
      gtotal = 0;
      btotal = 0;
      bptr = &boxlist[i];

      amin = bptr->amin;
      amax = bptr->amax;
      rmin = bptr->rmin;
      rmax = bptr->rmax;
      gmin = bptr->gmin;
      gmax = bptr->gmax;
      bmin = bptr->bmin;
      bmax = bptr->bmax;

      // Scan this box, and get and weight its colour contributions.
      for(a = amin; a <= amax; a++)
         {
         for (r = rmin; r <= rmax; r++)
            {
            for (g = gmin; g <= gmax; g++)
               {
               histdata = &(histogram[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
               inpaldata = &(in_pal[(a<<ashift) + (r<<rshift) + (g<<gshift) + bmin]);
               for (b = bmin; b <= bmax; b++)
                  {
	               if(count = *histdata)
                     {
	                  total += count;
	                  atotal += a * count;
	                  rtotal += r * count;
	                  gtotal += g * count;
	                  btotal += b * count;
                     }

                  // Rework this histogram entry to be an inverse lookup to the palette entry
                  // And note that it is represented in the palette for mipmapping
                  *histdata = i;
                  *inpaldata = 1;
                  histdata++;
                  inpaldata++;
                  }
               }
            }
         }

      // Work out the average colour for the cell, weighted by the number of pixels
      // using the colours
      if(total)
         {
         a = atotal / total;
         r = rtotal / total;
         g = gtotal / total;
         b = btotal / total;
         // Create the palette entry
         paldata[i] = (a << ashift) | (r << rshift) | (g << gshift) | (b << bshift);
         }
      else
         paldata[i] = 0;
      }
}












//
// Copy paletted data into the new surface
//
// Assign colours matching a colour key to index 0 in the palette 
// if requested
//
// (Set the colour in index 0 to be the colour key value?)
//

int  CopyPalettisedData(void           *orig_data,
                        unsigned short *srcdata,
                        unsigned char  *dstdata,
                        int            srcformat,
                        int            width,
                        int            height,
                        UBOOL           has_key,
                        unsigned long  keyval)
{
   int   i;
   // Copy the data from the original map to the palettised map
   // No dithering (Floyd-Steinberg may soon be implemented)
   i = width * height;

   while(i)
      {
      i--;
      dstdata[i] = (unsigned char)histogram[srcdata[i]];
      }


   // Now check the colour key data if we have it, and assign all matching
   // entries to palette 0.
   // Would it be better to get rid of all this colour key stuff, and simply
   // treat images with colour key as 1555, putting the alpha in the palette?
   if(has_key)
      {
      // Only nonalpha source formats have colour key
      switch(srcformat)
         {
         case  XRGB_8888:
            {
            unsigned long int *data = (unsigned long int *) orig_data;

            i = width*height;

            while(i)
               {
               i--;
               if(data[i] == keyval)
                  dstdata[i] = 0;
               }

            }
            break;
         case  RGB_888:
            {
            int   j,k;
            unsigned char *data = (unsigned char *) orig_data;
            unsigned long  r,g,b;
            unsigned long item;
            i = width*height*3;
            j=0;
            k=0;
            while(j<i)
               {
               r = data[j++];
               g = data[j++];
               b = data[j++];
               item = (r << 16) | (g << 8) | b;
               if(item == keyval)
                  dstdata[k] = 0;
               k++;
               }
            }
            break;
         case  RGB_565:
            {
            unsigned short *data = (unsigned short *) orig_data;
            i = width*height;
            while(i)
               {
               i--;
               if(data[i] == keyval)
                  dstdata[i] = 0;
               }
            }
            break;
         default:
            return 0;
         }
      }

   return 1;
}








//
// Function to search the palette for the correct index for a
// given colour, and assign it into the lookup table
//
// Once we have done the search once, mark that entry in the histogram
// as located so we don't ever search for the same item again
//
//
//

int   IndexSearch(unsigned short colour,
                  unsigned short *palette,
                  int            pal_format,
                  int            has_colourkey,
                  int            nindices)
{
   int   i,best;
   long  a,r,g,b;
   long  ad,rd,gd,bd,dist,mindist;

   best = 0;
   mindist = 500000;

   // Must go through palette and find nearest match
   if(pal_format == ARGB_4444)
      {
      a = ACOMP4444(colour);
      r = RCOMP4444(colour);
      g = GCOMP4444(colour);
      b = BCOMP4444(colour);

      for(i=0;i<nindices;i++)
         {
         // Get distance
         ad = abs(a - ACOMP4444(palette[i]));
         rd = abs(r - RCOMP4444(palette[i]));
         gd = abs(g - GCOMP4444(palette[i]));
         bd = abs(b - BCOMP4444(palette[i]));

         // Add alpha onto distance twice because it's vital that we correctly match alpha
         // between levels
         dist = ad+ad+rd+gd+bd;

         if(dist >= mindist)
            continue;
         if(dist == 0)
            {
            best = i;
            break;
            }
         mindist = dist;
         best = i;
         }
      }
   else if(pal_format == ARGB_1555)
      {
      a = ACOMP1555(colour);
      r = RCOMP1555(colour);
      g = GCOMP1555(colour);
      b = BCOMP1555(colour);

      for(i=0;i<nindices;i++)
         {
         // Get distance
         ad = abs(a - ACOMP1555(palette[i]));
         // Don't match colours with incorrect alpha
         if(ad)
            continue;

         rd = abs(r - RCOMP1555(palette[i]));
         gd = abs(g - GCOMP1555(palette[i]));
         bd = abs(b - BCOMP1555(palette[i]));

         dist = rd+gd+bd;

         if(dist >= mindist)
            continue;
         if(dist == 0)
            {
            best = i;
            break;
            }
         mindist = dist;
         best = i;
         }
      }
   else        // 565
      {
      r = RCOMP565(colour);
      g = GCOMP565(colour);
      b = BCOMP565(colour);
      if(has_colourkey)
         i=1;
      else
         i=0;
      for(;i<nindices;i++)
         {
         // Get distance
         rd = abs(r - RCOMP565(palette[i]));
         gd = abs(g - GCOMP565(palette[i]));
         bd = abs(b - BCOMP565(palette[i]));
         dist = rd+gd+bd;
         if(dist >= mindist)
            continue;
         if(dist == 0)
            {
            best = i;
            break;
            }
         mindist = dist;
         best = i;
         }
      }

   in_pal[colour] = 1;
   histogram[colour] = best;

   return 1;
}





//
// Recursively generate all mipmap levels from the source data
//
// Working from the palettised version of the higher map level will
// introduce artifacts(slight), but cuts down on storage requirements
//
//
//
//

int   GenerateMipmap(unsigned char    *srcdata,
                     unsigned char    *dstdata,
                     unsigned short   *palette,
                     int              pal_format,
                     int              width,
                     int              height,
                     int              has_colourkey,
                     int              nboxes,
                     int              maxboxes)
{
   unsigned short    texel_colour;
   unsigned char     *in,*out;
   unsigned short    c1,c2,c3,c4;
   unsigned long     a,r,g,b;
   int   x,y;

   in = srcdata;
   out = dstdata;

   if(width < 2)
      return(nboxes);
   if(height < 2)
      return(nboxes);

   // Create next mipmap level
   if(pal_format == ARGB_4444)
      {
      for(y=0;y<height;y+=2)
         {
         in  = &(srcdata[y*width]);
         out = &(dstdata[(y>>1)*(width>>1)]);

         for(x=0;x<width;x+=2)
            {
            c1 = palette[in[x]];
            c2 = palette[in[x+1]];
            c3 = palette[in[x+width]];
            c4 = palette[in[x+width+1]];

            a = ACOMP4444(c1) + ACOMP4444(c2) + ACOMP4444(c3) + ACOMP4444(c4);
            r = RCOMP4444(c1) + RCOMP4444(c2) + RCOMP4444(c3) + RCOMP4444(c4);
            g = GCOMP4444(c1) + GCOMP4444(c2) + GCOMP4444(c3) + GCOMP4444(c4);
            b = BCOMP4444(c1) + BCOMP4444(c2) + BCOMP4444(c3) + BCOMP4444(c4);

            a = a >> 2;
            r = r >> 2;
            g = g >> 2;
            b = b >> 2;

            texel_colour = (unsigned short)(((a & 0xf0) << 8) | ((r & 0xf0) << 4) | (g & 0xf0) | ((b & 0xf0) >> 4));

            // Check if the generated colour is in the palette, if not we must
            // search for it.
            if(!in_pal[texel_colour])
               {
#ifdef ALPHA_OPTIMISE
               if(texel_colour & 0xf000)
                  {
                  // If we have space left in our palette, then add this entry to the palette
                  // table so we can represent it exactly
                  if(nboxes < maxboxes)
                     {
                     palette[nboxes] = texel_colour;
                     in_pal[texel_colour] = 1;
                     histogram[texel_colour] = nboxes;
                     nboxes++;
                     }
                  else
                     {
                     IndexSearch(texel_colour,palette,pal_format,has_colourkey,nboxes);
                     out[x>>1] = (unsigned char)histogram[texel_colour];
                     }
                  }
               else
                  out[x>>1] = (unsigned char)histogram[0];
#else
               // If we have space left in our palette, then add this entry to the palette
               // table so we can represent it exactly
               if(nboxes < maxboxes)
                  {
                  palette[nboxes] = texel_colour;
                  in_pal[texel_colour] = 1;
                  histogram[texel_colour] = nboxes;
                  nboxes++;
                  }
               else
                  {
                  IndexSearch(texel_colour,palette,pal_format,has_colourkey,nboxes);
                  out[x>>1] = (unsigned char)histogram[texel_colour];
                  }
#endif
               }
            else
               out[x>>1] = (unsigned char)histogram[texel_colour];
            }
         }
      }
   else if(pal_format == ARGB_1555)
      {
      for(y=0;y<height;y+=2)
         {
         in  = &(srcdata[y*width]);
         out = &(dstdata[(y>>1)*(width>>1)]);

         for(x=0;x<width;x+=2)
            {
            c1 = palette[in[x]];
            c2 = palette[in[x+1]];
            c3 = palette[in[x+width]];
            c4 = palette[in[x+width+1]];

            a = ACOMP1555(c1) + ACOMP1555(c2) + ACOMP1555(c3) + ACOMP1555(c4);
            r = RCOMP1555(c1) + RCOMP1555(c2) + RCOMP1555(c3) + RCOMP1555(c4);
            g = GCOMP1555(c1) + GCOMP1555(c2) + GCOMP1555(c3) + GCOMP1555(c4);
            b = BCOMP1555(c1) + BCOMP1555(c2) + BCOMP1555(c3) + BCOMP1555(c4);

            a = a >> 2;
            r = r >> 2;
            g = g >> 2;
            b = b >> 2;

            // If more than 50% transparent then make it transparent
            if(a > 0x80)
               texel_colour = (unsigned short)(0x8000 | ((r & 0xf8) << 7) | ((g & 0xf8) << 2) | ((b & 0xf8) >> 3));
            else
               texel_colour = (unsigned short)(((r & 0xf8) << 7) | ((g & 0xf8) << 2) | ((b & 0xf8) >> 3));

            // Check if the generated colour is in the palette, if not we must
            // search for it.
            if(!in_pal[texel_colour])
               {
#ifdef ALPHA_OPTIMISE
               if(texel_colour & 0x8000)
                  {
                  // If we have space left in our palette, then add this entry to the palette
                  // table so we can represent it exactly
                  if(nboxes < maxboxes)
                     {
                     palette[nboxes] = texel_colour;
                     in_pal[texel_colour] = 1;
                     histogram[texel_colour] = nboxes;
                     nboxes++;
                     }
                  else
                     {
                     IndexSearch(texel_colour,palette,pal_format,has_colourkey,nboxes);
                     out[x>>1] = (unsigned char)histogram[texel_colour];
                     }
                  }
               else
                  out[x>>1] = (unsigned char)histogram[0];
#else
               // If we have space left in our palette, then add this entry to the palette
               // table so we can represent it exactly
               if(nboxes < maxboxes)
                  {
                  palette[nboxes] = texel_colour;
                  in_pal[texel_colour] = 1;
                  histogram[texel_colour] = nboxes;
                  nboxes++;
                  }
               else
                  {
                  IndexSearch(texel_colour,palette,pal_format,has_colourkey,nboxes);
                  out[x>>1] = (unsigned char)histogram[texel_colour];
                  }
#endif
               }
            else
               out[x>>1] = (unsigned char)histogram[texel_colour];
            }
         }
      }
   else     // RGB565
      {
      for(y=0;y<height;y+=2)
         {
         in  = &(srcdata[y*width]);
         out = &(dstdata[(y>>1) * (width>>1)]);

         for(x=0;x<width;x+=2)
            {
            if(has_colourkey)
               {
               int   cktest = 0;
               cktest += in[x] ? 0 : 1;
               c1 = palette[in[x]];
               cktest += in[x+1] ? 0 : 1;
               c2 = palette[in[x+1]];
               cktest += in[x+width] ? 0 : 1;
               c3 = palette[in[x+width]];
               cktest += in[x+width+1] ? 0 : 1;
               c4 = palette[in[x+width+1]];

               // If more than half the texels in the block are colourkeyed,
               // then colourkey the block
               if(cktest > 2)
                  {
                  out[x>>1] = 0;
                  continue;
                  }
               }
            else
               {
               c1 = palette[in[x]];
               c2 = palette[in[x+1]];
               c3 = palette[in[x+width]];
               c4 = palette[in[x+width+1]];
               }

            r = RCOMP565(c1) + RCOMP565(c2) + RCOMP565(c3) + RCOMP565(c4);
            g = GCOMP565(c1) + GCOMP565(c2) + GCOMP565(c3) + GCOMP565(c4);
            b = BCOMP565(c1) + BCOMP565(c2) + BCOMP565(c3) + BCOMP565(c4);

            r = r >> 2;
            g = g >> 2;
            b = b >> 2;

            texel_colour = (unsigned short)(((r & 0xf8) << 8) | ((g & 0xfc) << 3) | ((b & 0xf8) >> 3));

            // Check if the generated colour is in the palette, if not we must
            // search for it, (or generate it if we have the space...)
            if(!in_pal[texel_colour])
               {
               // If we have space left in our palette, then add this entry to the palette
               // table so we can represent it exactly
               if(nboxes < maxboxes)
                  {
                  palette[nboxes] = texel_colour;
                  in_pal[texel_colour] = 1;
                  histogram[texel_colour] = nboxes;
                  nboxes++;
                  }
               else
                  {
                  IndexSearch(texel_colour,palette,pal_format,has_colourkey,nboxes);
                  out[x>>1] = (unsigned char)histogram[texel_colour];
                  }
               }
            else
               out[x>>1] = (unsigned char)histogram[texel_colour];
            }
         }
      }


   // Recursively generate next mipmap level
   nboxes = GenerateMipmap(srcdata + (width*height),
                           dstdata + ((width>>1)*(height>>1)),
                           palette,
                           pal_format,
                           width>>1,
                           height>>1,
                           has_colourkey,
                           nboxes,
                           maxboxes);

   return(nboxes);
}










//
// Map a paletted image to a given palette
//
// Colour formats for the two palettes must currently be the same
// the palettes can have differing numbers of entries
// 
//
//

void   MapImageToGenericPalette(char *srcdata,
                                int  width,
                                int  height,
                                unsigned short *srcpal,
                                int  nentries_src,
                                unsigned short *dstpal,
                                int  nentries_dst,
                                int  pal_format)
{
   int   i,j;
   // Translation table between the two palettes
   unsigned char trans_table[256];
   long  adiff,rdiff,gdiff,bdiff,diff,mindiff,best;
   long  as,rs,gs,bs;

   // Construct the translation table
   switch(pal_format)
      {
      case  RGB_565:
         // For each entry in source palette...
         for(i=0;i<nentries_src;i++)
            {
            rs = RCOMP565(srcpal[i]);
            gs = GCOMP565(srcpal[i]);
            bs = BCOMP565(srcpal[i]);

            // Set min difference to be very high
            mindiff = 100000;
            best = 0;

            // Scan through destination palette for smallest colour difference
            // (should be weighted really)
            for(j=0;j<nentries_dst;j++)
               {
               rdiff = abs(rs - RCOMP565(dstpal[j]));
               gdiff = abs(gs - GCOMP565(dstpal[j]));
               bdiff = abs(bs - BCOMP565(dstpal[j]));
               diff = rdiff + gdiff + bdiff;

               // Early exit for exact match
               if(!diff)
                  {
                  best = j;
                  break;
                  }
               else if(diff < mindiff)
                  {
                  best = j;
                  mindiff = diff;
                  }
               }

            // Set translation table to this entry
            trans_table[i] = (unsigned char)best;
            }
         break;
      case  ARGB_1555:
         for(i=0;i<nentries_src;i++)
            {
            as = ACOMP1555(srcpal[i]);
            rs = RCOMP1555(srcpal[i]);
            gs = GCOMP1555(srcpal[i]);
            bs = BCOMP1555(srcpal[i]);

            // Set min difference to be very high
            mindiff = 100000;
            best = 0;

            // Scan through destination palette for smallest colour difference
            // (should be weighted really)
            for(j=0;j<nentries_dst;j++)
               {
               // Don't match entries with different alpha values
               if(as != ACOMP1555(dstpal[j]))
                  continue;

               rdiff = abs(rs - RCOMP1555(dstpal[j]));
               gdiff = abs(gs - GCOMP1555(dstpal[j]));
               bdiff = abs(bs - BCOMP1555(dstpal[j]));

               diff = rdiff + gdiff + bdiff;

               // Early exit for exact match
               if(!diff)
                  {
                  best = j;
                  break;
                  }
               else if(diff < mindiff)
                  {
                  best = j;
                  mindiff = diff;
                  }
               }

            // Set translation table to this entry
            trans_table[i] = (unsigned char)best;
            }
         break;
      case  ARGB_4444:
         for(i=0;i<nentries_src;i++)
            {
            as = ACOMP4444(srcpal[i]);
            rs = RCOMP4444(srcpal[i]);
            gs = GCOMP4444(srcpal[i]);
            bs = BCOMP4444(srcpal[i]);

            // Set min difference to be very high
            mindiff = 100000;
            best = 0;

            // Scan through destination palette for smallest colour difference
            // (should be weighted really)
            for(j=0;j<nentries_dst;j++)
               {
               // Weight alpha matching very highly
               adiff = 2 * abs(as - ACOMP4444(dstpal[j]));
               rdiff = abs(rs - RCOMP4444(dstpal[j]));
               gdiff = abs(gs - GCOMP4444(dstpal[j]));
               bdiff = abs(bs - BCOMP4444(dstpal[j]));

               diff = adiff + rdiff + gdiff + bdiff;

               // Early exit for exact match
               if(!diff)
                  {
                  best = j;
                  break;
                  }
               else if(diff < mindiff)
                  {
                  best = j;
                  mindiff = diff;
                  }
               }

            // Set translation table to this entry
            trans_table[i] = (unsigned char)best;
            }
         break;
      }

   // OK, we have the translation table, go through the source image, and translate 
   // its entries into the destination palette
   i = width * height;
   while(i--)
      srcdata[i] = trans_table[srcdata[i]];
}






//
// Heckbert quantiser
//
//
// Parameters
// Pointer to source data
// Pointer to preallocated 8 bit destination
// Pointer to preallocated palette 
// Format of source data (must be one of formats defined above)
// Number of desired colours in final image (normally 256)
// Width of source image in pixels
// Height of source image in pixels
// Flag indicating whether the data should be colour keyed. Colour key is only valid for
// non-alpha source data. Colour key will be ignored for alpha source data
// Colour key value (should be specified in the same format as the source data)
// 
// Returns : number of palette entries in the final image
//

int   HeckbertQuantize(void            *srcdata, 
                       unsigned char   *dstdata,
                       unsigned short  *paldata,
                       int             srcformat,
                       int             nentries,
                       int             width,
                       int             height,
                       int             has_colourkey,
                       unsigned long   keyval,
                       int             generate_mipmaps)
{
  
   int   hist_format;
   int   nboxes = 1;
   int   la,lr,lg,lb;
   int   split, max;
   box   *b;
   unsigned short *quantise_data;

   alpha_data = false;

   // Clear the box data
   appMemset(boxlist,0,256*sizeof(box));

   // Clear the histogram
   appMemset(histogram, 0, 65536 * sizeof(unsigned long));
   colour_count = 0;

   // If we will need to mipmap, clear the colour mapping data
   if(generate_mipmaps)
      appMemset(in_pal, 0, 65536 * sizeof(unsigned long));


   // Compile histogram in appropriate format
   switch(srcformat)
      {
      case  ARGB_8888:
         quantise_data = Histogram8888((unsigned long*) srcdata,width,height);
         alpha_data = true;
         hist_format = ARGB_4444;
         amul = rmul = gmul = bmul = 15;
         // Set shifts to index the histogram
         ashift = 12;
         rshift = 8;
         gshift = 4;
         bshift = 0;
         break;
      case  XRGB_8888:
         quantise_data = HistogramX888((unsigned long*) srcdata,width,height);
         hist_format = RGB_565;
         amul = 0;
         rmul = 31;
         gmul = 63;
         bmul = 31;
         // Set shifts to index the histogram
         ashift = 0;
         rshift = 11;
         gshift = 5;
         bshift = 0;
         break;
      case  RGB_888:
         quantise_data = Histogram888((unsigned char*) srcdata,width,height);
         hist_format = RGB_565;
         amul = 0;
         rmul = 31;
         gmul = 63;
         bmul = 31;
         // Set shifts to index the histogram
         ashift = 0;
         rshift = 11;
         gshift = 5;
         bshift = 0;
         break;
      case  ARGB_1555:
         alpha_data = true;
         quantise_data = Histogram16Bit((unsigned short*) srcdata,width,height,srcformat);
         hist_format = ARGB_1555;
         amul = 1;
         rmul = 31;
         gmul = 31;
         bmul = 31;
         // Set shifts to index the histogram
         ashift = 15;
         rshift = 10;
         gshift = 5;
         bshift = 0;
         break;
      case  ARGB_4444:
         alpha_data = true;
         quantise_data = Histogram16Bit((unsigned short*) srcdata,width,height,srcformat);
         hist_format = ARGB_4444;
         amul = rmul = gmul = bmul = 15;
         // Set shifts to index the histogram
         ashift = 12;
         rshift = 8;
         gshift = 4;
         bshift = 0;
         break;
      case  RGB_565:
         quantise_data = Histogram16Bit((unsigned short*) srcdata,width,height,srcformat);
         hist_format = RGB_565;
         amul = 0;
         rmul = 31;
         gmul = 63;
         bmul = 31;
         // Set shifts to index the histogram
         ashift = 0;
         rshift = 11;
         gshift = 5;
         bshift = 0;
         break;
      default:
         return 0;
      }

   // Try to optimise the colour weights
//   OptimiseColourWeightings(quantise_data,hist_format,width,height);

   // Initialise box at the head of the list to encompass the complete histogram
   boxlist[0].amin = 0;
   boxlist[0].amax = amul;
   boxlist[0].rmin = 0;
   boxlist[0].rmax = rmul;
   boxlist[0].gmin = 0;
   boxlist[0].gmax = gmul;
   boxlist[0].bmin = 0;
   boxlist[0].bmax = bmul;
   boxlist[0].colour_count = colour_count;

   if(alpha_data)
      {
      has_colourkey = false;
      boxlist[0].volume = (amul * ascale) * (rmul * rscale) * (gmul * gscale) * (bmul * bscale);
      }
   else
      boxlist[0].volume = (rmul * rscale) * (gmul * gscale) * (bmul * bscale);

   // If we have a colourkey then we must make sure we retain at least one colour in
   // the palette for the colour keyed texels, so reduce the number of entries that
   // we quantise to by one.
   if(has_colourkey)
      {
      if(nentries > 1)
         nentries -= 1;
      else
         return(0);
      }

   // Update initially
   if(alpha_data)
      UpdateBoxInfoWithAlpha(boxlist);
   else
      UpdateBoxInfo(boxlist);
 
   // Shrink the box so that it only encompasses the actual area

   // Now perform box splitting operation - first we split based on population, 
   // Then, when we have 1/2 our desired number of boxes we split based on volume
   // We continue until we have as many boxes as desired palette entries
   // When splitting a box we use a median cut approach, and split down the
   // middle of the longest (weighted) axis.
   // Splitting on population and then on volume is important - The first guarantees
   // that we represent sufficient colour detail in our palette, the second guarantees
   // that we do not make particularly bad approximations of colours in the colour space.

   while(nboxes < nentries)
      {
      if(nboxes < (nentries/2))
         b = FindMostPopulatedBox(boxlist,nboxes);
      else
         b = FindBoxWithLargestVolume(boxlist,nboxes);

      // Each box is split based on its longest scaled axis
      // Ties are split to favour, in order,  A,G,R,B

      if(!b)
         // we've run out of boxes that we can split, so just quit now...
         break;

      boxlist[nboxes] = *b;

      // Choose the axis to split the box
      lr = (b->rmax - b->rmin) * rscale;
      lg = (b->gmax - b->gmin) * gscale;
      lb = (b->bmax - b->bmin) * bscale;

      // Default to split in a axis (probably the longest)
      if(alpha_data)
         {
         la = (b->amax - b->amin) * ascale;
         split = 0;
         max = la;
         if(lg > max)
            {
            max = lg;
            split = 2;
            }
         }
      else
         {
         split = 2;
         max = lg;
         }
      if(lr > max)
         {
         max = lr;
         split = 1;
         }
      if(lb > max)
         {
         max = lb;
         split = 3;
         }

      // Now we split the box along the selected axis.
      // We will split at the halfway point along the axis
      switch(split)
         {
         case  0:
            split = (b->amax + b->amin) >> 1;
            b->amax = split;
            boxlist[nboxes].amin = split + 1;
            break;
         case  1:
            split = (b->rmax + b->rmin) >> 1;
            b->rmax = split;
            boxlist[nboxes].rmin = split + 1;
            break;
         case  2:
            split = (b->gmax + b->gmin) >> 1;
            b->gmax = split;
            boxlist[nboxes].gmin = split + 1;
            break;
         case  3:
            split = (b->bmax + b->bmin) >> 1;
            b->bmax = split;
            boxlist[nboxes].bmin = split + 1;
            break;
         }

      // Update the data for the boxes
      if(alpha_data)
         {
         UpdateBoxInfoWithAlpha(b);
         UpdateBoxInfoWithAlpha(&boxlist[nboxes]);
         }
      else
         {
         UpdateBoxInfo(b);
         UpdateBoxInfo(&boxlist[nboxes]);
         }
      nboxes++;
      }

   // If we have reserved colour 0 for colour key then we obviously have
   // one more box than the number we actually calculated
   if(has_colourkey)
      nboxes++;

   if(alpha_data)
      ComputeAlphaPalette(paldata,nentries,nboxes);
   else
      ComputePalette(paldata,nentries,nboxes,has_colourkey);

   // Now create the paletted version of the texture
   CopyPalettisedData(srcdata,
                      quantise_data,
                      dstdata,
                      srcformat,
                      width,
                      height,
                      has_colourkey,
                      keyval);

   if(generate_mipmaps)
      nboxes = GenerateMipmap(dstdata, dstdata+(width*height),
                              paldata,hist_format,width,
                              height,has_colourkey,nboxes,nentries);


   appFree(quantise_data);

   // Return the total colour count in the optimised palette
   return(nboxes);
}
