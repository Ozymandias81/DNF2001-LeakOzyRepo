/*ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 19:12 on 11-03-1999 -ƒƒ

                     The 32 bit MPEG Audio-Decoder C source

                €€€ﬂﬂ€€€ €€€ﬂ€€€ €€€    €€€ﬂ€€€ €€€  €€€ €€€ €€€
                €€€  ﬂﬂﬂ €€€ €€€ €€€    €€€ €€€  ﬂ€€€€ﬂ  €€€ €€€
                €€€ ‹‹‹‹ €€€‹€€€ €€€    €€€‹€€€    €€     ﬂ€€€ﬂ
                €€€  €€€ €€€ €€€ €€€    €€€ €€€  ‹€€€€‹    €€€
                €€€‹‹€€€ €€€ €€€ €€€‹‹‹ €€€ €€€ €€€  €€€   €€€

                               .. MUSIC SYSTEM ..
                This document contains confidential information
                     Copyright (c) 1993-99 Carlo Vogelsang

  ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
  ≥€≤± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤€≥
  √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
  ≥ This source file, GLX-MPA.C is Copyright  (c) 1993-99 by Carlo Vogelsang. ≥
  ≥ You may not copy, distribute,  duplicate or clone this file  in any form, ≥
  ≥ modified or non-modified. It belongs to the author.  By copying this file ≥
  ≥ you are violating laws and will be punished. I will knock your brains in  ≥
  ≥ myself or you will be sued to death..                                     ≥
  ≥                                                                     Carlo ≥
  ¿ƒ( How the fuck did you get this file anyway? )ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <math.h>
#include <windows.h>

#include "hdr\galaxy.h"							// Galaxy header
#include "hdr\loaders.h"						// Loaders header

#include "hufftab.h"	
#include "hufftab2.h"

#define PI		  4.0*atan(1.0)					// Definition of Pi
#define COSPI3    0.500000000f					// Cos(Pi/3)
#define COSPI6    0.866025403f					// Cos(Pi/6)
#define DCTODD1   0.984807753f					
#define DCTODD2  -0.342020143f
#define DCTODD3  -0.642787609f
#define DCTEVEN1  0.939692620f
#define DCTEVEN2 -0.173648177f
#define DCTEVEN3 -0.766044443f

typedef struct
{
	unsigned char *Data;						// Pointer to actual data
	long Size;									// Data size in bits
	long ReadPos;								// ReadPos in bits
	long WritePos;								// WritePos in bits
} BitStream;									// Bitstream Header

typedef struct									 
{
	int syncword;								// 11 bit syncword
	int VLSF;									//  1 bit VLSF
	int ID;										//  1 bit ID
	int layer;									//  2 bit layer
	int protection_bit;							//  1 bit protection
	int bitrate_index;							//  4 bit bitrate
	int sampling_frequency;						//  2 bit sampling freq.
	int padding_bit;							//  1 bit padding
	int private_bit;							//  1 bit reserved
	int mode;									//  2 bit mono/stereo
	int mode_extension;							//  2 bit js/ms
	int copyright;								//  1 bit copyright
	int original;								//  1 bit original
	int emphasis;								//  1 bit emphasis
	//additional infomation
	int crc_check;								// 16 bit CRC
	int allocation[2][32];						//  4 bit bit alloc.
	int scfsi[2][32];							//  2 bit sf selection
	int scalefactor[2][32][3];					//  6 bit scalefactors
	union
	{
		long sample[2][32][36];					// 16 bit subbandsamples
		long is[2][2][578];						// 16 bit spectrum
	}   maindata;  
	//
	float overlap[2][32][18];					// MDCT Reconstruction vector
	float subbandsamples[2][32][36];			// ?? bit subbandsamples
	float V[2][2][272];							// IDCT Reconstruction vector
	short pcmsamples[2][1152];					// 16 bit PCM samples
	//decoder variables
	int vshift[2];								// Offset in IDCT vector
	int Samples;								// Samples left
	int	Index;									// Current sample
	//layer 3 internal stream
	char main_buffer[2048];						// Internal stream buffer
	BitStream main_data;						// Stream structure
} MPEGAudioStream; 								// MPEG Audio header

static const long sampling_frequency[3][4]={	
	{22050,24000,16000,22050},					// MPEG 2 LSF	
	{44100,48000,32000,44100},					// MPEG 1
	{11025,12000,8000,11025},					// MPEG 2.5 VLSF
};	

static const long bitrate[3][4][16]={
	{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},			// MPEG 2 LSF
	{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0},
	{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0},
	{0,32,48,56,64,80,96,112,128,144,160,176,192,224,256,0}},
	{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},			// MPEG 1
	{0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0},
	{0,32,48,56,64,80,96,112,128,160,192,224,256,320,384,0},
	{0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,0}},
	{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},			// MPEG 2.5 VLSF
	{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0},
	{0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0},
	{0,32,48,56,64,80,96,112,128,144,160,176,192,224,256,0}}
};
/*
static const float D[512]={
 0.000000000,-0.000015259,-0.000015259,-0.000015259,
-0.000015259,-0.000015259,-0.000015259,-0.000030518,
-0.000030518,-0.000030518,-0.000030518,-0.000045776,
-0.000045776,-0.000061035,-0.000061035,-0.000076294,
-0.000076294,-0.000091553,-0.000106812,-0.000106812,
-0.000122070,-0.000137329,-0.000152588,-0.000167847,
-0.000198364,-0.000213623,-0.000244141,-0.000259399,
-0.000289917,-0.000320435,-0.000366211,-0.000396729,
-0.000442505,-0.000473022,-0.000534058,-0.000579834,
-0.000625610,-0.000686646,-0.000747681,-0.000808716,
-0.000885010,-0.000961304,-0.001037598,-0.001113892,
-0.001205444,-0.001296997,-0.001388550,-0.001480103,
-0.001586914,-0.001693726,-0.001785278,-0.001907349,
-0.002014160,-0.002120972,-0.002243042,-0.002349854,
-0.002456665,-0.002578735,-0.002685547,-0.002792358,
-0.002899170,-0.002990723,-0.003082275,-0.003173828,
 0.003250122, 0.003326416, 0.003387451, 0.003433228,
 0.003463745, 0.003479004, 0.003479004, 0.003463745,
 0.003417969, 0.003372192, 0.003280640, 0.003173828,
 0.003051758, 0.002883911, 0.002700806, 0.002487183,
 0.002227783, 0.001937866, 0.001617432, 0.001266479,
 0.000869751, 0.000442505,-0.000030518,-0.000549316,
-0.001098633,-0.001693726,-0.002334595,-0.003005981,
-0.003723145,-0.004486084,-0.005294800,-0.006118774,
-0.007003784,-0.007919312,-0.008865356,-0.009841919,
-0.010848999,-0.011886597,-0.012939453,-0.014022827,
-0.015121460,-0.016235352,-0.017349243,-0.018463135,
-0.019577026,-0.020690918,-0.021789551,-0.022857666,
-0.023910522,-0.024932861,-0.025909424,-0.026840210,
-0.027725220,-0.028533936,-0.029281616,-0.029937744,
-0.030532837,-0.031005859,-0.031387329,-0.031661987,
-0.031814575,-0.031845093,-0.031738281,-0.031478882,
 0.031082153, 0.030517578, 0.029785156, 0.028884888,
 0.027801514, 0.026535034, 0.025085449, 0.023422241,
 0.021575928, 0.019531250, 0.017257690, 0.014801025,
 0.012115479, 0.009231567, 0.006134033, 0.002822876,
-0.000686646,-0.004394531,-0.008316040,-0.012420654,
-0.016708374,-0.021179199,-0.025817871,-0.030609131,
-0.035552979,-0.040634155,-0.045837402,-0.051132202,
-0.056533813,-0.061996460,-0.067520142,-0.073059082,
-0.078628540,-0.084182739,-0.089706421,-0.095169067,
-0.100540161,-0.105819702,-0.110946655,-0.115921021,
-0.120697021,-0.125259399,-0.129562378,-0.133590698,
-0.137298584,-0.140670776,-0.143676758,-0.146255493,
-0.148422241,-0.150115967,-0.151306152,-0.151962280,
-0.152069092,-0.151596069,-0.150497437,-0.148773193,
-0.146362305,-0.143264771,-0.139450073,-0.134887695,
-0.129577637,-0.123474121,-0.116577148,-0.108856201,
 0.100311279, 0.090927124, 0.080688477, 0.069595337,
 0.057617187, 0.044784546, 0.031082153, 0.016510010,
 0.001068115,-0.015228271,-0.032379150,-0.050354004,
-0.069168091,-0.088775635,-0.109161377,-0.130310059,
-0.152206421,-0.174789429,-0.198059082,-0.221984863,
-0.246505737,-0.271591187,-0.297210693,-0.323318481,
-0.349868774,-0.376800537,-0.404083252,-0.431655884,
-0.459472656,-0.487472534,-0.515609741,-0.543823242,
-0.572036743,-0.600219727,-0.628295898,-0.656219482,
-0.683914185,-0.711318970,-0.738372803,-0.765029907,
-0.791213989,-0.816864014,-0.841949463,-0.866363525,
-0.890090942,-0.913055420,-0.935195923,-0.956481934,
-0.976852417,-0.996246338,-1.014617920,-1.031936646,
-1.048156738,-1.063217163,-1.077117920,-1.089782715,
-1.101211548,-1.111373901,-1.120223999,-1.127746582,
-1.133926392,-1.138763428,-1.142211914,-1.144287109,
 1.144989014, 1.144287109, 1.142211914, 1.138763428,
 1.133926392, 1.127746582, 1.120223999, 1.111373901,
 1.101211548, 1.089782715, 1.077117920, 1.063217163,
 1.048156738, 1.031936646, 1.014617920, 0.996246338,
 0.976852417, 0.956481934, 0.935195923, 0.913055420,
 0.890090942, 0.866363525, 0.841949463, 0.816864014,
 0.791213989, 0.765029907, 0.738372803, 0.711318970,
 0.683914185, 0.656219482, 0.628295898, 0.600219727,
 0.572036743, 0.543823242, 0.515609741, 0.487472534,
 0.459472656, 0.431655884, 0.404083252, 0.376800537,
 0.349868774, 0.323318481, 0.297210693, 0.271591187,
 0.246505737, 0.221984863, 0.198059082, 0.174789429,
 0.152206421, 0.130310059, 0.109161377, 0.088775635,
 0.069168091, 0.050354004, 0.032379150, 0.015228271,
-0.001068115,-0.016510010,-0.031082153,-0.044784546,
-0.057617187,-0.069595337,-0.080688477,-0.090927124,
 0.100311279, 0.108856201, 0.116577148, 0.123474121,
 0.129577637, 0.134887695, 0.139450073, 0.143264771,
 0.146362305, 0.148773193, 0.150497437, 0.151596069,
 0.152069092, 0.151962280, 0.151306152, 0.150115967,
 0.148422241, 0.146255493, 0.143676758, 0.140670776,
 0.137298584, 0.133590698, 0.129562378, 0.125259399,
 0.120697021, 0.115921021, 0.110946655, 0.105819702,
 0.100540161, 0.095169067, 0.089706421, 0.084182739,
 0.078628540, 0.073059082, 0.067520142, 0.061996460,
 0.056533813, 0.051132202, 0.045837402, 0.040634155,
 0.035552979, 0.030609131, 0.025817871, 0.021179199,
 0.016708374, 0.012420654, 0.008316040, 0.004394531,
 0.000686646,-0.002822876,-0.006134033,-0.009231567,
-0.012115479,-0.014801025,-0.017257690,-0.019531250,
-0.021575928,-0.023422241,-0.025085449,-0.026535034,
-0.027801514,-0.028884888,-0.029785156,-0.030517578,
 0.031082153, 0.031478882, 0.031738281, 0.031845093,
 0.031814575, 0.031661987, 0.031387329, 0.031005859,
 0.030532837, 0.029937744, 0.029281616, 0.028533936,
 0.027725220, 0.026840210, 0.025909424, 0.024932861,
 0.023910522, 0.022857666, 0.021789551, 0.020690918,
 0.019577026, 0.018463135, 0.017349243, 0.016235352,
 0.015121460, 0.014022827, 0.012939453, 0.011886597,
 0.010848999, 0.009841919, 0.008865356, 0.007919312,
 0.007003784, 0.006118774, 0.005294800, 0.004486084,
 0.003723145, 0.003005981, 0.002334595, 0.001693726,
 0.001098633, 0.000549316, 0.000030518,-0.000442505,
-0.000869751,-0.001266479,-0.001617432,-0.001937866,
-0.002227783,-0.002487183,-0.002700806,-0.002883911,
-0.003051758,-0.003173828,-0.003280640,-0.003372192,
-0.003417969,-0.003463745,-0.003479004,-0.003479004,
-0.003463745,-0.003433228,-0.003387451,-0.003326416,
 0.003250122, 0.003173828, 0.003082275, 0.002990723,
 0.002899170, 0.002792358, 0.002685547, 0.002578735,
 0.002456665, 0.002349854, 0.002243042, 0.002120972,
 0.002014160, 0.001907349, 0.001785278, 0.001693726,
 0.001586914, 0.001480103, 0.001388550, 0.001296997,
 0.001205444, 0.001113892, 0.001037598, 0.000961304,
 0.000885010, 0.000808716, 0.000747681, 0.000686646,
 0.000625610, 0.000579834, 0.000534058, 0.000473022,
 0.000442505, 0.000396729, 0.000366211, 0.000320435,
 0.000289917, 0.000259399, 0.000244141, 0.000213623,
 0.000198364, 0.000167847, 0.000152588, 0.000137329,
 0.000122070, 0.000106812, 0.000106812, 0.000091553,
 0.000076294, 0.000076294, 0.000061035, 0.000061035,
 0.000045776, 0.000045776, 0.000030518, 0.000030518,
 0.000030518, 0.000030518, 0.000015259, 0.000015259,
 0.000015259, 0.000015259, 0.000015259, 0.000015259};
*/
static const float D[17][32]={{
 0.000000000f,-0.000442505f, 0.003250122f,-0.007003784f, 0.031082153f,-0.078628540f, 0.100311279f,-0.572036743f,
 1.144989014f, 0.572036743f, 0.100311279f, 0.078628540f, 0.031082153f, 0.007003784f, 0.003250122f, 0.000442505f,
 0.000000000f,-0.000442505f, 0.003250122f,-0.007003784f, 0.031082153f,-0.078628540f, 0.100311279f,-0.572036743f,
 1.144989014f, 0.572036743f, 0.100311279f, 0.078628540f, 0.031082153f, 0.007003784f, 0.003250122f, 0.000442505f,
},{
-0.000015259f,-0.000473022f, 0.003326416f,-0.007919312f, 0.030517578f,-0.084182739f, 0.090927124f,-0.600219727f,
 1.144287109f, 0.543823242f, 0.108856201f, 0.073059082f, 0.031478882f, 0.006118774f, 0.003173828f, 0.000396729f,
-0.000015259f,-0.000473022f, 0.003326416f,-0.007919312f, 0.030517578f,-0.084182739f, 0.090927124f,-0.600219727f,
 1.144287109f, 0.543823242f, 0.108856201f, 0.073059082f, 0.031478882f, 0.006118774f, 0.003173828f, 0.000396729f,
},{
-0.000015259f,-0.000534058f, 0.003387451f,-0.008865356f, 0.029785156f,-0.089706421f, 0.080688477f,-0.628295898f,
 1.142211914f, 0.515609741f, 0.116577148f, 0.067520142f, 0.031738281f, 0.005294800f, 0.003082275f, 0.000366211f,
-0.000015259f,-0.000534058f, 0.003387451f,-0.008865356f, 0.029785156f,-0.089706421f, 0.080688477f,-0.628295898f,
 1.142211914f, 0.515609741f, 0.116577148f, 0.067520142f, 0.031738281f, 0.005294800f, 0.003082275f, 0.000366211f,
},{
-0.000015259f,-0.000579834f, 0.003433228f,-0.009841919f, 0.028884888f,-0.095169067f, 0.069595337f,-0.656219482f,
 1.138763428f, 0.487472534f, 0.123474121f, 0.061996460f, 0.031845093f, 0.004486084f, 0.002990723f, 0.000320435f,
-0.000015259f,-0.000579834f, 0.003433228f,-0.009841919f, 0.028884888f,-0.095169067f, 0.069595337f,-0.656219482f,
 1.138763428f, 0.487472534f, 0.123474121f, 0.061996460f, 0.031845093f, 0.004486084f, 0.002990723f, 0.000320435f,
},{
-0.000015259f,-0.000625610f, 0.003463745f,-0.010848999f, 0.027801514f,-0.100540161f, 0.057617187f,-0.683914185f,
 1.133926392f, 0.459472656f, 0.129577637f, 0.056533813f, 0.031814575f, 0.003723145f, 0.002899170f, 0.000289917f,
-0.000015259f,-0.000625610f, 0.003463745f,-0.010848999f, 0.027801514f,-0.100540161f, 0.057617187f,-0.683914185f,
 1.133926392f, 0.459472656f, 0.129577637f, 0.056533813f, 0.031814575f, 0.003723145f, 0.002899170f, 0.000289917f,
},{
-0.000015259f,-0.000686646f, 0.003479004f,-0.011886597f, 0.026535034f,-0.105819702f, 0.044784546f,-0.711318970f,
 1.127746582f, 0.431655884f, 0.134887695f, 0.051132202f, 0.031661987f, 0.003005981f, 0.002792358f, 0.000259399f,
-0.000015259f,-0.000686646f, 0.003479004f,-0.011886597f, 0.026535034f,-0.105819702f, 0.044784546f,-0.711318970f,
 1.127746582f, 0.431655884f, 0.134887695f, 0.051132202f, 0.031661987f, 0.003005981f, 0.002792358f, 0.000259399f,
},{
-0.000015259f,-0.000747681f, 0.003479004f,-0.012939453f, 0.025085449f,-0.110946655f, 0.031082153f,-0.738372803f,
 1.120223999f, 0.404083252f, 0.139450073f, 0.045837402f, 0.031387329f, 0.002334595f, 0.002685547f, 0.000244141f,
-0.000015259f,-0.000747681f, 0.003479004f,-0.012939453f, 0.025085449f,-0.110946655f, 0.031082153f,-0.738372803f,
 1.120223999f, 0.404083252f, 0.139450073f, 0.045837402f, 0.031387329f, 0.002334595f, 0.002685547f, 0.000244141f,
},{
-0.000030518f,-0.000808716f, 0.003463745f,-0.014022827f, 0.023422241f,-0.115921021f, 0.016510010f,-0.765029907f,
 1.111373901f, 0.376800537f, 0.143264771f, 0.040634155f, 0.031005859f, 0.001693726f, 0.002578735f, 0.000213623f,
-0.000030518f,-0.000808716f, 0.003463745f,-0.014022827f, 0.023422241f,-0.115921021f, 0.016510010f,-0.765029907f,
 1.111373901f, 0.376800537f, 0.143264771f, 0.040634155f, 0.031005859f, 0.001693726f, 0.002578735f, 0.000213623f,
},{
-0.000030518f,-0.000885010f, 0.003417969f,-0.015121460f, 0.021575928f,-0.120697021f, 0.001068115f,-0.791213989f,
 1.101211548f, 0.349868774f, 0.146362305f, 0.035552979f, 0.030532837f, 0.001098633f, 0.002456665f, 0.000198364f,
-0.000030518f,-0.000885010f, 0.003417969f,-0.015121460f, 0.021575928f,-0.120697021f, 0.001068115f,-0.791213989f,
 1.101211548f, 0.349868774f, 0.146362305f, 0.035552979f, 0.030532837f, 0.001098633f, 0.002456665f, 0.000198364f,
},{
-0.000030518f,-0.000961304f, 0.003372192f,-0.016235352f, 0.019531250f,-0.125259399f,-0.015228271f,-0.816864014f,
 1.089782715f, 0.323318481f, 0.148773193f, 0.030609131f, 0.029937744f, 0.000549316f, 0.002349854f, 0.000167847f,
-0.000030518f,-0.000961304f, 0.003372192f,-0.016235352f, 0.019531250f,-0.125259399f,-0.015228271f,-0.816864014f,
 1.089782715f, 0.323318481f, 0.148773193f, 0.030609131f, 0.029937744f, 0.000549316f, 0.002349854f, 0.000167847f,
},{
-0.000030518f,-0.001037598f, 0.003280640f,-0.017349243f, 0.017257690f,-0.129562378f,-0.032379150f,-0.841949463f,
 1.077117920f, 0.297210693f, 0.150497437f, 0.025817871f, 0.029281616f, 0.000030518f, 0.002243042f, 0.000152588f,
-0.000030518f,-0.001037598f, 0.003280640f,-0.017349243f, 0.017257690f,-0.129562378f,-0.032379150f,-0.841949463f,
 1.077117920f, 0.297210693f, 0.150497437f, 0.025817871f, 0.029281616f, 0.000030518f, 0.002243042f, 0.000152588f,
},{
-0.000045776f,-0.001113892f, 0.003173828f,-0.018463135f, 0.014801025f,-0.133590698f,-0.050354004f,-0.866363525f,
 1.063217163f, 0.271591187f, 0.151596069f, 0.021179199f, 0.028533936f,-0.000442505f, 0.002120972f, 0.000137329f,
-0.000045776f,-0.001113892f, 0.003173828f,-0.018463135f, 0.014801025f,-0.133590698f,-0.050354004f,-0.866363525f,
 1.063217163f, 0.271591187f, 0.151596069f, 0.021179199f, 0.028533936f,-0.000442505f, 0.002120972f, 0.000137329f,
},{
-0.000045776f,-0.001205444f, 0.003051758f,-0.019577026f, 0.012115479f,-0.137298584f,-0.069168091f,-0.890090942f,
 1.048156738f, 0.246505737f, 0.152069092f, 0.016708374f, 0.027725220f,-0.000869751f, 0.002014160f, 0.000122070f,
-0.000045776f,-0.001205444f, 0.003051758f,-0.019577026f, 0.012115479f,-0.137298584f,-0.069168091f,-0.890090942f,
 1.048156738f, 0.246505737f, 0.152069092f, 0.016708374f, 0.027725220f,-0.000869751f, 0.002014160f, 0.000122070f,
},{
-0.000061035f,-0.001296997f, 0.002883911f,-0.020690918f, 0.009231567f,-0.140670776f,-0.088775635f,-0.913055420f,
 1.031936646f, 0.221984863f, 0.151962280f, 0.012420654f, 0.026840210f,-0.001266479f, 0.001907349f, 0.000106812f,
-0.000061035f,-0.001296997f, 0.002883911f,-0.020690918f, 0.009231567f,-0.140670776f,-0.088775635f,-0.913055420f,
 1.031936646f, 0.221984863f, 0.151962280f, 0.012420654f, 0.026840210f,-0.001266479f, 0.001907349f, 0.000106812f,
},{
-0.000061035f,-0.001388550f, 0.002700806f,-0.021789551f, 0.006134033f,-0.143676758f,-0.109161377f,-0.935195923f,
 1.014617920f, 0.198059082f, 0.151306152f, 0.008316040f, 0.025909424f,-0.001617432f, 0.001785278f, 0.000106812f,
-0.000061035f,-0.001388550f, 0.002700806f,-0.021789551f, 0.006134033f,-0.143676758f,-0.109161377f,-0.935195923f,
 1.014617920f, 0.198059082f, 0.151306152f, 0.008316040f, 0.025909424f,-0.001617432f, 0.001785278f, 0.000106812f,
},{
-0.000076294f,-0.001480103f, 0.002487183f,-0.022857666f, 0.002822876f,-0.146255493f,-0.130310059f,-0.956481934f,
 0.996246338f, 0.174789429f, 0.150115967f, 0.004394531f, 0.024932861f,-0.001937866f, 0.001693726f, 0.000091553f,
-0.000076294f,-0.001480103f, 0.002487183f,-0.022857666f, 0.002822876f,-0.146255493f,-0.130310059f,-0.956481934f,
 0.996246338f, 0.174789429f, 0.150115967f, 0.004394531f, 0.024932861f,-0.001937866f, 0.001693726f, 0.000091553f,
},{
-0.000076294f,-0.001586914f, 0.002227783f,-0.023910522f,-0.000686646f,-0.148422241f,-0.152206421f,-0.976852417f,
 0.976852417f, 0.152206421f, 0.148422241f, 0.000686646f, 0.023910522f,-0.002227783f, 0.001586914f, 0.000076294f,
-0.000076294f,-0.001586914f, 0.002227783f,-0.023910522f,-0.000686646f,-0.148422241f,-0.152206421f,-0.976852417f,
 0.976852417f, 0.152206421f, 0.148422241f, 0.000686646f, 0.023910522f,-0.002227783f, 0.001586914f, 0.000076294f,
}			};
static float SCALE[64];							// Scalefactors (layer 1 and 2)
static float ASCALE[392];   					// All scaling (layer 3)
static float REQUANT[8192];						// Requantizer (layer 3)

