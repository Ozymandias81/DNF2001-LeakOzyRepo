/*ƒ- Internal revision no. 5.00b -ƒƒƒƒ Last revision at 17:26 on 29-09-1999 -ƒƒ

                           The 32 bit Win32 C Source

                €€€ﬂﬂ€€€ €€€ﬂ€€€ €€€    €€€ﬂ€€€ €€€  €€€ €€€ €€€
                €€€  ﬂﬂﬂ €€€ €€€ €€€    €€€ €€€  ﬂ€€€€ﬂ  €€€ €€€
                €€€ ‹‹‹‹ €€€‹€€€ €€€    €€€‹€€€    €€     ﬂ€€€ﬂ
                €€€  €€€ €€€ €€€ €€€    €€€ €€€  ‹€€€€‹    €€€
                €€€‹‹€€€ €€€ €€€ €€€‹‹‹ €€€ €€€ €€€  €€€   €€€

                                MUSIC SYSTEM 
                This document contains confidential information
                     Copyright (c) 1993-99 Carlo Vogelsang

  ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
  ≥€≤± COPYRIGHT NOTICE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±≤€≥
  √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
  ≥ This source file, GALAXY.C is Copyright (c) 1993-99  by  Carlo Vogelsang. ≥
  ≥ You may not copy, distribute,  duplicate or clone this file  in any form, ≥
  ≥ modified or non-modified. It belongs to the author.  By copying this file ≥
  ≥ you are violating laws and will be punished. I will knock your brains in  ≥
  ≥ myself or you will be sued to death..                                     ≥
  ≥                                                                     Carlo ≥
  ¿ƒ( How the fuck did you get this file anyway? )ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
*/

#include <math.h>
#include <windows.h>                            // Windows (tm) functions
#include <mmsystem.h>                           // Win-MM functions
#include <dsound.h>								// DirectSound functions
#include <initguid.h>							// Initialize all following GUIDs
#include "hdr\eax.h"							// Creative EAX functions
#include "hdr\eax2.h"							// Creative EAX 2.x functions
#include "hdr\eaxman.h"							// Creative EAX Manager functions
//#include "hdr\ia3d.h"							// Aureal A3D functions
#include "hdr\ia3dapi.h"						// Aureal A3D 2.0 functions
#include "hdr\galaxy.h"                         // Galaxy functions etc.
#include "hdr\loaders.h"						// Galaxy I/O routines
#include "hdr\glx-ima.h"						// Galaxy IMA Audio
#include "hdr\glx-mpa.h"						// Galaxy MPEG Audio
#include "hdr\glx-wav.h"						// Galaxy WAVE Audio

#include "eax.c"

/* Types */

#pragma pack (push,1) 							/* Turn off alignment */

typedef struct
{
  udword	 fourcc;
  udword	 time;
  sdword	 td0;
  sdword     td1;
  sdword	 td2;
  sdword	 td3;
  sdword	 td4;
  sdword	 td5;
  sword		 apf0gain2;
  sword		 apf0gain0;
  sword		 apf1gain2;
  sword		 apf1gain0;
  sword		 apf2gain2;
  sword		 apf2gain0;
  sword		 apf3gain2;
  sword		 apf3gain0;
  sword		 apf4gain2;
  sword		 apf4gain0;
  sword		 apf5gain2;
  sword		 apf5gain0;
  sword		 apf0gain1;
  sword		 apf1gain1;
  sword		 apf2gain1;
  sword		 apf3gain1;
  sword		 apf4gain1;
  sword		 apf5gain1;
  sword	     reserved[2];
  sword		 apf0lpfa;
  sword		 apf0lpfb;
  sword		 apf1lpfa;
  sword		 apf1lpfb;
  sword		 apf2lpfa;
  sword		 apf2lpfb;
  sword		 apf3lpfa;
  sword		 apf3lpfb;
  sword		 apf4lpfa;
  sword		 apf4lpfb;
  sword		 apf5lpfa;
  sword		 apf5lpfb;
  sword	     apf0lpfout;
  sword	     apf1lpfout;
  sword		 apf2lpfout;
  sword		 apf3lpfout;
  sword		 apf4lpfout;
  sword 	 apf5lpfout;
  sword		 leftout;
  sword		 rightout;
  sword		 dryleft;
  sword		 wetleft;
  sword		 dryright;
  sword		 wetright;
  sword		 buf01[16384   ][2];
  sword		 buf23[16384+16][2];
  sword		 buf45[16384+32][2];
} glxMMXReverb;

typedef struct
{
  udword	 fourcc;
  udword	 time;
  sdword	 td0;
  sdword     td1;
  sdword	 td2;
  sdword	 td3;
  sdword	 td4;
  sdword	 td5;
  float		 apf0gain0;
  float		 apf1gain0;
  float		 apf2gain0;
  float		 apf3gain0;
  float		 apf4gain0;
  float		 apf5gain0;
  float		 apf0gain1;
  float		 apf1gain1;
  float		 apf2gain1;
  float		 apf3gain1;
  float		 apf4gain1;
  float		 apf5gain1;
  float		 apf0gain2;
  float		 apf1gain2;
  float		 apf2gain2;
  float		 apf3gain2;	
  float		 apf4gain2;	
  float		 apf5gain2;	
  float		 apf0lpfa;
  float		 apf1lpfa;
  float		 apf2lpfa;
  float		 apf3lpfa;
  float		 apf4lpfa;
  float		 apf5lpfa;
  float		 apf0lpfb;
  float		 apf1lpfb;
  float		 apf2lpfb;
  float		 apf3lpfb;
  float		 apf4lpfb;
  float		 apf5lpfb;
  float	     apf0lpfout;
  float	     apf1lpfout;
  float		 apf2lpfout;
  float		 apf3lpfout;
  float		 apf4lpfout;
  float		 apf5lpfout;
  float		 leftout;  
  float		 rightout; 
  float		 wetleft;  
  float		 wetright; 
  float		 dryleft;  
  float		 dryright;  
  float		 buf01[16384   ][2];
  float		 buf23[16384+ 8][2];
  float		 buf45[16384+16][2];
} glxK3DReverb;

typedef struct
{
  udword	 fourcc;
  udword	 time;
  sdword	 td0;
  sdword     td1;
  sdword	 td2;
  sdword	 td3;
  sdword	 td4;
  sdword	 td5;
  float		 apf0gain0;
  float		 apf1gain0;
  float		 apf2gain0;
  float		 apf3gain0;
  float		 apf4gain0;
  float		 apf5gain0;
  float		 apf0gain1;
  float		 apf1gain1;
  float		 apf2gain1;
  float		 apf3gain1;
  float		 apf4gain1;
  float		 apf5gain1;
  float		 apf0gain2;
  float		 apf1gain2;
  float		 apf2gain2;
  float		 apf3gain2;	
  float		 apf4gain2;	
  float		 apf5gain2;	
  float		 apf0lpfa;
  float		 apf1lpfa;
  float		 apf2lpfa;
  float		 apf3lpfa;
  float		 apf4lpfa;
  float		 apf5lpfa;
  float		 apf0lpfb;
  float		 apf1lpfb;
  float		 apf2lpfb;
  float		 apf3lpfb;
  float		 apf4lpfb;
  float		 apf5lpfb;
  float	     apf0lpfout;
  float	     apf1lpfout;
  float		 apf2lpfout;
  float		 apf3lpfout;
  float		 apf4lpfout;
  float		 apf5lpfout;
  float		 leftout;  
  float		 rightout; 
  float		 wetleft;  
  float		 wetright; 
  float		 dryleft;  
  float		 dryright;  
  float		 buf01[16384   ][2];
  float		 buf23[16384+ 8][2];
  float		 buf45[16384+16][2];
} glxKNIReverb;

typedef struct 
{
  udword	 FourCC;
  udword	 Time;
  udword	 Volume;
  sdword	 Delay1;
  sdword	 Delay2;
  sdword	 Delay3;
  sdword	 Delay4;
  sdword	 Delay5;
  sdword	 Delay6;
  sword		 Delay1Gain;
  sword		 Delay2Gain;
  sword		 Delay3Gain;
  sword		 Delay4Gain;
  sword		 Delay5Gain;
  sword		 Delay6Gain;
  sword		 LPFOut[2];
  sword		 LPF[2];
  sword	     Buffer[32768];
} glxMMXEffect;

typedef struct
{
  udword	 FourCC;
  udword	 Time;
  sdword	 Delay;
  sdword	 Depth;
  sdword     Speed;
  udword	 Phase0;
  udword	 Phase1;
  sword      Feedbackleft;
  sword      Feedbackright;
  sword		 leftout;
  sword		 rightout;
  sword		 dryleft;
  sword		 wetleft;
  sword		 dryright;
  sword		 wetright;
  sword		 buf01[16384][2];
  sdword	 wave[1024];
} glxMMXChorus;

typedef struct
{
  udword	 FourCC;
  udword	 Time;
  sdword	 Delay;
  sdword	 Depth;
  sdword     Speed;
  udword	 Phase0;
  udword	 Phase1;
  float      Feedbackleft;
  float		 Feedbackright;
  float		 leftout;  
  float		 rightout; 
  float		 wetleft;
  float		 wetright;
  float		 dryleft;
  float		 dryright;
  float		 buf01[16384][2];
  sdword	 wave[1024];
} glxK3DChorus;

typedef struct
{
  udword	 FourCC;
  udword	 Time;
  sdword	 Delay;
  sdword	 Depth;
  sdword     Speed;
  udword	 Phase0;
  udword	 Phase1;
  float      Feedbackleft;
  float		 Feedbackright;
  float		 leftout;  
  float		 rightout; 
  float		 wetleft;
  float		 wetright;
  float		 dryleft;
  float		 dryright;
  float		 buf01[16384][2];
  sdword	 wave[1024];
} glxKNIChorus;

#pragma pack (pop)								/* Default alignment */
		
/* Uninitialised internal variables */

glxOutput       glxAudioOutput;					// Audiooutput structure
glxBuffer       glxAudioBuffer;	                // Audiobuffer structure
glxVoice        glxVoices[GLX_TOTALVOICES];		// Voice structures
glxChannel	    glxChannels[GLX_TOTALCHANNELS];	// Channel structures
ubyte           glxSongName[32];	  			// ASCIIZ Name of song
ubyte           glxAuthorName[32];				// ASCIIZ Name of author
ubyte           glxPlayerMode;					// Period/note system etc.
ubyte			glxMusicVoices;					// Music voices to be used
uword           glxInitialSpeed;				// Default 48 (Ticks per beat)
uword           glxInitialTempo;				// Default 120 (Beats per min)
uword           glxMinPeriod;  					// Minimum period allowed
uword           glxMaxPeriod;  					// Maximum period allowed
ubyte           glxInitialPanning[256];         // Initial panning data
ubyte           glxSampleVoices;				// Sample voices to be used
ubyte           glxSongLength;					// Length of song base zero
ubyte           glxOrders[256];	                // 256 Orders max.
glxPattern *    glxPatterns[256];	            // 256 Patterns max.
glxInstrument * glxInstruments[2][128];         // 128 Instruments/bank
glxPattern *	glxCurrentPtr;                  // Current data
volatile uword  glxCurrentTime;                 // Current time
volatile ubyte  glxPatternRow;                  // Pattern row
volatile ubyte  glxPatternBreak;				// Pattern break flag
volatile uword  glxCurrentTempo;				// Current beats per min
volatile uword  glxCurrentSpeed;				// Current ticks per row
volatile ubyte  glxCurrentOrder;				// Current order
volatile udword glxCurrentTick;					// Current tick
volatile udword glxCurrentSample;				// Current sample
volatile ubyte  glxPatternDelay;                // Current delay value
volatile ubyte  glxPatternLength;               // Current length
volatile ubyte  glxPatternBreakCnt;             // Rows to skip
volatile ubyte  glxPatternLStart;				// Loop start row
volatile ubyte  glxPatternLCount;             	// Loops left
volatile sbyte  glxMusicVolume;					// 128 Levels
volatile sbyte  glxMusicVolSlide;               // Volume slide step
volatile sbyte  glxMusicVolDest;                // Destination volume
volatile sbyte  glxSampleVolume;				// 128 Levels
volatile sbyte  glxSampleVolSlide;              // Volume slide step
volatile sbyte  glxSampleVolDest;               // Destination volume
volatile sbyte  glxCDVolume;                    // 128 Levels
volatile ubyte  glxMusicEnabled;				// Music enabled flag
volatile ubyte  glxOutputActive;                // Output active flag
volatile ubyte  glxMusicLooping;                // Music looping flag
volatile udword glxSamplingrate;				// Sampling/mixing rate

char *          glxBufferBase;					// Pointer to DSP Buffer
char *          glxBufferBase1;                 // Pointer to DSP Buffer 1
char *          glxBufferBase2;                 // Pointer to DSP Buffer 2
char *          glxBufferBase3;                 // Pointer to DSP Buffer 3
char *          glxBufferBase4;                 // Pointer to DSP Buffer 4
char *          glxBufferBase5;                 // Pointer to DSP Buffer 5
char *          glxBufferBase6;                 // Pointer to DSP Buffer 6
glxReverb       glxMusicReverb;					// Reverb desc. for music
glxReverb       glxSampleReverb;				// Reverb desc. for samples
glxChorus       glxMusicChorus;					// Chorus desc. for music
glxChorus       glxSampleChorus;				// Chorus desc. for samples
long			glxTimer1Count;					// DSP Timer 1 (count)
long			glxTimer1Period;				// DSP Timer 1 : Envelopes
long            glxTimer2Count;                 // DSP Timer 2 (count)
long            glxTimer2Period;                // DSP Timer 2 : Notes etc.
short *			glxPanningFunction;				// Panning function

sdword *        glxVolumeTableBase;             // Pointer to VolumeTable
sbyte *         glxIntTableBase;                // Pointer to FilterTable
void (__cdecl * glxMixerCodeBase)();            // Pointer to Mixingcode
void (__cdecl * glxPostProcBase)();             // Pointer to PostProc code
ubyte *         glxPostProcTable;               // Pointer to ClipTable
char *          glxVersionID;                   // Version ID string
char *          glxDriverID;                    // Driver ID string
ubyte           glxMMXFound;                    // MMX Flag
ubyte			glxK3DFound;					// 3DNow Flag
ubyte			glxKNIFound;					// KNI Flag
ubyte           glxMixerType;                   // Mixer type
glxCallback *   glxCallbackFunction;            // Callback function

LPEAXMANAGER	glxEaxManager;					// EAXManager object

/* Platform specific */

static CRITICAL_SECTION glxWorking;             // Working semaphore
static HANDLE			glxDecodeThreadHnd=NULL;// Decode thread handle
static DWORD			glxDecodeThreadID=0;	// Decode thread ID
static WAVEFORMATEX		OutputType;	   	  		// Digital output format
static DWORD			EfxMixAhead=40;         // FX Mixahead in MSec
static UINT				CDRomID=0;              // CD Player MCI ID
static UINT				TimerID=0;              // MM Timer ID

/* Initialised internal tables */

static const int FilterResp[2][17]={ 
	64,60,56,52,48,44,40,36,// Linear coefficients
    32,
    28,24,20,16,12,8,4,0,
    64,63,62,59,55,50,44,38,// Cosine coefficients
    32,
    26,20,14,9,5,2,1,0};

static const int WaveTables[3][64]={ 
	{0,24,49,74,97,120,141,161,180,197,212,224,235,244,
     250,253,255,253,250,244,235,224,212,197,180,161,
     141,120,97,74,49,24,
     0,-24,-49,-74,-97,-120,-141,-161,-180,-197,-212,
     -224,-235,-244,-250,-253,-255,-253,-250,-244,
     -235,-224,-212,-197,-180,-161,-141,-120,-97,
     -74,-49,-24},
    {255,247,239,231,223,215,206,198,190,182,174,166,158,
     150,142,134,125,117,109,101,93,85,77,69,61,53,45,
     36,28,20,12,4,
     -4,-12,-20,-28,-36,-45,-53,-61,-69,-77,-85,-93,
     -101,-109,-117,-125,-134,-142,-150,-158,-166,-174,
     -182,-190,-198,-206,-215,-223,-231,-239,-247,-255},
    {255,255,255,255,255,255,255,255,255,255,255,255,
     255,255,255,255,255,255,255,255,255,255,255,255,
     255,255,255,255,255,255,255,255,
     -255,-255,-255,-255,-255,-255,-255,-255,-255,-255,
     -255,-255,-255,-255,-255,-255,-255,-255,-255,-255,
     -255,-255,-255,-255,-255,-255,-255,-255,-255,-255,
     -255,-255} };

static const int LogTable[120]={ 
	65280,65280,65280,65280,65280,65280,65280,65280,
    65280,65280,65280,65280,
    65280,65280,65280,65280,65280,65280,65280,65280,
	65280,65150,61493,58042,
    54784,51709,48807,46068,43482,41042,38738,36564,
    34512,32575,30746,29021,
	27392,25855,24403,23034,21741,20521,19369,18282,
    17256,16287,15373,14510,
    13696,12927,12202,11517,10871,10260,9685,9141,
    8628,8144,7687,7255,
    6848,6464,6101,5758,5435,5130,4842,4570,
    4314,4072,3843,3628,
    3424,3232,3050,2879,2718,2565,2421,2285,
    2157,2036,1922,1814,
    1712,1616,1525,1440,1359,1283,1211,1143,
    1078,1018,961,907,
    856,808,763,720,679,641,605,571,
    539,509,480,453,
    428,404,382,360,340,321,303,286,
    270,255,240,227};

static const int LinearTable[768]={ 
	32768, 32738, 32708, 32679, 32649, 32620, 32591, 32561,
    32532, 32502, 32473, 32444, 32415, 32385, 32356, 32327,
    32298, 32269, 32239, 32210, 32181, 32152, 32123, 32094,
    32065, 32036, 32008, 31979, 31950, 31921, 31892, 31863,
    31835, 31806, 31777, 31749, 31720, 31691, 31663, 31634,
    31606, 31577, 31549, 31520, 31492, 31463, 31435, 31407,
    31378, 31350, 31322, 31293, 31265, 31237, 31209, 31181,
    31152, 31124, 31096, 31068, 31040, 31012, 30984, 30956,
    30928, 30900, 30873, 30845, 30817, 30789, 30761, 30734,
    30706, 30678, 30650, 30623, 30595, 30568, 30540, 30512,
    30485, 30457, 30430, 30403, 30375, 30348, 30320, 30293,
    30266, 30238, 30211, 30184, 30157, 30129, 30102, 30075,
    30048, 30021, 29994, 29967, 29940, 29913, 29886, 29859,
    29832, 29805, 29778, 29751, 29724, 29697, 29671, 29644,
    29617, 29590, 29564, 29537, 29510, 29484, 29457, 29431,
    29404, 29377, 29351, 29325, 29298, 29272, 29245, 29219,
    29192, 29166, 29140, 29114, 29087, 29061, 29035, 29009,
    28982, 28956, 28930, 28904, 28878, 28852, 28826, 28800,
    28774, 28748, 28722, 28696, 28670, 28644, 28619, 28593,
    28567, 28541, 28515, 28490, 28464, 28438, 28413, 28387,
    28361, 28336, 28310, 28285, 28259, 28234, 28208, 28183,
    28157, 28132, 28107, 28081, 28056, 28031, 28005, 27980,
    27955, 27930, 27904, 27879, 27854, 27829, 27804, 27779,
    27754, 27729, 27704, 27679, 27654, 27629, 27604, 27579,
    27554, 27529, 27504, 27479, 27455, 27430, 27405, 27380,
    27356, 27331, 27306, 27282, 27257, 27233, 27208, 27183,
    27159, 27134, 27110, 27086, 27061, 27037, 27012, 26988,
    26964, 26939, 26915, 26891, 26866, 26842, 26818, 26794,
    26770, 26745, 26721, 26697, 26673, 26649, 26625, 26601,
    26577, 26553, 26529, 26505, 26481, 26457, 26433, 26410,
    26386, 26362, 26338, 26314, 26291, 26267, 26243, 26220,
    26196, 26172, 26149, 26125, 26102, 26078, 26054, 26031,
    26007, 25984, 25961, 25937, 25914, 25890, 25867, 25844,
    25820, 25797, 25774, 25751, 25727, 25704, 25681, 25658,
    25635, 25611, 25588, 25565, 25542, 25519, 25496, 25473,
    25450, 25427, 25404, 25381, 25358, 25336, 25313, 25290,
    25267, 25244, 25222, 25199, 25176, 25153, 25131, 25108,
    25085, 25063, 25040, 25017, 24995, 24972, 24950, 24927,
    24905, 24882, 24860, 24837, 24815, 24793, 24770, 24748,
    24726, 24703, 24681, 24659, 24637, 24614, 24592, 24570,
    24548, 24526, 24503, 24481, 24459, 24437, 24415, 24393,
    24371, 24349, 24327, 24305, 24283, 24261, 24240, 24218,
    24196, 24174, 24152, 24130, 24109, 24087, 24065, 24043,
    24022, 24000, 23978, 23957, 23935, 23914, 23892, 23870,
    23849, 23827, 23806, 23784, 23763, 23742, 23720, 23699,
    23677, 23656, 23635, 23613, 23592, 23571, 23549, 23528,
    23507, 23486, 23465, 23443, 23422, 23401, 23380, 23359,
    23338, 23317, 23296, 23275, 23254, 23233, 23212, 23191,
    23170, 23149, 23128, 23107, 23086, 23066, 23045, 23024,
    23003, 22983, 22962, 22941, 22920, 22900, 22879, 22858,
    22838, 22817, 22797, 22776, 22755, 22735, 22714, 22694,
    22673, 22653, 22633, 22612, 22592, 22571, 22551, 22531,
    22510, 22490, 22470, 22449, 22429, 22409, 22389, 22369,
    22348, 22328, 22308, 22288, 22268, 22248, 22228, 22208,
    22188, 22168, 22148, 22128, 22108, 22088, 22068, 22048,
    22028, 22008, 21988, 21968, 21949, 21929, 21909, 21889,
    21870, 21850, 21830, 21810, 21791, 21771, 21751, 21732,
    21712, 21693, 21673, 21653, 21634, 21614, 21595, 21575,
    21556, 21537, 21517, 21498, 21478, 21459, 21440, 21420,
    21401, 21382, 21362, 21343, 21324, 21305, 21285, 21266,
    21247, 21228, 21209, 21189, 21170, 21151, 21132, 21113,
    21094, 21075, 21056, 21037, 21018, 20999, 20980, 20961,
    20942, 20923, 20905, 20886, 20867, 20848, 20829, 20810,
    20792, 20773, 20754, 20735, 20717, 20698, 20679, 20661,
    20642, 20623, 20605, 20586, 20568, 20549, 20531, 20512,
    20494, 20475, 20457, 20438, 20420, 20401, 20383, 20364,
    20346, 20328, 20309, 20291, 20273, 20254, 20236, 20218,
    20200, 20181, 20163, 20145, 20127, 20109, 20091, 20073,
    20054, 20036, 20018, 20000, 19982, 19964, 19946, 19928,
    19910, 19892, 19874, 19856, 19838, 19820, 19803, 19785,
    19767, 19749, 19731, 19713, 19696, 19678, 19660, 19642,
    19625, 19607, 19589, 19572, 19554, 19536, 19519, 19501,
    19483, 19466, 19448, 19431, 19413, 19396, 19378, 19361,
    19343, 19326, 19308, 19291, 19274, 19256, 19239, 19221,
    19204, 19187, 19169, 19152, 19135, 19118, 19100, 19083,
    19066, 19049, 19032, 19014, 18997, 18980, 18963, 18946,
    18929, 18912, 18895, 18878, 18861, 18844, 18827, 18810,
    18793, 18776, 18759, 18742, 18725, 18708, 18691, 18674,
    18657, 18641, 18624, 18607, 18590, 18573, 18557, 18540,
    18523, 18506, 18490, 18473, 18456, 18440, 18423, 18407,
    18390, 18373, 18357, 18340, 18324, 18307, 18291, 18274,
    18258, 18241, 18225, 18208, 18192, 18175, 18159, 18143,
    18126, 18110, 18094, 18077, 18061, 18045, 18028, 18012,
    17996, 17980, 17963, 17947, 17931, 17915, 17899, 17883,
    17866, 17850, 17834, 17818, 17802, 17786, 17770, 17754,
    17738, 17722, 17706, 17690, 17674, 17658, 17642, 17626,
    17610, 17594, 17578, 17563, 17547, 17531, 17515, 17499,
    17484, 17468, 17452, 17436, 17421, 17405, 17389, 17373,
    17358, 17342, 17326, 17311, 17295, 17280, 17264, 17248,
    17233, 17217, 17202, 17186, 17171, 17155, 17140, 17124,
    17109, 17093, 17078, 17063, 17047, 17032, 17016, 17001,
    16986, 16970, 16955, 16940, 16925, 16909, 16894, 16879,
    16864, 16848, 16833, 16818, 16803, 16788, 16773, 16757,
    16742, 16727, 16712, 16697, 16682, 16667, 16652, 16637,
    16622, 16607, 16592, 16577, 16562, 16547, 16532, 16517,
    16502, 16487, 16472, 16458, 16443, 16428, 16413, 16398};

/* Internal routines prototypes */

void  glxArpeggio(glxVoice *Voice);
void  glxSlideUp(glxVoice *Voice);
void  glxSlideDown(glxVoice *Voice);
void  glxSlideNote(glxVoice *Voice);
void  glxVibrato(glxVoice *Voice);
void  glxVolSlideNote(glxVoice *Voice);
void  glxVolVibrato(glxVoice *Voice);
void  glxTremolo(glxVoice *Voice);
void  glxPanning(glxVoice *Voice);
void  glxSampleOffset(glxVoice *Voice);
void  glxSlideVol(glxVoice *Voice);
void  glxPosJump(glxVoice *Voice);
void  glxSetVol(glxVoice *Voice);
void  glxPattBreak(glxVoice *Voice);
void  glxExtended(glxVoice *Voice);
void  glxSetFilter(glxVoice *Voice);
void  glxFineSlideUp(glxVoice *Voice);
void  glxFineSlideDown(glxVoice *Voice);
void  glxGlissando(glxVoice *Voice);
void  glxSetVibWave(glxVoice *Voice);
void  glxSetFinetune(glxVoice *Voice);
void  glxPattLoop(glxVoice *Voice);
void  glxSetTremWave(glxVoice *Voice);
void  glxFinePanning(glxVoice *Voice);
void  glxRetrigger(glxVoice *Voice);
void  glxFineVolUp(glxVoice *Voice);
void  glxFineVolDown(glxVoice *Voice);
void  glxNoteCut(glxVoice *Voice);
void  glxNoteDelay(glxVoice *Voice);
void  glxPattDelay(glxVoice *Voice);
void  glxInvertLoop(glxVoice *Voice);
void  glxSetSpeed(glxVoice *Voice);

void  glxUpdateMusic(void);
void  glxUpdateInstruments(void);
void  glxUpdateStreams(void);
void  glxUpdateVolumes(void);

/* External routines prototypes */

