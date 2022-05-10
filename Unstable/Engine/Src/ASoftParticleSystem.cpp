/*=============================================================================
	ASoftParticleSystem.cpp: DukeNet Script interface code.
	Copyright 1999-2000 3D Realms, Inc. All Rights Reserved.
=============================================================================*/
#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	ADukeNet object implementation.
-----------------------------------------------------------------------------*/
// Implement assorted particle system related classes:
IMPLEMENT_CLASS(AParticleSystem);
IMPLEMENT_CLASS(ASoftParticleSystem);
IMPLEMENT_CLASS(ASoftParticleAffector);
IMPLEMENT_CLASS(AParticleCollisionActor);

#define PARTICLE_GROW 32		   /* Number of particles by which particle system grows. */

static INT RenderedSystems,
		   RenderedParticles,
		   UpdatedParticles;

void ASoftParticleSystem::Serialize( FArchive& Ar )
{
	Super::Serialize(Ar);	// Serialize my superclass.

	for(INT i=0;i<ARRAY_COUNT(AdditionalSpawn);i++)
		if(AdditionalSpawns[i])
		{
			AdditionalSpawn[i].SpawnClass=AdditionalSpawns[i];
			AdditionalSpawns[i]=NULL;
		}

	// JEP... Save the particles out
	if (GSaveLoadHack && SaveParticles)
	{
		// Serialize the number of particles
		Ar << HighestParticleNumber;

		// Allocate space when loading
		if (Ar.IsLoading())
		{
			ParticleSystemHandle=(int)appRealloc((void *)ParticleSystemHandle,HighestParticleNumber*sizeof(FParticle),*Tag);
			AllocatedParticles=HighestParticleNumber;
			// UseParticleCollisionActors not supported yet during a save/load
			UseParticleCollisionActors = false;				
		}

		// Serialize each particle in the array
		FParticle *P=(FParticle *)ParticleSystemHandle;

		for (INT i = 0; i< HighestParticleNumber; i++, P++)
		{
			Ar << P->ActivationDelay;
			Ar << P->SpawnNumber;
			Ar << P->SpawnTime;
			Ar << P->Lifetime;
			Ar << P->RemainingLifetime;
			Ar << P->Location;
			Ar << P->PreviousLocation;
			Ar << P->WorldLocation;
			Ar << P->WorldPreviousLocation;
			Ar << P->Velocity;
			Ar << P->Acceleration;
			Ar << P->Texture;
			Ar << P->NextFrameDelay;
			Ar << P->DrawScale;
			Ar << P->Alpha;
			Ar << P->Rotation;
			Ar << P->RotationVelocity;
			Ar << P->RotationAcceleration;
			Ar << P->Rotation3d;
			Ar << P->RotationVelocity3d;
			Ar << P->RotationAcceleration3d;
		
			if (Ar.IsLoading())
			{
				// Collision actors are not saved out
				P->HaveCollisionActor = false;
			}
		}
	}
	// ... JEP
}

// Make sure the allocated buffer gets freed:
void ASoftParticleSystem::Destroy()
{
	if(ParticleSystemHandle) { appFree((void *)ParticleSystemHandle); ParticleSystemHandle=0; }

	// Free particle collision actors array.
	if ( UseParticleCollisionActors )
		CollisionActors.Empty();

	Super::Destroy();
}

// Allocate a particle, and return it's index or -1:
inline INT __fastcall ASoftParticleSystem::AllocParticle()
{
	INT i;
	FParticle *Particles=(FParticle *)ParticleSystemHandle;

	// Do I have an empty slot at the top?
	if(Particles)
	{
		i=-1;

		// Can I just allocate the highest particle?
		if(HighestParticleNumber<AllocatedParticles)
		{
			i=HighestParticleNumber;
			HighestParticleNumber++;

			if(i>=HighestParticleNumber) HighestParticleNumber=i+1;
		}

		// Can I take the place of the oldest particle?
		if(SpawnCanDestroyOldest&&(MaximumParticles>0))
		{
			INT LowestSpawnNumber=Particles[0].SpawnNumber,
				LowestSpawnIndex=0;

			// Find the particle with the lowest spawn number:
			for(i=1;i<HighestParticleNumber;i++)
				if(Particles[i].SpawnNumber<LowestSpawnNumber)
				{
					LowestSpawnNumber=Particles[i].SpawnNumber;
					LowestSpawnIndex=i;
				}
			
			i=LowestSpawnIndex;
		}
	
		// Clear out the particle slot:
		if(i>=0)
		{
			appMemset(&Particles[i],0,sizeof(Particles[0]));
			Particles[i].SpawnNumber=CurrentSpawnNumber++;
			return i;
		}
	}

	if((MaximumParticles>0)&&(AllocatedParticles>=MaximumParticles))
		return -1;

	// Couldn't find a particle slot, grow the buffer:
	INT NewParticleCount=AllocatedParticles+PARTICLE_GROW;
	if((MaximumParticles>0)&&(NewParticleCount>MaximumParticles)) NewParticleCount=MaximumParticles;

	ParticleSystemHandle=(int)appRealloc((void *)ParticleSystemHandle,NewParticleCount*sizeof(FParticle),*Tag);	
	Particles=(FParticle *)ParticleSystemHandle;
	
	AllocatedParticles=NewParticleCount;
	return AllocParticle();					// Should just be a single level of recursion.
}

// Free a given particle:
inline void __fastcall ASoftParticleSystem::FreeParticle(INT i)
{
	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	verify(Particles);
	//if(!Particles) appErrorf(TEXT("Tried to FreeParticle(%i) when Particles==NULL."),i);

	// Perform On Death Actions:

	// Should I spawn an actor where I died?
	if(SpawnOnDeath&&(appFrand()<=SpawnOnDeathChance))
	{
		GetLevel()->SpawnActor
		(
			SpawnOnDeath,
			NAME_None, 
			this,
			Instigator,
			Particles[i].Location,
			FRotator(0,0,0) 
		); 
	}

	if(DieSound)
		PlayActorSound(DieSound,SLOT_Misc,TransientSoundVolume,0,DieSoundRadius,1.0,0);

	// Check to see if we need to free a collision actor.
	if ( UseParticleCollisionActors && Particles[i].HaveCollisionActor )
	{
		for ( INT z=0; z<CollisionActors.Num(); z++ )
		{
			if ( CollisionActors(z)->ParticleIndex == Particles[i].SpawnNumber )
			{
				UsedCollisionActors--;
				CollisionActors(z)->bInUse = false;
				CollisionActors(z)->eventUnlocked();
				break;
			}
		}
		Particles[i].HaveCollisionActor = false;
	}

	// Should I spawn a corresponding particle in a friend particle system?
	SpawnFriend(SpawnFriendOnDeathActor,Particles[i].Location);

	// Was I the highest particle?
	if(HighestParticleNumber!=i+1)
		// Move the highest particle into my slot: 
		appMemcpy(&(Particles[i]),&(Particles[HighestParticleNumber-1]),sizeof(*Particles));

	// Decrement the highest particle:
	if(HighestParticleNumber>0) HighestParticleNumber--; 
}