//Bitstream functions (all inline expanded)

static unsigned long __inline getbits(BitStream *Stream,int BitCount)
{
	unsigned long BitBuffer=0,Index;

	if (BitCount)
	{
		Index=(Stream->ReadPos>>3);
		BitBuffer=((Stream->Data[Index]<<24)|(Stream->Data[Index+1]<<16)|(Stream->Data[Index+2]<<8)|Stream->Data[Index+3]);
		BitBuffer<<=(Stream->ReadPos&7);
		BitBuffer>>=(32-BitCount);
		Stream->ReadPos+=BitCount;
	}
	return BitBuffer;
}

static unsigned long __inline nextbits(BitStream *Stream,int BitCount)
{
	unsigned long BitBuffer=0,Index;

	if (BitCount)
	{
		Index=(Stream->ReadPos>>3);
		BitBuffer=((Stream->Data[Index]<<24)|(Stream->Data[Index+1]<<16)|(Stream->Data[Index+2]<<8)|Stream->Data[Index+3]);
		BitBuffer<<=(Stream->ReadPos&7);
		BitBuffer>>=(32-BitCount);
	}
	return BitBuffer;
}

static int __inline bytealigned(BitStream *Stream)
{
	return (Stream->ReadPos&7?0:1);
}

static int __inline endofstream(BitStream *Stream)
{
	return (Stream->ReadPos<Stream->Size?0:1);
}

//Float to 16 bit integer conversion

static short __inline float2short(float Value)
{
	double temp;
	long i;

	temp=Value+(((65536.0*65536.0*16.0)+(65536.0*65536.0*8.0))*65536.0);
	i=(*((long *)&temp));
	if (i>32767)
		i=32767;
	else if (i<-32768)
		i=-32768;
	return ((short)i);
}

//MDCT filter function (using a Lee/WFTA DCT decomposition)

