//=============================================================================
// VideoPoker. (NJS)
//=============================================================================
class VideoPoker expands CardGame;

#exec OBJ LOAD FILE=..\Sounds\a_zone1_vegas.dfx  PACKAGE=a_zone1_vegas

var () bool UseJokers;
var () int  Bet1Amount, Bet2Amount, Bet3Amount, MaxBet;	// Amount to bet for each of the bet buttons.

var () int CardsOffsetX, CardsOffsetY;		// Offset to start rendering the cards.
var () int CardSpacingX, CardSpacingY;		// Offset between the cards.

var () float UncoverTime;					// Time in seconds to uncover each card.

var () texture Numbers[10];					// The numbers.
var () int     NumberSpacing;				// Pixels between numbers
var () texture HeldTexture;					// Held texture.
var () int HeldOffsetX, HeldOffsetY;		// Offset of held relative to the card.
var () int BetAmountOffsetX, BetAmountOffsetY;	// Where to draw the bet amount.

var () int CreditsAmountOffsetX, CreditsAmountOffsetY;
var () int StartingCredits;

var () texture GameOverTexture;
var () int	   GameOverX, GameOverY;

var () texture WinTexture;
var () int	   WinX, WinY;

var (Payout) int JacksOrBetter;
var (Payout) int TwoPair;
var (Payout) int ThreeOfAKind;
var (Payout) int Straight;
var (Payout) int Flush;
var (Payout) int FullHouse;
var (Payout) int FourOfAKind;
var (Payout) int StraightFlush;
var (Payout) int RoyalFlush;

var (PayoutDisplay) int RoyalFlushAmountX, RoyalFlushAmountY,
						StraightFlushAmountX, StraightFlushAmountY,
						FourOfAKindAmountX, FourOfAKindAmountY,
						FullHouseAmountX, FullHouseAmountY,
						FlushAmountX, FlushAmountY,
						StraightAmountX, StraightAmountY,
						ThreeOfAKindAmountX, ThreeOfAKindAmountY,
						TwoPairAmountX, TwoPairAmountY,
						JacksOrBetterAmountX, JacksOrBetterAmountY;
var (PayoutDisplay) float WinFlashRate;

														
var Card Cards[5];	// The array of current cards
var byte Hold[5];
var bool Covering;

var int CurrentBet;
var int Credits;
var bool FlashWin, DrawWin;

var float NextWinFlash;

var enum EVPState
{
	VP_WaitingForDeal,
	VP_Dealing,			// Turning the cards over.
	VP_WaitingForDraw,
	VP_CoveringHeldCards,
	VP_Drawing,
	VP_WaitingForReset,
	VP_Resetting
} VPState;

struct TriggerInfo
{
	var Card		Cards[5];
	var EVPState	VPState;
	var int			CurrentBet;
	var byte		Hold[5];
	var bool		Covering;
};

var TriggerInfo		Triggers[32];
var int				NumTriggers;

var pawn			CurrentInstigator;

var bool			bPlayInsertCoinSound;
var float			PlayInsertCoinSoundTime;
var int				PlayInsertCoinSoundIndex;
var () sound		SoundInsertCoin[3];
var () Sound		SoundWin;
var () Sound		HoldSounds[2];
var () Sound		DealSounds[2];

function PreBeginPlay()
{
	NumTriggers = 0;

	Super.PreBeginPlay();

	MaxBet = 3;
}

// To begin play, just render the current state of the game.
function PostBeginPlay()
{
	Disable('Tick');
	Disable('Timer');

	FlashWin=false; 
	DrawWin=false; 
	CurrentBet=0; 
	Credits=StartingCredits;
	VPState=VP_WaitingForDeal;

	//DealCards();
	//RenderGame();
}

function Tick(float DeltaSeconds)
{
	if (bPlayInsertCoinSound)
	{
		PlayInsertCoinSoundTime += DeltaSeconds;

		if (PlayInsertCoinSoundTime >= 0.4)		// Hard coded hack
		{
			CurrentInstigator.PlaySound(SoundInsertCoin[PlayInsertCoinSoundIndex]);
			bPlayInsertCoinSound = false;
		}
	}

	if(FlashWin)
	{
		NextWinFlash-=DeltaSeconds;
		if(NextWinFlash<=0)
		{
			if(DrawWin) DrawWin=false;
			else DrawWin=true;
			NextWinFlash+=WinFlashRate;
			RenderGame();
		}
	} else
	{
		DrawWin=false;
		RenderGame();
		//Disable('tick');		
	}		
}

