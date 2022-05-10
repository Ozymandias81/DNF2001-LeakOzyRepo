//=============================================================================
// TriggerToggleHidden. (NJS)
//
// When triggered alters the status of the bHidden variable for the object 
// specified by Event.
//
// See the documentation for ToggleHiddenType immedietely below for a 
// description of what each operator does.
//=============================================================================
class TriggerToggleHidden expands Triggers;

#exec Texture Import File=Textures\TriggerHidden.pcx Name=S_TriggerHidden Mips=Off Flags=2

var() enum EToggleHiddenType
{
	TH_Show,		// Shows the target item.
	TH_Hide,		// Hides the target item.
	TH_Toggle,		// Toggle the target item's visible state.
	TH_Random		// Randomly set the target item's visible state.
} ToggleHiddenType;

// Trigger passes on the event to my targets. (when enabled)
function Trigger( actor Other, pawn EventInstigator )
{
	local actor A;
	
	// Make sure event is valid 
	if( Event != '' )
		// Trigger all actors with matching triggers 
		foreach AllActors( class 'Actor', A, Event )		
		{
			switch(ToggleHiddenType)
			{
				case TH_Show:   A.bHidden=false; break;
				case TH_Hide:   A.bHidden=true;  break;
					
				case TH_Toggle: 
					if(A.bHidden==false) A.bHidden=true;
					else A.bHidden=false;
					break;
					
				case TH_Random: 
					A.bHidden=bool(Rand(2));
					break;
			}
		}
}

defaultproperties
{
     ToggleHiddenType=TH_Toggle
     Texture=Texture'Engine.S_TriggerHidden'
}
