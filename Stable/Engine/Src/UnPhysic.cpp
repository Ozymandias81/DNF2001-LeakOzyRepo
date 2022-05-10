/*=============================================================================
	UnPhysic.cpp: Actor physics implementation

	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Steven Polge 3/97
=============================================================================*/

#include "EnginePrivate.h"
#include "DnMeshPrivate.h"
#include <stdarg.h>
#include <stdio.h>
#include <float.h>

#if 0
static void CheapBroadcastMessage(AActor* inActor, TCHAR* inFmt, ... )
{ 
	static TCHAR buf[256];
	GET_VARARGS( buf, ARRAY_COUNT(buf), inFmt );
	inActor->Level->eventBroadcastMessage(FString(buf),0,NAME_None);
}
#endif

void AActor::execMoveSmooth( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Delta);
	P_FINISH;

	bJustTeleported = 0;
	int didHit = moveSmooth(Delta);

	*(DWORD*)Result = didHit;
}

void AActor::execMoveActor( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Delta);
	P_GET_FLOAT_REF(HitTime);
	P_GET_VECTOR_REF(HitNormal);
	P_GET_VECTOR_REF(HitLocation);
	P_GET_ACTOR_REF(HitActor);
	P_GET_UBOOL_OPTX(bTest, 0);
	P_GET_UBOOL_OPTX(bNoFail, 0);
	P_FINISH;	

	FCheckResult Hit(1.f);

	bJustTeleported = 0;
	GetLevel()->MoveActor(this, Delta, Rotation, Hit, bTest, false, false, bNoFail);
	
	*HitTime = Hit.Time;
	*HitNormal = Hit.Normal;
	*HitLocation = Hit.Location;
	*HitActor = Hit.Actor;

	*(DWORD*)Result = (Hit.Time < 1.0) ? 0 : 1;		// return 1 if we moved entire delta, 0 otherwise
}

void AActor::execFindSpot(FFrame& Stack, RESULT_DECL)
{
	P_GET_UBOOL_OPTX(bCheckActors, 0);
	P_GET_UBOOL_OPTX(bAssumeFit, 0);
	P_FINISH;

	*(DWORD*)Result = GetLevel()->FindSpot(GetCylinderExtent(), Location, bCheckActors, bAssumeFit);
}

void AActor::execDropToFloor(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT_OPTX(AmountToDrop, 1000);
	P_GET_UBOOL_OPTX(bResetOnFailure, 1);
	P_FINISH;

	// Try moving down a long way and see if we hit the floor.
	FCheckResult	Hit(1.0);

	GetLevel()->MoveActor(this, FVector( 0, 0, -AmountToDrop), Rotation, Hit);

	*(DWORD*)Result = (Hit.Time < 1.0f) ? 0 : 1;
	
	if (!(*(DWORD*)Result ) && bResetOnFailure)
		GetLevel()->MoveActor(this, FVector( 0, 0, AmountToDrop*Hit.Time), Rotation, Hit);		// Move back up
}

void AActor::execSetPhysics( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(NewPhysics);
	P_FINISH;

	setPhysics(NewPhysics);

}

void AActor::execAutonomousPhysics( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(DeltaSeconds);
	P_FINISH;

	// round acceleration to be consistent with replicated acceleration
	Acceleration.X = 0.1 * int(10 * Acceleration.X);
	Acceleration.Y = 0.1 * int(10 * Acceleration.Y);
	Acceleration.Z = 0.1 * int(10 * Acceleration.Z);

	// Perform physics.
	if( Physics!=PHYS_None )
		performPhysics( DeltaSeconds );
}

void AActor::execForcedGetFrame( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if ( Mesh == NULL )
		return;

	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );
	if ( MeshInst == NULL )
		return;

	FMemMark Mark(GMem);
	static SMacTri TempTris[4096];
	MeshInst->Mac->EvaluateTris( 1.f, TempTris );
	VVec3* TempVerts = New<VVec3>(GMem, MeshInst->Mac->mGeometry->m_Verts.GetCount());
	INT NumVerts = MeshInst->GetFrame((FVector*)TempVerts, NULL, sizeof(VVec3), GMath.UnitCoords, 1.f);
	Mark.Pop();

//	FVector* TempVerts = New<FVector>(GMem, MeshInst->Mac->mGeometry->m_Verts.GetCount());
//	MeshInst->GetFrame( TempVerts, NULL, sizeof(FVector), GMath.UnitCoords, 1.f );
}

//======================================================================================

int AActor::moveSmooth(FVector Delta)
{
	FCheckResult Hit(1.f);
	int didHit = GetLevel()->MoveActor( this, Delta, Rotation, Hit );
	if (Hit.Time < 1.f)
	{
		FVector Adjusted = (Delta - Hit.Normal * (Delta | Hit.Normal)) * (1.f - Hit.Time);
		if( (Delta | Adjusted) >= 0 )
		{
			FVector OldHitNormal = Hit.Normal;
			FVector DesiredDir = Delta.SafeNormal();
			GetLevel()->MoveActor(this, Adjusted, Rotation, Hit);
			if (Hit.Time < 1.f)
			{
				eventHitWall(Hit.Normal, Hit.Actor);
				TwoWallAdjust(DesiredDir, Adjusted, Hit.Normal, OldHitNormal, Hit.Time);
				GetLevel()->MoveActor(this, Adjusted, Rotation, Hit);
			}
		}
	}
	return didHit;
}

void AActor::FindBase()
{
	FCheckResult Hit(1.f);
	GetLevel()->SingleLineCheck( Hit, this, Location + FVector(0,0,-8), Location, TRACE_AllColliding, GetCylinderExtent() );
	if (Base != Hit.Actor)
		SetBase(Hit.Actor);
}

void AActor::setPhysics(BYTE NewPhysics, AActor *NewFloor)
{

	if (Physics == NewPhysics)
		return;
	Physics = NewPhysics;

	if ((Physics == PHYS_Walking) || (Physics == PHYS_None) || (Physics == PHYS_Rolling) 
			|| (Physics == PHYS_Rotating) || (Physics == PHYS_Spider) )
	{
		if (NewFloor != NULL)
		{
			if (Base != NewFloor)
				SetBase(NewFloor);
		}
		else
			FindBase();
	}
	else if (Base != NULL)
		SetBase(NULL);

	if ( (Physics == PHYS_None) || (Physics == PHYS_Rotating) )
	{
		Velocity = FVector(0,0,0);
		Acceleration = FVector(0,0,0);
	}
}

void AActor::performPhysics(FLOAT DeltaSeconds)
{
	if ( DiscardedPhysicsFrames < 3 )
	{
		DiscardedPhysicsFrames++;
		return;
	}

	FVector OldVelocity = Velocity;

	// change position
	switch (Physics)
	{
		case PHYS_Projectile: physProjectile(DeltaSeconds, 0); break;
		case PHYS_Falling: physFalling(DeltaSeconds, 0); break;
		case PHYS_Rotating: break;
		case PHYS_Interpolating: 
			{
				OldLocation = Location;
				physPathing(DeltaSeconds); 
				Velocity = (Location - OldLocation)/DeltaSeconds;
				break;
			}
		case PHYS_MovingBrush: 
			{
				OldLocation = Location;
				physMovingBrush(DeltaSeconds); 
				Velocity = (Location - OldLocation)/DeltaSeconds;
				break;
			}
		case PHYS_Trailer: physTrailer(DeltaSeconds); break;
		case PHYS_Rolling: physRolling(DeltaSeconds, 0); break;
	}

	// rotate
	if ( !RotationRate.IsZero() ) 
		physicsRotation(DeltaSeconds);

	// NJS: Process location per DesiredLocation:
	if(bMoveToDesired)
	{	
		FVector deltaMotion;
		
		if(MountParent) // Am I mounted to someone?
		{
			if(DeltaSeconds>=DesiredLocationSeconds)
				deltaMotion=DesiredLocation-MountOrigin;
			else
			{
				deltaMotion=(DesiredLocation-MountOrigin)*(DeltaSeconds/DesiredLocationSeconds);
				DesiredLocationSeconds-=DeltaSeconds;
			}
		
			MountOrigin+=deltaMotion;
			//moveSmooth(deltaMotion);

			// Am I at my desired location? 
			if(MountOrigin==DesiredLocation)
				bMoveToDesired=false;		// I'm already there: 

		} else			// Not mounted to anyone.
		{
			if(DeltaSeconds>=DesiredLocationSeconds)
				deltaMotion=DesiredLocation-Location;
			else
			{
				deltaMotion=(DesiredLocation-Location)*(DeltaSeconds/DesiredLocationSeconds);
				DesiredLocationSeconds-=DeltaSeconds;
			}
		
			moveSmooth(deltaMotion);

			// Am I at my desired location? 
			if(Location==DesiredLocation)
				bMoveToDesired=false;		// I'm already there: 
		}
	}

#if 1
	if(MountParent) // NJS: Am I mounted to something?
	{
		STAT(clock(GStat.MountPhysCycles));		// JEP

		// CDH: Extended for other mount types
//		MountOrigin+=Location-MountPreviousLocation;
//		MountAngles+=Rotation-MountPreviousRotation; 

		FCoords CenterCoordFrame(FVector(0,0,0));
		do
		{
			if (MountType == MOUNT_Actor)
			{
				// Determine relative location:
				if(MountParent->IsA(APlayerPawn::StaticClass()))
					CenterCoordFrame*=((APlayerPawn*)MountParent)->ViewRotation;
				else
					CenterCoordFrame*=MountParent->Rotation;
				moveSmooth(  (MountOrigin.TransformPointBy(CenterCoordFrame) + MountParent->Location) - Location );

			}
			else if ((MountType == MOUNT_MeshBone) || (MountType == MOUNT_MeshSurface))
			{
				// Special handling for things mounted to weapons.
				UMeshInstance* MeshInst = MountParent->GetMeshInstance();
				if ( (MountParent->IsA(AWeapon::StaticClass())) &&
					 (MountParent->Owner != NULL) )
				{
					// Get the player owner's weapon mount and transform into that.
					UMeshInstance* OwnerMeshInst = MountParent->Owner->GetMeshInstance();
					FCoords WpnCoords( FVector(0,0,0) );
					OwnerMeshInst->GetMountCoords( FName(TEXT("Weapon")), MOUNT_MeshSurface, WpnCoords, MountParent );

					FVector OldPos = MountParent->Location;
					FRotator OldRot = MountParent->Rotation;
					MountParent->Location = FVector(0,0,0).TransformPointBy( WpnCoords );
					MountParent->Rotation = WpnCoords.Transpose().OrthoRotation();
					Exchange( ((AWeapon*) MountParent)->ThirdPersonMesh,  ((AWeapon*) MountParent)->Mesh );
					Exchange( ((AWeapon*) MountParent)->ThirdPersonScale, ((AWeapon*) MountParent)->DrawScale );
					MeshInst = MountParent->GetMeshInstance();
					if ( !MeshInst )
						break;
					if ( !MeshInst->GetMountCoords( MountMeshItem, MountType, CenterCoordFrame, this ) )
						break;
					Exchange( ((AWeapon*) MountParent)->ThirdPersonMesh,  ((AWeapon*) MountParent)->Mesh );
					Exchange( ((AWeapon*) MountParent)->ThirdPersonScale, ((AWeapon*) MountParent)->DrawScale );
					MountParent->Location = OldPos;
					MountParent->Rotation = OldRot;

				} else 
				{
					if ( !MeshInst )
						break;
					if ( !MeshInst->GetMountCoords( MountMeshItem, MountType, CenterCoordFrame, this ) )
						break;
				}
				GetLevel()->FarMoveActor( this, MountOrigin.TransformPointBy(CenterCoordFrame) );
				
			}
		} while(0);

		if ( !IndependentRotation )
		{
			FRotator NewRotation;
			if ( bMountRotationRelative )
			{
				if ( !bEstablishedRelativeBase )
				{
					MountRelativeBase = CenterCoordFrame;
					DesiredRotation = Rotation;
					bEstablishedRelativeBase = true;
				}
				NewRotation = (CenterCoordFrame.Axes() >> MountRelativeBase.Axes()).Transpose().OrthoRotation();
				NewRotation += DesiredRotation;
			}
			else 
			{
				CenterCoordFrame*=MountAngles;
				CenterCoordFrame=CenterCoordFrame.Transpose();
				NewRotation = CenterCoordFrame.OrthoRotation();
			}
		
			FCheckResult Hit(1.f);				
			GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit);
		}

//		MountPreviousLocation=Location; 
//		MountPreviousRotation=Rotation;
		
		STAT(unclock(GStat.MountPhysCycles));			// JEP
	}
#endif

	// allow touched actors to impact physics
	if ( PendingTouch )
	{
		PendingTouch->eventPostTouch(this);
		AActor *OldTouch = PendingTouch;
		PendingTouch = PendingTouch->PendingTouch;
		OldTouch->PendingTouch = NULL;
	}
}

void APawn::performPhysics(FLOAT DeltaSeconds)
{
	if ( DiscardedPhysicsFrames < 3 )
	{
		DiscardedPhysicsFrames++;
		return;
	}

	FVector OldVelocity = Velocity;

	// change position
	switch (Physics)
	{
		case PHYS_Walking:
            physWalking(DeltaSeconds, 0);
            break;
		case PHYS_Falling:
            physFalling(DeltaSeconds, 0); 
            break;
		case PHYS_Flying: 
            physFlying(DeltaSeconds, 0);
            break;
		case PHYS_Swimming: 
            physSwimming(DeltaSeconds, 0);
            break;
		case PHYS_Spider:
            physSpider(DeltaSeconds, 0);
            break;
        case PHYS_Rope:
            physRope(DeltaSeconds, 0);
            break;
		case PHYS_Interpolating: 
			OldLocation = Location;
			physPathing(DeltaSeconds); 
			Velocity = (Location - OldLocation)/DeltaSeconds;
			break;
		case PHYS_Jetpack:
			physJetpack(DeltaSeconds);
			break;
	}


	// rotate
	if ( (Physics != PHYS_Spider) 
			&& (IsA(APlayerPawn::StaticClass()) || (Rotation != DesiredRotation) || (RotationRate.Roll > 0)) ) 
		physicsRotation(DeltaSeconds, OldVelocity);

	MoveTimer -= DeltaSeconds;
	AvgPhysicsTime = 0.8f * AvgPhysicsTime + 0.2f * DeltaSeconds;

	// NJS: Am I mounted to something?
	if ( MountParent )
	{
//		MountOrigin+=Location-MountPreviousLocation;
//		MountAngles+=ViewRotation-MountPreviousRotation; 

		FCoords CenterCoordFrame(FVector(0,0,0));
		FRotator NewRotation = FRotator(0,0,0);

		if ( MountType == MOUNT_Actor )
		{
			CenterCoordFrame*=MountParent->Rotation;
			GetLevel()->FarMoveActor( this, MountOrigin.TransformPointBy(CenterCoordFrame) + MountParent->Location );

			CenterCoordFrame*=MountAngles;
			CenterCoordFrame=CenterCoordFrame.Transpose();

			NewRotation = CenterCoordFrame.OrthoRotation();
		}
		else if ( (MountType == MOUNT_MeshBone) || (MountType == MOUNT_MeshSurface) )
		{
			UMeshInstance* MeshInst = MountParent->GetMeshInstance();
			if ( (MeshInst != NULL) && (MeshInst->GetMountCoords(MountMeshItem, MountType, CenterCoordFrame, this) != NULL) )
			{
				GetLevel()->FarMoveActor( this, MountOrigin.TransformPointBy(CenterCoordFrame) /*+ MountParent->Location*/ );
				if ( !IndependentRotation )
				{
					if ( bMountRotationRelative )
					{
						if ( !bEstablishedRelativeBase )
						{
							MountRelativeBase = CenterCoordFrame;
							DesiredRotation = Rotation;
							bEstablishedRelativeBase = true;
						}
						NewRotation = (CenterCoordFrame.Axes() >> MountRelativeBase.Axes()).Transpose().OrthoRotation();
						NewRotation += DesiredRotation;
					}
					else 
					{
						CenterCoordFrame*=MountAngles;
						CenterCoordFrame=CenterCoordFrame.Transpose();
						NewRotation = CenterCoordFrame.OrthoRotation();
					}
				}
			}
		}

		FCheckResult Hit(1.f);				
		GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit);

//		ViewRotation=NewRotation;

//		MountPreviousLocation=Location;
//		MountPreviousRotation=ViewRotation;
	}
	if ( PendingTouch )
	{
		PendingTouch->eventPostTouch(this);
		if ( PendingTouch )
		{
			AActor *OldTouch = PendingTouch;
			PendingTouch = PendingTouch->PendingTouch;
			OldTouch->PendingTouch = NULL;
		}
	}

}

int AActor::fixedTurn(int current, int desired, int deltaRate)
{

	if (deltaRate == 0)
		return (current & 65535);

	int result = current & 65535;
	current = result;
	desired = desired & 65535;

	if (bFixedRotationDir)
	{
		if (bRotateToDesired)
		{
			if (deltaRate > 0)
			{
				if (current > desired)
					desired += 65536;
				result += Min(deltaRate, desired - current);
			}
			else 
			{
				if (current < desired)
					current += 65536;
				result += ::Max(deltaRate, desired - current);
			}
		}
		else
			result += deltaRate;
	}
	else if (bRotateToDesired)
	{
		if (current > desired)
		{
			if (current - desired < 32768)
				result -= Min((current - desired), Abs(deltaRate));
			else
				result += Min((desired + 65536 - current), Abs(deltaRate));
		}
		else
		{
			if (desired - current < 32768)
				result += Min((desired - current), Abs(deltaRate));
			else
				result -= Min((current + 65536 - desired), Abs(deltaRate));
		}
	}

	return (result & 65535);
}