int __fastcall ASoftParticleSystem::ScriptSpawnParticle( INT Count )
{
	if ( Count <= 0 ) 
		return -1;

	// Allocate the particles.
	INT Result = 0;
	while ( Count-- )
		if ( (Result = SpawnParticle()) < 0 )
			return Result;

	return Result;
}


static float ParticleDensityReduction=1.f;
static int ParticleTotalCount=0;
static int ParticlePassCount=0;

EXECFUNC(ParticleDensity)
{
	if(argc>=2)
	{
		ParticleTotalCount=0;
		ParticlePassCount=0;
		ParticleDensityReduction=atof(appToAnsi(argv[1]));
	}

	GDnExec->Printf(TEXT("%f"),ParticleDensityReduction);
}

// Spawns a single particle (Allocs and initializes) and returns particle index or -1
int __fastcall ASoftParticleSystem::SpawnParticle() 
{
	INT i;

	// Reduce the number of allocated particles:
	if(ParticleDensityReduction!=1.f)
	{
		ParticleTotalCount++;
		if(ParticleTotalCount&&(((float)ParticlePassCount/(float)ParticleTotalCount)>ParticleDensityReduction))
			return -1;

		ParticlePassCount++;
	}

	// Allocate the particle.
	if((i=AllocParticle())<0)	
		return -1;

	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	
	// Set the particle's activation delay to 0
	Particles[i].ActivationDelay=0.f;

	// Set default location:
	Particles[i].Location=PreviousLocation+SpawnOffset;

	// If I have a collision area, then spawn randomly somewhere inside it:
	if(SpawnAtExistingParticle&&(HighestParticleNumber>1))
	{
		int RandomParticle;

		// Pick a random particle that is both active and not myself:
		do RandomParticle=appRand()%HighestParticleNumber;
		while(RandomParticle==i);

		// Set my location to match its.
		Particles[i].Location=Particles[RandomParticle].Location;
	} else if(SpawnAtApex)
	{
		Particles[i].Location+=Apex;
	} else if(SpawnInALine)
	{
		FVector LineVector = Rotation.Vector();
		LineVector.Normalize();
		Particles[i].Location += LineVector * SpawnInALineLength * (appRand()&1?1:-1) * appFrand();
	} else if(CollisionHeight>0||CollisionRadius>0)
	{
		FLOAT Magnitude;
		if(SpawnAtHeight)	Magnitude=(CollisionHeight/2)*(appRand()&1?1:-1);	// Spawn right at collision box.
		else				Magnitude=(CollisionHeight*appFrand())-(CollisionHeight/2);
		Particles[i].Location.Z+=Magnitude;
	
		// Chose a random angle:
		FRotator r(0,appRand()^appRand()<<5,0);

		if(SpawnAtRadius) Magnitude=CollisionRadius;	// Spawn right at collision radius.
		else			  Magnitude=(appFrand()*(CollisionRadius*2))-CollisionRadius;
		Particles[i].Location+=(r.Vector()*Magnitude);
	} 

	if(TextureCount) 
	{
		Particles[i].Texture=Textures[appRand()%TextureCount];
		if(Particles[i].Texture&&Particles[i].Texture->AnimNext)
		{
			if(Particles[i].Texture->MaxFrameRate) Particles[i].NextFrameDelay=(1.f/(Particles[i].Texture->MaxFrameRate));
			else Particles[i].NextFrameDelay=0;
		} else Particles[i].NextFrameDelay=0;
	} else
		Particles[i].Texture=NULL;

	Particles[i].DrawScale=StartDrawScale+(DrawScaleVariance*appFrand()-DrawScaleVariance/2);
	if(AlphaStartUseSystemAlpha) AlphaStart=SystemAlphaScale;
	Particles[i].Alpha=AlphaStart+(AlphaVariance*appFrand()-AlphaVariance/2);
	Particles[i].Rotation=RotationInitial;
	Particles[i].Rotation+=appFrand()*RotationVariance-RotationVariance/2;
	Particles[i].RotationVelocity=RotationVelocity+appFrand()*RotationVelocityMaxVariance-RotationVelocityMaxVariance/2;
	Particles[i].RotationAcceleration=RotationAcceleration+appFrand()*RotationAccelerationMaxVariance-RotationAccelerationMaxVariance/2;

	// Set up 3d rotation:
	Particles[i].Rotation3d=RotationInitial3d;
	Particles[i].RotationVelocity3d=RotationVelocity3d;
	Particles[i].RotationAcceleration3d=RotationAcceleration3d;

	Particles[i].Rotation3d.Yaw+=(appFrand()*RotationVariance3d.Yaw)-RotationVariance3d.Yaw/2;
	Particles[i].Rotation3d.Pitch+=(appFrand()*RotationVariance3d.Pitch)-RotationVariance3d.Pitch/2;
	Particles[i].Rotation3d.Roll+=(appFrand()*RotationVariance3d.Roll)-RotationVariance3d.Roll/2;

	Particles[i].RotationVelocity3d.Yaw+=(appFrand()*RotationVelocityMaxVariance3d.Yaw)-RotationVelocityMaxVariance3d.Yaw/2;
	Particles[i].RotationVelocity3d.Pitch+=(appFrand()*RotationVelocityMaxVariance3d.Pitch)-RotationVelocityMaxVariance3d.Pitch/2;
	Particles[i].RotationVelocity3d.Roll+=(appFrand()*RotationVelocityMaxVariance3d.Roll)-RotationVelocityMaxVariance3d.Roll/2;

	Particles[i].RotationAcceleration3d.Yaw+=(appFrand()*RotationAccelerationMaxVariance3d.Yaw)-RotationAccelerationMaxVariance3d.Yaw/2;
	Particles[i].RotationAcceleration3d.Pitch+=(appFrand()*RotationAccelerationMaxVariance3d.Pitch)-RotationAccelerationMaxVariance3d.Pitch/2;
	Particles[i].RotationAcceleration3d.Roll+=(appFrand()*RotationAccelerationMaxVariance3d.Roll)-RotationAccelerationMaxVariance3d.Roll/2;

	// FIXME: PUT REST IN
	Particles[i].Velocity=InitialVelocity;
	Particles[i].Velocity.X+=appFrand()*MaxVelocityVariance.X-(MaxVelocityVariance.X/2);
	Particles[i].Velocity.Y+=appFrand()*MaxVelocityVariance.Y-(MaxVelocityVariance.Y/2);
	Particles[i].Velocity.Z+=appFrand()*MaxVelocityVariance.Z-(MaxVelocityVariance.Z/2);

	// Should I set my direction towards the apex?
	if(ApexInitialVelocity)
	{
		FVector ApexDirection=Particles[i].Location-(PreviousLocation+Apex);
		ApexDirection.Normalize();
		Particles[i].Velocity+=(ApexDirection*ApexInitialVelocity);
	}

	// Set up my acceleration:
	Particles[i].Acceleration=InitialAcceleration;
	Particles[i].Acceleration.X+=appFrand()*MaxAccelerationVariance.X-(MaxAccelerationVariance.X/2);
	Particles[i].Acceleration.Y+=appFrand()*MaxAccelerationVariance.Y-(MaxAccelerationVariance.Y/2);
	Particles[i].Acceleration.Z+=appFrand()*MaxAccelerationVariance.Z-(MaxAccelerationVariance.Z/2);
	
	if(UseZoneGravity) 	Particles[i].Acceleration+=Region.Zone->ZoneGravity;
	if(UseZoneVelocity) Particles[i].Acceleration+=Region.Zone->ZoneVelocity;

	Particles[i].PreviousLocation=Particles[i].Location;
	Particles[i].RemainingLifetime=Particles[i].Lifetime=Lifetime+(appFrand()*LifetimeVariance)-(LifetimeVariance/2);
	Particles[i].SpawnTime=Level->TimeSeconds;

	if(RelativeSpawn)			
	{
		Particles[i].Location=Location+((Location-Particles[i].Location).TransformVectorBy(GMath.UnitCoords*Rotation));
		Particles[i].Velocity=Particles[i].Velocity.TransformVectorBy(GMath.UnitCoords*Rotation);
	}

	if ( InheritVelocityActor != NULL )
	{
		FCoords Coords = GMath.UnitCoords / InheritVelocityActor->Rotation;
		FVector Forward = Coords.XAxis;
		Forward.Normalize();
		FVector IVelocity = InheritVelocityActor->Velocity;

		FLOAT Scale = Forward dot IVelocity;
		Particles[i].Velocity += Forward * Scale;
	}

	// Check to see if we need a collision actor.
	if ( UseParticleCollisionActors )
	{
		ParticlesSinceCollision++;
		if ( (ParticlesSinceCollision > ParticlesPerCollision) && (UsedCollisionActors < NumCollisionActors) )
		{
			// Find a free collision actor.
			for ( INT z=0; z<CollisionActors.Num(); z++ )
			{
				if ( CollisionActors(z) && !CollisionActors(z)->bInUse )
				{
					UsedCollisionActors++;
					ParticlesSinceCollision = 0;
					CollisionActors(z)->bInUse = true;
					CollisionActors(z)->ParticleIndex = Particles[i].SpawnNumber;
					CollisionActors(z)->MyParticleSystem = this;

					FCheckResult Hit(1.0);
					FVector Delta = Particles[i].Location - CollisionActors(z)->Location;
					GetLevel()->MoveActor( CollisionActors(z), Delta, Rotation, Hit );

					CollisionActors(z)->eventLocked();
					Particles[i].HaveCollisionActor = true;
					break;
				}
			}
		}
	}

	return i;
}

