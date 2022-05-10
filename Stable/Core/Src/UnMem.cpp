/*=============================================================================
	UnMem.cpp: Unreal memory grabbing functions
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Revision history:
	* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

/*-----------------------------------------------------------------------------
	FMemStack statics.
-----------------------------------------------------------------------------*/

FMemStack::FTaggedMemory* FMemStack::UnusedChunks = NULL;

/*-----------------------------------------------------------------------------
	FMemStack implementation.
-----------------------------------------------------------------------------*/

//
// Initialize this memory stack.
//
/*
void __fastcall FMemStack::Init( INT InDefaultChunkSize )
{

	DefaultChunkSize = InDefaultChunkSize;
	TopChunk         = NULL;
	End              = NULL;
	Top		         = NULL;
}
*/
//
// Free this memory stack.
//
/*
void __fastcall FMemStack::Exit()
{
	Tick();
	while( UnusedChunks )
	{
		void* Old = UnusedChunks;
		UnusedChunks = UnusedChunks->Next;
		appFree( Old );
	}
}
*/

//
// Return the amount of bytes that have been allocated by this memory stack.
//
INT __fastcall FMemStack::GetByteCount()
{
	INT Count = 0;
	for( FTaggedMemory* Chunk=TopChunk; Chunk; Chunk=Chunk->Next )
	{
		if( Chunk!=TopChunk )
			Count += Chunk->DataSize;
		else
			Count += Top - Chunk->Data;
	}
	return Count;
}

/*-----------------------------------------------------------------------------
	Chunk functions.
-----------------------------------------------------------------------------*/

//
// Allocate a new chunk of memory of at least MinSize size,
// and return it aligned to Align. Updates the memory stack's
// Chunks table and ActiveChunks counter.
//
BYTE* __fastcall FMemStack::AllocateNewChunk( INT MinSize )
{
	FTaggedMemory* Chunk=NULL;
	for( FTaggedMemory** Link=&UnusedChunks; *Link; Link=&(*Link)->Next )
	{
		// Find existing chunk.
		if( (*Link)->DataSize >= MinSize )
		{
			Chunk = *Link;
			*Link = (*Link)->Next;
			break;
		}
	}
	if( !Chunk )
	{
		// Create new chunk.
		INT DataSize    = Max( MinSize, DefaultChunkSize-(INT)sizeof(FTaggedMemory) );
		Chunk           = (FTaggedMemory*)appMalloc( DataSize + sizeof(FTaggedMemory), TEXT("MemChunk") );
		Chunk->DataSize = DataSize;
	}
	Chunk->Next = TopChunk;
	TopChunk    = Chunk;
	Top         = Chunk->Data;
	End         = Top + Chunk->DataSize;
	return Top;
}

void __fastcall FMemStack::FreeChunks( FTaggedMemory* NewTopChunk )
{
	while( TopChunk!=NewTopChunk )
	{
		FTaggedMemory* RemoveChunk = TopChunk;
		TopChunk                   = TopChunk->Next;
		RemoveChunk->Next          = UnusedChunks;
		UnusedChunks               = RemoveChunk;
	}
	Top = NULL;
	End = NULL;
	if( TopChunk )
	{
		Top = TopChunk->Data;
		End = Top + TopChunk->DataSize;
	}
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
