class UTHeads extends UTPlayerChunks;

function ChunkUp(int Damage)
{
}

simulated function Initfor(actor Other)
{
	Super.InitFor(Other);
	if ( Other.bIsPawn )
		PlayerOwner = Pawn(Other).PlayerReplicationInfo;
	else if ( Other.IsA('UTMasterCreatureChunk') )
		PlayerOwner = UTMasterCreatureChunk(Other).PlayerRep;
	else if ( Other.IsA('Carcass') )
		PlayerOwner = Carcass(Other).PlayerOwner;
	RotationRate = RotationRate/3;
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local UT_BloodBurst b;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode && !Level.bDropDetail )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		b = Spawn(class 'UT_BloodBurst');
		if ( bGreenBlood )
			b.GreenBlood();		
		b.RemoteRole = ROLE_None;
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

auto State Dying
{
	simulated function Tick(float DeltaTime)
	{
		local PlayerPawn P;

		Disable('Tick');
		if ( (PlayerOwner != None) && (PlayerOwner.Owner != None) )
		{
			P = PlayerPawn(PlayerOwner.Owner);
			if ( (P != None) && (P.Health <= 0) && !P.IsInState('GameEnded') )
			{
				P.ViewTarget = self;
				P.bBehindView = false;
			}
		}
	}
}