extern void * __cdecl k3dMixerInit(int MixerType,void *VBase,void *MBase);
extern void * __cdecl mmxMixerInit(int MixerType,void *VBase,void *MBase);
extern void * __cdecl x86MixerInit(int MixerType,void *VBase,void *MBase);
extern void * __cdecl kniMixerInit(int MixerType,void *Vbase,void *MBase);
extern int    __cdecl mmxChorus(glxMMXChorus *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl mmxReverb(glxMMXReverb *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl k3dChorus(glxK3DChorus *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl k3dReverb(glxK3DReverb *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl kniChorus(glxKNIChorus *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl kniReverb(glxKNIReverb *Reverb,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);
extern int    __cdecl mmxEffect(glxMMXEffect *Effect,char *DSPDestBuffer,char *DSPSourceBuffer,int DSPBufferSize,int Flags);

extern LPKSPROPERTYSET EAXCreate(LPDIRECTSOUND pDS);
extern void EAXSet(LPKSPROPERTYSET pEAX,double roomSize,double volume,double decayTime, double lpfCoefficient,double apfGain);

#define bound(value,min,max) ((value)<(min)?(min):((value)>(max)?(max):(value)))

/* Internal routines */

int __cdecl glxSetEAXManager(LPEAXMANAGER EaxMan)
{
	glxLock();
	glxEaxManager=EaxMan;
	glxUnlock();
	return GLXERR_NOERROR;
}

static int __cdecl glxInitA3D(void)
{
	// Setup for A3D 1.x
	if (CoCreateInstance(&CLSID_A3d,NULL,CLSCTX_INPROC_SERVER,&IID_IDirectSound,&glxAudioOutput.Handle)==S_OK)
	{
		return GLXERR_NOERROR;
	}
	glxAudioOutput.Handle=NULL;
	return GLXERR_UNSUPPORTEDDEVICE;
}

static int __cdecl glxInitA3D2(void)
{
	// Setup for A3D 2.0
	if (CoCreateInstance(&CLSID_A3dApi,NULL,CLSCTX_INPROC_SERVER,&IID_IA3d4,&glxAudioOutput.Extensions)==S_OK)
	{
		if (((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Init((LPA3D4)glxAudioOutput.Extensions,NULL,A3D_1ST_REFLECTIONS|A3D_OCCLUSIONS|A3D_DISABLE_SPLASHSCREEN,A3DRENDERPREFS_DEFAULT)==S_OK)
		{
			if (((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->IsFeatureAvailable((LPA3D4)glxAudioOutput.Extensions,A3D_1ST_REFLECTIONS)==A3D_TRUE)
			{
					return GLXERR_NOERROR;
			}
		}
		((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Release((LPA3D4)glxAudioOutput.Extensions);
	}
	glxAudioOutput.Extensions=NULL;
	return GLXERR_UNSUPPORTEDDEVICE;
}

static int __cdecl glxDefaultCallback(glxVoice *Voice,void *Param1,int Param2)
{
	if (!Voice)
	{
		if (Param1)
		{
			//Score callback (used internally)
			*((void **)Param1)=NULL;
			return 0;
		}
		else
		{
			//End of music callback
			return 0;
		}
	}
	else
	{
		if ((Param1)&&(Param2))
		{
			//Streaming callback
			return 0;
		}
		else
		{
			//End of sample callback
			return 0;
		}
	}
}

static int glxCalcPeriod(glxVoice *Voice,int Key)
{
	int Period=0;

	if ((Key>=0)&&(Key<=119))
	{
		if (glxPlayerMode&1)
		{
			if (Voice->SmpC4Speed)
				Period=((8363*LogTable[Key])/Voice->SmpC4Speed);
		}
		else
			Period=((10*12-Key)*256);
	}
	return Period;
}

static void glxCalcPitch(glxVoice *Voice,int Period)
{
	unsigned long Frequency;

	if (Period)
	{
		if (glxPlayerMode&1)
			Frequency=((8363*(428<<4))/Period);
		else
			Frequency=(long)(((__int64)Voice->SmpC4Speed*LinearTable[(Period%3072)>>2])>>(15+(Period/3072)-5));
		Voice->SmpPitch=((Frequency/glxSamplingrate)<<16);
		Voice->SmpPitch+=(((Frequency%glxSamplingrate)<<16)/glxSamplingrate);
		if (Voice->SmpLoopStart>Voice->SmpLoopEnd)
			Voice->SmpPitch=-Voice->SmpPitch;
	}
}

static int glxConvertSample(glxSample *Sample,void *Source,int SourceSize,void *DestLeft,void *DestRight,int DestSize,int *SourceRead,int *DestWritten)
{
	int Result;

	if (Sample->Type&GLX_MPEGAUDIO)
	{
		Result=glxDecodeMPA(Sample,Source,SourceSize,DestLeft,DestRight,DestSize,SourceRead,DestWritten);
		if (*SourceRead>SourceSize) *SourceRead=SourceSize;
		return Result;
	}
	else if (Sample->Type&GLX_IMAADPCM)
	{
		Result=glxDecodeIMA(Sample,Source,SourceSize,DestLeft,DestRight,DestSize,SourceRead,DestWritten);
//		if (*SourceRead>SourceSize) *SourceRead=SourceSize;
		return Result;
	}
	else
	{
		return glxDecodeWAV(Sample,Source,SourceSize,DestLeft,DestRight,DestSize,SourceRead,DestWritten);
	}
}

static void glxSetTimers(unsigned short Tempo,unsigned short Speed)
{
	if (glxPlayerMode&2)
	{
		glxTimer2Period=(((glxSamplingrate*5)/(Tempo*2))<<16);
		glxTimer2Period+=((((glxSamplingrate*5)%(Tempo*2))<<16)/(Tempo*2));
		glxTimer1Period=glxTimer2Period;
	}
	else
	{
		glxTimer2Period=(((glxSamplingrate*60)/(Tempo*Speed))<<16);
		glxTimer2Period+=((((glxSamplingrate*60)%(Tempo*Speed))<<16)/(Tempo*Speed));
		glxTimer1Period=((glxSamplingrate<<14)/250);
	}
}

static void glxSetSamplingrate(unsigned long Rate)
{
	int Voice;
	
	if ((Rate>=8000)&&(Rate<=48000))
	{
		for (Voice=0;Voice<GLX_TOTALVOICES;Voice++)
			glxVoices[Voice].SmpPitch=(long)(((__int64)glxVoices[Voice].SmpPitch*glxSamplingrate)/Rate);
		glxSamplingrate=Rate;
		glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
	}
}

static void glxSetDSPMode(int Mode)
{
	int Volume,Sample,Temp,Frac;

	//initsoftwaremixer
	glxMixerType=Mode;
	if ((glxMMXFound)&&(glxKNIFound)&&(glxAudioOutput.Format&GLX_STEREO))
	{
		glxPostProcBase=kniMixerInit(glxMixerType,glxVolumeTableBase,glxMixerCodeBase);
		glxMixerType|=(64+2+GLX_STEREO);	//MMX,KNI,32 bit buffer,stereo
	}
	else if ((glxMMXFound)&&(glxK3DFound)&&(glxAudioOutput.Format&GLX_STEREO))
	{
		glxPostProcBase=k3dMixerInit(glxMixerType,glxVolumeTableBase,glxMixerCodeBase);
		glxMixerType|=(64+2+GLX_STEREO);	//MMX,3DNow!,32 bit buffer,stereo
	}
	else if ((glxMMXFound)&&(glxAudioOutput.Format&GLX_STEREO))
	{
		glxPostProcBase=mmxMixerInit(glxMixerType,glxVolumeTableBase,glxMixerCodeBase);
		glxMixerType|=(64+GLX_STEREO);		//MMX,16 bit buffer,stereo
		glxMixerType&=~2;
	}
	else
	{
		glxPostProcBase=x86MixerInit(glxMixerType,glxVolumeTableBase,glxMixerCodeBase);
		glxMixerType|=(2);					//x86,32 bit buffer
	}
	//Build volumetable
	for (Volume=0;Volume<64;Volume++)
	{
		for (Sample=0;Sample<256;Sample++)
		{
			//Build 16 bit volume value (logarithmic table)
			Temp=((Volume*Volume)<<4);
			glxVolumeTableBase[((Volume   )*256+Sample)]=(Temp*((sbyte)Sample));
			glxVolumeTableBase[((Volume+64)*256+Sample)]=(Temp*((ubyte)Sample))>>8;
		}
	}
	//Build clipping/postprocess table
	glxPostProcTable=(char *)(glxVolumeTableBase+2*64*256);
	Sample=((glxMixerType&128)^128);
	memset(glxPostProcTable,Sample,15*256+128);
	for (Temp=0;Temp<256;Temp++)
		glxPostProcTable[15*256+128+Temp]=(Sample+Temp);
	memset(glxPostProcTable+15*256+128+256,Sample+255,15*256+128);
	//Build interpolation table
	glxIntTableBase=glxPostProcTable+32*256;
	for (Frac=0;Frac<17;Frac++)
	{
		for (Sample=0;Sample<256;Sample++)
		{
			glxIntTableBase[(Frac*256+Sample)*2]=((((sbyte)Sample)*FilterResp[1][Frac])>>6);
			glxIntTableBase[(Frac*256+Sample)*2+1]=(((sbyte)Sample)-((((sbyte)Sample)*FilterResp[1][Frac])>>6));
		}
	}
}

static void glxArpeggio(glxVoice *Voice)
{
	static const long ArpeggioTable[16]={ 
	32768,30929,29193,27554,26008,24548,23170,21870,
	20643,19484,18390,17358,16384,15464,14596,13777
	};
	long Period;

	if (glxCurrentTime!=0)
	{
		Period=Voice->SmpBasePeriod;
		switch (glxCurrentTime%3)
		{
			case 0x00:Period*=ArpeggioTable[0];
					break;
			case 0x01:Period*=ArpeggioTable[(Voice->CommandValue>>4)&0x0f];
					break;
			case 0x02:Period*=ArpeggioTable[(Voice->CommandValue)&0x0f];
					break;
		}
		Period>>=15;
		Voice->BenderValue=(Period-Voice->SmpBasePeriod);
	}
}

static void glxSlideUp(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		Voice->PortaSpeed=(Voice->CommandValue<<4);
		Voice->PortaDest=glxMinPeriod;
	}
}

static void glxSlideDown(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		Voice->PortaSpeed=(Voice->CommandValue<<4);
		Voice->PortaDest=glxMaxPeriod;
	}
}

static void glxSlideNote(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		Voice->PortaSpeed=(Voice->Portamento<<4);
	}
	else
	{
		if (Voice->CommandValue!=0)
			Voice->Portamento=Voice->CommandValue;
	}
}

static void glxVibrato(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		Voice->VibDepth=(((Voice->Vibrato&0x0f)<<3)<<2);
		Voice->VibSpeed=(((Voice->Vibrato>>2)&0x3c)<<8);
	}
	else
	{
		if (Voice->CommandValue&0x0f)
			Voice->Vibrato=(Voice->Vibrato&0xf0|(Voice->CommandValue&0x0f));
		if (Voice->CommandValue&0xf0)
			Voice->Vibrato=((Voice->CommandValue&0xf0)|Voice->Vibrato&0x0f);
	}
}

static void glxVolSlideNote(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		glxSlideVol(Voice);
		glxSlideNote(Voice);
	}
}

static void glxVolVibrato(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		glxSlideVol(Voice);
		glxVibrato(Voice);
	}
}

static void glxTremolo(glxVoice *Voice)
{
	if (glxCurrentTime!=0)
	{
		Voice->TremDepth=(((Voice->Tremolo&0x0f)<<2)<<9);
		Voice->TremSpeed=(((Voice->Tremolo>>2)&0x3c)<<8);
	}
	else
	{
		if (Voice->CommandValue&0x0f)
			Voice->Tremolo=(Voice->Tremolo&0xf0|(Voice->CommandValue&0x0f));
		if (Voice->CommandValue&0xf0)
			Voice->Tremolo=((Voice->CommandValue&0xf0)|Voice->Tremolo&0x0f);
	}
}

static void glxPanning(glxVoice *Voice)
{
	int Panning;

	if (glxCurrentTime==0)
	{
		Panning=Voice->CommandValue;
		if (Panning>128)
		{
			Panning-=4;
			if ((Panning>=128)&&(Panning<=192))	
			{
				Panning=((Panning&127)<<1);
				if (Panning>127)
					Panning=127;
			}
			else
				Panning=(GLX_MIDSMPPANNING>>8);
			Panning|=(GLX_SURSMPPANNING>>8);
		}
		else if (Panning==128)
			Panning=127;
		Voice->Panning=Voice->BasePanning=(Panning<<8);
	}
}

static void glxSampleOffset(glxVoice *Voice)
{
	udword Offset;

	if (glxCurrentTime==0)
	{
		if (Voice->CommandValue!=0)
			Voice->SampleOffset=Voice->CommandValue;
		Offset=(Voice->SmpStart+(Voice->SampleOffset<<8));
		if (Offset>=Voice->SmpEnd)
			Offset=(Voice->SmpEnd-1);
		Voice->SmpPtr=Offset;
		Voice->SmpFrac=0;
	}
}

static void glxSlideVol(glxVoice *Voice)
{
	int SlideStep,Volume;

	if (glxCurrentTime!=0)
	{
		Volume=Voice->SmpVol;
		SlideStep=Voice->CommandValue;
		if (SlideStep>0x0f)
			SlideStep=-(SlideStep>>4);
		Volume-=(SlideStep<<9);
		if (Volume<GLX_MINSMPVOLUME)
			Volume=GLX_MINSMPVOLUME;
		else if (Volume>GLX_MAXSMPVOLUME)
			Volume=GLX_MAXSMPVOLUME;
		Voice->SmpVol=Volume;
		Voice->SmpBaseVol=Volume;
	}
}

static void glxPosJump(glxVoice *Voice)
{
	if ((glxCurrentTime==0)&&(glxPatternDelay==0))
	{
		if (Voice->CommandValue<=glxSongLength)
		{
			if ((glxMusicLooping)||(Voice->CommandValue>glxCurrentOrder))
			{
				glxCurrentOrder=(Voice->CommandValue-1);
				glxPatternBreak=1;
			}
		}
	}
}

static void glxSetVol(glxVoice *Voice)
{
	int Volume;

	if (glxCurrentTime==0)
	{
		Volume=(Voice->CommandValue<<8);
		if (Volume>GLX_MAXSMPVOLUME)
			Volume=GLX_MAXSMPVOLUME;
		Voice->SmpVol=Volume;
		Voice->SmpBaseVol=Volume;
	}
}

static void glxPattBreak(glxVoice *Voice)
{
	if ((glxCurrentTime==0)&&(glxPatternDelay==0))
	{
		glxPatternBreakCnt=((10*((Voice->CommandValue>>4)&0x0f))+(Voice->CommandValue&0x0f)+1);
		glxPatternBreak=1;
	}
}

static void glxExtended(glxVoice *Voice)
{
	switch ((Voice->CommandValue>>4)&0x0f)
	{
		case 0x00: glxSetFilter(Voice); break;
		case 0x01: glxFineSlideUp(Voice); break;
		case 0x02: glxFineSlideDown(Voice); break;
		case 0x03: glxGlissando(Voice); break;
		case 0x04: glxSetVibWave(Voice); break;
		case 0x05: glxSetFinetune(Voice); break;
		case 0x06: glxPattLoop(Voice); break;
		case 0x07: glxSetTremWave(Voice); break;
		case 0x08: glxFinePanning(Voice); break;
		case 0x09: glxRetrigger(Voice); break;
		case 0x0a: glxFineVolUp(Voice); break;
		case 0x0b: glxFineVolDown(Voice); break;
		case 0x0c: glxNoteCut(Voice); break;
		case 0x0d: glxNoteDelay(Voice); break;
		case 0x0e: glxPattDelay(Voice); break;
		case 0x0f: glxInvertLoop(Voice); break;
	}
}

static void glxSetFilter(glxVoice *Voice)
{
}

static void glxFineSlideUp(glxVoice *Voice)
{
	if (glxCurrentTime==0)
	{
		Voice->PortaSpeed=((Voice->CommandValue&0x0f)<<4);
		Voice->PortaDest=glxMinPeriod;
	}
	else
		Voice->PortaSpeed=0;
}

static void glxFineSlideDown(glxVoice *Voice)
{
	if (glxCurrentTime==0)
	{
		Voice->PortaSpeed=((Voice->CommandValue&0x0f)<<4);
		Voice->PortaDest=glxMaxPeriod;
	}
	else
		Voice->PortaSpeed=0;
}

static void glxGlissando(glxVoice *Voice)
{
//	Voice->Glissando=Voice->CommandValue&1;
}

static void glxSetVibWave(glxVoice *Voice)
{
	Voice->VibWaveType=(Voice->CommandValue&7);
}

static void glxSetFinetune(glxVoice *Voice)
{
	static const long FinetuneTable[16]={ 
	32768,33005,33245,33486,33728,33973,34219,34468,
    30929,31153,31379,31606,31835,32066,32298,32532
	};
	
	Voice->SmpC4Speed=((8363*FinetuneTable[Voice->CommandValue&0x0f])>>15);
}

static void glxPattLoop(glxVoice *Voice)
{
	if ((glxCurrentTime==0)&&(glxPatternDelay==0)&&(glxPatternBreak==0))
	{
		if ((Voice->CommandValue&0x0f)!=0)
		{
			if (glxPatternLCount--==0)
				glxPatternLCount=(Voice->CommandValue&0x0f);
			if (glxPatternLCount)
			{
				glxPatternBreakCnt=(glxPatternLStart+1);
				glxPatternBreak=1;
				glxCurrentOrder--;
			}
		}
		else
			glxPatternLStart=glxPatternRow;
	}
}

static void glxSetTremWave(glxVoice *Voice)
{
	Voice->TremWaveType=(Voice->CommandValue&7);
}

static void glxFinePanning(glxVoice *Voice)
{
	Voice->Panning=Voice->BasePanning=(((Voice->CommandValue&0x0f)<<11)+1024);
}

static void glxRetrigger(glxVoice *Voice)
{
	if ((Voice->CommandValue&0x0f)!=0)
	{
		if ((glxCurrentTime%(Voice->CommandValue&0x0f))==0)
		{
			Voice->SmpPtr=Voice->SmpStart;
			Voice->SmpFrac=0;
		}
	}
}

static void glxFineVolUp(glxVoice *Voice)
{
	int Volume;

	if (glxCurrentTime==0)
	{
		Volume=Voice->SmpVol;
		Volume+=((Voice->CommandValue&0x0f)<<9);
		if (Volume>GLX_MAXSMPVOLUME)
			Volume=GLX_MAXSMPVOLUME;
		Voice->SmpVol=Volume;
		Voice->SmpBaseVol=Volume;
	}
}

static void glxFineVolDown(glxVoice *Voice)
{
	int Volume;

	if (glxCurrentTime==0)
	{
		Volume=Voice->SmpVol;
		Volume-=((Voice->CommandValue&0x0f)<<9);
		if (Volume<GLX_MINSMPVOLUME)
			Volume=GLX_MINSMPVOLUME;
		Voice->SmpVol=Volume;
		Voice->SmpBaseVol=Volume;
	}
}

static void glxNoteCut(glxVoice *Voice)
{
	if (glxCurrentTime>(Voice->CommandValue&0x0f))
	{
		Voice->SmpVol=0;
		Voice->SmpBaseVol=0;
	}
}

static void glxNoteDelay(glxVoice *Voice)
{
	glxInstrument *Instrument;
	udword StartAddress;
	glxSample *Sample;
	int Period,Key;

	if (glxCurrentTime==(Voice->CommandValue&0x0f))
	{
		if ((Instrument=glxInstruments[(Voice->InstNo&128)>>7][Voice->InstNo&127])!=NULL)
		{
			Key=Voice->NoteNo;
			Voice->InsArt=&Instrument->Articulation;
			if (Instrument->Split[Key]<Instrument->Samples)
			{
				Voice->SmpHdr=Sample=&Instrument->Sample[Instrument->Split[Key]];
				Voice->SmpNo=Instrument->Split[Key];
				if ((StartAddress=(udword)Sample->Data)!=0)
				{
					//Set local articulation data (if present)
					if (Sample->Articulation)
						Voice->InsArt=Sample->Articulation;
					//Adjust address if 16 bit sample
					if (Sample->Type&GLX_16BITSAMPLE)
						StartAddress>>=1;
					//Update Voice fields
					Voice->SmpFrac=0;
					Voice->SmpPtr=StartAddress;
					Voice->SmpStart=StartAddress;
					Voice->SmpLoopStart=StartAddress+Sample->LoopStart;
					Voice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
					Voice->SmpEnd=StartAddress+Sample->Length;
					Voice->SmpC4Speed=Sample->C4Speed;
					Voice->SmpType=Sample->Type;
					if (Sample->Type&GLX_PANNING)
						Voice->Panning=Voice->BasePanning=Sample->Panning;
					Voice->VibWaveType=Voice->InsArt->VibType;
					if ((Voice->VibWaveType&4)==0)
						Voice->VibIndex=0;
					Voice->VibSpeed=Voice->InsArt->VibSpeed;
					Voice->VibDepth=Voice->InsArt->VibDepth;
					Voice->TremWaveType=Voice->InsArt->TremType;
					if ((Voice->TremWaveType&4)==0)
						Voice->TremIndex=0;
					Voice->TremSpeed=Voice->InsArt->TremSpeed;
					Voice->TremDepth=Voice->InsArt->TremDepth;
					Period=glxCalcPeriod(Voice,Key);
					Voice->SmpBasePeriod=Voice->SmpPeriod=Period;
					glxCalcPitch(Voice,Period);
					Voice->Active=GLX_ON;
				}
			}
		}
	}
}

static void glxPattDelay(glxVoice *Voice)
{
	if (glxCurrentTime==0)
		glxPatternDelay=(Voice->CommandValue&0x0f);
	Voice->Command=Voice->CommandValue=0;
}

static void glxInvertLoop(glxVoice *Voice)
{
}

static void glxSetSpeed(glxVoice *Voice)
{
	if (glxCurrentTime==0)
	{
		if (Voice->CommandValue!=0)
		{
			if (Voice->CommandValue>32)
				glxCurrentTempo=Voice->CommandValue;
			else
				glxCurrentSpeed=Voice->CommandValue;
			glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
		}
		else
			glxMusicEnabled=GLX_OFF;
	}
}

static int glxProcessMIDITrack(glxTrack *Track)
{
	int Key,Velocity,Controller,Value,Temp,Data,Type,DeltaTime,Status,Channel;
	unsigned char *Stream;

	DeltaTime=Track->TimeToNext;
	Status=Track->Status;
	Stream=Track->Cursor;
	Channel=Status&15;
	if ((!Stream)&&(!Track->Flags))
	{
		//Initialise cursor
		Stream=Track->Cursor=Track->Events;
		//Read variable length DeltaTime at start of stream
		DeltaTime=Track->TimeToNext=0;
		if (Stream)
		{
			do
			{
				Temp=*Stream++;
				DeltaTime=((DeltaTime<<7)+(Temp&127));
			} while (Temp&128);
		}
	}
	while ((Stream)&&(!DeltaTime))
	{
		//Read events, check running status first
		if (Stream[0]&128)
		{
			Status=*Stream++;
			Channel=Status&15; 
		}
		switch (Status&240)
		{
			case 0x80://Note off
				Key=*Stream++;
				Velocity=*Stream++;
				if (glxChannels[Channel].VoiceMap[Key])
				{
					if (glxChannels[Channel].Hold1<64)
					{
						glxStopInstrument(glxChannels[Channel].VoiceMap[Key]);
						glxChannels[Channel].VoiceMap[Key]=NULL;
						glxChannels[Channel].Hold1Map[Key]=0;
					}
					else glxChannels[Channel].Hold1Map[Key]=1;
				}
				break;
			case 0x90://Note on
				Key=*Stream++;
				Velocity=*Stream++;
				if (Velocity)
				{
					if (glxChannels[Channel].VoiceMap[Key])
					{
						glxStopInstrument(glxChannels[Channel].VoiceMap[Key]);
						glxChannels[Channel].VoiceMap[Key]=NULL;
						glxChannels[Channel].Hold1Map[Key]=0;
					}
					if (Channel!=9) 
					{
						glxChannels[Channel].VoiceMap[Key]=
							glxStartInstrument(
								GLX_AUTO,
								glxChannels[Channel].Program,
								Key,
								glxChannels[Channel].Pitchwheel,
								glxChannels[Channel].Volume,
								Velocity,
								glxChannels[Channel].Expression,
								glxChannels[Channel].Panning,
								glxChannels[Channel].Modulation,
								glxChannels[Channel].Reverb,
								glxChannels[Channel].Chorus,
								GLX_NORMAL|128);
					}
					else
					{
						glxChannels[Channel].VoiceMap[Key]=
							glxStartInstrument(
								GLX_AUTO,
								glxChannels[Channel].Program|128,
								Key,
								glxChannels[Channel].Pitchwheel,
								glxChannels[Channel].Volume,
								Velocity,
								glxChannels[Channel].Expression,
								glxChannels[Channel].Panning,
								glxChannels[Channel].Modulation,
								glxChannels[Channel].Reverb,
								glxChannels[Channel].Chorus,
								GLX_NORMAL|128);
					}
				}
				else
				{
					if (glxChannels[Channel].VoiceMap[Key])
					{
						if (glxChannels[Channel].Hold1<64)
						{
							glxStopInstrument(glxChannels[Channel].VoiceMap[Key]);
							glxChannels[Channel].VoiceMap[Key]=NULL;
							glxChannels[Channel].Hold1Map[Key]=0;
						}
						else glxChannels[Channel].Hold1Map[Key]=1;
					}
				}
				break;
			case 0xa0://Key pressure
				Key=*Stream++;
				Value=*Stream++;
				break;
			case 0xb0://Controller change
				Controller=*Stream++;
				Value=*Stream++;
				switch (Controller)
				{	
					case 0x00://Bank select MSB
						glxChannels[Channel].Bank=((Value<<7)+(glxChannels[Channel].Bank&127));
						break;
					case 0x01://Modulation
						glxChannels[Channel].Modulation=Value;
						break;
					case 0x06://Data entry MSB
						glxChannels[Channel].Data=((Value<<7)+(glxChannels[Channel].Data&127));
						break;
					case 0x07://Channel Volume
						glxChannels[Channel].Volume=Value;
						break;
					case 0x0a://Panning
						glxChannels[Channel].Panning=Value;
						break;
					case 0x0b://Expression
						glxChannels[Channel].Expression=Value;
						break;
					case 0x20://Bank select LSB
						glxChannels[Channel].Bank=((glxChannels[Channel].Bank&16256)+Value);
						break;
					case 0x26://Data entry LSB
						glxChannels[Channel].Data=((glxChannels[Channel].Data&16256)+Value);
						break;
					case 0x40://Hold1
						glxChannels[Channel].Hold1=Value;
						break;
					case 0x5b://Reverb
						glxChannels[Channel].Reverb=Value;
						break;
					case 0x5d://Chorus
						glxChannels[Channel].Chorus=Value;
						break;
					case 0x62://NRPN LSB
						glxChannels[Channel].NRPN=((glxChannels[Channel].NRPN&16256)+Value);
						break;
					case 0x63://NRPN MSB
						glxChannels[Channel].NRPN=((Value<<7)+(glxChannels[Channel].NRPN&127));
						break;
					case 0x64://RPN LSB
						glxChannels[Channel].RPN=((glxChannels[Channel].RPN&16256)+Value);
						break;
					case 0x65://RPN MSB
						glxChannels[Channel].RPN=((Value<<7)+(glxChannels[Channel].RPN&127));
						break;
					case 0x79://Reset all controllers
						glxChannels[Channel].Pitchwheel=0;
						glxChannels[Channel].Expression=GLX_MAXINSEXPRESSION;
						glxChannels[Channel].Modulation=0;
						break;
					case 0x7b://All notes off
					case 0x7c://Omni on
					case 0x7d://Omni off
						for (Key=0;Key<128;Key++)
						{
							if (glxChannels[Channel].VoiceMap[Key])
							{
								glxStopInstrument(glxChannels[Channel].VoiceMap[Key]);
								glxChannels[Channel].VoiceMap[Key]=NULL;
							}
						}
						break;
					default:
						break;
				}
				//Update all instruments for channel
				for (Key=0;Key<128;Key++)
				{
					if (glxChannels[Channel].VoiceMap[Key])
					{
						if ((glxChannels[Channel].Hold1<64)&&(glxChannels[Channel].Hold1Map[Key]))
						{
							glxStopInstrument(glxChannels[Channel].VoiceMap[Key]);
							glxChannels[Channel].VoiceMap[Key]=NULL;
							glxChannels[Channel].Hold1Map[Key]=0;
						}
						else
						{
							glxControlInstrument(
								glxChannels[Channel].VoiceMap[Key],
								glxChannels[Channel].Pitchwheel,
								glxChannels[Channel].Volume,
								GLX_DEFINSVELOCITY,
								glxChannels[Channel].Expression,
								glxChannels[Channel].Panning,
								glxChannels[Channel].Modulation,
								glxChannels[Channel].Reverb,
								glxChannels[Channel].Chorus);
						}
					}
				}
				break;
			case 0xc0://Program change
				glxChannels[Channel].Program=*Stream++;
				break;
			case 0xd0://Channel pressure
				Value=*Stream++;
				break;
			case 0xe0://Pitchwheel
				glxChannels[Channel].Pitchwheel=(((8192-((Stream[1]<<7)+Stream[0]))*glxChannels[Channel].PitchwheelSens)/8192);
				for (Key=0;Key<128;Key++)
				{
					if (glxChannels[Channel].VoiceMap[Key])
					{
						glxControlInstrument(
							glxChannels[Channel].VoiceMap[Key],
							glxChannels[Channel].Pitchwheel,
							GLX_DEFINSVOLUME,
							GLX_DEFINSVELOCITY,
							GLX_DEFINSEXPRESSION,
							GLX_DEFINSPANNING,
							GLX_DEFINSMODULATION,
							GLX_DEFINSREVERB,
							GLX_DEFINSCHORUS);
					}
				}
				Stream+=2;
				break;	
			case 0xf0://System common and system realtime
				switch (Status)
				{
					case 0xf0://SysEx
						Data=0;
						do
						{
							Temp=*Stream++;
							Data=((Data<<7)+(Temp&127));
						} while (Temp&128);
						Stream+=Data;
						break;
					case 0xf2://Song position pointer
						Stream+=2;
						break;
					case 0xf3://Song select
						Stream++;
						break;
					case 0xf6://Tune request
						break;
					case 0xf7://SysEx End
						Data=0;
						do
						{
							Temp=*Stream++;
							Data=((Data<<7)+(Temp&127));
						} while (Temp&128);
						Stream+=Data;
						break;
					case 0xf8://Timing clock
						break;
					case 0xfa://Start sequence
						break;
					case 0xfb://Continue
						break;
					case 0xfc://Stop sequence
						break;
					case 0xfe://Active sensing
						break;
					case 0xff://Meta event
						Type=*Stream++;
						Data=0;
						do
						{
							Temp=*Stream++;
							Data=((Data<<7)+(Temp&127));
						} while (Temp&128);
						switch (Type)
						{
							case 0x00://Sequence number
								break;
							case 0x01://Text event
								break;
							case 0x02://Copyright notice
								break;
							case 0x03://Sequence/track name
								break;
							case 0x04://Instrument name
								break;
							case 0x05://Lyric
								break;
							case 0x06://Marker
								break;
							case 0x07://Cue point
								break;
							case 0x2f://End of track
								Stream=NULL;
								Track->Flags=1;
								break;
							case 0x51://Set tempo
								glxCurrentTempo=(60*1000000/((Stream[0]<<16)+(Stream[1]<<8)+(Stream[2])));
								glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
								break;
							case 0x54://SMPTE Offset
								break;
							case 0x58://Time signature
								break;
							case 0x59://Key signature
								break;
							case 0x7f://Sequencer specific
								break;
							default:
								break;
						}
						Stream+=Data;
						break;
				}
				break;
		} 
		//Read variable length DeltaTime
		DeltaTime=0;
		if (Stream)
		{
			do
			{
				Temp=*Stream++;
				DeltaTime=((DeltaTime<<7)+(Temp&127));
			} while (Temp&128);
		}
	}
	DeltaTime--;
	Track->Cursor=Stream;
	Track->Status=Status;
	Track->TimeToNext=DeltaTime;
	return Stream!=NULL?GLXERR_NOERROR:GLXERR_OUTOFSOURCEDATA;
}

static int glxProcessAMTrack(glxTrack *Track)
{
	int Key,Velocity,Program,Volume,Panning,Command;
	int Status,DeltaTime,Index,Period,Channel;
	glxInstrument *Instrument;
	unsigned char *Stream;
	glxSample *Sample;
	glxVoice *Voice;
	udword StartAddress;

	DeltaTime=Track->TimeToNext;
	Status=Track->Status;
	Stream=Track->Cursor;
	if ((!Stream)&&(!Track->Flags))
	{
		//Initialise cursor
		Stream=Track->Cursor=Track->Events;
		//Read variable length DeltaTime at start of stream
		DeltaTime=Track->TimeToNext=0;
		Status=Stream[0];
		if (Status&128)
		{
			//Get DeltaTime and check end of stream
			if ((DeltaTime=((Stream[2])+(Stream[3]<<8)))==0)
			{
				Stream=NULL;
				Track->Flags=1;
			}
		}
	}
	while ((Stream)&&(!DeltaTime))
	{
		//Process event data
		Status=*Stream++;
		Channel=(Status&63);
		Index=(*Stream++)+glxSampleVoices;
		if (Index>=GLX_TOTALVOICES)
			Index=GLX_TOTALVOICES-1;
		Voice=&glxVoices[Index];
		if (Status&128)
			DeltaTime=*((uword *)Stream)++;
		if (Status&64)
		{
			//Get command
			Command=*Stream++;
			//Process commands
			switch (Command)
			{
				case 0x00: //Program change
					Program=*Stream++;
					Voice->InstNo=Program;           
					break;
				case 0x01: //Panpot
					Panning=*Stream++;
					Voice->BasePanning=Voice->Panning=(Panning<<8);
					break;
				case 0x02: //Volume
					Volume=*Stream++;	
					Voice->Vol=Voice->VolDest=Volume;
					Voice->Volume=(Volume*Volume)<<1;
					break;
				case 0x03: //Modulation
					Voice->VibDepth=*Stream++;        
					break;
				case 0x04: //Pitch bend
					Voice->BenderValue=*((sword *)Stream)++;
					break;
				case 0x05: //Speed
					glxCurrentSpeed=*Stream++;                      
					glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
					break;
				case 0x06: //Tempo
					glxCurrentTempo=*((uword *)Stream)++;
					glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
					break;
				case 0x07: //Portamento
					Voice->Portamento=*Stream++;      
					break;
				case 0x08: 
					Voice->PortaSpeed=*((uword *)Stream)++;
					break;
				case 0x09: 
					Voice->Reverb=*Stream++;
					break;
				case 0x0a: 
					Voice->Chorus=*Stream++;
					break;
				default  : 
					break;
			}
		}
		else
		{
			//Get Key and Velocity (always present)
			Key=*Stream++;
			Velocity=*Stream++;
			//Convert and check values
			if ((Key&128)==0)
			{
				//Key on has additional Program, Volume and Panning
				Program=*Stream++;
				Volume=*Stream++;
				Panning=*Stream++;
				//Update Voice fields
				Voice->NoteNo=Key;
				Voice->InstNo=Program;
				Voice->Vol=Voice->VolDest=Volume;
				Voice->Volume=(Volume*Volume)<<1;
				Voice->Panning=Voice->BasePanning=(Panning<<8);
				Voice->Velocity=(Velocity*Velocity)<<1;
				Voice->VibDepth=0;
				Voice->VibSpeed=0;
				Voice->TremDepth=0;
				Voice->TremSpeed=0;
				Voice->BenderValue=0;
				if (Voice->Portamento<64)
				{
					Voice->Active=GLX_OFF;          
					glxChannels[Channel].VoiceMap[Key]=NULL;
					if ((Instrument=glxInstruments[(Voice->InstNo&128)>>7][Voice->InstNo&127])!=NULL)
					{
						Voice->InsArt=&Instrument->Articulation;  
						if (Instrument->Split[Key]<Instrument->Samples)
						{
							Voice->SmpHdr=Sample=&Instrument->Sample[Instrument->Split[Key]];
							Voice->SmpNo=Instrument->Split[Key];
							if ((StartAddress=(udword)Sample->Data)!=0)
							{
								Voice->Flags=128;
								//Copy custom articulation data
								if (Sample->Articulation)
									Voice->InsArt=Sample->Articulation;  
								//Adjust address if 16 bit sample
								if (Sample->Type&GLX_16BITSAMPLE)
									StartAddress>>=1;
								//Update Voice fields
								Voice->SmpFrac=0;
								Voice->SmpPtr=StartAddress;
								Voice->SmpStart=StartAddress;
								Voice->SmpLoopStart=StartAddress+Sample->LoopStart;
								Voice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
								Voice->SmpEnd=StartAddress+Sample->Length;
								Voice->SmpC4Speed=Sample->C4Speed;
								Voice->SmpType=Sample->Type;
								Voice->SmpVol=Sample->Volume;
								Voice->SmpBaseVol=Sample->Volume;
								if (Sample->Type&GLX_PANNING)
									Voice->Panning=Voice->BasePanning=Sample->Panning;
								Voice->VibWaveType=Voice->InsArt->VibType;
								if ((Voice->VibWaveType&4)==0)
									Voice->VibIndex=0;
								Voice->VibSpeed=Voice->InsArt->VibSpeed;
								Voice->VibDepth=Voice->InsArt->VibDepth;
								Voice->TremWaveType=Voice->InsArt->TremType;
								if ((Voice->TremWaveType&4)==0)
									Voice->TremIndex=0;
								Voice->TremSpeed=Voice->InsArt->TremSpeed;
								Voice->TremDepth=Voice->InsArt->TremDepth;
								Voice->InsVol=0;
								Voice->InsVolStep=0;
								Voice->InsVolTime=0;
								Voice->InsVolFade=32767;
								Voice->InsVolPoint=0;
								Voice->InsPit=0;
								Voice->InsPitStep=0;
								Voice->InsPitTime=0;
								Voice->InsPitFade=32767;
								Voice->InsPitPoint=0;
								Voice->InsPan=0;
								Voice->InsPanStep=0;
								Voice->InsPanTime=0;
								Voice->InsPanFade=32767;
								Voice->InsPanPoint=0;
								Period=glxCalcPeriod(Voice,Key);
								Voice->SmpBasePeriod=Voice->SmpPeriod=Period;
								glxCalcPitch(Voice,Period);
								Voice->Active=GLX_ON;
								glxChannels[Channel].VoiceMap[Key]=Voice;
							}
						}
					}
				}
				Voice->PortaDest=glxCalcPeriod(Voice,Key);
			}
			else
				Voice->NoteNo=Key;
		}
		//Preprocess event data
		DeltaTime=0;
		if (Stream)
		{
			Status=Stream[0];
			if (Status&128)
			{
				//Get DeltaTime and check end of stream
				if ((DeltaTime=((Stream[2])+(Stream[3]<<8)))==0)
				{
					Stream=NULL;
					Track->Flags=1;
				}
			}
		}
	}
	DeltaTime--;
	Track->Cursor=Stream;
	Track->Status=Status;
	Track->TimeToNext=DeltaTime;
	return Stream!=NULL?GLXERR_NOERROR:GLXERR_OUTOFSOURCEDATA;
}

static int glxProcessMODTrack(glxTrack *Track)
{
	int Key,Velocity,Command,Period,DeltaTime,Status;
	int Flag,Channel,Data,Index,Program;
	glxInstrument *Instrument;
	unsigned char *Stream;
	udword StartAddress;
	glxSample *Sample;
	glxVoice *Voice;
  
	DeltaTime=Track->TimeToNext;
	Status=Track->Status;
	Stream=Track->Cursor;
	if (!Stream)
	{
		//Initialise cursor
		Stream=Track->Cursor=Track->Events;
		//Set DeltaTime at start of stream
		DeltaTime=Track->TimeToNext=0;
		//Get length in rows
		glxPatternLength=*Stream++;
	}
	if ((Stream)&&(!DeltaTime))
	{
		//Set DeltaTime
		glxCurrentTime=0;
		DeltaTime=glxCurrentSpeed;
		//Check for pattern delay
		if (glxPatternDelay==0)
		{
			//Check for end of stream
			if ((!glxPatternBreak)&&(glxPatternRow!=glxPatternLength))
			{
				//Reset pitch/volume LFOs and commands
				for (Channel=0;Channel<glxMusicVoices;Channel++)
				{
					glxVoices[glxSampleVoices+Channel].VibDepth=0;
					glxVoices[glxSampleVoices+Channel].VibSpeed=0;
					glxVoices[glxSampleVoices+Channel].TremDepth=0;
					glxVoices[glxSampleVoices+Channel].TremSpeed=0;
					glxVoices[glxSampleVoices+Channel].PortaSpeed=0;
					glxVoices[glxSampleVoices+Channel].BenderValue=0;
					glxVoices[glxSampleVoices+Channel].Command=0;
					glxVoices[glxSampleVoices+Channel].CommandValue=0;
				}
				//Skip events
				while (glxPatternBreakCnt>1)
				{
					do
					{
						Flag=*Stream++;
						Channel=(Flag&31);
						if (Flag&128)
						{
							Data=*Stream++;
							Command=*Stream++;
						}
						if (Flag&64)
						{
							Program=*Stream++;
							Key=*Stream++;
						}
						if (Flag&32)
						{
							Velocity=*Stream++;
						}
					} while (Flag!=0);
					glxPatternBreakCnt--;
					glxPatternRow++;
				}
				//Process event data
				do
				{
					Flag=*Stream++;
					Channel=(Flag&31);
					if (Channel>GLX_TOTALCHANNELS)
						Channel=GLX_TOTALCHANNELS;
					Voice=&glxVoices[Channel+glxSampleVoices];
					if (Flag&128)
					{
						Voice->CommandValue=*Stream++;
						Voice->Command=*Stream++;
					}
					if (Flag&64)
					{
						Program=*Stream++;
						Key=*Stream++;
						if (Program)
						{
							Voice->InstNo=Program-1;
							//FastTracker 2 starts envelope on program change (instead of key)
							if (Voice->InsArt)
							{
								if (Voice->InsArt->VolFlag&1)
								{
									Voice->InsVol=0;
									Voice->InsVolTime=0;
									Voice->InsVolFade=32767;
									Voice->InsVolPoint=0;
								}
								if (Voice->InsArt->PitFlag&1)
								{
									Voice->InsPit=0;
									Voice->InsPitTime=0;
									Voice->InsPitFade=32767;
									Voice->InsPitPoint=0;
								}
								if (Voice->InsArt->PanFlag&1)
								{
									Voice->InsPan=0;
									Voice->InsPanTime=0;
									Voice->InsPanFade=32767;
									Voice->InsPanPoint=0;
								}
							}
						}
						if (Key)
						{
							if ((Key&128)==0)
							{
								Voice->NoteNo=Key-1;
								Voice->Velocity=32767;
								if ((Voice->Command!=0x03)&&(Voice->Command!=0x05))
								{
									if ((Voice->Command!=0x0e)||((Voice->CommandValue&0xf0)!=0xd0))
									{
										Voice->Active=GLX_OFF;
										glxChannels[Channel].VoiceMap[Key-1]=NULL;
										if ((Instrument=glxInstruments[(Voice->InstNo&128)>>7][Voice->InstNo&127])!=NULL)
										{
											Voice->InsArt=&Instrument->Articulation;  
											if (Instrument->Split[Key-1]<Instrument->Samples)
											{
												Voice->SmpHdr=Sample=&Instrument->Sample[Instrument->Split[Key-1]];
												Voice->SmpNo=Instrument->Split[Key-1];
												if ((StartAddress=(udword)Sample->Data)!=0)
												{
													Voice->Flags=128;
													//Set local articulation data (if present)
													if (Sample->Articulation)
														Voice->InsArt=Sample->Articulation;
													//Adjust address if 16 bit sample
													if (Sample->Type&GLX_16BITSAMPLE)
														StartAddress>>=1;
													//Update Voice fields
													Voice->SmpFrac=0;
													Voice->SmpPtr=StartAddress;
													Voice->SmpStart=StartAddress;
													Voice->SmpLoopStart=StartAddress+Sample->LoopStart;
													Voice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
													Voice->SmpEnd=StartAddress+Sample->Length;
													Voice->SmpC4Speed=Sample->C4Speed;
													Voice->SmpType=Sample->Type;
													if (Sample->Type&GLX_PANNING)
														Voice->Panning=Voice->BasePanning=Sample->Panning;
													Voice->VibWaveType=Voice->InsArt->VibType;
													if ((Voice->VibWaveType&4)==0)
														Voice->VibIndex=0;
													Voice->VibSpeed=Voice->InsArt->VibSpeed;
													Voice->VibDepth=Voice->InsArt->VibDepth;
													Voice->TremWaveType=Voice->InsArt->TremType;
													if ((Voice->TremWaveType&4)==0)
														Voice->TremIndex=0;
													Voice->TremSpeed=Voice->InsArt->TremSpeed;
													Voice->TremDepth=Voice->InsArt->TremDepth;
													Voice->InsVol=0;
													Voice->InsVolTime=0;
													Voice->InsVolFade=32767;
													Voice->InsVolPoint=0;
													Voice->InsPit=0;
													Voice->InsPitTime=0;
													Voice->InsPitFade=32767;
													Voice->InsPitPoint=0;
													Voice->InsPan=0;
													Voice->InsPanTime=0;
													Voice->InsPanFade=32767;
													Voice->InsPanPoint=0;
													Period=glxCalcPeriod(Voice,Key-1);
													Voice->SmpBasePeriod=Voice->SmpPeriod=Period;
													glxCalcPitch(Voice,Period);
													Voice->Active=GLX_ON;
													glxChannels[Channel].VoiceMap[Key-1]=Voice;
												}
											}
										}
									}
								}
								Voice->PortaDest=glxCalcPeriod(Voice,Key-1);
							}
							else
								Voice->NoteNo=Key;
						}
						if (Program)
						{
							if (Voice->SmpHdr!=NULL)
							{
								Velocity=Voice->SmpHdr->Volume;
								Voice->SmpVol=Velocity;
								Voice->SmpBaseVol=Velocity;
							}
						}
					}
					if (Flag&32)
					{
						Velocity=((*Stream++)<<8);
						Voice->SmpVol=Velocity;
						Voice->SmpBaseVol=Velocity;
					}
				} while (Flag!=0);
				glxPatternRow++;
			}
			else
				Stream=NULL;
		}
		else
			glxPatternDelay--;
	}
	for (Index=glxSampleVoices;Index<(glxSampleVoices+glxMusicVoices);Index++)
	{
		if ((glxVoices[Index].Command!=0)||(glxVoices[Index].CommandValue!=0))
		{
			switch (glxVoices[Index].Command&0x0f)
			{
				case 0x00: glxArpeggio(&glxVoices[Index]); break;
				case 0x01: glxSlideUp(&glxVoices[Index]); break;
				case 0x02: glxSlideDown(&glxVoices[Index]); break;
				case 0x03: glxSlideNote(&glxVoices[Index]); break;
				case 0x04: glxVibrato(&glxVoices[Index]); break;
				case 0x05: glxVolSlideNote(&glxVoices[Index]); break;
				case 0x06: glxVolVibrato(&glxVoices[Index]); break;
				case 0x07: glxTremolo(&glxVoices[Index]); break;
				case 0x08: glxPanning(&glxVoices[Index]); break;
				case 0x09: glxSampleOffset(&glxVoices[Index]); break;
				case 0x0a: glxSlideVol(&glxVoices[Index]); break;
				case 0x0b: glxPosJump(&glxVoices[Index]); break;
				case 0x0c: glxSetVol(&glxVoices[Index]); break;
				case 0x0d: glxPattBreak(&glxVoices[Index]); break;
				case 0x0e: glxExtended(&glxVoices[Index]); break;
				case 0x0f: glxSetSpeed(&glxVoices[Index]); break;
			}
		}
	}
	if (glxCurrentTime==0) DeltaTime=glxCurrentSpeed;
	DeltaTime--;
	glxCurrentTime++;
	Track->Cursor=Stream;
	Track->Status=Status;
	Track->TimeToNext=DeltaTime;
	return Stream!=NULL?GLXERR_NOERROR:GLXERR_OUTOFSOURCEDATA;
}

static void *glxProcessPattern(glxPattern *Pattern)
{
	unsigned int Channel,Track,Result,EndOfPattern=1;
	
	//NULL pattern means reset logic
	if (!Pattern)
	{
		//Initialise channels
		for (Channel=0;Channel<GLX_TOTALCHANNELS;Channel++)
		{
			memset(&glxChannels[Channel],0,sizeof(glxChannel));
			glxChannels[Channel].FourCC=GLX_FOURCC_CHAN;
			glxChannels[Channel].Size=(sizeof(glxChannel)-8);
			glxChannels[Channel].Bank=0;
			glxChannels[Channel].Program=0;
			glxChannels[Channel].Pitchwheel=0;
			glxChannels[Channel].PitchwheelSens=2*256;
			glxChannels[Channel].Panning=GLX_MIDINSPANNING;
			glxChannels[Channel].Modulation=0;
			glxChannels[Channel].Expression=GLX_MAXINSEXPRESSION;
			glxChannels[Channel].Volume=100;
			glxChannels[Channel].Hold1=0;
			glxChannels[Channel].Reverb=40;
			glxChannels[Channel].Chorus=0;
			glxChannels[Channel].RPN=0x3fff;
			glxChannels[Channel].NRPN=0x3fff;
			glxChannels[Channel].Data=0;
		}
	}
	else
	{
		//Process each track in pattern
		for (Track=0;Track<Pattern->Tracks;Track++)
		{
			switch (glxPlayerMode&6)
			{
				case 0x00:Result=glxProcessAMTrack(&Pattern->Track[Track]);
						  break;
				case 0x02:Result=glxProcessMODTrack(&Pattern->Track[Track]);
						  break;
				case 0x04:Result=glxProcessMIDITrack(&Pattern->Track[Track]);
						  break;
			}
			if (Pattern->Track[Track].Cursor) EndOfPattern=0;
		}
		if (EndOfPattern) 
		{
			for (Track=0;Track<Pattern->Tracks;Track++)
				Pattern->Track[Track].Flags=0;
			Pattern=NULL;
		}
	}
	return Pattern;
}

static int glxSetMMXEffect(glxMMXEffect *MMXEffect,glxReverb *Reverb)
{
  float mindelay=1.0,avgdelay=0.0,maxdelay=0.0;
  float maxgain=0.0,delay,gain,k,lpfa,roomsize;
  int i;

  if ((Reverb->Volume<-1.0f)||(Reverb->Volume>1.0f))
	return GLXERR_BADPARAMETER;
  if (Reverb->HFDamp>glxSamplingrate)
	return GLXERR_BADPARAMETER;
  //Clear reverb structure
  memset(MMXEffect,0,sizeof(glxMMXEffect));
  //Calculate reverb time from six comb filters
  for (i=0;i<6;i++)
  {
	if ((Reverb->Delay[i].Time*Reverb->Delay[i].Gain)>(maxdelay*maxgain))
	{
      maxdelay=Reverb->Delay[i].Time;
      maxgain=Reverb->Delay[i].Gain;
	  Reverb->Time=(float)((-60.0f*maxdelay)/(20.0f*log10(maxgain)));
	}
	if (Reverb->Delay[i].Time<mindelay)
      mindelay=Reverb->Delay[i].Time;
	avgdelay+=(Reverb->Delay[i].Time/6.0f);
  }
  //Set mastervolume
  MMXEffect->Volume=(sdword)(Reverb->Volume*32767.0);
  //Calculate 1-pole IIR LPF constant
  k=(float)(1.0-cos(2.0f*3.141f*Reverb->HFDamp/(float)glxSamplingrate));
  lpfa=(float)(sqrt(k*k+2.0f*k)-k);
  MMXEffect->LPF[1]=(sword)(lpfa*32767.0);
  MMXEffect->LPF[0]=(sword)((1.0-lpfa)*32767.0);
  //These are the actual reverberant comb filters
  delay=Reverb->Delay[0].Time;					
  gain=Reverb->Delay[0].Gain;
  MMXEffect->Delay1=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay1Gain=(sword)(gain*4095.0);
  delay=Reverb->Delay[1].Time;					
  gain=Reverb->Delay[1].Gain;
  MMXEffect->Delay2=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay2Gain=(sword)(gain*4095.0);
  delay=Reverb->Delay[2].Time;					
  gain=Reverb->Delay[2].Gain;
  MMXEffect->Delay3=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay3Gain=(sword)(gain*4095.0);
  delay=Reverb->Delay[3].Time;					
  gain=Reverb->Delay[3].Gain;
  MMXEffect->Delay4=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay4Gain=(sword)(gain*4095.0);
  delay=Reverb->Delay[4].Time;					
  gain=Reverb->Delay[4].Gain;
  MMXEffect->Delay5=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay5Gain=(sword)(gain*4095.0);
  delay=Reverb->Delay[5].Time;					
  gain=Reverb->Delay[5].Gain;
  MMXEffect->Delay6=-(long)(delay*glxSamplingrate);
  MMXEffect->Delay6Gain=(sword)(gain*4095.0);
  //Conversion from effects routine to EAX
  if (glxAudioOutput.Type==GLX_EAX)
  {
	roomsize=3.0f*(avgdelay-mindelay)/(maxdelay-mindelay);
	EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,roomsize,Reverb->Volume,Reverb->Time,lpfa,maxgain);
  }
  return GLXERR_NOERROR;
}

static int glxSetMMXChorus(glxMMXChorus *MMXChorus,glxChorus *Chorus)
{
	int i;

	//Clear chorus structure
	memset(MMXChorus,0,sizeof(glxMMXChorus));
	//Set chorus parameters
	MMXChorus->Delay=(long)(Chorus->Delay*glxSamplingrate);
	MMXChorus->Depth=(long)(Chorus->Depth*Chorus->Delay*glxSamplingrate);
	MMXChorus->Speed=(long)((65536.0*Chorus->Rate)/glxSamplingrate);
	MMXChorus->Phase0=0;
	MMXChorus->Phase1=(65536/2);
	MMXChorus->Feedbackleft=MMXChorus->Feedbackleft=(short)(Chorus->Feedback*32767.0);
	MMXChorus->dryleft=MMXChorus->dryright=(short)(32767.0*1.0);
	MMXChorus->wetleft=MMXChorus->wetright=(short)(32767.0*Chorus->Volume);
	//Convert all parameters into a lookup table
	for (i=0;i<256;i++)
	{
		MMXChorus->wave[i    ]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(       i /256.0))));
		MMXChorus->wave[i+256]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((256.0-i)/256.0))));
		MMXChorus->wave[i+512]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(      -i /256.0))));
		MMXChorus->wave[i+768]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((i-256.0)/256.0))));
	}
	return GLXERR_NOERROR;
}