function int Payout() // Handle payout or lack of one.
{
	local int Deck[53];
	local int StraightFinder[14];
	
	local int i,j,k,l,m;
	local bool jokerUsed;

	// Clear the deck hash:	
	for(i=0;i<ArrayCount(Deck);i++)
		Deck[i]=0;
	
	for(i=0;i<ArrayCount(StraightFinder);i++)
		StraightFinder[0]=0;
		
	// Hash each card into the deck array:
	for(i=0;i<ArrayCount(Cards);i++)
	{
		Deck[Card2DeckIndex(Cards[i])]++;
		StraightFinder[Cards[i].value]++;
	}

	// Search for each of the combinations:

	// Look for a royal flush:
	// NJS: Look for all of the same suit:
	if(UseJokers&&bool(StraightFinder[0]))
		JokerUsed=false;
	else JokerUsed=true; // No joker to use.

	for(i=10;i<ArrayCount(StraightFinder);i++)
	{
		if(!bool(StraightFinder[i]))
		{
			if(!JokerUsed) JokerUsed=true;
			else break;
		}
	}
	
	if(i==ArrayCount(StraightFinder))
		if(bool(StraightFinder[1])||!JokerUsed)
			return RoyalFlush;
	
	// Look for a straight flush:
	
	// Look for four of a kind:
	for(i=1;i<ArrayCount(StraightFinder);i++)
	{
		if((StraightFinder[i]==4)||(UseJokers&&bool(StraightFinder[0])&&StraightFinder[i]==3))
			return FourOfAKind;
	}

	// Look for a full house:
	for(i=1;i<ArrayCount(StraightFinder);i++)
	{
		if(UseJokers&&bool(StraightFinder[0]))
			JokerUsed=false;
		else JokerUsed=true; // No joker to use.

		if(StraightFinder[i]==3)	// Match 3 without joker
		{
			// Joker can make a pair out of anything?
			if(!JokerUsed) return FullHouse;
			
			for(j=1;j<ArrayCount(StraightFinder);j++)
				if(i!=j)
					if(StraightFinder[j]==2)
						return FullHouse;

		} else if((StraightFinder[i]==2)&&(!JokerUsed)) // Match 3 with joker
		{
			// Match two without joker (already used it.)
			for(j=1;j<ArrayCount(StraightFinder);j++)
				if(i!=j)
					if(StraightFinder[j]==2)
						return FullHouse;
		}
	}
		
	// Look for a flush:
	j=Cards[0].suit;
	if(UseJokers&&bool(Deck[0]))
		JokerUsed=false;
	else JokerUsed=true; // No joker to use.
	
	for(i=0;i<ArrayCount(Cards);i++)
		if(j!=Cards[i].suit) 
		{
			// Possibly use my joker:
			if(JokerUsed) break;
			else JokerUsed=true;
		}
		
	// Did I find a flush?
	if(i==ArrayCount(Cards))
		return Flush;
			
	// Look for a straight:
	for(i=1;i<(ArrayCount(StraightFinder)-4);i++)
	{
		if(UseJokers&&bool(Deck[0]))
			JokerUsed=false;
		else JokerUsed=true; // No joker to use.
		
		for(j=i;j<i+5;j++)
		{
			if(!bool(StraightFinder[j]))
			{
				if(JokerUsed) break;
				else JokerUsed=true;
			}
		}
		
		// I found a straight:
		if(j==i+5) return Straight; 
	}

	// Look for three of a kind:
	for(i=1;i<ArrayCount(StraightFinder);i++)
	{
		if((StraightFinder[i]==3)||(UseJokers&&bool(StraightFinder[0])&&StraightFinder[i]==2))
			return ThreeOfAKind;
	}
	
	// Look for two pair:
	for(i=1;i<ArrayCount(StraightFinder);i++)
	{
		if(StraightFinder[i]==2)	// Have I found one pair already?
		{
			// If I'm using jokers and have a joker (and already have one pair) then 
			// I've already won.
			if(UseJokers&&bool(Deck[0]))
				return TwoPair;

			for(j=1;j<ArrayCount(StraightFinder);j++)
				if((j!=i)&&(StraightFinder[j]==2))
					return TwoPair;
		}
	}
												
	// Check for a natural pair:
	for(i=1;i<ArrayCount(StraightFinder);i++)
	{	
		if((StraightFinder[i]==2)||(UseJokers&&bool(Deck[0])&&(StraightFinder[i]==1)))
		if((DeckIndex2Value(i)>=Jack)||(DeckIndex2Value(i)==Ace)) // Have I found a pair?
			return JacksOrBetter;
	}
	
	return 0;
}

