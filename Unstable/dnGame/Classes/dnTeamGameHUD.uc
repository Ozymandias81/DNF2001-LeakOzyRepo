class dnTeamGameHUD extends dnDeathmatchGameHUD;

var		localized string		CanPlantBombString;
var		localized string		HasBombString;

//============================================================================
//PostRender
//============================================================================
simulated function PostRender( Canvas C )
{
	Super.PostRender( C );

	if ( PlayerOwner.bCanPlantBomb )
	{
		DrawPlantBomb( C );	
	}
	
	if ( 
		 ( PlayerOwner.PlayerReplicationInfo != None ) && 
		 ( PlayerOwner.PlayerReplicationInfo.bHasBomb )
	   )
	{
		DrawHasBomb( C );
	}

	DrawMyClass( C );
	DrawRemainingTime( C );

	/*
	// Team Game Synopsis
	if ( PlayerPawn( Owner ) != None )
	{
		if ( ( PlayerPawn( Owner ).GameReplicationInfo != None ) && 
             ( PlayerPawn( Owner ).GameReplicationInfo.bTeamGame ) )
        {
		    DrawTeamGameSynopsis( C );
        }
	}
	*/
}

//============================================================================
//FirstDraw
//============================================================================
simulated function FirstDraw(canvas C)
{
	Super.FirstDraw( C );

	IndexItems[11] = spawn(class'HUDIndexItem_Credits');
}

//============================================================================
//DrawPlantBomb
//============================================================================
simulated function DrawPlantBomb( Canvas C )
{
	local int   i;
	local float XL, YL;

	C.DrawColor    = TextColor;
	C.bCenter      = true;
	C.Font         = MyFont;
	
	C.StrLen("TEST", XL, YL);
	
	C.SetPos(0, 0.75 * C.ClipY - (3*YL) );
	C.DrawText( CanPlantBombString );

	C.bCenter      = false;
	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}


//============================================================================
//DrawHasBomb
//============================================================================
simulated function DrawHasBomb( Canvas C )
{
	local int   i;
	local float XL, YL;

	C.DrawColor    = TextColor;	
	C.Font         = MyFont;
	
	C.StrLen( HasBombString, XL, YL );
	
	C.SetPos( C.ClipX - XL, C.ClipY - (2*YL) );
	C.DrawText( HasBombString );

	C.bCenter      = false;
	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}

//============================================================================
//DrawMyClass
//============================================================================
simulated function DrawMyClass( Canvas C )
{
	local int   i;
	local float XL, YL;
		
	if ( DukePlayer( Owner ) == None )
		return;

	C.DrawColor    = TextColor;	
	C.Font         = MyFont;
	
	C.StrLen( DukePlayer( Owner ).MyClassName, XL, YL );
	
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawText( DukePlayer( Owner ).MyClassName );

	C.bCenter      = false;
	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}

//============================================================================
//DrawRemainingTime
//============================================================================
simulated function DrawRemainingTime( Canvas C )
{
	local int   i;
	local float XL, YL;

	C.DrawColor    = TextColor;
	C.Font         = MyFont;
	
	C.StrLen( GameDMStats[3].Value, XL, YL );
	
	C.SetPos( C.ClipX - XL - 10, 0.9 * C.ClipY );
	C.DrawText( GameDMStats[3].Value );

	C.DrawColor.R  = 255;
	C.DrawColor.G  = 255;
	C.DrawColor.B  = 255;
}

//============================================================================
//DrawTeamGameSynopsis
//============================================================================
simulated function DrawTeamGameSynopsis( Canvas C )
{
	local dnTeamInfo TI;
	local float XL, YL;

	foreach AllActors( class'dnTeamInfo', TI )
	{
		if ( TI.Size > 0 )
		{
			C.Font			= SmallFont;
			C.DrawColor	= TeamColor[TI.TeamIndex]; 
			C.StrLen( TeamName[TI.TeamIndex], XL, YL );
			C.SetPos( 0, 100 + 16 * TI.TeamIndex );
			C.DrawText( TeamName[TI.TeamIndex], false );
			C.SetPos( XL, 100 + 16 * TI.TeamIndex );
			C.DrawText( int( TI.Score ), false );
		}
	}

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}


defaultproperties
{
	CanPlantBombString="Set us up the Bomb."
	HasBombString="You have the bomb."
}