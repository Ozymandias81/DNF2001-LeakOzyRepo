//=============================================================================
// TriggerVideoPoker. (NJS)
// 
// Event is video poker thingee to modify.
//=============================================================================
class TriggerVideoPoker expands Triggers;

var () enum EVideoPokerEvent
{
	VP_Draw,
	VP_CashOut,
	VP_Bet1,
	VP_Bet2,
	VP_Bet3,
	VP_ToggleCard1,
	VP_ToggleCard2,
	VP_ToggleCard3,
	VP_ToggleCard4,
	VP_ToggleCard5
	
} VideoPokerEvent;

function Trigger( actor Other, pawn EventInstigator )
{
	local VideoPoker v;
	
	if(Event!='')
		foreach allactors(class'VideoPoker',v,Event)
		{
			switch(VideoPokerEvent)
			{
				case VP_Draw:		 v.DrawPressed(); 			break;
				case VP_CashOut:	 v.CashOutPressed();		break;
				case VP_Bet1:		 v.Bet1Pressed();			break;
				case VP_Bet2:		 v.Bet2Pressed();			break;
				case VP_Bet3:		 v.Bet3Pressed();			break;
				case VP_ToggleCard1: v.ToggleCard1Pressed();	break;
				case VP_ToggleCard2: v.ToggleCard2Pressed();	break;
				case VP_ToggleCard3: v.ToggleCard3Pressed();	break;
				case VP_ToggleCard4: v.ToggleCard4Pressed();	break;
				case VP_ToggleCard5: v.ToggleCard5Pressed();	break;
			}
		}
}

defaultproperties
{
    Texture=Texture'Engine.S_TrigVideoPoker'

}
