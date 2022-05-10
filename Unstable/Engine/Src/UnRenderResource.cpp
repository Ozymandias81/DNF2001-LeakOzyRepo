/*=============================================================================
	UnRenderResource.cpp: Render resource implementation.
	Copyright 1997-2000 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Andrew Scheidecker
=============================================================================*/

#include "EnginePrivate.h"

IMPLEMENT_CLASS(URenderResource);
IMPLEMENT_CLASS(UVertexBuffer);
IMPLEMENT_CLASS(UIndexBuffer);

/*
	URenderResource::Serialize
*/

void URenderResource::Serialize(FArchive& Ar)
{
	guard(URenderResource::Serialize);

	Super::Serialize(Ar);

	Ar << Revision;

	unguard;
}

/*
	UVertexBuffer::Serialize
*/

void UVertexBuffer::Serialize(FArchive& Ar)
{
	guard(UVertexBuffer::Serialize);

	Super::Serialize(Ar);

	Ar << Vertices;

	unguard;
}

/*
	UIndexBuffer::Serialize
*/

void UIndexBuffer::Serialize(FArchive& Ar)
{
	guard(UIndexBuffer::Serialize);

	Super::Serialize(Ar);

	Ar << Indices;

	unguard;
}