// Choose 5 random cards face down:
function DealCards()
{
	local int i, j;
	local bool Dupe;
	

	for(i=0;i<ArrayCount(Cards);i++)
	{
		Hold[i]=byte(false);
		do
		{
			Cards[i]=RandomCard(UseJokers);
		
			// Make sure we haven't already dealt this card:
			Dupe=false;
		
			for(j=0;j<i;j++)
			{
				if((Cards[j].value==Cards[i].value)&&((Cards[j].suit==Cards[i].suit)||(!bool(Cards[i].value)&&!bool(Cards[j].value))))
				{
					Dupe=true;
					break;
				}
			}
		} until(!Dupe);
	}	
}

function DealDrawnCards()
{
	local int i, j;
	local Card C, OldCards[5];
	local bool Dupe;
	
	for(i=0;i<ArrayCount(Cards);i++)
	{
		OldCards[i]=Cards[i];	// NJS: Is this safe?
	}
	
	for(i=0;i<ArrayCount(Cards);i++)
	{
		if(!bool(Hold[i]))	// If this isn't a card we're holding on to.
		{
			do
			{
				Dupe=false;
				C=RandomCard(UseJokers);
			
				for(j=0;j<ArrayCount(Cards);j++)
				{
					if((C.value==Cards[j].value)&&(C.suit==Cards[j].suit)||
					   (C.value==OldCards[j].value)&&(C.suit==OldCards[j].suit))
					{
						Dupe=true;
						break;
					} else if((C.value==0&&Cards[j].value==0)) // Can't have more than one joker
					{
						Dupe=true;
						break;
					}
				}

			} until(!Dupe);
			Cards[i]=C;
		}
	}
}

function UncoverCards(bool isCovering)
{
	Covering=isCovering;

	if(bool(UncoverTime)) 
		SetTimer(UncoverTime,false);
	else 
		timer();
}

function Timer(optional int TimerNum)
{
	local int CurrentCard, i;

	for(CurrentCard=0;CurrentCard<ArrayCount(Cards);CurrentCard++)
	{	
		if((Covering==bool(Cards[CurrentCard].front))
		&&((VPState!=VP_CoveringHeldCards)||(VPState==VP_CoveringHeldCards&&!bool(Hold[CurrentCard]))))
		{
			Cards[CurrentCard].front=byte(!Covering); 
			RenderGame();
		
			if (Cards[CurrentCard].front != 0 && DealSounds[0] != None)
				CurrentInstigator.PlaySound(DealSounds[0]);
			else if (Cards[CurrentCard].front == 0 && DealSounds[1] != None)
				CurrentInstigator.PlaySound(DealSounds[1]);

			UncoverCards(Covering);
			return;
		}
	}
	
	switch(VPState)
	{
		case VP_Dealing: VPState=VP_WaitingForDraw;   break;
		case VP_CoveringHeldCards: VPState=VP_Drawing;
								   DealDrawnCards();
								   UncoverCards(false);
								   break;

		case VP_Drawing: // Evenually put thingee here
						 VPState=VP_WaitingForReset;  
						 i=Payout()*CurrentBet;
						 if(bool(i))
						 {
						 	FlashWin=true; DrawWin=true; //Enable('Tick');
						 	NextWinFlash=WinFlashRate;
						 	CurrentInstigator.AddCash(i);
							CurrentInstigator.PlaySound(SoundWin);
						 }
						 
						 CurrentBet=0;
						 RenderGame();
						 break; 
						 
		case VP_Resetting: VPState=VP_WaitingForDeal; 
						   FlashWin=false; DrawWin=false;
						   DealCards();			
						   break;
	};	
}


