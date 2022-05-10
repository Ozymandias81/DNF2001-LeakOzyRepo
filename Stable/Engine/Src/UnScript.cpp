/*=============================================================================
	UnScript.cpp: UnrealScript engine support code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Description:
	UnrealScript execution and support code.

Revision history:
	* Created by Tim Sweeney
=============================================================================*/
#include "EnginePrivate.h"


/*-----------------------------------------------------------------------------
	Tim's physics modes.
-----------------------------------------------------------------------------*/

//
// Interpolating along a path.
//
void AActor::physPathing( FLOAT DeltaTime )
{
	// Linear interpolate from Target to Target.Next.
	while( PhysRate!=0.f && bInterpolating && DeltaTime>0.f )
	{
		UBOOL Teleport=false;

		// Find destination interpolation point, if any:
		AInterpolationPoint *Dest = Cast<AInterpolationPoint>( Target );

		// Compute rate modifier.
		FLOAT RateModifier = 1.0;
		if( Dest && Dest->Next )
		{
			if(Dest->RateIsSpeed)
			{
				RateModifier=Dest->RateModifier/(Dest->Location-Dest->Next->Location).Size();
			} else if(Dest->Next->RateIsTime)
			{
				RateModifier = Dest->Next->RateModifier;
				if(RateModifier=0) Teleport=true;
			} else
				RateModifier = Dest->RateModifier * (1.0 - PhysAlpha) + Dest->Next->RateModifier * PhysAlpha;
		}

		if(Dest&&Dest->Next)
		{
			// Update level slomo.
			if((Dest->GameSpeedModifier!=1.0)||(Dest->Next->GameSpeedModifier!=1.0))
				Level->TimeDilation = Dest->GameSpeedModifier * (1.0 - PhysAlpha) + Dest->Next->GameSpeedModifier * PhysAlpha;
		}

		// Update screenflash and FOV.
		if( Dest && IsA(APlayerPawn::StaticClass()) )
		{
			((APlayerPawn*)this)->FlashScale=FVector(1,1,1)*(((APlayerPawn*)this)->DesiredFlashScale = (Dest->ScreenFlashScale * (1.0 - PhysAlpha) + Dest->Next->ScreenFlashScale * PhysAlpha));
			((APlayerPawn*)this)->FlashFog  =((APlayerPawn*)this)->DesiredFlashFog   = (Dest->ScreenFlashFog   * (1.0 - PhysAlpha) + Dest->Next->ScreenFlashFog   * PhysAlpha);
			((APlayerPawn*)this)->FovAngle                                           = (Dest->FovModifier      * (1.0 - PhysAlpha) + Dest->Next->FovModifier      * PhysAlpha) * ((APlayerPawn*)GetClass()->GetDefaultObject())->FovAngle;
		}

		// Update alpha.
		FLOAT OldAlpha =PhysAlpha;
		FLOAT DestAlpha=PhysAlpha+PhysRate*RateModifier*DeltaTime;

		
		// If rate modifier is zero, then teleport to destination instantly:
		if(!RateModifier) DestAlpha=1.001; 
		
		PhysAlpha = Clamp( DestAlpha, 0.0f, 1.0f );

		// Move and rotate.
		if( Dest && Dest->Next )
		{
			FCheckResult Hit;
			FVector  NewLocation;
			FRotator NewRotation;
			
			guard(ComputeNewPosition);
				if( Dest->Prev && Dest->Next->Next && (Dest->MotionType==MOTION_Spline))
				{

					KRSpline_Sample(PhysAlpha,NewLocation,NewRotation,
									 Dest->Prev->Location, Dest->Prev->Rotation,
									 Dest->Location, Dest->Rotation,
									 Dest->Next->Location, Dest->Next->Rotation,
									 Dest->Next->Next->Location, Dest->Next->Next->Rotation);

					// Tim's original cubic spline interpolation.
					//FLOAT W0 = Splerp(PhysAlpha+1.0);
					//FLOAT W1 = Splerp(PhysAlpha+0.0);
					//FLOAT W2 = Splerp(PhysAlpha-1.0);
					//FLOAT W3 = Splerp(PhysAlpha-2.0);
					//FLOAT RW = 1.0 / (W0 + W1 + W2 + W3);
					//NewLocation = (W0*Dest->Prev->Location + W1*Dest->Location + W2*Dest->Next->Location + W3*Dest->Next->Next->Location)*RW;
					//NewRotation = (W0*Dest->Prev->Rotation + W1*Dest->Rotation + W2*Dest->Next->Rotation + W3*Dest->Next->Next->Rotation)*RW;
				}
				else
				{
					// Linear interpolation.
					FLOAT W0 = 1.0 - PhysAlpha;
					FLOAT W1 = PhysAlpha;
					NewLocation = W0*Dest->Location + W1*Dest->Next->Location;
					NewRotation = W0*Dest->Rotation + W1*Dest->Next->Rotation;
				}
			unguard;

			guard(MoveActor);
				if(!Dest->InterpolateRotation)
				{
					// Should I ignore rotation?
					NewRotation=Rotation;
				}

				if(Teleport)
				{
					GetLevel()->FarMoveActor( this, NewLocation );
					GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit );

				} else
					GetLevel()->MoveActor( this, NewLocation - Location, NewRotation, Hit );
				if( IsA(APawn::StaticClass()) )
					((APawn*)this)->ViewRotation = Rotation;
			unguard;
		}

		guard(HandleAlphaOverflow)
			// If overflowing, notify and go to next place.
			if( PhysRate>0.0 && DestAlpha>1.0 )
			{
				PhysAlpha = 0.0;
				DeltaTime *= (DestAlpha - 1.0) / (DestAlpha - OldAlpha);
				if( Target )
				{
					Target->eventInterpolateEnd(this);
					eventInterpolateEnd(Target);
					if( Dest )
					{
						do
						{
							Target = Dest->Next;
							Dest = Cast<AInterpolationPoint>( Target );
						} while( Dest && Dest->bSkipNextPath );
					}
				}
			}
			else if( PhysRate<0.0 && DestAlpha<0.0 )
			{
				PhysAlpha = 1.0;
				DeltaTime *= (0.0 - DestAlpha) / (OldAlpha - DestAlpha);
				if( Target )
				{
					Target->eventInterpolateEnd(this);
					eventInterpolateEnd(Target);
					if( Dest )
					{
						do
						{
							Target = Dest->Prev;
							Dest = Cast<AInterpolationPoint>( Target );
						} while( Dest && Dest->bSkipNextPath );
					} 
					guard(CalleventInterpolateBegin);
					eventInterpolateBegin(Target);
					if(Target)
					{
						AInterpolationPoint *Dest2=Cast<AInterpolationPoint>(Target);
						if(Dest2) Dest2->eventInterpolateBegin(this);
					}
					unguard;
				}
				eventInterpolateEnd(NULL);
			}
			else DeltaTime=0.0;
		unguard;
	};
}

//
// Moving brush.
//
void AActor::physMovingBrush( FLOAT DeltaTime )
{
	guard(physMovingBrush);
	if( IsA(AMover::StaticClass()) )
	{
		AMover* Mover  = (AMover*)this;
		INT KeyNum     = Clamp( (INT)Mover->KeyNum, (INT)0, (INT)ARRAY_COUNT(Mover->KeyPos) );
		while( Mover->bInterpolating && DeltaTime>0.0 )
		{
			// We are moving.
			FLOAT NewAlpha = Mover->PhysAlpha + DeltaTime * Mover->PhysRate;
			if( NewAlpha > 1.0 )
			{
				DeltaTime *= (NewAlpha - 1.0) / (NewAlpha - PhysAlpha);
				NewAlpha   = 1.0;
			}
			else DeltaTime = 0.0;

			// Compute alpha.
			FLOAT RenderAlpha;
			if( Mover->MoverGlideType == MV_GlideByTime )
			{
				// Make alpha time-smooth and time-continuous.
				// f(0)=0, f(1)=1, f'(0)=f'(1)=0.
				RenderAlpha = 3.0*NewAlpha*NewAlpha - 2.0*NewAlpha*NewAlpha*NewAlpha;
			}
			else RenderAlpha = NewAlpha;

			// Move.
			FCheckResult Hit(1.0);
			if( GetLevel()->MoveActor
			(
				Mover,
				Mover->OldPos + ((Mover->BasePos + Mover->KeyPos[KeyNum]) - Mover->OldPos) * RenderAlpha - Mover->Location,
				Mover->OldRot + ((Mover->BaseRot + Mover->KeyRot[KeyNum]) - Mover->OldRot) * RenderAlpha,
				Hit
			) )
			{
				// Successfully moved.
				Mover->PhysAlpha = NewAlpha;
				Mover->LastMoveTime += DeltaTime;
				if( NewAlpha == 1.0 )
				{
					// Just finished moving.
					Mover->bInterpolating = 0;
					Mover->eventInterpolateEnd(NULL);
				}
			}
		}
	}
	unguard;
}

//
// Initialize execution.
//
void AActor::InitExecution()
{
	guard(AActor::InitExecution);

	UObject::InitExecution();

	check(GetStateFrame());
	check(GetStateFrame()->Object==this);
	check(GetLevel()!=NULL);
	check(GetLevel()->Actors(0)!=NULL);
	check(GetLevel()->Actors(0)==Level);
	check(Level!=NULL);

	unguardobj;
}

/*-----------------------------------------------------------------------------
	Natives.
-----------------------------------------------------------------------------*/

//////////////////////
// Console Commands //
//////////////////////

void AActor::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(UObject::execConsoleCommand);

	P_GET_STR(Command);
	P_GET_UBOOL_OPTX(bAllowExecFuncs, 0);
	P_GET_UBOOL_OPTX(bExecsOnly, 0);
	P_FINISH;

	FStringOutputDevice StrOut;
	if (bAllowExecFuncs)
	{
		if (ScriptConsoleExec(*Command, StrOut, NULL))
		{
			*(FString*)Result = *StrOut;
			return;
		}
		if (bExecsOnly)
		{
			StrOut.Logf(TEXT(""));
			*(FString*)Result = *StrOut;
			return;
		}
	}
	GetLevel()->Engine->Exec( *Command, StrOut );
	*(FString*)Result = *StrOut;

	unguard;
}

/////////////////////////////
// Log and error functions //
/////////////////////////////

void AActor::execError( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(S);
	P_FINISH;

	Stack.Log( *S );
	GetLevel()->DestroyActor( this );
}

//////////////////////////
// Clientside functions //
//////////////////////////

void APlayerPawn::execClientTravel( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(URL);
	P_GET_BYTE(TravelType);
	P_GET_UBOOL(bItems);
	P_FINISH;

	if( Player )
	{
		// Warn the client.
		eventPreClientTravel();

		// Do the travel.
		GetLevel()->Engine->SetClientTravel( Player, *URL, bItems, (ETravelType)TravelType );
	}
}

void APlayerPawn::execSaveLoadActive( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	*(UBOOL*)Result = GSaveLoadHack;
}

void APlayerPawn::execGetPlayerNetworkAddress( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerPawn::execGetPlayerNetworkAddress);
	P_FINISH;

	if( Player && Player->IsA(UNetConnection::StaticClass()) )
		*(FString*)Result = Cast<UNetConnection>(Player)->LowLevelGetRemoteAddress();
	else
		*(FString*)Result = TEXT("");
	unguard;
}

void APlayerPawn::execCopyToClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerPawn::execCopyToClipboard);
	P_GET_STR(Text);
	P_FINISH;
	appClipboardCopy(*Text);
	unguard;
}

void APlayerPawn::execPasteFromClipboard( FFrame& Stack, RESULT_DECL )
{
	guard(APlayerPawn::execCopyToClipboard);
	P_GET_STR(Text);
	P_FINISH;
	*(FString*)Result = appClipboardPaste();
	unguard;
}

