/*=============================================================================
	UnSpan.h: Span buffering functions and structures
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*------------------------------------------------------------------------------------
	General span buffer related classes.
------------------------------------------------------------------------------------*/

//
// A span buffer linked-list entry representing a free (undrawn) 
// portion of a scanline. 
//
class FSpan
{
public:
	// Variables.
	INT Start, End;
	FSpan* Next;

	// Constructors.
	FSpan()
	{}
	FSpan( INT InStart, INT InEnd )
	:	Start		(InStart)
	,	End			(InEnd)
	{}
};

//
// A raster span.
//
struct FRasterSpan
{
	INT X[2];
};

//
// A raster polygon.
//
class FRasterPoly
{
public:
	INT	StartY;
	INT EndY;
	FRasterSpan Lines[ZEROARRAY];
};

//
// A span buffer, which represents all free (undrawn) scanlines on
// the screen.
//
class ENGINE_API FSpanBuffer
{
public:
	INT			StartY;		// Starting Y value.
	INT			EndY;		// Last Y value + 1.
	INT			ValidLines;	// Number of lines at beginning (for screen).
	FSpan**		Index;		// Contains (EndY-StartY) units pointing to first span or NULL.
	FMemStack*	Mem;		// Memory pool everything is stored in.
	FMemMark	Mark;		// Top of memory pool marker.
	INT			Stride;		// NJS lines between each span

	// Constructors.
	FSpanBuffer()
	{ 
			Stride=1;
	}
	FSpanBuffer( const FSpanBuffer& Source, FMemStack& InMem )
	:	StartY		(Source.StartY)
	,	EndY		(Source.EndY)
	,	ValidLines	(Source.ValidLines)
	,	Index		(new(InMem,EndY-StartY)FSpan*)
	,	Mem			(&InMem)
	,	Mark		(InMem)
	{
		Stride=1;
		for( int i=0; i<EndY-StartY; i++ )
		{
			FSpan** PrevLink = &Index[i];
			for( FSpan* Other=Source.Index[i]; Other; Other=Other->Next )
			{
				*PrevLink = new( *Mem, 1, 4 )FSpan( Other->Start, Other->End );
				PrevLink  = &(*PrevLink)->Next;
			}
			*PrevLink = NULL;
		}
	}

	// Allocate a linear span buffer in temporary memory.  Allocates zero bytes
	// for the list; must call spanAllocLinear to allocate the proper amount of memory
	// for it.
	//
	inline void __fastcall AllocIndex( int AllocStartY, int AllocEndY, FMemStack* MemStack )
	{

		Mem         = MemStack;
		StartY      = AllocStartY;
		EndY        = AllocEndY;
		ValidLines  = 0;

		if( StartY <= EndY ) Index = New<FSpan*>(*Mem,AllocEndY-AllocStartY);
		else				 Index = NULL;

		Mark = FMemMark(*MemStack);
	}

	//
	// Allocate a linear span buffer and initialize it to represent
	// the yet-undrawn region of a viewport.
	//
	void __forceinline AllocIndexForScreen( INT SXR, INT SYR, FMemStack* MemStack )
	{
		Mem     = MemStack;
		StartY  = 0;
		EndY    = ValidLines = SYR;

		Index       = New<FSpan*>(*Mem,SYR);
		FSpan *List = New<FSpan>(*Mem,SYR);
		for( int i=0; i<SYR; i++ )
		{
			Index[i]      =&List[i];
			List [i].Start=0;
			List [i].End  =SXR;
			List [i].Next =NULL;
		}
	}	
	
	//
	// Free a linear span buffer in temporary rendering pool memory.
	// Works whether actually saved or not.
	//
	void __forceinline Release()
	{
		Mark.Pop();
	}
	void __fastcall GetValidRange( SWORD* ValidStartY, SWORD* ValidEndY );

	// Merge/copy/alter operations. (NJS: These two are not called)
	//
	// Copy the index from one span buffer to another span buffer.
	//
	// Status: Seldom called, no need to optimize.
	//

