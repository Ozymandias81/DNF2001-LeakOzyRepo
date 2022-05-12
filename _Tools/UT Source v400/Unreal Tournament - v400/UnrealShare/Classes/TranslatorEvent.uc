//=============================================================================
// TranslatorEvent.
//=============================================================================
class TranslatorEvent extends Triggers;

#exec AUDIO IMPORT FILE="Sounds\Pickups\TransA3.WAV" NAME="TransA3" GROUP="Pickups"
#exec Texture Import File=Textures\Message.pcx Name=S_Message Mips=Off Flags=2

// Human readable triggering message.
var() localized string Message;
var() localized string AltMessage;
var() localized string Hint;
var() bool bTriggerOnly;
var() sound NewMessageSound;
var() bool bTriggerAltMessage;
var bool bHitOnce, bHitDelay;
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var	  float TriggerTime;

var Translator Trans;

var() localized String M_NewMessage;
var() localized String M_TransMessage;

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor Targets;
	local string Temp;

	if (bTriggerAltMessage) 
	{
		Temp = Message;
		Message = AltMessage;
		AltMessage = Temp;
		bHitOnce = False;
		foreach TouchingActors(class'Actor', Targets)
			if (Targets == Other) Touch(Other);
	}
	else Touch(Other);
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	UnTouch(Other);
}


function Timer()
{
	bHitDelay=False;
}

function Touch( actor Other )
{
	local inventory Inv;
	
	if (PlayerPawn(Other)==None || bHitDelay) Return;
	
	if (Hint=="" && Message=="") Return;

	if ( ReTriggerDelay > 0 )
	{
		if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
			return;
		TriggerTime = Level.TimeSeconds;
	}
	
	for( Inv=Other.Inventory; Inv!=None; Inv=Inv.Inventory ) 	
		if (Translator(Inv)!=None) 
		{
			Translator(Inv).Hint = Hint;
			Translator(Inv).bShowHint = False;
			if (Message=="") Return;
			Trans = Translator(Inv);
			if (!bHitOnce) Translator(Inv).bNewMessage = true;
			else Translator(Inv).bNotNewMessage = true;
			Translator(Inv).NewMessage = Message;
			if (!bHitOnce) Pawn(Other).ClientMessage(M_NewMessage);
			else Pawn(Other).ClientMessage(M_TransMessage);
			bHitOnce = True;
			SetTimer(0.3,False);
			bHitDelay = True;
			PlaySound(NewMessageSound, SLOT_Misc);
			Break;
		}
	
}

function UnTouch( actor Other )
{
	if (Trans!=None)	{
		Trans.bNewMessage = False;
		Trans.bNotNewMessage = False;
		if( Trans.IsInState('Activated')) Trans.GoToState('Deactivated');
	}
	bHitDelay=False;
}

defaultproperties
{
     NewMessageSound=Sound'UnrealShare.TransA3'
     ReTriggerDelay=0.250000
     M_NewMessage="New Translator Message"
     M_TransMessage="Translator Message"
     Texture=Texture'UnrealShare.S_Message'
}