void APawn::physicsRotation(FLOAT deltaTime, FVector OldVelocity)
{

	// Accumulate a desired new rotation.
	FRotator NewRotation = Rotation;	

	if (!IsA(APlayerPawn::StaticClass())) //don't pitch or yaw player
	{
		int deltaYaw = (INT) (RotationRate.Yaw * deltaTime);
		bRotateToDesired = 1; //Pawns always have a "desired" rotation
		bFixedRotationDir = 0;
	
		//YAW 
		if ( DesiredRotation.Yaw != NewRotation.Yaw )
			NewRotation.Yaw = fixedTurn(NewRotation.Yaw, DesiredRotation.Yaw, deltaYaw);

		//PITCH
		if ( DesiredRotation.Pitch != NewRotation.Pitch )
		{
			if( Physics == PHYS_Flying )
			{
				int deltaPitch = (INT) (RotationRate.Pitch * deltaTime);
				NewRotation.Pitch = fixedTurn(NewRotation.Pitch, DesiredRotation.Pitch, deltaPitch );
			}
			else
			{
				//non flying pawns pitch instantly
				NewRotation.Pitch = Rotation.Pitch & 65535;
				//debugf("desired pitch %f actual pitch %f",DesiredRot.Pitch, NewRotation.Pitch);
				if ( !bNoRotConstraint )
				{
					if ( NewRotation.Pitch < 32768 )
					{
						if (NewRotation.Pitch > RotationRate.Pitch) //bound pitch
							NewRotation.Pitch = RotationRate.Pitch;
					}
					else if (NewRotation.Pitch < 65536 - RotationRate.Pitch)
						NewRotation.Pitch = 65536 - RotationRate.Pitch;
				}
			}
		}

	}

	//ROLL
	if (RotationRate.Roll > 0) 
	{
		//pawns roll based on physics
		if ((Physics == PHYS_Walking) && Velocity.SizeSquared() < 40000.f)
		{
			FLOAT SmoothRoll = Min(1.f, 8.f * deltaTime);
			if (NewRotation.Roll < 32768)
				NewRotation.Roll = (INT) (NewRotation.Roll * (1 - SmoothRoll));
			else
				NewRotation.Roll = (INT) (NewRotation.Roll + (65536 - NewRotation.Roll) * SmoothRoll);
		}
		else
		{
			FVector RealAcceleration = (Velocity - OldVelocity)/deltaTime;
			if (RealAcceleration.SizeSquared() > 10000.f) 
			{
				FLOAT MaxRoll = 28000.f;
				if ( Physics == PHYS_Walking )
					MaxRoll = 4096.f;
				NewRotation.Roll = 0;
				FVector Facing = Rotation.Vector();

				RealAcceleration = RealAcceleration.TransformVectorBy(GMath.UnitCoords/NewRotation); //y component will affect roll

				if (RealAcceleration.Y > 0) 
					NewRotation.Roll = Min(RotationRate.Roll, (int)(RealAcceleration.Y * MaxRoll/AccelRate)); 
				else
					NewRotation.Roll = ::Max(65536 - RotationRate.Roll, (int)(65536.f + RealAcceleration.Y * MaxRoll/AccelRate));

				//smoothly change rotation
				Rotation.Roll = Rotation.Roll & 65535;
				if (NewRotation.Roll > 32768)
				{
					if (Rotation.Roll < 32768)
						Rotation.Roll += 65536;
				}
				else if (Rotation.Roll > 32768)
					Rotation.Roll -= 65536;
	
				FLOAT SmoothRoll = Min(1.f, 5.f * deltaTime);
				NewRotation.Roll = (INT) (NewRotation.Roll * SmoothRoll + Rotation.Roll * (1 - SmoothRoll));

				//if ((NewRotation.Roll > MaxRoll) && (NewRotation.Roll < (65536 - MaxRoll)))
				//	debugf("Illegal roll for %f", RealAcceleration.Y);
			}
			else
			{
				FLOAT SmoothRoll = Min(1.f, 8.f * deltaTime);
				if (NewRotation.Roll < 32768)
					NewRotation.Roll = (INT) (NewRotation.Roll * (1 - SmoothRoll));
				else
					NewRotation.Roll = (INT) (NewRotation.Roll + (65536 - NewRotation.Roll) * SmoothRoll);
			}
		}
	}
	else
		NewRotation.Roll = 0;

	// Set the new rotation.
	if( NewRotation != Rotation )
	{
		FCheckResult Hit(1.0);
		GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
	}

}

/*
 * Brandon's Euler/Quat workshop.
 * Code from Graphic's Gems.
 */
typedef struct {float x, y, z, w;} Quat; /* Quaternion */
enum QuatPart {X, Y, Z, W};
typedef float HMatrix[4][4]; /* Right-handed, for column vectors */
typedef Quat EulerAngles;    /* (x,y,z)=ang 1,2,3, w=order code  */

/*** Order type constants, constructors, extractors ***/

    /* There are 24 possible conventions, designated by:	*/
    /*	  o EulAxI = axis used initially					*/
    /*	  o EulPar = parity of axis permutation				*/
    /*	  o EulRep = repetition of initial axis as last	    */
    /*	  o EulFrm = frame from which axes are taken	    */
    /* Axes I,J,K will be a permutation of X,Y,Z.			*/
    /* Axis H will be either I or K, depending on EulRep.   */
    /* Frame S takes axes from initial static frame.	    */
    /* If ord = (AxI=X, Par=Even, Rep=No, Frm=S), then	    */
    /* {a,b,c,ord} means Rz(c)Ry(b)Rx(a), where Rz(c)v	    */
    /* rotates v around Z by c radians.						*/

#define EulFrmS	     0
#define EulFrmR	     1
#define EulFrm(ord)  ((unsigned)(ord)&1)
#define EulRepNo     0
#define EulRepYes    1
#define EulRep(ord)  (((unsigned)(ord)>>1)&1)
#define EulParEven   0
#define EulParOdd    1
#define EulPar(ord)  (((unsigned)(ord)>>2)&1)
#define EulSafe	     "\000\001\002\000"
#define EulNext	     "\001\002\000\001"
#define EulAxI(ord)  ((int)(EulSafe[(((unsigned)(ord)>>3)&3)]))
#define EulAxJ(ord)  ((int)(EulNext[EulAxI(ord)+(EulPar(ord)==EulParOdd)]))
#define EulAxK(ord)  ((int)(EulNext[EulAxI(ord)+(EulPar(ord)!=EulParOdd)]))
#define EulAxH(ord)  ((EulRep(ord)==EulRepNo)?EulAxK(ord):EulAxI(ord))
    /* EulGetOrd unpacks all useful information about order simultaneously. */
#define EulGetOrd(ord,i,j,k,h,n,s,f) {unsigned o=ord;f=o&1;o=o>>1;s=o&1;o=o>>1;\
    n=o&1;o=o>>1;i=EulSafe[o&3];j=EulNext[i+n];k=EulNext[i+1-n];h=s?k:i;}
    /* EulOrd creates an order value between 0 and 23 from 4-tuple choices. */
#define EulOrd(i,p,r,f)	   (((((((i)<<1)+(p))<<1)+(r))<<1)+(f))
    /* Static axes */
#define EulOrdXYZs    EulOrd(X,EulParEven,EulRepNo,EulFrmS)
#define EulOrdXYXs    EulOrd(X,EulParEven,EulRepYes,EulFrmS)
#define EulOrdXZYs    EulOrd(X,EulParOdd,EulRepNo,EulFrmS)
#define EulOrdXZXs    EulOrd(X,EulParOdd,EulRepYes,EulFrmS)
#define EulOrdYZXs    EulOrd(Y,EulParEven,EulRepNo,EulFrmS)
#define EulOrdYZYs    EulOrd(Y,EulParEven,EulRepYes,EulFrmS)
#define EulOrdYXZs    EulOrd(Y,EulParOdd,EulRepNo,EulFrmS)
#define EulOrdYXYs    EulOrd(Y,EulParOdd,EulRepYes,EulFrmS)
#define EulOrdZXYs    EulOrd(Z,EulParEven,EulRepNo,EulFrmS)
#define EulOrdZXZs    EulOrd(Z,EulParEven,EulRepYes,EulFrmS)
#define EulOrdZYXs    EulOrd(Z,EulParOdd,EulRepNo,EulFrmS)
#define EulOrdZYZs    EulOrd(Z,EulParOdd,EulRepYes,EulFrmS)
    /* Rotating axes */
#define EulOrdZYXr    EulOrd(X,EulParEven,EulRepNo,EulFrmR)
#define EulOrdXYXr    EulOrd(X,EulParEven,EulRepYes,EulFrmR)
#define EulOrdYZXr    EulOrd(X,EulParOdd,EulRepNo,EulFrmR)
#define EulOrdXZXr    EulOrd(X,EulParOdd,EulRepYes,EulFrmR)
#define EulOrdXZYr    EulOrd(Y,EulParEven,EulRepNo,EulFrmR)
#define EulOrdYZYr    EulOrd(Y,EulParEven,EulRepYes,EulFrmR)
#define EulOrdZXYr    EulOrd(Y,EulParOdd,EulRepNo,EulFrmR)
#define EulOrdYXYr    EulOrd(Y,EulParOdd,EulRepYes,EulFrmR)
#define EulOrdYXZr    EulOrd(Z,EulParEven,EulRepNo,EulFrmR)
#define EulOrdZXZr    EulOrd(Z,EulParEven,EulRepYes,EulFrmR)
#define EulOrdXYZr    EulOrd(Z,EulParOdd,EulRepNo,EulFrmR)
#define EulOrdZYZr    EulOrd(Z,EulParOdd,EulRepYes,EulFrmR)

EulerAngles Eul_(float ai, float aj, float ah, int order)
{
    EulerAngles ea;
    ea.x = ai; ea.y = aj; ea.z = ah;
    ea.w = order;
    return (ea);
}
/* Construct quaternion from Euler angles (in radians). */
Quat Eul_ToQuat(EulerAngles ea)
{
    Quat qu;
    double a[3], ti, tj, th, ci, cj, ch, si, sj, sh, cc, cs, sc, ss;
    int i,j,k,h,n,s,f;
    EulGetOrd(ea.w,i,j,k,h,n,s,f);
    if (f==EulFrmR) {float t = ea.x; ea.x = ea.z; ea.z = t;}
    if (n==EulParOdd) ea.y = -ea.y;
    ti = ea.x*0.5; tj = ea.y*0.5; th = ea.z*0.5;
    ci = appCos(ti);  cj = appCos(tj);  ch = appCos(th);
    si = appSin(ti);  sj = appSin(tj);  sh = appSin(th);
    cc = ci*ch; cs = ci*sh; sc = si*ch; ss = si*sh;
    if (s==EulRepYes) {
	a[i] = cj*(cs + sc);	/* Could speed up with */
	a[j] = sj*(cc + ss);	/* trig identities. */
	a[k] = sj*(cs - sc);
	qu.w = cj*(cc - ss);
    } else {
	a[i] = cj*sc - sj*cs;
	a[j] = cj*ss + sj*cc;
	a[k] = cj*cs - sj*sc;
	qu.w = cj*cc + sj*ss;
    }
    if (n==EulParOdd) a[j] = -a[j];
    qu.x = a[X]; qu.y = a[Y]; qu.z = a[Z];
    return (qu);
}

/* Construct matrix from Euler angles (in radians). */
void Eul_ToHMatrix(EulerAngles ea, HMatrix M)
{
    double ti, tj, th, ci, cj, ch, si, sj, sh, cc, cs, sc, ss;
    int i,j,k,h,n,s,f;
    EulGetOrd(ea.w,i,j,k,h,n,s,f);
    if (f==EulFrmR) {float t = ea.x; ea.x = ea.z; ea.z = t;}
    if (n==EulParOdd) {ea.x = -ea.x; ea.y = -ea.y; ea.z = -ea.z;}
    ti = ea.x;	  tj = ea.y;	th = ea.z;
    ci = appCos(ti); cj = appCos(tj); ch = appCos(th);
    si = appSin(ti); sj = appSin(tj); sh = appSin(th);
    cc = ci*ch; cs = ci*sh; sc = si*ch; ss = si*sh;
    if (s==EulRepYes) {
	M[i][i] = cj;	  M[i][j] =  sj*si;    M[i][k] =  sj*ci;
	M[j][i] = sj*sh;  M[j][j] = -cj*ss+cc; M[j][k] = -cj*cs-sc;
	M[k][i] = -sj*ch; M[k][j] =  cj*sc+cs; M[k][k] =  cj*cc-ss;
    } else {
	M[i][i] = cj*ch; M[i][j] = sj*sc-cs; M[i][k] = sj*cc+ss;
	M[j][i] = cj*sh; M[j][j] = sj*ss+cc; M[j][k] = sj*cs-sc;
	M[k][i] = -sj;	 M[k][j] = cj*si;    M[k][k] = cj*ci;
    }
    M[W][X]=M[W][Y]=M[W][Z]=M[X][W]=M[Y][W]=M[Z][W]=0.0; M[W][W]=1.0;
}

/* Convert matrix to Euler angles (in radians). */
EulerAngles Eul_FromHMatrix(HMatrix M, int order)
{
    EulerAngles ea;
    int i,j,k,h,n,s,f;
    EulGetOrd(order,i,j,k,h,n,s,f);
    if (s==EulRepYes) {
	double sy = appSqrt(M[i][j]*M[i][j] + M[i][k]*M[i][k]);
	if (sy > 16*FLT_EPSILON) {
	    ea.x = appAtan2(M[i][j], M[i][k]);
	    ea.y = appAtan2(sy, M[i][i]);
	    ea.z = appAtan2(M[j][i], -M[k][i]);
	} else {
	    ea.x = appAtan2(-M[j][k], M[j][j]);
	    ea.y = appAtan2(sy, M[i][i]);
	    ea.z = 0;
	}
    } else {
	double cy = appSqrt(M[i][i]*M[i][i] + M[j][i]*M[j][i]);
	if (cy > 16*FLT_EPSILON) {
	    ea.x = appAtan2(M[k][j], M[k][k]);
	    ea.y = appAtan2(-M[k][i], cy);
	    ea.z = appAtan2(M[j][i], M[i][i]);
	} else {
	    ea.x = appAtan2(-M[j][k], M[j][j]);
	    ea.y = appAtan2(-M[k][i], cy);
	    ea.z = 0;
	}
    }
    if (n==EulParOdd) {ea.x = -ea.x; ea.y = - ea.y; ea.z = -ea.z;}
    if (f==EulFrmR) {float t = ea.x; ea.x = ea.z; ea.z = t;}
    ea.w = order;
    return (ea);
}

/* Convert quaternion to Euler angles (in radians). */
EulerAngles Eul_FromQuat(Quat q, int order)
{
    HMatrix M;
    double Nq = q.x*q.x+q.y*q.y+q.z*q.z+q.w*q.w;
    double s = (Nq > 0.0) ? (2.0 / Nq) : 0.0;
    double xs = q.x*s,	  ys = q.y*s,	 zs = q.z*s;
    double wx = q.w*xs,	  wy = q.w*ys,	 wz = q.w*zs;
    double xx = q.x*xs,	  xy = q.x*ys,	 xz = q.x*zs;
    double yy = q.y*ys,	  yz = q.y*zs,	 zz = q.z*zs;
    M[X][X] = 1.0 - (yy + zz); M[X][Y] = xy - wz; M[X][Z] = xz + wy;
    M[Y][X] = xy + wz; M[Y][Y] = 1.0 - (xx + zz); M[Y][Z] = yz - wx;
    M[Z][X] = xz - wy; M[Z][Y] = yz + wx; M[Z][Z] = 1.0 - (xx + yy);
    M[W][X]=M[W][Y]=M[W][Z]=M[X][W]=M[Y][W]=M[Z][W]=0.0; M[W][W]=1.0;
    return (Eul_FromHMatrix(M, order));
}

#define TODEG(x)    x = x * 180 / M_PI;
#define TORAD(x)    x = x / 180 * M_PI;

/*
 * End graphics gems code.
 */

