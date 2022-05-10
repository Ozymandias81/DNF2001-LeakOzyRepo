/*=============================================================================
	UnAudio.cpp: Unreal base audio.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney
	* Wave modification code by Erik de Neve
=============================================================================*/

#include "EnginePrivate.h" 

/*-----------------------------------------------------------------------------
	USound implementation.
-----------------------------------------------------------------------------*/

#pragma DISABLE_OPTIMIZATION
void FSoundData::Load()
{
	UBOOL Loaded = SavedPos>0;

	TLazyArray<BYTE>::Load();

	if( Loaded )
	{
		// Calculate our duration.
		Owner->Duration = GetPeriod();

		// Derive these from the exposed 'low quality' preference setting.
		INT Force8Bit = 0;
		INT ForceHalve = 0;
		if( Owner->Audio && Owner->Audio->GetLowQualitySetting() && !GIsEditor )
		{
			Force8Bit = 1;
			ForceHalve = 1;
		}

		// Frequencies below this sample rate will NOT be downsampled.
		DWORD FreqThreshold = 22050;

		// Reduce sound frequency and/or bit depth if required.
		if( Force8Bit || ForceHalve )
		{		
			// If ReadWaveInfo returns true, all relevant Wave chunks were found and 
			// all pointers in the WaveInfo structure have been successfully initialized.			
			FWaveModInfo WaveInfo;
			if( WaveInfo.ReadWaveInfo(*this) && WaveInfo.SampleDataSize>4  ) 
			{				
				// Three main conversions:
				// * Halving the frequency -> simple 0.25, 0.50, 0.25 kernel. 
				// * Reducing bit-depth 8->16  
				// * Both in one sweep.  
				//
				// Important: Wave data ALWAYS padded to use 16-bit alignment even
				// though the number of bytes in pWaveDataSize may be odd.	
				UBOOL ReduceBits = ((Force8Bit) && (*WaveInfo.pBitsPerSample == 16));
				UBOOL ReduceFreq = ((ForceHalve) && (*WaveInfo.pSamplesPerSec >= FreqThreshold));
				if( ReduceBits && ReduceFreq )
				{
					// Convert 16-bit sample to 8 bit and halve the frequency too.
					WaveInfo.HalveReduce16to8();
				}
				else if (ReduceBits && (!ReduceFreq))
				{	
					// Convert 16-bit sample down to 8-bit.
					WaveInfo.Reduce16to8();
				}
				else if( ReduceFreq )
				{
					// Just halve the frequency. Separate cases for 16 and 8 bits.
					WaveInfo.HalveData();
				}
				WaveInfo.UpdateWaveData( *this );
			}
		}

		// Register it.
		Owner->OriginalSize = Num();
		if( Owner->Audio && !GIsEditor )
			Owner->Audio->RegisterSound( Owner );
	}
}

FLOAT FSoundData::GetPeriod()
{
	// Ensure the data is present.
	TLazyArray<BYTE>::Load();
	// Calculate the sound's duration.
	FLOAT Period = 0.0f;
	FWaveModInfo WaveInfo;
	if( WaveInfo.ReadWaveInfo(*this) )
	{
		#define DEFAULT_FREQUENCY (22050)
		INT SPS = *WaveInfo.pSamplesPerSec;
		if (! SPS) SPS = DEFAULT_FREQUENCY;
		INT DurDiv =  *WaveInfo.pChannels * *WaveInfo.pBitsPerSample  * *WaveInfo.pSamplesPerSec;  
		if ( DurDiv ) Period = *WaveInfo.pWaveDataSize * 8.f / (FLOAT)DurDiv;
//		debugf(TEXT("Name %19s pChannels %9i pBitsps %9i pSampPs %9i pWaveDataSize %9i Time %9f"),Owner->GetName(),*WaveInfo.pChannels,*WaveInfo.pBitsPerSample,*WaveInfo.pSamplesPerSec,*WaveInfo.pWaveDataSize, Period );
	}	
	return Period;
}

FLOAT USound::GetDuration()
{
	if ( Duration <= 0.f )
		Duration = Data.GetPeriod();
	return Duration;
};

void USound::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << FileType;
	if( Ar.IsLoading() || Ar.IsSaving() )
	{
		Ar << Data;
	}
	else Ar.CountBytes( OriginalSize, OriginalSize );
}