static void mdct(MPEGAudioStream *Header,float xr[2][2][576],int block_type[2][2],int mixed_block_flag[2][2],int window_switching_flag[2][2],int big_values[2][2],int count1[2][2])
{
	static float Cs[8]={ 
		0.857492925712f, 0.881741997318f, 0.949628649103f, 0.983314592492f,
		0.995517816065f, 0.999160558175f, 0.999899195243f, 0.999993155067f
	};
	static float Ca[8]={
		-0.514495755427f,-0.471731968565f,-0.313377454204f,-0.181913199611f,
		-0.094574192526f,-0.040965582885f,-0.014198568572f,-0.003699974674f
	};
	static float twiddle6[12]={
		-0.821339815f,-1.306562965f,-3.830648788f,-3.830648788f,
		-1.306562965f,-0.821339815f,-0.630236207f,-0.541196100f,
		-0.504314480f,-0.504314480f,-0.541196100f,-0.630236207f
	};
	static float twiddle18[36]={
		-0.740093616f,-0.821339815f,-0.930579498f,-1.082840285f,
		-1.306562965f,-1.662754762f,-2.310113158f,-3.830648788f,
		-11.46279281f,-11.46279281f,-3.830648788f,-2.310113158f,
		-1.662754762f,-1.306562965f,-1.082840285f,-0.930579498f,
		-0.821339815f,-0.740093616f,-0.678170852f,-0.630236207f,
		-0.592844523f,-0.563690973f,-0.541196100f,-0.524264562f,
		-0.512139757f,-0.504314480f,-0.500476342f,-0.500476342f,
		-0.504314480f,-0.512139757f,-0.524264562f,-0.541196100f,
		-0.563690973f,-0.592844523f,-0.630236207f,-0.678170852f
	};
	float t0,t1,t2,t3,t4,t5,t6,t7,pp1,pp2;
	int i,j,gr,ch,sb,nch,ngr,window_type;
	float save,sum,tmp[18],tmp2[36];
	static int initialised=0;
	static float W[4][36];
	int sblimit;
 
	nch=Header->mode==0x03?1:2;
	ngr=Header->ID?2:1;
	if (!initialised)
	{
		//Calculate windowing functions (including 6->12 MDCT & 18->36 MDCT Twiddling)
		for (i=0;i<36;i++)
			W[0][i]=(float)(32768.0*sin((i+0.5)*PI/36.0)*twiddle18[i]);
		for (i=0;i<12;i++)
			W[2][i]=(float)(32768.0*sin((i+0.5)*PI/12.0)*twiddle6[i]);
		for (i=0;i<36;i++)
		{
			if (i<18)
				W[1][i]=(float)(32768.0*sin((i+0.5)*PI/36.0)*twiddle18[i]);
			else if (i<24)
				W[1][i]=(float)(32768.0*1.0*twiddle18[i]);
			else if (i<30)
				W[1][i]=(float)(32768.0*sin((i-18+0.5)*PI/12.0)*twiddle18[i]);
			else W[1][i]=(float)(0.0);
		}
		for (i=0;i<36;i++)
		{
			if (i<6)
				W[3][i]=(float)(0.0);
			else if (i<12)
				W[3][i]=(float)(32768.0*sin((i-6+0.5)*PI/12.0)*twiddle18[i]);
			else if (i<18)
				W[3][i]=(float)(32768.0*1.0*twiddle18[i]);
			else W[3][i]=(float)(32768.0*sin((i+0.5)*PI/36.0)*twiddle18[i]);
		}
		//Mdct routine initialised
		initialised=1;
	}
	for (gr=0;gr<ngr;gr++)
	{
		for (ch=0;ch<nch;ch++)
		{
			//calculate number of non-zero subbands
			sblimit=((big_values[gr][ch]*2+count1[gr][ch]*4-1)/18)+1;
			for (sb=0;sb<sblimit;sb++)	  
			{
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2)&&((!mixed_block_flag[gr][ch])||((mixed_block_flag[gr][ch])&&(sb>1))))
				{
					memset(tmp2,0,sizeof(tmp2));
					for (i=0;i<3;i++)
					{
 						//input aliasing for 12->6 point IDCT
						xr[gr][ch][sb*18+15+i]+=xr[gr][ch][sb*18+12+i]; 
						xr[gr][ch][sb*18+12+i]+=xr[gr][ch][sb*18+ 9+i]; 
						xr[gr][ch][sb*18+ 9+i]+=xr[gr][ch][sb*18+ 6+i];
						xr[gr][ch][sb*18+ 6+i]+=xr[gr][ch][sb*18+ 3+i];  
						xr[gr][ch][sb*18+ 3+i]+=xr[gr][ch][sb*18+ 0+i];
 						//input aliasing for 6->3 point IDCT
						xr[gr][ch][sb*18+15+i]+=xr[gr][ch][sb*18+ 9+i];
						xr[gr][ch][sb*18+ 9+i]+=xr[gr][ch][sb*18+ 3+i];
						// 3 point IDCT on even indices
						pp2=xr[gr][ch][sb*18+12+i]*0.500000000f;
						pp1=xr[gr][ch][sb*18+ 6+i]*0.866025403f;
						sum=xr[gr][ch][sb*18+ 0+i]+pp2;
						tmp[1]=xr[gr][ch][sb*18+0+i]-xr[gr][ch][sb*18+12+i];
						tmp[0]=sum+pp1;
						tmp[2]=sum-pp1;
						// 3 point IDCT on odd indices 
						pp2=xr[gr][ch][sb*18+15+i]*0.500000000f;
						pp1=xr[gr][ch][sb*18+ 9+i]*0.866025403f;
						sum=xr[gr][ch][sb*18+ 3+i]+pp2;
						tmp[4]=xr[gr][ch][sb*18+3+i]-xr[gr][ch][sb*18+15+i];
						tmp[3]=sum-pp1;
						tmp[5]=sum+pp1;
						// twiddle stuff for 6 point IDCT (3 muls)
						tmp[3]*=1.931851653f;
						tmp[4]*=0.707106781f;
						tmp[5]*=0.517638090f;
						// Butterflies on 3 point IDCT's
						save=tmp[0];
						tmp[0]=save+tmp[5];
						tmp[5]=save-tmp[5];
						save=tmp[1];
						tmp[1]=save+tmp[4];
						tmp[4]=save-tmp[4];
						save=tmp[2];
						tmp[2]=save+tmp[3];
						tmp[3]=save-tmp[3];
						// output reordering for 6x6 -> 12x6 DCT (+concatenating and twiddle/windowing)
						tmp2[i*6+ 6]-=tmp[3]*W[2][ 0];
						tmp2[i*6+ 7]-=tmp[4]*W[2][ 1];
						tmp2[i*6+ 8]-=tmp[5]*W[2][ 2];
						tmp2[i*6+ 9]+=tmp[5]*W[2][ 3];
						tmp2[i*6+10]+=tmp[4]*W[2][ 4];
						tmp2[i*6+11]+=tmp[3]*W[2][ 5];
						tmp2[i*6+12]+=tmp[2]*W[2][ 6];
						tmp2[i*6+13]+=tmp[1]*W[2][ 7];
						tmp2[i*6+14]+=tmp[0]*W[2][ 8];
						tmp2[i*6+15]+=tmp[0]*W[2][ 9];
						tmp2[i*6+16]+=tmp[1]*W[2][10];
						tmp2[i*6+17]+=tmp[2]*W[2][11];
					}
					for (j=0;j<18;j++)
					{
						Header->subbandsamples[ch][sb][gr*18+j]=(tmp2[j]+Header->overlap[ch][sb][j]);
						Header->overlap[ch][sb][j]=tmp2[j+18];
					}
				}
				else
				{  
					//long block alias reduction
					if (((block_type[gr][ch]==2)&&(sb==0))||((block_type[gr][ch]!=2)&&(sb<31)))
					{
						t0=xr[gr][ch][18*sb+17];
						t1=xr[gr][ch][18*sb+18];
						xr[gr][ch][18*sb+17]=t0*Cs[0]-t1*Ca[0];
						xr[gr][ch][18*sb+18]=t1*Cs[0]+t0*Ca[0];
						t2=xr[gr][ch][18*sb+16];
						t3=xr[gr][ch][18*sb+19];
						xr[gr][ch][18*sb+16]=t2*Cs[1]-t3*Ca[1];
						xr[gr][ch][18*sb+19]=t3*Cs[1]+t2*Ca[1];
						t4=xr[gr][ch][18*sb+15];
						t5=xr[gr][ch][18*sb+20];
						xr[gr][ch][18*sb+15]=t4*Cs[2]-t5*Ca[2];
						xr[gr][ch][18*sb+20]=t5*Cs[2]+t4*Ca[2];
						t6=xr[gr][ch][18*sb+14];
						t7=xr[gr][ch][18*sb+21];
						xr[gr][ch][18*sb+14]=t6*Cs[3]-t7*Ca[3];
						xr[gr][ch][18*sb+21]=t7*Cs[3]+t6*Ca[3];
						t0=xr[gr][ch][18*sb+13];
						t1=xr[gr][ch][18*sb+22];
						xr[gr][ch][18*sb+13]=t0*Cs[4]-t1*Ca[4];
						xr[gr][ch][18*sb+22]=t1*Cs[4]+t0*Ca[4];
						t2=xr[gr][ch][18*sb+12];
						t3=xr[gr][ch][18*sb+23];
						xr[gr][ch][18*sb+12]=t2*Cs[5]-t3*Ca[5];
						xr[gr][ch][18*sb+23]=t3*Cs[5]+t2*Ca[5];
						t4=xr[gr][ch][18*sb+11];
						t5=xr[gr][ch][18*sb+24];
						xr[gr][ch][18*sb+11]=t4*Cs[6]-t5*Ca[6];
						xr[gr][ch][18*sb+24]=t5*Cs[6]+t4*Ca[6];
						t6=xr[gr][ch][18*sb+10];
						t7=xr[gr][ch][18*sb+25];
						xr[gr][ch][18*sb+10]=t6*Cs[7]-t7*Ca[7];
						xr[gr][ch][18*sb+25]=t7*Cs[7]+t6*Ca[7];
					}
					//input aliasing for 36->18 point IDCT
					xr[gr][ch][sb*18+17]+=xr[gr][ch][sb*18+16]; 
					xr[gr][ch][sb*18+16]+=xr[gr][ch][sb*18+15]; 
					xr[gr][ch][sb*18+15]+=xr[gr][ch][sb*18+14]; 
					xr[gr][ch][sb*18+14]+=xr[gr][ch][sb*18+13];
					xr[gr][ch][sb*18+13]+=xr[gr][ch][sb*18+12]; 
					xr[gr][ch][sb*18+12]+=xr[gr][ch][sb*18+11]; 
					xr[gr][ch][sb*18+11]+=xr[gr][ch][sb*18+10]; 
					xr[gr][ch][sb*18+10]+=xr[gr][ch][sb*18+ 9];
					xr[gr][ch][sb*18+ 9]+=xr[gr][ch][sb*18+ 8];  
					xr[gr][ch][sb*18+ 8]+=xr[gr][ch][sb*18+ 7];  
					xr[gr][ch][sb*18+ 7]+=xr[gr][ch][sb*18+ 6];  
					xr[gr][ch][sb*18+ 6]+=xr[gr][ch][sb*18+ 5];
					xr[gr][ch][sb*18+ 5]+=xr[gr][ch][sb*18+ 4];
					xr[gr][ch][sb*18+ 4]+=xr[gr][ch][sb*18+ 3];
					xr[gr][ch][sb*18+ 3]+=xr[gr][ch][sb*18+ 2];
					xr[gr][ch][sb*18+ 2]+=xr[gr][ch][sb*18+ 1];
					xr[gr][ch][sb*18+ 1]+=xr[gr][ch][sb*18+ 0];
					//input aliasing for 18->9 point IDCT
					xr[gr][ch][sb*18+17]+=xr[gr][ch][sb*18+15]; 
					xr[gr][ch][sb*18+15]+=xr[gr][ch][sb*18+13]; 
					xr[gr][ch][sb*18+13]+=xr[gr][ch][sb*18+11]; 
					xr[gr][ch][sb*18+11]+=xr[gr][ch][sb*18+ 9];
					xr[gr][ch][sb*18+ 9]+=xr[gr][ch][sb*18+ 7];
					xr[gr][ch][sb*18+ 7]+=xr[gr][ch][sb*18+ 5];
					xr[gr][ch][sb*18+ 5]+=xr[gr][ch][sb*18+ 3];
					xr[gr][ch][sb*18+ 3]+=xr[gr][ch][sb*18+ 1];
					// 9 point IDCT on even indices
					t1=COSPI3*xr[gr][ch][sb*18+12];
					t2=COSPI3*(xr[gr][ch][sb*18+8]+xr[gr][ch][sb*18+16]-xr[gr][ch][sb*18+4]);
					t3=xr[gr][ch][sb*18+0]+t1;
					t4=xr[gr][ch][sb*18+0]-t1-t1;
					t5=t4-t2;
					t0=DCTEVEN1*(xr[gr][ch][sb*18+4]+xr[gr][ch][sb*18+ 8]);
					t1=DCTEVEN2*(xr[gr][ch][sb*18+8]-xr[gr][ch][sb*18+16]);
					tmp[4]=t4+t2+t2;
					t2=DCTEVEN3*(xr[gr][ch][sb*18+4]+xr[gr][ch][sb*18+16]);
					t6=t3-t0-t2;
					t0+=t3+t1;
					t3+=t2-t1;
					t2=DCTODD1*(xr[gr][ch][sb*18+ 2]+xr[gr][ch][sb*18+10]);
					t4=DCTODD2*(xr[gr][ch][sb*18+10]-xr[gr][ch][sb*18+14]);
					t7=COSPI6*xr[gr][ch][sb*18+6];
					t1=t2+t4+t7;
					tmp[0]=t0+t1;
					tmp[8]=t0-t1;
					t1=DCTODD3*(xr[gr][ch][sb*18+2]+xr[gr][ch][sb*18+14]);
					t2+=t1-t7;
					tmp[3]=t3+t2;
					t0=COSPI6*(xr[gr][ch][sb*18+10]+xr[gr][ch][sb*18+14]-xr[gr][ch][sb*18+2]);
					tmp[5]=t3-t2;
					t4-=t1+t7;
					tmp[1]=t5-t0;
					tmp[7]=t5+t0;
					tmp[2]=t6+t4;
					tmp[6]=t6-t4;
					// 9 point IDCT on odd indices
					t1=COSPI3*xr[gr][ch][sb*18+13];
					t2=COSPI3*(xr[gr][ch][sb*18+9]+xr[gr][ch][sb*18+17]-xr[gr][ch][sb*18+5]);
					t3=xr[gr][ch][sb*18+1]+t1;
					t4=xr[gr][ch][sb*18+1]-t1-t1;
					t5=t4-t2;
					t0=DCTEVEN1*(xr[gr][ch][sb*18+5]+xr[gr][ch][sb*18+9]);
					t1=DCTEVEN2*(xr[gr][ch][sb*18+9]-xr[gr][ch][sb*18+17]);
					tmp[13]=(t4+t2+t2)*0.707106781f;
					t2=DCTEVEN3*(xr[gr][ch][sb*18+5]+xr[gr][ch][sb*18+17]);
					t6=t3-t0-t2;
					t0+=t3+t1;
					t3+=t2-t1;
					t2=DCTODD1*(xr[gr][ch][sb*18+ 3]+xr[gr][ch][sb*18+11]);
					t4=DCTODD2*(xr[gr][ch][sb*18+11]-xr[gr][ch][sb*18+15]);
					t7=COSPI6*xr[gr][ch][sb*18+7];
					t1=t2+t4+t7;
					tmp[17]=(t0+t1)*0.501909918f;
					tmp[ 9]=(t0-t1)*5.736856623f;
					t1=DCTODD3*(xr[gr][ch][sb*18+ 3]+xr[gr][ch][sb*18+15]);
					t2+=t1-t7;
					tmp[14]=(t3+t2)*0.610387294f;
					t0=COSPI6*(xr[gr][ch][sb*18+11]+xr[gr][ch][sb*18+15]-xr[gr][ch][sb*18+3]);
					tmp[12]=(t3-t2)*0.871723397f;
					t4-=t1+t7;
					tmp[16]=(t5-t0)*0.517638090f;
					tmp[10]=(t5+t0)*1.931851653f;
					tmp[15]=(t6+t4)*0.551688959f;
					tmp[11]=(t6-t4)*1.183100792f;
					// Butterflies on 9 point IDCT's
					for (i=0;i<9;i++) 
					{
						save=tmp[i];
						tmp[i   ]=save+tmp[17-i];
						tmp[17-i]=save-tmp[17-i];
					}
					// output reordering for 18x18 -> 36x18 DCT (+twiddle/windowing and overlap adding)
					if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2)&&(mixed_block_flag[gr][ch]))
						window_type=0;
					else
						window_type=block_type[gr][ch];
					for (i=0;i<9;i++) 
					{
						Header->subbandsamples[ch][sb][gr*18+i  ]=(-tmp[i+ 9]*W[window_type][i  ])+Header->overlap[ch][sb][i  ];
						Header->subbandsamples[ch][sb][gr*18+i+9]=( tmp[17-i]*W[window_type][i+9])+Header->overlap[ch][sb][i+9];
						Header->overlap[ch][sb][i  ]=( tmp[8-i]*W[window_type][i+18]);
						Header->overlap[ch][sb][i+9]=( tmp[i  ]*W[window_type][i+27]);
					}
				}
				if (sb&1)
					for (i=1;i<18;i+=2)
						Header->subbandsamples[ch][sb][gr*18+i]=-Header->subbandsamples[ch][sb][gr*18+i];
			}
			for (sb=sblimit;sb<32;sb++)	  
				for (i=0;i<18;i++)
					Header->subbandsamples[ch][sb][gr*18+i]=0.0f;
		}
	}
}