void ALevelInfo::execGetLocalURL( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(FString*)Result = GetLevel()->URL.String();
}

void ALevelInfo::execGetAddressURL( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(FString*)Result = FString::Printf( TEXT("%s:%i"), *GetLevel()->URL.Host, GetLevel()->URL.Port );
}

///////////////////////////
// Client-side functions //
///////////////////////////

void APawn::execClientHearSound( FFrame& Stack, RESULT_DECL )
{
	guard(APawn::execClientHearSound);

	P_GET_OBJECT(AActor,Actor);
	P_GET_INT(Id);
	P_GET_OBJECT(USound,Sound);
	P_GET_VECTOR(SoundLocation);
	P_GET_VECTOR(Parameters);
	P_FINISH;

	UBOOL bMonitorSound = 0;
	if (Parameters.X < 0)
	{
		bMonitorSound = 1;
		Parameters.X = -Parameters.X;
	}
	FLOAT Volume = 0.01 * Parameters.X;
	FLOAT Radius = Parameters.Y;
	FLOAT Pitch  = 0.01 * Parameters.Z;
	if
	(	IsA(APlayerPawn::StaticClass()) 
	&&	((APlayerPawn*)this)->Player
	&&	((APlayerPawn*)this)->Player->IsA(UViewport::StaticClass())
	&&	GetLevel()->Engine->Audio )
	{
		if( Actor && Actor->bDeleteMe )
			Actor = NULL;
		GetLevel()->Engine->Audio->PlaySound( Actor, Id, Sound, SoundLocation, Volume, Radius ? Radius : 1600.f, Pitch, bMonitorSound );
	}
	unguardexec;
}

////////////////////////////////
// Latent function initiators //
////////////////////////////////

void AActor::execSleep( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(Seconds);
	P_FINISH;

	GetStateFrame()->LatentAction = EPOLL_Sleep;
	LatentFloat  = Seconds;
}

void AActor::execFinishAnim( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT_OPTX(ChannelIndex,0);
	P_FINISH;

	UMeshInstance* MeshInst = GetMeshInstance();
	if (MeshInst == NULL)
		return;

	FMeshChannel* Chan = &MeshInst->MeshChannels[ChannelIndex];

	// If we are looping, finish at the next sequence end.
	if (Chan->bAnimLoop)
	{
		Chan->bAnimLoop = 0;
		Chan->bAnimFinished = 0;
	}
	if (!ChannelIndex)
	{
		if( bAnimLoop )
		{
			bAnimLoop     = 0;
			bAnimFinished = 0;
		}
	}

	// If animation is playing, wait for it to finish.
	UBOOL CheckFrame = Chan->AnimFrame < Chan->AnimLast;
	if (!ChannelIndex)
		CheckFrame = AnimFrame < AnimLast;

	if( IsAnimating(ChannelIndex) && CheckFrame )
	{
		GetStateFrame()->LatentAction = EPOLL_FinishAnim;
		LatentInt = ChannelIndex;
	}
}

void AActor::execFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	GetStateFrame()->LatentAction = EPOLL_FinishInterpolation;
}

///////////////////////////
// Slow function pollers //
///////////////////////////

void AActor::execPollSleep( FFrame& Stack, RESULT_DECL )
{
	FLOAT DeltaSeconds = *(FLOAT*)Result;
	if( (LatentFloat-=DeltaSeconds) < 0.5 * DeltaSeconds )
	{
		// Awaken.
		GetStateFrame()->LatentAction = 0;
	}
}
IMPLEMENT_FUNCTION( AActor, EPOLL_Sleep, execPollSleep );

void AActor::execPollFinishAnim( FFrame& Stack, RESULT_DECL )
{
	INT ChannelIndex = LatentInt;
	if (!ChannelIndex)
	{
		if( bAnimFinished )
			GetStateFrame()->LatentAction = 0;
	}
	else
	{
		UMeshInstance* MeshInst = GetMeshInstance();
		if (MeshInst)
		{
			FMeshChannel* Chan = &MeshInst->MeshChannels[ChannelIndex];
			if (Chan->bAnimFinished)
				GetStateFrame()->LatentAction = 0;
		}
	}
}
IMPLEMENT_FUNCTION( AActor, EPOLL_FinishAnim, execPollFinishAnim );

void AActor::execPollFinishInterpolation( FFrame& Stack, RESULT_DECL )
{
	if( !bInterpolating )
		GetStateFrame()->LatentAction = 0;
}
IMPLEMENT_FUNCTION( AActor, EPOLL_FinishInterpolation, execPollFinishInterpolation );

/////////////////////////
// Animation functions //
/////////////////////////

void AActor::execPlayAnim( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_GET_FLOAT_OPTX(PlayAnimRate,1.0);
	P_GET_FLOAT_OPTX(TweenTime,-1.0);
	P_GET_INT_OPTX(ChannelIndex,0);
	P_FINISH;

	if (!Mesh)
	{
		Stack.Logf( TEXT("PlayAnim: No mesh") );
		return;
	}
	UMeshInstance* MeshInst = Mesh->GetInstance(this);
	if (MeshInst == NULL)
		return;
	if (SequenceName==NAME_None)
	{
		MeshInst->MeshChannels[ChannelIndex].AnimSequence = NAME_None;
		if (!ChannelIndex)
			AnimSequence = NAME_None;
		return;
	}
	HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
	if (!Seq)
	{
		Stack.Logf( TEXT("PlayAnim: Sequence '%s' not found in Mesh '%s'"), *SequenceName, Mesh->GetName() );
		return;
	}
	
	//debugf( TEXT("PlayAnim %s:%d"), *SequenceName, ChannelIndex );
	MeshInst->PlaySequence(Seq, ChannelIndex, false, PlayAnimRate, 0.f, TweenTime);
}

void AActor::execLoopAnim( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_GET_FLOAT_OPTX(PlayAnimRate,1.0);
	P_GET_FLOAT_OPTX(TweenTime,-1.0);
	P_GET_FLOAT_OPTX(MinRate,0.0);
	P_GET_INT_OPTX(ChannelIndex,0);
	P_FINISH;

	if (!Mesh)
	{
		Stack.Logf( TEXT("LoopAnim: No mesh") );
		return;
	}
	UMeshInstance* MeshInst = Mesh->GetInstance(this);
	if (SequenceName==NAME_None)
	{
		MeshInst->MeshChannels[ChannelIndex].AnimSequence = NAME_None;
		if (!ChannelIndex)
			AnimSequence = NAME_None;
		return;
	}
	HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
	if (!Seq)
	{
		Stack.Logf( TEXT("LoopAnim: Sequence '%s' not found in Mesh '%s'"), *SequenceName, Mesh->GetName() );
		return;
	}

	//debugf( TEXT("LoopAnim %s:%d"), *SequenceName, ChannelIndex );
	MeshInst->PlaySequence(Seq, ChannelIndex, true, PlayAnimRate, MinRate, TweenTime);
}

void AActor::execTweenAnim( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_GET_FLOAT(TweenTime);
	P_GET_INT_OPTX(ChannelIndex,0);
	P_FINISH;

	if (!Mesh)
	{
		Stack.Logf( TEXT("TweenAnim: No mesh") );
		return;
	}
	UMeshInstance* MeshInst = Mesh->GetInstance(this);
	if (SequenceName==NAME_None)
	{
		MeshInst->MeshChannels[ChannelIndex].AnimSequence = NAME_None;
		if (!ChannelIndex)
			AnimSequence = NAME_None;
		return;
	}
	HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
	if (!Seq)
	{
		Stack.Logf( TEXT("TweenAnim: Sequence '%s' not found in Mesh '%s'"), *SequenceName, Mesh->GetName() );
		return;
	}

	MeshInst->PlaySequence(Seq, ChannelIndex, false, 0.f, 0.f, TweenTime);
}

void AActor::execIsAnimating( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT_OPTX(ChannelIndex,0);
	P_FINISH;

	*(DWORD*)Result = IsAnimating(ChannelIndex);
}

void AActor::execSetAnimGroup( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_GET_NAME(GroupName);
	P_FINISH;

	// Store the animation group.
	if ( Mesh )
	{
		UMeshInstance* MeshInst = Mesh->GetInstance(this);
		if ( MeshInst )
		{
			HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
			if ( Seq )
				MeshInst->SetSeqGroupName(SequenceName, GroupName);
			else 
				Stack.Logf( TEXT("SetAnimGroup: Sequence '%s' not found in Mesh '%s'"), *SequenceName, Mesh->GetName() );
		}
	} else 
		Stack.Logf( TEXT("SetAnimGroup: No mesh") );
}

void AActor::execGetAnimGroup( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_FINISH;

	// Return the animation group.
	*(FName*)Result = NAME_None;
	if( Mesh )
	{
		UMeshInstance* MeshInst = Mesh->GetInstance(this);
		HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
		if( Seq )
			*(FName*)Result = MeshInst->GetSeqGroupName(SequenceName);
		else 
			Stack.Logf( TEXT("GetAnimGroup: Sequence '%s' not found in Mesh '%s'"), *SequenceName, Mesh->GetName() );
	} else 
		Stack.Logf( TEXT("GetAnimGroup: No mesh") );
}

void AActor::execHasAnim( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(SequenceName);
	P_FINISH;

	// Check for a certain anim sequence.
	if( Mesh )
	{
		/*
		IMeshSequence* Seq = Mesh->FindSequence(SequenceName);
		*/
		UMeshInstance* MeshInst = Mesh->GetInstance(this);
		HMeshSequence Seq = MeshInst->FindSequence(SequenceName);
		if( Seq )
		{
			*(DWORD*)Result = 1;
		} else
			*(DWORD*)Result = 0;
	} else Stack.Logf( TEXT("HasAnim: No mesh") );
}

void AActor::execGetMeshInstance( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	*(UMeshInstance**)Result = GetMeshInstance();
}

///////////////
// Collision //
///////////////

void AActor::execSetCollision( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL_OPTX(NewCollideActors,bCollideActors);
	P_GET_UBOOL_OPTX(NewBlockActors,  bBlockActors  );
	P_GET_UBOOL_OPTX(NewBlockPlayers, bBlockPlayers );
	P_FINISH;

	SetCollision( NewCollideActors, NewBlockActors, NewBlockPlayers );
}

void AActor::execSetCollisionSize( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(NewRadius);
	P_GET_FLOAT(NewHeight);
	P_FINISH;

	SetCollisionSize( NewRadius, NewHeight );

	// Return boolean success or failure.
	*(DWORD*)Result = 1;
}

void AActor::execSetBase( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(AActor,NewBase);
	P_FINISH;

	SetBase( NewBase );
}

///////////
// Audio //
///////////
void AActor::CheckHearSound(APawn* Hearer, INT Id, USound* Sound, FVector Parameters, FLOAT RadiusSquared)
{
	FVector HearSource;
	if ( Hearer->IsA(APlayerPawn::StaticClass()) && ((APlayerPawn *)Hearer)->ViewTarget )
		HearSource = ((APlayerPawn *)Hearer)->ViewTarget->Location;
	else
		HearSource = Hearer->Location;

	FLOAT NewRadiusSquared = RadiusSquared/1.3f;
	FLOAT DistSq = (HearSource-Location).SizeSquared();
	if( DistSq < NewRadiusSquared )
	{
		if ( !GetLevel()->Model->FastLineCheck(HearSource,Location) )
		{
			// if no line of sight, reduce radius and volume
			if ( Instigator != Hearer )
				NewRadiusSquared *= 0.6f;

			Parameters.X *= 0.35f;
			if ( DistSq > NewRadiusSquared )
				return;
		}
		Hearer->eventClientHearSound( this, Id, Sound, Location, Parameters );
	}
}

