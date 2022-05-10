//=============================================================================
// Al_TriggerAnim.
//=============================================================================
class TriggerAnim expands AnimPlayer;

var()	name	animSeq[9];
var()	float	animSpeed;
var()	bool 	animLoop;
var()	bool	animInstant;
var()	name	animSeqIdle[9];

function Trigger( actor Other, pawn EventInstigator )
{
	local	int	i;
        local   AnimPlayer A; 
	
	/* Make sure event is valid AND there is an Sequence to play*/
	if( Event != '' && animSeq[0] != '' )
		/* Trigger all actors with matching triggers */
                foreach AllActors( class 'AnimPlayer', A, Event )    
			///* Does this object's tag match */
			//if(Event==A.tag)
			{

				for(i=0;i<9;i++){	A.animSeq[i] = animSeq[i];	}
				A.animSpeed = animSpeed;
				A.animLoop	= animLoop;
				A.animInstant	= animInstant;
				for(i=0;i<9;i++){	A.animSeqIdle[i] = animSeqIdle[i];	}
				
				if(animLoop)	A.Al_LoopAnim();
				else			A.Al_PlayAnim();				
			}
}

defaultproperties
{
     bHidden=True
     bDirectional=False
     Physics=PHYS_None
}