//MMX(tm) Polyphase subband-filter function (using a 2 stage Lee DCT decomposition)

extern int __cdecl SubBandSynthesis_a(short *bandPtr,int channel,short *samples,float *V);

static void mmxSubbandSynthesis(MPEGAudioStream *Header)
{
	short shuffle1[32];
	int ch,i,nch,ns,s;
  
	switch (Header->layer)
	{
		case 0x01: ns=(Header->ID?18*2:18); break;
		case 0x02: ns=12*3;	break;
		case 0x03: ns=12; break;
	}
	nch=Header->mode==0x03?1:2;
	for (s=0;s<ns;s++)
	{
		for (ch=0;ch<nch;ch++)
		{
			for (i=0;i<32;i++) shuffle1[i]=float2short(Header->subbandsamples[ch][i][s]);
			SubBandSynthesis_a(shuffle1,ch,&Header->pcmsamples[ch][s*32],(float *)Header->V);
		}
	}
}

//3DNow!(tm) Polyphase subband-filter function (???)

//extern int __cdecl SubBandSynthesis_b(float *bandPtr,int channel,short *samples,float *V);

static void k3dSubbandSynthesis(MPEGAudioStream *Header)
{
	float shuffle1[32];
	int ch,i,nch,ns,s;
  
	switch (Header->layer)
	{
		case 0x01: ns=(Header->ID?18*2:18); break;
		case 0x02: ns=12*3;	break;
		case 0x03: ns=12; break;
	}
	nch=Header->mode==0x03?1:2;
	for (s=0;s<ns;s++)
	{
		for (ch=0;ch<nch;ch++)
		{
			for (i=0;i<32;i++) shuffle1[i]=Header->subbandsamples[ch][i][s];
			//SubBandSynthesis_b(shuffle1,ch,&Header->pcmsamples[ch][s*32],Header->V);
		}
	}
}

//FPU Polyphase subband-filter function (using a 5 stage Lee DCT decomposition)

static void x86SubbandSynthesis(MPEGAudioStream *Header)
{
	float shuffle1[32],shuffle2[32];
	int ch,i,j,k,nch,ns,s,part;
	static int initialised=0;
	static float H[5][16];					
	float sum;

	if (!initialised)
	{
		//Calculate ODD scaling matrix H
		for (j=0;j<16;j++)
			H[0][j]=(float)(1.0/(2.0*cos((2*j+1)*PI/64.0)));
		for (j=0;j<8;j++)
			H[1][j]=(float)(1.0/(2.0*cos((2*j+1)*PI/32.0)));
		for (j=0;j<4;j++)
			H[2][j]=(float)(1.0/(2.0*cos((2*j+1)*PI/16.0)));
		for (j=0;j<2;j++)
			H[3][j]=(float)(1.0/(2.0*cos((2*j+1)*PI/8.0)));
		for (j=0;j<1;j++)
			H[4][j]=(float)(1.0/(2.0*cos((2*j+1)*PI/4.0)));
		//Subband routine initialised
		initialised=1;
	}
	switch (Header->layer)
	{
		case 0x01: ns=(Header->ID?18*2:18); break;
		case 0x02: ns=12*3; break;
		case 0x03: ns=12; break;
	}
	nch=Header->mode==0x03?1:2;
	for (ch=0;ch<nch;ch++)
	{
		for (s=0;s<ns;s++)
		{
			//stage 1 input bufferfly (1*32->2*16)
			for (i=0;i<16;i++)
			{
				shuffle1[i*2+0]=(Header->subbandsamples[ch][i][s]+Header->subbandsamples[ch][31-i][s]);
				shuffle1[i*2+1]=(Header->subbandsamples[ch][i][s]-Header->subbandsamples[ch][31-i][s])*H[0][i];
			}
			//stage 2 input bufferfly (2*16->4*8)
			for (i=0;i<8;i++)
			{
				shuffle2[i*4+0]=(shuffle1[i*2+0]+shuffle1[30-i*2]);
				shuffle2[i*4+2]=(shuffle1[i*2+0]-shuffle1[30-i*2])*H[1][i];
				shuffle2[i*4+1]=(shuffle1[i*2+1]+shuffle1[31-i*2]);
				shuffle2[i*4+3]=(shuffle1[i*2+1]-shuffle1[31-i*2])*H[1][i];
			}
			//stage 3 input bufferfly (4*8->8*4)
			for (i=0;i<4;i++)
			{
				shuffle1[i*8+0]=(shuffle2[i*4+0]+shuffle2[28-i*4]);
				shuffle1[i*8+4]=(shuffle2[i*4+0]-shuffle2[28-i*4])*H[2][i];
				shuffle1[i*8+1]=(shuffle2[i*4+1]+shuffle2[29-i*4]);
				shuffle1[i*8+5]=(shuffle2[i*4+1]-shuffle2[29-i*4])*H[2][i];
				shuffle1[i*8+2]=(shuffle2[i*4+2]+shuffle2[30-i*4]);
				shuffle1[i*8+6]=(shuffle2[i*4+2]-shuffle2[30-i*4])*H[2][i];
				shuffle1[i*8+3]=(shuffle2[i*4+3]+shuffle2[31-i*4]);
				shuffle1[i*8+7]=(shuffle2[i*4+3]-shuffle2[31-i*4])*H[2][i];
			}
			//stage 4 input bufferfly (8*4->16*2)
			for (i=0;i<2;i++)
			{
				shuffle2[i*16+ 0]=(shuffle1[i*8+0]+shuffle1[24-i*8]);
				shuffle2[i*16+ 8]=(shuffle1[i*8+0]-shuffle1[24-i*8])*H[3][i];
				shuffle2[i*16+ 1]=(shuffle1[i*8+1]+shuffle1[25-i*8]);
				shuffle2[i*16+ 9]=(shuffle1[i*8+1]-shuffle1[25-i*8])*H[3][i];
				shuffle2[i*16+ 2]=(shuffle1[i*8+2]+shuffle1[26-i*8]);
				shuffle2[i*16+10]=(shuffle1[i*8+2]-shuffle1[26-i*8])*H[3][i];
				shuffle2[i*16+ 3]=(shuffle1[i*8+3]+shuffle1[27-i*8]);
				shuffle2[i*16+11]=(shuffle1[i*8+3]-shuffle1[27-i*8])*H[3][i];
				shuffle2[i*16+ 4]=(shuffle1[i*8+4]+shuffle1[28-i*8]);
				shuffle2[i*16+12]=(shuffle1[i*8+4]-shuffle1[28-i*8])*H[3][i];
				shuffle2[i*16+ 5]=(shuffle1[i*8+5]+shuffle1[29-i*8]);
				shuffle2[i*16+13]=(shuffle1[i*8+5]-shuffle1[29-i*8])*H[3][i];
				shuffle2[i*16+ 6]=(shuffle1[i*8+6]+shuffle1[30-i*8]);
				shuffle2[i*16+14]=(shuffle1[i*8+6]-shuffle1[30-i*8])*H[3][i];
				shuffle2[i*16+ 7]=(shuffle1[i*8+7]+shuffle1[31-i*8]);
				shuffle2[i*16+15]=(shuffle1[i*8+7]-shuffle1[31-i*8])*H[3][i];
			}
			//stage 5 input bufferfly+corrections (16*2->32*1)
			{
				shuffle1[ 0]=(shuffle2[ 0]+shuffle2[16]);
				shuffle1[16]=(shuffle2[ 0]-shuffle2[16])*H[4][0];
				shuffle1[ 1]=(shuffle2[ 1]+shuffle2[17]);
				shuffle1[17]=(shuffle2[ 1]-shuffle2[17])*H[4][0];
				shuffle1[ 2]=(shuffle2[ 2]+shuffle2[18]);
				shuffle1[18]=(shuffle2[ 2]-shuffle2[18])*H[4][0];
				shuffle1[ 3]=(shuffle2[ 3]+shuffle2[19]);
				shuffle1[19]=(shuffle2[ 3]-shuffle2[19])*H[4][0];
				shuffle1[ 4]=(shuffle2[ 4]+shuffle2[20]);
				shuffle1[20]=(shuffle2[ 4]-shuffle2[20])*H[4][0];
				shuffle1[ 5]=(shuffle2[ 5]+shuffle2[21]);
				shuffle1[21]=(shuffle2[ 5]-shuffle2[21])*H[4][0];
				shuffle1[ 6]=(shuffle2[ 6]+shuffle2[22]);
				shuffle1[22]=(shuffle2[ 6]-shuffle2[22])*H[4][0];
				shuffle1[ 7]=(shuffle2[ 7]+shuffle2[23]);
				shuffle1[23]=(shuffle2[ 7]-shuffle2[23])*H[4][0];
				shuffle1[ 8]=(shuffle2[ 8]+shuffle2[24]);
				shuffle1[24]=(shuffle2[ 8]-shuffle2[24])*H[4][0];
				shuffle1[ 9]=(shuffle2[ 9]+shuffle2[25]);
				shuffle1[25]=(shuffle2[ 9]-shuffle2[25])*H[4][0];
				shuffle1[10]=(shuffle2[10]+shuffle2[26]);
				shuffle1[26]=(shuffle2[10]-shuffle2[26])*H[4][0];
				shuffle1[11]=(shuffle2[11]+shuffle2[27]);
				shuffle1[27]=(shuffle2[11]-shuffle2[27])*H[4][0];
				shuffle1[12]=(shuffle2[12]+shuffle2[28]);
				shuffle1[28]=(shuffle2[12]-shuffle2[28])*H[4][0];
				shuffle1[13]=(shuffle2[13]+shuffle2[29]);
				shuffle1[29]=(shuffle2[13]-shuffle2[29])*H[4][0];
				shuffle1[14]=(shuffle2[14]+shuffle2[30]);
				shuffle1[30]=(shuffle2[14]-shuffle2[30])*H[4][0];
				shuffle1[15]=(shuffle2[15]+shuffle2[31]);
				shuffle1[31]=(shuffle2[15]-shuffle2[31])*H[4][0];
			}
			//stage 4 odd part output butterfly corrections
			{
				shuffle1[ 8]+=shuffle1[24];
				shuffle1[ 9]+=shuffle1[25];
				shuffle1[10]+=shuffle1[26];
				shuffle1[11]+=shuffle1[27];
				shuffle1[12]+=shuffle1[28];
				shuffle1[13]+=shuffle1[29];
				shuffle1[14]+=shuffle1[30];
				shuffle1[15]+=shuffle1[31];
			}
			//stage 3 odd part output butterfly corrections
			{
				shuffle1[ 4]+=shuffle1[12];
				shuffle1[ 5]+=shuffle1[13];
				shuffle1[ 6]+=shuffle1[14];
				shuffle1[ 7]+=shuffle1[15];
				shuffle1[12]+=shuffle1[20];
				shuffle1[13]+=shuffle1[21];
				shuffle1[14]+=shuffle1[22];
				shuffle1[15]+=shuffle1[23];
				shuffle1[20]+=shuffle1[28];
				shuffle1[21]+=shuffle1[29];
				shuffle1[22]+=shuffle1[30];
				shuffle1[23]+=shuffle1[31];
			}
			//stage 2 odd part output butterfly corrections
			{
				shuffle1[ 2]+=shuffle1[ 6];
				shuffle1[ 3]+=shuffle1[ 7];
				shuffle1[ 6]+=shuffle1[10];
				shuffle1[ 7]+=shuffle1[11];
				shuffle1[10]+=shuffle1[14];
				shuffle1[11]+=shuffle1[15];
				shuffle1[14]+=shuffle1[18];
				shuffle1[15]+=shuffle1[19];
				shuffle1[18]+=shuffle1[22];
				shuffle1[19]+=shuffle1[23];
				shuffle1[22]+=shuffle1[26];
				shuffle1[23]+=shuffle1[27];
				shuffle1[26]+=shuffle1[30];
				shuffle1[27]+=shuffle1[31];
			}
			//stage 1 odd part output butterfly corrections
			{
				shuffle1[ 1]+=shuffle1[ 3];
				shuffle1[ 3]+=shuffle1[ 5];
				shuffle1[ 5]+=shuffle1[ 7];
				shuffle1[ 7]+=shuffle1[ 9];
				shuffle1[ 9]+=shuffle1[11];
				shuffle1[11]+=shuffle1[13];
				shuffle1[13]+=shuffle1[15];
				shuffle1[15]+=shuffle1[17];
				shuffle1[17]+=shuffle1[19];
				shuffle1[19]+=shuffle1[21];
				shuffle1[21]+=shuffle1[23];
				shuffle1[23]+=shuffle1[25];
				shuffle1[25]+=shuffle1[27];
				shuffle1[27]+=shuffle1[29];
				shuffle1[29]+=shuffle1[31];
			}
			part=(s&1);
			//output reordering for 32x32 -> 64x32 DCT (Insert into V)
			for (i=0;i<16;i++) 
			{
				Header->V[ch][part  ][Header->vshift[ch]+ i*16]= shuffle1[16+i];
				Header->V[ch][part^1][Header->vshift[ch]+ i*16]=-shuffle1[16-i];
			}
			Header->V[ch][part  ][Header->vshift[ch]+16*16]= 0.0;
			Header->V[ch][part^1][Header->vshift[ch]+16*16]=-shuffle1[   0];
			//Calculate 32 (time)samples by windowing the 1024 entry cyclic V vector
			for (j=0,k=0;j<16;j++,k+=16)
			{
				sum =(D[j][16-Header->vshift[ch]]*Header->V[ch][part][k   ]); 
				sum+=(D[j][17-Header->vshift[ch]]*Header->V[ch][part][k+ 1]); 
				sum+=(D[j][18-Header->vshift[ch]]*Header->V[ch][part][k+ 2]); 
				sum+=(D[j][19-Header->vshift[ch]]*Header->V[ch][part][k+ 3]);
				sum+=(D[j][20-Header->vshift[ch]]*Header->V[ch][part][k+ 4]);
				sum+=(D[j][21-Header->vshift[ch]]*Header->V[ch][part][k+ 5]);
				sum+=(D[j][22-Header->vshift[ch]]*Header->V[ch][part][k+ 6]);
				sum+=(D[j][23-Header->vshift[ch]]*Header->V[ch][part][k+ 7]);
				sum+=(D[j][24-Header->vshift[ch]]*Header->V[ch][part][k+ 8]);
				sum+=(D[j][25-Header->vshift[ch]]*Header->V[ch][part][k+ 9]);
				sum+=(D[j][26-Header->vshift[ch]]*Header->V[ch][part][k+10]);
				sum+=(D[j][27-Header->vshift[ch]]*Header->V[ch][part][k+11]);
				sum+=(D[j][28-Header->vshift[ch]]*Header->V[ch][part][k+12]);
				sum+=(D[j][29-Header->vshift[ch]]*Header->V[ch][part][k+13]);
				sum+=(D[j][30-Header->vshift[ch]]*Header->V[ch][part][k+14]);
				sum+=(D[j][31-Header->vshift[ch]]*Header->V[ch][part][k+15]);
				Header->pcmsamples[ch][s*32+j]=float2short(sum);
			}
			if (part)
			{
				sum =(D[j][16-Header->vshift[ch]]*Header->V[ch][part][k   ]); 
				sum+=(D[j][18-Header->vshift[ch]]*Header->V[ch][part][k+ 2]); 
				sum+=(D[j][20-Header->vshift[ch]]*Header->V[ch][part][k+ 4]); 
				sum+=(D[j][22-Header->vshift[ch]]*Header->V[ch][part][k+ 6]);
				sum+=(D[j][24-Header->vshift[ch]]*Header->V[ch][part][k+ 8]);
				sum+=(D[j][26-Header->vshift[ch]]*Header->V[ch][part][k+10]);
				sum+=(D[j][28-Header->vshift[ch]]*Header->V[ch][part][k+12]);
				sum+=(D[j][30-Header->vshift[ch]]*Header->V[ch][part][k+14]);
				Header->pcmsamples[ch][s*32+j]=float2short(sum);
				for (j=17,k=15*16;j<32;j++,k-=16)
				{
					sum=-(D[32-j][Header->vshift[ch]+15]*Header->V[ch][part][k   ]); 
					sum+=(D[32-j][Header->vshift[ch]+14]*Header->V[ch][part][k+ 1]); 
					sum-=(D[32-j][Header->vshift[ch]+13]*Header->V[ch][part][k+ 2]); 
					sum+=(D[32-j][Header->vshift[ch]+12]*Header->V[ch][part][k+ 3]);
					sum-=(D[32-j][Header->vshift[ch]+11]*Header->V[ch][part][k+ 4]);
					sum+=(D[32-j][Header->vshift[ch]+10]*Header->V[ch][part][k+ 5]);
					sum-=(D[32-j][Header->vshift[ch]+ 9]*Header->V[ch][part][k+ 6]);
					sum+=(D[32-j][Header->vshift[ch]+ 8]*Header->V[ch][part][k+ 7]);
					sum-=(D[32-j][Header->vshift[ch]+ 7]*Header->V[ch][part][k+ 8]);
					sum+=(D[32-j][Header->vshift[ch]+ 6]*Header->V[ch][part][k+ 9]);
					sum-=(D[32-j][Header->vshift[ch]+ 5]*Header->V[ch][part][k+10]);
					sum+=(D[32-j][Header->vshift[ch]+ 4]*Header->V[ch][part][k+11]);
					sum-=(D[32-j][Header->vshift[ch]+ 3]*Header->V[ch][part][k+12]);
					sum+=(D[32-j][Header->vshift[ch]+ 2]*Header->V[ch][part][k+13]);
					sum-=(D[32-j][Header->vshift[ch]+ 1]*Header->V[ch][part][k+14]);
					sum+=(D[32-j][Header->vshift[ch]   ]*Header->V[ch][part][k+15]);
					Header->pcmsamples[ch][s*32+j]=float2short(sum);
				}
			}
			else
			{
				sum =(D[j][17-Header->vshift[ch]]*Header->V[ch][part][k+ 1]); 
				sum+=(D[j][19-Header->vshift[ch]]*Header->V[ch][part][k+ 3]); 
				sum+=(D[j][21-Header->vshift[ch]]*Header->V[ch][part][k+ 5]); 
				sum+=(D[j][23-Header->vshift[ch]]*Header->V[ch][part][k+ 7]);
				sum+=(D[j][25-Header->vshift[ch]]*Header->V[ch][part][k+ 9]);
				sum+=(D[j][27-Header->vshift[ch]]*Header->V[ch][part][k+11]);
				sum+=(D[j][29-Header->vshift[ch]]*Header->V[ch][part][k+13]);
				sum+=(D[j][31-Header->vshift[ch]]*Header->V[ch][part][k+15]);
				Header->pcmsamples[ch][s*32+j]=float2short(sum);
				for (j=17,k=15*16;j<32;j++,k-=16)
				{
					sum =(D[32-j][Header->vshift[ch]+15]*Header->V[ch][part][k   ]); 
					sum-=(D[32-j][Header->vshift[ch]+14]*Header->V[ch][part][k+ 1]); 
					sum+=(D[32-j][Header->vshift[ch]+13]*Header->V[ch][part][k+ 2]); 
					sum-=(D[32-j][Header->vshift[ch]+12]*Header->V[ch][part][k+ 3]);
					sum+=(D[32-j][Header->vshift[ch]+11]*Header->V[ch][part][k+ 4]);
					sum-=(D[32-j][Header->vshift[ch]+10]*Header->V[ch][part][k+ 5]);
					sum+=(D[32-j][Header->vshift[ch]+ 9]*Header->V[ch][part][k+ 6]);
					sum-=(D[32-j][Header->vshift[ch]+ 8]*Header->V[ch][part][k+ 7]);
					sum+=(D[32-j][Header->vshift[ch]+ 7]*Header->V[ch][part][k+ 8]);
					sum-=(D[32-j][Header->vshift[ch]+ 6]*Header->V[ch][part][k+ 9]);
					sum+=(D[32-j][Header->vshift[ch]+ 5]*Header->V[ch][part][k+10]);
					sum-=(D[32-j][Header->vshift[ch]+ 4]*Header->V[ch][part][k+11]);
					sum+=(D[32-j][Header->vshift[ch]+ 3]*Header->V[ch][part][k+12]);
					sum-=(D[32-j][Header->vshift[ch]+ 2]*Header->V[ch][part][k+13]);
					sum+=(D[32-j][Header->vshift[ch]+ 1]*Header->V[ch][part][k+14]);
					sum-=(D[32-j][Header->vshift[ch]   ]*Header->V[ch][part][k+15]);
					Header->pcmsamples[ch][s*32+j]=float2short(sum);
				}
			}
			Header->vshift[ch]=((Header->vshift[ch]-1)&0x0f);
			/* //output reordering for 32x32 -> 64x32 DCT
			for (i=0;i<16;i++) 
			{
				Header->V[ch][Header->vshift[ch]+i   ]= shuffle1[i+16];
				Header->V[ch][Header->vshift[ch]+i+17]=-shuffle1[31-i];
				Header->V[ch][Header->vshift[ch]+i+32]=-shuffle1[16-i];
				Header->V[ch][Header->vshift[ch]+i+48]=-shuffle1[i   ];
			}
			Header->V[ch][Header->vshift[ch]+16]=0.0;
			//Calculate 32 (time)samples by windowing the 1024 entry cyclic V vector
			for (j=0,k=Header->vshift[ch];j<32;j++,k++)
			{
				sum =(D[j    ]*Header->V[ch][ k     &0x3ff]);
				sum+=(D[j+ 32]*Header->V[ch][(k+ 96)&0x3ff]);
				sum+=(D[j+ 64]*Header->V[ch][(k+128)&0x3ff]);
				sum+=(D[j+ 96]*Header->V[ch][(k+224)&0x3ff]);
				sum+=(D[j+128]*Header->V[ch][(k+256)&0x3ff]);
				sum+=(D[j+160]*Header->V[ch][(k+352)&0x3ff]);
				sum+=(D[j+192]*Header->V[ch][(k+384)&0x3ff]);
				sum+=(D[j+224]*Header->V[ch][(k+480)&0x3ff]);
				sum+=(D[j+256]*Header->V[ch][(k+512)&0x3ff]);
				sum+=(D[j+288]*Header->V[ch][(k+608)&0x3ff]);
				sum+=(D[j+320]*Header->V[ch][(k+640)&0x3ff]);
				sum+=(D[j+352]*Header->V[ch][(k+736)&0x3ff]);
				sum+=(D[j+384]*Header->V[ch][(k+768)&0x3ff]);
				sum+=(D[j+416]*Header->V[ch][(k+864)&0x3ff]);
				sum+=(D[j+448]*Header->V[ch][(k+896)&0x3ff]);
				sum+=(D[j+480]*Header->V[ch][(k+992)&0x3ff]);
				Header->pcmsamples[ch][s*32+j]=float2short(sum);
			}
			Header->vshift[ch]=((Header->vshift[ch]-64)&0x03ff);*/
		}
	}
} 

