/*=============================================================================
    UnSpan.cpp: DukeForever span buffering functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

#define UPDATE_PREVLINK(START,END)\
	TopSpan         = New<FSpan>(*Mem,1,4);\
    *PrevLink       = TopSpan;\
    TopSpan->Start  = START;\
    TopSpan->End    = END;\
    PrevLink        = &TopSpan->Next;\
    ValidLines++;

#define UPDATE_PREVLINK_ALLOC(START,END)\
    NewSpan         = New<FSpan>(*Mem,1,4);\
    *PrevLink       = NewSpan;\
    NewSpan->Start  = START;\
    NewSpan->End    = END;\
    PrevLink        = &(NewSpan->Next);\
    ValidLines++;

/*-----------------------------------------------------------------------------
    Allocation.
-----------------------------------------------------------------------------*/


//
// Compute's a span buffer's valid range StartY-EndY range.
// Sets to 0,0 if the span is entirely empty.  You can also detect
// this condition by comparing ValidLines to 0.
//
void __fastcall FSpanBuffer::GetValidRange( SWORD* ValidStartY, SWORD* ValidEndY )
{
    if( ValidLines )
    {
        FSpan **TempIndex;
        int NewStartY,NewEndY;

        NewStartY = StartY;
        TempIndex = &Index [0];
        while( *TempIndex==NULL )
		{
			TempIndex++;
			NewStartY++;
		}

        NewEndY   = EndY;
        TempIndex = &Index [EndY-StartY-1];
        while( *TempIndex==NULL )
		{
			TempIndex--;
			NewEndY--;
		}

        *ValidStartY = NewStartY;
        *ValidEndY   = NewEndY;
	}
    else *ValidStartY = *ValidEndY = 0;
}



//
// Grind this polygon through the span buffer and:
// - See if the poly is totally occluded
// - Build a new, temporary span buffer for raster and span clipping the poly
//
// Doesn't affect the span buffer no matter what.
// Returns 1 if poly is all or partially visible, 0 if completely obscured.
//
INT __fastcall FSpanBuffer::CopyFromRaster( FSpanBuffer& Screen, INT RasterStartY, INT RasterEndY, FRasterSpan* Raster )
{

    FRasterSpan *Line;
    FSpan       **ScreenIndex,*ScreenSpan;
    FSpan       **TempIndex,**PrevLink,*NewSpan;
	int			i,OurStart,OurEnd,Accept=0;

    OurStart = Max(RasterStartY,Screen.StartY);
    OurEnd   = Min(RasterEndY,Screen.EndY);

 	TempIndex = &Index [0];

    // Extra check for OurStart>OurEnd = screen and rasterpoly don't overlap, so all-null output.
    if( OurStart>=OurEnd )
    {
    	for( i=StartY; i<EndY; i++ )
			*(TempIndex++) = NULL;
        return 0;
    }

    for( i=StartY; i<OurStart; i++ )
		*(TempIndex++) = NULL;

    Line        = Raster + OurStart - RasterStartY;
    ScreenIndex = Screen.Index + OurStart - Screen.StartY;

	INT LineX0=0,
		LineX1=0;

    for( i=OurStart; 
	     i<OurEnd; 
		 i++,*PrevLink=NULL,Line++
	   )
    {
        ScreenSpan      = *(ScreenIndex++);
        PrevLink        = TempIndex++;

		LineX0=Line->X[0];
		LineX1=Line->X[1];
        if( !ScreenSpan || LineX1 <= LineX0 )
			// This span is already full, or raster is empty.
			continue; 

        // Skip past all spans that occur before the raster.
        while( ScreenSpan->End <= LineX0 )
        {
            ScreenSpan = ScreenSpan->Next;
            if( !ScreenSpan )
				// This line is full.
				goto NextLine;
        }

        //checkSlow(ScreenSpan->End > LineX0);

        // See if this span straddles the raster's starting point.
        if( ScreenSpan->Start < LineX0 )
        {
            Accept = 1;

            // Add partial chunk to temporary span buffer.
            UPDATE_PREVLINK_ALLOC(LineX0,Min(LineX1, ScreenSpan->End));
            ScreenSpan = ScreenSpan->Next;
            if( !ScreenSpan )
				continue;
        }

        //checkSlow(ScreenSpan->Start >= LineX0);

        // Process all spans that are entirely within the raster.
        while( ScreenSpan->End <= LineX1 )
        {
            Accept = 1;

            // Add entire chunk to temporary span buffer.
            UPDATE_PREVLINK_ALLOC(ScreenSpan->Start,ScreenSpan->End);
            ScreenSpan = ScreenSpan->Next;
            if( !ScreenSpan )
				goto NextLine;
        }

        //checkSlow(ScreenSpan->End > LineX1);

        // If span overlaps raster's end point, process the partial chunk.
        if( ScreenSpan->Start < LineX1 )
        {
            // Add chunk from Span->Start to Line->End.X to temp span buffer.
            Accept = 1;
            UPDATE_PREVLINK_ALLOC(ScreenSpan->Start,LineX1);
        }
        NextLine:;
    }
    for( i=OurEnd; i<EndY; i++ )
		*(TempIndex++) = NULL;

    return Accept;
}

