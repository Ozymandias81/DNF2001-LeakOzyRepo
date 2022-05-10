//=============================================================================
// CardGame. (NJS)
//=============================================================================
class CardGame expands Dispatchers;

var () TextureCanvas TableCanvas;		// The canvas on which to play the card game
var () byte 		 BackgroundColor;	// Background color.

var () Texture CardBack;			// Image of the back of the card
var () Texture CardFront;			// Image of the front of the card
var () Texture JokerFront;			// Image of the front of the joker.

// Useful card constants:
const Joker = 0;
const Ace   = 1;
const Jack  = 11;
const Queen = 12;
const King  = 13;

// The array of red and black card letters and nummbers:
// 0=Joker, 1=ACE, 11=Jack(J), 12=Queen(Q), 13=King(K)
var () texture RedLetters[14];		// Joker, Ace,2,3,4,5,6,7,8,9,10,Jack,Queen,King
var () texture BlackLetters[14];	// Joker, Ace,2,3,4,5,6,7,8,9,10,Jack,Queen,King
var () texture AuxBitmap[14];		// Aux bitmap (Picture of king, queen, jack, nothing, etc)

// Useful constants for card suits:
const Spades   = 0;
const Clubs    = 1;
const Hearts   = 2;
const Diamonds = 3;

var () texture Suits[4];		   		// Spades, clubs, hearts, diamonds.
var () texture SmallSuits[4];	   		// Spades, clubs, hearts, diamonds.

var () int xValueOffset, yValueOffset;	// Offset from the upper left of the card to the 
										// value bitmap
var () int xSmallSuitOffset, 			// Offset from the upper left of the card to the	
		   ySmallSuitOffset;			// small suit bitmap.

var () int xSuitOffset,
 		   ySuitOffset;
 
var () int xAuxOffset,
		   yAuxOffset;

var () struct TableDecoration
{
	var () int x,y;
	var () texture DecorationTexture;
} TableDecorations[16];

// A general purpose function for storing cards:
struct Card
{
	var int suit;
	var int value;
	var byte front;
};

function int DeckIndex2Value( int index )
{
	if(index==0) return 0;	// Is this a joker?
	return ((index-1)%13)+1; // Ignore the suit.
}

// Returns the deck index for a given card:
function int Value2DeckIndex( int suit, int value )
{
	return (suit*13)+value;
}

// Converts a card into a deck index.
function int Card2DeckIndex(Card c)
{
	local int v;
	
	if(c.value==0) return 0;	// Joker is zero.
	
	return Value2DeckIndex(c.suit,c.value);
}

function Card RandomCard(bool UseJokers)
{
	local Card c;
	
	PickAgain:
	
	c.front=byte(false);
	c.suit=Rand(4);
	if(UseJokers) c.value=Rand(14);
	else c.value=Rand(13)+1;

	// Jokers is only valid when front and suit are zero:
	if(!bool(c.value)&&bool(c.suit))
		goto PickAgain;
		
	return c;
}

	    		   		   

function DrawTable()
{
	local int i;
	
	TableCanvas.DrawClear(BackgroundColor);
	
	for(i=0;i<ArrayCount(TableDecorations);i++)
	{
		if(TableDecorations[i].DecorationTexture!=none)
			TableCanvas.DrawBitmap(TableDecorations[i].x,TableDecorations[i].y,0,0,0,0,TableDecorations[i].DecorationTexture,true);
	}
}

// Returns true if the suit is black or false if the suit is red.
function bool isBlack( int suit )
{
	return ((suit==Spades)||(suit==Clubs));
}

// Draws the given card at the given position:
function DrawCard( int x, int y, bool front, int suit, int value )
{
	local texture temp;
	
	// Validate that I have avalid table canvas:
	if(TableCanvas==none)
		return;
	
	// Should I only draw the back of the card:
	if(!front)	
	{
		if(CardBack!=none)
			TableCanvas.DrawBitmap(x,  y, 0, 0, 0, 0, CardBack,true );
		
		return;
	}
	
	// Is this card a joker?
	if(value==Joker)
	{
		if(JokerFront!=none)
			TableCanvas.DrawBitmap(x,y,0,0,0,0,JokerFront,true);
			
		return;
	}
	
	// Draw the card's background:
	if(CardFront!=none)
		TableCanvas.DrawBitmap(x,y,0,0,0,0,CardFront,true);

	// Draw the card's value:
	if(isBlack(suit)) temp=BlackLetters[value];	// Grab the black version 
	else 			  temp=RedLetters[value];	// Grab the red version
	
	if(temp!=none)
		TableCanvas.DrawBitmap(x+xValueOffset,y+yValueOffset,0,0,0,0,temp);	
	
	// Draw the small suit:
	if(SmallSuits[suit]!=none)
		TableCanvas.DrawBitmap(x+xSmallSuitOffset,y+ySmallSuitOffset,0,0,0,0,SmallSuits[suit]);	

	// Draw the aux bitmap:
	if(AuxBitmap[value]!=none)
		TableCanvas.DrawBitmap(x+xAuxOffset,y+yAuxOffset,0,0,0,0,AuxBitmap[value]);
		
	// Draw the large suit:
	if(Suits[suit]!=none)
		TableCanvas.DrawBitmap(x+xSuitOffset,y+ySuitOffset,0,0,0,0,Suits[suit]);

}

// Draws a card by structure:
function DrawCardStructure( int x, int y, Card c )
{
	DrawCard(x,y,bool(c.front),c.suit,c.value);
}

defaultproperties
{
     BackgroundColor=97
     yValueOffset=3
     ySmallSuitOffset=18
     xSuitOffset=15
     ySuitOffset=30
     xAuxOffset=15
     yAuxOffset=3
}