static int glxSetK3DChorus(glxK3DChorus *K3DChorus,glxChorus *Chorus)
{
	int i;
	
	//Clear reverb structure
	memset(K3DChorus,0,sizeof(glxK3DChorus));
	//Set reverb volume
	K3DChorus->Delay=-(long)(Chorus->Delay*glxSamplingrate);
	K3DChorus->Depth=-(long)(Chorus->Depth*Chorus->Delay*glxSamplingrate);
	K3DChorus->Speed=(long)((65536.0*Chorus->Rate)/glxSamplingrate);
	K3DChorus->Phase0=0;
	K3DChorus->Phase1=(65536/2);
	K3DChorus->Feedbackleft=K3DChorus->Feedbackright=Chorus->Feedback;
	K3DChorus->dryleft=K3DChorus->dryright=1.0;
	K3DChorus->wetleft=K3DChorus->wetright=Chorus->Volume;
	//Convert all parameters into a lookup table
	for (i=0;i<256;i++)
	{
		K3DChorus->wave[i    ]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(       i /256.0))));
		K3DChorus->wave[i+256]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((256.0-i)/256.0))));
		K3DChorus->wave[i+512]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(      -i /256.0))));
		K3DChorus->wave[i+768]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((i-256.0)/256.0))));
	}
	return GLXERR_NOERROR;
}

static int glxSetKNIChorus(glxKNIChorus *KNIChorus,glxChorus *Chorus)
{
	int i;
	
	//Clear reverb structure
	memset(KNIChorus,0,sizeof(glxKNIChorus));
	//Set reverb volume
	KNIChorus->Delay=-(long)(Chorus->Delay*glxSamplingrate);
	KNIChorus->Depth=-(long)(Chorus->Depth*Chorus->Delay*glxSamplingrate);
	KNIChorus->Speed=(long)((65536.0*Chorus->Rate)/glxSamplingrate);
	KNIChorus->Phase0=0;
	KNIChorus->Phase1=(65536/2);
	KNIChorus->Feedbackleft=KNIChorus->Feedbackright=Chorus->Feedback;
	KNIChorus->dryleft=KNIChorus->dryright=1.0;
	KNIChorus->wetleft=KNIChorus->wetright=Chorus->Volume;
	//Convert all parameters into a lookup table
	for (i=0;i<256;i++)
	{
		KNIChorus->wave[i    ]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(       i /256.0))));
		KNIChorus->wave[i+256]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((256.0-i)/256.0))));
		KNIChorus->wave[i+512]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*(      -i /256.0))));
		KNIChorus->wave[i+768]=-(long)(32768.0*glxSamplingrate*(Chorus->Delay*(1.0+Chorus->Depth*((i-256.0)/256.0))));
	}
	return GLXERR_NOERROR;
}

static int glxSetMMXReverb(glxMMXReverb *MMXReverb,glxReverb *Reverb)
{
	float mindelay=1.0,avgdelay=0.0,maxdelay=0.0;
	float maxgain=0.0,delay,gain,k,lpfa,roomsize;
	EAXLISTENERPROPERTIES eaxReverb;
	float T=0.0,DHFR1;
	int i;

	if ((Reverb->Volume<-1.0f)||(Reverb->Volume>1.0f))
		return GLXERR_BADPARAMETER;
	if (Reverb->HFDamp>glxSamplingrate)
		return GLXERR_BADPARAMETER;
	//Clear reverb structure
	memset(MMXReverb,0,sizeof(glxMMXReverb));
	//Set reverb volume
	MMXReverb->dryleft=MMXReverb->dryright=(short)(32767.0*1.0);
	MMXReverb->wetleft=MMXReverb->wetright=(short)(32767.0*Reverb->Volume);
	//Calculate 1-pole IIR LPF constant
	k=(float)(1.0-cos(2.0f*3.141f*Reverb->HFDamp/(float)glxSamplingrate));
	lpfa=(float)(sqrt(k*k+2.0f*k)-k);
	//Long allpass delay line #0
	delay=Reverb->Delay[0].Time;					
	gain=1.0f-Reverb->Delay[0].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td0=-(long)(delay*glxSamplingrate);
	MMXReverb->apf0lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf0lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf0gain0=-(short)(gain*32767.0);
	MMXReverb->apf0gain1=(short)(gain*32767.0);
	MMXReverb->apf0gain2=(short)((1.0-gain*gain)*32767.0);
	//Long allpass delay line #1
	delay=Reverb->Delay[1].Time;					
	gain=1.0f-Reverb->Delay[1].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td1=-(long)(delay*glxSamplingrate);
	MMXReverb->apf1lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf1lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf1gain0=-(short)(gain*32767.0);
	MMXReverb->apf1gain1=(short)(gain*32767.0);
	MMXReverb->apf1gain2=(short)((1.0-gain*gain)*32767.0);
	//Long allpass delay line #2
	delay=Reverb->Delay[2].Time;					
	gain=1.0f-Reverb->Delay[2].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td2=-(long)(delay*glxSamplingrate);
	MMXReverb->apf2lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf2lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf2gain0=-(short)(gain*32767.0);
	MMXReverb->apf2gain1=(short)(gain*32767.0);
	MMXReverb->apf2gain2=(short)((1.0-gain*gain)*32767.0);
	//Long allpass delay line #3
	delay=Reverb->Delay[3].Time;					
	gain=1.0f-Reverb->Delay[3].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td3=-(long)(delay*glxSamplingrate);
	MMXReverb->apf3lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf3lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf3gain0=-(short)(gain*32767.0);
	MMXReverb->apf3gain1=(short)(gain*32767.0);
	MMXReverb->apf3gain2=(short)((1.0-gain*gain)*32767.0);
	//Long allpass delay line #4
	delay=Reverb->Delay[4].Time;					
	gain=1.0f-Reverb->Delay[4].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td4=-(long)(delay*glxSamplingrate);
	MMXReverb->apf4lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf4lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf4gain0=-(short)(gain*32767.0);
	MMXReverb->apf4gain1=(short)(gain*32767.0);
	MMXReverb->apf4gain2=(short)((1.0-gain*gain)*32767.0);
	//Long allpass delay line #5
	delay=Reverb->Delay[5].Time;					
	gain=1.0f-Reverb->Delay[5].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	MMXReverb->td5=-(long)(delay*glxSamplingrate);
	MMXReverb->apf5lpfa=(short)((lpfa)*gain*32767.0);
	MMXReverb->apf5lpfb=(short)((1.0-lpfa)*32767.0);
	MMXReverb->apf5gain0=-(short)(gain*32767.0);
	MMXReverb->apf5gain1=(short)(gain*32767.0);
	MMXReverb->apf5gain2=(short)((1.0-gain*gain)*32767.0);
	//Calculate reverb time from six comb filters
	for (i=0;i<6;i++)
	{
		if ((Reverb->Delay[i].Time*Reverb->Delay[i].Gain)>(maxdelay*maxgain))
		{
			maxdelay=Reverb->Delay[i].Time;
			maxgain=Reverb->Delay[i].Gain;
			Reverb->Time=(float)((-60.0f*maxdelay)/(20.0f*log10(maxgain)));
		}
		if (Reverb->Delay[i].Time<mindelay)
			mindelay=Reverb->Delay[i].Time;
		avgdelay+=(Reverb->Delay[i].Time/6.0f);
	}
	//Conversion from effects routine to EAX
	if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
	{
		//EAX 1.x mapping
		roomsize=3.0f*(avgdelay-mindelay)/(maxdelay-mindelay);
		EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,roomsize,Reverb->Volume,Reverb->Time,lpfa,maxgain);
		//EAX 2.x mapping
		memset(&eaxReverb,0,sizeof(EAXLISTENERPROPERTIES));
		for (i=0;i<6;i++) T+=Reverb->Delay[i].Time;
		DHFR1=(float)(log10(0.5/sqrt(8.0))/log10(0.5));
		eaxReverb.lRoom=bound((long)(1000.0f*log10((Reverb->Volume*0.5*Reverb->Volume*0.5)/(1.0-0.5*0.5))),EAXLISTENER_MINROOM,EAXLISTENER_MAXROOM);
		eaxReverb.lRoomHF=EAXLISTENER_DEFAULTROOMHF;
		eaxReverb.flRoomRolloffFactor=0.0f;
		eaxReverb.flDecayTime=bound((float)(-1.5f*T/log10(0.5)),EAXLISTENER_MINDECAYTIME,EAXLISTENER_MAXDECAYTIME);
		eaxReverb.flDecayHFRatio=bound((float)(1.0/(1.0-((1.0-1.0/DHFR1)*(1.0-cos(2.0*3.141f*5000.0/glxSamplingrate))/(1.0-cos(2.0*3.141f*Reverb->HFDamp/glxSamplingrate))))),EAXLISTENER_MINDECAYHFRATIO,EAXLISTENER_MAXDECAYHFRATIO);
		eaxReverb.lReflections=EAXLISTENER_MINREFLECTIONS;
		eaxReverb.flReflectionsDelay=EAXLISTENER_MINREFLECTIONSDELAY;
		eaxReverb.flReverbDelay=bound((Reverb->Delay[0].Time+Reverb->Delay[2].Time+Reverb->Delay[4].Time),EAXLISTENER_MINREVERBDELAY,EAXLISTENER_MAXREVERBDELAY);
		if (eaxReverb.flReverbDelay>(Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time))
			eaxReverb.flReverbDelay=bound((Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time),EAXLISTENER_MINREVERBDELAY,EAXLISTENER_MAXREVERBDELAY);
		eaxReverb.dwEnvironment=EAX_ENVIRONMENT_GENERIC;
		eaxReverb.flEnvironmentSize=bound((float)pow(T/16.0f,0.333f),EAXLISTENER_MINENVIRONMENTSIZE,EAXLISTENER_MAXENVIRONMENTSIZE);
		eaxReverb.flEnvironmentDiffusion=EAXLISTENER_DEFAULTENVIRONMENTDIFFUSION;
		eaxReverb.flAirAbsorptionHF=0.0f;
		eaxReverb.dwFlags=0;
		IKsPropertySet_Set(
			(LPKSPROPERTYSET)glxAudioOutput.Extensions,
			&DSPROPSETID_EAX_ListenerProperties,
			DSPROPERTY_EAXLISTENER_ALLPARAMETERS,
			NULL,0,
			&eaxReverb,sizeof(EAXLISTENERPROPERTIES));
	}
	return GLXERR_NOERROR;
}

static int glxSetK3DReverb(glxK3DReverb *K3DReverb,glxReverb *Reverb)
{
	float mindelay=1.0,avgdelay=0.0,maxdelay=0.0;
	float maxgain=0.0,delay,gain,k,lpfa,roomsize;
	EAXLISTENERPROPERTIES eaxReverb;
	float T=0.0,DHFR1;
	int i;

	if ((Reverb->Volume<-1.0f)||(Reverb->Volume>1.0f))
		return GLXERR_BADPARAMETER;
	if (Reverb->HFDamp>glxSamplingrate)
		return GLXERR_BADPARAMETER;
	//Clear reverb structure
	memset(K3DReverb,0,sizeof(glxK3DReverb));
	//Set reverb volume
	K3DReverb->dryleft=K3DReverb->dryright=1.0;
	K3DReverb->wetleft=K3DReverb->wetright=Reverb->Volume;
	//Calculate 1-pole IIR LPF constant
	k=(float)(1.0-cos(2.0f*3.141f*Reverb->HFDamp/(float)glxSamplingrate));
	lpfa=(float)(sqrt(k*k+2.0f*k)-k);
	//Long allpass delay line #0
	delay=Reverb->Delay[0].Time;					
	gain=1.0f-Reverb->Delay[0].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td0=-(long)(delay*glxSamplingrate);
	K3DReverb->apf0lpfa=(lpfa);
	K3DReverb->apf0lpfb=(1.0f-lpfa);
	K3DReverb->apf0gain0=-gain;
	K3DReverb->apf0gain1=gain;
	K3DReverb->apf0gain2=(1.0f-gain*gain);
	//Long allpass delay line #1
	delay=Reverb->Delay[1].Time;					
	gain=1.0f-Reverb->Delay[1].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td1=-(long)(delay*glxSamplingrate);
	K3DReverb->apf1lpfa=(lpfa);
	K3DReverb->apf1lpfb=(1.0f-lpfa);
	K3DReverb->apf1gain0=-gain;
	K3DReverb->apf1gain1=gain;
	K3DReverb->apf1gain2=(1.0f-gain*gain);
	//Long allpass delay line #2
	delay=Reverb->Delay[2].Time;					
	gain=1.0f-Reverb->Delay[2].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td2=-(long)(delay*glxSamplingrate);
	K3DReverb->apf2lpfa=(lpfa);
	K3DReverb->apf2lpfb=(1.0f-lpfa);
	K3DReverb->apf2gain0=-gain;
	K3DReverb->apf2gain1=gain;
	K3DReverb->apf2gain2=(1.0f-gain*gain);
	//Long allpass delay line #3
	delay=Reverb->Delay[3].Time;					
	gain=1.0f-Reverb->Delay[3].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td3=-(long)(delay*glxSamplingrate);
	K3DReverb->apf3lpfa=(lpfa);
	K3DReverb->apf3lpfb=(1.0f-lpfa);
	K3DReverb->apf3gain0=-gain;
	K3DReverb->apf3gain1=gain;
	K3DReverb->apf3gain2=(1.0f-gain*gain);
	//Long allpass delay line #4
	delay=Reverb->Delay[4].Time;					
	gain=1.0f-Reverb->Delay[4].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td4=-(long)(delay*glxSamplingrate);
	K3DReverb->apf4lpfa=(lpfa);
	K3DReverb->apf4lpfb=(1.0f-lpfa);
	K3DReverb->apf4gain0=-gain;
	K3DReverb->apf4gain1=gain;
	K3DReverb->apf4gain2=(1.0f-gain*gain);
	//Long allpass delay line #5
	delay=Reverb->Delay[5].Time;					
	gain=1.0f-Reverb->Delay[5].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	K3DReverb->td5=-(long)(delay*glxSamplingrate);
	K3DReverb->apf5lpfa=(lpfa);
	K3DReverb->apf5lpfb=(1.0f-lpfa);
	K3DReverb->apf5gain0=-gain;
	K3DReverb->apf5gain1=gain;
	K3DReverb->apf5gain2=(1.0f-gain*gain);
	//Calculate reverb time from six comb filters
	for (i=0;i<6;i++)
	{
		if ((Reverb->Delay[i].Time*Reverb->Delay[i].Gain)>(maxdelay*maxgain))
		{
			maxdelay=Reverb->Delay[i].Time;
			maxgain=Reverb->Delay[i].Gain;
			Reverb->Time=(float)((-60.0f*maxdelay)/(20.0f*log10(maxgain)));
		}
		if (Reverb->Delay[i].Time<mindelay)
			mindelay=Reverb->Delay[i].Time;
		avgdelay+=(Reverb->Delay[i].Time/6.0f);
	}
	//Conversion from effects routine to EAX
	if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
	{
		//EAX 1.x mapping
		roomsize=3.0f*(avgdelay-mindelay)/(maxdelay-mindelay);
		EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,roomsize,Reverb->Volume,Reverb->Time,lpfa,maxgain);
		//EAX 2.x mapping
		memset(&eaxReverb,0,sizeof(EAXLISTENERPROPERTIES));
		for (i=0;i<6;i++) T+=Reverb->Delay[i].Time;
		DHFR1=(float)(log10(0.5/sqrt(8.0))/log10(0.5));
		eaxReverb.lRoom=(long)(1000.0f*log10((Reverb->Volume*0.5*Reverb->Volume*0.5)/(1.0-0.5*0.5)));
		eaxReverb.lRoomHF=0;
		eaxReverb.flDecayTime=(float)(-1.5f*T/log10(0.5));
		eaxReverb.flDecayHFRatio=(float)(1.0/(1.0-((1.0-1.0/DHFR1)*(1.0-cos(2.0*3.141f*5000.0/glxSamplingrate))/(1.0-cos(2.0*3.141f*Reverb->HFDamp/glxSamplingrate)))));
		eaxReverb.flReverbDelay=(Reverb->Delay[0].Time+Reverb->Delay[2].Time+Reverb->Delay[4].Time);
		if (eaxReverb.flReverbDelay>(Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time))
			eaxReverb.flReverbDelay=(Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time);
		eaxReverb.dwEnvironment=EAX_ENVIRONMENT_GENERIC;
		eaxReverb.flEnvironmentSize=(float)pow(T,0.333f);
		IKsPropertySet_Set(
			(LPKSPROPERTYSET)glxAudioOutput.Extensions,
			&DSPROPSETID_EAX_ListenerProperties,
			DSPROPERTY_EAXLISTENER_ALLPARAMETERS,
			NULL,0,
			&eaxReverb,sizeof(EAXLISTENERPROPERTIES));
	}
	return GLXERR_NOERROR;
}

