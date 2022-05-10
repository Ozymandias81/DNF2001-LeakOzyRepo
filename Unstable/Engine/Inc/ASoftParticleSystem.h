/*=============================================================================
	ASoftParticleSystem.h: Class functions residing in the ADukeNet class.
	Copyright 1999-2000 3D Realms, Inc. All Rights Reserved.
=================================================================Greetings===*/

	// Constructors.
	ASoftParticleSystem() {}

	void Serialize( FArchive& Ar );
	void Destroy();

	UBOOL __fastcall Tick( FLOAT DeltaSeconds, ELevelTick TickType );
	UBOOL __fastcall InternalTick( FLOAT DeltaSeconds );
	void __fastcall UpdateParticles( FLOAT deltaSeconds );
	int __fastcall PlayerCanSeeMe();

	inline INT __fastcall AllocParticle();			// Allocate a particle, and return it's index or -1:	
	inline void __fastcall FreeParticle(INT i);	// Free a given particle:
	int __fastcall ScriptSpawnParticle( INT Count );
	int __fastcall SpawnParticle();				// Spawns a single particle (Allocs and initializes) and returns particle index or -1
	
	inline void __fastcall SpawnFriend(ASoftParticleSystem *Friend, FVector AtLocation);			// Spawn a friend particle.

	void __fastcall DrawParticles( void* Frame );

	FVector __fastcall AffectorFilterMotion(FVector v, ASoftParticleAffector *a);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
