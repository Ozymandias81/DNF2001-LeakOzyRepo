class UWindowHSliderControl extends UWindowDialogControl;


var	float	MinValue;
var	float	MaxValue;
var	float	Value;
var	float	Step;		// 0 = continuous

var	float	SliderWidth;
var	float	SliderDrawX, SliderDrawY, SliderTrackX, SliderTrackWidth;
var float	TrackStart;
var float	TrackWidth;
var float	GrabOffset;
var bool	bSliding;
var bool	bNoSlidingNotify;
var bool	bFloatValue;
var string	ValueString;
var float	LastSlideTime;
var float	MouseDownValue;

function Created()
{
	Super.Created();
	SliderWidth = WinWidth / 2;
}

function SetRange(float Min, float Max, float NewStep)
{
	MinValue = Min;
	MaxValue = Max;
	Step = NewStep;
	Value = CheckValue(Value);
}

function float GetValue()
{
	return Value;
}

function SetValue( float NewValue, optional bool bNoNotify )
{
	local int i;
	local float OldValue;

	OldValue = Value;

	Value = CheckValue(NewValue);

	if ( Value != OldValue )
	{
		//TLW: Added playing of a sound, volume = % of value in the range 
		//		(but don't pass zero for volume, otherwise PlayMenuSound() maxes out the volume) 
//		LookAndFeel.PlayMenuSound( Self, MS_SliderMove, 0.005f + ((Value - MinValue)  / (MaxValue - MinValue)) );
	
		// Notify
		if ( !bNoNotify )
			Notify( DE_Change );
	}

	if ( bFloatValue )
	{
		i = InStr(string(Value), ".");
		ValueString = Left(string(Value), i+3);
	} else
		ValueString = string(int(Value));
	ValueString = ValueString;
}


function float CheckValue(float Test)
{
	local float NewValue, Low, High;
	
	NewValue = Test;
	
	if(Step != 0)
	{
		Low = int(Test);
		High = Low + Step;
		if (Test < Low + (Step/2))
			NewValue = Low;
		else
			NewValue = High;
	}

	if(NewValue < MinValue) NewValue = MinValue;
	if(NewValue > MaxValue) NewValue = MaxValue;

	return NewValue;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	
	Super.BeforePaint(C, X, Y);
	
	TextSize(C, Text, W, H);
	LookAndFeel.HSlider_AutoSize( Self, C );

	switch(Align)
	{
	case TA_Left:
		SliderDrawX = WinWidth - SliderWidth;
		TextX = 0;
		break;
	case TA_Right:
		SliderDrawX = 0;	
		TextX = WinWidth - W;
		break;
	case TA_Center:
		SliderDrawX = (WinWidth - SliderWidth) / 2;
		TextX = (WinWidth - W) / 2;
		break;
	}

	SliderDrawY = 0;
	TextY = (WinHeight - H) / 2;

	if ( bMouseDown && (GetLevel().TimeSeconds > LastSlideTime+0.1) )
	{
		LastSlideTime = GetLevel().TimeSeconds;
		if((X >= TrackStart - TrackWidth/2) && (X <= TrackStart - TrackWidth/2 + TrackWidth)) {
			bSliding = True;
			GrabOffset = X - (TrackStart - TrackWidth/2);
			Root.CaptureMouse();
		}

		if(X < TrackStart - TrackWidth/2 && X > SliderDrawX)
		{
			if(Step != 0)
				SetValue(Value - Step);
			else
				SetValue(Value - 1);
		}
		
		if(X > TrackStart - TrackWidth/2 + TrackWidth && X < SliderDrawX + SliderWidth)
		{
			if(Step != 0)
				SetValue(Value + Step);
			else
				SetValue(Value + 1);
		}
	}
}

function Paint( Canvas C, float X, float Y )
{
	LookAndFeel.HSlider_Draw( Self, C );
}

function LMouseUp(float X, float Y)
{
	Super.LMouseUp(X, Y);

	if(bNoSlidingNotify)
		Notify(DE_Change);

	if ( Value != MouseDownValue )
		LookAndFeel.PlayMenuSound( Self, MS_MenuAction );
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	MouseDownValue = Value;
}


function MouseMove( float X, float Y )
{
//	local float NewValue;

	Super.MouseMove( X, Y );

	if ( bSliding && bMouseDown )
	{
//		NewValue = (X - SliderTrackX) / SliderTrackWidth;
		SetValue((((X - SliderTrackX - GrabOffset) / SliderTrackWidth) * (MaxValue - MinValue)) + MinValue, bNoSlidingNotify);
	}
	else
		bSliding = False;
}


function KeyDown(int Key, float X, float Y)
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	switch (Key)
	{
	case P.EInputKey.IK_Left:
		if(Step != 0)
			SetValue(Value - Step);
		else
			SetValue(Value - 1);

		break;
	case P.EInputKey.IK_Right:
		if(Step != 0)
			SetValue(Value + Step);
		else
			SetValue(Value + 1);

		break;
	case P.EInputKey.IK_Home:
		SetValue(MinValue);
		break;
	case P.EInputKey.IK_End:
		SetValue(MaxValue);
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}

defaultproperties
{
}