/*-----------------------------------------------------------------------------
    Merging.
-----------------------------------------------------------------------------*/

//
// Macro for copying a span.
//
/* NJS: now unused
#define COPY_SPAN(SRC_INDEX)\
{\
    PrevLink         = DestIndex++;\
    Span             = *(SRC_INDEX++);\
    while( Span )\
    {\
        UPDATE_PREVLINK(Span->Start,Span->End);\
        Span = Span->Next;\
    }\
    *PrevLink = NULL;\
}
*/
//
// Merge this existing span buffer with another span buffer.  Overwrites the appropriate
// parts of this span buffer.  If this span buffer's index isn't large enough
// to hold everything, reallocates the index.
//
// This is meant to be called with this span buffer using GDynMem and the other span
// buffer using GMem.
//
// Status: This is currently unused and doesn't need to be optimized.
//
void __fastcall FSpanBuffer::MergeWith( const FSpanBuffer& Other )
{

    // See if the existing span's index is large enough to hold the merged result.
    if( Other.StartY<StartY || Other.EndY>EndY )
    {
		// Must reallocate and copy index.
        int NewStartY = Min(StartY,Other.StartY);
        int NewEndY   = Max(EndY,  Other.EndY);
        int NewNum    = NewEndY - NewStartY;
        FSpan **NewIndex = New<FSpan*>(*Mem,NewNum);

        appMemzero(&NewIndex[0                    ],      (StartY-NewStartY)*sizeof(FSpan *));
        appMemcpy (&NewIndex[StartY-NewStartY     ],Index,(EndY     -StartY)*sizeof(FSpan *));
        appMemzero(&NewIndex[NewNum-(NewEndY-EndY)],      (NewEndY  -EndY  )*sizeof(FSpan *));

        StartY = NewStartY;
        EndY   = NewEndY;
        Index  = NewIndex;
    }

    // Now merge other span into this one.
    FSpan **ThisIndex  = &Index       [Other.StartY - StartY];
    FSpan **OtherIndex = &Other.Index [0];
    FSpan *ThisSpan,*OtherSpan,*TempSpan,**PrevLink;
    for( int i=Other.StartY; i<Other.EndY; i++ )
    {
        PrevLink    = ThisIndex;
        ThisSpan    = *(ThisIndex++);
        OtherSpan   = *(OtherIndex++);

        // Do everything relative to ThisSpan.
        while( ThisSpan && OtherSpan )
        {
            if( OtherSpan->End < ThisSpan->Start )
            {
				// Link OtherSpan in completely before ThisSpan.
                *PrevLink = TempSpan= New<FSpan>(*Mem,1,4);
                TempSpan->Start     = OtherSpan->Start;
                TempSpan->End       = OtherSpan->End;
                TempSpan->Next      = ThisSpan;
                PrevLink            = &TempSpan->Next;
                OtherSpan           = OtherSpan->Next;
                ValidLines++;
            }
            else if (OtherSpan->Start <= ThisSpan->End)
            {
				// Merge OtherSpan into ThisSpan.
                *PrevLink           = ThisSpan;
                ThisSpan->Start     = Min(ThisSpan->Start,OtherSpan->Start);
                ThisSpan->End       = Max(ThisSpan->End,  OtherSpan->End);
                TempSpan            = ThisSpan; // For maintaining End and Next.
                PrevLink            = &ThisSpan->Next;
                ThisSpan            = ThisSpan->Next;
                OtherSpan           = OtherSpan->Next;

                for(;;)
                {
                    if( ThisSpan&&(ThisSpan->Start <= TempSpan->End) )
                    {
                        TempSpan->End = Max(ThisSpan->End,TempSpan->End);
                        ThisSpan      = ThisSpan->Next;
                        ValidLines--;
                    }
                    else if( OtherSpan&&(OtherSpan->Start <= TempSpan->End) )
                    {
                        TempSpan->End = Max(TempSpan->End,OtherSpan->End);
                        OtherSpan     = OtherSpan->Next;
                    }
                    else break;
                }
            }
            else
            {
				// This span is entirely before the other span; keep it.
                *PrevLink           = ThisSpan;
                PrevLink            = &ThisSpan->Next;
                ThisSpan            = ThisSpan->Next;
            }
        }

        while( OtherSpan )
        {
			// Just append spans from OtherSpan.
            *PrevLink = TempSpan    = New<FSpan>(*Mem,1,4);
            TempSpan->Start         = OtherSpan->Start;
            TempSpan->End           = OtherSpan->End;
            PrevLink                = &TempSpan->Next;
            OtherSpan               = OtherSpan->Next;
            ValidLines++;
        }
        *PrevLink = ThisSpan;
    }
}

/*-----------------------------------------------------------------------------
    Duplicating.
-----------------------------------------------------------------------------*/

