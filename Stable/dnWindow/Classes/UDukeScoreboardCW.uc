/*-----------------------------------------------------------------------------
	UDukeScoreboardCW
	Author: Scott Alden
-----------------------------------------------------------------------------*/
class UDukeScoreboardCW expands UDukePageWindow;

var	UDukeScoreboardGrid		Grid;
var UWindowVSplitter		VSplitter;
var UWindowWindow			FakeWindow;

var float					UpdateTime;

var localized string		FragGoal;
var	localized string		TimeLimit;
var localized string		TimeRemaining;
var localized string		LastKilledByString;
var localized string        RespawnString;

//=============================================================================
//Created
//=============================================================================
function Created()
{
	Super.Created();

	/*
	VSplitter = UWindowVSplitter( CreateWindow( class'UWindowVSplitter', 
												10, 10,
												WinWidth-10, WinHeight
									          )
	                            );
	*/

	Grid = UDukeScoreboardGrid( CreateWindow( class'UDukeScoreboardGrid', 
	     						   		      0, 0,
											  WinWidth, WinHeight * 0.6,
											  self ) );	

	/*
	FakeWindow = VSplitter.CreateWindow( class'UWindowWindow', 
 	     								 0, 0,
										 WinWidth, WinHeight * 0.6,
                                         self
								       );
	
	FakeWindow.HideWindow();

	VSplitter.TopClientWindow    = Grid;
	VSplitter.BottomClientWindow = FakeWindow;
	*/
}

//=============================================================================
//Resize
//=============================================================================
function Resized()
{
	Super.Resized();
	Grid.SetSize( WinWidth, WinHeight * 0.6 );	
}

//=============================================================================
//Paint
//=============================================================================
function Paint( Canvas C, float MouseX, float MouseY )
{
	local font			oldfont;	
	local float			XL, YL, W, H;
	local string		MyTime;
	local DukePlayer	P;
	local Texture       Texture;
	local float			XOffset, YOffset;
	local string        S;
	local float			Padding;

	local dnDeathmatchGameReplicationInfo GRI;

	Super.Paint( C, MouseX, MouseY );

	GRI = dnDeathmatchGameReplicationInfo( GetPlayerOwner().GameReplicationInfo );

	if ( GRI == None )
		return;

	oldfont		= C.Font;
	C.Font		= font'mainmenufontsmall';
	C.DrawColor = WhiteColor;
	Padding     = 3;

	TextSize( C, "TEST", XL, YL );
	
	XOffset = WinWidth / 2;
	XOffset -= XOffset / 2;

	if ( GetPlayerOwner().Health <= 0 )
	{
		TextSize( C, RespawnString, XL, YL );
		YOffset = WinHeight - YL;
		ClipText( C, XOffset - ( XL / 2 ), YOffset, RespawnString );
	}

	YOffset		= Grid.WinTop + Grid.WinHeight + 10;	

	if ( GRI.Fraglimit > 0 )
	{
		TextSize( C, FragGoal @ GRI.FragLimit, XL, YL );
		ClipText( C, XOffset - ( XL / 2 ), YOffset, FragGoal @ GRI.FragLimit );
		YOffset += YL + Padding;
	}
	
	if ( GRI.TimeLimit > 0 )
	{
		S = TimeLimit @ GRI.TimeLimit $ ":00";
		TextSize( C, S, XL, YL );
		ClipText( C, XOffset - ( XL / 2 ), YOffset, S );
		YOffset += YL + Padding;

		MyTime = GetTime( GRI.RemainingTime );
		S = TimeRemaining @ MyTime;
		TextSize( C, TimeRemaining @ "00:00:00", XL, YL );
		ClipText( C, XOffset - ( XL / 2 ), YOffset, S );		
		YOffset += YL + Padding;
	}


	// Last Killed By
	P = DukePlayer( GetPlayerOwner() );
	
	if ( P != None )
	{
		if ( P.LastKilledByPlayerName != "" )
		{
			if ( P.LastKilledByPlayerIcon != None )
			{
				Texture = P.LastKilledByPlayerIcon;

				XOffset = WinWidth / 2;
				XOffset += XOffset / 2;
				YOffset = Grid.WinTop + Grid.WinHeight + 10;
				
				// Header
				TextSize( C, LastKilledByString, XL, YL );
				ClipText( C, XOffset - ( XL / 2 ), YOffset, LastKilledByString );
				
				YOffset += YL + 10;

				// Icon border
				W = Texture.USize;
				H = Texture.VSize;
				LookAndFeel.Bevel_DrawSimpleBevel( self, C, 
												   XOffset - ( W / 2 ), YOffset, 
												   W, H );

				C.DrawColor = WhiteColor;

				// Icon
				W = Texture.USize;
				H = Texture.VSize;
				DrawStretchedTextureSegment( C, 
					                         XOffset - ( W / 2 ), YOffset,
											 Texture.USize, Texture.VSize,
											 0, 0, 
											 Texture.USize, Texture.VSize, 
											 Texture, 
											 1.0, true );

				YOffset += Texture.USize + 20;
				
				// Player Name
				TextSize( C, P.LastKilledByPlayerName, XL, YL );
				ClipText( C, XOffset - ( XL / 2 ), YOffset, P.LastKilledByPlayerName );

			}
		}
	}	
}

//=============================================================================
//AfterCreate
//=============================================================================
function AfterCreate()
{
	Super.AfterCreate();
	FillGrid();
}

//=============================================================================
//FillGrid
//=============================================================================
function FillGrid()
{	
	local PlayerReplicationInfo PRI;
	local int					i;
	local int					SavedRow;
	local bool					bSavedRow;

	if ( GetPlayerOwner().GameReplicationInfo == None )
		return;

	if ( Grid.SelectedItem != None )
	{
		SavedRow  = Grid.SelectedRow;
		bSavedRow = true;
	}

	Grid.EmptyItems();

	for ( i=0; i<32; i++ )
	{
		if ( GetPlayerOwner().GameReplicationInfo.PRIArray[i] != None )
		{
			PRI = GetPlayerOwner().GameReplicationInfo.PRIArray[i];

			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Grid.AddPlayerItem( PRI );				
			}
		}
	}

	Grid.Sort();

	if ( bSavedRow )
	{
		Grid.SelectRow( SavedRow );
	}
}

//=============================================================================
//Tick
//=============================================================================
event Tick( float TimeSeconds )
{
	UpdateTime -= TimeSeconds;

	if ( UpdateTime <= 0 )
	{
		FillGrid();
		UpdateTime = default.UpdateTime;
	}
}

//============================================================================
//TwoDigitString
//============================================================================
function string TwoDigitString( int Num )
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string( Num );
}

//============================================================================
//GetTime
//============================================================================
simulated function string GetTime( int ElapsedTime )
{
    local string S;
    local int Seconds, Minutes, Hours;

	Seconds = ElapsedTime;	
    Minutes = Seconds / 60;
	Hours   = Minutes / 60;
	Seconds = Seconds - (Minutes * 60);
	Minutes = Minutes - (Hours * 60);

	S = TwoDigitString(Hours)$":"$TwoDigitString(Minutes)$":"$TwoDigitString(Seconds);
    return S;
}

defaultproperties
{
	UpdateTime=1.0
	FragGoal="Frag Limit:"
	TimeLimit="Time Limit:"
	TimeRemaining="Time Remaining:"
	LastKilledByString="Last Killed By:"
	RespawnString="Press the Spacebar to Respawn"
	ClientAreaAlpha=1.0
}