// Say hello to my little friend.
void __fastcall ASoftParticleSystem::SpawnFriend(ASoftParticleSystem *Friend,FVector AtLocation)
{
	if(Friend)
	{
		INT SpawnedIndex=Friend->SpawnParticle();	// Spawn the particle
		if(SpawnedIndex>=0)	// Was it spawned?
		{
			// Set it's location to mine.
			FParticle *p=&(((FParticle *)Friend->ParticleSystemHandle)[SpawnedIndex]);
			p->Location=AtLocation;
			p->PreviousLocation=AtLocation; 
		}
	}
}

void __fastcall ASoftParticleSystem::execDestroyParticleCollisionActors( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	// Free particle collision actors.
	for ( INT i=0; i<CollisionActors.Num(); i++ )
	{
		GetLevel()->DestroyActor( CollisionActors(i) );
	}
	CollisionActors.Empty();
}

void __fastcall ASoftParticleSystem::execForceTick( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(DeltaSeconds);
	P_FINISH;

	InternalTick(DeltaSeconds);
}

void __fastcall ASoftParticleSystem::execResetParticles( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	if(ParticleSystemHandle) { appFree((void *)ParticleSystemHandle); ParticleSystemHandle=0; }
	AllocatedParticles=HighestParticleNumber=0;		// Clear out previous variables	
	PreviousLocation=Location;						// Initialize PreviousLocation.

	// Initialize collision actor system.
	if ( UseParticleCollisionActors )
	{
		for ( INT i=0; i<CollisionActors.Num(); i++ )
		{
			GetLevel()->DestroyActor( CollisionActors(i) );
		}
		CollisionActors.Empty();
		for ( i=0; i<NumCollisionActors; i++ )
		{
			AParticleCollisionActor* NewActor = (AParticleCollisionActor*) GetLevel()->SpawnActor( CollisionActorClass, NAME_None, this, NULL, Location, Rotation, NAME_None );
			CollisionActors.AddItem( NewActor );

			if ( NewActor == NULL )
			{
				UseParticleCollisionActors = false;
				GLog->Logf( TEXT("Error spawning particle collision actors.") );
			}
		}
	}
}

void __fastcall ASoftParticleSystem::execSpawnParticle( FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters:   
	P_GET_INT(Count);
	P_FINISH;
	// End Grabbing Parameters

	ScriptSpawnParticle( Count );
}

void __fastcall ASoftParticleSystem::execAllocParticle( FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters: 
	P_FINISH;
	// End Grabbing Parameters  
	
	*(INT *)Result=AllocParticle();
}

void __fastcall ASoftParticleSystem::execFreeParticle( FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters: 
	P_GET_INT(i);
	P_FINISH;
	// End Grabbing Parameters  
	
	FreeParticle(i);
}