void USound::Destroy()
{
	if( Audio )
		Audio->UnregisterSound( this );
	Super::Destroy();
}

void USound::PostLoad()
{
	Super::PostLoad();
}
UAudioSubsystem* USound::Audio;
IMPLEMENT_CLASS(USound);

// CDH... VoiceSound implementation
IMPLEMENT_CLASS(UVoiceSound);
// ...CDH

/*-----------------------------------------------------------------------------
	WaveModInfo implementation - downsampling of wave files.
-----------------------------------------------------------------------------*/

//
//	Figure out the WAVE file layout.
//
UBOOL FWaveModInfo::ReadWaveInfo( TArray<BYTE>& WavData )
{
	FFormatChunk* FmtChunk;
	FRiffWaveHeader* RiffHdr = (FRiffWaveHeader*)&WavData(0);
	pWaveDataEnd = &WavData(0) + WavData.Num();	
	
	// Verify we've got a real 'WAVE' header.
	if( RiffHdr->wID != ( mmioFOURCC('W','A','V','E') )  )
		return 0;

	pMasterSize = &RiffHdr->ChunkLen;

	FRiffChunkOld* RiffChunk = (FRiffChunkOld*)&WavData(3*4);

	BYTE cChunkToFind[8] = "fmt ";

	// Chunk found ?
	if( !FindChunk( RiffChunk, cChunkToFind ) )
		return 0;

	FmtChunk = (FFormatChunk*)((BYTE*)RiffChunk + 8);
	pBitsPerSample  = &FmtChunk->wBitsPerSample;
	pSamplesPerSec  = &FmtChunk->nSamplesPerSec;
	pAvgBytesPerSec = &FmtChunk->nAvgBytesPerSec;
	pBlockAlign		= &FmtChunk->nBlockAlign;
	pChannels       = &FmtChunk->nChannels;

	// re-initalize the RiffChunk pointer
	RiffChunk = (FRiffChunkOld*)&WavData(3*4);
	// Look for the 'data' chunk.
	cChunkToFind[0] = 'd';
	cChunkToFind[1] = 'a';
	cChunkToFind[2] = 't';
	cChunkToFind[3] = 'a';

	// Chunk found ?
	if( !FindChunk( RiffChunk, cChunkToFind ) )
		return 0;

	pSampleDataStart	= (BYTE*)RiffChunk + 8;
	pWaveDataSize		= &RiffChunk->ChunkLen;
	SampleDataSize		=  RiffChunk->ChunkLen;
	OldBitsPerSample	= FmtChunk->wBitsPerSample;
	pSampleDataEnd		=  pSampleDataStart+SampleDataSize;

	NewDataSize	= SampleDataSize;

	// Re-initalize the RiffChunk pointer
	RiffChunk = (FRiffChunkOld*)&WavData(3*4);
	// Look for a 'smpl' chunk.
	cChunkToFind[0] = 's';
	cChunkToFind[1] = 'm';
	cChunkToFind[2] = 'p';
	cChunkToFind[3] = 'l';

	// Chunk found ? smpl chunk is optional.
	// Find the first sample-loop structure, and the total number of them.
	if( FindChunk( RiffChunk, cChunkToFind ) )
	{
		FSampleChunk* pSampleChunk =  (FSampleChunk*)( (BYTE*)RiffChunk + 8);
		SampleLoopsNum  = pSampleChunk->cSampleLoops; // Number of tSampleLoop structures.
		// First tSampleLoop structure starts right after the tSampleChunk.
		pSampleLoop = (FSampleLoop*) ((BYTE*)pSampleChunk + sizeof(FSampleChunk)); 
	}

	return 1;
}