	void __forceinline CopyIndexFrom( const FSpanBuffer& Source, FMemStack* Mem )
	{
	    StartY   = Source.StartY;
	    EndY     = Source.EndY;
 
		Index = New<FSpan*>(*Mem,Source.EndY-Source.StartY);
		appMemcpy( &Index[0], &Source.Index[0], (Source.EndY-Source.StartY) * sizeof(FSpan *) );
	}
	void __fastcall MergeWith(	const FSpanBuffer& Other );

	// Grabbing and updating from rasterizations.
	INT __fastcall CopyFromRaster( FSpanBuffer& ScreenSpanBuffer, INT RasterStartY, INT RasterEndY, FRasterSpan* Raster );
	//INT __fastcall CopyFromRasterUpdate( FSpanBuffer& ScreenSpanBuffer, INT RasterStartY, INT RasterEndY, FRasterSpan* Raster );


	//
	// Grind this polygon through the span buffer and:
	// - See if the poly is totally occluded.
	// - Update the span buffer by adding this poly to it.
	// - Build a new, temporary span buffer for raster and span clipping the poly.
	//
	// Returns 1 if poly is all or partially visible, 0 if completely obscured.
	// If 0 was returned, no screen span buffer memory was allocated and the resulting
	// span index can be safely freed.
	//
	// Requires that StartY <= Raster.StartY, EndY >= Raster.EndY;
	//
	// If the destination FSpanBuffer and the screen's FSpanBuffer are using the same memory
	// pool, the newly-allocated screen spans will be intermixed with the destination
	// screen spans.  Freeing the destination in this case will overwrite the screen span buffer
	// with garbage.
	//
	// Status: Extremely performance critical. NJS: Agreed
	//