void AActor::execDemoPlaySound( FFrame& Stack, RESULT_DECL )
{
	// Get parameters.
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,SLOT_Misc);
	P_GET_FLOAT_OPTX(Volume,TransientSoundVolume);
	P_GET_UBOOL_OPTX(bNoOverride, 0);
	P_GET_FLOAT_OPTX(Radius,TransientSoundRadius);
	P_GET_FLOAT_OPTX(Pitch,1.0);
	P_GET_UBOOL_OPTX(bMonitorSound, 0);
	P_FINISH;

	if( !Sound )
		return;

	// Play the sound locally
	INT Id = GetIndex()*16 + Slot*2 + bNoOverride;
	FLOAT RadiusSquared = Square( Radius ? Radius : 1600.f );
	FVector Parameters = FVector(100 * Volume, Radius, 100 * Pitch);
	if (bMonitorSound)
		Parameters.X = -Parameters.X;

	UClient* Client = GetLevel()->Engine->Client;
	if( Client )
	{
		for( INT i=0; i<Client->Viewports.Num(); i++ )
		{
			APlayerPawn* Hearer = Client->Viewports(i)->Actor;
			if( Hearer && Hearer->GetLevel()==GetLevel() )
				CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
		}
	}
}

#pragma DISABLE_OPTIMIZATION
void AActor::PlayActorSound(USound *Sound, unsigned char Slot, FLOAT Volume, UBOOL bNoOverride,FLOAT Radius,FLOAT Pitch,UBOOL bMonitorSound)
{
	if( !Sound )
		return;

	// Server-side demo needs a call to execDemoPlaySound for the DemoRecSpectator
	if(		GetLevel() && GetLevel()->DemoRecDriver
		&&	!GetLevel()->DemoRecDriver->ServerConnection
		&&	GetLevel()->GetLevelInfo()->NetMode != NM_Client )
		eventDemoPlaySound(Sound, Slot, Volume, bNoOverride, Radius, Pitch, bMonitorSound);

	INT Id = GetIndex()*16 + Slot*2 + bNoOverride;
	FLOAT RadiusSquared = Square( Radius ? Radius : 1600.f );
	FVector Parameters = FVector(100 * Volume, Radius, 100 * Pitch);
	if (bMonitorSound)
		Parameters.X = -Parameters.X;

	// Propogate these sounds locally only.

	// See if the function is simulated.
	//UFunction* Caller = Cast<UFunction>( Stack.Node );
//	if( (GetLevel()->GetLevelInfo()->NetMode == NM_Client)/* || (Caller && (Caller->FunctionFlags & FUNC_Simulated)) */)
//	{
		// Called from a simulated function, so propagate locally only.
		UClient* Client = GetLevel()->Engine->Client;
		if( Client )
		{
			for( INT i=0; i<Client->Viewports.Num(); i++ )
			{
				APlayerPawn* Hearer = Client->Viewports(i)->Actor;
				if( Hearer && Hearer->GetLevel()==GetLevel() )
					CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
			}
		}
		/*
	}
	else
	{
		// Propagate to all player actors.
		for( APawn* Hearer=Level->PawnList; Hearer; Hearer=Hearer->nextPawn )
		{
			if( Hearer->bIsPlayer )
				CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
		}
	}
	*/
}

void AActor::execPlaySound( FFrame& Stack, RESULT_DECL )
{
	// Get parameters.
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,SLOT_Misc);
	P_GET_FLOAT_OPTX(Volume,TransientSoundVolume);
	P_GET_UBOOL_OPTX(bNoOverride, 0);
	P_GET_FLOAT_OPTX(Radius,TransientSoundRadius);
	P_GET_FLOAT_OPTX(Pitch,TransientSoundPitch);
	P_GET_UBOOL_OPTX(bMonitorSound, 0);
	P_FINISH;

	if( !Sound )
		return;

	// Server-side demo needs a call to execDemoPlaySound for the DemoRecSpectator
	if(		GetLevel() && GetLevel()->DemoRecDriver
		&&	!GetLevel()->DemoRecDriver->ServerConnection
		&&	GetLevel()->GetLevelInfo()->NetMode != NM_Client )
		eventDemoPlaySound(Sound, Slot, Volume, bNoOverride, Radius, Pitch, bMonitorSound);

	INT Id = GetIndex()*16 + Slot*2 + bNoOverride;
	FLOAT RadiusSquared = Square( Radius ? Radius : 1600.f );
	FVector Parameters = FVector(100 * Volume, Radius, 100 * Pitch);
	if (bMonitorSound)
		Parameters.X = -Parameters.X;

	// See if the function is simulated.
	UFunction* Caller = Cast<UFunction>( Stack.Node );
	if( (GetLevel()->GetLevelInfo()->NetMode == NM_Client) || (Caller && (Caller->FunctionFlags & FUNC_Simulated)) )
	{
		// Called from a simulated function, so propagate locally only.
		UClient* Client = GetLevel()->Engine->Client;
		if( Client )
		{
			for( INT i=0; i<Client->Viewports.Num(); i++ )
			{
				APlayerPawn* Hearer = Client->Viewports(i)->Actor;
				if( Hearer && Hearer->GetLevel()==GetLevel() )
					CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
			}
		}
	}
	else
	{
		// Propagate to all player actors.
		for( APawn* Hearer=Level->PawnList; Hearer; Hearer=Hearer->nextPawn )
		{
			if( Hearer->bIsPlayer )
				CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
		}
	}
}
#pragma ENABLE_OPTIMIZATION

void AActor::execStopSound( FFrame& Stack, RESULT_DECL )
{
	// Get parameters.
	P_GET_BYTE(Slot);
	P_FINISH;

	INT Id = GetIndex()*16 + Slot*2;
	if ( GetLevel() && GetLevel()->Engine && GetLevel()->Engine->Audio )
		GetLevel()->Engine->Audio->StopSoundBySlot( this, Id );
}

void AActor::execPlayOwnedSound( FFrame& Stack, RESULT_DECL )
{
	// Get parameters.
	P_GET_OBJECT(USound,Sound);
	P_GET_BYTE_OPTX(Slot,SLOT_Misc);
	P_GET_FLOAT_OPTX(Volume,TransientSoundVolume);
	P_GET_UBOOL_OPTX(bNoOverride, 0);
	P_GET_FLOAT_OPTX(Radius,TransientSoundRadius);
	P_GET_FLOAT_OPTX(Pitch,1.0);
	P_GET_UBOOL_OPTX(bMonitorSound, 0);
	P_FINISH;

	if( !Sound )
		return;
	// if we're recording a demo, make a call to execDemoPlaySound()
	if( (GetLevel() && GetLevel()->DemoRecDriver && !GetLevel()->DemoRecDriver->ServerConnection) )
		eventDemoPlaySound(Sound, Slot, Volume, bNoOverride, Radius, Pitch, bMonitorSound);

	INT Id = GetIndex()*16 + Slot*2 + bNoOverride;
	FLOAT RadiusSquared = Square( Radius ? Radius : 1600.f );
	FVector Parameters = FVector(100 * Volume, Radius, 100 * Pitch);
	if (bMonitorSound)
		Parameters.X = -Parameters.X;

	if( GetLevel()->GetLevelInfo()->NetMode == NM_Client )
	{
		UClient* Client = GetLevel()->Engine->Client;
		if( Client )
		{
			for( INT i=0; i<Client->Viewports.Num(); i++ )
			{
				APlayerPawn* Hearer = Client->Viewports(i)->Actor;
				if( Hearer && Hearer->GetLevel()==GetLevel() )
					CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
			}
		}
	}
	else
	{
		AActor *RemoteOwner = NULL;
		if( GetLevel()->GetLevelInfo()->NetMode != NM_Standalone )
		{
			if ( IsA(APlayerPawn::StaticClass()) )
			{
				if ( ((APlayerPawn *)this)->Player
					&& !((APlayerPawn*)this)->Player->IsA(UViewport::StaticClass()) )
					RemoteOwner = this;
			}
			else if ( Owner && Owner->IsA(APlayerPawn::StaticClass()) && ((APlayerPawn *)Owner)->Player
					&& !((APlayerPawn*)Owner)->Player->IsA(UViewport::StaticClass()) )
				RemoteOwner = Owner;
		}

		for( APawn* Hearer=Level->PawnList; Hearer; Hearer=Hearer->nextPawn )
		{
			if( Hearer->bIsPlayer && (Hearer != RemoteOwner) )
				CheckHearSound(Hearer, Id, Sound, Parameters,RadiusSquared);
		}
	}
}

void AActor::execGetSoundDuration( FFrame& Stack, RESULT_DECL )
{
	// Get parameters.
	P_GET_OBJECT(USound,Sound);
	P_FINISH;

	if ( Sound != NULL )
	{
		FLOAT Dur = Sound->GetDuration();
		*(FLOAT*)Result = Dur;
	}
	else
	{
		UFunction* Caller = Cast<UFunction>( Stack.Node );
		GLog->Logf( TEXT("%s called GetSoundDuration with a null sound."), Caller->GetFullName() );
	}
}

//////////////
// Movement //
//////////////

void AActor::execMove( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Delta);
	P_FINISH;

	FCheckResult Hit(1.0);
	*(DWORD*)Result = GetLevel()->MoveActor( this, Delta, Rotation, Hit );

}

void AActor::execSetLocation( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(NewLocation);
	P_FINISH;

	*(DWORD*)Result = GetLevel()->FarMoveActor( this, NewLocation );
}

void AActor::execSetRotation( FFrame& Stack, RESULT_DECL )
{
	P_GET_ROTATOR(NewRotation);
	P_FINISH;

	FCheckResult Hit(1.0);
	*(DWORD*)Result = GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
}

//////////////
// Mounting //
//////////////

void AActor::execGetMountLocation( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(MountItem);
	P_FINISH;

	UMeshInstance* MeshInst = GetMeshInstance();
	if ( MeshInst )
	{
		FCoords outMountCoords(FVector(0,0,0));
		MeshInst->GetMountCoords( MountItem, MOUNT_MeshSurface, outMountCoords, NULL );
		*(FVector*)Result = FVector(0,0,0).TransformPointBy(outMountCoords);
	} else
		*(FVector*)Result = FVector(0,0,0);
}

void AActor::execSetToMount( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(MountItem);
	P_GET_ACTOR(MountParent);
	P_GET_ACTOR(Mount);
	P_GET_VECTOR_OPTX(MountOffset,FVector(0,0,0));
	P_FINISH;

	UMeshInstance* MeshInst = MountParent->GetMeshInstance();
	if (MeshInst)
	{
		FCoords MountCoords(FVector(0,0,0));
		MeshInst->GetMountCoords( MountItem, MOUNT_MeshSurface, MountCoords, Mount );
		FVector Loc = MountOffset.TransformPointBy(MountCoords);
		FRotator Rot = MountCoords.Transpose().OrthoRotation();
		GetLevel()->FarMoveActor( Mount, Loc );
	}
}

///////////////
// Relations //
///////////////

void AActor::execSetOwner( FFrame& Stack, RESULT_DECL )
{
	P_GET_ACTOR(NewOwner);
	P_FINISH;

	SetOwner( NewOwner );
}

//////////////////
// Line tracing //
//////////////////

