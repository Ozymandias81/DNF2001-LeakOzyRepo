//=============================================================================
// dnSwitchDecoration.
//=============================================================================
class dnSwitchDecoration expands dnDecoration;

struct SwitchState
{
	var () bool  AfterSequence;
	var () name  Sequence;
	var () bool  SequenceLoop;
	var () sound Sound;
	var () name  Event;
	var () sound AmbientSound;
	var () class<actor> SpawnActor;
	var () Mesh 	Mesh;
	var () Texture 	Skin;
};

var() SwitchState SwitchStates[8];
var() bool RandomState;	// Randomly select a state whenever triggered
var() bool Loop;		// Loop after last state.
var() int CurrentSwitchState;
var() int NumberStates;
var   bool bTriggeredOnce;

var() name BrokenEvent;
var() bool bBroken;

function PostBeginPlay()
{
	local SwitchInpatcher IP;

	PlayAnim(SwitchStates[CurrentSwitchState].Sequence,1.0,0.0);

	IP = spawn( class'SwitchInpatcher' );
	IP.Tags[0] = BrokenEvent;
	IP.MySwitch = Self;
	IP.Inpatch();

	Super.PostBeginPlay();
}

function Broken( actor Other, pawn EventInstigator )
{
	if ( Other != Self )
		bBroken = true;
}

event GlobalTrigger( name TriggerEvent, optional Pawn Instigator, optional actor Other )
{
	if ( bBroken )
		return;
	else
		Super.GlobalTrigger( TriggerEvent, Instigator, Other );
}

function AnimEnd()
{
	if (bTriggeredOnce)
		if((CurrentSwitchState>=0)&&(CurrentSwitchState<NumberStates))
			if(SwitchStates[CurrentSwitchState].AfterSequence)
			{
				if(SwitchStates[CurrentSwitchState].Sound!=none)
					PlaySound(SwitchStates[CurrentSwitchState].Sound);	
		
				if(SwitchStates[CurrentSwitchState].Event!='')
					GlobalTrigger(SwitchStates[CurrentSwitchState].Event,Instigator);	
	
				AmbientSound=SwitchStates[CurrentSwitchState].AmbientSound;
			
				if(SwitchStates[CurrentSwitchState].SpawnActor!=none)
					Spawn(SwitchStates[CurrentSwitchState].SpawnActor);
					
				if(SwitchStates[CurrentSwitchState].Mesh!=none)
					Mesh=SwitchStates[CurrentSwitchState].Mesh;

				if(SwitchStates[CurrentSwitchState].Skin!=none)
					Skin=SwitchStates[CurrentSwitchState].Skin;
				enable('Trigger');
			}
}

function Trigger( actor Other, pawn EventInstigator )
{
	disable('Trigger');
	bTriggeredOnce = True;

	Instigator=EventInstigator;
	super.Trigger(Other,EventInstigator);	// Process standard decoration code

	// Have I finished playing all states?
	if(CurrentSwitchState>=NumberStates)
		return;

	if(RandomState) 
		currentSwitchState=Rand(NumberStates);
	else
	{
		CurrentSwitchState++;
		if(Loop)									// Should I loop?
			if(CurrentSwitchState>=NumberStates)	// Have I exceeded my maximum # of states?
				CurrentSwitchState=0;				// Start at the very beginning.
	}
	
	// Fire off the current switch state:
	if(SwitchStates[CurrentSwitchState].Sequence!='')
	{
		if(SwitchStates[CurrentSwitchState].SequenceLoop)
			LoopAnim(SwitchStates[CurrentSwitchState].Sequence,1.0,0.0);
		else
			PlayAnim(SwitchStates[CurrentSwitchState].Sequence,1.0,0.0);
	}
	if(!SwitchStates[currentSwitchState].AfterSequence)
	{
		if(SwitchStates[CurrentSwitchState].Sound!=none)
			PlaySound(SwitchStates[CurrentSwitchState].Sound);	
	
		if(SwitchStates[CurrentSwitchState].Event!='')
			GlobalTrigger(SwitchStates[CurrentSwitchState].Event,EventInstigator);	
	
		AmbientSound=SwitchStates[CurrentSwitchState].AmbientSound;
		
		if(SwitchStates[CurrentSwitchState].SpawnActor!=none)
			Spawn(SwitchStates[CurrentSwitchState].SpawnActor);

		if(SwitchStates[CurrentSwitchState].Mesh!=none)
			Mesh=SwitchStates[CurrentSwitchState].Mesh;

		if(SwitchStates[CurrentSwitchState].Skin!=none)
			Skin=SwitchStates[CurrentSwitchState].Skin;
		enable('Trigger');
	}
	
}

defaultproperties
{
}
