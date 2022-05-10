/*-----------------------------------------------------------------------------
	ezAbsolv
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ezAbsolv extends dnKeyboardInput;

var() localized string			DefaultPriest;

// Simple word matches.
struct SSimpleMatch
{
	var() string MatchWords[10];
	var() string Responses[10];
	var() bool NeedsPredicate;
};
var()		SSimpleMatch		SimpleMatches[50];


function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function AttachDuke( DukePlayer NewDuke )
{
	Super.AttachDuke( NewDuke );
}

function DoneLerping()
{
	Super.DoneLerping();

	CreatePriestWindows();
}

function CreatePriestWindows()
{
	// Create the priest window.
	Windows[0].Name = "Priest Window";
	Windows[0].IsConsole = true;
	Windows[0].NoEdit = true;
	Windows[0].x = 16; Windows[0].y = 16;
	Windows[0].Width = 226; Windows[0].Height = 10;
	Windows[0].MaxLines = 4;
	Windows[0].TextLines[0] = DefaultPriest;
	NumWindows++;

	// Create the confessional.
	Windows[1].Name = "Confessional";
	Windows[1].IsConsole = true;
	Windows[1].x = 16; Windows[1].y = 80;
	Windows[1].Width = 226; Windows[1].Height = 2;
	Windows[1].MaxLines = 2;
	NumWindows++;

	// Create the submit button.
	Windows[2].Name = "Submit Button";
	Windows[2].IsButton = true;
	Windows[2].x = 13;
	Windows[2].y = 231;
	Windows[2].Width = 45;
	Windows[2].Height = 16;
	Windows[2].ClickWidth = 45;
	Windows[2].ClickHeight = 16;
	Windows[2].ButtonDownTex = texture'ezmail.emailexit';
	Windows[2].ButtonTex = texture'ezmail.emailsend';
	NumWindows++;

	CW = 1;
}

function MouseClick()
{
	Super.MouseClick();

	if ( ClickInside( Windows[2] ) )
		ButtonPressed(2);
}

function bool ClickInside( SWindowControl inWindow )
{
	if ( ((MouseX > inWindow.x) && (MouseX < inWindow.x + inWindow.ClickWidth)) &&
		 ((MouseY > inWindow.y) && (MouseY < inWindow.y + inWindow.ClickHeight)) )
		 return true;
	else
		return false;
}

function ButtonPressed( int WindowIndex )
{
	local int i;
	local string Question, Reply;

	if ( WindowIndex == 2 )
	{
		// Send the message to the priest.
		Windows[2].ButtonDownTime = 0.15;
		for (i=0; i<2; i++ )
		{
			if ( Windows[1].TextLines[i] != "" )
				Question = Question@Windows[1].TextLines[i];
		}

		Reply = GetPriestReply( Question );
		Windows[0].TextLines[0] = Reply;
	}
}

function string GetPriestReply( string Question )
{
	local int i, j, k, l, NumResponses, iPos;
	local string Reply, pQuestion, Predicate, CheckSubject, PuncMark;

	pQuestion = Caps( Question );

	// Check all simple matches.
	for ( j=0; j<50; j++ )
	{
		for ( l=0; l<10; l++ )
		{
			if ( SimpleMatches[j].MatchWords[l] == "" )
				continue;

			iPos = InStr( pQuestion, SimpleMatches[j].MatchWords[l] );
			if ( iPos > -1 )
			{
				// Find out how many possible responses there are.
				for ( k=0; k<10; k++ )
				{
					if ( SimpleMatches[j].Responses[k] == "" )
						continue;
					NumResponses++;
				}

				// Only approximate complete matches for need predicates.
				if ( SimpleMatches[j].NeedsPredicate )
				{
					// Get the remainder of the sentence from the subject on.
					Predicate = Right( Question, Len(Question)-iPos );

					// Get the subject they asked about.
					CheckSubject = Left( Predicate, Len(SimpleMatches[j].MatchWords[l]) );

					// Only match if exact.
					if ( CheckSubject ~= SimpleMatches[j].MatchWords[l] )
					{
						// Get a random prefix.
						i = rand(NumResponses);
						Reply = SimpleMatches[j].Responses[rand(NumResponses)];

						// Pull off the punctuation mark.
						PuncMark = Right( Reply, 1 );
						Reply = Left( Reply, Len(Reply)-1 );
						
						// Assemble the predicate.
						Predicate = Right( Predicate, Len(Predicate) - Len(CheckSubject) );

						// Convert person on the predicate.
						ConvertPerson( Predicate );

						// Strip punctuation from the predicate.
						StripPunc( Predicate );

						// Attach the predicate to the subject prefix.  Add the punctuation at the end.
						Reply = Reply$Predicate$PuncMark;

						// Send it off.
						return Reply;
					}
					else
					{
						// Didn't match exact, so we move on.
						Reply = "";
					}
				}
				else
				{
					// Return a random fixed reply.
					i = rand(NumResponses);
					Reply = SimpleMatches[j].Responses[rand(NumResponses)];
					return Reply;
				}
			}
		}
	}

	// No keyword.
	i = rand(7);
	switch (i)
	{
		case 0: Reply = "Do you feel intense religious stress?"; break;
		case 1: Reply = "What does that suggest to you?"; break;
		case 2: Reply = "I see."; break;
		case 3: Reply = "I'm not sure I understand you fully."; break;
		case 4: Reply = "Now, please clarify yourself."; break;
		case 5: Reply = "Can you elaborate on that?"; break;
		case 6: Reply = "That is quite interesting."; break;
		return Reply;
	}
}

// Converts person on an incoming phrase.
function ConvertPerson( out string inString )
{
	MatchReplace( inString, "YOU ARE", "I am" );
	MatchReplace( inString, "YOU'RE", "I am" );
	MatchReplace( inString, "YOU", "I" );
	MatchReplace( inString, "ME", "you" );
	if ( !MatchReplace( inString, "YOUR", "my" ) )
		MatchReplace( inString, "MY", "your" );
}

// Strips punctuation from the end of an incoming phrase.
function StripPunc( out string inString )
{
	local string PuncMark;
	
	PuncMark = Right( inString, 1 );
	if ( (PuncMark == ".") || (PuncMark == "!") || (PuncMark == "?") )
		inString = Left( inString, Len(inString)-1 );
}

// Tries to replace toMatch in inString with toReplaceWith.  Returns true if successful.
function bool MatchReplace( out string inString, string toMatch, string toReplaceWith )
{
	local int i;
	local string sleft, sright;

	i = InStr( Caps(inString), toMatch );
	if ( i > -1 )
	{
		// Get left part.
		sleft = Left( inString, i );

		// Get right part.
		sright = Right( inString, Len(inString)-(i+Len(toMatch)) );

		// Modify the string.
		inString = sleft$toReplaceWith$sright;
		return true;
	} else
		return false;
}

defaultproperties
{
	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
    HealthPrefab=HEALTH_NeverBreak
	ItemName="ezAbsolv Station"
	LodMode=LOD_Disabled
	Mesh=mesh'c_generic.ezmail_wall'
	MeshScreenIndex=1
	ScreenSurfaceIndex=-1
	SrcViewOffs=(X=0.0,Y=-15.0,Z=0.0)
	DstViewOffs=(X=0.0,Y=0.0,Z=0.0)
	ScreenCanvas=SmackerTexture'SMK8.emailsmack1KS'
	bPushable=false
	Grabbable=false

	MouseTexture=texture'ezmail.email_cursor'
	DefaultPriest="Welcome, my son, please tell me of your sins."

	SimpleMatches(0)=(MatchWords[0]="HOW",MatchWords[1]="WHO",MatchWords[2]="WHAT",MatchWords[3]="WHEN",Responses[0]="Why do you ask?",Responses[1]="Do you believe this affects your soul?",Responses[2]="What do you think about that?",Responses[3]="Are such questions on your mind often?",Responses[4]="Perhaps you should search your soul for the answer.")
	SimpleMatches(1)=(MatchWords[0]="WHY",Responses[0]="Why? Only God can answer that.",Responses[1]="Perhaps you should turn to scripture for the answer you seek.")
	SimpleMatches(2)=(MatchWords[0]="WHERE",Responses[0]="Where? Only God can say for sure.",Responses[1]="Perhaps in your soul you know the answer.")
	SimpleMatches(3)=(MatchWords[0]="NAME",Responses[0]="I don't care about names...please go on.",Responses[1]="Do names mean anything to you?",Responses[2]="Why do you mention names at all?")
	SimpleMatches(4)=(MatchWords[0]="THANK",Responses[0]="You're welcome.",Responses[1]="Blessed are you, my son.",Responses[2]="May God forgive you.")
	SimpleMatches(5)=(MatchWords[0]="CAUSE",MatchWords[1]="COS",MatchWords[2]="BECAUSE",Responses[0]="Is that the real reason?",Responses[1]="Don't any other reasons come to mind?",Responses[2]="Does that reason explain anything else?",Responses[3]="What other reasons might there be?")
	SimpleMatches(6)=(MatchWords[0]="SORRY",Responses[0]="God will forgive, my son.",Responses[1]="Apologies are not necessary. God forgives.",Responses[2]="It is good that you recognize your fault.",Responses[3]="We are all sinners, my son.")
	SimpleMatches(7)=(MatchWords[0]="HELLO",Responses[0]="How do you do. How may I help you?",Responses[1]="Hello, please tell me your sins.")
	SimpleMatches(8)=(MatchWords[0]="MAYBE",Responses[0]="You don't seem quite certain.",Responses[1]="Why the uncertain tone?",Responses[2]="Can't you be more positive?",Responses[3]="You aren't sure?")
	SimpleMatches(9)=(MatchWords[0]="YES",Responses[0]="Are you sure?",Responses[1]="What else do you think about that?")
	SimpleMatches(10)=(MatchWords[0]="FRIEND",Responses[0]="Do you have any friends?",Responses[1]="Do your friends worry you?",Responses[2]="Do they pick on you?",Responses[3]="Are your friends a source of anxiety?")
	SimpleMatches(11)=(MatchWords[0]="COMPUTER",Responses[0]="Do computers worry you?",Responses[1]="Are you talking about me in particular?",Responses[2]="Why do you mention computers?",Responses[3]="Don't you think computers can help you?")
	SimpleMatches(12)=(MatchWords[0]="CAN YOU",Responses[0]="Would it help you if I?",Responses[1]="What would you think if I?",NeedsPredicate=true)
	SimpleMatches(13)=(MatchWords[0]="CAN I",Responses[0]="Do you want to be able to?",Responses[1]="What would it mean if you could?",NeedsPredicate=true)
	SimpleMatches(14)=(MatchWords[0]="I DON'T",Responses[0]="Why don't you?",Responses[1]="Do you wish to be able to?",NeedsPredicate=true)
	SimpleMatches(15)=(MatchWords[0]="I FEEL",Responses[0]="Do you often feel?",Responses[1]="Do you think it is right to feel?",Responses[2]="Do you enjoy feeling?",NeedsPredicate=true)
	SimpleMatches(16)=(MatchWords[0]="ARE YOU",Responses[0]="Why are you interested whether I am?",Responses[1]="Would you prefer if I were?",Responses[2]="The Lord is.",NeedsPredicate=true)
	SimpleMatches(17)=(MatchWords[0]="YOU ARE",Responses[0]="Perhaps the Lord is.",Responses[1]="What makes you think I am?",Responses[2]="The Good Book says I am.",NeedsPredicate=true)
	SimpleMatches(18)=(MatchWords[0]="I AM",Responses[0]="Did you come to me because you are?",Responses[1]="How did you come to be?",Responses[2]="The Lord says it is sinful to be.",NeedsPredicate=true)
	SimpleMatches(20)=(MatchWords[0]="FUCK",MatchWords[1]="SHIT",MatchWords[2]="CUNT",MatchWords[3]="COCK",Responses[0]="Please don't use four-letter words.",Responses[1]="Profanity is not necessary.",Responses[2]="Do you use such foul language often?",Responses[3]="Do you like using obscene words?")
}
