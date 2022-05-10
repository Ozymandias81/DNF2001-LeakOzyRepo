//=============================================================================
// Al_AnimPlayer.
//=============================================================================
class AnimPlayer expands Triggers;


//-----------------------------------------------------------------------------
// Variables.

var		name	animSeq[9];
var		float	animSpeed;
var	 	bool	animLoop;
var		bool	animInstant;
var		name	animSeqIdle[9];

var		int	animPlayOnce;


//-----------------------------------------------------------------------------
// Functions.

function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	Enable( 'Tick' );
}



function Al_PlayAnim ()
{
local int i;
	if(animSeq[0] == '') return;

	do i=Rand(ArrayCount(animSeq));
		until(animSeq[i]!='');
		
	animPlayOnce = 2;
	if(animInstant) PlayAnim(animSeq[i],animSpeed);
	else	animPlayOnce = 1;
}


function Al_LoopAnim ()
{
local int i;

	if(animSeq[0] == '') return;

	do i=Rand(ArrayCount(animSeq));
		until(animSeq[i]!='');
		
	if(animInstant) LoopAnim(animSeq[i],animSpeed);
	animPlayOnce = 0;
}


function Tick ( float deltaTime )
{
	local int i;
	super.Tick(deltaTime);

	if(Mesh==none) return;
	
	if(animSeq[0] == '') return;
	if( IsAnimating() ) return;

	if( animLoop || animPlayOnce == 1 )
	{
		do i=Rand(ArrayCount(animSeq));
			until(animSeq[i]!='');
		
		PlayAnim(animSeq[i],animSpeed);
		
		if(animPlayOnce == 1) animPlayOnce = 2;		// don't play anim again	
	}

	// Play Idle sequence after single sequence
	if(animSeqIdle[0] == '') return;

	if( !animLoop && animPlayOnce == 2 )
	{
		do i=Rand(ArrayCount(animSeqIdle));
			until(animSeqIdle[i]!='');
		
		PlayAnim(animSeqIdle[i],animSpeed);	
	}
}

defaultproperties
{
     bHidden=False
     bDirectional=True
     Physics=PHYS_MovingBrush
     Texture=Texture'Engine.S_KeyframeDispatch'
}
