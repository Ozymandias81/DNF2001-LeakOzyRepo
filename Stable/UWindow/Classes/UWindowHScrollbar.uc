//=============================================================================
// UWindowHScrollBar - A horizontal scrollbar
//=============================================================================
class UWindowHScrollBar extends UWindowWindow;

var UWindowSBLeftButton		LeftButton;
var UWindowSBRightButton	RightButton;
var bool					bDisabled;
var float					MinPos;
var float					MaxPos;
var float					MaxVisible;
var float					Pos;				// offset to WinTop
var float					ThumbStart, ThumbWidth;
var float					NextClickTime;
var float					DragX;
var bool					bDragging;
var float					ScrollAmount;

function Show(float P)
{
	if(P < 0) return;
	if(P > MaxPos + MaxVisible) return;

	while(P < Pos) 
		if(!Scroll(-1))
			break;
	while(P - Pos > MaxVisible - 1)
		if(!Scroll(1))
			break;
}

function bool Scroll(float Delta) 
{
	local float OldPos;
	
	OldPos = Pos;
	Pos = Pos + Delta;
	CheckRange();
	return Pos == OldPos + Delta;
}

function SetRange(float NewMinPos, float NewMaxPos, float NewMaxVisible, optional float NewScrollAmount)
{
	if(NewScrollAmount == 0)
		NewScrollAmount = 1;

	ScrollAmount = NewScrollAmount;
	MinPos = NewMinPos;
	MaxPos = NewMaxPos - NewMaxVisible;
	MaxVisible = NewMaxVisible;

	CheckRange();
}

function CheckRange() 
{
	if(Pos < MinPos)
	{
		Pos = MinPos;
	}
	else
	{
		if(Pos > MaxPos) Pos = MaxPos;
	}

	bDisabled = (MaxPos <= MinPos);
	LeftButton.bDisabled = bDisabled;
	RightButton.bDisabled = bDisabled;

	if(bDisabled)
	{
		Pos = 0;
	}
	else
	{
		ThumbStart = ( 	(Pos - MinPos) * 
						(WinWidth - (2*LookAndFeel.SBPosIndicator.W))
					 ) / (MaxPos + MaxVisible - MinPos);
		/*
		ThumbWidth = (	MaxVisible * 
						(WinWidth - (2*LookAndFeel.SBPosIndicator.W))
					 ) / (MaxPos + MaxVisible - MinPos);
		*/
		ThumbWidth = LookAndFeel.SBPosIndicator.H;

		if(ThumbWidth < LookAndFeel.SBPosIndicator.W) 
			ThumbWidth = LookAndFeel.SBPosIndicator.W;
		
		if(ThumbWidth + ThumbStart > WinWidth - 2*LookAndFeel.SBPosIndicator.W)
		{
			ThumbStart = WinWidth - 2*LookAndFeel.SBPosIndicator.W - ThumbWidth;
		}
	
		ThumbStart = ThumbStart + LookAndFeel.SBPosIndicator.H;
	}
}

function Created() 
{
	Super.Created();
	LeftButton = UWindowSBLeftButton(CreateWindow(class'UWindowSBLeftButton', 
									 			  0, 0, 
									 			  LookAndFeel.SBLeftUp.W, LookAndFeel.SBLeftUp.H
									 )
	);
	RightButton = UWindowSBRightButton(CreateWindow(class'UWindowSBRightButton', 
													WinWidth-10, 0, 
													LookAndFeel.SBRightUp.W, LookAndFeel.SBRightUp.H
									)
	);
}


function BeforePaint(Canvas C, float X, float Y)
{
	//TLW: Want an overlap with bevel of frame window
	LeftButton.WinTop = 1;
	LeftButton.WinLeft = -1;		
//	LeftButton.WinWidth = LookAndFeel.ScrollBarPosIndicator.W;
//	LeftButton.WinHeight = LookAndFeel.SBLeftUp.H + 1;

	RightButton.WinTop = 1;
	RightButton.WinLeft = WinWidth - LookAndFeel.SBRightUp.W + 1; 
//	RightButton.WinWidth = LookAndFeel.ScrollBarPosIndicator.W;
//	RightButton.WinHeight = LookAndFeel.SBRightUp.H + 1;

	CheckRange();
}

function Paint(Canvas C, float X, float Y) 
{
	LookAndFeel.SB_HDraw(Self, C);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if(bDisabled) return;

	if(X < ThumbStart)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetLevel().TimeSeconds + 0.5;
		return;
	}
	if(X > ThumbStart + ThumbWidth)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetLevel().TimeSeconds + 0.5;
		return;
	}

	if((X >= ThumbStart) && (X <= ThumbStart + ThumbWidth))
	{
		DragX = X - ThumbStart;
		bDragging = True;
		Root.CaptureMouse();
		return;
	}
}


function Tick(float Delta) 
{
	local bool bLeft, bRight;
	local float X, Y;

	if(bDragging) return;

	bLeft = False;
	bRight = False;

	if(bMouseDown)
	{
		GetMouseXY(X, Y);
		bLeft = (X < ThumbStart);
		bRight = (X > ThumbStart + ThumbWidth);
	}
	
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetLevel().TimeSeconds)  && bLeft)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetLevel().TimeSeconds + 0.1;
	}

	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetLevel().TimeSeconds)  && bRight)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetLevel().TimeSeconds + 0.1;
	}

	if(!bMouseDown || (!bLeft && !bRight))
	{
		NextClickTime = 0;
	}
}

function MouseMove(float X, float Y)
{
	if(bDragging && bMouseDown && !bDisabled)
	{
		while(X < (ThumbStart+DragX) && Pos > MinPos)
		{
			Scroll(-1);
		}

		while(X > (ThumbStart+DragX) && Pos < MaxPos)
		{
			Scroll(1);
		}	
	}
	else
		bDragging = False;
}

defaultproperties
{
}