void AActor::execTrace( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF(HitLocation); // CDH: optional
	P_GET_VECTOR_REF(HitNormal); // CDH: optional
	P_GET_VECTOR_OPTX(TraceEnd,FCoords(GMath.UnitCoords / Rotation).XAxis*1000.f); // CDH: 1000 units in front of you
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_GET_UBOOL_OPTX(bTraceActors,bCollideActors);
	P_GET_VECTOR_OPTX(TraceExtent,FVector(0,0,0));
	P_GET_UBOOL_OPTX(bMeshAccurate,0);
	P_GET_INT_REF(HitMeshTri); // CDH: optional
	P_GET_VECTOR_REF(HitMeshBarys); // CDH: optional
	P_GET_NAME_REF(HitMeshBoneName); // CDH: optional
	P_GET_OBJECT_REF(UTexture,HitMeshTexture); // CDH: optional
	P_GET_VECTOR_REF(HitUV); // !BR: optional
	P_FINISH;

	// Trace the line.
	FCheckResult Hit(1.0);
	DWORD TraceFlags;
	if( bTraceActors )
		TraceFlags = TRACE_AllColliding | TRACE_ProjTargets;
	else
		TraceFlags = TRACE_VisBlocking;

	GetLevel()->SingleLineCheck( Hit, this, TraceEnd, TraceStart, TraceFlags, TraceExtent, 0, bMeshAccurate );
	
	/*if( Hit.Actor && Hit.Item!=INDEX_NONE )
	{
		UModel*  Model = Hit.Actor->IsA(ULevelInfo::StaticClass) ? XLevel->Model : Actor->Model;
		FBspNode& Node = Model->Nodes( Hit.Item );
		FBspSurf& Surf = Model->Surfs( Node.iSurf );
		UTexture* HitTexture = Surf->Texture;
		//do something with HitTexture
	}*/
	*(AActor**)Result = Hit.Actor;
	*HitLocation      = Hit.Location;
	*HitNormal        = Hit.Normal;
	if (bMeshAccurate) // CDH
	{
		*HitMeshBoneName = Hit.MeshBoneName;
		*HitMeshTri = Hit.MeshTri;
		*HitMeshBarys = Hit.MeshBarys;
		*HitMeshTexture = Hit.MeshTexture;
		*HitUV = Hit.PointUV;
	}
}

void AActor::execFastTrace( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(TraceEnd);
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_FINISH;

	// Trace the line.
	*(DWORD*)Result = GetLevel()->Model->FastLineCheck(TraceEnd, TraceStart);
}

extern void SpeakText(void *string);

void AActor::execSpeakText( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(S);
	P_FINISH;
  
	
//	SpeakText((TCHAR *)*S);
}

void AActor::execNameForString( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(S);
	P_FINISH;
   
	*(FName*)Result=FName(*S);
}


extern UTexture* TraceTexture
(
	AActor*			Actor,
	FCheckResult&	Hit,
	FVector&		SurfBase,
	FVector&		SurfU,
	FVector&		SurfV,
	FVector&		SurfUSize,
	FVector&		SurfVSize,
	FVector			TraceEnd,
	FVector			TraceStart = FVector(0,0,0),
	UTexture        *NewTexture=NULL,
	INT				*SurfaceIndexOut=NULL,
	DWORD			bCalcXY=0,
	INT				*x=NULL,
	INT				*y=NULL
);

void AActor::execTraceTexture(FFrame &Stack, RESULT_DECL)
{
	P_GET_VECTOR(TraceEnd);
	P_GET_VECTOR_OPTX(TraceStart,Location);
	P_GET_OBJECT_OPTX(UTexture,NewTexture,NULL);
	P_GET_VECTOR_REF(SurfBase);
	P_GET_VECTOR_REF(SurfU);
	P_GET_VECTOR_REF(SurfV);
	P_GET_VECTOR_REF(SurfUSize);
	P_GET_VECTOR_REF(SurfVSize);
	P_GET_INT_REF(SurfaceIndexOut);
	P_GET_UBOOL_OPTX(bCalcXY, 0);
	P_GET_INT_REF(x);
	P_GET_INT_REF(y);
	P_FINISH;

	FCheckResult Hit(1.0);

	UTexture* HitTexture=TraceTexture(	this, 
										Hit, 
										*SurfBase, 
										*SurfU, 
										*SurfV, 
										*SurfUSize, 
										*SurfVSize, 
										TraceEnd, 
										TraceStart,
										NewTexture,
										SurfaceIndexOut,
										bCalcXY,
										x,
										y
										);
	*(UTexture**)Result = HitTexture;
}

void AActor::execGetPointRegion(FFrame &Stack, RESULT_DECL)
{
	P_GET_VECTOR(TestPoint);
	P_FINISH;

	FPointRegion TestRegion = GetLevel()->Model->PointRegion( Level, TestPoint );
	*(FPointRegion*)Result = TestRegion;
}

void AActor::execIsInWaterRegion(FFrame &Stack, RESULT_DECL)
{
	P_GET_VECTOR(TestPoint);
	P_FINISH;

	FPointRegion TestRegion = GetLevel()->Model->PointRegion( Level, TestPoint );
	*(UBOOL*)Result = TestRegion.Zone->bWaterZone;
}

void AActor::execTraceWaterPoint(FFrame &Stack, RESULT_DECL)
{
	P_GET_VECTOR(StartTrace);
	P_GET_VECTOR(EndTrace);
	P_FINISH;

	APawn::findWaterLine(GetLevel(), Level, StartTrace, EndTrace);

	*(FVector*)Result = EndTrace;
}

extern INT FindSurfaceByName(AActor *Actor, FName SurfaceTag, INT After=-1 );
void AActor::execFindSurfaceByName(FFrame &Stack, RESULT_DECL)
{
	P_GET_NAME(SurfaceTag);
	P_GET_INT_OPTX(After,-1);
	P_FINISH;

	*(INT *)Result=FindSurfaceByName(this,SurfaceTag,After);

}

//native final function name FindNameForSurface( int SurfaceIndex );
extern FName FindNameForSurface( AActor *Actor, INT SurfaceIndex );
void AActor::execFindNameForSurface(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_FINISH;

	*(FName *)Result=FindNameForSurface(this,SurfaceIndex);
}

extern void SetSurfacePan(AActor *Actor, INT SurfaceIndex, INT PanU=0, INT PanV=0);
void AActor::execSetSurfacePan(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_GET_INT_OPTX(PanU,0);
	P_GET_INT_OPTX(PanV,0);
	P_FINISH;

	SetSurfacePan(this,SurfaceIndex,PanU,PanV);
}

extern int GetSurfaceUPan(AActor *Actor, INT SurfaceIndex);
void AActor::execGetSurfaceUPan(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_FINISH;

	*(INT *)Result=GetSurfaceUPan(this,SurfaceIndex);
}

extern int GetSurfaceVPan(AActor *Actor, INT SurfaceIndex);
void AActor::execGetSurfaceVPan(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_FINISH;

	*(INT *)Result=GetSurfaceVPan(this,SurfaceIndex);
}

extern UTexture *GetSurfaceTexture(AActor *Actor, INT SurfaceIndex);
void AActor::execGetSurfaceTexture(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_FINISH;

	*(UTexture **)Result=GetSurfaceTexture(this,SurfaceIndex);
}

extern void SetSurfaceTexture(AActor *Actor, INT SurfaceIndex, UTexture *NewTexture);
void AActor::execSetSurfaceTexture(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_GET_OBJECT(UTexture,NewTexture);
	P_FINISH;

	SetSurfaceTexture(this,SurfaceIndex,NewTexture);
}

extern void SetSurfaceName(AActor* Actor, INT SurfaceIndex, FName NewName);
void AActor::execSetSurfaceName(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(SurfaceIndex);
	P_GET_NAME(SurfaceName);
	P_FINISH;

	SetSurfaceName(this,SurfaceIndex,SurfaceName);
}

extern void RenameAllSurfaces(AActor* Actor, FName OldName, FName NewName);
void AActor::execRenameAllSurfaces(FFrame &Stack, RESULT_DECL)
{
	P_GET_NAME(OldName);
	P_GET_NAME(NewName);
	P_FINISH;

	RenameAllSurfaces(this,OldName,NewName);
}

void AActor::execMeshGetTexture(FFrame &Stack, RESULT_DECL)
{
	P_GET_INT(TextureNum);
	P_FINISH;

	if ((Mesh != NULL) && Mesh->GetInstance(this))
		*(UTexture**)Result = Mesh->GetInstance(this)->GetTexture(TextureNum);
}

///////////////////////
// Spawn and Destroy //
///////////////////////

void AActor::execSpawn( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,SpawnClass);
	P_GET_OBJECT_OPTX(AActor,SpawnOwner,NULL); 
	P_GET_NAME_OPTX(SpawnName,NAME_None);
	P_GET_VECTOR_OPTX(SpawnLocation,Location);
	P_GET_ROTATOR_OPTX(SpawnRotation,Rotation);
	P_FINISH;

	// Spawn and return actor.
	AActor* Spawned = SpawnClass ? GetLevel()->SpawnActor
	(
		SpawnClass,
		NAME_None,
		SpawnOwner,
		Instigator,
		SpawnLocation,
		SpawnRotation,
		SpawnName
	) : NULL;
	*(AActor**)Result = Spawned;
}

void AActor::execDestroy( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	
	*(DWORD*)Result = GetLevel()->DestroyActor( this );
}

////////////
// Timing //
////////////

void AActor::execSetTimer( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(NewTimerRate);
	P_GET_UBOOL(bLoop);
	P_GET_INT_OPTX(TimerNum,0);
	P_FINISH;

	if (TimerNum > MaxTimers)
		TimerNum = MaxTimers;
	TimerCounter[TimerNum]	= 0.0;
	TimerRate[TimerNum]		= NewTimerRate;
	if (bLoop)
		TimerLoop[TimerNum]	= 1;
	else
		TimerLoop[TimerNum]	= 0;
}

void AActor::execSetCallbackTimer( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(NewTimerRate);
	P_GET_UBOOL(bLoop);
	P_GET_NAME(CallbackName);
	P_FINISH;

	UFunction* Callback = FindFunction( CallbackName );
	if ( Callback == NULL )
		return;

	// Look for a timer that matches.
	for ( INT i=0; i<CallbackTimerPointers.Num(); i++ )
	{
		if ( CallbackTimerPointers(i) == (INT) Callback )
		{
			CallbackTimerRates(i) = NewTimerRate;
			CallbackTimerLoops(i) = (INT) bLoop;
			CallbackTimerCounters(i) = 0.f;
			return;
		}
	}

	// If no match, create a new timer.
	CallbackTimerRates.AddItem( NewTimerRate );
	CallbackTimerLoops.AddItem( (INT) bLoop );
	CallbackTimerPointers.AddItem( (INT) Callback );
	CallbackTimerCounters.AddItem( 0.f );
}

void AActor::execEndCallbackTimer( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(CallbackName);
	P_FINISH;

	UFunction* Callback = FindFunction( CallbackName );
	if ( Callback == NULL )
		return;

	// Find the callback timer which matches this function and remove it.
	for ( INT i=0; i<CallbackTimerPointers.Num(); i++ )
	{
		if ( CallbackTimerPointers(i) == (INT) Callback )
		{
			CallbackTimerRates.Remove(i);
			CallbackTimerCounters.Remove(i);
			CallbackTimerPointers.Remove(i);
			CallbackTimerLoops.Remove(i);
			return;
		}
	}
}

void AActor::execSetTimerCounter( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(TimerNum);
	P_GET_FLOAT(NewTimerCounter);
	P_FINISH;

	if ( TimerNum > MaxTimers )
		TimerNum = MaxTimers;
	TimerCounter[TimerNum]	= NewTimerCounter;
}

void AActor::execCallFunctionByName( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(CallbackName);
	P_FINISH;

	UFunction* Callback = FindFunction( CallbackName );
	if ( Callback == NULL )
		return;

	// Call the function they gave us.
	ProcessEvent( Callback, NULL );
}