function RenderGame()
{
	DrawTable();
	RenderCards();
	DrawStats();
	
	if(DrawWin)
		TableCanvas.DrawBitmap(WinX,WinY,0,0,0,0,WinTexture,true);
	
	if(VPState==VP_WaitingForReset)
		TableCanvas.DrawBitmap(GameOverX,GameOverY,0,0,0,0,GameOverTexture,true);
}

function RenderCards()
{
	local int i, x, y;
	
	x=CardsOffsetX; y=CardsOffsetY;
	for(i=0;i<ArrayCount(Cards);i++)
	{
		DrawCardStructure( x, y, Cards[i] );
	
		// If we're waiting for the draw, then draw the held bitmap
		if((VPState==VP_WaitingForDraw)&&bool(Hold[i])&&(HeldTexture!=none))
			TableCanvas.DrawBitmap(x+HeldOffsetX,y+HeldOffsetY,0,0,0,0,HeldTexture,true);
		
		x+=CardSpacingX; y+=CardSpacingY;
	}	
}

function DrawNumber( int x, int y, int num)
{
	local int i;
	local string NumString;
	
	NumString=""$num$"T";
	
	
	for(i=0;(Mid(NumString,i,1)!="T");i++)
	{
		TableCanvas.DrawBitmap(x,y,0,0,0,0,Numbers[Asc(Mid(NumString,i,1))-Asc("0")],true);
		x+=NumberSpacing;
	}	
}

function DrawStats()
{
	local int i;
	
	DrawNumber(BetAmountOffsetX,BetAmountOffsetY,currentBet);
	//DrawNumber(CreditsAmountOffsetX,CreditsAmountOffsetY,Credits);

	i=CurrentBet; 
	if(i<=0) i=1;
	
	DrawNumber(RoyalFlushAmountX, RoyalFlushAmountY, RoyalFlush*i);
	DrawNumber(StraightFlushAmountX, StraightFlushAmountY,StraightFlush*i);
	DrawNumber(FourOfAKindAmountX, FourOfAKindAmountY,FourOfAKind*i);
	DrawNumber(FullHouseAmountX, FullHouseAmountY,FullHouse*i);
	DrawNumber(FlushAmountX, FlushAmountY,Flush*i);
	DrawNumber(StraightAmountX, StraightAmountY,Straight*i);
	DrawNumber(ThreeOfAKindAmountX, ThreeOfAKindAmountY,ThreeOfAKind*i);
	DrawNumber(TwoPairAmountX, TwoPairAmountY,TwoPair*i);
	DrawNumber(JacksOrBetterAmountX, JacksOrBetterAmountY,JacksOrBetter*i);

}

// Toggle whether or not a card is held:
function ToggleHold(int i)
{
	if(VPState==VP_WaitingForDraw)
	{
		if(bool(Hold[i])) 
		{
			Hold[i]=byte(false); 
			CurrentInstigator.PlaySound(HoldSounds[1]);
		}
		else 
		{
			Hold[i]=byte(true);
			CurrentInstigator.PlaySound(HoldSounds[0]);
		}

		RenderGame();
	}
}

function bool CanBetAmount(int i, optional Pawn Instigator, optional bool bSayMsg)
{
	if(VPState!=VP_WaitingForReset && VPState!=VP_WaitingForDeal)
	{
		if (bSayMsg)
			Instigator.ClientMessage("You cannot bet right now.");

		return false;
	}

	if (Instigator != None)
	{
		if(Instigator.Cash <= 0)
		{
			if (bSayMsg)
				Instigator.ClientMessage("You don't have any money!");
			return false;
		}

		if (CurrentBet+i > MaxBet)
		{
			if (bSayMsg)
				Instigator.ClientMessage("You have already bet the maximum.");
			return false;
		}
	}

	return true;
}

function bool AddToBet(int i, optional Pawn Instigator)
{
	if (!CanBetAmount(i))
		return false;
		
	bPlayInsertCoinSound = true;
	PlayInsertCoinSoundTime = 0.0f;
	PlayInsertCoinSoundIndex = CurrentBet;

	if (Instigator != None)
		Instigator.AddCash(-1);

	CurrentInstigator = Instigator;

	if(VPState==VP_WaitingForReset)
	{
		VPState=VP_Resetting;
		UncoverCards(true);
		
		CurrentBet+=i;
	} 
	else if(VPState==VP_WaitingForDeal)
	{
		CurrentBet+=i;
		
		RenderGame();
	}

	return true;
}

