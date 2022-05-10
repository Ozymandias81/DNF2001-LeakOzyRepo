/*-----------------------------------------------------------------------------
	EZPhone
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class EZPhone extends InputDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Textures\ezphone.dtx

//#exec AUDIO IMPORT FILE="Sounds\phone.WAV" NAME="PhoneRing" GROUP="ezPhone"

var bool					bDirty;

var int						InputSurface, VideoSurface;
var TextureCanvas			InputScreen;
var SmackerTexture			VideoScreen;
var texture					PhoneBackground;
var texture					VideoBackground;
var texture					PhoneKeypad;
var texture					PhoneKeyPress[12];
var texture					PhoneCallPressed;
var texture					PhoneAnswer;
var texture					PhoneAnswerPressed;
var texture					PhoneHangup;
var texture					PhoneHangupPressed;
var texture					HitTex;

// Status smacks.
var SmackerTexture			PhoneSaver;
var SmackerTexture			ConnectingVideo;
var SmackerTexture			InterruptVideo;
var SmackerTexture			IncomingCallVideo;
var SmackerTexture			BusyVideo;
var SmackerTexture			ErrorVideo;

var struct KeyBox
{
	var float Top, Left;
	var float Width, Height;
}							KeyBoxes[12];
var int						TouchedKey;
var float					TouchedTimer;
var KeyBox					BigKeyBox;
var bool					BigKeyTouched;
var float					BigKeyTimer;
var bool					bHungUp, bExamined;
var bool					SaverActive;

var float					InterruptTime;

var string					EnteredNumber;

var(PhoneSounds) sound		KeyPressSound[12];
var(PhoneSounds) sound		BigButtonPressSound;
var(PhoneSounds) sound		PhoneRingSound, PhoneRingingSound;
var(PhoneSounds) sound		BusySound;
var(PhoneSounds) sound		ErrorSound;

var name					VidScreenOnAnim, VidScreenOffAnim;

var enum EPhoneModes
{
	PM_Idle,
	PM_Connecting,
	PM_Connected,
	PM_Ringing,
	PM_Error,
	PM_Busy,
	PM_Interrupted
}							PhoneMode;

// Phone call events.
var EZPhoneEvent			CurrentEvent;


function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Initialize the phone.
	LoopAnim(VidScreenOffAnim);

	SaverActive = true;

	HitTex = PhoneSaver;

//	VideoScreen = SmackerTexture( MeshGetTexture(VideoSurface) );
//	VideoScreen.pause = true;

	PhoneMode = PM_Idle;

	bDirty = true;
}

function Tick(float DeltaTime)
{
	local float X, Y, XL, YL;
	local font pFont;
	local int i;

	Super.Tick(DeltaTime);

	if (SaverActive)
		return;

	// Are we done with a call?
	if ( (PhoneMode == PM_Connected) && (CurrentEvent != None) && (CurrentEvent.PhoneSmack.currentFrame+1 == CurrentEvent.SmackFrames) )
		HangUp();

	if (bDirty)
	{
		// Draw the background.
		if (AnimSequence != VidScreenOffAnim)
			InputScreen.DrawBitmap( 0, 0, 0, 0, 0, 0, VideoBackground, true, false, false );
		else
			InputScreen.DrawBitmap( 0, 0, 0, 0, 0, 0, PhoneBackground, true, false, false );

		// Draw the keypad.
		InputScreen.DrawBitmap( 148, 98, 0, 0, 0, 0, PhoneKeyPad, true, false, false );

		// Draw the big icon.
		switch (PhoneMode)
		{
			case PM_Idle:
				if (bHungUp)
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneHangupPressed, true, false, false );
				else if (BigKeyTouched)
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneCallPressed, true, false, false );
				break;
			case PM_Connecting:
				if (BigKeyTouched)
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneCallPressed, true, false, false );
				else
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneHangup, true, false, false );
				break;
			case PM_Connected:
				InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneHangup, true, false, false );
				break;
			case PM_Ringing:
				if (BigKeyTouched)
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneAnswerPressed, true, false, false );
				else
					InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneAnswer, true, false, false );
				break;
			case PM_Interrupted:
			case PM_Busy:
			case PM_Error:
				InputScreen.DrawBitmap( BigKeyBox.Left, BigKeyBox.Top, 0, 0, 0, 0, PhoneHangup, true, false, false );
				break;
		}

		// Draw the touched key overlay.
		if (TouchedKey >= 0)
			InputScreen.DrawBitmap( KeyBoxes[TouchedKey].Left, KeyBoxes[TouchedKey].Top, 0, 0, 0, 0, PhoneKeyPress[TouchedKey], true, false, false );

		// Draw the entered phone number.
		if (EnteredNumber != "")
		{
			if (TouchPawn != None)
				pFont = DukeHUD(TouchPawn.MyHUD).SmallFont;

			for (i=0; i<Len(EnteredNumber); i++)
			{
				if (i < 4)
					X = 220 - 7*i;
				else
					X = 220 - 7*(i+1);
				Y = 68;
				InputScreen.DrawString( pFont, X, Y, Mid(EnteredNumber, i, 1), false, false, true );
			}
			if (Len(EnteredNumber) > 4)
			{
				X = 220 - 7*4;
				Y = 68;
				InputScreen.DrawString( pFont, X, Y, "-", false, false, true );
			}
		}

		bDirty = false;
	}

	if (TouchedTimer > 0.0)
	{
		TouchedTimer -= DeltaTime;
		if (TouchedTimer < 0.0)
		{
			bDirty = true;
			TouchedTimer = 0.0;
			TouchedKey = -1;
		}
	}
	if (BigKeyTimer > 0.0)
	{
		BigKeyTimer -= DeltaTime;
		if (BigKeyTimer < 0.0)
		{
			bDirty = true;
			BigKeyTimer = 0.0;
			BigKeyTouched = false;
			bHungUp = false;
		}
	}
	if (InterruptTime > 0.0)
	{
		InterruptTime -= DeltaTime;
		if (InterruptTime <= 0.0)
		{
			InterruptTime = 0.0;
			PhoneMode = PM_Idle;
			LoopAnim(VidScreenOffAnim);
			bHungUp = false;
			VideoScreen.pause = true;
			if (CurrentEvent != None)
				CurrentEvent.PhoneSmack.pause = true;
			bDirty = true;
		}
	}
}

event Used(Actor Other, Pawn EventInstigator)
{
	local vector PointUV;
	local texture HitMeshTexture;
	local actor HitActor;

	if (bDisrupted || bPowerOff)
		return;

	HitActor = EventInstigator.TraceFromCrosshairMesh( EventInstigator.UseDistance,,,,,,HitMeshTexture, PointUV );
	if (HitMeshTexture == HitTex)
		ScreenTouched( EventInstigator, PointUV.X*ScreenX, PointUV.Y*ScreenY );
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	local int i;

	if (SaverActive)
	{
		SaverActive = false;
		ScreenSaver.pause = true;
		MultiSkins[InputSurface] = CanvasTexture;
		CanvasTexture.Palette = PhoneBackground.Palette;
		InputScreen = CanvasTexture;
		TouchPawn = PlayerPawn(Other);
		return;
	}

	if (bDisrupted || bPowerOff)
		return;

	bDirty = true;

	Super.ScreenTouched( Other, X, Y );

	// Determine the number behind the hit.
	TouchedKey = -1;
	for (i=0; i<12; i++)
	{
		if ((X > KeyBoxes[i].Left) && (X < KeyBoxes[i].Left+KeyBoxes[i].Width) &&
			(Y > KeyBoxes[i].Top)  && (Y < KeyBoxes[i].Top+KeyBoxes[i].Height))
		{
			TouchedKey = i;
			TouchedTimer = 0.2;
		}
	}

	// Check the key.
	if ((TouchedKey > -1) && (PhoneMode == PM_Idle))
	{
		if (Other.IsA('DukePlayer'))
			DukePlayer(Other).Hand_PressButton();

		PlaySound( KeyPressSound[TouchedKey], SLOT_None, 1.0 );

		// If they hit the star, reset our state.
		if ( (TouchedKey == 10) || (TouchedKey == 11) )
			ResetPressed();
		else {
			if (Len(EnteredNumber) == 8)
				EnteredNumber = Left(EnteredNumber, 7);
			EnteredNumber = TouchedKey$EnteredNumber;
		}

		return;
	}

	// See if we hit the big button.
	if ((X > BigKeyBox.Left) && (X < BigKeyBox.Left+BigKeyBox.Width) && 
		(Y > BigKeyBox.Top)  && (Y < BigKeyBox.Top+BigKeyBox.Height))
	{
		if (Other.IsA('DukePlayer'))
			DukePlayer(Other).Hand_PressButton();

		PlaySound( BigButtonPressSound, SLOT_None, 1.0 );

		BigKeyTouched = true;
		BigKeyTimer = 0.2;

		switch (PhoneMode)
		{
			case PM_Idle:
				PhoneConnecting();
				break;
			case PM_Connecting:
				Hangup();
				break;
			case PM_Connected:
				Hangup();
				break;
			case PM_Ringing:
				AnswerCall();
				break;
			case PM_Interrupted:
				break;
			case PM_Error:
			case PM_Busy:
				Hangup();
		}
	}
}

// Move the phone to the connecting mode.
function PhoneConnecting()
{
	local EZPhoneEvent PhoneEvent, FoundEvent;

	PhoneMode = PM_Connecting;
	LoopAnim(VidScreenOnAnim);

	MultiSkins[VideoSurface] = ConnectingVideo;
	ConnectingVideo.pause = false;
	ConnectingVideo.currentFrame = 0;

	// Check to see if any of the phone events in this level match this number.
	// If nothing does, its a wrong number.
	foreach AllActors(class'EZPhoneEvent', PhoneEvent)
	{
		if (ReverseNumber(PhoneEvent.PhoneNumber) == EnteredNumber)
			FoundEvent = PhoneEvent;
	}

	if (FoundEvent == None)
	{
		if (Len(EnteredNumber) == 8)
		{
			PhoneMode = PM_Busy;
			PlaySound( BusySound, SLOT_Misc, 1.0 );
			MultiSkins[VideoSurface] = BusyVideo;
		} else {
			PhoneMode = PM_Error;
			PlaySound( ErrorSound, SLOT_Misc, 1.0 );
			MultiSkins[VideoSurface] = ErrorVideo;
		}
	}
	else 
	{
		SetTimer( 3.0, true );
		SetTimer( 6 + FRand()*10, false, 2 );
		CurrentEvent = FoundEvent;
	}
}

function string ReverseNumber(string Number)
{
	local int i;
	local string TempNumber;

	// Reverse the phone number.
	for (i=0; i<Len(Number); i++)
	{
		TempNumber = TempNumber $ Mid(Number,Len(Number)-1-i,1);
	}

	return TempNumber;
}

function Hangup()
{
	StopSound(SLOT_Misc);
	PhoneMode = PM_Idle;
	LoopAnim(VidScreenOffAnim);
	VideoScreen.pause = true;
	BigKeyTimer = 0.2;
	bHungUp = true;
	if (CurrentEvent != None)
		CurrentEvent.PhoneSmack.pause = true;
	CurrentEvent = None;
	EnteredNumber = "";
	bDirty = true;

	// If we aren't being examined, prepare to close the phone up.
	if (!bExamined)
		SetTimer(3.0, false, 3);
}

// Set up the phone for an incoming call.
function IncomingCall()
{
	bDirty = true;
	if (SaverActive)
	{
		SaverActive = false;
		ScreenSaver.pause = true;
		MultiSkins[InputSurface] = CanvasTexture;
		CanvasTexture.Palette = PhoneBackground.Palette;
		InputScreen = CanvasTexture;
	}

	// Set the new phone mode.
	PhoneMode = PM_Ringing;

	// Show the video screen.
	LoopAnim(VidScreenOnAnim);

	// Set the connect video to the correct frame.
	MultiSkins[VideoSurface] = IncomingCallVideo;
	IncomingCallVideo.pause = false;
	IncomingCallVideo.currentFrame = 0;

	// Set the ring timer.
	PlaySound( PhoneRingSound, SLOT_Misc, 0.5 );
	SetTimer(4.0, true);
}

// Answer a pending call.
function AnswerCall()
{
	// Set the new phone mode.
	PhoneMode = PM_Connected;

	// Stop the ringing.
	StopSound(SLOT_Misc);

	// Show the video screen.
	LoopAnim(VidScreenOnAnim);

	// Set up the video smack.
	if ((CurrentEvent != None) && (CurrentEvent.PhoneSmack != None))
	{
		MultiSkins[VideoSurface] = CurrentEvent.PhoneSmack;
		CurrentEvent.PhoneSmack.currentFrame = 0;
		CurrentEvent.PhoneSmack.pause = false;
		CurrentEvent.PhoneSmack.loop = false;
		CurrentEvent.PhoneSmack.DrawClear(0);
	} else
		BroadcastMessage(CurrentEvent@"has no PhoneSmack!");
}

// Break this call because something happened on the remote end.
function InterruptCall()
{
	// Set the new phone mode.
	PhoneMode = PM_Interrupted;

	// Show the video screen.
	LoopAnim(VidScreenOnAnim);

	// Set the right video.
	MultiSkins[VideoSurface] = InterruptVideo;
	InterruptVideo.pause = false;
	InterruptVideo.currentFrame = 0;

	// Set an interrupt time.
	InterruptTime = 3.0;

	CurrentEvent = None;
}

// Timer handles perodic events like rings.
function Timer( optional int TimerNum )
{
	if ( PhoneMode == PM_Connecting )
	{
		if (TimerNum == 2)
			AnswerCall();
		else
			PlaySound( PhoneRingingSound, SLOT_Misc, 0.5 );
	}
	else if ( PhoneMode == PM_Ringing )
		PlaySound( PhoneRingSound, SLOT_Misc, 0.5 );
}

function ResetPressed()
{
	bDirty = true;

//	PlaySound( KeyPadResetSound, SLOT_None );
	EnteredNumber = "";
	TouchPawn = none;
}

function Examine( Actor Other )
{
	Super.Examine( Other );

	if (PhoneMode == PM_Idle)
		SetTimer(0.0, false, 3);

	bExamined = true;
}

function UnExamine( Actor Other )
{
	Super.UnExamine( Other );

	if (PhoneMode == PM_Idle)
		CloseTime = 2.0;
	else
		CloseTime = 0.0;

	bExamined = false;
}

function CloseDecoration( Actor Other )
{
	Super.CloseDecoration( Other );

	EnteredNumber = "";
	SaverActive = true;
	ScreenSaver.pause = false;
	MultiSkins[InputSurface] = ScreenSaver;
	TouchPawn = none;
	bDirty = true;
}

defaultproperties
{
	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
	bProjTarget=true
	bExaminable=true
	ExamineFOV=70

    HealthPrefab=HEALTH_NeverBreak
	ItemName="Video Phone"
	LodMode=LOD_Disabled

	TouchedKey=-1

	CanvasTexture=texturecanvas'ezphone.ezphone_canvas'
	Mesh=mesh'c_generic.ezphone_wall'
	ScreenSurface=1
	InputSurface=1
	VideoSurface=3
	PhoneBackground=texture'ezphone.vd_backgD'
	VideoBackground=texture'ezphone.vd_backgAD'
	PhoneKeypad=texture'ezphone.vd_keypD'
	PhoneKeyPress(0)=texture'ezphone.vd_num0D'
	PhoneKeyPress(1)=texture'ezphone.vd_num1D'
	PhoneKeyPress(2)=texture'ezphone.vd_num2D'
	PhoneKeyPress(3)=texture'ezphone.vd_num3D'
	PhoneKeyPress(4)=texture'ezphone.vd_num4D'
	PhoneKeyPress(5)=texture'ezphone.vd_num5D'
	PhoneKeyPress(6)=texture'ezphone.vd_num6D'
	PhoneKeyPress(7)=texture'ezphone.vd_num7D'
	PhoneKeyPress(8)=texture'ezphone.vd_num8D'
	PhoneKeyPress(9)=texture'ezphone.vd_num9D'
	PhoneKeyPress(10)=texture'ezphone.vd_numstarD'
	PhoneKeyPress(11)=texture'ezphone.vd_numpndD'
	PhoneCallPressed=texture'ezphone.vd_callHD'
	PhoneAnswer=texture'ezphone.vd_answerD'
	PhoneAnswerPressed=texture'ezphone.vd_answerHD'
	PhoneHangup=texture'ezphone.vd_hangupD'
	PhoneHangupPressed=texture'ezphone.vd_hangupHD'

	ConnectingVideo=smackertexture'ezphone.ezphone_con'
	InterruptVideo=smackertexture'ezphone.ezphone_dis'
	IncomingCallVideo=smackertexture'ezphone.ezphone_inc'
	BusyVideo=smackertexture'ezphone.ezphone_busy'
	ErrorVideo=smackertexture'ezphone.ezphone_err'

	KeyBoxes(0)=(Top=191,Left=191,Width=22,Height=22)
	KeyBoxes(1)=(Top=116,Left=166,Width=22,Height=22)
	KeyBoxes(2)=(Top=116,Left=191,Width=22,Height=22)
	KeyBoxes(3)=(Top=116,Left=216,Width=22,Height=22)
	KeyBoxes(4)=(Top=141,Left=166,Width=22,Height=22)
	KeyBoxes(5)=(Top=141,Left=191,Width=22,Height=22)
	KeyBoxes(6)=(Top=141,Left=216,Width=22,Height=22)
	KeyBoxes(7)=(Top=166,Left=166,Width=22,Height=22)
	KeyBoxes(8)=(Top=166,Left=191,Width=22,Height=22)
	KeyBoxes(9)=(Top=166,Left=216,Width=22,Height=22)
	KeyBoxes(10)=(Top=191,Left=166,Width=22,Height=22)
	KeyBoxes(11)=(Top=191,Left=216,Width=22,Height=22)
	BigKeyBox=(Top=24,Left=170,Width=92,Height=42)

	KeyPressSound(0)=sound'a_generic.telephone.PhoneDial0'
	KeyPressSound(1)=sound'a_generic.telephone.PhoneDial1'
	KeyPressSound(2)=sound'a_generic.telephone.PhoneDial2'
	KeyPressSound(3)=sound'a_generic.telephone.PhoneDial3'
	KeyPressSound(4)=sound'a_generic.telephone.PhoneDial4'
	KeyPressSound(5)=sound'a_generic.telephone.PhoneDial5'
	KeyPressSound(6)=sound'a_generic.telephone.PhoneDial6'
	KeyPressSound(7)=sound'a_generic.telephone.PhoneDial7'
	KeyPressSound(8)=sound'a_generic.telephone.PhoneDial8'
	KeyPressSound(9)=sound'a_generic.telephone.PhoneDial9'
	KeyPressSound(10)=sound'a_generic.telephone.PhoneDialPound'
	KeyPressSound(11)=sound'a_generic.telephone.PhoneDialStar'
	BigButtonPressSound=sound'a_generic.keypad.KeypdType59'
	PhoneRingSound=sound'a_generic.telephone.PhoneRingOut'
	PhoneRingingSound=sound'a_generic.telephone.PhoneRingIns'
	BusySound=sound'a_generic.telephone.PhoneBusyLp'
	ErrorSound=sound'a_generic.telephone.PhoneError1'

	PhoneSaver=smackertexture'ezphone.video.ezphone_saver'
	VidScreenOnAnim=vidscreen_on
	VidScreenOffAnim=idle
}