////////////////
// Warp zones //
////////////////

void AWarpZoneInfo::execWarp( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF(WarpLocation);
	P_GET_VECTOR_REF(WarpVelocity);
	P_GET_ROTATOR_REF(WarpRotation);
	P_FINISH;

	// Perform warping.
	*WarpLocation = (*WarpLocation).TransformPointBy ( WarpCoords.Transpose() );
	*WarpVelocity = (*WarpVelocity).TransformVectorBy( WarpCoords.Transpose() );
	*WarpRotation = (GMath.UnitCoords / *WarpRotation * WarpCoords.Transpose()).OrthoRotation();
}

void AWarpZoneInfo::execUnWarp( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF(WarpLocation);
	P_GET_VECTOR_REF(WarpVelocity);
	P_GET_ROTATOR_REF(WarpRotation);
	P_FINISH;

	// Perform unwarping.
	*WarpLocation = (*WarpLocation).TransformPointBy ( WarpCoords );
	*WarpVelocity = (*WarpVelocity).TransformVectorBy( WarpCoords );
	*WarpRotation = (GMath.UnitCoords / *WarpRotation * WarpCoords).OrthoRotation();
}

/*-----------------------------------------------------------------------------
	Native iterator functions.
-----------------------------------------------------------------------------*/

void AActor::execAllActors( FFrame& Stack, RESULT_DECL )
{
	// NJS: To see who's calling me
	// Get the parms.
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_GET_NAME_OPTX(TagName,NAME_None);
	P_FINISH;

	//debugf(TEXT("** execAllActors:%s (Class:%s, Tag:%s)"),GetName()/**Tag*/,BaseClass->GetName(),*TagName);

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;
	ULevel* CurrentLevel=GetLevel();	// NJS: If there is ever need for a level change in a foreach allactors, move this into the main loop below

	// PreIterator:
	INT wEndOffset = Stack.ReadWord(); 
	BYTE B=0, Buffer[MAX_CONST_SIZE]; 
	BYTE *StartCode = Stack.Code; 
	do 
	{
		// Fetch next actor in the iteration.
		AActor *TestActor;
		INT MaxActors=CurrentLevel->Actors.Num();

		// NJS: Reordered the loop for a bit of a speed improvement:
		// NJS: Special case the AActor class (ie. the IsA can be eliminated)
		if(BaseClass==AActor::StaticClass())
		{
			if(TagName==NAME_None)	// Search for every actor. (Disreguard it's tag)
			{
				while( iActor<MaxActors )
				{
					TestActor = CurrentLevel->Actors(iActor++);
					if(	TestActor )
						goto SkipNullCheck; //break;
				}
			} else	// Search for an actor with a particular tag.
			{
				while(iActor<MaxActors)
				{
					TestActor=CurrentLevel->Actors(iActor++);
					if(TestActor&&TestActor->Tag==TagName)
						goto SkipNullCheck; //break;
				}

			}

		} else if(TagName==NAME_None)	// Search for an actor of any class, disreguarding it's tag
		{
			while(iActor<MaxActors)
			{
				TestActor=CurrentLevel->Actors(iActor++);
				if(TestActor&&TestActor->IsA(BaseClass) )
					goto SkipNullCheck; //break;
			}

		} else
		{
			while( iActor<MaxActors )	// Search for an actor of any class, taking it's tag into account
			{
				TestActor = CurrentLevel->Actors(iActor++);
				if(	TestActor && TestActor->Tag==TagName && TestActor->IsA(BaseClass) )
					goto SkipNullCheck; //break;
			}
		}

		// No Actor was found this round:
		*OutActor = NULL;
		Stack.Code = &Stack.Node->Script(wEndOffset + 1);
		return;

	SkipNullCheck:	// Jump here to skip the NULL check, when we know the actor isn't NULL
		*OutActor=TestActor;
		// Post Iterator
		while( (B=*Stack.Code)!=EX_IteratorPop && B!=EX_IteratorNext ) 
			Stack.Step( Stack.Object, Buffer ); 
		if( *Stack.Code++==EX_IteratorNext ) 
			Stack.Code = StartCode; 

	} while( B != EX_IteratorPop );

}

void AActor::execChildActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;

	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		while( iActor<GetLevel()->Actors.Num() && *OutActor==NULL )
		{
			AActor* TestActor = GetLevel()->Actors(iActor++);
			if(	TestActor && TestActor->IsA(BaseClass) && TestActor->IsOwnedBy( this ) )
				*OutActor = TestActor;
		}
		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

void AActor::execBasedActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;

	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		while( iActor<GetLevel()->Actors.Num() && *OutActor==NULL )
		{
			AActor* TestActor = GetLevel()->Actors(iActor++);
			if(	TestActor && TestActor->IsA(BaseClass) && TestActor->Base==this )
				*OutActor = TestActor;
		}
		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

void AActor::execTouchingActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iTouching=0;

	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		for( iTouching; iTouching<Touching.Num() && *OutActor==NULL; iTouching++ )
		{
			AActor* TestActor = Touching(iTouching);
			if(	TestActor && TestActor->IsA(BaseClass) )
				*OutActor = TestActor;
		}
		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

void AActor::execTraceActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_GET_VECTOR_REF(HitLocation);
	P_GET_VECTOR_REF(HitNormal);
	P_GET_VECTOR(End);
	P_GET_VECTOR_OPTX(Start,Location);
	P_GET_VECTOR_OPTX(TraceExtent,FVector(0,0,0));
	P_FINISH;

	FMemMark Mark(GMem);
	BaseClass         = BaseClass ? BaseClass : AActor::StaticClass();
	FCheckResult* Hit = GetLevel()->MultiLineCheck( GMem, End, Start, TraceExtent, 1, Level, 0 );

	PRE_ITERATOR;
		if( Hit )
		{
			*OutActor    = Hit->Actor;
			*HitLocation = Hit->Location;
			*HitNormal   = Hit->Normal;
			Hit          = Hit->GetNext();
		}
		else
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			*OutActor = NULL;
			break;
		}
	POST_ITERATOR;
	Mark.Pop();
}

void AActor::execRadiusActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_GET_FLOAT(Radius);
	P_GET_VECTOR_OPTX(TraceLocation,Location);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;

	PRE_ITERATOR;
		
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		ULevel* CurrentLevel=GetLevel();
		INT MaxActors=CurrentLevel->Actors.Num();

		// NJS: Unrolled the loop a bit:
		if(BaseClass==AActor::StaticClass())	// If the base class is AActor, then I can remove the IsA
		{
			while( iActor<MaxActors && *OutActor==NULL )
			{
				AActor* TestActor = CurrentLevel->Actors(iActor++);
				if
				(	TestActor
				&&	(TestActor->Location-TraceLocation).SizeSquared()<Square(Radius+TestActor->CollisionRadius))
					*OutActor = TestActor;
			}
		} else	// Base class is something other than actor
		{
			while( iActor<MaxActors && *OutActor==NULL )
			{
				AActor* TestActor = CurrentLevel->Actors(iActor++);
				if
				(	TestActor
				&&	TestActor->IsA(BaseClass) 
				&&	(TestActor->Location-TraceLocation).SizeSquared()<Square(Radius+TestActor->CollisionRadius))
					*OutActor = TestActor;
			}
		}

		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

void AActor::execVisibleActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_GET_FLOAT_OPTX(Radius,0.0);
	P_GET_VECTOR_OPTX(TraceLocation,Location);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;

	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		while( iActor<GetLevel()->Actors.Num() && *OutActor==NULL )
		{
			AActor* TestActor = GetLevel()->Actors(iActor++);
			if
			(	TestActor
			&& !TestActor->bHidden
			&&	TestActor->IsA(BaseClass)
			&&	(Radius==0.0 || (TestActor->Location-TraceLocation).SizeSquared() < Square(Radius))
			&&	GetLevel()->Model->FastLineCheck(TestActor->Location, TraceLocation) )
				*OutActor = TestActor;
		}
		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

void AActor::execVisibleCollidingActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_GET_FLOAT_OPTX(Radius,0.0);
	P_GET_VECTOR_OPTX(TraceLocation,Location);
	P_GET_UBOOL_OPTX(bIgnoreHidden, 0);
	P_FINISH;

	Radius = Radius ? Radius : 1000;
	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	FMemMark Mark(GMem);
	FCheckResult* Link=GetLevel()->Hash->ActorRadiusCheck( GMem, TraceLocation, Radius, 0 );
	
	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		if ( Link )
		{
			while
			(	Link
			&&	(!Link->Actor
			||	!Link->Actor->IsA(BaseClass) 
			||  (bIgnoreHidden && Link->Actor->bHidden)
			||	(!Link->Actor->IsA(AMover::StaticClass()) && !GetLevel()->Model->FastLineCheck(Link->Actor->Location, TraceLocation))) )
				Link=Link->GetNext();

			if ( Link )
			{
				*OutActor = Link->Actor;
				Link=Link->GetNext();
			}
		}
		if ( *OutActor == NULL ) 
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;

	Mark.Pop();
}

