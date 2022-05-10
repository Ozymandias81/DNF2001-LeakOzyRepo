/*=============================================================================
	AFocalPoint.cpp: DukeNet Script interface code.
	Copyright 1999-2000 3D Realms, Inc. All Rights Reserved.
=============================================================================*/
#include "EnginePrivate.h"

void AFocalPoint::NotifyPawns()
{
	clock(GetLevel()->SeePlayer);

	for( APawn *Pawn=GetLevel()->GetLevelInfo()->PawnList; Pawn != NULL; Pawn = Pawn->nextPawn )
	{
		if( Pawn->IsProbing( NAME_SeeFocalPoint ) )
		{
			Pawn->bNoHeightMod = true;
//			Pawn->PeripheralVision = PeripheryMod;
			if( Pawn->LineOfSightTo( this, true ) )
				Pawn->eventSeeFocalPoint( this );
//			Pawn->PeripheralVision = (( APawn* )APawn::StaticClass()->GetDefaultActor())->PeripheralVision;
			Pawn->bNoHeightMod = false;
		}
	}

	unclock(GetLevel()->SeePlayer);
}

void AFocalPoint::execNotifyObservers( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	NotifyPawns();
}