//Audio layer 1 (side information and main_data decoding/requantisizing)

static void audio_data_1(void *Stream,MPEGAudioStream *Header)
{
	static const char bitspersample[16]={
		0,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0
	};
	static const long D[16]={
		65536,32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2
	};
	static const float C[16]={
		0.00000000000f,2.00000000000f,1.33333333333f,1.14285714286f,
		1.06666666666f,1.03225806452f,1.01587301587f,1.00787401575f,
		1.00392156863f,1.00195694716f,1.00097751711f,1.00048851979f,
		1.00024420024f,1.00012208522f,1.00006103888f,1.00003051851f
	};
	int bound,ch,nb,nch,s,sb;
	float subbandsample;

	//Variable initialization
	nch=Header->mode==0x03?1:2;
	if (Header->mode==0x01)
	{
		switch (Header->mode_extension&0x03)
		{
			case 0x00: bound=4; break;
			case 0x01: bound=8; break;
			case 0x02: bound=12; break;
			case 0x03: bound=16; break;
		}
	}
	else
		bound=32;
	//Bit allocation information decoding
	for (sb=0;sb<bound;sb++)
		for (ch=0;ch<nch;ch++)
			Header->allocation[ch][sb]=getbits(Stream,4);
	for (sb=bound;sb<32;sb++)
		Header->allocation[0][sb]=Header->allocation[1][sb]=getbits(Stream,4);
	//Scalefactor decoding
	for (sb=0;sb<32;sb++)
		for (ch=0;ch<nch;ch++)
			if (Header->allocation[ch][sb]!=0)
				Header->scalefactor[ch][sb][0]=getbits(Stream,6);
	//Subband sample decoding
	for (s=0;s<12;s++)
	{
		for (sb=0;sb<bound;sb++)
			for (ch=0;ch<nch;ch++)
				if (Header->allocation[ch][sb]!=0)
					Header->maindata.sample[ch][sb][s]=getbits(Stream,bitspersample[Header->allocation[ch][sb]]);
		for (sb=bound;sb<32;sb++)
			if (Header->allocation[0][sb]!=0)
				Header->maindata.sample[0][sb][s]=Header->maindata.sample[1][sb][s]=getbits(Stream,bitspersample[Header->allocation[0][sb]]);
	}
	//Requantization
	for (ch=0;ch<nch;ch++)
	{
		for (sb=0;sb<32;sb++)
		{
			if (Header->allocation[ch][sb]!=0)
			{
				nb=bitspersample[Header->allocation[ch][sb]];
				for (s=0;s<12;s++)
				{
					Header->maindata.sample[ch][sb][s]<<=(16-nb);
					Header->maindata.sample[ch][sb][s]-=32768;
					Header->maindata.sample[ch][sb][s]+=D[nb];
					subbandsample=Header->maindata.sample[ch][sb][s]*C[nb];
					subbandsample*=SCALE[Header->scalefactor[ch][sb][0]];
					Header->subbandsamples[ch][sb][s]=subbandsample;
				}
			}
			else
			{
				for (s=0;s<12;s++)
					Header->subbandsamples[ch][sb][s]=0.0;
			}
		}
	}
}

//Audio layer 2 (side information and main_data decoding/requantisizing)