	INT __forceinline CopyFromRasterUpdate( FSpanBuffer& Screen, INT RasterStartY, INT RasterEndY, FRasterSpan* Raster )
	{
		FRasterSpan *Line;
		FSpan       **ScreenIndex,*NewScreenSpan,*NewSpan,*ScreenSpan,**PrevScreenLink,
					**TempIndex,**PrevLink;
		INT			i,OurStart,OurEnd,Accept=0;

		//if( StartY>RasterStartY || EndY<RasterEndY )
		//{
		//	debugf( NAME_Warning, TEXT("Illegal span range <%i,%i> <%i,%i>"), StartY, EndY, RasterStartY, RasterEndY );
		//	return 0;
		//}

		OurStart  = Max( RasterStartY, Screen.StartY );
		OurEnd    = Min( RasterEndY,   Screen.EndY   );
 		TempIndex = &Index[ 0 ];

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
			 i++, Line++, *PrevLink=NULL
		   )
		{
			PrevScreenLink=ScreenIndex;
			ScreenSpan    =*(ScreenIndex++);
			PrevLink      =TempIndex++;

			// Skip if this screen span is already full, or if the raster is empty.
			if(!ScreenSpan) continue; 

			LineX0=Line->X[0];
			LineX1=Line->X[1];

			if(LineX1<=LineX0) continue; 

			// Skip past all spans that occur before the raster.
			while( ScreenSpan->End <= LineX0 )
			{
				PrevScreenLink  = &(ScreenSpan->Next);
				ScreenSpan      = ScreenSpan->Next;
				if( !ScreenSpan ) goto NextLine; 
			}

			// ASSERT: ScreenSpan->End.X > Line->Start.X.

			// See if this span straddles the raster's starting point.
			if( ScreenSpan->Start < LineX0 )
			{
				// Add partial chunk to span buffer.
				Accept = 1;

				// Originally UPDATE_PREVLINK_ALLOC:
				NewSpan         = New<FSpan>(*Mem,1,4);
				*PrevLink       = NewSpan;
				NewSpan->Start  = LineX0;
				NewSpan->End    = Min(LineX1, ScreenSpan->End);
				PrevLink        = &(NewSpan->Next);
				ValidLines++;

				// See if span entirely encloses raster; if so, break span
				// up into two pieces and we're done.
				if( ScreenSpan->End > LineX1 )
				{
					// Get memory for the new span.  Note that this may be drawing from
					// the same memory pool as the destination.
					NewScreenSpan       = New<FSpan>(*Screen.Mem,1,4);
					NewScreenSpan->Start= LineX1;
					NewScreenSpan->End  = ScreenSpan->End;
					NewScreenSpan->Next = ScreenSpan->Next;

					ScreenSpan->Next    = NewScreenSpan;
					ScreenSpan->End     = LineX0;

					Screen.ValidLines++;

					continue;  // Done (everything is clean).
				}
				else
				{
					// Remove partial chunk from the span buffer.
					ScreenSpan->End = LineX0;

					PrevScreenLink  = &(ScreenSpan->Next);
					ScreenSpan      = ScreenSpan->Next;
					if (!ScreenSpan ) continue; // Done (everything is clean).
				}
			}

			// ASSERT: Span->Start >= Line->Start.X
			// if (ScreenSpan->Start < Line->Start.X) appError ("Span2");

			// Process all screen spans that are entirely within the raster.
			while( ScreenSpan->End <= LineX1 )
			{
				// Add entire chunk to temporary span buffer.
				Accept = 1;
				// Originally UPDATE_PREVLINK_ALLOC
				NewSpan         =New<FSpan>(*Mem,1,4);
				*PrevLink       =NewSpan;
				NewSpan->Start  =ScreenSpan->Start;
				NewSpan->End    =ScreenSpan->End;
				PrevLink        =&(NewSpan->Next);
				ValidLines++;

				// Delete this span from the span buffer.
				*PrevScreenLink = ScreenSpan = ScreenSpan->Next;
				Screen.ValidLines--;
				if( ScreenSpan==NULL )
					goto NextLine; // Done (everything is clean).
			}

			// ASSERT: Span->End > Line->End.X
			// if (ScreenSpan->End <= Line->End.X) appError ("Span3");

			// If span overlaps raster's end point, process the partial chunk:
			if( ScreenSpan->Start < LineX1 )
			{
				// Add chunk from Span->Start to Line->End.X to temp span buffer.
				Accept = 1;
				// Originally: UPDATE_PREVLINK_ALLOC(ScreenSpan->Start,LineX1);
				NewSpan          = New<FSpan>(*Mem,1,4);
				*PrevLink        = NewSpan;
				NewSpan->Start   = ScreenSpan->Start;
				ScreenSpan->Start= NewSpan->End = LineX1;
				PrevLink         = &(NewSpan->Next);
				ValidLines++;

				// Shorten this span line by removing the raster.
			}
			NextLine:;
		}

		for( i=OurEnd; i<EndY; i++ )
			*(TempIndex++) = NULL;

		return Accept;
	}

	//
	// See if a rectangle is visible.  Returns 1 if all or partially visible,
	// 0 if totally occluded.
	//
	// Status: Performance critical.
	//
	INT __forceinline BoxIsVisible( INT X1, INT Y1, INT X2, INT Y2 )
	{
		if( Y1 >= EndY )    return 0;
		if( Y2 <= StartY )  return 0;
		if (Y1 < StartY)    Y1 = StartY;
		if (Y2 > EndY)      Y2 = EndY;

		// Check box occlusion with span buffer.
		FSpan **ScreenIndex = &Index [Y1-StartY];
		int Count   = Y2-Y1;

		// Start checking last line, then first and the rest.
		FSpan *Span = *(ScreenIndex + Count - 1 );
		while( --Count >= 0 )
		{
			for(;Span && X2>Span->Start;Span=Span->Next)
   				if( X1 < Span->End )
    				return 1;

			Span = *ScreenIndex++;
		}
		return 0;
	}
	// Debugging.
	void AssertEmpty( TCHAR* Name );
	void AssertNotEmpty( TCHAR* Name );
	void AssertValid( TCHAR* Name );
	void AssertGoodEnough( TCHAR* Name );
};

/*------------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------------*/