void __fastcall ASoftParticleSystem::execGetParticle(FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters: 
	P_GET_INT(i);
	P_GET_STRUCT_REF(FParticle,p);
	P_FINISH;
	// End Grabbing Parameters  

	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	
	// Clamp to range:
	if(!Particles||(i<0)||(i>=HighestParticleNumber)) 
	{
		*((UBOOL *)Result)=0;
		return;
	}

	// Copy the particle:
	appMemcpy(p,&Particles[i],sizeof(FParticle));
	*((UBOOL *)Result)=1;
}

void __fastcall ASoftParticleSystem::execSetParticle(FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters: 
	P_GET_INT(i);
	P_GET_STRUCT_REF(FParticle,p);
	P_FINISH;
	// End Grabbing Parameters  

	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	
	// Clamp to range:
	if(!Particles||(i<0)||(i>=HighestParticleNumber)) 
	{
		*((UBOOL *)Result)=0;
		return;
	}
	
	// Copy the particle:
	appMemcpy(&Particles[i],p,sizeof(FParticle));
	*((UBOOL *)Result)=1;
}

void __fastcall ASoftParticleSystem::execDrawParticles( FFrame& Stack, RESULT_DECL )
{
	// Begin Grabbing Parameters: 
	P_GET_OBJECT(UCanvas,c);
	P_FINISH;
	// End Grabbing Parameters  

	DrawParticles(c->Frame);
}

FVector __fastcall ASoftParticleSystem::AffectorFilterMotion(FVector v, ASoftParticleAffector *a)
{
	if(!a->AffectX) v.X=0;
	if(!a->AffectY) v.Y=0;
	if(!a->AffectZ) v.Z=0;
	return v;
}

void __fastcall ASoftParticleSystem::execAffectParticles( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(ASoftParticleAffector,a);
	P_FINISH;

	if(!a) return;

	// Grab the particle system handle:
	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	if(!Particles) return;

	FLOAT CollisionRadiusSquared=a->CollisionRadius*a->CollisionRadius;

	switch(a->Type)
	{
		case PAT_None: break;

		case PAT_Magnet: 
		{
			// Update all particles in the system:   
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;
				FLOAT Length=Distance.Size();

				// If I'm outside the collision radius then I'm not affected.   
				if(Length>a->CollisionRadius) continue;
				Distance.Normalize();
				Particles[i].Location+=AffectorFilterMotion((1.f-(Length/a->CollisionRadius))*Distance*a->Magnitude*Level->TimeDeltaSeconds, a); 
			}
		}
		break;
		
		case PAT_Noise:
		{
			// Update all particles in the system: 
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;
				FLOAT Length=Distance.Size();

				// If I'm outside the collision radius then I'm not affected. 
				if(Length>a->CollisionRadius) continue;
				Distance.Normalize();
				FLOAT MaxMagnitude=(1.f-(Length/a->CollisionRadius))*a->Magnitude*Level->TimeDeltaSeconds;
				FVector Temp;
				Temp.X=appFrand()*MaxMagnitude-MaxMagnitude/2;
				Temp.Y=appFrand()*MaxMagnitude-MaxMagnitude/2;
				Temp.Z=appFrand()*MaxMagnitude-MaxMagnitude/2;

				Particles[i].Location+=AffectorFilterMotion(Temp,a); 
			}
		}
		break;

		case PAT_Force:
		{
			FVector Force=a->Rotation.Vector()*a->Magnitude*Level->TimeDeltaSeconds;
			// Update all particles in the system: 
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;

				// If I'm outside the collision radius then I'm not affected. 
				if(Distance.SizeSquared()>CollisionRadiusSquared) continue;
				Particles[i].Location+=AffectorFilterMotion(Force,a);
			}

		}
		break;

		case PAT_Teleport:
		{
			// Update all particles in the system: 
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;

				// If I'm outside the collision radius then I'm not affected. 
				if(Distance.SizeSquared()>CollisionRadiusSquared) continue;
				FVector TeleportDirection;
				TeleportDirection.X=(appFrand()*2)-1;
				TeleportDirection.Y=(appFrand()*2)-1;
				TeleportDirection.Z=(appFrand()*2)-1;
				TeleportDirection.Normalize();
				Particles[i].Location=AffectorFilterMotion(a->Location+(TeleportDirection*(appFrand()*a->CollisionRadius)),a);
			}

		}
		break;

		case PAT_Destroy:
		{
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;

				// If I'm outside the collision radius then I'm not affected.   
				if(Distance.SizeSquared()>CollisionRadiusSquared) continue;
				FreeParticle(i);
			}
		}
		break;

		case PAT_Wake:
		{
		}
		break;

		case PAT_Vortex:
		{
			//FVector CenterLocationWithoutZ=a->Location;
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				FVector Distance=Particles[i].Location-a->Location;
				FLOAT Length=Distance.Size();

				// If I'm outside the collision radius then I'm not affected: 
				if(Length>a->CollisionRadius) continue;

				// Rotate about my Z Axis:
				FRotator NewRotation=FRotator(0,0,0);
				FLOAT MaxMagnitude=(1.f-(Length/a->CollisionRadius))*a->Magnitude*Level->TimeDeltaSeconds;
				NewRotation.Yaw=MaxMagnitude;
				Particles[i].Location=a->Location+((Particles[i].Location-a->Location).TransformVectorBy(GMath.UnitCoords*NewRotation));
			}
		}
		break;

		default: break;
	}
}

int __fastcall ASoftParticleSystem::PlayerCanSeeMe()
{
	int seen = 0;
	int NetMode = GetLevel()->GetLevelInfo()->NetMode;
	if ( (NetMode == NM_Standalone)
		|| ((NetMode == NM_Client) && (bNetTemporary || (Role == ROLE_Authority))) )
	{
		// just check local player visibility
		for( INT i=0; i<GetLevel()->Engine->Client->Viewports.Num(); i++ )
			if ( TestCanSeeMe( GetLevel()->Engine->Client->Viewports(i)->Actor ) )
			{
				seen = 1;
				break;
			}
	}
	else
	{
		for ( APawn *next=GetLevel()->GetLevelInfo()->PawnList; next!=NULL; next=next->nextPawn )
			if ( TestCanSeeMe((APlayerPawn *)next) )
			{
				seen = 1;
				break;
			}
	}
	return seen;
}