UBOOL FWaveModInfo::FindChunk( const FRiffChunkOld*& pRiffChunk, const BYTE cChunkToFind[])
{
	//Instead of adding 8 bytes to the RiffChunk ptr, make a sentinel ptr before hand
	const SIZE_T szSizeOfFRiffChunkHeader = sizeof(FRiffChunkOld);
	const BYTE* const pbyteSentinel = pWaveDataEnd - szSizeOfFRiffChunkHeader;
	const DWORD fourccOfChunkToFind = mmioFOURCC(	cChunkToFind[0],
													cChunkToFind[1],
													cChunkToFind[2],
													cChunkToFind[3]
	);	//TLW: Should be of type FOURCC, but is too problematic to get to compile right

	BYTE* pbyteRiffChunkIterator = (BYTE*) pRiffChunk;

	// Look for the chunk labeled cChunkToFind.
	while( pbyteRiffChunkIterator < pbyteSentinel)  
	{
		if( pRiffChunk->ChunkID == fourccOfChunkToFind )
			return 1;	//TRUE;

		// Go to next chunk.
		pbyteRiffChunkIterator = &(
			pbyteRiffChunkIterator[szSizeOfFRiffChunkHeader + Pad16Bit(pRiffChunk->ChunkLen)]
		);
		pRiffChunk = (FRiffChunkOld*) (pbyteRiffChunkIterator); 
	}

	//else, not found
	return 0;	//FALSE;
}

//
// Update internal variables and shrink the data fields.
//
UBOOL FWaveModInfo::UpdateWaveData( TArray<BYTE>& WavData )
{
	if( NewDataSize < SampleDataSize )
	{		
		// Shrinkage of data chunk in bytes -> chunk data must always remain 16-bit-padded.
		INT ChunkShrinkage = Pad16Bit(SampleDataSize)  - Pad16Bit(NewDataSize);

		// Update sizes.
		*pWaveDataSize  = NewDataSize;
		*pMasterSize   -= ChunkShrinkage;

		// Refresh all wave parameters depending on bit depth and/or sample rate.
		*pBlockAlign    =  *pChannels * (*pBitsPerSample >> 3); // channels * Bytes per sample
		*pAvgBytesPerSec = *pBlockAlign * *pSamplesPerSec; //sample rate * Block align

		// Update 'smpl' chunk data also, if present.
		if (SampleLoopsNum)
		{
			FSampleLoop* pTempSampleLoop = pSampleLoop;
			INT SampleDivisor = ( (SampleDataSize *  *pBitsPerSample) / (NewDataSize ) );
			for (INT SL = 0; SL<SampleLoopsNum; SL++)
			{
				pTempSampleLoop->dwStart = pTempSampleLoop->dwStart  * OldBitsPerSample / SampleDivisor;
				pTempSampleLoop->dwEnd   = pTempSampleLoop->dwEnd  * OldBitsPerSample / SampleDivisor;
				pTempSampleLoop++; // Next TempSampleLoop structure.
			}	
		}		
			
		// Now shuffle back all data after wave data by SampleDataSize/2 (+ padding) bytes 
		// INT SampleShrinkage = ( SampleDataSize/4) * 2;
		BYTE* NewWaveDataEnd = pSampleDataEnd - ChunkShrinkage;

		for ( INT pt = 0; pt< ( pWaveDataEnd -  pSampleDataEnd); pt++ )
		{ 
			NewWaveDataEnd[pt] =  pSampleDataEnd[pt];
		}			

		// Resize the dynamic array.
		WavData.Remove( WavData.Num() - ChunkShrinkage, ChunkShrinkage );
		
		/*
		static INT SavedBytes = 0;
		SavedBytes += ChunkShrinkage;
		debugf(NAME_Log," Audio shrunk by: %i bytes, total savings %i bytes.",ChunkShrinkage,SavedBytes);
		debugf(NAME_Log," New BitsPerSample: %i ", *pBitsPerSample);
		debugf(NAME_Log," New SamplesPerSec: %i ", *pSamplesPerSec);
		debugf(NAME_Log," Olddata/NEW*wav* sizes: %i %i ", SampleDataSize, *pMasterSize);
		*/
	}

	// Noise gate filtering assumes 8-bit sound.
	// Warning: While very useful on SOME sounds, it erased too many low-volume sound fx
	// in its current form - even when 'noise' level scaled to average sound amplitude.
	// if (NoiseGate) NoiseGateFilter();

	return 1;
}