void AActor::physicsRotation(FLOAT deltaTime)
{
	if ( (!bRotateToDesired && !bFixedRotationDir)
		|| (bRotateToDesired && (Rotation == DesiredRotation)) )
		return;

	// Accumulate a desired new rotation.
	FRotator NewRotation = Rotation;	
	FRotator deltaRotation = RotationRate * deltaTime;

	// NJS: If I'm mounted, use my MountAngles instead of rotation.
	if(MountParent)
		NewRotation = MountAngles;

	if (!bRotateByQuat)
	{
		//YAW
		if ( (deltaRotation.Yaw != 0) && (!bRotateToDesired || (DesiredRotation.Yaw != NewRotation.Yaw)) )
			NewRotation.Yaw = fixedTurn(NewRotation.Yaw, DesiredRotation.Yaw, deltaRotation.Yaw);
		//PITCH
		if ( (deltaRotation.Pitch != 0) && (!bRotateToDesired || (DesiredRotation.Pitch != NewRotation.Pitch)) )
			NewRotation.Pitch = fixedTurn(NewRotation.Pitch, DesiredRotation.Pitch, deltaRotation.Pitch);
		//ROLL
		if ( (deltaRotation.Roll != 0) && (!bRotateToDesired || (DesiredRotation.Roll != NewRotation.Roll)) )
			NewRotation.Roll = fixedTurn(NewRotation.Roll, DesiredRotation.Roll, deltaRotation.Roll);
	} else
	{
		Quat q;
	    EulerAngles sa;
		FLOAT RPitch, RYaw, RRoll;

		unsigned z = EulOrdXYZs;

		RPitch = (Rotation.Pitch / 65535.f) * 2.f * PI;
		RYaw   = (Rotation.Yaw   / 65535.f) * 2.f * PI;
		RRoll  = (Rotation.Roll  / 65536.f) * 2.f * PI;
		sa.x = RRoll; sa.y = RPitch; sa.z = RYaw; sa.w = z;
		q = Eul_ToQuat(sa);
		FQuat QRot;
		QRot.V.X = q.x;
		QRot.V.Y = q.y;
		QRot.V.Z = q.z;
		QRot.S   = q.w;

		RPitch	= (deltaRotation.Pitch / 65535.f) * 2.f * PI;
		RYaw	= (deltaRotation.Yaw   / 65535.f) * 2.f * PI;
		RRoll	= (deltaRotation.Roll  / 65535.f) * 2.f * PI;
		sa.x = RRoll; sa.y = RPitch; sa.z = RYaw; sa.w = z;
		q = Eul_ToQuat(sa);
		FQuat QRotDelta;
		QRotDelta.V.X = q.x;
		QRotDelta.V.Y = q.y;
		QRotDelta.V.Z = q.z;
		QRotDelta.S   = q.w;

		QRot *= QRotDelta;

		q.x = QRot.V.X;
		q.y = QRot.V.Y;
		q.z = QRot.V.Z;
		q.w = QRot.S;
		sa = Eul_FromQuat(q, z);
		RRoll = sa.x / (2.f*PI);
		NewRotation.Roll = appRound(65535 * RRoll);
		RPitch = sa.y / (2.f*PI);
		NewRotation.Pitch = appRound(65535 * RPitch);
		RYaw = sa.z / (2.f*PI);
		NewRotation.Yaw = appRound(65535 * RYaw);
	}

	// Set the new rotation.
	if(MountParent) // NJS: If mounted, just change mount angles
	{
		MountAngles=NewRotation;
	} else if( NewRotation != Rotation )
	{
		FCheckResult Hit(1.0);
		GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
	}

	if(MountParent)
	{
		// Mounted version:
		if ( bRotateToDesired && (MountAngles== DesiredRotation) && IsProbing(NAME_EndedRotation) )
			eventEndedRotation(); //tell thing rotation ended
	} else
	{
		if ( bRotateToDesired && (Rotation == DesiredRotation) && IsProbing(NAME_EndedRotation) )
			eventEndedRotation(); //tell thing rotation ended
	}

}

/*
physWalking()

*/
//-----------------------------------------------------------------------------
// climable and frictionless texture support routines 
//-----------------------------------------------------------------------------
//const float FRICTION_SLIPPERY  = 0.0;
//const float FRICTION_CLIMBABLE = 10.0;

INT FindSurfaceByName(AActor *Actor, FName SurfaceTag, INT After=-1 )
{
	UModel* Model = Actor->XLevel->Model;
	
	if(Model->Surfs.Num()>After+1)	// Do I have 
		for(int i=After+1;i<Model->Surfs.Num();i++)
		{
			FBspSurf* Surf = &Model->Surfs(i);
			if(Surf->SurfaceTag==SurfaceTag)
				return i;
		}
	
	// Couldn't find it, just return
	return -1;
}

static FBspSurf *GetSurfaceForIndex(AActor *Actor, INT SurfaceIndex)
{
	UModel* Model = Actor->XLevel->Model;

	// Make sure the surface is valid:
	if(SurfaceIndex<0) return NULL;
	if(SurfaceIndex>=Model->Surfs.Num()) return NULL;

	return &Model->Surfs(SurfaceIndex);
}

FName FindNameForSurface( AActor *Actor, INT SurfaceIndex )
{
	FBspSurf *Surf=GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return NAME_None;
	return Surf->SurfaceTag;
}


void SetSurfacePan(AActor *Actor, INT SurfaceIndex, INT PanU=0, INT PanV=0)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return;
	Surf->PanU=PanU;
	Surf->PanV=PanV;
}

int GetSurfaceUPan(AActor *Actor, INT SurfaceIndex)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return 0;
	return Surf->PanU;
}

int GetSurfaceVPan(AActor *Actor, INT SurfaceIndex)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return 0;
	return Surf->PanV;
}

UTexture *GetSurfaceTexture(AActor *Actor, INT SurfaceIndex)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return NULL;

	return Surf->Texture;
}

void SetSurfaceTexture(AActor *Actor, INT SurfaceIndex, UTexture *NewTexture)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor,SurfaceIndex);
	if(!Surf) return;
	Surf->Texture=NewTexture;
}

void SetSurfaceName(AActor* Actor, INT SurfaceIndex, FName NewName)
{
	FBspSurf* Surf = GetSurfaceForIndex(Actor, SurfaceIndex);
	if(!Surf) return;
	Surf->SurfaceTag = NewName;
}

void RenameAllSurfaces(AActor* Actor, FName OldName, FName NewName)
{
	UModel* Model = Actor->XLevel->Model;
	
	if(Model->Surfs.Num()>0)
		for(int i=1;i<Model->Surfs.Num();i++)
		{
			FBspSurf* Surf = &Model->Surfs(i);
			if(Surf->SurfaceTag==OldName)
				Surf->SurfaceTag = NewName;
		}
}