// InternalTick is essentially what the original script actor tick did.  
// Has to be seperated out for things like PrimeTime to work.
UBOOL __fastcall ASoftParticleSystem::InternalTick( FLOAT DeltaSeconds )
{
	// Possibly update my apex:
	if ( ApexActor )
		Apex = ApexActor->Location;		

	if ( LastEnabled != Enabled )
	{
		// detected a changed in enabled
		eventEnabledStateChange();
	}
	LastEnabled = Enabled;

	FLOAT f = 0.f;
	if ( (TriggerType == SPT_TimeWarpPulse) && (PulseStartTime != 0) )
	{
		if ( Level->TimeSeconds >= PulseEndTime )
			TimeWarp = 1.f;
		else
		{
			f = (Level->TimeSeconds - PulseStartTime) / (PulseEndTime - PulseStartTime);
			if ( f <= 0.5f )
			{
				FLOAT a = f * 2.f;
				FLOAT b = 1.f;
				TimeWarp = Lerp( a, b, PulseMagnitude );
			}
			else
			{
				FLOAT a = (f - 0.5f) * 2.f;
				FLOAT b = PulseMagnitude;
				TimeWarp = Lerp( a, b, 1.f );
			}
		}
	}
	else if ( (TriggerType == SPT_TimeWarpPulseUp ) && ( PulseStartTime != 0 ) )
	{
		if ( Level->TimeSeconds >= PulseEndTime )
			TimeWarp = PulseMagnitude;
		else
		{
			f = (Level->TimeSeconds - PulseStartTime) / (PulseEndTime - PulseStartTime);
			FLOAT b = 1.f;
			TimeWarp = Lerp( f, b, PulseMagnitude );
		}
	}

	if ( DamagePeriod != 0 )
	{
		DamagePeriodRemaining -= DeltaSeconds;
		if ( DamagePeriodRemaining < 0 )
		{
			eventParticleHurtRadius();
			DamagePeriodRemaining += DamagePeriod;
		}
	}

	// Have I just been dismounted?
	if ( TriggerOnDismount && (MountParent == NULL) )
	{
		TriggerOnDismount = false;
		eventScriptTriggerOnDismount();
	}

	if ( UpdateWhenNotVisible || PlayerCanSeeMe() || bPriming )
	{
		// Update particles: 
		if ( UpdateEnabled )
		{
			if(SmoothSpawn&&!Enabled)
			{
				DeltaSeconds+=ElapsedTime;
				ElapsedTime=0;
				if(DeltaSeconds>=0)
					UpdateParticles( DeltaSeconds );
			}
			else  if(!SmoothSpawn)
				UpdateParticles( DeltaSeconds );
		}
		// Spawn particles:
		// Note: Particles MUST be spawned AFTER being updated for relative location to work correctly
		// FIXME: Something is still causing the parent to move after this!  Corrected for in DrawParticles
		if ( Enabled && UpdateEnabled ) // Only spawn new particles when enabled.
		{
			if ( SpawnPeriod > 0 )
			{
				ElapsedTime += DeltaSeconds;

				if(!SmoothSpawn||!UpdateEnabled)
				{
					// Spawn new particles: 
					while ( ElapsedTime >= SpawnPeriod )
					{
						ElapsedTime -= SpawnPeriod;
						ScriptSpawnParticle( SpawnNumber );
					}
				} else
				{
					while (ElapsedTime >= AbsoluteSpawnPeriod)
					{
						ElapsedTime-=AbsoluteSpawnPeriod;
						UpdateParticles(AbsoluteSpawnPeriod);
						ScriptSpawnParticle(1);
					}
					// Need to check error and update based on it here:
						
				}

			} else
			{
				if(!SmoothSpawn||!UpdateEnabled)
				{
					ScriptSpawnParticle( SpawnNumber );
				} 
				else
				{
					FLOAT IndividualParticlePeriod=DeltaSeconds/SpawnNumber;

					for(int SpawnNumberIndex=0;SpawnNumberIndex<SpawnNumber;SpawnNumberIndex++)
					{
						ScriptSpawnParticle(1);
						UpdateParticles(IndividualParticlePeriod);
					}
				}
			}
		}

		// Destroy the system if it's empty:
		if ( DestroyWhenEmpty && (HighestParticleNumber == 0) )
		{
			GetLevel()->DestroyActor(this);
			return true;
		}
		if ( DestroyWhenEmptyAfterSpawn && (HighestParticleNumber == 0) && (CurrentSpawnNumber != 0) )
		{
			GetLevel()->DestroyActor(this);
			return true;
		}	
	}
	else
	{
		ElapsedTime = 0;
	}
	return true;
}

UBOOL __fastcall ASoftParticleSystem::Tick( FLOAT DeltaSeconds, ELevelTick TickType )
{
	UBOOL Result = Super::Tick( DeltaSeconds, TickType );

	if ( GIsEditor || !Result )
		return Result;

	return InternalTick(DeltaSeconds);
}

