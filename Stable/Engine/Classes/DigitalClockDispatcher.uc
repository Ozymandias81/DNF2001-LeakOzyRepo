//=============================================================================
// DigitalClockDispatcher. (NJS)
// 
// Draws a digital clock in a specified font to the specified canvas.
//=============================================================================
class DigitalClockDispatcher expands Dispatchers;

var () font ClockFont;				// Font to use
var () TextureCanvas ClockCanvas;	// TextureCanvas to draw the font on.
var () int x,y;						// Coordinates on the canvas of the clock's upper left corner
	
var () bool UseHours,				// Display hours
  			UseMinutes,				// Display minutes
  			UseSeconds,				// Display seconds
  			UseHundredths,			// Display hundredth's of a second
  			MilitaryTime,			// Display time in military time
  			FlashColon,				// Show the flashing colon.
  			UseAMPM;				// Show the AM/PM marker

var () string FillCharacter; // Usually zero or space

function string FormatTimeNumber(int t)
{
	local string TimeString;
	local int tOver10;
	
	TimeString="";
	
	tOver10=t/10;
	if(bool(tOver10))
		TimeString=TimeString$tOver10;
	else 	
		TimeString=TimeString$FillCharacter;

	TimeString=TimeString$int((t%10));

	return TimeString;
}

function string ColonString()
{
	if(!FlashColon||bool(Level.Second&1)) return ":";
	return " ";
}

function PostBeginPlay()
{
	if(UseHundredths)          SetTimer(0.01,true);
	else if(FlashColon||UseSeconds) SetTimer(1,true);
	else if(UseMinutes)		   SetTimer(60,true);
	else if(UseHours)		   SetTimer(60*60,true);
}

function Timer(optional int TimerNum)
{
	local string TimeString;
	local int i;
	
	if(!bool(ClockFont)||!bool(ClockCanvas)) return;
	
	TimeString="";
	
	if(UseHours)
	{
		i=Level.Hour;

		if(!MilitaryTime) // Convert to military time:
		{
			i=i%12; 
			if(i==0) i=12;
		}			
	
		TimeString=TimeString$FormatTimeNumber(i);
	}	
	
	if(UseMinutes)
	{
		if(UseHours) TimeString=TimeString$ColonString(); 
		TimeString=TimeString$FormatTimeNumber(Level.Minute);
	}

	if(UseSeconds)
	{
		if(UseHours||UseMinutes) TimeString=TimeString$ColonString(); 
		TimeString=TimeString$FormatTimeNumber(Level.Second);
	}

	if(UseHundredths)
	{
		if(UseHours||UseMinutes||UseSeconds) TimeString=TimeString$ColonString(); 
		TimeString=TimeString$FormatTimeNumber(Level.Millisecond/10);
	}
	
	if(UseAMPM)
	{
		if(UseHours||UseMinutes||UseSeconds||UseHundredths) TimeString=TimeString$" ";
		
		if(Level.Hour%12==Level.Hour)
			TimeString=TimeString$"AM";
		else
			TimeString=TimeString$"PM";
	}
	
	ClockCanvas.DrawString(ClockFont,x,y,TimeString,false,false,false);
}

defaultproperties
{
}