/*
void __fastcall FSpanBuffer::CopyIndexFrom( const FSpanBuffer& Source, FMemStack* Mem )
{
    StartY   = Source.StartY;
    EndY     = Source.EndY;
 
    Index = New<FSpan*>(*Mem,Source.EndY-Source.StartY);
    appMemcpy( &Index[0], &Source.Index[0], (Source.EndY-Source.StartY) * sizeof(FSpan *) );
}
*/

/*
INT __fastcall FSpanBuffer::BoxIsVisible( INT X1, INT Y1, INT X2, INT Y2 )
{
	FSpan **ScreenIndex, *Span;
	if( Y1 >= EndY )    return 0;
	if( Y2 <= StartY )  return 0;
	if (Y1 < StartY)    Y1 = StartY;
	if (Y2 > EndY)      Y2 = EndY;

	// Check box occlusion with span buffer.
	ScreenIndex = &Index [Y1-StartY];
	int Count   = Y2-Y1;

	// Start checking last line, then first and the rest.
	Span = *(ScreenIndex + Count - 1 );
	while( --Count >= 0 )
	{
		for(;Span && X2>Span->Start;Span=Span->Next)
   			if( X1 < Span->End )
    			return 1;

		Span = *ScreenIndex++;
	}
	return 0;
}
*/

/*-----------------------------------------------------------------------------
    Debugging.
-----------------------------------------------------------------------------*/

//
// These debugging functions are available while writing span buffer code.
// They perform various checks to make sure that span buffers don't become
// corrupted.  They don't need optimizing, of course.
//

//
// Make sure that a span buffer is completely empty.
//
void FSpanBuffer::AssertEmpty( TCHAR* Name )
{
    FSpan **TempIndex,*Span;
    int i;

    TempIndex = Index;
    for( i=StartY; i<EndY; i++ )
    {
        Span = *(TempIndex++);
        while (Span!=NULL)
        {
            appErrorf( _T("%s not empty, line=%i<%i>%i, start=%i, end=%i"), Name, StartY, i, EndY, Span->Start, Span->End );
            Span=Span->Next;
        }
    }
}

//
// Assure that a span buffer isn't empty.
//
void FSpanBuffer::AssertNotEmpty( TCHAR* Name )
{
    FSpan **TempIndex,*Span;
    int i,NotEmpty=0;

    TempIndex = Index;
    for( i=StartY; i<EndY; i++ )
    {
        Span = *(TempIndex++);
        while (Span!=NULL)
        {
            if( Span->Start>=Span->End )
				appErrorf( _T("%s contains %i-length span"), Name, Span->End-Span->Start );
            NotEmpty=1;
            Span=Span->Next;
        }
    }
    if( !NotEmpty )
		appErrorf( _T("%s is empty"), Name );
}

//
// Make sure that a span buffer is valid.  Performs the following checks:
// - Make sure there are no zero-length spans
// - Make sure there are no negative-length spans
// - Make sure there are no overlapping spans
// - Make sure all span pointers are valid (otherwise GPF's)
//
void FSpanBuffer::AssertValid( TCHAR* Name )
{
    FSpan **TempIndex,*Span;
    int i,PrevEnd,c=0;

    TempIndex = Index;
    for( i=StartY; i<EndY; i++ )
    {
        PrevEnd = -1000;
        Span = *(TempIndex++);
        while( Span )
        {
            if ((i==StartY)||(i==(EndY-1)))
            {
                if ((PrevEnd!=-1000) && (PrevEnd >= Span->Start)) appErrorf(TEXT("%s contains %i-length overlap, line %i/%i"),Name,PrevEnd-Span->Start,i-StartY,EndY-StartY);
                if (Span->Start>=Span->End) appErrorf(TEXT("%s contains %i-length span, line %i/%i"),Name,Span->End-Span->Start,i-StartY,EndY-StartY);
                PrevEnd = Span->End;
            }
            Span=Span->Next;
            c++;
        }
    }
    if( c!=ValidLines )
		appErrorf( _T("%s bad ValidLines: claimed=%i, correct=%i"), Name, ValidLines, c );
}

//
// Like AssertValid, but 'ValidLines' checked for zero/nonzero only.
//
void FSpanBuffer::AssertGoodEnough( TCHAR* Name )
{
    FSpan **TempIndex,*Span;
    int i,PrevEnd,c=0;

    TempIndex = Index;
    for( i=StartY; i<EndY; i++ )
    {
        PrevEnd = -1000;
        Span = *(TempIndex++);
        while (Span)
        {
            if( (i==StartY)||(i==(EndY-1)) )
            {
                if ((PrevEnd!=-1000) && (PrevEnd >= Span->Start)) appErrorf(_T("%s contains %i-length overlap, line %i/%i"),Name,PrevEnd-Span->Start,i-StartY,EndY-StartY);
                if (Span->Start>=Span->End) appErrorf(_T("%s contains %i-length span, line %i/%i"),Name,Span->End-Span->Start,i-StartY,EndY-StartY);
                PrevEnd = Span->End;
            }
            Span=Span->Next;
            c++;
        }
    }
    if( (c==0) != (ValidLines==0) )
		appErrorf( _T("%s bad ValidLines: claimed=%i, correct=%i"), Name, ValidLines, c );
}