/*-----------------------------------------------------------------------------
	EZVendMachine, EZ Vend Machine for dispensing gameplay objects.
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class EZVendMachine expands InputDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Textures\SMK4.dtx
#exec OBJ LOAD FILE=..\Textures\SMK5.dtx
#exec OBJ LOAD FILE=..\Textures\ezvend.dtx

var		bool					SaverActive;
var		float					TouchedTimer;

var		smackertexture			EZVendTex;
var		texture					LeftDownTex;
var		texture					RightDownTex;
var		texture					InfoDownTex;
var		texture					SoldOutTex;

var		texture					PriceTex_SoldOut;
var		texture					PriceTex_One;
var		texture					PriceTex_Three;
var		texture					PriceTex_Four;
var		texture					PriceTex_Five;
var		texture					PriceTex_Ten;
var		texture					PriceTex_Fifteen;
var		texture					PriceTex_Twenty;
var		texture					PriceTex_TwentyFive;
var		texture					PriceTex_Thirty;
var		texture					PriceTex_Fifty;
var		texture					PriceTex_SeventyFive;
var		texture					PriceTex_OneHundred;
var		texture					PriceTex_OneHundredFifty;
var		texture					PriceTex_TwoHundred;

var		bool					HandUp;

enum EPrice
{
	BUCKS_1,
	BUCKS_3,
	BUCKS_4,
	BUCKS_5,
	BUCKS_10,
	BUCKS_15,
	BUCKS_20,
	BUCKS_25,
	BUCKS_30,
	BUCKS_50,
	BUCKS_75,
	BUCKS_100,
	BUCKS_150,
	BUCKS_200
};

struct KeyBox
{
	var float Top, Left;
	var float Width, Height;
};

var		KeyBox					LeftButton;
var		float					LeftTouchTime;
var		KeyBox					RightButton;
var		float					RightTouchTime;
var		KeyBox					InfoButton;
var		float					InfoTouchTime;
var		KeyBox					BuyButton;
var		float					BuyTouchTime;

var		float					MovieLeft, MovieTop;
var		float					PriceLeft, PriceTop;
var		float					DescLeft, DescTop;

var(EZVendSounds) sound			KeyPressSound;
var(EZVendSounds) sound			ItemSound[5];
var(EZVendSounds) sound			GrabItemSound;
var(EZVendSounds) sound			GrabItemAngrySound;
var(EZVendSounds) sound			ItemDropSound;
var		int						AngerLevel;
var		float					TalkTime;

var() class<Inventory>			VendItems[10];
var() int						VendAmounts[10];
var int							NumVendItems;
var int							CurrentVendItem, PendingItem;
var float						PendingTime;

var SmackerTexture				VendMovie;
var Inventory					VendedItem;

var int							IntroFrame;
var float						NextIntroTime;

function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	SaverActive = true;

	for (i=0; i<10; i++)
	{
		if (VendItems[i] != None)
			NumVendItems++;
	}

	if (NumVendItems > 0)
		VendMovie = VendItems[0].default.VendIcon;
}

function RenderActor SpecialLook( PlayerPawn LookPlayer )
{
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal;
	local vector DrawOffset, PointUV;
	local texture HitMeshTexture;
	local Actor HitActor, HitActor2;

	SetCollision(false,false,false);
	bProjTarget = false;
	HitActor = LookPlayer.TraceFromCrosshair( LookPlayer.UseDistance );
	bProjTarget = true;
	SetCollision(true,true,true);

	return RenderActor(HitActor);
}

function Used( Actor Other, Pawn EventInstigator )
{
	local Actor HitActor;

	if (bDisrupted || bPowerOff)
		return;
	if (NumVendItems == 0)
		return;
	if (EventInstigator == none)
		return;

	CloseTime = 0.0;
	HitActor = EventInstigator.TraceFromCrosshair( EventInstigator.UseDistance );
	if (HitActor == Self)
	{
		SetCollision(false,false,false);
		bProjTarget = false;
		HitActor   = EventInstigator.TraceFromCrosshair( EventInstigator.UseDistance );
		if ((HitActor != None) && (HitActor == VendedItem))
		{
			if (Other.IsA('DukePlayer'))
				DukePlayer(Other).Hand_SwipeItem( VendedItem, Other, EventInstigator );
		}
		bProjTarget = true;
		SetCollision(true,true,true);
	}
	Super.Used( Other, EventInstigator );
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	if (bDisrupted || bPowerOff)
		return;

	if (NumVendItems == 0)
		return;

	TouchedTimer = Level.TimeSeconds;

	// Screen was pressed to activate the panel.
	if (!ScreenSaver.pause)
	{
		SaverActive			= false;
		ScreenSaver.pause	= true;
		MultiSkins[ScreenSurface] = ScreenCanvas;
		ScreenCanvas.palette= LeftDownTex.palette;
		IntroFrame			= 0;
		EZVendTex.CurrentFrame = 0;
		CurrentVendItem		= 0;
		PendingItem			= 0;
		PendingTime			= 0;
		VendMovie			= VendItems[CurrentVendItem].default.VendIcon;
		TouchPawn			= PlayerPawn(Other);

		if (Other.IsA('DukePlayer'))
			DukePlayer(Other).Hand_PressButton();

		return;
	}

	if (Level.TimeSeconds - BuyTouchTime < 0.8 )
		return;
	if (Level.TimeSeconds - InfoTouchTime < 0.8 )
		return;
	if (Level.TimeSeconds - RightTouchTime < 0.8 )
		return;
	if (Level.TimeSeconds - LeftTouchTime < 0.8 )
		return;

	if (Other.IsA('DukePlayer'))
		DukePlayer(Other).Hand_PressButton();

	// Did we hit the buy button?
	if ((X > BuyButton.Left) && (X < BuyButton.Left+BuyButton.Width) &&
		(Y > BuyButton.Top) && (Y < BuyButton.Top+BuyButton.Height))
	{
		BuyButtonPressed( Other );
		return;
	}
	
	// Did we hit the info button?
	if ((X > InfoButton.Left) && (X < InfoButton.Left+InfoButton.Width) &&
		(Y > InfoButton.Top) && (Y < InfoButton.Top+InfoButton.Height))
	{
		InfoButtonPressed();
		return;
	}

	// Did we hit the right button?
	if ((X > RightButton.Left) && (X < RightButton.Left+RightButton.Width) &&
		(Y > RightButton.Top) && (Y < RightButton.Top+RightButton.Height))
	{
		RightButtonPressed();
		return;
	}

	// Did we hit the left button?
	if ((X > LeftButton.Left) && (X < LeftButton.Left+LeftButton.Width) &&
		(Y > LeftButton.Top) && (Y < LeftButton.Top+LeftButton.Height))
	{
		LeftButtonPressed();
		return;
	}
}

function BuyButtonPressed( Pawn Other )
{
	local vector X,Y,Z,FallLocation;
	local ammo a;
	local class<ammo> ca;
	local int i, Price;

	if ( ClassIsChildOf(VendItems[CurrentVendItem], class'Ammo') )
	{
		// The player might be full of this kind of ammo.
		ca = class<ammo> (VendItems[CurrentVendItem]);
		if (ca.default.ParentAmmo != None)
			a = Ammo( Other.FindInventoryType( ca.default.ParentAmmo ) );
		else
			a = Ammo( Other.FindInventoryType( ca ) );
		if (a != none)
		{
			i = ca.default.AmmoType;
			if (a.ModeAmount[i] == a.MaxAmmo[i])
				return;
		}
	} else if ( VendItems[CurrentVendItem].static.CantBuyItem( Other ) )
		return;

	if ( VendAmounts[CurrentVendItem] == 0 )
		return;

	if (VendedItem != None)
	{
		if (Level.TimeSeconds > TalkTime)
		{
			TalkTime = Level.TimeSeconds + GetSoundDuration( ItemSound[AngerLevel] );
			Say( ItemSound[AngerLevel] );
			AngerLevel++;
			if (AngerLevel > 4)
				AngerLevel = 4;
		}
		return;
	}

	// Use cash.
	switch (VendItems[CurrentVendItem].default.VendPrice)
	{
		case BUCKS_1:
			Price = 1;
			break;
		case BUCKS_3:
			Price = 3;
			break;
		case BUCKS_4:
			Price = 4;
			break;
		case BUCKS_5:
			Price = 5;
			break;
		case BUCKS_10:
			Price = 10;
			break;
		case BUCKS_15:
			Price = 15;
			break;
		case BUCKS_20:
			Price = 20;
			break;
		case BUCKS_25:
			Price = 25;
			break;
		case BUCKS_30:
			Price = 30;
			break;
		case BUCKS_50:
			Price = 50;
			break;
		case BUCKS_75:
			Price = 75;
			break;
		case BUCKS_100:
			Price = 100;
			break;
		case BUCKS_150:
			Price = 150;
			break;
		case BUCKS_200:
			Price = 200;
			break;
	}
	if (Other.Cash < Price)
		return;
	Other.AddCash(-Price);

	PlaySound( KeyPressSound, SLOT_None );
	BuyTouchTime = Level.TimeSeconds;

	GetAxes( Rotation, X, Y, Z );
	VendedItem = spawn( VendItems[CurrentVendItem], , , , Rotation );
	VendedItem.VendOwner = Self;
	SetToMount( 'item_ejection', Self, VendedItem, vect(0,0,-5) );
	VendedItem.bDontPickupOnTouch = true;
	FallLocation   = VendedItem.Location;
	FallLocation.Z = VendedItem.Location.Z - 28 - VendedItem.default.CollisionHeight/2;
	VendedItem.SetupVendItem(FallLocation);
	VendAmounts[CurrentVendItem]--;
	VendedItem.PlaySound(ItemDropSound);
}

function InfoButtonPressed()
{
	PlaySound( KeyPressSound, SLOT_None );
	Say( VendItems[CurrentVendItem].default.VendSound );
	InfoTouchTime = Level.TimeSeconds;
}

function RightButtonPressed()
{
	PlaySound( KeyPressSound, SLOT_None );
	RightTouchTime = Level.TimeSeconds;
	PendingTime = Level.TimeSeconds;
	PendingItem = CurrentVendItem+1;
	if (PendingItem == NumVendItems)
		PendingItem = 0;
}

function LeftButtonPressed()
{
	PlaySound( KeyPressSound, SLOT_None );
	LeftTouchTime = Level.TimeSeconds;
	PendingTime = Level.TimeSeconds;
	PendingItem = CurrentVendItem-1;
	if (PendingItem == -1)
		PendingItem = NumVendItems-1;
}

function Tick(float DeltaTime)
{
	local float XL, YL;
	local font pFont;
	local texture VendPrice;
	local int CloseFrame;
	local vector PointUV;
	local texture HitMeshTexture;
	local actor HitActor;

	Super.Tick(DeltaTime);

	if (SaverActive)
		return;

	if ( (TouchPawn != None) && (TouchPawn.ExamineActor == Self) )
	{
		HitActor = TouchPawn.TraceFromCrosshairMesh( TouchPawn.UseDistance,,,,,,HitMeshTexture, PointUV );

		if ( !HandUp && (HitMeshTexture == HitTexture) )
		{
			DukePlayer(TouchPawn).Hand_BringUp( false, true );
			HandUp = true;
		}
		else if ( HandUp && (HitMeshTexture != HitTexture) )
		{
			DukePlayer(TouchPawn).Hand_PutDown( true );
			HandUp = false;
		}
	}

	if (VendedItem != None)
	{
		VendedItem.VendUpdate(DeltaTime);
		if (AnimSequence != 'take_item_light')
			AnimSequence = 'take_item_light';
	} else if (AnimSequence != 'machine_on')
		AnimSequence = 'machine_on';

	// Update the manually animated stuff.
	if (Level.TimeSeconds - BuyTouchTime < 0.45)
		CloseFrame = UpdateManualAnimationBuy(DeltaTime);
	else
		CloseFrame = UpdateManualAnimation(DeltaTime);

	if (ScreenSaver.pause)
	{
		// Draw the background.
		ScreenCanvas.DrawBitmap( 0, 0, 0, 0, 0, 0, EZVendTex, false, false, false );

		if (IntroFrame < 25)
			return;

		// Draw the button downs.
		if (Level.TimeSeconds - LeftTouchTime < 0.8 )
			ScreenCanvas.DrawBitmap( LeftButton.Left, LeftButton.Top, 0, 0, 0, 0, LeftDownTex, false, false, false );
		if (Level.TimeSeconds - RightTouchTime < 0.8 )
			ScreenCanvas.DrawBitmap( RightButton.Left, RightButton.Top, 0, 0, 0, 0, RightDownTex, false, false, false );
		if (Level.TimeSeconds - InfoTouchTime < 0.8 )
			ScreenCanvas.DrawBitmap( InfoButton.Left, InfoButton.Top, 0, 0, 0, 0, InfoDownTex, false, false, false );

		// Draw the movie.
		if (EZVendTex.CurrentFrame == 34)
			ScreenCanvas.DrawBitmap( MovieLeft, MovieTop, 0, 0, 0, 0, VendMovie, false, false, false );

		// Draw the price.
		if (CloseFrame == 3)
		{
			switch (VendItems[CurrentVendItem].default.VendPrice)
			{
				case BUCKS_1:
					VendPrice = PriceTex_One;
					break;
				case BUCKS_3:
					VendPrice = PriceTex_Three;
					break;
				case BUCKS_4:
					VendPrice = PriceTex_Four;
					break;
				case BUCKS_5:
					VendPrice = PriceTex_Five;
					break;
				case BUCKS_10:
					VendPrice = PriceTex_Ten;
					break;
				case BUCKS_15:
					VendPrice = PriceTex_Fifteen;
					break;
				case BUCKS_20:
					VendPrice = PriceTex_Twenty;
					break;
				case BUCKS_25:
					VendPrice = PriceTex_TwentyFive;
					break;
				case BUCKS_30:
					VendPrice = PriceTex_Thirty;
					break;
				case BUCKS_50:
					VendPrice = PriceTex_Fifty;
					break;
				case BUCKS_75:
					VendPrice = PriceTex_SeventyFive;
					break;
				case BUCKS_100:
					VendPrice = PriceTex_OneHundred;
					break;
				case BUCKS_150:
					VendPrice = PriceTex_OneHundredFifty;
					break;
				case BUCKS_200:
					VendPrice = PriceTex_TwoHundred;
					break;
			}
			// Might be sold out.
			if (VendAmounts[CurrentVendItem] == 0)
				VendPrice = PriceTex_SoldOut;
			ScreenCanvas.DrawBitmap( PriceLeft, PriceTop, 0, 0, 0, 0, VendPrice, false, false, false );
		}

		// Draw the description.
		if (CloseFrame > -1)
		{
			if (Level.TimeSeconds - BuyTouchTime < 0.45)
				ScreenCanvas.DrawBitmap( DescLeft, DescTop, 0, 0, 0, 0, VendItems[CurrentVendItem].default.VendTitle[3], true, false, false );
			else
				ScreenCanvas.DrawBitmap( DescLeft, DescTop, 0, 0, 0, 0, VendItems[CurrentVendItem].default.VendTitle[CloseFrame], true, false, false );
		}
	}
}

function Examine( Actor Other )
{
	local HUDIndexItem_Cash CashItem;

	Super(dnDecoration).Examine( Other );

	HandUp = false;
	if ( Other.bIsPawn )
		ScreenTouched( Pawn(Other), 0, 0 );

	DukePlayer(TouchPawn).Hand_BringUp( true );

	if ( Other.IsA('DukePlayer') )
	{
		CashItem = spawn(class'HUDIndexItem_Cash');
		DukeHUD(DukePlayer(Other).MyHUD).RegisterCashItem( CashItem );
	}

	CloseTime = 0.0;
}

function UnExamine( Actor Other )
{
	Super(dnDecoration).UnExamine( Other );

	HandUp = false;
	DukePlayer(TouchPawn).Hand_WeaponUp();

	CloseTime = 2.0;
	if (Other.IsA('DukePlayer'))
		DukeHUD(DukePlayer(Other).MyHUD).RegisterCashItem( None );
}

function SaverActivated()
{
	SaverActive = true;
	MultiSkins[ScreenSurface] = ScreenSaver;
	ScreenSaver.pause = false;
}

function CloseDecoration( Actor Other )
{
	Super.CloseDecoration( Other );

	SaverActive = true;
	MultiSkins[ScreenSurface] = ScreenSaver;
	ScreenSaver.pause = false;
}

function int UpdateManualAnimationBuy(float DeltaTime)
{
	local float TimeDiff;
	local int CloseFrame;

	// Find a time change if we are opening/closing.
	TimeDiff = Level.TimeSeconds - BuyTouchTime;

	// Update the vend movie.
	if (VendAmounts[CurrentVendItem] > 0)
	{
		VendMovie.pause = false;
		VendMovie.ForceTick(DeltaTime);
	} else
		VendMovie.pause = true;

	// Wink the money.
	if (TimeDiff < 0.05)
		CloseFrame = 3;
	else if (TimeDiff < 0.1)
		CloseFrame = 2;
	else if (TimeDiff < 0.15)
		CloseFrame = 1;
	else if (TimeDiff < 0.25)
		CloseFrame = 0;
	else if (TimeDiff < 0.3)
		CloseFrame = 1;
	else if (TimeDiff < 0.35)
		CloseFrame = 2;
	else
		CloseFrame = 3;

	// Update the background.
	EZVendTex.pause = true;
	EZVendTex.ForceTick(DeltaTime);
	EZVendTex.CurrentFrame = 34;

	return CloseFrame;
}

function int UpdateManualAnimation(float DeltaTime)
{
	local float TimeDiff;
	local int CloseFrame;

	// Find a time change if we are opening/closing.
	TimeDiff = Level.TimeSeconds - PendingTime;

	// Update the vend movie.
	VendMovie.pause = false;
	VendMovie.ForceTick(DeltaTime);

	// Increment the intro movie.
	if ((IntroFrame < 25) && (Level.TimeSeconds > NextIntroTime))
	{
		NextIntroTime = Level.TimeSeconds + 0.05;
		IntroFrame++;
		EZVendTex.CurrentFrame = IntroFrame;
	} else if (IntroFrame < 25)
		EZVendTex.CurrentFrame = IntroFrame;

	if (TimeDiff > 0.75)
	{
		CloseFrame = 3;
	} else if (TimeDiff > 0.70) {
		CloseFrame = 2;
	} else if (TimeDiff > 0.65) {
		CloseFrame = 1;
	} else if (TimeDiff > 0.60) {
		CloseFrame = 0;
	} else
		CloseFrame = -1;

	// ...we are changing out the current item.
	if (PendingItem != CurrentVendItem)
	{
		if (TimeDiff < 0.05)
			CloseFrame = 3;
		else if (TimeDiff < 0.1)
			CloseFrame = 2;
		else if (TimeDiff < 0.15)
			CloseFrame = 1;
		else if (TimeDiff < 0.2)
			CloseFrame = 0;
		else
			CloseFrame = -1;
	}

	// Update the background.
	EZVendTex.pause = true;
	if (EZVendTex.CurrentFrame != 34)
		EZVendTex.ForceTick(DeltaTime);
	if (CloseFrame == -1)
	{
		// Maybe the price and name are closed...
		if (PendingItem != CurrentVendItem)
		{
			if (TimeDiff < 0.225)
				EZVendTex.CurrentFrame = 33;
			else if (TimeDiff < 0.25)
				EZVendTex.CurrentFrame = 32;
			else if (TimeDiff < 0.275)
				EZVendTex.CurrentFrame = 30;
			else if (TimeDiff < 0.3)
				EZVendTex.CurrentFrame = 29;
			else if (TimeDiff < 0.325)
				EZVendTex.CurrentFrame = 28;
			else if (TimeDiff < 0.35)
				EZVendTex.CurrentFrame = 27;
			else {
				EZVendTex.CurrentFrame = 26;
				CurrentVendItem = PendingItem;
				VendMovie = VendItems[CurrentVendItem].default.VendIcon;
			}
		} else {
			if (TimeDiff > 0.575)
				EZVendTex.CurrentFrame = 34;
			else if (TimeDiff > 0.55)
				EZVendTex.CurrentFrame = 33;
			else if (TimeDiff > 0.525)
				EZVendTex.CurrentFrame = 32;
			else if (TimeDiff > 0.5)
				EZVendTex.CurrentFrame = 31;
			else if (TimeDiff > 0.475)
				EZVendTex.CurrentFrame = 30;
			else if (TimeDiff > 0.45)
				EZVendTex.CurrentFrame = 29;
			else if (TimeDiff > 0.4)
				EZVendTex.CurrentFrame = 28;
			else
				EZVendTex.CurrentFrame = 27;
		}
	} else
		EZVendTex.CurrentFrame = 34;

	return CloseFrame;
}

function NotifyPickup( Inventory Other )
{
	VendedItem = None;
	if (AngerLevel > 3)
		Say( GrabItemAngrySound );
	else
		Say( GrabItemSound );
	AngerLevel = 0;
}

function Say( sound SoundToSay )
{
	PlaySound( SoundToSay, SLOT_Talk );
	PlaySound( SoundToSay, SLOT_Interact );
}

defaultproperties
{
    HealthPrefab=HEALTH_NeverBreak
    Physics=PHYS_Falling
    Mesh=DukeMesh'c_generic.ezvend'
    bNotTargetable=true
    CollisionRadius=30.000000
    CollisionHeight=47.500000
	bNoFOVOnExamine=true
	bBlockPlayers=true
	bShield=false
	AnimSequence=machine_on

	ScreenSurface=6

	EZVendTex=smackertexture'smk5.s_ezmainbak'
	LeftDownTex=texture'ezvend.staticimages.left_depress'
	RightDownTex=texture'ezvend.staticimages.right_depress'
	InfoDownTex=texture'ezvend.staticimages.quest_depress'
	SoldOutTex=texture'ezvend.staticimages.ez_soldout'

	PriceTex_SoldOut=texture'ezvend.moneyamount.soldout_03'
	PriceTex_One=texture'ezvend.moneyamount.money1_3'
	PriceTex_Three=texture'ezvend.moneyamount.money3_03'
	PriceTex_Four=texture'ezvend.moneyamount.money4_3'
	PriceTex_Five=texture'ezvend.moneyamount.money5_3'
	PriceTex_Ten=texture'ezvend.moneyamount.money10'
	PriceTex_Fifteen=texture'ezvend.moneyamount.money15_3'
	PriceTex_Twenty=texture'ezvend.moneyamount.money20'
	PriceTex_TwentyFive=texture'ezvend.moneyamount.money25_3'
	PriceTex_Thirty=texture'ezvend.moneyamount.money30'
	PriceTex_Fifty=texture'ezvend.moneyamount.money50_3'
	PriceTex_SeventyFive=texture'ezvend.moneyamount.money75'
	PriceTex_OneHundred=texture'ezvend.moneyamount.money100'
	PriceTex_OneHundredFifty=texture'ezvend.moneyamount.money150'
	PriceTex_TwoHundred=texture'ezvend.moneyamount.money200'

	LeftButton=(Left=24,Top=224,Width=64,Height=32)
	RightButton=(Left=173,Top=224,Width=64,Height=32)
	InfoButton=(Left=97,Top=224,Width=64,Height=32)
	BuyButton=(Left=25,Top=55,Width=205,Height=165)
	MovieLeft=64
	MovieTop=75
	PriceLeft=64
	PriceTop=73
	DescLeft=40
	DescTop=182

	KeyPressSound=sound'a_generic.keypad.KeypdType59'

	ItemSound(0)=sound'a_dukevoice.ezvend.ez-item1'
	ItemSound(1)=sound'a_dukevoice.ezvend.ez-item2'
	ItemSound(2)=sound'a_dukevoice.ezvend.ez-item3'
	ItemSound(3)=sound'a_dukevoice.ezvend.ez-item4'
	ItemSound(4)=sound'a_dukevoice.ezvend.ez-item5'
	GrabItemSound=sound'a_dukevoice.ezvend.ez-thanks'
	GrabItemAngrySound=sound'a_dukevoice.ezvend.ez-thanks2'
	ItemDropSound=sound'a_generic.whoosh.WhooshThrow1'

	bSpecialLook=true
	CanvasTexture=texturecanvas'ezvend.ezvend_screen'

	VendAmounts(0)=1
	VendAmounts(1)=1
	VendAmounts(2)=1
	VendAmounts(3)=1
	VendAmounts(4)=1
	VendAmounts(5)=1
	VendAmounts(6)=1
	VendAmounts(7)=1
	VendAmounts(8)=1
	VendAmounts(9)=1

	bUseViewportForZ=true
}