// Input functions:
function DrawPressed() // Same button as deal 
{
	local int i;
	
	switch(VPState)
	{
		case VP_WaitingForDeal: 
			if(bool(CurrentBet))	// Did we bet something?
			{
				VPState=VP_Dealing;	// We are now dealing.
				UncoverCards(false);			// Start uncovering
			}
			break;
			
		case VP_WaitingForDraw:
			VPState=VP_CoveringHeldCards; //VP_Drawing;					
			UncoverCards(true);
			break;
		
		case VP_WaitingForReset:
			VPState=VP_Resetting;
			UncoverCards(true);
			break;
			
		default: break;
	}	
}

function CashOutPressed()
{
}

function bool Bet1Pressed(optional Pawn Instigator)
{
	return AddToBet(Bet1Amount, Instigator);
}

function Bet2Pressed()
{
	AddToBet(Bet2Amount);
}

function Bet3Pressed()
{
	AddToBet(Bet3Amount);
}
	
function ToggleCard1Pressed()
{
	ToggleHold(0);
}

function ToggleCard2Pressed()
{
	ToggleHold(1);
}

function ToggleCard3Pressed()
{
	ToggleHold(2);
}

function ToggleCard4Pressed()
{
	ToggleHold(3);
}

function ToggleCard5Pressed()
{
	ToggleHold(4);
}

function int GetKey()
{
	if (NumTriggers >= ArrayCount(Triggers))
		return 0;	// Oh well...

	CurrentBet=0; 

	Triggers[NumTriggers].VPState = VP_WaitingForDeal;
	Triggers[NumTriggers].CurrentBet = 0;

	NumTriggers++;

	return (NumTriggers-1);
}

function Activate(int Key)
{
	local int i;

	Enable('Timer');
	Enable('Tick');

	// Restore the states to this trigger
	if (Key < 0)
		Key = 0;
	else if (Key >= ArrayCount(Triggers))
		Key = ArrayCount(Triggers)-1;

	for (i=0; i<ArrayCount(Cards); i++)
		Cards[i] = Triggers[Key].Cards[i];

	for (i=0; i<ArrayCount(Hold); i++)
		Hold[i] = Triggers[Key].Hold[i];
	
	CurrentBet = Triggers[Key].CurrentBet;
	VPState = Triggers[Key].VPState;
	Covering = Triggers[Key].Covering;

	if (VPState == VP_WaitingForDeal)
	{
		FlashWin=false; 
		DrawWin=false; 
		//Disable('Tick');
		DealCards();
	}
	else
		UncoverCards(Covering);

	RenderGame();
}

function DeActivate(int Key)
{
	local int i;

	// Save the states for this trigger
	if (Key < 0)
		Key = 0;
	else if (Key >= ArrayCount(Triggers))
		Key = ArrayCount(Triggers)-1;

	for (i=0; i<ArrayCount(Cards); i++)
		Triggers[Key].Cards[i] = Cards[i];

	for (i=0; i<ArrayCount(Hold); i++)
		Triggers[Key].Hold[i] = Hold[i];

	Triggers[Key].CurrentBet = CurrentBet;
	Triggers[Key].VPState = VPState;
	Triggers[Key].Covering = Covering;

	Disable('Tick');
	Disable('Timer');
}

defaultproperties
{
     CardSpacingX=50
     JacksOrBetter=1
     TwoPair=2
     ThreeOfAKind=3
     Straight=4
     Flush=6
     FullHouse=9
     FourOfAKind=25
     StraightFlush=50
     RoyalFlush=250
	
	 SoundInsertCoin(0)=Sound'a_zone1_vegas.Casino.VPokerCoin02'
     SoundInsertCoin(1)=Sound'a_zone1_vegas.Casino.VPokerCoin02'
     SoundInsertCoin(2)=Sound'a_zone1_vegas.Casino.VPokerCoin01'
	 SoundWin=Sound'a_zone1_vegas.Casino.VPokerPay01'
	 HoldSounds(0)=Sound'a_zone1_vegas.Casino.VPokerHold01a'
	 HoldSounds(1)=Sound'a_zone1_vegas.Casino.VPokerHold02a'
	 DealSounds(0)=Sound'a_zone1_vegas.Casino.VPokerDeal19'
	 DealSounds(1)=None//Sound'a_zone1_vegas.Casino.VPokerHold02a'
}
