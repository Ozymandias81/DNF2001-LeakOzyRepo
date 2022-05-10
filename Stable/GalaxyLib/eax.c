#define PSET_SETGET (KSPROPERTY_SUPPORT_GET|KSPROPERTY_SUPPORT_SET)

// local small buffer
static LPDIRECTSOUNDBUFFER pBuffer=NULL;    // dummy DS buffer

// Some local prototypes
static unsigned long CalcEAXEnvironment(double roomSize);
static float CalcEAXVolume(double volume);
static float CalcEAXDecayTime(double decayTime);
static float CalcEAXDamping(double lpfCoefficient, double apfGain);

//---------------------------------------------------------------------------//
//
//   EAXCreate
//
//   DESCRIPTION:
//       Opens an EAX environment if one's available
//
//   PARAMETERS:
//	      pDS: direct sound object
//
//   RETURNS:
//       EAX object pointer, NULL if none could be found
//---------------------------------------------------------------------------//
static LPKSPROPERTYSET EAXCreate(LPDIRECTSOUND pDS)
   {
   WAVEFORMATEX fmt={WAVE_FORMAT_PCM,2,44100,176400,4,16,0};  // for dummy 3D buffer
   DSBUFFERDESC desc;
   LPDIRECTSOUND3DBUFFER p3DBuf;                // 3D buffer interface
   LPKSPROPERTYSET pEAX;                        // property set interface
   unsigned long support=0;                     // variable to hold support status

   //create a dummy buffer
   memset(&desc, 0, sizeof(DSBUFFERDESC));
   desc.dwSize = sizeof(DSBUFFERDESC);
   desc.dwFlags = DSBCAPS_STATIC | DSBCAPS_CTRL3D;
   desc.dwBufferBytes = 128;
   desc.lpwfxFormat = &fmt;
   if (IDirectSound_CreateSoundBuffer(pDS,&desc,&pBuffer,NULL) != DS_OK)
      return NULL;

   // Create a 3D buffer interface
   if (IDirectSoundBuffer_QueryInterface(pBuffer,&IID_IDirectSound3DBuffer,&p3DBuf) != DS_OK
      || IDirectSound3DBuffer_QueryInterface(p3DBuf,&IID_IKsPropertySet,&pEAX) != DS_OK)
      {
      IDirectSoundBuffer_Release(pBuffer);
      pBuffer=NULL;
      return NULL;
      }

   // Create the EAX reverb interface
   if (IKsPropertySet_QuerySupport(pEAX,&DSPROPSETID_EAX_ReverbProperties,DSPROPERTY_EAX_ALL,&support) != DS_OK
      || (support & PSET_SETGET) != PSET_SETGET)
      {
      IDirectSoundBuffer_Release(pBuffer);
      pBuffer=NULL;
      pEAX=NULL;
      }

   return pEAX;
   }

//---------------------------------------------------------------------------//
//
//   EAXRelease
//
//   DESCRIPTION:
//       Closes an EAX environment
//
//   PARAMETERS:
//	     pEAX: EAX object
//
//   RETURNS:
//       EAX object pointer, NULL if none could be found
//---------------------------------------------------------------------------//
static void EAXRelease(LPKSPROPERTYSET pEAX)
   {
   if (pEAX)
      IKsPropertySet_Release(pEAX);
   if (pBuffer)
      {
      IDirectSoundBuffer_Release(pBuffer);
      pBuffer=NULL;
      }
   }

