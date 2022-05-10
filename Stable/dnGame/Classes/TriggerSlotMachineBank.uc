//=============================================================================
// TriggerSlotMachineBank.
//=============================================================================
class TriggerSlotMachineBank expands RenderActor;

var () int MachineNumber;
var SlotMachineBank Bank;
var () Enum EAction
	   {
		  SL_Disable,	// Disable n nearest slot machine triggers.
	      SL_Bet,
	      SL_Spin
	   } Action;
var () int DamageAmount;

var actor TouchPawn;

function PostBeginPlay()
{
	local TriggerSlotMachineBank t,
							 closest;
	local float Distance, temp;

	closest=none;
	Distance=99999999.9;

	if(Action==SL_Disable)
	{
		GrabTrigger=False;
		foreach AllActors(class'TriggerSlotMachineBank',t)
		{
			if(t!=self)
			{
				temp=VSize(t.Location-Location);
				if(temp<=Distance)
				{
					Distance=temp;
					closest=t;
				}
			}
		}

		closest.Bank.DamageMachine(closest.MachineNumber,DamageAmount);
		Destroy();
		return;
	} 
	Bank=SlotMachineBank(FindActorTagged(class'SlotMachineBank', Event));
}
/*
function UnTouch(actor Other)
{
	Super.UnTouch(Other);
		
	if (Other.IsA('DukePlayer'))
		DukePlayer(Other).Hand_QuickAnim('SlapButton');
}
*/

function Examine( Actor Other )
{
	local bool ret;

	ret = false;

	Super(dnDecoration).Examine( Other );

	//BroadcastMessage("Examining");
	
	if(Action==SL_Bet) 			
		ret = Bank.AddBet(MachineNumber,Pawn(Other));
	else if(Action==SL_Spin)	
		ret = Bank.ActivateMachine(MachineNumber,Pawn(Other));

	if (ret)
		TouchPawn = Other;
	else
		TouchPawn = None;
}

function UnExamine( Actor Other )
{	
	Super(dnDecoration).UnExamine( Other );
	
	//BroadcastMessage("Done examining");

	if (TouchPawn != None)
		DukePlayer(TouchPawn).Hand_WeaponUp();
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(Action==SL_Bet) 			
		Bank.AddBet(MachineNumber,EventInstigator);
	else if(Action==SL_Spin)	
		Bank.ActivateMachine(MachineNumber,EventInstigator);
}

defaultproperties
{
	bHidden=True
	CollisionRadius=+00040.000000
	CollisionHeight=+00040.000000
	bCollideActors=True
	DamageAmount=10
	GrabTrigger=True
	bProjTarget=True
	bExaminable=true
	bNoFOVOnExamine=true
	bExamineRadiusCheck=true
	ExamineRadius=50.0
}