static int glxSetKNIReverb(glxKNIReverb *KNIReverb,glxReverb *Reverb)
{
	float mindelay=1.0,avgdelay=0.0,maxdelay=0.0;
	float maxgain=0.0,delay,gain,k,lpfa,roomsize;
	EAXLISTENERPROPERTIES eaxReverb;
	float T=0.0,DHFR1;
	int i;

	if ((Reverb->Volume<-1.0f)||(Reverb->Volume>1.0f))
		return GLXERR_BADPARAMETER;
	if (Reverb->HFDamp>glxSamplingrate)
		return GLXERR_BADPARAMETER;
	//Clear reverb structure
	memset(KNIReverb,0,sizeof(glxKNIReverb));
	//Set reverb volume
	KNIReverb->dryleft=KNIReverb->dryright=1.0;
	KNIReverb->wetleft=KNIReverb->wetright=Reverb->Volume;
	//Calculate 1-pole IIR LPF constant
	k=(float)(1.0-cos(2.0f*3.141f*Reverb->HFDamp/(float)glxSamplingrate));
	lpfa=(float)(sqrt(k*k+2.0f*k)-k);
	//Long allpass delay line #0
	delay=Reverb->Delay[0].Time;					
	gain=1.0f-Reverb->Delay[0].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td0=-(long)(delay*glxSamplingrate);
	KNIReverb->apf0lpfa=(lpfa);
	KNIReverb->apf0lpfb=(1.0f-lpfa);
	KNIReverb->apf0gain0=-gain;
	KNIReverb->apf0gain1=gain;
	KNIReverb->apf0gain2=(1.0f-gain*gain);
	//Long allpass delay line #1
	delay=Reverb->Delay[1].Time;					
	gain=1.0f-Reverb->Delay[1].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td1=-(long)(delay*glxSamplingrate);
	KNIReverb->apf1lpfa=(lpfa);
	KNIReverb->apf1lpfb=(1.0f-lpfa);
	KNIReverb->apf1gain0=-gain;
	KNIReverb->apf1gain1=gain;
	KNIReverb->apf1gain2=(1.0f-gain*gain);
	//Long allpass delay line #2
	delay=Reverb->Delay[2].Time;					
	gain=1.0f-Reverb->Delay[2].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td2=-(long)(delay*glxSamplingrate);
	KNIReverb->apf2lpfa=(lpfa);
	KNIReverb->apf2lpfb=(1.0f-lpfa);
	KNIReverb->apf2gain0=-gain;
	KNIReverb->apf2gain1=gain;
	KNIReverb->apf2gain2=(1.0f-gain*gain);
	//Long allpass delay line #3
	delay=Reverb->Delay[3].Time;					
	gain=1.0f-Reverb->Delay[3].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td3=-(long)(delay*glxSamplingrate);
	KNIReverb->apf3lpfa=(lpfa);
	KNIReverb->apf3lpfb=(1.0f-lpfa);
	KNIReverb->apf3gain0=-gain;
	KNIReverb->apf3gain1=gain;
	KNIReverb->apf3gain2=(1.0f-gain*gain);
	//Long allpass delay line #4
	delay=Reverb->Delay[4].Time;					
	gain=1.0f-Reverb->Delay[4].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td4=-(long)(delay*glxSamplingrate);
	KNIReverb->apf4lpfa=(lpfa);
	KNIReverb->apf4lpfb=(1.0f-lpfa);
	KNIReverb->apf4gain0=-gain;
	KNIReverb->apf4gain1=gain;
	KNIReverb->apf4gain2=(1.0f-gain*gain);
	//Long allpass delay line #5
	delay=Reverb->Delay[5].Time;					
	gain=1.0f-Reverb->Delay[5].Gain;
	if (delay==0.0) delay=0.001f;
	if (gain==1.0) gain=0.999f;
	KNIReverb->td5=-(long)(delay*glxSamplingrate);
	KNIReverb->apf5lpfa=(lpfa);
	KNIReverb->apf5lpfb=(1.0f-lpfa);
	KNIReverb->apf5gain0=-gain;
	KNIReverb->apf5gain1=gain;
	KNIReverb->apf5gain2=(1.0f-gain*gain);
	//Calculate reverb time from six comb filters
	for (i=0;i<6;i++)
	{
		if ((Reverb->Delay[i].Time*Reverb->Delay[i].Gain)>(maxdelay*maxgain))
		{
			maxdelay=Reverb->Delay[i].Time;
			maxgain=Reverb->Delay[i].Gain;
			Reverb->Time=(float)((-60.0f*maxdelay)/(20.0f*log10(maxgain)));
		}
		if (Reverb->Delay[i].Time<mindelay)
			mindelay=Reverb->Delay[i].Time;
		avgdelay+=(Reverb->Delay[i].Time/6.0f);
	}
	//Conversion from effects routine to EAX
	if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
	{
		//EAX 1.x mapping
		roomsize=3.0f*(avgdelay-mindelay)/(maxdelay-mindelay);
		EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,roomsize,Reverb->Volume,Reverb->Time,lpfa,maxgain);
		//EAX 2.x mapping
		memset(&eaxReverb,0,sizeof(EAXLISTENERPROPERTIES));
		for (i=0;i<6;i++) T+=Reverb->Delay[i].Time;
		DHFR1=(float)(log10(0.5/sqrt(8.0))/log10(0.5));
		eaxReverb.lRoom=(long)(1000.0f*log10((Reverb->Volume*0.5*Reverb->Volume*0.5)/(1.0-0.5*0.5)));
		eaxReverb.lRoomHF=0;
		eaxReverb.flDecayTime=(float)(-1.5f*T/log10(0.5));
		eaxReverb.flDecayHFRatio=(float)(1.0/(1.0-((1.0-1.0/DHFR1)*(1.0-cos(2.0*3.141f*5000.0/glxSamplingrate))/(1.0-cos(2.0*3.141f*Reverb->HFDamp/glxSamplingrate)))));
		eaxReverb.flReverbDelay=(Reverb->Delay[0].Time+Reverb->Delay[2].Time+Reverb->Delay[4].Time);
		if (eaxReverb.flReverbDelay>(Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time))
			eaxReverb.flReverbDelay=(Reverb->Delay[1].Time+Reverb->Delay[3].Time+Reverb->Delay[5].Time);
		eaxReverb.dwEnvironment=EAX_ENVIRONMENT_GENERIC;
		eaxReverb.flEnvironmentSize=(float)pow(T,0.333f);
		IKsPropertySet_Set(
			(LPKSPROPERTYSET)glxAudioOutput.Extensions,
			&DSPROPSETID_EAX_ListenerProperties,
			DSPROPERTY_EAXLISTENER_ALLPARAMETERS,
			NULL,0,
			&eaxReverb,sizeof(EAXLISTENERPROPERTIES));
	}
	return GLXERR_NOERROR;
}

static void glxUpdateMusic(void)
{
	int Voice;

	glxCurrentTick++;
	if (glxMusicEnabled)
	{
		while ((glxCurrentPtr=glxProcessPattern(glxCurrentPtr))==NULL)
		{
			glxCallbackFunction(NULL,&glxCurrentPtr,0);
			while (glxCurrentPtr==NULL)
			{
				glxCurrentOrder++;
				glxPatternBreak=0;
				glxPatternRow=0xff;
				if (glxCurrentOrder==0)
				{
					glxCurrentSpeed=glxInitialSpeed;
					glxCurrentTempo=glxInitialTempo;
					glxSetTimers(glxCurrentTempo,glxCurrentSpeed);
					for (Voice=0;Voice<glxMusicVoices;Voice++)
						glxVoices[Voice+glxSampleVoices].Panning=glxVoices[Voice+glxSampleVoices].BasePanning=glxInitialPanning[Voice]<<8;
				}
				if ((glxCurrentOrder<=glxSongLength)&&(glxOrders[glxCurrentOrder]!=255))
				{
					if (glxOrders[glxCurrentOrder]<254)
						glxCurrentPtr=glxPatterns[glxOrders[glxCurrentOrder]];
				}
				else
				{
					glxMusicEnabled=GLX_OFF;
					glxCurrentOrder=0xff;
					if (glxMusicLooping)
						glxMusicEnabled=GLX_ON;
					else
						glxCallbackFunction(NULL,NULL,0);
				}
			}
		}
	}
}

static void glxUpdateInstruments(void)
{
	int DeltaTime,DeltaVolume,DeltaPitch,DeltaPanning;
	int Voice,Index,Period,Volume,SlideStep;
	glxArti *Instrument;
 
	for (Voice=0;Voice<(glxMusicVoices+glxSampleVoices);Voice++)
	{
		if ((glxVoices[Voice].Active)&&((Instrument=glxVoices[Voice].InsArt)!=NULL))
		{
			//Volume envelope
			if (glxVoices[Voice].InsArt->VolFlag&1)
			{
				if (glxVoices[Voice].InsVolTime==glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsVolPoint].Time)
				{
					if ((glxVoices[Voice].InsArt->VolFlag&4)&&(glxVoices[Voice].InsVolPoint==glxVoices[Voice].InsArt->VolLE))
					{
						glxVoices[Voice].InsVolPoint=glxVoices[Voice].InsArt->VolLS;
						glxVoices[Voice].InsVolTime=glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsArt->VolLS].Time;
						glxVoices[Voice].InsVol=glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsArt->VolLS].Value;
					}
					if ((glxVoices[Voice].InsArt->VolFlag&2)&&((glxVoices[Voice].NoteNo&128)==0)&&(glxVoices[Voice].InsVolPoint==glxVoices[Voice].InsArt->VolSustain))
					{
						//Sustain (*do nothing*)
						glxVoices[Voice].InsVol=glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsArt->VolSustain].Value;
					}
					else
					{
						if (glxVoices[Voice].InsVolPoint<glxVoices[Voice].InsArt->VolSize)
						{
							glxVoices[Voice].InsVol=glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsVolPoint].Value;
							DeltaTime=(glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsVolPoint+1].Time-glxVoices[Voice].InsVolTime);
							DeltaVolume=(glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsVolPoint+1].Value-glxVoices[Voice].InsVol);
							if (DeltaTime==0)
							{
								glxVoices[Voice].InsVol+=DeltaVolume;
								glxVoices[Voice].InsVolStep=0;
							}
							else
								glxVoices[Voice].InsVolStep=(DeltaVolume/DeltaTime);
							glxVoices[Voice].InsVolPoint++;
						}
					}
				}
				else
				{
					glxVoices[Voice].InsVol+=glxVoices[Voice].InsVolStep;
					glxVoices[Voice].InsVolTime++;
				}
			}
			else
				glxVoices[Voice].InsVol=glxVoices[Voice].InsVolFade=32767;
			//Pitch envelope
			if (glxVoices[Voice].InsArt->PitFlag&1)
			{
				if (glxVoices[Voice].InsPitTime==glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsPitPoint].Time)
				{
					if ((glxVoices[Voice].InsArt->PitFlag&4)&&((glxVoices[Voice].InsPitPoint)==glxVoices[Voice].InsArt->PitLE))
					{
						glxVoices[Voice].InsPitPoint=glxVoices[Voice].InsArt->PitLS;
						glxVoices[Voice].InsPitTime=glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsArt->PitLS].Time;
						glxVoices[Voice].InsPit=glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsArt->PitLS].Value;
					}
					if ((glxVoices[Voice].InsArt->PitFlag&2)&&((glxVoices[Voice].NoteNo&128)==0)&&(glxVoices[Voice].InsPitPoint==glxVoices[Voice].InsArt->PitSustain))
					{
						//Sustain (*do nothing*)
						glxVoices[Voice].InsPit=glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsArt->PitSustain].Value;
					}
					else
					{
						if (glxVoices[Voice].InsPitPoint<glxVoices[Voice].InsArt->PitSize)
						{
							glxVoices[Voice].InsPit=glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsPitPoint].Value;
							DeltaTime=(glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsPitPoint+1].Time-glxVoices[Voice].InsPitTime);
							DeltaPitch=(glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsPitPoint+1].Value-glxVoices[Voice].InsPit);
							if (DeltaTime==0)
							{
								glxVoices[Voice].InsPit+=DeltaPitch;
								glxVoices[Voice].InsPitStep=0;
							}
							else
								glxVoices[Voice].InsPitStep=(DeltaPitch/DeltaTime);
							glxVoices[Voice].InsPitPoint++;
						}
					}
				}
				else
				{	
					glxVoices[Voice].InsPit+=glxVoices[Voice].InsPitStep;
					glxVoices[Voice].InsPitTime++;
				}
			}
			else
				glxVoices[Voice].InsPit=glxVoices[Voice].InsPitFade=0;
			//Panning envelope
			if (glxVoices[Voice].InsArt->PanFlag&1)
			{
				if (glxVoices[Voice].InsPanTime==glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsPanPoint].Time)
				{
					if ((glxVoices[Voice].InsArt->PanFlag&4)&&((glxVoices[Voice].InsPanPoint)==glxVoices[Voice].InsArt->PanLE))
					{
						glxVoices[Voice].InsPanPoint=glxVoices[Voice].InsArt->PanLS;
						glxVoices[Voice].InsPanTime=glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsArt->PanLS].Time;
						glxVoices[Voice].InsPan=glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsArt->PanLS].Value;
					}
					if ((glxVoices[Voice].InsArt->PanFlag&2)&&((glxVoices[Voice].NoteNo&128)==0)&&(glxVoices[Voice].InsPanPoint==glxVoices[Voice].InsArt->PanSustain))
					{
						//Sustain (*do nothing*)
						glxVoices[Voice].InsPan=glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsArt->PanSustain].Value;
					}
					else
					{
						if (glxVoices[Voice].InsPanPoint<glxVoices[Voice].InsArt->PanSize)
						{
							glxVoices[Voice].InsPan=glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsPanPoint].Value;
							DeltaTime=(glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsPanPoint+1].Time-glxVoices[Voice].InsPanTime);
							DeltaPanning=(glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsPanPoint+1].Value-glxVoices[Voice].InsPan);
							if (DeltaTime==0)
							{
								glxVoices[Voice].InsPan+=DeltaPanning;
								glxVoices[Voice].InsPanStep=0;
							}
							else
								glxVoices[Voice].InsPanStep=(DeltaPanning/DeltaTime);
							glxVoices[Voice].InsPanPoint++;
						}
					}
				}
				else
				{
					glxVoices[Voice].InsPan+=glxVoices[Voice].InsPanStep;
					glxVoices[Voice].InsPanTime++;
				}
			}
			else
				glxVoices[Voice].InsPan=glxVoices[Voice].InsPanFade=0;
			//Envelope release
			if (glxVoices[Voice].NoteNo&128)
			{
				if (glxVoices[Voice].InsArt->VolFlag&1)
				{
					if (((glxPlayerMode&2)==0)&&(glxVoices[Voice].InsVolPoint<=glxVoices[Voice].InsArt->VolSustain))
					{
						glxVoices[Voice].InsVolPoint=glxVoices[Voice].InsArt->VolSustain;
						glxVoices[Voice].InsVolTime=glxVoices[Voice].InsArt->Volume[glxVoices[Voice].InsArt->VolSustain].Time;
					}
					if (glxVoices[Voice].InsVolFade<glxVoices[Voice].InsArt->VolFadeOut)
						glxVoices[Voice].InsVolFade=glxVoices[Voice].Active=GLX_OFF;
					else
						glxVoices[Voice].InsVolFade-=glxVoices[Voice].InsArt->VolFadeOut;
				}
				else
					glxVoices[Voice].InsVolFade=glxVoices[Voice].Active=GLX_OFF;
				if (glxVoices[Voice].InsArt->PitFlag&1)
				{
					if (((glxPlayerMode&2)==0)&&(glxVoices[Voice].InsPitPoint<=glxVoices[Voice].InsArt->PitSustain))
					{	
						glxVoices[Voice].InsPitPoint=glxVoices[Voice].InsArt->PitSustain;
						glxVoices[Voice].InsPitTime=glxVoices[Voice].InsArt->Pitch[glxVoices[Voice].InsArt->PitSustain].Time;
					}
					if (glxVoices[Voice].InsPitFade<glxVoices[Voice].InsArt->PitFadeOut)
						glxVoices[Voice].InsPitFade=0;
					else
						glxVoices[Voice].InsPitFade-=glxVoices[Voice].InsArt->PitFadeOut;
				}
				else
					glxVoices[Voice].InsPitFade=0;
				if (glxVoices[Voice].InsArt->PanFlag&1)
				{
					if (((glxPlayerMode&2)==0)&&(glxVoices[Voice].InsPanPoint<=glxVoices[Voice].InsArt->PanSustain))
					{
						glxVoices[Voice].InsPanPoint=glxVoices[Voice].InsArt->PanSustain;
						glxVoices[Voice].InsPanTime=glxVoices[Voice].InsArt->Panning[glxVoices[Voice].InsArt->PanSustain].Time;
					}
					if (glxVoices[Voice].InsPanFade<glxVoices[Voice].InsArt->PanFadeOut)
						glxVoices[Voice].InsPanFade=0;
					else
						glxVoices[Voice].InsPanFade-=glxVoices[Voice].InsArt->PanFadeOut;
				}
				else
					glxVoices[Voice].InsPanFade=0;
			}
			//Portamento (Pitch slide)
			SlideStep=glxVoices[Voice].PortaSpeed;
			if (glxVoices[Voice].SmpBasePeriod<glxVoices[Voice].PortaDest)
			{
				if ((glxVoices[Voice].PortaDest-glxVoices[Voice].SmpBasePeriod)<SlideStep)
					SlideStep=(glxVoices[Voice].PortaDest-glxVoices[Voice].SmpBasePeriod);
				glxVoices[Voice].SmpBasePeriod+=SlideStep;
			}
			if (glxVoices[Voice].SmpBasePeriod>glxVoices[Voice].PortaDest)
			{
				if ((glxVoices[Voice].SmpBasePeriod-glxVoices[Voice].PortaDest)<SlideStep)
					SlideStep=(glxVoices[Voice].SmpBasePeriod-glxVoices[Voice].PortaDest);
				glxVoices[Voice].SmpBasePeriod-=SlideStep;
			}
			//Pitch LFO (vibrato), Pitch Bend and Pitch Envelope
			Period=glxVoices[Voice].SmpBasePeriod+glxVoices[Voice].BenderValue;
			Index=((glxVoices[Voice].VibIndex+glxVoices[Voice].VibSpeed)&0xffff);
			Period+=((glxVoices[Voice].VibDepth*WaveTables[glxVoices[Voice].VibWaveType][Index>>10])>>8);
			Period+=((glxVoices[Voice].InsPit*glxVoices[Voice].InsPitFade)>>15);
			if (Period<0)
				Period=0;
			if (Period>30720)
				Period=30720;
			glxVoices[Voice].VibIndex=Index;
			glxVoices[Voice].SmpPeriod=Period;
			glxCalcPitch(&glxVoices[Voice],Period);
			//Modulation LFO (Tremolo)
			Volume=glxVoices[Voice].SmpBaseVol;
			Index=((glxVoices[Voice].TremIndex+glxVoices[Voice].TremSpeed)&0xffff);
			Volume+=((glxVoices[Voice].TremDepth*WaveTables[glxVoices[Voice].TremWaveType][Index>>10])>>8);
			if (Volume<GLX_MINSMPVOLUME)
				Volume=GLX_MINSMPVOLUME;
			if (Volume>GLX_MAXSMPVOLUME)
				Volume=GLX_MAXSMPVOLUME;
			glxVoices[Voice].TremIndex=Index;
			glxVoices[Voice].SmpVol=Volume;
		}
	}
}

static void glxUpdateStreams(void)
{
	int Voice;

	for (Voice=0;Voice<glxSampleVoices;Voice++)
	{
		if ((glxVoices[Voice].Enabled)&&(glxVoices[Voice].Active)&&(glxVoices[Voice].Flags&GLX_MASTER))
		{
			if ((glxVoices[Voice].SmpType&GLX_STREAMINGAUDIO)||(glxVoices[Voice].SmpType&GLX_COMPRESSED)||(glxVoices[Voice].SmpType&GLX_STEREOSAMPLE))
				PostThreadMessage(glxDecodeThreadID,WM_USER,(WPARAM)Voice,(LPARAM)(glxVoices[Voice].SmpPtr-glxVoices[Voice].SmpLoopStart));
		}
	}
}

static void glxUpdateVolumes(void)
{
	int Voice;

	//Update music master volume
	if (glxMusicVolDest<glxMusicVolume)
	{
		if (glxMusicVolSlide<(glxMusicVolDest-glxMusicVolume))
			glxMusicVolSlide=(glxMusicVolDest-glxMusicVolume);
	}
	else if (glxMusicVolDest>glxMusicVolume)
	{
		if (glxMusicVolSlide>(glxMusicVolDest-glxMusicVolume))
			glxMusicVolSlide=(glxMusicVolDest-glxMusicVolume);
	}
	if (glxMusicVolDest!=glxMusicVolume)
		glxMusicVolume+=glxMusicVolSlide;
	//Update sample master volume
	if (glxSampleVolDest<glxSampleVolume)
	{
		if (glxSampleVolSlide<(glxSampleVolDest-glxSampleVolume))
			glxSampleVolSlide=(glxSampleVolDest-glxSampleVolume);
	}
	else if (glxSampleVolDest>glxSampleVolume)
	{
		if (glxSampleVolSlide>(glxSampleVolDest-glxSampleVolume))
			glxSampleVolSlide=(glxSampleVolDest-glxSampleVolume);
	}
	if (glxSampleVolDest!=glxSampleVolume)
		glxSampleVolume+=glxSampleVolSlide;
	//Update voice volumes
	for (Voice=0;Voice<(glxMusicVoices+glxSampleVoices);Voice++)
	{
		if (glxVoices[Voice].VolDest<glxVoices[Voice].Vol)
		{
			if (glxVoices[Voice].VolSlide<(glxVoices[Voice].VolDest-glxVoices[Voice].Vol))
				glxVoices[Voice].VolSlide=(glxVoices[Voice].VolDest-glxVoices[Voice].Vol);
		}
		else if (glxVoices[Voice].VolDest>glxVoices[Voice].Vol)
		{
			if (glxVoices[Voice].VolSlide>(glxVoices[Voice].VolDest-glxVoices[Voice].Vol))
				glxVoices[Voice].VolSlide=(glxVoices[Voice].VolDest-glxVoices[Voice].Vol);
		}
		if (glxVoices[Voice].VolDest!=glxVoices[Voice].Vol)
			glxVoices[Voice].Vol+=glxVoices[Voice].VolSlide;
		glxVoices[Voice].Volume=(glxVoices[Voice].Vol*glxVoices[Voice].Vol*2);
	}
}

static int glxSoftwareMixer(char *DSPMusicBuffer,char *DSPSampleBuffer,char *DSPMusicReverbBuffer,char *DSPSampleReverbBuffer,char *DSPMusicChorusBuffer,char *DSPSampleChorusBuffer,int DSPBufferSize)
{
	int Voice,LeftVolume,RightVolume,Mode,LeftReverb,RightReverb,LeftChorus,RightChorus;
	int DSPBufferCount,DSPBufferIndex,DSPBlockShift,BlockShift;
	int Samples,SamplesLeft,Temp,Overshoot,ControlPoint;
	char *DSPBuffer,*DSPReverbBuffer,*DSPChorusBuffer;
	int FinalVolume,FinalPanning,MasterVolume;

	DSPBufferIndex=0;
	DSPBufferSize=(DSPBufferSize<512?DSPBufferSize:512);
	DSPBlockShift=(((glxMixerType&2)>>1)+(glxMixerType&GLX_STEREO)+1);
	BlockShift=((glxAudioOutput.Format&GLX_16BIT)>>1)+(glxAudioOutput.Format&GLX_STEREO);	
	memset(DSPMusicBuffer,0,DSPBufferSize<<DSPBlockShift);
	memset(DSPSampleBuffer,0,DSPBufferSize<<DSPBlockShift);
	memset(DSPMusicReverbBuffer,0,DSPBufferSize<<DSPBlockShift);
	memset(DSPSampleReverbBuffer,0,DSPBufferSize<<DSPBlockShift);
	memset(DSPMusicChorusBuffer,0,DSPBufferSize<<DSPBlockShift);
	memset(DSPSampleChorusBuffer,0,DSPBufferSize<<DSPBlockShift);
	while ((DSPBufferIndex<DSPBufferSize)&&(glxAudioBuffer.Premix))
	{
		//Timer 1 is for articulation / Timer 2 is for score processing
		DSPBufferCount=((DSPBufferSize-DSPBufferIndex)<<16);
		if (glxTimer1Count<DSPBufferCount)
			DSPBufferCount=(glxTimer1Count&0xffff0000);
		if (glxTimer2Count<DSPBufferCount)
			DSPBufferCount=(glxTimer2Count&0xffff0000);
		glxTimer1Count-=DSPBufferCount;
		if (glxTimer1Count<0x10000)
		{
			glxUpdateInstruments();
			glxTimer1Count+=glxTimer1Period;
		}
		glxTimer2Count-=DSPBufferCount;
		if (glxTimer2Count<0x10000)
		{
			glxUpdateMusic();
			glxUpdateStreams();
			glxUpdateVolumes();
			glxTimer2Count+=glxTimer2Period;
		}
		DSPBufferCount>>=16;
		//DSPBufferCount is samples to next timer event
		if (!glxAudioBuffer.Premix)
			continue;
		for (Voice=0;Voice<(glxSampleVoices+glxMusicVoices);Voice++)
		{
			if ((glxVoices[Voice].Enabled)&&(glxVoices[Voice].Active)&&(glxVoices[Voice].SmpPitch))
			{
				//Setup mixing mode (adaptive filtering)
				Mode=(glxVoices[Voice].SmpType&GLX_16BITSAMPLE)>>2;
				Mode|=((glxVoices[Voice].SmpPitch<65536?2:0)&((glxMixerType&4)>>1));
				Mode|=(glxVoices[Voice].Panning&32768)>>13;
				//Setup DSP buffers
				if (glxVoices[Voice].Flags&128)
				{
					DSPBuffer=DSPMusicBuffer;
					DSPReverbBuffer=DSPMusicReverbBuffer;
					DSPChorusBuffer=DSPMusicChorusBuffer;
					MasterVolume=(glxMusicVolume*glxMusicVolume*2);
				}
				else
				{
					DSPBuffer=DSPSampleBuffer;
					DSPReverbBuffer=DSPSampleReverbBuffer;
					DSPChorusBuffer=DSPSampleChorusBuffer;
					MasterVolume=(glxSampleVolume*glxSampleVolume*2);
				}
				//Calculate Final Panning
  				Temp=((glxVoices[Voice].BasePanning&0x7fff)-(glxVoices[Voice].Panning&0x7fff));
				if (Temp)
				{
					if (Temp<-512)
						Temp=-512;
					else if (Temp>512)
						Temp=512;
					glxVoices[Voice].Panning+=Temp;
				}
				FinalPanning=GLX_MIDSMPPANNING-abs((glxVoices[Voice].Panning&0x7fff)-GLX_MIDSMPPANNING);
				FinalPanning=(FinalPanning*glxVoices[Voice].InsPan)>>15;
				FinalPanning=(FinalPanning*glxVoices[Voice].InsPanFade)>>15;
				FinalPanning=(FinalPanning+(glxVoices[Voice].Panning&0x7fff));
				//Calculate Final Volume
				FinalVolume=(MasterVolume*glxVoices[Voice].Volume)>>15;
				FinalVolume=(FinalVolume*glxVoices[Voice].Velocity)>>15;
				FinalVolume=(FinalVolume*glxVoices[Voice].Expression)>>15;
				FinalVolume=(FinalVolume*glxVoices[Voice].InsVol)>>15;
				FinalVolume=(FinalVolume*glxVoices[Voice].InsVolFade)>>15;
				FinalVolume=(FinalVolume*glxVoices[Voice].SmpVol)>>15;
				//Calculate left and right volume levels
				LeftVolume=(FinalVolume*glxPanningFunction[32767-FinalPanning])>>15;
				RightVolume=(FinalVolume*glxPanningFunction[FinalPanning])>>15;
				//Calculate left and right reverb levels
				LeftReverb=(LeftVolume*glxVoices[Voice].Reverb)>>7;
				RightReverb=(RightVolume*glxVoices[Voice].Reverb)>>7;
				//Calculate left and right chorus levels
				LeftChorus=(LeftVolume*glxVoices[Voice].Chorus)>>7;
				RightChorus=(RightVolume*glxVoices[Voice].Chorus)>>7;
				//Set samples left to mix	
				SamplesLeft=DSPBufferCount;
				while ((SamplesLeft)&&(glxVoices[Voice].Active))
				{
					//Calculate samples to mix
					if ((glxVoices[Voice].SmpType&GLX_LOOPED)&&((glxVoices[Voice].SmpType&GLX_ALWAYSLOOP)||(!(glxVoices[Voice].NoteNo&128))||(glxVoices[Voice].SmpPitch<0)))
						ControlPoint=glxVoices[Voice].SmpLoopEnd;
					else
						ControlPoint=glxVoices[Voice].SmpEnd;
					Temp=ControlPoint-glxVoices[Voice].SmpPtr;
					if (Temp<-32767)
						Temp=-32767;
  					else if (Temp>32767)
						Temp=32767;
					Samples=(((Temp<<16)-glxVoices[Voice].SmpFrac)/glxVoices[Voice].SmpPitch)+1;
					Samples=(Samples<SamplesLeft?Samples:SamplesLeft);
					//Do actual mixing
					if (FinalVolume)
					{
						glxMixerCodeBase(
							DSPBuffer,DSPReverbBuffer,DSPChorusBuffer,
							Samples,
							glxVoices[Voice].SmpPtr,glxVoices[Voice].SmpFrac,
							glxVoices[Voice].SmpPitch,
							LeftVolume,RightVolume,
							LeftReverb,RightReverb,
							LeftChorus,RightChorus,
							Mode		
						);
					}
					//Update Voice position
					Temp=glxVoices[Voice].SmpPitch*Samples;
					Temp+=glxVoices[Voice].SmpFrac;
					glxVoices[Voice].SmpFrac=Temp&65535;
					glxVoices[Voice].SmpPtr+=Temp>>16;
					//Check looping and/or end-of-sample
					if (glxVoices[Voice].SmpPitch<0)
						Overshoot=ControlPoint-glxVoices[Voice].SmpPtr;
					else
						Overshoot=glxVoices[Voice].SmpPtr-ControlPoint;
					if (Overshoot>=0)
					{
						if ((glxVoices[Voice].SmpType&GLX_LOOPED)&&((glxVoices[Voice].SmpType&GLX_ALWAYSLOOP)||(!(glxVoices[Voice].NoteNo&128))||(glxVoices[Voice].SmpPitch<0)))
						{
							if (glxVoices[Voice].SmpType&GLX_BIDILOOP)
							{
								Temp=glxVoices[Voice].SmpLoopStart;
								glxVoices[Voice].SmpLoopStart=glxVoices[Voice].SmpLoopEnd;
								glxVoices[Voice].SmpLoopEnd=Temp;
								glxVoices[Voice].SmpPitch=-glxVoices[Voice].SmpPitch;
							}
							glxVoices[Voice].SmpPtr=glxVoices[Voice].SmpLoopStart+Overshoot;
						}
						else
						{
							glxVoices[Voice].Active=GLX_OFF;
							if (glxVoices[Voice].Flags&GLX_CALLBACK)
								glxCallbackFunction(&glxVoices[Voice],NULL,0);
						}
					}
					//Update variables
					SamplesLeft-=Samples;
					DSPBuffer+=(Samples<<DSPBlockShift);
					DSPReverbBuffer+=(Samples<<DSPBlockShift);
					DSPChorusBuffer+=(Samples<<DSPBlockShift);
				} 
			}
		}
		DSPBufferIndex+=DSPBufferCount;
		glxCurrentSample+=DSPBufferCount;
		DSPMusicBuffer+=(DSPBufferCount<<DSPBlockShift);
		DSPMusicReverbBuffer+=(DSPBufferCount<<DSPBlockShift);
		DSPMusicChorusBuffer+=(DSPBufferCount<<DSPBlockShift);
		DSPSampleBuffer+=(DSPBufferCount<<DSPBlockShift);
		DSPSampleReverbBuffer+=(DSPBufferCount<<DSPBlockShift);
		DSPSampleChorusBuffer+=(DSPBufferCount<<DSPBlockShift);
		glxAudioBuffer.Premix+=(DSPBufferCount<<BlockShift);
	}
	//Return SAMPLES written to buffers
	return DSPBufferIndex;
}