void __fastcall ASoftParticleSystem::UpdateParticles( FLOAT deltaSeconds )
{
	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	if(!Particles) return;

	// Update particles position to compenstate for relative location:
	if(RelativeLocation)
	{
		FVector DeltaLocation=Location-PreviousLocation;
		if(DeltaLocation!=FVector(0,0,0))
			for(INT i=0;i<HighestParticleNumber;i++)
				{
					Particles[i].PreviousLocation+=DeltaLocation;
					Particles[i].Location+=DeltaLocation;
				}
	}	
	PreviousLocation=Location;	// Update previous location:

	// Compute Net Friction: 
	FLOAT TotalFriction=LocalFriction;
	if(UseZoneGroundFriction) TotalFriction+=Region.Zone->ZoneGroundFriction;	// Add in zone ground friction.
	if(UseZoneFluidFriction)  TotalFriction+=Region.Zone->ZoneFluidFriction;	// Add In zone fluid friction
	TotalFriction*=deltaSeconds;

	// Compute draw scale velocity:
	FLOAT DrawScaleVelocity;
	if(Lifetime) DrawScaleVelocity=((EndDrawScale-StartDrawScale)/Lifetime)*deltaSeconds;
	else 		 DrawScaleVelocity=0;

	// Compute alpha velocity:
	FLOAT AlphaVelocity;
	if (Lifetime && !bUseAlphaRamp)
		AlphaVelocity = ((AlphaEnd-AlphaStart)/Lifetime)*deltaSeconds;
	else
		AlphaVelocity=0;

	// Compute System alpha scale: 
	SystemAlphaScaleVelocity+=SystemAlphaScaleAcceleration*deltaSeconds;
	SystemAlphaScale+=SystemAlphaScaleVelocity*deltaSeconds;
	if(SystemAlphaScale<0)			SystemAlphaScale=0;
	else if(SystemAlphaScale>1.f)	SystemAlphaScale=1.f;

	// Initialize flocking:
	FVector AverageCenter=FVector(0,0,0);
	FVector AverageDirection=FVector(0,0,0);

	if(FlockToCenterVelocity||FlockToCenterAcceleration||FlockToDirectionScale||FlockMountToCenter||FlockMountToDirection)
	{
		for(INT i=0;i<HighestParticleNumber;i++)
		{
			AverageCenter+=Particles[i].Location;
			AverageDirection+=Particles[i].Velocity;
		}

		AverageDirection+=(Rotation.Vector()*FlockDirectionWeight);
		AverageDirection.Normalize();

		if(HighestParticleNumber) // Finish computing center if there are any active particles.
		{
			AverageCenter+=(Location*FlockCenterWeight);				// Add in center weight.
			AverageCenter/=(HighestParticleNumber+FlockCenterWeight);	// Compute average.
		}
	}

	// Initialize the bounding box:
	BoundingBoxMin=Location-FVector(5,5,5);	// NJS: Make sure mappers can specify the min and max offsets as well.
	BoundingBoxMax=Location+FVector(5,5,5); // NJS: Make sure mappers can specify the min and max offsets as well.
	
	// Update all particles in the system: 
	UpdatedParticles+=HighestParticleNumber;

	for(INT i=0;i<HighestParticleNumber;i++)
	{
		if ( Lifetime && bUseAlphaRamp )
		{
			FLOAT MidLife = Lifetime * AlphaRampMid;
			FLOAT Age = Lifetime - Particles[i].RemainingLifetime;
			if ( Age <= MidLife )
			{
				// Early life.
				AlphaVelocity = ((AlphaMid-AlphaStart)/MidLife)*deltaSeconds;
			}
			else
			{
				// Late life.
				AlphaVelocity = ((AlphaEnd-AlphaMid)/(Lifetime-MidLife))*deltaSeconds;
			}
		}

		if(Lifetime)
		{
			Particles[i].RemainingLifetime-=deltaSeconds;

			// See if my lifetime has expired:
			if(Particles[i].RemainingLifetime<=0)
			{
				FreeParticle(i); i--; // Reupdate this particle, as it may have been replaced with the former highest particle number	
				continue;
			}
		}

		// Handle the activation Delay
		if(Particles[i].ActivationDelay)
		{
			Particles[i].ActivationDelay-=deltaSeconds;
			if(Particles[i].ActivationDelay<=0.f) Particles[i].ActivationDelay=0.f;
		} else
		{

			// Update particle's previous location:
			Particles[i].PreviousLocation=Particles[i].Location;

			// Handle Realtime acceleration variance:
			if(RealtimeAccelerationVariance.X) Particles[i].Velocity.X+=(appFrand()*RealtimeAccelerationVariance.X-(RealtimeAccelerationVariance.X/2))*deltaSeconds;
			if(RealtimeAccelerationVariance.Y) Particles[i].Velocity.Y+=(appFrand()*RealtimeAccelerationVariance.Y-(RealtimeAccelerationVariance.Y/2))*deltaSeconds;
			if(RealtimeAccelerationVariance.Z) Particles[i].Velocity.Z+=(appFrand()*RealtimeAccelerationVariance.Z-(RealtimeAccelerationVariance.Z/2))*deltaSeconds;

			// Update velocity to compensate for acceleration:
			Particles[i].Velocity+=(Particles[i].Acceleration*deltaSeconds);

			// Handle Realtime velocity variance:
			if(RealtimeVelocityVariance.X) Particles[i].Velocity.X+=(appFrand()*RealtimeVelocityVariance.X-(RealtimeVelocityVariance.X/2))*deltaSeconds;
			if(RealtimeVelocityVariance.Y) Particles[i].Velocity.Y+=(appFrand()*RealtimeVelocityVariance.Y-(RealtimeVelocityVariance.Y/2))*deltaSeconds;
			if(RealtimeVelocityVariance.Z) Particles[i].Velocity.Z+=(appFrand()*RealtimeVelocityVariance.Z-(RealtimeVelocityVariance.Z/2))*deltaSeconds;

			// Handle sinsodial effects:
			if(SineWaveFrequency)
			{
				FLOAT ComputedSin=appSin(Particles[i].RemainingLifetime*SineWaveFrequency)*deltaSeconds;
				Particles[i].Velocity+=VelocityAmplitude*ComputedSin;
				Particles[i].Acceleration+=AccelerationAmplitude*ComputedSin;
			}

			// Handle Flocking velocity:
			if(FlockToCenterVelocity||FlockToCenterAcceleration)
			{
				FVector CenterDirection=AverageCenter-Particles[i].Location;
				CenterDirection.Normalize();
				if(FlockToCenterVelocity)	  Particles[i].Velocity+=CenterDirection*(FlockToCenterVelocity*deltaSeconds);
				if(FlockToCenterAcceleration) Particles[i].Acceleration+=CenterDirection*(FlockToCenterAcceleration*deltaSeconds);
			}			

			// Handle flocking to direction:
			if(FlockToDirectionScale)
			{
				FLOAT VelocitySize=Particles[i].Velocity.Size();
				Particles[i].Velocity.Normalize();
				Particles[i].Velocity+=(AverageDirection*FlockToDirectionScale*deltaSeconds);
				Particles[i].Velocity.Normalize();
				Particles[i].Velocity*=VelocitySize;
			}

			// Compute new draw scale and alpha values:
			Particles[i].DrawScale+=DrawScaleVelocity;
			Particles[i].Alpha+=AlphaVelocity;

			// Compute Effects of Friction: 
			if(TotalFriction!=0.f)
			{
				FVector VelocityDirection=Particles[i].Velocity;
				if(VelocityDirection.Size()<TotalFriction)
				{
					Particles[i].Velocity=FVector(0,0,0);
				} else
				{
					VelocityDirection.Normalize();
					Particles[i].Velocity-=(VelocityDirection*TotalFriction);
				}
			}

			// Update the particle's location according to it's velocity:
			Particles[i].Location+=(Particles[i].Velocity*deltaSeconds);

			// Handle particle collisions with the world:
			if(ParticlesCollideWithWorld||ParticlesCollideWithActors)
			{		
				FVector TraceEnd  =Particles[i].Location;
				FVector TraceStart=Particles[i].PreviousLocation;
				FVector TraceExtent(0,0,0);

				// Trace the line.
				FCheckResult Hit(1.f);
				DWORD TraceFlags=0;

				if(ParticlesCollideWithActors) TraceFlags|=TRACE_AllColliding|TRACE_ProjTargets;
				if(ParticlesCollideWithWorld)  TraceFlags|=TRACE_VisBlocking;

				GetLevel()->SingleLineCheck(Hit,this,TraceEnd,TraceStart,TraceFlags,TraceExtent);
				
				FVector HitLocation=Hit.Location;
				FVector HitNormal  =Hit.Normal;
				
				// Did I hit something?
				if(Hit.Actor)
				{
					Particles[i].Location=HitLocation;

					if(Particles[i].PreviousLocation==HitLocation) // If I was here before, it's not really a bounce...
					{
						Particles[i].Rotation3d.Pitch=0;
						Particles[i].Rotation3d.Roll=0;
						Particles[i].RotationVelocity3d=FRotator(0,0,0);	
					} else
					{
						//Particles[i].Velocity.SizeSquared()<=(20*20)

						// Should I spawn something here?
						if(SpawnOnBounce&&(appFrand()<=SpawnOnBounceChance))
						{
							GetLevel()->SpawnActor
							(
								SpawnOnBounce,
								NAME_None, 
								this,
								Instigator,
								HitLocation,
								Hit.Normal.Rotation() 
							); 
						}


						if(BounceSound)
							PlayActorSound(BounceSound,SLOT_Misc,TransientSoundVolume,0,BounceSoundRadius,1.0,0);
					
						// Does this particle die when it hits something?
						if(DieOnBounce) 
						{ 
							FreeParticle(i); 
							continue; 
						}
						
						// Spawn any friends:
						SpawnFriend(SpawnFriendOnBounceActor,Particles[i].Location);

						// Give myself a random 3d bounce:
						Particles[i].RotationVelocity3d.Yaw  +=(appFrand()*RotationVarianceOnBounce3d.Yaw)  -RotationVarianceOnBounce3d.Yaw  /2;
						Particles[i].RotationVelocity3d.Pitch+=(appFrand()*RotationVarianceOnBounce3d.Pitch)-RotationVarianceOnBounce3d.Pitch/2;
						Particles[i].RotationVelocity3d.Roll +=(appFrand()*RotationVarianceOnBounce3d.Roll) -RotationVarianceOnBounce3d.Roll /2;

						// If I don't bounce then zero out my velocity:
						if(!Bounce||!BounceElasticity)
						{
							Particles[i].Velocity          =FVector(0,0,0);
							Particles[i].Rotation3d.Pitch  =0;
							Particles[i].Rotation3d.Roll   =0;
							Particles[i].RotationVelocity3d=FRotator(0,0,0);
						} else
						{
							// Otherwise bounce off the surface:
							FVector A=Particles[i].Velocity;
							FLOAT VelocitySize=A.Size();
							A.Normalize();
							FVector B=HitNormal;

							B=B.SafeNormal();
							FVector NewVelocity=A-2.f*B*(B|A);
							NewVelocity.X+=((appFrand()*BounceVelocityVariance.X)-(BounceVelocityVariance.X*0.5f));
							NewVelocity.Y+=((appFrand()*BounceVelocityVariance.Y)-(BounceVelocityVariance.Y*0.5f));
							NewVelocity.Z+=((appFrand()*BounceVelocityVariance.Z)-(BounceVelocityVariance.Z*0.5f));

							NewVelocity.Normalize();
							
							Particles[i].Velocity=NewVelocity*VelocitySize*BounceElasticity; 


							Particles[i].Rotation3d.Pitch/=2;
							Particles[i].Rotation3d.Roll/=2;
							Particles[i].RotationVelocity3d.Pitch/=2;
							Particles[i].RotationVelocity3d.Roll/=2;
						}
					}
				}
			} else if(Bounce||DieOnBounce||SpawnOnBounce) 
			{
				// NJS: TODO: FIX Z Bounce plane so that negative apex values work.
				if(Particles[i].Location.Z<=(Location.Z+Apex.Z))
				{
					FVector BouncePlaneNormal(0,0,1);
					FVector BouncePlaneHit=Particles[i].Location;
					BouncePlaneHit.Z=(Location.Z+Apex.Z);

					// Should I spawn something here?
					if(SpawnOnBounce&&(appFrand()<=SpawnOnBounceChance))
					{
						GetLevel()->SpawnActor
						(
							SpawnOnBounce,
							NAME_None, 
							this,
							Instigator,
							BouncePlaneHit,
							BouncePlaneNormal.Rotation() 
						); 
					}

					if(Bounce)
					{
						Particles[i].Velocity.Z*=-BounceElasticity;
						Particles[i].Location.Z=BouncePlaneHit.Z;
					}

					if(BounceSound)
						PlayActorSound(BounceSound,SLOT_Misc,TransientSoundVolume,0,BounceSoundRadius,1.0,0);

					SpawnFriend(SpawnFriendOnBounceActor,Particles[i].Location);

					if(DieOnBounce) 
					{ 
						FreeParticle(i); 
						continue; 
					}
				}
			}

			// Update Rotation:
			Particles[i].RotationVelocity+=Particles[i].RotationAcceleration*deltaSeconds;
			Particles[i].Rotation+=Particles[i].RotationVelocity*deltaSeconds;

			// Update3d rotation:
			Particles[i].RotationVelocity3d+=Particles[i].RotationAcceleration3d*deltaSeconds;
			Particles[i].Rotation3d+=Particles[i].RotationVelocity3d*deltaSeconds;

			// Update Texture Frame:
			if(Particles[i].Texture)
			{
				Particles[i].NextFrameDelay-=deltaSeconds;
				if(Particles[i].NextFrameDelay<=0)
				{

					if(Particles[i].Texture->AnimNext)
					{
						Particles[i].Texture=Particles[i].Texture->AnimNext;
						if(Particles[i].Texture->MaxFrameRate) Particles[i].NextFrameDelay+=(1.0/(Particles[i].Texture->MaxFrameRate));
						else Particles[i].NextFrameDelay=0;
					} else
					{
						// Should I die when I hit the last frame?
						if(DieOnLastFrame)
						{
							FreeParticle(i);
							continue;
						}
					}
				}
			}

			// Check to see if I left the radius
			if(DieOutsideRadius)
				if((Particles[i].Location-Location).SizeSquared()>(DieOutsideRadius*DieOutsideRadius))
				{
					FreeParticle(i);
					continue;
				}
		} 

		// Update my bounding box:
			 if(Particles[i].Location.X<BoundingBoxMin.X) BoundingBoxMin.X=Particles[i].Location.X;
		else if(Particles[i].Location.X>BoundingBoxMax.X) BoundingBoxMax.X=Particles[i].Location.X;

			 if(Particles[i].Location.Y<BoundingBoxMin.Y) BoundingBoxMin.Y=Particles[i].Location.Y;
		else if(Particles[i].Location.Y>BoundingBoxMax.Y) BoundingBoxMax.Y=Particles[i].Location.Y;

			 if(Particles[i].Location.Z<BoundingBoxMin.Z) BoundingBoxMin.Z=Particles[i].Location.Z;
		else if(Particles[i].Location.Z>BoundingBoxMax.Z) BoundingBoxMax.Z=Particles[i].Location.Z;


		// Update positions of particle collision actors.
		if ( UseParticleCollisionActors && Particles[i].HaveCollisionActor )
		{
			for ( INT z=0; z<CollisionActors.Num(); z++ )
			{
				if ( CollisionActors(z) && CollisionActors(z)->bInUse && (CollisionActors(z)->ParticleIndex == Particles[i].SpawnNumber) )
				{
					FCheckResult Hit(1.0);
					FVector Delta = Particles[i].Location - CollisionActors(z)->Location;
					GetLevel()->MoveActor( CollisionActors(z), Delta, Rotation, Hit );

					CollisionActors(z)->pLifetime = Particles[i].Lifetime;
					CollisionActors(z)->pLifetimeRemaining = Particles[i].RemainingLifetime;
					CollisionActors(z)->eventUpdate();
				}
			}
		}
	}


	// Note that these two should be last to correctly work with relative position:
	// Though I may have to change when the particle spawn actually occurs.
	if(FlockMountToCenter)
		GetLevel()->FarMoveActor(this,AverageCenter,false,true);

	if(FlockMountToDirection)
	{
		FCheckResult Hit(1.f);
		GetLevel()->MoveActor(this, FVector(0,0,0), AverageDirection.Rotation(), Hit);
	}

}

