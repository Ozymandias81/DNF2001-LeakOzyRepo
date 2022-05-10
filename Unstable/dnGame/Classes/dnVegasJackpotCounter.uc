//=============================================================================
// dnVegasJackpotCounter.  Actually should be used for general number outputs.
//=============================================================================
class dnVegasJackpotCounter expands InfoActor;

var () texture Digits[10];		// Digit bitmaps.
var () texture Comma 			?("Comma bitmap, if none, commas arent used");
var () texture DecimalPoint     ?("Decimal point bitmap, if none, decimal points arent used.");
var () texture DollarSign;

var () int			 PrintedDigits;
var () TextureCanvas OutputTexture 		?("Texture canvas to output to.");
var () name			 InputVariable 		?("Name of the input variable to get the value from.");
var () float		 InitialValue 		?("Initial counter value.");
var () float		 LeastSignificantDigitScrollRate;	// In digits per second
var () int			 NumberSpacing;
var () int			 PeriodSpacing;
var () int			 CommaSpacing;
var    float		 DigitScrollPositions[16];	// Percent through the 0-9 cycle
var () int			 MaxScrollGranularity;

function PostBeginPlay()
{
	local int i;
	super.PostBeginPlay();
	if(NumberSpacing==0)
		NumberSpacing=Digits[0].USize+Digits[0].USize/4;
	DigitScrollPositions[0]=InitialValue*100;
}

function Tick(float DeltaSeconds)
{
	local int i,x,y,digit,yOffset;
	local float f;
	
	OutputTexture.DrawClear(0);

	y=0;
	x=OutputTexture.USize-NumberSpacing;
	
	// Add in the spin amount:
	DigitScrollPositions[0]+=(LeastSignificantDigitScrollRate*DeltaSeconds);
	
	// Normalize the rest of the rotors
	for(i=0;i<PrintedDigits;i++)
	{
		// Compute the digit:
		if(i>0) DigitScrollPositions[i]=DigitScrollPositions[i-1]/10;

		// Render the digit:
		// Compute y offset:
		Digit= int(DigitScrollPositions[i])%10;

		f=((DigitScrollPositions[i]-int(DigitScrollPositions[i])));
		
		if(i>0)
		{
			if(f>=0.99)
			{
				f-=0.99;
				f*=100;
			} else f=0;
		} 
		f=1.0-f;

		yOffset=int(f*Digits[Digit].VSize);

		if(DecimalPoint!=none&&(i==2))
		{
			OutputTexture.DrawBitmap(x,y+Digits[0].VSize,0,0,0,0,DecimalPoint);
			x-=PeriodSpacing;
		} else if(Comma!=none&&(i-2)%3==0&&i!=2)
		{
			OutputTexture.DrawBitmap(x,y+Digits[0].VSize,0,0,0,0,Comma);
			x-=CommaSpacing;
		}

		OutputTexture.DrawBitmap(x,y+yOffset-Digits[Digit].VSize,0,0,0,0,Digits[((Digit-1)+10)%10]);
		OutputTexture.DrawBitmap(x,y+yOffset,0,0,0,0,Digits[Digit]);
		OutputTexture.DrawBitmap(x,y+yOffset+Digits[Digit].VSize,0,0,0,0,Digits[(Digit+1)%10]);

		x-=NumberSpacing;
	}

	if(DollarSign!=none)
	{
		OutputTexture.DrawBitmap(x,y+Digits[0].VSize,0,0,0,0,DollarSign);
		x-=NumberSpacing;
	}		
}

defaultproperties
{
     PrintedDigits=16
     LeastSignificantDigitScrollRate=20.000000
     NumberSpacing=0
	 MaxScrollGranularity=8
}