//---------------------------------------------------------------------------//
//
//   EAXSet
//
//   DESCRIPTION:
//       Sets the EAX parameters
//
//   PARAMETERS:
//	 pEAX: EAX property set interface
//	 roomSize: size of room, normal range 0 to 2.8
//	 volume: range 0 to 1.0
//	 decayTime: T60 decay time in seconds.
//       lpfCoefficient: the Coefficient of Carlo's 1 pole LPF (range 0-1)
//	 apfGain: gain of an all-pass containing the LPF (range 0-1)
//
//   RETURNS:
//       Nothing
//---------------------------------------------------------------------------//
static void EAXSet(LPKSPROPERTYSET pEAX, double roomSize, double volume,
            double decayTime, double lpfCoefficient, double apfGain)
   {
   EAX_REVERBPROPERTIES props;

   // check for valid buffer
   if (!pBuffer)
      return;

   // translate the properties
   props.environment=CalcEAXEnvironment(roomSize);
   props.fVolume=CalcEAXVolume(volume);
   props.fDecayTime_sec=CalcEAXDecayTime(decayTime);
   props.fDamping=CalcEAXDamping(lpfCoefficient, apfGain);

   // Set the EAX parameters
   IKsPropertySet_Set(pEAX,&DSPROPSETID_EAX_ReverbProperties,
                      DSPROPERTY_EAX_ALL,NULL,0,
                      &props,sizeof(EAX_REVERBPROPERTIES));
   }

//---------------------------------------------------------------------------//
//
//   CalcEAXEnvironment
//
//   DESCRIPTION:
//       Calculates an EAX environment from a room size
//
//   PARAMETERS:
//	 roomSize: size of room, normal range 0 to 2.8
//
//   RETURNS:
//       EAX environment
//---------------------------------------------------------------------------//
static unsigned long CalcEAXEnvironment(double roomSize)
   {
   unsigned long environment;

   if (roomSize<0.4)
      environment = EAX_ENVIRONMENT_BATHROOM;
   else if (roomSize<0.8)
      environment = EAX_ENVIRONMENT_HALLWAY;
   else if (roomSize<1.2)
      environment = EAX_ENVIRONMENT_STONEROOM;
   else if (roomSize<1.6)
      environment = EAX_ENVIRONMENT_CAVE;
   else if (roomSize<2.0)
      environment = EAX_ENVIRONMENT_ARENA;
   else if (roomSize<2.4)
      environment = EAX_ENVIRONMENT_AUDITORIUM;
   else
      environment = EAX_ENVIRONMENT_QUARRY;
   return environment;
   }

//---------------------------------------------------------------------------//
//
//   CalcEAXVolume
//
//   DESCRIPTION:
//       Calculates an EAX volume from Carlo's volume
//
//   PARAMETERS:
//	 volume: range 0 to 1.0
//
//    RETURNS:
//       EAX volume
//---------------------------------------------------------------------------//
static float CalcEAXVolume(double volume)
   {
   if (volume < 0.0)
      volume=0.0;
   else if (volume > 1.0)
      volume=1.0;
   return (float)volume;
   }

//---------------------------------------------------------------------------//
//
//   CalcEAXDecayTime
//
//   DESCRIPTION:
//       Calculates an EAX Decay Time from Carlo's T60 decay time
//
//   PARAMETERS:
//	 decayTime: T60 decay time in seconds.
//
//    RETURNS:
//       EAX volume
//---------------------------------------------------------------------------//
static float CalcEAXDecayTime(double decayTime)
   {
   if (decayTime < 0.1)
      decayTime = 0.1;
   else if (decayTime > 20.0)
      decayTime = 20.0;
   return (float)decayTime;
   }

//---------------------------------------------------------------------------//
//
//   CalcEAXDamping
//
//   DESCRIPTION:
//       Calculates an EAX Decay Time.
//
//   PARAMETERS:
//       lpfCoefficient: the Coefficient of Carlo's 1 pole LPF (range 0-1)
//	 apfGain: gain of an all-pass containing the LPF (range 0-1)
//
//    RETURNS:
//       EAX Damping parameter
//---------------------------------------------------------------------------//
static float CalcEAXDamping(double lpfCoefficient, double apfGain)
   {
   double d;
   double dmin=0.0000001;

   if (lpfCoefficient < dmin)
      lpfCoefficient = dmin;
   else if (lpfCoefficient > 1.0)
      lpfCoefficient = 1.0;
   if (apfGain < dmin)
      apfGain = dmin;
   else if (apfGain > 1.0)
      apfGain = 1.0;
   d = apfGain * lpfCoefficient / (2.0 - lpfCoefficient);
   d = log(apfGain)/log(d);
   if (d < 0.0)
      d = 0.0;
   else if (d > 1.0)
      d = 1.0;
   return (float)d;
   }