void __fastcall ASoftParticleSystem::DrawParticles( void* _Frame )
{
	FSceneNode *Frame=(FSceneNode *)_Frame;

	RenderedSystems++;	
	
	if(!HighestParticleNumber) return;

	FParticle *Particles=(FParticle *)ParticleSystemHandle;
	if(!Particles) return;
	RenderedParticles+=HighestParticleNumber;

	FLOAT OriginalTime=Frame->Viewport->CurrentTime;
	Frame->Viewport->CurrentTime=0;

	// Adjust particles world location to take it's relative location into account:
	if(RelativeLocation)			
	{
		// Update particles position to compenstate for relative location:
		// FIXME: Shouldn't have to do this, something else is getting moved at a weird time.
		FVector DeltaLocation=Location-PreviousLocation;
		if(DeltaLocation!=FVector(0,0,0))
			for(INT i=0;i<HighestParticleNumber;i++)
			{
				Particles[i].PreviousLocation+=DeltaLocation;
				Particles[i].Location+=DeltaLocation;
			}
		PreviousLocation=Location;	// Update previous location

		// Handle relative rotation if the particle system uses it:
		if(RelativeRotation)
		{
			FCoords RelativeCoords=GMath.UnitCoords*Rotation;

			// Moved the branch outside the loop for performance reasons.
			if(UseLines)
			{
				for(INT i=0;i<HighestParticleNumber;i++)	
				{
					Particles[i].WorldLocation=Location+((Particles[i].Location-Location).TransformVectorBy(RelativeCoords));
					Particles[i].WorldPreviousLocation=Location+((Particles[i].PreviousLocation-Location).TransformVectorBy(RelativeCoords));
				}
			} else
			{
				for(INT i=0;i<HighestParticleNumber;i++)	
				{
					Particles[i].WorldLocation=Location+((Particles[i].Location-Location).TransformVectorBy(RelativeCoords));
				}
			}
		} else
		{
			// Update world location:  (NJS: Hopefully a bug fix for using RelativeLocation without RelativeRotation)
			for(INT i=0;i<HighestParticleNumber;i++)	
			{
				Particles[i].WorldPreviousLocation=Particles[i].PreviousLocation;
				Particles[i].WorldLocation=Particles[i].Location;
			}
		}

	} else
	{
		for(INT i=0;i<HighestParticleNumber;i++)	
			Particles[i].WorldPreviousLocation=Particles[i].WorldLocation=Particles[i].Location;
	}

	if(DrawType==DT_Sprite||UseLines)
	{
		// Attempt to draw the particles the new way, but revert to the old way if the new way isn't supported on the current render device.
		Frame->Viewport->RenDev->dnDrawParticles(*this,Frame);
	} else // Draw any generic unreal actor as a particle system:
	{	
		FVector   InitialLocation=Location;
		FRotator  InitialRotation=Rotation;
		UTexture *InitialTexture=Texture;
		FLOAT     InitialDrawScale=DrawScale;
		FLOAT	  InitialAlpha=Alpha;
		FLOAT     InitialBillboardRotation=BillboardRotation;

		UBOOL InitialBHidden=bHidden;
		bHidden=false;
		
		ParticleRecursing=true;

		for(INT i=0;i<HighestParticleNumber;i++)	
		{
			Location=Particles[i].WorldLocation;
			Rotation=Particles[i].Rotation3d;

			if(Particles[i].Texture) Texture=Particles[i].Texture;
			else					 Texture=InitialTexture;

			Alpha=Particles[i].Alpha;
			BillboardRotation=Particles[i].Rotation;
			DrawScale=Particles[i].DrawScale;
			Frame->Viewport->Canvas->Render->DrawActor(Frame,this); 
		}

		ParticleRecursing=false;
		bHidden=InitialBHidden;
		Rotation=InitialRotation;
		Location=InitialLocation;
		Texture=InitialTexture;
		DrawScale=InitialDrawScale;
		Alpha=InitialAlpha;
		BillboardRotation=InitialBillboardRotation;
	}

	Frame->Viewport->CurrentTime=OriginalTime;
	
}

void __fastcall ASoftParticleSystem::execGetParticleStats( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT_REF(Systems);
	P_GET_INT_REF(Particles);
	P_GET_INT_REF(OutUpdatedParticles);
	P_FINISH;

	*Systems=RenderedSystems;			   RenderedSystems  =0;
	*Particles=RenderedParticles;		   RenderedParticles=0;
	*OutUpdatedParticles=UpdatedParticles; UpdatedParticles =0;
}