static int glxUpdateBuffer(char *Buffer, int BufferSize, int WritePos1, int WritePos2, int WriteCount1, int WriteCount2)
{
	int BufferCount1,BufferCount2;
	int BufferCount,BlockShift;
	int DSPBlockShift;
	int BytesWritten=0;

	//Calculate misc. shifts  
	DSPBlockShift=(((glxMixerType&GLX_16BIT)>>1)+(glxMixerType&GLX_STEREO)+1);
	BlockShift=((glxAudioOutput.Format&GLX_16BIT)>>1)+(glxAudioOutput.Format&GLX_STEREO);
	WriteCount1>>=BlockShift;
	WriteCount2>>=BlockShift;
	//Actual mixing loop
	while ((WriteCount1)&&(WriteCount2)&&(glxAudioBuffer.Premix))
	{
		//Mix music, effects and reverb into separate buffers
		if (BufferCount=glxSoftwareMixer(glxBufferBase1,glxBufferBase2,glxBufferBase3,glxBufferBase4,glxBufferBase5,glxBufferBase6,WriteCount1<WriteCount2?WriteCount1:WriteCount2))
		{
			if ((glxMusicReverb.Code)&&(glxMusicReverb.Data))
				glxMusicReverb.Code(glxMusicReverb.Data,glxBufferBase1,glxBufferBase3,BufferCount,0);
			if ((glxSampleReverb.Code)&&(glxSampleReverb.Data))
				glxSampleReverb.Code(glxSampleReverb.Data,glxBufferBase2,glxBufferBase4,BufferCount,0);
			if ((glxMusicChorus.Code)&&(glxMusicChorus.Data))
	  			glxMusicChorus.Code(glxMusicChorus.Data,glxBufferBase1,glxBufferBase5,BufferCount,0);
			if ((glxSampleChorus.Code)&&(glxSampleChorus.Data))
	  			glxSampleChorus.Code(glxSampleChorus.Data,glxBufferBase2,glxBufferBase6,BufferCount,0);
		}
		//Convert to output format (with cyclic buffer logic)   
		BufferCount1=BufferCount;
		if (((BufferSize-WritePos1)>>BlockShift)<BufferCount1)
			BufferCount1=((BufferSize-WritePos1)>>BlockShift);
		BufferCount2=BufferCount-BufferCount1;
		glxPostProcBase(glxBufferBase1,BufferCount1,Buffer+WritePos1,glxAudioOutput.Format);  
		glxPostProcBase(glxBufferBase1+(BufferCount1<<DSPBlockShift),BufferCount2,Buffer,glxAudioOutput.Format);  
		BufferCount1=BufferCount;
		if (((BufferSize-WritePos2)>>BlockShift)<BufferCount1)
			BufferCount1=((BufferSize-WritePos2)>>BlockShift);
		BufferCount2=BufferCount-BufferCount1;
		glxPostProcBase(glxBufferBase2,BufferCount1,Buffer+WritePos2,64|glxAudioOutput.Format);  
		glxPostProcBase(glxBufferBase2+(BufferCount1<<DSPBlockShift),BufferCount2,Buffer,64|glxAudioOutput.Format);
		//Update write positions and counters
		WritePos1=((WritePos1+(BufferCount<<BlockShift))%BufferSize);
		WritePos2=((WritePos2+(BufferCount<<BlockShift))%BufferSize);
		WriteCount1-=BufferCount;
		WriteCount2-=BufferCount;
		//Update total byte counter
		BytesWritten+=(BufferCount<<BlockShift);
	}
	return BytesWritten;
}

static void glxUpdateHardwareStatus(void)
{
	int status,i;

	for (i=0;i<glxSampleVoices;i++)
	{
		if ((glxVoices[i].Custom1)&&(glxVoices[i].Flags&GLX_POSITIONAL))
		{
			if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2)||(glxAudioOutput.Type==GLX_A3D))
			{
				IDirectSoundBuffer_GetStatus((LPDIRECTSOUNDBUFFER)glxVoices[i].Custom1,&status);
				glxVoices[i].Active=((status&DSBSTATUS_PLAYING)==DSBSTATUS_PLAYING);
				if (!glxVoices[i].Active)
				{
					glxStopSample3D(&glxVoices[i]);
					if (glxVoices[i].Flags&GLX_CALLBACK)
						glxCallbackFunction(&glxVoices[i],NULL,0);
				}
			}
			else if (glxAudioOutput.Type==GLX_A3D2)
			{
				((LPA3DSOURCE)glxVoices[i].Custom1)->lpVtbl->GetStatus((LPA3DSOURCE)glxVoices[i].Custom1,&status);
				glxVoices[i].Active=(((status&A3DSTATUS_PLAYING)==A3DSTATUS_PLAYING)||((status&A3DSTATUS_WAITING_FOR_FLUSH)==A3DSTATUS_WAITING_FOR_FLUSH));
				if (!glxVoices[i].Active)
				{
					glxStopSample3D(&glxVoices[i]);
					if (glxVoices[i].Flags&GLX_CALLBACK)
						glxCallbackFunction(&glxVoices[i],NULL,0);
				}
			}
		}
	}
}

static void CALLBACK glxDSTimerHandler(UINT IDEvent,UINT uReserved,DWORD dwUser,DWORD dwReserved1,DWORD dwReserved2)
{
	int MixedBytes,MusicBytes,PremixBytes,SampleBytes;
	DWORD AudioPlay,AudioWrite;
	DWORD AudioPtrCnt,AudioPtr2Cnt;
	BYTE *AudioPtr,*AudioPtr2;
	HRESULT DSRes;
  
	if (glxOutputActive)
	{
		glxLock();
		glxUpdateHardwareStatus();
		// Get current (play and) write position(s)
		if (IDirectSoundBuffer_GetCurrentPosition((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,&AudioPlay,&AudioWrite)==DS_OK)
		{
			// Get current play and write positions
			AudioPlay=AudioPlay%glxAudioBuffer.Length;
			AudioWrite=AudioWrite%glxAudioBuffer.Length;
			// Calculate play/write positions
			AudioWrite=(AudioWrite+(EfxMixAhead*OutputType.nAvgBytesPerSec/1000))%glxAudioBuffer.Length;
			// Align play/write cursor to sample boundaries
			AudioPlay&=~(OutputType.nBlockAlign-1);
			AudioWrite&=~(OutputType.nBlockAlign-1);
			// Set initial values
			if (glxAudioBuffer.PlayPos==glxAudioBuffer.WritePos)
			{
				glxAudioBuffer.PlayPos=AudioPlay;
				glxAudioBuffer.WritePos=AudioWrite;
			}
			// Calculate total bytes to update
			MusicBytes=(AudioPlay-glxAudioBuffer.PlayPos);
			if (MusicBytes<0) MusicBytes+=glxAudioBuffer.Length;
			SampleBytes=(AudioWrite-glxAudioBuffer.WritePos);
			if (SampleBytes<0) SampleBytes+=glxAudioBuffer.Length;
			// Adjust size of premix
			glxAudioBuffer.Premix-=(MusicBytes<SampleBytes?MusicBytes:SampleBytes);
			// Refill premix buffer if lost
			if (glxAudioBuffer.Premix<=0) 
			{
				// Calculate total bytes to premix
				PremixBytes=(glxAudioBuffer.PlayPos-glxAudioBuffer.WritePos);
				if (PremixBytes<0) PremixBytes+=glxAudioBuffer.Length;
				// Set size of premix
				glxAudioBuffer.Premix=(glxAudioBuffer.WritePos-glxAudioBuffer.PlayPos);
				if (glxAudioBuffer.Premix<0) glxAudioBuffer.Premix+=glxAudioBuffer.Length;
				// Update audio buffer
				MixedBytes=glxUpdateBuffer(glxAudioBuffer.Data,glxAudioBuffer.Length,glxAudioBuffer.WritePos,glxAudioBuffer.WritePos,PremixBytes,PremixBytes);
				// Copy to DirectSound buffer
				DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,glxAudioBuffer.Length,&AudioPtr,&AudioPtrCnt,NULL,NULL,DSBLOCK_ENTIREBUFFER);
				if (DSRes==DSERR_BUFFERLOST)
				{
					IDirectSoundBuffer_Restore((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
					IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,0,DSBPLAY_LOOPING);
					DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,glxAudioBuffer.Length,&AudioPtr,&AudioPtrCnt,NULL,NULL,DSBLOCK_ENTIREBUFFER);
				}
				if (DSRes==DS_OK)
				{
					memcpy(AudioPtr,glxAudioBuffer.Data,glxAudioBuffer.Length);
					IDirectSoundBuffer_Unlock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,AudioPtr,AudioPtrCnt,NULL,0);
				}
			}
			//Continue only if valid premix buffer
			if (glxAudioBuffer.Premix)
			{
				// Update audio buffer
				MixedBytes=glxUpdateBuffer(glxAudioBuffer.Data,glxAudioBuffer.Length,glxAudioBuffer.PlayPos,glxAudioBuffer.WritePos,MusicBytes,SampleBytes);
				// Copy to DirectSound buffer (music)
				DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,glxAudioBuffer.PlayPos,MixedBytes,&AudioPtr,&AudioPtrCnt,&AudioPtr2,&AudioPtr2Cnt,0);
				if (DSRes==DSERR_BUFFERLOST)
				{
					IDirectSoundBuffer_Restore((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
					IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,0,DSBPLAY_LOOPING);
					DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,glxAudioBuffer.PlayPos,MixedBytes,&AudioPtr,&AudioPtrCnt,&AudioPtr2,&AudioPtr2Cnt,0);
				}
				if (DSRes==DS_OK)
				{
					memcpy(AudioPtr,glxAudioBuffer.Data+glxAudioBuffer.PlayPos,AudioPtrCnt);
					memcpy(AudioPtr2,glxAudioBuffer.Data,AudioPtr2Cnt);
					IDirectSoundBuffer_Unlock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,AudioPtr,AudioPtrCnt,AudioPtr2,AudioPtr2Cnt);
				}
				// Copy to DirectSound buffer (samples)
				DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,glxAudioBuffer.WritePos,MixedBytes,&AudioPtr,&AudioPtrCnt,&AudioPtr2,&AudioPtr2Cnt,0);
				if (DSRes==DSERR_BUFFERLOST)
				{
					IDirectSoundBuffer_Restore((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
					IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,0,DSBPLAY_LOOPING);
					DSRes=IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,glxAudioBuffer.WritePos,MixedBytes,&AudioPtr,&AudioPtrCnt,&AudioPtr2,&AudioPtr2Cnt,0);
				}
				if (DSRes==DS_OK)
				{
					memcpy(AudioPtr,glxAudioBuffer.Data+glxAudioBuffer.WritePos,AudioPtrCnt);
					memcpy(AudioPtr2,glxAudioBuffer.Data,AudioPtr2Cnt);
					IDirectSoundBuffer_Unlock((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,AudioPtr,AudioPtrCnt,AudioPtr2,AudioPtr2Cnt);
				}
				// Update mixed positions
				glxAudioBuffer.PlayPos=(glxAudioBuffer.PlayPos+MixedBytes)%glxAudioBuffer.Length;
				glxAudioBuffer.WritePos=(glxAudioBuffer.WritePos+MixedBytes)%glxAudioBuffer.Length;
			}
		}
		glxUnlock();
	}
}

static void CALLBACK glxMMTimerHandler(UINT IDEvent,UINT uReserved,DWORD dwUser,DWORD dwReserved1,DWORD dwReserved2)
{
	int MixedBytes,MusicBytes,PremixBytes,SampleBytes;
	DWORD AudioPlay,AudioWrite;
	MMTIME MMPos;

	if (glxOutputActive)
	{
		glxLock();
		// Get current (play and) write position(s)
		MMPos.wType=TIME_BYTES;
		if (waveOutGetPosition((HWAVEOUT)glxAudioOutput.Handle,&MMPos,sizeof(MMTIME))==MMSYSERR_NOERROR)
		{
			// Get current play and write positions
			AudioPlay=(MMPos.u.cb-((2048*OutputType.nAvgBytesPerSec)/11025))%glxAudioBuffer.Length;
			AudioWrite=(MMPos.u.cb+((2048*OutputType.nAvgBytesPerSec)/11025))%glxAudioBuffer.Length;
			// Calculate play/write positions
			AudioWrite=(AudioWrite+(EfxMixAhead*OutputType.nAvgBytesPerSec/1000))%glxAudioBuffer.Length;
			// Align play/write cursor to sample boundaries
			AudioPlay&=~(OutputType.nBlockAlign-1);
			AudioWrite&=~(OutputType.nBlockAlign-1);
			// Set initial values
			if (glxAudioBuffer.PlayPos==glxAudioBuffer.WritePos)
			{
				glxAudioBuffer.PlayPos=AudioPlay;
				glxAudioBuffer.WritePos=AudioWrite;
			}
			// Calculate total bytes to update
			MusicBytes=(AudioPlay-glxAudioBuffer.PlayPos);
			if (MusicBytes<0) MusicBytes+=glxAudioBuffer.Length;
			SampleBytes=(AudioWrite-glxAudioBuffer.WritePos);
			if (SampleBytes<0) SampleBytes+=glxAudioBuffer.Length;
			// Adjust size of premix
			glxAudioBuffer.Premix-=(MusicBytes<SampleBytes?MusicBytes:SampleBytes);
			// Refill premix buffer if lost
			if (glxAudioBuffer.Premix<=0) 
			{
				// Calculate total bytes to premix
				PremixBytes=(glxAudioBuffer.PlayPos-glxAudioBuffer.WritePos);
				if (PremixBytes<0) PremixBytes+=glxAudioBuffer.Length;
				// Set size of premix
				glxAudioBuffer.Premix=(glxAudioBuffer.WritePos-glxAudioBuffer.PlayPos);
				if (glxAudioBuffer.Premix<0) glxAudioBuffer.Premix+=glxAudioBuffer.Length;
				// Update audio buffer
				MixedBytes=glxUpdateBuffer(glxAudioBuffer.Data,glxAudioBuffer.Length,glxAudioBuffer.WritePos,glxAudioBuffer.WritePos,PremixBytes,PremixBytes);
			}
			// Update premix buffer
			if (glxAudioBuffer.Premix>0)
			{
				// Update audio buffer
				MixedBytes=glxUpdateBuffer(glxAudioBuffer.Data,glxAudioBuffer.Length,glxAudioBuffer.PlayPos,glxAudioBuffer.WritePos,MusicBytes,SampleBytes);
				// Update mixed positions
				glxAudioBuffer.PlayPos=(glxAudioBuffer.PlayPos+MixedBytes)%glxAudioBuffer.Length;
				glxAudioBuffer.WritePos=(glxAudioBuffer.WritePos+MixedBytes)%glxAudioBuffer.Length;
			}
		}
		glxUnlock();
	}
}

static DWORD WINAPI glxDecodeThread(void *Param)
{
	long ReadCursor,WriteCursor,SourceCursor,SampleSize,SourceSize;
	long BytesRead,BytesWritten,BytesToCopy,Done,StreamBufferSize;
	glxVoice *LVoice,*RVoice,*NextVoice;
	HANDLE Mutexes[GLX_TOTALVOICES];
	char *Source,*Left,*Right;
	MSG	Msg;
	int i=0;
	
	while (GetMessage(&Msg,NULL,0,0))
	{	
		switch(Msg.message)
		{
			case WM_USER:
				if ((glxVoices[Msg.wParam].SmpType&GLX_STREAMINGAUDIO)||(glxVoices[Msg.wParam].SmpType&GLX_COMPRESSED)||(glxVoices[Msg.wParam].SmpType&GLX_STEREOSAMPLE))
				{
					//Fill voice decode buffer
					i=0;
					NextVoice=&glxVoices[Msg.wParam];
					while ((NextVoice)&&(NextVoice->Mutex))
					{
						Mutexes[i]=NextVoice->Mutex;
						NextVoice=NextVoice->Link;
						i++;
					} 
					if (WaitForMultipleObjects(i,Mutexes,TRUE,1000)==WAIT_OBJECT_0)
					{
						if (glxVoices[Msg.wParam].Mutex)
						{
							LVoice=&glxVoices[Msg.wParam];
							RVoice=(glxVoice *)LVoice->Link;
							if ((!RVoice)||((RVoice)&&(RVoice->Mutex)))
							{
								//Get source/write positions
								ReadCursor=(LVoice->SmpType&GLX_16BITSAMPLE?Msg.lParam<<1:Msg.lParam);
								WriteCursor=LVoice->Custom1;
								SourceCursor=LVoice->Custom2;
								SampleSize=(LVoice->SmpType&GLX_COMPRESSED?1:((LVoice->SmpType&GLX_16BITSAMPLE?2:1)*(LVoice->SmpType&GLX_STEREOSAMPLE?2:1)));
								SourceSize=(LVoice->SmpHdr->Length*SampleSize);
								StreamBufferSize=(LVoice->SmpHdr->Reserved);
								Source=(char *)(LVoice->SmpHdr->Data);
								Left=(char *)(LVoice?(LVoice->SmpType&GLX_16BITSAMPLE?LVoice->SmpLoopStart<<1:LVoice->SmpLoopStart):0);
								Right=(char *)(RVoice?(RVoice->SmpType&GLX_16BITSAMPLE?RVoice->SmpLoopStart<<1:RVoice->SmpLoopStart):0);
								//Figure how much decoded data
								if (WriteCursor==StreamBufferSize)
									WriteCursor=((ReadCursor+2048)%StreamBufferSize);
								BytesToCopy=(ReadCursor-WriteCursor);
								if (BytesToCopy<0) BytesToCopy+=StreamBufferSize;
								BytesToCopy=(BytesToCopy<StreamBufferSize?BytesToCopy:StreamBufferSize);
								//Decode stream
								if (LVoice->SmpType&GLX_STREAMINGAUDIO)
								{
									SourceCursor=LVoice->Custom3;
									SourceSize=LVoice->Custom4;
								}
								Done=0;
								while ((Done<2)&&(BytesToCopy))
								{
									glxConvertSample(LVoice->SmpHdr,Source+SourceCursor,SourceSize-SourceCursor,LVoice?Left+WriteCursor:NULL,RVoice?Right+WriteCursor:NULL,BytesToCopy<(StreamBufferSize-WriteCursor)?BytesToCopy:(StreamBufferSize-WriteCursor),&BytesRead,&BytesWritten);
									if ((!BytesRead)&&(!BytesWritten))
									{
										if ((LVoice->SmpType&GLX_STREAMINGAUDIO)&&(SourceCursor))
										{
											memcpy(Source,Source+SourceCursor,SourceSize-SourceCursor);
											SourceSize=SourceSize-SourceCursor+glxCallbackFunction(&glxVoices[Msg.wParam],Source+SourceSize-SourceCursor,SourceCursor);
											LVoice->Custom2+=SourceCursor;
											SourceCursor=0;
										}
										Done++;
									}
									else 
									{
										WriteCursor=((WriteCursor+BytesWritten)%StreamBufferSize);
										BytesToCopy-=BytesWritten;
										SourceCursor+=BytesRead;
										Done=0;	
									}
								} 
								if (LVoice->SmpType&GLX_STREAMINGAUDIO)
								{
									LVoice->Custom3=SourceCursor;
									LVoice->Custom4=SourceSize;
									SourceCursor+=LVoice->Custom2;
								}
								//Check for end of sample
								if (BytesToCopy)
								{
									if ((LVoice->SmpHdr->Type&GLX_LOOPED)==0)
									{
										if (LVoice)
										{
											if (ReadCursor<WriteCursor)
											{
												LVoice->SmpType&=~(GLX_ALWAYSLOOP|GLX_LOOPED);
												LVoice->SmpEnd=LVoice->SmpLoopEnd=(LVoice->SmpType&GLX_16BITSAMPLE?(((udword)Left+WriteCursor)>>1):((udword)Left+WriteCursor));
											}
											if ((StreamBufferSize-WriteCursor)<BytesToCopy)
											{
												memset(Left+WriteCursor,0,StreamBufferSize-WriteCursor);
												memset(Left,0,BytesToCopy-StreamBufferSize+WriteCursor);
											}
											else memset(Left+WriteCursor,0,BytesToCopy);
										}
										if (RVoice)
										{
											if (ReadCursor<WriteCursor)
											{
												RVoice->SmpType&=~(GLX_ALWAYSLOOP|GLX_LOOPED);
												RVoice->SmpEnd=RVoice->SmpLoopEnd=(RVoice->SmpType&GLX_16BITSAMPLE?(((udword)Right+WriteCursor)>>1):((udword)Right+WriteCursor));
											}
											if ((StreamBufferSize-WriteCursor)<BytesToCopy)
											{
												memset(Right+WriteCursor,0,StreamBufferSize-WriteCursor);
												memset(Right,0,BytesToCopy-StreamBufferSize+WriteCursor);
											}
											else memset(Right+WriteCursor,0,BytesToCopy);
										}
										WriteCursor=((WriteCursor+BytesToCopy)%StreamBufferSize);
									}
									else
									{
										SourceCursor=LVoice->SmpHdr->LoopStart;
									}
								}
								//Update source/write positions
								LVoice->Custom1=WriteCursor;
								LVoice->Custom2=SourceCursor;
								//Release this voice
								if ((RVoice)&&(RVoice->Mutex))
									ReleaseMutex(RVoice->Mutex);
							}
							ReleaseMutex(LVoice->Mutex);
						}
					}
				}
				break;
			default:
				break;
		}
	}
	return GLXERR_NOERROR;
}

/* External routines */

glxSample * __cdecl glxAllocateStreamingBuffer(char *Name,int Length,int Frequency,int Format,int Size)
{
	glxSample *Sample;

	if (Sample=getmem(sizeof(glxSample)))
	{
		memset(Sample,0,sizeof(glxSample));
		/* Validate sample structure */
		Sample->FourCC=GLX_FOURCC_SAMP;
		Sample->Size=sizeof(glxSample)-8;
		if (Name) memcpy(Sample->Message,Name,strlen(Name)<28?strlen(Name):28);
		Sample->Panning=GLX_MIDSMPPANNING;
		Sample->Volume=GLX_MAXSMPVOLUME;
		Sample->Type=GLX_STREAMINGAUDIO|Format;
		Sample->Length=Length;
		Sample->LoopStart=0;
		Sample->LoopEnd=0;
		Sample->C4Speed=Frequency;
		Sample->Reserved=Size;
		Sample->Data=getmem(Sample->Reserved);
		return Sample;
	}
	return GLX_NULL;
}

glxVoice * __cdecl glxAllocateSampleVoice(glxVoice *ThisVoice)
{
	udword Voice,StartTime=0xfffffffe;
	glxVoice *EmptyVoice=NULL;

	glxLock();
	for (Voice=0;Voice<glxSampleVoices;Voice++)
	{
		if ((glxVoices[Voice].Active==GLX_OFF)&&(glxVoices[Voice].Flags&GLX_MASTER))
		{
			EmptyVoice=&glxVoices[Voice];
			StartTime=EmptyVoice->StartTime=0;
		}
		else if ((&glxVoices[Voice]!=ThisVoice)&&(glxVoices[Voice].StartTime<StartTime))
		{
			EmptyVoice=&glxVoices[Voice];
			StartTime=EmptyVoice->StartTime;
		}
	}
	glxUnlock();
	return EmptyVoice;
}

glxVoice * __cdecl glxAllocateInstrumentVoice(void)
{
	udword Voice,StartTime=0xfffffffe;
	glxVoice *EmptyVoice=NULL;

	glxLock();
    for (Voice=0;Voice<glxSampleVoices;Voice++)
    {
		if ((glxVoices[Voice].NoteNo&128)&&(glxVoices[Voice].StartTime<StartTime))
		{
			EmptyVoice=&glxVoices[Voice];
			StartTime=EmptyVoice->StartTime;
		}
    }
    glxUnlock();
    return EmptyVoice;
}

