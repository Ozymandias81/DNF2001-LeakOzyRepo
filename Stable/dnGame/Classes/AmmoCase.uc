/*-----------------------------------------------------------------------------
	AmmoCase
	Author: Brandon Reinhart

	For item offsets:
		X = Forward/Back
		Y = Left/Right of center.
		Z = Up/Down

    Here are sample settings for a couple of nicely laid out clips:
	These clips are upside down though, might want to fix that.
		Treats(0)=cl@ss'pistolClip_Gold'
		TreatsRotation(0)=(Pitch=-98368,Yaw=9328,Roll=-16528)
		TreatsOffset(0)=(X=5,Y=8,Z=-13)
		Treats(1)=cl@ss'pistolClip_Gold'
		TreatsRotation(1)=(Pitch=-98368,Yaw=9328,Roll=-16528)
		TreatsOffset(1)=(X=5,Y=-8,Z=-13)

-----------------------------------------------------------------------------*/
class AmmoCase extends dnDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\a_inventory.dfx

var bool bTreatsSpawned;

var() class<Actor> Treats[5];
var() vector TreatsOffset[5];
var() rotator TreatsRotation[5];
var Actor TreatItems[5];

var sound OpenSound;
var sound CloseSound;

function RenderActor SpecialLook( PlayerPawn LookPlayer )
{
	local Actor HitActor;

	// Turn off collision and see if we hit what is inside.
	if ( AnimSequence == 'open1' )
	{
		SetCollision( false, false, false );
		bProjTarget = false;
		HitActor = LookPlayer.TraceFromCrosshair( LookPlayer.UseDistance );
		bProjTarget = true;
		SetCollision( true, true, true );
	}

	// If we didn't hit anything inside, return our self.
	if ( HitActor == None )
		HitActor = Self;

	return RenderActor(HitActor);
}

event Used( Actor Other, Pawn EventInstigator )
{
	local vector X,Y,Z;
	local Actor HitActor;
	local int i, j;
	local bool bItemUsed;

	HitActor = EventInstigator.TraceFromCrosshair( EventInstigator.UseDistance );
	if ( (HitActor == Self) && (AnimSequence == 'open1') )
	{
		SetCollision( false, false, false );
		bProjTarget = false;
		HitActor = EventInstigator.TraceFromCrosshair( EventInstigator.UseDistance );
		for ( i=0; i<5; i++ )
		{
			if ( (HitActor != None) && (HitActor == TreatItems[i]) )
			{
				TreatItems[i].Used( Other, EventInstigator );
				if ( TreatItems[i].bCarriedItem || TreatItems[i].bDeleteMe || TreatItems[i].bHidden )
					TreatItems[i] = None;
				bItemUsed = true;
			}
		}
		bProjTarget = true;
		SetCollision( true, true, true );

		if ( bItemUsed )
			return;
	}

	if ( (AnimSequence == 'closed1') && (MountParent == None) )
	{
		PlayAnim('opening1');

		if ( !bTreatsSpawned )
		{
			for ( i=0; i<5; i++ )
			{
				if ( Treats[i] != None )
				{
					TreatItems[i] = spawn( Treats[i] );
					if ( TreatItems[i].IsA('Inventory') )
						Inventory(TreatItems[i]).bDontPickupOnTouch = true;
					GetAxes( Rotation, X, Y, Z );
					TreatItems[i].SetRotation( Rotation + TreatsRotation[i] );
					TreatItems[i].SetLocation( Location + X*TreatsOffset[i].X + Y*TreatsOffset[i].Y + Z*TreatsOffset[i].Z );
					TreatItems[i].SetPhysics( PHYS_MovingBrush );
					if ( !TreatItems[i].bIsPawn )
					{
						TreatItems[i].MountType = MOUNT_Actor;
						TreatItems[i].AttachActorToParent( Self );
						TreatItems[i].SetCollision( true, false, false );
						TreatItems[i].bCollideWorld = false;
					}
				}
			}
			bTreatsSpawned = true;
		}

		PlaySound( OpenSound );
	}
	else if ( AnimSequence == 'open1' )
	{
		j = 0;
		for ( i=0; i<5; i++ )
		{
			if ( TreatItems[i] != None )
				j++;
		}
		if ( j == 0 )
			PlayAnim('closing1');
	}
}

function PlayCloseSound()
{
	PlaySound( CloseSound );
}

function AnimEnd()
{
	if ( AnimSequence == 'opening1' )
		LoopAnim( 'open1' );
	else if ( AnimSequence == 'closing1' )
		LoopAnim( 'closed1' );
}

defaultproperties
{
	bUseTriggered=true
	Grabbable=false
	bSpecialLook=true
	bPushable=false

	CollisionHeight=25
	CollisionRadius=27

	AnimSequence=closed1

	ItemName="Ammo Case"
	Mesh=mesh'c_dnWeapon.ammocase1'
    HealthPrefab=HEALTH_NeverBreak
	MassPrefab=MASS_Heavy

	Treats(0)=class'pistolClip_Gold'
	TreatsRotation(0)=(Pitch=-98368,Yaw=9328,Roll=-16528)
	TreatsOffset(0)=(X=5,Y=8,Z=-13)
	Treats(1)=class'pistolClip_Gold'
	TreatsRotation(1)=(Pitch=-98368,Yaw=9328,Roll=-16528)
	TreatsOffset(1)=(X=5,Y=-8,Z=-13)

	OpenSound=sound'a_inventory.AmmoCaseOpen'
	CloseSound=sound'a_inventory.AmmoCaseClose'
}
