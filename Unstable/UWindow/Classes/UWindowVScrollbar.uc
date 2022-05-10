//=============================================================================
// UWindowVScrollBar - A vertical scrollbar
//=============================================================================
class UWindowVScrollBar extends UWindowWindow;

var UWindowSBUpButton		UpButton;
var UWindowSBDownButton		DownButton;
var bool					bDisabled;
var float					MinPos;
var float					MaxPos;
var float					MaxVisible;
var float					Pos;				// offset to WinTop
var float					ThumbStart, ThumbHeight;
var float					NextClickTime;
var float					DragY;
var bool					bDragging;
var float					ScrollAmount;
var bool					bFramedWindow;
var bool					bInBevel;

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
	MaxPos = NewMaxPos - NewMaxVisible;
	MaxVisible = NewMaxVisible;

	CheckRange();
}

function CheckRange()
{
	local float IndicatorHeight;

	if ( bFramedWindow )
		IndicatorHeight = LookAndFeel.SBPosIndicator.H;
	else
		IndicatorHeight = LookAndFeel.SBPosIndicatorSmall.H;

	if(Pos < MinPos)
	{
		Pos = MinPos;
	}
	else
	{
		if(Pos > MaxPos) Pos = MaxPos;
	}

	bDisabled = (MaxPos <= MinPos);
	DownButton.bDisabled = bDisabled;
	UpButton.bDisabled = bDisabled;

	if(bDisabled)
	{
		Pos = 0;
	}
	else
	{
		ThumbStart = (	(Pos - MinPos) * 
						(WinHeight - (2*LookAndFeel.SBPosIndicator.H))
					 ) / (MaxPos + MaxVisible - MinPos);
		ThumbHeight = (MaxVisible * 
					   (WinHeight - (2*LookAndFeel.SBPosIndicator.H))
					 ) / (MaxPos + MaxVisible - MinPos);
		if(	ThumbHeight < LookAndFeel.SBPosIndicator.H) 
			ThumbHeight = LookAndFeel.SBPosIndicator.H;
		
		if(ThumbHeight + ThumbStart > WinHeight - (2*LookAndFeel.SBPosIndicator.H))
		{
			ThumbStart = WinHeight - (2*LookAndFeel.SBPosIndicator.H) - ThumbHeight;
		}
	
		ThumbStart = ThumbStart + LookAndFeel.SBPosIndicator.H;
	}
}

function Created()
{
	Super.Created();
	UpButton = UWindowSBUpButton(CreateWindow(class'UWindowSBUpButton', 
											  0, 0, 
											  LookAndFeel.SBUpUp.W, LookAndFeel.SBUpUp.H
								 )
	);
	DownButton = UWindowSBDownButton(CreateWindow(class'UWindowSBDownButton', 
												  0, WinHeight-LookAndFeel.SBDownUp.W, 
												  LookAndFeel.SBDownUp.W, LookAndFeel.SBDownUp.H
									 )
	);
}

function BeforePaint(Canvas C, float X, float Y)
{
	UpButton.WinTop =  0;
	UpButton.WinLeft = 0;
	DownButton.WinLeft = 0;
	if ( bFramedWindow )
	{
		UpButton.WinWidth = WinWidth;
		UpButton.WinHeight = LookAndFeel.VScrollUpDown.H;

		DownButton.WinWidth = WinWidth;
		DownButton.WinHeight = LookAndFeel.VScrollDownDown.H;

		DownButton.WinTop = WinHeight - DownButton.WinHeight;
	}
	else if ( bInBevel )
	{
		UpButton.WinWidth = WinWidth;
		UpButton.WinHeight = LookAndFeel.VScrollSmallUpDown.H + 3;

		DownButton.WinWidth = WinWidth;
		DownButton.WinHeight = LookAndFeel.VScrollSmallDownDown.H + 3;

		DownButton.WinTop = WinHeight - DownButton.WinHeight - 3;
	}
	else
	{
		UpButton.WinWidth = WinWidth;
		UpButton.WinHeight = LookAndFeel.VScrollBevelUpDown.H;
		DownButton.WinWidth = WinWidth;
		DownButton.WinHeight = LookAndFeel.VScrollBevelDownDown.H;

		DownButton.WinTop = WinHeight - DownButton.WinHeight;
	}

	CheckRange();
}

function Paint(Canvas C, float X, float Y) 
{
	LookAndFeel.SB_VDraw(Self, C);
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if(bDisabled) return;

	if(Y < ThumbStart)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetLevel().TimeSeconds + 0.5;
		return;
	}
	if(Y > ThumbStart + ThumbHeight)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetLevel().TimeSeconds + 0.5;
		return;
	}

	if((Y >= ThumbStart) && (Y <= ThumbStart + ThumbHeight))
	{
		DragY = Y - ThumbStart;
		bDragging = True;
		Root.CaptureMouse();
		return;
	}
}

function Tick(float Delta)
{
	local bool bUp, bDown;
	local float X, Y;

	if(bDragging) return;

	bUp = False;
	bDown = False;

	if(bMouseDown)
	{
		GetMouseXY(X, Y);
		bUp = (Y < ThumbStart);
		bDown = (Y > ThumbStart + ThumbHeight);
	}
	
	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetLevel().TimeSeconds)  && bUp)
	{
		Scroll(-(MaxVisible-1));
		NextClickTime = GetLevel().TimeSeconds + 0.1;
	}

	if(bMouseDown && (NextClickTime > 0) && (NextClickTime < GetLevel().TimeSeconds)  && bDown)
	{
		Scroll(MaxVisible-1);
		NextClickTime = GetLevel().TimeSeconds + 0.1;
	}

	if(!bMouseDown || (!bUp && !bDown))
	{
		NextClickTime = 0;
	}
}

function MouseMove(float X, float Y)
{
	if(bDragging && bMouseDown && !bDisabled)
	{
		while(Y < (ThumbStart+DragY) && Pos > MinPos)
		{
			Scroll(-1);
		}

		while(Y > (ThumbStart+DragY) && Pos < MaxPos)
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