//
// Reduce bit depth and halve the number of samples simultaneously.
//
void FWaveModInfo::HalveReduce16to8()
{
	DWORD SampleWords =  SampleDataSize >> 1;
	INT OrigValue,NewValue;
	INT ErrorDiff = 0;

	DWORD SampleBytes = SampleWords >> 1;

	INT NextSample0 = (INT)((SWORD*) pSampleDataStart)[0];
	INT NextSample1,NextSample2;

	BYTE* SampleData =  pSampleDataStart;
	for (DWORD T=0; T<SampleBytes; T++)
	{
		NextSample1 = (INT)((SWORD*)SampleData)[T*2];
		NextSample2 = (INT)((SWORD*)SampleData)[T*2+1];
		INT Filtered16BitSample = 32768*4 + NextSample0 + NextSample1 + NextSample1 + NextSample2;
		NextSample0 = NextSample2;

		// Error diffusion works in '18 bit' resolution.
		OrigValue = ErrorDiff + Filtered16BitSample;
		// Rounding: "+0.5"
		NewValue  = (OrigValue + 512) & 0xfffffc00;
		if (NewValue > 0x3fc00) NewValue = 0x3fc00;

		INT NewSample = NewValue >> (8+2);
		SampleData[T] = (BYTE)NewSample;	// Output byte.

		ErrorDiff = OrigValue - NewValue;   // Error cycles back into input.
	}

	NewDataSize = SampleBytes;

	*pBitsPerSample  = 8;
	*pSamplesPerSec  = *pSamplesPerSec >> 1;

	NoiseGate = true;
}

//
// Reduce bit depth.
//
void FWaveModInfo::Reduce16to8()
{
	DWORD SampleBytes =  SampleDataSize >> 1;
	INT OrigValue,NewValue;
	INT ErrorDiff = 0;
	BYTE* SampleData = pSampleDataStart;

	for (DWORD T=0; T<SampleBytes; T++)
	{
		// Error diffusion works in 16 bit resolution.
		OrigValue = ErrorDiff + 32768 + (INT)((SWORD*)SampleData)[T];
		// Rounding: '+0.5', then mask off low 2 bits.
		NewValue  = (OrigValue + 127 ) & 0xffffff00;  // + 128
		if (NewValue > 0xff00) NewValue = 0xff00;

		INT NewSample = NewValue >> 8;
		SampleData[T] = NewSample;

		ErrorDiff = OrigValue - NewValue;  // Error cycles back into input.
	}				

	NewDataSize = SampleBytes;
	*pBitsPerSample  = 8;
	NoiseGate = true;
}

//
// Halve the number of samples.
//
void FWaveModInfo::HalveData()
{
	if( *pBitsPerSample == 16)
	{						
		DWORD SampleWords =  SampleDataSize >> 1;
		INT OrigValue,NewValue;
		INT ErrorDiff = 0;

		DWORD ScaledSampleWords = SampleWords >> 1; 

		INT NextSample0 = (INT)((SWORD*) pSampleDataStart)[0];
		INT NextSample1, NextSample2;

		BYTE* SampleData =  pSampleDataStart;
		for (DWORD T=0; T<ScaledSampleWords; T++)
		{
			NextSample1 = (INT)((SWORD*)SampleData)[T*2];
			NextSample2 = (INT)((SWORD*)SampleData)[T*2+1];
			INT Filtered18BitSample = 32768*4 + NextSample0 + NextSample1 + NextSample1 + NextSample2;
			NextSample0 = NextSample2;

			// Error diffusion works with '18 bit' resolution.
			OrigValue = ErrorDiff + Filtered18BitSample;
			// Rounding: '+0.5', then mask off low 2 bits.
			NewValue  = (OrigValue + 2) & 0x3fffc;
			if (NewValue > 0x3fffc) NewValue = 0x3fffc;
			((SWORD*)SampleData)[T] = (NewValue >> 2) - 32768;  // Output SWORD.
			ErrorDiff = OrigValue - NewValue; // Error cycles back into input.
		}				
		NewDataSize = (ScaledSampleWords * 2);
		*pSamplesPerSec  = *pSamplesPerSec >> 1;
	}
	else if( *pBitsPerSample == 8 )
	{									
		INT OrigValue,NewValue;
		INT ErrorDiff = 0;
	
		DWORD SampleBytes = SampleDataSize >> 1;  
		BYTE* SampleData = pSampleDataStart;

		INT NextSample0 = SampleData[0];
		INT NextSample1, NextSample2;

		for (DWORD T=0; T<SampleBytes; T++)
		{
			NextSample1 =  SampleData[T*2];
			NextSample2 =  SampleData[T*2+1];
			INT Filtered10BitSample =  NextSample0 + NextSample1 + NextSample1 + NextSample2;
			NextSample0 =  NextSample2;

			// Error diffusion works with '10 bit' resolution.
			OrigValue = ErrorDiff + Filtered10BitSample;
			// Rounding: '+0.5', then mask off low 2 bits.
			NewValue  = (OrigValue + 2) & 0x3fc;
			if (NewValue > 0x3fc) NewValue = 0x3fc;
			SampleData[T] = (BYTE)(NewValue >> 2);	// Output BYTE.
			ErrorDiff = OrigValue - NewValue;		// Error cycles back into input.
		}				
		NewDataSize = SampleBytes; 
		*pSamplesPerSec  = *pSamplesPerSec >> 1;
	}
}