int __cdecl glxControlChannel(int Channel,int Command,int Parameter1,int Parameter2)
{
	int Key,Result=GLXERR_NOERROR;
	
	if ((Channel>=0)&&(Channel<=GLX_TOTALCHANNELS))
	{
		glxLock();
		switch (Command)
		{
			case GLX_SETMODE:
				for (Key=0;Key<128;Key++)
					glxControlVoice(glxChannels[Channel].VoiceMap[Key],GLX_SETMODE,Parameter1,Parameter2);
				break;
			case GLX_SETVOLUME:
				for (Key=0;Key<128;Key++)
					glxControlVoice(glxChannels[Channel].VoiceMap[Key],GLX_SETVOLUME,Parameter1,Parameter2);
				break;
			default:		
				Result=GLXERR_BADPARAMETER;
				break;
		}	
		glxUnlock();
		return Result;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxControlVoice(glxVoice *Voice,int Command,int Parameter1,int Parameter2)
{
	int Result=GLXERR_NOERROR;
	
	if (Voice)
	{
		glxLock();
		switch (Command)
		{
			case GLX_GETSTATUS:
				if (Voice->Flags&GLX_POSITIONAL)
				{
					if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2)||(glxAudioOutput.Type==GLX_A3D))
					{
						if (Voice->Custom1)
						{
							IDirectSoundBuffer_GetStatus((LPDIRECTSOUNDBUFFER)Voice->Custom1,&Result);
							Voice->Active=((Result&DSBSTATUS_PLAYING)==DSBSTATUS_PLAYING);
						}
					}
					else if (glxAudioOutput.Type==GLX_A3D2)
					{
						if (Voice->Custom1)
						{
							((LPA3DSOURCE)Voice->Custom1)->lpVtbl->GetStatus((LPA3DSOURCE)Voice->Custom1,&Result);
							Voice->Active=(((Result&A3DSTATUS_PLAYING)==A3DSTATUS_PLAYING)||((Result&A3DSTATUS_WAITING_FOR_FLUSH)==A3DSTATUS_WAITING_FOR_FLUSH));
						}
					}
				}
				Result=(Voice->Active);
				break;
			case GLX_SETMODE:
				if ((Parameter1==GLX_ON)||(Parameter1==GLX_OFF))
					Voice->Enabled=Parameter1;
				else Result=GLXERR_BADPARAMETER;
				break;			
			case GLX_SETVOLUME:
				if ((Parameter1>=0)&&(Parameter1<=127))
				{
					if (Parameter2==GLX_VOLSET)
					{
						Voice->Vol=Parameter1;
						Voice->VolSlide=0;
						Voice->VolDest=Parameter1;
					}
					else
					{
						if (Voice->Vol<Parameter1)
							Voice->VolSlide=Parameter2;
						else
							Voice->VolSlide=-Parameter2;
						Voice->VolDest=Parameter1;
					}
				}
				else Result=GLXERR_BADPARAMETER;
				break;
			default:
				Result=GLXERR_BADPARAMETER;
				break;
		}	
		glxUnlock();
		return Result;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxControlMusic(int Command,int Parameter)
{
	int Result=GLXERR_NOERROR;

	glxLock();
	switch (Command)
	{
		case GLX_SETPOSITION:
			if (Parameter<0)
				Parameter+=(glxCurrentOrder+2);
			if (Parameter<=glxSongLength)
			{
				glxCurrentOrder=Parameter-1;
				glxPatternBreak=1;
				glxFlushOutput();
			}
			else Result=GLXERR_BADPARAMETER;
			break;
		case GLX_SETPOSITION2:
			if (Parameter<0)
				Parameter+=(glxCurrentOrder+2);
			if (Parameter<=glxSongLength)
				glxCurrentOrder=Parameter-1;
			else Result=GLXERR_BADPARAMETER;
			break;
		case GLX_SETLOOPMODE:
			glxMusicLooping=Parameter;
			break;
		default:
			Result=GLXERR_BADPARAMETER;
			break;
	}
	glxUnlock();
	return Result;
}

int __cdecl glxControlInstrument(glxVoice *Voice,int Pitchwheel,int Volume,int Velocity,int Expression,int Panning,int Modulation,int Reverb,int Chorus)
{
	if (Voice)
	{
		glxLock();
		if (Pitchwheel!=GLX_DEFINSPITCH)
			Voice->BenderValue=Pitchwheel;
		if (Volume!=GLX_DEFINSVOLUME)
			Voice->VolDest=Voice->Vol=Volume;
		if (Velocity!=GLX_DEFINSVELOCITY)
			Voice->Velocity=(Velocity*Velocity*2);
		if (Expression!=GLX_DEFINSEXPRESSION)
			Voice->Expression=(Expression*Expression*2);
		if (Panning!=GLX_DEFINSPANNING)
			Voice->Panning=Voice->BasePanning=(Panning<<8);
		if (Modulation!=GLX_DEFINSMODULATION)
			Voice->VibDepth=Modulation;
		if (Reverb!=GLX_DEFINSREVERB)
			Voice->Reverb=Reverb;
		if (Chorus!=GLX_DEFINSCHORUS)
			Voice->Chorus=Chorus;
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxControlSample(glxVoice *Voice,int Frequency,int Volume,int Panning)
{
	if (Voice)
	{
		glxLock();
		while (Voice)
		{
			if (Frequency==GLX_DEFSMPFREQUENCY)	
				Voice->SmpC4Speed=Voice->SmpHdr->C4Speed;
			else
				Voice->SmpC4Speed=Frequency;
			if (Volume==GLX_DEFSMPVOLUME)
				Voice->SmpBaseVol=Voice->SmpVol=Voice->SmpHdr->Volume;
			else
				Voice->SmpBaseVol=Voice->SmpVol=Volume;
			if (Panning==GLX_DEFSMPPANNING)
				Voice->Panning=Voice->BasePanning=(Voice->SmpType&GLX_PANNING?Voice->SmpHdr->Panning:Voice->Panning);
			else
				Voice->Panning=Voice->BasePanning=Panning;
			Voice->SmpPitch=((Voice->SmpC4Speed/glxSamplingrate)<<16);
			Voice->SmpPitch+=(((Voice->SmpC4Speed%glxSamplingrate)<<16)/glxSamplingrate);
			Voice=Voice->Link;
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxObstructSample3D(glxVoice *Voice,int Obstruction,int Occlusion)
{
	LPKSPROPERTYSET EAXSource;
	
	if (Voice)
	{
		glxLock();
		while (Voice)
		{
			if (Voice->Flags&GLX_POSITIONAL)
			{
				if (Voice->Custom2)
				{
					if (IDirectSound3DBuffer_QueryInterface((LPDIRECTSOUND3DBUFFER)Voice->Custom2,&IID_IKsPropertySet,&EAXSource)==DS_OK)
					{
						IKsPropertySet_Set(
							EAXSource,
							&DSPROPSETID_EAX_BufferProperties,
							DSPROPERTY_EAXBUFFER_OBSTRUCTION,
							NULL,0,
							&Obstruction,sizeof(long));
						IKsPropertySet_Set(
							EAXSource,
							&DSPROPSETID_EAX_BufferProperties,
							DSPROPERTY_EAXBUFFER_OCCLUSION,
							NULL,0,
							&Occlusion,sizeof(long));
						if (EAXSource)	
							IKsPropertySet_Release(EAXSource);
					}
				}
			}
			Voice=Voice->Link;
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxControlSample3D(glxVoice *Voice,int Frequency,int Volume,glxVector *Position,glxVector *Velocity)
{
	float Distance1,Distance2,Orientation;
	glxVector Difference1,Difference2;

	if (Voice)
	{
		glxLock();
		while (Voice)
		{
			if (Frequency==GLX_DEFSMPFREQUENCY)	
				Voice->SmpC4Speed=Voice->SmpHdr->C4Speed;
			else
				Voice->SmpC4Speed=Frequency;
			if (Volume==GLX_DEFSMPVOLUME)
				Voice->SmpBaseVol=Voice->SmpVol=Voice->SmpHdr->Volume;
			else
				Voice->SmpBaseVol=Voice->SmpVol=Volume;
			Voice->SmpPitch=((Voice->SmpC4Speed/glxSamplingrate)<<16);
			Voice->SmpPitch+=(((Voice->SmpC4Speed%glxSamplingrate)<<16)/glxSamplingrate);
			if (Voice->Flags&GLX_POSITIONAL)
			{
				if ((glxAudioOutput.Type==GLX_A3D)||(glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
				{
					if (Voice->Custom1)
					{
						IDirectSoundBuffer_SetFrequency((LPDIRECTSOUNDBUFFER)Voice->Custom1,Voice->SmpC4Speed);
						IDirectSoundBuffer_SetVolume((LPDIRECTSOUNDBUFFER)Voice->Custom1,(long)(2000.0*log10(((float)glxSampleVolume*(float)glxSampleVolume*(float)Voice->Volume*(float)Voice->SmpVol)/(16384.0f*32768.0f*32768.0f))));
					}
					if (Voice->Custom2)
					{
						IDirectSound3DBuffer_SetPosition((LPDIRECTSOUND3DBUFFER)Voice->Custom2,Position->X,Position->Y,Position->Z,DS3D_IMMEDIATE);
						IDirectSound3DBuffer_SetVelocity((LPDIRECTSOUND3DBUFFER)Voice->Custom2,Velocity->X,Velocity->Y,Velocity->Z,DS3D_IMMEDIATE);
					}
				}
				else if (glxAudioOutput.Type==GLX_A3D2)
				{
					if (Voice->Custom1)
					{
//						((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Clear((LPA3D4)glxAudioOutput.Extensions);
						((LPA3DSOURCE)Voice->Custom1)->lpVtbl->SetGain((LPA3DSOURCE)Voice->Custom1,(((float)glxSampleVolume*(float)glxSampleVolume*(float)Voice->Volume*(float)Voice->SmpVol)/(16384.0f*32768.0f*32768.0f)));
						((LPA3DSOURCE)Voice->Custom1)->lpVtbl->SetPitch((LPA3DSOURCE)Voice->Custom1,(float)Voice->SmpC4Speed/(float)Voice->SmpHdr->C4Speed);
						((LPA3DSOURCE)Voice->Custom1)->lpVtbl->SetPosition3f((LPA3DSOURCE)Voice->Custom1,Position->X,Position->Y,Position->Z);
						((LPA3DSOURCE)Voice->Custom1)->lpVtbl->SetVelocity3f((LPA3DSOURCE)Voice->Custom1,Velocity->X,Velocity->Y,Velocity->Z);
//						((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Flush((LPA3D4)glxAudioOutput.Extensions);
					}
				}
				else if (glxAudioOutput.Type==GLX_G3D)
				{
					if (glxAudioOutput.Listener)
					{
						//Calc. displacement vector at t	
						Difference1.X=Position->X-((glxVector *)glxAudioOutput.Listener)->X;
						Difference1.Y=Position->Y-((glxVector *)glxAudioOutput.Listener)->Y;
						Difference1.Z=Position->Z-((glxVector *)glxAudioOutput.Listener)->Z;
						//Calc. distance at t
						Distance1=(float)(sqrt(Difference1.X*Difference1.X+Difference1.Y*Difference1.Y+Difference1.Z*Difference1.Z));
						//Calc. displacement vector at t plus 1/343 sec
						Difference2.X=(float)(Position->X+(Velocity->X/343.0)-((glxVector *)glxAudioOutput.Listener)->X);
						Difference2.Y=(float)(Position->Y+(Velocity->Y/343.0)-((glxVector *)glxAudioOutput.Listener)->Y);
						Difference2.Z=(float)(Position->Z+(Velocity->Z/343.0)-((glxVector *)glxAudioOutput.Listener)->Z);
						//Calc. distance at t plus 1/343 sec
						Distance2=(float)(sqrt(Difference2.X*Difference2.X+Difference2.Y*Difference2.Y+Difference2.Z*Difference2.Z));
						//Calc. sound orientation
						if (Distance1)
							Orientation=(float)(atan2(Difference1.Z,Difference1.X));//+atan2(Listener->X,Listener->Z);
						else
							Orientation=1.57f;
						//Calc. panning uses Dolby Surround
						if (Orientation<0)
							Voice->Panning=Voice->BasePanning=(int)(GLX_SURSMPPANNING+GLX_MIDSMPPANNING);
						else
							Voice->Panning=Voice->BasePanning=(int)(GLX_MIDSMPPANNING+GLX_MIDSMPPANNING*0.707f*cos(Orientation));
						//Calc. attenuation uses the inverse square law 
						if (fabs(Distance1)<1.0)
							Voice->Velocity=(int)(GLX_MAXSMPVOLUME);
						else
							Voice->Velocity=(int)(GLX_MAXSMPVOLUME/Distance1);
						//Calc. dopler shift uses speed of sound 343 m/sec
						Frequency=(int)(Voice->SmpC4Speed/(1.0+(Distance2-Distance1)));
						Voice->SmpPitch=((Frequency/glxSamplingrate)<<16);
						Voice->SmpPitch+=(((Frequency%glxSamplingrate)<<16)/glxSamplingrate);
					}
				}
			}
			Voice=Voice->Link;
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxDeinit(void)
{
	if (!glxOutputActive)
	{
		// Free decoding thread 
		if (glxDecodeThreadHnd)
			CloseHandle(glxDecodeThreadHnd);
		// Free COM library
		CoUninitialize();
		// Free critcal section
		DeleteCriticalSection(&glxWorking);
		// Free DSPBuffer, MixCode, Output and Volumetable
		if (glxPanningFunction)
			GlobalFree(glxPanningFunction);
		if (glxAudioBuffer.Data)
			GlobalFree(glxAudioBuffer.Data);
		if (glxMixerCodeBase)
			GlobalFree(glxMixerCodeBase);
		if (glxBufferBase)
			GlobalFree(glxBufferBase);
		if (glxVolumeTableBase)
			GlobalFree(glxVolumeTableBase);
		// Everything went ok
		return GLXERR_NOERROR;
	}
	return GLXERR_OUTPUTACTIVE;
}

int __cdecl glxDetectOutput(int Driver,int Flags)
{
	WAVEFORMATEX OutputDetect;
	WAVEOUTCAPS OutputCaps;
	DSBUFFERDESC DSBDesc;
	DSCAPS DSCaps;

	if (!glxOutputActive)
	{
		glxLock();
		//Clear output structure
		memset(&glxAudioOutput,0,sizeof(glxOutput));
		glxAudioOutput.FourCC=GLX_FOURCC_OUTP;
		glxAudioOutput.Size=sizeof(glxOutput)-8;
		glxAudioOutput.Driver=Driver;
		//Check using 22 Khz, 8 bit, Mono
		OutputDetect.wFormatTag=WAVE_FORMAT_PCM;
		OutputDetect.nChannels=1;
		OutputDetect.nSamplesPerSec=22050;
		OutputDetect.nAvgBytesPerSec=22050;
		OutputDetect.nBlockAlign=1;
		OutputDetect.wBitsPerSample=8;
		OutputDetect.cbSize=0;
		/* Check if Microsoft Directsound driver is present */
		if ((glxAudioOutput.Driver==GLX_AUTODETECT)||(glxAudioOutput.Driver==GLX_DIRECTSOUND))
		{
			// Setup for A3D 2.0
			if (glxInitA3D2()!=GLXERR_NOERROR)
			{
				// Setup for A3D 1.x
				glxInitA3D();
			}
			// Setup for DirectSound3D
			if ((!glxAudioOutput.Handle)&&(CoCreateInstance(&CLSID_DirectSound,NULL,CLSCTX_INPROC_SERVER,&IID_IDirectSound,&glxAudioOutput.Handle)!=S_OK))
				glxAudioOutput.Handle=NULL;
			if ((glxAudioOutput.Handle)&&(IDirectSound_Initialize((LPDIRECTSOUND)glxAudioOutput.Handle,NULL)==DS_OK))
			{
				if (IDirectSound_SetCooperativeLevel((LPDIRECTSOUND)glxAudioOutput.Handle,GetActiveWindow(),DSSCL_PRIORITY)==DS_OK)
				{
					memset(&DSCaps,0,sizeof(DSCAPS));
					DSCaps.dwSize=sizeof(DSCAPS);
					IDirectSound_GetCaps((LPDIRECTSOUND)glxAudioOutput.Handle,&DSCaps);
					if ((DSCaps.dwFlags&DSCAPS_EMULDRIVER)==0)
					{
						memset(&DSBDesc,0,sizeof(DSBUFFERDESC));
						DSBDesc.dwSize=sizeof(DSBUFFERDESC);
						DSBDesc.dwFlags=DSBCAPS_PRIMARYBUFFER|DSBCAPS_CTRL3D;
						if (IDirectSound_CreateSoundBuffer((LPDIRECTSOUND)glxAudioOutput.Handle,&DSBDesc,&(LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,NULL)==DS_OK)
						{
							if (glxAudioOutput.Extensions)
							{
								// A3D 2.0
								((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->SetCooperativeLevel((LPA3D4)glxAudioOutput.Extensions,GetActiveWindow(),A3D_CL_NORMAL);
								((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->SetCoordinateSystem((LPA3D4)glxAudioOutput.Extensions,A3D_LEFT_HANDED_CS);
								if (((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->QueryInterface((LPA3D4)glxAudioOutput.Extensions,&IID_IA3dListener,&glxAudioOutput.Listener)!=S_OK)
									glxAudioOutput.Listener=NULL;
								((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->SetPosition3f((LPA3DLISTENER)glxAudioOutput.Listener,0.0f,0.0f,0.0f);
								((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->SetOrientation6f((LPA3DLISTENER)glxAudioOutput.Listener,0.0f,0.0f,1.0f,0.0f,1.0f,0.0f);
								glxAudioOutput.Type=GLX_A3D2;
							}
							else if (glxAudioOutput.Extensions=EAXCreate((LPDIRECTSOUND)glxAudioOutput.Handle))
							{
								// EAX 1.0
								if (IDirectSoundBuffer_QueryInterface((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,&IID_IDirectSound3DListener,&glxAudioOutput.Listener)!=DS_OK)
									glxAudioOutput.Listener=NULL;
								glxAudioOutput.Type=GLX_EAX;
							}
							else if (IDirectSound_QueryInterface((LPDIRECTSOUND)glxAudioOutput.Handle,&IID_IA3d,&glxAudioOutput.Extensions)==DS_OK)
							{
								// A3D 1.0
								if (IDirectSoundBuffer_QueryInterface((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,&IID_IDirectSound3DListener,&glxAudioOutput.Listener)!=DS_OK)
									glxAudioOutput.Listener=NULL;
								glxAudioOutput.Type=GLX_A3D;
							}
							else
							{
								glxAudioOutput.Extensions=NULL;
								if (glxAudioOutput.Listener=malloc(sizeof(glxVector)))
									memset(glxAudioOutput.Listener,0,sizeof(glxVector));
								glxAudioOutput.Type=GLX_G3D;
							}
							memset(&DSBDesc,0,sizeof(DSBUFFERDESC));
							DSBDesc.dwSize=sizeof(DSBUFFERDESC);
							DSBDesc.dwFlags=DSBCAPS_GLOBALFOCUS|DSBCAPS_GETCURRENTPOSITION2;
							DSBDesc.dwBufferBytes=OutputDetect.nAvgBytesPerSec;
							DSBDesc.lpwfxFormat=&OutputDetect;
							if (IDirectSound_CreateSoundBuffer((LPDIRECTSOUND)glxAudioOutput.Handle,&DSBDesc,&(LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,NULL)==DS_OK)
							{
								if (IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,0,DSBPLAY_LOOPING)==DS_OK)
								{
									glxAudioOutput.Driver=GLX_DIRECTSOUND;
									glxAudioOutput.Format=GLX_16BIT|GLX_STEREO;
									IDirectSoundBuffer_Stop((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
								}
								IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
								glxAudioBuffer.Handle=NULL;
							}
							if (glxAudioOutput.Type==GLX_A3D2)
							{
								if (glxAudioOutput.Listener)
								{
									((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->Release((LPA3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Release((LPA3D4)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_A3D)
							{
								if (glxAudioOutput.Listener)
								{
									IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								IA3d_Release((LPIA3D)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_EAX)
							{
								if (glxAudioOutput.Listener)
								{
									IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								EAXRelease((LPKSPROPERTYSET)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_G3D)
							{
								if (glxAudioOutput.Listener)
								{
									free(glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
							}
							IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer);
							glxAudioOutput.Mixer=NULL;
						}
					}
				}
			}
			if (glxAudioOutput.Handle)
				IDirectSound_Release((LPDIRECTSOUND)glxAudioOutput.Handle);
			glxAudioOutput.Handle=NULL;
		}

		/* Check if Windows wave driver is present */
		if ((glxAudioOutput.Driver==GLX_AUTODETECT)||(glxAudioOutput.Driver==GLX_WAVEDRIVER))
		{
			if (waveOutGetDevCaps(WAVE_MAPPER,&OutputCaps,sizeof(OutputCaps))==MMSYSERR_NOERROR)
			{
				glxAudioOutput.Driver=GLX_WAVEDRIVER;
				if (OutputCaps.wChannels==2)
					glxAudioOutput.Format|=GLX_STEREO;
				if ((OutputCaps.dwFormats&WAVE_FORMAT_1M16)||(OutputCaps.dwFormats&WAVE_FORMAT_1S16)||
					(OutputCaps.dwFormats&WAVE_FORMAT_2M16)||(OutputCaps.dwFormats&WAVE_FORMAT_2S16)||
					(OutputCaps.dwFormats&WAVE_FORMAT_4M16)||(OutputCaps.dwFormats&WAVE_FORMAT_4S16))
				glxAudioOutput.Format|=GLX_16BIT;
				glxAudioOutput.Type=GLX_G3D;
			}
		}
		
		/* Check if autodetection requested */
		if ((glxAudioOutput.Driver==GLX_AUTODETECT)||(glxAudioOutput.Driver==GLX_NOSOUND))
		{
			glxAudioOutput.Driver=GLX_NOSOUND;
			glxAudioOutput.Format=GLX_16BIT|GLX_STEREO;
			glxAudioOutput.Type=GLX_G3D;
		}

		/* Return error code */
		glxUnlock();
		return (((glxAudioOutput.Driver==Driver)||(Driver==GLX_AUTODETECT))?GLXERR_NOERROR:GLXERR_UNSUPPORTEDDEVICE);
	}
	return GLXERR_OUTPUTACTIVE;
}

int __cdecl glxFlushOutput(void)
{
	glxLock();
	glxAudioBuffer.Premix=0;
	glxUnlock();
	return GLXERR_NOERROR;
}

int __cdecl glxInfo(char **Version,char **Driver)
{
	if ((Version!=NULL)||(Driver!=NULL))
	{
		sprintf(glxVersionID,"Galaxy Music System revision 5.00 compiled on %s at %s",__DATE__,__TIME__);
		*Version=glxVersionID;
		*Driver=glxDriverID;
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxInit(void)
{
	static char glxVersion[80];
	int Voice,i;

	if (1)
	{
		//Get processor information (MMX/3DNow!/KNI)
		__asm
		{
			push	eax 							// Save EAX
			push	ebx 							// Save EBX
			push	ecx 							// Save ECX
			push	edx 							// Save EDX
			mov 	glxMMXFound,0					// No MMX support
			mov 	glxK3DFound,0					// No 3DNow! support
			mov 	glxKNIFound,0					// No KNI support
			pushfd									// Save eflags
			pop 	ebx 							// Store eflags in EBX
			mov 	eax,ebx 						// EAX=EBX
			xor 	eax,200000h 					// Flip CPUID bit
			push	eax 							// Store new eflags
			popfd									// Restore new eflags
			pushfd									// Save new eflags
			pop 	eax 							// Store new eflags in EAX
			cmp 	eax,ebx 						// CPUID bit flipped ?
			je		Done							// Nope ? We're done !
			mov 	eax,00000000h					// EAX=00000000h (Largest std. func.)
			_emit	00fh							// 00fh,0a2h = CPUID
			_emit	0a2h							// What are you ?
			cmp 	eax,00000001h					// Function 0001h supported ?
			jb		Done							// Nope ? We're done !
			mov 	eax,00000001h					// EAX=000000001h (Standard features)
			_emit	00fh							// 00fh,0a2h = CPUID
			_emit	0a2h							// Get standard features
			test	edx,00800000h					// MMX present ?
			setnz	glxMMXFound 					// If so, set MMX Flag
			test	edx,02000000h					// KNI present ?
			setnz	glxKNIFound 					// If so, set KNI Flag
			mov 	eax,80000000h					// EAX=80000000h (Largest ext. func.)
			_emit	00fh							// 00fh,0a2h = CPUID
			_emit	0a2h							// Get largest ext. function
			cmp 	eax,80000001h					// Function 80000001h supported ?
			jb		Done							// Nope ? We're done !
			mov 	eax,80000001h					// EAX=00001h (Extended features)
			_emit	00fh							// 00fh,0a2h = CPUID
			_emit	0a2h							// Get extended features
			test	edx,80000000h					// 3DNow! present ?
			setnz	glxK3DFound 					// If so, set 3DNow! Flag
			Done:
			pop 	edx 							// Restore EDX
			pop 	ecx 							// Restore ECX
			pop 	ebx 							// Restore EBX
			pop 	eax 							// Restore EAX
		}
		//Check if OS supports processor extensions
		if (glxKNIFound)
		{
			__try
			{
				__asm
				{
					_emit	00fh
					_emit	028h
					_emit	0c8h					// movaps xmm1,xmm0
				}
			} 
			__except(EXCEPTION_EXECUTE_HANDLER)
			{
				glxKNIFound=0;
			}
		}
		//Clear internal structures
		for (Voice=0;Voice<GLX_TOTALVOICES;Voice++)
		{
			memset(&glxVoices[Voice],0,sizeof(glxVoice));
			glxVoices[Voice].FourCC=GLX_FOURCC_VOIC;
			glxVoices[Voice].Size=(sizeof(glxVoice)-8);
			glxVoices[Voice].InstNo=0;
			glxVoices[Voice].Chorus=0;
			glxVoices[Voice].Reverb=127;
			glxVoices[Voice].NoteNo=128|60;
			glxVoices[Voice].Vol=glxVoices[Voice].VolDest=127;
			glxVoices[Voice].Flags=GLX_MASTER;
			glxVoices[Voice].Volume=(127*127*2);
			glxVoices[Voice].Expression=GLX_MAXSMPEXPRESSION;
			glxVoices[Voice].Panning=glxVoices[Voice].BasePanning=GLX_MIDSMPPANNING;
		}
		memset(glxInstruments,0,sizeof(glxInstruments));
		memset(glxOrders,0,sizeof(glxOrders));
		memset(glxPatterns,0,sizeof(glxPatterns));
		//Setup internal variables
		glxCurrentPtr=NULL;
		glxCurrentTime=0;
		glxPatternRow=0xff;
		glxPatternBreak=0;
		glxCurrentSpeed=48;
		glxCurrentTempo=120;
		glxCurrentOrder=0xff;
		glxPatternDelay=0;
		glxPatternLength=0;
		glxPatternBreakCnt=1;
		glxSongLength=0;
		glxMusicVolume=127;
		glxSampleVolume=127;
		glxCDVolume=127;
		glxMusicVoices=0;
		glxSampleVoices=8;
		memset(glxInitialPanning,GLX_MIDINSPANNING,sizeof(glxInitialPanning));
		glxInitialSpeed=48;
		glxInitialTempo=120;
		glxOutputActive=GLX_OFF;
		glxMusicEnabled=GLX_OFF;
		glxMusicLooping=GLX_ON;
		glxPlayerMode=0;
		glxSamplingrate=22050;
		glxMinPeriod=0;
		glxMaxPeriod=30720;
		glxCurrentTick=0;
		glxCurrentSample=0;
		glxCallbackFunction=glxDefaultCallback;
		glxEaxManager=NULL;
		glxTimer1Period=glxTimer1Count=((22050<<16)/1000);
		glxTimer2Period=glxTimer2Count=((22050<<16)/96);
		memset(&glxMusicReverb,0,sizeof(glxMusicReverb));
		memset(&glxSampleReverb,0,sizeof(glxSampleReverb));
		memset(&glxMusicChorus,0,sizeof(glxMusicChorus));
		memset(&glxSampleChorus,0,sizeof(glxSampleChorus));
		// Allocate memory for Volumetable
		glxVolumeTableBase=GlobalAlloc(GPTR,160*1024);
		// Allocate memory for Dry,Effect1 and Effect2 (misalign for cache)
		glxBufferBase=GlobalAlloc(GPTR,6*(4096+64)+64);
		glxBufferBase1=(char *)((((long)glxBufferBase)+63)&~63);
		glxBufferBase2=glxBufferBase1+4096+64;
		glxBufferBase3=glxBufferBase2+4096+64;
		glxBufferBase4=glxBufferBase3+4096+64;
		glxBufferBase5=glxBufferBase4+4096+64;
		glxBufferBase6=glxBufferBase5+4096+64;
		glxMixerCodeBase=GlobalAlloc(GPTR,8*1024);
		// Allocate memory for one second of audio data
		memset(&glxAudioBuffer,0,sizeof(glxAudioBuffer));
		glxAudioBuffer.Data=GlobalAlloc(GPTR,48000*2*2);
		glxAudioBuffer.Length=48000*2*2;
		// Build panning table
		glxPanningFunction=GlobalAlloc(GPTR,32768*2);
		for (i=0;i<32768;i++) glxPanningFunction[i]=(short)(32767.0*sqrt((double)i/32767.0));
		// Initialise audio output
		memset(&glxAudioOutput,0,sizeof(glxAudioOutput));
		glxAudioOutput.Driver=GLX_AUTODETECT;
		glxAudioOutput.Format=GLX_COSINE|GLX_16BIT|GLX_STEREO;
		// Initialise critcal section
		InitializeCriticalSection(&glxWorking);
		// Initialise COM
		CoInitialize(NULL);
		// Initialise decode thread 
		glxDecodeThreadHnd=CreateThread((LPSECURITY_ATTRIBUTES)NULL,0,glxDecodeThread,0,0,&glxDecodeThreadID);
		SetThreadPriority(glxDecodeThreadHnd,THREAD_PRIORITY_HIGHEST);
		// Build library ID
		sprintf(glxVersion,"Galaxy Music System compiled at %s",__TIMESTAMP__);
		glxVersionID=glxVersion;
		// Everything went ok
		return GLXERR_NOERROR;
	}
	return GLXERR_OUTPUTACTIVE;
}

int __cdecl glxLock(void)
{
	EnterCriticalSection(&glxWorking);
	return GLXERR_NOERROR;
}

int __cdecl glxResetMusic(void)
{
	int Voice;

	if (!glxMusicEnabled)
	{
		glxLock();
		for (Voice=glxSampleVoices;Voice<GLX_TOTALVOICES;Voice++)
		{
			memset(&glxVoices[Voice],0,sizeof(glxVoice));
			glxVoices[Voice].InstNo=0;
			glxVoices[Voice].Chorus=0;
			glxVoices[Voice].Reverb=40;
			glxVoices[Voice].Vol=glxVoices[Voice].VolDest=100;
			glxVoices[Voice].Volume=(100*100*2);
			glxVoices[Voice].Expression=GLX_MAXSMPEXPRESSION;
			glxVoices[Voice].Panning=glxVoices[Voice].BasePanning=GLX_MIDSMPPANNING;
			glxVoices[Voice].NoteNo=128|60;
		}
		glxCurrentPtr=NULL;
		glxCurrentTime=0;
		glxPatternRow=0xff;
		glxPatternBreak=0;
		glxCurrentTempo=120;
		glxCurrentSpeed=48;
		glxCurrentOrder=0xff;
		glxPatternBreakCnt=1;
		glxSongLength=0;
		glxMusicVolume=127;
		glxInitialSpeed=48;
		glxInitialTempo=120;
		glxMusicLooping=GLX_ON;
		glxPlayerMode=0;
		glxMinPeriod=0;
		glxMaxPeriod=30720;
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_MUSICPLAYING;
}

int __cdecl glxSetCallback(glxCallback *Function)
{
	if (Function!=NULL)
	{
		glxCallbackFunction=Function;
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxSetCDAudioVolume(int Volume,int Speed)
{
	MIXERCONTROLDETAILS_UNSIGNED MixerControlUnsigned;
	MIXERCONTROLDETAILS MixerControlDetails;
	AUXCAPS AuxilaryCaps;
	MIXERCAPS MixerCaps;
	MIXERLINE MixerLineCaps;
	UINT Device;
	
	if ((Volume>=0)&&(Volume<=127))
	{
		glxLock();
		glxCDVolume=Volume;
		//First try any auxilary devices
		for (Device=0;Device<auxGetNumDevs();Device++)
		{
			if (auxGetDevCaps(Device,&AuxilaryCaps,sizeof(AuxilaryCaps))==MMSYSERR_NOERROR)
			{
				if ((AuxilaryCaps.wTechnology&AUXCAPS_CDAUDIO)&&(AuxilaryCaps.dwSupport&AUXCAPS_VOLUME))
					auxSetVolume(Device,((Volume<<24)|(Volume<<8)));
			}
		}
		//Second go through mixer API
		for (Device=0;Device<mixerGetNumDevs();Device++)
		{
			if (mixerGetDevCaps(Device,&MixerCaps,sizeof(MixerCaps))==MMSYSERR_NOERROR)
			{
				memset(&MixerLineCaps,0,sizeof(MixerLineCaps));
				MixerLineCaps.cbStruct=sizeof(MIXERLINE);
				MixerLineCaps.dwComponentType=MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC;
				if (mixerGetLineInfo((HMIXEROBJ)Device,&MixerLineCaps,MIXER_GETLINEINFOF_COMPONENTTYPE|MIXER_OBJECTF_MIXER)==MMSYSERR_NOERROR)
				{
					memset(&MixerControlDetails,0,sizeof(MixerControlDetails));
					MixerControlDetails.cbStruct=sizeof(MIXERCONTROLDETAILS);
					MixerControlDetails.dwControlID=MixerLineCaps.dwLineID;
					MixerControlDetails.cChannels=1;
					MixerControlDetails.cbDetails=sizeof(MIXERCONTROLDETAILS_UNSIGNED);
					MixerControlDetails.paDetails=&MixerControlUnsigned;
					mixerGetControlDetails((HMIXEROBJ)Device,&MixerControlDetails,MIXER_OBJECTF_MIXER);
					MixerControlUnsigned.dwValue=(Volume<<9);
					mixerSetControlDetails((HMIXEROBJ)Device,&MixerControlDetails,MIXER_OBJECTF_MIXER);
				}
			}
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxSetMusicVoices(int VoiceCount)
{
	int Voice;

	if ((!glxOutputActive)&&((VoiceCount+glxSampleVoices)<=GLX_TOTALVOICES))
	{
		glxMusicVoices=VoiceCount;
		for (Voice=glxSampleVoices;Voice<(VoiceCount+glxSampleVoices);Voice++)
			glxVoices[Voice].Enabled=GLX_ON;
		return 1;
	}
	return GLX_NULL;
}

int __cdecl glxSetMusicVolume(int Volume,int Speed)
{
	if ((Volume>=0)&&(Volume<=127))
	{
		glxLock();
		if (Speed==GLX_VOLSET)
		{
			glxMusicVolume=Volume;
			glxMusicVolSlide=0;
			glxMusicVolDest=Volume;
		}
		else
		{
			if (glxMusicVolume<Volume)
				glxMusicVolSlide=Speed;
			else
				glxMusicVolSlide=-Speed;
			glxMusicVolDest=Volume;
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxSetSampleVoices(int VoiceCount)
{
	int Voice;

	if ((!glxOutputActive)&&((VoiceCount+glxMusicVoices)<=GLX_TOTALVOICES))
	{
		glxSampleVoices=VoiceCount;
		for (Voice=0;Voice<VoiceCount;Voice++)
			glxVoices[Voice].Enabled=GLX_ON;
		return 1;
	}
	return GLX_NULL;
}

int __cdecl glxSetSampleVolume(int Volume,int Speed)
{
	if ((Volume>=0)&&(Volume<=127))
	{
		glxLock();
		if (Speed==GLX_VOLSET)
		{
			glxSampleVolume=Volume;
			glxSampleVolSlide=0;
			glxSampleVolDest=Volume;
		}
		else
		{
			if (glxSampleVolume<Volume)
				glxSampleVolSlide=Speed;
			else
				glxSampleVolSlide=-Speed;
			glxSampleVolDest=Volume;
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxSetMusicChorus(glxChorus *Chorus)
{
	glxLock();
	if ((Chorus)&&(Chorus->Volume!=0.0))
	{
		Chorus->Data=glxMusicChorus.Data;
		memcpy(&glxMusicChorus,Chorus,sizeof(glxChorus)-4);
		if ((glxMMXFound)&&(glxKNIFound))
		{
			glxMusicChorus.Code=kniChorus;
			if (!glxMusicChorus.Data)
				glxMusicChorus.Data=malloc(sizeof(glxKNIChorus));
			else
				glxMusicChorus.Data=realloc(glxMusicChorus.Data,sizeof(glxKNIChorus));
			glxSetKNIChorus(glxMusicChorus.Data,Chorus);
		}
		else if ((glxMMXFound)&&(glxK3DFound))
		{
			glxMusicChorus.Code=k3dChorus;
			if (!glxMusicChorus.Data)
				glxMusicChorus.Data=malloc(sizeof(glxK3DChorus));
			else
				glxMusicChorus.Data=realloc(glxMusicChorus.Data,sizeof(glxK3DChorus));
			glxSetK3DChorus(glxMusicChorus.Data,Chorus);
		}
		else if (glxMMXFound)
		{
			glxMusicChorus.Code=mmxChorus;
			if (!glxMusicChorus.Data)
				glxMusicChorus.Data=malloc(sizeof(glxMMXChorus));
			else
				glxMusicChorus.Data=realloc(glxMusicChorus.Data,sizeof(glxMMXChorus));
			glxSetMMXChorus(glxMusicChorus.Data,Chorus);
		}
	}
	else
	{
		glxMusicChorus.Code=NULL;
		if (glxMusicChorus.Data)
		{
			free(glxMusicChorus.Data);
			glxMusicChorus.Data=NULL;
		}
	}
	glxUnlock();
	return GLXERR_NOERROR;
}

int __cdecl glxSetMusicReverb(glxReverb *Reverb)
{
	glxLock();
	if ((Reverb)&&(Reverb->Volume!=0.0))
	{
		Reverb->Data=glxMusicReverb.Data;
		memcpy(&glxMusicReverb,Reverb,sizeof(glxReverb));
		if ((glxMMXFound)&&(glxKNIFound))
		{
			glxMusicReverb.Code=kniReverb;
			if (!glxMusicReverb.Data)
				glxMusicReverb.Data=malloc(sizeof(glxKNIReverb));
			else
				glxMusicReverb.Data=realloc(glxMusicReverb.Data,sizeof(glxKNIReverb));
			glxSetKNIReverb(glxMusicReverb.Data,Reverb);
		}
		else if ((glxMMXFound)&&(glxK3DFound))
		{
			glxMusicReverb.Code=k3dReverb;
			if (!glxMusicReverb.Data)
				glxMusicReverb.Data=malloc(sizeof(glxK3DReverb));
			else
				glxMusicReverb.Data=realloc(glxMusicReverb.Data,sizeof(glxK3DReverb));
			glxSetK3DReverb(glxMusicReverb.Data,Reverb);
		}
		else if (glxMMXFound)
		{
			glxMusicReverb.Code=mmxReverb;
			if (!glxMusicReverb.Data)
				glxMusicReverb.Data=malloc(sizeof(glxMMXReverb));
			else
				glxMusicReverb.Data=realloc(glxMusicReverb.Data,sizeof(glxMMXReverb));
			glxSetMMXReverb(glxMusicReverb.Data,Reverb);
		}
		else glxMusicReverb.Code=NULL;
	}
	else
	{
		glxMusicReverb.Code=NULL;
		if (glxMusicReverb.Data)
		{
			free(glxMusicReverb.Data);
			glxMusicReverb.Data=NULL;
		}
		if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
			EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,0.0,0.0,0.0,0.0,0.0);
	}
	glxUnlock();
	return GLXERR_NOERROR;
}

int __cdecl glxSetSampleChorus(glxChorus *Chorus)
{
	glxLock();
	if ((Chorus)&&(Chorus->Volume!=0.0))
	{
		Chorus->Data=glxSampleChorus.Data;
		memcpy(&glxSampleChorus,Chorus,sizeof(glxChorus)-4);
		if ((glxMMXFound)&&(glxKNIFound))
		{
			glxSampleChorus.Code=kniChorus;
			if (!glxSampleChorus.Data)
				glxSampleChorus.Data=malloc(sizeof(glxKNIChorus));
			else
				glxSampleChorus.Data=realloc(glxSampleChorus.Data,sizeof(glxKNIChorus));
			glxSetKNIChorus(glxSampleChorus.Data,Chorus);
		}
		else if ((glxMMXFound)&&(glxK3DFound))
		{
			glxSampleChorus.Code=k3dChorus;
			if (!glxSampleChorus.Data)
				glxSampleChorus.Data=malloc(sizeof(glxK3DChorus));
			else
				glxSampleChorus.Data=realloc(glxSampleChorus.Data,sizeof(glxK3DChorus));
			glxSetK3DChorus(glxSampleChorus.Data,Chorus);
		}
		if (glxMMXFound)
		{
			glxSampleChorus.Code=mmxChorus;
			if (!glxSampleChorus.Data)
				glxSampleChorus.Data=malloc(sizeof(glxMMXChorus));
			else
				glxSampleChorus.Data=realloc(glxSampleChorus.Data,sizeof(glxMMXChorus));
			glxSetMMXChorus(glxSampleChorus.Data,Chorus);
			}
		else glxSampleChorus.Code=NULL;
	}	
	else
	{
		glxSampleChorus.Code=NULL;
		if (glxSampleChorus.Data)
		{
			free(glxSampleChorus.Data);
			glxSampleChorus.Data=NULL;
		}
	}
	glxUnlock();
	return GLXERR_NOERROR;
}

int __cdecl glxSetSampleReverb(glxReverb *Reverb)
{
	glxLock();
	if ((Reverb)&&(Reverb->Volume!=0.0))
	{
		Reverb->Data=glxSampleReverb.Data;
		memcpy(&glxSampleReverb,Reverb,sizeof(glxReverb));
		if ((glxMMXFound)&&(glxKNIFound))
		{
			glxSampleReverb.Code=kniReverb;
			if (!glxSampleReverb.Data)
				glxSampleReverb.Data=malloc(sizeof(glxKNIReverb));
			else
				glxSampleReverb.Data=realloc(glxSampleReverb.Data,sizeof(glxKNIReverb));
			glxSetKNIReverb(glxSampleReverb.Data,&glxSampleReverb);
		}
		else if ((glxMMXFound)&&(glxK3DFound))
		{
			glxSampleReverb.Code=k3dReverb;
			if (!glxSampleReverb.Data)
				glxSampleReverb.Data=malloc(sizeof(glxK3DReverb));
			else
				glxSampleReverb.Data=realloc(glxSampleReverb.Data,sizeof(glxK3DReverb));
			glxSetK3DReverb(glxSampleReverb.Data,&glxSampleReverb);
		}
		else if (glxMMXFound)
		{
			glxSampleReverb.Code=mmxReverb;
			if (!glxSampleReverb.Data)
				glxSampleReverb.Data=malloc(sizeof(glxMMXReverb));
			else
				glxSampleReverb.Data=realloc(glxSampleReverb.Data,sizeof(glxMMXReverb));
			glxSetMMXReverb(glxSampleReverb.Data,&glxSampleReverb);
		}
		else glxSampleReverb.Code=NULL;
	}
	else
	{
		glxSampleReverb.Code=NULL;
		if (glxSampleReverb.Data)
		{
			free(glxSampleReverb.Data);
			glxSampleReverb.Data=NULL;
		}
		if ((glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
			EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,0.0,0.0,0.0,0.0,0.0);
	}
	glxUnlock();
	return GLXERR_NOERROR;
}

//for unreal compatibility

int __cdecl glxSetSampleReverb2(glxReverb *Reverb)
{
	glxLock();
	if ((Reverb)&&(Reverb->Volume!=0.0))
	{
		memcpy(&glxSampleReverb,Reverb,sizeof(glxReverb));
		if ((glxMMXFound)&&(!glxK3DFound))
		{
			glxSampleReverb.Code=mmxEffect;
			if (!glxSampleReverb.Data)
				glxSampleReverb.Data=malloc(sizeof(glxMMXEffect));
			glxSetMMXEffect(glxSampleReverb.Data,Reverb);
		}
		else glxSampleReverb.Code=NULL;
	}
	else
	{
		glxSampleReverb.Code=NULL;
		if (glxSampleReverb.Data)
		{
			free(glxSampleReverb.Data);
			glxSampleReverb.Data=NULL;
		}
		if (glxAudioOutput.Type==GLX_EAX)
			EAXSet((LPKSPROPERTYSET)glxAudioOutput.Extensions,0.0,0.0,0.0,0.0,0.0);
	}
	glxUnlock();
	return GLXERR_NOERROR;
}

int __cdecl glxStartCDAudio(int StartTrack,int EndTrack)
{
	MCI_OPEN_PARMS mciOpenParms;
	MCI_SET_PARMS mciSetParms;
	MCI_PLAY_PARMS mciPlayParms;
	MCI_STATUS_PARMS mciStatusParms;
	DWORD dwReturn;
	int TrackNo;

	if (CDRomID==0)
	{
		memset(&mciOpenParms,0,sizeof(MCI_OPEN_PARMS));
		mciOpenParms.lpstrDeviceType=(char *)MCI_DEVTYPE_CD_AUDIO;
		if (dwReturn=mciSendCommand((UINT)NULL,MCI_OPEN,MCI_OPEN_TYPE|MCI_OPEN_TYPE_ID|MCI_OPEN_SHAREABLE,(DWORD)(LPVOID)&mciOpenParms))
			return dwReturn;
		CDRomID=mciOpenParms.wDeviceID;
	}
	memset(&mciSetParms,0,sizeof(MCI_SET_PARMS));
	mciSetParms.dwTimeFormat=MCI_FORMAT_MILLISECONDS;
	if (dwReturn=mciSendCommand(CDRomID,MCI_SET,MCI_SET_TIME_FORMAT,(DWORD)(LPVOID)&mciSetParms))
	{
		if (mciSendCommand(CDRomID,MCI_CLOSE,0,(DWORD)NULL)==0)
			CDRomID=0;
		return dwReturn;
	}	
	memset(&mciStatusParms,0,sizeof(MCI_STATUS_PARMS));
	mciStatusParms.dwItem=MCI_STATUS_POSITION;
	mciStatusParms.dwTrack=StartTrack;
	if (dwReturn=mciSendCommand(CDRomID,MCI_STATUS,MCI_STATUS_ITEM|MCI_TRACK,(DWORD)(LPVOID)&mciStatusParms))
	{
		if (mciSendCommand(CDRomID,MCI_CLOSE,0,(DWORD)NULL)==0)
			CDRomID=0;
		return dwReturn;
	}
	memset(&mciPlayParms,0,sizeof(MCI_PLAY_PARMS));
	mciPlayParms.dwCallback=(DWORD)NULL;
	mciPlayParms.dwFrom=mciStatusParms.dwReturn;
	mciPlayParms.dwTo=mciStatusParms.dwReturn;
	for (TrackNo=StartTrack;TrackNo<=EndTrack;TrackNo++)
	{
		mciStatusParms.dwItem=MCI_STATUS_LENGTH;
		mciStatusParms.dwTrack=TrackNo;
		if (dwReturn=mciSendCommand(CDRomID,MCI_STATUS,MCI_STATUS_ITEM|MCI_TRACK,(DWORD)(LPVOID)&mciStatusParms))
		{
			if (mciSendCommand(CDRomID,MCI_CLOSE,0,(DWORD)NULL)==0)
				CDRomID=0;
			return dwReturn;
		}
		mciPlayParms.dwTo+=mciStatusParms.dwReturn;
	}
	if (dwReturn=mciSendCommand(CDRomID,MCI_PLAY,MCI_FROM|MCI_TO,(DWORD)(LPVOID)&mciPlayParms))
	{
		if (mciSendCommand(CDRomID,MCI_CLOSE,0,(DWORD)NULL)==0)
			CDRomID=0;
		return dwReturn;
	}
	return GLXERR_NOERROR;
}

glxVoice * __cdecl glxStartInstrument(int Voice,int Program,int Key,int Pitchwheel,int Volume,int Velocity,int Expression,int Panning,int Modulation,int Reverb,int Chorus,int Flags)
{
	glxVoice *ThisVoice,*LinkedVoice=NULL;
	glxInstrument *Instrument;
	udword StartAddress;
	glxSample *Sample;
	int Layer,Layers;

	if (glxSampleVoices==0)
		return GLX_NULL;
	if ((Instrument=glxInstruments[(Program&128)>>7][Program&127])==NULL)
		return GLX_NULL;
	if (Instrument->FourCC!=GLX_FOURCC_INST)
		return GLX_NULL;
	if ((Sample=&Instrument->Sample[Instrument->Split[Key]])==NULL)
		return GLX_NULL;
	if (Sample->FourCC!=GLX_FOURCC_SAMP)
		return GLX_NULL;
	if (Sample->Type&GLX_STEREOSAMPLE)
		Layers=2;
	else
		Layers=1;
	glxLock();
	for (Layer=0;Layer<Layers;Layer++)
	{
		ThisVoice=((Voice==GLX_AUTO)?glxAllocateInstrumentVoice():&glxVoices[Voice+Layer-1]);
		if (ThisVoice)
		{
			ThisVoice->Active=GLX_OFF;
			if (Sample->Data)
			{
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
					ThisVoice->StartTime=((Layer<(Layers-1))?0xfffffffe:0xffffffff);
				else
					ThisVoice->StartTime=((Flags&GLX_LOCKED)?0xfffffffe:glxCurrentTick);
				ThisVoice->NoteNo=Key;
				ThisVoice->InstNo=Program;
				ThisVoice->SmpNo=Instrument->Split[Key];
				ThisVoice->Active=GLX_ON;
				ThisVoice->Flags=Flags;
				if (Velocity==GLX_DEFINSVELOCITY)
					ThisVoice->Velocity=GLX_MAXSMPVELOCITY;
				else
					ThisVoice->Velocity=(Velocity*Velocity*2);
				if (Sample->Articulation)
					ThisVoice->InsArt=Sample->Articulation;
				else
					ThisVoice->InsArt=&Instrument->Articulation;
				ThisVoice->InsVol=0;
				ThisVoice->InsVolStep=0;
				ThisVoice->InsVolTime=0;
				ThisVoice->InsVolFade=32767;
				ThisVoice->InsVolPoint=0;
				ThisVoice->InsPit=0;
				ThisVoice->InsPitStep=0;
				ThisVoice->InsPitTime=0;
				ThisVoice->InsPitFade=32767;
				ThisVoice->InsPitPoint=0;
				ThisVoice->InsPan=0;
				ThisVoice->InsPanStep=0;
				ThisVoice->InsPanTime=0;
				ThisVoice->InsPanFade=32767;
				ThisVoice->InsPanPoint=0;
				ThisVoice->SmpHdr=Sample;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					StartAddress=(udword)getmem(Sample->Reserved+31);
					memset((void *)StartAddress,0,Sample->Reserved);
				}
				else
					StartAddress=(udword)Sample->Data;
				ThisVoice->SmpPtr=StartAddress=((Sample->Type&GLX_16BITSAMPLE)?StartAddress>>1:StartAddress);
				ThisVoice->SmpFrac=0;
				ThisVoice->SmpType=Sample->Type;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					ThisVoice->SmpType|=GLX_ALWAYSLOOP|GLX_LOOPED;
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->SmpEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->Custom1=Sample->Reserved;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=Sample->Reserved;
					ThisVoice->Custom4=Sample->Reserved;
				}
				else
				{
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress+Sample->LoopStart;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
					ThisVoice->SmpEnd=StartAddress+Sample->Length;
					ThisVoice->Custom1=0;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=0;
					ThisVoice->Custom4=0;
				}
				ThisVoice->SmpC4Speed=Sample->C4Speed;
				ThisVoice->SmpVol=Sample->Volume;
				ThisVoice->SmpBaseVol=Sample->Volume;
				if (Volume==GLX_DEFINSVOLUME)
					ThisVoice->Vol=100;
				else
					ThisVoice->Vol=Volume;
				if (Expression==GLX_DEFINSEXPRESSION)
					ThisVoice->Expression=GLX_MAXSMPEXPRESSION;
				else
					ThisVoice->Expression=(Expression*Expression*2);
				if (Panning==GLX_DEFINSPANNING)
				{
					if (Layers>1)
						ThisVoice->Panning=ThisVoice->BasePanning=((Layer&1)?GLX_MINSMPPANNING:GLX_MAXSMPPANNING);
					else if (Sample->Type&GLX_PANNING)
						ThisVoice->Panning=ThisVoice->BasePanning=Sample->Panning;
				}
				else
					ThisVoice->Panning=ThisVoice->BasePanning=(Panning<<8);
				if (Chorus==GLX_DEFINSCHORUS)
					ThisVoice->Chorus=0;
				else
					ThisVoice->Chorus=Chorus;
				if (Reverb==GLX_DEFINSREVERB)
					ThisVoice->Reverb=40;
				else
					ThisVoice->Reverb=Reverb;
				if (Pitchwheel==GLX_DEFINSPITCH)
					ThisVoice->BenderValue=0;
				else
					ThisVoice->BenderValue=Pitchwheel;
				ThisVoice->VibWaveType=ThisVoice->InsArt->VibType;
				if ((ThisVoice->VibWaveType&4)==0)
					ThisVoice->VibIndex=0;
				ThisVoice->VibSpeed=ThisVoice->InsArt->VibSpeed;
				if (Modulation==GLX_DEFINSMODULATION)
					ThisVoice->VibDepth=ThisVoice->InsArt->VibDepth;
				else
					ThisVoice->VibDepth=Modulation;
				ThisVoice->TremWaveType=ThisVoice->InsArt->TremType;
				if ((ThisVoice->TremWaveType&4)==0)
					ThisVoice->TremIndex=0;
				ThisVoice->TremSpeed=ThisVoice->InsArt->TremSpeed;
				ThisVoice->TremDepth=ThisVoice->InsArt->TremDepth;
				ThisVoice->SmpBasePeriod=ThisVoice->SmpPeriod=glxCalcPeriod(ThisVoice,Key);
				ThisVoice->Link=LinkedVoice;
				LinkedVoice=ThisVoice;
			}
		}
	}
	glxUnlock();
	return ThisVoice;
}

int __cdecl glxStartMusic(void)
{
	int Voice;
  
	if (!glxMusicEnabled)
	{
		if (glxMusicVoices)
		{
			glxLock();
			for (Voice=glxSampleVoices;Voice<(glxSampleVoices+glxMusicVoices);Voice++)
				glxVoices[Voice].Enabled=GLX_ON;
			glxMusicEnabled=GLX_ON;
			glxUnlock();
			return GLXERR_NOERROR;
		}
		return GLXERR_NOMUSICLOADED;
	}
	return GLXERR_MUSICPLAYING;
}

glxVoice * __cdecl glxStartSample(int Voice,glxSample *Sample,int Frequency,int Volume,int Panning,int Flags)
{
	glxVoice *PreviousVoice=NULL;
	glxVoice *ThisVoice=NULL;
	udword StartAddress;
	int Layer,Layers;

	if (glxSampleVoices==0)
		return GLX_NULL;
	if (Sample==NULL)
		return GLX_NULL;
	if (Sample->FourCC!=GLX_FOURCC_SAMP)
		return GLX_NULL;
	if (Sample->Type&GLX_STEREOSAMPLE)
		Layers=2;
	else
		Layers=1;
	glxLock();
	glxUpdateHardwareStatus();
	for (Layer=0;Layer<Layers;Layer++)
	{
		PreviousVoice=ThisVoice;
		ThisVoice=((Voice==GLX_AUTO)?glxAllocateSampleVoice(ThisVoice):&glxVoices[Voice+Layer-1]);
		if ((ThisVoice)&&(glxStopSample(ThisVoice)==GLXERR_NOERROR))
		{
			if (Sample->Data)
			{
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
					ThisVoice->StartTime=(((Flags&GLX_LOCKED)||(Layer!=0))?0xfffffffe:glxCurrentTick);
				else
					ThisVoice->StartTime=((Flags&GLX_LOCKED)?0xfffffffe:glxCurrentTick);
				ThisVoice->NoteNo=60;
				ThisVoice->InstNo=0;
				ThisVoice->SmpNo=0;
				ThisVoice->Active=GLX_ON;
				ThisVoice->Enabled=GLX_ON;
				ThisVoice->Flags=((Layer==0)?(Flags|GLX_MASTER):(Flags&~(GLX_CALLBACK|GLX_MASTER)));
				ThisVoice->Velocity=GLX_MAXSMPVELOCITY;
				ThisVoice->Expression=GLX_MAXSMPEXPRESSION;
				ThisVoice->InsArt=NULL;
				ThisVoice->InsVol=32767;
				ThisVoice->InsVolTime=0;
				ThisVoice->InsVolFade=32767;
				ThisVoice->InsVolPoint=0;
				ThisVoice->InsPit=0;
				ThisVoice->InsPitTime=0;
				ThisVoice->InsPitFade=0;
				ThisVoice->InsPitPoint=0;
				ThisVoice->InsPan=0;
				ThisVoice->InsPanTime=0;
				ThisVoice->InsPanFade=0;
				ThisVoice->InsPanPoint=0;
				ThisVoice->SmpHdr=Sample;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					StartAddress=(udword)getmem(Sample->Reserved+31);
					memset((void *)StartAddress,0,Sample->Reserved);
				}
				else
					StartAddress=(udword)Sample->Data;
				ThisVoice->SmpPtr=StartAddress=((Sample->Type&GLX_16BITSAMPLE)?StartAddress>>1:StartAddress);
				ThisVoice->SmpFrac=0;
				ThisVoice->SmpType=Sample->Type;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					ThisVoice->SmpType|=GLX_ALWAYSLOOP|GLX_LOOPED;
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->SmpEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->Custom1=Sample->Reserved;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=Sample->Reserved;
					ThisVoice->Custom4=Sample->Reserved;
				}
				else
				{
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress+Sample->LoopStart;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
					ThisVoice->SmpEnd=StartAddress+Sample->Length;
					ThisVoice->Custom1=0;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=0;
					ThisVoice->Custom4=0;
				}
				if (Frequency==GLX_DEFSMPFREQUENCY)
					ThisVoice->SmpC4Speed=Sample->C4Speed;
				else
					ThisVoice->SmpC4Speed=Frequency;
				if (Volume==GLX_DEFSMPVOLUME)
					ThisVoice->SmpBaseVol=ThisVoice->SmpVol=Sample->Volume;
				else
					ThisVoice->SmpBaseVol=ThisVoice->SmpVol=Volume;
				if (Panning==GLX_DEFSMPPANNING)
				{
					if (Layers>1)
						ThisVoice->Panning=ThisVoice->BasePanning=((Layer&1)?GLX_MAXSMPPANNING:GLX_MINSMPPANNING);
					else if (Sample->Type&GLX_PANNING)
						ThisVoice->Panning=ThisVoice->BasePanning=Sample->Panning;
				}
				else
					ThisVoice->Panning=ThisVoice->BasePanning=Panning;
				ThisVoice->SmpPitch=((ThisVoice->SmpC4Speed/glxSamplingrate)<<16);
				ThisVoice->SmpPitch+=(((ThisVoice->SmpC4Speed%glxSamplingrate)<<16)/glxSamplingrate);
				ThisVoice->SmpBasePeriod=ThisVoice->SmpPeriod=glxCalcPeriod(ThisVoice,60);
				ThisVoice->VibIndex=0;
				ThisVoice->TremIndex=0;
				ThisVoice->Mutex=CreateMutex(NULL,TRUE,NULL);
				ThisVoice->Link=NULL;
				if (PreviousVoice)
					PreviousVoice->Link=ThisVoice;
			}
		}
		else if (PreviousVoice)
		{
			glxStopSample(PreviousVoice);
			PreviousVoice=NULL;
		}
	}
	if (ThisVoice) ReleaseMutex(ThisVoice->Mutex);
	if (PreviousVoice) ReleaseMutex(PreviousVoice->Mutex);
	glxUnlock();
	return (PreviousVoice?PreviousVoice:ThisVoice);
}

glxVoice * __cdecl glxStartSample3D(int Voice,glxSample *Sample,int Frequency,int Volume,glxVector *Position,glxVector *Velocity,int Flags)
{
	float Distance1,Distance2,Orientation;
	LPKSPROPERTYSET SourceEaxPropertySet;
	SOURCEATTRIBUTES SourceAttributes;
	glxVector Difference1,Difference2;
	int Layer,Layers,WritePtrCnt1;
	glxVoice *PreviousVoice=NULL;
	glxVoice *ThisVoice=NULL;
	udword StartAddress,i;
	WAVEFORMATEX SampleType;
	DSBUFFERDESC DSBDesc;
	void *WritePtr1;
	long SourceID;

	if (glxSampleVoices==0)
		return GLX_NULL;
	if (Sample==NULL)
		return GLX_NULL;
	if (Sample->FourCC!=GLX_FOURCC_SAMP)
		return GLX_NULL;
	if (Sample->Type&GLX_STEREOSAMPLE)
		Layers=2;
	else
		Layers=1;
	glxLock();
	glxUpdateHardwareStatus();
	for (Layer=0;Layer<Layers;Layer++)
	{
		PreviousVoice=ThisVoice;
		ThisVoice=((Voice==GLX_AUTO)?glxAllocateSampleVoice(ThisVoice):&glxVoices[Voice+Layer-1]);
		if ((ThisVoice)&&(glxStopSample3D(ThisVoice)==GLXERR_NOERROR))
		{
			if (Sample->Data)
			{
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
					ThisVoice->StartTime=(((Flags&GLX_LOCKED)||(Layer!=0))?0xfffffffe:glxCurrentTick);
				else
					ThisVoice->StartTime=((Flags&GLX_LOCKED)?0xfffffffe:glxCurrentTick);
				ThisVoice->NoteNo=60;
				ThisVoice->InstNo=0;
				ThisVoice->SmpNo=0;
				ThisVoice->Active=GLX_ON;
				ThisVoice->Enabled=GLX_ON;
				ThisVoice->Flags=((Layer==0)?(Flags|GLX_MASTER):(Flags&~(GLX_CALLBACK|GLX_MASTER)));
				ThisVoice->Velocity=GLX_MAXSMPVELOCITY;
				ThisVoice->Expression=GLX_MAXSMPEXPRESSION;
				ThisVoice->InsArt=NULL;
				ThisVoice->InsVol=32767;
				ThisVoice->InsVolTime=0;
				ThisVoice->InsVolFade=32767;
				ThisVoice->InsVolPoint=0;
				ThisVoice->InsPit=0;
				ThisVoice->InsPitTime=0;
				ThisVoice->InsPitFade=0;
				ThisVoice->InsPitPoint=0;
				ThisVoice->InsPan=0;
				ThisVoice->InsPanTime=0;
				ThisVoice->InsPanFade=0;
				ThisVoice->InsPanPoint=0;
				ThisVoice->SmpHdr=Sample;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					StartAddress=(udword)getmem(Sample->Reserved+31);
					memset((void *)StartAddress,0,Sample->Reserved);
				}
				else
					StartAddress=(udword)Sample->Data;
				ThisVoice->SmpPtr=StartAddress=((Sample->Type&GLX_16BITSAMPLE)?StartAddress>>1:StartAddress);
				ThisVoice->SmpFrac=0;
				ThisVoice->SmpType=Sample->Type;
				if ((Sample->Type&GLX_STREAMINGAUDIO)||(Sample->Type&GLX_COMPRESSED)||(Sample->Type&GLX_STEREOSAMPLE))
				{
					ThisVoice->Flags|=GLX_NOPOSITIONAL;
					ThisVoice->SmpType|=GLX_ALWAYSLOOP|GLX_LOOPED;
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->SmpEnd=StartAddress+Sample->Reserved/2-1;
					ThisVoice->Custom1=Sample->Reserved;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=Sample->Reserved;
					ThisVoice->Custom4=Sample->Reserved;
				}
				else
				{
					ThisVoice->Flags|=GLX_POSITIONAL;
					ThisVoice->SmpStart=StartAddress;
					ThisVoice->SmpLoopStart=StartAddress+Sample->LoopStart;
					ThisVoice->SmpLoopEnd=StartAddress+Sample->LoopEnd;
					ThisVoice->SmpEnd=StartAddress+Sample->Length;
					ThisVoice->Custom1=0;
					ThisVoice->Custom2=0;
					ThisVoice->Custom3=0;
					ThisVoice->Custom4=0;
				}
				if (Frequency==GLX_DEFSMPFREQUENCY)	
					ThisVoice->SmpC4Speed=Sample->C4Speed;
				else 
					ThisVoice->SmpC4Speed=Frequency;
				if (Volume==GLX_DEFSMPVOLUME) 
					ThisVoice->SmpBaseVol=ThisVoice->SmpVol=Sample->Volume;
				else 
					ThisVoice->SmpBaseVol=ThisVoice->SmpVol=Volume;
				if (Layers>1)
					ThisVoice->Panning=ThisVoice->BasePanning=((Layer&1)?GLX_MAXSMPPANNING:GLX_MINSMPPANNING);
				else if (Sample->Type&GLX_PANNING)
					ThisVoice->Panning=ThisVoice->BasePanning=Sample->Panning;
				ThisVoice->SmpPitch=((ThisVoice->SmpC4Speed/glxSamplingrate)<<16);
				ThisVoice->SmpPitch+=(((ThisVoice->SmpC4Speed%glxSamplingrate)<<16)/glxSamplingrate);
				ThisVoice->SmpBasePeriod=ThisVoice->SmpPeriod=glxCalcPeriod(ThisVoice,60);
				ThisVoice->VibIndex=0;
				ThisVoice->TremIndex=0;
				ThisVoice->Mutex=CreateMutex(NULL,TRUE,NULL);
				ThisVoice->Link=NULL;
				if (PreviousVoice)
					PreviousVoice->Link=ThisVoice;
				//Start 3D positional sound	IF possible
				if (ThisVoice->Flags&GLX_POSITIONAL)
				{
					if ((glxAudioOutput.Type==GLX_A3D)||(glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
					{
						//Now create NEW secondary DSound buffer :
						SampleType.wFormatTag=WAVE_FORMAT_PCM;
						SampleType.nChannels=(ThisVoice->SmpType&GLX_STEREOSAMPLE)?2:1;
						SampleType.nSamplesPerSec=(ThisVoice->SmpC4Speed);
						SampleType.nBlockAlign=((ThisVoice->SmpType&GLX_16BITSAMPLE)?2:1)*((ThisVoice->SmpType&GLX_STEREOSAMPLE)?2:1);
						SampleType.wBitsPerSample=(ThisVoice->SmpType&GLX_16BITSAMPLE)?16:8;
						SampleType.nAvgBytesPerSec=(SampleType.nSamplesPerSec*SampleType.nBlockAlign);
						SampleType.cbSize=0;
						memset(&DSBDesc,0,sizeof(DSBUFFERDESC));
						DSBDesc.dwSize=sizeof(DSBUFFERDESC);
						DSBDesc.lpwfxFormat=&SampleType;
						DSBDesc.dwBufferBytes=(Sample->Length*SampleType.nBlockAlign);
						DSBDesc.dwFlags=DSBCAPS_LOCHARDWARE|DSBCAPS_CTRL3D|DSBCAPS_CTRLVOLUME|DSBCAPS_CTRLFREQUENCY;
						if (IDirectSound_CreateSoundBuffer((LPDIRECTSOUND)glxAudioOutput.Handle,&DSBDesc,&(LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,NULL)==DS_OK)
						{
							IDirectSoundBuffer_Lock((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,0,0,&WritePtr1,&WritePtrCnt1,NULL,NULL,DSBLOCK_ENTIREBUFFER);
							if (Sample->Type&GLX_16BITSAMPLE) memcpy(WritePtr1,Sample->Data,Sample->Length*SampleType.nBlockAlign);
							else for (i=0;i<Sample->Length;i++)
								((ubyte *)WritePtr1)[i]=((sbyte *)Sample->Data)[i]+128;
							IDirectSoundBuffer_Unlock((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,WritePtr1,WritePtrCnt1,NULL,0);
							if (IDirectSoundBuffer_QueryInterface((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,&IID_IDirectSound3DBuffer,(void **)&ThisVoice->Custom2)==S_OK)
							{
								IDirectSoundBuffer_SetVolume((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,(long)(2000.0*log10(((float)glxSampleVolume*(float)glxSampleVolume*(float)ThisVoice->Volume*(float)ThisVoice->SmpVol)/(16384.0f*32768.0f*32768.0f))));
	 							IDirectSoundBuffer_SetFrequency((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,ThisVoice->SmpC4Speed);
								IDirectSound3DBuffer_SetMode((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,DS3DMODE_HEADRELATIVE,DS3D_IMMEDIATE);
								IDirectSound3DBuffer_SetPosition((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,Position->X,Position->Y,Position->Z,DS3D_IMMEDIATE);
								IDirectSound3DBuffer_SetVelocity((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,Velocity->X,Velocity->Y,Velocity->Z,DS3D_IMMEDIATE);
								if (glxEaxManager)
								{
									if (IEaxManager_GetSourceID(glxEaxManager,Sample->Message,&SourceID)==EM_OK)
									{
										if (IEaxManager_GetSourceAttributes(glxEaxManager,SourceID,&SourceAttributes)==EM_OK)
										{
											IDirectSound3DBuffer_SetMinDistance((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,SourceAttributes.fMinDistance/400.0f,DS3D_IMMEDIATE);
											IDirectSound3DBuffer_SetMaxDistance((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,SourceAttributes.fMaxDistance/400.0f,DS3D_IMMEDIATE);
											IDirectSound3DBuffer_SetConeOrientation((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,SourceAttributes.fConeXdir,SourceAttributes.fConeYdir,SourceAttributes.fConeZdir,DS3D_IMMEDIATE);
											IDirectSound3DBuffer_SetConeOutsideVolume((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,SourceAttributes.lConeOutsideVolume,DS3D_IMMEDIATE);
											IDirectSound3DBuffer_SetConeAngles((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,SourceAttributes.ulInsideConeAngle,SourceAttributes.ulOutsideConeAngle, DS3D_IMMEDIATE);
											if (IDirectSound3DBuffer_QueryInterface((LPDIRECTSOUND3DBUFFER)ThisVoice->Custom2,&IID_IKsPropertySet,(void**)&SourceEaxPropertySet)==S_OK)
											{
												IKsPropertySet_Set(
													SourceEaxPropertySet,
													&DSPROPSETID_EAX_BufferProperties,
													DSPROPERTY_EAXBUFFER_ALLPARAMETERS,
													NULL,
													0,
													&SourceAttributes.eaxAttributes,
													sizeof(EAXBUFFERPROPERTIES));
												IKsPropertySet_Release(SourceEaxPropertySet);
											}
										}
									}

								}
								if (Sample->Type&GLX_LOOPED) IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,0,0,DSBPLAY_LOOPING);
								else IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1,0,0,0);
								ThisVoice->Active=GLX_ON;
								ThisVoice->Enabled=GLX_OFF;
							}
							else
							{
								IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)ThisVoice->Custom1);
								ThisVoice->Custom1=ThisVoice->Custom2=0;
							}
						}
						else
							ThisVoice->Custom1=ThisVoice->Custom2=0;
					}
					else if (glxAudioOutput.Type==GLX_A3D2)
					{
						SampleType.wFormatTag=WAVE_FORMAT_PCM;
						SampleType.nChannels=(ThisVoice->SmpType&GLX_STEREOSAMPLE)?2:1;
						SampleType.nSamplesPerSec=(ThisVoice->SmpHdr->C4Speed);
						SampleType.nBlockAlign=((ThisVoice->SmpType&GLX_16BITSAMPLE)?2:1)*((ThisVoice->SmpType&GLX_STEREOSAMPLE)?2:1);
						SampleType.wBitsPerSample=(ThisVoice->SmpType&GLX_16BITSAMPLE)?16:8;
						SampleType.nAvgBytesPerSec=(SampleType.nSamplesPerSec*SampleType.nBlockAlign);
						SampleType.cbSize=0;
						if ((glxAudioOutput.Extensions)&&(((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->NewSource((LPA3D4)glxAudioOutput.Extensions,A3DSOURCE_INITIAL_RENDERMODE_A3D,&(LPA3DSOURCE)ThisVoice->Custom1)==S_OK))
						{
//							((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Clear((LPA3D4)glxAudioOutput.Extensions);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetTransformMode((LPA3DSOURCE)ThisVoice->Custom1,A3DSOURCE_TRANSFORMMODE_HEADRELATIVE);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetWaveFormat((LPA3DSOURCE)ThisVoice->Custom1,&SampleType);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->AllocateWaveData((LPA3DSOURCE)ThisVoice->Custom1,Sample->Length*SampleType.nBlockAlign);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->Lock((LPA3DSOURCE)ThisVoice->Custom1,0,0,&WritePtr1,&WritePtrCnt1,NULL,NULL,A3D_ENTIREBUFFER);
							if (Sample->Type&GLX_16BITSAMPLE) memcpy(WritePtr1,Sample->Data,Sample->Length*SampleType.nBlockAlign);
							else for (i=0;i<Sample->Length;i++) 
								((ubyte *)WritePtr1)[i]=((sbyte *)Sample->Data)[i]+128;
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->Unlock((LPA3DSOURCE)ThisVoice->Custom1,WritePtr1,WritePtrCnt1,NULL,0);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetGain((LPA3DSOURCE)ThisVoice->Custom1,(((float)glxSampleVolume*(float)glxSampleVolume*(float)ThisVoice->Volume*(float)ThisVoice->SmpVol)/(16384.0f*32768.0f*32768.0f)));
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetPitch((LPA3DSOURCE)ThisVoice->Custom1,(float)ThisVoice->SmpC4Speed/(float)ThisVoice->SmpHdr->C4Speed);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetPosition3f((LPA3DSOURCE)ThisVoice->Custom1,Position->X,Position->Y,Position->Z);
							((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->SetVelocity3f((LPA3DSOURCE)ThisVoice->Custom1,Velocity->X,Velocity->Y,Velocity->Z);
							if (Sample->Type&GLX_LOOPED) ((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->Play((LPA3DSOURCE)ThisVoice->Custom1,A3D_LOOPED);
							else ((LPA3DSOURCE)ThisVoice->Custom1)->lpVtbl->Play((LPA3DSOURCE)ThisVoice->Custom1,A3D_SINGLE);
//							((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Flush((LPA3D4)glxAudioOutput.Extensions);
							ThisVoice->Active=GLX_ON;
							ThisVoice->Enabled=GLX_OFF;
						}
						else
							ThisVoice->Custom1=ThisVoice->Custom2=0;
					}
					if (!ThisVoice->Active)
					{
						if (glxAudioOutput.Listener)
						{
							//Calc. displacement vector at t	
							Difference1.X=Position->X-((glxVector *)glxAudioOutput.Listener)->X;
							Difference1.Y=Position->Y-((glxVector *)glxAudioOutput.Listener)->Y;
							Difference1.Z=Position->Z-((glxVector *)glxAudioOutput.Listener)->Z;
							//Calc. distance at t
							Distance1=(float)(sqrt(Difference1.X*Difference1.X+Difference1.Y*Difference1.Y+Difference1.Z*Difference1.Z));
							//Calc. displacement vector at t plus 1/343 sec
							Difference2.X=(float)(Position->X+(Velocity->X/343.0)-((glxVector *)glxAudioOutput.Listener)->X);
							Difference2.Y=(float)(Position->Y+(Velocity->Y/343.0)-((glxVector *)glxAudioOutput.Listener)->Y);
							Difference2.Z=(float)(Position->Z+(Velocity->Z/343.0)-((glxVector *)glxAudioOutput.Listener)->Z);
							//Calc. distance at t plus 1/343 sec
							Distance2=(float)(sqrt(Difference2.X*Difference2.X+Difference2.Y*Difference2.Y+Difference2.Z*Difference2.Z));
							//Calc. sound orientation
							if (Distance1)
								Orientation=(float)(atan2(Difference1.Z,Difference1.X));//+atan2(Listener->X,Listener->Z);
							else
								Orientation=1.57f;
							//Calc. panning uses Dolby Surround
							if (Orientation<0)
								ThisVoice->Panning=ThisVoice->BasePanning=(int)(GLX_SURSMPPANNING+GLX_MIDSMPPANNING);
							else
								ThisVoice->Panning=ThisVoice->BasePanning=(int)(GLX_MIDSMPPANNING+GLX_MIDSMPPANNING*0.707f*cos(Orientation));
							//Calc. attenuation uses the inverse square law 
							if (fabs(Distance1)<1.0)
								ThisVoice->Velocity=(int)(GLX_MAXSMPVOLUME);
							else
								ThisVoice->Velocity=(int)(GLX_MAXSMPVOLUME/Distance1);
							//Calc. dopler shift uses speed of sound 343 m/sec
							Frequency=(int)(ThisVoice->SmpC4Speed/(1.0+(Distance2-Distance1)));
							ThisVoice->SmpPitch=((Frequency/glxSamplingrate)<<16);
							ThisVoice->SmpPitch+=(((Frequency%glxSamplingrate)<<16)/glxSamplingrate);
							ThisVoice->Active=GLX_ON;
							ThisVoice->Enabled=GLX_ON;
						}
					}
				}
			}
		}
		else if (PreviousVoice)
		{
			glxStopSample3D(PreviousVoice);
			PreviousVoice=NULL;
		}
	}
	if (ThisVoice) ReleaseMutex(ThisVoice->Mutex);
	if (PreviousVoice) ReleaseMutex(PreviousVoice->Mutex);
	glxUnlock();
	return (PreviousVoice?PreviousVoice:ThisVoice);
}

int __cdecl glxStartOutput(void *Owner,unsigned int Rate,int Format,int MixAhead)
{
	int SamplesPerSec[]={48000,44100,32000,22050,16000,11025,8000};
	int BitsPerSample[]={16,8};
	int Channels[]={2,1};
	int i,j,k,status;
	DSBUFFERDESC DSBDesc;
	DSCAPS DSCaps;	
 
	if (!glxOutputActive)
	{
		//Clear output structure
		memset(&glxAudioOutput,0,sizeof(glxOutput));
		//kill this check sometime..
		if ((glxMusicVoices+glxSampleVoices)>GLX_TOTALVOICES)
			return GLXERR_OUTOFVOICES;
		/* Limit FX mixahead between 5..495 MSec */
		if (MixAhead<5) MixAhead=5;
		else if (MixAhead>495) MixAhead=495;
		EfxMixAhead=MixAhead;
		glxLock();
	
		/* Microsoft Directsound driver */
		if ((!glxAudioOutput.Handle)&&(Owner))
		{
			/* Initialize DirectSound object */
			if (Format&GLX_3DAUDIO)
			{
				// Setup for A3D 2.0
				if (glxInitA3D2()!=GLXERR_NOERROR)
				{
					// Setup for A3D 1.x
					glxInitA3D();
				}
				// Setup for DirectSound3D
				if ((!glxAudioOutput.Handle)&&(CoCreateInstance(&CLSID_DirectSound,NULL,CLSCTX_INPROC_SERVER,&IID_IDirectSound,&glxAudioOutput.Handle)!=S_OK))
					glxAudioOutput.Handle=NULL;
			}
			else
			{
 				// Setup for normal DirectSound
				if (CoCreateInstance(&CLSID_DirectSound,NULL,CLSCTX_INPROC_SERVER,&IID_IDirectSound,&glxAudioOutput.Handle)!=S_OK)
					glxAudioOutput.Handle=NULL;
			}
			if ((glxAudioOutput.Handle)&&(IDirectSound_Initialize((LPDIRECTSOUND)glxAudioOutput.Handle,NULL)==DS_OK))
			{
				if (IDirectSound_SetCooperativeLevel((LPDIRECTSOUND)glxAudioOutput.Handle,Owner,DSSCL_PRIORITY)==DS_OK)
				{
					memset(&DSCaps,0,sizeof(DSCAPS));
					DSCaps.dwSize=sizeof(DSCAPS);
					IDirectSound_GetCaps((LPDIRECTSOUND)glxAudioOutput.Handle,&DSCaps);
					if ((DSCaps.dwFlags&DSCAPS_EMULDRIVER)==0)
					{
						/* Setup DirectSound primary buffer */
						memset(&DSBDesc,0,sizeof(DSBUFFERDESC));
						DSBDesc.dwSize=sizeof(DSBUFFERDESC);
						DSBDesc.dwFlags=DSBCAPS_PRIMARYBUFFER|DSBCAPS_CTRL3D;
						if (IDirectSound_CreateSoundBuffer((LPDIRECTSOUND)glxAudioOutput.Handle,&DSBDesc,&(LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,NULL)==DS_OK)
						{
							if (Format&GLX_3DAUDIO)
							{
								// A3D 2.0
								if (glxAudioOutput.Extensions)
								{
									// A3D 2.0
									((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->SetCooperativeLevel((LPA3D4)glxAudioOutput.Extensions,Owner,A3D_CL_NORMAL);
									((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->SetCoordinateSystem((LPA3D4)glxAudioOutput.Extensions,A3D_LEFT_HANDED_CS);
									if (((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->QueryInterface((LPA3D4)glxAudioOutput.Extensions,&IID_IA3dListener,&glxAudioOutput.Listener)!=S_OK)
										glxAudioOutput.Listener=NULL;
									((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->SetPosition3f((LPA3DLISTENER)glxAudioOutput.Listener,0.0f,0.0f,0.0f);
									((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->SetOrientation6f((LPA3DLISTENER)glxAudioOutput.Listener,0.0f,0.0f,1.0f,0.0f,1.0f,0.0f);
									glxAudioOutput.Type=GLX_A3D2;
								}
								else if (glxAudioOutput.Extensions=EAXCreate((LPDIRECTSOUND)glxAudioOutput.Handle))
								{
									// EAX 1.0
									if (IDirectSoundBuffer_QueryInterface((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,&IID_IDirectSound3DListener,&glxAudioOutput.Listener)!=DS_OK)
										glxAudioOutput.Listener=NULL;
									glxAudioOutput.Type=GLX_EAX;
								}
								else if (IDirectSound_QueryInterface((LPDIRECTSOUND)glxAudioOutput.Handle,&IID_IA3d,&glxAudioOutput.Extensions)==DS_OK)
								{
									// A3D 1.0
									if (IDirectSoundBuffer_QueryInterface((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,&IID_IDirectSound3DListener,&glxAudioOutput.Listener)!=DS_OK)
										glxAudioOutput.Listener=NULL;
									glxAudioOutput.Type=GLX_A3D;
								}
								else
								{
									glxAudioOutput.Extensions=NULL;
									if (glxAudioOutput.Listener=malloc(sizeof(glxVector)))
										memset(glxAudioOutput.Listener,0,sizeof(glxVector));
									glxAudioOutput.Type=GLX_G3D;
								}
							}
							else
							{
								glxAudioOutput.Extensions=NULL;
								glxAudioOutput.Listener=NULL;
								glxAudioOutput.Type=GLX_NORMAL;
							}
							/* find best matching supported format */
							for (i=0;i<2;i++)
							{
								for (j=0;j<2;j++)
								{
									for (k=0;k<7;k++)
									{
										memset(&OutputType,0,sizeof(WAVEFORMATEX));
										OutputType.wFormatTag=WAVE_FORMAT_PCM;
										OutputType.nChannels=Channels[i];
										OutputType.wBitsPerSample=BitsPerSample[j];
										OutputType.nBlockAlign=OutputType.nChannels*OutputType.wBitsPerSample/8;
										OutputType.nSamplesPerSec=SamplesPerSec[k];
										OutputType.nAvgBytesPerSec=SamplesPerSec[k]*OutputType.nBlockAlign;
										//Adjust for user criteria		
										if (OutputType.nSamplesPerSec<=Rate)
										{
											if ((OutputType.nChannels==1)||(Format&GLX_STEREO))
											{
												if ((OutputType.wBitsPerSample==8)||(Format&GLX_16BIT))
												{
													status=GLXERR_UNSUPPORTEDFORMAT;
													if (IDirectSoundBuffer_SetFormat((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer,&OutputType)==DS_OK)
													{
														memset(&DSBDesc,0,sizeof(DSBUFFERDESC));
														DSBDesc.dwSize=sizeof(DSBUFFERDESC);
														DSBDesc.dwFlags=DSBCAPS_GLOBALFOCUS|DSBCAPS_GETCURRENTPOSITION2;
														DSBDesc.dwBufferBytes=OutputType.nAvgBytesPerSec;
														DSBDesc.lpwfxFormat=&OutputType;
														if (IDirectSound_CreateSoundBuffer((LPDIRECTSOUND)glxAudioOutput.Handle,&DSBDesc,&(LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,NULL)==DS_OK)
														{
															memset(glxAudioBuffer.Data,((OutputType.wBitsPerSample&8)<<4),OutputType.nAvgBytesPerSec);
															if (IDirectSoundBuffer_Play((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle,0,0,DSBPLAY_LOOPING)==DS_OK)
															{
																glxAudioBuffer.Length=OutputType.nAvgBytesPerSec;
																glxAudioBuffer.PlayPos=glxAudioBuffer.WritePos=0;
																glxAudioBuffer.Premix=0;
																glxAudioOutput.Driver=GLX_DIRECTSOUND;
																glxAudioOutput.Format=Format&GLX_COSINE;
																glxAudioOutput.Format|=(OutputType.nChannels>>1);
																glxAudioOutput.Format|=((OutputType.wBitsPerSample&8)<<4);
																glxAudioOutput.Format|=((OutputType.wBitsPerSample&16)>>3);
																glxFlushOutput();
																glxSetDSPMode((glxAudioOutput.Format&133)|2);
																glxSetSamplingrate(OutputType.nSamplesPerSec);
																glxOutputActive=GLX_ON;
																timeBeginPeriod(1);
   																TimerID=timeSetEvent(MixAhead>>1,0,glxDSTimerHandler,0,TIME_PERIODIC);
																glxDriverID="Directsound(tm) output driver v4.0";
																glxUnlock();
																return GLXERR_NOERROR;
															}
															IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
															glxAudioBuffer.Handle=NULL;
														}
													}
												}
											}
										}
									}
								}
							}
							if (glxAudioOutput.Type==GLX_A3D2)
							{
								if (glxAudioOutput.Listener)
								{
									((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->Release((LPA3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Release((LPA3D4)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_A3D)
							{
								if (glxAudioOutput.Listener)
								{
									IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								IA3d_Release((LPIA3D)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_EAX)
							{
								if (glxAudioOutput.Listener)
								{
									IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
								EAXRelease((LPKSPROPERTYSET)glxAudioOutput.Extensions);
								glxAudioOutput.Extensions=NULL;
							}
							if (glxAudioOutput.Type==GLX_G3D)
							{
								if (glxAudioOutput.Listener)
								{
									free(glxAudioOutput.Listener);
									glxAudioOutput.Listener=NULL;
								}
							}
							IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer);
							glxAudioOutput.Mixer=NULL;
						}
					}
				}
			}
			if (glxAudioOutput.Handle)
				IDirectSound_Release((LPDIRECTSOUND)glxAudioOutput.Handle);
			glxAudioOutput.Handle=NULL;
		}

		/* Windows wave driver */
		if (!glxAudioOutput.Handle)
		{
			if (Format&GLX_3DAUDIO)
			{
				glxAudioOutput.Extensions=NULL;
				if (glxAudioOutput.Listener=malloc(sizeof(glxVector)))
					memset(glxAudioOutput.Listener,0,sizeof(glxVector));
				glxAudioOutput.Type=GLX_G3D;
			}
			else
			{
				glxAudioOutput.Extensions=NULL;
				glxAudioOutput.Listener=NULL;
				glxAudioOutput.Type=GLX_NORMAL;
			}
			/* find best matching supported format */
			for (i=0;i<2;i++)
			{
  				for (j=0;j<2;j++)
				{
					for (k=0;k<7;k++)
					{
						OutputType.wFormatTag=WAVE_FORMAT_PCM;
 						OutputType.nChannels=Channels[i];
						OutputType.wBitsPerSample=BitsPerSample[j];
						OutputType.nBlockAlign=OutputType.nChannels*OutputType.wBitsPerSample/8;
						OutputType.nSamplesPerSec=SamplesPerSec[k];
						OutputType.nAvgBytesPerSec=SamplesPerSec[k]*OutputType.nBlockAlign;
						OutputType.cbSize=0;
  						//Adjust for user criteria		
						if (OutputType.nSamplesPerSec<=Rate)
						{
							if ((OutputType.nChannels==1)||(Format&GLX_STEREO))
							{
								if ((OutputType.wBitsPerSample==8)||(Format&GLX_16BIT))
								{
									status=GLXERR_UNSUPPORTEDFORMAT;
									if (waveOutOpen(&(HWAVEOUT)glxAudioOutput.Handle,WAVE_MAPPER,&OutputType,0,0,WAVE_FORMAT_DIRECT_QUERY)==MMSYSERR_NOERROR)
									{
										status=GLXERR_DEVICEBUSY;
										if (waveOutOpen(&(HWAVEOUT)glxAudioOutput.Handle,WAVE_MAPPER,&OutputType,0,0,0)==MMSYSERR_NOERROR)
										{
											/* Setup Windows Multimedia driver buffer and start playing */
											if (!(LPWAVEHDR)glxAudioBuffer.Handle)
												glxAudioBuffer.Handle=malloc(sizeof(WAVEHDR));
											memset((LPWAVEHDR)glxAudioBuffer.Handle,0,sizeof(WAVEHDR));
											((LPWAVEHDR)glxAudioBuffer.Handle)->lpData=glxAudioBuffer.Data;
											((LPWAVEHDR)glxAudioBuffer.Handle)->dwBufferLength=OutputType.nAvgBytesPerSec;
											((LPWAVEHDR)glxAudioBuffer.Handle)->dwFlags=WHDR_BEGINLOOP|WHDR_ENDLOOP;
											((LPWAVEHDR)glxAudioBuffer.Handle)->dwLoops=0xffffffff;
											waveOutPrepareHeader((HWAVEOUT)glxAudioOutput.Handle,(LPWAVEHDR)glxAudioBuffer.Handle,sizeof(WAVEHDR));
											memset(glxAudioBuffer.Data,((OutputType.wBitsPerSample&8)<<4),OutputType.nAvgBytesPerSec);
											if ((status=waveOutWrite((HWAVEOUT)glxAudioOutput.Handle,(LPWAVEHDR)glxAudioBuffer.Handle,sizeof(WAVEHDR)))==MMSYSERR_NOERROR)
											{
												glxAudioBuffer.Length=OutputType.nAvgBytesPerSec;
												glxAudioBuffer.PlayPos=glxAudioBuffer.WritePos=0;
												glxAudioBuffer.Premix=0;
												glxAudioOutput.Driver=GLX_WAVEDRIVER;
												glxAudioOutput.Format=Format&GLX_COSINE;
												glxAudioOutput.Format|=(OutputType.nChannels>>1);
												glxAudioOutput.Format|=((OutputType.wBitsPerSample&8)<<4);
												glxAudioOutput.Format|=((OutputType.wBitsPerSample&16)>>3);
												glxFlushOutput();
												glxSetDSPMode((glxAudioOutput.Format&133)|2);
												glxSetSamplingrate(OutputType.nSamplesPerSec);
												glxOutputActive=GLX_ON;
												timeBeginPeriod(1);
												TimerID=timeSetEvent(MixAhead>>1,0,glxMMTimerHandler,0,TIME_PERIODIC);
												glxDriverID="Windows(r) wave output driver 4.0";		
												glxUnlock();
												return GLXERR_NOERROR;
											}
											waveOutClose((HWAVEOUT)glxAudioOutput.Handle);
											glxAudioOutput.Handle=NULL;
										}
									}
								}
							}
						}
					}	
				}
			}
		}
		
		glxUnlock();
		return status;
	}
	return GLXERR_OUTPUTACTIVE;
}

int __cdecl glxStopCDAudio(void)
{
	DWORD dwReturn=1;
	MCI_GENERIC_PARMS mciCloseParms;

	if (CDRomID!=0)
	{
		dwReturn=mciSendCommand(CDRomID,MCI_STOP,0,(DWORD)NULL);
		if ((dwReturn=mciSendCommand(CDRomID,MCI_CLOSE,0,(DWORD)(LPVOID)&mciCloseParms))==0)
			CDRomID=0;
	}
	return dwReturn;
}

int __cdecl glxStopInstrument(glxVoice *Voice)
{
	HANDLE Mutexes[GLX_TOTALVOICES];
	glxVoice *NextVoice;
	int i=0;

	if (Voice!=NULL)
	{
		glxLock();
		NextVoice=Voice;
		while ((NextVoice)&&(NextVoice->Mutex))
		{
			Mutexes[i]=NextVoice->Mutex;
			NextVoice=NextVoice->Link;
			i++;
		} 
		if (WaitForMultipleObjects(i,Mutexes,TRUE,1000)==WAIT_OBJECT_0)
		{
			while ((Voice)&&(Voice->Mutex))
			{
				Voice->NoteNo|=128;
				/*
				Voice->Active=GLX_OFF;
				if ((Voice->SmpType&GLX_STREAMINGAUDIO)||(Voice->SmpType&GLX_COMPRESSED)||(Voice->SmpType&GLX_STEREOSAMPLE))
				{
					freemem((void *)(Voice->SmpType&GLX_16BITSAMPLE?Voice->SmpStart<<1:Voice->SmpStart));
					Voice->Custom1=0;
					Voice->Custom2=0;
					Voice->Custom3=0;
					Voice->Custom4=0;
				}
				*/
				CloseHandle(Voice->Mutex);
				Voice->Mutex=NULL;
				NextVoice=Voice->Link;
				Voice->Link=NULL;
				Voice=NextVoice;
			}
		}
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxStopMusic(void)
{
	int Voice;

	if (glxMusicEnabled)
	{
		if (glxMusicVoices)
		{
			glxLock();
			for (Voice=0;Voice<glxMusicVoices;Voice++)
				glxVoices[Voice+glxSampleVoices].Enabled=GLX_OFF;
			glxMusicEnabled=GLX_OFF;
			glxUnlock();
			return GLXERR_NOERROR;
		}
		return GLXERR_NOMUSICLOADED;
	}
	return GLXERR_NOMUSICPLAYING;
}

int __cdecl glxStopSample(glxVoice *Voice)
{
	HANDLE Mutexes[GLX_TOTALVOICES];
	glxVoice *NextVoice;
	int i=0;
	
	if (Voice!=NULL)
	{
		glxLock();
		NextVoice=Voice;
		while ((NextVoice)&&(NextVoice->Mutex))
		{
			Mutexes[i]=NextVoice->Mutex;
			NextVoice=NextVoice->Link;
			i++;
		} 
		if (WaitForMultipleObjects(i,Mutexes,TRUE,1000)==WAIT_OBJECT_0)
		{
			while ((Voice)&&(Voice->Mutex))
			{
				if (Voice->Flags&GLX_POSITIONAL)
				{
					if ((glxAudioOutput.Type==GLX_A3D)||(glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
					{
						if (Voice->Custom1)
						{
							IDirectSoundBuffer_Stop((LPDIRECTSOUNDBUFFER)Voice->Custom1);
							if (Voice->Custom2)
							{
								IDirectSound3DBuffer_Release((LPDIRECTSOUND3DBUFFER)Voice->Custom2);
								Voice->Custom2=0;
							}
							IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)Voice->Custom1);
							Voice->Custom1=0;
						}
					}
					else if (glxAudioOutput.Type==GLX_A3D2)
					{
						if (Voice->Custom1)
						{
							((LPA3DSOURCE)Voice->Custom1)->lpVtbl->Stop((LPA3DSOURCE)Voice->Custom1);
							((LPA3DSOURCE)Voice->Custom1)->lpVtbl->Release((LPA3DSOURCE)Voice->Custom1);
							Voice->Custom1=0;
						}
					}
				}
				if ((Voice->SmpType&GLX_STREAMINGAUDIO)||(Voice->SmpType&GLX_COMPRESSED)||(Voice->SmpType&GLX_STEREOSAMPLE))
				{
					if (Voice->SmpStart)
						freemem((void *)(Voice->SmpType&GLX_16BITSAMPLE?Voice->SmpStart<<1:Voice->SmpStart));
					Voice->SmpStart=0;
					Voice->Custom1=0;
					Voice->Custom2=0;
					Voice->Custom3=0;
					Voice->Custom4=0;
				}
				Voice->StartTime=0;
				Voice->Active=GLX_OFF;
				Voice->Flags=GLX_MASTER;
				CloseHandle(Voice->Mutex);
				Voice->Mutex=NULL;
				NextVoice=Voice->Link;
				Voice->Link=NULL;
				Voice=NextVoice;
			}
		}
		glxUnlock();
		return GLXERR_NOERROR;//Voice?GLXERR_CANNOTSTOPVOICE:GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxStopSample3D(glxVoice *Voice)
{
	HANDLE Mutexes[GLX_TOTALVOICES];
	glxVoice *NextVoice;
	int i=0;

	if (Voice!=NULL)
	{
		glxLock();
		NextVoice=Voice;
		while ((NextVoice)&&(NextVoice->Mutex))
		{
			Mutexes[i]=NextVoice->Mutex;
			NextVoice=NextVoice->Link;
			i++;
		} 
		if (WaitForMultipleObjects(i,Mutexes,TRUE,1000)==WAIT_OBJECT_0)
		{
			while ((Voice)&&(Voice->Mutex))
			{
				if (Voice->Flags&GLX_POSITIONAL)
				{
					if ((glxAudioOutput.Type==GLX_A3D)||(glxAudioOutput.Type==GLX_EAX)||(glxAudioOutput.Type==GLX_EAX2))
					{
						if (Voice->Custom1)
						{
							IDirectSoundBuffer_Stop((LPDIRECTSOUNDBUFFER)Voice->Custom1);
							if (Voice->Custom2)
							{
								IDirectSound3DBuffer_Release((LPDIRECTSOUND3DBUFFER)Voice->Custom2);
								Voice->Custom2=0;
							}
							IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)Voice->Custom1);
							Voice->Custom1=0;
						}
					}
					else if (glxAudioOutput.Type==GLX_A3D2)
					{
						if (Voice->Custom1)
						{
							((LPA3DSOURCE)Voice->Custom1)->lpVtbl->Stop((LPA3DSOURCE)Voice->Custom1);
							((LPA3DSOURCE)Voice->Custom1)->lpVtbl->Release((LPA3DSOURCE)Voice->Custom1);
							Voice->Custom1=0;
						}
					}
				}
				if ((Voice->SmpType&GLX_STREAMINGAUDIO)||(Voice->SmpType&GLX_COMPRESSED)||(Voice->SmpType&GLX_STEREOSAMPLE))
				{
					if (Voice->SmpStart)
						freemem((void *)(Voice->SmpType&GLX_16BITSAMPLE?Voice->SmpStart<<1:Voice->SmpStart));
					Voice->SmpStart=0;
					Voice->Custom1=0;
					Voice->Custom2=0;
					Voice->Custom3=0;
					Voice->Custom4=0;
				}
				Voice->StartTime=0;
				Voice->Active=GLX_OFF;
				Voice->Flags=GLX_MASTER;
				CloseHandle(Voice->Mutex);
				Voice->Mutex=NULL;
				NextVoice=Voice->Link;
				Voice->Link=NULL;
				Voice=NextVoice;
			}
		}
		glxUnlock();
		return GLXERR_NOERROR;//Voice?GLXERR_CANNOTSTOPVOICE:GLXERR_NOERROR;
	}
	return GLXERR_BADPARAMETER;
}

int __cdecl glxStopOutput(void)
{
	if (glxOutputActive)
	{
		glxLock();
		timeKillEvent(TimerID);
		timeEndPeriod(1);
		glxOutputActive=GLX_OFF;
		if (glxAudioOutput.Driver==GLX_DIRECTSOUND)
		{
			/* Stop DirectSound */
			if ((LPDIRECTSOUND)glxAudioOutput.Handle)
			{
				if ((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle)
				{
					IDirectSoundBuffer_Stop((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
					IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioBuffer.Handle);
					glxAudioBuffer.Handle=NULL;
				}
				if ((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer)
				{
					if (glxAudioOutput.Type==GLX_G3D)
					{
						if (glxAudioOutput.Listener)
						{
							free(glxAudioOutput.Listener);
							glxAudioOutput.Listener=NULL;
						}
					}
					if (glxAudioOutput.Type==GLX_A3D)
					{
						if (glxAudioOutput.Listener)
						{
							IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
							glxAudioOutput.Listener=NULL;
						}
						IA3d_Release((LPIA3D)glxAudioOutput.Extensions);
						glxAudioOutput.Extensions=NULL;
					}
					if (glxAudioOutput.Type==GLX_EAX)
					{
						if (glxAudioOutput.Listener)
						{
							IDirectSound3DListener_Release((LPDIRECTSOUND3DLISTENER)glxAudioOutput.Listener);
							glxAudioOutput.Listener=NULL;
						}
						EAXRelease((LPKSPROPERTYSET)glxAudioOutput.Extensions);
						glxAudioOutput.Extensions=NULL;
					}
					if (glxAudioOutput.Type==GLX_A3D2)
					{
						if (glxAudioOutput.Listener)
						{
							((LPA3DLISTENER)glxAudioOutput.Listener)->lpVtbl->Release((LPA3DLISTENER)glxAudioOutput.Listener);
							glxAudioOutput.Listener=NULL;
						}
						((LPA3D4)glxAudioOutput.Extensions)->lpVtbl->Release((LPA3D4)glxAudioOutput.Extensions);
						glxAudioOutput.Extensions=NULL;
					}
					IDirectSoundBuffer_Release((LPDIRECTSOUNDBUFFER)glxAudioOutput.Mixer);
  					glxAudioOutput.Mixer=NULL;
				}
				IDirectSound_Release((LPDIRECTSOUND)glxAudioOutput.Handle);
				glxAudioOutput.Handle=NULL;
			}
		}
		if (glxAudioOutput.Driver==GLX_WAVEDRIVER)
		{
			/* Stop Multimedia driver */
			if ((HWAVEOUT)glxAudioOutput.Handle)
			{
				waveOutReset((HWAVEOUT)glxAudioOutput.Handle);
				if ((LPWAVEHDR)glxAudioBuffer.Handle)
				{
					waveOutUnprepareHeader((HWAVEOUT)glxAudioOutput.Handle,(LPWAVEHDR)glxAudioBuffer.Handle,sizeof(WAVEHDR));
					free((LPWAVEHDR)glxAudioBuffer.Handle);
					glxAudioBuffer.Handle=NULL;
				}
				if ((glxVector *)glxAudioOutput.Listener)
				{
					free((glxVector *)glxAudioOutput.Listener);
					glxAudioOutput.Listener=NULL;
				}
				waveOutClose((HWAVEOUT)glxAudioOutput.Handle);
				glxAudioOutput.Handle=NULL;
			}
		}
		/* Reset Driver ID string */
		glxDriverID=NULL;
		glxUnlock();
		return GLXERR_NOERROR;
	}
	return GLXERR_OUTPUTNOTACTIVE;
}

int __cdecl glxUnlock(void)
{
	LeaveCriticalSection(&glxWorking);
	return GLXERR_NOERROR;
}
