//=============================================================================
// G_Toilet.						  September 26th, 2000 - Charlie Wiederhold
//
// Piss code by Brandon Reinhart
//=============================================================================
class G_Toilet expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

var			 PendingSequence	work_ps;
var			 ControlRemapper	PissRemapper;

var(Pissing) int				PissEvents;
var(Pissing) float				PissDuration[9];
var			 int				PissState;
var			 float				PissTime, WaitTime;

var			 dnDukePiss			Piss;
var			 PlayerPawn			Pisser;

var			 bool				bWasDuck;

var			 sound				ZipperSound, PissSound, FlushSound;

var			 bool				bPissWhenReady;
var			 bool				bToiletSeat;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	PissRemapper = spawn(class'ControlRemapper', Self);
	PissRemapper.bLockPosition = true;
	PissRemapper.bLockRotation = true;
	PissRemapper.bHideWeapon = true;
	PissRemapper.bDontUnRemap = true;
	PissRemapper.bLerpRotation = true;
	PissRemapper.bLerpLocation = true;
}

function Trigger( actor Other, pawn EventInstigator )
{
	local vector PissLocation, X, Y, Z;
	local rotator PissRotation;

	if (!EventInstigator.IsA('PlayerPawn'))
		return;

	Pisser = PlayerPawn(EventInstigator);

	if (!Pisser.bHasToPiss)
		return;

	if (Pisser.bDuck > 0)
	{
		bWasDuck = true;
		Pisser.DuckUp();
		Pisser.DuckPressedCount++;
	}

	Pisser.bPissing = true;
	Pisser.DukeVoice.DukeSay(ZipperSound);

	if ( bToiletSeat )
	{
		work_ps.PlaySequence = 'SeatUp';
		PushPendingSequence( work_ps, false );
	}
	bPissWhenReady = !bToiletSeat;

	GetAxes( Rotation, X, Y, Z );

	PissLocation = Location;
	PissLocation.Z += EventInstigator.BaseEyeHeight;
	PissLocation = PissLocation + 35*X;
	PissRemapper.SetLocation( PissLocation );

	PissRotation = Rotation;
	PissRotation.Yaw += 32768;
	PissRotation.Pitch = 59651;
	PissRemapper.SetRotation( PissRotation );

	PissRemapper.Trigger( Other, EventInstigator );

	PissState = 0;

	Enable('Tick');
}

function AnimEnd()
{
	if ( AnimSequence == 'SeatUp' )
	{
		SpawnPiss();
		PissTime = PissDuration[PissState++];
		PlaySound(PissSound);
	}

	Super.AnimEnd();
}

function SpawnPiss()
{
	local vector PissLocation, X, Y, Z;
	local rotator PissRotation;

	// Time to piss!
	GetAxes( Rotation, X, Y, Z );
	PissLocation = Location;
	PissLocation.Z += 15;
	PissLocation = PissLocation + 25*X;
	PissRotation = Rotation;
	PissRotation.Yaw += 16384;
	Piss = spawn(class'dnDukePiss', Self, , PissLocation, PissRotation);
}

function Tick( float Delta )
{
	Super.Tick( Delta );

	if (bPissWhenReady && !PissRemapper.Lerping())
	{
		bPissWhenReady = false;

		SpawnPiss();
		Piss.DieOnBounce = true;
		PissTime = PissDuration[PissState++];
		PlaySound(PissSound);
		return;
	}

	if (PissTime > 0.0)
	{
		PissTime -= Delta;
		if (PissTime <= 0.0)
		{
			if (PissState == PissEvents)
			{
				EndPissing();
				return;
			}
			PissTime = 0.0;
			WaitTime = PissDuration[PissState++];
			Piss.Enabled = false;
		}
		return;
	}

	if (WaitTime > 0.0)
	{
		WaitTime -= Delta;
		if (WaitTime <= 0.0)
		{
			if (PissState == PissEvents)
			{
				EndPissing();
				return;
			}
			WaitTime = 0.0;
			PissTime = PissDuration[PissState++];
			Piss.Enabled = true;
		}
	}
}

function EndPissing()
{
	local int i;

	PlaySound(FlushSound);
	PlayAnim('flush');
	Piss.Enabled = false;
	PissTime = 0.0;
	WaitTime = 0.0;
	Piss.Destroy();
	Piss = None;
	Pisser.StopRemappingInput();
	Pisser.CantPissTime = 180;
	Pisser.bHasToPiss = false;
	i = Pisser.AddEgo(10, true);
	Pisser.DukeVoice.DukeSay(sound'dnGame.medMegaHeal');
	Pisser.bPissing = false;
	PissRemapper.RemapActor = None;

	if (bWasDuck)
	{
		if (Pisser.DuckPressedCount > 0)
			Pisser.DuckDown();
		bWasDuck = false;
	}

	Disable('Tick');
}

function Destroyed()
{
	if (Piss != None)
	{
		Piss.Destroy();
		Piss = None;
	}

	if (PissRemapper != None)
	{
		PissRemapper.Destroy();
		PissRemapper = None;
	}

	// Punt to superclass.
	super.Destroyed();

}

defaultproperties
{
	 PissDuration(0)=4.5
	 PissDuration(1)=0.2
	 PissDuration(2)=0.3
	 PissDuration(3)=0.3
	 PissEvents=4
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(1)=Class'dnParticles.dnDebris_Metal1_Small'
     FragType(2)=Class'dnParticles.dnDebris_Smoke'
     FragType(3)=Class'dnParticles.dnDebris_Sparks1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Generic1'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Generic1a'
     FragBaseScale=0.300000
	 bUseTriggered=true
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     TriggeredSequence=Flush
     DestroyedSound=Sound'a_impact.Ceramic.ImpactCer02'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_Toilet_Broken')
     CurrentPendingSequence=0
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.ToiletA'
     ItemName="Toilet"
     CollisionRadius=14.000000
     CollisionHeight=24.000000
     bTakeMomentum=False
	 AnimSequence=offLoop
	 ZipperSound=sound'a_dukevoice.DukeLeak.DNZipper04'
	 PissSound=sound'a_dukevoice.DukeLeak.DNLeak01b'
	 FlushSound=sound'a_generic.Water.Toilet1'
	 bToiletSeat=true
}
