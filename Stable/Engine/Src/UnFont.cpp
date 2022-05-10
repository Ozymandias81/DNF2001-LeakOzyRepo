/*=============================================================================
	UnFont.cpp: Unreal font code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*------------------------------------------------------------------------------
	UFont implementation.
------------------------------------------------------------------------------*/

UFont::UFont()
{}

void UFont::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	UBOOL GSavedLazyLoad = GLazyLoad;
	GLazyLoad = 1;
	Ar << Pages << CharactersPerPage;

if (!IsA(UFontTrueType::StaticClass()))		// JEP: special case TrueType fonts
{
	check(!(CharactersPerPage&(CharactersPerPage-1)));
	if( !GLazyLoad )
		for( INT c=0,p=0; c<256; c+=CharactersPerPage,p++ )
			if( p<Pages.Num() && Pages(p).Texture )
				for( INT i=0; i<Pages(p).Texture->Mips.Num(); i++ )
					Pages(p).Texture->Mips(i).DataArray.Load();
}

	GLazyLoad = GSavedLazyLoad;
}
IMPLEMENT_CLASS(UFont);

/*------------------------------------------------------------------------------
	UFontTrueType implementation.
------------------------------------------------------------------------------*/

UFontTrueType::UFontTrueType() : UFont()
{}

void UFontTrueType::Serialize( FArchive& Ar )
{
	//SetFlags( RF_DebugSerialize );
	Super::Serialize(Ar);				// JEP:  Call super (fixed the crash, look at the changes in super)
}

IMPLEMENT_CLASS(UFontTrueType);

/*------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------*/