static void audio_data_2(void *Stream,MPEGAudioStream *Header)
{
	long samplecode;
	float subbandsample;
	int bound,ch,gr,nch,s,sb,sblimit,table,qclass;
	static const char grouping[17]={
		1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	};
	static const char bitspersample[17]={
		2,3,3,4,4,5,6,7,8,9,10,11,12,13,14,15,16
	};
	static const char bitspercodeword[17]={
		5,7,3,10,4,5,6,7,8,9,10,11,12,13,14,15,16
	};
	static const long D[17]={
		16384,16384,8192,16384,4096,2048,1024,512,256,128,64,32,16,8,4,2,1
	};
	static const long nlevels[17]={
		3,5,7,9,15,31,63,127,255,511,1023,2047,4095,8191,16383,32767,65535
	};
	static const float C[17]={
		1.33333333333f,1.60000000000f,1.14285714286f,1.77777777777f,
		1.06666666666f,1.03225806452f,1.01587301587f,1.00787401575f,
		1.00392156863f,1.00195694716f,1.00097751711f,1.00048851979f,
		1.00024420024f,1.00012208522f,1.00006103888f,1.00003051851f,
		1.00001525902f
	};
	static const char sblimits[2][4][16]={
		{{0,8,8,27,27,27,30,30,30,30,30,0,0,0,0,0},
		{0,8,8,27,27,27,27,27,27,27,27,0,0,0,0,0},
		{0,12,12,27,27,27,30,30,30,30,30,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},
		{{0,0,0,0,8,0,8,27,27,27,30,30,30,30,30,0},
		{0,0,0,0,8,0,8,27,27,27,27,27,27,27,27,0},
		{0,0,0,0,12,0,12,27,27,27,30,30,30,30,30,0},
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
	};
	static const char classes[2][2][32][16]={
		{{{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}},
		{{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}}},
		{{{4,0,2,4,5,6,7,8,9,10,11,12,13,14,15,16},
		{4,0,2,4,5,6,7,8,9,10,11,12,13,14,15,16},
		{4,0,2,4,5,6,7,8,9,10,11,12,13,14,15,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{4,0,1,2,3,4,5,6,7,8,9,10,11,12,13,16},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,2,3,4,5,16,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{2,0,1,16,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}},
		{{4,0,1,3,4,5,6,7,8,9,10,11,12,13,14,15},
		{4,0,1,3,4,5,6,7,8,9,10,11,12,13,14,15},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{3,0,1,3,4,5,6,7,-1,-1,-1,-1,-1,-1,-1,-1},
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},	
		{0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}}}
	};

	//Variable initialization
	nch=Header->mode==0x03?1:2;
	if (Header->ID)
		sblimit=sblimits[nch-1][Header->sampling_frequency][Header->bitrate_index];
	else
		sblimit=30;
	if ((sblimit==27)||(sblimit==30))
		table=0;
	else
		table=1;
	if (Header->mode==0x01)
	{
		switch (Header->mode_extension&0x03)
		{
			case 0x00: bound=4; break;
			case 0x01: bound=8; break;
			case 0x02: bound=12; break;
			case 0x03: bound=16; break;
		}
	}
	else
		bound=sblimit;
	//Bit allocation information decoding
	for (sb=0;sb<bound;sb++)
		for (ch=0;ch<nch;ch++)
			Header->allocation[ch][sb]=getbits(Stream,classes[Header->ID][table][sb][0]);
	for (sb=bound;sb<sblimit;sb++)
		Header->allocation[0][sb]=Header->allocation[1][sb]=getbits(Stream,classes[Header->ID][table][sb][0]);
	for (sb=sblimit;sb<32;sb++)
		Header->allocation[0][sb]=Header->allocation[1][sb]=0;
	for (sb=0;sb<sblimit;sb++)
		for (ch=0;ch<nch;ch++)
			if (Header->allocation[ch][sb]!=0)
				Header->scfsi[ch][sb]=getbits(Stream,2);
	//Scalefactor decoding
	for (sb=0;sb<sblimit;sb++)
		for (ch=0;ch<nch;ch++)
			if (Header->allocation[ch][sb]!=0)
			{
				switch(Header->scfsi[ch][sb])
				{
					case 0x00:
						Header->scalefactor[ch][sb][0]=getbits(Stream,6);
						Header->scalefactor[ch][sb][1]=getbits(Stream,6);
						Header->scalefactor[ch][sb][2]=getbits(Stream,6);
						break;
					case 0x01:
						Header->scalefactor[ch][sb][0]=Header->scalefactor[ch][sb][1]=getbits(Stream,6);
						Header->scalefactor[ch][sb][2]=getbits(Stream,6);
						break;
					case 0x02:
						Header->scalefactor[ch][sb][0]=Header->scalefactor[ch][sb][1]=Header->scalefactor[ch][sb][2]=getbits(Stream,6);
						break;
					case 0x03:
						Header->scalefactor[ch][sb][0]=getbits(Stream,6);
						Header->scalefactor[ch][sb][1]=Header->scalefactor[ch][sb][2]=getbits(Stream,6);
						break;
				}
			}
	//Subband sample decoding
	for (gr=0;gr<12;gr++)
	{
		for (sb=0;sb<bound;sb++)
			for (ch=0;ch<nch;ch++)
				if (Header->allocation[ch][sb]!=0)
				{
					if (grouping[classes[Header->ID][table][sb][Header->allocation[ch][sb]]])
					{
						samplecode=getbits(Stream,bitspercodeword[classes[Header->ID][table][sb][Header->allocation[ch][sb]]]);
						for (s=0;s<3;s++)
						{
							Header->maindata.sample[ch][sb][3*gr+s]=(samplecode%nlevels[classes[Header->ID][table][sb][Header->allocation[ch][sb]]]);
							samplecode/=nlevels[classes[Header->ID][table][sb][Header->allocation[ch][sb]]];
						}
					}
					else for (s=0;s<3;s++)
						Header->maindata.sample[ch][sb][3*gr+s]=getbits(Stream,bitspercodeword[classes[Header->ID][table][sb][Header->allocation[ch][sb]]]);
		}
		for (sb=bound;sb<sblimit;sb++)
			if (Header->allocation[0][sb]!=0)
			{
				if (grouping[classes[Header->ID][table][sb][Header->allocation[0][sb]]])
				{
					samplecode=getbits(Stream,bitspercodeword[classes[Header->ID][table][sb][Header->allocation[0][sb]]]);
					for (s=0;s<3;s++)
					{
						Header->maindata.sample[0][sb][3*gr+s]=Header->maindata.sample[1][sb][3*gr+s]=(samplecode%nlevels[classes[Header->ID][table][sb][Header->allocation[0][sb]]]);
						samplecode/=nlevels[classes[Header->ID][table][sb][Header->allocation[0][sb]]];
					}
				}		
				else for (s=0;s<3;s++)
					Header->maindata.sample[0][sb][3*gr+s]=Header->maindata.sample[1][sb][3*gr+s]=getbits(Stream,bitspercodeword[classes[Header->ID][table][sb][Header->allocation[0][sb]]]);
			}
	}
	//Requantization
	for (ch=0;ch<nch;ch++)
	{
		for (sb=0;sb<32;sb++)
		{
			if (Header->allocation[ch][sb]!=0)
			{
				qclass=classes[Header->ID][table][sb][Header->allocation[ch][sb]];
				for (gr=0;gr<12;gr++)
					for (s=0;s<3;s++)
					{
   						Header->maindata.sample[ch][sb][gr*3+s]<<=(16-bitspersample[qclass]);
						Header->maindata.sample[ch][sb][gr*3+s]-=32768;
						Header->maindata.sample[ch][sb][gr*3+s]+=D[qclass];
						subbandsample=Header->maindata.sample[ch][sb][gr*3+s]*C[qclass];
						subbandsample*=SCALE[Header->scalefactor[ch][sb][gr>>2]];
						Header->subbandsamples[ch][sb][gr*3+s]=subbandsample;
					}
			}
			else
			{
				for (gr=0;gr<12;gr++)
					for (s=0;s<3;s++)
						Header->subbandsamples[ch][sb][gr*3+s]=0.0;
			}
		}
	}
}

//Audio layer 3 (side information and main_data decoding/requantisizing/stereo)

static void audio_data_3(void *Stream,MPEGAudioStream *Header)
{
	static const char slen1[16]={
		0,0,0,0,3,1,1,1,2,2,2,3,3,3,4,4
	};
	static const char slen2[16]={
		0,1,2,3,0,1,2,3,1,2,3,1,2,3,2,3
	};
	static const char pretab[24]={
		0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,2,2,3,3,3,2,2,2,2
	};
	static const char linbits[32]={
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,6,8,10,13,4,5,6,7,8,9,11,13
	};
	static const int nr_of_sfb[6][3][4]={
		{{6, 5, 5, 5},{ 9, 9, 9, 9 },{6, 9, 9, 9}},
        {{6, 5, 7, 3},{ 9, 9, 12, 6},{6, 9, 12, 6}},
        {{11, 10, 0, 0},{ 18, 18, 0, 0},{15,18,0,0 }},
        {{7, 7, 7, 0},{ 12, 12, 12, 0},{6, 15, 12, 0}},
        {{6, 6, 6, 3},{12, 9, 9, 6},{6, 12, 9, 6}},
        {{8, 8, 5, 0},{15,12,9,0},{6,18,9,0}}
	};
	static const int ssfbands[3][3][14]={
		{{0,4,8,12,18,24,32,42,56,74,100,132,174,192},
		{0,4,8,12,18,26,36,48,62,80,104,136,180,192},
		{0,4,8,12,18,26,36,48,62,80,104,134,174,192}},
		{{0,4,8,12,16,22,30,40,52,66,84,106,136,192},
		{0,4,8,12,16,22,28,38,50,64,80,100,126,192},
		{0,4,8,12,16,22,30,42,58,78,104,138,180,192}},
		{{0,4,8,12,18,26,36,48,62,80,104,134,174,192},
		{0,4,8,12,18,26,36,48,62,80,104,134,174,192},
		{0,8,16,24,36,52,72,96,124,160,162,164,166,192}}
	};
	static const int lsfbands[3][3][23]={
		{{0,6,12,18,24,30,36,44,54,66,80,96,
	    116,140,168,200,238,284,336,396,464,522,576},
		{0,6,12,18,24,30,36,44,54,66,80,96,
		114,136,162,194,232,278,332,394,464,540,576},
		{0,6,12,18,24,30,36,44,54,66,80,96,
		116,140,168,200,238,284,336,396,464,522,576}},
		{{0,4,8,12,16,20,24,30,36,44,52,62,
	    74,90,110,134,162,196,238,288,342,418,576},
		{0,4,8,12,16,20,24,30,36,42,50,60,
		72,88,106,128,156,190,230,276,330,384,576},
		{0,4,8,12,16,20,24,30,36,44,54,66,
		82,102,126,156,194,240,296,364,448,550,576}},
		{{0,6,12,18,24,30,36,44,54,66,80,96,
		116,140,168,200,238,284,336,396,464,522,576},
		{0,6,12,18,24,30,36,44,54,66,80,96,
		116,140,168,200,238,284,336,396,464,522,576},
		{0,12,24,36,48,60,72,88,108,132,160,192,
		232,280,336,400,476,566,568,570,572,574,576}}
	};
	static const short *bigvaltable[32]={ 
		huff0, huff1, huff2, huff3, huff5, huff5, huff6, huff7, 
		huff8, huff9, huff10,huff11,huff12,huff13,huff15,huff15,
		huff16,huff16,huff16,huff16,huff16,huff16,huff16,huff16,
		huff24,huff24,huff24,huff24,huff24,huff24,huff24,huff24
	};
	static const long *bigvaltable2[32]={	
		NULL,	 NULL,	  NULL,	   NULL,	NULL,	 NULL,	  NULL,	   huff2_7,
		huff2_8, huff2_9, huff2_10,huff2_11,huff2_12,huff2_13,huff2_15,huff2_15,
		huff2_16,huff2_16,huff2_16,huff2_16,huff2_16,huff2_16,huff2_16,huff2_16, 
		huff2_24,huff2_24,huff2_24,huff2_24,huff2_24,huff2_24,huff2_24,huff2_24
	};
	static const char count1table[2][64]={	
		{0x6b,0x6f,0x6d,0x6e,0x67,0x65,0x59,0x59,
		0x56,0x56,0x53,0x53,0x5a,0x5a,0x5c,0x5c,
		0x42,0x42,0x42,0x42,0x41,0x41,0x41,0x41,
		0x44,0x44,0x44,0x44,0x48,0x48,0x48,0x48,
		0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,
		0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,
		0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,
		0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10},
		{0x4f,0x4f,0x4f,0x4f,0x4e,0x4e,0x4e,0x4e,
		0x4d,0x4d,0x4d,0x4d,0x4c,0x4c,0x4c,0x4c,
		0x4b,0x4b,0x4b,0x4b,0x4a,0x4a,0x4a,0x4a,
		0x49,0x49,0x49,0x49,0x48,0x48,0x48,0x48,
		0x47,0x47,0x47,0x47,0x46,0x46,0x46,0x46,
		0x45,0x45,0x45,0x45,0x44,0x44,0x44,0x44,
		0x43,0x43,0x43,0x43,0x42,0x42,0x42,0x42,
		0x41,0x41,0x41,0x41,0x40,0x40,0x40,0x40}
	};
	static const float is_ratio[2][2][2][32]={
		{{{1.00000000000f,0.84089642763f,1.00000000000f,0.70710676908f,
		1.00000000000f,0.59460353851f,1.00000000000f,0.50000000000f,
		1.00000000000f,0.42044821382f,1.00000000000f,0.35355338454f,
		1.00000000000f,0.29730176926f,1.00000000000f,0.25000000000f,
		1.00000000000f,0.21022410691f,1.00000000000f,0.17677669227f,
		1.00000000000f,0.14865088463f,1.00000000000f,0.12500000000f,
		1.00000000000f,0.10511205345f,1.00000000000f,0.08838834614f,
		1.00000000000f,0.07432544231f,1.00000000000f,0.00000000000f},
		{1.00000000000f,1.00000000000f,0.84089642763f,1.00000000000f,
		0.70710676908f,1.00000000000f,0.59460353851f,1.00000000000f,
		0.50000000000f,1.00000000000f,0.42044821382f,1.00000000000f,
		0.35355338454f,1.00000000000f,0.29730176926f,1.00000000000f,
		0.25000000000f,1.00000000000f,0.21022410691f,1.00000000000f,
		0.17677669227f,1.00000000000f,0.14865088463f,1.00000000000f,
		0.12500000000f,1.00000000000f,0.10511205345f,1.00000000000f,
		0.08838834614f,1.00000000000f,0.07432544231f,0.00000000000f}},
		{{1.00000000000f,0.70710676908f,1.00000000000f,0.50000000000f,
		1.00000000000f,0.35355338454f,1.00000000000f,0.25000000000f,
		1.00000000000f,0.17677669227f,1.00000000000f,0.12500000000f,
		1.00000000000f,0.08838834614f,1.00000000000f,0.06250000000f,
		1.00000000000f,0.04419417307f,1.00000000000f,0.03125000000f,
		1.00000000000f,0.02209708653f,1.00000000000f,0.01562500000f,
		1.00000000000f,0.01104854327f,1.00000000000f,0.00781250000f,
		1.00000000000f,0.00552427163f,1.00000000000f,0.00000000000f},
		{1.00000000000f,1.00000000000f,0.70710676908f,1.00000000000f,
		0.50000000000f,1.00000000000f,0.35355338454f,1.00000000000f,
		0.25000000000f,1.00000000000f,0.17677669227f,1.00000000000f,
		0.12500000000f,1.00000000000f,0.08838834614f,1.00000000000f,
		0.06250000000f,1.00000000000f,0.04419417307f,1.00000000000f,
		0.03125000000f,1.00000000000f,0.02209708653f,1.00000000000f,
		0.01562500000f,1.00000000000f,0.01104854327f,1.00000000000f,
		0.00781250000f,1.00000000000f,0.00552427163f,0.00000000000f}}},
		{{{0.00000000000f,0.21132486541f,0.36602540378f,0.50000000000f,
		0.63397459622f,0.78867513459f,1.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f},
		{1.00000000000f,0.78867513459f,0.63397459622f,0.50000000000f,
		0.36602540378f,0.21132486541f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f}},
		{{0.00000000000f,0.21132486541f,0.36602540378f,0.50000000000f,
		0.63397459622f,0.78867513459f,1.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f},
		{1.00000000000f,0.78867513459f,0.63397459622f,0.50000000000f,
		0.36602540378f,0.21132486541f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f,
		0.00000000000f,0.00000000000f,0.00000000000f,0.00000000000f}}}
	};
	int part2_3_length[2][2],big_values[2][2],count1[2][2],global_gain[2][2];
	int scalefac_compress[2][2],window_switching_flag[2][2],part2_base[2][2];
	int block_type[2][2],mixed_block_flag[2][2],table_select[2][2][3];
	int subblock_gain[2][2][3],region0_count[2][2],region1_count[2][2];
	int preflag[2][2],scalefac_scale[2][2],count1table_select[2][2];
	int scalefac_l[2][2][22],scalefac_s[2][2][13][3],slen[4];
	int main_data_begin,private_bits,frame_length,header_size;
	int ch,gr,nch,ngr,scfsi_band,sfb,window,blocknumber;
	int region,region1,region2,ancillary_bit,b,scale;
	int i,j,k,l,v,w,x,y,count1value,intensity_scale;
	unsigned long bigvalvalue;
	float m,s,xr[2][2][576];

	//Variable initialization
	nch=Header->mode==0x03?1:2;
	ngr=Header->ID?2:1;
	//Bit allocation information decoding (side-info reading)
	if (Header->ID)
	{
		header_size=(4+(Header->protection_bit?0:2)+(nch==1?17:32));  
		frame_length=(((144000*bitrate[Header->VLSF|Header->ID][Header->layer][Header->bitrate_index])/sampling_frequency[Header->VLSF|Header->ID][Header->sampling_frequency])+Header->padding_bit);
		main_data_begin=getbits(Stream,9);
		if (Header->mode==0x03)
			private_bits=getbits(Stream,5);
		else
			private_bits=getbits(Stream,3);
		for (ch=0;ch<nch;ch++)
			for (scfsi_band=0;scfsi_band<4;scfsi_band++)
				Header->scfsi[ch][scfsi_band]=getbits(Stream,1);
		for (gr=0;gr<ngr;gr++)
			for (ch=0;ch<nch;ch++)
			{
				part2_3_length[gr][ch]=getbits(Stream,12);
				big_values[gr][ch]=getbits(Stream,9);
				global_gain[gr][ch]=getbits(Stream,8);
				scalefac_compress[gr][ch]=getbits(Stream,4);
				window_switching_flag[gr][ch]=getbits(Stream,1);
				if (window_switching_flag[gr][ch])
				{
					block_type[gr][ch]=getbits(Stream,2);
					mixed_block_flag[gr][ch]=getbits(Stream,1);
					for (region=0;region<2;region++)
						table_select[gr][ch][region]=getbits(Stream,5);
					for (window=0;window<3;window++)
						subblock_gain[gr][ch][window]=getbits(Stream,3);
					if ((block_type[gr][ch]==2)&&(!mixed_block_flag[gr][ch]))
						region0_count[gr][ch]=8;
					else
						region0_count[gr][ch]=7;
					region1_count[gr][ch]=(21-(region0_count[gr][ch]+1));
				}
				else
				{
					block_type[gr][ch]=0;
					mixed_block_flag[gr][ch]=0;
					for (region=0;region<3;region++)
						table_select[gr][ch][region]=getbits(Stream,5);
					region0_count[gr][ch]=getbits(Stream,4);
					region1_count[gr][ch]=getbits(Stream,3);
				}
				preflag[gr][ch]=getbits(Stream,1);
				scalefac_scale[gr][ch]=getbits(Stream,1);
				count1table_select[gr][ch]=getbits(Stream,1);
			}
	}
	else
	{
		header_size=(4+(Header->protection_bit?0:2)+(nch==1?9:17));  
		frame_length=(((72000*bitrate[Header->VLSF|Header->ID][Header->layer][Header->bitrate_index])/sampling_frequency[Header->VLSF|Header->ID][Header->sampling_frequency])+Header->padding_bit);
		main_data_begin=getbits(Stream,8);
		if (Header->mode==0x03)
			private_bits=getbits(Stream,1);
		else
			private_bits=getbits(Stream,2);
		for (ch=0;ch<nch;ch++)
			for (scfsi_band=0;scfsi_band<4;scfsi_band++)
				Header->scfsi[ch][scfsi_band]=0;
		for (gr=0;gr<ngr;gr++)
		{
			for (ch=0;ch<nch;ch++)
			{
				part2_3_length[gr][ch]=getbits(Stream,12);
				big_values[gr][ch]=getbits(Stream,9);
				global_gain[gr][ch]=getbits(Stream,8);
				scalefac_compress[gr][ch]=getbits(Stream,9);
				window_switching_flag[gr][ch]=getbits(Stream,1);
				if (window_switching_flag[gr][ch])
				{
					block_type[gr][ch]=getbits(Stream,2);
					mixed_block_flag[gr][ch]=getbits(Stream,1);
					for (region=0;region<2;region++)
						table_select[gr][ch][region]=getbits(Stream,5);
					for (window=0;window<3;window++)
						subblock_gain[gr][ch][window]=getbits(Stream,3);
					if ((block_type[gr][ch]==2)&&(!mixed_block_flag[gr][ch]))
						region0_count[gr][ch]=8;
					else
						region0_count[gr][ch]=7;
					region1_count[gr][ch]=(21-(region0_count[gr][ch]+1));
				}
				else
				{
					block_type[gr][ch]=0;
					mixed_block_flag[gr][ch]=0;
					for (region=0;region<3;region++)
						table_select[gr][ch][region]=getbits(Stream,5);
					region0_count[gr][ch]=getbits(Stream,4);
					region1_count[gr][ch]=getbits(Stream,3);
				}
				preflag[gr][ch]=0;
				scalefac_scale[gr][ch]=getbits(Stream,1);
				count1table_select[gr][ch]=getbits(Stream,1);
			}
		}
	}
	if ((Header->main_data.WritePos>>3)>=main_data_begin)
		memcpy(Header->main_data.Data,Header->main_data.Data+(Header->main_data.WritePos>>3)-main_data_begin,main_data_begin);
	Header->main_data.WritePos=(main_data_begin<<3);
	Header->main_data.ReadPos=0;
	for (i=0;i<(frame_length-header_size);i++)
	{
		Header->main_data.Data[Header->main_data.WritePos>>3]=(unsigned char)getbits(Stream,8);
		Header->main_data.WritePos+=8;
	}
	for (gr=0;gr<ngr;gr++)
	{
		for (ch=0;ch<nch;ch++)
		{
			//Scalefactor decoding
			if (Header->ID)
			{
				//MPEG 1 scalefactors
				part2_base[gr][ch]=Header->main_data.ReadPos;
				intensity_scale=0;
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
				{
					if (mixed_block_flag[gr][ch])
					{
						for (sfb=0;sfb<8;sfb++)
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen1[scalefac_compress[gr][ch]]);
						for (sfb=3;sfb<6;sfb++)
							for (window=0;window<3;window++)
 								scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen1[scalefac_compress[gr][ch]]);
						for (sfb=6;sfb<12;sfb++)
							for (window=0;window<3;window++)
								scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen2[scalefac_compress[gr][ch]]);
  						for (window=0;window<3;window++)
							scalefac_s[gr][ch][sfb][window]=0;
					}
					else
					{
						for (sfb=0;sfb<6;sfb++)
							for (window=0;window<3;window++)
								scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen1[scalefac_compress[gr][ch]]);
						for (sfb=6;sfb<12;sfb++)
							for (window=0;window<3;window++)
								scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen2[scalefac_compress[gr][ch]]);
  						for (window=0;window<3;window++)
							scalefac_s[gr][ch][sfb][window]=0;
					}
				}
				else
				{
  					for (sfb=0;sfb<6;sfb++)
						if ((Header->scfsi[ch][0]==0)||(gr==0))
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen1[scalefac_compress[gr][ch]]);
						else
							scalefac_l[gr][ch][sfb]=scalefac_l[0][ch][sfb];
					for (sfb=6;sfb<11;sfb++)
	  					if ((Header->scfsi[ch][1]==0)||(gr==0))
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen1[scalefac_compress[gr][ch]]);
						else
							scalefac_l[gr][ch][sfb]=scalefac_l[0][ch][sfb];
					for (sfb=11;sfb<16;sfb++)
						if ((Header->scfsi[ch][2]==0)||(gr==0))
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen2[scalefac_compress[gr][ch]]);
						else
							scalefac_l[gr][ch][sfb]=scalefac_l[0][ch][sfb];
					for (sfb=16;sfb<21;sfb++)
						if ((Header->scfsi[ch][3]==0)||(gr==0))
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen2[scalefac_compress[gr][ch]]);
						else
							scalefac_l[gr][ch][sfb]=scalefac_l[0][ch][sfb];
					scalefac_l[gr][ch][sfb]=0;
				}
			}
			else
			{
				//MPEG 2 scalefactors
				part2_base[gr][ch]=Header->main_data.ReadPos;
				if (((Header->mode_extension==1)||(Header->mode_extension==3))&&(ch==1))
				{
					intensity_scale=scalefac_compress[gr][ch]&1;
					scalefac_compress[gr][ch]>>=1;
					if (scalefac_compress[gr][ch]<180)
					{
						slen[0]=(scalefac_compress[gr][ch]/36);
						slen[1]=(scalefac_compress[gr][ch]%36)/6;
						slen[2]=(scalefac_compress[gr][ch]%36)%6;
						slen[3]=0;
						blocknumber=3;
					}
					else if (scalefac_compress[gr][ch]<244)
					{
						slen[0]=((scalefac_compress[gr][ch]-180)>>4)&3;
						slen[1]=((scalefac_compress[gr][ch]-180)>>2)&3;
						slen[2]=((scalefac_compress[gr][ch]-180)&3);
						slen[3]=0;
						blocknumber=4;
					}
					else if (scalefac_compress[gr][ch]<256)
					{
						slen[0]=(scalefac_compress[gr][ch]-244)/3;
						slen[1]=(scalefac_compress[gr][ch]-244)%3;
						slen[2]=0;
						slen[3]=0;
						blocknumber=5;
					}
				}
				else
				{
					if (scalefac_compress[gr][ch]<400)
					{
						slen[0]=(scalefac_compress[gr][ch]>>4)/5;
						slen[1]=(scalefac_compress[gr][ch]>>4)%5;
						slen[2]=(scalefac_compress[gr][ch]>>2)&3;
						slen[3]=(scalefac_compress[gr][ch]&3);
						blocknumber=0;
					}
					else if (scalefac_compress[gr][ch]<500)
					{
						slen[0]=((scalefac_compress[gr][ch]-400)>>2)/5;
						slen[1]=((scalefac_compress[gr][ch]-400)>>2)%5;
						slen[2]=((scalefac_compress[gr][ch]-400)&3);
						slen[3]=0;
						blocknumber=1;
					}
					else if (scalefac_compress[gr][ch]<512)
					{
						slen[0]=(scalefac_compress[gr][ch]-500)/3;
						slen[1]=(scalefac_compress[gr][ch]-500)%3;
						slen[2]=0;
						slen[3]=0;
						preflag[gr][ch]=1;
						blocknumber=2;
					}
				}
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
				{
					if (mixed_block_flag[gr][ch])
					{
						for (sfb=0;sfb<6;sfb++)
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen[j]);
						k=6;
						sfb=3;
						for (j=0;j<4;j++)
						{
							for (;k<nr_of_sfb[blocknumber][2][j];k+=3)
							{
								for (window=0;window<3;window++)
 									scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen[j]);
								//if (ch) is_max[sfb+6]=(1<<slen[j])-1;
								sfb++;
							}
							k=0;
						}
  						for (window=0;window<3;window++)
							scalefac_s[gr][ch][sfb][window]=0;
					}
					else
					{
						sfb=0;
						for (j=0;j<4;j++)
						{
							for (k=0;k<nr_of_sfb[blocknumber][1][j];k+=3)
							{
								for (window=0;window<3;window++)
									scalefac_s[gr][ch][sfb][window]=getbits(&Header->main_data,slen[j]);
								//if (ch) is_max[sfb+6]=(1<<slen[j])-1;
								sfb++;
							}
						}
  						for (window=0;window<3;window++)
							scalefac_s[gr][ch][sfb][window]=0;
					}
				}
				else
				{
					sfb=0;
					for(j=0;j<4;j++)
					{
						for (k=0;k<nr_of_sfb[blocknumber][0][j];k++)
						{
							scalefac_l[gr][ch][sfb]=getbits(&Header->main_data,slen[j]);
							//if (ch) is_max[sfb]=(1<<slen[j])-1;
							sfb++;
						}
					}
					scalefac_l[gr][ch][sfb]=0;
				}
			}
			//Subband sample decoding (frequency lines)
			if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
			{
				region=0;
				region1=36; 
				region2=576;
			}	
			else
			{
				region=0;
				region1=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][region0_count[gr][ch]+1];
				region2=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][region0_count[gr][ch]+1+region1_count[gr][ch]+1];
			}
			if (big_values[gr][ch]>576/2) big_values[gr][ch]=576/2;
			for (l=0;l<big_values[gr][ch]*2;l+=2)
			{
				if (l==region1)	region++;
				if (l==region2)	region++;
				bigvalvalue=bigvaltable[table_select[gr][ch][region]][nextbits(&Header->main_data,8)];
				getbits(&Header->main_data,(bigvalvalue>>8)&0x7f);
				if (bigvalvalue&0x8000)
				{
					i=bigvalvalue&0xff;
					bigvalvalue=bigvaltable2[table_select[gr][ch][region]][i++];
 					while (((bigvalvalue>>16)&0xffff)!=nextbits(&Header->main_data,(bigvalvalue>>8)&0x7f))
						bigvalvalue=bigvaltable2[table_select[gr][ch][region]][i++];
					getbits(&Header->main_data,(bigvalvalue>>8)&0x7f);
				}
				x=(bigvalvalue>>4)&0x0f;
				y=(bigvalvalue)&0x0f;
				if ((x==15)&&(linbits[table_select[gr][ch][region]]))
					x+=getbits(&Header->main_data,linbits[table_select[gr][ch][region]]);
				if ((x)&&(getbits(&Header->main_data,1)))
					x=-x;
				if ((y==15)&&(linbits[table_select[gr][ch][region]]))
					y+=getbits(&Header->main_data,linbits[table_select[gr][ch][region]]);
				if ((y)&&(getbits(&Header->main_data,1)))
					y=-y;
				Header->maindata.is[gr][ch][l  ]=x;
				Header->maindata.is[gr][ch][l+1]=y;
			}
			count1[gr][ch]=0;
			while ((l<576)&&(Header->main_data.ReadPos<(part2_base[gr][ch]+part2_3_length[gr][ch])))
			{	
				count1value=count1table[count1table_select[gr][ch]][nextbits(&Header->main_data,6)];
				getbits(&Header->main_data,count1value>>4);
				v=(count1value>>3)&0x01;
				w=(count1value>>2)&0x01;
				x=(count1value>>1)&0x01;
				y=(count1value)&0x01;
				if ((v)&&(getbits(&Header->main_data,1)))
					v=-v;
				if ((w)&&(getbits(&Header->main_data,1)))
					w=-w;
				if ((x)&&(getbits(&Header->main_data,1)))
					x=-x;
				if ((y)&&(getbits(&Header->main_data,1)))
					y=-y;
				Header->maindata.is[gr][ch][l  ]=v;
				Header->maindata.is[gr][ch][l+1]=w;
				Header->maindata.is[gr][ch][l+2]=x;
				Header->maindata.is[gr][ch][l+3]=y;
				count1[gr][ch]++;
				l+=4;
			}
			for (;l<576;l++)
				Header->maindata.is[gr][ch][l  ]=0;
			if ((big_values[gr][ch]*2+count1[gr][ch]*4)>576)
				count1[gr][ch]=(576-big_values[gr][ch]*2)/4;
			Header->main_data.ReadPos=(part2_base[gr][ch]+part2_3_length[gr][ch]);
		}
	}
	for (b=0;b<0;b++)
		ancillary_bit=getbits(&Header->main_data,1);
	//Requantization
	for (gr=0;gr<ngr;gr++)
	{
		for (ch=0;ch<nch;ch++)
		{
			if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
			{
				sfb=l=0;
				if (mixed_block_flag[gr][ch])
				{
					while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<36)
					{
						scale=global_gain[gr][ch]-210;
						scale-=scalefac_l[gr][ch][sfb]<<(1+scalefac_scale[gr][ch]);
						for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
						{
							if (Header->maindata.is[gr][ch][l]<0)
								xr[gr][ch][l]=-REQUANT[-Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
							else
								xr[gr][ch][l]= REQUANT[ Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
						}
						sfb++;
					}
					sfb=3;
				}
				while ((ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3)<(big_values[gr][ch]*2+count1[gr][ch]*4))
				{
					for (window=0;window<3;window++)
					{
						scale=global_gain[gr][ch]-210-(subblock_gain[gr][ch][window]<<3);
						scale-=scalefac_s[gr][ch][sfb][window]<<(1+scalefac_scale[gr][ch]);
						for (i=ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3;i<ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1]*3;i+=3,l++)
						{
							if (Header->maindata.is[gr][ch][l]<0)
								xr[gr][ch][i+window]=-REQUANT[-Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
							else
								xr[gr][ch][i+window]= REQUANT[ Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
						}
					}
					sfb++;
				}
				for (;l<576;l++)
					xr[gr][ch][l]=0.0f;
			}
			else
			{
				sfb=l=0;
				while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<(big_values[gr][ch]*2+count1[gr][ch]*4))
				{
					scale=global_gain[gr][ch]-210;
					scale-=scalefac_l[gr][ch][sfb]<<(1+scalefac_scale[gr][ch]);
					if (preflag[gr][ch]) scale-=pretab[sfb]<<(1+scalefac_scale[gr][ch]);
					for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
					{
						if (Header->maindata.is[gr][ch][l]<0)
							xr[gr][ch][l]=-REQUANT[-Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
						else
							xr[gr][ch][l]= REQUANT[ Header->maindata.is[gr][ch][l]]*ASCALE[scale+346];
					}
					sfb++;
				}
				for (;l<576;l++)
					xr[gr][ch][l]=0.0f;
			}
		}
	}
	//Stereo processing
	if (Header->mode==0x01)
	{
		for (gr=0;gr<ngr;gr++)
		{
			if (Header->mode_extension&2)
			{
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
				{
					sfb=0;
					while ((ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3)<(big_values[gr][1]*2+count1[gr][1]*4))
					{
						for (l=ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3;l<ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1]*3;l+=3)
						{
							for (window=0;window<3;window++)
							{
								m=xr[gr][0][l+window];
								s=xr[gr][1][l+window];
								xr[gr][0][l+window]=((m+s)*0.70710678119f);
								xr[gr][1][l+window]=((m-s)*0.70710678119f);
							}
						}
						sfb++;
					}
				}
				else
				{
					sfb=0;
					while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<(big_values[gr][1]*2+count1[gr][1]*4))
					{
						for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
						{
							m=xr[gr][0][l];
							s=xr[gr][1][l];
							xr[gr][0][l]=((m+s)*0.70710678119f);
							xr[gr][1][l]=((m-s)*0.70710678119f);
						}
						sfb++;
					}
				}
			}
			if (Header->mode_extension&1)
			{
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
				{
					sfb=0;
					while ((ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3)<(big_values[gr][1]*2+count1[gr][1]*4)) sfb++;
					while ((ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3)<(big_values[gr][0]*2+count1[gr][0]*4))
					{
						for (window=0;window<3;window++)
						{
							if (scalefac_s[gr][1][sfb][window]!=7)
							{
								for (l=ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3;l<ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1]*3;l+=3)
								{
									xr[gr][1][l+window]=(xr[gr][0][l+window]*is_ratio[Header->ID][intensity_scale][1][scalefac_s[gr][1][sfb][window]]);
									xr[gr][0][l+window]=(xr[gr][0][l+window]*is_ratio[Header->ID][intensity_scale][0][scalefac_s[gr][1][sfb][window]]);
								}
							}
							else if (Header->mode_extension&2)
							{
								for (l=ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3;l<ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1]*3;l+=3)
								{
									m=xr[gr][0][l+window];
									s=xr[gr][1][l+window];
									xr[gr][0][l+window]=((m+s)*0.70710678119f);
									xr[gr][1][l+window]=((m-s)*0.70710678119f);
								}
							}
						}
						sfb++;
					}
				}
				else
				{
					sfb=0;
					while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<(big_values[gr][1]*2+count1[gr][1]*4)) sfb++;
					while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<(big_values[gr][0]*2+count1[gr][0]*4))
					{
						if (scalefac_l[gr][1][sfb]!=7)
						{
							for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
							{
								xr[gr][1][l]=(xr[gr][0][l]*is_ratio[Header->ID][intensity_scale][1][scalefac_l[gr][1][sfb]]);
								xr[gr][0][l]=(xr[gr][0][l]*is_ratio[Header->ID][intensity_scale][0][scalefac_l[gr][1][sfb]]);
							}
						}
						else if (Header->mode_extension&2)
						{
							for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
							{
								m=xr[gr][0][l];
								s=xr[gr][1][l];
								xr[gr][0][l]=((m+s)*0.70710678119f);
								xr[gr][1][l]=((m-s)*0.70710678119f);
							}
						}
						sfb++;
					}
				}
			}
			if (Header->mode_extension&2)
			{
				if ((window_switching_flag[gr][ch])&&(block_type[gr][ch]==2))
				{
					while ((ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3)<(big_values[gr][0]*2+count1[gr][0]*4))
					{
						for (l=ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb]*3;l<ssfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1]*3;l+=3)
						{
							for (window=0;window<3;window++)
							{
								m=xr[gr][0][l+window];
								s=xr[gr][1][l+window];
								xr[gr][0][l+window]=((m+s)*0.70710678119f);
								xr[gr][1][l+window]=((m-s)*0.70710678119f);
							}
						}
						sfb++;
					}
				}
				else
				{
					while ((lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb])<(big_values[gr][0]*2+count1[gr][0]*4))
					{
						for (l=lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb];l<lsfbands[Header->VLSF|Header->ID][Header->sampling_frequency][sfb+1];l++)
						{
							m=xr[gr][0][l];
							s=xr[gr][1][l];
							xr[gr][0][l]=((m+s)*0.70710678119f);
							xr[gr][1][l]=((m-s)*0.70710678119f);
						}
						sfb++;
					}
				}
			}
			big_values[gr][0]=big_values[gr][1]=(l/2);
			count1[gr][0]=count1[gr][1]=0;
		}
	}
	//IMDCT
	mdct(Header,xr,block_type,mixed_block_flag,window_switching_flag,big_values,count1);
}

