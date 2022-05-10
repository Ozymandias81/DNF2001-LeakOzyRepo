/*-----------------------------------------------------------------------------
	HitPackage_Shotgun
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class HitPackage_Shotgun extends HitPackage;

var int					HitSeed;
var bool				bAcidShot;

replication
{
	reliable if ( Role == ROLE_Authority )
		HitSeed, bAcidShot;
}

simulated function Deliver()
{
	local HitPackage hit;
	local class<HitPackage> hitclass;
	local int i;
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local rotator AdjustedAim;
	local float ShotHoriz[10], ShotVert[10];
	local Actor Other;
	local dnAcidRoundFX AcidFX;

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	if ( Instigator == None )
		return;

	// Deliver the subpackages.
	GetAxes( Instigator.ViewRotation, X, Y, Z );
	StartTrace = vect(ShotOriginX, ShotOriginY, ShotOriginZ);
	AdjustedAim = Instigator.AdjustAim( 1000000, StartTrace, 2*class'weapon'.default.AimError, false, false );

	// Group the randoms to make sure nothing interferes.
	Seed( HitSeed );
	for ( i=0; i<10; i++ )
	{
		ShotHoriz[i] = FRand();
		ShotVert[i]  = FRand();
	}

	// Find the correct hit locations.
	for ( i=0; i<10; i++ )
	{
		EndTrace = StartTrace + class'Shotgun'.default.PelletRandHoriz * (ShotHoriz[i] - 0.5) * Y * 3000 + class'shotgun'.default.PelletRandHoriz * (ShotVert[i] - 0.5) * Z * 3000;
		X = vector(AdjustedAim);
		EndTrace += (3000 * X);
		Other = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true, , Level.GRI.bMeshAccurateHits );

		if ( (Other == Level) || Other.IsA('Mover') )
			hitclass = HitPackageLevelClass;
		else if ( Other != None )
			hitclass = Other.GetHitPackageClass( HitLocation );

		if ( (hit == none) || (hit.class != hitclass) )
		{
			if ( (Other == Level) || Other.IsA('Mover') )
				hit = spawn( hitclass, , , HitLocation );
			else
				hit = spawn( hitclass, Other, , HitLocation );
		}
		else if ( (hit != none) && (hit.class == hitclass) )
		{
			hit.LifeSpan = 1.0;
			hit.SetLocation( HitLocation );
			if ( Other == Level )
				hit.SetOwner( None );
			else
				hit.SetOwner( Other );
		}

		if ( hit != none )
		{
			hit.HitDamage		= 10;
			hit.ShotOriginX		= ShotOriginX;
			hit.ShotOriginY		= ShotOriginY;
			hit.ShotOriginZ		= ShotOriginZ;
			hit.bTraceBeam		= false;
			hit.bRicochet		= false;
			hit.Instigator		= Instigator;
			hit.RemoteRole		= ROLE_None;
			hit.Role			= ROLE_Authority;
			if ( (i==0) || (i%3!=0) )
				hit.bNoCreationSounds = true;
			else
				hit.bNoCreationSounds = false;

			hit.Deliver();

			if ( bAcidShot && (Level.NetMode == NM_Client) )
			{
				AcidFX = spawn( class'dnAcidRoundFX',,, HitLocation, Rotator(HitNormal) );
				if ( (Other != None) && (Other != Level) )
				{
					AcidFX.SetPhysics( PHYS_MovingBrush );
					AcidFX.AttachActorToParent( Other, false, false );
				}
			}
		}
	}
}

defaultproperties
{
	HitPackageLevelClass=class'HitPackage_DukeLevel'
}