void AZoneInfo::execZoneActors( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_ACTOR_REF(OutActor);
	P_FINISH;

	BaseClass = BaseClass ? BaseClass : AActor::StaticClass();
	INT iActor=0;

	PRE_ITERATOR;
		// Fetch next actor in the iteration.
		*OutActor = NULL;
		while( iActor<GetLevel()->Actors.Num() && *OutActor==NULL )
		{
			AActor* TestActor = GetLevel()->Actors(iActor++);
			if
			(	TestActor
			&&	TestActor->IsA(BaseClass)
			&&	TestActor->IsInZone(this) )
				*OutActor = TestActor;
		}
		if( *OutActor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
}

/*-----------------------------------------------------------------------------
	Script processing function.
-----------------------------------------------------------------------------*/

//
// Execute the state code of the actor.
//
void AActor::ProcessState( FLOAT DeltaSeconds )
{
	if
	(	GetStateFrame()
	&&	GetStateFrame()->Code
	&&	(Role>=ROLE_Authority || (GetStateFrame()->StateNode->StateFlags & STATE_Simulated))
	&&	!IsPendingKill() )
	{
		UState* OldStateNode = GetStateFrame()->StateNode;
		guard(AActor::ProcessState);
		if( ++GScriptEntryTag==1 )
			clock(GScriptCycles);

		// If a latent action is in progress, update it.
		if( GetStateFrame()->LatentAction )
			(this->*GNatives[GetStateFrame()->LatentAction])( *GetStateFrame(), (BYTE*)&DeltaSeconds );

		// Execute code.
		INT NumStates=0;
		while( !bDeleteMe && GetStateFrame()->Code && !GetStateFrame()->LatentAction )
		{
			BYTE Buffer[MAX_CONST_SIZE];
			GetStateFrame()->Step( this, Buffer );
			if( GetStateFrame()->StateNode!=OldStateNode )
			{
				OldStateNode = GetStateFrame()->StateNode;
				if( ++NumStates > 4 )
				{
					//GetStateFrame().Logf( "Pause going from %s to %s", xx, yy );
					break;
				}
			}
		}
		if( --GScriptEntryTag==0 )
			unclock(GScriptCycles);
		unguardf(( TEXT("Object %s, Old State %s, New State %s"), GetFullName(), OldStateNode->GetFullName(), GetStateFrame()->StateNode->GetFullName() ));
	}
}

//
// Internal RPC calling.
//
static inline void InternalProcessRemoteFunction
(
	AActor*			Actor,
	UNetConnection*	Connection,
	UFunction*		Function,
	void*			Parms,
	FFrame*			Stack,
	UBOOL			IsServer
)
{
	Actor->GetLevel()->NumRPC++;

	// Make sure this function exists for both parties.
	FClassNetCache* ClassCache = Connection->PackageMap->GetClassNetCache( Actor->GetClass() );
	if( !ClassCache )
		return;
	FFieldNetCache* FieldCache = ClassCache->GetFromField( Function );
	if( !FieldCache )
		return;

	// Get the actor channel.
	UActorChannel* Ch = Connection->ActorChannels.FindRef(Actor);
	if( !Ch )
	{
		if( IsServer )
			Ch = (UActorChannel *)Connection->CreateChannel( CHTYPE_Actor, 1 );
		if( !Ch )
			return;
		if( IsServer )
			Ch->SetChannelActor( Actor );
	}

	// Make sure initial channel-opening replication has taken place.
	if( Ch->OpenPacketId==INDEX_NONE )
	{
		if( !IsServer )
			return;
		Ch->ReplicateActor();
	}

	// Form the RPC preamble.
	FOutBunch Bunch( Ch, 0 );
	//debugf(TEXT("   Call %s"),Function->GetFullName());
	Bunch.WriteInt( FieldCache->FieldNetIndex, ClassCache->GetMaxIndex() );

	// Form the RPC parameters.
	if( Stack )
	{
		appMemzero( Parms, Function->ParmsSize );
		for( TFieldIterator<UProperty> It(Function); It && (It->PropertyFlags & (CPF_Parm|CPF_ReturnParm))==CPF_Parm; ++It )
			Stack->Step( Stack->Object, (BYTE*)Parms + It->Offset );            
		checkSlow(*Stack->Code==EX_EndFunctionParms);
	}
	for( TFieldIterator<UProperty> It(Function); It && (It->PropertyFlags & (CPF_Parm|CPF_ReturnParm))==CPF_Parm; ++It )
	{
		if( Connection->PackageMap->ObjectToIndex(*It)!=INDEX_NONE )
		{
			UBOOL Send = 1;
			if( !It->IsA(UBoolProperty::StaticClass()) )
			{
				Send = !It->Matches(Parms,NULL,0);
				Bunch.WriteBit( Send );
			}
			if( Send )
                It->NetSerializeItem( Bunch, Connection->PackageMap, (BYTE*)Parms + It->Offset );
		}
	}

	// Reliability.
	//warning: RPC's might overflow, preventing reliable functions from getting thorough.
	if( Function->FunctionFlags & FUNC_NetReliable )
		Bunch.bReliable = 1;

	// Send the bunch.
	if( !Bunch.IsError() )
		Ch->SendBunch( &Bunch, 1 );
	else
		debugf( NAME_DevNet, TEXT("RPC bunch overflowed") );
}

//
// Return whether a function should be executed remotely.
//
UBOOL AActor::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessRemoteFunction);

	// Quick reject.
	if( (Function->FunctionFlags & FUNC_Static) || bDeleteMe )
		return 0;
	UBOOL Absorb = Role<=ROLE_SimulatedProxy && !(Function->FunctionFlags & FUNC_Simulated);
	if( GetLevel()->DemoRecDriver )
	{
		if( GetLevel()->DemoRecDriver->ServerConnection )
			return Absorb;
		ProcessDemoRecFunction( Function, Parms, Stack );
	}
	if( Level->NetMode==NM_Standalone )
		return 0;
	if( !(Function->FunctionFlags & FUNC_Net) )
		return Absorb;

	// Check if the actor can potentially call remote functions.
	APlayerPawn*    Top              = Cast<APlayerPawn>(GetTopOwner());
	UNetConnection* ClientConnection = NULL;
	if
	(	(Role==ROLE_Authority) && !(Function->FunctionFlags & FUNC_Multicast)
	&&	(Top==NULL || (ClientConnection=Cast<UNetConnection>(Top->Player))==NULL) )
		return Absorb;

	// See if UnrealScript replication condition is met.
	while( Function->GetSuperFunction() )
		Function = Function->GetSuperFunction();
	UBOOL Val=0;
	FFrame( this, Function->GetOwnerClass(), Function->RepOffset, NULL ).Step( this, &Val );
	if( !Val )
		return Absorb;

	// Get the connection.
	UBOOL           IsServer   = Level->NetMode==NM_DedicatedServer || Level->NetMode==NM_ListenServer;
	UNetConnection* Connection = IsServer ? ClientConnection : GetLevel()->NetDriver->ServerConnection;
	
	TArray<UNetConnection*> ConnectionList;
	
	// Multicast function, send to all client connections, otherwise just send it to the 1 client
	if( Function->FunctionFlags & FUNC_Multicast )
		ConnectionList = XLevel->NetDriver->ClientConnections;
	else
		ConnectionList.AddItem( Connection );

	for( INT i=0; i<ConnectionList.Num(); i++ )
	{
		UNetConnection* Connection = ConnectionList(i);
		check(Connection);

		// If saturated and function is unimportant, skip it.
		if( !(Function->FunctionFlags & FUNC_NetReliable) && !Connection->IsNetReady(0) )
			continue;

		// Send function data to remote.
		InternalProcessRemoteFunction( this, Connection, Function, Parms, Stack, IsServer );
	}

	return 1;
	unguardf(( TEXT("(%s)"), Function->GetFullName() ));
}

// Replicate a function call to a demo recording file
void AActor::ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessDemoRecFunction);

	// Check if the function is replicatable
	if( (Function->FunctionFlags & (FUNC_Static|FUNC_Net))!=FUNC_Net || bNetTemporary )
		return;

	UBOOL IsNetClient = (GetLevel()->GetLevelInfo()->NetMode == NM_Client);

	// Check if actor was spawned locally in a client-side demo 
	if(IsNetClient && Role == ROLE_Authority)
		return;

	// See if UnrealScript replication condition is met.
	while( Function->GetSuperFunction() )
		Function = Function->GetSuperFunction();

	UBOOL Val=0;
	if(IsNetClient)
		Exchange(RemoteRole, Role);
	bDemoRecording = 1;
	bClientDemoRecording = IsNetClient;
	FFrame( this, Function->GetOwnerClass(), Function->RepOffset, NULL ).Step( this, &Val );
	bDemoRecording = 0;
	bClientDemoRecording = 0;
	if(IsNetClient)
		Exchange(RemoteRole, Role);
	bClientDemoNetFunc = 0;
	if( !Val )
		return;

	// Get the channel.
	UNetConnection* Connection = GetLevel()->DemoRecDriver->ClientConnections(0);
	check(Connection);

	// Send function data to remote.
	BYTE* SavedCode = Stack ? Stack->Code : NULL;
	InternalProcessRemoteFunction( this, Connection, Function, Parms, Stack, 1 );
	if( Stack )
		Stack->Code = SavedCode;

	unguardf(( TEXT("(%s/%s)"), GetName(), Function->GetFullName() ));
}

/*-----------------------------------------------------------------------------
	GameInfo
-----------------------------------------------------------------------------*/

//
// Network
//
void AGameInfo::execGetNetworkNumber( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execNetworkNumber);
	P_FINISH;

	*(FString*)Result = XLevel->NetDriver ? XLevel->NetDriver->LowLevelGetNetworkNumber() : FString(TEXT(""));

	unguardexec;
}

//
// Deathmessage parsing.
//
void AGameInfo::execParseKillMessage( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execParseKillMessage);
	P_GET_STR(KillerName);
	P_GET_STR(VictimName);
	P_GET_STR(WeaponName);
	P_GET_STR(KillMessage);
	P_FINISH;

	FString Message, Temp;
	INT Offset;

	Temp = KillMessage;

	Offset = Temp.InStr(TEXT("%k"));
	if (Offset != -1)
	{
		Message = Temp.Left(Offset);
		Message += KillerName;
		Message += Temp.Right(Temp.Len() - Offset - 2);
	}
	Temp = Message;

	Offset = Temp.InStr(TEXT("%o"));
	if (Offset != -1)
	{
		Message = Temp.Left(Offset);
		Message += VictimName;
		Message += Temp.Right(Temp.Len() - Offset - 2);
	}
	Temp = Message;

	Offset = Temp.InStr(TEXT("%w"));
	if (Offset != -1)
	{
		Message = Temp.Left(Offset);
		Message += WeaponName;
		Message += Temp.Right(Temp.Len() - Offset - 2);
	}

	*(FString*)Result = Message;

	unguardexec;
}

/*-----------------------------------------------------------------------------
	ADecal Implementation
-----------------------------------------------------------------------------*/

// Find the coplanar surface corresponding to this intersection point.
static INT FindCoplanarSurface( UModel* Model, INT iNode, FVector IntersectionPoint, INT Depth )
{
	guard(FindCoplanarSurface);
	if( iNode == INDEX_NONE )
		return INDEX_NONE;

	FBspNode* Node = &Model->Nodes( iNode );
	if( Node->NumVertices > 0)
	{
		// check if this intersection point lies inside this node.
		FVert* Verts = &Model->Verts( Node->iVertPool );
		FVector &SurfNormal = Model->Vectors( Model->Surfs( Node->iSurf).vNormal );

		FVector* PrevVertex = &Model->Points( Verts[Node->NumVertices - 1].pVertex );
		UBOOL Success = 1;
		FLOAT PrevDot = 0;
		for( INT i=0;i<Node->NumVertices;i++ )
		{
			FVector* Vertex = &Model->Points(Verts[i].pVertex);
			FVector ClipNorm = SurfNormal ^ (*Vertex - *PrevVertex);
			FPlane ClipPlane( *Vertex, ClipNorm );

			FLOAT Dot = ClipPlane.PlaneDot( IntersectionPoint );
			
			if( (Dot < 0 && PrevDot > 0) ||
				(Dot > 0 && PrevDot < 0) )
			{
				Success = 0;
				break;
			}
			PrevDot = Dot;
			PrevVertex = Vertex;
		}
		if( Success )
			return Node->iSurf;
	}

	// check next co-planars to see if it contains this intersection point.
	return FindCoplanarSurface( Model, Node->iPlane, IntersectionPoint, Depth + 1 );
	unguard;
}

static void CalcClippedNodes( UModel* Model, FBspSurf& Surf, FVector* DecalVerts, TArray<INT>& NodeArray )
{
	guard(CalcClippedNodes);

	for( INT n=0;n<Surf.Nodes.Num(); n++)
	{
		FBspNode* Node = &Model->Nodes( Surf.Nodes(n) );
		
		if( Node->NumVertices > 0)
		{
			static FVector	Pts[FBspNode::MAX_FINAL_VERTICES];
			static FLOAT	Dots[FBspNode::MAX_FINAL_VERTICES];
			int NumPts;

			for( INT i=0;i<4;i++ )
				Pts[i] = DecalVerts[i];
			NumPts = 4;

			// check if this node contains any of the decal
			FVert* Verts = &Model->Verts( Node->iVertPool );
			FVector &SurfNormal = Model->Vectors( Surf.vNormal );

			FVector* PrevVertex = &Model->Points( Verts[Node->NumVertices - 1].pVertex );
			UBOOL Success = 1;
			for( i=0;i<Node->NumVertices;i++ )
			{
				FVector* Vertex = &Model->Points(Verts[i].pVertex);
				FVector ClipNorm = SurfNormal ^ (*Vertex - *PrevVertex);
				FPlane ClipPlane( *Vertex, ClipNorm );

				for(INT j=0;j<NumPts;j++)
					Dots[j] = ClipPlane.PlaneDot( Pts[j] );
				for(j=0;j<NumPts;j++)
				{
					if(		(Dots[j] > 0 && Dots[(j+1)%NumPts] < 0) 
						||	(Dots[j] < 0 && Dots[(j+1)%NumPts] > 0))
					{
						guard(InsertClippingPoint);
						FVector NewPoint = FLinePlaneIntersection( Pts[j], Pts[(j+1)%NumPts], ClipPlane );
						if(j < NumPts-1)
						{	
							// move Dots[] and Pts[] arrays along
							appMemmove( &Dots[j+2], &Dots[j+1], sizeof(FLOAT) * (NumPts - j - 1));
							appMemmove( &Pts[j+2], &Pts[j+1], sizeof(FVector) * (NumPts - j - 1));
						}
						Pts[j+1] = NewPoint;
						Dots[j+1] = 0; 
						NumPts++;
						j++;
						check(NumPts < FBspNode::MAX_FINAL_VERTICES);
						unguard;
					}			
				}
				guard(DeleteClippedPoints);
				for(j=0;j<NumPts;j++)
				{
					if( Dots[j] < 0 )
					{
						appMemmove( &Dots[j], &Dots[j+1], sizeof(FLOAT) * (NumPts - j - 1));
						appMemmove( &Pts[j], &Pts[j+1], sizeof(FVector) * (NumPts - j - 1) );
						j--;
						NumPts--;
					}
				}
				unguard;
				if( NumPts == 0 )
				{
					Success = 0;
					break;
				}
				PrevVertex = Vertex;
			}
			if( Success )
				NodeArray.AddItem( Surf.Nodes(n) );
		}
	}
	unguard;
}