//
//	Noise gate filter. Hard to make general-purpose without hacking up some (soft) sounds.
//
void FWaveModInfo::NoiseGateFilter()
{
	BYTE* SampleData  =  pSampleDataStart;
	INT   SampleBytes = *pWaveDataSize; 
	INT	  MinBlankSize = 860 * ((*pSamplesPerSec)/11025); // 600-800...

	// Threshold sound amplitude. About 18 seems OK.
	INT Amplitude	 = 18;

	// Ignore any over-threshold signals if under this size. ( 32 ?)
	INT GlitchSize	 = 32 * ((*pSamplesPerSec)/11025);
	INT StartSilence =  0;
	INT EndSilence	 =  0;
	INT LastErased   = -1;

	for( INT T = 0; T< SampleBytes; T++ )
	{
		UBOOL Loud;
		if	( Abs(SampleData[T]-128) >= Amplitude )
		{
			Loud = true;							
			if (StartSilence > 0)
			{
				if ( (T-StartSilence) < GlitchSize ) Loud = false;
			}							
		}
		else Loud = false;

		if( StartSilence == 0 )
		{
			if( !Loud )
				StartSilence = T;
		}
		else
		{													
			if( ((EndSilence == 0) && (Loud)) || (T ==(SampleBytes-1) ) )
			{
				EndSilence = T;
				//
				// Erase an area of low-amplitude sound ( noise... ) if size >= MinBlankSize.
				//
				// Todo: try erasing smoothly - decay, create some attack, 
				// proportional to the size of the area. ?
				//
				if	(( EndSilence - StartSilence) >= MinBlankSize )
				{					
					for ( INT Er = StartSilence; Er< EndSilence; Er++ )
					{
						SampleData[Er] = 128;
					}
				}
				LastErased = EndSilence-1;
				StartSilence = 0;
				EndSilence   = 0;
			}
		}										
	}
}

/*-----------------------------------------------------------------------------
	UMusic implementation.
-----------------------------------------------------------------------------*/

void UMusic::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << FileType;
	if( Ar.IsLoading() || Ar.IsSaving() )
	{
		Ar << Data;
		if( Ar.IsLoading() )
			OriginalSize = Data.Num();
	}
	else Ar.CountBytes( OriginalSize, OriginalSize );
}
void UMusic::Destroy()
{
	if( Audio )
		Audio->UnregisterMusic( this );
	Super::Destroy();
}
void UMusic::PostLoad()
{
	Super::PostLoad();
}
UAudioSubsystem* UMusic::Audio;
IMPLEMENT_CLASS(UMusic);

/*-----------------------------------------------------------------------------
	UAudioSubsystem implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UAudioSubsystem);


/*-----------------------------------------------------------------------------
	Miles Music Interface.
-----------------------------------------------------------------------------*/
void AActor::execMusicPlay(FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Filename);
	P_GET_UBOOL_OPTX(Instant,0);
	P_GET_FLOAT_OPTX(CrossfadeTime,0.0f);
	P_GET_UBOOL_OPTX(Push,0);
	P_FINISH;

	UAudioSubsystem *Audio=GetLevel()->Engine->Audio;
	if(!Audio) 
	{
		GetLevel()->Engine->InitAudio();
		Audio=GetLevel()->Engine->Audio;

	}
	if(Audio) 
		GetLevel()->Engine->Audio->MusicPlay((TCHAR *)*(GetLevel()->GetLevelInfo()->Mp3Prefix),(TCHAR *)*Filename,Instant,CrossfadeTime,Push);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