//Syncronization function

static int sync(void *Stream)
{
	while ((!endofstream(Stream))&&(!bytealigned(Stream)))
		getbits(Stream,1);
	while ((!endofstream(Stream))&&(nextbits(Stream,11)!=0x7ff))
		getbits(Stream,8);
	return (!endofstream(Stream));
}

//Decode header

static void header(void *Stream,MPEGAudioStream *Header)
{
	Header->syncword=getbits(Stream,11);
	Header->VLSF=(getbits(Stream,1)^1)<<1;
	Header->ID=getbits(Stream,1);
	Header->layer=getbits(Stream,2);
	Header->protection_bit=getbits(Stream,1);
	Header->bitrate_index=getbits(Stream,4);
	Header->sampling_frequency=getbits(Stream,2);
	Header->padding_bit=getbits(Stream,1);
	Header->private_bit=getbits(Stream,1);
	Header->mode=getbits(Stream,2);
	Header->mode_extension=getbits(Stream,2);
	Header->copyright=getbits(Stream,1);
	Header->original=getbits(Stream,1);
	Header->emphasis=getbits(Stream,2);
}

//Decode CRC (if present)

static void error_check(void *Stream,MPEGAudioStream *Header)
{
	if (Header->protection_bit==0)
		Header->crc_check=getbits(Stream,16);
}