/*
static DWORD GetPolyFlags( AActor* Owner )
{
	DWORD PolyFlags=0;

	if     (Owner->Style==STY_Masked     ) PolyFlags|=PF_Masked;
	else if(Owner->Style==STY_Translucent) PolyFlags|=PF_Translucent;
	else if(Owner->Style==STY_Modulated  ) PolyFlags|=PF_Modulated;

	if( Owner->bNoSmooth     ) PolyFlags|=PF_NoSmooth;
	if( Owner->bSelected     ) PolyFlags|=PF_Selected;
	if( Owner->bMeshEnviroMap) PolyFlags|=PF_Environment;
	if(!Owner->bMeshCurvy    ) PolyFlags|=PF_Flat;

	return PolyFlags;
}
*/

void ADecal::execAttachDecal( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(TraceDistance);
	P_GET_VECTOR_OPTX(DecalDir,FVector(0,0,0));
	P_GET_FLOAT_OPTX(ScaleX,1.f);
	P_GET_FLOAT_OPTX(ScaleY,1.f);
	P_FINISH;

	ScaleX=10.f;

	*(INT*)Result = 0;
	if( !GetLevel()->Engine->Client || !GetLevel()->Engine->Client->Decals )
		return;

	if( Region.Zone->bFogZone )
		return;
	if(!Texture)
	{
		debugf(TEXT("AttachDecal: No Texture"));
		return;
	}
	MultiDecalLevel = Min<INT>(MultiDecalLevel, 4);

	UModel *Model = Level->XLevel->Model;
	FCheckResult Hit(1.0);
	FVector EndVect = -1 * Rotation.Vector(); // assume rotation oriented in direction of hitnormal
	EndVect.Normalize(); // FIXME - Jack, no need to do this - EndVect already normalized
	EndVect *= TraceDistance;

	INT RandDir = 0;
	if ( DecalDir.IsZero() && RandomRotation )
	{
		DecalDir = VRand();
		RandDir = 1;
	}

	if( Model->LineCheck( Hit, NULL, Location + EndVect, Location, FVector(0, 0, 0), TRACE_VisBlocking ) != 0 ||
	    Hit.Item == INDEX_NONE )
	{
		return;
	}
	else
	{
		FBspSurf &Surf = Model->Surfs( Model->Nodes(Hit.Item).iSurf );

		// Don't attach a decal to a masked surface.
		if ( Surf.PolyFlags & PF_Masked )
			return;
		if ( Surf.Texture && (Surf.Texture->PolyFlags & PF_Masked) )
			return;

		FVector &SurfNormal = Model->Vectors(Surf.vNormal);
		FVector &SurfBase = Model->Points(Surf.pBase);
		FVector Intersection = FLinePlaneIntersection( Location,  Location + EndVect, SurfBase, SurfNormal );
		INT SurfIndex = FindCoplanarSurface( Model, Hit.Item, Intersection, 0 );
	
		if( SurfIndex == INDEX_NONE )
			return;
	
		guard(SetupMain);
		// setup vertices for main decal surface.
		FBspSurf &Surf = Model->Surfs(SurfIndex);
		FVector &SurfNormal = Model->Vectors(Surf.vNormal);
		FVector &SurfBase = Model->Points(Surf.pBase);
		FVector DecalCenter = FLinePlaneIntersection( Location, Location + EndVect, SurfBase, SurfNormal );

		FLOAT d = Rotation.Vector() | SurfNormal;
		if( !d )
		{
			//debugf(TEXT("AttachDecal: decal ray is parallel to surface"));
			return;
		}
		if(Abs(((SurfBase - DecalCenter) | SurfNormal)) > 0.001f )
		{
			//debugf(TEXT("AttachDecal: Couldn't place decal: dot product is %f"), ((SurfBase - DecalCenter) | SurfNormal));
			return;
		}

		if( Surf.PolyFlags & (PF_AutoUPan|PF_AutoVPan) )
			return;

		// NJS: Code to keep decals from spawning too close to other decals.
		if(MinSpawnDistance!=0)
		{
			for( INT j=0;j<Surf.Decals.Num();j++)
				if(FDistSquared(DecalCenter, Surf.Decals(j).Location)<Square(MinSpawnDistance))	// CAN'T REFER TO ACTOR!
					return;
		}

		// attach decal to new surface
		FDecal* MainDecal = NULL;
		for( INT j=0;j<Surf.Decals.Num();j++)
			if(Surf.Decals(j)./*Actor->*/Texture == Texture)
			{
				Surf.Decals.InsertZeroed(j);
				MainDecal = &Surf.Decals(j);					
				break;
			}
		if(!MainDecal) 
			MainDecal = &Surf.Decals(Surf.Decals.AddZeroed());	
		
		// NJS: Initialize Decal:
		MainDecal->Actor = (Behavior==DB_Normal)?this:NULL;
		MainDecal->Texture=Texture;
		MainDecal->DrawScale=DrawScale;
		MainDecal->AmbientGlow=AmbientGlow;
		MainDecal->ScaleGlow=ScaleGlow;

		STY2PolyFlags(NULL,MainDecal->PolyFlags,MainDecal->PolyFlagsEx);
		//MainDecal->PolyFlags=GetPolyFlags(this);
		MainDecal->PolyFlagsEx|=Texture->PolyFlagsEx;
		MainDecal->SpawnTime=MainDecal->LastRenderedTime=Level->TimeSeconds;
		MainDecal->Location=DecalCenter;
		MainDecal->Behavior=Behavior;
		MainDecal->BehaviorArgument=BehaviorArgument;

		SurfList.AddItem(SurfIndex);

		if ( !RandDir )
		{
			// Project DecalDir onto the surface.
			FVector MainAxis = DecalDir - (DecalDir | SurfNormal) * SurfNormal;

			if ( MainAxis.IsNearlyZero() )
			{
				MainAxis = DecalDir = ( SurfBase - DecalCenter );
				RandDir = 1;
			}
			else
			{
				// Then we cross with the normal to get the other axis.
				FVector OtherAxis = MainAxis ^ SurfNormal;
				MainAxis.Normalize();
				OtherAxis.Normalize();

				// Calculate the vector from the center to the diagonal.
				MainDecal->Vertices[0] = MainAxis + OtherAxis;
				MainDecal->Vertices[1] = MainAxis - OtherAxis;
			}
		}
		if ( RandDir )
		{
			// Calculate the vector from the center to the diagonal.
			MainDecal->Vertices[0] = DecalDir - (DecalDir | SurfNormal) * SurfNormal;
			MainDecal->Vertices[1] = MainDecal->Vertices[0] ^ SurfNormal;
		}

		// Calculate a rectangular decal.
		FLOAT USize = 0.f;
		if (UScale > 0.f)
			USize = Texture->USize * UScale;
		else
			USize = Texture->USize * DrawScale;
		FLOAT VSize = 0.f;
		if (VScale > 0.f)
			VSize = Texture->VSize * VScale;
		else
			VSize = Texture->VSize * DrawScale;
		MainDecal->Vertices[0].Normalize();
		MainDecal->Vertices[1].Normalize();
		FVector TopMiddle = MainDecal->Vertices[0];
		FVector LeftMiddle = MainDecal->Vertices[1];
		FVector TopComponent = TopMiddle * (VSize/2);
		FVector LeftComponent = LeftMiddle * (USize/2);
		MainDecal->Vertices[0] = TopComponent - LeftComponent;
		MainDecal->Vertices[1] = TopComponent + LeftComponent;
		MainDecal->Vertices[2] = -MainDecal->Vertices[0];
		MainDecal->Vertices[3] = -MainDecal->Vertices[1];

		// Translate the vertices into place.
		MainDecal->Vertices[0] += DecalCenter;
		MainDecal->Vertices[1] += DecalCenter;
		MainDecal->Vertices[2] += DecalCenter;
		MainDecal->Vertices[3] += DecalCenter;
		CalcClippedNodes( Model, Surf, MainDecal->Vertices, MainDecal->Nodes );

		FLOAT NormSize = SurfNormal.Size();
		FVector TraceVect = -10*(SurfNormal / NormSize);
		for (INT i=1; i<4; i++)
		{
			FVector TracePoint = MainDecal->Vertices[i];
			if( Model->LineCheck( Hit, NULL, TracePoint + TraceVect, TracePoint - TraceVect, FVector(0, 0, 0), TRACE_VisBlocking ) == 0 && Hit.Item != INDEX_NONE )
			{
				FBspSurf &SecSurf = Model->Surfs( Model->Nodes(Hit.Item).iSurf );
				FVector &SecNormal = Model->Vectors(SecSurf.vNormal);
				FVector &SecBase = Model->Points(SecSurf.pBase);
				FVector SecInt = FLinePlaneIntersection( TracePoint - TraceVect,  TracePoint + TraceVect, SecBase, SecNormal );
				SurfIndex = FindCoplanarSurface( Model, Hit.Item, SecInt, 0 );
			}
			else
				continue;

			if( SurfIndex == INDEX_NONE )
				continue;

			FBspSurf &SecSurf  =Model->Surfs(SurfIndex);
			FVector  &SecNormal=Model->Vectors(SecSurf.vNormal);
			FVector  &SecBase  =Model->Points(SecSurf.pBase);

			INT Found;
			if(SurfList.FindItem(SurfIndex, Found))
				continue;

			if( SecSurf.PolyFlags & (PF_AutoUPan|PF_AutoVPan) )
				continue;

			FLOAT costheta = (SurfNormal | SecNormal) / (SurfNormal.Size() * SecNormal.Size());
			if( Abs(costheta) <= 0.7 ) 
				continue;	// angle is too close to 90 degrees	

			// attach decal to seondary surface
			FDecal* SecDecal = NULL;
			for( j=0;j<SecSurf.Decals.Num();j++)
				if(SecSurf.Decals(j).Texture == Texture)
				{
					SecSurf.Decals.InsertZeroed(j);
					SecDecal = &SecSurf.Decals(j);					
					break;
				}
			if(!SecDecal) 
				SecDecal = &SecSurf.Decals(SecSurf.Decals.AddZeroed());
			
			// NJS: Setup the decal:
			SecDecal->Actor = (Behavior==DB_Normal)?this:NULL;;
			SecDecal->Texture=Texture;
			SecDecal->DrawScale=DrawScale;
			SecDecal->AmbientGlow=AmbientGlow;
			SecDecal->ScaleGlow=ScaleGlow;
			STY2PolyFlags(NULL,SecDecal->PolyFlags,SecDecal->PolyFlagsEx);
			//SecDecal->PolyFlags=GetPolyFlags(this);
			SecDecal->PolyFlagsEx|=Texture->PolyFlagsEx;
			SecDecal->SpawnTime=SecDecal->LastRenderedTime=Level->TimeSeconds;
			SecDecal->Location=DecalCenter;
			SecDecal->Behavior=Behavior;
			SecDecal->BehaviorArgument=BehaviorArgument;

			SurfList.AddItem(SurfIndex);

			for( j=0;j<4;j++)
			{
				// Locate texture-wrapped point on secondary surface, for each vertex
				FVector A = FLinePlaneIntersection( MainDecal->Vertices[j]-SurfNormal, MainDecal->Vertices[j], SecBase, SecNormal );
				FVector B = FLinePlaneIntersection( MainDecal->Vertices[j]-SecNormal, MainDecal->Vertices[j], SecBase, SecNormal );
				FLOAT X = (MainDecal->Vertices[j] - B).Size() / costheta;
				FLOAT H = (MainDecal->Vertices[j] - A).Size() / costheta;
				FVector AB = B - A;
				AB.Normalize();
				SecDecal->Vertices[j] = B - (H-X)*AB;
			}
			CalcClippedNodes( Model, SecSurf, SecDecal->Vertices, SecDecal->Nodes );
			SecDecal->Vertices[0] -= SecBase;
			SecDecal->Vertices[1] -= SecBase;
			SecDecal->Vertices[2] -= SecBase;
			SecDecal->Vertices[3] -= SecBase;
			for( j=0; j<4; j++ )
				SecDecal->TransformedVerts[j] = SecDecal->Vertices[j];
			if ( Surf.Actor && Surf.Actor->IsA(AMover::StaticClass()) )
				SecDecal->BaseRotation = Surf.Actor->Rotation;
		}

		MainDecal->Vertices[0] -= SurfBase;
		MainDecal->Vertices[1] -= SurfBase;
		MainDecal->Vertices[2] -= SurfBase;
		MainDecal->Vertices[3] -= SurfBase;
		for( j=0; j<4; j++ )
			MainDecal->TransformedVerts[j] = MainDecal->Vertices[j];
		if ( Surf.Actor && Surf.Actor->IsA(AMover::StaticClass()) )
			MainDecal->BaseRotation = Surf.Actor->Rotation;

		unguard;
	}
	*(INT*)Result = 1;
}

