//=============================================================================
// 
// FILE:			UDukeStatusBar.uc
// 
// AUTHOR:			Timothy L. Weisser
// 
// DESCRIPTION:		Same as MenuStatusBar, with differing display routines
// 
// MOD HISTORY: 
// 
//==========================================================================
class UDukeStatusBar extends UWindowWindow;

var string ContextHelp;
var localized string DefaultHelp;
var localized string DefaultIntroHelp;

function Created()
{
	Super.Created();
}

function SetHelp(string NewHelp)
{
	ContextHelp = NewHelp;
}

function Close(optional bool bByParent)
{
	Root.Console.CloseUWindow();
}

function BeforePaint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[F_Normal];
	Super.BeforePaint(C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	local GameInfo G;
	G = GetLevel().Game;
	
	C.DrawColor = LookAndFeel.EditBoxTextColor;

	if(ContextHelp != "")
		ClipText(C, 2, 2, ContextHelp);
	else if((G != None) && G.IsA('DukeIntro'))
		ClipText(C, 2, 2, DefaultIntroHelp);
	else
		ClipText(C, 2, 2, DefaultHelp);
		
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

}

defaultproperties
{
     DefaultHelp="Press ESC to return to the game"
     DefaultIntroHelp="Use the Game menu to start a new game."
}
