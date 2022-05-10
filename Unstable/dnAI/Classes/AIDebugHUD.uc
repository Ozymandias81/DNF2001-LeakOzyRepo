/*-----------------------------------------------------------------------------
	DukeHUD
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class AIDebugHUD extends DukeHUD;


/*-----------------------------------------------------------------------------
	PostRender
-----------------------------------------------------------------------------*/

simulated function PostRender( canvas C )
{
	local actor HitActor;

	Super.PostRender( C );
	HitActor = PlayerOwner.TraceFromCrosshair( 1024 );
	if( AIPawn( HitActor ) != None )
		AIWatchTarget = AIPawn( HitActor );
	DrawAIDebugHUD( C );
}

simulated function DrawAIDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j;

	if (DebugFont == None)
		DebugFont = C.CreateTTFont( "Tahoma", 10 );
	C.Font = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	XPos = 10*HUDScaleX;
	YPos = 64*HUDScaleY;

	// Weapon Status
	C.DrawColor.R = 200;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.SetPos( XPos, YPos );
	C.DrawText( "AI Status" );
	C.StrLen( "AI Status", XL, YL );
	C.DrawColor = WhiteColor;
	C.SetPos( XPos, YPos+YL );
	C.DrawText( "Class:" );
	C.SetPos( XPos, YPos+YL*2 );
	C.DrawText( "State:" );
	C.SetPos( XPos, YPos+YL*3 );
	C.DrawText( "Health:" );
	C.SetPos( XPos, YPos+YL*4 );
	C.DrawText( "Name:");
	C.SetPos( XPos, YPos+YL*5 );
	C.DrawText( "Tag:");
	C.SetPos( XPos, YPos+YL*6 );
	C.DrawText( "MoveTarget:");
	C.SetPos( XPos, YPos+YL*7 );
	C.DrawText( "Destination:");
	C.SetPos( XPos, YPos+YL*8 );
	C.DrawText("AnimSequence 0:");
	C.SetPos( XPos, YPos+YL*9 );
	C.DrawText("AnimSequence 1:");
	C.SetPos( XPos, YPos+YL*10 );
	C.DrawText("AnimSequence 2:");
	C.SetPos( XPos, YPos+YL*11 );
	C.DrawText("Rotation:");
	C.SetPos( XPos, YPos+YL*12 );
	C.SetPos( XPos, YPos + YL * 13 );
	C.DrawText( "HeadTrackingActor:" );

	if( AIWatchTarget.IsA( 'EDFHeavyWeps' ) )
	{
		C.SetPos( XPos, YPos+YL*14 );
		C.DrawText( "EMPCount:");
	}

	C.StrLen( "PADDING PADDING PAD", XL2, YL2 );
	C.SetPos( XPos + XL2, YPos+YL );
	C.DrawText( AIWatchTarget.Class );
	C.SetPos( XPos + XL2, YPos+YL*2 );
	C.DrawText( AIWatchTarget.GetStateName() );
	C.SetPos( XPos + XL2, YPos+YL*3 );
	C.DrawText( AIWatchTarget.Health );
	C.SetPos( XPos + XL2, YPos+YL*4 );
	C.DrawText( AIWatchTarget.Name );
	C.SetPos( XPos + XL2, YPos+YL*5 );
	C.DrawText( AIWatchTarget.Tag );
	C.SetPos( XPos + XL2, YPos+YL*6 );
	C.DrawText( AIWatchTarget.MoveTarget );
	C.SetPos( XPos + XL2, YPos+YL*7 );
	C.DrawText( AIWatchTarget.Destination );
	C.SetPos( XPos + XL2, YPos+YL*8 );
	C.DrawText( AIWatchTarget.GetSequence( 0 ) );
	C.SetPos( XPos + XL2, YPos+YL*9 );
	C.DrawText( AIWatchTarget.GetSequence( 1 ) );
	C.SetPos( XPos + XL2, YPos+YL*10 );
	C.DrawText( AIWatchTarget.GetSequence( 2 ) );
	C.SetPos( XPos + XL2, YPos+YL*11 );
	C.DrawText( AIWatchTarget.Rotation );
	C.SetPos( XPos + XL2, YPos+YL*13 );
	if( AIWatchTarget.HeadTrackingActor != None )
	{
		C.DrawText( AIWatchTarget.HeadTrackingActor );
	}
	if( AIWatchTarget.IsA( 'EDFHeavyWeps' ) )
	{
		C.SetPos( XPos + XL2, YPos+YL*14 );
		C.DrawText( EDFHeavyWeps( AIWatchTarget ).EMPCount );
	}
}


