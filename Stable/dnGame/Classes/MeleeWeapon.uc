/*-----------------------------------------------------------------------------
	MeleeWeapon
-----------------------------------------------------------------------------*/
class MeleeWeapon expands dnWeapon
	abstract;

#exec AUDIO IMPORT FILE="Sounds\pickups\genwep1.WAV" NAME="WeaponPickup" GROUP="Pickups"

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var() float MeleeHitMomentum;
var() float MeleeHitRadius;


// Never have to reload a melee weapon.
simulated function bool GottaReload() { return false; }

// Returns damage for this hit.
simulated function int GetHitDamage(actor Victim, name BoneName)
{
	return 15*Pawn(Owner).MeleeDamageMultiplier;
}



/*-----------------------------------------------------------------------------
	Traces
-----------------------------------------------------------------------------*/

// Performs trace fire logic.
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	local Actor HitActor;
	local vector Direction;
	local vector StartTrace, EndTrace, BeamTrace;
	local vector HitLocation, HitNormal;
	local vector BackHitLocation, BackHitNormal;
	local vector HitMeshBarys;
	local int HitMeshTri;
	local name HitMeshBone;
	local texture HitMeshTex;
	local PointRegion HitRegion;
	local class<Material> HitMat;
	local float MaxMaterialWidth;
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local int HitSurfaceIndex;

	PawnOwner = Pawn(Owner);
	GetAxes( PawnOwner.ViewRotation, X, Y, Z );
	StartTrace = Owner.Location + CalcDrawOffset();
	AdjustedAim = PawnOwner.AdjustAim( 1000000, StartTrace, 2*AimError, false, false );
	EndTrace = StartTrace + vector(AdjustedAim)*MeleeHitRadius;

	// Trace out to see what we hit.
	HitActor = Trace( 
		HitLocation, HitNormal, EndTrace, StartTrace, !bNoActors, ,
		!bNoMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex
		);

	// JEP...
	// Find the material if we hit a brush.
	if ( (HitActor != None) && ((HitActor == Level) || HitActor.IsA('Mover')) )
		HitMat = TraceMaterial( EndTrace, StartTrace, HitSurfaceIndex );

	// Hit the material.
	if ( (HitMat != None) && (Level.NetMode != NM_DedicatedServer) )
		HitMaterial( HitMat, TraceHitCategory, HitLocation, HitNormal, !bNoCreationSounds, HitSurfaceIndex );
	// ...JEP

	// Hit whatever we hit.
	if ( (HitActor != None) && !bEffectsOnly )
		TraceHit( 
			StartTrace, EndTrace, HitActor, HitLocation, HitNormal, 
			HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamTrace
			);
}

// Returns hit segment.
function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{
	if ( (HitActor != self) && (HitActor != Owner) && (HitActor != Level) )
	{
		HitActor.SetDamageBone(HitMeshBone);
		HitActor.TakeDamage( GetHitDamage(HitActor, HitMeshBone), Pawn(Owner), HitLocation, vect(0,0,0), class'KungFuDamage' );
		HitActor.SetDamageBone('None');
	}
}



defaultproperties
{
	 MeleeHitMomentum=1000.000000
	 MeleeHitRadius=500.000000
	 SAnimIdleSmall(0)=(AnimChance=49.000000,AnimRate=1.000000)
	 SAnimIdleSmall(1)=(AnimChance=49.000000,AnimRate=1.000000)
	 SAnimIdleSmall(2)=(AnimChance=2.000000,AnimRate=1.000000)
     ReloadCount=0
     bInstantHit=True
	 bAltInstantHit=True
     AmmoName=None
	 AltAmmoName=None
	 AmmoType=None
	 AltAmmoType=None
     FireOffset=(X=58.599998,Y=-17.639999,Z=-3.760000)
     AIRating=0.900000
     AutoSwitchPriority=1
     PlayerViewOffset=(X=6.400000,Y=0.640000,Z=-24.240000)
     PickupSound=Sound'dnGame.Pickups.WeaponPickup'
     AnimRate=1.000000
     SoundRadius=64
     SoundVolume=200
     CollisionHeight=8.000000
	 bWeaponPenetrates=false
}