class DukeHand extends Item;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

var bool bWaitingToBringup, bPuttingDown, bNoIdle;
var Inventory SwipeInv;
var Pawn SwipeInstigator;
var Actor SwipeOther;

enum QuickAnimMode
{
	QuickAnim_None,
	QuickAnim_Anim1,
	QuickAnim_Anim2,
};

var name			QuickAnimName1;
var name			QuickAnimName2;
var QuickAnimMode	WaitingForQuickAnimMode;
var bool			bWaitingForQuickAnimToFinish;
var float			QuickAnimTime;

function WaitToBringup()
{
	bPuttingDown = false;
	bWaitingToBringup = true;
}

function WaitForQuickAnim( name AnimName1, optional name AnimName2, optional float AnimTime )
{
	bPuttingDown = false;
	WaitingForQuickAnimMode = QuickAnim_Anim1;
	bWaitingForQuickAnimToFinish = false;
	QuickAnimName1 = AnimName1;
	QuickAnimName2 = AnimName2;
	QuickAnimTime = AnimTime;

	if ( QuickAnimTime == 0.0 )
		QuickAnimTime = 1.0;
}

function bool IsBusy()
{
	if ( IsAnimating() )
		return true;

	if ( WaitingForQuickAnimMode != QuickAnim_None )
		return true;
	
	if ( bWaitingToBringup )
		return true;

	return false;
}

function Tick( float Delta )
{
	if ( PlayerPawn(Owner) == None )
		return;

	if ( PlayerPawn(Owner).Weapon != None )
		return;

	if ( bWaitingForQuickAnimToFinish )
		return;

	if ( WaitingForQuickAnimMode != QuickAnim_None )
	{
		if ( WaitingForQuickAnimMode == QuickAnim_Anim1 )
		{
			if ( QuickAnimName1 != '' )
			{
				PlayAnim( QuickAnimName1, QuickAnimTime, 0.0 );
				QuickAnimName1 = '';
			}

			bWaitingForQuickAnimToFinish = true;			// Now wait for anim to finish
			WaitingForQuickAnimMode = QuickAnim_Anim2;
		}
		else if ( WaitingForQuickAnimMode == QuickAnim_Anim2 )
		{
			if ( QuickAnimName2 != '' )
			{
				PlayAnim( QuickAnimName2, QuickAnimTime, 0.0 );
				QuickAnimName2 = '';
				bWaitingForQuickAnimToFinish = true;
			}
			WaitingForQuickAnimMode = QuickAnim_None;
		}
			
		if ( bWaitingForQuickAnimToFinish )
		{
			DukePlayer(Owner).DrawHand = true;
			bHidden = false;
		}
	}
	else if ( bWaitingToBringup )
	{
		BringUp();
	}
}

function BringUp()
{
	DukePlayer(Owner).DrawHand = true;
	bWaitingToBringup = false;
	bHidden = false;
	
	// Bringing the hand up will overwrite the quickanim
	bWaitingForQuickAnimToFinish = false;
	WaitingForQuickAnimMode = QuickAnim_None;

	PlayAnim( 'HitButton_Activate', 1.0, 0.1 );
}

function PutDown( optional bool bNoWeapon )
{
	// If we were in a quick anim, then don't play the put down hand animation.
	if ( (!bPuttingDown || bNoWeapon) && !bWaitingForQuickAnimToFinish )
		PlayAnim( 'HitButton_Deactivate', 1.0, 0.1 );

	// Reset the quick anim stuff
	bWaitingForQuickAnimToFinish = false;
	WaitingForQuickAnimMode = QuickAnim_None;
	
	if ( bNoWeapon )
		bNoIdle = true;
	else
		bPuttingDown = true;
}

function StartSwipeItem( Inventory Item, Actor Other, Pawn EventInstigator )
{
	SwipeInv = Item;
	SwipeOther = Other;
	SwipeInstigator = EventInstigator;
	PlayAnim( 'SwipeItem', 1.3, 0.1 );
	bNoIdle = true;
	bHidden = false;
	DukePlayer(Owner).DrawHand = true;
}

function SwipeItem()
{
	SwipeInv.Used( SwipeOther, SwipeInstigator );
	SwipeInstigator.PlaySound( DukePlayer(SwipeInstigator).GrabSound, SLOT_Interact );
}

function PressButton()
{
	PlayAnim( 'HitButton', 1.0, 0.1 );
}

function AnimEnd()
{
	local DukePlayer DukeOwner;

	DukeOwner = DukePlayer(Owner);

	if ( bPuttingDown || bWaitingForQuickAnimToFinish )
	{
		bPuttingDown = false;
		DukeOwner.bDukeHandUp = false;
		bHidden = true;
		DukeOwner.DrawHand = false;
		
		if ( !bWaitingForQuickAnimToFinish )
			DukeOwner.WeaponUp();
		
		bWaitingForQuickAnimToFinish = false;
	}
	else if ( !bNoIdle )
	{
		LoopAnim( 'HitButton_IdleA', 1.0, 0.1 );
	}

	bNoIdle = false;
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( Owner == None )
		return;
	if ( (Level.NetMode == NM_Client) && (!Owner.IsA('PlayerPawn') || (PlayerPawn(Owner).Player == None)) )
		return;
	SetLocation( Owner.Location + CalcDrawOffset() );
	SetRotation( Pawn(Owner).ViewRotation );
	bHidden = false;
	Canvas.SetClampMode( false );
	Canvas.DrawActor( self, false );
	Canvas.SetClampMode( true );
	bHidden = true;
}

defaultproperties
{
	DrawScale=0.1
	bOnlyOwnerSee=true
	bHidden=true
	DrawType=DT_Mesh
	Mesh=mesh'c_dnWeapon.hands'
	bCollideActors=false
	bCollideWorld=false
	bBlockPlayers=false
	bBlockActors=false
	bProjTarget=false
	PlayerViewOffset=(X=50.0,Y=0.0,Z=2045.0)
	//PlayerViewOffset=(X=50.0,Y=0.0,Z=2065.0)
	Style=STY_Translucent
	bWaitingForQuickAnimToFinish=false
	WaitingForQuickAnimMode=QuickAnim_None
}