void ADecal::execDetachDecal( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	while( SurfList.Num() > 0 )
	{
		// detach decal from old surface
		FBspSurf& Surf = Level->XLevel->Model->Surfs(SurfList(SurfList.Num()-1));
		UBOOL RemovedDecal = 0;
		for( INT i=0; i<Surf.Decals.Num(); i++ )
			if( Surf.Decals(i).Actor == this )
			{
				Surf.Decals.Remove(i);
				RemovedDecal = 1;
				break;
			}

		//!! check(RemovedDecal);  // caused a crash with shadows during GC...
		SurfList.Remove(SurfList.Num()-1);
	}
}

// Color functions
#define P_GET_COLOR(var)            P_GET_STRUCT(FColor,var)

void AActor::execMultiply_ColorFloat( FFrame& Stack, RESULT_DECL )
{
	P_GET_COLOR(A);
	P_GET_FLOAT(B);
	P_FINISH;

	A.R = (BYTE) (A.R * B);
	A.G = (BYTE) (A.G * B);
	A.B = (BYTE) (A.B * B);
	*(FColor*)Result = A;
}	

void AActor::execMultiply_FloatColor( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT (A);
	P_GET_COLOR(B);
	P_FINISH;

	B.R = (BYTE) (B.R * A);
	B.G = (BYTE) (B.G * A);
	B.B = (BYTE) (B.B * A);
	*(FColor*)Result = B;
}	

void AActor::execAdd_ColorColor( FFrame& Stack, RESULT_DECL )
{
	P_GET_COLOR(A);
	P_GET_COLOR(B);
	P_FINISH;

	A.R = A.R + B.R;
	A.G = A.G + B.G;
	A.B = A.B + B.B;
	*(FColor*)Result = A;
}

void AActor::execSubtract_ColorColor( FFrame& Stack, RESULT_DECL )
{
	P_GET_COLOR(A);
	P_GET_COLOR(B);
	P_FINISH;

	A.R = A.R - B.R;
	A.G = A.G - B.G;
	A.B = A.B - B.B;
	*(FColor*)Result = A;
}

/*-----------------------------------------------------------------------------
	Mail support code
-----------------------------------------------------------------------------*/

#include "mail.h"

#if 0
static void MyCheapBroadcastMessage(AActor* inActor, TCHAR* inFmt, ... )
{ 
	static TCHAR buf[5000];
	GET_VARARGS( buf, ARRAY_COUNT(buf), inFmt );
	inActor->Level->eventBroadcastMessage(FString(buf),0,NAME_None);
}
#endif

void AActor::execSendMailMessage( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Rcpt);
	P_GET_STR(Message);
	P_GET_STR(Subject);
	P_GET_STR(Sender);
	P_GET_STR(SMTPServer);
	P_FINISH;

	const char	*pRcpt = NULL, *pMessage = NULL, *pSubject = NULL, *pSender = NULL, *pSMTPServer = NULL;

	pRcpt = Rcpt.toAnsi();
	pMessage = Message.toAnsi();
	pSubject = Subject.toAnsi();
	pSender = Sender.toAnsi();
	pSMTPServer = SMTPServer.toAnsi();

	if (!pRcpt)
	{
		*(UBOOL*)Result = false;
		return;
	}
	
	if (pMessage && strlen(pMessage) <= 0)
		pMessage = NULL;
	if (pSubject && strlen(pSubject) <= 0)
		pSubject = NULL;
	if (pSender && strlen(pSender) <= 0)
		pSender = NULL;
	if (pSMTPServer && strlen(pSMTPServer) <= 0)
		pSMTPServer = NULL;

	/*
	if (pMessage && strlen(pMessage) > 0)
		MyCheapBroadcastMessage(this, TEXT("%s"), appFromAnsi(pMessage));
	else
		MyCheapBroadcastMessage(this, TEXT("No Message"));
	*/

	*(UBOOL*)Result = SendMailMessage((char*)pSMTPServer, (char*)pSender, (char*)pRcpt, (char*)pSubject, (char*)pMessage);
}

// JEP...
#if 1
#define MAX_ENUM_SURFS			(32)

static INT	GEnumSurfs[MAX_ENUM_SURFS];
static INT	GNumEnumSurfs;

static void EnumSurfsInRadius_r(UModel *Model, INT iNode, FVector &Center, FLOAT Radius)
{
	if (iNode == INDEX_NONE)
		return;		// Leaf

	if (GNumEnumSurfs >= MAX_ENUM_SURFS)
		return;		// We outtie 5000

	const FBspNode *Node = &Model->Nodes(iNode);
	
	FLOAT Dist = Node->Plane.PlaneDot(Center);

	if (Dist >= Radius)			// Sphere on front side of node
	{
		EnumSurfsInRadius_r(Model, Node->iFront, Center, Radius);
		return;
	}
	else if (Dist < -Radius)		// Sphere on back side of node
	{
		EnumSurfsInRadius_r(Model, Node->iBack, Center, Radius);
		return;
	}

	// Sphere is on the node, so go down both sides
	EnumSurfsInRadius_r(Model, Node->iFront, Center, Radius);
	EnumSurfsInRadius_r(Model, Node->iBack, Center, Radius);
			
	// See which surfaces the radius impacts
	FVector IntersectionPoint	= Center - ((FVector&)Node->Plane)*Dist;	// BTW, I don't really need to project the point on the node, I can use the original Center
	FLOAT	RadiusSq			= Square(Radius);
	// Find the radius at the impact point
	FLOAT	ImpactRadiusSq		= RadiusSq - Square(Dist);

	// Check this node's poly's vertices.
	while(iNode != INDEX_NONE && GNumEnumSurfs < MAX_ENUM_SURFS)
	{
		// Loop through all coplanars.
		Node						= &Model->Nodes(iNode);

		iNode = Node->iPlane;
	
		// Skip surface if it's already in the GEnumSurfs list
		for (INT i = 0; i< GNumEnumSurfs; i++)
		{
			if (GEnumSurfs[i] == Node->iSurf)
				break;
		}

		if (i != GNumEnumSurfs)
			continue;

		// FIXME: Would be a major speed-up if we tagged surfaces that were enumeratble

		const FBspSurf	*Surf		= &Model->Surfs(Node->iSurf);
		FVector			&SurfNormal	= Model->Vectors(Surf->vNormal);

		const FVert* VertPool = &Model->Verts(Node->iVertPool);
		
		const FVector *PrevVertex = &Model->Points(VertPool[Node->NumVertices - 1].pVertex );

		for (INT v=0; v<Node->NumVertices; v++)
		{
			const FVector *Vertex = &Model->Points(VertPool->pVertex);
		
			FVector ClipNorm = SurfNormal ^ (*Vertex - *PrevVertex);
			ClipNorm.Normalize();

			FPlane ClipPlane( *Vertex, ClipNorm );
			FLOAT Dot = ClipPlane.PlaneDot( IntersectionPoint );

			if (Dot < 0.0f && Square(Dot) > ImpactRadiusSq)
				break;		// Outside, not in radius

			PrevVertex = Vertex;

			VertPool++;
		}

		if (v == Node->NumVertices)
		{
			// Surface touches radius
			GEnumSurfs[GNumEnumSurfs++] = Node->iSurf;
		}
	}
}

static void EnumSurfsInRadius(AActor *Actor, UModel *Model, FVector Center, FLOAT Radius, UBOOL bHitLocationFromSurf, INT MaxSurfs)
{
	GNumEnumSurfs = 0;

	if (!Model->Nodes.Num()) 
		return;

	EnumSurfsInRadius_r(Model, 0, Center, Radius);
	
	// FIXME: Sort them here by closest vert before we clamp them (so we get the most important surfaces)
	if (GNumEnumSurfs > MaxSurfs)
		GNumEnumSurfs = MaxSurfs;

	for (INT i = 0; i < GNumEnumSurfs; i++)
	{
		const FBspSurf	*Surf		= &Model->Surfs(GEnumSurfs[i]);
		FVector			&SurfNormal	= Model->Vectors(Surf->vNormal);

		/*		// Work in progress
		if (bHitLocationFromSurf)
		{
			const FVert	*VertPool = &Model->Verts(Node->iVertPool);
			FVector		HitLocation(0,0,0);
			
			for (INT v=0; v<Node->NumVertices; v++)
			{
				const FVector *Vertex = &Model->Points(VertPool->pVertex);

				HitLocation += (*Vertex);
			}

			HitLocation /= Node->NumVertices;
		
			Actor->eventEnumSurfsInRadiusCB(GEnumSurfs[i], Surf->Texture, HitLocation, SurfNormal);
		}
		else
		*/
			Actor->eventEnumSurfsInRadiusCB(GEnumSurfs[i], Surf->Texture, Center, SurfNormal);
	}
}
#endif
// ...JEP

//========================================================================================
//	execEnumSurfsInRadius
//========================================================================================
void AActor::execEnumSurfsInRadius( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_OPTX(Center,Location);
	P_GET_FLOAT_OPTX(Radius, CollisionRadius);
	P_GET_UBOOL_OPTX(bHitLocationFromSurf, false);
	P_GET_INT_OPTX(MaxSurfs, MAX_ENUM_SURFS);
	P_FINISH;

	EnumSurfsInRadius(this, GetLevel()->Model, Center, Radius, bHitLocationFromSurf, MaxSurfs);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