//Decode and synthesize main audio data

static void audio_data(void *Stream,MPEGAudioStream *Header)
{
	switch (Header->layer&0x03)
	{
		case 0x03:  
			audio_data_1(Stream,Header);
			if (glxMMXFound)
				mmxSubbandSynthesis(Header);
			else
				x86SubbandSynthesis(Header);
			break;
		case 0x02:
			audio_data_2(Stream,Header);
			if (glxMMXFound)
				mmxSubbandSynthesis(Header);
			else
				x86SubbandSynthesis(Header);
			break;
		case 0x01:
			audio_data_3(Stream,Header);
  			if (glxMMXFound)
  				mmxSubbandSynthesis(Header);
  			else
				x86SubbandSynthesis(Header);
			break;
		case 0x00:
			break;
	}
}

//Decode ancillary data

static void ancillary_data(void *Stream,MPEGAudioStream *Header)
{
	int ancillary_bit,b;
	
	if ((Header->layer==1)||(Header->layer==2))
		for (b=0;b<0;b++)
			ancillary_bit=getbits(Stream,1);
}

//Decode entire frame

static int decodeframe(void *Stream,MPEGAudioStream *Header)
{
	int Samples;
	
	if (sync(Stream))
	{
		header(Stream,Header);
		error_check(Stream,Header);
		audio_data(Stream,Header);
		ancillary_data(Stream,Header);
		if (Header->layer==3) 
			Samples=384;
		else if ((Header->layer==1)&&(!Header->ID)) 
			Samples=576;
		else Samples=1152;
		return Samples;
	}
	return 0;
}

//Matrix initialization function

static void glxInitMPA(void)
{
	int i;

	//Calculate scalefactors (layer 1 and 2)
	for (i=0;i<64;i++)
		SCALE[i]=(float)(pow(2.0,(3-i)/3.0));
	//Calculate all scaling (layer 3)
	for (i=-346;i<46;i++)
		ASCALE[i+346]=(float)(pow(2.0,i/4.0));
	//Calculate requantizer (layer 3)
	for (i=0;i<8192;i++)
		REQUANT[i]=(float)(pow(i,4.0/3.0));
}

//Decode block of data

int	__cdecl glxDecodeMPA(glxSample *Sample,void *MPEGStream,int MPEGStreamSize,short *LeftWaveStream,short *RightWaveStream,int WaveStreamSize,int *BytesRead,int *BytesWritten)
{
	int OutSamples,FrameSize,StreamPos;
	MPEGAudioStream *Header;
	BitStream Stream;

	if ((MPEGStream)&&(Sample))
	{
		//Initialize header
		Header=(MPEGAudioStream *)Sample->Articulation;
		//Initialize MPEG stream
		Stream.Data=MPEGStream;
		Stream.Size=MPEGStreamSize<<3;
		Stream.ReadPos=0;
		Stream.WritePos=0;
		//Initialize WAVE stream (assume 16 bit samples)
		WaveStreamSize>>=1;
		*BytesRead=0;
		*BytesWritten=0;
		//First try syncronizing
		if (sync(&Stream))
		{
			//preprocess header (sampling_frequency etc.) 
			StreamPos=Stream.ReadPos;
			header(&Stream,Header);
			Stream.ReadPos=StreamPos;
			//Calculate complete frames in stream and resize stream
			if ((Header->layer&0x03)==0x03)
				FrameSize=((32*12000*bitrate[Header->VLSF|Header->ID][Header->layer][Header->bitrate_index])/sampling_frequency[Header->VLSF|Header->ID][Header->sampling_frequency]);
			else
				FrameSize=((8*144000*bitrate[Header->VLSF|Header->ID][Header->layer][Header->bitrate_index])/sampling_frequency[Header->VLSF|Header->ID][Header->sampling_frequency]);
			if (!Header->ID) FrameSize/=2;
			if (FrameSize) Stream.Size=(((Stream.Size-Stream.ReadPos)/FrameSize)*FrameSize)+Stream.ReadPos;
			//Start decoding the requested amounth of samples
			while ((WaveStreamSize)&&(!endofstream(&Stream)))
			{
				if (!Header->Samples)
				{
					Header->Samples=decodeframe(&Stream,Header);
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
						if (Header->mode==3)
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
			*BytesRead=(Stream.ReadPos>>3);
			return GLXERR_NOERROR;
		}
		return GLXERR_DAMAGEDFILE;
	}
	else if (Sample)
	{
		//Initialize header
		Header=(MPEGAudioStream *)Sample->Articulation=getmem(sizeof(MPEGAudioStream));
		memset(Header,0,sizeof(MPEGAudioStream));
		Header->main_data.Data=Header->main_buffer;
		return GLXERR_NOERROR;
	}
	return GLXERR_NOERROR;
}

glxSample * __cdecl glxLoadMPA(glxSample *Sample,void *Stream,int Flags)
{
	MPEGAudioStream Header;
	BitStream TestStream;

	//Initialise MPEG audio engine
	glxInitMPA();
	//Initialise/Reset decoding allocate MPEG local data
	glxDecodeMPA(Sample,NULL,0,NULL,NULL,0,NULL,NULL);
	//Initialize bitstream (first 16kB only)
	TestStream.Data=malloc(16384);
	TestStream.Size=(read(TestStream.Data,1,16384,Stream)<<3);
	TestStream.ReadPos=0;
	TestStream.WritePos=0;
	seek(Stream,-TestStream.Size>>3,SEEK_CUR);
	//Scan stream for 12 bit sync word
	if (sync(&TestStream))
	{
		//preprocess first header (sampling_frequency etc.)
		header(&TestStream,&Header);
		//setup mpeg audio test stuff
		Sample->FourCC=GLX_FOURCC_SAMP;
		Sample->Size=sizeof(glxSample)-8;
		Sample->Panning=GLX_MIDSMPPANNING;
		Sample->Volume=GLX_MAXSMPVOLUME;
		Sample->Type=((Header.mode==3)?(GLX_MPEGAUDIO|GLX_PANNING|GLX_16BITSAMPLE):(GLX_MPEGAUDIO|GLX_STEREOSAMPLE|GLX_16BITSAMPLE));
		seek(Stream,0,SEEK_END);
		Sample->Length=tell(Stream);
		seek(Stream,-Sample->Length,SEEK_CUR);
		Sample->LoopStart=0;
		Sample->LoopEnd=0;
		Sample->C4Speed=sampling_frequency[Header.VLSF|Header.ID][Header.sampling_frequency];
		if (Flags&GLX_LOADASSTREAMING)
		{
			Sample->Type|=GLX_STREAMINGAUDIO;
			Sample->Reserved=32768;
			Sample->Data=getmem(Sample->Reserved);
		}
		else if (Sample->Data=getmem(Sample->Length))
		{
			Sample->Reserved=32768;
			read(Sample->Data,1,Sample->Length,Stream);
		}
		free(TestStream.Data);
		return Sample;
	}
	free(TestStream.Data);
	return NULL;
}