INT FindCoplanarSurface( UModel* Model, INT iNode, FVector IntersectionPoint, INT Depth, FVector &SurfUSize, FVector &SurfVSize )
{
	if( iNode == INDEX_NONE )
		return INDEX_NONE;

	FBspNode* Node = &Model->Nodes( iNode );
	if( Node->NumVertices > 0)
	{
		// check if this intersection point lies inside this node.
		FVert* Verts = &Model->Verts( Node->iVertPool );
		FVector &SurfNormal = Model->Vectors( Model->Surfs(Node->iSurf).vNormal );

		FVector* PrevVertex = &Model->Points(Verts[Node->NumVertices - 1].pVertex );
		
		UBOOL Success = 1;
		FLOAT PrevDot = 0;
		SurfUSize=(Model->Points(Verts[1].pVertex)-Model->Points(Verts[0].pVertex));
		SurfVSize=(Model->Points(Verts[1].pVertex)-Model->Points(Verts[2].pVertex));

		for( INT i=0;i<Node->NumVertices;i++ )
		{
			FVector* Vertex = &Model->Points(Verts[i].pVertex);
			FVector ClipNorm = SurfNormal ^ (*Vertex - *PrevVertex);
			FPlane ClipPlane( *Vertex, ClipNorm );
			FLOAT Dot = ClipPlane.PlaneDot( IntersectionPoint );
	 
			if( (Dot < 0 && PrevDot > 0) || (Dot > 0 && PrevDot < 0) )
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
	return FindCoplanarSurface( Model, Node->iPlane, IntersectionPoint,Depth + 1,SurfUSize,SurfVSize );
}

UTexture* TraceTexture
(
	AActor*			Actor,
	FCheckResult&	Hit,
	FVector&		SurfBase,
	FVector&		SurfU,
	FVector&		SurfV,
	FVector&		SurfUSize,
	FVector&		SurfVSize,
	FVector			TraceEnd,
	FVector			TraceStart=FVector(0,0,0),
	UTexture        *NewTexture=NULL,
	INT				*SurfaceIndexOut=NULL,
	DWORD			bCalcXY=0,
	INT				*x=NULL,
	INT				*y=NULL
)
{
	UTexture *Texture = NULL;
	UModel *Model = Actor->Level->XLevel->Model;
	Model->LineCheck( Hit, NULL, TraceEnd, TraceStart, FVector(0, 0, 0), 0 );
	if ( Hit.Item == INDEX_NONE )
	{
		return NULL;
	}

	// Attempt to locate the surface/texture associated with the BSP Node (Hit.Item)
	SurfBase = FVector(0, 0, 0);

	// Determine the node the trace actually hit (because the current Node could just be the first node in a number of coplanar nodes)
	FBspSurf& Surf = Model->Surfs( Model->Nodes(Hit.Item).iSurf );
	FVector& SurfNormal = Model->Vectors( Surf.vNormal );
	SurfBase = Model->Points(Surf.pBase);

	SurfU = Model->Vectors( Surf.vTextureU );
	SurfV = Model->Vectors( Surf.vTextureV );

	FVector Intersection = FLinePlaneIntersection( TraceStart, TraceEnd, SurfBase, SurfNormal );
	INT SurfIndex = FindCoplanarSurface( Model, Hit.Item, Intersection, 0, SurfUSize, SurfVSize );

	if ( SurfIndex != INDEX_NONE )
	{
		FBspSurf* Surf = &Model->Surfs( SurfIndex );
		Texture = Surf->Texture;
		if ( NewTexture ) Surf->Texture = NewTexture;
	}

	// let them know what the surfaceindex was
	if (SurfaceIndexOut)
		*SurfaceIndexOut = SurfIndex;

	// Now find the x,y texture location hit (if asked to do so)
	if (Texture && bCalcXY && x && y)
	{
		float		u, v, UScale, VScale;

		//UScale	= 1.0f / (Texture->USize * Texture->Scale);
		//VScale	= 1.0f / (Texture->VSize * Texture->Scale);
		UScale	= (Texture->Scale);
		VScale	= (Texture->Scale);

		u = (((Intersection - SurfBase) | SurfU) - Surf.PanU)*UScale;
		v = (((Intersection - SurfBase) | SurfV) - Surf.PanV)*VScale;
		
		*x = INT(u)&(Texture->USize-1);
		*y = INT(v)&(Texture->VSize-1);
	}

	return Texture;
}

static AMaterial* MaterialForTexture( UTexture* Texture )
{
	if(!Texture) return NULL;
	if(!Texture->Material)	
	{
		// Do I have a material name?
		if(Texture->MaterialName!=NAME_None)
		{
			TCHAR Name[256];

			UClass *Class=UClass::StaticClass();
			appSprintf(Name,TEXT("dnMaterial.%s"),*Texture->MaterialName);

			bool bMayFail=true;
			Texture->Material=(UClass *)Texture->StaticLoadObject( Class, NULL, Name, NULL, LOAD_NoWarn | (bMayFail?LOAD_Quiet:0), NULL );
		} 
	}

	// Try again now that I may have registered my material:
	if(!Texture->Material) return NULL;

	return (AMaterial *)Texture->Material->GetDefaultActor();
}

static UTexture* CheckClimbSurfaceForward( APawn* Pawn, FCheckResult& Hit )
{
    FVector StartTrace, EndTrace, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize;
	FRotator Rot;
	UTexture* Texture;

	Rot = Pawn->ViewRotation;
    Rot.Pitch = 0;

    StartTrace = Pawn->Location - FVector(0,0,0.7) * Pawn->CollisionHeight;
    EndTrace   = StartTrace + 2*Pawn->CollisionRadius * Rot.Vector();
    Texture    = TraceTexture( Pawn, Hit, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize, EndTrace, StartTrace );

    return Texture;
}

static UTexture* CheckClimbSurfaceForwardNoPitch( APawn* Pawn, FCheckResult& Hit )
{
    FVector StartTrace, EndTrace, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize;
	FRotator Rot;
	UTexture* Texture;

	Rot = Pawn->ViewRotation;
    Rot.Pitch = 0;

    StartTrace = Pawn->Location - FVector(0,0,0.7) * Pawn->CollisionHeight;
    EndTrace   = StartTrace + 2*Pawn->CollisionRadius * Rot.Vector();
    Texture    = TraceTexture( Pawn, Hit, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize, EndTrace, StartTrace );

    return Texture;
}

static UTexture* CheckClimbSurface( APawn* Pawn, FCheckResult& Hit, ELadderState &hitDir )
{
    FVector     StartTrace, EndTrace, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize;
	FRotator    Rot;
	UTexture*   Texture=NULL;
    INT         temp;

    Rot = Pawn->ViewRotation;
	Rot.Pitch = 0;
    StartTrace = Pawn->Location - FVector(0,0,1) * Pawn->CollisionHeight;    // Feet
    
    for ( temp=LADDER_None; temp<LADDER_Num_Directions; temp++ )
    {        
	    EndTrace = StartTrace + 2*Pawn->CollisionRadius * Rot.Vector();
	    Texture  = TraceTexture( Pawn, Hit, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize, EndTrace, StartTrace );
    
        if( MaterialForTexture(Texture) && (MaterialForTexture(Texture)->bClimbable) )
        {
            hitDir = (ELadderState)temp;
            return Texture;
        }
	    
        Rot.Yaw += 65536 / LADDER_Num_Directions;
    }

    hitDir = LADDER_None;
    return Texture;
}

static UTexture* CheckWalkSurface( APawn* Pawn, FCheckResult& Hit )
{
    FVector StartTrace, EndTrace, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize;
    UTexture* Texture;

	// trace from player origin to radius*2 below the collision cylinder
    StartTrace = Pawn->Location;
    EndTrace = StartTrace - (FVector(0,0,1) * ( Pawn->CollisionHeight + Pawn->CollisionRadius * 2 ));
    Texture = TraceTexture( Pawn, Hit, SurfBase, SurfU, SurfV, SurfUSize, SurfVSize, EndTrace, StartTrace );
	if(Texture) return Texture;

	return Texture;
}

static bool CheckSurfaces( APawn* Pawn, FLOAT deltaTime, INT Iterations, float *ZoneFriction, float &TexUPanSpeed, float &TexVPanSpeed )
{
	FCheckResult        Hit(1.0);
	UTexture            *Texture=NULL;
	AMaterial           *Material;
    APlayerPawn         *PlayerPawn;
	ELadderState        HitDir;
    AMaterial           *CurrentMaterial;
    FLOAT               scale;
    FRotator            Rot;

	if( Pawn->IsA( APlayerPawn::StaticClass() ) )
	{
        PlayerPawn = (APlayerPawn *)Pawn;
        
        Pawn->LastWalkMaterial=NULL;

        // If we're on a ladder and on the ground pressing back gets us off the ladder instantly
        if ( PlayerPawn->bOnGround && PlayerPawn->bWasBack )
        {
            if ( PlayerPawn->bOnLadder )
                PlayerPawn->eventOffLadder();

            PlayerPawn->bOnLadder = false;
            goto out;
        }

        // If we are on the ground and NOT on a ladder, then check for a ladder surface in front of us
        // but we don't care about our current pitch, so we can get on ladders without looking at them
        if ( PlayerPawn->bOnGround && !PlayerPawn->bOnLadder )
        {
		    Texture = CheckClimbSurfaceForwardNoPitch( Pawn, Hit );
            CurrentMaterial=MaterialForTexture(Texture);
                      
            if ( !CurrentMaterial )
                goto out;
            
            if ( !CurrentMaterial->bClimbable )
                goto out;
        }
        else if ( PlayerPawn->bOnGround && PlayerPawn->bOnLadder ) 
        {
            // We're on the ground and ON the ladder, so try to see if we can get off
		    Texture = CheckClimbSurfaceForward( Pawn, Hit );       
            CurrentMaterial=MaterialForTexture(Texture);    
 
            if ( PlayerPawn->bOnLadder )
                PlayerPawn->eventOffLadder();

            PlayerPawn->bOnLadder = false;
         
            if ( !CurrentMaterial )
                goto out;
            
            if ( !CurrentMaterial->bClimbable )
                goto out;
        }
		
        // Quick forward check to get on when we're close to the bottom of the ladder
        HitDir = LADDER_Forward;
        Texture = CheckClimbSurfaceForward( Pawn, Hit );

        // Check all around the player to see if we're still on the ladder
        if ( !Texture )
        {
            Texture = CheckClimbSurface( Pawn, Hit, HitDir );
        }

        if ( HitDir != PlayerPawn->LadderState )
            PlayerPawn->eventSetLadderState( HitDir );
    
		if( MaterialForTexture( Texture ) )
		{	
			CurrentMaterial = MaterialForTexture( Texture );

            // Only climb if the material is climbable and a short time has passed since we grabbed before.
			if( 
                ( CurrentMaterial->bClimbable ) && 
                ( PlayerPawn->GetLevel()->TimeSeconds > ( PlayerPawn->ladderJumpTime + 1.0 ) ) 
              )
			{
                // Ok, we're climbing a ladder.
                if ( !PlayerPawn->bOnLadder )
                    PlayerPawn->eventOnLadder();

				Material               = CurrentMaterial;    
                PlayerPawn->bOnLadder  = true;
                Pawn->LastWalkMaterial = Texture->Material;
                Pawn->eventWalkTexture( Texture, Hit.Location, Hit.Normal );                

                // Special controls for movement
				if( !Pawn->Acceleration.IsZero() )
				{
                    Rot = PlayerPawn->ViewRotation;
                    // Dot against UP to get a scalar for facing up or down.
                    scale = Rot.Vector() | FVector( 0,0,1 ); 
                    
                    // If we're facing the ladder directly, then go up
                    if ( scale == 0 )
                        scale = 0.5;
                    
                    // If we are facing forward or backward on the ladder and not strafing,
                    // then zero out the x/y movement so we don't go off the sides
                    if ( 
                         ( ( HitDir == LADDER_Forward ) || 
                           ( HitDir == LADDER_Backward ) || 
                           ( HitDir == LADDER_Backward_Right ) || 
                           ( HitDir == LADDER_Backward_Left ) ) &&
                         !( PlayerPawn->bWasLeft || PlayerPawn->bWasRight )
                       )
                    
                    {
                        PlayerPawn->Acceleration.X = 0;
                        PlayerPawn->Acceleration.Y = 0;
                    }                    

                    if ( PlayerPawn->bWasForward )
                    {
                        // Pressed forward, so translate speed into Z axis movement and dampen X/Y
                        PlayerPawn->Acceleration.X *= 0.6;
                        PlayerPawn->Acceleration.Y *= 0.6;
                        PlayerPawn->Acceleration.Z = 0;
                        PlayerPawn->Velocity.Z = PlayerPawn->GroundSpeed * scale;
                    }
                    else if ( PlayerPawn->bWasBack )  
                    {
                        // Pressed back, so translate speed into Z axis movement and dampen X/Y
                        PlayerPawn->Acceleration.X *= 0.6;
                        PlayerPawn->Acceleration.Y *= 0.6;
                        PlayerPawn->Acceleration.Z = 0;
                        PlayerPawn->Velocity.Z = PlayerPawn->GroundSpeed * -scale;
                    }
                    else
                    {
                        PlayerPawn->Velocity.Z = 0;
                    }
                    
                    // Scale upward velocity to move slower on climbables
                    PlayerPawn->Velocity.Z *= PlayerPawn->ladderSpeedFactor;

                    //Slow down X/Y movement so we don't fly off the ladder
                    if ( PlayerPawn->bWasLeft || PlayerPawn->bWasRight )  
                    {
                        // scale strafing
                        PlayerPawn->Velocity.X *= 0.8;
                        PlayerPawn->Velocity.Y *= 0.8;
                    }
                    else 
                    {
                        // scale normal movement
                        PlayerPawn->Velocity.X *= 0.7;
                        PlayerPawn->Velocity.Y *= 0.7;
                    }

				}
                else
                {
                    PlayerPawn->Velocity = FVector( 0,0,0 );
                }

                // Run the climbing physics
                Pawn->physClimbing( deltaTime, Iterations );

                // Sounds, don't do steps if we're not moving
                if ( Pawn->OldLocation == Pawn->Location )
                {
                    Pawn->LastWalkMaterial = NULL;
                }


/*
				if(Material->bLockClimbers)
				{
					// Should I vote no?
					FCheckResult Hit(1.0);
					Texture = CheckClimbSurface( Pawn, Hit, angle );
					if( !MaterialForTexture(Texture) || !(MaterialForTexture(Texture)->bClimbable)) 
					{
						// I vote no!
						Pawn->GetLevel()->FarMoveActor(Pawn,Location);
						Pawn->Velocity=FVector(0,0,0);
					}
				}
*/
				return true;
			}
            else // Texture is not climbable
            {        
                if ( PlayerPawn->bOnLadder )
                    PlayerPawn->eventOffLadder();
                PlayerPawn->bOnLadder = false;
            }
		}
        else // No Ladder in front of us
        {        
            if ( PlayerPawn->bOnLadder )
                PlayerPawn->eventOffLadder();
            PlayerPawn->bOnLadder = false;
        }
	}

out:

	if(Pawn->Physics==PHYS_Walking)
	{
		Pawn->LastWalkMaterial=NULL;

		Texture = CheckWalkSurface( Pawn, Hit );
		Pawn->eventWalkTexture( Texture, Hit.Location, Hit.Normal );
				
		if( Texture && MaterialForTexture(Texture) )
		{
			AMaterial *CurrentMaterial=MaterialForTexture(Texture);
			Pawn->LastWalkMaterial=Texture->Material;//MaterialForTexture(Texture);

			float Friction=CurrentMaterial->Friction;
			(*ZoneFriction)*=Friction;

			if(CurrentMaterial->AppliedForce.X||CurrentMaterial->AppliedForce.Y||CurrentMaterial->AppliedForce.Z)
			{
				UModel* Model = Pawn->XLevel->Model;

				const FBspNode*	Node = &Model->Nodes( Hit.Item );
				if( Node != NULL )
				{
					FVector MovementVector(0,0,0);
					MovementVector=CurrentMaterial->AppliedForce; 
					Pawn->GetLevel()->MoveActor( Pawn, MovementVector*deltaTime, Pawn->Rotation, Hit);

					{
						// Should I vote no?
						FCheckResult Hit(1.0);
						if(Texture!=CheckWalkSurface( Pawn, Hit ))
						{
							Pawn->Velocity=MovementVector*2;	
							Pawn->setPhysics(PHYS_Falling);
						}
					}
				}
			}

			if(Friction&&(Friction<1.0))
			{
				// compute slip direction
				FVector Slide = (deltaTime * Pawn->Region.Zone->ZoneGravity/(0.5 * ::Max(0.05f, 4.0f * Friction))) * deltaTime;
				FVector Delta = Slide - Hit.Normal * (Slide | Hit.Normal);
				if( (Delta | Slide) >= 0 )
					Pawn->GetLevel()->MoveActor( Pawn, Delta, Pawn->Rotation, Hit);	
			}
		
		}
	}
	return false;
}
//-----------------------------------------------------------------------------

void APawn::physWalking(FLOAT deltaTime, INT Iterations)
{

	float ZoneFriction=Region.Zone->ZoneGroundFriction;
	float TexUPanSpeed=Region.Zone->TexUPanSpeed;
	float TexVPanSpeed=Region.Zone->TexVPanSpeed;

	// NJS: Needs some tweaking to work with normal pawns: (also a small frame rate hit)
	//if(IsA(APlayerPawn::StaticClass()))
		if( CheckSurfaces( this, deltaTime, Iterations, &ZoneFriction, TexUPanSpeed, TexVPanSpeed ) )
			return;

	if ( Region.ZoneNumber == 0 )
	{
		// not in valid spot
		if ( Role == ROLE_Authority )
			debugf( TEXT("%s fell out of the world!"), GetName() );
		eventFellOutOfWorld();
		return;
	}



	//bound acceleration
	//goal - support +-Z gravity, but not other vectors
	Velocity.Z = 0;
	Acceleration.Z = 0;
	FVector AccelDir;
	if ( Acceleration.IsZero() )
		AccelDir = Acceleration;
	else
		AccelDir = Acceleration.SafeNormal();
	calcVelocity(AccelDir, deltaTime, GroundSpeed, ZoneFriction/*Region.Zone->ZoneGroundFriction*/, 0, 1, 0);   
	
	FVector DesiredMove = Velocity;
	if ( IsA(APlayerPawn::StaticClass()) || (Region.Zone->ZoneVelocity.SizeSquared() > 90000) )
	{
		// Add effect of velocity zone
		// Rather than constant velocity, hacked to make sure that velocity being clamped when walking doesn't 
		// cause the zone velocity to have too much of an effect at fast frame rates

		DesiredMove = DesiredMove + Region.Zone->ZoneVelocity * 25 * deltaTime;
	}
	DesiredMove.Z = 0.0;
	//-------------------------------------------------------------------------------------------
	//Perform the move
	FVector GravDir = FVector(0,0,-1);
	if (Region.Zone->ZoneGravity.Z > 0)
		GravDir.Z = 1;
	FVector Down = GravDir * (MaxStepHeight + 2.0);
	FCheckResult Hit(1.0);
	OldLocation = Location;
	bJustTeleported = 0;
	int bCheckedFall = 0;
	int bMustJump = 0;

	FLOAT remainingTime = deltaTime;
	FLOAT timeTick;

	// There can be only 1:
	//if((IsA(APawn::StaticClass())&&!IsA(APlayerPawn::StaticClass()))) return;

	while ( (remainingTime > 0.0) && (Iterations < 8) )
	{
		Iterations++;
		if ( (remainingTime > 0.05) && (IsA(APlayerPawn::StaticClass()) ||
			(DesiredMove.SizeSquared() * remainingTime * remainingTime > 400.f)) )
				timeTick = Min(0.05f, remainingTime * 0.5f);
		else timeTick = remainingTime;
		remainingTime -= timeTick;
		FVector Delta = timeTick * DesiredMove;
		FVector subLoc = Location;
		FVector subMove = Delta;
		int bZeroMove = Delta.IsNearlyZero();
		if ( bZeroMove )
		{
			remainingTime = 0;
			bHitSlopedWall = 0;
		}
		else
		{
			FVector ForwardCheck = AccelDir * CollisionRadius;
			if ( !bAvoidLedges )
				ForwardCheck *= 0.5; 
			// if AI controlled, check for fall by doing trace forward
			// try to find reasonable walk along ledge
			if ( (!IsA(APlayerPawn::StaticClass()) /*|| bIsWalking*/) && !bCanFly ) 
			{
				// check if clear in front
				FVector Destn = Location + Delta + ForwardCheck;
				GetLevel()->SingleLineCheck(Hit, this, Destn, Location, TRACE_VisBlocking);  
				if (Hit.Time == 1.0)
				{
					// clear in front - see if there is footing at walk destination
					FLOAT DesiredDist = Delta.Size();
					// check down enough to catch either step or slope
					FLOAT TestDown = ::Max( 4.f + MaxStepHeight + CollisionHeight, 4.f + CollisionHeight + CollisionRadius + DesiredDist);
					// try a point trace
					GetLevel()->SingleLineCheck(Hit, this, Destn + TestDown * GravDir, Destn , TRACE_VisBlocking);
					FLOAT MaxRadius = ::Min(14.f, 0.5f * CollisionRadius);
					// if point trace hit nothing, or hit a slope, do a trace with extent
					if ( (Hit.Time == 1.0) 
						|| ((Hit.Normal.Z > 0.7) && (Hit.Time * TestDown > CollisionHeight + MaxStepHeight + 4.f) 
							&& (Hit.Time * TestDown > CollisionHeight + 4.f + appSqrt(1 - Hit.Normal.Z * Hit.Normal.Z) * (CollisionRadius + DesiredDist)/Hit.Normal.Z)) )
						GetLevel()->SingleLineCheck(Hit, this, Destn + GravDir * (MaxStepHeight + 4.0), Destn , TRACE_VisBlocking, FVector(MaxRadius, MaxRadius, CollisionHeight));
					if (Hit.Time == 1.0)  
					{
						// We have a ledge!
						Destn = Location + DesiredDist * AccelDir + ForwardCheck;
						//first, try tracing back to get the ledge direction
						FVector DesiredDir = Delta/DesiredDist;
						FVector LedgeDown = GravDir * (CollisionHeight + 6.0);
						GetLevel()->SingleLineCheck(Hit, this, Location + LedgeDown - 2 * CollisionRadius * AccelDir, 
											Destn + LedgeDown , TRACE_VisBlocking);
						LedgeDown = GravDir * (MaxStepHeight + 6.0);
						FVector LedgeDir;
						int bMoveForward = 0;
						int bGoodMove = 0;
						if (Hit.Time < 1.0) //found a ledge
						{
							if ( bAvoidLedges )
							{
								LedgeDir = Hit.Normal;
								LedgeDir.Z = 0;
								Delta = -1 * DesiredSpeed * GroundSpeed * timeTick * LedgeDir;
								bMoveForward = 0;
								if ( bStopAtLedges )
									MoveTimer = -1;
								else
									MoveTimer -= 0.25;
							}
							else
							{
								LedgeDir.X = Hit.Normal.Y;
								LedgeDir.Y = -1 * Hit.Normal.X;
								LedgeDir.Z = 0;
								LedgeDir = LedgeDir.SafeNormal();
								if ( (LedgeDir | AccelDir) < 0 )
									LedgeDir *= -1;
								FLOAT DP = (LedgeDir | AccelDir );
								bMoveForward = ( (DP < 0.5) || (bCanJump && (DP < 0.7)) ) ;
								if ( DP < 0.7 )
									Delta = Min(0.8f, DesiredSpeed) * GroundSpeed * timeTick * LedgeDir;
								else
									Delta = DesiredSpeed * GroundSpeed * timeTick * LedgeDir;
							}
						}
						else 
						{
							Destn = Location + Delta + ForwardCheck;
							LedgeDir.X = DesiredDir.Y;
							LedgeDir.Y = -1 * DesiredDir.X;
							LedgeDir.Z = 0;
							bMoveForward = 1;
							Delta = Min(0.8f, DesiredSpeed) * GroundSpeed * timeTick * LedgeDir;
							Destn = Location + Delta;
							GetLevel()->SingleLineCheck(Hit, this, Destn, Location, TRACE_VisBlocking, GetCylinderExtent());
							if (Hit.Time == 1.0)
							{
								GetLevel()->SingleLineCheck(Hit, this, Destn + LedgeDown, Destn, TRACE_VisBlocking, GetCylinderExtent());
								if ( Hit.Time == 1.0 ) //reflect delta about desiredir
									Delta *= -1;
								else 
									bGoodMove = 1;
							}
							else 
								bGoodMove = 1;
						}
						if ( IsA(APlayerPawn::StaticClass()) )
						{
							bMoveForward = 0;
							if ( !bGoodMove )
							{
								Destn = Location + Delta + ForwardCheck;
								GetLevel()->SingleLineCheck(Hit, this, Destn, Location, TRACE_VisBlocking, GetCylinderExtent());
								if ( Hit.Time == 1.0 )
									GetLevel()->SingleLineCheck(Hit, this, Destn + LedgeDown, Destn, TRACE_VisBlocking, FVector(MaxRadius, MaxRadius, CollisionHeight));
								if (Hit.Time == 1.0)
								{
									Acceleration = FVector(0,0,0);
									Delta = FVector(0,0,0);
								}
							}
						}
						if ( bCanJump && bMoveForward )
						{
							if ( !IsProbing(NAME_MayFall) )
								Delta = AccelDir * DesiredDist;
							else if ( !bCheckedFall )
							{
								bCheckedFall = 1;
								bMoveForward = 0;
								eventMayFall();
								if ( bCanJump )
								{
									bMustJump = 1;
									Delta = AccelDir * DesiredDist;
								}
							}
						}
						if ( !bCanJump  ) //if can't jump, make sure this is valid
						{
							if ( bMoveForward ) //check if should just move forward
							{
								Destn = Location + DesiredDir * (DesiredDist + CollisionRadius);
								GetLevel()->SingleLineCheck(Hit, this, Destn, Location, TRACE_VisBlocking, GetCylinderExtent());
								if ( Hit.Time == 1.0 )
								{
									GetLevel()->SingleLineCheck(Hit, this, Destn + LedgeDown, Destn, TRACE_VisBlocking, GetCylinderExtent());
									if ( Hit.Time < 1.0 )
									{
										Destn = Location + DesiredDir * DesiredDist;
										GetLevel()->SingleLineCheck(Hit, this, Destn + LedgeDown, Destn, TRACE_VisBlocking, GetCylinderExtent());
									}
								}
								if ( Hit.Time < 1.0 )
									Delta = DesiredDir * DesiredDist;
								else 
								{
									bMoveForward = 0;
									if ( appFrand() < 2 * timeTick )
										MoveTimer = -1.0;
									else
										MoveTimer -= 0.1;
								}
							}
							if ( !bMoveForward && !bGoodMove )
							{
								Destn = Location + Delta + ForwardCheck;
								GetLevel()->SingleLineCheck(Hit, this, Destn, Location, TRACE_VisBlocking, GetCylinderExtent());
								if ( Hit.Time == 1.0 )
									GetLevel()->SingleLineCheck(Hit, this, Destn + LedgeDown, Destn, TRACE_VisBlocking, GetCylinderExtent());
								else if ( (Hit.Normal | DesiredDir) < MinHitWall )
									MoveTimer = -1.0;
								if (Hit.Time == 1.0)
								{
									GetLevel()->SingleLineCheck
										(Hit, this, Location + LedgeDown, Location , TRACE_VisBlocking, FVector(MaxRadius, MaxRadius, CollisionHeight));
									remainingTime = 0.0;
									MoveTimer = -1.0;
									Acceleration = FVector(0,0,0);
									if ( Hit.Time == 1.0 )
										Delta = -1 * GroundSpeed * timeTick * DesiredDir;
									else
										Delta = FVector(0,0,0);
								}
							}
						}
					}
				}
				subMove = Delta;
			}

			// check if might hit sloped wall, and decide if to change direction before move
			if ( bHitSlopedWall )
			{
				FLOAT DesiredDist = Delta.Size();
				FVector DesiredDir = Delta/DesiredDist;
				FVector CheckDir = DesiredDir * ::Max(30.f, DesiredDist + 4);
				GetLevel()->SingleLineCheck(Hit, this, Location + CheckDir, Location , TRACE_VisBlocking, GetCylinderExtent());
				bHitSlopedWall = ( (Hit.Time < 1.0) && (Hit.Normal.Z > 0.01) && (Hit.Normal.Z < 0.7) );
				if ( bHitSlopedWall )
				{
					Hit.Normal.Z = 0.0;
					Hit.Normal = Hit.Normal.SafeNormal();
					Delta = (Delta - Hit.Normal * (Delta | Hit.Normal));
				}
				else if ( this->IsA(APlayerPawn::StaticClass()) ) //make sure really done with sloped wall
				{
					FVector CheckLoc = Location;
					CheckLoc.Z = CheckLoc.Z - CollisionHeight + MaxStepHeight + 4;
					GetLevel()->SingleLineCheck(Hit, this, CheckLoc + 100 * DesiredDir, CheckLoc , TRACE_VisBlocking);
					bHitSlopedWall = ( (Hit.Time < 1.0) && (Hit.Normal.Z > 0.01) && (Hit.Normal.Z < 0.7) );
					if ( !bHitSlopedWall )
					{
						FVector LeftDir = FVector(DesiredDir.Y, -1 * DesiredDir.X, 0) + DesiredDir;
						LeftDir = LeftDir.SafeNormal();
						GetLevel()->SingleLineCheck(Hit, this, CheckLoc + 100 * LeftDir, CheckLoc , TRACE_VisBlocking);
						bHitSlopedWall = ( (Hit.Time < 1.0) && (Hit.Normal.Z > 0.01) && (Hit.Normal.Z < 0.7) );
					}
					if ( !bHitSlopedWall )
					{
						FVector LeftDir = FVector(-1 * DesiredDir.Y, DesiredDir.X, 0) + DesiredDir;
						LeftDir = LeftDir.SafeNormal();
						GetLevel()->SingleLineCheck(Hit, this, CheckLoc + 100 * LeftDir, CheckLoc , TRACE_VisBlocking);
						bHitSlopedWall = ( (Hit.Time < 1.0) && (Hit.Normal.Z > 0.01) && (Hit.Normal.Z < 0.7) );
					}
				} 
				GetLevel()->MoveActor(this, Delta, Rotation, Hit);
			}
			else
			{
				GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				bHitSlopedWall = ( (Hit.Time < 1.0) && (Hit.Normal.Z > 0.01) && (Hit.Normal.Z < 0.7) );
			}

			if (Hit.Time < 1.0) //try to step up
			{
				FVector DesiredDir = Delta.SafeNormal();
				stepUp(GravDir, DesiredDir, Delta * (1.0 - Hit.Time), Hit);
				if ( Physics == PHYS_Falling ) // pawn decided to jump up
				{
					FLOAT DesiredDist = subMove.Size();
					FLOAT ActualDist = (Location - subLoc).Size2D();
					remainingTime += timeTick * (1 - Min(1.f,ActualDist/DesiredDist)); 
					eventFalling();
					if ( Physics == PHYS_Falling ) 
					{
						if (remainingTime > 0.01)
							physFalling(remainingTime, Iterations);
					}
					else if ( Physics == PHYS_Flying )
					{
						Velocity = FVector(0,0, AirSpeed);
						Acceleration = FVector(0,0,AccelRate);
						if (remainingTime > 0.01)
							physFlying(remainingTime, Iterations);
					}
					return;
				}
			}

			if ( this->IsA(APawn::StaticClass()) && (Physics == PHYS_Swimming) ) //just entered water
			{
				((APawn *)this)->startSwimming(Velocity, timeTick, remainingTime, Iterations);
				return;
			}
		}

		//drop to floor
		if ( bZeroMove )
		{
			FVector Foot = Location - FVector(0,0,CollisionHeight);
			GetLevel()->SingleLineCheck( Hit, this, Foot - FVector(0,0,20), Foot, TRACE_VisBlocking );
			FLOAT FloorDist = Hit.Time * 20;
			bZeroMove = ((Base == Hit.Actor) && (FloorDist <= 4.6) && (FloorDist >= 4.1));
		}
		if ( !bZeroMove )
		{
			GetLevel()->SingleLineCheck( Hit, this, Location + Down, Location, TRACE_AllColliding, GetCylinderExtent() );
			FLOAT FloorDist = Hit.Time * (MaxStepHeight + 2.0);

			if ( (Hit.Time < 1.0) && ((Hit.Actor != Base) || (FloorDist > 2.4)) ) 
			{
				GetLevel()->MoveActor(this, Down, Rotation, Hit);
				if (Hit.Actor != Base)
					SetBase(Hit.Actor);
				if ( this->IsA(APawn::StaticClass()) && (Physics == PHYS_Swimming) ) //just entered water
				{
					((APawn *)this)->startSwimming(Velocity, timeTick, remainingTime, Iterations);
					return;
				}
			}
			else if ( FloorDist < 1.9 )
			{
				FVector realNorm = Hit.Normal;
				GetLevel()->MoveActor(this, FVector(0,0,2.1 - FloorDist), Rotation, Hit);
				Hit.Time = 0;
				Hit.Normal = realNorm;
			}
			
			if ( !bMustJump && (Hit.Time < 1.0) && (Hit.Normal.Z >= 0.7) )  
			{
				if ( (Hit.Normal.Z < 1.0) && ((Hit.Normal.Z * ZoneFriction/*Region.Zone->ZoneGroundFriction*/) < 3.3) ) //slide down slope, depending on friction and gravity
				{
					FVector Slide = (deltaTime * Region.Zone->ZoneGravity/(2 * ::Max(0.5f, ZoneFriction/*Region.Zone->ZoneGroundFriction*/))) * deltaTime;
					Delta = Slide - Hit.Normal * (Slide | Hit.Normal);
					if( (Delta | Slide) >= 0 )
						GetLevel()->MoveActor(this, Delta, Rotation, Hit);
					if ( this->IsA(APawn::StaticClass()) && (Physics == PHYS_Swimming) ) //just entered water
					{
						((APawn *)this)->startSwimming(Velocity, timeTick, remainingTime, Iterations);
						return;
					}
				}				
			}
			else
			{
				if ( !bMustJump && bCanJump && !bCheckedFall && IsProbing(NAME_MayFall) )
				{
					bCheckedFall = 1;
					eventMayFall();
				}
				if ( !bMustJump && (!bCanJump /*|| bIsWalking*/) ) 
				{
					Velocity = FVector(0,0,0);
					Acceleration = FVector(0,0,0);
					GetLevel()->FarMoveActor(this,OldLocation,0,0 );
					MoveTimer = -1.0;
					return;
				}
				else // falling
				{
					if ( Hit.Time < 1.0 )
						bHitSlopedWall = 1;
					FLOAT DesiredDist = subMove.Size();
					FLOAT ActualDist = (Location - subLoc).Size2D();
					if (DesiredDist == 0.0f)
						remainingTime = 0;
					else
						remainingTime += timeTick * (1 - Min(1.f,ActualDist/DesiredDist)); 
					Velocity.Z = 0.0;
					eventFalling();
					if (Physics == PHYS_Walking)
						setPhysics(PHYS_Falling); //default if script didn't change physics
					if ( !bMustJump && (Physics == PHYS_Falling) )
					{
						FLOAT velZ = Velocity.Z;
						if (!bJustTeleported && (deltaTime > remainingTime))
							Velocity = (Location - OldLocation)/(deltaTime - remainingTime);
						Velocity.Z = velZ;
						if (remainingTime > 0.01)
							physFalling(remainingTime, Iterations);
						return;
					}
					else 
					{
						Delta = remainingTime * DesiredMove;
						GetLevel()->MoveActor(this, Delta, Rotation, Hit); 
						remainingTime = 0;
					}
				}
			}
		}
	}

	//if ( Iterations > 7 )
	//	debugf("Over 7 iterations in physics!");
	// make velocity reflect actual move
	if (!bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;
	Velocity.Z = 0.0;
}

/* calcVelocity()
Calculates new velocity and acceleration for pawn for this tick
bounds acceleration and velocity, adds effects of friction and momentum
// bBrake only for walking?
// fixme - what is right for air turn rate - make it a pawn var?
// e.g. Max(bFluid * airbraking, friction)
*/
void APawn::calcVelocity(FVector AccelDir, FLOAT deltaTime, FLOAT maxSpeed, FLOAT friction, INT bFluid, INT bBrake, INT bBuoyant)
{
	FLOAT effectiveFriction = ::Max((FLOAT)bFluid,friction); 
	INT bWalkingPlayer = ( this->IsA(APlayerPawn::StaticClass()) && bIsWalking );
	if (bBrake && Acceleration.IsZero()) 
	{
		FVector OldVel = Velocity;
		FVector SumVel = FVector(0,0,0);

		FLOAT RemainingTime = deltaTime;
		// subdivide braking to get reasonably consistent results at lower frame rates
		// (important for packet loss situations w/ networking)
		while ( RemainingTime > 0.03 )
		{
			Velocity = Velocity - (2 * Velocity) * 0.03 * effectiveFriction; //don't drift to a stop, brake
			if ( (Velocity | OldVel) > 0.f )
				SumVel += 0.03 * Velocity/deltaTime;
			RemainingTime -= 0.03;
		}
		Velocity = Velocity - (2 * Velocity) * RemainingTime * effectiveFriction; //don't drift to a stop, brake
		if ( (Velocity | OldVel) > 0.f )
			SumVel += RemainingTime * Velocity/deltaTime;
		Velocity = SumVel;
		if ( ((OldVel | Velocity) < 0.0)
			|| (Velocity.SizeSquared() < 100) )//brake to a stop, not backwards
			Velocity = FVector(0,0,0);
	}
	else
	{
		FLOAT VelSize = Velocity.Size();
		if ( bWalkingPlayer )
		{
			if (Acceleration.SizeSquared() > 0.09 * AccelRate * AccelRate)
					Acceleration = AccelDir * AccelRate * 0.3;
		}
		else if (Acceleration.SizeSquared() > AccelRate * AccelRate)
			Acceleration = AccelDir * AccelRate;
		Velocity = Velocity - (Velocity - AccelDir * VelSize) * deltaTime * effectiveFriction;  
	}

	Velocity = Velocity * (1 - bFluid * friction * deltaTime) + Acceleration * deltaTime;

	if (!this->IsA(APlayerPawn::StaticClass()))
		maxSpeed *= DesiredSpeed;

	if ( bBuoyant )
		Velocity = Velocity + Region.Zone->ZoneGravity * deltaTime * (1.0 - Buoyancy/Mass);

	if ( bWalkingPlayer && (Velocity.SizeSquared() > 0.09 * maxSpeed * maxSpeed) )
	{
		FLOAT speed = Velocity.Size();
		Velocity = Velocity/speed;
		Velocity *= ::Max(0.3f * maxSpeed, speed * (1 - deltaTime * 2 * effectiveFriction)); 
	}
	else if (Velocity.SizeSquared() > maxSpeed * maxSpeed)
	{
		Velocity = Velocity.SafeNormal();
		Velocity *= maxSpeed;
	}


}

void APawn::stepUp(FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult &Hit)
{

	FVector Down = GravDir * MaxStepHeight;
	FVector Up = -1 * Down;
	GetLevel()->MoveActor(this, Up, Rotation, Hit); 
	GetLevel()->MoveActor(this, Delta, Rotation, Hit);
	if (Hit.Time < 1.0) 
	{
		if ( this->IsA(APlayerPawn::StaticClass()) && Hit.Actor->IsA(ADecoration::StaticClass()) && ((ADecoration *)(Hit.Actor))->bPushable
			&& ((Hit.Normal | DesiredDir) < -0.9) )
		{
			bJustTeleported = true;
			Velocity *= Mass/(Mass + Hit.Actor->Mass);
			processHitWall(Hit.Normal, Hit.Actor);
			if ( Physics == PHYS_Falling )
				return;
		}
		else if ((Abs(Hit.Normal.Z) < 0.2) && (Hit.Time * Delta.SizeSquared() > 144.0))
		{
			stepUp(GravDir, DesiredDir, Delta * (1 - Hit.Time), Hit);
			if ( Physics == PHYS_Falling )
				return;
		}
		else 
		{
			processHitWall(Hit.Normal, Hit.Actor);
			//adjust and try again
			FVector OriginalDelta = Delta;
			FVector OldHitNormal = Hit.Normal;
			Delta = (Delta - Hit.Normal * (Delta | Hit.Normal)) * (1.0 - Hit.Time);
			if( (Delta | OriginalDelta) >= 0 )
			{
				GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				if (Hit.Time < 1.0)
				{
					processHitWall(Hit.Normal, Hit.Actor);
					if ( Physics == PHYS_Falling )
						return;
					TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				}
			}
		}
	}
	GetLevel()->MoveActor(this, Down, Rotation, Hit);

	if ((Hit.Time < 1.0) && (Hit.Normal.Z < 0.5))
	{
		Delta = (Down - Hit.Normal * (Down | Hit.Normal))  * (1.0 - Hit.Time);
		if( (Delta | Down) >= 0 )
			GetLevel()->MoveActor(this, Delta, Rotation, Hit);
	} 

}

void AActor::processHitWall(FVector HitNormal, AActor *HitActor)
{
	if ( HitActor->IsA(APawn::StaticClass()) )
		return;

	if ( this->IsA(APawn::StaticClass()) )
	{
		if ( ((APawn *)this)->bForceHitWall && IsProbing(NAME_HitWall) )
		{
			eventHitWall(HitNormal, HitActor);
			return;
		}
		if ( Acceleration.IsZero() )
			return;
		FVector Dir = (((APawn *)this)->Destination - Location).SafeNormal();
		if ( Physics == PHYS_Walking )
		{
			HitNormal.Z = 0;
			Dir.Z = 0;
		}
		
		if ( ((APawn *)this)->MinHitWall < (Dir | HitNormal) )
			return;
		if ( !IsProbing(NAME_HitWall) && (Physics != PHYS_Falling) )
		{
			((APawn *)this)->MoveTimer = -1.0;
			((APawn *)this)->bFromWall = 1;
			return;
		}
	}
	else if ( !IsProbing(NAME_HitWall) )
	{
		return;
	}
	eventHitWall(HitNormal, HitActor);
}

#pragma DISABLE_OPTIMIZATION 
void AActor::processLanded(FVector HitNormal, AActor *HitActor, FLOAT remainingTime, INT Iterations)
{

	if ( !bIsPawn && Region.Zone->bBounceVelocity && (Region.Zone->ZoneVelocity != FVector(0,0,0)) )
	{
		Velocity = Region.Zone->ZoneVelocity + FVector(0,0,80);
		return;
	}
	if ( IsA(APawn::StaticClass()) ) //Check that it is a valid landing (not a BSP cut)
	{
		FCheckResult Hit(1.0);
		GetLevel()->SingleLineCheck(Hit, this, Location -  FVector(0,0,0.2 * CollisionRadius + 8),
			Location, TRACE_ProjTargets, 0.9 * GetCylinderExtent());  
		if ( Hit.Time == 1.0 ) //Not a valid landing
		{
			FVector Adjusted = Location;
			if ( GetLevel()->FindSpot(1.1 * GetCylinderExtent(), Adjusted, 0, 0) && (Adjusted != Location) )
			{
				GetLevel()->FarMoveActor(this, Adjusted, 0, 0);
				Velocity.X += appFrand() * 60 - 30;
				Velocity.Y += appFrand() * 60 - 30; 
				debugf( TEXT("ProcessLanded::Invalid Landing") );
				return;
			}
		}
	}
	else if ( IsA(ADecoration::StaticClass()) )
	{
		if ( ((ADecoration *)this)->numLandings < 5 ) // make sure its on a valid landing
		{
			FCheckResult Hit(1.0);
			GetLevel()->SingleLineCheck(Hit, this, Location -  FVector(0,0,(CollisionHeight + CollisionRadius + 8)),
				Location - FVector(0,0,(0.8 * CollisionHeight)) , TRACE_ProjTargets);  
			if ( !Hit.Actor )
			{
				FVector partExtent = 0.5 * GetCylinderExtent();
				partExtent.Z *= 2;
				int bQuad1 = GetLevel()->SingleLineCheck(Hit, this, Location + FVector(0.5 * CollisionRadius, 0.5 * CollisionRadius, -8),
					Location + FVector(0.5 * CollisionRadius, 0.5 * CollisionRadius, 0), TRACE_AllColliding, partExtent);
				int bQuad2 = GetLevel()->SingleLineCheck(Hit, this, Location + FVector(-0.5 * CollisionRadius, 0.5 * CollisionRadius, -8),
					Location + FVector(-0.5 * CollisionRadius, 0.5 * CollisionRadius, 0), TRACE_AllColliding, partExtent);
				int bQuad3 = GetLevel()->SingleLineCheck(Hit, this, Location + FVector(-0.5 * CollisionRadius, -0.5 * CollisionRadius, -8),
					Location + FVector(-0.5 * CollisionRadius, -0.5 * CollisionRadius, 0), TRACE_AllColliding, partExtent);
				int bQuad4 = GetLevel()->SingleLineCheck(Hit, this, Location + FVector(0.5 * CollisionRadius, -0.5 * CollisionRadius, -8),
					Location + FVector(0.5 * CollisionRadius, -0.5 * CollisionRadius, 0), TRACE_AllColliding, partExtent);
				
				if ( (bQuad1 + bQuad2 + bQuad3 + bQuad4 > 1) && !(bQuad1 + bQuad3 == 0) && !(bQuad2 + bQuad4 == 0) )
				{
					((ADecoration *)this)->numLandings++;
					Velocity = 2 * Clamp( -1.f * Velocity.Z, 30.f, 30.f + CollisionRadius) * 
								FVector((FLOAT)(bQuad1 + bQuad4 - bQuad2 - bQuad3), (FLOAT)(bQuad1 + bQuad2 - bQuad3 - bQuad4) , 0.5);
					return;
				}
			}
			if ( IsA(ACarcass::StaticClass()) && (HitNormal.Z < 0.9) && ((ACarcass *)this)->bSlidingCarcass )
			{
				if ( appFrand() < 0.2 )
					((ADecoration *)this)->numLandings++;
				Velocity = HitNormal * 120;
				Velocity.Z = 70;
				return;
			}
			((ADecoration *)this)->numLandings = 0;
		}
		else
			((ADecoration *)this)->numLandings = 0;
	}

	/*if(!*/eventLanded(HitNormal);/*)*/
//		return;

	//if (Physics == PHYS_Falling || Physics == PHYS_Jetpack)
	if ( Physics == PHYS_Falling )
	{
		if (this->IsA(APawn::StaticClass()))
			setPhysics(PHYS_Walking, HitActor);
		else
		{
			setPhysics(PHYS_None, HitActor);
			Velocity = FVector(0,0,0);
		}
	}

	if ((Physics == PHYS_Walking) && this->IsA(APawn::StaticClass()))
	{
		Acceleration = Acceleration.SafeNormal();
		if (remainingTime > 0.01)
			((APawn *)this)->physWalking(remainingTime, Iterations);
	}

}
#pragma ENABLE_OPTIMIZATION 

void AActor::physFalling(FLOAT deltaTime, INT Iterations)
{
	/*
	if(IsA(ADecoration::StaticClass()))
	{
		setPhysics(PHYS_None);	// NJS: Revert physics when I haven't moved for a frame:
		return;
	}
	*/

	//bound acceleration, falling object has minimal ability to impact acceleration
	APawn *ThisPawn = this->IsA(APawn::StaticClass()) ? (APawn*)this : NULL;

	float ZoneFriction=Region.Zone->ZoneGroundFriction;
	float TexUPanSpeed=Region.Zone->TexUPanSpeed;
	float TexVPanSpeed=Region.Zone->TexVPanSpeed;

	if( ThisPawn  )
		if(CheckSurfaces( ThisPawn, deltaTime, Iterations, &ZoneFriction, TexUPanSpeed, TexVPanSpeed))
            return;

	if ( Region.ZoneNumber == 0 )
	{
		// Not in valid spot.
		if ( (Role == ROLE_Authority)
			&& (IsA(AInventory::StaticClass()) || IsA(ADecoration::StaticClass()) || IsA(APawn::StaticClass())) )
			debugf( TEXT("%s fell out of the world!"), GetName() );
		eventFellOutOfWorld();
		return;
	}

	FLOAT BoundSpeed = 0; //Bound final 2d portion of velocity to this if non-zero
	FVector RealAcceleration = Acceleration;

	if (ThisPawn)
	{
		// For original Unreal air control, use ThisPawn->AirControl = 0.05
		// test for slope to avoid using air control to climb walls
		FLOAT AirControl = ThisPawn->AirControl;
		if( AirControl > 0.15f )
		{
			FVector TestWalk = ( AirControl * ThisPawn->AccelRate * Acceleration.SafeNormal() + Velocity ) * deltaTime;
			TestWalk.Z = 0;
			FCheckResult Hit(1.0);
			GetLevel()->SingleLineCheck( Hit, this, Location + TestWalk, Location, TRACE_VisBlocking, FVector( CollisionRadius, CollisionRadius, CollisionHeight ) );
			if( Hit.Actor != NULL )
				AirControl = 0.05f;
		}

		// boost maxAccel to increase player's control when falling
		FLOAT maxAccel = ThisPawn->AccelRate * AirControl;
		FVector Velocity2D = Velocity;
		Velocity2D.Z = 0;
		Acceleration.Z = 0;
		FLOAT speed2d = Velocity2D.Size2D(); 
		if (speed2d < 10.0) //allow initial burst
			maxAccel = maxAccel + (10 - speed2d)/deltaTime;
		else if ( speed2d >= ThisPawn->GroundSpeed )
		{
			if ( AirControl <= 0.05f )
				maxAccel = 1.f;
			else 
				BoundSpeed = speed2d;
		}

		if (Acceleration.SizeSquared() > maxAccel * maxAccel)
		{
			Acceleration = Acceleration.SafeNormal();
			Acceleration = Acceleration * maxAccel;
		}
	}
	FLOAT remainingTime = deltaTime;
	FLOAT timeTick = 0.1;
	int numBounces = 0;
	FCheckResult Hit(1.0);
	int AdjustApex = 0;

	while ( (remainingTime > 0.0) && (Iterations < 8) )
	{
		Iterations++;
		if (remainingTime > 0.1)
			timeTick = Min(0.1f, remainingTime * 0.5f);
		else timeTick = remainingTime;

		remainingTime -= timeTick;
		OldLocation = Location;
		bJustTeleported = 0;

		FVector OldVelocity = Velocity;
		

		if (!Region.Zone->bWaterZone)
		{
			if ( IsA(ADecoration::StaticClass()) && ((ADecoration *)this)->bBobbing ) 
				Velocity = OldVelocity + 0.5 * (Acceleration + 0.5 * Region.Zone->ZoneGravity) * timeTick; //average velocity for tick
			else if ( IsA(APlayerPawn::StaticClass()) && ((APawn *)this)->FootRegion.Zone->bWaterZone && (OldVelocity.Z < 0) )
			{
				Velocity = OldVelocity * (1 - ((APawn *)this)->FootRegion.Zone->ZoneFluidFriction * timeTick)
						+ 0.5 * (Acceleration + Region.Zone->ZoneGravity) * timeTick; 
			}
			else
				Velocity = OldVelocity + 0.5 * (Acceleration + Region.Zone->ZoneGravity) * timeTick; //average velocity for tick
		}
		else
		{
			Velocity = OldVelocity * (1 - 2 * Region.Zone->ZoneFluidFriction * timeTick) 
					+ 0.5 * (Acceleration + Region.Zone->ZoneGravity * (1.0 - Buoyancy/::Max(1.f,Mass))) * timeTick; 

			if (Buoyancy < Mass)
				Velocity *= Buoyancy / ::Max(1.f, Mass);
		}

		if ( !AdjustApex && ((OldVelocity.Z > 0) != (Velocity.Z > 0))
			&& (Abs(OldVelocity.Z) > 5.f) && (Abs(Velocity.Z) > 5.f)) //sign of Z component changed
		{
			AdjustApex = 1;
			FLOAT part = Abs(OldVelocity.Z)/(Abs(OldVelocity.Z) + Abs(Velocity.Z));
			if ((part * timeTick > 0.015) && ((1 - part) * timeTick > 0.015))
			{
				remainingTime = remainingTime + timeTick * (1 - part);
				timeTick = timeTick * part;
				if (!Region.Zone->bWaterZone)
				{
					if ( IsA(ADecoration::StaticClass()) && ((ADecoration *)this)->bBobbing ) 
						Velocity = OldVelocity + 0.5 * (Acceleration + 0.5 * Region.Zone->ZoneGravity) * timeTick; //average velocity for tick
					else if ( IsA(APlayerPawn::StaticClass()) && ((APawn *)this)->FootRegion.Zone->bWaterZone  && (OldVelocity.Z < 0) )
					{
						Velocity = OldVelocity * (1 - ((APawn *)this)->FootRegion.Zone->ZoneFluidFriction * timeTick)
								+ 0.5 * (Acceleration + Region.Zone->ZoneGravity) * timeTick; 
					}
					else
						Velocity = OldVelocity + 0.5 * (Acceleration + Region.Zone->ZoneGravity) * timeTick; //average velocity for tick
				}
				else
					Velocity = OldVelocity * (1 - 2 * Region.Zone->ZoneFluidFriction * timeTick) 
					+ 0.5 * (Acceleration + Region.Zone->ZoneGravity * (1.0 - Buoyancy/::Max(1.f,Mass))) * timeTick; 
			}
		}
		else
			AdjustApex = 0;
		if ( BoundSpeed != 0 )
		{
			// using air control, so make sure not exceeding acceptable speed
			FVector Vel2D = Velocity;
			Vel2D.Z = 0;
			if ( Vel2D.SizeSquared() > BoundSpeed * BoundSpeed )
			{
				Vel2D = Vel2D.SafeNormal();
				Vel2D = Vel2D * BoundSpeed;
				Vel2D.Z = Velocity.Z;
				Velocity = Vel2D;
			}
		}
		if ( Velocity.Z < -1200 )
			Velocity.Z = -1200; // Terminal velocity.
		FVector ZoneVel = FVector(0,0,0);
		if ( !bIsPawn || IsA(APlayerPawn::StaticClass()) || (Region.Zone->ZoneVelocity.SizeSquared() > 40000) )
			ZoneVel = Region.Zone->ZoneVelocity;

		FVector Adjusted = (Velocity + ZoneVel) * timeTick;

		
		if(!(GetLevel()->MoveActor(this, Adjusted, Rotation, Hit)))
		{
			if(PhysNoneOnStop)
			{
				setPhysics(PHYS_None);
				PhysNoneOnStop=0;
				return;
			}
		}
		
			
		if ( bDeleteMe )
			return;
		else if ( ThisPawn && (Physics == PHYS_Swimming) ) //just entered water
		{
			remainingTime = remainingTime + timeTick * (1.0 - Hit.Time);
			ThisPawn->startSwimming(OldVelocity, timeTick, remainingTime, Iterations);
			return;
		}
		else if ( Hit.Time < 1.0 )
		{
			if ( Hit.Actor->IsA(APlayerPawn::StaticClass()) && this->IsA(ADecoration::StaticClass()) )
				((ADecoration *)this)->numLandings = ::Max(0, ((ADecoration *)this)->numLandings - 1); 
			if (bBounce)
			{
				eventHitWall(Hit.Normal, Hit.Actor);
				if ( Physics == PHYS_None )
					return;
				else if ( numBounces < 2 )
					remainingTime += timeTick * (1.0 - Hit.Time);
				numBounces++;
			}
			else
			{
				if (Hit.Normal.Z > 0.7)
				{
					remainingTime += timeTick * (1.0 - Hit.Time);
					if (!bJustTeleported && (Hit.Time > 0.1) && (Hit.Time * timeTick > 0.003f) )
						Velocity = (Location - OldLocation)/(timeTick * Hit.Time);
					processLanded(Hit.Normal, Hit.Actor, remainingTime, Iterations);
					return;
				}
				else
				{
					processHitWall(Hit.Normal, Hit.Actor);
					FVector OldHitNormal = Hit.Normal;
					FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
					if( (Delta | Adjusted) >= 0 )
					{
						GetLevel()->MoveActor(this, Delta, Rotation, Hit);
						if (Hit.Time < 1.0) //hit second wall
						{
							if ( Hit.Normal.Z > 0.7 )
							{
								remainingTime = 0.0;
								processLanded(Hit.Normal, Hit.Actor, remainingTime, Iterations);
								return;
							}
							else 
								processHitWall(Hit.Normal, Hit.Actor);
		
							FVector DesiredDir = Adjusted.SafeNormal();
							TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
							int bDitch = ( (OldHitNormal.Z > 0) && (Hit.Normal.Z > 0) && (Delta.Z == 0) && ((Hit.Normal | OldHitNormal) < 0) );
							GetLevel()->MoveActor(this, Delta, Rotation, Hit);
							if ( bDitch || (Hit.Normal.Z > 0.7) )
							{
								remainingTime = 0.0;
								processLanded(Hit.Normal, Hit.Actor, remainingTime, Iterations);
								return;
							}
						}
					}
					FLOAT OldZ = OldVelocity.Z;
					OldVelocity = (Location - OldLocation)/timeTick;
					OldVelocity.Z = OldZ;
				}
			}
		}

		//if ( Iterations > 7 )
		//	debugf("More than 7 iterations in falling");
		if (!bBounce && !bJustTeleported)
		{
			// refine the velocity by figuring out the average actual velocity over the tick, and then the final velocity.
			// This particularly corrects for situations where level geometry affected the fall.
			Velocity = (Location - OldLocation)/timeTick - ZoneVel; //actual average velocity
			if ( (Velocity.Z < OldVelocity.Z) || (OldVelocity.Z >= 0) )
				Velocity = 2 * Velocity - OldVelocity; //end velocity has 2* accel of avg
			if (Velocity.SizeSquared() > Region.Zone->ZoneTerminalVelocity * Region.Zone->ZoneTerminalVelocity)
			{
				Velocity = Velocity.SafeNormal();
				Velocity *= Region.Zone->ZoneTerminalVelocity;
			}
		}
	}

	Acceleration = RealAcceleration;
}

void APawn::startSwimming(FVector OldVelocity, FLOAT timeTick, FLOAT remainingTime, INT Iterations)
{
	//debugf("fell into water");
	FVector End = Location;
	findWaterLine(GetLevel(), Level, OldLocation, End);
	FLOAT waterTime = 0.0;
	if (End != Location)
	{	
		waterTime = timeTick * (End - Location).Size()/(Location - OldLocation).Size();
		remainingTime += waterTime;
		FCheckResult Hit(1.0);
		GetLevel()->MoveActor(this, End - Location, Rotation, Hit);
	}
	if (!bBounce && !bJustTeleported)
		{
			Velocity = (Location - OldLocation)/(timeTick - waterTime); //actual average velocity
			Velocity = 2 * Velocity - OldVelocity; //end velocity has 2* accel of avg
			if (Velocity.SizeSquared() > 16000000.0)
			{
				Velocity = Velocity.SafeNormal();
				Velocity *= 4000.0;
			}
		//FIXME - calc. velocity more correctly everywhere
		}
	if ((Velocity.Z > -160.f) && (Velocity.Z < 0)) //allow for falling out of water
		Velocity.Z = -80.f - Velocity.Size2D() * 0.7; //smooth bobbing
	if (remainingTime > 0.01)
		physSwimming(remainingTime, Iterations);

}

void APawn::physClimbing(FLOAT deltaTime, INT Iterations)
{
    FVector ZoneVel;
	FVector AccelDir;
    FLOAT ZoneFriction=Region.Zone->ZoneGroundFriction;

    // Check for climbing out of the world
	if ( bCollideWorld && (Region.ZoneNumber == 0) )
	{
		// not in valid spot
		debugf( TEXT("%s climbed out of the world!"), GetName());
		if ( !bIsPlayer )
			GetLevel()->DestroyActor( this );
		return;
	}

    // Don't normalize a zero vector
	if ( Acceleration.IsZero() )
		AccelDir = Acceleration;
	else
		AccelDir = Acceleration.SafeNormal();

    // Get the velocity of the player
	calcVelocity(AccelDir, deltaTime, GroundSpeed, ZoneFriction, 0, 1, 0);  

	Iterations++;
	OldLocation      = Location;
	bJustTeleported  = 0;		
	ZoneVel          = FVector(0,0,0);
	FVector Adjusted = (Velocity + ZoneVel) * deltaTime; 
	FCheckResult Hit(1.0);
	GetLevel()->MoveActor(this, Adjusted, Rotation, Hit);

	if (Hit.Time < 1.0) 
	{
		FVector GravDir = FVector(0,0,-1);
		if (Region.Zone->ZoneGravity.Z > 0)
			GravDir.Z = 1;
		FVector DesiredDir = Adjusted.SafeNormal();
		FVector VelDir     = Velocity.SafeNormal();
		FLOAT UpDown       = GravDir | VelDir;

		if ( (Abs(Hit.Normal.Z) < 0.2) && (UpDown < 0.5) && (UpDown > -0.2) )
		{
			FLOAT stepZ    = Location.Z;
			stepUp(GravDir, DesiredDir, Adjusted * (1.0 - Hit.Time), Hit);
			OldLocation.Z  = Location.Z + (OldLocation.Z - stepZ);
		}
		else
		{
			processHitWall(Hit.Normal, Hit.Actor);
			//adjust and try again
			FVector OldHitNormal = Hit.Normal;
			FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
			if( (Delta | Adjusted) >= 0 )
			{
				GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				if (Hit.Time < 1.0) //hit second wall
				{
					processHitWall(Hit.Normal, Hit.Actor);
					TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				}
			}
		}
	}

	if (!bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;
}

void APawn::physFlying(FLOAT deltaTime, INT Iterations)
{

	FVector AccelDir;

	if ( bCollideWorld && (Region.ZoneNumber == 0) )
	{
		// not in valid spot
		debugf( TEXT("%s flew out of the world!"), GetName());
		if ( !bIsPlayer )
			GetLevel()->DestroyActor( this );
		return;
	}
	if ( Acceleration.IsZero() )
		AccelDir = Acceleration;
	else
		AccelDir = Acceleration.SafeNormal();
	calcVelocity(AccelDir, deltaTime, AirSpeed, Region.Zone->ZoneFluidFriction, 1, 0, 0);  

	Iterations++;
	OldLocation = Location;
	bJustTeleported = 0;
	FVector ZoneVel;
	if ( this->IsA(APlayerPawn::StaticClass()) || (Region.Zone->ZoneVelocity.SizeSquared() > 90000) )
		ZoneVel = Region.Zone->ZoneVelocity;
	else
		ZoneVel = FVector(0,0,0);
	FVector Adjusted = (Velocity + ZoneVel) * deltaTime; 
	FCheckResult Hit(1.0);
	GetLevel()->MoveActor(this, Adjusted, Rotation, Hit);
	if (Hit.Time < 1.0) 
	{
		FVector GravDir = FVector(0,0,-1);
		if (Region.Zone->ZoneGravity.Z > 0)
			GravDir.Z = 1;
		FVector DesiredDir = Adjusted.SafeNormal();
		FVector VelDir = Velocity.SafeNormal();
		FLOAT UpDown = GravDir | VelDir;
		if ( (Abs(Hit.Normal.Z) < 0.2) && (UpDown < 0.5) && (UpDown > -0.2) )
		{
			FLOAT stepZ = Location.Z;
			stepUp(GravDir, DesiredDir, Adjusted * (1.0 - Hit.Time), Hit);
			OldLocation.Z = Location.Z + (OldLocation.Z - stepZ);
		}
		else
		{
			processHitWall(Hit.Normal, Hit.Actor);
			//adjust and try again
			FVector OldHitNormal = Hit.Normal;
			FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
			if( (Delta | Adjusted) >= 0 )
			{
				GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				if (Hit.Time < 1.0) //hit second wall
				{
					processHitWall(Hit.Normal, Hit.Actor);
					TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
				}
			}
		}
	}

	if( bFlyingVehicle && ( Velocity.X > 100 || Velocity.X <= -100 ) )
	{
		FLOAT MaxPitch = 28000.f;
		FRotator NewRotation = FRotator(0,0,0);
		NewRotation.Pitch = 0;
		FVector Facing = Rotation.Vector();
		NewRotation.Pitch = -5000; 
		Rotation.Pitch = Rotation.Pitch & 65535;
		if (NewRotation.Pitch > 32768)
		{
			if (Rotation.Pitch < 32768)
				Rotation.Pitch += 65536;
		}
		else if (Rotation.Pitch > 32768)
			Rotation.Pitch -= 65536;
	
		FLOAT SmoothPitch = Min(1.f, 5.f * deltaTime);
		NewRotation.Pitch = (INT) (NewRotation.Pitch * SmoothPitch + Rotation.Pitch * (1 - SmoothPitch));
		NewRotation.Yaw = Rotation.Yaw;
		NewRotation.Roll = Rotation.Roll;
		if( NewRotation != Rotation )
		{
			FCheckResult Hit(1.0);
			GetLevel()->MoveActor( this, FVector(0,0,0), NewRotation, Hit );
		}
	}

	if (!bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;
}

/* Swimming uses gravity - but scaled by (mass - buoyancy)/mass
This is used only by pawns 

*/
// findWaterLine is temporary until trace supports zone change notification
FLOAT APawn::Swim(FVector Delta, FCheckResult &Hit)
{
	FVector Start = Location;
	FLOAT airTime = 0.0;
	GetLevel()->MoveActor(this, Delta, Rotation, Hit);
	FVector End = Location;
	if (!Region.Zone->bWaterZone) //then left water
	{
		findWaterLine(GetLevel(), Level, Start, End);
		if (End != Location)
		{
			airTime = (End - Location).Size()/Delta.Size();
			GetLevel()->MoveActor(this, End - Location, Rotation, Hit);
		}
	}
	return airTime;
}

//get as close to waterline as possible, staying on same side as currently
void APawn::findWaterLine(ULevel* XLevel, ALevelInfo* Level, FVector Start, FVector &End)
{
	if ((End - Start).SizeSquared() < 0.5)
		return; //current value of End is acceptable

	FVector MidPoint = 0.5 * (Start + End);
	FPointRegion EndRegion = XLevel->Model->PointRegion( Level, End );
	FPointRegion MidRegion = XLevel->Model->PointRegion( Level, MidPoint );
	if( MidRegion.Zone->bWaterZone != EndRegion.Zone->bWaterZone )
		Start = MidPoint; 
	else
		End = MidPoint;

	findWaterLine(XLevel, Level, Start, End);
}

void APawn::physSwimming(FLOAT deltaTime, INT Iterations)
{

	float UnusedZoneFriction=1.0;
	float UnusedPan=0;
	if( CheckSurfaces( this, deltaTime, Iterations,&UnusedZoneFriction,UnusedPan,UnusedPan ) )
		return;

	if (!HeadRegion.Zone->bWaterZone && (Velocity.Z > 100.f))
		//damp positive Z out of water
		Velocity.Z = Velocity.Z * (1 - deltaTime);

	Iterations++;
	OldLocation = Location;
	bJustTeleported = 0;
	FVector AccelDir;
	if ( Acceleration.IsZero() )
		AccelDir = Acceleration;
	else
		AccelDir = Acceleration.SafeNormal();
	calcVelocity(AccelDir, deltaTime, WaterSpeed, Region.Zone->ZoneFluidFriction, 1, 0, 1);  
	FLOAT velZ = Velocity.Z;
	FVector ZoneVel;
	if ( this->IsA(APlayerPawn::StaticClass()) || (Region.Zone->ZoneVelocity.SizeSquared() > 90000) )
	{
		// Add effect of velocity zone
		// Rather than constant velocity, hacked to make sure that velocity being clamped when swimming doesn't 
		// cause the zone velocity to have too much of an effect at fast frame rates

		ZoneVel = Region.Zone->ZoneVelocity * 25 * deltaTime;
	}
	else
		ZoneVel = FVector(0,0,0);
	FVector Adjusted = (Velocity + ZoneVel) * deltaTime; 
	FCheckResult Hit(1.0);
	FLOAT remainingTime = deltaTime * Swim(Adjusted, Hit);

	if (Hit.Time < 1.0) 
	{
		FVector GravDir = FVector(0,0,-1);
		if (Region.Zone->ZoneGravity.Z > 0)
			GravDir.Z = 1;
		FVector DesiredDir = Adjusted.SafeNormal();
		FVector VelDir = Velocity.SafeNormal();
		FLOAT UpDown = GravDir | VelDir;
		if ( (Abs(Hit.Normal.Z) < 0.2) && (UpDown < 0.5) && (UpDown > -0.2) )
		{
			FLOAT stepZ = Location.Z;
			stepUp(GravDir, DesiredDir, Adjusted * (1.0 - Hit.Time), Hit);
			OldLocation.Z = Location.Z + (OldLocation.Z - stepZ);
		}
		else
		{
			processHitWall(Hit.Normal, Hit.Actor);
			//adjust and try again
			FVector OldHitNormal = Hit.Normal;
			FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
			if( (Delta | Adjusted) >= 0 )
			{
				remainingTime = remainingTime * (1.0 - Hit.Time) * Swim(Delta, Hit);
				if (Hit.Time < 1.0) //hit second wall
				{
					processHitWall(Hit.Normal, Hit.Actor);
					TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
					remainingTime = remainingTime * (1.0 - Hit.Time) * Swim(Delta, Hit);
				}
			}
		}
	}

	if (!bJustTeleported && (remainingTime < deltaTime))
	{
		int bWaterJump = (velZ != Velocity.Z); //changed by script
		if (bWaterJump)
			velZ = Velocity.Z;
		Velocity = (Location - OldLocation) / (deltaTime - remainingTime);
		if (bWaterJump)
			Velocity.Z = velZ;
	}

	if (!Region.Zone->bWaterZone)
	{
		if (Physics == PHYS_Swimming)
			setPhysics(PHYS_Falling); //in case script didn't change it (w/ zone change)
		if ((Velocity.Z < 160.f) && (Velocity.Z > 0)) //allow for falling out of water
			Velocity.Z = 40.f + Velocity.Size2D() * 0.4; //smooth bobbing
	}

	if (remainingTime > 0.01) //may have left water - if so, script might have set new physics mode
	{
		if (Physics == PHYS_Falling) 
			physFalling(remainingTime, Iterations);
		else if (Physics == PHYS_Flying)
			physFlying(remainingTime, Iterations);
	}

}

/* PhysProjectile is tailored for projectiles 
*/
void AActor::physProjectile(FLOAT deltaTime, INT Iterations)
{

	//bound acceleration, calculate velocity, add effects of friction and momentum
	//friction affects projectiles less (more aerodynamic)
	FLOAT remainingTime = deltaTime;
	int numBounces = 0;

	if ( Region.ZoneNumber == 0 )
	{
		GetLevel()->DestroyActor( this );
		return;
	}

	OldLocation = Location;
	bJustTeleported = 0;
	FCheckResult Hit(1.0);

	while ( (remainingTime > 0.0) && (Iterations < 8) )
	{
		Iterations++;
		if ( Region.Zone->bWaterZone )
			Velocity = (Velocity * (1 - 0.2 * Region.Zone->ZoneFluidFriction * remainingTime));
		Velocity = Velocity	+ Acceleration * remainingTime;
		FLOAT timeTick = remainingTime;
		remainingTime = 0.0;

		if ( this->IsA(AProjectile::StaticClass()) 
			&& (Velocity.SizeSquared() > ((AProjectile *)this)->MaxSpeed * ((AProjectile *)this)->MaxSpeed) )
		{
			Velocity = Velocity.SafeNormal();
			Velocity *= ((AProjectile *)this)->MaxSpeed;
		}

		FVector Adjusted = Velocity * deltaTime; 
		Hit.Time = 1.0;
		GetLevel()->MoveActor(this, Adjusted, Rotation, Hit);
		
		if ( (Hit.Time < 1.0) && !bDeleteMe && !bJustTeleported )
		{
			FVector DesiredDir = Adjusted.SafeNormal();
			eventHitWall(Hit.Normal, Hit.Actor);
			if (bBounce)
			{
				if (numBounces < 2)
					remainingTime = timeTick * (1.0 - Hit.Time);
				numBounces++;
				if (Physics == PHYS_Falling)
					physFalling(remainingTime, Iterations);
			}
		}
	}

	//if ( Iterations > 7 )
	//	debugf("Projectile with too many physics iterations!");
	if (!bBounce && !bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;

}

/*
physRolling() - intended for non-pawns which are rolling or sliding along a floor

*/

void AActor::physRolling(FLOAT deltaTime, INT Iterations)
{
	//bound acceleration
	//goal - support +-Z gravity, but not other vectors
	//note that Z components of velocity and acceleration are not zeroed
	FVector VelDir = Velocity.SafeNormal();
	FVector AccelDir = Acceleration.SafeNormal();
	Velocity = Velocity - (VelDir - AccelDir) * Velocity.Size()
		* deltaTime * (Region.Zone->ZoneGroundFriction+GroundFriction);

//	Velocity = Velocity * (1 - Region.Zone->ZoneFluidFriction * deltaTime) + Acceleration * deltaTime;
	Velocity = Velocity + Acceleration * deltaTime;
	FVector DesiredMove = Velocity + Region.Zone->ZoneVelocity;
	OldLocation = Location;
	bJustTeleported = 0;

	//-------------------------------------------------------------------------------------------
	//Perform the move
	FLOAT remainingTime = deltaTime;
	FLOAT timeTick = 0.1;
	FVector GravDir = FVector(0,0,-1);
	if (Region.Zone->ZoneGravity.Z > 0)
		GravDir.Z = 1; 
	FVector Down = GravDir * 16.0;
	FCheckResult Hit(1.0);
	//int numBounces = 0;
	while ( (remainingTime > 0.0) && (Iterations < 8) )
	{
		Iterations++;
		if (remainingTime > 0.1)
			timeTick = Min(0.1f, remainingTime * 0.5f);
		else timeTick = remainingTime;

		remainingTime -= timeTick;
		FVector Delta = timeTick * DesiredMove;
		FVector SubMove = Delta;
		FVector SubLoc = Location;
		if (!Delta.IsNearlyZero())
		{
			GetLevel()->MoveActor(this, Delta, Rotation, Hit);
			if (Hit.Time < 1.0) 
			{
				eventHitWall(Hit.Normal, Hit.Actor);

				processHitWall(Hit.Normal, Hit.Actor);
				//adjust and try again
				FVector OriginalDelta = Delta;
				FVector OldHitNormal = Hit.Normal;
				Delta = (Delta - Hit.Normal * (Delta | Hit.Normal)) * (1.0 - Hit.Time);
				if( (Delta | OriginalDelta) >= 0 )
				{
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
					if (Hit.Time < 1.0)
					{
						processHitWall(Hit.Normal, Hit.Actor);
						if ( Physics == PHYS_Falling )
							return;
						TwoWallAdjust(Velocity, Delta, Hit.Normal, OldHitNormal, Hit.Time);
						GetLevel()->MoveActor(this, Delta, Rotation, Hit);
					}
				}
				/*
				if (bBounce)
				{
					if (numBounces < 2)
						remainingTime += timeTick * (1.0 - Hit.Time);
					numBounces++;
				}
				else
				{
					//adjust and try again
					FVector OriginalDelta = Delta;
			
					// Try again.
					FVector OldHitNormal = Hit.Normal;
					Delta = (Delta - Hit.Normal * (Delta | Hit.Normal)) * (1.0 - Hit.Time);
					if( (Delta | OriginalDelta) >= 0 )
					{
						GetLevel()->MoveActor(this, Delta, Rotation, Hit);
						if (Hit.Time < 1.0)
						{
							eventHitWall(Hit.Normal, Hit.Actor);
							FVector DesiredDir = DesiredMove.SafeNormal();
							TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
							GetLevel()->MoveActor(this, Delta, Rotation, Hit);
						}
					}
				}
				*/
			}
		}

		//drop to floor
		GetLevel()->MoveActor(this, Down, Rotation, Hit);
		FLOAT DropTime = Hit.Time;
		FLOAT DropHitZ = Hit.Normal.Z;
		if (DropTime < 1.0) //slide down slope, depending on friction and gravity 
		{
			if ((Hit.Normal.Z < 1.0) && ((Hit.Normal.Z * Region.Zone->ZoneGroundFriction) < 3.3))
			{
				FVector Slide = (deltaTime * Region.Zone->ZoneGravity/(2 * ::Max(0.5f, Region.Zone->ZoneGroundFriction))) * deltaTime;
				Delta = Slide - Hit.Normal * (Slide | Hit.Normal);
				if( (Delta | Slide) >= 0 )
				{
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
					DropHitZ = ::Max(DropHitZ, Hit.Normal.Z);
				}
			}				
		}

		if ((DropTime == 1.0) || (DropHitZ < 0.7)) //then falling
		{
			FVector AdjustUp = -1 * (Down * DropTime); 
			GetLevel()->MoveActor(this, AdjustUp, Rotation, Hit);
			FLOAT DesiredDist = SubMove.Size();
			FLOAT ActualDist = (Location - SubLoc).Size2D();
			remainingTime += timeTick * (1 - Min(1.f,ActualDist/DesiredDist)); 
			eventFalling();
			if (Physics == PHYS_Rolling)
				setPhysics(PHYS_Falling); //default if script didn't change physics
			if (Physics == PHYS_Falling)
			{
				if (!bJustTeleported && (deltaTime > remainingTime))
					Velocity = (Location - OldLocation)/(deltaTime - remainingTime);
				Velocity.Z = 0.0;

				if (remainingTime > 0.005)
					physFalling(remainingTime, Iterations);
				return;
			}
			else 
			{
				Delta = remainingTime * DesiredMove;
				GetLevel()->MoveActor(this, Delta, Rotation, Hit); 
			}
		}
		else if( Hit.Actor != Base)
		{
			// Handle floor notifications (standing on other actors).
			//debugf("%s is now on floor %s",GetFullName(),Hit.Actor ? Hit.Actor->GetFullName() : "None");
			SetBase( Hit.Actor );
		}			//drop to floor

	}
	// make velocity reflect actual move
	if (!bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;

	if ( Velocity.Size() < 10.f )
		eventStoppedRolling();
}


/*
physSpider()

*/
inline int APawn::checkFloor(FVector Dir, FCheckResult &Hit)
{
	GetLevel()->SingleLineCheck(Hit, 0, Location - MaxStepHeight * Dir, Location, TRACE_VisBlocking, GetCylinderExtent());
	if (Hit.Time < 1.0)
	{
		Floor = Hit.Normal;
		return 1;
	}
	return 0;
}

int APawn::findNewFloor(FVector OldLocation, FLOAT deltaTime, FLOAT remainingTime, int Iterations)
{
	
	//look for floor
	FCheckResult Hit(1.0);
	//debugf("Find new floor for %s", GetFullName());
	// JC: Added below 2 lines to support snatchers hanging from ceiling.
	if( checkFloor(FVector(0,0,-1), Hit) )
		return 1;
	if ( checkFloor(FVector(0,0,1), Hit) )
		return 1;
	if ( checkFloor(FVector(0,1,0), Hit) )
		return 1;
	if ( checkFloor(FVector(0,-1,0), Hit) )
		return 1;
	if ( checkFloor(FVector(1,0,0), Hit) )
		return 1;
	if ( checkFloor(FVector(-1,0,0), Hit) )
		return 1;

	// Fall
	eventFalling();
	if (Physics == PHYS_Spider)
		setPhysics(PHYS_Falling); //default if script didn't change physics
	if (Physics == PHYS_Falling)
	{
		FLOAT velZ = Velocity.Z;
		if (!bJustTeleported && (deltaTime > remainingTime))
			Velocity = (Location - OldLocation)/(deltaTime - remainingTime);
		Velocity.Z = velZ;
		if (remainingTime > 0.005)
			physFalling(remainingTime, Iterations);
	}

	return 0;

}

//#pragma DISABLE_OPTIMIZATION
void APawn::physSpider(FLOAT deltaTime, INT Iterations)
{

	//calculate velocity
	FVector AccelDir;
	if ( Acceleration.IsZero() ) 
	{
		AccelDir = Acceleration;
		FVector OldVel = Velocity;
		Velocity = Velocity - (2 * Velocity) * deltaTime * Region.Zone->ZoneGroundFriction; //don't drift to a stop, brake
		if ((OldVel | Velocity) < 0.0) //brake to a stop, not backwards
			Velocity = Acceleration;
	}
	else
	{
		AccelDir = Acceleration.SafeNormal();
		FLOAT VelSize = Velocity.Size();
		if (Acceleration.SizeSquared() > AccelRate * AccelRate)
			Acceleration = AccelDir * AccelRate;
		Velocity = Velocity - (Velocity - AccelDir * VelSize) * deltaTime * Region.Zone->ZoneGroundFriction;  
	}

	Velocity = Velocity + Acceleration * deltaTime;
	FLOAT maxSpeed = GroundSpeed * DesiredSpeed;
	Iterations++;

	if (Velocity.SizeSquared() > maxSpeed * maxSpeed)
	{
		Velocity = Velocity.SafeNormal();
		Velocity *= maxSpeed;
	}
	FVector ZoneVel;
	if ( Region.Zone->ZoneVelocity.SizeSquared() > 90000 )
		ZoneVel = Region.Zone->ZoneVelocity;
	else
		ZoneVel = FVector(0,0,0);
	FVector DesiredMove = Velocity + ZoneVel;
	FLOAT MoveSize = DesiredMove.Size();
	FVector DesiredDir = DesiredMove/MoveSize;

	//Perform the move
	// Look for supporting wall
	int bFindNewFloor = Floor.IsNearlyZero();
	FCheckResult Hit(1.0);
	FVector GravDir = -1 * Floor;
	FVector Down = GravDir * (MaxStepHeight + 4.0);
	DesiredRotation = Rotation;
	if (!bFindNewFloor)
	{
		GetLevel()->SingleLineCheck(Hit, 0, Location + Down, Location, TRACE_VisBlocking, GetCylinderExtent());
		bFindNewFloor = (Hit.Time == 1.0);
	}
	if (bFindNewFloor)
	{
		if ( !findNewFloor(Location, deltaTime, deltaTime, Iterations) ) //find new floor or fall
			return;
		else
		{
			GravDir = -1 * Floor;
			Down = GravDir * (MaxStepHeight + 4.0);
		}
	}

	DesiredRotation = Floor.Rotation();
	DesiredRotation.Pitch -= 16384;
	DesiredRotation.Roll = 0;

	// modify desired move based on floor
	FLOAT dotp = AccelDir | Floor;
	FVector realDir = DesiredDir;
	if ( (Floor.Z < 0.6) && (dotp > 0.9) )
	{
		Floor = FVector(0,0,0);
		eventFalling();
		setPhysics(PHYS_Falling); 
		physFalling(deltaTime, Iterations);
		return;
	}
	else
	{
		DesiredDir = DesiredDir - Floor * (DesiredDir | Floor);
		DesiredDir = DesiredDir.SafeNormal();
	}

	OldLocation = Location;
	bJustTeleported = 0;

	FLOAT remainingTime = deltaTime;
	FLOAT timeTick = 0.05;
	DesiredMove = MoveSize * DesiredDir;
	while ( (remainingTime > 0.0) && (Iterations < 8) )
	{
		Iterations++;
		if (remainingTime > 0.05)
			timeTick = Min(0.05f, remainingTime * 0.5f);
		else timeTick = remainingTime;
		remainingTime -= timeTick;
		FVector Delta = timeTick * DesiredMove;
		FVector subLoc = Location;
		FVector subMove = Delta;

		if (!Delta.IsNearlyZero())
		{
			GetLevel()->MoveActor(this, Delta, DesiredRotation, Hit);
			if (Hit.Time < 1.0) 
			{
				if (Hit.Normal.Z >= 0)
				{
					if ( ((Hit.Normal | realDir) < 0) && ((Floor | realDir) < 0) ) 
						eventHitWall(Hit.Normal, Hit.Actor);
					else
					{
						FVector Combo = (Hit.Normal + Floor).SafeNormal();
						if ( (realDir | Combo) > 0.9 )
							eventHitWall(Hit.Normal, Hit.Actor);
					}
					Floor = Hit.Normal;
					GravDir = -1 * Floor;
					Down = GravDir * (MaxStepHeight + 4.0);
				}
				else if ( (Hit.Normal | realDir) < 0 ) 
					eventHitWall(Hit.Normal, Hit.Actor);
				else if ( (Floor | realDir) > 0.7 )
				{
					eventFalling();
					if (Physics == PHYS_Spider)
						setPhysics(PHYS_Falling); //default if script didn't change physics
					if (Physics == PHYS_Falling)
					{
						FLOAT velZ = Velocity.Z;
						if (!bJustTeleported && (deltaTime > remainingTime))
							Velocity = (Location - OldLocation)/(deltaTime - remainingTime);
						Velocity.Z = velZ;
						if (remainingTime > 0.005)
							physFalling(remainingTime, Iterations);
						return;
					}
				}
				FVector DesiredDir = Delta.SafeNormal();
				stepUp(GravDir, DesiredDir, Delta * (1.0 - Hit.Time), Hit);
				if (Physics == PHYS_Falling)
				{
					if (remainingTime > 0.005)
						physFalling(remainingTime, Iterations);
					return;
				}
			}
		}

		//drop to floor
		GetLevel()->MoveActor(this, Down, Rotation, Hit);
		if (Hit.Time == 1.0) //then find new floor or fall
		{
			if ( findNewFloor(OldLocation, deltaTime, remainingTime, Iterations) )
			{
				GravDir = -1 * Floor;
				Down = GravDir * (MaxStepHeight + 4.0);
			}
			else
				return;
		}
		else 
		{
			Floor = Hit.Normal;
			if( Hit.Actor != Base && !Hit.Actor->IsA(APawn::StaticClass()) )
			// Handle floor notifications (standing on other actors).
				SetBase( Hit.Actor );
		}
	}

	// make velocity reflect actual move
	if (!bJustTeleported)
		Velocity = (Location - OldLocation) / deltaTime;
}
//#pragma ENABLE_OPTIMIZATION

void AActor::physTrailer(FLOAT deltaTime)
{

	FRotator trailRot;
	if ( !Owner )
		return;
	if ( DrawType == DT_Sprite )
	{
		if ( bTrailerPrePivot )
			GetLevel()->FarMoveActor(this, Owner->Location + PrePivot, 0, 1);
		else if (bTrailerSameRotation )
			GetLevel()->FarMoveActor(this, Owner->Location - Mass * Owner->Rotation.Vector(), 0, 1);
		else
			GetLevel()->FarMoveActor(this, Owner->Location, 0, 1);
		return;
	}
	GetLevel()->FarMoveActor(this, Owner->Location, 0, 1);
	FCheckResult Hit(1.0);
	if ( bTrailerSameRotation )
		trailRot = Owner->Rotation;
	else if ( Owner->Velocity.IsNearlyZero() )
		trailRot = FRotator(16384,0,0);
	else
		trailRot = (-1 * Owner->Velocity).Rotation();

	GetLevel()->MoveActor(this, FVector(0,0,0), trailRot, Hit);

}

#include "DnMeshPrivate.h"
#include "..\..\Cannibal\CannibalUnr.h"

void APawn::physRope
    (
    FLOAT deltaSeconds,
    INT   Iterations
    )

{
    APlayerPawn *PlayerPawn;

    if ( Iterations > 8 )
        return;

    // Only players on ropes
	if( this->IsA( APlayerPawn::StaticClass() ) )
	{
        FCoords BoneCoords;
        FVector AccelDir;

        PlayerPawn = (APlayerPawn *)this;

        // Don't normalize a zero vector
	    if ( Acceleration.IsZero() )
		    AccelDir = Acceleration;
	    else
		    AccelDir = Acceleration.SafeNormal();

        // Get the velocity of the player        
	    calcVelocity(AccelDir, deltaSeconds, GroundSpeed, Region.Zone->ZoneGroundFriction, 0, 1, 0);

        // Player should be attached to a rope, and have a handle to the bone that he's on
        ABoneRope *rope = PlayerPawn->currentRope;

        if ( !rope )
            return;

        // Exec the rope to get the proper position
        rope->DoBoneRope( deltaSeconds, false ); 

        UDukeMeshInstance *MeshInst = Cast<UDukeMeshInstance>( rope->GetMeshInstance() );

        if ( !MeshInst )
            return;

        CMacBone *bone = (CMacBone*)rope->GetBoneFromHandle( PlayerPawn->boneRopeHandle );

        if ( !bone )
            return;
        
        MeshInst->GetBoneCoords( bone, BoneCoords );
        BoneCoords = BoneCoords.Transpose();

        // Get top rope bone
        CMacBone *topBone     = MeshInst->Mac->mActorBones.GetData()+2;
        
        // Get the bottom bone
        CMacBone *bottomBone  = MeshInst->Mac->mActorBones.GetData() + (MeshInst->Mac->mActorBones.GetCount()-1);

        CMacBone    *targetBone=NULL;
        FCoords     targetBoneCoords;
        UBOOL       BoneCoordsValid=false;

		targetBoneCoords = FCoords();            
        FVector     delta(0,0,0), ropeDir(0,0,0);

        // Dot against UP to get a scalar for facing up or down.
        FLOAT myDot   = PlayerPawn->ViewRotation.Vector() | FVector( 0,0,1 ); 
        FLOAT speed   = AccelDir.Z;

        UBOOL movingUp, movingDown;
        if ( PlayerPawn->eventDuckHeld() || PlayerPawn->eventJumpHeld() )
        { 
            movingUp = movingDown = false;
        }
        else 
        {
            movingUp   = ( ( ( myDot > rope->m_lookThreshold ) && ( speed > 0 ) ) || ( ( myDot < -rope->m_lookThreshold ) && ( speed > 0 ) ) );
            movingDown = ( ( ( myDot > rope->m_lookThreshold ) && ( speed < 0 ) ) || ( ( myDot < -rope->m_lookThreshold ) && ( speed < 0 ) ) );
        }

        if ( movingUp )
            eventSetRopeClimbState( RS_ClimbUp );
        else if ( movingDown )
            eventSetRopeClimbState( RS_ClimbDown );
        else
            eventSetRopeClimbState( RS_ClimbNone );

        // Check to see if the player is offset from the rope.  If it is positive, then
        // we are moving up.  Negative means we are going down.
        if ( ( PlayerPawn->ropeOffset > 0 ) || movingUp ) 
        {
            // Pushing up, or currently going up the rope, move towards the bone above
            targetBone       = bone - 1;
            MeshInst->GetBoneCoords( targetBone, targetBoneCoords );
            targetBoneCoords = targetBoneCoords.Transpose();
            delta            = targetBoneCoords.Origin - BoneCoords.Origin;
            ropeDir          = delta;
            ropeDir.Normalize();
        }         
        else if ( ( PlayerPawn->ropeOffset < 0 ) || movingDown )
        {
            // Pushing down, or currently going down the rope, move towards the bone below
            targetBone       = bone + 1;
            MeshInst->GetBoneCoords( targetBone, targetBoneCoords );
            targetBoneCoords = targetBoneCoords.Transpose();
            delta            = targetBoneCoords.Origin - BoneCoords.Origin;
            ropeDir          = -delta;
            ropeDir.Normalize();
        }

        // Only climb up if we're not at the top bone
        if ( ( topBone != bone ) && ( movingUp ) )
        {
            PlayerPawn->ropeOffset += rope->m_climbUpSpeed * deltaSeconds;
            
            // Reached next bone, so set the handle to it.
            if ( PlayerPawn->ropeOffset > delta.Size() )
            {
                PlayerPawn->ropeOffset = 0;
                
                check( targetBone );
                bone       = targetBone;
                PlayerPawn->boneRopeHandle = rope->GetHandleFromBone( bone );
                // Reset the coords to the target.
                BoneCoords = targetBoneCoords;
                BoneCoordsValid = true;
            }
        }

        if ( 
            ( ( bottomBone != bone ) && ( movingDown ) ) ||
            ( ( bottomBone == bone ) && ( movingDown ) && ( PlayerPawn->ropeOffset > 0 ) )
           )
        {
            // Climb down toward next bone position
            PlayerPawn->ropeOffset += -rope->m_climbDownSpeed * deltaSeconds;
            
            // Reached next bone, so set the handle to it.
            if ( PlayerPawn->ropeOffset < -delta.Size() )
            {
                PlayerPawn->ropeOffset = 0;
                check( targetBone );
                bone   = targetBone;
                PlayerPawn->boneRopeHandle = rope->GetHandleFromBone( bone );
                // Reset the coords to the target.
                BoneCoords = targetBoneCoords;
                BoneCoordsValid = true;
            }
        }        
        
        // Adjust the player's view based on the rotation of the rope
        if ( rope->bAdjustView )
            {
            FCoords rotBoneCoords;
            FCoords viewCoords;
            FLOAT   roll = ViewRotation.Roll;
            FLOAT   yaw = ViewRotation.Yaw;

            viewCoords = FCoords( FVector(), ViewRotation.Vector(), FVector(), FVector() );
            MeshInst->GetBoneCoords( topBone, rotBoneCoords );            
            rotBoneCoords =  rotBoneCoords.Transpose();        
            viewCoords <<= rotBoneCoords;

            ViewRotation = viewCoords.OrthoRotation();
            ViewRotation.Roll = roll;
            ViewRotation.Yaw  = yaw;
            }

        FRotator tempRot;
        FVector  forward,left,up;
        tempRot = Rotation;

        // Delta is how far we need to move to the rope
        delta = BoneCoords.Origin + ( PlayerPawn->ropeOffset * ropeDir ) - this->Location;

        ViewRotation.AngleVectors( forward, left, up );
        tempRot.Pitch = 0;
        
        delta   += tempRot.Vector() * -rope->m_riderRopeOffset; // Offset from the rope in the direction we are looking
        delta.Z += rope->m_riderVerticalOffset;                 // vertical offset
        delta   += left * rope->m_riderHorizontalOffset;        // horizontal offset

        if ( PlayerPawn->bMoveToRope )  // Move over time to location to smooth out the snap of the rope
        {
            FVector oldDelta = delta;
            FVector deltaDir = delta;
            FLOAT   oldSize;

            deltaDir.Normalize();

            oldSize = delta.Size();
			delta = deltaDir * PlayerPawn->onRopeSpeed * deltaSeconds;            

            if ( delta.Size() > oldSize ) // When we get to the rope, turn off the smoothing
            {
                delta = oldDelta;
                PlayerPawn->bMoveToRope = false;
            }

        }

	    FCheckResult Hit(1.0);
	    int didHit = GetLevel()->MoveActor( this, delta, Rotation, Hit );
	    if (Hit.Time < 1.0)        
        {
            // We hit something.  Invert the rope's velocity to bounce off
            rope->RiderHitSolid();
            physRope( deltaSeconds, ++Iterations );
        }
    }
}

void APawn::physJetpack( FLOAT DeltaTime )
{
	// Get a self pointer.
	APawn *ThisPawn = this->IsA(APawn::StaticClass()) ? (APawn*)this : NULL;
	if ( !ThisPawn )
		return;

	FVector OldVelocity = Velocity;
	Velocity = Velocity + 0.5 * Acceleration * DeltaTime;
	FVector Adjusted = Velocity * DeltaTime;
	Velocity = Velocity * 0.965;

	// Make sure we aren't going too fast.
	FLOAT BoundSpeed = 400.f;
	FVector Vel2D = Velocity;
	Vel2D.Z = 0;
	if ( Vel2D.SizeSquared() > BoundSpeed * BoundSpeed )
	{
		Vel2D = Vel2D.SafeNormal();
		Vel2D = Vel2D * BoundSpeed;
		Vel2D.Z = Velocity.Z;
		Velocity = Vel2D;
	}

	if ( Velocity.Z > 200.f )
		Velocity.Z = 200.f;
//	if ( Velocity.Z < -200.f )
//		Velocity.Z = -200.f;

	FCheckResult Hit(1.0);
	GetLevel()->MoveActor( this, Adjusted, Rotation, Hit );

	INT numBounces = 0;
	FLOAT timeTick = DeltaTime, remainingTime = 0.f;
	if ( bDeleteMe )
		return;
	else if ( ThisPawn && (Physics == PHYS_Swimming) ) //just entered water
	{
		timeTick = 0.f + timeTick * (1.0 - Hit.Time);
		ThisPawn->startSwimming(OldVelocity, timeTick, 0.f, 1);
		return;
	}
	else if ( Hit.Time < 1.0 )
	{
		if ( Hit.Actor->IsA(APlayerPawn::StaticClass()) && this->IsA(ADecoration::StaticClass()) )
			((ADecoration *)this)->numLandings = ::Max(0, ((ADecoration *)this)->numLandings - 1); 
		if (bBounce)
		{
			eventHitWall(Hit.Normal, Hit.Actor);
			if ( Physics == PHYS_None )
				return;
			else if ( numBounces < 2 )
				remainingTime += timeTick * (1.0 - Hit.Time);
			numBounces++;
		}
		else
		{
			// We don't care about hitting the ground when on a jetpack
			//if (Hit.Normal.Z > 0.7)
			//{
			//	remainingTime += timeTick * (1.0 - Hit.Time);
			//	processLanded(Hit.Normal, Hit.Actor, remainingTime, 1);
			//	return;
			//}
			//else
			{
				processHitWall(Hit.Normal, Hit.Actor);
				FVector OldHitNormal = Hit.Normal;
				FVector Delta = (Adjusted - Hit.Normal * (Adjusted | Hit.Normal)) * (1.0 - Hit.Time);
				if( (Delta | Adjusted) >= 0 )
				{
					GetLevel()->MoveActor(this, Delta, Rotation, Hit);
					if (Hit.Time < 1.0) //hit second wall
					{
						if ( Hit.Normal.Z > 0.7 )
						{
							remainingTime = 0.0;
							processLanded(Hit.Normal, Hit.Actor, remainingTime, 1);
							return;
						}
						else 
							processHitWall(Hit.Normal, Hit.Actor);
	
						FVector DesiredDir = Adjusted.SafeNormal();
						TwoWallAdjust(DesiredDir, Delta, Hit.Normal, OldHitNormal, Hit.Time);
						int bDitch = ( (OldHitNormal.Z > 0) && (Hit.Normal.Z > 0) && (Delta.Z == 0) && ((Hit.Normal | OldHitNormal) < 0) );
						GetLevel()->MoveActor(this, Delta, Rotation, Hit);
						if ( bDitch || (Hit.Normal.Z > 0.7) )
						{
							remainingTime = 0.0;
							processLanded(Hit.Normal, Hit.Actor, remainingTime, 1);
							return;
						}
					}
				}
				FLOAT OldZ = OldVelocity.Z;
				OldVelocity = (Location - OldLocation)/timeTick;
				OldVelocity.Z = OldZ;
			}
		}
	}
}